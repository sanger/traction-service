# frozen_string_literal: true

require 'rails_helper'

RSpec.describe.skip InstrumentTypeValidator, reason: 'Refactor' do
  let!(:instrument_types) { YAML.load_file(Rails.root.join('config/pacbio_instrument_types.yml'), aliases: true)[Rails.env] }

  describe 'when the instrument type is Sequel IIe' do
    before do
      create(:pacbio_smrt_link_version, name: 'v11', default: true)
    end

    context 'run' do
      it 'required attributes' do
        instrument_types['sequel_iie']['run']['required_attributes'].each do |attribute|
          run = build(:pacbio_run, system_name: 'Sequel IIe', plates: [build(:pacbio_plate)])
          run.send("#{attribute}=", nil)
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[attribute]).to include("can't be blank")
        end
      end
    end

    context 'plates' do
      it 'required attributes' do
        instrument_types['sequel_iie']['plates']['required_attributes'].each do |attribute|
          plate = build(:pacbio_plate)
          run = build(:pacbio_run, system_name: 'Sequel IIe', plates: [plate])
          plate.send("#{attribute}=", nil)
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(plate.errors.messages[attribute]).to include("can't be blank")
        end
      end

      it 'minimum or maximum number of plates' do
        plates = build_list(:pacbio_plate, 2)

        run = build(:pacbio_run, system_name: 'Sequel IIe', plates: [plates.first])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates]).to be_empty

        # Minimum
        run = build(:pacbio_run, system_name: 'Sequel IIe', plates: [])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates]).to include('must have at least 1 plate')

        # Maximum
        run = build(:pacbio_run, system_name: 'Sequel IIe', plates:)
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates]).to include('must have at most 1 plate')
      end
    end

    context 'wells' do
      it 'minimum or maximum number of wells' do
        run = build(:pacbio_run, system_name: 'Sequel IIe', plates: [build(:pacbio_plate, well_count: 1)])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages).to be_empty

        # Minimum
        run = build(:pacbio_run, system_name: 'Sequel IIe', plates: [build(:pacbio_plate, well_count: 0)])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:wells]).to include("plate #{run.plates.first.plate_number} must have at least 1 well")

        # Maximum
        run = build(:pacbio_run, system_name: 'Sequel IIe', plates: [build(:pacbio_plate, well_count: 100)])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:wells]).to include("plate #{run.plates.first.plate_number} must have at most 96 wells")
      end
    end
  end

  describe 'when the instrument type is Revio' do
    before do
      create(:pacbio_smrt_link_version, name: 'v12_revio', default: true)
    end

    context 'plates' do
      it 'required attributes' do
        instrument_types['sequel_iie']['plates']['required_attributes'].each do |attribute|
          plate = build(:pacbio_plate)
          run = build(:pacbio_run, system_name: 'Sequel IIe', plates: [plate])
          plate.send("#{attribute}=", nil)
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[:plates]).to include("plate #{plate.plate_number} #{attribute} can't be blank")
        end
      end
    end

    context 'wells' do
      it 'minimum or maximum number of wells' do
        wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'C', column: '1'), build(:pacbio_well, row: 'D', column: '1')]
        run = build(:pacbio_run, system_name: 'Revio', plates: build_list(:pacbio_plate, 2, wells: [wells.first]))
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates]).to be_empty

        run = build(:pacbio_run, system_name: 'Revio', plates: build_list(:pacbio_plate, 2, wells:))
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates]).to be_empty

        # Minimum
        run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, well_count: 0), build(:pacbio_plate, wells: [wells.first])])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates].length).to eq(1)
        expect(run.errors.messages[:plates]).to include("plate #{run.plates.first.plate_number} must have at least 1 well")

        # Maximum
        run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, well_count: 5), build(:pacbio_plate, wells:)])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates].length).to eq(1)
        expect(run.errors.messages[:plates]).to include("plate #{run.plates.first.plate_number} must have at most 4 wells")
      end

      it 'well positions' do
        run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'G', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates].length).to eq(1)
        expect(run.errors.messages[:plates]).to include("wells must be in positions #{instrument_types['revio']['wells']['positions']}")

        run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'C', column: '1'), build(:pacbio_well, row: 'H', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
        instrument_type_validator = described_class.new(instrument_types:)
        instrument_type_validator.validate(run)
        expect(run.errors.messages[:plates].length).to eq(1)
        expect(run.errors.messages[:plates]).to include("wells must be in positions #{instrument_types['revio']['wells']['positions']}")
      end

      context 'well combinations' do
        it 'valid well combinations' do
          instrument_types['revio']['wells']['combinations'].each do |combination|
            wells = combination.map do |position|
              row, column = position.chars
              build(:pacbio_well, row:, column:)
            end
            run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells:)])
            instrument_type_validator = described_class.new(instrument_types:)
            instrument_type_validator.validate(run)
            expect(run.errors.messages).to be_empty
          end
        end

        it 'A1, D1 filled' do
          run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'D', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[:plates].length).to eq(1)
          expect(run.errors.messages[:plates]).to include('"plate #{plates.first.plate_number} wells must be in a valid order')
        end

        it 'A1, C1 filled' do
          run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'C', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[:plates].length).to eq(1)
          expect(run.errors.messages[:plates]).to include('"plate #{plates.first.plate_number} wells must be in a valid order')
        end

        it 'B1, D1 filled' do
          run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'D', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[:plates].length).to eq(1)
          expect(run.errors.messages[:plates]).to include('"plate #{plates.first.plate_number} wells must be in a valid order')
        end

        it 'A1, C1, D1 filled' do
          run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'C', column: '1'), build(:pacbio_well, row: 'D', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[:plates].length).to eq(1)
          expect(run.errors.messages[:plates]).to include('"plate #{plates.first.plate_number} wells must be in a valid order')
        end

        it 'A1, B1, D1 filled' do
          run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'D', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[:plates].length).to eq(1)
          expect(run.errors.messages[:plates]).to include('"plate #{plates.first.plate_number} wells must be in a valid order')
        end

        it 'B1, D1 filled but in reverse order' do
          run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'D', column: '1'), build(:pacbio_well, row: 'B', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[:plates].length).to eq(1)
          expect(run.errors.messages[:plates]).to include('"plate #{plates.first.plate_number} wells must be in a valid order')
        end

        it 'wont validate wells that are marked for destruction' do
          well_for_destruction = build(:pacbio_well, row: 'B', column: '1')
          well_for_destruction.mark_for_destruction
          run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1'), well_for_destruction, build(:pacbio_well, row: 'C', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[:plates].length).to eq(1)
          expect(run.errors.messages[:plates]).to include('"plate #{plates.first.plate_number} wells must be in a valid order')
        end
      end
    end
  end
end
