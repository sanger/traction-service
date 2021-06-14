# frozen_string_literal: true

# The association between a request and a library has become a belongs_to
# and has moved from request_libraries. This migrate is concerned with moving
# existing data
class MigrateExistingPacbioRequestData < ActiveRecord::Migration[6.0]
  JOIN_TABLE = 'pacbio_request_libraries'
  # We don't use the associations, as otherwise the migration becomes coupled to
  # the underlying model, and can fail if the associations are changed.
  JOINS = "LEFT OUTER JOIN #{JOIN_TABLE} ON #{JOIN_TABLE}.pacbio_library_id = pacbio_libraries.id"

  def up
    sanity_check
    say 'Migrating data'
    # rubocop:disable Rails/SkipsModelValidations
    pacbio_libraries.update_all([
      "pacbio_libraries.pacbio_request_id = #{JOIN_TABLE}.pacbio_request_id",
      "pacbio_libraries.tag_id = #{JOIN_TABLE}.tag_id"
    ])
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    say 'Removing data'
    pacbio_libraries.where([
      "pacbio_libraries.pacbio_request_id = #{JOIN_TABLE}.pacbio_request_id",
      "pacbio_libraries.tag_id = #{JOIN_TABLE}.tag_id"
    ]).update_all([
      'pacbio_libraries.pacbio_request_id = NULL',
      'pacbio_libraries.tag_id = NULL'
    ])

    say 'Checking for additional data'
    additional_data = pacbio_libraries.where("#{JOIN_TABLE}.id IS NULL")
                                      .pluck(:id, :pacbio_request_id, :tag_id)
    say "#{additional_data.length} items found", true
    return if additional_data.blank?

    say 'Inserting new request library records', true
    # rubocop:disable Rails/SkipsModelValidations
    Pacbio::RequestLibrary.insert_all(
      additional_data.map do |library_id, request_id, tag_id|
        { pacbio_library_id: library_id, pacbio_request_id: request_id, tag_id: tag_id }
      end
    )
    # rubocop:enable Rails/SkipsModelValidations
  end

  private

  def pacbio_libraries
    Pacbio::Library.joins(JOINS)
  end

  # Basic sanity check to ensure we aren't doing something destructive
  def sanity_check
    say 'Checking for libraries with multiple requests'
    libraries_with_multiple_requests = Pacbio::RequestLibrary.group(:pacbio_library_id)
                                                             .where.not(pacbio_library_id: nil)
                                                             .having('count(id) > 1')
                                                             .pluck(:pacbio_library_id)

    if libraries_with_multiple_requests.empty?
      say 'Okay', true
      return
    end

    raise StandardError, "Libraries #{libraries_with_multiple_requests} have multiple requests"
  end
end
