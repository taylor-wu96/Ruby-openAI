# frozen_string_literal: true

require 'roda'
require 'json'

module RubyOpenAI
  # Backend web app controller
  class App < Roda
    # api using
    plugin :all_verbs
    plugin :halt
    plugin :default_headers

    route do |r|
      r.get 'api' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        { success: true, message: 'Welcome to ruby openAI world' }.to_json
      end

      r.post 'openai' do
        data = JSON.parse(r.body.read)
        # TODO: = Todo.create(data)
        response.status = 201
        puts 'Data: ', data
        todo.to_json
      end
    end
  end
end
