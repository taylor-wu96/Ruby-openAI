# frozen_string_literal: true

require 'sequel'

module RubyOpenAI
  # class to store the error logs
  class Errorlog < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    many_to_one :chat, class: :'RubyOpenAI::Chat'

    def attributes
      {
        id:,
        chat_id:,
        error_message:
      }
    end
  end
end
