# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# Load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  describe 'tol_tubes_report_view:create' do
    before do
      ApplicationRecord.connection.execute('DROP VIEW IF EXISTS tubes_report;')
    end

    it 'creates the tubes_report view' do
      expect do
        Rake::Task['tol_tubes_report_view:create'].reenable
        Rake::Task['tol_tubes_report_view:create'].invoke
      end
        .to change { ApplicationRecord.connection.execute('SHOW TABLES LIKE "tubes_report";').count }
        .from(0)
        .to(1)
    end
  end

  describe 'tol_tubes_report_view:destroy' do
    before do
      ApplicationRecord.connection.execute('CREATE OR REPLACE VIEW tubes_report AS SELECT 1;')
    end

    it 'destroys the tubes_report view' do
      expect do
        Rake::Task['tol_tubes_report_view:destroy'].reenable
        Rake::Task['tol_tubes_report_view:destroy'].invoke
      end
        .to change { ApplicationRecord.connection.execute('SHOW TABLES LIKE "tubes_report";').count }
        .from(1)
        .to(0)
    end
  end
end
