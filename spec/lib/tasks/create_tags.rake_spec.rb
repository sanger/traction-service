# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v10') || create(:pacbio_smrt_link_version, name: 'v10', default: true)
    Pacbio::SmrtLinkVersion.find_by(name: 'v11') || create(:pacbio_smrt_link_version, name: 'v11')
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_revio') || create(:pacbio_smrt_link_version, name: 'v12_revio')
  end

  describe 'create tags' do
    it 'creates all of the pacbio tag sets' do
      Rake::Task['tags:create:pacbio_all'].invoke
      expect(TagSet.count).to eq(7)
    end

    it 'creates all of the ont tag sets' do
      Rake::Task['tags:create:ont_all'].invoke
      expect(TagSet.count).to eq(1)
    end

    it 'creates all of the tag sets' do
      # We need to reenable all tag tasks because they have all already been invoked by this point
      Rake.application.in_namespace(:tags) { |namespace| namespace.tasks.each(&:reenable) }
      Rake::Task['tags:create:traction_all'].invoke
      expect(TagSet.count).to eq(8)
    end
  end
end
