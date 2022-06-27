# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_plate, class: 'Pacbio::Plate' do
    run { create(:pacbio_run) }

    factory :pacbio_plate_with_wells do
      transient do
        well_count { 1 }
        well_factory { :pacbio_well }
      end

      wells { create_list(well_factory, well_count) }
    end

    trait :pooled do
      transient do
        pool_count { 1 }
        # TODO: This needs sorting as we should be able to select the number of pools
        well_factory { :pacbio_well_with_pools }
      end
    end
  end
end
