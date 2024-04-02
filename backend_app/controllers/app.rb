# frozen_string_literal: true

require 'roda'
require 'json'

module RubyOpenAI
  # Backend web app controller
  class App < Roda
    # api using
    plugin :all_verbs
    plugin :public, root: 'dist'
    plugin :render
    plugin :halt
    # plugin :default_headers

    route do |r|
      r.get 'api' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        { success: true, message: 'Welcome to ruby openAI world' }.to_json
      end

      r.post 'openai' do
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        new_chat = if Chat.first(user_id:).nil?
                     Chat.create(user_id:)
                   else
                     Chat.first(user_id:)
                   end
        puts new_chat.attributes
        user_message = Message.create(chat_id: new_chat.id, role: 'user', response: data['message_content'])

        history_messages = Message.where(chat_id: new_chat.id).map(&:values).map do |item|
          {
            role: item[:role],
            content: item[:response]
          }
        end
        puts 'testable answer:', history_messages

        response_data = ChatGptAPI.send_message(data['system_content'], history_messages)
        # puts 'Data: ', response_data
        chatbot_message = Message.create(chat_id: new_chat.id, role: 'assistant',
                                         response: response_data['choices'][0]['message']['content'])
        # new_message = Message.create(chat_id: new_chat.id, role: 'user', response: data['message_content'])
        chatbot_message.attributes.to_json

        # response_data = ChatGptAPI.send_message(data['system_content'], data['message_content']).to_json
        # # TODO: = Todo.create(data)
        # response.status = 201
        # test_json = JSON.parse(response_data)
        # puts 'Data: ', response_data
        # puts test_json['choices'][0]['message']['content']

        # response_data.to_json
      end
      r.get 'messages' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        user_id = r.params['user_id'] || 'anonymous'
        chat_id = Chat.first(user_id:).id

        Message.where(chat_id:).map(&:values).to_json
      end

      # frontend api
      r.public
      r.root do
        File.read(File.join('dist', 'index.html'))
      end

      r.get [String, true], [String, true], [true] do |_parsed_request|
        File.read(File.join('dist', 'index.html'))
      end
    end
  end
end
