# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcResultsUploadFactory, type: :model do
  describe '#create_entities!' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns true' do
      expect(factory.create_entities!).to be true
    end
  end
end
