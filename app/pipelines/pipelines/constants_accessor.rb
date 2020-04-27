module Pipelines
  class ConstantsAccessor
    def initialize(base)
      @constants_base = base
    end

    def request_external_study_id
      @constants_base.request.external_study_id
    end

    def sample_species
      @constants_base.sample.species
    end
  end
end
