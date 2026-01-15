# Publishing data
This document describes how to publish aliquot volume tracking data to the MultiLIMS Warehouse (MLWH) `aliquot` table from Traction Service.

The use case for this may be lost data recovery or backfilling data for existing records in MLWH.

## Overview
As seen in the Architectural Overview, Traction Service publishes aliquot volume tracking data to the MultiLIMS Warehouse (MLWH) `aliquot` table using an event messaging queue (EMQ) publisher. This typically happens automatically when an elgible aliquot record is created or updated in Traction Service. However, if there has been data loss or if there is a need to backfill existing records, we can manually trigger the publishing of aliquot data to MLWH.

## Steps to publish data to MLWH
1. **Identify the records to publish**: Determine which aliquot records need to be published or republished to MLWH. This could be based on a specific date range, record IDs, or other criteria.

2. **Run the publishing task**: Use the Rake task provided in Traction Service to publish the identified aliquot records to MLWH. This can be done by executing the following command in the terminal in the given environment:

    ```bash
    bundle exec rails pool_and_library_aliquots:push_data_to_warehouse
    ```

    This command will trigger the publishing process for all eligible aliquot records. If you need to filter records based on specific criteria (e.g., date range), you may need to modify the Rake task accordingly.

3. **Verify the publishing**: After running the Rake task, verify that the aliquot records have been successfully published to MLWH. This can be done by querying the `aliquot` table in MLWH to check for the presence of the published records.

## Modified rake task example
Here is an example of how the Rake task might look after modification to include all publishable aliquots for a given date range. In this case aliquots created or updated on or after October 15, 2025, are published. This can be run manually in the rails console in the given environment.

```ruby
begin
    aliquots = Aliquot.publishable.select do |aliquot|
    aliquot.created_at >= Date.new(2025, 10, 15) || aliquot.updated_at >= Date.new(2025, 10, 15)
    end

    Emq::Publisher.publish(aliquots, Pipelines.pacbio, 'volume_tracking')
    puts '-> Successfully pushed all pool and library aliquots data to the warehouse'
rescue StandardError => e
    Rails.logger.error("Failed to publish message: #{e.message}")
    puts "-> Failed to push aliquots data to the warehouse: #{e.message}"
end
```