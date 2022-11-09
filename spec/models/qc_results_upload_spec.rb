# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcResultsUpload, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  describe '#create' do
    it 'is possible to create a new record' do
      expect do
        described_class.create!(
          csv_data: 'a,b,c\n'
        )
      end.to change(described_class, :count).by(1)
    end

    it 'errors if missing required csv_data field' do
      expect do
        described_class.create!
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end