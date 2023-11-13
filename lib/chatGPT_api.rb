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

    def self.send_message(message_content)
      response = make_request(message_content)
      handle_errors(response)
      JSON.parse(response.body)
    end

    def self.make_request(message_content)
      uri = URI.parse(API_ENDPOINT)
      request = build_request(uri, message_content)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def self.build_request_body(message_content)
      JSON.dump(
        {
          'model' => 'gpt-3.5-turbo',
          'n' => 1,
          'messages' => [
            {
              'role' => 'user',
              'content' => message_content
            }
          ]
        }
      )
    end
    # rubocop:enable Metrics/MethodLength

    def self.build_request(uri, message_content)
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/json'
      request['Authorization'] = "Bearer #{API_KEY}"
      request.body = build_request_body(message_content)
      request
    end

    def self.handle_errors(response)
      raise HTTP_ERROR[response.code.to_i], response.message if HTTP_ERROR.keys.include?(response.code.to_i)
    end
  end
end

response = RubyOpenAI::ChatGPTAPI.send_message('Hello!')
puts response['choices']
