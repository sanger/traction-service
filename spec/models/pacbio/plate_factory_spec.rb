# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::PlateFactory, type: :model, pacbio: true do

  # create a plate
  # a plate will have 96 wells
  # each well can have one or more samples
  # each sample will have some attributes

  let(:sequencescape_plates) { build_list(:sequencescape_plate, 5)}
  let(:sequencescape_plate) { sequencescape_plates.first }

  context '#initialize' do

    let(:plate_factory) { Pacbio::PlateFactory.new({ plates: [sequencescape_plate]})}

    context 'plate wrapper' do
      
      let(:plate_wrapper) { plate_factory.plates.first}

      it 'will have a barcode' do
        expect(plate_wrapper.barcode).to eq(sequencescape_plate[:barcode])
      end

      it 'will have some wells' do
        expect(plate_wrapper.wells.length).to eq(sequencescape_plate[:wells].length)
      end

      context 'well wrapper' do
        
        let(:well_wrapper) { plate_wrapper.wells.first}

        it 'will have a position' do
          expect(well_wrapper.position).to eq(sequencescape_plate[:wells].first[:position])
        end

        it 'will have a reference to the plate' do
          expect(well_wrapper.plate).to eq(plate_wrapper.plate)
        end

        context 'sample wrapper' do
        
          let(:sample_wrapper) { well_wrapper.samples.first }
          let(:original_sample) { sequencescape_plate[:wells].first[:samples].first }
  
          it 'will have an external_id' do
            expect(sample_wrapper.external_id).to eq(original_sample[:external_id])
          end
  
          it 'will have a name' do
            expect(sample_wrapper.name).to eq(original_sample[:name])
          end
  
          it 'will have a species' do
            expect(sample_wrapper.species).to eq(original_sample[:species])
          end

          it 'will have a reference to the well' do
            expect(sample_wrapper.well).to eq(well_wrapper.well)
          end

          it 'will have all of the request attributes' do
            Pacbio.request_attributes.each do |attr|
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

end
