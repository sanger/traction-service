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

- Add `used_by` to `qc_results_upload`

## Tasks To Do

### Factory

- Add `used_by` to Controller/ resource

- Design factory and methods etc
