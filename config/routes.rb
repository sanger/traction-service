Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    jsonapi_resources :samples, only: [:create, :index]
    jsonapi_resources :libraries, only: [:create, :index]
  end
end
