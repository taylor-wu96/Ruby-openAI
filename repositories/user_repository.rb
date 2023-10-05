require 'sequel'
require_relative '../entities/user'

module Repositories
  class UserRepository
    # Set up the DB connection (this could be moved to a central location)
    DB = Sequel.connect("sqlite://db/development.sqlite3")

    # Create a new user in the database
    def self.create(attrs)
      user_data = {
        username: attrs[:username],
        hashed_password: attrs[:hashed_password]
      }
      new_id = DB[:users].insert(user_data) # Assuming a table named "users"
      attrs.merge(id: new_id)
    end
    def self.find(user_id)
      user_data = DB[:users].where(id: user_id).first
      return nil unless user_data
      Entities::User.new(user_data)
    end
    # Find a user by their username
    def self.find_by_username(username)
      user_data = DB[:users].where(username: username).first
      return nil unless user_data
      Entities::User.new(user_data)
    end
  end
end
