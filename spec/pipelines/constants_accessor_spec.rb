# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pipelines::ConstantsAccessor, type: :model do
  context 'when base constants are defined' do
    let(:constants_accessor) {
      Pipelines::ConstantsAccessor.new(
        Class.new do
          def pcr_tag_set
            Class.new do
              def name
                'test tag set name'
              end

              def hostname
                'test hostname'
              end
            end.new
          end
        end.new
      )
    }

    it 'will return the pcr tag set name' do
      expect(constants_accessor.pcr_tag_set_name).to eq('test tag set name')
    end

    it 'will return the pcr tag set hostname' do
      expect(constants_accessor.pcr_tag_set_hostname).to eq('test hostname')
    end
  end
end
