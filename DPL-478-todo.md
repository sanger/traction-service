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

- Add column `type` to `qc_assay_types` table, which is nullable, type String/enum(values: Long Read Extraction, ToL etc)

## Tasks To Do

### Database changes

- Update column `type` to `qc_assay_types` table, to Enum (values: `Long Read Extraction`, `ToL`)

- Update `qc_results`. Remove `status` and `decision_made_by` columns (possible rollback migration) and remove associated code

- Create new `qc_decisons` table, with `barcode`, `status` and `decision_made_by`. (Is `barcode` needed?). Add model code and tests

- Create new `qc_results_decisons` joining table between `qc_results` and `qc_decisons`. And model code, relationship associations, and tests. 

- Update `qc_results`. Add reference to new `qc_decisons` table (foriegn key)


### Factory

- Design factory and methods etc


