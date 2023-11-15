# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'dotenv'

# Module to interact with OpenAI's API
module RubyOpenAI
  Dotenv.load

  # Custom error classes
  module Errors
    class NotFound < StandardError; end
    class Unauthorized < StandardError; end
  end

  # HTTP error mappings
  HTTP_ERROR = {
    401 => Errors::Unauthorized,
    404 => Errors::NotFound
  }.freeze

  # Class for interfacing with ChatGPT API
  class ChatGptAPI
    API_ENDPOINT = 'https://api.openai.com/v1/chat/completions'
    API_KEY = ENV['OPENAI_API_KEY']

    def self.send_message(system_content, message_content)
      response = make_request(system_content, message_content)
      handle_errors(response)
      JSON.parse(response.body)
    end

    def self.make_request(system_content, message_content)
      uri = URI.parse(API_ENDPOINT)
      request = build_request(uri, system_content, message_content)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def self.build_request_body(system_content, message_content)
      JSON.dump(
        {
          'model' => 'gpt-4',
          'temperature' => 0.3,
          'messages' => [
            {
              'role' => 'system',
              'content' => system_content
            },
            {
              'role' => 'user',
              'content' => message_content
            }
          ]
        }
      )
    end
    # rubocop:enable Metrics/MethodLength

    def self.build_request(uri, system_content, message_content)
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/json'
      request['Authorization'] = "Bearer #{API_KEY}"
      request.body = build_request_body(system_content, message_content)
      request
    end

    def self.handle_errors(response)
      raise HTTP_ERROR[response.code.to_i], response.message if HTTP_ERROR.keys.include?(response.code.to_i)
    end
  end
end
