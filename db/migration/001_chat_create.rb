# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:chats) do
      primary_key :id
      String :user_id, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
