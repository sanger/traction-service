require 'rails_helper'

RSpec.describe Pacbio::Request, type: :model, pacbio: true do

  it 'must have a library type' do
    expect(build(:pacbio_request, library_type: nil)).to_not be_valid
  end

  it 'must have an estimate of number of gigabases required' do
    expect(build(:pacbio_request, estimate_of_gb_required: nil)).to_not be_valid
  end

  it 'must have number of smrt cells' do
    expect(build(:pacbio_request, number_of_smrt_cells: nil)).to_not be_valid
  end

  it 'must have a cost code' do
    expect(build(:pacbio_request, cost_code: nil)).to_not be_valid
  end

  it 'must have an external study id' do
    expect(build(:pacbio_request, external_study_id: nil)).to_not be_valid
  end

  it 'must have a sample' do
    expect(build(:pacbio_request, sample: nil)).to_not be_valid
  end

end