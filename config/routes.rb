Rails.application.routes.draw do
  post 'register_changes', to: 'users#register_changes'
  get 'list_changes', to: 'users#list_changes'
end
