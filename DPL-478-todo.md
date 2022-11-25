# Notes

## Tasks done

### Database changes

- Create Scaffold for qcResultsUpload with field `csv_data`
  `rails g scaffold QcResultsUpload csv_data:text --api --pretend`
- Add column `status` to `qc_results` table, which is nullable, type String
- Add column `decision_recorded_by` to `qc_results` table, which is not nullable(?). Enum with values:
  Long Read
  ToL
- Agree CSV format from UI -> Service
  CSV string
- Add presence validation test for csv_data to QcResultsUpload spec
- Update `lib/tasks/create_qc_assay_types.rake` so key/ label values are up to date, based on Google sheet "DPL-478 - long read QC results heading vs system field name"
- Add column `used_by` to `qc_assay_types` table, to Enum (values: `Long Read Extraction`, `ToL`)
- Create new `qc_decisons` table, with `status` and `decision_made_by`.
- Create new `qc_results_decisons` joining table between `qc_results` and `qc_decisons`.
- Update model code and tests for `qc_result`
- Add model code and tests for `qc_decision`
- And model code, relationship associations, and tests for `qc_results_decison`
- Add `used_by` to `qc_results_upload`, controller and resource
- Design factory and methods etc
- Create Factory logic
- Send CSV string via API, to controller, and pass through to the factory
- Make field constants
- Test factory logic `build` method
- Adding comments to the factory methods
- Test with a tol decision
- Validate: if there are missing headers
- Validate: if there are duplicate headers
- Validate: if there are missing data

## Tasks To Do

- Validate: when there is a missing qc assay type data
- Validate: when there is missing require lr decision
- Dont hard code test data
- Validation to ensure that the qc results are correct
- Replace `_tbc_` for 'Femto Frag Size'
- Check when deleting qc result, what happens
- JSON API resource which will provide feedback on success or provide errors
- Error handling
- Check all CSV columns are unique

- An agreed message format to send the qc results to the warehouse
- A handler to send the message to the warehouse
- modification of qc type column so that it can recognise different label (OPTIONAL - to decide)
- docs

## Docs

when CSV is updated, check:

- LR and TOL DECISION constants in factory
- check assay type rake task
