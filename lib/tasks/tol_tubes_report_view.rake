# frozen_string_literal: true

namespace :tol_tubes_report_view do
  desc 'Manage the creation and destruction of the tubes_report view.'
  task create: [:environment] do
    ApplicationRecord.connection.execute <<~END_OF_SQL
      CREATE OR REPLACE VIEW tubes_report AS
        SELECT
          pl.created_at AS library_created_at,
          CASE
            WHEN st.barcode IS NOT NULL
              THEN st.barcode
            ELSE
              CONCAT(sp.barcode, ':', sw.`position`)
          END AS source_identifier,
          dt.barcode AS destination_barcode,
          s.name AS sample_name,
          pr.cost_code,
          pr.external_study_id AS study_uuid
        FROM pacbio_libraries pl
        JOIN pacbio_requests pr
          ON pr.id = pl.pacbio_request_id
        JOIN pacbio_pools pp
          ON pp.id = pl.pacbio_pool_id
        JOIN tubes dt
          ON dt.id = pp.tube_id
        JOIN requests r
          ON r.requestable_type = "Pacbio::Request"
          AND r.requestable_id = pr.id
        JOIN samples s
          ON s.id = r.sample_id
        LEFT JOIN container_materials cmt
          ON cmt.material_type = "Pacbio::Request"
          AND cmt.material_id = pr.id
          AND cmt.container_type = "Tube"
        LEFT JOIN tubes st
          ON st.id = cmt.container_id
        LEFT JOIN container_materials cmw
          ON cmw.material_type = "Pacbio::Request"
          AND cmw.material_id = pr.id
          AND cmw.container_type = "Well"
        LEFT JOIN wells sw
          ON sw.id  = cmw.container_id
        LEFT JOIN plates sp
          ON sp.id = sw.plate_id;
    END_OF_SQL

    puts '-> TOL tubes report view successfully created' unless Rails.env.test?
  end

  task destroy: [:environment] do
    ApplicationRecord.connection.execute <<~END_OF_SQL
      DROP VIEW IF EXISTS tubes_report;
    END_OF_SQL

    puts '-> TOL tubes report view successfully destroyed' unless Rails.env.test?
  end
end
