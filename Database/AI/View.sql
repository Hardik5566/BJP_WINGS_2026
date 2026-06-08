/*
    BJP Wings - AI Reporting Views
    Core tables: tbl_user, tbl_user_booth, tbl_voting_record, tbl_log, tbl_voter_survey
    By: (your team) | For: AskElectionAI - use ONLY these views in AI queries
    Rules: Always filter app_id = @app_id | SELECT only | TOP for lists
*/

-- ============================================================
-- 1) ai_user_booth_flat  (user ↔ booth, one row per assignment)
-- ============================================================

CREATE OR ALTER VIEW dbo.ai_user_booth_flat
AS
    /* Multi-booth users (SP, K, WP, etc.) */
    SELECT
        u.app_id,
        u.user_id,
        u.name        AS user_name,
        u.user_type,
        dbo.fn_get_designation(u.user_type) AS role_name,
        ub.booth_no,
        u.mobile_no,
        u.last_login
    FROM dbo.tbl_user AS u WITH (NOLOCK)
    INNER JOIN dbo.tbl_user_booth AS ub WITH (NOLOCK)
        ON ub.user_id = u.user_id
       AND ub.status = 1
    WHERE u.status = 1

    UNION

    /* Single-booth on user row (BP, BC, VC) */
    SELECT
        u.app_id,
        u.user_id,
        u.name,
        u.user_type,
        dbo.fn_get_designation(u.user_type),
        u.booth_no,
        u.mobile_no,
        u.last_login
    FROM dbo.tbl_user AS u WITH (NOLOCK)
    WHERE u.status = 1
      AND u.booth_no IS NOT NULL
      AND u.user_type IN ('BP', 'BC', 'VC');
GO

-- ============================================================
-- 2) ai_user  (staff list with booth string + login days)
-- ============================================================

CREATE OR ALTER VIEW dbo.ai_user
AS
SELECT
    u.user_id,
    u.app_id,
    u.name,
    u.mobile_no,
    u.user_type,
    dbo.fn_get_designation(u.user_type) AS role_name,
    CASE
        WHEN u.user_type = 'BP' THEN CAST(u.booth_no AS VARCHAR(10))
        ELSE bth.booth_list
    END AS booth_list,
    u.booth_no AS primary_booth_no,   /* BP/BC/VC only */
    u.temp_status,
    u.last_login,
    DATEDIFF(DAY, u.last_login, GETDATE()) AS days_since_login,
    u.start_voter_no,
    u.end_voter_no
FROM dbo.tbl_user AS u WITH (NOLOCK)
OUTER APPLY
(
    SELECT
        CAST(b.booth_no AS VARCHAR(10)) + '|' AS [text()]
    FROM dbo.tbl_user_booth AS b WITH (NOLOCK)
    WHERE b.status = 1
      AND b.user_id = u.user_id
    FOR XML PATH('')
) AS bth(booth_list)
WHERE u.status = 1;
GO

-- ============================================================
-- 3) ai_voter  (voter + slip/sleep flag from tbl_log)
-- ============================================================
CREATE OR ALTER VIEW dbo.ai_voter
AS
SELECT
    r.id,
    r.app_id,
    r.ac_no,
    r.part_no              AS booth_no,
    r.slnoinpart           AS voter_sr_no,
    r.f_name,
    r.eng_f_name,
    r.m_name,
    r.eng_m_name,
    r.surname,
    r.eng_surname,
    r.f_surname,
    r.f_eng_surname,
    (r.f_name + ' ' + ISNULL(r.m_name, '') + ' ' + ISNULL(r.surname, ''))       AS voter_name_gu,
    (r.eng_f_name + ' ' + ISNULL(r.eng_m_name, '') + ' ' + ISNULL(r.eng_surname, '')) AS voter_name_en,
    r.idcard_no,
    r.sex                  AS gender,
    r.age,
    TRY_CONVERT(INT, NULLIF(r.age, '-')) AS age_int,
    r.contact_no,
    r.family_id,
    r.polling_location,
    r.eng_polling_location,
    r.house_no,
    r.localityid,
    CASE WHEN sl.app_id IS NULL THEN 0 ELSE 1 END AS sleep_send,
    sl.last_sleep_send_date,
    ISNULL(sl.sleep_count, 0) AS slip_send_count
FROM dbo.tbl_voting_record AS r WITH (NOLOCK)
LEFT JOIN dbo.vw_get_uniq_sleep_send_date AS sl WITH (NOLOCK)
    ON r.idcard_no = sl.idcard
   AND r.app_id = sl.app_id;
GO

