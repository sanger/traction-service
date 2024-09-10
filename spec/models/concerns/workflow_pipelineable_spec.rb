# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowPipelineable, type: :concern do
  # Create a dummy class to include the concern
  let(:dummy_class) do
    Class.new(ApplicationRecord) do
      self.table_name = 'dummy_table'
      include WorkflowPipelineable
    end
  end

  describe 'enum' do
    it 'defines the correct pipeline values' do
      expect(dummy_class.pipelines).to eq(
        'pacbio' => 0,
        'ont' => 1,
        'extraction' => 2,
        'sample_qc' => 3,
        'hic' => 4,
        'bio_nano' => 5
      )
    end
  end

  describe '.workflow_pipelines' do
    it 'returns the correct pipeline keys' do
      expect(dummy_class.workflow_pipelines).to match_array(%w[pacbio ont extraction sample_qc hic bio_nano])
    end
  end
end
