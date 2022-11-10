# frozen_string_literal: true

FactoryBot.define do
  factory :tube do
    trait :with_barcode do
      barcode
    end

    transient do
      requests { [] }
      libraries { [] }
      materials { requests + libraries }
    end

    after :create do |tube, evaluator|
      next if evaluator.materials.empty? # Avoids us flagging the relationship as loaded

      tube.container_materials = evaluator.materials.map do |material|
        create(:container_material, container: tube, material:)
      end
    end

    factory :tube_with_saphyr_request do
      transient do
        requests { create_list(:saphyr_request, 1) }
      end
    end

    factory :tube_with_saphyr_library do
      transient do
        libraries { create_list(:saphyr_library, 1) }
      end
    end

    factory :tube_with_pacbio_library do
      transient do
        libraries { create_list(:pacbio_library, 1) }
      end
    end

    factory :tube_with_pacbio_request do
      transient do
        requests { create_list(:pacbio_request, 1) }
      end
    end

    factory :tube_with_ont_request do
      transient do
        requests { create_list(:ont_request, 1) }
      end
    end
  end
end
