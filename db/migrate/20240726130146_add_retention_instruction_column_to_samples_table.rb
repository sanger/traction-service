class AddRetentionInstructionColumnToSamplesTable < ActiveRecord::Migration[7.1]
  def up
    add_column :samples, :retention_instruction, :integer
  end

  def down
    remove_column :samples, :retention_instruction
  end
end
