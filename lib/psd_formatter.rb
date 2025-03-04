# frozen_string_literal: true

require 'syslog/logger'

# PsdFormatter
class PsdFormatter < Syslog::Logger::Formatter
  LINE_FORMAT = "(thread-%s) [%s] %5s -- : %s\n"
  # Severity label for logging (max 5 chars).
  SEV_LABEL = %w[DEBUG INFO WARN ERROR FATAL ANY].each(&:freeze).freeze

  def initialize(deployment_info)
    # deployment_info is set as DETAILS in deployed_version and called in deployment project
    @app_tag = deployment_info.values.compact.join(':').freeze
    super()
  end

  def call(severity, _timestamp, _progname, msg)
    thread_id = Thread.current.object_id
    format(LINE_FORMAT, thread_id, @app_tag, format_severity(severity), msg)
  end

  private

  def format_severity(severity)
    if severity.is_a?(Integer)
      SEV_LABEL[severity] || 'ANY'
    else
      severity
    end
  end
end
