# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataType do
  describe '#name' do
    it 'must be present' do
      expect(build(:data_type, name: nil)).not_to be_valid
    end

    it 'must be unique within a pipeline' do
      create(:data_type, name: 'example')
      expect(build(:data_type, name: 'example')).not_to be_valid
    end

    it 'can be shared between pipelines' do
      create(:data_type, name: 'example', pipeline: :pacbio)
      expect(build(:data_type, name: 'example', pipeline: :ont)).to be_valid
    end
  end

  it 'must have a pipeline' do
    expect(build(:data_type, pipeline: nil)).not_to be_valid
  end
end
