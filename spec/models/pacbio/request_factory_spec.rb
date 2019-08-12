# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::RequestFactory, type: :model, pacbio: true do
  let(:attributes) { [attributes_for(:sample).merge(attributes_for(:pacbio_request)), 
                      attributes_for(:sample).merge(attributes_for(:pacbio_request)),
                      attributes_for(:sample).merge(attributes_for(:pacbio_request))] }

  it_behaves_like 'requestor factory'

end
