use jp2


----------------------------------------------
----- Create Polling Location Blur Print -----
----------------------------------------------
declare @app_id int = 1

insert into tbl_polling_location
select
	@app_id,
	polling_location,
	eng_polling_location,
	COUNT(*)
from
	tbl_voting_record
where
	app_id=@app_id
group by
	polling_location,
	eng_polling_location

-------------------------------
--- Create Polling Location Blur Print ----------
-------------------------------
--truncate table tbl_address
declare @app_id int = 1

insert into tbl_address
select
	@app_id,
	localityid,
	eng_localityid,
	COUNT(*)
from
	tbl_voting_record
where
	app_id=@app_id
	and eng_localityid is not null
group by
	localityid,
	eng_localityid
	

-------------------------------
--- Create Polling Location Blur Print ----------
-------------------------------
--truncate table tbl_booth
declare @app_id int = 1

insert into tbl_booth (app_id,booth_no,total_voter)
select
	@app_id,
	part_no,
	COUNT(*)
from
	tbl_voting_record
where
	app_id=@app_id
group by
	part_no
order by
	cast(part_no as int)
	
	
	

-------------------------------
--- Create Polling Location Blur Print ----------
-------------------------------
--truncate table tbl_surname
declare @app_id int = 1


insert into tbl_surname (app_id,eng_surname,total_voter)
select
	@app_id,
	eng_surname,
	COUNT(*)
from
	tbl_voting_record
where
	app_id=@app_id
	and len(eng_surname)>2
group by
	eng_surname

	
	
	      
	

	