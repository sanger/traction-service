# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    jsonapi_resources :samples, only: %i[index create]
    jsonapi_resources :tubes, only: %i[index]

    namespace :saphyr do
      resources :runs, only: %i[index create update show destroy]
      resources :chips, only: %i[index update show create destroy]
      resources :flowcells, only: %i[index update show create destroy]
      resources :libraries, only: %i[index create destroy show]
      resources :enzymes, only: %i[index]
    end

    namespace :pacbio do
      resources :runs, only: %i[index create update show destroy]
      resources :plates, only: %i[index create update destroy]
    end
  end
end
