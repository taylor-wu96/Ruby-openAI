class ChatController < Roda
  plugin :sessions, secret: ENV['SESSION_SECRET']
  plugin :json

  route do |r|
    r.on 'chat' do
      r.get do
        # Respond with chat instructions or status
        { info: 'Endpoint for chat interactions. Send message in POST request.' }
      end

      # Endpoint to create a new chat
      r.post 'new' do
        system_content = r.params['system_content']
        # Create a new chat entry
        chat = Repositories::ChatRepository.create({user_id: session['user_id'], system_content: system_content})
        { success: true, chat_id: chat[:id] }
      end

      r.post do
        message = r.params['message']
        # Use the ChatGPT API to get a response
        chat_service = ConversationService.new(Repositories::UserRepository.find(session['user_id']), r.params['chat_id'])
        response = chat_service.send_message(message)
        # Return the response
        { user_message: message, assistant_reply: response }
      end
    end

    r.on 'history' do
      chat_service = ConversationService.new(UserRepository.find(session['user_id']))
      history = chat_service.get_history

      { conversations: history }
    end
  end
end
