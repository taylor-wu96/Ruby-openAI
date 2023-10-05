require 'roda'
require 'json'
require 'figaro'
require 'jwt'
Figaro.application = Figaro::Application.new(environment: ENV['RACK_ENV'], path: File.expand_path('config/application.yml'))
Figaro.application.load
require_relative '../models/chat_gpt_api'
require_relative '../models/user'
require_relative '../models/conversation'
require_relative '../models/chat'
require_relative '../repositories/user_repository'
require_relative '../repositories/conversation_repository'
require_relative '../repositories/chat_repository'
require_relative '../services/conversation_service'
require_relative 'auth_controller'
require_relative 'chat_controller'

class ChatService < Roda
  plugin :json
  JWT_SECRET = ENV['JWT_SECRET']
  route do |r|
    r.root do
      'Welcome to Chat Service!'
    end
    r.on 'api/v1/auth' do
      r.run AuthController
    end
    r.on 'api/v1' do
      # Extract the JWT from the Authorization header
      auth_header = r.env['HTTP_AUTHORIZATION']
      token = auth_header.split(' ').last if auth_header && auth_header.start_with?('Bearer ')

      # If there's no token or it doesn't start with "Bearer", halt immediately
      unless token
        r.halt 403, { message: 'Not authorized' }.to_json
      end

      begin
        decoded_token = JWT.decode(token, JWT_SECRET, true, { algorithm: 'HS256' })
        @auth_account = decoded_token[0]['user_id']
      rescue JWT::DecodeError
        r.halt 403, { message: 'Not authorized' }.to_json
      end
      r.run ChatController
    end
  end
end
