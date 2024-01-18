require 'net/http'
require 'json'
require 'uri'
require 'dotenv'

Dotenv.load

uri = URI('https://api.openai.com/v1/chat/completions')

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['Authorization'] = "Bearer #{ENV['OPENAI_API_KEY']}"
request.body = JSON.dump({
  model: 'gpt-3.5-turbo',
  messages: [
    {
      role: 'user',
      content: 'Hello!'
    }
  ],
  logprobs: true,
  top_logprobs: 2
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
  http.request(request)
end

puts response.body

response_body = JSON.parse(response.body)

# Accessing the specific log probability
log_probability = response_body['choices'][0]['logprobs']['content'][0]['logprob']

probability = 10 ** log_probability
puts "Regular Probability: #{probability}"
