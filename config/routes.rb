# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    jsonapi_resources :samples,  only: %i[index create]
    jsonapi_resources :tags,     only: %i[index create update destroy]
    jsonapi_resources :tag_sets, only: %i[index create update destroy]
    jsonapi_resources :library_types, only: %i[index create update]
    jsonapi_resources :data_types, only: %i[index create update]
    jsonapi_resources :receptions, only: %i[index create show]
    jsonapi_resources :qc_assay_types, only: %i[index show]
    jsonapi_resources :qc_results, only: %i[index create show]
    jsonapi_resources :qc_results_uploads, only: %i[create]
    jsonapi_resources :qc_receptions, only: %i[create]

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
      jsonapi_resources :runs, constraints: { id: /[0-9]+/ } do
        get 'sample_sheet', to: 'runs#sample_sheet'
      end

      namespace :runs do
        # The empty block here *does* seem to change the behaviour, as the removal
        # results in the error:
        # JSONAPI: Could not find resource 'v1/pacbio/runs/library'.
        #   (Class V1::Pacbio::Runs::LibraryResource not found)
        # Which is an issue with the namespaced resources not looking up the global ones.
        # See comment in app/resources/v1/pacbio/runs/well_resource.rb
        # rubocop:disable Lint/EmptyBlock
        jsonapi_resources(:plates,        only: %i[index create update destroy]) {}
        jsonapi_resources(:wells,         only: %i[index create update destroy]) {}
        # rubocop:enable Lint/EmptyBlock
      end

      jsonapi_resources :libraries,           only: %i[index create update destroy]
      jsonapi_resources :requests,            only: %i[index create update destroy]
      jsonapi_resources :tubes,               only: %i[index]
      jsonapi_resources :pools,               except: %i[destroy]
      jsonapi_resources :smrt_link_versions,  only: %i[index show]
      jsonapi_resources :smrt_link_options,   only: %i[index show]
    end

    namespace :ont do
      jsonapi_resources :instruments,         only: %i[index show]
      jsonapi_resources(:runs,                only: %i[index show create update]) do
        get 'sample_sheet', to: 'runs#sample_sheet'
      end
      jsonapi_resources :flowcells,           only: %i[index show create update]
      jsonapi_resources :requests,            except: %i[create destroy]
      jsonapi_resources :libraries,           only: %i[index update destroy]
      jsonapi_resources :pools,               except: %i[destroy]
      jsonapi_resources :plates,              only: %i[index]
      jsonapi_resources :tubes,               only: %i[index]
      jsonapi_resources :tag_sets
    end
  end

  mount Flipper::Api.app(Flipper) => '/flipper/api', constraints: ->(request) { request.get? }

  # Caution: We currently have no auth on the flipper UI, potentially allowing anyone within
  # the sanger who knows the URL to flip features. You *can* add basic auth with:
  #
  #   builder.use Rack::Auth::Basic do |username, password|
  #     # do_validation
  #   end
  # end
  #
  # You could then either add bcrypt and validate against a hash stored in FLIPPER_USER
  # or auth with ldap and check teams.
  #
  # Choosing to defer for the moment, as risk is pretty low.
  flipper_ui = Flipper::UI.app do |builder|
    # Required to prevent a 'Forbidden' response. I'm assuming as the Rails app
    # itself is API only
    builder.use Rack::Session::Cookie, secret: Rails.application.credentials[:secret_key_base]
  end
  mount flipper_ui, at: '/flipper'
end
