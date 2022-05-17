# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    jsonapi_resources :samples,  only: %i[index create]
    jsonapi_resources :tags,     only: %i[index create update destroy]
    jsonapi_resources :tag_sets, only: %i[index create update destroy]

    namespace :saphyr do
      jsonapi_resources :runs,          only: %i[index create show update destroy]
      jsonapi_resources :chips,         only: %i[index create show update destroy]
      jsonapi_resources :flowcells,     only: %i[index create show update destroy]
      jsonapi_resources :libraries,     only: %i[index create show destroy]
      jsonapi_resources :enzymes,       only: %i[index]
      jsonapi_resources :requests,      only: %i[index create update destroy]
      jsonapi_resources :tubes,         only: %i[index]
    end

    namespace :pacbio do

      jsonapi_resources :plates,        only: %i[index create]
      jsonapi_resources :tag_sets

      # This seems the best way to do this for now.
      # because we also have a namespace without the constraint
      # it will treat runs/plates or runs/wells as part of the resource
      # limiting it to numbers will cause plates and wells
      # to be redirected to the namespace
      jsonapi_resources :runs, constraints: { id: /[0-9]+/} do
        %i[index create update destroy]
        get 'sample_sheet', to: 'runs#sample_sheet'
      end

      namespace :runs do
        jsonapi_resources(:plates,        only: %i[index create update destroy]) {}
        jsonapi_resources(:wells,         only: %i[index create update destroy]) {}
      end

      jsonapi_resources :libraries,       only: %i[index update destroy]
      jsonapi_resources :requests,        only: %i[index create update destroy]
      jsonapi_resources :tubes,           only: %i[index]
      jsonapi_resources :pools,           except: %i[destroy]
    end
  end
end
