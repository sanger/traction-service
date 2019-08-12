# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Saphyr::RequestFactory, type: :model, saphyr: true do
  let(:attributes) { [attributes_for(:sample).merge(attributes_for(:saphyr_request)), 
                      attributes_for(:sample).merge(attributes_for(:saphyr_request)),
                      attributes_for(:sample).merge(attributes_for(:saphyr_request))] }

  it_behaves_like 'requestor factory'

end
