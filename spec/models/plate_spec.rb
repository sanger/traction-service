require 'rails_helper'

RSpec.describe Plate, type: :model do
  context 'labware' do
    let(:labware_model) { :plate }
    it_behaves_like 'labware'
  end
end
