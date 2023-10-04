# app/models/message.rb
class Message < ApplicationRecord
  validates :role, presence: true
  validates :content, presence: true
end