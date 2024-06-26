# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstrumentTypeValidator do
  let!(:instrument_types) { YAML.load_file(Rails.root.join('config/pacbio_instrument_types.yml'), aliases: true)[Rails.env] }
  let!(:version12_sequel_iie) { create(:pacbio_smrt_link_version, name: 'v12_sequel_iie') }
  let!(:version11) { create(:pacbio_smrt_link_version, name: 'v11') }

  describe 'when the instrument type is Sequel IIe' do
    # This is a test for the config. It would be better to use other tests but want to time box this for now ...
    it 'Sequel IIe and Revio should both exclude records marked for destruction from limits validation' do
      expect(instrument_types['sequel_iie']['models']['plates']['validations']['limits']['options']['exclude_marked_for_destruction']).to be_truthy
      expect(instrument_types['revio']['models']['plates']['validations']['limits']['options']['exclude_marked_for_destruction']).to be_truthy
      expect(instrument_types['revio']['models']['wells']['validations']['sequencing_kit_box_barcode']['options']['exclude_marked_for_destruction']).to be_truthy
    end

    context 'plates' do
      it 'required attributes' do
        instrument_types['sequel_iie']['models']['plates']['validations']['required_attributes']['options']['required_attributes'].each do |attribute|
          plate = build(:pacbio_plate)
          run = build(:pacbio_generic_run, system_name: 'Sequel IIe', smrt_link_version: version12_sequel_iie, plates: [plate])
          plate.send("#{attribute}=", nil)
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(plate.errors.messages[attribute]).to include("can't be blank")
        end
      end

      it 'minimum or maximum number of plates' do
        plates = build_list(:pacbio_plate, 2)

        run = build(:pacbio_generic_run, system_name: 'Sequel IIe', smrt_link_version: version12_sequel_iie, plates: [plates.first])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates]).to be_empty

        # Minimum
        run = build(:pacbio_generic_run, system_name: 'Sequel IIe', smrt_link_version: version12_sequel_iie, plates: [])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates]).to include('must have at least 1 plate')

        # Maximum
        run = build(:pacbio_generic_run, system_name: 'Sequel IIe', smrt_link_version: version12_sequel_iie, plates:)
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates]).to include('must have at most 1 plate')
      end
    end

    context 'wells' do
      it 'minimum or maximum number of wells' do
        run = build(:pacbio_generic_run, system_name: 'Sequel IIe', smrt_link_version: version11, plates: [build(:pacbio_plate, well_count: 1)])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages).to be_empty

        # Minimum
        run = build(:pacbio_generic_run, system_name: 'Sequel IIe', smrt_link_version: version11, plates: [build(:pacbio_plate, well_count: 0)])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates].first).to include("plate #{run.plates.first.plate_number} wells must have at least 1 well")

        # Maximum
        run = build(:pacbio_generic_run, system_name: 'Sequel IIe', smrt_link_version: version11, plates: [build(:pacbio_plate, well_count: 97)])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates].first).to include("plate #{run.plates.first.plate_number} wells must have at most 96 well")
      end
    end
  end

  describe 'when the instrument type is Revio' do
    before do
      create(:pacbio_smrt_link_version, name: 'v12_revio', default: true)
    end

    context 'plates' do
      it 'required attributes' do
        instrument_types['revio']['models']['plates']['validations']['required_attributes']['options']['required_attributes'].each do |attribute|
          plate = build(:pacbio_plate)
          run = build(:pacbio_generic_run, system_name: 'Revio', plates: [plate])
          plate.send("#{attribute}=", nil)
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[:plates]).to include("plate #{plate.plate_number} #{attribute} can't be blank")
        end
      end

      it 'validates sequencing_kit_box_barcode' do
        create(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
        create(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'B', column: '1')])])

        run = build(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates]).to include('plate 1 plates sequencing kit box barcode has already been used on 2 plates')
      end
    end

    context 'wells' do
      it 'when the number of wells is within limits' do
        well_positions = %w[A1 B1 C1 D1]
        run = build(:pacbio_revio_run, well_positions_plate_1: well_positions)
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates]).to be_empty

        run = build(:pacbio_revio_run, well_positions_plate_1: well_positions, well_positions_plate_2: well_positions)
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates]).to be_empty
      end

      it 'when the number of wells exceeds the limit' do
        run = build(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, well_count: 5), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates].length).to eq(3)
        expect(run.errors.messages[:plates]).to include("plate #{run.plates.first.plate_number} wells must have at most 4 wells")
      end

      it 'when the number of wells is under the limit' do
        run = build(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, well_count: 0), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates].length).to eq(2)
        expect(run.errors.messages[:plates]).to include("plate #{run.plates.first.plate_number} wells must have at least 1 well")
      end

      it 'well positions' do
        test_cases = [
          { well_positions_plate_1: ['G1'], well_positions_plate_2: ['A1'] },
          { well_positions_plate_1: %w[A1 B1 C1 H1], well_positions_plate_2: ['A1'], system_name: 'Revio' }
        ]

        test_cases.each do |test_case|
          run = build(:pacbio_revio_run, **test_case)
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)

          validations = instrument_types['revio']['models']['wells']['validations']
          valid_positions = validations['well_positions']['options']['valid_positions']
          invalid_positions = run.plates.first.wells.map(&:position) - valid_positions
          expected_error_message = "plate #{run.plates.first.plate_number} wells #{invalid_positions.join(',')} must be in positions #{valid_positions.join(',')}"

          expect(run.errors.messages[:plates].length).to eq(2)
          expect(run.errors.messages[:plates]).to include(expected_error_message)
        end
      end

      context 'well combinations' do
        it 'valid well combinations' do
          instrument_types['revio']['models']['wells']['validations']['well_combinations']['options']['valid_combinations'].each do |combination|
            run = build(:pacbio_revio_run, system_name: 'Revio', well_positions_plate_1: combination)
            instrument_type_validator = described_class.new(instrument_types:)
            instrument_type_validator.validate(run)
            expect(run.errors.messages).to be_empty
          end
        end

        it 'invalid well combinations' do
          instrument_types['revio']['models']['wells']['validations']['well_combinations']['invalid_combinations'].each do |combination|
            run = build(:pacbio_revio_run, well_positions_plate_1: combination)
            instrument_type_validator = described_class.new(instrument_types:)
            instrument_type_validator.validate(run)
            invalid_order = combination.join(',')
            expect(run.errors.messages[:plates]).to include("plate #{run.plates.first.plate_number} wells must be in a valid order, currently #{invalid_order}")
          end
        end

        it 'wont validate wells that are marked for destruction' do
          well_for_destruction = build(:pacbio_well, row: 'B', column: '1')
          well_for_destruction.mark_for_destruction
          run = build(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1'), well_for_destruction, build(:pacbio_well, row: 'C', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          invalid_order = run.plates.first.wells.map(&:position) - [well_for_destruction.position]
          invalid_order = invalid_order.join(',')
          expect(run.errors.messages[:plates].length).to eq(1)
          expect(run.errors.messages[:plates]).to include("plate #{run.plates.first.plate_number} wells must be in a valid order, currently #{invalid_order}")
        end
      end
    end
  end
end
