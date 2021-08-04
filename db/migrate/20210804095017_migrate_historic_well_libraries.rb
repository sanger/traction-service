# frozen_string_literal: true

# Migrate historic well library associations to pools
class MigrateHistoricWellLibraries < ActiveRecord::Migration[6.0]
  # Stub class to support migration
  class PacbioWellLibrary < ApplicationRecord
    self.table_name = 'pacbio_well_libraries'
  end

  def up
    say 'Fetching well_libraries'
    existing_pools = Pacbio::WellPool.pluck(:pacbio_pool_id)
    well_pools = PacbioWellLibrary.joins(
                    'LEFT OUTER JOIN pacbio_libraries ON pacbio_libraries.id = pacbio_well_libraries.pacbio_library_id'
                  )
                  .where.not(pacbio_libraries: { pacbio_pool_id: existing_pools })
                  .pluck('pacbio_well_libraries.pacbio_well_id','pacbio_libraries.pacbio_pool_id')
    say "Found #{well_pools.count} well_libraries", true

    say 'Generating well_pools'
    well_pool_attributes = well_pools.map do |well_id, pool_id|
      { pacbio_well_id: well_id, pacbio_pool_id: pool_id }
    end

    transaction do
      Pacbio::WellPool.create!(well_pool_attributes)
    end

    backup_data(well_pools)
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          'Cannot be rolled-back automatically. Check ~/MigrateHistoricWellLibrariesBackup-*.csv'
  end

  def backup_data(data)
    timestamp = Time.zone.now.strftime('%Y%m%d%H%M%S')
    filename = Pathname(Dir.home).join("MigrateHistoricWellLibrariesBackup-#{timestamp}.csv")

    CSV.open(filename, 'w') do |csv|
      csv << %w[well_id pool_id]
      data.each { |row| csv << row }
    end

    say "Backed up to #{filename}", true
  end
end
