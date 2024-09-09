class CreateWorkflowSteps < ActiveRecord::Migration[7.2]
  def change
    create_table :workflow_steps do |t|
      t.references :workflow, null: false, foreign_key: true
      t.string :code
      t.string :stage

      t.timestamps
    end
    add_index :workflow_steps, :code, unique: true
  end
end
