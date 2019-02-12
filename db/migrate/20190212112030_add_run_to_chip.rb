class AddRunToChip < ActiveRecord::Migration[5.2]
  def change
    add_reference :chips, :run, foreign_key: true
  end
end
