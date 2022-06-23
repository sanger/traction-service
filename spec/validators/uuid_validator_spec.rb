# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UuidValidator do
  describe '#validate_each' do
    let(:record_class) { Ont::Request }
    let(:record) { record_class.new }
    let(:attribute) { :external_study_id }

    before do
      described_class.new(attributes: [attribute]).validate_each(record, attribute, value)
    end

    context 'with a nil value' do
      let(:value) { nil }

      it 'is valid' do
        expect(record.errors.full_messages).to be_empty
      end
    end

    context 'with a non-uuid' do
      let(:value) { 'not-a-uuid' }

      it 'adds an error to the record' do
        expect(record.errors.full_messages).to include('External study is not a valid uuid')
      end
    end

    context 'with a uuid' do
      let(:value) { generate(:uuid) }

      it 'is valid' do
        expect(record.errors.full_messages).to be_empty
      end
    end
  end
end
