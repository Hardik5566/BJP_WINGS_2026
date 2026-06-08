/*
================================================================================
  LIVE VOTING — STORED PROCEDURES
================================================================================
  Objects : dbo.tbl_live_voting, dbo.tt_live_voting_bulk
  Deploy  : After LiveVotingTable.sql (and indexed view script if used)
================================================================================
*/

/*------------------------------------------------------------------------------
  TYPE : dbo.tt_live_voting_bulk
------------------------------------------------------------------------------*/
IF TYPE_ID(N'[dbo].[tt_live_voting_bulk]') IS NULL
BEGIN
    CREATE TYPE [dbo].[tt_live_voting_bulk] AS TABLE
    (
          [app_id]      INT NOT NULL
        , [part_no]     INT NOT NULL
        , [slnoinpart]  INT NOT NULL
    );
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.ins_live_voting_bulk_sp
  INPUT     : @rows (TVP), @created_by optional
  RESULT    : SELECT 'ok' after insert (DataSet.Tables[0] for WebService JSON)
------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[ins_live_voting_bulk_sp]
(
      @rows        [dbo].[tt_live_voting_bulk] READONLY
    , @created_by  INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[tbl_live_voting] ([app_id], [part_no], [slnoinpart], [created_by])
    SELECT
          d.[app_id]
        , d.[part_no]
        , d.[slnoinpart]
        , @created_by
    FROM
    (
        SELECT DISTINCT
              r.[app_id]
            , r.[part_no]
            , r.[slnoinpart]
        FROM @rows AS r
    ) AS d
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [dbo].[tbl_live_voting] AS lv
        WHERE lv.[app_id]     = d.[app_id]
          AND lv.[part_no]    = d.[part_no]
          AND lv.[slnoinpart] = d.[slnoinpart]
    );

    SELECT 'ok';
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.get_LiveVoting_Dashboard_for_admin_sp
  INPUT     : @app_id, @user_id
  RESULT    : Table0 total_voting_count | Table1 total, voting, remain (contact book)
