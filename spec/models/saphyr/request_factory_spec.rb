# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Saphyr::RequestFactory, type: :model, saphyr: true do
  let(:attributes) do
    [
      { sample: attributes_for(:sample), request: attributes_for(:saphyr_request) },
      { sample: attributes_for(:sample), request: attributes_for(:saphyr_request) },
      { sample: attributes_for(:sample), request: attributes_for(:saphyr_request) }
    ]
  end

  it_behaves_like 'requestor factory'

end
