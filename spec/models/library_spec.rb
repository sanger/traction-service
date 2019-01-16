require "rails_helper"

RSpec.describe Library, type: :model do
  context 'on creation' do
    it 'should have a state' do
      expect(create(:library, state: 'pending').state).to eq('pending')
    end

    it 'should have a sample' do
      sample = create(:sample)
      expect(create(:library, sample: sample).sample).to eq(sample)
      expect(create(:library, sample: sample).sample_id).to eq(sample.id)
    end
  end

  context 'state' do
    it 'should be set to pending on creation' do
      expect(create(:library_no_state).state).to eq('pending')
    end
  end

end
