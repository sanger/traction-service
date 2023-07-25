# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v10') || create(:pacbio_smrt_link_version, name: 'v10', default: true)
    Pacbio::SmrtLinkVersion.find_by(name: 'v11') || create(:pacbio_smrt_link_version, name: 'v11')
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_revio') || create(:pacbio_smrt_link_version, name: 'v12_revio')
  end

  describe 'ont_instruments:create' do
    it 'creates the correct instrument data' do
      Rake::Task['ont_instruments:create'].reenable
      expect { Rake::Task['ont_instruments:create'].invoke }.to change(Ont::Instrument, :count).and output("-> ONT Instruments successfully created\n").to_stdout
    end
  end
end
