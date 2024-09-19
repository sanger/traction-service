# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  describe 'workflows:create_or_update' do
    before do
      Rake::Task['workflows:create_or_update'].reenable
    end

    context 'with default data' do
      before do
        Workflow.delete_all
        WorkflowStep.delete_all
      end

      it 'creates workflows and workflow steps' do
        expect do
          Rake.application.invoke_task('workflows:create_or_update')
        end.to change(Workflow, :count).by(8)
        expect(WorkflowStep.count).to eq(38)
        workflow = Workflow.find_by(name: 'Pacbio ULI LP')
        expect(workflow).not_to be_nil
        expect(workflow.pipeline).to eq('pacbio')

        workflow_step = WorkflowStep.find_by(code: 'PULPRL')
        expect(workflow_step).not_to be_nil
        expect(workflow_step.stage).to eq('PreLibrary')
      end
    end

    context 'with JSON data given as commandline' do
      let(:data) do
        '\[{\"workflow\": \"Workflow1\"\, \"pipeline\": \"pacbio\"\,\"options\":[{\"stage\":\"Stage 1\"\,\"code\":\"CODE1\"}]}\]'
      end

      it 'creates workflows and workflow steps from JSON data' do
        expect do
          Rake.application.invoke_task("workflows:create_or_update[#{data}]")
        end.to change(WorkflowStep, :count).by(1)

        workflow = Workflow.find_by(name: 'Workflow1')
        expect(workflow).not_to be_nil
        expect(workflow.pipeline).to eq('pacbio')

        workflow_step = WorkflowStep.find_by(code: 'CODE1')
        expect(workflow_step).not_to be_nil
        expect(workflow_step.stage).to eq('Stage 1')
      end
    end

    context 'updating existing workflow steps' do
      let(:data) do
        '\[{\"workflow\": \"Pacbio ULI LP\"\, \"pipeline\": \"pacbio\"\,\"options\":[{\"stage\":\"Stage 2\"\,\"code\":\"CODE2\"}]}\]'
      end

      it 'updates existing workflow' do
        expect do
          Rake.application.invoke_task("workflows:create_or_update[#{data}]")
        end.to change(Workflow, :count).by(1)
                                       .and change(WorkflowStep, :count).by(1)
                                                                        .and output(
                                                                          <<~HEREDOC
                                                                            Workflow 'Pacbio ULI LP' has been created or updated.
                                                                            Workflow step with code 'CODE2' has been created or updated.
                                                                          HEREDOC
                                                                        ).to_stdout
        workflow = Workflow.find_by(name: 'Pacbio ULI LP')
        expect(workflow).not_to be_nil
        expect(workflow.workflow_steps).to include(an_object_having_attributes(code: 'CODE2'))
      end
    end

    context 'with duplicate workflows in given data' do
      let(:data) do
        '\[{\"workflow\": \"Workflow1\"\, \"pipeline\": \"pacbio\"\,\"options\":[{\"stage\":\"Stage 1\"\,\"code\":\"CODE1\"}]}\,{\"workflow\": \"Workflow1\"\, \"pipeline\": \"pacbio\"\,\"options\":[{\"stage\":\"Stage 1\"\,\"code\":\"CODE1\"}]}\]'
      end

      it 'outputs the correct message for duplicate workflows' do
        expect do
          Rake.application.invoke_task("workflows:create_or_update[#{data}]")
        end.to output(
          "Workflow 'Workflow1' has been created or updated.\n" \
          "Workflow step with code 'CODE1' has been created or updated.\n" \
          "Duplicate workflow 'Workflow1' found in given data. Skipping.\n"
        ).to_stdout
      end
    end

    context 'with invalid pipeline' do
      let(:data) do
        '\[{\"workflow\": \"Workflow1\"\, \"pipeline\": \"invalid\"\,\"options\":[{\"stage\":\"Stage 1\"\,\"code\":\"CODE1\"}]}\]'
      end

      it 'skips the workflow' do
        expect do
          Rake.application.invoke_task("workflows:create_or_update[#{data}]")
        end.to output("Pipeline 'invalid' does not exist. Skipping workflow 'Workflow1'.\n").to_stdout

        expect { Rake.application.invoke_task("workflows:create_or_update[#{data}]") }.not_to change(Workflow, :count)
        expect { Rake.application.invoke_task("workflows:create_or_update[#{data}]") }.not_to change(WorkflowStep, :count)
      end
    end

    context 'with existing workflow step in another workflow' do
      let(:data) do
        '\[{\"workflow\": \"Workflow1\"\, \"pipeline\": \"pacbio\"\,\"options\":[{\"stage\":\"Stage 1\"\,\"code\":\"CODE1\"}]}\,{\"workflow\": \"Workflow2\"\, \"pipeline\": \"pacbio\"\,\"options\":[{\"stage\":\"Stage 1\"\,\"code\":\"CODE1\"}]}\]'
      end

      it 'skips the workflow step' do
        expect do
          Rake.application.invoke_task("workflows:create_or_update[#{data}]")
        end.to output(
          "Workflow 'Workflow1' has been created or updated.\n" \
          "Workflow step with code 'CODE1' has been created or updated.\n" \
          "Workflow 'Workflow2' has been created or updated.\n" \
          "Code 'CODE1' already exists in another workflow. Skipping.\n"
        ).to_stdout

        expect(WorkflowStep.find_by(code: 'CODE1').workflow.name).to eq('Workflow1')
      end
    end
  end
end
