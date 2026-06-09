/*
	By :  Hardik Vaghasiya
	Date : 27 Jan, 2026
*/

----------------------------
--------- Copy -------------
----------------------------
CREATE TABLE [dbo].[tbl_app](
	[app_id] [int] NULL,
	[vidhansabha_no] NVARCHAR(100) NULL,
	[vidhansabha_name] NVARCHAR(MAX) NULL,
	[total_voter] [int] NULL,
	[candidate_no] [int] NULL,
	[candidate_name] [nvarchar](500) NULL,
	[party_short_name] [nvarchar](20) NULL,
	[party_full_name] [nvarchar](500) NULL,
	[party_logo_png] [nvarchar](max) NULL,
	[party_logo_jpg] [nvarchar](max) NULL,
	[slip_message] [nvarchar](max) NULL,
	[sms_slip_message] [nvarchar](max) NULL,
	[invitation_message] [nvarchar](max) NULL,
	[offline_status] [int] NULL,
	[offline_db_url] [nvarchar](max) NULL,
	[offline_ver] [nvarchar](50) NULL,
	[splace_url] [nvarchar](max) NULL,
	[app_link] [nvarchar](max) NULL,
	[video_link] [nvarchar](max) NULL,
	[app_ver] [nvarchar](50) NULL,
	[status] [bit] NULL,
	[create_by] [int] NULL,
	[create_date] [datetime] NULL,
	[modify_by] [int] NULL,
	[modify_date] [datetime] NULL,
	[delete_by] [int] NULL,
	[delete_date] [datetime] NULL,
	[popup_status] [int] NULL,
	[popup_url] [varchar](max) NULL
) 


CREATE TABLE module_rights_management (
    id INT PRIMARY KEY identity(1,1),
    app_id INT NOT NULL,               -- Unique ID for the specific Application/Client
    
    call_center  TINYINT DEFAULT 0,    -- 0: No Access, 1: View, 2: Full
    prachar      TINYINT DEFAULT 0,
    aachar_sahita TINYINT DEFAULT 0,
    live_voting  TINYINT DEFAULT 0,
    sleep_send   TINYINT DEFAULT 0,
    meta_wtsp    TINYINT DEFAULT 0,
    AI           TINYINT DEFAULT 0,
	update_date datetime
);

----------------------------
--------- User -------------
----------------------------
CREATE TABLE tbl_user
(
    user_id INT IDENTITY(1,1) PRIMARY KEY,
	app_id int,
    name NVARCHAR(200),
    mobile_no VARCHAR(15),
    user_type VARCHAR(10),
	photo varchar(max),
    booth_no INT NULL,     -- only for Booth Pramukh
	device_id varchar(max),
	temp_status bit,
    status bit,
	create_by int,
	create_date datetime,
	modify_by int,
	modify_date datetime,
	delete_by int,
	delete_date datetime,
	last_login datetime,
	start_voter_no INT NULL,
    end_voter_no   INT NULL
);


----------------------------
--------- User -------------
----------------------------
CREATE TABLE tbl_user_booth
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    booth_no INT NOT NULL,

	status bit,
	create_by int,
	create_date datetime,
	modify_by int,
	modify_date datetime,
	delete_by int,
	delete_date datetime,
);



--------------------------------------
------------ Admin -------------------
--------------------------------------
CREATE TABLE [dbo].[tbl_voting_record]
(
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ac_no] int not null,
	[part_no] int not null,
	[slnoinpart] int not NULL,
	[house_no]  nvarchar(1000) NULL DEFAULT ('-'),
	[eng_house_no] nvarchar(1000) NULL DEFAULT ('-'),
	[localityid] nvarchar(max) NULL DEFAULT ('-'),
	[eng_localityid] nvarchar(max) NULL DEFAULT ('-'),

	[f_name] nvarchar(1000) NULL DEFAULT ('-'),
	[eng_f_name] nvarchar(1000) NULL DEFAULT ('-'),
	
	[f_surname] nvarchar(1000) NULL DEFAULT ('-'),
	[f_eng_surname] nvarchar(1000) NULL DEFAULT ('-'),
	
	[m_name] nvarchar(1000) NULL DEFAULT ('-'),
	[eng_m_name] nvarchar(1000) NULL DEFAULT ('-'),
	
	[surname] nvarchar(1000) NULL DEFAULT ('-'),
	[eng_surname] nvarchar(1000) NULL DEFAULT ('-'),

	[idcard_no] nvarchar(50) NULL DEFAULT ('-'),
	[sex] nvarchar(50) NULL DEFAULT ('-'),
	[age] nvarchar(50) NULL DEFAULT ('-'),
	[contact_no] nvarchar(50) NULL DEFAULT ('-'),
	[polling_location] nvarchar(max) NULL DEFAULT ('-'),
	[eng_polling_location] nvarchar(max) NULL DEFAULT ('-'),

	family_id bigint,
	app_id int not null
)

