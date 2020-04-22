module Types
  class WellType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, String, null:false
    field :updated_at, String, null:false

    field :position, String, null: false
    field :plate_id, Integer, null: false
  end
end
