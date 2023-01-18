# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PipelineValidator do
  describe '#validate_each' do
    let(:record_class) { Ont::Request }
    let(:record) { record_class.new }
    let(:attribute) { :library_type }
    let(:pipeline) { :ont }

    before do
      described_class.new(attributes: [attribute], with: pipeline).validate_each(record, attribute, value)
    end

    context 'with a nil value' do
      let(:value) { nil }

      # We'll allow nil here, and let the presence validator handle that if
      # required
      it 'does not add an error to the record' do
        expect(record.errors.full_messages).to be_empty
      end
    end

    context 'with the incorrect pipeline' do
      let(:value) { build(:library_type, :pacbio) }

      it 'adds an error to the record' do
        expect(record.errors.full_messages).to include('Library type is in pacbio not ont pipeline')
      end
    end

    context 'with the correct pipeline' do
      let(:value) { build(:library_type, pipeline) }

      it 'does not add an error to the record' do
        expect(record.errors.full_messages).to be_empty
      end
    end
  end
end
