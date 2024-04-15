# frozen_string_literal: true

# Removes the linking tables for PacBio wells.
# These tables are no longer used and are not needed as they have been superseeded by Aliquots.
class RemovePacbioWellLinkingTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :pacbio_well_libraries
    drop_table :pacbio_well_pools
  end
end
