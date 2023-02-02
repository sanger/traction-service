# frozen_string_literal: true

module V1
  module Ont
    # JsonApi::Resource controllers are primarily handled by the corresponding
    # resources
    # See {Run} and {RunResource} for more information
    class RunsController < ApplicationController
      before_action { not_found unless Flipper.enabled?(:dpl_281_ont_create_sequencing_runs) }

      # endpoint generating a sample sheet for a Ont::Run
      def sample_sheet
        run = ::Ont::Run.find(params[:run_id])
        csv = run.generate_sample_sheet

        send_data csv,
                  type: 'text/csv; charset=utf-8; header=present',
                  disposition: "attachment; filename=#{run.experiment_name}.csv"
      end

      # endpoint to retrive sample sheet setting
      def sample_sheet_settings
        json_file = File.read('config/sample-sheet-settings-template.json')
        send_data json_file,
                  type: 'text/json; charset=utf-8; header=present',
                  disposition: 'attachment; filename=sample-sheet-settings-template.json'
      end
    end
  end
end
