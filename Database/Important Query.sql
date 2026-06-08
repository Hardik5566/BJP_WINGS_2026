----------------------------------
----- Find Family -------
----------------------------------
DECLARE @ac_no INT = 52;

;WITH cte AS
(
    SELECT
        id,
        ac_no,
        part_no,
        eng_f_name,
        f_eng_surname,
        slnoinpart,

        -- sequence grouping (ONLY by continuity)
        slnoinpart
        - ROW_NUMBER() OVER
        (
            PARTITION BY
                ac_no,
                part_no,
                f_eng_surname
            ORDER BY slnoinpart
        ) AS seq_group
    FROM tbl_voting_record
    WHERE ac_no = @ac_no
)
SELECT
    id,
    ac_no,
    part_no,
    eng_f_name,
    f_eng_surname,
    slnoinpart,
    seq_group,
    DENSE_RANK() OVER
    (
        ORDER BY
            ac_no,
            part_no,
            f_eng_surname,
            seq_group
    ) AS family_id
FROM cte
ORDER BY part_no, slnoinpart;



-----------------------------------
-------- Save Family Id -----------
-----------------------------------
DECLARE @app_id INT = 54;

;WITH cte AS
(
    SELECT
        id,
        ac_no,
        part_no,
        eng_f_name,
        f_eng_surname,
        slnoinpart,
        
        -- sequence grouping (ONLY by continuity)
        slnoinpart
        - ROW_NUMBER() OVER
        (
            PARTITION BY
                ac_no,
                part_no,
                f_eng_surname
            ORDER BY slnoinpart
        ) AS seq_group
    FROM tbl_voting_record
    WHERE app_id =@app_id
),
cte_family AS
(
    SELECT
        id,
        DENSE_RANK() OVER
        (
            ORDER BY
                ac_no,
                part_no,
                f_eng_surname,
                seq_group
        ) AS family_id
    FROM cte
)
UPDATE t
SET t.family_id = c.family_id
FROM tbl_voting_record t
INNER JOIN cte_family c
    ON t.id = c.id
WHERE t.app_id = @app_id;