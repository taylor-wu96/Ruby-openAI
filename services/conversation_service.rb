require_relative '../models/chat_gpt_api'
require_relative '../repositories/conversation_repository'

class ConversationService
  def initialize(user, chat_id)
    @user = user
    @chat_id = chat_id
    @chat_api = RubyOpenAI::ChatGPTAPI.new(Repositories::ConversationRepository.get_system_messages_by_chat_id(@chat_id))
  end

  def send_message(message)
    # Get conversations history from database by chat_id
    existing_conversation = Repositories::ConversationRepository.find_by_chat_id(@chat_id)
    @chat_api.update_messages_from_series(existing_conversation)

    new_message = { role: 'user', content: message }
    # Merge the user's new message
    @chat_api.update_messages('user', message)

    # Use the ChatGPT API to get a response
    response = @chat_api.send_message(message)
    reply = response['choices'][0]['message']['content']

    # Merge the assistant's reply
    assistant_message = { role: 'assistant', content: reply }
    @chat_api.update_messages('assistant', reply)

    Repositories::ConversationRepository.save([new_message, assistant_message], @user.id, @chat_id)

    reply
  end

  def get_history
    Repositories::ConversationRepository.find_by_user_id(@user.id)
  end
end
