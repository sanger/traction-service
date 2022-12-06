# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::PlateCreator, pacbio: true do
  let(:external_plates) { build_list(:external_plate, 5) }
  let(:external_plate) { external_plates.first }

  describe '#initialize' do
    let(:plate_creator) { described_class.new({ plates: [external_plate] }) }

    context 'plate wrapper' do
      let(:plate_wrapper) { plate_creator.plate_wrappers.first }

      it 'will have a barcode' do
        expect(plate_wrapper.barcode).to eq(external_plate[:barcode])
      end

      it 'will have some wells' do
        expect(plate_wrapper.well_wrappers.length).to eq(external_plate[:wells].length)
      end

      context 'well wrapper' do
        let(:well_wrapper) { plate_wrapper.well_wrappers.first }

        it 'will have a position' do
          expect(well_wrapper.position).to eq(external_plate[:wells].first[:position])
        end

        it 'will have a reference to the plate' do
          expect(well_wrapper.plate).to eq(plate_wrapper.plate)
        end

        context 'sample wrapper' do
          let(:sample_wrapper) { well_wrapper.sample_wrappers.first }
          let(:original_sample) { external_plate[:wells].first[:samples].first }

          it 'will have all of the sample attributes' do
            Pacbio::PlateCreator::SampleWrapper::SAMPLE_ATTRIBUTES.each do |attr|
              expect(sample_wrapper.send(attr)).to eq(original_sample[attr])
            end
          end

          it 'will have a reference to the well' do
            expect(sample_wrapper.well).to eq(well_wrapper.well)
          end

          it 'will have all of the request attributes' do
            Pacbio::PlateCreator::SampleWrapper::REQUEST_ATTRIBUTES.each do |attr|
              expect(sample_wrapper.send(attr)).to eq(original_sample[attr])
            end
          end

          it 'will build a request' do
            expect(sample_wrapper.request).to be_present
            expect(sample_wrapper.request.requestable).to eq(sample_wrapper.pacbio_request)
            expect(sample_wrapper.request.sample).to eq(sample_wrapper.sample)
          end

          it 'will build a container material' do
            expect(sample_wrapper.container_material).to be_present
            expect(sample_wrapper.container_material.material).to eq(sample_wrapper.pacbio_request)
            expect(sample_wrapper.container_material.container).to eq(sample_wrapper.well)
          end
        end
      end
    end
  end

  describe '#valid' do
    context 'sample wrapper' do
      it 'will not be valid without a valid sample' do
        attributes = attributes_for(:external_sample).except(:name).merge(well: build(:well))
        sample_wrapper = Pacbio::PlateCreator::SampleWrapper.new(attributes)
        expect(sample_wrapper).not_to be_valid
        expect(sample_wrapper.errors.full_messages).to include("Sample name can't be blank")
      end

      it 'will not be valid without a valid request' do
        attributes = attributes_for(:external_sample).except(:external_study_id).merge(well: build(:well))
        sample_wrapper = Pacbio::PlateCreator::SampleWrapper.new(attributes)
        expect(sample_wrapper).not_to be_valid
        expect(sample_wrapper.errors.full_messages).to include("Sample external study can't be blank")
      end
    end

    context 'well wrapper' do
      it 'will not be valid if the well is not valid' do
        attributes = attributes_for(:well).except(:position).merge(plate: build(:plate))
        well_wrapper = Pacbio::PlateCreator::WellWrapper.new(attributes)
        expect(well_wrapper).not_to be_valid
        expect(well_wrapper.errors.full_messages).to include("Well position can't be blank")
      end

      it 'will not be valid if the sample or request is not valid' do
        attributes = attributes_for(:well).merge(plate: build(:plate),
                                                 samples: [attributes_for(:external_sample).except(:name)])
        well_wrapper = Pacbio::PlateCreator::WellWrapper.new(attributes)
        expect(well_wrapper).not_to be_valid
      end
    end

    context 'plate wrapper' do
      it 'will not be valid if there are no wells' do
        attributes = attributes_for(:plate)
        plate_wrapper = Pacbio::PlateCreator::PlateWrapper.new(attributes)
        expect(plate_wrapper).not_to be_valid
        expect(plate_wrapper.errors.full_messages).to include('Wells should be present')
      end

      it 'will not be valid if the wells are not valid' do
        attributes = attributes_for(:plate).merge(wells: [attributes_for(:well).except(:position)])
        plate_wrapper = Pacbio::PlateCreator::PlateWrapper.new(attributes)
        expect(plate_wrapper).not_to be_valid
      end
    end

    context 'plate creator' do
      it 'will not be valid if there are no plates' do
        plate_creator = described_class.new(plates: [])
        expect(plate_creator).not_to be_valid
        expect(plate_creator.errors.full_messages).to include('Plates should be present and an array')
      end

      it 'will not be valid if there are no wells' do
        attributes = attributes_for(:plate).merge(wells: [attributes_for(:well).except(:position)])
        plate_creator = described_class.new(plates: [attributes])
        expect(plate_creator).not_to be_valid
      end
    end
  end

  describe '#save' do
    describe 'when valid' do
      let(:plate_creator) { described_class.new({ plates: [external_plate] }) }

      before do
        plate_creator.save!
      end

      it 'will create a plate' do
        plate_creator.plate_wrappers.each do |plate_wrapper|
          expect(plate_wrapper.plate).to be_persisted
        end
      end

      it 'will create some wells' do
        plate_wrapper = plate_creator.plate_wrappers.first
        plate_wrapper.well_wrappers.each do |well_wrapper|
          expect(well_wrapper.well).to be_persisted
        end
      end

      it 'will create some samples, requests and and container_materials' do
        well_wrapper = plate_creator.plate_wrappers.first.well_wrappers.first
        well_wrapper.sample_wrappers.each do |sample_wrapper|
          expect(sample_wrapper.sample).to be_persisted
          expect(sample_wrapper.pacbio_request).to be_persisted
          expect(sample_wrapper.request).to be_persisted
          expect(sample_wrapper.container_material).to be_persisted
        end
      end

      it 'the requests will be linked to the samples and containers (sanity check)' do
        sample_wrapper = plate_creator.plate_wrappers.first.well_wrappers.first.sample_wrappers.first
        expect(sample_wrapper.well.materials.first).to eq(sample_wrapper.pacbio_request)
        expect(sample_wrapper.pacbio_request.container).to eq(sample_wrapper.well)
      end
    end

    describe 'when not valid' do
      it 'no plates' do
        plate_creator = described_class.new({ plates: [] })
        expect(plate_creator.save!).to be_falsy
      end

      it 'no wells' do
        plate_creator = described_class.new({ plates: [external_plate.except(:wells)] })
        expect(plate_creator.save!).to be_falsy
      end

      context 'dodgy well' do
        let(:invalid_plate) do
          external_plate[:wells] << attributes_for(:well).except(:position)
          external_plate
        end

        let(:plate_creator) { described_class.new({ plates: [invalid_plate] }) }

        it 'is not valid' do
          expect(plate_creator).not_to be_valid
        end

        it 'does not save anything' do
          plate_creator.save!

          plate_creator.plate_wrappers.each do |plate_wrapper|
            expect(plate_wrapper.plate).not_to be_persisted

            plate_wrapper.well_wrappers.each do |well_wrapper|
              expect(well_wrapper.plate).not_to be_persisted
              next if well_wrapper.sample_wrappers.nil?

              well_wrapper.sample_wrappers.each do |sample_wrapper|
                expect(sample_wrapper.sample).not_to be_persisted
                expect(sample_wrapper.pacbio_request).not_to be_persisted
                expect(sample_wrapper.request).not_to be_persisted
                expect(sample_wrapper.container_material).not_to be_persisted
              end
            end
          end
        end
      end
    end
  end
end
