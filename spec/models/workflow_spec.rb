# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workflow do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'associations' do
    it { is_expected.to have_many(:workflow_steps).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:workflow_steps).allow_destroy(true) }
  end

  describe 'enum' do
    it 'defines the correct pipeline values' do
      expect(described_class.pipelines).to eq(
        'pacbio' => 0,
        'ont' => 1,
        'extraction' => 2,
        'sample_qc' => 3,
        'hic' => 4,
        'bio_nano' => 5
      )
    end

    it 'returns the correct pipeline keys' do
      expect(described_class.workflow_pipelines).to match_array(%w[pacbio ont extraction sample_qc hic bio_nano])
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated workflow_steps when workflow is destroyed' do
      workflow = described_class.create!(name: 'Test Workflow', pipeline: 'pacbio')
      workflow.workflow_steps.create!(stage: 'Stage 1', code: 'CODE1')

      expect { workflow.destroy }.to change(WorkflowStep, :count).by(-1)
    end
  end
end
