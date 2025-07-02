# frozen_string_literal: true

FactoryBot.define do
  factory :tube do
    trait :with_barcode do
      sequence(:barcode) { |n| "TRAC-#{n}" }
    end

    ont_requests { [] }
    ont_pools { [] }
    pacbio_requests { [] }
    pacbio_pools { [] }
    pacbio_library { nil }

    transient do
      materials { pacbio_requests + ont_requests }
    end

    after :create do |tube, evaluator|
      next if evaluator.materials.empty? # Avoids us flagging the relationship as loaded

      tube.container_materials = evaluator.materials.map do |material|
        create(:container_material, container: tube, material:)
      end
    end

    factory :tube_with_pacbio_library do
      pacbio_library { association(:pacbio_library) }
    end

    factory :tube_with_pacbio_pool do
      pacbio_pools { create_list(:pacbio_pool, 1, tube: instance) }
    end

    factory :tube_with_pacbio_request do
      pacbio_requests { create_list(:pacbio_request, 1) }
    end

    factory :tube_with_ont_request do
      ont_requests { create_list(:ont_request, 1) }
    end

    factory :tube_with_ont_pool do
      ont_pools { create_list(:ont_pool, 1, tube: instance) }
    end
  end
end
