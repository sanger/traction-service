# frozen_string_literal: true

module V1
  # Handles import of resources into Traction
  # Traction-UI will handle the loading of information from other sources
  # and translating it into the format we can use here.
  # See spec/requests/v1/reception_spec.rb for example payload.
  # This file is largely empty, as JSONAPI::Resource heavily favours convention
  # over configuration and relies on the resource to determine what's possible
  class ReceptionsController < ApplicationController
  end
end
