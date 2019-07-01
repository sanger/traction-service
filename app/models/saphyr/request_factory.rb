# frozen_string_literal: true

# RequestFactory
module Saphyr
  class RequestFactory
    include ActiveModel::Model

    validate :check_requests

    def initialize(attributes = [])
      build_requests(attributes)
    end

    def requests
      @requests ||= []
    end

    def save
      return false unless valid?

      requests.collect(&:save)
      true
    end

    private

    def build_requests(attributes)
      attributes.each do |request|
        sample_attributes = request.extract!(:name, :external_id, :species)
        requests << Saphyr::Request.new(request.merge!(tube: Tube.new, sample: Sample.find_or_initialize_by(sample_attributes)))
      end
    end

    def check_requests
      if requests.empty?
        errors.add('requests', 'there were no requests')
        return
      end

      requests.each do |request|
        next if request.valid?

        request.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end

  end
end