--------------------------------------
------------ Booth -------------------
--------------------------------------
create table tbl_booth
(
	id int identity(1,1),
	app_id int,
	booth_no int,
	total_voter int
)


--------------------------------------
------------ Booth -------------------
--------------------------------------
create table tbl_address
(
	id int identity(1,1),
	app_id int,
	add_uni nvarchar(max),
	add_eng nvarchar(max),
	total_voter int
)

--------------------------------------
------------ Booth -------------------
--------------------------------------
create table tbl_surname
(
	id int identity(1,1),
	app_id int,
	eng_surname varchar(100),
	total_voter int
)


--------------------------------------
------------ Booth -------------------
--------------------------------------
create table tbl_polling_location
(
	id int identity(1,1),
	app_id int,
	polling_location varchar(max),
	eng_polling_location varchar(1000),
	total_voter int
)

-----------------------------------------------
-------------- Contact Group ------------------
-----------------------------------------------
create table tbl_contact_group
(
	id int identity(1,1),
	app_id int,
	user_id int,
	idcard_no varchar(50),
	mobile_no nvarchar(15),
	create_date datetime
)


-------------------------
---- Polling Location ---
-------------------------
CREATE TABLE tbl_user_phonebook_count
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	app_id int,
	[user_id] [int] NULL,
	[total_voter] [int] NULL
)


-------------------------
---- Polling Location ---
-------------------------
create table tbl_my_group
(
	id int identity(1,1),
	app_id int,
	user_id int,
	idcard varchar(20),
	create_date datetime
)

-------------------------
---- Prachar Material ---
-------------------------
CREATE TABLE tbl_prachar_master
(
    id INT IDENTITY(1,1) PRIMARY KEY,

	app_id int,
    -- Type of content
    prachar_type VARCHAR(20),  
    -- TEXT | IMAGE | VIDEO | AUDIO | SELFIE | SLEEP

    content NVARCHAR(MAX),      
    -- text message OR image path OR audio/video URL

    status BIT DEFAULT 1,

    create_by INT,
    create_date DATETIME DEFAULT GETDATE(),

    modify_by INT NULL,
    modify_date DATETIME NULL,

    delete_by INT NULL,
    delete_date DATETIME NULL
);


-------------------------
---- Surname Group ------
-------------------------
CREATE TABLE tbl_surname_group
(
	group_id      INT IDENTITY(1,1) PRIMARY KEY,
	app_id        INT NOT NULL,
	user_id       INT NOT NULL,
	group_name    NVARCHAR(200) NOT NULL,
	seed_surname  VARCHAR(100) NULL,
	surname_list  VARCHAR(MAX) NULL,
	status        BIT NOT NULL DEFAULT 1,
	create_by     INT NOT NULL,
	create_date   DATETIME NOT NULL DEFAULT GETDATE(),
	modify_by     INT NULL,
	modify_date   DATETIME NULL,
	delete_by     INT NULL,
	delete_date   DATETIME NULL
);

-- Voters in each group (same voter allowed in different groups)
CREATE TABLE tbl_surname_group_member
(
	id           INT IDENTITY(1,1) PRIMARY KEY,
	group_id     INT NOT NULL,
	app_id       INT NOT NULL,
	user_id      INT NOT NULL,
	idcard_no    VARCHAR(50) NOT NULL,
	status       BIT NOT NULL DEFAULT 1,
	create_by    INT NOT NULL,
	create_date  DATETIME NOT NULL DEFAULT GETDATE(),
	modify_by    INT NULL,
	modify_date  DATETIME NULL,
	delete_by    INT NULL,
	delete_date  DATETIME NULL
);

