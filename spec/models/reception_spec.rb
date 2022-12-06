# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reception do
  subject { build(:reception, attributes) }

  context 'without a source' do
    let(:attributes) { { source: nil } }

    it { is_expected.to be_invalid }
  end

  context 'with a source' do
    let(:attributes) { { source: 'traction-ui.sequencescape' } }

    it { is_expected.to be_valid }
  end

  # We get a bit strict with validation, mainly to stop us getting a
  # mix of styles should we have other apps posting to our API
  context 'with a space' do
    let(:attributes) { { source: 'traction-ui sequencescape' } }

    it { is_expected.to be_invalid }
  end

  context 'with an underscore' do
    let(:attributes) { { source: 'traction_ui.sequencescape' } }

    it { is_expected.to be_invalid }
  end

  context 'with uppercase' do
    let(:attributes) { { source: 'traction-ui.Sequencescape' } }

    it { is_expected.to be_invalid }
  end
end