------------------------------------------------------------------------------*/
--[get_LiveVoting_Dashboard_for_admin_sp] 1,1
CREATE OR ALTER PROCEDURE [dbo].[get_LiveVoting_Dashboard_for_admin_sp]
(
    @app_id  INT,
    @user_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS total_voting_count
    FROM dbo.tbl_live_voting WITH (NOLOCK)
    WHERE app_id = @app_id;

    SELECT
        total,
        voting,
        (total - voting) AS remain
    FROM (
        SELECT
            COUNT(DISTINCT cg.idcard_no) AS total,
            COUNT(DISTINCT CASE WHEN voted.idcard_no IS NOT NULL THEN cg.idcard_no END) AS voting
        FROM dbo.tbl_contact_group AS cg WITH (NOLOCK)
        LEFT JOIN (
            SELECT DISTINCT v.idcard_no
            FROM dbo.tbl_voting_record AS v WITH (NOLOCK)
            INNER JOIN dbo.tbl_live_voting AS lv WITH (NOLOCK)
                ON  lv.app_id = v.app_id
                AND lv.part_no = v.part_no
                AND lv.slnoinpart = v.slnoinpart
            WHERE v.app_id = @app_id
              AND ISNULL(v.idcard_no, '') <> ''
        ) AS voted ON voted.idcard_no = cg.idcard_no
        WHERE cg.app_id = @app_id
          AND cg.user_id = @user_id
          AND cg.idcard_no IS NOT NULL
          AND cg.idcard_no <> ''
    ) AS ContactBookLive;
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.dis_booth_wise_voting_report_sp
  INPUT     : @app_id
  RESULT    : booth_no, total_voter, total_voting, total_remain, voting_percent
------------------------------------------------------------------------------*/
--[dis_booth_wise_voting_report_sp] 1
CREATE OR ALTER PROCEDURE [dbo].[dis_booth_wise_voting_report_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        b.booth_no,
        b.total_voter,
        ISNULL(v.total_voting, 0) AS total_voting,
        (b.total_voter - ISNULL(v.total_voting, 0)) AS total_remain,
        CASE
            WHEN b.total_voter > 0
            THEN CAST((ISNULL(v.total_voting, 0) * 100.0) / b.total_voter AS DECIMAL(10, 2))
            ELSE 0.00
        END AS voting_percent
    FROM dbo.tbl_booth AS b
    OUTER APPLY (
        SELECT COUNT(*) AS total_voting
        FROM dbo.tbl_live_voting AS lv
        WHERE lv.app_id  = b.app_id
          AND lv.part_no = b.booth_no
    ) AS v
    WHERE b.app_id = @app_id
    ORDER BY
        b.booth_no;

		select upto_percent,color_code from dbo.fn_voting_percent_color_range()
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.dis_polling_location_wise_voting_report_sp
  INPUT     : @app_id
  RESULT    : eng_polling_location, total_voter, total_voting, total_remain, voting_percent
------------------------------------------------------------------------------*/
--dis_polling_location_wise_voting_report_sp 1
CREATE OR ALTER PROCEDURE [dbo].[dis_polling_location_wise_voting_report_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.eng_polling_location,
        p.total_voter,
        ISNULL(v.total_voting, 0) AS total_voting,
        (p.total_voter - ISNULL(v.total_voting, 0)) AS total_remain,
        CASE
            WHEN p.total_voter > 0
            THEN CAST((ISNULL(v.total_voting, 0) * 100.0) / p.total_voter AS DECIMAL(10, 2))
            ELSE 0.00
        END AS voting_percent
    FROM dbo.tbl_polling_location AS p
    OUTER APPLY (
        SELECT COUNT(*) AS total_voting
        FROM dbo.tbl_live_voting AS lv
        INNER JOIN dbo.tbl_voting_record AS r
            ON  r.app_id     = lv.app_id
            AND r.part_no    = lv.part_no
            AND r.slnoinpart = lv.slnoinpart
        WHERE r.app_id = p.app_id
          AND r.eng_polling_location = p.eng_polling_location
    ) AS v
    WHERE p.app_id = @app_id
    ORDER BY
        p.eng_polling_location;
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.dis_phonebook_wise_voting_report_sp
  INPUT     : @app_id
  RESULT    : per user phonebook: total_phonebook_member, total_voting, remain, %
------------------------------------------------------------------------------*/
--dis_phonebook_wise_voting_report_sp 1
CREATE OR ALTER PROCEDURE [dbo].[dis_phonebook_wise_voting_report_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.user_id,
        u.user_type,
        dbo.fn_get_designation(u.user_type) AS designation,
        u.name,
        u.mobile_no,
        p.total_voter AS total_phonebook_member,
        ISNULL(v.total_voting, 0) AS total_voting,
        (p.total_voter - ISNULL(v.total_voting, 0)) AS total_remain,
        CASE
            WHEN p.total_voter > 0
            THEN CAST((ISNULL(v.total_voting, 0) * 100.0) / p.total_voter AS DECIMAL(10, 2))
            ELSE 0.00
        END AS voting_percent
    FROM dbo.tbl_user AS u
    INNER JOIN dbo.tbl_user_phonebook_count AS p
        ON  p.user_id = u.user_id
        AND p.app_id  = u.app_id
    OUTER APPLY (
        SELECT COUNT(*) AS total_voting
        FROM dbo.tbl_live_voting AS lv
        INNER JOIN dbo.tbl_voting_record AS r
            ON  r.app_id     = lv.app_id
            AND r.part_no    = lv.part_no
            AND r.slnoinpart = lv.slnoinpart
        WHERE lv.app_id = u.app_id
          AND r.idcard_no IN (
              SELECT DISTINCT cg.idcard_no
              FROM dbo.tbl_contact_group AS cg
              WHERE cg.user_id = u.user_id
                AND cg.app_id  = u.app_id
                AND cg.idcard_no IS NOT NULL
                AND cg.idcard_no <> ''
          )
    ) AS v
    WHERE u.status = 1
      AND u.app_id = @app_id
    ORDER BY
        u.name;
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.dis_booth_wise_live_voting_voter_sp
  INPUT     : @app_id, @booth_no
  RESULT    : all booth voters with is_voted, voted_at
------------------------------------------------------------------------------*/
--dis_booth_wise_live_voting_voter_sp 1, 12
CREATE OR ALTER PROCEDURE [dbo].[dis_booth_wise_live_voting_voter_sp]
(
    @app_id   INT,
    @booth_no INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.id,
        r.slnoinpart,
        r.eng_f_name,
        r.f_eng_surname,
        r.eng_m_name,
        r.eng_surname,
        r.part_no,
        r.part_no AS booth_no,
        RIGHT(RTRIM(r.contact_no), 10) AS contact_no,
        r.idcard_no,
        r.sex,
        r.age,
        r.eng_house_no,
        r.eng_localityid,
        r.eng_polling_location,
        CASE WHEN lv.part_no IS NOT NULL THEN 1 ELSE 0 END AS is_voted,
        lv.voted_at
    FROM dbo.tbl_voting_record AS r
    LEFT JOIN dbo.tbl_live_voting AS lv
        ON  lv.app_id     = r.app_id
        AND lv.part_no    = r.part_no
        AND lv.slnoinpart = r.slnoinpart
    WHERE r.app_id  = @app_id
      AND r.part_no = @booth_no
    ORDER BY
        r.slnoinpart;
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.dis_polling_location_wise_live_voting_voter_sp
  INPUT     : @app_id, @polling_location
  RESULT    : all polling-location voters with is_voted, voted_at
------------------------------------------------------------------------------*/
--dis_polling_location_wise_live_voting_voter_sp 1, N'POLLING LOCATION NAME'
CREATE OR ALTER PROCEDURE [dbo].[dis_polling_location_wise_live_voting_voter_sp]
(
    @app_id           INT,
    @polling_location NVARCHAR(max) -- MAX ના બદલે ફિક્સ અથવા ટેબલ કોલમની સાઈઝ પ્રમાણે રાખવું
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.id,
        r.slnoinpart,
        r.eng_f_name,
        r.f_eng_surname,
        r.eng_m_name,
        r.eng_surname,
        r.part_no,
        r.part_no AS booth_no,
        RIGHT(RTRIM(r.contact_no), 10) AS contact_no,
        r.idcard_no,
        r.sex,
        r.age,
        r.eng_house_no,
        r.eng_localityid,
        r.eng_polling_location,
        CASE WHEN lv.part_no IS NOT NULL THEN 1 ELSE 0 END AS is_voted,
        lv.voted_at
    FROM dbo.tbl_voting_record AS r
    LEFT JOIN dbo.tbl_live_voting AS lv
        ON  lv.app_id     = r.app_id
        AND lv.part_no    = r.part_no
        AND lv.slnoinpart = r.slnoinpart
    WHERE r.app_id = @app_id
      AND r.eng_polling_location = @polling_location
    ORDER BY
        r.part_no,
        r.slnoinpart;
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.dis_phonebook_wise_live_voting_voter_sp
  INPUT     : @app_id, @user_id
  RESULT    : phonebook contact voters with is_voted, voted_at
------------------------------------------------------------------------------*/
--dis_phonebook_wise_live_voting_voter_sp 1, 12
CREATE OR ALTER PROCEDURE [dbo].[dis_phonebook_wise_live_voting_voter_sp]
(
    @app_id  INT,
    @user_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.id,
        r.slnoinpart,
        r.eng_f_name,
        r.f_eng_surname,
        r.eng_m_name,
        r.eng_surname,
        r.part_no,
        r.part_no AS booth_no,
        RIGHT(RTRIM(r.contact_no), 10) AS contact_no,
        r.idcard_no,
        r.sex,
        r.age,
        r.eng_house_no,
        r.eng_localityid,
        r.eng_polling_location,
        cg.mobile_no AS contact_book_mobile,
        CASE WHEN lv.part_no IS NOT NULL THEN 1 ELSE 0 END AS is_voted,
        lv.voted_at
    FROM dbo.tbl_contact_group AS cg
    INNER JOIN dbo.tbl_voting_record AS r
        ON  r.idcard_no = cg.idcard_no
        AND r.app_id    = cg.app_id
    LEFT JOIN dbo.tbl_live_voting AS lv
        ON  lv.app_id     = r.app_id
        AND lv.part_no    = r.part_no
        AND lv.slnoinpart = r.slnoinpart
    WHERE cg.app_id  = @app_id
      AND cg.user_id = @user_id
      AND cg.idcard_no IS NOT NULL   -- સર્ગેબલ ફિલ્ટર જે ઇન્ડેક્સ સ્કેન અટકાવશે
      AND cg.idcard_no <> ''
    ORDER BY
        r.part_no,
        r.slnoinpart;
END;
GO