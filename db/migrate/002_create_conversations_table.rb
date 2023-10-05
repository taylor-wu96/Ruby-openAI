Sequel.migration do
  change do
    create_table(:conversations) do
      primary_key :id
      foreign_key :user_id, :users
      String :messages, text: true
      TrueClass :is_assistant, default: false
      foreign_key :chat_id, :chats
    end
  end
end
