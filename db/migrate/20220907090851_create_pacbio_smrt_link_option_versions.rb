class CreatePacbioSmrtLinkOptionVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :pacbio_smrt_link_option_versions do |t|

      t.belongs_to :pacbio_smrt_link_version, index: { name: :index_smrt_link_option_versions_on_version_id }, foreign_key: true
      t.belongs_to :pacbio_smrt_link_option, index: { name: :index_smrt_link_option_versions_on_option_id }, foreign_key: true
      t.timestamps
    end
  end
end
