# frozen_string_literal: true

require 'sequel'
module RubyOpenAI
  class Chat < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true
    many_to_one :message, class: :'RubyOpenAI::Message'
    many_to_one :behavior, class: :'RubyOpenAI::Behavior'
    one_to_one :task, class: :'RubyOpenAI::Task'
    many_to_one :errorlog, class: :'RubyOpenAI::Errorlog'

    def attributes
      {
        id:,
        user_id:,
        ip_address:
      }
    end
  end
end
