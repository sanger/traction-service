require 'rails_helper'

RSpec.describe Pacbio::Well, type: :model, pacbio: true do
  context 'uuidable' do
    let(:uuidable_model) { :pacbio_well }
    it_behaves_like 'uuidable'
  end

  context 'row' do
    it 'must have a row' do
      expect(build(:pacbio_well, row: nil)).to_not be_valid
    end
  end

  context 'column' do
    it 'must have a column' do
      expect(build(:pacbio_well, column: nil)).to_not be_valid
    end
  end

  context 'movie time' do
    it 'must be present' do
      expect(build(:pacbio_well, movie_time: nil)).to_not be_valid
    end

    it 'can be a decimal' do
      expect(build(:pacbio_well, movie_time: 0.2).movie_time).to eq(0.2)

    end

    it 'must be within range' do
      expect(build(:pacbio_well, movie_time: 15)).to be_valid
      expect(build(:pacbio_well, movie_time: 31)).to_not be_valid
      expect(build(:pacbio_well, movie_time: 0)).to_not be_valid
    end

  end

  context 'insert size' do
    let(:pools)     { create_list(:pacbio_pool, 2) }
    let(:well)      { create(:pacbio_well, pools: pools) }

    it 'gest the fragment size of the first pool in the well' do
      expect(well.pools[0].insert_size).to eq(well.insert_size)
    end
  end

  it 'must have an on plate loading concentration' do
    expect(build(:pacbio_well, on_plate_loading_concentration: nil)).to_not be_valid
  end

  context 'position' do
    it 'can have a position' do
      expect(build(:pacbio_well, row: 'B', column: '1').position).to eq('B1')
    end
  end

  it 'must have to a plate' do
    expect(build(:pacbio_well, plate: nil)).to_not be_valid
  end

  it 'must have a binding kit box barcode' do
    expect(build(:pacbio_well, binding_kit_box_barcode: nil)).to_not be_valid
  end

  it 'can have a comment' do
    expect(build(:pacbio_well).comment).to be_present
  end

  it 'can have a summary' do
    well = create(:pacbio_well_with_pools)
    expect(well.summary).to eq("#{well.sample_names} #{well.comment}")
  end

  context '#pools?' do
    let(:pools) { create_list(:pacbio_pool, 2) }
    it 'with pools' do
      well = create(:pacbio_well, pools: pools)
      expect(well.pools?).to be_truthy
    end

    it 'no pools' do
      well = create(:pacbio_well)
      expect(well.pools?).to_not be_truthy
    end
  end

  context 'Generate HiFi' do
    it 'must have a generate_hifi' do
      expect(build(:pacbio_well, generate_hifi: nil)).to_not be_valid
    end

    it 'must include the correct options' do
      expect(Pacbio::Well.generate_hifis.keys).to eq(["In SMRT Link", "On Instrument", "Do Not Generate"])
    end

    it 'must have a Generate_hifi' do
      expect(create(:pacbio_well, generate_hifi: 0).generate_hifi).to eq "In SMRT Link"
      expect(create(:pacbio_well, generate_hifi: "In SMRT Link").generate_hifi).to eq "In SMRT Link"
      expect(create(:pacbio_well, generate_hifi: 1).generate_hifi).to eq "On Instrument"
      expect(create(:pacbio_well, generate_hifi: "On Instrument").generate_hifi).to eq "On Instrument"
      expect(create(:pacbio_well, generate_hifi: 2).generate_hifi).to eq "Do Not Generate"
      expect(create(:pacbio_well, generate_hifi: "Do Not Generate").generate_hifi).to eq "Do Not Generate"
    end
  end

  context 'ccs_analysis_output' do
    it 'may have ccs_analysis_output' do
      expect(create(:pacbio_well, ccs_analysis_output: 'Yes')).to be_valid
      expect(create(:pacbio_well, ccs_analysis_output: 'No')).to be_valid
      expect(create(:pacbio_well, ccs_analysis_output: '')).to be_valid
    end

    it 'sets ccs_analysis_output to "No" if blank' do
      well = create(:pacbio_well, ccs_analysis_output: '')
      expect(well.ccs_analysis_output).to eq("No")
    end

    it 'ccs_analysis_output stays "Yes" if set to yes' do
      well = create(:pacbio_well, ccs_analysis_output: 'Yes')
      expect(well.ccs_analysis_output).to eq("Yes")
    end
  end

  context 'pre-extension time' do
    it 'is not required' do
      expect(create(:pacbio_well, pre_extension_time: nil)).to be_valid
    end

    it 'can be set' do
      well = build(:pacbio_well, pre_extension_time: 2 )
      expect(well.pre_extension_time).to eq(2)
    end
  end

  context 'loading target p1 plus p2' do
    it 'is not required' do
      expect(build(:pacbio_well, loading_target_p1_plus_p2: nil)).to be_valid
    end

    it 'can be a decimal' do
      expect(build(:pacbio_well, loading_target_p1_plus_p2: 0.5).loading_target_p1_plus_p2).to eq(0.5)

    end

    it 'must be within range' do
      expect(build(:pacbio_well, loading_target_p1_plus_p2: 0.45)).to be_valid
      expect(build(:pacbio_well, loading_target_p1_plus_p2: 72)).to_not be_valid
      expect(build(:pacbio_well, loading_target_p1_plus_p2: 0)).to be_valid
    end

  end

  context 'libraries' do
    let(:libraries) { create_list(:pacbio_library, 5, :tagged) }
    let(:pools)     { create_list(:pacbio_pool, 2, libraries: libraries) }
    let(:well)      { create(:pacbio_well, pools: pools) }

    it 'can have one or more' do
      expect(well.libraries).to eq(libraries)
    end
  end

  context 'pools' do
    let(:pools) { create_list(:pacbio_pool, 2) }
    let(:well)  { create(:pacbio_well, pools: pools) }

    it 'can have one or more' do
      expect(well.pools.length).to eq(2)
    end

    it 'can return a list of sample names' do
      sample_names = well.sample_names.split(':')
      expect(sample_names.length).to eq(2)
      expect(sample_names.first).to eq(well.libraries.first.request.sample_name)

      sample_names = well.sample_names(',').split(',')
      expect(sample_names.length).to eq(2)
      expect(sample_names.first).to eq(well.libraries.first.request.sample_name)
    end

    it 'can return a list of tags' do
      tag_ids = well.libraries.collect(&:tag_id)
      expect(well.tags).to eq(tag_ids)
    end

  end

  context 'sample sheet mixin' do
    let(:well)                { create(:pacbio_well) }

    it 'includes the Sample Sheet mixin' do
      expect(well.same_barcodes_on_both_ends_of_sequence).to eq true
    end
  end

  context 'template prep kit box barcode' do
    let(:well)   { create(:pacbio_well_with_pools) }

    it 'returns the well pools template_prep_kit_box_barcode' do
      expected = well.pools.first.template_prep_kit_box_barcode
      expect(well.template_prep_kit_box_barcode).to eq expected
    end
  end

  context 'collection?' do
    let(:well)                { create(:pacbio_well) }

    it 'will always be true' do
      expect(well).to be_collection
    end
  end
end
