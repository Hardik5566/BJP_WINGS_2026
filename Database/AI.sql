
alter view vw_voter_search_AI
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

	

	