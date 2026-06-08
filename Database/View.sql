
alter view vw_get_uniq_sleep_send_date
as
WITH cte AS (
    SELECT
        l.app_id,
        l.idcard,
        l.create_date,
		l.prachar_type,
        ROW_NUMBER() OVER (
            PARTITION BY l.app_id, l.idcard
            ORDER BY l.create_date DESC
        ) AS rn,
        COUNT(*) OVER (
            PARTITION BY l.app_id, l.idcard
        ) AS sleep_count
    FROM tbl_log as l
	join tbl_voting_record as r on r.idcard_no=l.idcard and l.app_id=r.app_id
    WHERE l.prachar_type IN ('SLEEP','SMS SLEEP','PRINT','WEB','W-SLEEP')
	
)
SELECT
    app_id,
    idcard,
	prachar_type,
    FORMAT(create_date, 'dd MMM, yyyy hh:mm tt') AS last_sleep_send_date,
    sleep_count
FROM cte
WHERE rn = 1;




CREATE OR ALTER VIEW vw_get_user_wise_uniq_sleep_send
AS
WITH cte AS (
    SELECT
		l.app_id,
        l.user_id,     -- Changed to use your actual user column
        l.idcard,      
        l.create_date,
        l.prachar_type,
        
        -- Groups by User + Voter, sorts latest date to the top (rn = 1)
        ROW_NUMBER() OVER (
            PARTITION BY l.app_id,l.user_id, l.idcard 
            ORDER BY l.create_date DESC
        ) AS rn,
        
        -- Counts total slips sent by this user to this voter
        COUNT(l.idcard) OVER (
            PARTITION BY l.app_id,l.user_id, l.idcard
        ) AS sleep_count
        
    FROM tbl_log as l
	join tbl_voting_record as r on l.idcard=r.idcard_no and l.app_id=r.app_id
    WHERE l.prachar_type IN ('SLEEP', 'SMS SLEEP', 'PRINT', 'WEB', 'W-SLEEP')
)
SELECT
	app_id,
    user_id,
    idcard,
    prachar_type,
    FORMAT(create_date, 'dd MMM, yyyy hh:mm tt') AS last_sleep_send_date,
    create_date AS raw_send_date,
    sleep_count
FROM cte
WHERE rn = 1;


create view vw_get_all_user
as
SELECT
    u.user_id,
    u.app_id,
    u.name,
    u.mobile_no,
    u.user_type,
    CASE 
        WHEN ISNULL(u.photo, '') = '' 
        THEN '' 
        ELSE dbo.get_server_path() + 'img/admin/' + u.photo 
    END AS photo_path,
    case u.user_type when 'BP' then cast(u.booth_no as varchar(10)) else bth.booth end AS booth_no,
    u.temp_status,
    u.last_login
FROM tbl_user AS u
OUTER APPLY
(
    SELECT 
        cast(b.booth_no as varchar(10)) + '|' 
    FROM tbl_user_booth AS b
    WHERE b.status = 1 
      AND b.user_id = u.user_id
    FOR XML PATH('')
) AS bth(booth)
WHERE u.status = 1;


create view vw_get_all_user_for_AI
as
SELECT
    u.user_id,
    u.app_id,
    u.name,
    u.mobile_no,
    u.user_type,
    CASE 
        WHEN ISNULL(u.photo, '') = '' 
        THEN '' 
        ELSE dbo.get_server_path() + 'img/admin/' + u.photo 
    END AS photo_path,
    case u.user_type when 'BP' then cast(u.booth_no as varchar(10)) else bth.booth end AS booth_no,
    u.temp_status,
    u.last_login
FROM tbl_user AS u
OUTER APPLY
(
    SELECT 
        cast(b.booth_no as varchar(10)) + '|' 
    FROM tbl_user_booth AS b
    WHERE b.status = 1 
      AND b.user_id = u.user_id
    FOR XML PATH('')
) AS bth(booth)
WHERE u.status = 1;



