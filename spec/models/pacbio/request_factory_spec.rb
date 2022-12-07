# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::RequestFactory, pacbio: true do
  let(:attributes) do
    [
      { sample: attributes_for(:sample),
        request: attributes_for(:pacbio_request),
        tube: { barcode: 'SE108532I' } },
      { sample: attributes_for(:sample),
        request: attributes_for(:pacbio_request),
        tube: { barcode: 'SE108533J' } },
      { sample: attributes_for(:sample),
        request: attributes_for(:pacbio_request),
        tube: { barcode: 'SE108534K' } }
    ]
  end

  it_behaves_like 'requestor factory'
end
