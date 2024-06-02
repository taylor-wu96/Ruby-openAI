require 'aws-sdk-sqs'
require 'ostruct'
require_relative '../models/tasks'

module RubyOpenAI
  # set up for the random task queue
  class RandomQueue
    def initialize(config)
      @sqs = Aws::SQS::Client.new(
        access_key_id: config.AWS_SQS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SQS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
      @queue = Aws::SQS::Queue.new(url: config.AWS_SQS_URL, client: @sqs)
      @attributes = @sqs.get_queue_attributes(
        queue_url: config.AWS_SQS_URL,
        attribute_names: ['All']
      )
      @url = config.AWS_SQS_URL
    end

    def random_task
      fill_task(10) if queue_size.to_i.zero?
      task = @queue.receive_messages({
                                       max_number_of_messages: 1,
                                       receive_request_attempt_id: 'String'
                                     })
      # print('task data response:', task.first.data)
      # print('receipt_handle:', task.first.data.receipt_handle)
      # print('message_id:', task.first.data.message_id)

      # task.first.body
      task.first.data
      # print('get task:', task)
      # JSON.parse(task, object_class: OpenStruct)
    end

    def finish_task(task)
      @queue.delete_messages(
        entries: [
          {
            id: task.message_id,
            receipt_handle: task.receipt_handle
          }
        ]
      )
    rescue Aws::SQS::Errors::ReceiptHandleIsInvalid
      raise ArgumentError, "Input receipt \"#{task}\" is not a valid receipt"
    rescue StandardError => e
      raise RuntimeError, 'Could not send the delete request to SQS', e
    end

    def fill_task(numoftask = 400)
      (1..numoftask).each do |i|
        @queue.send_message(queue_url: @queue, message_body: { task: i.even? ? 'CREATIVE' : 'PRACTICAL' }.to_json)
      end
    end

    def clear_queue
      @sqs.purge_queue(queue_url: @url)
    end

    def queue_size
      @attributes.attributes['ApproximateNumberOfMessages']
    end

    def queue_attributes
      @attributes = @sqs.get_queue_attributes(
        queue_url: @url,
        attribute_names: ['All']
      )
      @attributes
    end
  end
end
