# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    jsonapi_resources :samples, only: %i[create index]
    jsonapi_resources :libraries, only: %i[create index destroy]
    jsonapi_resources :tubes, only: %i[index]
  end
end
