# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VolumeTracking::MessageBuilder, type: :model do
  describe '#content' do
    let(:configuration) { Pipelines.pacbio.volume_tracking.avro_schema_version_1 }
    let(:pacbio_library) { create(:pacbio_library) }
    let(:pacbio_request) { create(:pacbio_request) }
    let(:pacbio_pool) { create(:pacbio_pool) }
    let(:pacbio_run)  { create(:pacbio_revio_run, smrt_link_version: create(:pacbio_smrt_link_version, name: 'v12_revio')) }
    let(:pacbio_well) { build(:pacbio_well, plate: pacbio_run.plates.first) }

    context 'with a aliquot with library as source and no used_by' do
      let(:aliquot) { create(:aliquot, source: pacbio_library) }
      let(:message_builder) { described_class.new(object: aliquot, configuration:) }

      it 'produces the message in the correct format' do
        expect(message_builder.publish_data).to include({
                                                          source_type: 'library',
                                                          source_barcode: pacbio_library.tube.barcode,
                                                          sample_name: pacbio_library.sample_name,
                                                          used_by_type: 'none',
                                                          used_by_barcode: '',
                                                          aliquot_uuid: aliquot.uuid
                                                        })
      end
    end

    context 'with a aliquot with pool as source and no used_by' do
      let(:aliquot) { create(:aliquot, source: pacbio_pool) }
      let(:message_builder) { described_class.new(object: aliquot, configuration:) }
      let(:expected_sample_names) do
        aliquot.source.used_aliquots
               .select { |aliquot| aliquot.source.is_a?(Pacbio::Library) }
               .map(&:source)
               .map(&:sample)
               .map(&:name)
               .uniq
               .join(': ')
      end

      it 'produces the message in the correct format' do
        expect(message_builder.publish_data).to include({
                                                          source_type: 'pool',
                                                          source_barcode: pacbio_pool.tube.barcode,
                                                          sample_name: expected_sample_names,
                                                          used_by_type: 'none',
                                                          used_by_barcode: '',
                                                          aliquot_uuid: aliquot.uuid
                                                        })
      end
    end

    context 'with a aliquot with pool as source and well as used_by' do
      let(:aliquot) { create(:aliquot, source: pacbio_pool, used_by: pacbio_well) }
      let(:message_builder) { described_class.new(object: aliquot, configuration:) }
      let(:expected_sample_names) do
        aliquot.source.used_aliquots
               .select { |aliquot| aliquot.source.is_a?(Pacbio::Library) }
               .map(&:source)
               .map(&:sample)
               .map(&:name)
               .uniq
               .join(': ')
      end

      it 'produces the message in the correct format' do
        expect(message_builder.publish_data).to include({
                                                          source_type: 'pool',
                                                          source_barcode: pacbio_pool.tube.barcode,
                                                          sample_name: expected_sample_names,
                                                          used_by_type: 'run',
                                                          used_by_barcode: "#{pacbio_well.plate.sequencing_kit_box_barcode}:#{pacbio_well.plate.plate_number}:#{pacbio_well.position}",
                                                          aliquot_uuid: aliquot.uuid
                                                        })
      end
    end

    context 'with a aliquot with pool as source and different aliquot source type' do
      let(:pacbio_request) { create(:pacbio_request) }
      let(:aliquot) { create(:aliquot, source: pacbio_pool, used_by: pacbio_well) }
      let(:message_builder) { described_class.new(object: aliquot, configuration:) }

      it 'the produced message contains only samples from pacbio library' do
        pacbio_pool.used_aliquots << [create(:aliquot, source: pacbio_library), create(:aliquot, source: pacbio_library),
                                      create(:aliquot, source: pacbio_request)]

        sample_name = message_builder.publish_data[:sample_name]
        expect(sample_name).to be_a(String)
        expect(sample_name.split(':').size).to eq(2)
      end
    end

    context 'with an aliquot with request as source and library as used_by' do
      let(:configuration) { Pipelines.pacbio.volume_tracking.avro_schema_version_2 }
      let(:aliquot) { create(:aliquot, source: pacbio_request, used_by: pacbio_library) }
      let(:message_builder) { described_class.new(object: aliquot, configuration:) }

      it 'produces the message in the correct format' do
        pacbio_request.tube = create(:tube, barcode: '123456789')
        expect(message_builder.publish_data).to include({
                                                          source_type: 'request',
                                                          source_barcode: pacbio_request.tube.barcode,
                                                          sample_name: pacbio_request.sample_name,
                                                          used_by_type: 'library',
                                                          used_by_barcode: '',
                                                          aliquot_uuid: aliquot.uuid
                                                        })
      end
    end

    context 'with a aliquot with library as source and pool as used_by' do
      let(:aliquot) { create(:aliquot, source: pacbio_library, used_by: pacbio_pool) }
      let(:message_builder) { described_class.new(object: aliquot, configuration:) }

      it 'produces the message in the correct format' do
        expect(message_builder.publish_data).to include({
                                                          source_type: 'library',
                                                          source_barcode: pacbio_library.tube.barcode,
                                                          sample_name: pacbio_library.sample_name,
                                                          used_by_type: 'pool',
                                                          used_by_barcode: pacbio_pool.tube.barcode,
                                                          aliquot_uuid: aliquot.uuid
                                                        })
      end
    end

    context 'with a aliquot with library as source and well as used_by' do
      let(:aliquot) { create(:aliquot, source: pacbio_library, used_by: pacbio_well) }
      let(:message_builder) { described_class.new(object: aliquot, configuration:) }

      it 'produces the message in the correct format' do
        expect(message_builder.publish_data).to include({
                                                          source_type: 'library',
                                                          source_barcode: pacbio_library.tube.barcode,
                                                          sample_name: pacbio_library.sample_name,
                                                          used_by_type: 'run',
                                                          used_by_barcode: "#{pacbio_well.plate.sequencing_kit_box_barcode}:#{pacbio_well.plate.plate_number}:#{pacbio_well.position}",
                                                          aliquot_uuid: aliquot.uuid
                                                        })
      end
    end
  end
end
