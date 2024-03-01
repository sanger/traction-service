# frozen_string_literal: true

namespace :tol_tubes_report_view do
  desc 'Manage the creation and destruction of the tubes_report view.'
  task create: [:environment] do
    Rake::Task['tol_tubes_report_view:v1:create'].execute
  end

  task destroy: [:environment] do
    ApplicationRecord.connection.execute <<~END_OF_SQL
      DROP VIEW IF EXISTS tubes_report;
    END_OF_SQL

    puts '-> TOL tubes report view successfully destroyed' unless Rails.env.test?
  end

  namespace :v1 do
    desc 'Version 1 -- valid from 2024-03-01'
    task create: [:environment] do
      ApplicationRecord.connection.execute <<~END_OF_SQL
        CREATE OR REPLACE VIEW tubes_report AS
          SELECT
            pb_lib.created_at AS library_created_at,
            CASE
              WHEN src_tube.barcode IS NOT NULL
                THEN src_tube.barcode
              ELSE
                CONCAT(src_plate.barcode, ':', src_well.`position`)
            END AS source_identifier,
            CASE
              WHEN pool_tube.barcode IS NOT NULL
                THEN pool_tube.barcode
              ELSE
                lib_tube.barcode
            END AS destination_barcode,
            samp.name AS sample_name,
            pb_req.estimate_of_gb_required AS genome_size,
            pb_req.cost_code,
            pb_req.external_study_id AS study_uuid
          FROM pacbio_libraries pb_lib
          JOIN pacbio_requests pb_req
            ON pb_req.id = pb_lib.pacbio_request_id
          LEFT JOIN pacbio_pools pb_pool
            ON pb_pool.id = pb_lib.pacbio_pool_id
          LEFT JOIN tubes pool_tube
            ON pool_tube.id = pb_pool.tube_id
          LEFT JOIN tubes lib_tube
            ON lib_tube.id = pb_lib.tube_id
          JOIN requests req
            ON req.requestable_type = "Pacbio::Request"
            AND req.requestable_id = pb_req.id
          JOIN samples samp
            ON samp.id = req.sample_id
          LEFT JOIN container_materials cmt
            ON cmt.material_type = "Pacbio::Request"
            AND cmt.material_id = pb_req.id
            AND cmt.container_type = "Tube"
          LEFT JOIN tubes src_tube
            ON src_tube.id = cmt.container_id
          LEFT JOIN container_materials cmw
            ON cmw.material_type = "Pacbio::Request"
            AND cmw.material_id = pb_req.id
            AND cmw.container_type = "Well"
          LEFT JOIN wells src_well
            ON src_well.id  = cmw.container_id
          LEFT JOIN plates src_plate
            ON src_plate.id = src_well.plate_id;
      END_OF_SQL

      puts '-> TOL tubes report view successfully created' unless Rails.env.test?
    end
  end
end
