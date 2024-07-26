class AddRetentionInstructionColumnToSamplesTable < ActiveRecord::Migration[7.1]
  def change
    add_column :samples, :retention_instruction, :integer
  end
end
