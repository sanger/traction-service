# frozen_string_literal: true

# Ont namespace
module Ont
  # RequestFactory
  # The factory will build a plate, associated wells and
  # requests from the request parameters
  class RequestFactory
    include ActiveModel::Model

    validate :check_plates, :check_wells, :check_requests, :check_joins

    def initialize(attributes = {})
      build_plate(attributes.extract!(:barcode))
      build_wells_and_requests(attributes[:wells])
    end

    attr_reader :plate

    def wells
      @wells ||= []
    end

    def requests
      @requests ||= []
    end

    def joins
      @joins ||= []
    end

    def save
      return false unless valid?

      plate.save
      wells.collect(&:save)
      requests.collect(&:save)
      joins.collect(&:save)
      true
    end

    private

    def build_plate(plate_attributes)
      @plate = ::Plate.new(plate_attributes)
    end

    def build_wells_and_requests(wells_with_samples)
      wells_with_samples.each do |well_with_sample|
        well_attributes = well_with_sample.extract!(:position).merge(plate: plate)
        well = build_well(well_attributes)
        next unless well_with_sample.key?(:sample)

        sample_attributes = well_with_sample[:sample].extract!(:name)
        request = build_request(sample_attributes)
        build_join(well, request)
      end
    end

    def build_well(well_attributes)
      wells << ::Well.new(well_attributes)
      wells.last
    end

    def build_request(sample_attributes)
      requests << ::Request.new(requestable: Request.new(
        sample: Sample.find_or_initialize_by(sample_attributes)
      ))
      requests.last
    end

    def build_join(well, request)
      joins << ::ContainerMaterial.new(container: well, material: request)
    end

    def check_plate
      if plate.nil?
        errors.add('plate', 'can not be nil')
        return
      end

      errors.add('plate', 'must have a barcode') if plate.barcode.nil?
    end

    def check_wells
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

    def check_joins
      # Wells can be empty of samples, so don't fail on no joins
      joins.find_each do |join|
        next if join.valid?

        join.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end
  end
end
