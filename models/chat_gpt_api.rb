require 'net/http'
require 'uri'
require 'json'
require 'dotenv'

module RubyOpenAI
  Dotenv.load

  module Errors
    class NotFound < StandardError; end
    class Unauthorized < StandardError; end
  end

  HTTP_ERROR = {
    401 => Errors::Unauthorized,
    404 => Errors::NotFound
  }.freeze

  class ChatGPTAPI
    API_ENDPOINT = 'https://api.openai.com/v1/chat/completions'
    API_KEY = ENV['OPENAI_API_KEY']

    attr_reader :messages

    def initialize(system_content = nil)
      @messages = [{
        'role' => 'system',
        'content' => system_content || 'You are a helpful assistant.'
      }]
    end

    def send_message(message_content)
      update_messages('user', message_content)
      response = make_request
      handle_errors(response)
      parsed_response = JSON.parse(response.body)
      update_messages('assistant', parsed_response['choices'][0]['message']['content'])
      parsed_response
    end

    def update_messages_from_series(data_series)
      data_series.each do |data|
        role = data[:is_assistant] ? 'assistant' : 'user'
        content = data[:messages]
        @messages << {
          'role' => role,
          'content' => content
        }
      end
    end

    def update_messages(role, content)
      @messages << {
        'role' => role,
        'content' => content
      }
    end

    private


    def make_request
      uri = URI.parse(API_ENDPOINT)
      request = build_request(uri)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    def build_request(uri)
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/json'
      request['Authorization'] = "Bearer #{API_KEY}"
      request.body = JSON.dump({
        'model' => 'gpt-3.5-turbo',
        'n' => 1,
        'messages' => @messages
      })
      request
    end

    def handle_errors(response)
      if HTTP_ERROR.keys.include?(response.code.to_i)
        raise HTTP_ERROR[response.code.to_i], response.message
      end
    end
  end
end
