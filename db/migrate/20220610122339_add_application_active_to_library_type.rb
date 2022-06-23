# frozen_string_literal: true

# Reminded of
# https://github.com/sanger/traction-service/issues/730
class AddApplicationActiveToLibraryType < ActiveRecord::Migration[7.0]
  def change
    add_column :library_types, :external_identifier, :string
    add_column :library_types, :active, :boolean, default: 1, null: false
  end
end
