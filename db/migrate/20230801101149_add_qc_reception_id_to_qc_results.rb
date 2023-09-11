# frozen_string_literal: true

# Added an optional foreign key qc_reception_id to create an association with qc_receptions
class AddQcReceptionIdToQcResults < ActiveRecord::Migration[7.0]
  def change
    add_reference :qc_results, :qc_reception, null: true, foreign_key: true
  end
end
