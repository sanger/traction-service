# frozen_string_literal: true

FactoryBot.define do
  factory :reception do
    source { 'traction-ui.sequencescape' }
  end

  factory :reception_resource_factory_v1, class: 'Reception::ResourceFactoryV1' do
    reception
    request_attributes do
      [
        {
          request: { library_type: create(:library_type, :ont).name, data_type: create(:data_type, :ont).name, cost_code: generate(:cost_code), external_study_id: generate(:external_study_id) },
          sample: { name: generate(:sample_name), species: 'Human', external_id: generate(:uuid) },
          container: { type: 'tubes', barcode: generate(:barcode) }
        }
      ]
    end
  end

  factory :reception_resource_factory_v2, class: 'Reception::ResourceFactoryV2' do
    transient do
      # We need this to ensure the library and data types are created upfront
      # To enable the resource_factory caching to work properly
      library_type { association :library_type, strategy: :create }
      data_type { association :data_type, strategy: :create }
    end

    reception
    plates_attributes do
      [
        {
          type: 'plates',
          barcode: generate(:barcode),
          wells_attributes: [
            {
              position: 'A1',
              request: { library_type: library_type.name, data_type: data_type.name, cost_code: generate(:cost_code), external_study_id: generate(:external_study_id) },
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
          request: { library_type: library_type.name, data_type: data_type.name, cost_code: generate(:cost_code), external_study_id: generate(:external_study_id) },
          sample: { name: generate(:sample_name), species: 'Human', external_id: generate(:uuid) }
        }
      ]
    end
  end
end
