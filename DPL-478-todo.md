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
- Validate: when there is a missing qc assay type data
- Validate: when there is missing require lr decision
- Replace `_tbc_` for 'Femto Frag Size'
- Error handling
- Future proof: add other used_by, and more QC Assay Types, and ensure only wanted are created
- JSON API resource which will provide feedback on success or provide errors
- Add documentation
- Validate used_by known?
- If the upload fails then there should be some feedback giving reasons as to why it has failed with an indication of where it has failed
- There should be wiggle room if the use tries to upload previously recorded records. Rather than failing it will just create a new record. The qc results table is idempotent so should not overwrite amend or delete.

* An agreed message format to send the qc results to the warehouse
* A handler to send the message to the warehouse

## Tasks To Do

- Add tests
- Refactor CSV conversion?
- Refactor Validation?
- Check deleting QC Result, what happens/ should happen
- If the upload is successful there should be some feedback indicating that it is a success along with an indication of how many qc results have been created
