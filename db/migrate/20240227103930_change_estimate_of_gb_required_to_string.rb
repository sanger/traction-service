# frozen_string_literal: true

# Change estimate_of_gb_required to a string to support TOL auto-manifests with genome_size.
class ChangeEstimateOfGbRequiredToString < ActiveRecord::Migration[7.1]
  def up
    change_column :pacbio_requests, :estimate_of_gb_required, :string
  end

  # The conversion back to integer is not possible if any value in the column cannot be converted.
  # If that happens, the reverse migration will fail.
  def down
    change_column :pacbio_requests, :estimate_of_gb_required, :integer
  end
end
