require "rails_helper"

RSpec.describe Pipelines::Configuration, type: :model do
  let(:params) {
    {
      'pipeline_a': {
        'lims': 'lims_a',
        'instrument_name': 'bert',
        'message': {
          'key': 'pipeline_a_flowcell',
          'fields': {
            'field_a': {
              'type': :string,
              'value': 'blah, blah, blah'
            },
            'field_b': {
              'type': :model,
              'value': 'attr_a'
            },
            'field_c': {
              'type': :model,
              'value': 'attr_c.attr_d'
            },
            'field_d': {
              'type': :constant,
              'value': 'Time.current'
            }
          }
        }
      },
      'pipeline_b': {
        'lims': 'lims_b',
        'instrument_name': 'ernie',
        'message': {
          'key': 'pipeline_b_flowcell',
          'fields': {
            'field_a': {
              'type': :string,
              'value': 'dah, dah, dah'
            },
            'field_b': {
              'type': :model,
              'value': 'attr_b'
            },
            'field_c': {
              'type': :constant,
              'value': 'Time.current'
            }
          }
        }
      }
    }
  }

  let(:configuration) { Pipelines::Configuration.new(params) }

  it 'will have configuration for each pipeline' do
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

  it 'will have a list of pipelines' do
    expect(configuration.pipelines).to eq(['pipeline_a', 'pipeline_b'])
  end

end