# frozen_string_literal: true

# Type - to store the source/users of the assay_type. Eg: Long Read, etc 
class AddTypeToQcAssayTypes < ActiveRecord::Migration[7.0]
  def up
    say 'adding type to qc_assay_types'
    add_column :qc_assay_types, :type, :string
  end

  def down
    say 'removing type from qc_assay_types'
    remove_column :qc_assay_types, :type
  end
end