CREATE view [dbo].[vw_voter_search_AI]
as
select
		r.[ac_no]
      ,r.[part_no]
      ,r.[slnoinpart]
      ,r.[house_no]
      ,r.[eng_house_no]
      ,r.[localityid]
      ,r.[eng_localityid]
      ,r.[f_name]
      ,r.[eng_f_name]
      ,r.[f_surname]
      ,r.[f_eng_surname]
      ,r.[m_name]
      ,r.[eng_m_name]
      ,r.[surname]
      ,r.[eng_surname]
      ,r.[idcard_no]
      ,r.[sex]
      ,r.[age]
      ,r.[contact_no]
      ,r.[polling_location]
      ,r.[eng_polling_location]
      ,r.[family_id]
	  ,r.app_id
	  ,case when s.app_id is null then 0 else 1 end as sleep_send
from
	tbl_voting_record as r
	left join vw_get_uniq_sleep_send_date as s on r.idcard_no=s.idcard and r.app_id=s.app_id

	
/* Latest survey per (survey_by, voter_idcard) — user-wise unique among status=1. */
alter VIEW dbo.vw_user_latest_voter_survey
AS
SELECT
      survey_id
    , app_id
    , voter_idcard
    , booth_no
    , survey_by
    , survey_by_designation
    , survey_date
    , voter_available
    , not_available_reason
    , not_available_note
    , contact_no
    , voter_status
    , note
    , visit_count
    , is_latest
    , lat_long
    , visit_location
    , status
    , create_date
FROM
(
    SELECT
          s.survey_id
        , s.app_id
        , s.voter_idcard
        , s.booth_no
        , s.survey_by
        , s.survey_by_designation
        , s.survey_date
        , s.voter_available
        , s.not_available_reason
        , s.not_available_note
        , s.contact_no
        , s.voter_status
        , s.note
        , s.visit_count
        , s.is_latest
        , s.lat_long
        , s.visit_location
        , s.status
        , s.create_date
        , ROW_NUMBER() OVER (
              PARTITION BY s.survey_by, s.voter_idcard
              ORDER BY     s.survey_date DESC, s.survey_id DESC
          ) AS rn
    FROM dbo.tbl_voter_survey AS s
    WHERE s.status = 1
) AS t
WHERE t.rn = 1;



alter VIEW vw_uniq_voter_survey
AS

    SELECT
        s.survey_id,
        s.app_id,
        s.voter_idcard,
        s.booth_no,
        s.survey_by,
        s.survey_by_designation,
        s.survey_date,
        s.voter_available,
        s.not_available_reason,
        s.not_available_note,
        s.contact_no,
        s.voter_status,
        s.note,
        s.visit_count,
        s.is_latest,
        s.lat_long,
        s.visit_location,
        s.status,
        s.create_date
    FROM tbl_voter_survey s
	where s.status=1 and s.is_latest=1


create VIEW dbo.vw_date_wise_latest_voter_survey
AS
SELECT
      survey_id
    , app_id
    , voter_idcard
    , booth_no
    , survey_by
    , survey_by_designation
    , survey_date
    , voter_available
    , not_available_reason
    , not_available_note
    , contact_no
    , voter_status
    , note
    , visit_count
    , is_latest
    , lat_long
    , visit_location
    , status
    , create_date
FROM
(
    SELECT
          s.survey_id
        , s.app_id
        , s.voter_idcard
        , s.booth_no
        , s.survey_by
        , s.survey_by_designation
        , s.survey_date
        , s.voter_available
        , s.not_available_reason
        , s.not_available_note
        , s.contact_no
        , s.voter_status
        , s.note
        , s.visit_count
        , s.is_latest
        , s.lat_long
        , s.visit_location
        , s.status
        , s.create_date
        , ROW_NUMBER() OVER (
              -- ફેરફાર અહીં કર્યો છે: મતદાર અને સર્વેની તારીખ (Time સિવાય) મુજબ ગ્રુપિંગ થશે
              PARTITION BY CAST(s.survey_date AS DATE), s.voter_idcard
              ORDER BY     s.survey_date DESC, s.survey_id DESC
          ) AS rn
    FROM dbo.tbl_voter_survey AS s
    WHERE s.status = 1
) AS t
WHERE t.rn = 1;

