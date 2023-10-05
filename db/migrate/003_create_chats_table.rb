Sequel.migration do
  change do
    create_table(:chats) do
    primary_key :id
    foreign_key :user_id, :users
    String :system_content, text: true
    end
  end
end
