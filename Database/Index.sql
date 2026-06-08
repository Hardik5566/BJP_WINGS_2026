-----------------------------
------- Master Seaerch ------
-----------------------------
CREATE NONCLUSTERED INDEX [idx_voting_record_search] ON [dbo].[tbl_voting_record]
(
	[eng_f_name] ASC,
	[eng_surname] ASC,
	[eng_m_name] ASC,
	[contact_no] ASC,
	[idcard_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]



CREATE NONCLUSTERED INDEX idx_voting_appid
ON tbl_voting_record(app_id);


CREATE NONCLUSTERED INDEX IX_voting_app_part
ON tbl_voting_record (app_id)
INCLUDE (
    id, slnoinpart, eng_f_name, f_eng_surname, eng_m_name,
    eng_surname, eng_localityid, eng_polling_location,
    idcard_no, contact_no, part_no, eng_house_no
);


CREATE NONCLUSTERED INDEX IX_voting_name
ON tbl_voting_record (app_id, eng_f_name, f_eng_surname, eng_m_name);

----------------- Age Wise Search ------------------
CREATE NONCLUSTERED INDEX idx_age_search_optimized
ON tbl_voting_record (app_id, age, slnoinpart)
INCLUDE (eng_f_name, f_eng_surname, eng_m_name, eng_surname, eng_localityid, eng_polling_location, idcard_no, contact_no, part_no, sex, eng_house_no);

----------------- Show All Surname ------------------
CREATE NONCLUSTERED INDEX idx_surname_app_id 
ON tbl_surname (app_id) 
INCLUDE (eng_surname, total_voter);


----------------- Surname Wise Search ------------------
CREATE NONCLUSTERED INDEX idx_surname_search_opt
ON tbl_voting_record (app_id, eng_surname, slnoinpart)
INCLUDE (eng_f_name, f_eng_surname, eng_m_name, eng_localityid, eng_polling_location, idcard_no, contact_no, part_no, sex, eng_house_no);

----------------- Add Contact Group Member ------------------
CREATE NONCLUSTERED INDEX IX_VoterRecord_App_Contact 
ON [dbo].[tbl_voting_record] ([app_id], [contact_no])
INCLUDE ([idcard_no]);

----------------- Display Contact Group Member ------------------
CREATE NONCLUSTERED INDEX IX_VoterRecord_IDCard_App
ON [dbo].[tbl_voting_record] ([idcard_no], [app_id])
INCLUDE ([id], [slnoinpart], [eng_f_name], [f_eng_surname], [eng_m_name], [eng_surname], 
         [eng_localityid], [eng_polling_location], [contact_no], 
         [part_no],[eng_house_no]);

----------------- Family Find ------------------
CREATE NONCLUSTERED INDEX IX_voting_app_id_id
ON tbl_voting_record (app_id, id);

CREATE NONCLUSTERED INDEX IX_voting_app_family
ON tbl_voting_record (app_id, family_id)
INCLUDE
(
    id,
    ac_no,
    idcard_no,
    part_no,
    slnoinpart,
    f_name,
    f_surname,
    eng_f_name,
    f_eng_surname,
    m_name,
    surname,
    eng_m_name,
    eng_surname,
    sex,
    age,
    polling_location,
    eng_polling_location
);


----------------- Phonebook ------------------
CREATE INDEX IX_contact_group_user
ON tbl_contact_group (app_id, user_id, idcard_no);


----------------- Survey ------------------
CREATE INDEX IX_survey_user_voter
ON tbl_voter_survey (app_id, survey_by, voter_idcard, survey_date DESC)
INCLUDE (voter_available, voter_status, not_available_reason);


-- Admin survey dashboard: one narrow index over current row per voter only (not full history)
CREATE NONCLUSTERED INDEX IX_survey_app_latest_active
ON dbo.tbl_voter_survey (app_id)
INCLUDE (voter_available, voter_status)
WHERE is_latest = 1 AND status = 1;