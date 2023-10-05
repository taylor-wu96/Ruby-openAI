require 'sequel'

module Repositories
  class ConversationRepository
    # Set up the DB connection (this could be moved to a central location)
    DB = Sequel.connect("sqlite://db/development.sqlite3")
    def self.find_by_user_id(user_id)
      DB[:conversations].where(user_id: user_id).all
    end

    def self.save(conversations, user_id, chat_id)
      conversations.each do |message|
        if message[:role] == 'user'
          DB[:conversations].insert(user_id: user_id, chat_id: chat_id, messages: message[:content], is_assistant: false)
        elsif message[:role] == 'assistant'
          DB[:conversations].insert(user_id: nil, chat_id: chat_id, messages: message[:content], is_assistant: true)
        end
      end
    end

    def self.get_system_messages_by_chat_id(chat_id)
      chats_data = DB[:chats].where(id: chat_id).first
      return [] unless chats_data && chats_data[:system_content]
      # Deserialize the messages from JSON format
      chats_data[:system_content]
    end

    def self.find_by_chat_id(chat_id)
      DB[:conversations].where(chat_id: chat_id).all
    end
  end
end
