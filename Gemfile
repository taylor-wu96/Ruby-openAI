# frozen_string_literal: true

source 'https://rubygems.org'

gem 'dotenv'

# Networking
gem 'http'

gem 'nokogiri', '~> 1.15'

gem 'langchainrb', '~> 0.7.3'

gem 'ruby-openai', '~> 5.2.0'

gem 'diffy'

# server

gem 'csv'
gem 'figaro', '~>1.2'
gem 'foreman', '~>0.0'
gem 'puma', '~>6.0'
gem 'rake', '~>13.0'
gem 'roda', '~>3.0'
gem 'sequel', '~>5.0'
gem 'tilt'
# Use AWS gem for accessing SQS
gem 'aws-sdk'

group :production do
  gem 'pg', '~>1.0'
end

group :development, :test do
  gem 'pry'
  gem 'sqlite3', '~> 1.0'
end

group :development do
  gem 'rubocop'
end
