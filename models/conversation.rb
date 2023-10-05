class Conversation
  attr_reader :id, :user_id, :chat_id, :messages

  def initialize(id:, user_id:, chat_id:, messages:)
    @id = id
    @user_id = user_id
    @chat_id = chat_id
    @messages = messages
  end
end
