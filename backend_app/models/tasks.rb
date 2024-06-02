# frozen_string_literal: true

require 'sequel'
module RubyOpenAI
  # class to store the task for the user
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
        task_finished_time:,
        final_submission:,
        message_id:,
        receipt_handle:,
        word_editing_count:,
        word_deleted_count:,
        character_revision_count:
      }
    end
  end
end
