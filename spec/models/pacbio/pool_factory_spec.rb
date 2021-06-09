require 'rails_helper'

RSpec.describe Pacbio::PoolFactory, type: :model, pacbio: true do

  let!(:libraries) { build_list(:pacbio_library, 5).collect(&:attributes)}

  context '#initialize' do

    let(:pool_factory) { Pacbio::PoolFactory.new(libraries: libraries)}

    it 'works' do
      expect(true).to be_truthy
    end

    it 'will have some libraries' do
      expect(pool_factory.libraries.length).to eq(libraries.length)
    end

  end
end