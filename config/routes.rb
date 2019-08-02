# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    jsonapi_resources :samples, only: %i[index create]
    jsonapi_resources :tubes,   only: %i[index]
    jsonapi_resources :tags,    only: %i[index create update destroy]

    namespace :saphyr do
      resources :runs,          only: %i[index create show update destroy]
      resources :chips,         only: %i[index create show update destroy]
      resources :flowcells,     only: %i[index create show update destroy]
      resources :libraries,     only: %i[index create show destroy]
      resources :enzymes,       only: %i[index]
      resources :requests,      only: %i[index create update destroy]
    end

    namespace :pacbio do
      resources :runs do
        %i[index create update destroy]
        get 'sample_sheet', to: 'runs#sample_sheet'
      end
      resources :plates,        only: %i[index create update destroy]
      resources :wells,         only: %i[index create update destroy]
      resources :libraries,     only: %i[index create destroy]
      resources :requests,      only: %i[index create update destroy]
    end
  end
end
