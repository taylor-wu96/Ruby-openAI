# frozen_string_literal: true

# models/location.rb

require 'sequel'

module RubyOpenAI
  class Message < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    many_to_one :chat, class: :'RubyOpenAI::Chat'

    # def validate
    #   super
    #   validates_presence %i[name course_id]
    # end

    def attributes
      {
        id:,
        chat_id:,
        role:,
        response:
      }
    end
  end
end
