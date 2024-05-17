# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'dotenv'

# Module to interact with OpenAI's API
module RubyOpenAI
  # Custom error classes
  # module Errors
  #   class NotFound < StandardError; end
  #   class Unauthorized < StandardError; end
  # end

  # # HTTP error mappings
  # HTTP_ERROR = {
  #   401 => Errors::Unauthorized,
  #   404 => Errors::NotFound
  # }.freeze

  # Class for interfacing with ChatGPT API
  class ChatGptStreaming
    Dotenv.load
    API_ENDPOINT = 'https://api.openai.com/v1/chat/completions'
    API_KEY = ENV['OPENAI_API_KEY']

    # def self.send_message(system_content, history_messages, temperature)
    #   response = make_request(system_content, history_messages, temperature)
    #   handle_errors(response)
    #   JSON.parse(response.body)
    # end

    def self.make_request(system_content, history_messages, temperature)
      uri = URI.parse(API_ENDPOINT)
      requests = build_request(uri, system_content, history_messages, temperature)
      print 'request:', requests
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request requests do |response|
          print 'From open Ai', response.read_body
        end
        # http.request(requests)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def self.build_request_body(system_content, history_messages, temperature)
      # history_messages.
      # 'gpt-3.5-turbo'
      puts 'test:', JSON.dump(
        {
          'model' => 'gpt-4o',
          'stream' => true,
          'temperature' => temperature || 0.6,
          'messages' =>
            history_messages.unshift({
                                       'role' => 'system',
                                       'content' => system_content
                                     })

        }
      )
      JSON.dump(
        {
          'model' => 'gpt-4o',
          'temperature' => temperature || 0.6,
          'stream' => true,
          'messages' =>
            history_messages.unshift({
                                       'role' => 'system',
                                       'content' => system_content
                                     })
        }
      )
    end
    # rubocop:enable Metrics/MethodLength

    def self.build_request(uri, system_content, history_messages, temperature)
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/json'
      # request.content_type = 'text/event-stream'
      request['Authorization'] = "Bearer #{API_KEY}"
      request.body = build_request_body(system_content, history_messages, temperature)
      request
    end

    def self.handle_errors(response)
      raise HTTP_ERROR[response.code.to_i], response.message if HTTP_ERROR.keys.include?(response.code.to_i)
    end
  end
end
