# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowStep, type: :model do
  let(:workflow) { Workflow.create!(name: 'Test Workflow', pipeline: 'pacbio') }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:code) }

    it 'validates uniqueness of code case-insensitively' do
      workflow_step = create(:workflow_step, code: 'unique_code', workflow:)
      expect(workflow_step).to validate_uniqueness_of(:code).case_insensitive
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:workflow) }
  end
end
