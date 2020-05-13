require "rails_helper"

RSpec.describe Pipelines::ConstantsAccessor, type: :model do
  context 'when base constants are defined' do
    let(:constants_accessor) {
      Pipelines::ConstantsAccessor.new(
        Class.new do
          def pcr_tag_set_name
            'test tag set name'
          end
        end.new
      )
    }

    it 'will return the pcr tag set name' do
      expect(constants_accessor.pcr_tag_set_name).to eq('test tag set name')
    end
  end
end
