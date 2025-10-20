# frozen_string_literal: true

require 'rails_helper'

require './spec/support/json_matcher'

RSpec.describe 'ReceptionsController' do
  Broker::Handle.class_eval do
    def test_received_messages
      @test_received_messages ||= []
    end

    def clear_test_received_messages
      @test_received_messages = []
    end

    def publish(message)
      test_received_messages.push(message.payload)
    end
  end

  before do
    Broker::Handle.clear_test_received_messages
  end

  describe '#post with ont data' do
    let!(:library_type) { create(:library_type, :ont) }
    let!(:data_type) { create(:data_type, :ont) }

    context 'with a valid payload and a publishable source' do
      let(:object_body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              # Only tol lab share source publishes
              source: Reception::TOL_LAB_SHARE_SOURCE,
              tubes_attributes: [
                {
                  type: 'tubes',
                  barcode: 'NT1',
                  request: attributes_for(:ont_request).merge(
                    library_type: library_type.name,
                    data_type: data_type.name
                  ),
                  sample: attributes_for(:sample)
                }
              ]
            }
          }
        }
      end
      let(:body) do
        object_body.to_json
      end

      it 'has a created status' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body
      end

      it 'publishes a message' do
        allow(Messages).to receive(:publish).and_call_original
        expect(Messages).to receive(:publish).twice
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(Broker::Handle.test_received_messages.length).to eq(2)
        expect(Broker::Handle.test_received_messages[0].include?('priority_level')).to be true
        assert match_json?(Broker::Handle.test_received_messages[0],
                           {
                             'lims' => 'Traction', 'sample' => {
                               'common_name' => 'human',
                               'last_updated' => /.*/,
                               'id_sample_lims' => /.*/,
                               'uuid_sample_lims' => /.*/,
                               'name' => /.*/,
                               'public_name' => 'PublicName',
                               'priority_level' => 'Medium',
                               'country_of_origin' => 'United Kingdom'
                             }
                           })

        assert match_json?(Broker::Handle.test_received_messages[1],
                           {
                             'lims' => 'Traction', 'stock_resource' => {
                               'stock_resource_id' => /\d/,
                               'labware_coordinate' => nil,
                               'human_barcode' => 'NT1',
                               'machine_barcode' => 'NT1',
                               'labware_type' => 'tube',
                               'created_at' => /.*/,
                               'updated_at' => /.*/,
                               'samples' => [
                                 {
                                   'sample_uuid' => /.*/,
                                   'study_uuid' => /.*/
                                 }
                               ]
                             }
                           })
      end
    end

    context 'with a valid payload and a non publishable source' do
      let(:object_body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              tubes_attributes: [
                {
                  type: 'tubes',
                  barcode: 'NT1',
                  request: attributes_for(:ont_request).merge(
                    library_type: library_type.name,
                    data_type: data_type.name
                  ),
                  sample: attributes_for(:sample)
                }
              ]
            }
          }
        }
      end
      let(:body) do
        object_body.to_json
      end

      it 'has a created status' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body
      end

      it 'does not publish a message' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(Broker::Handle.test_received_messages.length).to eq(0)
      end
    end

    context 'when receiving a change on labware' do
      let(:object_body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              tubes_attributes: [
                {
                  type: 'tubes',
                  barcode: 'NT1',
                  request: attributes_for(:ont_request).merge(
                    library_type: library_type.name,
                    data_type: data_type.name
                  ),
                  sample: attributes_for(:sample)
                }
              ]
            }
          }
        }
      end

      let(:body) do
        object_body.to_json
      end

      let(:changed_body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              tubes_attributes: [
                {
                  type: 'tubes',
                  barcode: 'NT1',
                  request: attributes_for(:ont_request).merge(
                    library_type: library_type.name,
                    data_type: data_type.name
                  ),
                  sample: attributes_for(:sample).merge({
                                                          species: 'blablabla'
                                                        })
                }
              ]
            }
          }
        }.to_json
      end

      it 'rejects the request' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body

        post v1_receptions_path, params: changed_body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_content), response.body
      end
    end

    context 'when receiving an update on labware' do
      let(:body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              plates_attributes: [
                {
                  type: 'plates',
                  barcode: 'NT1',
                  wells_attributes: [
                    {
                      position: 'A1',
                      request: attributes_for(:ont_request).merge(
                        library_type: library_type.name,
                        data_type: data_type.name
                      ),
                      sample: attributes_for(:sample)
                    }
                  ]
                }
              ]
            }
          }
        }.to_json
      end
      let(:updated_body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              plates_attributes: [
                {
                  type: 'plates',
                  barcode: 'NT1',
                  wells_attributes: [
                    {
                      position: 'A2',
                      request: attributes_for(:ont_request).merge(
                        library_type: library_type.name,
                        data_type: data_type.name
                      ),
                      sample: attributes_for(:sample)
                    }
                  ]
                }
              ]
            }
          }
        }.to_json
      end

      it 'can accept an update on labware' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body
        post v1_receptions_path, params: updated_body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body
      end
    end

    context 'when receiving an update on labware with some duplicates' do
      let(:body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              plates_attributes: [
                {
                  type: 'plates',
                  barcode: 'NT1',
                  wells_attributes: [
                    {
                      position: 'A1',
                      request: attributes_for(:ont_request).merge(
                        library_type: library_type.name,
                        data_type: data_type.name
                      ),
                      sample: attributes_for(:sample)
                    }
                  ]
                }
              ]
            }
          }
        }.to_json
      end
      let(:updated_body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              plates_attributes: [
                {
                  type: 'plates',
                  barcode: 'NT1',
                  wells_attributes: [
                    {
                      position: 'A1',
                      request: attributes_for(:ont_request).merge(
                        library_type: library_type.name,
                        data_type: data_type.name
                      ),
                      sample: attributes_for(:sample)
                    },
                    {
                      position: 'A2',
                      request: attributes_for(:ont_request).merge(
                        library_type: library_type.name,
                        data_type: data_type.name
                      ),
                      sample: attributes_for(:sample)
                    }
                  ]
                }
              ]
            }
          }
        }.to_json
      end

      it 'can accept an update on labware with duplicates' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body
        post v1_receptions_path, params: updated_body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body

        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['attributes']['labware']['NT1']).to eq(
          {
            'imported' => 'partial',
            'errors' => ['A1 already has a sample']
          }
        )
      end
    end

    context 'with pool_attributes' do
      let(:ont_tag_set) { create(:tag_set_with_tags, pipeline: 'ont') }

      context 'with a valid pool creation payload' do
        let(:body) do
          {
            data: {
              type: 'receptions',
              attributes: {
                source: 'traction-ui.sequencescape',
                tubes_attributes: [
                  {
                    type: 'tubes',
                    barcode: 'NT1',
                    request: attributes_for(:ont_request).merge(
                      library_type: library_type.name,
                      data_type: data_type.name
                    ),
                    library: {
                      volume: 1,
                      concentration: 2,
                      insert_size: 3,
                      kit_barcode: ont_tag_set.name,
                      tag_sequence: ont_tag_set.tags.first.oligo
                    },
                    sample: attributes_for(:sample)
                  },
                  {
                    type: 'tubes',
                    barcode: 'NT2',
                    request: attributes_for(:ont_request).merge(
                      library_type: library_type.name,
                      data_type: data_type.name
                    ),
                    library: {
                      volume: 1,
                      concentration: 2,
                      insert_size: 3,
                      kit_barcode: ont_tag_set.name,
                      tag_sequence: ont_tag_set.tags.second.oligo
                    },
                    sample: attributes_for(:sample)
                  },
                  {
                    type: 'tubes',
                    barcode: 'NT3',
                    request: attributes_for(:ont_request).merge(
                      library_type: library_type.name,
                      data_type: data_type.name
                    ),
                    library: {
                      volume: 1,
                      concentration: 2,
                      insert_size: 3,
                      kit_barcode: ont_tag_set.name,
                      tag_sequence: ont_tag_set.tags.third.oligo
                    },
                    sample: attributes_for(:sample)
                  }
                ],
                pool_attributes: {
                  volume: 1,
                  concentration: 2,
                  insert_size: 3,
                  kit_barcode: ont_tag_set.name,
                  barcode: 'NT123'
                }
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created), response.body
        end

        it 'creates the correct data' do
          expect { post v1_receptions_path, params: body, headers: json_api_headers }
            .to change(Ont::Pool, :count)
            .from(0)
            .to(1)
            .and change(Ont::Library, :count)
            .from(0)
            .to(3)
            .and change(Request, :count)
            .from(0)
            .to(3)
            .and change(Ont::Request, :count)
            .from(0)
            .to(3)

          new_pool = Ont::Pool.last
          expect(new_pool.tube.barcode).to eq('NT123')
          expect(new_pool.volume).to eq(1)
          expect(new_pool.concentration).to eq(2)
          expect(new_pool.insert_size).to eq(3)
          expect(new_pool.kit_barcode).to eq(ont_tag_set.name)
          expect(new_pool.libraries.count).to eq(3)
          new_pool.libraries.each do |library|
            expect(library.volume).to eq(1)
            expect(library.concentration).to eq(2)
            expect(library.insert_size).to eq(3)
            expect(library.kit_barcode).to eq(ont_tag_set.name)
            # Check the library has a tag
            expect(library.tag).to eq(ont_tag_set.tags.find_by(id: library.tag_id))
          end

          labware = JSON.parse(response.parsed_body)['data']['attributes']['labware']
          expected_labware = {
            'NT1' => { 'imported' => 'success', 'errors' => [] },
            'NT2' => { 'imported' => 'success', 'errors' => [] },
            'NT3' => { 'imported' => 'success', 'errors' => [] },
            'NT123' => { 'imported' => 'success', 'errors' => [] }
          }
          expect(labware).to eq(expected_labware)
        end
      end

      context 'with invalid pool attributes' do
        let(:body) do
          {
            data: {
              type: 'receptions',
              attributes: {
                source: 'traction-ui.sequencescape',
                tubes_attributes: [
                  {
                    type: 'tubes',
                    barcode: 'NT1',
                    request: attributes_for(:ont_request).merge(
                      library_type: library_type.name,
                      data_type: data_type.name
                    ),
                    library: {
                      volume: 1,
                      concentration: 2,
                      insert_size: 3,
                      kit_barcode: ont_tag_set.name,
                      tag_sequence: ont_tag_set.tags.first.oligo
                    },
                    sample: attributes_for(:sample)
                  }
                ],
                pool_attributes: {
                  kit_barcode: ont_tag_set.name,
                  volume: nil,
                  concentration: -1,
                  insert_size: nil,
                  barcode: 'NT123'
                }
              }
            }
          }.to_json
        end

        it 'has a unprocessable_content status' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include('pool/concentration - must be greater than or equal to 0')
        end
      end

      context 'with missing libraries' do
        let(:body) do
          {
            data: {
              type: 'receptions',
              attributes: {
                source: 'traction-ui.sequencescape',
                tubes_attributes: [
                  {
                    type: 'tubes',
                    barcode: 'NT1',
                    request: attributes_for(:ont_request).merge(
                      library_type: library_type.name,
                      data_type: data_type.name
                    ),
                    sample: attributes_for(:sample)
                  }
                ],
                pool_attributes: {
                  kit_barcode: nil,
                  volume: 1,
                  concentration: 1,
                  insert_size: nil,
                  barcode: 'NT123'
                }
              }
            }
          }.to_json
        end

        it 'has a unprocessable_content status' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include('pool/libraries - can\'t be blank')
        end
      end

      context 'with libraries with incorrect tags' do
        let(:ont_tag_set_2) { create(:tag_set_with_tags, pipeline: 'ont') }
        let(:body) do
          {
            data: {
              type: 'receptions',
              attributes: {
                source: 'traction-ui.sequencescape',
                tubes_attributes: [
                  {
                    type: 'tubes',
                    barcode: 'NT1',
                    request: attributes_for(:ont_request).merge(
                      library_type: library_type.name,
                      data_type: data_type.name
                    ),
                    library: {
                      volume: 1,
                      concentration: 2,
                      insert_size: 3,
                      kit_barcode: ont_tag_set.name,
                      tag_sequence: ont_tag_set.tags.first.oligo
                    },
                    sample: attributes_for(:sample)
                  },
                  {
                    type: 'tubes',
                    barcode: 'NT2',
                    request: attributes_for(:ont_request).merge(
                      library_type: library_type.name,
                      data_type: data_type.name
                    ),
                    library: {
                      volume: 1,
                      concentration: 2,
                      insert_size: 3,
                      kit_barcode: ont_tag_set.name,
                      tag_sequence: 'incorrect sequence'
                    },
                    sample: attributes_for(:sample)
                  }
                ],
                pool_attributes: {
                  kit_barcode: ont_tag_set.name,
                  volume: 1,
                  concentration: 1,
                  insert_size: nil,
                  barcode: 'NT123'
                }
              }
            }
          }.to_json
        end

        it 'has a unprocessable_content status' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include('pool/tags - must be present on all libraries')
        end
      end

      context 'with requests with unknown library types' do
        let(:ont_tag_set_2) { create(:tag_set_with_tags, pipeline: 'ont') }
        let(:body) do
          {
            data: {
              type: 'receptions',
              attributes: {
                source: 'traction-ui.sequencescape',
                tubes_attributes: [
                  {
                    type: 'tubes',
                    barcode: 'NT1',
                    request: attributes_for(:ont_request).merge(
                      library_type: library_type.name,
                      data_type: data_type.name
                    ),
                    library: {
                      volume: 1,
                      concentration: 2,
                      insert_size: 3,
                      kit_barcode: ont_tag_set.name,
                      tag_sequence: ont_tag_set.tags.first.oligo
                    },
                    sample: attributes_for(:sample)
                  },
                  {
                    type: 'tubes',
                    barcode: 'NT2',
                    request: attributes_for(:ont_request).merge(
                      library_type: 'unknown',
                      data_type: data_type.name
                    ),
                    library: {
                      volume: 1,
                      concentration: 2,
                      insert_size: 3,
                      kit_barcode: ont_tag_set.name,
                      tag_sequence: ont_tag_set.tags.first.oligo
                    },
                    sample: attributes_for(:sample)
                  }
                ],
                pool_attributes: {
                  kit_barcode: ont_tag_set.name,
                  volume: 1,
                  concentration: 1,
                  insert_size: nil,
                  barcode: 'NT123'
                }
              }
            }
          }.to_json
        end

        it 'has a unprocessable_content status' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include('requests/1/library_type - is not a recognised library type')
        end
      end
    end

    context 'with a invalid payload' do
      context 'with an invalid source' do
        let(:body) do
          {
            data: {
              type: 'receptions',
              attributes: {
                source: 'Not_A valid SOURCE!!!',
                tubes_attributes: [
                  {
                    type: 'tubes',
                    barcode: 'NT1',
                    request: attributes_for(:ont_request).merge(
                      library_type: library_type.name,
                      data_type: data_type.name
                    ),
                    sample: attributes_for(:sample)
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_content status' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'generates a valid json-api error response' do
          post v1_receptions_path, params: body, headers: json_api_headers
          pointer = json.dig('errors', 0, 'source', 'pointer')
          expect(pointer).to eq('/data/attributes/source')
        end
      end

      context 'with a invalid library type' do
        let(:body) do
          {
            data: {
              type: 'receptions',
              attributes: {
                source: 'traction-ui.sequencescape',
                tubes_attributes: [
                  {
                    type: 'tubes',
                    barcode: 'NT1',
                    request: attributes_for(:ont_request).merge(
                      library_type: 'Invalid Library Type',
                      data_type: data_type.name
                    ),
                    sample: attributes_for(:sample)
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_content status' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'generates a valid json-api error response' do
          post v1_receptions_path, params: body, headers: json_api_headers
          pointer = json.dig('errors', 0, 'source', 'pointer')
          expect(pointer).to eq('/data/attributes/requests/0/library_type')
        end
      end

      context 'with a invalid sample payload' do
        let(:body) do
          {
            data: {
              type: 'receptions',
              attributes: {
                source: 'traction-ui.sequencescape',
                tubes_attributes: [
                  {
                    type: 'tubes',
                    barcode: 'NT1',
                    request: attributes_for(:ont_request).merge(
                      library_type: library_type.name,
                      data_type: data_type.name
                    ),
                    sample: {}
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_content status' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'generates a valid json-api error response' do
          post v1_receptions_path, params: body, headers: json_api_headers
          pointers = json.fetch('errors').map do |error|
            error.dig('source', 'pointer')
          end
          expect(pointers).to include('/data/attributes/requests/0/sample')
          expect(pointers).to include('/data/attributes/requests/0/sample')
        end
      end

      context 'with a badly structured payload' do
        let(:body) do
          {
            data: {
              type: 'receptions',
              attributes: {
                source: 'traction-ui.sequencescape',
                tubes_attributes: ''
              }
            }
          }.to_json
        end

        it 'has a bad_request status' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'with all duplicated samples' do
        let(:body) do
          {
            data: {
              type: 'receptions',
              attributes: {
                source: 'traction-ui.sequencescape',
                plates_attributes: [
                  {
                    type: 'plates',
                    barcode: 'NT1',
                    wells_attributes: [
                      {
                        position: 'A1',
                        request: attributes_for(:ont_request).merge(
                          library_type: library_type.name,
                          data_type: data_type.name
                        ),
                        sample: attributes_for(:sample)
                      }
                    ]
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has a bad_request status and correct errors' do
          create(:plate_with_wells_and_requests, barcode: 'NT1', pipeline: 'pacbio')
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content)
          expect(json['errors'][0]['detail']).to eq('requests - there are no new samples to import')
        end
      end
    end
  end

  describe '#post with pacbio data' do
    let!(:library_type) { create(:library_type, :pacbio) }
    let!(:data_type) { create(:data_type, :pacbio) }

    context 'with a valid payload and a publishable source' do
      let(:object_body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              # Only tol lab share source publishes
              source: Reception::TOL_LAB_SHARE_SOURCE,
              tubes_attributes: [
                {
                  type: 'tubes',
                  barcode: 'NT1',
                  request: attributes_for(:pacbio_request).merge(
                    library_type: library_type.name,
                    data_type: data_type.name
                  ),
                  sample: attributes_for(:sample)
                }
              ]
            }
          }
        }
      end
      let(:body) do
        object_body.to_json
      end

      it 'has a created status' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body
      end

      it 'publishes a message' do
        allow(Messages).to receive(:publish).and_call_original
        expect(Messages).to receive(:publish).twice
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(Broker::Handle.test_received_messages.length).to eq(2)
        expect(Broker::Handle.test_received_messages[0].include?('priority_level')).to be true
        assert match_json?(Broker::Handle.test_received_messages[0],
                           {
                             'lims' => 'Traction', 'sample' => {
                               'common_name' => 'human',
                               'last_updated' => /.*/,
                               'id_sample_lims' => /.*/,
                               'uuid_sample_lims' => /.*/,
                               'name' => /.*/,
                               'public_name' => 'PublicName',
                               'priority_level' => 'Medium',
                               'country_of_origin' => 'United Kingdom'
                             }
                           })

        assert match_json?(Broker::Handle.test_received_messages[1],
                           {
                             'lims' => 'Traction', 'stock_resource' => {
                               'stock_resource_id' => /\d/,
                               'labware_coordinate' => nil,
                               'human_barcode' => 'NT1',
                               'machine_barcode' => 'NT1',
                               'labware_type' => 'tube',
                               'created_at' => /.*/,
                               'updated_at' => /.*/,
                               'samples' => [
                                 {
                                   'sample_uuid' => /.*/,
                                   'study_uuid' => /.*/
                                 }
                               ]
                             }
                           })
      end
    end

    context 'with a valid payload and a non publishable source' do
      let(:object_body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              tubes_attributes: [
                {
                  type: 'tubes',
                  barcode: 'NT1',
                  request: attributes_for(:pacbio_request).merge(
                    library_type: library_type.name,
                    data_type: data_type.name
                  ),
                  sample: attributes_for(:sample)
                }
              ]
            }
          }
        }
      end

      let(:body) do
        object_body.to_json
      end

      it 'has a created status' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body
      end

      it 'does not publish a message' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(Broker::Handle.test_received_messages.length).to eq(0)
      end
    end

    context 'with pool attributes' do
      let(:pacbio_tag_set) { create(:tag_set_with_tags, pipeline: 'pacbio') }
      let(:body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              tubes_attributes: [
                {
                  type: 'tubes',
                  barcode: 'NT1',
                  request: attributes_for(:pacbio_request).merge(
                    library_type: library_type.name,
                    data_type: data_type.name
                  ),
                  library: {
                    volume: 1,
                    concentration: 2,
                    insert_size: 3,
                    template_prep_kit_box_barcode: 'test',
                    tag_sequence: pacbio_tag_set.tags.first.oligo
                  },
                  sample: attributes_for(:sample)
                }
              ],
              pool_attributes: {
                template_prep_kit_box_barcode: nil,
                volume: nil,
                concentration: nil,
                insert_size: nil
              }
            }
          }
        }.to_json
      end

      it 'has a unprocessable_content status' do
        # This errors because of a type mismatch when attempting to create the pool as its trying to
        # put PacBio libraries into an ONT pool
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_content)
        expect(json['errors'][0]['detail']).to eq('pool/libraries - can\'t be blank')
      end
    end

    context 'with library attributes' do
      let(:object_body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              tubes_attributes: [
                {
                  type: 'tubes',
                  barcode: 'NT1',
                  library:,
                  request: attributes_for(:pacbio_request).merge(
                    library_type: library_type.name,
                    data_type: data_type.name
                  ),
                  sample: attributes_for(:sample)
                }
              ]
            }
          }
        }
      end
      let(:body) do
        object_body.to_json
      end

      context 'library has all attributes' do
        let(:library) { { volume: 1, concentration: 2, insert_size: 3, template_prep_kit_box_barcode: 'barcode' } }

        it 'has a created status' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created), response.body
        end

        it 'creates the correct library for the request' do
          expect { post v1_receptions_path, params: body, headers: json_api_headers }
            .to change(Pacbio::Library, :count)
            .from(0)
            .to(1)

          new_library = Pacbio::Library.last
          expect(new_library.volume).to eq(1)
          expect(new_library.concentration).to eq(2)
          expect(new_library.insert_size).to eq(3)
          expect(new_library.template_prep_kit_box_barcode).to eq('barcode')
        end

        it 'creates the correct request associated with the library' do
          expect { post v1_receptions_path, params: body, headers: json_api_headers }
            .to change(Request, :count)
            .from(0)
            .to(1)

          new_request = Request.last
          expect(new_request.requestable).to be_a(Pacbio::Request)

          new_pacbio_request = new_request.requestable
          new_library = Pacbio::Library.last
          expect(new_library.request.id).to be(new_pacbio_request.id)
        end
      end

      context 'library has essential attributes' do
        let(:library) { { volume: 1, concentration: 2, template_prep_kit_box_barcode: 'barcode' } }

        it 'has a created status' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created), response.body
        end

        it 'creates the correct library for the request' do
          expect { post v1_receptions_path, params: body, headers: json_api_headers }
            .to change(Pacbio::Library, :count)
            .from(0)
            .to(1)

          new_library = Pacbio::Library.last
          expect(new_library.volume).to eq(1)
          expect(new_library.concentration).to eq(2)
          expect(new_library.insert_size).to be_nil
          expect(new_library.template_prep_kit_box_barcode).to eq('barcode')
        end
      end

      context 'library is missing volume' do
        let(:library) { { concentration: 2, template_prep_kit_box_barcode: 'barcode' } }

        it 'responds with correct result' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content), response.body
          expect(response.body).to include('requests/0/requestable - is invalid')
        end
      end

      context 'library is missing concentration' do
        let(:library) { { volume: 1, template_prep_kit_box_barcode: 'barcode' } }

        it 'responds with correct result' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content), response.body
          expect(response.body).to include('requests/0/requestable - is invalid')
        end
      end

      context 'library is missing template prep kit box barcode' do
        let(:library) { { volume: 1, concentration: 2 } }

        it 'responds with correct result' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content), response.body
          expect(response.body).to include('requests/0/requestable - is invalid')
        end
      end

      context 'library is an empty object' do
        let(:library) { {} }

        it 'responds with correct result' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content), response.body
          expect(response.body).to include('requests/0/requestable - is invalid')
        end
      end
    end
  end
end
