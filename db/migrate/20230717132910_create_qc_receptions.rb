class CreateQcReceptions < ActiveRecord::Migration[7.0]
  def change
    create_table :qc_receptions do |t|
      t.string :source

      t.timestamps
    end
  end
end
