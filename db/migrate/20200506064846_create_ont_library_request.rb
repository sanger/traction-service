class CreateOntLibraryRequest < ActiveRecord::Migration[6.0]
  def change
    create_table :ont_library_requests do |t|
      t.belongs_to :ont_library, index: true
      t.belongs_to :ont_request, index: true
      t.timestamps
    end
  end
end
