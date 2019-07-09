require "rails_helper"

RSpec.describe Pipelines, type: :model do
  let(:params) {
    {
      'pipeline_a': {
        'lims': 'lims_a',
        'instrument_name': 'bert'
      },
      'pipeline_b': {
        'lims': 'lims_b',
        'instrument_name': 'ernie'
      }
    }
  }

  describe '#configure' do

    before(:each) do
      Pipelines.configure(params)
    end

    it 'will create a method for each pipeline' do
      expect(Pipelines.pipeline_a).to be_present
      expect(Pipelines.pipeline_a.lims).to eq('lims_a')

      expect(Pipelines.pipeline_b).to be_present
      expect(Pipelines.pipeline_b.lims).to eq('lims_b')
    end

    it 'will allow pipeline to be found' do
      expect(Pipelines.find('pipeline_a').lims).to eq('lims_a')
      expect(Pipelines.find(:pipeline_a).lims).to eq('lims_a')
    end
  end

end