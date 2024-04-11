# frozen_string_literal: true

namespace :tol_tubes_report_view do
  desc 'Manage the creation and destruction of the tubes_report view.'
  task create: [:environment] do
    Rake::Task['tol_tubes_report_view:v2:create'].execute
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
                THEN src_tube.barcode -- Get the tube barcode if a tube was found...
              ELSE -- ...otherwise create a barcode from the plate and well position.
                CONCAT(src_plate.barcode, ':', src_well.`position`)
            END AS source_identifier,
            CASE
              WHEN pool_tube.barcode IS NOT NULL
                THEN pool_tube.barcode -- Get the destination tube barcode if the pool referenced a tube...
              ELSE -- ...otherwise get the destination tube barcode from the tube associated with the library.
                lib_tube.barcode
            END AS destination_barcode,
            samp.name AS sample_name,
            pb_req.estimate_of_gb_required AS genome_size,
            pb_req.cost_code,
            pb_req.external_study_id AS study_uuid
          FROM pacbio_libraries pb_lib -- Start with the Pacbio libraries.
          JOIN pacbio_requests pb_req -- Join each library to its Pacbio request.
            ON pb_req.id = pb_lib.pacbio_request_id
          LEFT JOIN pacbio_pools pb_pool -- Try to join a Pacbio pool, but some libraries won't have a pool.
            ON pb_pool.id = pb_lib.pacbio_pool_id
          LEFT JOIN tubes pool_tube -- Try to join a tube for the pool, but some pools might not have a tube.
            ON pool_tube.id = pb_pool.tube_id
          LEFT JOIN tubes lib_tube -- Try to join a tube directly associated with the library, some libraries don't have a tube.
            ON lib_tube.id = pb_lib.tube_id
          JOIN requests req -- Find the base request for the Pacbio request polymorphic association.
            ON req.requestable_type = "Pacbio::Request"
            AND req.requestable_id = pb_req.id
          JOIN samples samp -- Join the sample associated with the request.
            ON samp.id = req.sample_id
          LEFT JOIN container_materials cmt -- Try to find a relationship between a tube and the Pacbio request.
            ON cmt.material_type = "Pacbio::Request"
            AND cmt.material_id = pb_req.id
            AND cmt.container_type = "Tube"
          LEFT JOIN tubes src_tube -- Join the actual tube if the relationship above was found.
            ON src_tube.id = cmt.container_id
          LEFT JOIN container_materials cmw -- Try to find a relationship between a well and the Pacbio request.
            ON cmw.material_type = "Pacbio::Request"
            AND cmw.material_id = pb_req.id
            AND cmw.container_type = "Well"
          LEFT JOIN wells src_well -- Join the actual well if the relationship above was found.
            ON src_well.id  = cmw.container_id
          LEFT JOIN plates src_plate -- Join the plate for the well if the relationship above was found.
            ON src_plate.id = src_well.plate_id;
      END_OF_SQL

      puts '-> TOL tubes report view successfully created' unless Rails.env.test?
    end
  end

  namespace :v2 do
    desc 'Version 2 -- valid from 2024-04-11'
    task create: [:environment] do
      ApplicationRecord.connection.execute <<~END_OF_SQL
        CREATE OR REPLACE VIEW tubes_report AS
          SELECT
            samp.created_at AS sample_created_at,
            CASE
              WHEN src_tube.barcode IS NOT NULL
                THEN src_tube.barcode -- Get the tube barcode if a tube was found...
              ELSE -- ...otherwise create a barcode from the plate and well position.
                CONCAT(src_plate.barcode, ':', src_well.`position`)
            END AS source_identifier,
            lib_tube.barcode AS destination_barcode,
            samp.name AS sample_name,
            pb_req.estimate_of_gb_required AS genome_size,
            pb_req.cost_code,
            pb_req.external_study_id AS study_uuid
          FROM pacbio_requests pb_req -- Start with the Pacbio Requests.
          LEFT JOIN pacbio_libraries pb_lib -- Try to join a Pacbio Library, but some requests won't have a library.
            ON pb_req.id = pb_lib.pacbio_request_id
          LEFT JOIN tubes lib_tube -- Try to join a tube directly associated with the library, some libraries don't have a tube.
            ON lib_tube.id = pb_lib.tube_id
          JOIN requests req -- Find the base request for the Pacbio request polymorphic association.
            ON req.requestable_type = "Pacbio::Request"
            AND req.requestable_id = pb_req.id
          JOIN samples samp -- Join the sample associated with the request.
            ON samp.id = req.sample_id
          LEFT JOIN container_materials cmt -- Try to find a relationship between a tube and the Pacbio request.
            ON cmt.material_type = "Pacbio::Request"
            AND cmt.material_id = pb_req.id
            AND cmt.container_type = "Tube"
          LEFT JOIN tubes src_tube -- Join the actual tube if the relationship above was found.
            ON src_tube.id = cmt.container_id
          LEFT JOIN container_materials cmw -- Try to find a relationship between a well and the Pacbio request.
            ON cmw.material_type = "Pacbio::Request"
            AND cmw.material_id = pb_req.id
            AND cmw.container_type = "Well"
          LEFT JOIN wells src_well -- Join the actual well if the relationship above was found.
            ON src_well.id  = cmw.container_id
          LEFT JOIN plates src_plate -- Join the plate for the well if the relationship above was found.
            ON src_plate.id = src_well.plate_id;
      END_OF_SQL

      puts '-> TOL tubes report view successfully created' unless Rails.env.test?
    end
  end
end
