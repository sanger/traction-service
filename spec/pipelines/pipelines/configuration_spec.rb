# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pipelines::Configuration, type: :model do
  let(:params) do
    {
      pipeline_a: {
        lims: 'lims_a',
        instrument_name: 'bert',
        message: {
          key: 'pipeline_a_flowcell',
          fields: {
            field_a: {
              type: :string,
              value: 'blah, blah, blah'
            },
            field_b: {
              type: :model,
              value: 'attr_a'
            },
            field_c: {
              type: :model,
              value: 'attr_c.attr_d'
            },
            field_d: {
              type: :constant,
              value: 'Time.current'
            }
          }
        }
      },
      pipeline_b: {
        lims: 'lims_b',
        instrument_name: 'ernie',
        message: {
          key: 'pipeline_b_flowcell',
          fields: {
            field_a: {
              type: :string,
              value: 'dah, dah, dah'
            },
            field_b: {
              type: :model,
              value: 'attr_b'
            },
            field_c: {
              type: :constant,
              value: 'Time.current'
            }
          }
        }
      }
    }
  end

  let(:configuration) { described_class.new(params) }

  it 'has configuration for each pipeline' do
    expect(configuration).to respond_to(:pipeline_a)
    expect(configuration).to respond_to(:pipeline_b)
  end

  it 'each configuration will have a lims' do
    expect(configuration.pipeline_a.lims).to eq('lims_a')
    expect(configuration.pipeline_b.lims).to eq('lims_b')
  end

  it 'each configuration will have an instrument name' do
    expect(configuration.pipeline_a.instrument_name).to eq('bert')
    expect(configuration.pipeline_b.instrument_name).to eq('ernie')
  end

  it 'each configuration will have some message configuration' do
    message = configuration.pipeline_a.message

    expect(message.key).to eq('pipeline_a_flowcell')
    expect(message.fields.count).to eq(4)
    expect(message.fields.field_a.type).to eq(:string)
    expect(message.fields.field_a.value).to eq('blah, blah, blah')
    expect(message.fields.field_d.type).to eq(:constant)
    expect(message.fields.field_d.value).to eq('Time.current')

    message = configuration.pipeline_b.message
    expect(message.key).to eq('pipeline_b_flowcell')
    expect(message.fields.field_a.type).to eq(:string)
    expect(message.fields.field_a.value).to eq('dah, dah, dah')
    expect(message.fields.field_c.type).to eq(:constant)
    expect(message.fields.field_c.value).to eq('Time.current')
  end

  it 'each configuration will obey its hierarchy' do
    expect(configuration.pipeline_a.message.fields.field_a.value).to eq('blah, blah, blah')
    expect { configuration.pipeline_a.message.field_a.value }.to raise_error(NameError)
  end

  it 'has a list of pipelines' do
    expect(configuration.pipelines).to eq(%w[pipeline_a pipeline_b])
  end

  it 'stills work if we create an item' do
    pipeline_a = Pipelines::Configuration::Item.new('pipeline_a',
                                                    params[:pipeline_a].with_indifferent_access)
    expect(pipeline_a.pipeline).to eq('pipeline_a')
    expect(pipeline_a.lims).to eq('lims_a')
    expect(pipeline_a.instrument_name).to eq('bert')
    expect(pipeline_a.message.fields.count).to eq(4)
  end

  describe 'versioning' do
    subject(:configuration) { described_class.new(params) }

    let(:params) do
      {
        pipeline_c: {
          sample_sheet: {
            v10: {
              field_a: 'a',
              field_10: 'b'
            },
            v20: {
              field_a: 'a',
              field_20: 'c'
            }
          }
        }
      }
    end

    it 'returns the version if it exists' do
      expect(configuration.pipeline_c.sample_sheet.by_version('v10').children).to eq(configuration.pipeline_c.sample_sheet.v10.children)
    end

    it 'raises an error if it is not a valid version format' do
      expect { configuration.pipeline_c.sample_sheet.by_version('not a version') }.to raise_error(Version::Error, 'Unsupported or invalid version')
    end

    it 'raises an error if it is not a valid version' do
      expect { configuration.pipeline_c.sample_sheet.by_version('v30') }.to raise_error(Version::Error, 'Unsupported or invalid version')
    end

    it 'is able to access fields for a specific version' do
      expect(configuration.pipeline_c.sample_sheet.by_version('v10').field_10).to eq('b')
    end

    it 'does not be able to access fields from another version' do
      expect { configuration.pipeline_c.sample_sheet.by_version('v10').field_20 }.to raise_error(NoMethodError)
    end

    it 'does not be able to access fields from another version without by_version' do
      expect(configuration.pipeline_c.sample_sheet.v20.field_20).to eq('c')
      expect { configuration.pipeline_c.sample_sheet.v10.field_20 }.to raise_error(NoMethodError)
    end

    it 'does not be able to access fields from another version once another version has been loaded' do
      expect(configuration.pipeline_c.sample_sheet.by_version('v20').field_20).to eq('c')
      expect { configuration.pipeline_c.sample_sheet.by_version('v10').field_20 }.to raise_error(NoMethodError)
    end
  end
end
