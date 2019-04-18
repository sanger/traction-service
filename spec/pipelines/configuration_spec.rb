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
        'message': 'pipeline_b_flowcell',
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

  let(:configuration) { Pipelines::Configuration.new(params)}


  it 'will have configuration for each pipeline' 

  it 'each configuration will have a lims'

  it 'each configuration will have an instrument name'

  it 'each configuration will have some message configuration' 



end