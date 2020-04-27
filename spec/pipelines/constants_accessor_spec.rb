require "rails_helper"

RSpec.describe Pipelines::ConstantsAccessor, type: :model do
  context 'when base constants are defined' do
    let(:constants_accessor) {
      Pipelines::ConstantsAccessor.new(
        Class.new do
          def request
            Class.new do
              def external_study_id
                'test study id'
              end
            end.new
          end

          def sample
            Class.new do
              def species
                'test species'
              end
            end.new
          end
        end.new
      )
    }

    it 'will return the external study id' do
      expect(constants_accessor.request_external_study_id).to eq('test study id')
    end

    it 'will return the sample species' do
      expect(constants_accessor.sample_species).to eq('test species')
    end
  end
end
