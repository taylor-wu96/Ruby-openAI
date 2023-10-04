# config/routes.rb

Rails.application.routes.draw do
  resources :chats, only: [:index, :create], defaults: { format: 'json' }
end
