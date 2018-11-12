require 'rails_helper'

RSpec.describe Sample, type: :model do
  
  context 'on creation' do
    it 'should have a name' do
      expect(create(:sample, name: 'mysample').name).to eq('mysample')
    end

    it 'must have a unique name' do
      sample = create(:sample)
      expect(build(:sample, name: sample.name)).not_to be_valid
    end
  end

  context 'on update' do
    it 'name cannot be updated' do
      sample = create(:sample)
      name = sample.name
      sample.update_attributes(name: 'sample3')
      expect(sample.reload.name).to eq(name)
    end
  end

end
