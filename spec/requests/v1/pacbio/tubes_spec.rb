require "rails_helper"

RSpec.describe 'TubesController', type: :request do

  let(:pipeline_name)       { 'pacbio' }
  let(:other_pipeline_name) { 'saphyr' }

  it_behaves_like 'tubes'

end
