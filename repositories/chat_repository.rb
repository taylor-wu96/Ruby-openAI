require 'sequel'

module Repositories
  class ChatRepository
    # Set up the DB connection (this could be moved to a central location)
    DB = Sequel.connect("sqlite://db/development.sqlite3")
    # Create a new chat in the database
    def self.create(attrs)
      chat_data = {
        user_id: attrs[:user_id],
        system_content: attrs[:system_content]
      }
      new_id = DB[:chats].insert(chat_data) # Assuming a table named "chats"
      chat_data.merge(id: new_id)
    end

    # Find a chat by its ID
    def self.find_by_id(chat_id)
      chat_data = DB[:chats].where(id: chat_id).first
      return nil unless chat_data
      chat_data
    end

    # Retrieve all chats for a user
    def self.find_by_user_id(user_id)
      chats_data = DB[:chats].where(user_id: user_id).all
      chats_data
    end
  end
end
