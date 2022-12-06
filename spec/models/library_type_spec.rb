# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryType do
  describe '#name' do
    it 'must be present' do
      expect(build(:library_type, name: nil)).not_to be_valid
    end

    it 'must be unique within a pipeline' do
      create(:library_type, name: 'example')
      expect(build(:library_type, name: 'example')).not_to be_valid
    end

    # Initially I hoped we could share library type between pipelines, but that
    # would impact on the ability to use library type to determine pipeline
    # Leaving this test here to warn if someone else makes a similar change in
    # future and hasn't considered this.
    it 'must be unique between pipelines' do
      create(:library_type, name: 'example', pipeline: :pacbio)
      expect(build(:library_type, name: 'example', pipeline: :ont)).not_to be_valid
    end
  end

  describe '::active' do
    subject { described_class.active }

    let!(:active_library_type) { create(:library_type, active: true) }
    let!(:inactive_library_type) { create(:library_type, active: false) }

    it { is_expected.to include(active_library_type) }
    it { is_expected.not_to include(inactive_library_type) }
  end

  it 'must have a pipeline' do
    expect(build(:library_type, pipeline: nil)).not_to be_valid
  end
end
