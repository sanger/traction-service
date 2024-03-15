# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_well, class: 'Pacbio::Well' do
    movie_time { 15 }
    sequence(:on_plate_loading_concentration) { |n| "10.#{n}".to_f }
    row { 'A' }
    sequence(:column) { |n| "0#{n}" }

    # you can't use attributes_for unless you remove the need for instance
    plate { instance.present? ? build(:pacbio_plate, wells: [instance]) : build(:pacbio_plate) }

    sequence(:comment) { |n| "comment#{n}" }
    sequence(:binding_kit_box_barcode) { |n| "DM111710086220011171#{n}" }

    transient do
      pool_count { 5 }
      pool_factory { :pacbio_pool }
      pool_max { 2 }
      library_count { 0 }
      library_factory { :pacbio_library }
      library_max { 2 }
    end

    pools do
      build_list(pool_factory, pool_count)
    end

    libraries do
      build_list(library_factory, library_count)
    end

    after(:build) do |well|
      well.libraries.each do |lib|
        well.used_aliquots << build(:aliquot, source: lib, aliquot_type: :derived, used_by: well)
      end
      well.pools.each do |pool|
        well.used_aliquots << build(:aliquot, source: pool, aliquot_type: :derived, used_by: well)
      end
    end

    # v10
    generate_hifi { 'In SMRT Link' }
    ccs_analysis_output { 'Yes' }

    # v11
    ccs_analysis_output_include_low_quality_reads { 'Yes' }
    ccs_analysis_output_include_kinetics_information { 'Yes' }
    include_fivemc_calls_in_cpg_motifs { 'Yes' }
    demultiplex_barcodes { 'In SMRT Link' }
    loading_target_p1_plus_p2 { 0.85 }

    # v12_revio
    movie_acquisition_time { 15 }
    include_base_kinetics { 'True' }
    sequence(:library_concentration) { |n| "10.#{n}".to_f }
    sequence(:polymerase_kit) { |n| "DM111710086220011171#{n}" }

    factory :pacbio_well_with_pools do
      before(:create) do |well, evaluator|
        well.pools = create_list(:pacbio_pool, evaluator.pool_count)
      end
    end
  end
end
