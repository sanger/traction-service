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

        begin
          csv = run.generate_sample_sheet
          send_data csv,
                    type: 'text/csv; charset=utf-8; header=present',
                    disposition: "attachment; filename=#{run.name}.csv"
        rescue Version::Error => e
          # generate_sample_sheet will raise a Version::Error if the version cannot be found
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
    end
  end
end
