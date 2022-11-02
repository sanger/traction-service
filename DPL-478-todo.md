# Notes

## Tasks done

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

## Tasks To Do

- Add `decision_made_by` enum (LR or TOL) to model

- Confirm qc_results table columns for LR and TOL

- Design factory and methods etc

- Expose `status` and `decision_made_by` to QcResultResource, if required?
