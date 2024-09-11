# frozen_string_literal: true

DEFAULT_WORKFLOWS = [
  {
    workflow: 'Pacbio ULI LP',
    pipeline: 'pacbio',
    options: [
      { stage: 'PreLibrary', code: 'PULPRL' },
      { stage: 'Pre PCR Amplification', code: 'PULPPA' },
      { stage: 'Post Amplification A', code: 'PULPAA' },
      { stage: 'Post Amplification B', code: 'PULPAB' },
      { stage: 'Post Pool pre-Size Selection', code: 'PULPPS' },
      { stage: 'Final Library', code: 'PULSBT' }
    ]
  },
  {
    workflow: 'Pacbio ULI SP',
    pipeline: 'pacbio',
    options: [
      { stage: 'Sheared + 3.1xSPRI', code: 'PUSSHS' },
      { stage: '3.1xSPRI', code: 'PUSSPR' },
      { stage: 'Sheared', code: 'PUSSHR' },
      { stage: 'Excess', code: 'PUSEXC' }
    ]
  },
  {
    workflow: 'Pacbio Standard',
    pipeline: 'pacbio',
    options: [
      { stage: 'Supernatant', code: 'PSSUP' },
      { stage: 'Sheared', code: 'PSSHR' },
      { stage: 'Post SPRI', code: 'PSSPR' },
      { stage: 'Pre-Nuclease', code: 'PSPNU' },
      { stage: 'Pre-Size Selection', code: 'PSPSS' },
      { stage: 'Pre-Norm', code: 'PSPNO' }
    ]
  },
  {
    workflow: 'Extraction',
    pipeline: 'extraction',
    options: [
      { stage: 'Extraction', code: 'EEXT' },
      { stage: 'Post extraction post-SPRI 1 (SPK3)', code: 'ESP1' },
      { stage: 'Sheared', code: 'ESHR' },
      { stage: 'Sheared + SPRI', code: 'ESP2' },
      { stage: 'Supernatant', code: 'ESN1' },
      { stage: 'Supernatant', code: 'ESN2' }
    ]
  },
  {
    workflow: 'Sample QC',
    pipeline: 'sample_qc',
    options: [
      { stage: 'Sheared', code: 'SQCSHR' },
      { stage: 'Sheared + SPRI', code: 'SQCSHS' },
      { stage: 'SPRI', code: 'SQCSPR' },
      { stage: 'PreLib', code: 'SQCPRL' },
      { stage: 'Excess', code: 'SQCEXC' }
    ]
  },
  {
    workflow: 'ONT',
    pipeline: 'ont',
    options: [
      { stage: 'Stock', code: 'OSTK' },
      { stage: 'Sheared', code: 'OSHR' },
      { stage: 'PreLib', code: 'OPRL' },
      { stage: 'End Repaired', code: 'OEND' },
      { stage: 'Final Library', code: 'OFIN' },
      { stage: 'Pool', code: 'OPLX' }
    ]
  },
  {
    workflow: 'HiC',
    pipeline: 'hic',
    options: [
      { stage: 'Excess x-linked', code: 'HXCL' },
      { stage: 'Excess pre library', code: 'HXPL' },
      { stage: 'Excess tissue', code: 'HXTI' }
    ]
  },
  {
    workflow: 'BioNano',
    pipeline: 'bio_nano',
    options: [
      { stage: 'Extraction', code: 'BEXT' },
      { stage: 'Labelling', code: 'BDLE' }
    ]
  }
].freeze

# This Rake task is used to create or update workflows.
#
# Usage:
#   bundle exec rake "workflows:create_or_update[<json_data>]"
#
# Example JSON Data:
# [
#   {
#     "workflow": "Workflow1",
#     "pipeline": "pacbio",
#     "options": [
#       {
#         "stage": "Stage 1",
#         "code": "CODE2"
#       }
#     ]
#   }
# ]
#
# Example Command:
#   bundle exec rake "workflows:create_or_update[[{\"workflow\": \"Workflow1\", \"pipeline\": \"pacbio\", \"options\": [{\"stage\": \"Stage 1\", \"code\": \"CODE2\"}]}]]"
#
# The JSON data should be properly escaped when passed as an argument.
# The task will create or update workflows and their associated steps based on the provided data.
# Note:
#   - Command line arguments are optional. If not provided, the task will use default values given in DEFAULT_WORKFLOWS.
#   - The task will skip duplicate workflows in the given data.
#   - The task will skip workflows with non-existent pipeline values.
#   - The task will skip workflow steps with same 'code' that already exist in another workflow.

namespace :workflows do
  # Description of the task
  desc 'Create or update workflows'
  # Define the task with a JSON data argument
  task :create_or_update, [:json_data] => :environment do |_, args|
    # Parse the JSON data argument or use default data if none is provided
    json_data = args[:json_data]
    workflows_data = json_data ? JSON.parse(json_data).map(&:deep_symbolize_keys) : DEFAULT_WORKFLOWS

    # Set to keep track of processed workflows to ensure uniqueness within the given data
    processed_workflows = Set.new

    # Iterate over each workflow data entry
    workflows_data.each do |workflow_data|
      workflow_name = workflow_data[:workflow]

      # Check for uniqueness in the given workflow data
      # This does not check for uniqueness in the database to allow updating existing workflows
      if processed_workflows.include?(workflow_name)
        puts "Duplicate workflow '#{workflow_name}' found in given data. Skipping."
        next
      end

      # Add the workflow name to the set of processed workflows
      processed_workflows.add(workflow_name)

      # Get the pipeline enum value from the Workflow model
      pipeline_enum_value = Workflow.pipelines[workflow_data[:pipeline]]

      # Skip if the pipeline value doesn't exist
      unless pipeline_enum_value
        puts "Pipeline '#{workflow_data[:pipeline]}' does not exist. Skipping workflow '#{workflow_name}'."
        next
      end

      # Find or create a workflow by name and update the pipeline
      workflow = Workflow.find_or_create_by(name: workflow_name) do |workflow_obj|
        workflow_obj.pipeline = pipeline_enum_value
      end

      puts "Workflow '#{workflow_name}' has been created or updated."

      workflow_data[:options].each do |option|
        # Find or initialize a workflow step by code
        # This allows us to update the workflow step with additional attributes before saving

        workflow_step = WorkflowStep.find_or_initialize_by(code: option[:code])

        # Skip if the workflow step already exists in another workflow. This is to prevent the same code from being used in multiple workflows.
        # The code is not validated for uniqueness in the database so as to allow for updating existing workflow steps.
        if workflow_step.persisted? && workflow_step.workflow != workflow
          puts "Code '#{option[:code]}' already exists in another workflow. Skipping."
          next
        end

        workflow_step.workflow = workflow
        workflow_step.update!(
          stage: option[:stage],
          code: option[:code]
        )
        puts "Workflow step with code '#{option[:code]}' has been created or updated."
      end
    end
  end
end
