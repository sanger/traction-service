# frozen_string_literal: true

require 'csv'

# Initially tubes imported from sample extraction had the original barcodes
# stored in 'source_barcode' on request, and new traction barcodes generated.
# This behaviour is changing, and this migration replaces the historic
# traction barcodes with their sample extraction equivalent.
# TRAC barcodes were not printed off or exported for these tubes.
class MigrateSamplesExtractionBarcodesToTubes < ActiveRecord::Migration[6.0]
  # We don't use the associations, as otherwise the migration becomes coupled to
  # the underlying model, and can fail if the associations are changed.
  JOINS = [
    "INNER JOIN `container_materials` ON `container_materials`.`material_type` = 'Pacbio::Request'
      AND `container_materials`.`container_type` = 'Tube'
      AND `container_materials`.`material_id` = `pacbio_requests`.`id`",
    'INNER JOIN `tubes` ON `tubes`.`id` = `container_materials`.`container_id`'
  ]

  def up
    say 'Backing up original data'
    backup_data
    say 'Migrating data'
    # rubocop:disable Rails/SkipsModelValidations
    pacbio_requests.update_all('tubes.barcode = pacbio_requests.source_barcode')
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          'Cannot be rolled-back manually. Check ~/TractionBarcodeBackup-*.csv'
  end

  private

  def pacbio_requests
    Pacbio::Request.where.not(source_barcode: nil).joins(JOINS)
  end

  def backup_data
    timestamp = Time.zone.now.strftime('%Y%m%d%H%M%S')
    data = pacbio_requests.pluck(:id, :source_barcode, '`tubes`.`id`', '`tubes`.`barcode`')
    say "#{data.length} records found", true
    filename = Pathname(Dir.home).join("TractionBarcodeBackup-#{timestamp}.csv")

    CSV.open(filename, 'w') do |csv|
      csv << %w[request_id sample_extraction_barcode tube_id traction_barcode]
      data.each { |row| csv << row }
    end

    say "Backed up to #{filename}", true
  end
end
