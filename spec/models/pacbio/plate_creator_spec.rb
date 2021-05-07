# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::PlateCreator, type: :model, pacbio: true do

  # create a plate
  # a plate will have 96 wells
  # each well can have one or more samples
  # each sample will have some attributes

  let(:external_plates) { build_list(:external_plate, 5)}
  let(:external_plate) { external_plates.first }

  context '#initialize' do

    let(:plate_creator) { Pacbio::PlateCreator.new({ plates: [external_plate]})}

    context 'plate wrapper' do
      
      let(:plate_wrapper) { plate_creator.plates.first}

      it 'will have a barcode' do
        expect(plate_wrapper.barcode).to eq(external_plate[:barcode])
      end

      it 'will have some wells' do
        expect(plate_wrapper.wells.length).to eq(external_plate[:wells].length)
      end

      context 'well wrapper' do
        
        let(:well_wrapper) { plate_wrapper.wells.first}

        it 'will have a position' do
          expect(well_wrapper.position).to eq(external_plate[:wells].first[:position])
        end

        it 'will have a reference to the plate' do
          expect(well_wrapper.plate).to eq(plate_wrapper.plate)
        end

        context 'sample wrapper' do
        
          let(:sample_wrapper) { well_wrapper.samples.first }
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

  context '#valid' do
    
    context 'sample wrapper' do

      it 'will not be valid without a valid sample' do
        attributes = attributes_for(:external_sample).except(:name).merge(well: build(:well))
        sample_wrapper = Pacbio::PlateCreator::SampleWrapper.new(attributes)
        expect(sample_wrapper).to_not be_valid
      end

      it 'will not be valid without a valid request' do
        attributes = attributes_for(:external_sample).except(:external_study_id).merge(well: build(:well))
        sample_wrapper = Pacbio::PlateCreator::SampleWrapper.new(attributes)
        expect(sample_wrapper).to_not be_valid
      end
      
    end

    context 'well wrapper' do
      
      it 'will not be valid if the well is not valid' do
        attributes = attributes_for(:well).except(:position).merge(plate: build(:plate))
        well_wrapper = Pacbio::PlateCreator::WellWrapper.new(attributes)
        expect(well_wrapper).to_not be_valid
      end

      it 'will not be valid if the sample or request is not valid' do
        attributes = attributes_for(:well).merge(plate: build(:plate), samples: [attributes_for(:external_sample).except(:name)])
        well_wrapper = Pacbio::PlateCreator::WellWrapper.new(attributes)
        expect(well_wrapper).to_not be_valid
      end
    end

    context 'plate wrapper' do

      it 'will not be valid if there are no wells' do
        attributes = attributes_for(:plate)
        plate_wrapper = Pacbio::PlateCreator::PlateWrapper.new(attributes)
        expect(plate_wrapper).to_not be_valid
      end
     
      it 'will not be valid if the wells are not valid' do
        attributes = attributes_for(:plate).merge(wells: [attributes_for(:well).except(:position)])
        plate_wrapper = Pacbio::PlateCreator::PlateWrapper.new(attributes)
        expect(plate_wrapper).to_not be_valid
      end

    end

    context 'plate creator' do
      it 'will not be valid if there are no plates' do
        plate_wrapper = Pacbio::PlateCreator.new(plates: [])
        expect(plate_wrapper).to_not be_valid
      end
     
      it 'will not be valid if the wells are not valid' do
        attributes = attributes_for(:plate).merge(wells: [attributes_for(:well).except(:position)])
        plate_wrapper = Pacbio::PlateCreator.new(plates: [attributes])
        expect(plate_wrapper).to_not be_valid
      end
    end
  end

  context '#save' do

    describe 'when valid' do

      let(:plate_creator) { Pacbio::PlateCreator.new({ plates: [external_plate]})}

      before(:each) do
        plate_creator.save
      end
      
      it 'will create a plate' do
        plate_creator.plates.each do |plate_wrapper|
          expect(plate_wrapper.plate).to be_persisted
        end
      end
  
      it 'will create some wells' do
        plate_wrapper = plate_creator.plates.first
        plate_wrapper.wells.each do |well_wrapper|
          expect(well_wrapper.well).to be_persisted
        end

      end
  
      it 'will create some samples, requests and and container_materials' do
        well_wrapper = plate_creator.plates.first.wells.first
        well_wrapper.samples.each do |sample_wrapper|
          expect(sample_wrapper.sample).to be_persisted
          expect(sample_wrapper.pacbio_request).to be_persisted
          expect(sample_wrapper.request).to be_persisted
          expect(sample_wrapper.container_material).to be_persisted
        end
        
      end
  
      it 'the requests will be linked to the samples and containers (sanity check)' do
        sample_wrapper = plate_creator.plates.first.wells.first.samples.first
        expect(sample_wrapper.well.materials.first).to eq(sample_wrapper.pacbio_request)
        expect(sample_wrapper.pacbio_request.container).to eq(sample_wrapper.well)
      end

    end

    it 'should only validate once' do
      plate_creator = Pacbio::PlateCreator.new({ plates: [external_plate]})

      well = plate_creator.plates.first.wells.first.well
      sample_wrapper = plate_creator.plates.first.wells.first.samples.first
    
      allow(well).to receive(:valid?).and_return(true)
      allow(sample_wrapper.sample).to receive(:valid?).and_return(true)
      allow(sample_wrapper.pacbio_request).to receive(:valid?).and_return(true)
      allow(sample_wrapper.container_material).to receive(:valid?).and_return(true)

      plate_creator.save

      expect(well).to have_received(:valid?).once

      # TODO: they should only be validated once but because of the request they are validated twice
      expect(sample_wrapper.pacbio_request).to have_received(:valid?).twice
      expect(sample_wrapper.sample).to have_received(:valid?).twice
    end

    describe 'when not valid' do
      

    end
  
  end

end
