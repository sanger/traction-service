# frozen_string_literal: true

require './app/models/pacbio/smrt_link_version_type'

ActiveRecord::Type.register(:version, SmrtLinkVersionType)
