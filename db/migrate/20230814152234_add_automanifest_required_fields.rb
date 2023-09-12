class AddAutomanifestRequiredFields < ActiveRecord::Migration[7.0]
  def change
    change_table :samples, bulk: true do |t|
      t.string :sanger_sample_id, comment: 'Sanger sample id'
      t.string :supplier_name, comment: 'Supplier name'
      t.string :taxon_id, comment: 'Taxon Id'
      t.string :donor_id, comment: 'Donor Id'
      t.string :country_of_origin, comment: 'Country of origin'
      t.string :accession_number, comment: 'Accession Number'
    end
  end
end
