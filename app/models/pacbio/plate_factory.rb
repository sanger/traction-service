# frozen_string_literal: true

module Pacbio
  # PlateFactory
  # This will build a plate with wells and samples
  # we could use the respective models but that would cause more complexity
  # It is done in a cascading manner
  # Assumptions are:
  #  *the plate will probably have an external barcode to map to the LIMS it has originated from
  #  *if no barcode then a TRAC one is generated
  #  *the plate will have one or more wells
  #  *each well will have a sample but it is not required
  class PlateFactory
    include ActiveModel::Model

    attr_reader :plates

    def plates=(plates)
      @plates = plates.collect { |plate| PlateWrapper.new(plate) }
    end

    # PlateWrapper
    # creates a standard Plate
    # creates an array of wells which are instances of WellWrapper
    class PlateWrapper
      include ActiveModel::Model

      attr_reader :wells, :plate

      delegate :barcode, to: :plate

      def initialize(attributes = {})
        @plate = ::Plate.new(attributes.except(:wells))
        @wells = attributes[:wells].collect { |well| WellWrapper.new(well.merge(plate: plate)) }
      end
    end

    # WellWrapper
    # creates a standard Well
    # creates an array of samples which are instances of SampleWrapper
    # the wells will generally contain a single untagged sample but the LIMS
    # has the potential for multiple tagged samples in a well
    class WellWrapper
      include ActiveModel::Model

      attr_reader :samples, :well

      delegate :position, :plate, to: :well

      def initialize(attributes = {})
        @well = ::Well.new(attributes.except(:samples))
        @samples = attributes[:samples].try(:collect) do |sample|
          SampleWrapper.new(sample.merge(well: well))
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
    class SampleWrapper
      include ActiveModel::Model

      SAMPLE_ATTRIBUTES = %i[external_id name species].freeze

      attr_reader :sample, :well, :pacbio_request, :request, :container_material

      delegate(*SAMPLE_ATTRIBUTES, to: :sample)
      delegate(*Pacbio.request_attributes, to: :pacbio_request)

      def initialize(attributes = {})
        @well = attributes[:well]
        @sample = ::Sample.find_or_initialize_by(attributes.slice(*SAMPLE_ATTRIBUTES))
        @pacbio_request = Pacbio::Request.new(attributes.slice(*Pacbio.request_attributes))
        @request = ::Request.new(requestable: pacbio_request, sample: sample)
        @container_material = ContainerMaterial.new(container: well, material: pacbio_request)
      end
    end
  end
end
