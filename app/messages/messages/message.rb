# frozen_string_literal: true

module Messages
  # Message
  # Creates a message in the correct structure for the warehouse
  class Message
    include ActiveModel::Model

    attr_accessor :object, :configuration

    # Produces the message in the correct format
    # Example:
    #   {"lims"=>"Traction", "bmap_flowcell"=>{"sample_uuid"=>"5",
    #     "study_uuid"=>"5", "experiment_name"=>5, "enzyme_name"=>"Nb.BssSI",
    #     "chip_barcode"=>"FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX",
    #     "chip_serialnumber"=>"FLEVEAOLPTOWPNWU", "position"=>2, "id_library_lims"=>5,
    #     "id_flowcell_lims"=>10, "instrument_name"=>"saphyr",
    #     "last_updated"=>Mon, 12 Aug 2019 12:37:51 UTC +00:00}}
    def content
      { lims: configuration.lims }.with_indifferent_access.tap do |result|
        result[configuration.key] = configuration.fields.each_with_object({}) do |(k, v), r|
          r[k] = instance_value(object, v)
        end
      end
    end

    # Content as json
    def payload
      content.to_json
    end

    # If the message contains a number of children for example
    # with Pacbio each well will have a number of samples
    # For each field get the value
    # This is applied to the nested object not the
    # original object
    def build_children(object, field)
      Array(object.send(field[:value])).collect do |o|
        field[:children].each_with_object({}) do |(k, v), r|
          r[k] = instance_value(o, v)
        end
      end
    end

    # Find the instance value for each field
    # If the field is a:
    # * [string]    - return the value
    # * [model]     - take the value split it by the full stop
    #                 and recursively send the method to the object
    #                 e.g. it is object.foo.bar will first evaluate
    #                 foo and then apply bar
    # * [constant]  - Takes the constant and applies the method chain
    #                 to it e.g DateTime.now
    # * [array]     - usually an array of fields
    def instance_value(object, field)
      case field[:type]
      when :string
        field[:value]
      when :model
        evaluate_method_chain(object, field[:value].split('.'))
      when :constant
        evaluate_method_chain(field[:value].split('.').first.constantize,
                              field[:value].split('.')[1..-1])
      when :array
        build_children(object, field)
      end
    end

    def evaluate_method_chain(object, chain)
      chain.inject(object, :send)
    end
  end
end
