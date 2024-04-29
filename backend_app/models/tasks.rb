# frozen_string_literal: true

# models/location.rb

require 'sequel'

module RubyOpenAI
  class Task < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    one_to_one :chat, class: :'RubyOpenAI::Chat'

    # def validate
    #   super
    #   validates_presence %i[name course_id]
    # end

    def attributes
      {
        id:,
        chat_id:,
        task_name:,
        final_submission:,
        message_id:,
        receipt_handle:
      }
    end
  end
end
