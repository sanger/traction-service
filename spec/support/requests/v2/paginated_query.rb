# frozen_string_literal: true

RSpec.shared_examples 'paginated_query' do
  context 'when no entities' do
    it 'returns empty entity list' do
      post v2_path, params: { query: "{ #{graphql_method} { nodes { id } } }" }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'][graphql_method]['nodes'].length).to eq(0)
    end
  end

  context 'when 15 entities' do
    let!(:queryable) { create_list(paginated_model, 15) }

    def expected_ids(drop, take)
      queryable.sort { |a, b| b.updated_at <=> a.updated_at }
               .drop(drop)
               .take(take)
               .map { |entity| entity.id.to_s }
    end

    context 'no pagination variables' do
      let(:query) do
        "{ #{graphql_method} { nodes { id } " \
        'pageInfo { hasNextPage hasPreviousPage pageCount currentPage entitiesCount } } }'
      end

      it 'returns first 10 entities in reverse updated at order' do
        post v2_path, params: { query: query }
        expect(response).to have_http_status(:success)

        json = ActiveSupport::JSON.decode(response.body)
        nodes_json = json['data'][graphql_method]['nodes']
        expect(nodes_json.length).to eq(10)
        expect(nodes_json.map { |n| n['id'] }).to eq(expected_ids(0, 10))
      end

      it 'gives correct page info' do
        post v2_path, params: { query: query }
        expect(response).to have_http_status(:success)

        json = ActiveSupport::JSON.decode(response.body)
        page_info_json = json['data'][graphql_method]['pageInfo']
        expect(page_info_json['hasNextPage']).to be_truthy
        expect(page_info_json['hasPreviousPage']).to be_falsey
        expect(page_info_json['pageCount']).to eq(2)
        expect(page_info_json['currentPage']).to eq(1)
        expect(page_info_json['entitiesCount']).to eq(15)
      end
    end

    context 'with pageNum variable' do
      let(:query) do
        "{ #{graphql_method}(pageNum: 2) { nodes { id } " \
        'pageInfo { hasNextPage hasPreviousPage pageCount currentPage entitiesCount } } }'
      end

      it 'returns the final 5 entities in reverse updated at order' do
        post v2_path, params: { query: query }
        expect(response).to have_http_status(:success)

        json = ActiveSupport::JSON.decode(response.body)
        nodes_json = json['data'][graphql_method]['nodes']
        expect(nodes_json.length).to eq(5)
        expect(nodes_json.map { |n| n['id'] }).to eq(expected_ids(10, 10))
      end

      it 'gives correct page info' do
        post v2_path, params: { query: query }
        expect(response).to have_http_status(:success)

        json = ActiveSupport::JSON.decode(response.body)
        page_info_json = json['data'][graphql_method]['pageInfo']
        expect(page_info_json['hasNextPage']).to be_falsey
        expect(page_info_json['hasPreviousPage']).to be_truthy
        expect(page_info_json['pageCount']).to eq(2)
        expect(page_info_json['currentPage']).to eq(2)
        expect(page_info_json['entitiesCount']).to eq(15)
      end
    end

    context 'with pageNum and pageSize variables' do
      let(:query) do
        "{ #{graphql_method}(pageNum: 2, pageSize: 4) { nodes { id } " \
        'pageInfo { hasNextPage hasPreviousPage pageCount currentPage entitiesCount } } }'
      end

      it 'returns entities 5 through 8 in reverse updated at order' do
        post v2_path, params: { query: query }
        expect(response).to have_http_status(:success)

        json = ActiveSupport::JSON.decode(response.body)
        nodes_json = json['data'][graphql_method]['nodes']
        expect(nodes_json.length).to eq(4)
        expect(nodes_json.map { |n| n['id'] }).to eq(expected_ids(4, 4))
      end

      it 'gives correct page info' do
        post v2_path, params: { query: query }
        expect(response).to have_http_status(:success)

        json = ActiveSupport::JSON.decode(response.body)
        page_info_json = json['data'][graphql_method]['pageInfo']
        expect(page_info_json['hasNextPage']).to be_truthy
        expect(page_info_json['hasPreviousPage']).to be_truthy
        expect(page_info_json['pageCount']).to eq(4)
        expect(page_info_json['currentPage']).to eq(2)
        expect(page_info_json['entitiesCount']).to eq(15)
      end
    end
  end
end
