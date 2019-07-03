# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    jsonapi_resources :samples, only: %i[index create]
    jsonapi_resources :tubes,   only: %i[index]

    namespace :saphyr do
      resources :runs,          only: %i[index create show update destroy]
      resources :chips,         only: %i[index create show update destroy]
      resources :flowcells,     only: %i[index create show update destroy]
      resources :libraries,     only: %i[index create show destroy]
      resources :enzymes,       only: %i[index]
    end

    namespace :pacbio do
      resources :runs,          only: %i[index create show update destroy]
      resources :plates,        only: %i[index create update destroy]
      resources :wells,         only: %i[index create update destroy]
      resources :libraries,     only: %i[index create destroy]
      resources :tags,          only: %i[index create update destroy]
    end
  end
end