-------------------------
---- Surname book count ---
-------------------------
CREATE TABLE tbl_user_surnamebook_count
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	app_id int,
	[user_id] [int] NULL,
	[total_voter] [int] NULL
)

-------------------------
---- Polling Location ---
-------------------------
CREATE TABLE tbl_log
(
    log_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
    app_id       INT            NOT NULL,
    idcard       VARCHAR(50)    NOT NULL,   -- voter id card
    user_id      INT            NOT NULL,   -- prachar user
    prachar_type VARCHAR(20)    NOT NULL,   -- IMAGE, TEXT, VIDEO, SELFIE, SLEEP, PRINT
    create_date  DATETIME       NOT NULL DEFAULT dbo.get_date()
);

-------------------------
---- Polling Location ---
-------------------------
CREATE TABLE tbl_voter_survey (
    survey_id INT IDENTITY(1,1) PRIMARY KEY,

    -- Voter Info
	app_id int not null,
    voter_idcard VARCHAR(30) NOT NULL,
    booth_no INT NULL,

    -- Survey Person Info
    survey_by INT NOT NULL,
    survey_by_designation VARCHAR(30) NOT NULL,
    survey_date DATETIME NOT NULL DEFAULT dbo.get_date(),

    -- Availability
    voter_available BIT NOT NULL,
    not_available_reason VARCHAR(50) NULL,
    not_available_note NVARCHAR(500) NULL,

    contact_no VARCHAR(20) NULL,
    voter_status VARCHAR(20) NULL,
    note NVARCHAR(MAX) NULL,

    -- Visit Tracking
    visit_count INT NOT NULL DEFAULT 1,
    is_latest BIT NOT NULL DEFAULT 1,

    -- Location
    lat_long VARCHAR(200) NULL,
    visit_location NVARCHAR(500) NULL,

    -- Record Control
    status BIT NOT NULL DEFAULT 1,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date()
);


-- Government Schemes
CREATE TABLE tbl_scheme (
    scheme_id INT IDENTITY PRIMARY KEY,
    scheme_name NVARCHAR(1000),
    is_active BIT DEFAULT 1
);

-- Community
CREATE TABLE tbl_community (
    community_id INT IDENTITY PRIMARY KEY,
    community_name NVARCHAR(100),
    is_active BIT DEFAULT 1
);

-- Caste (depends on Community)
CREATE TABLE tbl_caste (
    caste_id INT IDENTITY PRIMARY KEY,
    caste_name NVARCHAR(100),
    is_active BIT DEFAULT 1
);


----------------------------
---------- Post ------------
----------------------------
CREATE TABLE tbl_Post (
    post_id BIGINT IDENTITY(1,1) PRIMARY KEY,
	app_id int,
    user_id BIGINT,
    content NVARCHAR(MAX),
    share_count INT DEFAULT 0,
	[status] [bit] NULL default 1,
	[create_by] [int] NULL,
	[create_date] [datetime] NULL default dbo.get_date(),
	[modify_by] [int] NULL,
	[modify_date] [datetime] NULL,
	[delete_by] [int] NULL,
	[delete_date] [datetime] NULL
);

----------------------------
---------- Post ------------
----------------------------
CREATE TABLE tbl_PostMedia (
    media_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    post_id BIGINT,                 -- linked to Posts
    media_type NVARCHAR(50),        -- 'image', 'file', 'youtube'
    media_url NVARCHAR(1000),       -- file path or link
    [status] [bit] NULL default 1,
	[create_by] [int] NULL,
	[create_date] [datetime] NULL default dbo.get_date(),
	[modify_by] [int] NULL,
	[modify_date] [datetime] NULL,
	[delete_by] [int] NULL,
	[delete_date] [datetime] NULL
);

