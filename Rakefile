require 'rake'
require 'puma'
require 'sequel'
require 'yaml'
require 'securerandom'

task :default => :server

desc 'Generate a random session secret'
task :generate_secret do
  secret = SecureRandom.hex(64)
  puts "Generated Secret: #{secret}"
  puts "NOTE: Copy this secret and add or update it in your .env file as SESSION_SECRET."
end

namespace :db do
  desc 'Run database migrations'
  task :migrate do
    # Set up the database connection
    DB = Sequel.connect("sqlite://db/development.sqlite3")

    # Load and run migrations
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrate')
  end
end

desc 'Start the Puma server'
task :server do
  exec 'puma config.ru'
end
