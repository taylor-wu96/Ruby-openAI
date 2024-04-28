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
    PRACTICAL_TASK = 'practical'
    CREATVIE_TASK = 'creative'
    route do |r|
      r.get 'api' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        { success: true, message: 'Welcome to ruby openAI world' }.to_json
      end

      r.post 'update_ip' do
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        new_chat = if Chat.first(user_id:).nil?
                     Chat.create(user_id:)
                   else
                     Chat.first(user_id:)
                   end
        new_chat.update(ip_address: data['ip_address'])
        response.status = 201
        new_chat.attributes.to_json
      end

      r.post 'submit-task' do
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        new_chat = if Chat.first(user_id:).nil?
                     Chat.create(user_id:)
                   else
                     Chat.first(user_id:)
                   end

        unless Task.where(chat_id: new_chat.id).empty?
          task = Task.where(chat_id: new_chat.id).first
          task.update(final_submission: data['task_description'])
          return task.attributes.to_json
        end
        response.status = 201
        return { success: false, message: 'No task to update' }.to_json
      end

      r.post 'openai' do
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        temp = data['temp'] || 0.7
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

        response_data = ChatGptAPI.send_message(data['system_content'], history_messages, temp)
        # puts 'Data: ', response_data
        chatbot_message = Message.create(chat_id: new_chat.id, role: 'assistant',
                                         response: response_data['choices'][0]['message']['content'])
        # new_message = Message.create(chat_id: new_chat.id, role: 'user', response: data['message_content'])
        response.status = 201
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

      r.post 'behavior' do
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        new_chat = if Chat.first(user_id:).nil?
                     Chat.create(user_id:)
                   else
                     Chat.first(user_id:)
                   end
        user_behavior = Behavior.create(chat_id: new_chat.id, content: data['content'], type: data['type'],
                                        target_object: data['target_object'], log_time: data['log_time'])
        response.status = 201
        user_behavior.attributes.to_json
      end

      r.get 'behavior_log' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        user_id = r.params['user_id'] || 'anonymous'
        chat_id = Chat.first(user_id:).id

        Behavior.where(chat_id:).map(&:values).to_json
      end

      r.get 'random-task' do
        # print Task.all
        # print Task.all.map(:task_name)
        response['Content-Type'] = 'application/json'
        response.status = 200
        user_id = r.params['user_id'] || 'anonymous'
        new_chat = if Chat.first(user_id:).nil?
                     Chat.create(user_id:)
                   else
                     Chat.first(user_id:)
                   end
        unless Task.where(chat_id: new_chat.id).empty?
          task = Task.where(chat_id: new_chat.id).first
          return task.attributes.to_json
        end
        if Task.all.empty?
          task = Task.create(task_name: CREATVIE_TASK, chat_id: new_chat.id)
          return task.attributes.to_json
        else
          numOfPracticalTask = Task.all.map(&:task_name).count(PRACTICAL_TASK)
          numOfCreativeTask = Task.all.map(&:task_name).count(CREATVIE_TASK)

          if numOfPracticalTask >= numOfCreativeTask
            task = Task.create(task_name: CREATVIE_TASK, chat_id: new_chat.id)
            return task.attributes.to_json
          else
            task = Task.create(task_name: PRACTICAL_TASK, chat_id: new_chat.id)
            return task.attributes.to_json
          end
        end
      end
      r.post 'task' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        user_id = r.params['user_id'] || 'anonymous'
        new_chat = if Chat.first(user_id:).nil?
                     Chat.create(user_id:)
                   else
                     Chat.first(user_id:)
                   end
        unless Task.where(chat_id: new_chat.id).empty?
          task = Task.where(chat_id: new_chat.id).first
          return task.attributes.to_json
        end
      end

      r.get 'task-to-csv' do
        # response['Content-Type'] = 'application/json'
        user_id = r.params['user_id'] || 'anonymous'
        if user_id == 'all'
          data = Task.all.map(&:values)
          headers = data.first.keys.map(&:to_s)
          content = [headers.to_csv] + data.map { |row| row.values.to_csv }
          # File.write('./export.csv', content.join)
          return content.join
        end
        unless Chat.first(user_id:).nil?
          chat_id = Chat.first(user_id:).id
          data = Task.where(chat_id:).map(&:values)
          headers = data.first.keys.map(&:to_s)
          content = [headers.to_csv] + data.map { |row| row.values.to_csv }
          # File.write('./export.csv', content.join)
          return content.join
        end

        'No data' if Chat.first(user_id:).nil? # return no data
      end

      r.get 'behavior-to-csv' do
        response['Content-Type'] = 'text/csv'
        response.status = 200

        user_id = r.params['user_id'] || 'anonymous'
        if user_id == 'all'
          data = Behavior.all.map(&:values)
          headers = data.first.keys.map(&:to_s)
          content = [headers.to_csv] + data.map { |row| row.values.to_csv }
          # File.write('./export.csv', content.join)
          return content.join
        end
        unless Chat.first(user_id:).nil?
          chat_id = Chat.first(user_id:).id
          data = Behavior.where(chat_id:).map(&:values)
          headers = data.first.keys.map(&:to_s)
          content = [headers.to_csv] + data.map { |row| row.values.to_csv }
          # File.write('./export.csv', content.join)
          return content.join
        end

        'No data' if Chat.first(user_id:).nil? # return no data
      end

      r.get 'message-to-csv' do
        response['Content-Type'] = 'text/csv'
        response.status = 200

        user_id = r.params['user_id'] || 'anonymous'
        if user_id == 'all'
          data = Message.all.map(&:values)
          headers = data.first.keys.map(&:to_s)
          content = [headers.to_csv] + data.map { |row| row.values.to_csv }
          # File.write('./export.csv', content.join)
          return content.join
        end
        unless Chat.first(user_id:).nil?
          chat_id = Chat.first(user_id:).id
          data = Message.where(chat_id:).map(&:values)
          headers = data.first.keys.map(&:to_s)
          content = [headers.to_csv] + data.map { |row| row.values.to_csv }
          # File.write('./export.csv', content.join)
          return content.join
        end

        'No data' if Chat.first(user_id:).nil? # return no data
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
