class CreateCostCodeAndStudyReportView < ActiveRecord::Migration[7.1]
  def up
    Rake::Task['tol_tubes_report_view:v1:create'].invoke
  end

  def down
    Rake::Task['tol_tubes_report_view:destroy'].invoke
  end
end
