require "langchain"
require "openai"

llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"])

# https://github.com/andreibondarev/langchainrb/blob/main/lib/langchain/llm/response/openai_response.rb
puts llm.chat(prompt: "Hey! How are you?").chat_completions