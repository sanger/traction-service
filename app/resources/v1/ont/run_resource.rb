# frozen_string_literal: true

module V1
    module Ont
      # RunResource
      class RunResource < JSONAPI::Resource
        model_name 'Ont::Run'
  
        attributes :experiment_name, :state, :created_at

        after_create :create_run!

        def create_run!
          @model.create_run!
        end

      end
    end
  end
  