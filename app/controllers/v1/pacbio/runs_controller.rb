# frozen_string_literal: true

module V1
  module Pacbio
    # JsonApi::Resource controllers are primarily handled by the corresponding
    # resources
    # See {Pacbio::Run} and {Run} for more information
    class RunsController < ApplicationController
      # endpoint generating a sample sheet for a Pacbio::Run
      def sample_sheet
        run = ::Pacbio::Run.find(params[:run_id])
        csv = run.generate_sample_sheet

        send_data csv,
                  type: 'text/csv; charset=utf-8; header=present',
                  disposition: "attachment; filename=#{run.name}.csv"
      end
    end
  end
end