-- ============================================================
-- 4) ai_voter_survey  (voter + latest survey per voter)
--     Use vw_uniq_voter_survey (is_latest = 1)
-- ============================================================
CREATE OR ALTER VIEW dbo.ai_voter_survey
AS
SELECT
    v.id,
    v.app_id,
    v.part_no              AS booth_no,
    v.slnoinpart           AS voter_sr_no,
    v.idcard_no,
    v.f_name,
    v.eng_f_name,
    v.surname,
    v.eng_surname,
    v.age,
    v.sex                  AS gender,
    v.contact_no           AS voter_contact,
    v.family_id,
    s.survey_id,
    s.survey_by,
    su.name                AS survey_by_name,
    su.user_type           AS survey_by_type,
    s.survey_date,
    s.voter_available,
    s.not_available_reason,
    s.voter_status,        /* P=Positive, N=Negative, D=Doubtful, C=Cant Say */
    CASE s.voter_status
        WHEN 'P' THEN N'Positive'
        WHEN 'N' THEN N'Negative'
        WHEN 'D' THEN N'Doubtful'
        WHEN 'C' THEN N'Cant Say'
        ELSE NULL
    END AS voter_status_label,
    s.visit_count,
    s.note                 AS survey_note,
    s.contact_no           AS survey_contact_no
FROM dbo.tbl_voting_record AS v WITH (NOLOCK)
LEFT JOIN dbo.vw_uniq_voter_survey AS s WITH (NOLOCK)
    ON v.idcard_no = s.voter_idcard
   AND v.app_id = s.app_id
LEFT JOIN dbo.tbl_user AS su WITH (NOLOCK)
    ON s.survey_by = su.user_id
   AND su.status = 1;
GO

-- ============================================================
-- 5) ai_user_activity_log  (tbl_log + user + voter booth)
-- ============================================================
CREATE OR ALTER VIEW dbo.ai_user_activity_log
AS
SELECT
    l.log_id,
    l.app_id,
    l.user_id,
    u.name                 AS user_name,
    u.user_type,
    dbo.fn_get_designation(u.user_type) AS role_name,
    l.idcard               AS voter_idcard,
    v.part_no              AS booth_no,
    v.slnoinpart           AS voter_sr_no,
    v.f_name,
    v.eng_f_name,
    v.surname,
    v.eng_surname,
    l.prachar_type,
    l.create_date,
    CAST(l.create_date AS DATE) AS activity_date
FROM dbo.tbl_log AS l WITH (NOLOCK)
INNER JOIN dbo.tbl_user AS u WITH (NOLOCK)
    ON l.user_id = u.user_id
   AND u.status = 1
LEFT JOIN dbo.tbl_voting_record AS v WITH (NOLOCK)
    ON l.idcard = v.idcard_no
   AND l.app_id = v.app_id;
GO

-- ============================================================
-- 6) ai_booth_dashboard  (pre-aggregated booth summary)
-- ============================================================

CREATE OR ALTER VIEW dbo.ai_booth_dashboard
AS
SELECT
    v.app_id,
    v.booth_no,
    COUNT(*)                                                    AS total_voters,
    SUM(CASE WHEN v.sleep_send = 1 THEN 1 ELSE 0 END)          AS slip_sent_count,
    SUM(CASE WHEN v.sleep_send = 0 THEN 1 ELSE 0 END)          AS slip_not_sent_count,
    SUM(CASE WHEN vs.survey_id IS NOT NULL THEN 1 ELSE 0 END)  AS survey_done_count,
    SUM(CASE WHEN vs.survey_id IS NULL THEN 1 ELSE 0 END)      AS survey_pending_count,
    SUM(CASE WHEN vs.voter_status = 'P' THEN 1 ELSE 0 END)    AS positive_count,
    SUM(CASE WHEN vs.voter_status = 'N' THEN 1 ELSE 0 END)    AS negative_count,
    SUM(CASE WHEN vs.voter_status = 'D' THEN 1 ELSE 0 END)    AS doubtful_count,
    SUM(CASE WHEN vs.voter_status = 'C' THEN 1 ELSE 0 END)    AS cant_say_count
FROM dbo.ai_voter AS v WITH (NOLOCK)
LEFT JOIN dbo.vw_uniq_voter_survey AS vs WITH (NOLOCK)
    ON v.idcard_no = vs.voter_idcard
   AND v.app_id = vs.app_id
GROUP BY
    v.app_id,
    v.booth_no;
GO

-- ============================================================
-- 7) ai_vc_voter_range  (Voter Captain serial allocation)
-- ============================================================

CREATE OR ALTER VIEW dbo.ai_vc_voter_range
AS
SELECT
    u.app_id,
    u.user_id,
    u.name                 AS vc_name,
    u.mobile_no,
    u.booth_no,
    v.idcard_no,
    v.slnoinpart           AS voter_sr_no,
    v.f_name,
    v.eng_f_name,
    v.surname,
    v.eng_surname,
    v.age,
    v.sex                  AS gender
FROM dbo.tbl_user AS u WITH (NOLOCK)
INNER JOIN dbo.tbl_voting_record AS v WITH (NOLOCK)
    ON v.app_id = u.app_id
   AND v.part_no = u.booth_no
   AND v.slnoinpart >= u.start_voter_no
   AND v.slnoinpart <= u.end_voter_no
WHERE u.status = 1
  AND u.user_type = 'VC'
  AND u.start_voter_no IS NOT NULL
  AND u.end_voter_no IS NOT NULL
  AND u.end_voter_no >= u.start_voter_no;
GO