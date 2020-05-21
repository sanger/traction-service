# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pipelines::ConstantsAccessor, type: :model do
  context 'when base constants are defined' do
    let!(:mock_rails_config) do
      Class.new do
        def env_constants
          {
            ont: {
              covid: {
                pcr_tag_set: {
                  name: 'test tag set name',
                  hostname: 'test tag set host name'
                },
                study_uuid: 'test study uuid'
              }
            }
          }
        end
      end.new
    end

    before do
      allow(Rails).to receive(:configuration).and_return(mock_rails_config)
    end

    it 'will return the pcr tag set name' do
      expect(Pipelines::ConstantsAccessor.ont_covid_pcr_tag_set_name).to eq('test tag set name')
    end

    it 'will return the pcr tag set hostname' do
      expect(Pipelines::ConstantsAccessor.ont_covid_pcr_tag_set_hostname)
        .to eq('test tag set host name')
    end

    it 'will return the study id' do
      expect(Pipelines::ConstantsAccessor.ont_covid_study_uuid).to eq('test study uuid')
    end
  end
end
