# frozen_string_literal: true

module Pacbio
  # PlateCreator
  # This will build a plate with wells and samples
  # we could use the respective models but that would cause more complexity
  # It is done in a cascading manner
  # Assumptions are:
  #  *the plate will probably have an external barcode to map to the LIMS it has originated from
  #  *if no barcode then a TRAC one is generated
  #  *the plate will have one or more wells
  #  *each well will have a sample but it is not required
  class PlateCreator
    include ActiveModel::Model

    attr_reader :plates

    validate :check_plates

    def plates=(plates)
      @plates = plates.collect { |plate| PlateWrapper.new(plate) }
    end

    def save
      return false unless valid?

      plates.collect(&:save)
    end

    def check_plates
      if plates.empty?
        errors.add(:plates, 'should be present')
        return
      end

      plates.each do |plate|
        next if plate.valid?

        plate.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end

    # PlateWrapper
    # creates a standard Plate
    # creates an array of wells which are instances of WellWrapper
    # A plate will always be valid as a barcode can be generated
    # There needs to be some wells
    # If the wells are present they will need to be valid
    class PlateWrapper
      include ActiveModel::Model

      attr_reader :wells, :plate

      delegate :barcode, to: :plate

      validate :check_wells

      def initialize(attributes = {})
        @plate = ::Plate.new(attributes.except(:wells))
        @wells = attributes[:wells].try(:collect) do |well|
          WellWrapper.new(well.merge(plate: plate))
        end
      end

      def save
        plate.save(validate: false)
        wells.collect(&:save)
      end

      private

      def check_wells
        if wells.blank?
          errors.add(:wells, 'should be present')
          return
        end

        wells.each do |well|
          next if well.valid?

          well.errors.each do |k, v|
            errors.add(k, v)
          end
        end
      end
    end

    # WellWrapper
    # creates a standard Well
    # creates an array of samples which are instances of SampleWrapper
    # the wells will generally contain a single untagged sample but the LIMS
    # has the potential for multiple tagged samples in a well
    # Wells can be empty

    # For a well wrapper to be valid:
    #  *the well needs to be valid
    #  *if there are any samples they all need to be valid
    class WellWrapper
      include ActiveModel::Model

      attr_reader :samples, :well

      delegate :position, :plate, to: :well

      validate :check_well, :check_samples

      def initialize(attributes = {})
        @well = ::Well.new(attributes.except(:samples))
        @samples = attributes[:samples].try(:collect) do |sample|
          SampleWrapper.new(sample.merge(well: well))
        end
      end

      def save
        well.save(validate: false)
        return if samples.blank?

        samples.collect(&:save)
      end

      private

      def check_well
        return if well.valid?

        well.errors.each do |k, v|
          errors.add(k, v)
        end
      end

      def check_samples
        return if samples.blank?

        samples.each do |sample|
          next if sample.valid?

          sample.errors.each do |k, v|
            errors.add(k, v)
          end
        end
      end
    end

    # SampleWrapper
    # This is the biggie
    # A sample can be sequenced multiple times so the sample is fixed and read only
    # and it can have multiple requests so
    # we will either find or create the sample
    # we will then create a Pacbio::Request
    # This is then wrapped in an outer Request made up of the Sample and
    # the Pacbio::Request because the container is used by all pipelines
    # Finally we create a link (Container::Material) between the well (container)
    # and the material (request)
    # Because samples in each pipeline can exist in various containers e.g. Tube or Well

    # For a sample wrapper to be valid:
    #  *the sample needs to be valid
    #  *the request needs to be valid
    #  *the container (well) needs to be valid
    # we don't need to check the request as it would duplicate the sample and pacbio_request checks
    # we don't need to check the container material as the container is checked in the parent and
    # the material is the pacbio_request
    class SampleWrapper
      include ActiveModel::Model

      SAMPLE_ATTRIBUTES = %i[external_id name species].freeze
      REQUEST_ATTRIBUTES = %i[
        library_type estimate_of_gb_required number_of_smrt_cells cost_code
        external_study_id source_barcode
      ].freeze

      attr_reader :sample, :well, :pacbio_request, :request, :container_material

      delegate(*SAMPLE_ATTRIBUTES, to: :sample)
      delegate(*REQUEST_ATTRIBUTES, to: :pacbio_request)

      validate :check_models

      def initialize(attributes = {})
        @well = attributes[:well]
        @sample = ::Sample.find_or_initialize_by(attributes.slice(*SAMPLE_ATTRIBUTES))
        @pacbio_request = Pacbio::Request.new(attributes.slice(*REQUEST_ATTRIBUTES))
        @request = ::Request.new(requestable: pacbio_request, sample: sample)
        @container_material = ContainerMaterial.new(container: well, material: pacbio_request)
      end

      def save
        sample.save(validate: false)
        pacbio_request.save(validate: false)
        container_material.save(validate: false)
      end

      private

      def check_models
        [sample, pacbio_request].each do |model|
          next if model.valid?

          model.errors.each do |k, v|
            errors.add(k, v)
          end
        end
      end
    end
  end
end
