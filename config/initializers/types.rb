# frozen_string_literal: true

require './app/models/smrt_link_version_type'

ActiveRecord::Type.register(:smrt_link_version, SmrtLinkVersionType)
