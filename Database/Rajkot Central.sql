--------------------------------------
--------- Booth Pramukh --------------
--------------------------------------
--quick_search_from_all_rajkot_ward_sp 0,'hardik vaghasiya'
alter proc quick_search_from_all_rajkot_ward_sp
(
	@app_id INT,
	@search NVARCHAR(200)
)
as
begin
-- Split search string into words
;WITH words AS
(
    SELECT LTRIM(RTRIM(LOWER(value))) AS word
    FROM STRING_SPLIT(@search, ' ')
    WHERE value <> ''
)
SELECT v.id,
	v.ward_no,
	v.app_id,
		v.eng_f_name+' ('+(v.f_name)+')' as eng_f_name,
		v.f_eng_surname+' ('+(v.f_surname)+')' as f_eng_surname,
		v.eng_m_name+' ('+(v.m_name)+')' as eng_m_name,
		v.eng_surname+' ('+(v.surname)+')' as eng_surname,


       v.contact_no,
       v.idcard_no,
       v.eng_house_no,
	   v.part_no,
	   v.[slnoinpart],
	   v.[localityid],
	   v.[eng_localityid]
FROM get_rajkot_data v
WHERE (v.app_id = @app_id or @app_id =0)
  AND NOT EXISTS
    (
      SELECT 1
      FROM words w
      WHERE NOT (
			
            ISNULL(v.eng_f_name,'')    LIKE '%' + w.word + '%'

			
          OR ISNULL(v.f_eng_surname,'') LIKE '%' + w.word + '%'

		  
          OR ISNULL(v.eng_m_name,'')    LIKE '%' + w.word + '%'

		  
          OR ISNULL(v.eng_surname,'')   LIKE '%' + w.word + '%'

          OR ISNULL(v.contact_no,'')    LIKE '%' + w.word + '%'

          OR ISNULL(v.idcard_no,'')    LIKE '%' + w.word + '%'

      )

  );

end
  

  --------------------------------------
------------ Admin -------------------
--------------------------------------
--user_login_sp '9909345328',''
alter proc rajkot_master_admin_login_sp
(
	@mobile_no varchar(15),
	@device_id varchar(max)
)
as
begin

select
	u.user_id,
	u.app_id,
	a.vidhansabha_no,
	a.vidhansabha_name,
	a.total_voter,

	a.candidate_no,
	a.candidate_name,
	a.party_short_name,
	a.party_full_name,
	a.party_logo_png,
	a.party_logo_jpg,

	a.slip_message,
	a.sms_slip_message,

	a.app_link,
	a.app_ver,

	u.name,
	u.mobile_no,
	u.temp_status,

	    
	m.aachar_sahita,
	m.sleep_send   
from
	tbl_user as u
	join tbl_app as a on u.app_id=a.app_id and a.status=1
	join module_rights_management as m on a.app_id=m.app_id
	OUTER APPLY
	(
		SELECT 
			cast(b.booth_no as varchar(10)) + ',' 
		FROM tbl_user_booth AS b
		WHERE b.status = 1 
		  AND b.user_id = u.user_id
		FOR XML PATH('')
	) AS bth(booth)
where
	u.status=1
	and u.mobile_no=@mobile_no
	and u.user_type='A'
	and u.delete_by=0
	and a.vidhansabha_name='Rajkot Municipal Corporation'
order by
	a.vidhansabha_no
end

