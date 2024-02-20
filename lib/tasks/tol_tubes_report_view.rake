# frozen_string_literal: true

namespace :tol_tubes_report_view do
  desc 'Manage the creation and destruction of the tubes_report view.'
  task create: [:environment] do
    ApplicationRecord.connection.execute <<~END_OF_SQL
      CREATE OR REPLACE VIEW tubes_report AS
      SELECT
        pl.created_at,
        t.barcode,
        pr.cost_code,
        pr.external_study_id as study_uuid
      FROM pacbio_libraries pl
      JOIN pacbio_requests pr
        ON pr.id = pl.pacbio_request_id
      JOIN pacbio_pools pp
        ON pp.id = pl.pacbio_pool_id
      JOIN tubes t
        ON t.id = pp.tube_id;
    END_OF_SQL

    puts '-> TOL tubes report view successfully created'
  end

  task destroy: [:environment] do
    ApplicationRecord.connection.execute <<~END_OF_SQL
      DROP VIEW IF EXISTS tubes_report;
    END_OF_SQL

    puts '-> TOL tubes report view successfully destroyed'
  end
end
