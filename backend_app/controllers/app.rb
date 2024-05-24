# frozen_string_literal: true

require 'roda'
require 'json'
require 'net/http'
require 'uri'

module RubyOpenAI
  # Backend web app controller
  class App < Roda
    # api using
    plugin :all_verbs
    plugin :public, root: 'dist'
    plugin :render
    plugin :halt
    plugin :streaming
    # plugin :default_headers
    PRACTICAL_TASK = 'practical'
    CREATVIE_TASK = 'creative'
    BASE_PROMPT = 'Act as a travel advisor and provide technical insight on travel aspect suggestions. Write in active voice to make sentences more engaging and easier to follow. The user you are responding to needs to complete a writing task about airports. As the strict advisor, you must keep your replies less than 100 words and briefer is better.'
    TEST_LOREM = 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'

    WELCOME_MESSAGE = 'Hello, I am your AI assistant. I have abundant traveling experiences and knowledge. How can I help you today?'
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
          RandomQueue.new(Api.config).finish_task(task)
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
        Message.create(chat_id: new_chat.id, role: 'user', response: data['message_content'])

        history_messages = Message.where(chat_id: new_chat.id).map(&:values).map do |item|
          {
            role: item[:role],
            content: item[:response]
          }
        end
        puts 'testable answer:', history_messages

        response_data = ChatGptAPI.send_message(BASE_PROMPT, history_messages, temp)
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
        new_chat = if Chat.first(user_id:).nil?
                     Chat.create(user_id:)
                   else
                     Chat.first(user_id:)
                   end
        if Message.where(chat_id: new_chat.id).all.empty?
          Message.create(chat_id: new_chat.id, role: 'assistant', response: WELCOME_MESSAGE)
        end

        Message.where(chat_id: new_chat.id).map(&:values).to_json
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

      # old version of random task
      # r.get 'random-task' do
      #   # print Task.all
      #   # print Task.all.map(:task_name)
      #   response['Content-Type'] = 'application/json'
      #   response.status = 200
      #   user_id = r.params['user_id'] || 'anonymous'
      #   new_chat = if Chat.first(user_id:).nil?
      #                Chat.create(user_id:)
      #              else
      #                Chat.first(user_id:)
      #              end
      #   unless Task.where(chat_id: new_chat.id).empty?
      #     task = Task.where(chat_id: new_chat.id).first
      #     return task.attributes.to_json
      #   end
      #   if Task.all.empty?
      #     task = Task.create(task_name: CREATVIE_TASK, chat_id: new_chat.id)
      #     return task.attributes.to_json
      #   else
      #     numOfPracticalTask = Task.all.map(&:task_name).count(PRACTICAL_TASK)
      #     numOfCreativeTask = Task.all.map(&:task_name).count(CREATVIE_TASK)

      #     if numOfPracticalTask >= numOfCreativeTask
      #       task = Task.create(task_name: CREATVIE_TASK, chat_id: new_chat.id)
      #       return task.attributes.to_json
      #     else
      #       task = Task.create(task_name: PRACTICAL_TASK, chat_id: new_chat.id)
      #       return task.attributes.to_json
      #     end
      #   end
      # end

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
          print('headers:', headers)
          print('data:', data)
          header_csv = headers.join(',') + "\n"
          content = [header_csv] + data.map { |row| row.values.join(',') + "\n" }
          # File.write('./export.csv', content.join)
          return content.join
        end
        unless Chat.first(user_id:).nil?
          chat_id = Chat.first(user_id:).id
          data = Behavior.where(chat_id:).map(&:values)
          headers = data.first.keys.map(&:to_s)
          header_csv = headers.join(',') + "\n"
          content = [header_csv] + data.map { |row| row.values.join(',') + "\n" }
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

      # test Queue
      r.get 'queue' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        # print('test:', Api.config)
        RandomQueue.new(Api.config).queue_attributes.to_json
      end

      r.get 'reset-queue' do
        queue = RandomQueue.new(Api.config)
        queue.clear_queue
        response['Content-Type'] = 'application/json'
        response.status = 200
        queue.fill_task.to_json
      end

      r.get 'random-task' do
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

        # task = Task.create(task_name: CREATVIE_TASK, chat_id: new_chat.id)

        queue = RandomQueue.new(Api.config)
        task_body = queue.random_task
        task_name = JSON.parse(task_body.body)['task']
        Task.create(task_name:, chat_id: new_chat.id, message_id: task_body.message_id,
                    receipt_handle: task_body.receipt_handle).attributes.to_json
      end

      # basic streaming
      r.on 'streaming' do
        response.headers['Content-Type'] = 'text/event-stream'
        response.headers['Last-Modified'] = Time.now.httpdate
        response.status = 200
        tmp = ''
        stream do |out|
          TEST_LOREM.split(' ').each do |v|
            tmp += v + ' '
            out << "data: #{tmp}\n\n"
            sleep 0.05
          end
        end
      end

      # streaming with openAI api in frontend assign prompt
      r.post 'openAI-streaming' do
        response['Content-Type'] = 'text/event-stream'
        response['Cache-Control'] = 'no-cache'
        response['Connection'] = 'keep-alive'

        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)

        temp = data['temp'] || 0.7
        new_chat = if Chat.first(user_id:).nil?
                     Chat.create(user_id:)
                   else
                     Chat.first(user_id:)
                   end

        Message.create(chat_id: new_chat.id, role: 'user', response: data['message_content'])

        history_messages = Message.where(chat_id: new_chat.id).map(&:values).map do |item|
          {
            role: item[:role],
            content: item[:response]
          }
        end
        streaming_gpt = ChatGptStreaming.new(BASE_PROMPT, history_messages, temp)
        stream do |out|
          streaming_gpt.streaming.each { |message| out << message }
        end
      end

      r.post 'message' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        print 'data to store:', data
        role = data['role'] || 'user'
        new_chat = if Chat.first(user_id:).nil?
                     Chat.create(user_id:)
                   else
                     Chat.first(user_id:)
                   end
        Message.create(chat_id: new_chat.id, role:, response: data['message_content'])
        Message.where(chat_id: new_chat.id).map(&:values).to_json
      end

      # streaming with openAI api in fixed prompt
      # r.get 'test-response' do
      #   response['Content-Type'] = 'text/event-stream'
      #   response['Cache-Control'] = 'no-cache'
      #   response['Connection'] = 'keep-alive'
      #   history_messages = [{
      #     role: 'user',
      #     content: 'Can you help me to write a creative story in 2050 Japan?'
      #   }]

      #   # stream(:keep_open) do |out|
      #   #   sse_client.on_event do |event|
      #   #     out << "data: #{event.data}\n\n"
      #   #   end

      #   #   sse_client.on_error do |error|
      #   #     out << "event: error\ndata: #{error.message}\n\n"
      #   #   end
      #   # end
      #   requests, uri = ChatGptStreaming.make_request(BASE_PROMPT, history_messages, 0.7)
      #   print 'requests:', requests
      #   print 'uri:', uri
      #   stream do |out|
      #     Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      #       http.request requests do |response|
      #         # print 'response_now:', response.body
      #         # out << "data: #{response.body.data}\n\n"

      #         response.read_body do |chunk|
      #           print 'chunk:', chunk
      #           out << chunk
      #           # out << "data: #{chunk}\n\n"
      #         end
      #       end
      #       # http.request(requests)
      #     end
      #   end
      # end

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
