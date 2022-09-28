# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmrtLinkOptionsValidator do
  describe.skip '#validate' do
    let(:record) { build(:pacbio_well) }
    let(:available_smrt_link_versions) { SmrtLink::Versions::AVAILABLE }
    let(:required_fields_by_version) { SmrtLink::Versions.required_fields_by_version }

    let(:versions) { create_list(:pacbio_smrt_link_version, 2) }

    # rubocop:disable RSpec/LetSetup
    let!(:smrt_link_option_for_demultiplex_barcodes) { create(:pacbio_smrt_link_option, key: 'demultiplex_barcodes', validations: { required: true, inclusion: { in: %w[yes no] } }, smrt_link_versions: [versions.first, versions.last]) }
    let!(:smrt_link_option_for_loading_target_p1_plus_p2) { create(:pacbio_smrt_link_option, key: 'loading_target_p1_plus_p2', validations: { allow_blank: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 } }, smrt_link_versions: [versions.first]) }
    let!(:smrt_link_option_for_movie_time) { create(:pacbio_smrt_link_option, key: 'movie_time', validations: { presence: true, numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 30 } }, smrt_link_versions: [versions.last]) }
    # rubocop:enable RSpec/LetSetup

    context 'valid' do
      let(:record) { build(:pacbio_well, plate: create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: versions.first)), demultiplex_barcodes: 'yes', loading_target_p1_plus_p2: 0.85) }

      before do
        described_class.new(available_smrt_link_versions:, required_fields_by_version:).validate(record)
      end

      it 'does not add an error to the record' do
        expect(record).to be_valid
      end
    end

    context 'invalid' do
      it 'will mark the record as invalid' do
        expect(build(:pacbio_well, demultiplex_barcodes: nil)).not_to be_valid
      end

      context 'will show the correct errors' do
        let(:plate) { create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: versions.first)) }

        it 'when the value is missing' do
          well = build(:pacbio_well, plate:, demultiplex_barcodes: nil)
          expect(well.errors.full_messages.length).to eq(1)
          expect(well.errors.full_messages).to include('Demultiplex barcodes must be present')
        end

        it 'when the value is not in the proscribed list' do
          well = build(:pacbio_well, plate:, demultiplex_barcodes: 'si')
          expect(well.errors.full_messages).to include('Demultiplex barcodes is not a valid value')
        end

        it 'when the value is not a number' do
          well = build(:pacbio_well, plate:, loading_target_p1_plus_p2: 'manana')
          expect(well.errors.full_messages).to include('Loading target p1 plus p2 is not a valid value')
        end

        it 'when the value is not within range' do
          well = build(:pacbio_well, plate:, loading_target_p1_plus_p2: 2)
          expect(well.errors.full_messages).to include('Loading target p1 plus p2 is not in range')
        end
      end

      it 'will only mark the record as invalid for the correct version' do
        well = build(:pacbio_well, plate:, movie_time: nil)
        expect(well).to be_valid
      end
    end
  end
end
