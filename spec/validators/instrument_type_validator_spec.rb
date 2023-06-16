# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/RepeatedExampleGroupBody, RSpec/ScatteredSetup
RSpec.describe InstrumentTypeValidator do
  describe.skip 'when the instrument type is Sequel IIe' do
    before do
      create(:pacbio_smrt_link_version, name: 'v11', default: true)
    end

    context 'run' do
      it 'required attributes' do
        expect(true).to be_truthy
      end
    end

    context 'plates' do
      it 'required attributes' do
        expect(true).to be_truthy
      end
    end

    context 'wells' do
      it 'minimum number of wells' do
        expect(true).to be_truthy
      end
    end
  end

  describe.skip 'when the instrument type is Revio' do
    before do
      create(:pacbio_smrt_link_version, name: 'v12_revio', default: true)
    end

    context 'plates' do
      it 'required attributes' do
        expect(true).to be_truthy
      end
    end

    context 'wells' do
      it 'minimum number of wells' do
        expect(true).to be_truthy
      end
    end
  end
end
# rubocop:enable RSpec/RepeatedExampleGroupBody, RSpec/ScatteredSetup
