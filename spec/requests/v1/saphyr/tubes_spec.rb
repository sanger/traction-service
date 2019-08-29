require "rails_helper"

RSpec.describe 'TubesController', type: :request do

  let(:pipeline_name)       { 'saphyr' }
  let(:other_pipeline_name) { 'pacbio' }

  it_behaves_like 'tubes'

end
