# frozen_string_literal: true

require Rails.root.join('app', 'pipelines', 'pipelines')

Pipelines.configure(Rails.configuration.pipelines)