create VIEW dbo.vw_date_wise_latest_voter_survey_only_call_center
AS
SELECT
      survey_id
    , app_id
    , voter_idcard
    , booth_no
    , survey_by
    , survey_by_designation
    , survey_date
    , voter_available
    , not_available_reason
    , not_available_note
    , contact_no
    , voter_status
    , note
    , visit_count
    , is_latest
    , lat_long
    , visit_location
    , status
    , create_date
FROM
(
    SELECT
          s.survey_id
        , s.app_id
        , s.voter_idcard
        , s.booth_no
        , s.survey_by
        , s.survey_by_designation
        , s.survey_date
        , s.voter_available
        , s.not_available_reason
        , s.not_available_note
        , s.contact_no
        , s.voter_status
        , s.note
        , s.visit_count
        , s.is_latest
        , s.lat_long
        , s.visit_location
        , s.status
        , s.create_date
        , ROW_NUMBER() OVER (
              -- ફેરફાર અહીં કર્યો છે: મતદાર અને સર્વેની તારીખ (Time સિવાય) મુજબ ગ્રુપિંગ થશે
              PARTITION BY CAST(s.survey_date AS DATE), s.voter_idcard
              ORDER BY     s.survey_date DESC, s.survey_id DESC
          ) AS rn
    FROM dbo.tbl_voter_survey AS s
    WHERE s.status = 1 and s.survey_by_designation='CL'
) AS t
WHERE t.rn = 1;
	
alter view vw_get_wtsp_tranction_log
as
select 
	l.app_id,
	l.user_id,
	l.transfer_qty,
	l.remarks,
	'TR' as [type],
	case  
	when l.transfer_qty>0 then 'Transfer Balance'
	when l.transfer_qty<0 then 'Remove Balance'
	end as title,
	l.create_date
from 
	tbl_wtsp_internal_allocation_logs as l
union all
select 
	c.app_id,
	c.user_id,
	c.total_message_use,
	c.remarks,
	'BC'  as [type],
	'Bulk Campaig' as title,
	c.create_date
from 
	tbl_wtsp_campaign as c
where
	c.status=1


create view vw_booth_wise_sleep_send_count
as
SELECT 
    r.app_id, 
    r.part_no, 
    COUNT(r.idcard_no) AS Total_Voters,
    COUNT(s.idcard) AS Total_Sent_Voters
    
FROM 
    tbl_voting_record AS r
LEFT JOIN 
    vw_get_uniq_sleep_send_date AS s ON r.idcard_no = s.idcard
GROUP BY 
    r.app_id, 
    r.part_no;



-----------------------------------
---- Booth With Total View --------
-----------------------------------
alter view get_call_central_uniq_survey_view
as
select * from (
select 
	row_number() over(partition by s.app_id,s.voter_idcard order by survey_id desc) as sr,
	s.app_id,
	s.survey_id,
	s.voter_idcard,
	r.part_no as booth_no,
	s.voter_status,
	s.note,
	s.create_by,
	s.create_date
from 
	tbl_call_center_survey as s
	join tbl_voting_record as r
on
	s.voter_idcard=r.idcard_no
where
	s.status=1
	and r.idcard_no!=''
)
as tbl where sr=1



-----------------------------------
---- Booth With Total View --------
-----------------------------------
alter view get_rajkot_data
as
select
	a.vidhansabha_no as ward_no,
	r.id,
	r.ac_no,
	r.part_no,
	r.slnoinpart,
	r.house_no,
	r.eng_house_no,
	r.localityid,
	r.eng_localityid,
	r.f_name,
	r.eng_f_name,
	r.f_surname,
	r.f_eng_surname,
	r.m_name,
	r.eng_m_name,
	r.surname,
	r.eng_surname,
	r.idcard_no,
	r.sex,
	r.age,
	r.contact_no,
	r.polling_location,
	r.eng_polling_location,
	r.family_id,
	r.app_id
from
	tbl_voting_record as r
	join tbl_app as a on r.app_id=a.app_id and a.status=1
where
	a.app_id in (1,2,3,7,8,9,10,11,12,13,14,17,18,19,20,21,22,23)


	
