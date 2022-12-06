# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmrtLinkOptionsValidator do
  describe '#validate' do
    let(:record) { build(:pacbio_well) }
    let(:versions) { create_list(:pacbio_smrt_link_version, 2) }

    before do
      create(:pacbio_smrt_link_option, key: 'demultiplex_barcodes', validations: { presence: {}, inclusion: { in: Pacbio::GENERATE } }, smrt_link_versions: [versions.first, versions.last])
      create(:pacbio_smrt_link_option, key: 'loading_target_p1_plus_p2', validations: { numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 } }, smrt_link_versions: [versions.first])
      create(:pacbio_smrt_link_option, key: 'movie_time', validations: { presence: {}, numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 30 } }, smrt_link_versions: [versions.last])
    end

    context 'valid' do
      let(:record) { build(:pacbio_well, plate: create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: versions.first)), demultiplex_barcodes: 'In SMRT Link', loading_target_p1_plus_p2: 0.85, movie_time: 5) }

      before do
        described_class.new.validate(record)
      end

      it 'does not add an error to the record' do
        expect(record).to be_valid
      end
    end

    context 'invalid' do
      let(:plate) { create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: versions.first)) }

      it 'will mark the record as invalid' do
        well = build(:pacbio_well, plate:, demultiplex_barcodes: nil)
        described_class.new.validate(well)
        expect(well).not_to be_valid
      end

      context 'will show the correct errors' do
        let(:plate) { create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: versions.first)) }

        it 'when the value is missing' do
          well = build(:pacbio_well, plate:, demultiplex_barcodes: nil)
          described_class.new.validate(well)
          p well.errors.full_messages
          expect(well.errors.full_messages.length).to eq(2)
          expect(well.errors.full_messages).to include("Demultiplex barcodes can't be blank")
          expect(well.errors.full_messages).to include('Demultiplex barcodes is not included in the list')
        end

        it 'when the value is not in the proscribed list' do
          well = build(:pacbio_well, plate:, demultiplex_barcodes: 'si')
          described_class.new.validate(well)
          expect(well.errors.full_messages).to include('Demultiplex barcodes is not included in the list')
        end

        it 'when the value is not a number' do
          well = build(:pacbio_well, plate:, loading_target_p1_plus_p2: 'manana')
          described_class.new.validate(well)
          expect(well.errors.full_messages).to include('Loading target p1 plus p2 is not a number')
        end

        it 'when the value is not within range' do
          well = build(:pacbio_well, plate:, loading_target_p1_plus_p2: 2)
          described_class.new.validate(well)
          expect(well.errors.full_messages).to include('Loading target p1 plus p2 must be less than or equal to 1')
        end
      end

      it 'will only mark the record as invalid for the correct version' do
        well = build(:pacbio_well, plate:, movie_time: nil)
        described_class.new.validate(well)
        expect(well).to be_valid
      end
    end
  end
end
