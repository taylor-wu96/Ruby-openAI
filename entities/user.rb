require 'bcrypt'

module Entities
  class User
    attr_accessor :id, :username, :hashed_password

    def initialize(attrs = {})
      @id = attrs[:id]
      @username = attrs[:username]
      @hashed_password = attrs[:hashed_password]
    end

    def verify_password(plain_password)
      BCrypt::Password.new(self.hashed_password) == plain_password
    end
  end
end
  