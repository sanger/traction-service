# frozen_string_literal: true

FactoryBot.define do
  factory :reception do
    source { 'traction-ui.sequencescape' }
    plates_attributes do
      [
        {
          type: 'plates',
          barcode: generate(:barcode),
          wells_attributes: [
            {
              position: 'A1',
              request: { library_type: create(:library_type, :ont).name, data_type: create(:data_type, :ont).name, cost_code: generate(:cost_code), external_study_id: generate(:external_study_id) },
              sample: { name: generate(:sample_name), species: 'Human', external_id: generate(:uuid) }
            }
          ]
        }
      ]
    end
    tubes_attributes do
      [
        {
          type: 'tubes',
          barcode: generate(:barcode),
          request: { library_type: create(:library_type, :ont).name, data_type: create(:data_type, :ont).name, cost_code: generate(:cost_code), external_study_id: generate(:external_study_id) },
          sample: { name: generate(:sample_name), species: 'Human', external_id: generate(:uuid) }
        }
      ]
    end
  end

  factory :reception_resource_factory, class: 'Reception::ResourceFactory' do
    reception
  end
end
