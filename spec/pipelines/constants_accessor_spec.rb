require "rails_helper"

RSpec.describe Pipelines::ConstantsAccessor, type: :model do
  context 'when base constants are defined' do
    let(:constants_accessor) {
      Pipelines::ConstantsAccessor.new(
        Class.new do
          def external_study_id
            'test study id'
          end

          def species
            'test species'
          end
        end.new
      )
    }

    it 'will return the external study id' do
      expect(constants_accessor.external_study_id).to eq('test study id')
    end

    it 'will return the species' do
      expect(constants_accessor.species).to eq('test species')
    end
  end
end
