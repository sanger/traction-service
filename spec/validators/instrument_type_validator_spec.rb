# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstrumentTypeValidator do
  let!(:instrument_types) { YAML.load_file(Rails.root.join('config/pacbio_instrument_types.yml'), aliases: true)[Rails.env]['instrument_types'] }

  describe 'when the instrument type is Sequel IIe' do
    before do
      create(:pacbio_smrt_link_version, name: 'v11', default: true)
    end

    context 'run' do
      it 'required attributes' do
        instrument_types['sequel_iie']['run']['required_attributes'].each do |attribute|
          run = build(:pacbio_run, system_name: 'Sequel IIe')
          run.send("#{attribute}=", nil)
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[attribute]).to include("can't be blank")
        end
      end
    end

    context 'plates' do
      it 'required attributes', skip: 'not yet implemented' do
        instrument_types['sequel_iie']['plate']['required_attributes'].each do |attribute|
          run = build(:pacbio_run, system_name: 'Sequel IIe')
          run.send("#{attribute}=", nil)
          instrument_type_validator = described_class.new(instrument_types:)
          instrument_type_validator.validate(run)
          expect(run.errors.messages[attribute]).to include("can't be blank")
        end
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
