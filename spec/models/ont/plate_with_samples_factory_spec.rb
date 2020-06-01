# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ont::PlateWithSamplesFactory, type: :model, ont: true do
  let(:time) { DateTime.now }
  let(:timestamp) { { created_at: time, updated_at: time } }
  let(:tags) { create_list(:tag, 3) }
  let(:serialised_request_data_1) do
    [
      {
        ont_request: { uuid: '1', name: 'request A1-1', external_id: 'ExtIdA1-1' }.merge(timestamp),
        tag_id: tags[0].id
      },
      {
        ont_request: { uuid: '2', name: 'request A1-2', external_id: 'ExtIdA1-2' }.merge(timestamp),
        tag_id: tags[1].id
      },
      {
        ont_request: { uuid: '3', name: 'request A1-3', external_id: 'ExtIdA1-3' }.merge(timestamp),
        tag_id: tags[2].id
      }
    ]
  end
  let(:serialised_request_data_2) do
    [
      {
        ont_request: { uuid: '4', name: 'request A2-1', external_id: 'ExtIdA2-1' }.merge(timestamp),
        tag_id: tags[0].id
      }
    ]
  end
  let(:serialised_request_data_3) do
    [
      {
        ont_request: { uuid: '5', name: 'request B2-1', external_id: 'ExtIdB2-1' }.merge(timestamp),
        tag_id: tags[0].id
      },
      {
        ont_request: { uuid: '6', name: 'request B2-2', external_id: 'ExtIdB2-2' }.merge(timestamp),
        tag_id: tags[1].id
      }
    ]
  end
  let(:serialised_well_data) do
    [
      { well: { position: 'A1' }.merge(timestamp), request_data: serialised_request_data_1 },
      { well: { position: 'A2' }.merge(timestamp), request_data: serialised_request_data_2 },
      { well: { position: 'B2' }.merge(timestamp), request_data: serialised_request_data_3 }
    ]
  end
  let(:serialised_plate_data) do
    {
      plate: { barcode: 'abc123' }.merge(timestamp),
      well_data: serialised_well_data
    }
  end

  def mock_valid_plate_factory
    allow_any_instance_of(Ont::PlateFactory).to receive(:valid?).and_return(true)
    allow_any_instance_of(Ont::PlateFactory).to receive(:bulk_insert_serialise)
      .and_return(serialised_plate_data)
  end

  def mock_invalid_plate_factory
    errors = ActiveModel::Errors.new(Ont::PlateFactory.new)
    errors.add('plate factory', message: 'This is a test error')

    allow_any_instance_of(Ont::PlateFactory).to receive(:valid?).and_return(false)
    allow_any_instance_of(Ont::PlateFactory).to receive(:errors).and_return(errors)
  end

  context 'serialisation' do
    let(:factory) { Ont::PlateWithSamplesFactory.new }
    let(:time) { DateTime.now }

    before do
      allow(DateTime).to receive(:now).and_return(time)
    end

    context 'ont_request_data' do
      let(:request) { create(:ont_request) }
      let(:uuid) { 'test uuid' }
      let(:tag_id) { 'test tag id' }

      before do
        allow(SecureRandom).to receive(:uuid).and_return(uuid)
      end

      it 'returns expected serialisation' do
        ont_request_data = factory.ont_request_data(request, tag_id)
        expect(ont_request_data).to eq(
          {
            ont_request: {
              uuid: uuid,
              external_id: request.external_id,
              name: request.name,
              created_at: time,
              updated_at: time
            },
            tag_id: tag_id
          }
        )
      end
    end

    context 'well_data' do
      let(:well) { create(:well) }
      let(:request_data) { 'test request data' }

      it 'returns expected serialisation' do
        well_data = factory.well_data(well, request_data)
        expect(well_data).to eq(
          {
            well: {
              position: well.position,
              created_at: time,
              updated_at: time
            },
            request_data: request_data
          }
        )
      end
    end

    context 'plate_data' do
      let(:plate) { create(:plate) }
      let(:well_data) { 'test well data' }

      it 'returns expected serialisation' do
        plate_data = factory.plate_data(plate, well_data)
        expect(plate_data).to eq(
          {
            plate: {
              barcode: plate.barcode,
              created_at: time,
              updated_at: time
            },
            well_data: well_data
          }
        )
      end
    end
  end

  context 'process' do
    let(:attributes) { 'some test attributes' }
    let(:factory) { Ont::PlateWithSamplesFactory.new(attributes) }

    it 'initialises a new plate factory' do
      expect(Ont::PlateFactory).to receive(:new).with(attributes)
      factory.process
    end
  end

  context 'valid' do
    let(:attributes) { { barcode: 'test barcode' } }
    let(:factory) { Ont::PlateWithSamplesFactory.new(attributes) }

    it 'is false if plate factory is not valid' do
      mock_invalid_plate_factory
      factory.process
      expect(factory.valid?).to be_falsey
      expect(factory.errors.full_messages.length).to eq(1)
      expect(factory.errors.full_messages)
        .to contain_exactly('Plate factory {:message=>"This is a test error"}')
    end

    it 'is true if plate factory is valid' do
      mock_valid_plate_factory
      factory.process
      expect(factory.valid?).to be_truthy
    end
  end

  context 'save' do
    context 'valid build' do
      context 'successful transaction' do
        let(:all_serialised_requests) do
          serialised_request_data_1 + serialised_request_data_2 + serialised_request_data_3
        end
        factory = nil
        save = false

        before do
          mock_valid_plate_factory
          factory = Ont::PlateWithSamplesFactory.new
          factory.process
          save = factory.save
        end

        it 'returns created plate with no errors' do
          expect(save).to eq(Plate.first)
          expect(factory.errors).to be_empty
        end

        it 'inserts a single plate' do
          expect(Plate.count).to eq(1)
          expect(Plate.first.barcode).to eq(serialised_plate_data[:plate][:barcode])
        end

        it 'inserts expected wells' do
          expect(Well.count).to eq(serialised_well_data.count)
          serialised_well_data.each do |well_data|
            wells = Well.where(position: well_data[:well][:position])
            expect(wells.count).to eq(1)
            expect(wells.first.plate).to eq(Plate.first)
          end
        end

        it 'inserts expected requests' do
          expect(Ont::Request.count).to eq(all_serialised_requests.count)
          all_serialised_requests.each do |request_data|
            requests = Ont::Request.where(uuid: request_data[:ont_request][:uuid])
            expect(requests.count).to eq(1)
            expect(requests.first.name).to eq(request_data[:ont_request][:name])
            expect(requests.first.external_id).to eq(request_data[:ont_request][:external_id])
          end
        end

        it 'inserts expected container_materials' do
          expect(ContainerMaterial.count).to eq(all_serialised_requests.count)
          serialised_well_data.each do |well_data|
            well = Well.find_by(position: well_data[:well][:position])
            well_data[:request_data].each do |request_data|
              request = Ont::Request.find_by(uuid: request_data[:ont_request][:uuid])
              expect(ContainerMaterial.where(container: well, material: request).count).to eq(1)
            end
          end
        end

        it 'inserts expected tag_taggables' do
          expect(TagTaggable.count).to eq(all_serialised_requests.count)
          serialised_well_data.each do |well_data|
            well_data[:request_data].each do |request_data|
              request = Ont::Request.find_by(uuid: request_data[:ont_request][:uuid])
              tag = Tag.find(request_data[:tag_id])
              expect(TagTaggable.where(tag: tag, taggable: request).count).to eq(1)
            end
          end
        end
      end

      context 'fails' do
        before do
          mock_valid_plate_factory
        end

        it 'with failed plate insert' do
          message = 'this is a plate error'
          allow(Plate).to receive(:insert_all!).and_raise(message)
          factory = Ont::PlateWithSamplesFactory.new
          factory.process
          expect(factory.save).to be_falsey
          expect(factory.errors.full_messages.count).to eq(1)
          expect(factory.errors.full_messages)
            .to contain_exactly("Import was not successful: #{message}")
        end

        it 'with failed well insert' do
          message = 'this is a well error'
          allow(Well).to receive(:insert_all!).and_raise(message)
          factory = Ont::PlateWithSamplesFactory.new
          factory.process
          expect(factory.save).to be_falsey
          expect(factory.errors.full_messages.count).to eq(1)
          expect(factory.errors.full_messages)
            .to contain_exactly("Import was not successful: #{message}")
        end

        it 'with failed request insert' do
          message = 'this is a request error'
          allow(Ont::Request).to receive(:insert_all!).and_raise(message)
          factory = Ont::PlateWithSamplesFactory.new
          factory.process
          expect(factory.save).to be_falsey
          expect(factory.errors.full_messages.count).to eq(1)
          expect(factory.errors.full_messages)
            .to contain_exactly("Import was not successful: #{message}")
        end

        it 'with failed container_material insert' do
          message = 'this is a container_material error'
          allow(ContainerMaterial).to receive(:insert_all!).and_raise(message)
          factory = Ont::PlateWithSamplesFactory.new
          factory.process
          expect(factory.save).to be_falsey
          expect(factory.errors.full_messages.count).to eq(1)
          expect(factory.errors.full_messages)
            .to contain_exactly("Import was not successful: #{message}")
        end

        it 'with failed tag_taggable insert' do
          message = 'this is a tag_taggable error'
          allow(TagTaggable).to receive(:insert_all!).and_raise(message)
          factory = Ont::PlateWithSamplesFactory.new
          factory.process
          expect(factory.save).to be_falsey
          expect(factory.errors.full_messages.count).to eq(1)
          expect(factory.errors.full_messages)
            .to contain_exactly("Import was not successful: #{message}")
        end
      end

      context 'failed transaction' do
        def create_failing_mock(failing_insert_type)
          mock_valid_plate_factory
          allow(failing_insert_type).to receive(:insert_all!).and_raise('this is an error')
          factory = Ont::PlateWithSamplesFactory.new
          factory.process
          factory.save
        end

        context 'failing Plate insert' do
          it 'does not insert any objects' do
            create_failing_mock(Plate)
            expect(Plate.all.count).to eq(0)
            expect(Well.all.count).to eq(0)
            expect(ContainerMaterial.all.count).to eq(0)
            expect(Ont::Request.all.count).to eq(0)
            expect(TagTaggable.all.count).to eq(0)
          end
        end

        context 'failing Well insert' do
          it 'does not insert any objects' do
            create_failing_mock(Well)
            expect(Plate.all.count).to eq(0)
            expect(Well.all.count).to eq(0)
            expect(ContainerMaterial.all.count).to eq(0)
            expect(Ont::Request.all.count).to eq(0)
            expect(TagTaggable.all.count).to eq(0)
          end
        end

        context 'failing ContainerMaterial insert' do
          it 'does not insert any objects' do
            create_failing_mock(ContainerMaterial)
            expect(Plate.all.count).to eq(0)
            expect(Well.all.count).to eq(0)
            expect(ContainerMaterial.all.count).to eq(0)
            expect(Ont::Request.all.count).to eq(0)
            expect(TagTaggable.all.count).to eq(0)
          end
        end

        context 'failing Ont::Request insert' do
          it 'does not insert any objects' do
            create_failing_mock(Ont::Request)
            expect(Plate.all.count).to eq(0)
            expect(Well.all.count).to eq(0)
            expect(ContainerMaterial.all.count).to eq(0)
            expect(Ont::Request.all.count).to eq(0)
            expect(TagTaggable.all.count).to eq(0)
          end
        end

        context 'failing TagTaggable insert' do
          it 'does not insert any objects' do
            create_failing_mock(TagTaggable)
            expect(Plate.all.count).to eq(0)
            expect(Well.all.count).to eq(0)
            expect(ContainerMaterial.all.count).to eq(0)
            expect(Ont::Request.all.count).to eq(0)
            expect(TagTaggable.all.count).to eq(0)
          end
        end
      end
    end

    context 'invalid build' do
      factory = nil
      save = true

      before do
        mock_invalid_plate_factory
        factory = Ont::PlateWithSamplesFactory.new
        factory.process
        save = factory.save
      end

      it 'returns false with errors' do
        expect(save).to be_falsey
        expect(factory.errors.full_messages.count).to eq(1)
        expect(factory.errors.full_messages)
          .to contain_exactly('Plate factory {:message=>"This is a test error"}')
      end

      it 'does not insert any plates' do
        expect(Plate.all.count).to eq(0)
      end

      it 'does not insert any wells' do
        expect(Well.all.count).to eq(0)
      end

      it 'does not insert any container_materials' do
        expect(ContainerMaterial.all.count).to eq(0)
      end

      it 'does not insert any ont_requests' do
        expect(Ont::Request.all.count).to eq(0)
      end

      it 'does not insert any tag_taggables' do
        expect(TagTaggable.all.count).to eq(0)
      end
    end
  end
end
