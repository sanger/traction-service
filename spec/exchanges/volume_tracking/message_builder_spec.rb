# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VolumeTracking::MessageBuilder, type: :model do
  describe '#content' do
    let(:configuration) { Pipelines.pacbio.volume_tracking.avro_schema_version_1 }
    let(:pacbio_library) { create(:pacbio_library) }
    let(:pacbio_pool) { create(:pacbio_pool) }
    let(:pacbio_run)  { create(:pacbio_revio_run, smrt_link_version: create(:pacbio_smrt_link_version, name: 'v12_revio')) }
    let(:pacbio_well) { build(:pacbio_well, plate: pacbio_run.plates.first) }

    context 'with a aliquot with library as source and no used_by' do
      let(:aliquot) { create(:aliquot, source: pacbio_library) }
      let(:message_builder) { described_class.new(object: aliquot, configuration:) }

      it 'produces the message in the correct format' do
        expect(message_builder.publish_data).to eq({
                                                     source_type: 'library',
                                                     source_barcode: pacbio_library.tube.barcode,
                                                     sample_name: pacbio_library.sample_name,
                                                     used_by_type: 'nil',
                                                     used_by_barcode: '',
                                                     aliquot_id: aliquot.id.to_s || ''
                                                   })
      end
    end

    context 'with a aliquot with library as source and pool as used_by' do
      let(:aliquot) { create(:aliquot, source: pacbio_library, used_by: pacbio_pool) }
      let(:message_builder) { described_class.new(object: aliquot, configuration:) }

      it 'produces the message in the correct format' do
        expect(message_builder.publish_data).to eq({
                                                     source_type: 'library',
                                                     source_barcode: pacbio_library.tube.barcode,
                                                     sample_name: pacbio_library.sample_name,
                                                     used_by_type: 'pool',
                                                     used_by_barcode: pacbio_pool.tube.barcode,
                                                     aliquot_id: aliquot.id.to_s || ''
                                                   })
      end
    end

    context 'with a aliquot with library as source and well as used_by' do
      let(:aliquot) { create(:aliquot, source: pacbio_library, used_by: pacbio_well) }
      let(:message_builder) { described_class.new(object: aliquot, configuration:) }

      it 'produces the message in the correct format' do
        expect(message_builder.publish_data).to eq({
                                                     source_type: 'library',
                                                     source_barcode: pacbio_library.tube.barcode,
                                                     sample_name: pacbio_library.sample_name,
                                                     used_by_type: 'well',
                                                     used_by_barcode: "#{pacbio_well.plate.sequencing_kit_box_barcode}:#{pacbio_well.plate.plate_number}:#{pacbio_well.position}",
                                                     aliquot_id: aliquot.id.to_s || ''
                                                   })
      end
    end
  end
end
