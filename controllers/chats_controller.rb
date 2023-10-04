# app/controllers/chats_controller.rb

class ChatsController < ApplicationRecord
  def index
    @messages = Message.all
    respond_to do |format|
      format.html # This would serve the plain HTML file
      format.json { render json: @messages }
    end
  end

  def create
    user_message = params[:user_message]
    Message.create(role: 'user', content: user_message)

    response = RubyOpenAI::ChatGPTAPI.send_message(user_message)
    assistant_message = response['choices'][0]['message']['content']

    Message.create(role: 'assistant', content: assistant_message)

    head :ok
  end
end
