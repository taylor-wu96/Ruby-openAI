require 'net/http'
require 'uri'
require 'json'
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
    API_KEY = Rails.application.credentials.openai[:api_key]

    def self.send_message(message_content)
      response = make_request(message_content)
      handle_errors(response)
      JSON.parse(response.body)
    end

    private

    def self.make_request(message_content)
      uri = URI.parse(API_ENDPOINT)
      request = build_request(uri, message_content)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    def self.build_request(uri, message_content)
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/json'
      request['Authorization'] = "Bearer #{API_KEY}"
      request.body = JSON.dump({
        'model' => 'gpt-3.5-turbo',
        'n' => 3,
        'messages' => [
          {
            'role' => 'system',
            'content' => 'You are a helpful assistant.'
          },
          {
            'role' => 'user',
            'content' => message_content
          }
        ]
      })
      request
    end

    def self.handle_errors(response)
      if HTTP_ERROR.keys.include?(response.code.to_i)
        raise HTTP_ERROR[response.code.to_i], response.message
      end
    end
  end
end
