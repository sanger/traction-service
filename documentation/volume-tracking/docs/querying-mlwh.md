# Querying the Aliquots table

Volume tracking information in MultiLIMS Warehouse are stored in the `aliquot` table. The schema of this table is given below.

!!! note

    MultiLIMS Warehouse is a MySQL database. 
    Therefore, `aliquot` is a relational schema, that adheres to relational database architecture. 
    It contains a primary key `id` (auto incremented) and the attributes are typed with MySQL [standard data types](https://dev.mysql.com/doc/refman/8.4/en/data-types.html).

<center>

| **Attribue**      | **Type**        | **Description**                                          | **Values**                    |
|-------------------|-----------------|----------------------------------------------------------|-------------------------------|
| `id_lims`         | `varchar(255)`  | The LIMS system that the aliquot was created in          | `Traction`                    |
| `aliquot_uuid`    | `varchar(255)`  | The UUID of the aliquot in the LIMS system               |                               |
| `aliquot_type`    | `varchar(255)`  | The type of the aliquot                                  | `primary`, `derived`          |
| `source_type`     | `varchar(255)`  | The type of the source of the aliquot                    | `library`, `pool`, `request`  |     
| `source_barcode`  | `varchar(255)`  | The barcode of the source of the aliquot                 |                               |
| `sample_name`     | `varchar(255)`  | The name of the sample that the aliquot was created from |                               |
| `used_by_type`    | `varchar(255)`  | The type of the entity that the aliquot is used by       | `none`, `run`, `pool`         |
| `used_by_barcode` | `varchar(255)`  | The barcode of the entity that the aliquot is used by    |                               |
| `volume`          | `decimal(10,2)` | The volume of the aliquot ($\mu L$)                      |                               |
| `concentration`   | `decimal(10,2)` | The concentration of the aliquot ($ng/\mu L$)            |                               |
| `insert_size`     | `int`           | The size of the insert in base pairs                     |                               |
| `last_updated`    | `datetime(6)`   | The date and time that the aliquot was last updated      |                               |
| `recorded_at`     | `datetime(6)`   | The date and time that the aliquot was recorded          |                               |
| `created_at`      | `datetime(6)`   | The date and time that the aliquot was created           |                               |

</center>

## Top up Management

One of the main reasons for the volume tracking data is to be able to query whether there is enough library available for resequencing to increase yield to a suitable amount.

### How do I query the warehouse to find out how much library is left?

## Common Queries

Given below are some common SQL queries we think that would be useful for querying the MultiLIMS Warehouse' `aliquot` table.

!!! note

    A non-techinical explanation can be found in this page (WIP).

- What is the initial volume of a **library** identified by the barcode `foo`?

    ```sql
    SELECT volume AS initial_volume
    FROM aliquot
    WHERE source_barcode = "foo"  -- Change "foo" to the actual barcode
    AND aliquot_type = "primary"
    AND source_type = "library"
    ORDER BY id DESC
    LIMIT 1;
    ```

- What is the initial volume of a **pool** identified by the barcode `foo`?

    ```sql
    SELECT volume AS initial_volume
    FROM aliquot
    WHERE source_barcode = "foo"    -- Change "foo" to the actual barcode
    AND aliquot_type = "primary"
    AND source_type = "pool"
    ORDER BY id DESC
    LIMIT 1;
    ```

- How much of volume left in a **library** identified by the barcode `foo`?

    1. Find out the initial volume of the library.
    2. Find out the distinct `used_by_barcode` for the given library.
    3. Within each `used_by_barcode` record, we need to find the latest record
    4. Then, sum the volume of all the latest `used_by_barcode` records.

    ```sql
    SELECT 
        (SELECT volume 
        FROM aliquot
        WHERE source_barcode = 'foo'    -- Change "foo" to the actual barcode
        AND aliquot_type = 'primary'
        AND source_type = 'library'
        ORDER BY id DESC
        LIMIT 1) 
        - 
        (
            SELECT
            SUM(volume)
            FROM
                aliquot a
            INNER JOIN (
                SELECT
                    source_barcode,
                    used_by_barcode,
                    MAX(created_at) AS latest
                FROM
                    aliquot
                WHERE
                    source_barcode = 'foo' AND aliquot_type = 'derived'
                GROUP BY
                    source_barcode, used_by_barcode
            ) b ON a.source_barcode = b.source_barcode
            AND a.used_by_barcode = b.used_by_barcode
            AND a.created_at = b.latest
            WHERE
                a.source_barcode = 'foo' AND a.aliquot_type = 'derived'
        ) 
    AS remaining_volume;
    ```

- How much volume of a **pool** (identified by barcode `foo`) is used in a **run** (identified by barcode `bar`)?

    ```sql
    SELECT volume
    FROM aliquot
    WHERE source_barcode = "foo"    -- Change "foo" to the actual barcode
    AND source_type = "pool"
    AND aliquot_type = "derived"
    AND used_by_type = "run"
    AND used_by_barcode = "bar"     -- Change "bar" to the actual barcode
    ORDER BY created_at DESC 
    LIMIT 1;
    ```

    !!! note

        Note that we use _generated_ barcodes using `sequencing_kit_box_barcode`, the plate number of the plate used for the run and the position of the well. 
        `sequencing_kit_box_barcode` is defined in `Pacbio::Run` relation mentioned in the [ERD](architectural-overview.md#traction-service) e.g format `4438383464646466464646466464:1:A1`.

- How much volume of a **library** (identified by barcode `foo`) is used in a **run** (identified by barcode `bar`)?

    ```sql
    SELECT volume
    FROM aliquot
    WHERE source_barcode = "foo"    -- Change "foo" to the actual barcode
    AND source_type = "library"
    AND aliquot_type = "derived"
    AND used_by_type = "run"
    AND used_by_barcode = "bar"     -- Change "bar" to the actual barcode
    ORDER BY created_at DESC 
    LIMIT 1;
    ```

- How much of volume left in a **pool** identified by the barcode `foo`?

    ```sql
    SELECT 
        (SELECT volume 
        FROM aliquot
        WHERE source_barcode = 'foo'    -- Change "foo" to the actual barcode
        AND aliquot_type = 'primary'
        AND source_type = 'pool'
        ORDER BY id DESC
        LIMIT 1) 
        - 
        (
            SELECT
            SUM(volume)
            FROM
                aliquot a
            INNER JOIN (
                SELECT
                    source_barcode,
                    used_by_barcode,
                    MAX(created_at) AS latest
                FROM
                    aliquot
                WHERE
                    source_barcode = 'foo' AND aliquot_type = 'derived'
                GROUP BY
                    source_barcode, used_by_barcode
            ) b ON a.source_barcode = b.source_barcode
            AND a.used_by_barcode = b.used_by_barcode
            AND a.created_at = b.latest
            WHERE
                a.source_barcode = 'foo' AND a.aliquot_type = 'derived'
        ) 
    AS remaining_volume;
    ```
