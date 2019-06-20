# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    jsonapi_resources :samples, only: %i[index create]
    jsonapi_resources :libraries, only: %i[index create destroy show]
    jsonapi_resources :tubes, only: %i[index]
    jsonapi_resources :enzymes, only: %i[index]
    jsonapi_resources :runs, only: %i[index create update show destroy]
    jsonapi_resources :chips, only: %i[index update show create destroy]
    jsonapi_resources :flowcells, only: %i[index update show create destroy]
  end
end
