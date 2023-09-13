# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  describe 'qc_assay_types:create' do
    it 'creates the correct number of qc assay types' do
      expect { Rake::Task['qc_assay_types:create'].invoke }.to change(QcAssayType, :count).by(16).and output(
        <<~HEREDOC
          -> QC Assay Types updated
        HEREDOC
      ).to_stdout
    end
  end
end
