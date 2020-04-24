# frozen_string_literal: true

# Ont namespace
module Ont
  # RequestFactory
  # The factory will build a plate, associated wells and
  # requests from the request parameters
  class RequestFactory
    include ActiveModel::Model

    validate :check_plate, :check_wells, :check_requests, :check_well_request_joins

    def initialize(attributes = {})
      build_requests(attributes)
    end

    attr_reader :plate

    def wells
      @wells ||= []
    end

    def requests
      @requests ||= []
    end

    def well_request_joins
      @well_request_joins ||= []
    end

    def save
      return false unless valid?

      plate.save
      wells.collect(&:save)
      requests.collect(&:save)
      well_request_joins.collect(&:save)
      true
    end

    private

    def build_requests(attributes)
      wells_with_samples_attributes = attributes.extract!(:wells)
      build_plate(attributes)
      wells_with_samples_attributes[:wells].each do |well_with_sample_attributes|
        build_well(well_with_sample_attributes)
        next unless well_with_sample_attributes.key?(:sample)

        build_request(well_with_sample_attributes[:sample])
        build_well_request_join
      end
    end

    def build_plate(attributes)
      plate_attributes = attributes.extract!(:barcode)
      @plate = ::Plate.new(plate_attributes)
    end

    def build_well(well_with_sample_attributes)
      well_attributes = well_with_sample_attributes.extract!(:position).merge!(plate: plate)
      wells << ::Well.new(well_attributes)
    end

    def build_request(request_attributes)
      sample = build_or_fetch_sample(request_attributes)
      requests << ::Request.new(
        requestable: Ont::Request.new(
          external_study_id: Pipelines.ont.covid.request.external_study_id
        ),
        sample: sample
      )
    end

    def build_or_fetch_sample(request_attributes)
      sample_attributes = request_attributes
                          .extract!(:name, :external_id)
                          .merge!(species: Pipelines.ont.covid.sample.species)
      Sample.find_or_initialize_by(sample_attributes)
    end

    def build_well_request_join
      join_attributes = { container: wells.last.well, material: requests.last }
      well_request_joins << ::ContainerMaterial.new(join_attributes)
    end

    def check_plate
      return if plate.valid?

      plate.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    def check_well
      errors.add('wells', 'there were no wells') if wells.empty?

      wells.each do |well|
        next if well.valid?

        well.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end

    def check_requests
      # Wells can be empty of samples, so don't fail on no requests
      requests.each do |request|
        next if request.valid?

        request.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end

    def check_well_request_joins
      # Wells can be empty of samples, so don't fail on no joins
      well_request_joins.each do |join|
        next if join.valid?

        join.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end
  end
end
