# frozen_string_literal: true

module Mutations
  # Mutation to create a plate with samples in wells.
  class CreatePlateWithSamplesMutation < BaseMutation
    argument :study_type, Types::Enums::Ont::StudyTypeEnum,
             'The study type for the samples (not currently used).', required: false
    argument :arguments, Types::Inputs::Ont::PlateWithSamplesInputType,
             'Arguments describing the plate, wells and samples to create a plate for.',
             required: true

    field :plate, Types::Outputs::PlateType, 'The generated plate, or nil if errors were thrown.',
          null: true
    field :errors, [String], 'An array of error messages thrown when creating the plate.',
          null: false

    #
    # Constructs the plate, wells, samples and requests
    # Below is plant UML describing the key sequence flow, it is not
    # intended to be exhaustive.
    #
    # PNG version in create_plate_with_samples_mutation.png
    #
    # Plant UML:
    # https://plantuml.com/
    # VSCode extension: https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml
    #
    # A lot of the complexity below is to generate bulk inserts for performance.
    # We have a few passes:
    # - Initial pass builds the factories and record objects
    # - We then have a validation pass
    # - Followed by serializing everything, the passes back to PlateWithSamplesFactory
    #   here help maintain shared timestamps
    #
=begin
    @startuml Sequence Flow
    CreatePlateWithSamplesMutation -> "Ont::PlateWithSamplesFactory" : process
    "Ont::PlateWithSamplesFactory" -> "Ont::PlateFactory" : initialize
    "Ont::PlateFactory" -> Plate : initialize
    "Ont::PlateFactory" <- Plate
      loop each well
        "Ont::PlateFactory" -> "Ont::WellFactory" : initialize
        "Ont::WellFactory" -> Well : initialize
        "Ont::WellFactory" <- Well
        "Ont::WellFactory" -> "Pipelines::ConstantsAccessor" : ont_covid_pcr_tag_set_name
        "Ont::WellFactory" <- "Pipelines::ConstantsAccessor"
        "Ont::WellFactory" -> TagSetService : load_tag_set
        "Ont::WellFactory" <- TagSetService
          loop each sample
            "Ont::WellFactory" -> "Ont::RequestFactory" : initialize
            "Ont::RequestFactory" -> "Ont::Request" : initialize
            "Ont::RequestFactory" <- "Ont::Request"
            "Ont::WellFactory" <- "Ont::RequestFactory"
          end
        "Ont::PlateFactory" <- "Ont::WellFactory" : initialize
      end
    "Ont::PlateWithSamplesFactory" <- "Ont::PlateFactory"
    CreatePlateWithSamplesMutation <- "Ont::PlateWithSamplesFactory"
    CreatePlateWithSamplesMutation -> "Ont::PlateWithSamplesFactory" : save
    note right: Validation delegates down the same stack
    "Ont::PlateWithSamplesFactory" -> "Ont::PlateFactory" : valid?
    "Ont::PlateFactory" -> "Ont::Plate" : valid?
    "Ont::PlateFactory" <- "Ont::Plate"
      loop each well
        "Ont::PlateFactory" -> "Ont::WellFactory" : valid?
        "Ont::WellFactory" -> Well : valid?
        "Ont::WellFactory" <- Well
          loop each sample
            "Ont::WellFactory" -> "Ont::RequestFactory" : valid?
            "Ont::RequestFactory" -> "Ont::Request" : valid?
            "Ont::RequestFactory" <- "Ont::Request"
            "Ont::WellFactory" <- "Ont::RequestFactory"
          end
        "Ont::PlateFactory" <- "Ont::WellFactory" : valid?
      end
    "Ont::PlateWithSamplesFactory" <- "Ont::PlateFactory"
    note right: Serialize Everything
    "Ont::PlateWithSamplesFactory" -> "Ont::PlateFactory" : bulk_insert_serialize
      loop each well
        "Ont::PlateFactory" -> "Ont::WellFactory" : bulk_insert_serialize
          loop each sample
            "Ont::WellFactory" -> "Ont::RequestFactory" : bulk_insert_serialise
            "Ont::RequestFactory" -> "Ont::PlateWithSamplesFactory" : ont_request_data
            "Ont::RequestFactory" <- "Ont::PlateWithSamplesFactory" : ont_request_data
            "Ont::WellFactory" <- "Ont::RequestFactory"
          end
        "Ont::WellFactory" -> "Ont::PlateWithSamplesFactory" : well_data
        "Ont::WellFactory" <- "Ont::PlateWithSamplesFactory"
        "Ont::PlateFactory" <- "Ont::WellFactory"
      end
    "Ont::PlateFactory" -> "Ont::PlateWithSamplesFactory" : plate_data
    "Ont::PlateFactory" <- "Ont::PlateWithSamplesFactory"
    "Ont::PlateWithSamplesFactory" <- "Ont::PlateFactory" : @serialised_plate_data
    note right: Then we generate bulk inserts
    "Ont::PlateWithSamplesFactory" -> Plate : insert_all!
    "Ont::PlateWithSamplesFactory" <- Plate
    "Ont::PlateWithSamplesFactory" -> Plate : find_by!(:barcode)
    "Ont::PlateWithSamplesFactory" <- Plate
    "Ont::PlateWithSamplesFactory" -> Well : insert_all!
    "Ont::PlateWithSamplesFactory" <- Well
    "Ont::PlateWithSamplesFactory" -> "Ont::Request" : insert_all!
    "Ont::PlateWithSamplesFactory" <- "Ont::Request"
    "Ont::PlateWithSamplesFactory" -> "Ont::Request" : where(:uuids)
    "Ont::PlateWithSamplesFactory" <- "Ont::Request"
    "Ont::PlateWithSamplesFactory" -> Plate : wells
    "Ont::PlateWithSamplesFactory" <- Plate
    "Ont::PlateWithSamplesFactory" -> ContainerMaterial : insert_all!
    "Ont::PlateWithSamplesFactory" <- ContainerMaterial
    "Ont::PlateWithSamplesFactory" -> TagTaggable : insert_all!
    "Ont::PlateWithSamplesFactory" <- TagTaggable
    @enduml
=end
    #
    # @param arguments [Types::Inputs::Ont::PlateWithSamplesInputType]
    #
    # @return [Void]
    #
    def resolve(arguments:)
      factory = Ont::PlateWithSamplesFactory.new(arguments.to_h)
      factory.process
      plate = factory.save

      if plate
        resolved_plate = Plate.resolved_query.find_by(id: plate.id)
        { plate: resolved_plate, errors: [] }
      else
        { plate: nil, errors: factory.errors.full_messages }
      end
    end
  end
end
