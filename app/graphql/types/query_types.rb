# frozen_string_literal: true

module Types
  # The type for defining GraphQL queries.
  class QueryTypes < BaseObject
    # Wells

    field :well, Types::Outputs::WellType, 'Find a Well by ID.', null: true do
      argument :id, ID, 'The ID of the Well to find.', required: true
    end

    def well(id:)
      Well.resolved_query.find_by(id: id)
    end

    field :wells, [Types::Outputs::WellType], 'Find all Wells.', null: false do
      argument :plate_id, ID, 'The Plate ID to fetch wells for.', required: false
    end

    def wells(plate_id: nil)
      if plate_id.nil?
        Well.resolved_query.all
      else
        Well.resolved_query.where(plate_id: plate_id)
      end
    end

    # Plates

    field :plates, Types::Outputs::PlateType.connection_type, 'Find all Plates by page.',
          null: false do
      # Built in classes add some confusing arguments we don't want to appear in the GraphQL docs
      arguments.reject! { |k, _| %w[first last before after].include? k }
      argument :page_num, Int, 'The page number to return plates for.', required: false
      argument :page_size, Int, 'The number of plates to return per page.', required: false
    end

    def plates(page_num: 1, page_size: 10)
      Connections::PaginatedConnectionWrapper.new(Plate.resolved_query,
                                                  page_num: page_num,
                                                  page_size: page_size,
                                                  total_item_count: Plate.all.count)
    end

    # Ont::Libraries

    field :ont_libraries, Types::Outputs::Ont::LibraryType.connection_type,
          'Find all Ont Libraries.', null: false do
      desc = "Whether to only include libraries that haven't been loaded into flowcells yet.  " \
             'Default: false.'
      # Built in classes add some confusing arguments we don't want to appear in the GraphQL docs
      arguments.reject! { |k, _| %w[first last before after].include? k }
      argument :unassigned_to_flowcells, Boolean, desc, required: false
      argument :page_num, Int, 'The page number to return Ont Runs for.', required: false
      argument :page_size, Int, 'The number of Ont Runs to return per page.', required: false
    end

    def ont_libraries(unassigned_to_flowcells: false, page_num: 1, page_size: 10)
      base_query = Ont::Library.resolved_query

      if unassigned_to_flowcells
        base_query = base_query.left_outer_joins(:flowcell).where(ont_flowcells: { id: nil })
      end

      Connections::PaginatedConnectionWrapper.new(base_query,
                                                  page_num: page_num,
                                                  page_size: page_size,
                                                  total_item_count: base_query.all.count)
    end

    # Ont::Runs

    field :ont_run, Types::Outputs::Ont::RunType, 'Find an Ont Run by ID.', null: true do
      argument :id, ID, 'The ID of the Ont Run to find.', required: true
    end

    def ont_run(id:)
      return nil unless Ont::Run.exists?(id)

      Ont::Run.resolved_query.find_by(id: id)
    end

    field :ont_runs, Types::Outputs::Ont::RunType.connection_type, 'Find all Ont Runs by page.',
          null: false do
      # Built in classes add some confusing arguments we don't want to appear in the GraphQL docs
      arguments.reject! { |k, _| %w[first last before after].include? k }
      argument :page_num, Int, 'The page number to return Ont Runs for.', required: false
      argument :page_size, Int, 'The number of Ont Runs to return per page.', required: false
    end

    def ont_runs(page_num: 1, page_size: 10)
      Connections::PaginatedConnectionWrapper.new(Ont::Run.resolved_query,
                                                  page_num: page_num,
                                                  page_size: page_size,
                                                  total_item_count: Ont::Run.all.count)
    end
  end
end