----------------------------
---------- Post ------------
----------------------------
CREATE TABLE tbl_wtsp_wallets (
    id INT PRIMARY KEY IDENTITY(1,1),
    app_id INT UNIQUE,           -- Your unique Client App Identifier
    total_messages FLOAT DEFAULT 0, 
    [status] BIT DEFAULT 1,      -- 1 = Active, 0 = Inactive
    [create_by] INT NULL,
    [create_date] DATETIME DEFAULT GETDATE(),
    [modify_by] INT NULL,
    [modify_date] DATETIME NULL,
    [delete_by] INT NULL,
    [delete_date] DATETIME NULL
);

----------------------------
---------- Post ------------
----------------------------
CREATE TABLE tbl_wtsp_user_wallets (
    id INT PRIMARY KEY IDENTITY(1,1),
    app_id INT NOT NULL,           -- Link to the Main Client
    user_id INT NOT NULL,          -- The specific person/sub-user
    
    total_messages FLOAT DEFAULT 0,  -- Messages this specific user can send
    
    [status] BIT DEFAULT 1,      -- 1 = Active, 0 = Inactive
    [create_by] INT NULL,
    [create_date] DATETIME DEFAULT GETDATE(),
    [modify_by] INT NULL,
    [modify_date] DATETIME NULL,
    [delete_by] INT NULL,
    [delete_date] DATETIME NULL
);

----------------------------
---------- Post ------------
----------------------------
CREATE TABLE tbl_wtsp_internal_allocation_logs (
    id INT PRIMARY KEY IDENTITY(1,1),
    app_id INT NOT NULL,           -- The Client App container
    user_id INT NOT NULL,     -- The Main User (Admin) who gave balance
    
    transfer_qty FLOAT NOT NULL,   -- Messages moved
    
    remarks NVARCHAR(500),         -- e.g., "Assigned to Marketing Team"
    
	[status] BIT DEFAULT 1,      -- 1 = Active, 0 = Inactive
    [create_by] INT NULL,
    [create_date] DATETIME DEFAULT GETDATE(),
    [modify_by] INT NULL,
    [modify_date] DATETIME NULL,
    [delete_by] INT NULL,
    [delete_date] DATETIME NULL
);

----------------------------
---------- Post ------------
----------------------------
CREATE TABLE tbl_wtsp_recharge_logs (
    id INT PRIMARY KEY IDENTITY(1,1),
    app_id INT NOT NULL,            -- The Client Account
    
    total_message FLOAT DEFAULT 0,  -- Qty of messages added
    
    -- Financials
    total_amount FLOAT DEFAULT 0,   -- The total bill amount (How much they should pay)
    paid_amount FLOAT DEFAULT 0,    -- How much they have actually paid
    due_amount AS (total_amount - paid_amount), -- SQL Computed Column (Auto-calculates)
    
    is_payment_done BIT DEFAULT 0,  -- 0 = Pending, 1 = Fully Paid
    payment_mode VARCHAR(50),       -- Cash, UPI, Bank Transfer
    
    remarks NVARCHAR(500), 
    
    [status] BIT DEFAULT 1,         -- 1 = Active, 0 = Inactive
    [create_by] INT NULL,
    [create_date] DATETIME DEFAULT GETDATE(),
    [modify_by] INT NULL,
    [modify_date] DATETIME NULL,
    [delete_by] INT NULL,
    [delete_date] DATETIME NULL
);


CREATE TABLE tbl_wtsp_campaign (
    id INT PRIMARY KEY IDENTITY(1,1),
    app_id INT NOT NULL,            -- The Client App container
    user_id INT NOT NULL,           -- The specific user who sent the message
    
    total_message_use int NOT NULL, -- Number of messages deducted
    
    -- Meta API Details
    campaign_id NVARCHAR(100),      -- Optional: ID of the bulk campaign
    remarks NVARCHAR(MAX),          -- The "Note" (e.g., "Bulk Marketing Send")
    
    
    [status] BIT DEFAULT 1,         -- 1 = Active, 0 = Inactive
    [create_by] INT NULL,
    [create_date] DATETIME DEFAULT GETDATE(),
    [modify_by] INT NULL,
    [modify_date] DATETIME NULL,
    [delete_by] INT NULL,
    [delete_date] DATETIME NULL
);


