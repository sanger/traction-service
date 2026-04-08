class CreateApiApplicationsAndApiKeys < ActiveRecord::Migration[7.0]
  def change
    create_table :api_applications do |t|
      t.string :name, null: false # application name
      t.string :contact_name, null: false
      t.string :contact_email
      t.text :description
      t.timestamps
    end

    create_table :api_keys do |t|
      t.references :api_application, null: false, foreign_key: true
      t.string :key_digest, null: false
      t.integer :status, null: false, default: 0 # enum: 0=active, 1=grace_period, 2=expired
      t.datetime :expires_at
      t.datetime :last_used_at
      t.timestamps
    end

    add_index :api_keys, [:api_application_id, :status]
    add_index :api_keys, :key_digest, unique: true
  end
end
