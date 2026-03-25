class CreateApiApplicationsAndApiKeys < ActiveRecord::Migration[7.0]
  def change
    create_table :api_applications do |t|
      t.string :name, null: false # application name
      t.string :contact_name
      t.string :contact_email
      t.text :description
      t.integer :privileges, default: 0, null: false # enum: 0=full, 1=read_only
      t.timestamps
    end

    create_table :api_keys do |t|
      t.references :api_application, null: false, foreign_key: true
      t.string :key, null: false
      t.integer :status, null: false, default: 0 # enum: 0=active, 1=grace_period, 2=expired, 3=revoked
      t.datetime :expires_at
      t.timestamps
    end

    add_index :api_keys, [:api_application_id, :status]
    add_index :api_keys, :key, unique: true
  end
end
