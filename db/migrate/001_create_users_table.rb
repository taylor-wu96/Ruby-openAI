Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :username, null: false, unique: true
      String :hashed_password, null: false
    end
  end
end
