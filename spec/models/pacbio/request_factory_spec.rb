# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::RequestFactory, type: :model, pacbio: true do
  let(:attributes) do
    [
      attributes_for(:sample).merge(attributes_for(:pacbio_request, barcode: 'SE108532I')),
      attributes_for(:sample).merge(attributes_for(:pacbio_request, barcode: 'SE108533J')),
      attributes_for(:sample).merge(attributes_for(:pacbio_request, barcode: 'SE108534K'))
    ]
  end

  it_behaves_like 'requestor factory'
end
