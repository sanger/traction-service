# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'QcResult Message', type: :model do
  let(:config)              { Pipelines.configure(Pipelines.load_yaml) }
  let(:qc_result_config)    { config.qc_result }
  let(:qc_result)           { create(:qc_result) }
  let(:qc_decision)         { create(:qc_decision) }
  let(:qc_result_message)   { QcResultsUploadFactory::QcResultMessage.new(qc_result:, decision_made_by: qc_decision.decision_made_by) }
  let(:message)             { Messages::Message.new(object: qc_result_message, configuration: qc_result_config.message) }

  before do
    create(:qc_decision_result, qc_result:, qc_decision:)
  end

  it 'has a lims' do
    expect(message.content[:lims]).to eq(qc_result_config.lims)
  end

  it 'has a key' do
    expect(message.content[qc_result_config.key]).not_to be_empty
  end

  describe 'key' do
    let(:key) { message.content[qc_result_config.key] }

    let(:timestamp) { Time.zone.parse('Mon, 08 Apr 2019 09:15:11 UTC +00:00') }

    before do
      allow(Time).to receive(:current).and_return timestamp
    end

    it 'must have a labware_barcode' do
      expect(key[:labware_barcode]).to eq(qc_result_message.labware_barcode)
    end

    it 'must have a sample_id' do
      expect(key[:sample_id]).to eq(qc_result_message.sample_external_id)
    end

    it 'must have a assay_type' do
      expect(key[:assay_type]).to eq(qc_result_message.qc_assay_type.label)
    end

    it 'must have a assay_type_key' do
      expect(key[:assay_type_key]).to eq(qc_result_message.qc_assay_type.key)
    end

    it 'must have a units' do
      expect(key[:units]).to eq(qc_result_message.qc_assay_type.units)
    end

    it 'must have a value' do
      expect(key[:value]).to eq(qc_result_message.value)
    end

    it 'must have an id_long_read_qc_result_lims' do
      expect(key[:id_long_read_qc_result_lims]).to eq(qc_result_message.id)
    end

    it 'must have a created' do
      expect(key[:created]).to eq(qc_result_message.created_at)
    end

    it 'must have a last_updated' do
      expect(key[:last_updated]).to eq(timestamp)
    end

    it 'must have a qc_status' do
      expect(key[:qc_status]).to eq(qc_result_message.qc_decision.status)
    end

    it 'must have a qc_status_decision_by' do
      expect(key[:qc_status_decision_by]).to eq(qc_result_message.qc_decision.decision_made_by)
    end
  end
end
