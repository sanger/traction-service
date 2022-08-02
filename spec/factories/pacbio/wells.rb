# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_well, class: 'Pacbio::Well' do
    movie_time { 10 }
    sequence(:on_plate_loading_concentration) { |n| "10.#{n}" }
    row { 'A' }
    sequence(:column) { |n| "0#{n}" }
    plate { create(:pacbio_plate) }
    sequence(:comment) { |n| "comment#{n}" }
    generate_hifi { 'In SMRT Link' }
    ccs_analysis_output { '' }
    sequence(:binding_kit_box_barcode) { |n| "DM111710086220011171#{n}" }

    ccs_analysis_output_include_low_quality_reads { true }
    fivemc_calls_in_cpg_motifs { true }

    transient do
      pool_count { 5 }
    end

    factory :pacbio_well_with_pools do
      after(:create) do |well, evaluator|
        well.pools = create_list(:pacbio_pool, evaluator.pool_count)
      end
    end
  end
end
