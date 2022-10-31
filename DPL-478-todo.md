# Notes

## Tasks done

- Create Scaffold for qcResultsUpload with field `csv_data`
  `rails g scaffold QcResultsUpload csv_data:text --api --pretend`

- Add column `status` to `qc_results` table, which is nullable. Enum with values:
  Pass
  Fail
  Failed Profile
  On Hold ULI
  Review
  NA (control)

- Add column `decision_recorded_by` to `qc_results` table, which is not nullable(?). Enum with values:
  Long Read
  ToL

## Tasks To Do

- Update `lib/tasks/create_qc_assay_types.rake` so key/ label values are up to date, based on Google sheet "DPL-478 - long read QC results heading vs system field name"

- Expose `status` and `decision_made_by` to QcResultResource, if required?

- Add TOL Decision values to enum for `status`? Or change `status` to be a free text string
