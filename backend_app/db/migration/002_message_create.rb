# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    # Create messages table
    create_table(:messages) do
      primary_key :id
      foreign_key :chat_id, :chats # Links message to a specific chat
      String :role
      String :response
      DateTime :created_at
      DateTime :updated_at

      # unique %i[course_id name]
    end
  end
end
