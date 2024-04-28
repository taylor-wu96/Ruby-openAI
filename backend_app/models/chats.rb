# frozen_string_literal: true

# models/location.rb

require 'sequel'

module RubyOpenAI
  class Chat < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true
    many_to_one :message, class: :'RubyOpenAI::Message'
    many_to_one :behavior, class: :'RubyOpenAI::Behavior'
    one_to_one :task, class: :'RubyOpenAI::Task'

    # def validate
    #   super
    #   validates_presence %i[name course_id]
    # end

    def attributes
      {
        id:,
        user_id:,
        ip_address:
      }
    end
  end
end
