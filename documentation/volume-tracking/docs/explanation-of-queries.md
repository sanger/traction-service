# An explanation for the queries

This page aims to give a non-technical explanation for the queries outlined in [this page](querying-mlwh.md).

---

- What is the initial volume of a **library** identified by the barcode foo?

    ```sql
    SELECT volume AS initial_volume
    FROM aliquot
    WHERE source_barcode = "foo"  -- Change "foo" to the actual barcode
    AND aliquot_type = "primary"
    AND source_type = "library"
    ORDER BY created_at DESC
    LIMIT 1;
    ```

    This query queries the `aliquot` table for records having the following criteria:

    - `source_barcode` is `foo`.
    - `aliquot_type` is `primary`.
    - `source_type` is `library`.

    In other words, it queries the `aliquot` table for libraries with a certain barcode (`foo`). The `aliquot_type` filter here is applied because we need the **initial volume**. Because this initial volume can be updated, we are retrieving all the records having the above criteria and taking the latest record.

---

- What is the initial volume of a **pool** identified by the barcode foo?

    ```sql
    SELECT volume AS initial_volume
    FROM aliquot
    WHERE source_barcode = "foo"    -- Change "foo" to the actual barcode
    AND aliquot_type = "primary"
    AND source_type = "pool"
    ORDER BY id DESC
    LIMIT 1;
    ```

    Querying for the initial volume of a pool is similar to a library described above. The only parameter change is the `source_type`.

---

- How much of volume left in a **library** identified by the barcode `foo`?

    Overall, the idea is to take the initial volume of a library, and deduct the sum of the volumes of all the derived aliquots from the initial volume of that library (pools and runs created out of that library).

    $$
    V_{remaining} = V_{initial} - \sum^{n}_{i=1} v_i
    $$

    $v_i$ stands for the $i$'th derived aliquot volume from the library.

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

    It is a bit of a complicated query to understand as a whole. However, if we think about the subqueries, it is a bit easier to comprehend.


    The outermost statement is a `SELECT .... AS remaining_volume` statement. The inner query can be separated to two more queries whose results are deducted from the other. Let us take these two queries and investigate them.


    ```sql
    ...
    (SELECT volume 
        FROM aliquot
        WHERE source_barcode = 'foo'    -- Change "foo" to the actual barcode
        AND aliquot_type = 'primary'
        AND source_type = 'library'
        ORDER BY id DESC
    LIMIT 1) 
    ...
    ```

    This has been explained before in a section above, where it queries for the initial volume ($V_{initial}$).

    The second query aims to get the sum of volumes of aliquots derived from the source library.

    ```sql
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
    ```

    Deducting the results coming from these two queries gives the volume remaining for a given library identified by the `source_barcode`.

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

    This query is the same as the query described above, except the `source_type` is given as `pool` as we want to check how much volume left in a pool, rather than in a library.

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

    To identify the volume of a library used by a run, we query the derived aliquots from the library (with the `source_barcode` of the library) and use the `used_by_barcode` parameter as the run's barcode and `used_by_type` as `run`. This essentially means that we want to retrieve derived records of a certain library that are being used by a run. Because the table is populated each time a pool is used on a run, we need to take the latest record.

