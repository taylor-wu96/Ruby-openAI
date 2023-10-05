require 'bcrypt'

class User
  attr_reader :id, :username, :hashed_password

  def initialize(id:, username:, hashed_password:)
    @id = id
    @username = username
    @hashed_password = hashed_password
  end

  def self.encrypt_password(password)
    BCrypt::Password.create(password)
  end

  def verify_password(password)
    BCrypt::Password.new(hashed_password) == password
  end
end
