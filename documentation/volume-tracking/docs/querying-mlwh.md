# Querying the Aliquots table

Volume tracking information in MultiLIMS Warehouse are stored in the `aliquot` table. The schema of this table is given below.

<center>

|    **Attribue**   |     **Type**    |
|:-----------------:|:---------------:|
|     `id_lims`     |     `bigint`    |
|   `aliquot_uuid`  |  `varchar(255)` |
|   `aliquot_type`  |  `varchar(255)` |
|   `source_type`   |  `varchar(255)` |
|  `source_barcode` |  `varchar(255)` |
|   `sample_name`   |  `varchar(255)` |
|   `used_by_type`  |  `varchar(255)` |
| `used_by_barcode` |  `varchar(255)` |
|      `volume`     | `decimal(10,2)` |
|  `concentration`  | `decimal(10,2)` |
|   `insert_size`   |      `int`      |
|   `last_updated`  |  `datetime(6)`  |
|   `recorded_at`   |  `datetime(6)`  |
|    `created_at`   |  `datetime(6)`  |

</center>

## Common Queries

Given below are some common SQL queries we think that would be useful for querying the MultiLIMS Warehouse' `aliquot` table.

- What is the initial volume of a **library** identified by the barcode `foo`?

    ```sql
    SELECT volume AS initial_volume
    FROM aliquot
    WHERE source_barcode = "foo"    -- Change "foo" to the actual barcode
    AND aliquot_type = "primary"
    AND source_type = "library";
    ```

- What is the initial volume of a **pool** identified by the barcode `foo`?

    ```sql
    SELECT volume AS initial_volume
    FROM aliquot
    WHERE source_barcode = "foo"    -- Change "foo" to the actual barcode
    AND aliquot_type = "primary"
    AND source_type = "pool";
    ```

- How much of volume left in a **library** identified by the barcode `foo`?

    ```sql
    SELECT 
        (SELECT volume 
        FROM aliquot
        WHERE source_barcode = 'foo'    -- Change "foo" to the actual barcode
        AND aliquot_type = 'primary'
        AND source_type = 'library'
        LIMIT 1) 
        - 
        (SELECT COALESCE(SUM(volume), 0)
        FROM aliquot
        WHERE source_barcode = 'foo'    -- Change "foo" to the actual barcode
        AND aliquot_type = 'derived'
        AND source_type = 'library'
        ) 
    AS remaining_volume;
    ```
