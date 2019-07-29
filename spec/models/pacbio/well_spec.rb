require 'rails_helper'

RSpec.describe Pacbio::Well, type: :model, pacbio: true do

  context 'movie time' do
    it 'must be present' do
      expect(build(:pacbio_well, movie_time: nil)).to_not be_valid
    end

    it 'must be within range' do
      expect(build(:pacbio_well, movie_time: 15)).to be_valid
      expect(build(:pacbio_well, movie_time: 31)).to_not be_valid
      expect(build(:pacbio_well, movie_time: 0)).to_not be_valid
    end

  end

  context 'insert size' do

    it 'must be present' do
      expect(build(:pacbio_well, insert_size: nil)).to_not be_valid
    end

    it 'must be within range' do
      expect(build(:pacbio_well, insert_size: 10)).to be_valid
      expect(build(:pacbio_well, insert_size: 5)).to_not be_valid
    end
  end

  it 'must have an on plate loading concentration' do
    expect(build(:pacbio_well, on_plate_loading_concentration: nil)).to_not be_valid
  end

  context 'position' do

    it 'must have a row' do
      expect(build(:pacbio_well, row: nil)).to_not be_valid
    end

    it 'must have a column' do
      expect(build(:pacbio_well, column: nil)).to_not be_valid
    end

    it 'can have a position' do
      expect(build(:pacbio_well, row: 'B', column: '01').position).to eq('B01')
    end
  end

  it 'must have to a plate' do
    expect(build(:pacbio_well, plate: nil)).to_not be_valid
  end

  it 'can have a comment' do
    expect(build(:pacbio_well).comment).to be_present
  end

  it 'can have a summary' do
    well = create(:pacbio_well_with_library)
    expect(well.summary).to eq("#{well.library.request.sample_name},#{well.comment}")
  end

   it 'will have a uuid' do
    expect(create(:pacbio_well).uuid).to be_present
  end


  context 'sequencing mode' do
    it 'must be present' do
      expect(build(:pacbio_well, sequencing_mode: nil)).to_not be_valid
    end

    it 'must include the correct options' do
      expect(Pacbio::Well.sequencing_modes.keys).to eq(['CLR', 'CCS'])
    end
  end

  context '#generate_ccs_data' do
    it 'returns true if sequencing_mode is CCS' do
      expect(create(:pacbio_well, sequencing_mode: 'CCS').generate_ccs_data).to eq true
    end

    it 'returns false if sequencing_mode is CLR' do
      expect(create(:pacbio_well, sequencing_mode: 'CLR').generate_ccs_data).to eq false
    end
  end

  context 'libraries' do
    it 'can have one or more' do
      well = create(:pacbio_well)
      well.libraries << create_list(:pacbio_library, 5)
      expect(well.libraries.count).to eq(5)
    end
  end

  context 'request libraries' do
    it 'can have one or more' do
      well = create(:pacbio_well)
      tag = create(:tag)

      request_libraries = create_list(:pacbio_request_library, 2)
      well.libraries << request_libraries.collect(&:library)

      expect(well.request_libraries.length).to eq(2)

    end
  end

end
