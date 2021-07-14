# frozen_string_literal: true

# Legacy libraries don't have a pool id set. We'll generate one here.
class GeneratePoolsForLegacyLibraries < ActiveRecord::Migration[6.0]
  def up
    say 'Fetching libraries without pools'
    libraries = Pacbio::Library.where(pacbio_pool_id: nil)
                               .includes(:tube)
    say "Found #{libraries.count} libraries", true

    say 'Generating pools'
    updated_libraries = transaction do
      libraries.find_each.map do |library|
        pool = library.create_pool!(tube: library.tube, libraries: [library])
        [library.id, library.tube.id, pool.id]
      end
    end

    backup_data(updated_libraries)
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          'Cannot be rolled-back automatically. Check ~/TractionPoolsBackup-*.csv'
  end

  def backup_data(data)
    timestamp = Time.zone.now.strftime('%Y%m%d%H%M%S')
    filename = Pathname(Dir.home).join("TractionPoolsBackup-#{timestamp}.csv")

    CSV.open(filename, 'w') do |csv|
      csv << %w[library_id tube_id pool_id]
      data.each { |row| csv << row }
    end

    say "Backed up to #{filename}", true
  end
end
