module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end
  
    # First describe the field signature:
    field :well, WellType, null: true do
      description "Find a well by ID"
      argument :id, ID, required: true
      argument :position, String, required: false
      # fields should be queried in camel-case (this will be `truncatedPreview`)
      argument :plate_id, Int, required: false
    end
    
    # Then provide an implementation:
    def well(id:)
      Well.find(id)
    end
  end
end
