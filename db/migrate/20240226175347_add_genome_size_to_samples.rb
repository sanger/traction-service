# frozen_string_literal: true

# Add an optional column genome_size to samples to recieve this information
# from TOL through receptions endpoint.
class AddGenomeSizeToSamples < ActiveRecord::Migration[7.1]
  def change
    change_table :samples, bulk: true do |t|
      t.string :genome_size, comment: 'The genome size (base pairs) for a sample.'
    end
  end
end
