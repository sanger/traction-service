# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    jsonapi_resources :samples, only: %i[index create]
    jsonapi_resources :tags,    only: %i[index create update destroy]

    namespace :saphyr do
      jsonapi_resources :runs,          only: %i[index create show update destroy]
      jsonapi_resources :chips,         only: %i[index create show update destroy]
      jsonapi_resources :flowcells,     only: %i[index create show update destroy]
      jsonapi_resources :libraries,     only: %i[index create show destroy]
      jsonapi_resources :enzymes,       only: %i[index]
      jsonapi_resources :requests,      only: %i[index create update destroy]
      jsonapi_resources :tubes, only: %i[index]
    end

    namespace :pacbio do
      jsonapi_resources :runs do
        %i[index create update destroy]
        get 'sample_sheet', to: 'runs#sample_sheet'
      end
      jsonapi_resources :plates,        only: %i[index create update destroy]
      jsonapi_resources :wells,         only: %i[index create update destroy] do
        scope module: :wells do
          # TODO: converting this to jsonapi_resources causes a resource not
          # found error.
          resources :libraries, only: %i[create]
        end
      end
      # TODO: converting this to jsonapi_resources causes test failure
      resources :libraries,     only: %i[index create destroy]
      jsonapi_resources :requests,      only: %i[index create update destroy]
      jsonapi_resources :wells,         only: %i[index create update destroy]
      jsonapi_resources :tubes, only: %i[index]
    end
  end
end
