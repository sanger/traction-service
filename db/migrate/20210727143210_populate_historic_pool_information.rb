# frozen_string_literal: true

# Migrate information from existing libraries:
# 1 - Where there is a single library, take all the information
# 2 - Otherwise, only grab the timestamps
class PopulateHistoricPoolInformation < ActiveRecord::Migration[6.0]
  def up
    Pacbio::Pool.transaction do
      say 'Fetching libraries without timestamps'
      say "Found #{pools_to_update.count} pools", true
      say 'Updating pools'
      ids = pools_to_update.find_each.map do |pool|
        next if pool.libraries.empty?

        attributes = pool_attributes(pool)
        pool.update!(attributes)
        [pool.id]
      end

      backup_data(ids)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          'Cannot be rolled-back automatically. Check ~/PopulateHistoricPoolInformationBackup-*.csv'
  end

  def pool_attributes(pool)
    if pool.libraries.one?
      pool.libraries.first.attributes.slice('updated_at',
                                            'created_at',
                                            'volume',
                                            'concentration',
                                            'template_prep_kit_box_barcode',
                                            'fragment_size')
    else
      pool.libraries.first.attributes.slice('updated_at','created_at')
    end
  end

  def pools_to_update
    Pacbio::Pool.where(created_at: nil).includes(:libraries)
  end

  def backup_data(data)
    timestamp = Time.zone.now.strftime('%Y%m%d%H%M%S')
    filename = Pathname(Dir.home).join("PopulateHistoricPoolInformationBackup-#{timestamp}.csv")

    CSV.open(filename, 'w') do |csv|
      csv << %w[pool_id]
      data.each { |row| csv << row }
    end

    say "Backed up to #{filename}", true
  end
end
