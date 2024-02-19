class CreateCostCodeAndStudyReportView < ActiveRecord::Migration[7.1]
  def up
    # Create the view needed for TOL reports on tubes.
    execute <<-SQL
      CREATE VIEW tubes_report AS
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
    SQL
  end

  def down
    # Remove the view.
    execute <<-SQL
      DROP VIEW tubes_report;
    SQL
  end
end
