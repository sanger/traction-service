# frozen_string_literal: true

# ApplicationController
class ApplicationController < JSONAPI::ResourceController
  skip_before_action :verify_authenticity_token
end
