class Chat
  attr_reader :id, :user_id, :system_content

  def initialize(id:, user_id:, system_content:)
    @id = id
    @user_id = user_id
    @system_content = system_content
  end
end
