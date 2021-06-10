require 'rails_helper'

RSpec.describe Pacbio::Request, type: :model, pacbio: true do

  it_behaves_like 'requestor model'

  context 'cost_code default value' do
    it 'sets cost_code to a default value if not entered' do
      request = Pacbio::Request.create(library_type: 'library_type_1', 
                                       estimate_of_gb_required: 10, 
                                       number_of_smrt_cells: 1, 
                                       external_study_id: 1 )
      expect(request.cost_code).to eq(Rails.application.config.pacbio_request_cost_code) #= config value is'S4773'
    end

    it 'sets cost_code to entered value if inputted' do
      request = Pacbio::Request.create(library_type: 'library_type_1', 
                                       estimate_of_gb_required: 10, 
                                       number_of_smrt_cells: 1, 
                                       external_study_id: 1,
                                       cost_code: 'PSD123' )
      expect(request.cost_code).to eq('PSD123')
    end
  end

  context 'libraries' do
    it 'can have one or more' do
      request = create(:pacbio_request)
      (1..5).each do |i|
        create(:pacbio_request_library, request: request, library: create(:pacbio_library), tag: create(:tag))
      end
      expect(request.libraries.count).to eq(5)
    end
  end

end