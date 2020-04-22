module Types
  class WellType < Types::BaseObject
    field :id, ID, null: false
    field :position, String, null: true
    field :plate_id, Integer, null: true
  end
end
