# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcReception do
  describe '#create' do
    before do
      create(:qc_assay_type, key: 'sheared_femto_fragment_size', label: 'Sheared Femto Fragment Size (bp)', used_by: 1, units: 'bp')
    end

    let(:qc_reception) { build(:qc_reception) }
    let(:config) { YAML.load_file(Rails.root.join('config/locales/en.yml'), aliases: true) }
    let(:error_config) { config['en']['activerecord']['errors']['models']['qc_reception'] }

    it 'is possible to create a new record' do
      expect do
        described_class.create!(
          source: qc_reception.source,
          qc_results_list: qc_reception.qc_results_list
        )
      end.to change(described_class, :count).by(1)
    end

    describe '#validates_nested' do
      it 'errors if missing required source field' do
        error_message = error_config['attributes']['source']['blank']
        expect do
          described_class.create!(qc_results_list: qc_reception.qc_results_list)
        end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Source #{error_message}")
      end

      it 'errors if missing required qc_results_list' do
        error_message = error_config['attributes']['qc_results_list']['blank']
        expect do
          described_class.create!(source: qc_reception.source)
        end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Qc results list #{error_message}")
      end
    end

    context 'when the qc_results_list is an empty object' do
      let(:qc_reception) { build(:qc_reception, qc_results_list: [{}]) }

      it 'raises validation error' do
        error_message = error_config['attributes']['qc_results_list']['empty']
        expect do
          described_class.create!(
            source: qc_reception.source,
            qc_results_list: qc_reception.qc_results_list
          )
        end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Qc results list #{error_message}")
      end
    end
  end

  describe '#destroy' do
    it 'cannot be destroyed if there are associated records in qc_results' do
      qc_assay_type = create(:qc_assay_type,
                             key: 'sheared_femto_fragment_size',
                             label: 'Sheared Femto Fragment Size (bp)',
                             used_by: 1,
                             units: 'bp')
      qc_reception = create(:qc_reception)
      create(:qc_result, qc_assay_type:, qc_reception:)
      expect do
        qc_reception.destroy!
      end.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
  end

  describe '#association' do
    it 'has the correct association with qc_results' do
      qc_assay_type = create(:qc_assay_type,
                             key: 'sheared_femto_fragment_size',
                             label: 'Sheared Femto Fragment Size (bp)',
                             used_by: 1,
                             units: 'bp')
      qc_reception = create(:qc_reception, qc_results_list: [{
                              'sheared_femto_fragment_size' => '5',
                              'labware_barcode' => 'FD20706500',
                              'sample_external_id' => 'supplier_sample_name_DDD'
                            }])
      qc_result = create(:qc_result,
                         labware_barcode: 'FD20706500',
                         sample_external_id: 'supplier_sample_name_DDD',
                         value: '5',
                         qc_assay_type:,
                         qc_reception:)
      expect(qc_reception.qc_results).to eq [qc_result]
    end
  end
end
