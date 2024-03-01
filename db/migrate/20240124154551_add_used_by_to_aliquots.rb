class AddUsedByToAliquots < ActiveRecord::Migration[7.1]
  def change
    add_reference :aliquots, :used_by, polymorphic: true, index: true
    remove_reference :aliquots, :pacbio_well, null: true, foreign_key: true
  end
end