-------------------------
------------ Log --------
-------------------------
create table tbl_offline_user
(
	id int identity(1,1),
	app_id int,
	user_id int,
	start_time datetime,
	end_time datetime
)

-----------------------------------
------ Call Center Survey ---------
-----------------------------------
create table tbl_call_center_survey
(
	survey_id int identity(1,1),
	app_id int,
	voter_idcard varchar(100),
	voter_status varchar(10),
	note nvarchar(max),
	create_by int,
	status bit,
	create_date datetime
)


create table tbl_social_media_link
(
	id int identity(1,1),
	app_id int,
	idcard_no varchar(50),
	fb varchar(max),
	insta varchar(max)
)



--------------------------------------------------------
---------- Popup Alert Master --------------------------
--------------------------------------------------------
CREATE TABLE tbl_PopupAlert (
    popup_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    app_id INT NOT NULL,                        -- ક્યા ક્લાયન્ટ/એપ માટે છે
    user_id BIGINT NOT NULL,                    -- કોણે ક્રિએટ કર્યું છે
    title NVARCHAR(250) NULL,                   -- પોપ-અપનું ટાઈટલ
    content NVARCHAR(MAX) NULL,                 -- પોપ-અપનું મેઈન લખાણ (Text)
    show_status int,
    is_active BIT DEFAULT 1,                    -- ૧ = ચાલુ, ૦ = બંધ (એક સમયે એક જ ૧ રહેશે)
    
    [status] BIT NULL DEFAULT 1,                -- ૧ = એક્ટિવ, ૦ = ડીલીટ
    [create_by] INT NULL,
    [create_date] DATETIME NULL DEFAULT dbo.get_date(),
    [modify_by] INT NULL,
    [modify_date] DATETIME NULL,
    [delete_by] INT NULL,
    [delete_date] DATETIME NULL
);


--------------------------------------------------------
---------- Popup Alert Media (Child) -------------------
--------------------------------------------------------
CREATE TABLE tbl_PopupAlertMedia (
    media_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    popup_id BIGINT NOT NULL,                   -- માસ્ટર ટેબલની FK
    media_type NVARCHAR(50) NOT NULL,           -- 'image', 'youtube', 'drive', 'instagram', 'facebook'
    media_url NVARCHAR(1000) NOT NULL,          -- ઈમેજનો પાથ અથવા વીડિયોની લિંક
    
    [status] BIT NULL DEFAULT 1,                -- ૧ = એક્ટિવ, ૦ = ડીલીટ
    [create_by] INT NULL,
    [create_date] DATETIME NULL DEFAULT dbo.get_date()
);


CREATE TABLE tbl_gov_scheme (
    scheme_id INT IDENTITY PRIMARY KEY,
    scheme_name NVARCHAR(max),
	scheme_short_name NVARCHAR(10),
    is_active BIT DEFAULT 1,
	[status] BIT NULL DEFAULT 1,                -- ૧ = એક્ટિવ, ૦ = ડીલીટ
    [create_by] INT NULL,
    [create_date] DATETIME NULL DEFAULT dbo.get_date(),
    [modify_by] INT NULL,
    [modify_date] DATETIME NULL,
    [delete_by] INT NULL,
    [delete_date] DATETIME NULL
);


CREATE TABLE tbl_scheme_beneficiary (
    id           BIGINT IDENTITY(1,1) PRIMARY KEY,
    app_id       INT         NOT NULL,
    voter_idcard VARCHAR(50) NOT NULL,
    scheme_id    INT         NOT NULL,     -- FK to tbl_scheme.scheme_id
    status       BIT         NOT NULL DEFAULT 1
);


create table tbl_bulk_prachar_enquiry
(
	prachar_id int identity(1,1),
	prachar_type varchar(100),
	ac_no int,
	app_id int,
	total_voter bigint,
	total_mobile_no bigint,
	cost_per_voter float,
	total_cost bigint,
	prachar_status varchar(100),
	payment_status varchar(100),
	create_by int,
	create_date datetime,
	modify_by int,
	modify_date datetime,
	delete_by int,
	delete_date datetime
)
