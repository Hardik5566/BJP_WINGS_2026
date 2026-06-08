

--------------------------------------

------------ Admin -------------------

--------------------------------------

alter PROCEDURE [dbo].[dis_all_rajkot_App]

AS

BEGIN

    SET NOCOUNT ON;

    SELECT 

        app_id,

		'Ward No. '+cast(vidhansabha_no as varchar(10)) as ward_no,

        vidhansabha_no,

        vidhansabha_name,

        total_voter,

        candidate_no,

        candidate_name,

        party_short_name,

        party_full_name,

        party_logo_png,

        party_logo_jpg,

        slip_message,

        sms_slip_message,

        invitation_message,

        offline_status,

        offline_db_url,

        offline_ver,

        splace_url,

        app_link,

        video_link,

        app_ver,

        [status],

        popup_status,

        popup_url

    FROM 

        tbl_app -- Assuming your table name is App_Master

    WHERE 

        status=1

		and vidhansabha_name='Rajkot Municipal Corporation'

    ORDER BY 

        vidhansabha_no ASC;

END



--------------------------------------

------------ Admin -------------------

--------------------------------------

create PROCEDURE [dbo].[dis_all_App]

AS

BEGIN

    SET NOCOUNT ON;



    SELECT 

        app_id,

        vidhansabha_no,

        vidhansabha_name,

        total_voter,

        candidate_no,

        candidate_name,

        party_short_name,

        party_full_name,

        party_logo_png,

        party_logo_jpg,

        slip_message,

        sms_slip_message,

        invitation_message,

        offline_status,

        offline_db_url,

        offline_ver,

        splace_url,

        app_link,

        video_link,

        app_ver,

        [status],

        popup_status,

        popup_url

    FROM 

        tbl_app -- Assuming your table name is App_Master

    WHERE 

        status=1

    ORDER BY 

        vidhansabha_no ASC;

END



--------------------------------------

------------ Admin -------------------

--------------------------------------

alter PROCEDURE dis_admin_sp

(

	@app_id int

)

AS

BEGIN

    SET NOCOUNT ON;



    SELECT 

        user_id,

        name,

        mobile_no,

        photo,

		case isnull(photo,'') when '' then '' else dbo.get_server_path()+'img/admin/'+photo end as photo_path,

        booth_no,

        temp_status,

		format(last_login,'dd MMM, yyyy hh:mm tt') as last_login

        

    FROM tbl_user

    WHERE user_type = 'A'

      AND status = 1 

	  and app_id=@app_id

END



--------------------------------------
------------ Admin -------------------
--------------------------------------

ALTER PROCEDURE ins_user_sp
(
    @app_id INT,
    @name NVARCHAR(200),
    @mobile_no VARCHAR(15),
    @user_type VARCHAR(10),
    @booth_no INT = NULL,
    @booth_list VARCHAR(MAX) = NULL,
    @start_voter_no INT = NULL,
    @end_voter_no INT = NULL,
    @create_by INT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @user_id INT;

    -- 1️⃣ Check duplicate mobile
    IF EXISTS (SELECT 1 FROM tbl_user WHERE mobile_no = @mobile_no and user_type=@user_type AND status = 1 AND app_id = @app_id)
    BEGIN
        SELECT 2 AS SuccessCode, 'Mobile number already registered' AS Msg;
        RETURN;
    END

    -- 2️⃣ Special Check for 'BC': Only one BC allowed per booth per app
    IF @user_type = 'BC' AND @booth_no IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM tbl_user WHERE booth_no = @booth_no AND user_type = 'BC' AND status = 1 AND app_id = @app_id)
        BEGIN
            SELECT 3 AS SuccessCode, 'Booth Captaion already exists for this booth' AS Msg;
            RETURN;
        END
    END

    -- 3️⃣ Insert user
    INSERT INTO tbl_user
    (
        app_id, name, mobile_no, user_type, booth_no, temp_status,
        start_voter_no, end_voter_no,
        status, create_by, create_date
    )
    VALUES
    (
        @app_id, @name, @mobile_no, @user_type, @booth_no,
        1,
        CASE WHEN @user_type = 'VC' THEN @start_voter_no ELSE NULL END,
        CASE WHEN @user_type = 'VC' THEN @end_voter_no ELSE NULL END,
        1, @create_by, dbo.get_date()
    );

    SET @user_id = SCOPE_IDENTITY();

    -- 4️⃣ Insert booth mapping
    IF @user_type IN ('SK','CC','LV','SP','CL','WP') AND @booth_list IS NOT NULL
    BEGIN
        INSERT INTO tbl_user_booth (user_id, booth_no, status, create_by, create_date)
        SELECT @user_id, CAST(Item AS INT), 1, @create_by, dbo.get_date()
        FROM dbo.SplitString(@booth_list, ',');
    END

    SELECT 1 AS SuccessCode, 'Inserted successfully' AS Msg;
END


--------------------------------------

------------ Admin -------------------

--------------------------------------

alter PROCEDURE upd_user_sp
(
    @user_id INT,
    @app_id INT,
    @name NVARCHAR(200),
    @mobile_no VARCHAR(15),
    @user_type VARCHAR(10),          -- A, SA, BP, SK, CC, LV
    @booth_no INT = NULL,            -- For BP
    @booth_list VARCHAR(MAX) = NULL, -- For SK, CC, LV
    @start_voter_no INT = NULL,
    @end_voter_no INT = NULL,
    @modify_by INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- 1️⃣ Duplicate mobile check (exclude current user)
        IF EXISTS (
            SELECT 1
            FROM tbl_user
            WHERE mobile_no = @mobile_no
              AND status = 1
              AND app_id=@app_id
              AND user_type=@user_type
              AND user_id <> @user_id
        )
        BEGIN
            ROLLBACK TRAN;
            SELECT -1 AS result; -- duplicate mobile
            RETURN;
        END

        -- 2️⃣ Update main user table
        UPDATE tbl_user
        SET
            name = @name,
            mobile_no = @mobile_no,
            user_type = @user_type,
            booth_no = CASE
                WHEN @user_type IN ('BP', 'BS','VC','BC') THEN ISNULL(@booth_no, booth_no)
                ELSE NULL
            END,
            start_voter_no = CASE WHEN @user_type = 'VC' THEN @start_voter_no ELSE NULL END,
            end_voter_no = CASE WHEN @user_type = 'VC' THEN @end_voter_no ELSE NULL END,
            modify_by = @modify_by,
            modify_date = dbo.get_date()
        WHERE
            user_id = @user_id
            AND app_id = @app_id
            AND status = 1;



        -- 3️⃣ Handle booth mapping for multi-booth users

        IF @user_type IN ('SP','CL','LV','WP')

        BEGIN

            -- Insert new mapping

            IF @booth_list IS NOT NULL AND LEN(@booth_list) > 0

            BEGIN



				UPDATE tbl_user_booth

				SET

					status = 0,

					modify_by = @modify_by,

					modify_date = dbo.get_date()

				WHERE

					user_id = @user_id

					AND status = 1;



                INSERT INTO tbl_user_booth

                (

                    user_id, booth_no, status,

                    create_by, create_date

                )

                SELECT

                    @user_id,

                    CAST(Item AS INT),

                    1,

                    @modify_by,

                    dbo.get_date()

                FROM dbo.SplitString(@booth_list, ',');

            END

        END

        ELSE

        BEGIN

            -- If user changed from multi-booth to BP / A / SA

            UPDATE tbl_user_booth

            SET

                status = 0,

                modify_by = @modify_by,

                modify_date = dbo.get_date()

            WHERE

                user_id = @user_id

                AND status = 1;

        END



        COMMIT TRAN;

        SELECT 1 AS result; -- success



    END TRY

    BEGIN CATCH

        ROLLBACK TRAN;

        SELECT 0 AS result; -- error

    END CATCH

END





--------------------------------------

------------ Admin -------------------

--------------------------------------

-- user_login_sp '9909345328',''

alter proc user_login_sp

(

	@mobile_no varchar(15),

	@device_id varchar(max)

)

as

begin

SET NOCOUNT ON;



update tbl_user set last_login=dbo.get_date(),device_id=@device_id where mobile_no=@mobile_no and status=1



SELECT
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

    a.offline_status,
    a.offline_db_url,
    a.offline_ver,

    dbo.get_server_path() + 'img/splace/' + a.splace_url AS splace_url,
    a.app_link,
    a.video_link,
    a.app_ver,

    u.name,
    u.mobile_no,
    u.user_type,
    u.photo,
    CASE ISNULL(u.photo, '') WHEN '' THEN '' ELSE dbo.get_server_path() + 'img/admin/' + u.photo END AS photo_path,
    CASE WHEN u.user_type in ('BP','BC','BS','VC') THEN CAST(u.booth_no AS VARCHAR(10)) ELSE ISNULL(bth.booth, '') END AS booth_no,
    u.temp_status,

    a.popup_status,
    a.popup_url,

    m.call_center,  
    m.prachar,      
    m.aachar_sahita,
    m.live_voting, 
    m.sleep_send,   
    m.meta_wtsp,   
    m.AI,
    1 as app_close
FROM
    dbo.tbl_user AS u WITH (NOLOCK)
    INNER JOIN dbo.tbl_app AS a WITH (NOLOCK) ON u.app_id = a.app_id AND a.status = 1
    INNER JOIN dbo.module_rights_management AS m WITH (NOLOCK) ON a.app_id = m.app_id
    OUTER APPLY
        (
            -- STRING_AGG વાપરવાથી XML કરતા ૧૦ ગણી ફાસ્ટ સ્પીડ મળશે અને છેલ્લે કોમા (,) પણ નહિ નડે
            SELECT STRING_AGG(CAST(b.booth_no AS VARCHAR(10)), ',') AS booth
            FROM dbo.tbl_user_booth AS b WITH (NOLOCK)
            WHERE b.status = 1 AND b.user_id = u.user_id
        ) AS bth
WHERE
    u.status = 1
	and u.mobile_no=@mobile_no



end



--------------------------------------

------------ Admin -------------------

--------------------------------------
alter proc user_login_for_splace_sp
(

	@app_id int,
	@user_id int,
	@device_id varchar(max)

)

as

begin



SET NOCOUNT ON;



update tbl_user set last_login=dbo.get_date(),device_id=@device_id where app_id=@app_id and user_id=@user_id and status=1

SELECT
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

    a.offline_status,
    a.offline_db_url,
    a.offline_ver,

    dbo.get_server_path() + 'img/splace/' + a.splace_url AS splace_url,
    a.app_link,
    a.video_link,
    a.app_ver,

    u.name,
    u.mobile_no,
    u.user_type,
    u.photo,
    CASE ISNULL(u.photo, '') WHEN '' THEN '' ELSE dbo.get_server_path() + 'img/admin/' + u.photo END AS photo_path,
    
    -- તમારા નવા લોજિક (BP અને BS) મુજબ બૂથ નંબર હેન્ડલિંગ
    CASE 
        WHEN u.user_type IN ('BP','BC', 'BS','VC') THEN CAST(u.booth_no AS VARCHAR(10)) 
        ELSE ISNULL(bth.booth, '') 
    END AS booth_no,
    
    u.temp_status,

    a.popup_status,
    a.popup_url,

    m.call_center,  
    m.prachar,      
    m.aachar_sahita,
    m.live_voting, 
    m.sleep_send,   
    m.meta_wtsp,   
    m.AI,
    1 app_close
FROM
    dbo.tbl_user AS u WITH (NOLOCK)
    INNER JOIN dbo.tbl_app AS a WITH (NOLOCK) ON u.app_id = a.app_id AND a.status = 1
    INNER JOIN dbo.module_rights_management AS m WITH (NOLOCK) ON a.app_id = m.app_id
    OUTER APPLY
        (
            -- XML કરતા STRING_AGG ઘણું ફાસ્ટ ચાલશે અને છેલ્લે આવતો કોમા (,) ઓટોમેટિક હટાવી દેશે
            SELECT STRING_AGG(CAST(b.booth_no AS VARCHAR(10)), ',') AS booth
            FROM dbo.tbl_user_booth AS b WITH (NOLOCK)
            WHERE b.status = 1 AND b.user_id = u.user_id
        ) AS bth
WHERE
    u.status = 1
    AND u.app_id = @app_id   -- આઈડી બેઝ્ડ ફિલ્ટર (ઇન્ડેક્સ સીધું જ હિટ થશે)
    AND u.user_id = @user_id;




	DECLARE @mobile_no VARCHAR(100) = ''

	-- Get the mobile number first

SELECT @mobile_no = mobile_no FROM tbl_user WHERE user_id = @user_id



-- Combined Result

SELECT 

    COUNT(DISTINCT app_id) AS app_count,

    COUNT(CASE WHEN app_id = @app_id THEN user_id END) AS respo_count

FROM 

    tbl_user

WHERE 

    mobile_no = @mobile_no

	and status=1





end





--------------------------------------

------------ Admin -------------------

--------------------------------------

alter PROCEDURE [dbo].[dis_sub_admin_sp]

(

	@app_id int

)



AS

BEGIN

    SET NOCOUNT ON;



    SELECT 

        user_id,

        name,

        mobile_no,

        photo,

		case isnull(photo,'') when '' then '' else dbo.get_server_path()+'img/admin/'+photo end as photo_path,

        booth_no,

        temp_status,

		format(last_login,'dd MMM, yyyy hh:mm tt') as last_login

    FROM tbl_user

    WHERE user_type = 'SA'

      AND status = 1 

	  and app_id=@app_id

END

 

--------------------------------------

------------ Admin -------------------

--------------------------------------

alter PROCEDURE [dbo].[dis_karyakarta_sp]

(

	@app_id int

)

AS

BEGIN

    SET NOCOUNT ON;



    SELECT 

        user_id,

        name,

        mobile_no,

        photo,

		case isnull(photo,'') when '' then '' else dbo.get_server_path()+'img/admin/'+photo end as photo_path,

        booth_no,

        temp_status,

		format(last_login,'dd MMM, yyyy hh:mm tt') as last_login

    FROM tbl_user

    WHERE user_type = 'K'

      AND status = 1 

	  and app_id=@app_id

END

 

--------------------------------------

------------ Admin -------------------

--------------------------------------

alter PROCEDURE [dbo].[dis_saktikendra_sp]

(

	@app_id int

)

AS

BEGIN

    SET NOCOUNT ON;



    

	select 

		u.user_id,

		u.name,

		u.mobile_no,

		u.photo,

		case isnull(photo,'') when '' then '' else dbo.get_server_path()+'img/admin/'+photo end as photo_path,

		b.booth_no,

		format(last_login,'dd MMM, yyyy hh:mm tt') as last_login

	from 

		tbl_user as u

		outer apply

		(

			select

				cast(booth_no as varchar(10))+','

			from

				tbl_user_booth as b where b.user_id=u.user_id and b.status=1 for xml path('')

		) as b(booth_no)

	where

		u.status=1

		and u.user_type='SP'

		and u.app_id=@app_id

END



--------------------------------------
------------ Admin -------------------
--------------------------------------
--dis_party_cadre_dash_sp 1
ALTER PROCEDURE [dbo].[dis_party_cadre_dash_sp]
(
    @app_id INT
)
AS
BEGIN
   SET NOCOUNT ON;

SELECT
    total_shaktikendra,
    total_karyakarta,
    total_booth,
    total_booth_with_pramukh,
    (total_booth - total_booth_with_pramukh) AS remain_booth
FROM (
    SELECT
        -- શક્તિ કેન્દ્ર પ્રમુખ (SP)
        SUM(CASE WHEN u.user_type = 'SP' THEN 1 ELSE 0 END) AS total_shaktikendra,
        
        
        -- કાર્યકર્તા (K)
        SUM(CASE WHEN u.user_type = 'K' THEN 1 ELSE 0 END) AS total_karyakarta,
        
        -- ટોટલ બૂથ (માસ્ટર ટેબલમાંથી)
        (SELECT COUNT(*) FROM dbo.tbl_booth WHERE app_id = @app_id) AS total_booth,
        
        -- યુનિક બૂથ જ્યાં પ્રમુખ (BP) નિમાયેલ છે
        COUNT(DISTINCT CASE WHEN u.user_type = 'BP' AND u.booth_no IS NOT NULL THEN u.booth_no END) AS total_booth_with_pramukh
    FROM 
        dbo.tbl_user AS u
    WHERE 
        u.status = 1
        AND u.app_id = @app_id
) AS DashboardData;
END
GO

--dis_personal_cadre_dash_sp 1
create PROCEDURE [dbo].[dis_personal_cadre_dash_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        total_shaktikendra,
        total_booth,
        total_booth_with_pramukh,
        (total_booth - total_booth_with_pramukh) AS remain_booth
    FROM (
        SELECT
            SUM(CASE WHEN u.user_type = 'WP' THEN 1 ELSE 0 END) AS total_shaktikendra,
            (SELECT COUNT(*) FROM dbo.tbl_booth WHERE app_id = @app_id) AS total_booth,
            COUNT(DISTINCT CASE WHEN u.user_type = 'BC' AND u.booth_no IS NOT NULL THEN u.booth_no END) AS total_booth_with_pramukh
        FROM dbo.tbl_user AS u
        WHERE u.status = 1
          AND u.app_id = @app_id
    ) AS DashboardData;
END
GO




--------------------------------------
------------ Admin -------------------
--------------------------------------
--[dis_war_pramukh_sp] 1
create PROCEDURE [dbo].[dis_war_pramukh_sp]

(

	@app_id int

)

AS

BEGIN

    SET NOCOUNT ON;



    

	select 

		u.user_id,

		u.name,

		u.mobile_no,

		u.photo,

		case isnull(photo,'') when '' then '' else dbo.get_server_path()+'img/admin/'+photo end as photo_path,

		b.booth_no,

		format(last_login,'dd MMM, yyyy hh:mm tt') as last_login

	from 

		tbl_user as u

		outer apply

		(

			select

				cast(booth_no as varchar(10))+','

			from

				tbl_user_booth as b where b.user_id=u.user_id and b.status=1 for xml path('')

		) as b(booth_no)

	where

		u.status=1

		and u.user_type='WP'

		and u.app_id=@app_id

END





--------------------------------------

------------ Admin -------------------

--------------------------------------

create PROCEDURE [dbo].[dis_live_voting_user_sp]

(

	@app_id int

)

AS

BEGIN

    SET NOCOUNT ON;



    

	select 

		u.user_id,

		u.name,

		u.mobile_no,

		u.photo,

		case isnull(photo,'') when '' then '' else dbo.get_server_path()+'img/admin/'+photo end as photo_path,

		b.booth_no,

		format(last_login,'dd MMM, yyyy hh:mm tt') as last_login

	from 

		tbl_user as u

		outer apply

		(

			select

				cast(booth_no as varchar(10))+','

			from

				tbl_user_booth as b where b.user_id=u.user_id and b.status=1 for xml path('')

		) as b(booth_no)

	where

		u.status=1

		and u.user_type='LV'

		and u.app_id=@app_id

END





 --------------------------------------

------------ Admin -------------------

--------------------------------------

alter PROCEDURE [dbo].[dis_call_center_user_sp]

(

	@app_id int

)

AS

BEGIN

    SET NOCOUNT ON;



    

	select 

		u.user_id,

		u.name,

		u.mobile_no,

		u.photo,

		case isnull(photo,'') when '' then '' else dbo.get_server_path()+'img/admin/'+photo end as photo_path,

		b.booth_no,

		format(last_login,'dd MMM, yyyy hh:mm tt') as last_login

	from 

		tbl_user as u

		outer apply

		(

			select

				cast(booth_no as varchar(10))+','

			from

				tbl_user_booth as b where b.user_id=u.user_id and b.status=1 for xml path('')

		) as b(booth_no)

	where

		u.status=1

		and u.user_type='CL'

		and u.app_id=@app_id

END





--------------------------------------

--------- Booth Pramukh --------------

--------------------------------------

--dis_booth_pramukh_and_total_booth_list_sp 3

alter proc dis_booth_pramukh_and_total_booth_list_sp

(

	@app_id INT

)

as

begin



SELECT

    b.booth_no,

    b.total_voter,

    ISNULL(bp.total_booth_pramukh, 0) AS total_booth_pramukh,

	format(last_login,'dd MMM, yyyy hh:mm tt') as last_login

FROM tbl_booth AS b

LEFT JOIN (

    SELECT

        u.booth_no,

		max(u.last_login) as last_login,

        COUNT(*) AS total_booth_pramukh

    FROM tbl_user AS u

    WHERE

        u.status = 1

        AND u.user_type = 'BP'

        AND u.app_id = @app_id

    GROUP BY u.booth_no

) bp ON bp.booth_no = b.booth_no

WHERE

    b.app_id = @app_id

ORDER BY

    b.booth_no;

end



--------------------------------------

--------- Booth Pramukh --------------

--------------------------------------

--sel_user_sp 12,1

ALTER PROCEDURE [dbo].[sel_user_sp]

(

    @user_id INT,

    @app_id INT

)

AS

BEGIN

    SET NOCOUNT ON;



    SELECT

        u.user_id,

        u.app_id,

        u.name,

        u.mobile_no,

        u.user_type,

        u.booth_no,

		u.photo,

		case u.photo when '' then '' else dbo.get_server_path()+'img/admin/'+u.photo end as photo_path,



        -- Multi booth list for edit

        CASE 

            WHEN u.user_type IN ('SP','CL','LV')

            THEN STUFF((

                SELECT ',' + CAST(ub.booth_no AS VARCHAR)

                FROM tbl_user_booth ub

                WHERE ub.user_id = u.user_id

                  AND ub.status = 1

                FOR XML PATH(''), TYPE

            ).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

            ELSE NULL

        END+',' AS booth_list



    FROM tbl_user u

    WHERE

        u.user_id = @user_id

        AND u.app_id = @app_id

        AND u.status = 1;

END



alter proc dis_booth_pramukh_sp

(

	@app_id int

)

as

begin

SELECT

    b.booth_no,

    b.total_voter,

    bp.name,
	bp.mobile_no,
    bp.photo,

	case bp.photo when '' then '' else dbo.get_server_path()+'img/admin/'+bp.photo end as photo_path,

    FORMAT(bp.last_login, 'dd MMM, yyyy hh:mm tt') AS last_login

FROM tbl_booth AS b

OUTER APPLY (

    SELECT TOP 1

        u.name,
		u.mobile_no,
        u.photo,

        u.last_login

    FROM tbl_user AS u

    WHERE u.app_id = @app_id

      AND u.booth_no = b.booth_no

      AND u.status = 1

      AND u.user_type = 'BP'

    ORDER BY u.last_login DESC -- Added DESC to get the most recent login

) AS bp 

WHERE b.app_id = @app_id

ORDER BY b.booth_no;

end



--dis_booth_captain_sp 1
alter proc dis_booth_captain_sp

(

	@app_id int

)

as

begin

SELECT

    b.booth_no,

    b.total_voter,

    bc.name,
	bc.mobile_no,
    bc.photo,

	case bc.photo when '' then '' else dbo.get_server_path()+'img/admin/'+bc.photo end as photo_path,

    FORMAT(bc.last_login, 'dd MMM, yyyy hh:mm tt') AS last_login

FROM tbl_booth AS b

OUTER APPLY (

    SELECT TOP 1

        u.name,
		u.mobile_no,
        u.photo,

        u.last_login

    FROM tbl_user AS u

    WHERE u.app_id = @app_id

      AND u.booth_no = b.booth_no

      AND u.status = 1

      AND u.user_type = 'BC'

    ORDER BY u.last_login DESC

) AS bc 

WHERE b.app_id = @app_id

ORDER BY b.booth_no;

end





--------------------------------------

--------- Booth Pramukh --------------

--------------------------------------
dis_total_booth_sp 1
alter proc dis_total_booth_sp

(

	@app_id int

)

as

begin

select

	app_id,

	booth_no,

	total_voter,

	0 as allocated

from

	tbl_booth

where

	app_id=@app_id

end





--------------------------------------

--------- Booth Pramukh --------------

--------------------------------------

create proc dlt_user_sp

(

	@user_id int,

	@delete_by int

)

as

begin

	update tbl_user

	set

		status=0,

		delete_by=@delete_by,

		delete_date=dbo.get_date()

	where

		user_id=@user_id



	update tbl_user_booth

	set

		status=0,

		delete_by=@delete_by,

		delete_date=dbo.get_date()

	where

		user_id=@user_id



	select 'ok'

end



--------------------------------------

--------- Booth Pramukh --------------

--------------------------------------

alter proc dis_booth_list_for_sakti_creation_sp

(

	@app_id INT,
	@user_type varchar(50)

)

as

begin

SELECT

    bh.booth_no,

    bh.total_voter,

    CASE 

        WHEN ub.booth_no IS NOT NULL THEN 1 

        ELSE 0 

    END AS is_assigned

FROM tbl_booth bh

LEFT JOIN (

    SELECT DISTINCT b.booth_no

    FROM tbl_user u

    JOIN tbl_user_booth b 

        ON u.user_id = b.user_id

       AND b.status = 1

	   and u.user_type=@user_type

    WHERE u.app_id = @app_id

      AND u.status = 1

) ub 

    ON ub.booth_no = bh.booth_no

WHERE bh.app_id = @app_id order by bh.booth_no;

end





--------------------------------------

--------- Booth Pramukh --------------

--------------------------------------

--speack_and_search_sp 1,'hard shar pat'

alter proc speak_and_search_sp

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

FROM tbl_voting_record v

WHERE v.app_id = @app_id

  AND NOT EXISTS

    (

      SELECT 1

      FROM words w

      WHERE NOT (

			ISNULL(v.f_name,'')          LIKE N'%' + w.word + N'%'

             or ISNULL(v.eng_f_name,'')    LIKE '%' + w.word + '%'



			 or ISNULL(v.f_surname,'')          LIKE N'%' + w.word + N'%'

          OR ISNULL(v.f_eng_surname,'') LIKE '%' + w.word + '%'



		  or ISNULL(v.m_name,'')          LIKE N'%' + w.word + N'%'

          OR ISNULL(v.eng_m_name,'')    LIKE '%' + w.word + '%'



		  or ISNULL(v.surname,'')          LIKE N'%' + w.word + N'%'

          OR ISNULL(v.eng_surname,'')   LIKE '%' + w.word + '%'



          OR ISNULL(v.contact_no,'')    LIKE '%' + w.word + '%'



          OR ISNULL(v.idcard_no,'')    LIKE '%' + w.word + '%'



          OR ISNULL(v.eng_house_no,'')  LIKE '%' + w.word + '%'



      )



  );



end

  

 

--------------------------------------------------------

------------------- Master Search ----------------------

--------------------------------------------------------

--master_search_sp 1,'priya','','','',''

alter PROC master_search_sp

(

    @app_id int,

    @f_name nvarchar(500),

    @m_name nvarchar(500),

    @surname nvarchar(500),

    @mobile_no nvarchar(500),

    @id_card_no nvarchar(500)

)

AS

BEGIN

    SET NOCOUNT ON;



	 -- 🔹 Trim all input parameters (ISNULL: C# may send DBNull for empty optional filters)

    SET @f_name     = ISNULL(LTRIM(RTRIM(@f_name)), N'');

    SET @m_name     = ISNULL(LTRIM(RTRIM(@m_name)), N'');

    SET @surname    = ISNULL(LTRIM(RTRIM(@surname)), N'');

    SET @mobile_no  = ISNULL(LTRIM(RTRIM(@mobile_no)), N'');

    SET @id_card_no = ISNULL(LTRIM(RTRIM(@id_card_no)), N'');



    SELECT

        id,

        slnoinpart,

		eng_f_name+' ('+(f_name)+')' as eng_f_name,

		f_eng_surname+' ('+(f_surname)+')' as f_eng_surname,

		eng_m_name+' ('+(m_name)+')' as eng_m_name,

		eng_surname+' ('+(surname)+')' as eng_surname,

        eng_localityid,

        eng_polling_location,

        idcard_no,

        RIGHT(contact_no, 10) AS contact_no,

        part_no,

        eng_house_no

    FROM 

        tbl_voting_record 

    WHERE

        app_id = @app_id

        -- Use prefix matching if possible for speed: @f_name + '%'

        AND (@f_name = '' OR (eng_f_name LIKE '%' + @f_name + '%' OR f_name LIKE N'%' + @f_name + N'%'))

        AND (@surname = '' OR f_eng_surname LIKE '%'+@surname + '%')

        AND (@m_name = '' OR eng_m_name LIKE '%'+@m_name + '%')

        AND (@mobile_no = '' OR contact_no LIKE '%' + @mobile_no + '%')

        AND (@id_card_no = '' OR idcard_no = @id_card_no)

END





--------------------------------------------------------

------------------- Master Search ----------------------

--------------------------------------------------------

alter proc scan_and_search_sp

(

	@app_id int,

	@id_card_no nvarchar(500)

)

as

begin

	select

		id,

		(N'भाग - '+cast(v.part_no as varchar(10))+N'    क्रमांक - '+cast(v.slnoinpart as varchar(10))) as first_detail,

		N'नाम :'+(isnull(v.f_name,'')+' '+isnull(v.f_surname,''))+' ('+(isnull(v.eng_f_name,'')+' '+isnull(v.f_eng_surname,''))+')'as full_name,

		N'पिता/पति : '+isnull(v.m_name,'')+''+isnull(v.surname,'')+' ('+isnull(v.eng_m_name,'')+' '+isnull(v.eng_surname,'')+')' as middle_name,

		N'जाति/आयु : '+(case v.sex when 'M' Then N'पुरुष' when 'F' then  N'स्री' end+'/'+v.age) as sex_age,

		(N'वोटर आईडी नंबर : '+isnull(v.idcard_no,'-')) as idcard_no,

		N'मतदान स्थल : '+v.polling_location	 as polling_location,

		right(contact_no,10) as contact_no

	from 

		tbl_voting_record as v

	where

		idcard_no=@id_card_no

		and app_id=@app_id





	select

		dbo.get_server_path()+'/img/prachar/'+content as img

	from

		tbl_prachar_master

	where

		status=1

		and app_id=@app_id

		and prachar_type='SLEEP'



end







-----------------------------------------------

------ Age Wise and Booth Wise Search ---------

-----------------------------------------------

--age_wise_search_sp 1,30,35

ALTER PROC age_wise_search_sp
(
    @app_id INT,
    @from_age INT,
    @to_age INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  
        id,
        slnoinpart,
        ISNULL(eng_f_name, '') + ' (' + ISNULL(f_name, '') + ')' as eng_f_name,
        ISNULL(f_eng_surname, '') + ' (' + ISNULL(f_surname, '') + ')' as f_eng_surname,
        ISNULL(eng_m_name, '') + ' (' + ISNULL(m_name, '') + ')' as eng_m_name,
        ISNULL(eng_surname, '') + ' (' + ISNULL(surname, '') + ')' as eng_surname,
        eng_localityid,
        eng_polling_location,
        idcard_no,
        -- Force string handling here
        CAST(RIGHT(contact_no, 10) AS VARCHAR(20)) AS contact_no,
        part_no,
        sex,
        eng_house_no
    FROM 
        tbl_voting_record
    WHERE
        -- Safely handle app_id matching
        app_id = @app_id
        -- Ensure age conversion doesn't break if age column has weird data
        AND TRY_CAST(age AS INT) >= @from_age 
        AND TRY_CAST(age AS INT) <= @to_age
    ORDER BY
        slnoinpart
    OPTION (RECOMPILE); 
END



-----------------------------------------------

------ Age Wise and Booth Wise Search ---------

-----------------------------------------------

ALTER PROC dis_all_surname_sp

(

    @app_id INT

)

AS

BEGIN

    SET NOCOUNT ON; -- બિનજરૂરી મેસેજીસ બંધ કરવા માટે



    SELECT

        eng_surname AS surname,

        total_voter

    FROM

        tbl_surname WITH (NOLOCK) -- રીડિંગ ફાસ્ટ કરવા અને લોકીંગ ટાળવા માટે

    WHERE

        app_id = @app_id

    ORDER BY 

        total_voter DESC; -- સામાન્ય રીતે વધારે વોટરવાળી અટક પહેલા બતાવવી ઉપયોગી રહે છે

END







-----------------------------------------------

--------- Surname Wise Search -----------------

-----------------------------------------------

--surname_wise_search_sp 1,'PATIL,SHENDE,MESHRAM,RAUT,JOSHI,DESHMUKH,YADAV,'

alter proc surname_wise_search_sp

(

	@app_id int,

	@surname_list nvarchar(max)

)

as

begin	

	select  

		id,

		slnoinpart,

		eng_f_name,

		f_eng_surname,

		eng_m_name,

		eng_surname,

		eng_localityid,

		eng_polling_location,

		idcard_no,

		right(contact_no,10) as contact_no,

		part_no,

		sex,

		eng_house_no

	from 

		tbl_voting_record  WITH (NOLOCK)

	where

		app_id=@app_id

		and eng_surname in (select rtrim(ltrim(Item)) from SplitString(@surname_list,','))

	order by

		slnoinpart

end









---------------------------------

---- Get All Polling Location ---

---------------------------------

alter proc dis_all_polling_location_sp

(

	@app_id int

)

as

begin

	select eng_polling_location,total_voter from tbl_polling_location where app_id=@app_id

end







--------------------------------------

------- Display Booth Wise Voter -----

--------------------------------------

--dis_polling_location_wise_voter_sp 'BHARAT RATNALNDIRA GANDHI VIDYA MANDIR, ROOM NO 81, VEER SAVARKAR NAGAR,GR.FIR. THANE, 400604'

create proc dis_polling_location_wise_voter_sp

(

	@app_id int,

	@polling_location nvarchar(max)

)

as

begin

	select 

		r.id,

		r.eng_f_name,

		r.f_eng_surname,

		r.eng_m_name,

		r.eng_surname,

		r.part_no,

		r.eng_localityid,

		r.part_no as booth_no,

		right(r.contact_no,10) as contact_no,

		r.idcard_no,

		r.slnoinpart,

		r.eng_polling_location,

		r.sex,

		r.eng_house_no

	from 

		tbl_voting_record as r

	where

		eng_polling_location=@polling_location

	order by

		slnoinpart

end





--------------------------------------------------------

------------------- Master Search ----------------------

--------------------------------------------------------

--dis_booth_wise_search_sp 3,5

alter proc dis_booth_wise_search_sp

(

	@app_id int,

	@booth_no int

)

as

begin

	select

		r.id,

		r.slnoinpart,

		r.eng_f_name+' ('+(f_name)+')' as eng_f_name,

		r.f_eng_surname+' ('+(f_surname)+')' as f_eng_surname,

		r.eng_m_name+' ('+(m_name)+')' as eng_m_name,

		r.eng_surname+' ('+(surname)+')' as eng_surname,

		r.eng_localityid,

		r.eng_polling_location,

		r.idcard_no,

		r.sex+'/'+r.age as sex_age,

		right(r.contact_no,10) as contact_no,

		r.part_no,

		r.eng_house_no

	from 

		tbl_voting_record as r

	where

		r.part_no=@booth_no

		and r.app_id=@app_id

	order by

		r.slnoinpart

end





--------------------------------------------------------

------------------- Master Search ----------------------

--------------------------------------------------------

--dis_booth_wise_voter_for_bulk_sleep_send_sp 1,3,5

alter proc dis_booth_wise_voter_for_bulk_sleep_send_sp

(

	@user_id int,

	@app_id int,

	@booth_no int

)

as

begin



	DECLARE @GeneratedID NVARCHAR(100)=''

    EXEC sp_ins_wtsp_campaign @app_id, @user_id, 'Bulk Send', @user_id -- This inserts into tbl_wtsp_campaign

    

    -- 2. Fetch the ID we just made

    select @GeneratedID = campaign_id FROM tbl_wtsp_campaign WHERE id = SCOPE_IDENTITY()

	

	select

		r.id,

		r.slnoinpart,

		r.f_name,

		r.f_surname,

		r.m_name,

		r.surname,

		r.eng_localityid,

		r.eng_polling_location,

		r.idcard_no,

		r.sex+'/'+r.age as sex_age,

		right(r.contact_no,10) as contact_no,

		r.part_no,

		r.eng_house_no,

		r.polling_location

	from 

		tbl_voting_record as r

	where

		r.part_no=@booth_no

		and r.app_id=@app_id

		and r.slnoinpart between 501 and 800

		and len(r.contact_no)>9

	order by

		r.slnoinpart

end



--------------------------------------

---- Display Sakti Pramukh Cadre -----

--------------------------------------

--dis_booth_pramukh_cadre_with_voter_sp 1,1

alter proc dis_booth_pramukh_cadre_with_voter_sp

(

	@app_id int,

	@booth_no int

)

as

begin



-- Query 1: Optimized

SELECT

    u.user_id,

    u.[user_type],

	u.booth_no,

    dbo.fn_get_designation(u.[user_type]) AS designation,

    u.name,

    u.mobile_no,

    COALESCE(u.photo, '') AS photo,

	isnull(format(u.last_login,'dd MMM, yyyy hh:mm tt'),'') as last_login,

    CASE WHEN u.photo = '' THEN '' ELSE dbo.get_server_path() + 'img/admin/' + u.photo END AS photo_path

FROM

    tbl_user AS u

WHERE

    u.booth_no = @booth_no

    AND u.status = 1

    AND (u.[user_type] = 'BP' or u.[user_type]='BS')

	and u.app_id=@app_id



-- Query 2: Optimized

select

	r.id,

    r.f_name as eng_f_name,

    r.f_surname as f_eng_surname,

    r.m_name as eng_m_name,

    r.surname as eng_surname,

    r.part_no,

    r.eng_localityid,

    r.part_no AS booth_no,

    RIGHT(r.contact_no, 10) AS contact_no,

    r.idcard_no,

    r.slnoinpart,

    r.eng_polling_location,

    r.sex,

    r.age,

    r.eng_house_no,

	s.voter_available,

	s.voter_status,

	s.not_available_reason

from

	tbl_voting_record as r

	left join tbl_voter_survey as s on r.idcard_no=s.voter_idcard and s.status=1 and s.is_latest=1

where

	r.part_no=@booth_no

	and r.app_id=@app_id

order by

	r.slnoinpart

end



--dis_booth_captain_cadre_with_voter_sp 1,1

create proc dis_booth_captain_cadre_with_voter_sp

(

	@app_id int,

	@booth_no int

)

as

begin



-- Query 1: Booth Captain cadre (BC, Voter Captain VC)

SELECT

    u.user_id,

    u.[user_type],

	u.booth_no,

    dbo.fn_get_designation(u.[user_type]) AS designation,

    u.name,

    u.mobile_no,

    COALESCE(u.photo, '') AS photo,

	isnull(format(u.last_login,'dd MMM, yyyy hh:mm tt'),'') as last_login,

    CASE WHEN u.photo = '' THEN '' ELSE dbo.get_server_path() + 'img/admin/' + u.photo END AS photo_path,

	u.start_voter_no,

	u.end_voter_no,

	CASE

	    WHEN u.user_type = 'VC' AND u.start_voter_no IS NOT NULL AND u.end_voter_no IS NOT NULL AND u.end_voter_no >= u.start_voter_no

	        THEN u.end_voter_no - u.start_voter_no + 1

	    WHEN u.user_type = 'BC'

	        THEN b.total_voter

	    ELSE NULL

	END AS voters_allocated

FROM

    tbl_user AS u

LEFT JOIN tbl_booth AS b ON b.booth_no = u.booth_no AND b.app_id = @app_id

WHERE

    u.booth_no = @booth_no

    AND u.status = 1

    AND (u.[user_type] = 'BC' OR u.[user_type] = 'VC')

	and u.app_id=@app_id



-- Query 2: same voter list as booth pramukh view

select

	r.id,

    r.f_name as eng_f_name,

    r.f_surname as f_eng_surname,

    r.m_name as eng_m_name,

    r.surname as eng_surname,

    r.part_no,

    r.eng_localityid,

    r.part_no AS booth_no,

    RIGHT(r.contact_no, 10) AS contact_no,

    r.idcard_no,

    r.slnoinpart,

    r.eng_polling_location,

    r.sex,

    r.age,

    r.eng_house_no,

	s.voter_available,

	s.voter_status,

	s.not_available_reason

from

	tbl_voting_record as r

	left join tbl_voter_survey as s on r.idcard_no=s.voter_idcard and s.status=1 and s.is_latest=1

where

	r.part_no=@booth_no

	and r.app_id=@app_id

order by

	r.slnoinpart

	

end


--dis_booth_captain_cadre_with_voter_sp 1,1

CREATE OR ALTER PROCEDURE dbo.dis_booth_captain_cadre_sp
(
    @app_id INT,
    @booth_no INT
)
AS
BEGIN
    SET NOCOUNT ON; -- બિનજરૂરી મેસેજીસ બંધ કરીને એક્ઝિક્યુશન ફાસ્ટ કરશે

    -- Query 1: Booth Captain cadre (BC) and Voter Captain (VC)
    SELECT
        u.user_id,
        u.[user_type],
        u.booth_no,
        dbo.fn_get_designation(u.[user_type]) AS designation,
        u.name,
        u.mobile_no,
        ISNULL(u.photo, '') AS photo,
        ISNULL(FORMAT(u.last_login, 'dd MMM, yyyy hh:mm tt'), '') AS last_login,
        CASE 
            WHEN ISNULL(u.photo, '') = '' THEN '' 
            ELSE dbo.get_server_path() + 'img/admin/' + u.photo 
        END AS photo_path,
        u.start_voter_no,
        u.end_voter_no,
        
        -- એલોકેટેડ વોટર્સની ગણતરી (VC માટે રેન્જ અને BC માટે ટોટલ બૂથ વોટર્સ)
        CASE
            WHEN u.user_type = 'VC' AND u.start_voter_no IS NOT NULL AND u.end_voter_no IS NOT NULL AND u.end_voter_no >= u.start_voter_no
                THEN (u.end_voter_no - u.start_voter_no) + 1
            WHEN u.user_type = 'BC'
                THEN b.total_voter
            ELSE NULL
        END AS voters_allocated
    FROM
        dbo.tbl_user AS u WITH (NOLOCK)
        LEFT JOIN dbo.tbl_booth AS b WITH (NOLOCK) ON b.booth_no = u.booth_no AND b.app_id = @app_id
    WHERE
        u.app_id = @app_id            -- ઇન્ડેક્સ માટે એપ આઈડી પહેલા ફિલ્ટર થશે
        AND u.booth_no = @booth_no    -- બૂથ નંબર ફિલ્ટર
        AND u.status = 1
        AND u.[user_type] IN ('BC', 'VC') -- OR ની જગ્યાએ IN વાપરવાથી ઇન્ડેક્સ સીકિંગ સારું થશે
    ORDER BY
        u.[user_type] ASC, 
        u.name ASC;
END



--dis_booth_captain_cadre_with_voter_sp 1,1

CREATE OR ALTER PROCEDURE dbo.dis_booth_captain_voter_sp
(
    @app_id INT,
    @booth_no INT
)
AS
BEGIN
    SET NOCOUNT ON; -- બિનજરૂરી મેસેજીસ બંધ કરીને એક્ઝિક્યુશન સ્પીડ વધારશે

    SELECT
        r.id,
        r.f_name AS eng_f_name,
        r.f_surname AS f_eng_surname,
        r.m_name AS eng_m_name,
        r.surname AS eng_surname,
        r.part_no,
        r.eng_localityid,
        r.part_no AS booth_no,
        RIGHT(RTRIM(r.contact_no), 10) AS contact_no, -- સ્પેસ રીમૂવ કરીને છેલ્લેથી ૧૦ આંકડા પકડાશે
        r.idcard_no,
        r.slnoinpart,
        r.eng_polling_location,
        r.sex,
        r.age,
        r.eng_house_no,
        ISNULL(s.voter_available, '') AS voter_available,
        ISNULL(s.voter_status, '') AS voter_status,
        ISNULL(s.not_available_reason, '') AS not_available_reason
    FROM
        dbo.tbl_voting_record AS r WITH (NOLOCK)
        LEFT JOIN dbo.tbl_voter_survey AS s WITH (NOLOCK) 
            ON r.idcard_no = s.voter_idcard 
            AND s.app_id = @app_id -- સર્વે ટેબલમાં પણ એપ આઈડી મેચ કરવું સેફ રહેશે
            AND s.status = 1 
            AND s.is_latest = 1
    WHERE
        r.app_id = @app_id      -- ઇન્ડેક્સ માટે સૌથી પહેલા એપ આઈડી ફિલ્ટર થશે
        AND r.part_no = @booth_no -- બૂથ નંબર ફિલ્ટર
    ORDER BY
        CAST(r.slnoinpart AS INT); -- સીરીયલ નંબર વાઇઝ પ્રોપર સોર્ટિંગ (ટેક્સ્ટ સોર્ટિંગની ભૂલ અટકાવવા માટે)
END


--------------------------------------

---- Display Sakti Pramukh Cadre -----

--------------------------------------

create proc dis_booth_pramukh_cadre_sp

(

	@app_id int,

	@booth_no int

)

as

begin



-- Query 1: Optimized

SELECT

    u.user_id,

    u.[user_type],

	u.booth_no,

    dbo.fn_get_designation(u.[user_type]) AS designation,

    u.name,

    u.mobile_no,

    COALESCE(u.photo, '') AS photo,

    CASE WHEN u.photo = '' THEN '' ELSE dbo.get_server_path() + 'img/admin/' + u.photo END AS photo_path

FROM

    tbl_user AS u

WHERE

    u.booth_no = @booth_no

    AND u.status = 1

    AND (u.[user_type] = 'BP' or u.[user_type]='BS')

	and u.app_id=@app_id



end



--------------------------------------

---- Display Sakti Pramukh Cadre -----

--------------------------------------

--dis_booth_pramukh_voter_sp 1,1

alter proc dis_booth_pramukh_voter_sp

(

	@app_id int,

	@booth_no int

)

as

begin



select

	r.id,

    r.eng_f_name,

    r.f_eng_surname,

    r.eng_m_name,

    r.eng_surname,

    r.part_no,

    r.eng_localityid,

    r.part_no AS booth_no,

    RIGHT(r.contact_no, 10) AS contact_no,

    r.idcard_no,

    r.slnoinpart,

    r.eng_polling_location,

    r.sex,

    r.age,

    r.eng_house_no,

	s.voter_available,

	s.voter_status,

	s.not_available_reason

from

	tbl_voting_record as r

	left join tbl_voter_survey as s on r.idcard_no=s.voter_idcard and s.status=1 and s.is_latest=1

where

	r.part_no=@booth_no

	and r.app_id=@app_id

order by

	r.slnoinpart

end



--------------------------------------

---- Display Sakti Pramukh Cadre -----

--------------------------------------

create proc display_booth_pramukh_by_sakti_pramukh

(

	@app_id int,

	@user_id int

)

as

begin



SELECT

    b.booth_no,

    b.total_voter,

    ISNULL(bp.total_booth_pramukh, 0) AS total_booth_pramukh

FROM tbl_booth AS b

join tbl_user_booth as ub on b.booth_no=ub.booth_no and ub.status=1

LEFT JOIN (

    SELECT

        u.booth_no,

        COUNT(*) AS total_booth_pramukh

    FROM tbl_user AS u

    WHERE

        u.status = 1

        AND u.user_type = 'BP'

        AND u.app_id = @app_id

    GROUP BY u.booth_no

) bp ON bp.booth_no = b.booth_no

WHERE

    b.app_id = @app_id

	and ub.user_id=@user_id

ORDER BY

    b.booth_no;



end



--------------------------------------

---- Display Sakti Pramukh Cadre -----

--------------------------------------

--dis_all_user_sp 1

alter proc dis_all_user_sp

(

	@app_id int

)

as

begin

select

	u.user_id,

	u.name,

	u.mobile_no,

	u.photo,

	u.temp_status,

	u.[user_type],

	isnull(u.booth_no,'') as booth_no,

	dbo.fn_get_designation(u.[user_type]) as designation,

	format(last_login,'dd MMM, yyyy hh:mm tt') as last_login

from

	tbl_user as u

where

	u.status=1

	and u.app_id=@app_id

end





--------------------------------------

---- Display Sakti Pramukh Cadre -----

--------------------------------------



SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO



ALTER PROC [dbo].[add_contact_group_member_sp]

(

    @app_id INT,

    @user_id INT,

    @string NVARCHAR(MAX) -- Pipe separated mobile numbers

)

AS

BEGIN

    SET NOCOUNT ON;

    SET XACT_ABORT ON; -- Rollback transaction if a runtime error occurs



    BEGIN TRY

        BEGIN TRANSACTION;



        -- 1. Use a Temp Table to store and standardize input numbers

        CREATE TABLE #ProcessedNumbers (Mobile NVARCHAR(20) PRIMARY KEY);

        

        INSERT INTO #ProcessedNumbers (Mobile)

        SELECT DISTINCT RIGHT(LTRIM(RTRIM(value)), 10)

        FROM STRING_SPLIT(@string, '|') -- SQL 2016+ માટે, જો જૂનું હોય તો તમારું SplitString વાપરો

        WHERE value <> '' AND LEN(LTRIM(RTRIM(value))) >= 10;



        -- 2. Clean old data for this user/app specifically

        DELETE FROM tbl_contact_group 

        WHERE user_id = @user_id 

          AND app_id = @app_id;



        -- 3. Optimized Insertion

        -- JOINING on standard 10-digit format for better performance

        INSERT INTO tbl_contact_group (app_id, user_id, idcard_no, mobile_no, create_date)

        SELECT DISTINCT

            @app_id,

            @user_id,

            v.idcard_no,

            v.contact_no,

            GETDATE()

        FROM tbl_voting_record AS v WITH (NOLOCK)

        INNER JOIN #ProcessedNumbers AS m 

            ON (v.contact_no = m.Mobile OR RIGHT(v.contact_no, 10) = m.Mobile)

        WHERE v.app_id = @app_id

          AND v.idcard_no IS NOT NULL 

          AND v.idcard_no <> '';



        DECLARE @total_voter INT = @@ROWCOUNT;



        -- 4. Update phonebook count efficiently

        IF EXISTS (SELECT 1 FROM tbl_user_phonebook_count WHERE user_id = @user_id AND app_id = @app_id)

        BEGIN

            UPDATE tbl_user_phonebook_count 

            SET total_voter = @total_voter 

            WHERE user_id = @user_id AND app_id = @app_id;

        END

        ELSE IF (@total_voter > 0)

        BEGIN

            INSERT INTO tbl_user_phonebook_count (app_id, user_id, total_voter)

            VALUES (@app_id, @user_id, @total_voter);

        END



        -- 5. Final Select with Latest Survey Status

        -- Optimized with a CTE for clarity and speed

        ;WITH LatestSurvey AS (

            SELECT

                voter_idcard,

                voter_available,

                voter_status,

                not_available_reason,

                ROW_NUMBER() OVER (PARTITION BY voter_idcard ORDER BY survey_id DESC) AS rn

            FROM tbl_voter_survey

            WHERE app_id = @app_id

              AND survey_by = @user_id

        )

        SELECT 

            gm.idcard_no AS idcard,

            v.id,

            v.slnoinpart,

            v.eng_f_name,

            v.f_eng_surname,

            v.eng_m_name,

            v.eng_surname,

            v.eng_localityid,

            v.eng_polling_location,

            v.idcard_no,

            v.contact_no,

            v.part_no,

            v.eng_house_no,

            ls.voter_available,

            ls.voter_status,

            ls.not_available_reason

        FROM tbl_contact_group gm

        JOIN tbl_voting_record v ON gm.idcard_no = v.idcard_no AND v.app_id = @app_id

        LEFT JOIN LatestSurvey ls ON ls.voter_idcard = v.idcard_no AND ls.rn = 1

        WHERE gm.user_id = @user_id

          AND gm.app_id = @app_id;



        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;



        -- Return error info for debugging

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();

        RAISERROR(@ErrorMessage, 16, 1);

    END CATCH



    -- Cleanup

    IF OBJECT_ID('tempdb..#ProcessedNumbers') IS NOT NULL 

        DROP TABLE #ProcessedNumbers;

END



GO

--add_contact_group_member_sp 3,1167,'9724480899|8673040007|7405228426|9375122007|9824673699|8401287148|9998983434|9104228888|9909545007|9712714113|6351100253|8866601189|9409484877|7041008888|9099529423|9328817782|7859844298|8780883591|9724056453|9428271583|9978514320|9879459416|9712879622|8849611208|7434026099|6351217331|8160247846|9558092394|9687676082|7228805656|9898371269|9099607608|9664821543|7984235867|9328421763|8511857782|8154000090|9714455405|9825414477|7990997266|7227809194|9723644303|9054651649|9328811651|8238299154|6355225578|9978309375|7486905404|9979502825|9913616577|9714203337|9978946546|9227141314|9824600280|9725350404|8849465097|9016272662|9586838321|9316610813|8401147325|8320355850|9824235278|7801816686|9687541114|7600706701|9925134848|8238000090|9265996752|8000661188|9909416498|9687159098|8200173880|9016600266|9428296335|9104038060|7861996064|9016882838|7600003697|6351361443|9313351276|7623085423|9725880218|6352420848|9328784800|7984803839|9712965159|9974032055|8780510494|9909911900|6353580603|9377636564|7874238403|6351988853|9157745459|9825094067|8160520053|7383914996|9727328248|9712333465|6355520963|9173382851|6353074774|7862043412|9033809734|9106350999|6353936894|9016226036|9054272740|9427638961|9265877606|7984758077|8780294512|7600275859|8347393996|8980032562|9016783321|9033682447|8469034409|9376769898|6354085653|9909011523|8529890100|9925420145|7211101757|9898546854|9904322160|6354044480|7265867707|8000840002|9624929312|6352887510|9726226522|9978570053|9913124052|9725264007|9428188604|7990245758|9265666466|9825765433|9725084682|7069465882|6352427745|9429895363|6355274466|9638754548|9106071903|9316250431|8511080827|7698488888|9512700099|8238689890|7984830551|8469929955|6351381063|6359210898|8140228128|9824449624|9727805513|9998837719|7778081868|9974780507|9687395435|9898200826|6351229776|9727948671|9328448008|9924376346|9033211111|8401427349|8488000053|7203900468|9913938850|8154950508|8200975218|9638000307|6351200737|9664947333|9712974470|9624099999|8128694601|9558114682|9998943242|9909100909|7990556997|9099955881|9825714144|9909888678|7990827050|8758058587|9727704266|9825128051|7016385885|9879189289|6352087772|9316303647|9558716527|9861266229|8799271681|9054362045|9537736507|9924898761|9825432214|7777956779|9909595303|7990027922|9033311999|9429979170|9925221714|9898577904|7698111312|8733931259|7778968695|7621023309|9558352845|9824690699|7041369999|7383436573|7041973158|7069975086|7043332662|7043332467|8141478022|7043973313|7016508853|7229090504|7383050783|7383200045|7043741001|8511585123|8160443223|8401603029|7405850044|8347575971|8153076777|8545911111|8306861586|8487925879|8511852110|8530035647|8690981579|7383762891|7405356520|7802824485|8401341429|8401364713|7567976831|7600036103|8696118933|7600088028|7567045704|7622097389|8128290999|7567476976|7567554477|7874230018|8140263017|7600080287|7567045633|8758719532|7698197880|7600080123|8734060029|9016180100|9033894073|8866497247|8905701001|9104351149|9274209703|9104916515|9099368469|9067460730|9137788888|9265249692|9106018601|9067604022|9099098276|9106105571|9033445483|9227365658|9067461136|9173196091|9033442694|9664538153|9427071536|9687999299|9712956523|9375401001|9408045109|9376353993|9722861508|9724806771|9723171740|9712928468|9724361119|9724502121|9427200517|9722661177|9693469693|9718075198|9377699201|9377377099|9727423022|9512148080|9558399372|9512571085|9428010669|9537751856|9737658981|9537476082|9586993767|9724984888|9737210609|9586974401|9512231428|9428299931|9558142875|9727700031|9574440855|9727046925|9913550593|9904215935|9904735185|9824283442|9638929909|9879184377|9638466220|9909018736|9825798344|9624673759|9824227751|9824285939|9898144347|9624788900|9824896585|9909072205|9925039331|9998323111|9974662200|9913842353|9978446126|9979012005|9979069111|9924863993|9930569443|9925158392|9998000181|9979601900|8238001601|9870196655|8347230802|9909301540|9687830300|8156012334|8347136286|9248188769|8469531060|9099012323|9015135135|8880488804|9167398360|8238190921|8306726111|8401445523|8401883391|8347260609|7211119560|7048859981|7567866992|7359242427|7802063533|8141361378|7737836288|7600080269|7405484888|7874749549|7698008057|7567198226|8128064108|7567862729|8153960799|9099444541|8733056559|9228307662|8980808006|9173255555|9228003777|9054022229|9099076136|9173701740|8401924277|9157685662|8733025080|9033091359|9033485489|8153879118|9033340420|9157160122|8733871132|9426226426|9375711110|9725860037|9409056789|9723352719|9375960170|9427726774|9724634055|9408007171|9426548244|9726357903|9725304343|9723645554|9427811899|9725804370|9275007745|9374100635|9725036360|9558122947|9428344141|9574364007|9726604303|9429806323|9624716262|9624740871|9737090760|9727760247|9428220400|9512702993|9537604279|9586548171|9638215598|9638633298|9428003212|9558515129|9727811811|9737370535|9638977186|9825804443|9824400226|9879418039|9824208162|9662581285|9879233376|9737597317|9824404578|9825760676|9825660515|9825077843|9687686144|9687672335|9825416027|9879377202|9662907555|9909992053|9898134486|9898213715|9925512069|9913745273|9925247467|9904474284|9925327850|9904930492|9974390391|9925852076|9925750058|9909184264|9904999799|9925536495|9974242882|9913333937|7383523708|9979362125|7202857792|9998630399|6356924792|6352805680|6359529690|7016161599|9898376904|6351180026|9979167397|8530078617|9979909282|9978229006|8980996882|7016757422|9429440132|8780731543|7096676625|9818030168|9327503143|9408942640|9898576092|8980810018|9327033141|8320005788|7016767884|9626262397|8401031695|7265099950|9879539949|9714126340|7567724541|9913876363|8866425024|8000490061|9904472696|9898110926|7359899997|7779082988|9714814213|9099053414|9978293654|9473685846|8446169704|9426895795|9824619401|7600080280|7041781881|7698005941|7478444565|8200140977|7633079406|9898076195|7016287226|9276810040|7383211541|9227971347|9767076755|8734987816|8140195541|9624800025|9375327632|9099561412|9825895478|9726773603|9664685475|9925409780|9106835057|8460400524|9316072160|9825735274|7698005013|9881716939|6351964991|9724901700|9825991314|7201884885|9624391263|7698005985|9033848698|9978187377|9574331077|9879879646|9879478662|9429243208|9924989898|9824599988|9978199900|7874792952|9974410101|9898295336|9427794278|9978480890|9924324558|7698005983|9978413913|9726933355|9099097638|7698128001|9909100990|9825229729|7878596363|9638000700|8980000104|9925644899|8501812333|9016435914|9978988832|9427726885|9825123613|9723772915|9913600011|9924899248|7046357133|7359063302|9723468005|9328128894|9067500000|9879527362|9879635505|9558588449|9409434146|9725912862|9898111611|7069886644|7069083880|9898557030|9978926260|7698005978|8511622900|9724262919|9727690116|9724600999|9099252121|7284848472|9998889088|9375944444|9925353275|8980041547|7023384607|9408923694|9054047444|9712927133|7779000048|7202099909|9067882345|9824498575|7016060556|8401702606|9428463638|9537565887|8511303839|9892042735|7698798404|9054992580|9909920098|9824503835|9825649704|8088888848|8780664651|9998318423|9428202060|9712800999|8780934252|9428492888|9376240926|8000801001|9909010475|9979288488|9879599950|9537988088|9558216162|9898082099|9726922607|9099925351|9924600009|8469500009|9722000972|9376240844|9825192941|9374116576|8511108828|9276106568|7046717329|9924291291|9825606123|9662289995|9879196781|9979996303|9925195960|9904999786|9925809102|9825612071|9825619242|9825110426|9904170300|9825072234|7016380799|9825223404|9879789217|9099052755|8200213020|9712021777|9998994233|9723900120|9375422233|9033400880|9824281421|7575016201|9537200001|7779045005|9725224717|9426438604|9723258766|9824057676|9825108887|9824290476|9033194595|9904060766|9427760030|9824800527|9979931457|8469295658|9537000091|9898519115|9824153737|9033777766|8128429063|9638444440|9824571726|8980900030|9426262642|9722788888|9925684444|6352944407|9824240908|8530678007|9033493793|9228718712|9537350308|9924575027|9228500009|9979062494|9727540312|9737852418|9638500746|6351677823|9687693407|9227555501|7878787827|9106509213|9726218805|9998928080|9825487187|9924457546|9054964455|9601709999|9375333303|9662180438|9879160786|8490823539|9824256906|8000221082|8530377777|7016320355|9974641999|9376873532|9825197973|8128126007|8758709035|9979435002|9737200057|9920799460|9725059999|9712134344|9824719088|8780678263|9825311314|9879605324|8849188726|9783704135|7878173737|9825261695|9624281996|8891179574|9724550335|9898176417|9998899007|9624370549|8141561317|9773054098|9558337980|8487885537|9824202222|9426261039|8780834560|9824387132|9909374535|9662219901|9426638444|8866346929|9879111117|9925188799|9825734456|9898082882|7574918333|9312432625|9924094583|9723771327|8141957417|8200303628|9601682007|9924379009|9228000001|8735000009|8140688602|9909916709|9909999989|9825288857|7405356503|9913940288|9825269593|9825261981|9824213497|7990236556|9904650777|9925807178|9428466564|9664883484|9824415927|9714299990|9818682238|7988423992|9898632337|9825303344|9099519900|9408560336|9586470009|8141062101|9898966846|9824890801|9825306687|9726484477|9825197413|9979084466|9913036904|9924577511|9737380077|9879964008|9913994002|6352114553|9825913111|9173540627|9898817143|9714997977|9825172360|7698738350|9825035336|9879539993|9904411682|9725342871|7874938218|9825829067|7016837535|9687070706|9374141000|8469722999|9067211111|9824212798|9228823456|9998435868|9377402444|9227552280|9824202687|7984001478|9898771702|9974132288|8866247400|9913487887|9726707777|9687417174|7600005787|9737484856|9712728285|8154094928|9824504561|8866399063|9723190009|9016099999|9428986864|9825827014|9265813152|9909940703|8141347302|9157546930|9978622196|9824897745|9723623276|9825451082|9662232607|9330103797|9327799997|9925048484|9099928989|9687686146|9033441002|9327865380|9974388881|8360083161|9824810100|9687611145|9426907659|8980052717|9737200005|9726858640|9712977399|9898302404|9727888880|9825399199|9227292278|8200161727|9979675281|9870038630|7990341742|9099918571|9825075306|9998931888|9909993711|9510635999|9316640847|9974086876|9173689786|9712196842|8980452767|8156081082|9099926426|9998789431|9924612566|8758295599|9825222341|9925199556|7567627452|9374102232|9898800777|9924751166|9825384050|9825371111|9722200007|9727420668|8980868943|9978941730|9898936264|9426650000|9825192517|9805153735|7801810288|9904471572|7622099496|9974035360|9429980743|9601251789|9924810757|9824312083|6352976182|9727995842|9727877302|7009978692|8866718748|9426476233|9313305757|7624060809|9724228777|9909200420|9320001494|9824416190|9924399533|9909257260|7874177475|8511111151|8155852664|7359409999|7984621592|8866331155|9824288650|9723775400|9909211911|9099923844|9033233888|9879303864|9824246080|9825071517|9909262583|8347101737|9898563232|9824297322|9714455554|9909104722|9824507007|9737377077|9033393203|9824400099|7487977175|9998861502|9924897400|9099084238|9067180671|9106957707|9879985555|9426145399|7383242507|9510588433|9974757677|9167788485|9825133338|9586609981|9925129512|9824221711|9725709757|9810161116|9714919199|9825606231|9998111033|9879003141|9904400003|9824400813|9825237004|9879185152|9879539394|9898073188|7383811622|9909617786|9998279502|9898258987|9904050156|9998888805|9998291978|9925155303|9979001002|9974728989|9998120000|7878777717|9925041701|9979217789|9979753155|9978822987|9925786163|7573024297|7567509187|7600001201|9099991561|9824582423|9624459080|7990504628|8141537890|9998890090|9998469799|8488807302|9998079516|8511183741|9879055676|9825711101|9724205610|9033822229|8128519999|7383331330|9586296161|9427502339|9714096327|7016090576|9925507512|9558671655|9904675092|9924499683|9979136037|9909026096|7877371781|7567987110|7093856096|9898800303|9714008494|9033248248|8758300302|9913340420|9374127677|7874552955|9636277089|9898424682|9714945678|9825930109|9601363263|9327549077|7984709318|9898808368|9924030303|9879081472|9664567078|9662776397|9426991662|7573807111|9726200682|9898082792|9898494962|7567481929|8160127871|9879806360|9714781099|9712197588|9978410110|9016476636|7990203886|9724861846|8154074546|9877777153|9825725535|9510378378|8160254885|8780005078|8758669996|9909006991|8780672790|9879395386|9725001234|8469231114|7383242378|9712175591|9879577388|9824478594|9879694494|9898159280|9925830603|9998429856|9974460990|9879879881|8347008649|8000069940|9924012003|9979468912|9104367086|7600399468|9104515592|9714438718|9825755170|7359616991|7383898272|9925801433|9909322202|7450000010|9724477777|7621034792|8427547523|8347088888|9137647906|7820003707|9925422567|7435919254|7990571706|9033762064|8320212215|9898337238|9879890826|7909088894|9825252618|9537877792|9924890025|9833881120|9925500249|8780923963|7600910109|9924270304|9723493395|9724295888|7802055505|9173038808|8320699415|7383493565|9825775521|9978977077|8160374764|9586377180|9879359549|8780610057|9033077777|9574527765|9913324307|7778803641|9725693371|9979011910|8347001042|9212318818|6358275289|8401644157|9924493808|9978874498|6354694104|9925041167|9099016409|9574600600|8780087707|9104025691|7600008001|9925801368|9510714952|7016537769|6352474847|9925244430|9724455818|9825463800|9825077236|9824441045|8200739106|9461028920|9825771687|8238847121|9825230535|9990334260|9408548773|8530778080|9904095635|9409012214|6355633463|9825121122|9173329792|7777995091|6352383411|8530606670|8121089223|9978890044|9099092907|9377293777|8160955100|9099981579|9664866605|6351910511|9726244500|7621056790|9712023516|7020071250|8238511861|7878581414|9924119103|9537594155|9377577669|7984053287|9327873028|9998323872|9904111119|9924927834|9033355555|9327005400|8758707076|9725015255|9429567252|9909300552|9023358015|9157507196|7575000086|9429917303|9426962291|9737651691|7043129252|9723688883|9173391302|9601833338|9428276872|9726004889|7359383333|9149841451|9824865037|8160516819|9714036340|7984687030|9428699761|9601366058|8799122015|7359144602|9833759937|8154885836|9033698842|9898312593|9714760231|9825668246|7016424434|9870988880|8160466089|9998152791|9909280764|6354942672|8238389404|9909022619|9327816891|7621023307|8026599990|7048455500|7285026767|8401251322|9427726015|9909577178|9898489555|8401606052|9825434334|8140306856|9924118529|9825413283|8000931762|9227601662|9099058045|9099040537|7405057017|9879499066|9099058032|8401855301|9825073632|9904645111|9574786021|8347473567|9925067265|9913167333|9428580065|9979049641|9879800001|9586954654|8401319390|8140229683|9724920104|9537305729|9737727791|8490014028|7096137352|8487917173|9879621828|9824224562|9727191993|7990498094|7878040470|9825884548|8487911275|9099589907|8849984751|9824040889|9265836858|9507877777|9924999555|9909280889|9427497352|8980030010|9511747601|9822928858|8000003354|9998537017|9928006006|8140953555|9727100746|6354981938|7874200945|9879799303|8200385169|9898958090|6354040113|8447971777|9978529567|9327511545|7383633380|9429402550|9824827072|9725555599|8849315628|9727234486|8320440804|8252711111|9979547022|9099048553|9173786572|9624200009|8733000007|7698758033|9824000711|8010928888|8401523222|9825989840|9825388294|9909833474|9726622121|9998890906|9726479303|8320454580|9725300900|9925573373|7878173373|6353830561|9925238702|7984089489|9825587989|9099991579|8780294719|9428408605|9824372183|9374110681|8140071886|7487921191|9726781757|8511185506|9825496846|8511185505|7990357043|6356185873|9724796105|9328939376|9376777433|9328904159|9825729662|7436015167|9825127867|8758189339|7622026009|9662076489|6354930261|9904195099|9428010188|6351400903|9687362783|8866115012|9913903852|9429343339|9773291550|9376775777|9925444190|9574868327|7859805908|8866988880|8866861830|9662195795|9033000302|9265737544|6354795732|8866173806|9825989727|7567049727|9328711159|9824329129|9925841777|9879835986|9825044012|9773405652|9824416712|9824843748|7990440420|7383061268|9512241739|9687888966|9664559003|9825084984|9054685925|9924261651|7043983255|9824211521|9725034164|9316055372|8460707070|9825077969|7405074051|7573900004|9998077888|9377249749|9427505084|6351561722|7228854774|8000229000|7820047356|9825292671|8140487584|9974653395|7600003654|9413180909|9824882485|8238710072|9265428899|8949029087|9023209911|9909505100|9787707999|9825865444|9879687730|7405555955|9265797960|9924215302|7573847111|9106256691|7016865780|9033807901|8511111424|9727400303|9824704682|9998240445|9375402002|8866558054|9662700987|9825273821|9819537940|9974981810|9227106449|7778812237|7801877173|8153968265|8128693433|9106670966|9537386282|6359649902|9898116103|9106788106|8511309140|9825105185|7777969400|8459463315|9689157496|9998174420|9157970033|9974044444|7383567575|9879073373|9824876177|8160464170|7971636460|9924398809|8320983497|9879524032|6353002331|6351847595|7874300333|9377147474|8320038039|9727711616|8347008631|9909024365|9725313113|9825935550|9879878861|9898882121|9374601230|9898218989|9879599976|9898179272|9879598389|9824088199|9925455572|8160142820|9978399998|9825340700|9712750841|9979466584|9909372335|9173661304|9825450155|9724140555|9898285435|8469950110|9974174874|9523677777|9725523313|9099938007|8980808954|9978300008|9426551999|9033004242|9904572387|9925686420|9099090197|9879310077|9727414143|6352360299|7698375135|8128077718|9687693014|9662529933|8460311110|9924586300|9924295457|9904802211|8347691869|9375443078|7359907566|9998817772|7990643017|7600012993|9664663544|9824675156|9824436461|9714800900|9909944240|9726747215|9824097640|9879309655|9879596908|9687692147|9099777803|9749988888|9327108080|9664961516|9429345368|9374772777|8238174142|9426949144|8000811811|8320492779|8306983068|7861084740|9924773764|9825998111|8081099999|9824236394|9924001914|9870039992|9925457017|9825506026|9978469767|9979980815|9998055345|9909500099|9307399999|9978485298|9773495165|9925456150|9722222983|9924033126|9824894262|9879107443|8155881881|9033205050|9727000001|9537322101|9638901648|9825643072|9924323066|8000028080|8460844441|9228820396|9328999998|9376026360|8866776777|7567061863|6351988330|9714447058|8347999909|9904161687|9825620009|8140000099|9909015959|9099707273|8469000915|9824999111|9375111101|8849754183|9724997777|9879401754|9428789698|9106505734|9898025055|9173050501|9925915310|9664843385|9726708050|9913527754|9016631111|7878099959|7600973009|8128151960|9899820230|7984788037|9974646460|9925414721|9009607884|9879768618|9898441330|9879295191|9925023030|9276000011|9725872821|9824865622|9426201876|9904808487|9426548779|9824818546|9978504168|8000546548|9898327632|9726900004|9825997861|7046250475|9898116770|9723236766|9825220241|8000090303|8980000121|9408495223|8469990999|9099417105|9925568360|9913053756|7284913822|9033776600|8128212141|7567676794|9898578632|8732970292|9316134287|9998474337|9726979715|7698000009|9725799013|7878782477|9879497199|9624585282|9426808080|9879963970|9099123231|9924157992|8509911111|9624709999|9925456363|7698897676|9510636936|8140300085|9601518999|9913899014|9099098393|9428792782|9638585466|8511040702|9712259656|7698947482|7984718843|9979918581|9016726753|9429345363|9974586007|9824245403|9586900005|9104100009|9824326336|9428256079|9879007520|9898800092|9824411092|9624711899|9998877730|8866614001|9099102323|9601111145|7041127476|9998837327|9879507213|7801995169|9925228989|7226091984|9099021610|9725900099|9998571916|7990479020|7621053905|9638816928|9879303082|9979178025|9723230001|9898942171|9904720101|9512900500|9998882099|8238611316|9880774886|9998885411|9427220153|9227787777|9925220571|9427505085|9723726102|9825072335|9825383089|9265040403|9277405827|9737883990|8141781010|9979789119|9913746151|9879909989|9227892222|9824892970|9067353633|9898177772|9304011111|8866400005|7405492007|9723300008|9427601601|9824234485|9714377777|9879046304|9825366767|8200983550|9924842323|9825219936|9638232338|8200974441|7874900365|9104960007|9624395150|8320689065|9925486616|9824899272|9978406260|9904084624|8849056135|9173998966|8141774772|9979338922|9723710324|9979308888|9173546622|8200556129|9825236035|7600555125|8980948661|9879498515|9909917018|9998510777|9825620113|9374101191|9998215821|7698892892|9426264406|9978900907|9825399777|8000830130|9824323688|9909341441|9904225609|9727253535|9723900028|8320172600|9067464605|9824008951|9638191473|9824214474|7337388486|7567676733|9824210888|9979300888|9662499003|9512021212|9537577551|9737565370|9979433544|9712209080|9898267555|9443263910|9313205003|9773092671|9825200009|9909969512|9909556975|9978819818|9737829747|9904200088|9978882200|7031178692|9924164457|9978383838|9429540536|9824181023|9313580024|7861011848|9824478181|8320324929|7043043218|9909031213|9978393003|9904277707|8530307864|9426555849|9510448202|9327998261|7694897889|9099675809|7990024951|7359011000|9687184828|9825790421|9904929519|7600942571|8866349234|7698000099|9712703777|9726000010|9824049336|7878009777|9377200008|9737777720|9879115846|9925491996|9374125752|7041899999|9727997099|9824113987|9924010007|9033411117|9638000040|9558790079|9033879289|8160928458|9898999303|9723922526|7802074555|9624997999|7016425723|9714916476|9016354907|9979036464|9712200999|7778849645|9376366003|9664623569|9913094505|7226999997|9979238016|9925000962|9998888680|9106979363|9924872274|9104389223|7575875490|9913290585|7567615151|9824207475|9974183866|9879173272|8320571238|9824396026|9824996026|9824165755|9898281981|8320824406|8238272126|9427220203|9265566291|7990837619|7405763643|8238805013|9825537918|9054064801|9898082361|9925273643|7621925813|9879699299|9099309999|9624437539|9879264532|9426459914|8530597757|8469004090|9879022225|9824219103|9662690909|7383204044|9825576166|9099217187|9909137535|9825624594|9925339554|6352677288|8460213321|9913324441|8320890923|9898854000|9328777222|8780811987|9664764944|8866800034|7016748421|8000828991|9824841777|9574481470|9033342999|9687539159|7069366420|9586487636|8793760058|7096916039|7567009240|9913592217|9825211844|9909928590|9979605010|7575074966|7600036152|9727714938|9979309700|8320706783|9924771711|9773140015|8140287483|9725397697|7041200009|9558801066|9925124343|9662983017|9925645410|9924191819|8320092658|9825660105|9979699199|9825419010|8140799140|9512151111|7433806655|9924101200|9925777007|9537832304|9737101663|9377103332|9879893712|9408603538|9925003738|9426980975|9374337770|9428229477|9824163744|7016008810|7575061412|9925507860|9925966788|9979600333|9913297846|9825795033|9664832007|9824904307|9924308308|9898411997|9824915235|9979655877|7405585152|8264626556|9824203399|8866440555|8000888008|9825882419|8238340347|9825444676|8200878004|9998275077|9924114547|9913080843|9737039965|9510063345|7485993683|9824949976|8000091818|8905978692|9723021108|9687475081|9925615825|9824216492|9601261093|9824446571|9409527184|9426712152|9590278692|9033332511|7600369262|8128853523|9714201881|9913400333|9974660945|9737378001|9033711111|9327031010|9979405258|9998812871|9574163174|9327565022|9998617516|9723368460|9870081276|9898999499|9714699927|7567506556|9825118718|9924762232|9978011135|9825313413|9879870502|9925299252|9909137582|9724990000|9316529679|9586817711|9328188661|9825087158|9773069951|9372247525|9924509999|9998480801|8000081339|9879467773|9374107477|9687000808|9033350233|9624700003|9016680617|9099999189|8000084603|9426269060|9328201515|9898439046|9879589089|9426815833|9898206676|8000810009|9107000090|7567300010|8320441838|9104608267|8000199001|9924109020|8511095023|9913468229|9824338775|9737400099|9974344574|9737484876|8401769333|8200517999|9824072234|8866684582|9824222932|9662199028|9879511878|8451828000|7016652355|8401840185|9825581688|9879574917|9825158331|8000117892|9925191111|9824356191|9879399904|9773468622|7874639395|7567500008|9727321162|8690777797|9879512592|9924525605|9824865970|9925386167|6354030835|9586591727|9687177871|9328192225|9824917555|9824296690|8200701043|9979544276|9714436333|9824999876|9328018378|9909565434|9824416990|9228699665|9712020161|7016230034|9429411378|7874441764|9879605870|9033943347|7698867686|9824850048|9825490236|9537900004|9825420767|9726600047|9879000962|7777901775|9737406401|8140200091|9925831185|9714511704|9662376722|9429650557|9898200008|7359758268|9601061893|9879210192|8758625121|7990709408|9292929286|9909192991|9825216921|9016031192|9879836400|9825500404|7990746845|9825327341|9978820004|9725372050|8320678237|9825354643|9913286955|7972791077|9924484250|9898797295|9825686915|9979931339|9825710853|9909776887|9824907431|9909884788|9426972449|9978970555|9825998210|9904039666|8141808025|9104503836|9726142142|8128837310|7405623456|9033146292|9328221551|9824187918|9726808901|9601700999|9909015215|9879530308|9428298695|9427270173|9824210063|9825215590|8460200004|9824208487|9428296539|9328875960|7016169899|9714349912|9898719090|9737826678|9601330220|9725839191|9265369401|9979902458|9574500019|9825060375|8511228084|9898941542|9825791781|9825081849|9274747576|9904136433|9724416969|9328755505|9824248696|8000080007|9824297496|9924480850|8849306050|9664972832|7600281592|9712375888|9723453429|9998885875|9824216432|9725987472|9033774135|8000181001|9824812879|9601262999|9099948400|9824523374|9377027077|9825735494|9687121212|9824144040|7777998835|9375750999|8160886702|9875129157|9238800007|8320067592|9824088380|9904736963|9624599990|9099929240|9586525525|9824740308|9979007700|9825463132|7383582013|9099025394|9825218027|9662273728|9879508041|9824335497|9825613224|9725397353|9825075190|9727709169|7874168163|9825314302|6354701008|7600007951|9925399028|9574738080|9427749386|9638300900|9033227738|9825058787|9879608090|9825702611|9925752323|9825794809|9173309306|9724999994|9825152719|9316588710|9033044440|9998842862|6355499556|9714677777|8511611173|9558305060|9537379007|9033198655|9099752848|9824889478|9375710109|9825258167|9979799099|9824343507|9824233618|9723477770|9725350302|9825945710|9879044833|6351710363|8141461233|9067763101|9712700099|9898593009|9687238323|9978921210|9712099099|7359500099|9904225345|9925032337|9925529190|9879430303|9925592950|9426932017|9824216504|9033342293|9004115292|9726523050|9712378163|9724109155|9265865813|9824028534|9978784164|9925129261|9427726811|9574400022|9712853031|9825673752|7777927272|9737812125|9825093847|9723662525|9727700777|9998149925|9574411319|7622877609|7575010157|7016830253|9424306923|8460389200|9624421084|9426889299|9925048384|7874009997|9909602812|9377718777|6354963134|7405522635|9979448989|7874313463|9825500909|9427642500|9662766119|9723628151|9870023749|9099151544|8490032622|9427414755|8320024367|9712593555|9924393661|9898688868|7990751524|9898697090|9586503463|9824241535|9998799990|9909782572|9662640105|9879049879|9737663402|9913625208|9099670708|9428227463|9714500004|8200821479|9825940139|9355509347|7600430299|8454850750|9712902727|9724784402|9909900594|8849681574|9426719667|9428003467|9978678981|9904045954|9925118380|7359118571|9924123423|7211186222|8238132011|7623939472|9726925888|7567677963|9106514914|9638147487|9537338188|8200292416|9909302444|9714021736|6355003789|7600189999|9265854498|7984849241|6353190581|9016170875|9106008345|9979045595|8780703465|6352173959|6355227058|6351391292|9662389939|9574511704|9687319613|9725610100|9328050629|9016413286|9106817749|8153814159|9512675622|9824329974|8690313233|9978804667|9106176381|9106527203|8780685481|6355675109|9081277701|9316120087|9409719331|9016211247|9375810011|9979592354|9727872555|9879598993|6353330887|9016053132|9879977110|6353376080|9998060721|9664784573|9974224700|9427410234|9712930157|8140700709|8824638669|9725800025|9033188188|9723538477|7990920867|8511854786|9824530021|9067455707|8490999962|9638200178|9274518188|9904322487|8000007735|7202957519|6355544788|9638391275|8401077770|7818839304|6352454575|7043988775|9825210476|9426926699|9978389051|9601628485|7016055234|9998740223|9316979189|7698870019|9727691176|9054179108|9081666908|8799363921|8780624875|7486999302|6354622141|9274334482|9879764384|9428532281|8849440450|9004944449|9904096615|7878913302|9925499680|9998345677|9104555377|9601300302|9978666011|9016843330|9726016314|6354111578|9924922057|7016707535|9277001314|9723132397|9825498709|7202020607|6359288180|9724012100|9824865944|6356687391|8758529449|9925290910|9998083012|7041499126|9909716504|9054454808|7490052684|7874382669|6352546833|9664686171|9519171043|6354095199|9725153345|9601011015|9604200009|9328268282|9327132010|8200134658|9725230404|9773086858|8238293903|6357557518|8460537151|7874341473|9274700311|9712176397|7202017217|7435098303|8469726453|8401627456|7203830072|7862903804|7000770007|7284992355|8153008888|9879491240|6352325991|7228897186|9579411202|9428230341|6353386713|9727856192|8849511411|9913988880|9712931570|9727700072|9408700301|9537328642|9979000902|9537284725|9510013634|7405312127|8401294580|9328597020|7227083083|7990012459|7990493973|9825850993|9898075002|9825217508|8320071433|7600187381|9023342467|9574514814|7802890082|7016331566|7778988882|8866613861|7622924241|9327586243|7016936761|8511850786|9726426077|9925677844|9662004444|9601707091|8200265171|9228707051|'

--ALTER PROC add_contact_group_member_sp

--(

--    @app_id INT,

--    @user_id INT,

--    @string NVARCHAR(MAX)

--)

--AS

--BEGIN

--    SET NOCOUNT ON;



--    -- 1. Use a Temp Table to store split items for faster joining

--    CREATE TABLE #ProcessedNumbers (Mobile NVARCHAR(20) PRIMARY KEY);

    

--    INSERT INTO #ProcessedNumbers (Mobile)

--    SELECT DISTINCT Item FROM dbo.SplitString(@string, '|');



--    -- 2. Clean old data using a targeted index (ensure user_id is indexed)

--    DELETE FROM tbl_contact_group WHERE user_id = @user_id AND app_id = @app_id;



--    -- 3. Optimized Insertion

--    -- We move the 'REPLACE' logic to a subquery or CROSS APPLY to help the optimizer

--    INSERT INTO tbl_contact_group (app_id, user_id, idcard_no, mobile_no, create_date)

--    SELECT DISTINCT

--        @app_id,

--        @user_id,

--        v.idcard_no,

--        v.contact_no,

--        dbo.get_date()

--    FROM tbl_voting_record AS v WITH (NOLOCK)

--    INNER JOIN #ProcessedNumbers AS m 

--        -- This is still slow but better than before. 

--        -- See 'Step 2' for the real fix (Indexing).

--        ON m.Mobile = CASE 

--            WHEN v.contact_no LIKE '+91%' THEN RIGHT(v.contact_no, 10)

--            WHEN v.contact_no LIKE '91%' AND LEN(v.contact_no) = 12 THEN RIGHT(v.contact_no, 10)

--            ELSE v.contact_no END

--    WHERE v.app_id = @app_id;



--    DECLARE @total_voter INT = @@ROWCOUNT;



--    -- 4. Update phonebook count

--    DELETE FROM tbl_user_phonebook_count WHERE user_id = @user_id AND app_id = @app_id;



--    IF (@total_voter > 0)

--    BEGIN

--        INSERT INTO tbl_user_phonebook_count (app_id, user_id, total_voter)

--        VALUES (@app_id, @user_id, @total_voter);

--    END





--    -- 5. Final Select using IDCard (Ensure idcard_no is indexed)

--   SELECT 

--    gm.idcard_no AS idcard,

--    v.id,

--    v.slnoinpart,

--    v.eng_f_name,

--    v.f_eng_surname,

--    v.eng_m_name,

--    v.eng_surname,

--    v.eng_localityid,

--    v.eng_polling_location,

--    v.idcard_no,

--    v.contact_no,

--    v.part_no,

--    v.eng_house_no,

--    s.voter_available,

--    s.voter_status,

--    s.not_available_reason

--FROM tbl_contact_group gm

--JOIN tbl_voting_record v

--    ON gm.idcard_no = v.idcard_no

--   AND v.app_id = @app_id



--LEFT JOIN

--(

--    SELECT 

--        voter_idcard,

--        voter_available,

--        voter_status,

--        not_available_reason

--    FROM

--    (

--        SELECT

--            voter_idcard,

--            voter_available,

--            voter_status,

--            not_available_reason,

--            ROW_NUMBER() OVER (

--                PARTITION BY voter_idcard

--                ORDER BY survey_id DESC

--            ) AS rn

--        FROM tbl_voter_survey

--        WHERE app_id = @app_id

--          AND survey_by = @user_id

--    ) x

--    WHERE rn = 1

--) s

--    ON s.voter_idcard = v.idcard_no



--WHERE gm.user_id = @user_id

--  AND gm.app_id = @app_id

--  AND gm.idcard_no <> '';



--    DROP TABLE #ProcessedNumbers;





--END







--------------------------------------

---------- Display All Admin ---------

--------------------------------------

--dis_all_contact_match_admin_sp 1

alter proc [dbo].[dis_all_contact_match_admin_sp]

(

	@app_id int

)

as

begin

select

	u.user_id,

	u.user_type,

	dbo.fn_get_designation(u.[user_type]) as designation,

	u.name,

	u.mobile_no,

	'' as photo_path,

	c.total_voter as total_phonebook_member

from

	tbl_user_phonebook_count as c

	join tbl_user as u

on

	c.user_id=u.user_id

	and c.app_id=u.app_id

where

	u.status=1

	and u.app_id=@app_id

	and c.app_id=@app_id



end







------------------------------------------------

---------- Display Contact Group Member --------

------------------------------------------------

--dis_contact_group_member_sp 1,1

alter proc dis_contact_group_member_sp

(

	@app_id int,

	@user_id int

)

as

begin

	

SELECT 

    gm.idcard_no AS idcard,

    v.id,

    v.slnoinpart,

    v.eng_f_name,

    v.f_eng_surname,

    v.eng_m_name,

    v.eng_surname,

    v.eng_localityid,

    v.eng_polling_location,

    v.idcard_no,

    v.contact_no,

    v.part_no,

    v.eng_house_no,

    s.voter_available,

    s.voter_status,

    s.not_available_reason

FROM tbl_contact_group gm

JOIN tbl_voting_record v

    ON gm.idcard_no = v.idcard_no

   AND v.app_id = @app_id



LEFT JOIN

(

    SELECT 

        voter_idcard,

        voter_available,

        voter_status,

        not_available_reason

    FROM

    (

        SELECT

            voter_idcard,

            voter_available,

            voter_status,

            not_available_reason,

            ROW_NUMBER() OVER (

                PARTITION BY voter_idcard

                ORDER BY survey_id DESC

            ) AS rn

        FROM tbl_voter_survey

        WHERE app_id = @app_id

          AND survey_by = @user_id

    ) x

    WHERE rn = 1

) s

    ON s.voter_idcard = v.idcard_no



WHERE gm.user_id = @user_id

  AND gm.app_id = @app_id

  AND gm.idcard_no <> '';

end



------------------------------------------------

---------- Display Contact Group Member --------

------------------------------------------------

create PROCEDURE ins_my_group_sp

(

    @app_id INT,

    @user_id INT,

    @idcard VARCHAR(20)

)

AS

BEGIN

    SET NOCOUNT ON;



    INSERT INTO tbl_my_group

    (

        app_id,

        user_id,

        idcard,

        create_date

    )

    VALUES

    (

        @app_id,

        @user_id,

        @idcard,

        dbo.get_date()

    );



    SELECT 'ok';

END;



------------------------------------------------

---------- Display Contact Group Member --------

------------------------------------------------

alter PROC dis_my_group_member_sp

(

    @app_id INT,

    @user_id INT

)

AS

BEGIN

    SET NOCOUNT ON;



    SELECT

		g.id as member_id,

        v.id,

        v.slnoinpart,

        v.eng_f_name,

        v.f_eng_surname,

        v.eng_m_name,

        v.eng_surname,

        v.eng_localityid,

        v.eng_polling_location,

        v.idcard_no,

        v.contact_no,

        v.part_no,

        v.eng_house_no

    FROM tbl_my_group g

    INNER JOIN tbl_voting_record v

        ON g.idcard = v.idcard_no

        AND g.app_id = v.app_id

    WHERE

        g.app_id = @app_id

        AND g.user_id = @user_id;

END;





------------------------------------------------

---------- Delete Contact Group Member ---------

------------------------------------------------

alter PROCEDURE del_my_group_member_sp

(

    @id INT

)

AS

BEGIN

    SET NOCOUNT ON;



    DELETE FROM tbl_my_group

    WHERE

        id = @id



    SELECT 'ok'

END;



------------------------------------------------

---------- Delete Contact Group Member ---------

------------------------------------------------

alter proc dis_user_list_by_create_group_sp

(

	@app_id int

)

as

begin

;with m as

(

	

select

	g.user_id,

	count(1) as total_member

from

	tbl_my_group as g

where

	g.app_id=@app_id

group by

	g.user_id

)



select

	u.user_id,

	u.name,

	u.mobile_no,

	u.photo,

	u.user_type,

	dbo.fn_get_designation(u.[user_type]) AS designation,

	m.total_member

from

	m

	join tbl_user as u on m.user_id=u.user_id

where

	u.app_id=@app_id

end



------------------------------------------------

------ Insert / Overwrite Prachar Content ------

------------------------------------------------

alter PROC ins_prachar_master_sp

(

	@app_id int,

    @prachar_type VARCHAR(20),   -- TEXT | IMAGE | VIDEO | AUDIO | SELFIE | SLEEP

    @content NVARCHAR(MAX),

    @create_by INT

)

AS

BEGIN

    SET NOCOUNT ON;



    -- Types that allow ONLY ONE record

    IF @prachar_type IN ('TEXT', 'SELFIE', 'SLEEP','AUDIO','PRINT')

    BEGIN

        -- If exists → UPDATE (overwrite)

        IF EXISTS (SELECT 1 FROM tbl_prachar_master WHERE prachar_type = @prachar_type AND status = 1 and app_id=@app_id)

        BEGIN

            UPDATE tbl_prachar_master

            SET

                content = @content,

                modify_by = @create_by,

                modify_date = dbo.get_date()

            WHERE 

				app_id=@app_id

				and prachar_type = @prachar_type

				AND status = 1;



            SELECT 'ok';

            RETURN;

        END

    END



    -- Default behavior → INSERT

    INSERT INTO tbl_prachar_master

    (

		app_id,

        prachar_type,

        content,

        status,

        create_by,

        create_date

    )

    VALUES

    (

		@app_id,

        @prachar_type,

        @content,

        1,

        @create_by,

        dbo.get_date()

    );



    SELECT 'ok';

END;



------------------------------------------------

-------- Display Prachar Content ---------------

------------------------------------------------

 --dis_prachar_master_sp 2,'SLEEP'

alter PROC dis_prachar_master_sp

(

    @app_id INT,

    @prachar_type VARCHAR(20)   -- TEXT | IMAGE | VIDEO | AUDIO | SELFIE | SLEEP

)

AS

BEGIN

    SET NOCOUNT ON;



    SELECT

        p.id,

        CASE 

             WHEN p.prachar_type IN ('IMAGE', 'AUDIO', 'SELFIE', 'SLEEP','PRINT') 

                THEN dbo.get_server_path() + '/img/prachar/' + p.content

            ELSE p.content

        END AS content,

		u.name,

		dbo.fn_get_designation(u.[user_type]) AS designation

    FROM tbl_prachar_master as p

	join tbl_user as u on p.create_by=u.user_id

    WHERE

        p.app_id = @app_id

        AND p.prachar_type = @prachar_type

        AND p.status = 1

    ORDER BY

        p.create_date DESC;   -- useful for IMAGE / VIDEO / AUDIO

END;





-----------------------------------------------

--------- Image Prachar With Log --------------

-----------------------------------------------

create proc dis_prachar_with_log_sp

(

	@app_id int,

	@user_id int,

	@prachar_type varchar(50),

	@idcard varchar(100)

)

as

begin

	

	insert into tbl_log

	values

	(

		@app_id,

		@idcard,

		@user_id,

		@prachar_type,

		dbo.get_date()

	)



	 SELECT

        p.id,

        CASE 

             WHEN p.prachar_type IN ('IMAGE', 'AUDIO', 'SELFIE', 'SLEEP','PRINT') 

                THEN dbo.get_server_path() + '/img/prachar/' + p.content

            ELSE p.content

        END AS content

    FROM tbl_prachar_master as p

    WHERE

        p.app_id = @app_id

        AND p.prachar_type = @prachar_type

        AND p.status = 1



end



------------------------------------------------

----------- Delete Prachar Content --------------

------------------------------------------------

CREATE PROC del_prachar_master_sp

(

    @app_id INT,

    @id INT,

    @delete_by INT

)

AS

BEGIN

    SET NOCOUNT ON;



    UPDATE tbl_prachar_master

    SET

        status = 0,

        delete_by = @delete_by,

        delete_date = dbo.get_date()

    WHERE

        id = @id

        AND app_id = @app_id



    SELECT 'ok';

END;







-------------------------------

--- Insert Surname Group ------

-------------------------------
CREATE OR ALTER PROCEDURE [dbo].[ins_surname_group_sp]
(
      @app_id        INT
    , @user_id       INT
    , @group_name    NVARCHAR(200) = NULL
    , @seed_surname  VARCHAR(100)  = NULL
    , @surname_list  VARCHAR(MAX)
    , @idcard_list   VARCHAR(MAX)  = NULL
    , @create_by     INT           = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Clean inputs
    SET @group_name   = LTRIM(RTRIM(ISNULL(@group_name, '')));
    SET @seed_surname = NULLIF(LTRIM(RTRIM(ISNULL(@seed_surname, ''))), '');
    SET @surname_list = NULLIF(LTRIM(RTRIM(ISNULL(@surname_list, ''))), '');
    SET @idcard_list  = NULLIF(LTRIM(RTRIM(ISNULL(@idcard_list, ''))), '');

    IF @create_by IS NULL
        SET @create_by = @user_id;

    -- 2. Stage split strings into clean temporary table variables
    DECLARE @ParsedSurnames TABLE (Surname VARCHAR(100) PRIMARY KEY);
    INSERT INTO @ParsedSurnames (Surname)
    SELECT DISTINCT LTRIM(RTRIM(s.Item))
    FROM dbo.SplitString(ISNULL(@surname_list, ''), ',') AS s
    WHERE s.Item IS NOT NULL AND LTRIM(RTRIM(s.Item)) <> '';

    -- Fallback for group name if it was empty
    IF @group_name = ''
    BEGIN
        SELECT TOP 1 @group_name = Surname FROM @ParsedSurnames;
        IF @group_name IS NULL OR @group_name = ''
            SET @group_name = N'Surname Group';
    END;

    DECLARE @group_id INT;
    DECLARE @now DATETIME = dbo.get_date();

    -- 3. Insert main parent group record
    INSERT INTO dbo.tbl_surname_group
    (
          app_id, user_id, group_name, seed_surname, surname_list
        , status, create_by, create_date
    )
    VALUES
    (
          @app_id, @user_id, @group_name, @seed_surname, ISNULL(@surname_list, '')
        , 1, @create_by, @now
    );

    SET @group_id = SCOPE_IDENTITY();

    -- 4. Insert child member details based on selection criteria
    IF @idcard_list IS NOT NULL
    BEGIN
        DECLARE @ParsedCards TABLE (IDCard VARCHAR(100) PRIMARY KEY);
        INSERT INTO @ParsedCards (IDCard)
        SELECT DISTINCT LTRIM(RTRIM(s.Item))
        FROM dbo.SplitString(@idcard_list, ',') AS s
        WHERE s.Item IS NOT NULL AND LTRIM(RTRIM(s.Item)) <> '';

        INSERT INTO dbo.tbl_surname_group_member
        (
              group_id, app_id, user_id, idcard_no
            , status, create_by, create_date
        )
        SELECT 
              @group_id, @app_id, @user_id, r.idcard_no, 1, @create_by, @now
        FROM @ParsedCards AS c
        INNER JOIN dbo.tbl_voting_record AS r 
            ON r.idcard_no = c.IDCard
           AND r.app_id = @app_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.tbl_surname_group_member
        (
              group_id, app_id, user_id, idcard_no
            , status, create_by, create_date
        )
        SELECT DISTINCT
              @group_id, @app_id, @user_id, r.idcard_no, 1, @create_by, @now
        FROM dbo.tbl_voting_record AS r
        INNER JOIN @ParsedSurnames AS s 
            ON r.eng_surname = s.Surname  
        WHERE r.app_id = @app_id
          AND r.idcard_no IS NOT NULL 
          AND r.idcard_no <> '';
    END;

    -- 5. Clean & Simple Update for User Total Count
    DELETE FROM dbo.tbl_user_surnamebook_count
    WHERE app_id = @app_id AND user_id = @user_id;

    INSERT INTO dbo.tbl_user_surnamebook_count (app_id, user_id, total_voter)
    SELECT
          @app_id
        , @user_id
        , COUNT(DISTINCT m.idcard_no)
    FROM dbo.tbl_surname_group_member AS m
    INNER JOIN dbo.tbl_surname_group AS g
        ON  g.group_id = m.group_id
        AND g.app_id   = m.app_id
    WHERE m.app_id = @app_id
      AND m.user_id = @user_id
      AND m.status = 1
      AND m.delete_by IS NULL
      AND g.status = 1
      AND g.delete_by IS NULL;

    -- 6. FINAL SINGLE RESULT SET (Always returns success data for C#)
    SELECT
          g.group_id
        , g.group_name
        , g.seed_surname
        , g.surname_list
        , g.create_date
        , v.id AS voter_id
        , v.slnoinpart
        , v.eng_f_name
        , v.f_eng_surname
        , v.eng_m_name
        , v.eng_surname
        , v.eng_localityid
        , v.eng_polling_location
        , v.idcard_no
        , RIGHT(RTRIM(v.contact_no), 10) AS contact_no
        , v.part_no
        , v.eng_house_no
    FROM dbo.tbl_surname_group AS g
    LEFT JOIN dbo.tbl_surname_group_member AS m
        ON  m.group_id = g.group_id
        AND m.status = 1
        AND m.delete_by IS NULL
    LEFT JOIN dbo.tbl_voting_record AS v
        ON  v.idcard_no = m.idcard_no
        AND v.app_id    = m.app_id
    WHERE g.group_id = @group_id
    ORDER BY TRY_CAST(v.slnoinpart AS INT);

END;
GO

--upd_surname_group_sp 3, 4, 10, 'Vaghasiya', 'Vaghasiya', 'VAGHASIYA', 'id1,id2', 4
CREATE OR ALTER PROCEDURE [dbo].[upd_surname_group_sp]
(
      @app_id        INT
    , @user_id       INT
    , @group_id      INT
    , @group_name    NVARCHAR(200) = NULL
    , @seed_surname  VARCHAR(100)  = NULL
    , @surname_list  VARCHAR(MAX)
    , @idcard_list   VARCHAR(MAX)  = NULL
    , @modify_by     INT           = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @group_name   = LTRIM(RTRIM(ISNULL(@group_name, '')));
    SET @seed_surname = NULLIF(LTRIM(RTRIM(ISNULL(@seed_surname, ''))), '');
    SET @surname_list = NULLIF(LTRIM(RTRIM(ISNULL(@surname_list, ''))), '');
    SET @idcard_list  = NULLIF(LTRIM(RTRIM(ISNULL(@idcard_list, ''))), '');

    IF @modify_by IS NULL
        SET @modify_by = @user_id;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.tbl_surname_group AS g
        WHERE g.group_id  = @group_id
          AND g.app_id    = @app_id
          AND g.user_id   = @user_id
          AND g.status    = 1
          AND g.delete_by IS NULL
    )
    BEGIN
        SELECT
              CAST(NULL AS INT)           AS group_id
            , CAST(NULL AS NVARCHAR(200)) AS group_name
            , CAST(NULL AS VARCHAR(100))  AS seed_surname
            , CAST(NULL AS VARCHAR(MAX))  AS surname_list
            , CAST(NULL AS DATETIME)      AS create_date
            , CAST(NULL AS INT)           AS voter_id
            , CAST(NULL AS VARCHAR(50))   AS slnoinpart
            , CAST(NULL AS VARCHAR(200))  AS eng_f_name
            , CAST(NULL AS VARCHAR(200))  AS f_eng_surname
            , CAST(NULL AS VARCHAR(200))  AS eng_m_name
            , CAST(NULL AS VARCHAR(200))  AS eng_surname
            , CAST(NULL AS VARCHAR(200))  AS eng_localityid
            , CAST(NULL AS VARCHAR(500))  AS eng_polling_location
            , CAST(NULL AS VARCHAR(50))   AS idcard_no
            , CAST(NULL AS VARCHAR(10))   AS contact_no
            , CAST(NULL AS VARCHAR(50))   AS part_no
            , CAST(NULL AS VARCHAR(200))  AS eng_house_no
        WHERE 1 = 0;
        RETURN;
    END;

    DECLARE @ParsedSurnames TABLE (Surname VARCHAR(100) PRIMARY KEY);
    INSERT INTO @ParsedSurnames (Surname)
    SELECT DISTINCT LTRIM(RTRIM(s.Item))
    FROM dbo.SplitString(ISNULL(@surname_list, ''), ',') AS s
    WHERE s.Item IS NOT NULL AND LTRIM(RTRIM(s.Item)) <> '';

    IF @group_name = ''
    BEGIN
        SELECT TOP 1 @group_name = Surname FROM @ParsedSurnames;
        IF @group_name IS NULL OR @group_name = ''
            SET @group_name = N'Surname Group';
    END;

    DECLARE @TargetCards TABLE (IDCard VARCHAR(100) PRIMARY KEY);
    DECLARE @now DATETIME = dbo.get_date();

    IF @idcard_list IS NOT NULL
    BEGIN
        INSERT INTO @TargetCards (IDCard)
        SELECT DISTINCT LTRIM(RTRIM(s.Item))
        FROM dbo.SplitString(@idcard_list, ',') AS s
        WHERE s.Item IS NOT NULL AND LTRIM(RTRIM(s.Item)) <> '';
    END
    ELSE
    BEGIN
        INSERT INTO @TargetCards (IDCard)
        SELECT DISTINCT r.idcard_no
        FROM dbo.tbl_voting_record AS r
        INNER JOIN @ParsedSurnames AS s
            ON r.eng_surname = s.Surname
        WHERE r.app_id = @app_id
          AND r.idcard_no IS NOT NULL
          AND r.idcard_no <> '';
    END;

    UPDATE dbo.tbl_surname_group
    SET
          group_name   = @group_name
        , seed_surname = @seed_surname
        , surname_list = ISNULL(@surname_list, '')
        , modify_by    = @modify_by
        , modify_date  = @now
    WHERE group_id  = @group_id
      AND app_id    = @app_id
      AND user_id   = @user_id
      AND status    = 1
      AND delete_by IS NULL;

    UPDATE m
    SET
          m.status      = 0
        , m.delete_by   = @modify_by
        , m.delete_date = @now
    FROM dbo.tbl_surname_group_member AS m
    WHERE m.group_id  = @group_id
      AND m.app_id    = @app_id
      AND m.user_id   = @user_id
      AND m.status    = 1
      AND m.delete_by IS NULL
      AND NOT EXISTS (
            SELECT 1
            FROM @TargetCards AS t
            WHERE t.IDCard = m.idcard_no
      );

    UPDATE m
    SET
          m.status      = 1
        , m.delete_by   = NULL
        , m.delete_date = NULL
        , m.modify_by   = @modify_by
        , m.modify_date = @now
    FROM dbo.tbl_surname_group_member AS m
    INNER JOIN @TargetCards AS t
        ON t.IDCard = m.idcard_no
    WHERE m.group_id = @group_id
      AND m.app_id   = @app_id
      AND m.user_id  = @user_id;

    INSERT INTO dbo.tbl_surname_group_member
    (
          group_id, app_id, user_id, idcard_no
        , status, create_by, create_date
    )
    SELECT
          @group_id, @app_id, @user_id, r.idcard_no, 1, @modify_by, @now
    FROM @TargetCards AS t
    INNER JOIN dbo.tbl_voting_record AS r
        ON r.idcard_no = t.IDCard
       AND r.app_id    = @app_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.tbl_surname_group_member AS m
        WHERE m.group_id  = @group_id
          AND m.idcard_no = t.IDCard
    );

    DELETE FROM dbo.tbl_user_surnamebook_count
    WHERE app_id = @app_id AND user_id = @user_id;

    INSERT INTO dbo.tbl_user_surnamebook_count (app_id, user_id, total_voter)
    SELECT
          @app_id
        , @user_id
        , COUNT(DISTINCT m.idcard_no)
    FROM dbo.tbl_surname_group_member AS m
    INNER JOIN dbo.tbl_surname_group AS g
        ON  g.group_id = m.group_id
        AND g.app_id   = m.app_id
    WHERE m.app_id = @app_id
      AND m.user_id = @user_id
      AND m.status = 1
      AND m.delete_by IS NULL
      AND g.status = 1
      AND g.delete_by IS NULL;

    SELECT
          g.group_id
        , g.group_name
        , g.seed_surname
        , g.surname_list
        , g.create_date
        , v.id AS voter_id
        , v.slnoinpart
        , v.eng_f_name
        , v.f_eng_surname
        , v.eng_m_name
        , v.eng_surname
        , v.eng_localityid
        , v.eng_polling_location
        , v.idcard_no
        , RIGHT(RTRIM(v.contact_no), 10) AS contact_no
        , v.part_no
        , v.eng_house_no
    FROM dbo.tbl_surname_group AS g
    LEFT JOIN dbo.tbl_surname_group_member AS m
        ON  m.group_id = g.group_id
        AND m.status = 1
        AND m.delete_by IS NULL
    LEFT JOIN dbo.tbl_voting_record AS v
        ON  v.idcard_no = m.idcard_no
        AND v.app_id    = m.app_id
    WHERE g.group_id = @group_id
    ORDER BY TRY_CAST(v.slnoinpart AS INT);
END;
GO

--dis_my_surname_group_sp 1, 12
CREATE OR ALTER PROCEDURE [dbo].[dis_my_surname_group_sp]
(
    @app_id  INT,
    @user_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          g.group_id
        , g.group_name AS surname
        , COUNT(m.idcard_no) AS voter_count
    FROM dbo.tbl_surname_group AS g
    LEFT JOIN dbo.tbl_surname_group_member AS m
        ON  m.group_id  = g.group_id
        AND m.app_id     = g.app_id
        AND m.status     = 1
        AND m.delete_by IS NULL
    WHERE g.app_id = @app_id
      AND g.user_id = @user_id
      AND g.status = 1
      AND g.delete_by IS NULL
    GROUP BY
          g.group_id
        , g.group_name
        , g.create_date
    ORDER BY
        g.create_date DESC;
END;
GO

--dis_surname_group_wise_voter_sp 1, 12, 5
CREATE OR ALTER PROCEDURE [dbo].[dis_surname_group_wise_voter_sp]
(
      @app_id   INT
    , @user_id  INT
    , @group_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          v.id
        , v.slnoinpart
        , v.eng_f_name
        , v.f_eng_surname
        , v.eng_m_name
        , v.eng_surname
        , v.eng_localityid
        , v.eng_polling_location
        , v.idcard_no
        , RIGHT(RTRIM(v.contact_no), 10) AS contact_no
        , v.part_no
        , v.eng_house_no
    FROM dbo.tbl_surname_group_member AS m
    INNER JOIN dbo.tbl_surname_group AS g
        ON  g.group_id = m.group_id
        AND g.app_id   = m.app_id
        AND g.user_id  = m.user_id
    INNER JOIN dbo.tbl_voting_record AS v
        ON  v.idcard_no = m.idcard_no
        AND v.app_id    = m.app_id
    WHERE g.app_id    = @app_id
      AND g.user_id   = @user_id
      AND g.group_id  = @group_id
      AND g.status    = 1
      AND g.delete_by IS NULL
      AND m.status    = 1
      AND m.delete_by IS NULL
    ORDER BY TRY_CAST(v.slnoinpart AS INT);
END;
GO

--dlt_surname_group_sp 1, 12, 5, 12
CREATE OR ALTER PROCEDURE [dbo].[dlt_surname_group_sp]
(
      @app_id    INT
    , @user_id   INT
    , @group_id  INT
    , @delete_by INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @delete_by IS NULL
        SET @delete_by = @user_id;

    DECLARE @now DATETIME = dbo.get_date();

    -- 1. Soft-delete members belonging to this group
    UPDATE dbo.tbl_surname_group_member
    SET
          status      = 0
        , delete_by   = @delete_by
        , delete_date = @now
    WHERE group_id  = @group_id
      AND app_id    = @app_id
      AND user_id   = @user_id
      AND status    = 1
      AND delete_by IS NULL;

    -- 2. Soft-delete the parent group record
    UPDATE dbo.tbl_surname_group
    SET
          status      = 0
        , delete_by   = @delete_by
        , delete_date = @now
    WHERE group_id  = @group_id
      AND app_id    = @app_id
      AND user_id   = @user_id
      AND status    = 1
      AND delete_by IS NULL;

    -- 3. Recalculate remaining active total voter count for the user
    DELETE FROM dbo.tbl_user_surnamebook_count
    WHERE app_id = @app_id AND user_id = @user_id;

    INSERT INTO dbo.tbl_user_surnamebook_count (app_id, user_id, total_voter)
    SELECT
          @app_id
        , @user_id
        , COUNT(DISTINCT m.idcard_no)
    FROM dbo.tbl_surname_group_member AS m
    INNER JOIN dbo.tbl_surname_group AS g
        ON  g.group_id = m.group_id
        AND g.app_id   = m.app_id
    WHERE m.app_id = @app_id
      AND m.user_id = @user_id
      AND m.status = 1
      AND m.delete_by IS NULL
      AND g.status = 1
      AND g.delete_by IS NULL;

    -- 4. Clean web service response
    SELECT 'ok';
END;
GO

--dis_surname_group_edit_sp 3, 4, 10
CREATE OR ALTER PROCEDURE [dbo].[dis_surname_group_edit_sp]
(
      @app_id   INT
    , @user_id  INT
    , @group_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @surname_list VARCHAR(MAX);

    SELECT @surname_list = g.surname_list
    FROM dbo.tbl_surname_group AS g
    WHERE g.group_id  = @group_id
      AND g.app_id    = @app_id
      AND g.user_id   = @user_id
      AND g.status    = 1
      AND g.delete_by IS NULL;

    IF @surname_list IS NULL
    BEGIN
        SELECT
              CAST(NULL AS INT)          AS voter_id
            , CAST(NULL AS VARCHAR(50))  AS slnoinpart
            , CAST(NULL AS VARCHAR(200)) AS eng_f_name
            , CAST(NULL AS VARCHAR(200)) AS f_eng_surname
            , CAST(NULL AS VARCHAR(200)) AS eng_m_name
            , CAST(NULL AS VARCHAR(200)) AS eng_surname
            , CAST(NULL AS VARCHAR(50))  AS idcard_no
            , CAST(NULL AS VARCHAR(10))  AS contact_no
            , CAST(NULL AS VARCHAR(50))  AS part_no
            , CAST(0 AS BIT)             AS is_member
        WHERE 1 = 0;
        RETURN;
    END;

    DECLARE @ParsedSurnames TABLE (Surname VARCHAR(100) PRIMARY KEY);
    INSERT INTO @ParsedSurnames (Surname)
    SELECT DISTINCT LTRIM(RTRIM(s.Item))
    FROM dbo.SplitString(@surname_list, ',') AS s
    WHERE s.Item IS NOT NULL
      AND LTRIM(RTRIM(s.Item)) <> '';

    SELECT
          v.id AS voter_id
        , v.slnoinpart
        , v.eng_f_name
        , v.f_eng_surname
        , v.eng_m_name
        , v.eng_surname
        , v.idcard_no
        , RIGHT(RTRIM(v.contact_no), 10) AS contact_no
        , v.part_no
        , CASE
            WHEN m.id IS NOT NULL THEN 1
            ELSE 0
          END AS is_member
    FROM dbo.tbl_surname_group AS g
    INNER JOIN dbo.tbl_voting_record AS v
        ON  v.app_id = g.app_id
    INNER JOIN @ParsedSurnames AS s
        ON  v.eng_surname = s.Surname
    LEFT JOIN dbo.tbl_surname_group_member AS m
        ON  m.group_id  = g.group_id
        AND m.idcard_no = v.idcard_no
        AND m.app_id    = g.app_id
        AND m.status    = 1
        AND m.delete_by IS NULL
    WHERE g.group_id   = @group_id
      AND g.app_id     = @app_id
      AND g.user_id    = @user_id
      AND g.status     = 1
      AND g.delete_by IS NULL
      AND v.idcard_no IS NOT NULL
      AND v.idcard_no  <> ''
    ORDER BY
          is_member DESC
        , TRY_CAST(v.slnoinpart AS INT);
END;
GO




-------------------------------

--- Display Surname Group -----

-------------------------------

create proc dis_surname_group_sp

(

	@app_id int,

	@user_id int

)

as

begin



select 

	v.id,

	v.slnoinpart,

	v.eng_f_name,

	v.f_eng_surname,

	v.eng_m_name,

	v.eng_surname,

	v.eng_localityid,

	v.eng_polling_location,

	v.idcard_no,

	v.contact_no,

	v.part_no,

	v.eng_house_no

from 

	tbl_surname_group as s

	join tbl_voting_record as v

on

	s.idcard=v.idcard_no

where

	s.user_id=@user_id

	and s.app_id=@app_id

	and s.idcard!=''

end



-------------------------------

--- Display Surname Group -----

-------------------------------

create proc dis_surname_match_admin_sp

(

	@app_id int

)

as

begin

select

	u.user_id,

	u.user_type,

	dbo.fn_get_designation(u.[user_type]) AS designation,

	u.name,

	u.mobile_no,

	case isnull(photo,'') when '' then '' else dbo.get_server_path()+'img/admin/'+isnull(photo,'') end as photo_path,

	sg.total_voter as total_surname_member

from

	tbl_user_surnamebook_count as sg

	join tbl_user as u

on

	sg.user_id=u.user_id

	and sg.app_id=u.app_id

where

	u.status=1

	and sg.total_voter>0

	and sg.app_id=@app_id

order by 

	sg.total_voter desc

end







-----------------------------------------------

--------- No PhoneBook Match User -------------

-----------------------------------------------

alter proc dis_no_phonebook_match_user_sp

(

	@app_id int

)

as

begin

	

	SET NOCOUNT ON;



	select

		u.user_id,

		u.name,

		u.booth_no,

		u.user_type,

		COALESCE(u.mobile_no,'') as mobile_no,

		case u.photo when '' then dbo.get_server_path()+'img/admin/user.png' else dbo.get_server_path()+'img/admin/'+u.photo end as [image],

		format(u.last_login,'dd MMM, yyyy hh:mm tt') as last_login

	from

		tbl_user as u

		left join tbl_contact_group as c

	on

		u.user_id=c.user_id

		and u.app_id=c.app_id

	where

		u.status=1

		and u.app_id=@app_id

		and c.id is null

end





-------------------------------

--- sleep distribution count --

-------------------------------

create proc dis_booth_wise_phonebook_sp

(

	@app_id int

)

as

begin

select	

	r.part_no as booth_no,

	count(distinct c.idcard_no) as total

from 

	tbl_contact_group as c

	join tbl_user as u

on

	c.user_id=u.user_id

	and c.app_id=u.app_id

	join tbl_voting_record as r

on

	c.idcard_no=r.idcard_no

	and c.app_id=r.app_id

where

	u.status=1

	and c.app_id=@app_id

	and c.idcard_no!=''

group by

	r.part_no

order by

	cast(r.part_no as int)

end



-------------------------------

--- sleep distribution count --

-------------------------------

alter proc dis_booth_wise_phonebook_member_sp

(

	@app_id int,

	@booth_no int

)

as

begin



 SET NOCOUNT ON;



select 

	v.id,

	v.slnoinpart,

	v.eng_f_name,

	v.f_eng_surname,

	v.eng_m_name,

	v.eng_surname,

	v.eng_localityid,

	v.eng_polling_location,

	v.idcard_no,

	v.contact_no,

	v.part_no,

	v.eng_house_no

from 

	tbl_contact_group as gm	

	join tbl_voting_record as v

on

	gm.idcard_no=v.idcard_no

	and gm.app_id=v.app_id

where

	v.part_no=@booth_no

	and gm.app_id=@app_id

	and gm.idcard_no!=''

group by

	v.id,

	v.slnoinpart,

	v.eng_f_name,

	v.f_eng_surname,

	v.eng_m_name,

	v.eng_surname,

	v.eng_localityid,

	v.eng_polling_location,

	v.idcard_no,

	v.contact_no,

	v.part_no,

	v.eng_house_no

end







-------------------------------

--- Display Surname Group -----

-------------------------------
--dis_admin_dash_sp 1,1
alter proc dis_admin_dash_sp

( 

	@app_id int,

	@user_id int

)

as

begin

SET NOCOUNT ON;



;with

contact as (select COUNT(c.user_id) as contact_group_user from tbl_user_phonebook_count as c join tbl_user as u on c.user_id=u.user_id and c.app_id=u.app_id where u.status=1 and c.app_id=@app_id),

surname as (select COUNT(c.user_id) as surname_group_user from dbo.tbl_user_surnamebook_count as c join dbo.tbl_user as u on c.user_id = u.user_id and c.app_id = u.app_id where u.status = 1 and c.app_id = @app_id),

member_group as(select COUNT(distinct c.user_id) as member_group_user from tbl_my_group as c join tbl_user as u on c.user_id=u.user_id and c.app_id=u.app_id where u.status=1  and c.app_id=@app_id),

slip_send_user as (select count(distinct s.user_id) as slip_send_user from vw_get_user_wise_uniq_sleep_send as s join tbl_user as u on s.user_id=u.user_id and s.app_id=u.app_id where u.status=1 and s.app_id=@app_id)



select contact_group_user,surname_group_user,member_group_user,slip_send_user from contact,surname,member_group,slip_send_user





;with

contact as (select COUNT(user_id) as contact_group from tbl_contact_group where user_id=@user_id and app_id=@app_id),

surname as (select ISNULL((select c.total_voter from dbo.tbl_user_surnamebook_count as c where c.user_id = @user_id and c.app_id = @app_id), 0) as surname_group),

my_member as(select count(user_id) as my_member from tbl_my_group where user_id=@user_id and app_id=@app_id),

slip_send as(select count(user_id) as slip_send from vw_get_user_wise_uniq_sleep_send where user_id=@user_id and app_id=@app_id)

select contact_group,surname_group,my_member,slip_send from contact,surname,my_member,slip_send

SELECT COUNT(DISTINCT idcard_no) AS total_confirm_voter
FROM (
    SELECT idcard_no
    FROM dbo.tbl_contact_group
    WHERE app_id = @app_id
      AND idcard_no IS NOT NULL
      AND idcard_no <> ''

    UNION

    SELECT m.idcard_no
    FROM dbo.tbl_surname_group_member AS m
    INNER JOIN dbo.tbl_surname_group AS g
        ON  g.group_id = m.group_id
        AND g.app_id   = m.app_id
    WHERE g.app_id = @app_id
      AND m.status = 1
      AND m.delete_by IS NULL
      AND g.status = 1
      AND g.delete_by IS NULL
      AND m.idcard_no IS NOT NULL
      AND m.idcard_no <> ''

    UNION

    SELECT idcard AS idcard_no
    FROM dbo.tbl_my_group
    WHERE app_id = @app_id
      AND idcard IS NOT NULL
      AND idcard <> ''
) AS CombinedGroups;


select
	title,
	content,
	show_status,
	CASE media_type 
        WHEN 'i' THEN dbo.get_server_path() + 'img/popup/images/' + m.media_url 
        WHEN 'a' THEN dbo.get_server_path() + 'img/popup/audio/' + m.media_url 
        ELSE m.media_url -- YouTube, FB વગેરે ડાયરેક્ટ લિંક્સ માટે બેકઅપ
    END AS media_url_path
from
	tbl_PopupAlert as p
	join tbl_PopupAlertMedia as m on p.popup_id=m.popup_id and m.status=1
where
	p.status=1
	and p.is_active=1
	and p.app_id=@app_id

end









-------------------------------

--- Display Surname Group -----

-------------------------------

create proc change_profile_photo_sp

(

	@user_id int,

	@Photo varchar(max)

)

as

begin

	update

		tbl_user

	set

		photo=@Photo

	where

		user_id=@user_id



	select 'ok'

end







-----------------------------------------------------
------- Print Receipt in All Family -----------------
-----------------------------------------------------
--print_bulk_receipt_in_printer_sp 1,1,1
ALTER proc print_bulk_receipt_in_printer_sp

(

	@app_id int,

	@booth_no int,

	@user_id int

)

as

begin

select 

	v.ac_no,
	v.part_no,
	v.slnoinpart,
	v.idcard_no as idcard_no_only, 
	N'નામ :'+(isnull(v.f_name,'')+' '+isnull(v.f_surname,'')) as full_name,

	N'પિતા/પતિ : '+isnull(v.m_name,'')+''+isnull(v.surname,'')+' ('+isnull(v.eng_m_name,'')+' '+isnull(v.eng_surname,'')+')' as middle_name,

	N'જાતિ/ઉમર : '+(case isnull(v.sex,'') when 'M' Then N'પુરુષ' when 'F' then  N'સ્ત્રી' else '' end+'/'+isnull(v.age,'')) as sex_age,

	(N'આઇડિકાર્ડ : '+isnull(v.idcard_no,'-')) as idcard_no,

	N'મતદાન સ્થળ : '+v.polling_location	 as polling_location

from 

	tbl_voting_record as v

where

	v.part_no=@booth_no

	and v.app_id=@app_id 





select 

	dbo.get_server_path() + '/img/prachar/' + content  as img

from 

	tbl_prachar_master

where 

	app_id=@app_id 

	and prachar_type='PRINT' and status=1

select 
	a.vidhansabha_no,
	a.vidhansabha_name,
	a.candidate_name,
	a.party_full_name,
	a.party_logo_png
from 
	tbl_app as a
where 
	a.app_id = @app_id

end

ALTER proc [dbo].[print_receipt_in_printer_sp]
(
	@app_id int,
	@voter_id int,
	@idcard_no varchar(30),
	@user_id int
)
as
begin

--insert into tbl_log
--values
--(
--	@app_id,
--	@idcard_no,
--	@user_id,
--	'P_SLEEP',
--	dbo.get_date()
--)


select
	v.ac_no,
	v.part_no,
	v.slnoinpart,
	v.idcard_no as idcard_no_only, 
	(N'ભાગ નં - '+cast(v.ac_no as varchar(10))+N'    બૂથ નં - '+cast(v.part_no as varchar(10))+N'    ક્રમ નં. - '+cast(v.slnoinpart as varchar(10))) as first_detail,
	N'નામ :'+(isnull(v.f_name,'')+' '+isnull(v.f_surname,'')) as full_name,
	N'પિતા/પતિ : '+isnull(v.m_name,'')+''+isnull(v.surname,'')+' ('+isnull(v.eng_m_name,'')+' '+isnull(v.eng_surname,'')+')' as middle_name,
	N'જાતિ/ઉમર : '+(case isnull(v.sex,'') when 'M' Then N'પુરુષ' when 'F' then  N'સ્ત્રી' else '' end+'/'+isnull(v.age,'')) as sex_age,
	(N'આઇડિકાર્ડ : '+isnull(v.idcard_no,'-')) as idcard_no,
	N'મતદાન સ્થળ : '+v.polling_location	 as polling_location
from 
	tbl_voting_record as v
where
	v.id=@voter_id
	and v.app_id=@app_id 


select 
	dbo.get_server_path() + '/img/prachar/' + content  as img
from 
	tbl_prachar_master
where 
	app_id=@app_id 
	and prachar_type='PRINT' and status=1
	
end



-----------------------------------------------------
------- Print Receipt in All Family -----------------
-----------------------------------------------------

--[get_receipt_in_all_family_for_wtsp_sp] 1,1,1

alter proc [dbo].[get_receipt_in_all_family_for_wtsp_sp]

(

	@app_id int,

	@voter_id int,

	@user_id int

)

as

begin



declare @family_id int = (select family_id from tbl_voting_record where id=@voter_id and app_id=@app_id)



SELECT 

    v.id,

	v.ac_no,

    v.idcard_no,

    v.part_no,

    v.slnoinpart,

    v.f_name,

    v.f_surname,

    v.eng_f_name,

    v.f_eng_surname,

    v.m_name,

    v.surname,

    v.eng_m_name,

    v.eng_surname,

    v.sex,

    v.age,

    v.polling_location,

    v.eng_polling_location

INTO #FamilyVoters

FROM tbl_voting_record AS v

WHERE 

	v.app_id = @app_id

	and v.family_id=@family_id



-- 2. Show voter data

SELECT TOP 30

    id,

  	(N'ભાગ નં - '+cast(v.ac_no as varchar(10))+N'    બૂથ નં - '+cast(v.part_no as varchar(10))+N'    ક્રમ નં. - '+cast(v.slnoinpart as varchar(10))) as first_detail,

	N'નામ :'+(isnull(v.f_name,'')+' '+isnull(v.f_surname,'')) as full_name,

	N'પિતા/પતિ : '+isnull(v.m_name,'')+''+isnull(v.surname,'')+' ('+isnull(v.eng_m_name,'')+' '+isnull(v.eng_surname,'')+')' as middle_name,

	N'જાતિ/ઉમર : '+(case isnull(v.sex,'') when 'M' Then N'પુરુષ' when 'F' then  N'સ્ત્રી' else '' end+'/'+isnull(v.age,'')) as sex_age,

	(N'આઇડિકાર્ડ : '+isnull(v.idcard_no,'-')) as idcard_no,

	N'મતદાન સ્થળ : '+v.polling_location	 as polling_location,

    isnull(eng_polling_location,'') as eng_polling_location,

    '' AS ele_date

FROM #FamilyVoters as v

ORDER BY slnoinpart;





-- 3. Insert logs

INSERT INTO tbl_log

SELECT 

	@app_id,

	idcard_no,

    @user_id,

    'W_SLEEP',

    dbo.get_date()

FROM #FamilyVoters;



-- 4. Clean up

DROP TABLE #FamilyVoters;



select 

	dbo.get_server_path() + '/img/prachar/' + content  as img

from 

	tbl_prachar_master

where 

	app_id=@app_id 

	and prachar_type='SLEEP' and status=1

end



-----------------------------------------------------

------- Print Receipt in All Family -----------------

-----------------------------------------------------

--get_receipt_in_all_family_for_web_sleep_sp 1,'JWH4355426',1

alter proc [dbo].[get_receipt_in_all_family_for_web_sleep_sp]

(

	@app_id int,

	@idcard varchar(30),

	@user_id int

)

as

begin



declare @family_id int = (select family_id from tbl_voting_record where idcard_no=@idcard and app_id=@app_id)



SELECT 

    v.id,

	v.ac_no,

    v.idcard_no,

    v.part_no,

    v.slnoinpart,

    v.f_name,

    v.f_surname,

    v.eng_f_name,

    v.f_eng_surname,

    v.m_name,

    v.surname,

    v.eng_m_name,

    v.eng_surname,

    v.sex,

    v.age,

    v.polling_location,

    v.eng_polling_location

INTO #FamilyVoters

FROM tbl_voting_record AS v

WHERE 

	v.app_id = @app_id

	and v.family_id=@family_id



-- 2. Show voter data

SELECT TOP 30

    id,

	ac_no,

	part_no,

	slnoinpart,

    N'' + ISNULL(f_name, '') + ' ' + ISNULL(f_surname, '')  AS full_name,

    N'' + ISNULL(m_name, '') + ' ' + ISNULL(surname, '')  AS middle_name,

    N'' + (CASE ISNULL(sex, '') WHEN 'M' THEN N'પુરુષ' WHEN 'F' THEN N'સ્ત્રી' ELSE '' END + '/' + ISNULL(age, '')) AS sex_age,

    (N'' + ISNULL(idcard_no, '-')) AS idcard_no,

    N'' + ISNULL(polling_location, '') AS polling_location,

    isnull(eng_polling_location,'') as eng_polling_location,

    '' AS ele_date

FROM #FamilyVoters

ORDER BY slnoinpart;





---- 3. Insert logs

--INSERT INTO tbl_log

--SELECT 

--	@app_id,

--	idcard_no,

--    @user_id,

--    'SLEEP',

--    dbo.get_date()

--FROM #FamilyVoters;



-- 4. Clean up

DROP TABLE #FamilyVoters;



select 

	dbo.get_server_path() + '/img/prachar/' + content  as img

from 

	tbl_prachar_master

where 

	app_id=@app_id 

	and prachar_type='SLEEP' and status=1

end



-----------------------------------------------------

------- Print Receipt in All Family -----------------

-----------------------------------------------------
--[get_receipt_in_single_for_wtsp_sp] 1,1,1
alter proc [dbo].[get_receipt_in_single_for_wtsp_sp]

(

	@app_id int,

	@voter_id int,

	@user_id int

)

as

begin





insert into tbl_log

select 

	@app_id,

	v.idcard_no,

	@user_id,

	'W_SLEEP',

	dbo.get_date()

from 

	tbl_voting_record as v

where

	v.id=@voter_id



select 

	(N'ભાગ નં - '+cast(v.ac_no as varchar(10))+N'    બૂથ નં - '+cast(v.part_no as varchar(10))+N'    ક્રમ નં. - '+cast(v.slnoinpart as varchar(10))) as first_detail,

	N'નામ :'+(isnull(v.f_name,'')+' '+isnull(v.f_surname,'')) as full_name,

	N'પિતા/પતિ : '+isnull(v.m_name,'')+''+isnull(v.surname,'')+' ('+isnull(v.eng_m_name,'')+' '+isnull(v.eng_surname,'')+')' as middle_name,

	N'જાતિ/ઉમર : '+(case isnull(v.sex,'') when 'M' Then N'પુરુષ' when 'F' then  N'સ્ત્રી' else '' end+'/'+isnull(v.age,'')) as sex_age,

	(N'આઇડિકાર્ડ : '+isnull(v.idcard_no,'-')) as idcard_no,

	N'મતદાન સ્થળ : '+v.polling_location	 as polling_location,

	v.eng_polling_location,



	'' as ele_date

from 

	tbl_voting_record as v

where

	v.id=@voter_id

	

select 

	dbo.get_server_path() + '/img/prachar/' + content  as img

from 

	tbl_prachar_master

where 

	app_id=@app_id 

	and prachar_type='SLEEP' and status=1

end



-----------------------------------------------------

------- Print Receipt in All Family -----------------

-----------------------------------------------------
--[get_receipt_in_single_for_wtsp_sp] 1,1,1
alter proc ins_sleep_log_sp

(

	@app_id int,

	@voter_id varchar(max),

	@user_id int

)

as

begin

SET NOCOUNT ON;



insert into tbl_log

select 

	@app_id,

	s.Item,

	@user_id,

	'W_SLEEP',

	dbo.get_date()

from 

	dbo.SplitString(ISNULL(@voter_id, ''), ',') as s

where

	s.Item!=''


select 

	dbo.get_server_path() + '/img/prachar/' + content  as img

from 

	tbl_prachar_master

where 

	app_id=@app_id 

	and prachar_type='SLEEP' and status=1

end


-----------------------------------------------------

------- Print Receipt in All Family -----------------

-----------------------------------------------------
--[get_receipt_in_single_for_wtsp_sp] 1,1,1
alter proc [dbo].[get_receipt_in_single_for_wtsp_sp]

(

	@app_id int,

	@voter_id int,

	@user_id int

)

as

begin





insert into tbl_log

select 

	@app_id,

	v.idcard_no,

	@user_id,

	'W_SLEEP',

	dbo.get_date()

from 

	tbl_voting_record as v

where

	v.id=@voter_id



end


-----------------------------------------------------

------- Print Receipt in All Family -----------------

-----------------------------------------------------

create proc dis_family_member_sp

(

	@app_id int,

	@voter_id int

)

as

begin

declare @family_id int = (select family_id from tbl_voting_record where id=@voter_id and app_id=@app_id)



SELECT 

    v.id,

	v.ac_no,

    v.idcard_no,

    v.part_no,

    v.slnoinpart,

    v.f_name,

    v.f_surname,

    v.eng_f_name,

    v.f_eng_surname,

    v.m_name,

    v.surname,

    v.eng_m_name,

    v.eng_surname,

    v.sex,

    v.age,

    v.polling_location,

    v.eng_polling_location

FROM tbl_voting_record AS v

WHERE 

	v.app_id = @app_id

	and v.family_id=@family_id

end





 

-----------------------------------------------------

------- Print Receipt in All Family -----------------

-----------------------------------------------------

alter proc [dbo].[get_receipt_in_single_for_sms_sp]

(

	@app_id int,

	@voter_id int,

	@user_id int

)

as

begin





insert into tbl_log

select 

	@app_id,

	v.idcard_no,

	@user_id,

	'SMS SLEEP',

	dbo.get_date()

from 

	tbl_voting_record as v

where

	v.id=@voter_id



select 

	(N'ભાગ નં - '+cast(v.ac_no as varchar(10))+N'    બૂથ નં - '+cast(v.part_no as varchar(10))+N'    ક્રમ નં. - '+cast(v.slnoinpart as varchar(10))) as first_detail,

	N'નામ :'+(isnull(v.f_name,'')+' '+isnull(v.f_surname,'')) as full_name,

	N'પિતા/પતિ : '+isnull(v.m_name,'')+''+isnull(v.surname,'')+' ('+isnull(v.eng_m_name,'')+' '+isnull(v.eng_surname,'')+')' as middle_name,

	N'જાતિ/ઉમર : '+(case isnull(v.sex,'') when 'M' Then N'પુરુષ' when 'F' then  N'સ્ત્રી' else '' end+'/'+isnull(v.age,'')) as sex_age,

	(N'આઇડિકાર્ડ : '+isnull(v.idcard_no,'-')) as idcard_no,

	N'મતદાન સ્થળ : '+v.polling_location	 as polling_location,

	v.eng_polling_location,



	'' as ele_date

from 

	tbl_voting_record as v

where

	v.id=@voter_id

	



end



-----------------------------------------------------

------- Print Receipt in All Family -----------------

-----------------------------------------------------

alter proc [dbo].[get_receipt_in_all_family_for_sms_sp]

(

	@app_id int,

	@voter_id int,

	@user_id int

)

as

begin



declare @family_id int = (select family_id from tbl_voting_record where id=@voter_id and app_id=@app_id)



SELECT 

    v.id,

	v.ac_no,

    v.idcard_no,

    v.part_no,

    v.slnoinpart,

    v.f_name,

    v.f_surname,

    v.eng_f_name,

    v.f_eng_surname,

    v.m_name,

    v.surname,

    v.eng_m_name,

    v.eng_surname,

    v.sex,

    v.age,

    v.polling_location,

    v.eng_polling_location

INTO #FamilyVoters

FROM tbl_voting_record AS v

WHERE 

	v.app_id = @app_id

	and v.family_id=@family_id



-- 2. Show voter data

SELECT TOP 30

    id,

    (N'ભાગ નં - '+cast(v.ac_no as varchar(10))+N'    બૂથ નં - '+cast(v.part_no as varchar(10))+N'    ક્રમ નં. - '+cast(v.slnoinpart as varchar(10))) as first_detail,

	N'નામ :'+(isnull(v.f_name,'')+' '+isnull(v.f_surname,'')) as full_name,

	N'પિતા/પતિ : '+isnull(v.m_name,'')+''+isnull(v.surname,'')+' ('+isnull(v.eng_m_name,'')+' '+isnull(v.eng_surname,'')+')' as middle_name,

	N'જાતિ/ઉમર : '+(case isnull(v.sex,'') when 'M' Then N'પુરુષ' when 'F' then  N'સ્ત્રી' else '' end+'/'+isnull(v.age,'')) as sex_age,

	(N'આઇડિકાર્ડ : '+isnull(v.idcard_no,'-')) as idcard_no,

	N'મતદાન સ્થળ : '+v.polling_location	 as polling_location,

	v.eng_polling_location,



	'' as ele_date

FROM #FamilyVoters as v

ORDER BY slnoinpart;





-- 3. Insert logs

INSERT INTO tbl_log

SELECT 

	@app_id,

	idcard_no,

    @user_id,

    'SMS SLEEP',

    dbo.get_date()

FROM #FamilyVoters;



-- 4. Clean up

DROP TABLE #FamilyVoters;



end





--------------------------------------------

--------- Insert Voter Visit ---------------

--------------------------------------------

create proc ins_log_sp

(

	@app_id int,

	@user_id int,

	@idcard varchar(50),

	@prachar_type varchar(10)

)

as

begin

	

	insert into tbl_log

	values

	(

		@app_id,

		@idcard,

		@user_id,

		@prachar_type,

		dbo.get_date()

	)

	

	select 'ok'

end







-------------------------------

--- Display Surname Group -----

-------------------------------

create proc change_user_temp_status_sp

(

	@app_id int,

	@user_id int,

	@modify_by int

)

as

begin

	update

		tbl_user

	set

		temp_status=case temp_status when 1 then 0 else 1 end,

		modify_by=@modify_by,

		modify_date=dbo.get_date()

	where

		user_id=@user_id

		and app_id=@app_id



	select 'ok'

end



ALTER PROCEDURE [dbo].[ins_voter_survey]

(

    @app_id INT,

    @voter_idcard VARCHAR(30),

    @booth_no INT = NULL,

    @survey_by INT,

    @survey_by_designation VARCHAR(30),

    @voter_available BIT,

    @not_available_reason VARCHAR(50) = NULL,

    @not_available_note NVARCHAR(500) = NULL,

    @contact_no VARCHAR(20) = NULL,

    @voter_status VARCHAR(20) = NULL,

    @note NVARCHAR(MAX) = NULL,

    @lat_long VARCHAR(200) = NULL,

    @visit_location NVARCHAR(500) = NULL

)

AS

BEGIN

    SET NOCOUNT ON;



    BEGIN TRY

        BEGIN TRAN;



        UPDATE tbl_voter_survey

        SET is_latest = 0

        WHERE app_id = @app_id

          AND voter_idcard = @voter_idcard

          AND is_latest = 1;



        INSERT INTO tbl_voter_survey

        (

            app_id,

            voter_idcard,

            booth_no,

            survey_by,

            survey_by_designation,

            voter_available,

            not_available_reason,

            not_available_note,

            contact_no,

            voter_status,

            note,

            visit_count,

            is_latest,

            lat_long,

            visit_location

        )

        VALUES

        (

            @app_id,

            @voter_idcard,

            @booth_no,

            @survey_by,

            @survey_by_designation,

            @voter_available,

            @not_available_reason,

            @not_available_note,

            @contact_no,

            @voter_status,

            @note,

            ISNULL(

                (

                    SELECT MAX(visit_count)

                    FROM tbl_voter_survey

                    WHERE app_id = @app_id

                      AND voter_idcard = @voter_idcard

                ),

                0

            ) + 1,

            1,

            @lat_long,

            @visit_location

        );



        COMMIT;

    END TRY

    BEGIN CATCH

        ROLLBACK;

        THROW;

    END CATCH



	select 'ok'

END;



--[dis_survey_dash_for_admin_sp] 1,''
ALTER PROCEDURE [dbo].[dis_survey_dash_for_admin_sp]
(
      @app_id    INT
    , @survey_by VARCHAR(50) = NULL -- 'Party Cadre', 'Personal Cadre', 'Call Center', or NULL/blank
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @survey_by = NULLIF(LTRIM(RTRIM(@survey_by)), '');

    DECLARE @dash TABLE
    (
        total_survey  BIGINT NOT NULL,
        not_available BIGINT NOT NULL,
        p             BIGINT NOT NULL,
        n             BIGINT NOT NULL,
        d             BIGINT NOT NULL,
        c             BIGINT NOT NULL
    );

    INSERT INTO @dash (total_survey, not_available, p, n, d, c)
    SELECT
        COUNT_BIG(1),
        ISNULL(SUM(CASE WHEN voter_available = 0 THEN 1 ELSE 0 END), 0),
        ISNULL(SUM(CASE WHEN voter_available = 1 AND voter_status = 'P' THEN 1 ELSE 0 END), 0),
        ISNULL(SUM(CASE WHEN voter_available = 1 AND voter_status = 'N' THEN 1 ELSE 0 END), 0),
        ISNULL(SUM(CASE WHEN voter_available = 1 AND voter_status = 'D' THEN 1 ELSE 0 END), 0),
        ISNULL(SUM(CASE WHEN voter_available = 1 AND voter_status = 'C' THEN 1 ELSE 0 END), 0)
    FROM dbo.tbl_voter_survey
    WHERE app_id = @app_id
      AND is_latest = 1
      AND status = 1
      AND (
            @survey_by IS NULL
            OR (@survey_by = 'Party Cadre' AND survey_by_designation IN ('SP', 'BP', 'K', 'BS'))
            OR (@survey_by = 'Personal Cadre' AND survey_by_designation IN ('WP', 'VC', 'BC'))
            OR (@survey_by = 'Call Center' AND survey_by_designation = 'CL')
          );

    -- Result set 1: total survey count
    SELECT p+n+d+c as total_survey FROM @dash;

    -- Result set 2: P / N / D / C + not available
    SELECT p, n, d, c, not_available FROM @dash;

END;
GO


--[dis_survey_dash_for_admin_sp] 1,''
create PROCEDURE [dbo].[dis_survey_dash_for_sakti_and_warroom_sp]
(
    @app_id    INT,
    @booth_no varchar(500)
)
AS
BEGIN
  SET NOCOUNT ON;

    

    DECLARE @dash TABLE
    (
        total_survey  BIGINT NOT NULL,
        not_available BIGINT NOT NULL,
        p             BIGINT NOT NULL,
        n             BIGINT NOT NULL,
        d             BIGINT NOT NULL,
        c             BIGINT NOT NULL
    );

    INSERT INTO @dash (total_survey, not_available, p, n, d, c)
    SELECT
        COUNT_BIG(1),
        ISNULL(SUM(CASE WHEN voter_available = 0 THEN 1 ELSE 0 END), 0),
        ISNULL(SUM(CASE WHEN voter_available = 1 AND voter_status = 'P' THEN 1 ELSE 0 END), 0),
        ISNULL(SUM(CASE WHEN voter_available = 1 AND voter_status = 'N' THEN 1 ELSE 0 END), 0),
        ISNULL(SUM(CASE WHEN voter_available = 1 AND voter_status = 'D' THEN 1 ELSE 0 END), 0),
        ISNULL(SUM(CASE WHEN voter_available = 1 AND voter_status = 'C' THEN 1 ELSE 0 END), 0)
    FROM dbo.tbl_voter_survey as v
	join dbo.SplitString(@booth_no,',') as b on v.booth_no=b.Item
    WHERE app_id = @app_id
      AND is_latest = 1
      AND status = 1
     

    -- Result set 1: total survey count
    SELECT p+n+d+c as total_survey FROM @dash;

    -- Result set 2: P / N / D / C + not available
    SELECT p, n, d, c, not_available FROM @dash;

END;
GO


dis_boothpramukh_survey_dashboard_sp 1,1
alter proc dis_boothpramukh_survey_dashboard_sp

(

	@app_id INT,

	@booth_no int

)

as

begin


SELECT

    COUNT(1) AS total_survey,

    SUM(CASE WHEN voter_available = 0 THEN 1 ELSE 0 END) AS not_available

FROM 

	vw_uniq_voter_survey 

where 

	app_id=@app_id

	and booth_no=@booth_no;





SELECT

    ISNULL(P, 0)  AS p,

    ISNULL(N, 0)   AS n,

    ISNULL(D, 0)  AS d,

	ISNULL(C, 0)  AS c

FROM

(

    SELECT

        s.voter_status

    FROM vw_uniq_voter_survey AS s

    WHERE

        s.app_id = @app_id

		and booth_no=@booth_no

        AND s.voter_available = 1

) AS src

PIVOT

(

    COUNT(voter_status)

    FOR voter_status IN (P, N, D,C)

) AS p;



end







-----------------------------------

------ Booth Wise Survey ----------

-----------------------------------

--dis_booth_wise_survey_dash_sp 1

alter proc dis_booth_wise_survey_dash_sp

(

	 @app_id int

)

as

begin

;WITH s AS

(

    SELECT

        s.booth_no,

        CASE 

            WHEN s.voter_available = 0 THEN 'NA'

            ELSE s.voter_status

        END AS voter_status,

        COUNT(1) AS total

    FROM tbl_voter_survey AS s

    WHERE

        s.status = 1

        AND s.is_latest = 1

		and s.app_id=@app_id

    GROUP BY

        s.booth_no,

        CASE 

            WHEN s.voter_available = 0 THEN 'NA'

            ELSE s.voter_status

        END

),

p AS

(

    SELECT

        booth_no,

        ISNULL([P],0)  AS P,

        ISNULL([N],0)  AS N,

        ISNULL([D],0)  AS D,

        ISNULL([C],0)  AS C,

        ISNULL([NA],0) AS NA

    FROM s

    PIVOT

    (

        SUM(total)

        FOR voter_status IN ([P],[N],[D],[C],[NA])

    ) pv

)



SELECT

    b.booth_no,

	b.total_voter,

    ISNULL(p.P,0)  AS P,

    ISNULL(p.N,0)  AS N,

    ISNULL(p.D,0)  AS D,

    ISNULL(p.C,0)  AS C,

    ISNULL(p.NA,0) AS NA,

	isnull(P,0)+isnull(N,0)+isnull(D,0)+isnull(C,0)+isnull(NA,0)  as total_survey

FROM tbl_booth b

LEFT JOIN p ON b.booth_no = p.booth_no

where b.app_id=@app_id

ORDER BY b.booth_no;





end



--dis_booth_wise_survey_dash_for_saktikendra_pramukh_sp 1,'23,26,'

create PROC [dbo].dis_booth_wise_survey_dash_for_saktikendra_pramukh_sp

(

    @app_id INT,

    @booth_no VARCHAR(MAX) = '' -- Pass '23,26,' here

)

AS

BEGIN

    SET NOCOUNT ON;



    -- CTE to handle the split booth numbers

    ;WITH SelectedBooths AS (

        SELECT Item AS booth_no 

        FROM dbo.SplitString(@booth_no, ',')

        WHERE RTRIM(Item) <> '' -- Removes empty strings if there's a trailing comma

    ),

    s AS

    (

        SELECT

            s.booth_no,

            CASE 

                WHEN s.voter_available = 0 THEN 'NA'

                ELSE s.voter_status

            END AS voter_status,

            COUNT(1) AS total

        FROM tbl_voter_survey AS s

        -- Filter survey by app_id and specific booths if provided

        WHERE s.status = 1

            AND s.is_latest = 1

            AND s.app_id = @app_id

            AND (

                @booth_no = '' OR 

                s.booth_no IN (SELECT booth_no FROM SelectedBooths)

            )

        GROUP BY

            s.booth_no,

            CASE 

                WHEN s.voter_available = 0 THEN 'NA'

                ELSE s.voter_status

            END

    ),

    p AS

    (

        SELECT

            booth_no,

            ISNULL([P],0)  AS P,

            ISNULL([N],0)  AS N,

            ISNULL([D],0)  AS D,

            ISNULL([C],0)  AS C,

            ISNULL([NA],0) AS NA

        FROM s

        PIVOT

        (

            SUM(total)

            FOR voter_status IN ([P],[N],[D],[C],[NA])

        ) pv

    )



    SELECT

        b.booth_no,

        b.total_voter,

        ISNULL(p.P,0)  AS P,

        ISNULL(p.N,0)  AS N,

        ISNULL(p.D,0)  AS D,

        ISNULL(p.C,0)  AS C,

        ISNULL(p.NA,0) AS NA,

        (ISNULL(p.P,0) + ISNULL(p.N,0) + ISNULL(p.D,0) + ISNULL(p.C,0) + ISNULL(p.NA,0)) AS total_survey

    FROM tbl_booth b

    LEFT JOIN p ON b.booth_no = p.booth_no

    WHERE b.app_id = @app_id

      AND (

          @booth_no = '' OR 

          b.booth_no IN (SELECT booth_no FROM SelectedBooths)

      )

    ORDER BY CAST(b.booth_no AS INT); -- Cast to INT if booth_no is string but contains numbers for correct sorting



END





-----------------------------------

------ Booth Wise Survey ----------

-----------------------------------

--dis_user_wise_survey_dash_sp 1

alter proc dis_user_wise_survey_dash_sp

(

	 @app_id int

)

as

begin

;WITH s AS

(

    SELECT

        s.survey_by,

        CASE 

            WHEN s.voter_available = 0 THEN 'NA'

            ELSE s.voter_status

        END AS voter_status,

        COUNT(1) AS total

    FROM vw_user_latest_voter_survey AS s

    WHERE

        s.status = 1

		and s.app_id=@app_id

    GROUP BY

        s.survey_by,

        CASE 

            WHEN s.voter_available = 0 THEN 'NA'

            ELSE s.voter_status

        END

),



p AS

(

    SELECT

        survey_by,

        ISNULL([P],0)  AS P,

        ISNULL([N],0)  AS N,

        ISNULL([D],0)  AS D,

        ISNULL([C],0)  AS C,

        ISNULL([NA],0) AS NA

    FROM s

    PIVOT

    (

        SUM(total)

        FOR voter_status IN ([P],[N],[D],[C],[NA])

    ) pv

)



SELECT

   u.user_id,

    u.name,

	u.[user_type],

	dbo.fn_get_designation(u.[user_type]) AS designation,

    u.mobile_no,

    u.photo,

	case isnull(u.photo,'') when '' then '' else dbo.get_server_path()+'img/admin/'+u.photo end as photo_path,

    ISNULL(p.P,0)  AS P,

    ISNULL(p.N,0)  AS N,

    ISNULL(p.D,0)  AS D,

    ISNULL(p.C,0)  AS C,

    ISNULL(p.NA,0) AS NA,

	isnull(P,0)+isnull(N,0)+isnull(D,0)+isnull(C,0)+isnull(NA,0)  as total_survey

FROM p

JOIN tbl_user as u ON p.survey_by = u.user_id

where u.app_id=@app_id

end





-----------------------------------

------ Booth Wise Survey ----------

-----------------------------------
dis_booth_wise_survey_voter_sp 1,1
ALTER PROCEDURE [dbo].[dis_booth_wise_survey_voter_sp]
(
    @app_id   INT,
    @booth_no INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.[id],
        v.[slnoinpart],
        v.[eng_f_name],
        v.[f_eng_surname],
        v.[eng_m_name],
        v.[eng_surname],
        v.[eng_localityid],
        v.[eng_polling_location],
        v.[idcard_no],
        v.[contact_no],
        v.[part_no],
        v.[eng_house_no],
        ISNULL(s.[survey_id], 0) AS [survey_id],
        s.[voter_available],
        s.[voter_status],
        s.[not_available_reason],
        u.[name],
        [dbo].[fn_get_designation](u.[user_type]) AS [designation]
    FROM [dbo].[vw_uniq_voter_survey] AS s
    INNER JOIN [dbo].[tbl_user] AS u 
        ON s.[survey_by] = u.[user_id]
    INNER JOIN [dbo].[tbl_voting_record] AS v 
        ON s.[voter_idcard] = v.[idcard_no]
        AND s.[app_id] = v.[app_id] -- Added for data integrity
    WHERE 
        s.[booth_no] = @booth_no
        AND s.[app_id] = @app_id; -- Added to use the input parameter
END
GO


------------------------------

------- Occupation Wise ------

------------------------------

--dis_user_wise_survey_voter_sp 1,''

ALTER PROCEDURE [dbo].[dis_user_wise_survey_voter_sp]
(
    @app_id      INT,
    @admin_id    INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.[id],
        v.[slnoinpart],
        v.[eng_f_name],
        v.[f_eng_surname],
        v.[eng_m_name],
        v.[eng_surname],
        v.[eng_localityid],
        v.[eng_polling_location],
        v.[idcard_no],
        v.[contact_no],
        v.[part_no],
        v.[eng_house_no],
        ISNULL(s.[survey_id], 0) AS [survey_id],
        s.[voter_available],
        s.[voter_status],
        s.[not_available_reason],
        u.[name],
        [dbo].[fn_get_designation](u.[user_type]) AS [designation]
    FROM [dbo].[vw_user_latest_voter_survey] AS s
    INNER JOIN [dbo].[tbl_user] AS u 
        ON s.[survey_by] = u.[user_id]
    INNER JOIN [dbo].[tbl_voting_record] AS v 
        ON s.[voter_idcard] = v.[idcard_no]
        AND s.[app_id] = v.[app_id]
    WHERE 
        s.[survey_by] = @admin_id
        AND s.[app_id] = @app_id;
END
GO



------------------------------

------- Occupation Wise ------

------------------------------

--dis_date_wise_survey_voter_sp '20 Nov, 2025'

ALTER PROCEDURE [dbo].[dis_date_wise_survey_voter_sp]
(
    @app_id INT,
    @date   DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.[id],
        v.[slnoinpart],
        v.[idcard_no], -- Removed the duplicate entry
        v.[eng_f_name],
        v.[f_eng_surname],
        v.[eng_m_name],
        v.[eng_surname],
        v.[eng_localityid],
        v.[eng_polling_location],
        v.[contact_no],
        v.[part_no],
        v.[eng_house_no],
        ISNULL(s.[survey_id], 0) AS [survey_id],
        s.[voter_available],
        s.[voter_status],
        s.[not_available_reason],
        u.[name],
        [dbo].[fn_get_designation](u.[user_type]) AS [designation]
    FROM [dbo].[vw_uniq_voter_survey] AS s
    INNER JOIN [dbo].[tbl_user] AS u 
        ON s.[survey_by] = u.[user_id]
        AND s.[app_id] = u.[app_id]
    INNER JOIN [dbo].[tbl_voting_record] AS v 
        ON s.[voter_idcard] = v.[idcard_no]
        AND s.[app_id] = v.[app_id]
    WHERE 
        s.[app_id] = @app_id
        AND v.[idcard_no] != ''
        -- Optimized date filtering
        AND s.[create_date] >= CAST(@date AS DATE) 
        AND s.[create_date] < DATEADD(day, 1, CAST(@date AS DATE));
END
GO

create PROCEDURE [dbo].[dis_date_wise_survey_voter_for_call_center_sp]
(
    @app_id INT,
    @date   DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.[id],
        v.[slnoinpart],
        v.[idcard_no], -- Removed the duplicate entry
        v.[eng_f_name],
        v.[f_eng_surname],
        v.[eng_m_name],
        v.[eng_surname],
        v.[eng_localityid],
        v.[eng_polling_location],
        v.[contact_no],
        v.[part_no],
        v.[eng_house_no],
        ISNULL(s.[survey_id], 0) AS [survey_id],
        s.[voter_available],
        s.[voter_status],
        s.[not_available_reason],
        u.[name],
        [dbo].[fn_get_designation](u.[user_type]) AS [designation]
    FROM [dbo].vw_date_wise_latest_voter_survey_only_call_center AS s
    INNER JOIN [dbo].[tbl_user] AS u 
        ON s.[survey_by] = u.[user_id]
        AND s.[app_id] = u.[app_id]
    INNER JOIN [dbo].[tbl_voting_record] AS v 
        ON s.[voter_idcard] = v.[idcard_no]
        AND s.[app_id] = v.[app_id]
    WHERE 
        s.[app_id] = @app_id
        AND v.[idcard_no] != ''
        -- Optimized date filtering
        AND s.[create_date] >= CAST(@date AS DATE) 
        AND s.[create_date] < DATEADD(day, 1, CAST(@date AS DATE));
END
GO



------------------------------

------- Occupation Wise ------

------------------------------

alter proc dis_scheme_wise_survey_voter_sp

(

	@app_id int,

	@scheme_id int

)

as

begin

select

	v.id,

	v.slnoinpart,

	v.eng_f_name,

	v.f_eng_surname,

	v.eng_m_name,

	v.eng_surname,

	v.eng_localityid,

	v.eng_polling_location,

	v.idcard_no,

	v.contact_no,

	v.part_no,

	v.eng_house_no,

	isnull(s.survey_id,0) as survey_id,

	s.voter_available,

	s.voter_status,

	s.not_available_reason,

	u.name,

	dbo.fn_get_designation(u.[user_type]) AS designation

from

	vw_uniq_voter_survey as s

	outer apply

	(

		select item as scheme_id from dbo.SplitString(s.scheme_id_list,',')

	) as sc

	join tbl_user as u

on

	s.survey_by=u.user_id

	and s.app_id=u.app_id

	join tbl_voting_record as v

on

	s.voter_idcard=v.idcard_no

	and s.app_id=v.app_id

where

	sc.scheme_id=@scheme_id

	and s.app_id=@app_id

end



------------------------------

------- Occupation Wise ------

------------------------------

alter proc dis_ration_card_wise_survey_voter_sp

(

	@app_id int,

	@ration_card varchar(100)

)

as

begin



select

	v.id,

	v.slnoinpart,

	v.eng_f_name,

	v.f_eng_surname,

	v.eng_m_name,



	v.eng_surname,

	v.eng_localityid,

	v.eng_polling_location,

	v.idcard_no,

	v.contact_no,

	v.part_no,

	v.eng_house_no,

	isnull(s.survey_id,0) as survey_id,

	s.voter_available,

	s.voter_status,

	s.not_available_reason,

	u.name,

	dbo.fn_get_designation(u.[user_type]) AS designation

from

	vw_uniq_voter_survey as s

	join tbl_user as u

on

	s.survey_by=u.user_id

	and s.app_id=u.app_id

	join tbl_voting_record as v

on

	s.voter_idcard=v.idcard_no

	and s.app_id=v.app_id

where

	s.ration_card=@ration_card

	and s.app_id=@app_id

end





------------------------------

------- Occupation Wise ------

------------------------------

alter proc [dbo].[dis_commuinity_wise_survey_voter_sp]

(

	@app_id int,

	@commuinity_id int

)

as

begin



select

	v.id,

	v.slnoinpart,

	v.eng_f_name,

	v.f_eng_surname,

	v.eng_m_name,

	v.eng_surname,

	v.eng_localityid,

	v.eng_polling_location,

	v.idcard_no,

	v.contact_no,

	v.part_no,

	v.eng_house_no,

	isnull(s.survey_id,0) as survey_id,

	s.voter_available,

	s.voter_status,

	s.not_available_reason,

	u.name,

	dbo.fn_get_designation(u.[user_type]) AS designation

from

	vw_uniq_voter_survey as s

	join tbl_user as u

on

	s.survey_by=u.user_id

	and s.app_id=u.app_id

	join tbl_voting_record as v

on

	s.voter_idcard=v.idcard_no

	and s.app_id=v.app_id

where

	s.religion=@commuinity_id

	and s.app_id=@app_id

end







------------------------------

------- Occupation Wise ------

------------------------------

alter proc dis_cast_wise_survey_voter_sp

(

	@app_id int,

	@cast_id int

)

as

begin



select

	v.id,

	v.slnoinpart,

	v.eng_f_name,

	v.f_eng_surname,

	v.eng_m_name,

	v.eng_surname,

	v.eng_localityid,

	v.eng_polling_location,

	v.idcard_no,

	v.contact_no,

	v.part_no,

	v.eng_house_no,

	isnull(s.survey_id,0) as survey_id,

	s.voter_available,

	s.voter_status,

	s.not_available_reason,

	u.name,

	dbo.fn_get_designation(u.[user_type]) AS designation

from

	vw_uniq_voter_survey as s

	join tbl_user as u

on

	s.survey_by=u.user_id

	and s.app_id=s.app_id

	join tbl_voting_record as v

on

	s.voter_idcard=v.idcard_no

	and s.app_id=v.app_id

where

	s.[caste]=@cast_id

	and s.app_id=@app_id

end


--------------------------------------
---- Display Sakti Pramukh Cadre -----
--------------------------------------
--dis_death_voter_sp 1
create PROCEDURE [dbo].[dis_not_availabe_voter_sp]
(
    @app_id INT,
    @reason VARCHAR(15),
    @booth_no VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
	
    -- કોમા સેપરેટેડ બૂથ નંબરને ટેબલમાં સ્પ્લિટ કરવા માટે CTE
    ;with booth as
    (
        select
            LTRIM(RTRIM(item)) as booth_no
        from
            dbo.SplitString(@booth_no, ',')
        where 
            LTRIM(RTRIM(item)) <> '' -- જો છેલ્લે વધારાનો કોમા ',' હોય તો બ્લેન્ક રો ન બને
    )

    SELECT 
        r.[id],
        r.[eng_f_name],
        r.[f_eng_surname],
        r.[eng_m_name],
        r.[eng_surname],
        r.[part_no],
        r.[eng_localityid],
        r.[part_no] AS [booth_no],
        RIGHT(RTRIM(r.[contact_no]), 10) AS [contact_no],
        r.[idcard_no],
        r.[slnoinpart],
        r.[eng_polling_location],
        r.[sex],
        r.[age],
        r.[eng_house_no],
        s.[voter_idcard],
        s.[not_available_reason],
        u.[name] AS [survey_by]
    FROM [dbo].[vw_uniq_voter_survey] AS s
    INNER JOIN [dbo].[tbl_voting_record] AS r 
        ON s.[voter_idcard] = r.[idcard_no] 
        AND s.[app_id] = r.[app_id]
    INNER JOIN [dbo].[tbl_user] AS u 
        ON s.[survey_by] = u.[user_id] 
        AND s.[app_id] = u.[app_id]
    WHERE 
        s.[not_available_reason] = @reason
        AND s.[app_id] = @app_id
        -- CRITICAL FIX: જો @booth_no ખાલી કે NULL હોય તો બધા બૂથ બતાવશે, નહીંતર ફક્ત લિસ્ટવાળા જ
        AND (
            ISNULL(@booth_no, '') = '' 
            OR r.[part_no] IN (select booth_no from booth)
        )
    ORDER BY 
        TRY_CAST(r.[part_no] AS INT),
        TRY_CAST(r.[slnoinpart] AS INT);
END
GO



--------------------------------------

---- Display Sakti Pramukh Cadre -----

--------------------------------------
--dis_death_voter_sp 1
ALTER PROCEDURE [dbo].[dis_death_voter_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        r.[id],
        r.[eng_f_name],
        r.[f_eng_surname],
        r.[eng_m_name],
        r.[eng_surname],
        r.[part_no],
        r.[eng_localityid],
        r.[part_no] AS [booth_no],
        RIGHT(RTRIM(r.[contact_no]), 10) AS [contact_no],
        r.[idcard_no],
        r.[slnoinpart],
        r.[eng_polling_location],
        r.[sex],
        r.[age],
        r.[eng_house_no],
        s.[voter_idcard],
        s.[not_available_reason],
        u.[name] AS [survey_by]
    FROM [dbo].[vw_uniq_voter_survey] AS s
    INNER JOIN [dbo].[tbl_voting_record] AS r 
        ON s.[voter_idcard] = r.[idcard_no] 
        AND s.[app_id] = r.[app_id]
    INNER JOIN [dbo].[tbl_user] AS u 
        ON s.[survey_by] = u.[user_id] 
        AND s.[app_id] = u.[app_id]
    WHERE 
        s.[not_available_reason] = 'Death'
        AND s.[app_id] = @app_id
    ORDER BY 
        TRY_CAST(r.[part_no] AS INT),
        TRY_CAST(r.[slnoinpart] AS INT);
END
GO




--------------------------------------

---- Display Sakti Pramukh Cadre -----

--------------------------------------
ALTER PROCEDURE [dbo].[dis_shifted_out_voter_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        r.[id],
        r.[eng_f_name],
        r.[f_eng_surname],
        r.[eng_m_name],
        r.[eng_surname],
        r.[part_no],
        r.[eng_localityid],
        r.[part_no] AS [booth_no],
        RIGHT(RTRIM(r.[contact_no]), 10) AS [contact_no],
        r.[idcard_no],
        r.[slnoinpart],
        r.[eng_polling_location],
        r.[sex],
        r.[age],
        r.[eng_house_no],
        s.[voter_idcard],
        s.[not_available_reason],
        u.[name] AS [survey_by]
    FROM [dbo].[vw_uniq_voter_survey] AS s
    INNER JOIN [dbo].[tbl_voting_record] AS r 
        ON s.[voter_idcard] = r.[idcard_no] 
        AND s.[app_id] = r.[app_id]
    INNER JOIN [dbo].[tbl_user] AS u 
        ON s.[survey_by] = u.[user_id] 
        AND s.[app_id] = u.[app_id]
    WHERE 
        s.[not_available_reason] = 'Shifted Out'
        AND s.[app_id] = @app_id
    ORDER BY 
        TRY_CAST(r.[part_no] AS INT),
        TRY_CAST(r.[slnoinpart] AS INT);
END
GO




--------------------------------------

---- Display Sakti Pramukh Cadre -----

--------------------------------------
--dis_wrong_mobile_no_voter_sp 1
create PROCEDURE [dbo].[dis_wrong_mobile_no_voter_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        r.[id],
        r.[eng_f_name],
        r.[f_eng_surname],
        r.[eng_m_name],
        r.[eng_surname],
        r.[part_no],
        r.[eng_localityid],
        r.[part_no] AS [booth_no],
        RIGHT(RTRIM(r.[contact_no]), 10) AS [contact_no],
        r.[idcard_no],
        r.[slnoinpart],
        r.[eng_polling_location],
        r.[sex],
        r.[age],
        r.[eng_house_no],
        s.[voter_idcard],
        s.[not_available_reason],
        u.[name] AS [survey_by]
    FROM [dbo].[vw_uniq_voter_survey] AS s
    INNER JOIN [dbo].[tbl_voting_record] AS r 
        ON s.[voter_idcard] = r.[idcard_no] 
        AND s.[app_id] = r.[app_id]
    INNER JOIN [dbo].[tbl_user] AS u 
        ON s.[survey_by] = u.[user_id] 
        AND s.[app_id] = u.[app_id]
    WHERE 
        s.[not_available_reason] = 'Wrong Mobile No'
        AND s.[app_id] = @app_id
    ORDER BY 
        TRY_CAST(r.[part_no] AS INT),
        TRY_CAST(r.[slnoinpart] AS INT);
END
GO




--------------------------------------
---- Display Sakti Pramukh Cadre -----
--------------------------------------
--dis_call_not_received_voter_sp 1
create PROCEDURE [dbo].[dis_call_not_received_voter_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        r.[id],
        r.[eng_f_name],
        r.[f_eng_surname],
        r.[eng_m_name],
        r.[eng_surname],
        r.[part_no],
        r.[eng_localityid],
        r.[part_no] AS [booth_no],
        RIGHT(RTRIM(r.[contact_no]), 10) AS [contact_no],
        r.[idcard_no],
        r.[slnoinpart],
        r.[eng_polling_location],
        r.[sex],
        r.[age],
        r.[eng_house_no],
        s.[voter_idcard],
        s.[not_available_reason],
        u.[name] AS [survey_by]
    FROM [dbo].[vw_uniq_voter_survey] AS s
    INNER JOIN [dbo].[tbl_voting_record] AS r 
        ON s.[voter_idcard] = r.[idcard_no] 
        AND s.[app_id] = r.[app_id]
    INNER JOIN [dbo].[tbl_user] AS u 
        ON s.[survey_by] = u.[user_id] 
        AND s.[app_id] = u.[app_id]
    WHERE 
        s.[not_available_reason] = 'Call Not Received'
        AND s.[app_id] = @app_id
    ORDER BY 
        TRY_CAST(r.[part_no] AS INT),
        TRY_CAST(r.[slnoinpart] AS INT);
END
GO




-----------------------------------

------ Booth Wise Survey ----------

-----------------------------------

alter proc dis_user_type_wise_survey_dash_sp

(

	@app_id int,

	@type varchar(20)

)

as

begin

;WITH s AS

(

    SELECT

        s.survey_by,

        CASE 

            WHEN s.voter_available = 0 THEN 'NA'

            ELSE s.voter_status

        END AS voter_status,

        COUNT(1) AS total

    FROM vw_user_latest_voter_survey AS s

    WHERE

        s.status = 1

		and s.app_id=@app_id

		and s.survey_by_designation=@type

    GROUP BY

        s.survey_by,

        CASE 

            WHEN s.voter_available = 0 THEN 'NA'

            ELSE s.voter_status

        END

),



p AS

(

    SELECT

        survey_by,

        ISNULL([P],0)  AS P,

        ISNULL([N],0)  AS N,

        ISNULL([D],0)  AS D,

        ISNULL([C],0)  AS C,

        ISNULL([NA],0) AS NA

    FROM s

    PIVOT

    (

        SUM(total)

        FOR voter_status IN ([P],[N],[D],[C],[NA])

    ) pv

)



SELECT

   u.user_id,

    u.name,

	u.[user_type],

	dbo.fn_get_designation(u.[user_type]) AS designation,

    u.mobile_no,

	u.booth_no,

    u.photo_path,

    ISNULL(p.P,0)  AS P,

    ISNULL(p.N,0)  AS N,

    ISNULL(p.D,0)  AS D,

    ISNULL(p.C,0)  AS C,

    ISNULL(p.NA,0) AS NA,

	isnull(P,0)+isnull(N,0)+isnull(D,0)+isnull(C,0)+isnull(NA,0)  as total_survey

FROM p

JOIN vw_get_all_user as u ON p.survey_by = u.user_id 

where u.app_id=@app_id and  u.user_type=@type 

end









-----------------------------------------------------

------- Print Receipt in All Family -----------------

-----------------------------------------------------

alter proc get_slip_photo_with_log_sp

(

	@app_id int,

	@voter_id int,

	@user_id int

)

as

begin



insert into tbl_log

select 

	@app_id,

	v.idcard_no,

	@user_id,

	'SLEEP',

	dbo.get_date()

FROM 

	tbl_voting_record AS v

WHERE 

	v.id = @voter_id

	

	

select 

	dbo.get_server_path() + '/img/prachar/' + content  as img

from 

	tbl_prachar_master

where 

	app_id=@app_id 

	and prachar_type='SLEEP' and status=1

end



-----------------------------------------------------

------- Print Receipt in All Family -----------------

-----------------------------------------------------

ALTER proc [dbo].[get_family_slip_photo_with_log_sp]  

(  

   @app_id int,  

   @voter_id int,  

   @user_id int  

)  

as  

begin  

    -- 1. Use a variable for the date so the function isn't called for every row

    declare @currentDate datetime = getdate(); 

    

    declare @family_id int = (select TOP 1 family_id from tbl_voting_record where id=@voter_id and app_id=@app_id);

	

    -- 2. Insert using the variable

    insert into tbl_log (app_id, idcard, user_id, prachar_type, create_date) -- Always specify columns

    select  

       @app_id,  

       v.idcard_no,  

       @user_id,  

       'SLEEP',  

       @currentDate  

    FROM  

       tbl_voting_record AS v  

    WHERE  

       v.family_id = @family_id;



    -- 3. Get server path once into a variable

    declare @serverPath nvarchar(max) = dbo.get_server_path();



    select  

       @serverPath + '/img/prachar/' + content as img  

    from  

       tbl_prachar_master  

    where  

       app_id=@app_id  

       and prachar_type='SLEEP' and status=1;

end



	

	

-----------------------------------------------------

------- Print Receipt in All Family -----------------

-----------------------------------------------------

ALTER PROC dis_star_karykarta_sp

(

    @app_id INT

)

AS

BEGIN

    SET NOCOUNT ON; -- Prevents extra result sets for performance



    WITH lg AS

    (

        SELECT

            user_id,

            count(distinct 

                case 

                    when l.prachar_type in ('SLEEP', 'PRINT', 'SMS SLEEP') then 'SYSTEM_OFF' 

                    else l.prachar_type 

                end + '_' + cast(l.idcard as varchar)

            ) as total

        FROM

            tbl_log as l

			join tbl_voting_record as r on l.idcard = r.idcard_no

        WHERE

            l.app_id = @app_id

			and r.app_id=@app_id

        GROUP BY

            l.user_id

    )



    SELECT

        u.user_id,

        u.name,

        u.mobile_no,

        u.photo,

        u.[user_type],

        dbo.fn_get_designation(u.[user_type]) AS designation,

        -- More concise photo path logic

        CASE 

            WHEN ISNULL(u.photo, '') = '' THEN '' 

            ELSE dbo.get_server_path() + 'img/admin/' + u.photo 

        END AS photo_path,

        ISNULL(lg.total, 0) AS total

    FROM

        tbl_user AS u

    LEFT JOIN lg ON u.user_id = lg.user_id -- Left join ensures you see all users for that app

    WHERE

        u.app_id = @app_id

    ORDER BY 

        lg.total DESC; -- Typically "Star Karyakartas" are ranked by activity

END



-----------------------------------------------------

------- Scheme -----------------

-----------------------------------------------------

CREATE PROC dis_scheme_sp

AS

BEGIN

    SET NOCOUNT ON;



    SELECT 

        scheme_id,

        scheme_name

    FROM tbl_scheme

    WHERE is_active = 1

    ORDER BY scheme_name ASC;

END





-----------------------------------------------------

------- Scheme -----------------

-----------------------------------------------------

CREATE PROC dis_community_sp

AS

BEGIN

    SET NOCOUNT ON;



    SELECT 

        community_id,

        community_name

    FROM tbl_community

    WHERE is_active = 1

    ORDER BY community_name ASC;

END



-----------------------------------------------------

------- Scheme -----------------

-----------------------------------------------------

CREATE PROC dis_caste_sp

AS

BEGIN

    SET NOCOUNT ON;



    SELECT 

        caste_id,

        caste_name

    FROM tbl_caste

    WHERE is_active = 1

    ORDER BY caste_name ASC;

END



-----------------------------------------------------

------- Scheme -----------------

-----------------------------------------------------

CREATE PROC dis_scheme_community_caste_data_sp

AS

BEGIN

    SET NOCOUNT ON;



    -- 1️⃣ Scheme

    SELECT 

        scheme_id AS id,

        scheme_name AS name

    FROM tbl_scheme

    WHERE is_active = 1

    ORDER BY scheme_name;



    -- 2️⃣ Community

    SELECT 

        community_id AS id,

        community_name AS name

    FROM tbl_community

    WHERE is_active = 1

    ORDER BY community_name;



    -- 3️⃣ Caste

    SELECT 

        caste_id AS id,

        caste_name AS name

    FROM tbl_caste

    WHERE is_active = 1

    ORDER BY caste_name;

END



-----------------------------------------------------

------- star_karykarta_detail -----------------

-----------------------------------------------------

alter proc view_star_karykarta_detail_sp

(

	@app_id INT,

    @user_id INT

)

as

begin







;WITH lg AS

(

    SELECT

        l.user_id,

        l.prachar_type,

        COUNT(DISTINCT l.idcard) AS total

    FROM tbl_log as l 

		join tbl_voting_record as r on l.idcard=r.idcard_no

    WHERE l.app_id = @app_id

      AND l.user_id = @user_id

	  and r.app_id=@app_id

    GROUP BY l.user_id, l.prachar_type

)



SELECT

    ISNULL([AUDIO],0)     AS AUDIO,

    ISNULL([VIDEO],0)     AS VIDEO,

    ISNULL([TEXT],0)      AS TEXT,

    ISNULL([SELFIE],0)    AS SELFIE,

    ISNULL([IMAGE],0)     AS IMAGE,

    ISNULL([SLEEP],0)     AS SLEEP,

    ISNULL([SMS SLEEP],0) AS [SMS SLEEP],

	ISNULL([CALL],0) AS [CALL],

	ISNULL([SURVEY],0) AS [SURVEY],

	ISNULL([MOBILE UPDATE],0) AS [MOBILE UPDATE],

	ISNULL([PRINT],0) AS [PRINT]

FROM lg

PIVOT

(

    SUM(total)

    FOR prachar_type IN 

    (

        [AUDIO],

        [VIDEO],

        [TEXT],

        [SELFIE],

        [IMAGE],

        [SLEEP],

        [SMS SLEEP],

		[CALL],

		[SURVEY],

		[MOBILE UPDATE],

		[PRINT]

    )

) AS p;







select

	u.user_id,

    u.[user_type],

	u.booth_no,

    dbo.fn_get_designation(u.[user_type]) AS designation,

    u.name,

    u.mobile_no,

    u.photo_path

from

	vw_get_all_user as u

where

	app_id=@app_id

	and user_id=@user_id

end





-----------------------------------------------------

------- star_karykarta_detail -----------------

-----------------------------------------------------

create proc dis_cast_wise_survey_dash_sp

(

	@app_id INT

)

as

begin



select 

	caste_id,

	name,

	isnull(P,0) as P,

	isnull(N,0) as N,

	isnull(D,0) as D,

	isnull(C,0) as C,

	isnull(P,0)+isnull(N,0)+isnull(D,0)+isnull(C,0) as total

from (

select

	c.caste_id,

	c.caste_name as name,

	s.voter_status,

	count(c.caste_id) as total

from

	vw_uniq_voter_survey as s

	join tbl_caste as c

on

	s.caste=c.caste_id

where

	s.app_id=@app_id

group by

	c.caste_id,

	c.caste_name,

	s.voter_status

) piv

pivot

(

	sum(total)

	for voter_status in (P,N,D,C)

) as tbl

end





------------------------------

------- Occupation Wise ------

------------------------------

create proc dis_community_wise_survey_dash_sp

(

	@app_id int

)

as

begin

select 

	community_id,

	community_name,

	isnull(P,0) as P,

	isnull(N,0) as N,

	isnull(D,0) as D,

	isnull(C,0) as C,

	isnull(P,0)+isnull(N,0)+isnull(D,0)+isnull(C,0) as total

from (

select

	c.community_id,

	c.community_name,

	s.voter_status,

	count(c.community_id) as total

from

	vw_uniq_voter_survey as s

	join tbl_community as c

on

	s.religion=c.community_id

where

	s.app_id=@app_id

group by

	c.community_id,

	c.community_name,

	s.voter_status

) piv

pivot

(

	sum(total)

	for voter_status in (P,N,D,C)

) as tbl

end







------------------------------

------- Occupation Wise ------

------------------------------

create proc dis_scheme_wise_survey_dash

(

	@app_id int

)

as

begin

select 

	scheme_id,

	scheme_name,

	isnull(P,0) as P,

	isnull(N,0) as N,

	isnull(D,0) as D,

	isnull(C,0) as C,

	isnull(P,0)+isnull(N,0)+isnull(D,0)+isnull(C,0) as total

from (

select

	sch.scheme_id,

	sch.scheme_name,

	s.voter_status,

	COUNT(*) as total

from

	vw_uniq_voter_survey as s

	outer apply

	(

		select Item from dbo.SplitString(s.scheme_id_list,',')

	) as sl

	join tbl_scheme as sch

on

	sch.scheme_id=sl.Item

where

	s.app_id=@app_id

group by

	sch.scheme_id,

	sch.scheme_name,

	s.voter_status

) as piv

pivot

(

	sum(total)

	for voter_status in (P,N,D,C)

) as tbl



end







------------------------------

------- Occupation Wise ------

------------------------------

create proc dis_ration_card_wise_survey_dash_sp

(

	@app_id int

)

as

begin

select 

	name,

	isnull(P,0) as P,

	isnull(N,0) as N,

	isnull(D,0) as D,

	isnull(C,0) as C,

	isnull(P,0)+isnull(N,0)+isnull(D,0)+isnull(C,0) as total

from (

select

	s.ration_card as name,

	s.voter_status,

	count(s.ration_card) as total

from

	vw_uniq_voter_survey as s

where

	s.ration_card!=''

	and s.app_id=@app_id

group by

	s.ration_card,

	s.voter_status



) piv

pivot

(

	sum(total)

	for voter_status in (P,N,D,C)

) as tbl

end







------------------------------

------- Occupation Wise ------

------------------------------

alter proc dis_date_wise_survey_dash_sp

(

	@app_id int,

	@month datetime

)

as

begin

select [date],d,isnull(total,0) as total from (

select 

	format(d.[date],'dd, MMM, yyyy') as [date],

	cast(d.[date] as date) as d,

	case when cast(s.create_date as date) is null then 0 else count(*) end as total

from 

	get_all_date_by_month(@month) as d

	left join vw_date_wise_latest_voter_survey as s

on

	d.[date]=cast(s.create_date as date)

where

	s.app_id=@app_id

group by

	cast(d.[date] as date),

	cast(s.create_date as date),

	format(d.[date],'dd, MMM, yyyy')

) as tbl

order by

	cast(d as date)

end



------------------------------

------- Occupation Wise ------

------------------------------

--dis_phonebook_wise_survey_dash_sp 1

alter proc dis_phonebook_wise_survey_dash_sp

(

	@app_id INT

)

as

begin



SELECT

    u.user_id,

    u.[user_type],

    dbo.fn_get_designation(u.[user_type]) AS designation,

    u.name,

    u.mobile_no,

    COALESCE(u.photo, '') AS photo,



    CASE 

        WHEN u.photo = '' THEN '' 

        ELSE dbo.get_server_path() + 'img/admin/' + u.photo 

    END AS photo_path,

	p.total_voter,

    COUNT(CASE WHEN s.voter_status = 'P' THEN 1 END) AS P,

    COUNT(CASE WHEN s.voter_status = 'N' THEN 1 END) AS N,

    COUNT(CASE WHEN s.voter_status = 'D' THEN 1 END) AS D,

    COUNT(CASE WHEN s.voter_status = 'C' THEN 1 END) AS C,

    COUNT(s.voter_status) AS total_survey



FROM tbl_user u

join tbl_user_phonebook_count as p on u.user_id=p.user_id and u.app_id=p.app_id

JOIN tbl_contact_group c  ON u.user_id = c.user_id  AND c.app_id = u.app_id

LEFT JOIN vw_user_latest_voter_survey s   ON c.user_id = s.survey_by  AND c.idcard_no = s.voter_idcard

WHERE u.app_id = @app_id

GROUP BY

    u.user_id,

    u.user_type,

	p.total_voter,

    u.name,

    u.mobile_no,

    u.photo

ORDER BY u.name;

end



--dis_phonebook_wise_Survey_voter_sp 1,12

alter proc dis_phonebook_wise_Survey_voter_sp

(

	@app_id int,

	@user_id int

)

as

begin

	set nocount on;



	select

		r.id,

		r.eng_f_name,

		r.f_eng_surname,

		r.eng_m_name,

		r.eng_surname,

		r.part_no,

		r.eng_localityid,

		r.part_no as booth_no,

		right(rtrim(r.contact_no), 10) as contact_no,

		r.idcard_no,

		r.slnoinpart,

		r.eng_polling_location,

		r.sex,

		r.age,

		r.eng_house_no,
		s.voter_status,
		s.voter_idcard,
		s.voter_available,
		s.not_available_note,
		s.not_available_reason,

		u.name as survey_by

	from tbl_contact_group as cg

	inner join dbo.vw_uniq_voter_survey as s on cg.idcard_no = s.voter_idcard and cg.app_id = s.app_id

	inner join dbo.tbl_voting_record as r on s.voter_idcard = r.idcard_no and s.app_id = r.app_id

	inner join dbo.tbl_user as u on s.survey_by = u.user_id and s.app_id = u.app_id

	where 
		s.app_id = @app_id

		and cg.user_id = @user_id

		and cg.idcard_no <> ''

	order by

		try_cast(r.part_no as int),

		try_cast(r.slnoinpart as int);

end





------------------------------

------- Occupation Wise ------

------------------------------

--dis_analytics_dash_sp 7

alter proc dis_analytics_dash_sp

(

	@app_id int

)

as

begin



select 

      CONVERT(varchar, CAST(create_date AS DATE), 106) as prachar_date, 

      count(1) as total_prachar 

   from tbl_log 

   where app_id = @app_id 

   group by CAST(create_date AS DATE) -- This is much faster than FORMAT()

   order by CAST(create_date AS DATE) DESC;



select count(1) as total_slip_send from	vw_get_uniq_sleep_send_date where app_id=@app_id



SELECT

    SUM(CASE WHEN voter_status = 'P' THEN 1 ELSE 0 END) AS P,

    SUM(CASE WHEN voter_status = 'D' THEN 1 ELSE 0 END) AS D,

    SUM(CASE WHEN voter_status = 'N' THEN 1 ELSE 0 END) AS N,

    SUM(CASE WHEN voter_status = 'C' THEN 1 ELSE 0 END) AS C,

    SUM(CASE WHEN voter_status = '' THEN 1 ELSE 0 END) AS BLANK

FROM vw_uniq_voter_survey

where app_id=@app_id;





select

	SUM(CASE WHEN last_login is null THEN 1 ELSE 0 END) AS NA,

	SUM(CASE WHEN last_login is not null THEN 1 ELSE 0 END) AS A

from

	tbl_user as u

where

	u.status=1

	and app_id=@app_id

end

select * from tbl_PostMedia order by media_id desc


------------------------------
------- Occupation Wise ------
------------------------------
alter PROCEDURE [dbo].[ins_post_sp]

	@app_id int,

    @UserId BIGINT,

    @Content NVARCHAR(MAX),

    @MediaList MediaTypeTable READONLY

AS

BEGIN

    SET NOCOUNT ON;



    -- 1. Insert post

    INSERT INTO tbl_post (app_id,user_id, content,create_by)

    VALUES (@app_id,@UserId, @Content, @UserId);



    DECLARE @PostId BIGINT = SCOPE_IDENTITY();



    -- 2. Insert media items

    INSERT INTO tbl_PostMedia (post_id, media_type, media_url,create_by)

    SELECT @PostId, media_type, media_url,@UserId

    FROM @MediaList;



	select  'ok'

END



------------------------------

------- Occupation Wise ------

------------------------------

CREATE PROCEDURE [dbo].[upd_post_sp]

	@UserId int,

    @PostId BIGINT,

    @Content NVARCHAR(MAX),

    @MediaList MediaTypeTable READONLY

AS

BEGIN

    SET NOCOUNT ON;



    -- 1. Update post content

    UPDATE tbl_post

    SET content = @Content,

        modify_date = dbo.get_date()

    WHERE post_id = @PostId;



    -- 2. Delete existing media for this post

    --update tbl_PostMedia set status=0,delete_by=@UserId,delete_date=dbo.get_date()

    --WHERE post_id = @PostId;



    -- 3. Insert new media items

    INSERT INTO tbl_PostMedia (post_id, media_type, media_url,create_by)

    SELECT @PostId, media_type, media_url,@UserId

    FROM @MediaList;



	select 'ok'

END



------------------------------

------- Occupation Wise ------

------------------------------

CREATE PROCEDURE [dbo].[dlt_post_sp]

    @UserId INT,

    @PostId BIGINT

AS

BEGIN

    SET NOCOUNT ON;



    -- 1. Mark the post as deleted

    UPDATE tbl_post

    SET status = 0,

        delete_by = @UserId,

        delete_date = dbo.get_date()

    WHERE post_id = @PostId;



    -- 2. Mark all related media as deleted

    UPDATE tbl_PostMedia

    SET status = 0,

        delete_by = @UserId,

        delete_date = dbo.get_date()

    WHERE post_id = @PostId;



    SELECT 'ok';

END



------------------------------

------- Occupation Wise ------

------------------------------

create proc [dbo].[dlt_post_media_sp]

(

	@media_id int

)

as

begin

	update 

		tbl_PostMedia 

	set 

		status=0,

		delete_by=0,

		delete_date=dbo.get_date() 

	where 

		media_id=@media_id

	select 'ok'

end



------------------------------

------- Occupation Wise ------

------------------------------
--[dis_post_sp] 1,1,0,10
alter PROCEDURE [dbo].[dis_post_sp]

	@app_id int,

    @CurrentUserId INT,

    @Offset INT = 0,

    @Fetch INT = 10

AS

BEGIN

    SET NOCOUNT ON;



     SELECT 

        p.post_id,

        p.user_id,

		u.name as user_name,

		case u.photo when '' then '' else dbo.get_server_path()+'img/admin/'+u.photo end as user_photo_path,

        p.content,

        p.share_count,

		dbo.fn_social_date(p.create_date) as create_date,

        

		

        -- Media as JSON array

        (SELECT 

			pm.media_type,

			pm.media_id,

			media_url

         FROM tbl_PostMedia pm

         WHERE pm.post_id = p.post_id

           AND pm.status = 1

         FOR JSON PATH) AS media

		 

    FROM 

		tbl_post p

		join tbl_user as u on p.user_id=u.user_id

		

    WHERE p.status = 1 and p.app_id=@app_id

    ORDER BY p.post_id DESC

    OFFSET @Offset ROWS

    FETCH NEXT @Fetch ROWS ONLY;

END



------------------------------

------- Occupation Wise ------

------------------------------

alter PROCEDURE [dbo].[dis_post_timeline_sp]

	@app_id int,

    @UserId INT,         -- The user whose timeline we want

    @Offset INT = 0,

    @Fetch INT = 10

AS

BEGIN

    SET NOCOUNT ON;



    -- 1. Fetch posts uploaded by the user

    SELECT 

        p.post_id,

        p.user_id,

		u.name as user_name,

		case u.photo when '' then '' else dbo.get_server_path()+'img/admin/'+u.photo end as user_photo_path,

        p.content,

        p.share_count,

       	dbo.fn_social_date(p.create_date) as create_date,

        



        -- Media as JSON array

        (SELECT 

			pm.media_type,

			pm.media_id,

			dbo.get_server_path()+'img/post/'+pm.media_url as media_url

         FROM tbl_PostMedia pm

         WHERE pm.post_id = p.post_id

           AND pm.status = 1

         FOR JSON PATH) AS media



    FROM 

		tbl_post p

		join tbl_user as u on p.user_id=u.user_id

    WHERE p.status = 1 and p.app_id=@app_id

      AND p.user_id = @UserId        -- Only this user’s posts

    ORDER BY p.create_date DESC

    OFFSET @Offset ROWS

    FETCH NEXT @Fetch ROWS ONLY;

END



------------------------------

------- Occupation Wise ------

------------------------------

CREATE PROCEDURE [dbo].[sel_post_by_id_sp]

    @PostId BIGINT

AS

BEGIN

    SET NOCOUNT ON;



    -- 1. Select post details

    SELECT 

        post_id,

        user_id,

        content,

        share_count

    FROM tbl_post

    WHERE post_id = @PostId

      AND status = 1;  -- only active posts



    -- 2. Select related active media

    SELECT 

        media_id,

        media_type,

		media_url,

        dbo.get_server_path()+'img/post/'+media_url as media_url_path

    FROM tbl_PostMedia

    WHERE post_id = @PostId

      AND status = 1;  -- only active media

END



------------------------------

------- User Wise ------

------------------------------

alter proc get_total_slip_distribution_count_sp

(

	@app_id int

)

as

begin



SELECT

    COUNT(CASE WHEN prachar_type = 'SLEEP' THEN idcard END) AS whtsapp,

    COUNT(CASE WHEN prachar_type = 'SMS SLEEP' THEN idcard END) AS sms,

    COUNT(CASE WHEN prachar_type = 'PRINT' THEN idcard END) AS [print],

    COUNT(CASE WHEN prachar_type = 'WEB' THEN idcard END) AS web

FROM 

    vw_get_uniq_sleep_send_date

WHERE

    idcard != ''

	and app_id=@app_id



--SELECT

--    COUNT(CASE WHEN prachar_type = 'SLEEP' THEN idcard END) AS whtsapp,

--    COUNT(CASE WHEN prachar_type = 'SMS SLEEP' THEN idcard END) AS web,

--    COUNT(CASE WHEN prachar_type = 'PRINT' THEN idcard END) AS sms,

--    COUNT(CASE WHEN prachar_type = 'WEB' THEN idcard END) AS [print]

--FROM 

--    vw_get_uniq_sleep_send_date

--WHERE

--    idcard != ''

--	and app_id=@app_id





end







------------------------------

------- User Wise ------

------------------------------

--dis_booth_wise_total_slip_distribution_count_sp 1,26

alter proc dis_booth_wise_total_slip_distribution_count_sp

(

	@app_id int,

	@booth_no int

)

as

begin

SELECT

    COUNT(CASE WHEN prachar_type = 'SLEEP' THEN idcard END) AS whtsapp,

    COUNT(CASE WHEN prachar_type = 'SMS SLEEP' THEN idcard END) AS web,

    COUNT(CASE WHEN prachar_type = 'PRINT' THEN idcard END) AS sms,

    COUNT(CASE WHEN prachar_type = 'WEB' THEN idcard END) AS [print]

FROM 

    vw_get_uniq_sleep_send_date as s

	join tbl_voting_record as r on s.idcard=r.idcard_no and s.app_id=r.app_id

WHERE

    isnull(s.idcard,'') != ''

	and r.part_no=@booth_no

	and s.app_id=@app_id



select total_voter from tbl_booth where booth_no=@booth_no and app_id=@app_id

end





------------------------------

------- User Wise ------

------------------------------

alter proc dis_saktikendra_wise_total_slip_distribution_count

(

	@app_id int,

	@booth_no varchar(200)

)

as

begin



DECLARE @booth_list TABLE (booth_no VARCHAR(10))

INSERT INTO @booth_list (booth_no)

SELECT Item FROM dbo.SplitString(@booth_no, ',')



SELECT

    COUNT(CASE WHEN prachar_type = 'SLEEP' THEN idcard END) AS whtsapp,

    COUNT(CASE WHEN prachar_type = 'SMS SLEEP' THEN idcard END) AS web,

    COUNT(CASE WHEN prachar_type = 'PRINT' THEN idcard END) AS sms,

    COUNT(CASE WHEN prachar_type = 'WEB' THEN idcard END) AS [print]

FROM 

    vw_get_uniq_sleep_send_date as s

	JOIN tbl_voting_record AS r ON s.idcard = r.idcard_no and s.app_id=r.app_id

	JOIN @booth_list b ON r.part_no = b.booth_no

WHERE

    idcard != ''

	and s.app_id=@app_id





SELECT SUM(total_voter) AS total_voter

FROM tbl_booth

WHERE booth_no IN (SELECT booth_no FROM @booth_list)



end







-------------------------------

--- Display Surname Group -----

-------------------------------

--phonebook_wise_slip_sending_sp 1

create proc phonebook_wise_slip_sending_sp

(

	@app_id int,

	@user_id int

)

as

begin



;with sl as

(

	select

		distinct

		idcard,

		max(create_date) as create_date

	from

		tbl_log as l

	where

		l.user_id=@user_id

		and l.app_id=@app_id

		and l.prachar_type in ('SLEEP','SMS SLEEP','PRINT','WEB')

	group by

		idcard



) 

select 

	v.id,

	v.slnoinpart,

	v.eng_f_name,

	v.f_eng_surname,

	v.eng_m_name,

	v.eng_surname,

	v.eng_localityid,

	v.eng_polling_location,

	v.idcard_no,

	v.contact_no,

	v.part_no,

	v.eng_house_no,

	isnull(format(s.create_date,'dd MMM, yyyy hh:mm tt'),'') as send_date,

	case when s.idcard is null then 0 else 1 end as slip_send

from 

	tbl_contact_group as gm

	join tbl_voting_record as v

on

	gm.idcard_no=v.idcard_no

	left join sl as s

on

	gm.idcard_no=s.idcard

where

	gm.user_id=@user_id

	and gm.app_id=@app_id

end







-------------------------------

--- Display Surname Group -----

-------------------------------

alter proc dis_phonebook_wise_slip_send_dash_sp

(

	@app_id int

)

as

begin

;with sl as

(

	select

		distinct

		idcard,

		max(create_date) as create_date

	from

		tbl_log as l

	where

		l.prachar_type in ('SLEEP','SMS SLEEP','PRINT','WEB')

		and l.app_id=@app_id

	group by

		idcard



) 



select

	u.user_id as admin_id,

	u.[user_type],

	u.name,

	u.mobile_no,

	dbo.get_server_path()+'img/admin/'+u.photo as photo,

	count(*) as total,

	sum(case when s.idcard is null then 0 else 1 end) as send

from

	tbl_contact_group as c

	join tbl_user as u

on

	c.user_id=u.user_id

	and c.app_id=u.app_id

	join tbl_voting_record as r

on

	c.idcard_no=r.idcard_no

	and c.app_id=r.app_id

	left join sl as s

on

	r.idcard_no=s.idcard

where

	c.app_id=@app_id

group by

	

	u.user_id,

	u.[user_type],

	u.name,

	u.mobile_no,

	dbo.get_server_path()+'img/admin/'+u.photo



end



-------------------------------

--- Display Surname Group -----

-------------------------------

create proc dis_booth_wise_slip_send_dash_sp

(

	@app_id int

)

as

begin

;with sl as

(

	select

		count(s.idcard) as [send],

		r.part_no as booth_no

	from

		vw_get_uniq_sleep_send_date as s

		join tbl_voting_record as r on s.idcard=r.idcard_no and s.app_id=r.app_id

	where

		s.app_id=@app_id

	group by

		r.part_no

)







select

	b.booth_no,

	b.total_voter,

	sl.[send],

	b.total_voter-sl.[send] as remain

from

	tbl_booth as b

	join sl on b.booth_no=sl.booth_no

where

	b.app_id=@app_id

order by

	CAST(b.booth_no AS int)

end



-------------------------------

--- Display Surname Group -----

-------------------------------

alter PROCEDURE [sp_AllocateUserBalance]

    @app_id INT,

    @user_id INT,

    @total_messege FLOAT,  -- Always pass a positive number here

    @action_type VARCHAR(10), -- 'ADD' or 'REMOVE'

    @remarks NVARCHAR(500),

    @create_by INT

AS

BEGIN

    SET NOCOUNT ON;



    BEGIN TRY

        BEGIN TRANSACTION;



        IF (@action_type = 'ADD')

        BEGIN

            -- 1. Check if Main Client has enough to give

            IF NOT EXISTS (SELECT 1 FROM tbl_wtsp_wallets WHERE app_id = @app_id AND total_messages >= @total_messege)

            BEGIN

                THROW 50000, 'Insufficient balance in Main Client account.', 1;

            END



            -- 2. Update Main Wallet

            UPDATE tbl_wtsp_wallets

            SET 

				total_messages=total_messages-@total_messege,

                modify_by = @create_by, modify_date = dbo.get_date()

            WHERE app_id = @app_id;



            -- 3. Update/Insert Sub-User Wallet

            IF EXISTS (SELECT 1 FROM tbl_wtsp_user_wallets WHERE app_id = @app_id AND user_id = @user_id)

            BEGIN

                UPDATE tbl_wtsp_user_wallets

                SET total_messages = total_messages + @total_messege,

                    modify_by = @create_by, modify_date = dbo.get_date()

                WHERE app_id = @app_id AND user_id = @user_id;

            END

            ELSE

            BEGIN

                INSERT INTO tbl_wtsp_user_wallets (app_id, user_id, total_messages, create_by, create_date)

                VALUES (@app_id, @user_id, @total_messege, @create_by, dbo.get_date());

            END

        END

        

        ELSE IF (@action_type = 'REMOVE')

        BEGIN

            -- 1. Check if Sub-User has enough to take back

            IF NOT EXISTS (SELECT 1 FROM tbl_wtsp_user_wallets WHERE app_id = @app_id AND user_id = @user_id AND total_messages >= @total_messege)

            BEGIN

                THROW 50000, 'Sub-user does not have enough balance to withdraw.', 1;

            END



            -- 2. Deduct from Sub-User

            UPDATE tbl_wtsp_user_wallets

            SET total_messages = total_messages - @total_messege,

                modify_by = @create_by, modify_date = dbo.get_date()

            WHERE app_id = @app_id AND user_id = @user_id;



            -- 3. Add back to Main Wallet

            UPDATE tbl_wtsp_wallets

            SET 

                total_messages = total_messages + @total_messege,

                modify_by = @create_by, modify_date = dbo.get_date()

            WHERE app_id = @app_id;



            -- Set message to negative for the log

            SET @total_messege = @total_messege * -1;

        END



        -- 4. Log the transaction (Always happens for both ADD and REMOVE)

        INSERT INTO tbl_wtsp_internal_allocation_logs (

            app_id, user_id, transfer_qty, remarks, create_by, create_date

        )

        VALUES (

            @app_id, @user_id, @total_messege, @remarks, @create_by, dbo.get_date()

        );



        COMMIT TRANSACTION;

        SELECT 'ok' AS Result;



    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();

        RAISERROR(@ErrorMessage, 16, 1);

    END CATCH

END



-------------------------------

--- Display Surname Group -----

-------------------------------

--dis_wtsp_msg_admin_dash_sp 1

alter proc dis_wtsp_msg_admin_dash_sp

(

	@app_id int

)

as

begin



;with ub as

(

	select

		sum(total_messages) as total_user_messages

	from

		tbl_wtsp_user_wallets as w

	where

		w.status=1

		and w.app_id=@app_id

)





select 

	w.total_messages+ub.total_user_messages as total_messages,

	w.total_messages as total_admin_messages,

	ub.total_user_messages

from

	tbl_wtsp_wallets as w

	join ub on 1=1 

where

	w.status=1

	and w.app_id=@app_id







select

	isnull(sum(l.total_message_use),0) as total_message_use

from

	tbl_wtsp_campaign as l

where

	l.status=1

	and l.app_id=@app_id



select

	l.user_id,

	u.name,

	l.transfer_qty,

	l.type,

	l.title,

	l.remarks,

	format(l.create_date,'dd MMM, yyyy') as transaction_date

from

	vw_get_wtsp_tranction_log as l

	join tbl_user as u on l.user_id=u.user_id

where

	l.app_id=@app_id

order by

	l.create_date desc



end





-------------------------------

--- Display Surname Group -----

-------------------------------

create proc dis_wtsp_user_wallets_sp

(

	@app_id int

)

as

begin

select

	w.user_id,

	u.name,

	u.user_type,

	case isnull(photo,'') when '' then '' else dbo.get_server_path()+'img/admin/'+photo end as photo_path,

	w.total_messages

from

	tbl_wtsp_user_wallets as w

	join tbl_user as u on w.user_id=u.user_id and u.status=1

where

	w.status=1

	and w.app_id=@app_id

	and u.app_id=@app_id

end





-------------------------------

--- Display Surname Group -----

-------------------------------

alter PROCEDURE sp_ins_wtsp_campaign

    @app_id INT,

    @user_id INT,

    @remarks NVARCHAR(MAX),

    @create_by INT

AS

BEGIN

    SET NOCOUNT ON;



    -- 1. Generate a Unique Campaign ID (Example: CMP-20240320-A1B2)

    -- This uses the date + a partial GUID to ensure it's never the same.

    DECLARE @new_campaign_id NVARCHAR(100);

    SET @new_campaign_id = 'CMP-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + LEFT(CAST(NEWID() AS NVARCHAR(36)), 8);



    -- 2. Insert into the table

    INSERT INTO tbl_wtsp_campaign (

        app_id, 

        user_id, 

        total_message_use, 

        campaign_id, 

        remarks, 

        [status], 

        [create_by], 

        [create_date]

    )

    VALUES (

        @app_id, 

        @user_id, 

        0, 

        @new_campaign_id, 

        @remarks, 

        1,            -- Default Active

        @create_by, 

        GETDATE()

    );



    -- 3. Return the newly created ID and Campaign String to your C# code

    SELECT 

		SCOPE_IDENTITY() AS NewID, 

		@new_campaign_id AS GeneratedCampaignID;

END





--------------------------------------------

--------- Insert Voter Visit ---------------

--------------------------------------------

create proc ins_bulk_wtsp_log_sp

(

	@app_id int,

	@user_id int,

	@idcard varchar(50),

	@campaign_id varchar(100)

)

as

begin

	

	insert into tbl_log

	values

	(

		@app_id,

		@idcard,

		@user_id,

		'W-SLEEP',

		dbo.get_date()

	)

	

	

	update tbl_wtsp_user_wallets

	set

		total_messages=total_messages-1

	where

		user_id=@user_id

		and app_id=@app_id

	

	update tbl_wtsp_campaign

	set

		total_message_use=total_message_use+1

	where

		campaign_id=@campaign_id



	select 'ok'

end





--------------------------------------------

--------- Insert Voter Visit ---------------

--------------------------------------------

create proc dis_booth_list_for_send_bulk_sleep_wtsp_sp

(

	@user_id INT,

	@app_id INT,

	@type VARCHAR(10)

)

as

begin

WITH booth AS (

    SELECT

        u.user_type,

        ISNULL(u.booth_no, b.booth_no) AS booth_no

    FROM

        tbl_user AS u

        LEFT JOIN tbl_user_booth AS b ON u.user_id = b.user_id

    WHERE

        u.user_id = @user_id

        AND u.app_id = @app_id

),

-- 2. Calculate Stats directly from the Voting Records

stats AS (

    SELECT

        r.app_id,

        r.part_no,

        COUNT(r.idcard_no) AS total_voter,                 -- Total in Booth

        COUNT(s.idcard) AS total_sleep_send,               -- Only those with Slips (ignores NULLs)

		count(r.contact_no) as total_contact

    FROM

        tbl_voting_record AS r

        LEFT JOIN vw_get_uniq_sleep_send_date AS s ON r.idcard_no = s.idcard

    WHERE 

        r.app_id = @app_id

    GROUP BY

        r.app_id,

        r.part_no

)



-- 3. Final Output filtered by User Permissions

SELECT

    st.part_no,

    st.total_voter,

	st.total_contact,

    st.total_sleep_send,

    (st.total_voter - st.total_sleep_send) AS pending_voter -- Remaining to send

FROM

    stats AS st

WHERE

    st.app_id = @app_id

    AND (

        st.part_no IN (SELECT booth_no FROM booth) 

        OR @type IN ('A', 'SA') -- Admin/SuperAdmin sees all

    )

ORDER BY 

    st.part_no ASC;

end





-------------------------------

--- Display Surname Group -----

-------------------------------

create proc dis_voter_survey_log_sp

(

	@app_id int,

	@voter_id varchar(50)

)

as

begin



select

	s.survey_id,

	s.survey_by,

	s.voter_status,

	s.voter_available,

	s.not_available_reason,

	s.lat_long,

	s.visit_location,

	format(s.create_date,'dd MMM, yyyy') as survey_date,

	u.name,

	u.user_type,

	u.mobile_no

from

	tbl_voter_survey as s

	join tbl_user as u

on

	s.survey_by=u.user_id

where

	s.status=1

	and s.voter_idcard=@voter_id

	and s.app_id=@app_id

order by

	s.create_date desc

end







-------------------------------

--- Display Surname Group -----

-------------------------------

create proc sel_survey_detail_sp

(

	@survey_id int

)

as

begin



SELECT

    s.survey_id,

    s.voter_idcard,

    s.contact_no,

    s.[address],

   isnull((

        SELECT STUFF((

            SELECT ', ' + sch.scheme_name

            FROM dbo.SplitString(s.scheme_id_list, ',') AS scm

            JOIN tbl_scheme AS sch ON scm.Item = sch.scheme_id

            FOR XML PATH(''), TYPE

        ).value('.', 'nvarchar(max)'), 1, 2, '')

    ),'') as scheme,

    s.scheme_id_list,

    s.voter_status,

	u.name,

	u.mobile_no,

    s.survey_by,

    s.lat_long,

    s.visit_location,

	s.note,

	format(s.create_date,'dd MMM, yyyy hh:mm tt') as survey_date

FROM tbl_voter_survey AS s

LEFT JOIN tbl_user AS u ON s.survey_by = u.user_id

where

	s.survey_id=@survey_id

end







-------------------------------

--- Display Surname Group -----

-------------------------------

create proc dis_polling_location_wise_slip_send_dash_sp

(

	@app_id int

)

as

begin

;with pl as

(

	select

		r.eng_polling_location,

		count(1) as total_voter

	from

		tbl_voting_record as r

	where

		r.app_id=@app_id

	group by

		r.eng_polling_location

)



select

	p.eng_polling_location,

	p.total_voter,

	ss.[send],

	p.total_voter-ss.[send] as remain

from

	pl as p

	cross apply

	(

		select 

			count(*) as [send] 

		from 

			vw_get_uniq_sleep_send_date as s 

			join tbl_voting_record as r on s.idcard=r.idcard_no

		where 

			r.eng_polling_location=p.eng_polling_location

			and r.app_id=@app_id

	) as ss

end



------------------------

------- User Wise ------

------------------------

create proc polling_location_wise_slip_sending_voter_sp

(

	@app_id int,

	@polling_location nvarchar(1000)

)

as

begin

select

	v.id,

	v.slnoinpart,

	v.eng_f_name,

	v.f_eng_surname,

	v.eng_m_name,

	v.eng_surname,

	v.eng_localityid,

	v.eng_polling_location,

	v.idcard_no,

	v.contact_no,

	v.part_no,

	v.eng_house_no,

	ss.sleep_count

from

	vw_get_uniq_sleep_send_date as ss

	join tbl_voting_record as v

on

	ss.idcard=v.idcard_no

	and ss.app_id=v.app_id

where

	v.eng_polling_location=@polling_location

	and ss.app_id=@app_id

end





------------------------------

------- User Wise ------

------------------------------

create proc dis_user_wise_slip_distribution_sp

(

	@app_id int

)

as

begin



;with

slip_log as 

(

	select

		l.user_id,

		COUNT(distinct l.idcard) as total

	from

		tbl_log as l

	WHERE

		prachar_type IN ('SLEEP','SMS SLEEP','PRINT','WEB','W-SLEEP')

		AND l.idcard != ''

		and l.app_id=@app_id

	group by

		l.user_id

)



select

	u.user_id,

	u.name,

	u.user_type,

	u.mobile_no,

	case isnull(photo,'') when '' then '' else dbo.get_server_path()+'img/admin/'+photo end as photo_path,

	sl.total 

from 

	slip_log as sl

	join tbl_user as u on sl.user_id=u.user_id and u.app_id=@app_id



end







------------------------------

------- User Wise ------

------------------------------

dis_date_wise_slip_distribution_sp 10,'Apr 2026'

alter proc dis_date_wise_slip_distribution_sp

(

	@app_id int,

	@month datetime

)

as

begin



;with date_log as

(

	select

		format(l.create_date,'dd MMM, yyyy') as [date],

		COUNT(distinct l.idcard) as total

	from

		tbl_log as l

		join tbl_voting_record as r on r.idcard_no=l.idcard and r.app_id=@app_id

	WHERE

		l.app_id=@app_id

		and prachar_type IN ('SLEEP','SMS SLEEP','PRINT','WEB','W-SLEEP')

		AND l.idcard != ''

	group by

		format(l.create_date,'dd MMM, yyyy')

)

select

	format(d.date,'dd MMM, yyyy') as [date],

	isnull(l.total,0) as total

from

	get_all_date_by_month(@month) as d

	left join date_log as l on d.[date]=cast(l.[date] as date)

order by

	d.date

end







------------------------

------- User Wise ------

------------------------

--date_wise_slip_sending_voter_sp '17 Jun, 2025'

create proc date_wise_slip_sending_voter_sp

(

	@app_id int,

	@date datetime

)

as

begin

select

	v.id,

	v.slnoinpart,

	v.eng_f_name,

	v.f_eng_surname,

	v.eng_m_name,

	v.eng_surname,

	v.eng_localityid,

	v.eng_polling_location,

	v.idcard_no,

	v.contact_no,

	v.part_no,

	v.eng_house_no,

	ss.sleep_count

from

	vw_get_uniq_sleep_send_date as ss

	join tbl_voting_record as v

on

	ss.idcard=v.idcard_no

	and ss.app_id=v.app_id

where

	cast(ss.last_sleep_send_date as date)=cast(@date as date)

	and ss.app_id=@app_id

order by

	cast(ss.last_sleep_send_date as date) desc

end







--------------------------------------------------------

------------------- Master Search ----------------------

--------------------------------------------------------

--master_search_for_slip_send_sp 1,'priya','','','','',''

alter proc master_search_for_slip_send_sp

(

	@app_id int,

	@f_name nvarchar(500),

	@m_name nvarchar(500),

	@surname nvarchar(500),

	@mobile_no nvarchar(500),

	@id_card_no nvarchar(500)

)

as

begin

	select

		v.id,

		v.slnoinpart,

		v.eng_f_name,

		v.f_eng_surname,

		v.eng_m_name,

		v.eng_surname,

		v.eng_localityid,

		v.eng_polling_location,

		v.idcard_no,

		right(v.contact_no,10) as contact_no,

		v.part_no,

		v.eng_house_no,

		case when s.idcard is null then 0 else 1 end as slip_send,

		isnull(last_sleep_send_date,'') as send_date,

		s.sleep_count

	from 

		tbl_voting_record as v

		left join vw_get_uniq_sleep_send_date as s

	on

		v.idcard_no=s.idcard

		and v.idcard_no=s.idcard

	where

		v.app_id=@app_id

		and (@f_name='' OR v.eng_f_name LIKE '%' + @f_name + '%')

        AND (eng_surname LIKE '%' + @surname + '%')

        AND (@m_name='' OR v.eng_m_name LIKE '%' + @m_name + '%')

        AND (@mobile_no='' OR v.contact_no LIKE '%' + @mobile_no + '%')

        AND (@id_card_no='' OR v.idcard_no LIKE '%' + @id_card_no + '%')

	

end





-------------------------------

--- Display Surname Group -----

-------------------------------

--dis_my_slip_sending_voter_sp 1 , 1

alter proc dis_my_slip_sending_voter_sp

(

	@app_id int,

	@user_id int

)

as

begin

	;with s as

	(

		select

			app_id,

			idcard,

			count(1) as total

		from

			tbl_log

		where

			prachar_type IN ('SLEEP','SMS SLEEP','PRINT','WEB','W-SLEEP')

			and user_id=@user_id

			and app_id=@app_id

		group by

			app_id,

			idcard

	)







	select 

		r.id,

		r.slnoinpart,

		r.eng_f_name,

		r.f_eng_surname,

		r.eng_m_name,

		r.eng_surname,

		r.eng_localityid,

		r.eng_polling_location,

		r.idcard_no,

		r.contact_no,

		r.part_no,

		r.eng_house_no,

		s.total as sleep_count

	from 

		s

		join tbl_voting_record as r on s.idcard=r.idcard_no and r.app_id=s.app_id

    WHERE 

		r.app_id=@app_id



end







-------------------------------

--- Display Surname Group -----

-------------------------------

--phonebook_wise_slip_sending_sp 1

alter proc booth_wise_slip_sending_sp

(

	@app_id int,

	@part_no int

)

as

begin

select

	v.id,

	v.slnoinpart,

	v.eng_f_name,

	v.f_eng_surname,

	v.eng_m_name,

	v.eng_surname,

	v.eng_localityid,

	v.eng_polling_location,

	v.idcard_no,

	v.contact_no,

	v.part_no,

	v.eng_house_no,

	isnull(last_sleep_send_date,'') as send_date,

	case when ss.idcard is null then 0 else 1 end as slip_send,

	ss.sleep_count

from

	tbl_voting_record as v

	left join vw_get_uniq_sleep_send_date as ss

on

	v.idcard_no=ss.idcard

	and v.app_id=ss.app_id

where

	v.part_no=@part_no

	and v.app_id=@app_id

order by

	v.slnoinpart

end









--------------------------------------

---- Display Sakti Pramukh Cadre -----

--------------------------------------




--------------------------------------

---- Display Sakti Pramukh Cadre -----

--------------------------------------
--dis_booth_pramukh_by_sakti_pramukh_sp 1,18590
alter proc dis_booth_pramukh_by_sakti_pramukh_sp

(

	@app_id int,

	@user_id int

)

as

begin



SELECT

    b.booth_no,

    b.total_voter,

    bp.name,

	bp.mobile_no,

    bp.photo,

	case bp.photo when '' then '' else dbo.get_server_path()+'img/admin/'+bp.photo end as photo_path,

    FORMAT(bp.last_login, 'dd MMM, yyyy hh:mm tt') AS last_login

FROM tbl_user_booth AS ub

JOIN tbl_booth AS b ON ub.booth_no = b.booth_no AND b.app_id = @app_id

OUTER APPLY (

    SELECT TOP 1

        u.name,

		u.mobile_no,

        u.photo,

        u.last_login

    FROM tbl_user AS u

    WHERE u.app_id = @app_id

      AND u.booth_no = b.booth_no

      AND u.status = 1

      AND u.user_type = 'BP'

    ORDER BY u.last_login DESC

) AS bp

WHERE ub.status = 1

  AND ub.user_id = @user_id

ORDER BY b.booth_no;

end



--------------------------------------

---- Booth Captain by Warroom Pramukh -----

--------------------------------------
alter proc [dbo].[dis_booth_captain_by_warroom_pramukh_sp]

(

	@app_id int,
	@user_id int

)

as

begin



SELECT

    b.booth_no,

    b.total_voter,

    bc.name,

	bc.mobile_no,

    bc.photo,

	case bc.photo when '' then '' else dbo.get_server_path()+'img/admin/'+bc.photo end as photo_path,

    FORMAT(bc.last_login, 'dd MMM, yyyy hh:mm tt') AS last_login

FROM tbl_user_booth AS ub

JOIN tbl_booth AS b ON ub.booth_no = b.booth_no AND b.app_id = @app_id

OUTER APPLY (

    SELECT TOP 1

        u.name,

		u.mobile_no,

        u.photo,

        u.last_login

    FROM tbl_user AS u

    WHERE u.app_id = @app_id

      AND u.booth_no = b.booth_no

      AND u.status = 1

      AND u.user_type = 'BC'

    ORDER BY u.last_login DESC

) AS bc

WHERE ub.status = 1

  AND ub.user_id = @user_id

ORDER BY b.booth_no;

end









-------------------------------
--- Display Surname Group -----
-------------------------------

--dis_booth_wise_slip_send_dash_for_saktikendra_sp 1,'23,26,'

alter proc dis_booth_wise_slip_send_dash_for_saktikendra_sp

(

	@app_id int,

	@booth_no varchar(500)

)

as

begin

;with booth as 

(

	select Item as booth_no from dbo.SplitString(@booth_no,',')

),

sl as

(

	select

		count(s.idcard) as [send],

		r.part_no as booth_no

	from

		vw_get_uniq_sleep_send_date as s

		join tbl_voting_record as r on s.idcard=r.idcard_no and s.app_id=r.app_id

		join booth as b on b.booth_no=r.part_no

	where

		s.app_id=@app_id

	group by

		r.part_no

)



select

	b.booth_no,

	b.total_voter,

	isnull(sl.[send],0) as [send],

	b.total_voter-isnull(sl.[send],0) as remain

from

	booth

	join tbl_booth as b on booth.booth_no=b.booth_no

	left join sl on b.booth_no=sl.booth_no

where

	b.app_id=@app_id

order by

	CAST(b.booth_no AS int)

end





--dis_saktikendra_survey_dashboard 1,'23,26,'

alter proc dis_saktikendra_survey_dashboard

(

	@app_id int,

	@booth varchar(100)

)

as

begin



	

;with b as

(

	select item as booth from dbo.SplitString(@booth,',')

)



SELECT

    COUNT(1) AS total_survey,

    SUM(CASE WHEN s.voter_available = 0 THEN 1 ELSE 0 END) AS not_available

FROM 

	b

	join tbl_voter_survey as s on s.booth_no=b.booth

where

	s.app_id=@app_id

	



;with b as

(

	select item as booth from dbo.SplitString(@booth,',')

)



SELECT

    ISNULL(P, 0)  AS p,

    ISNULL(N, 0)   AS n,

    ISNULL(D, 0)  AS d,

	ISNULL(C, 0)  AS c

FROM

(

    SELECT

        s.voter_status

    FROM tbl_voter_survey AS s

	join b on s.booth_no=b.booth

    WHERE

        s.app_id = @app_id

        AND s.voter_available = 1

) AS src

PIVOT

(

    COUNT(voter_status)

    FOR voter_status IN (P, N, D,C)

) AS p;





end

ALTER PROCEDURE [dbo].[ins_app_sp]

    -- tbl_app Parameters (Full List)

    @vidhansabha_no int,

    @vidhansabha_name NVARCHAR(500),

    @total_voter INT,

    @candidate_no VARCHAR(500),

    @candidate_name NVARCHAR(500),

    @party_short_name NVARCHAR(20),

    @party_full_name NVARCHAR(500),

    @party_logo_png NVARCHAR(MAX),

    @party_logo_jpg NVARCHAR(MAX),

    @slip_message NVARCHAR(MAX),

    @sms_slip_message NVARCHAR(MAX),    -- Added

    @invitation_message NVARCHAR(MAX),

    @offline_status INT, 

    @offline_db_url NVARCHAR(MAX),

    @offline_ver NVARCHAR(50),          -- Added

    @splace_url NVARCHAR(MAX),          -- Added

    @app_link NVARCHAR(MAX),            -- Added

    @app_ver NVARCHAR(50),

    @popup_status INT,

    @popup_url VARCHAR(MAX),

    @create_by INT,



    -- Module Rights Parameters

    @call_center TINYINT = 0,

    @prachar TINYINT = 0,

    @aachar_sahita TINYINT = 0,

    @live_voting TINYINT = 0,

    @sleep_send TINYINT = 0,

    @meta_wtsp TINYINT = 0,

    @AI TINYINT = 0

AS

BEGIN

    SET NOCOUNT ON;

    

    DECLARE @NewAppID INT;



    -- 1. Insert into tbl_app

    INSERT INTO [dbo].[tbl_app] (

        vidhansabha_no,

        vidhansabha_name,

        total_voter,

        candidate_no,

        candidate_name,

        party_short_name,

        party_full_name,

        party_logo_png,

        party_logo_jpg,

        slip_message,

        sms_slip_message,

        invitation_message,

        offline_status,

        offline_db_url,

        offline_ver,

        splace_url,

        app_link,

        video_link,

        app_ver,

        status,

        create_by,

        create_date,

        popup_status,

        popup_url

    )

    VALUES (

        @vidhansabha_no,

        @vidhansabha_name,

        @total_voter,

        @candidate_no,

        @candidate_name,

        @party_short_name,

        @party_full_name,

        @party_logo_png,

        @party_logo_jpg,

        @slip_message,

        @sms_slip_message,

        @invitation_message,

        @offline_status,

        @offline_db_url,

        @offline_ver,

        @splace_url,

        @app_link,

        '',

        @app_ver,

        1, -- status (Active)

        @create_by,

        dbo.get_date(),

        @popup_status,

        @popup_url

    );



    -- Capture the auto-generated ID

    SET @NewAppID = SCOPE_IDENTITY();



    -- 2. Insert into module_rights_management

    INSERT INTO module_rights_management (

        app_id,

        call_center,

        prachar,

        aachar_sahita,

        live_voting,

        sleep_send,

        meta_wtsp,

        AI,

        update_date

    )

    VALUES (

        @NewAppID,

        @call_center,

        @prachar,

        @aachar_sahita,

        @live_voting,

        @sleep_send,

        @meta_wtsp,

        @AI,

        dbo.get_date()

    );



    -- Return the newly created ID

    SELECT @NewAppID AS app_id;

END





alter PROCEDURE [dbo].[upd_app_sp]

    -- Identify which record to update

    @app_id INT,



    -- tbl_app Parameters

    @vidhansabha_no int,

    @vidhansabha_name NVARCHAR(500),

    @total_voter INT,

    @candidate_no NVARCHAR(500),

    @candidate_name NVARCHAR(500),

    @party_short_name NVARCHAR(20),

    @party_full_name NVARCHAR(500),

    @party_logo_png NVARCHAR(MAX),

    @party_logo_jpg NVARCHAR(MAX),

    @slip_message NVARCHAR(MAX),

    @sms_slip_message NVARCHAR(MAX),

    @invitation_message NVARCHAR(MAX),

    @offline_status INT, 

    @offline_db_url NVARCHAR(MAX),

    @offline_ver NVARCHAR(50),

    @splace_url NVARCHAR(MAX),

    @app_link NVARCHAR(MAX),

    @app_ver NVARCHAR(50),

    @popup_status INT,

    @popup_url VARCHAR(MAX),

    @update_by INT, -- Changed from create_by to track who edited



    -- Module Rights Parameters

    @call_center TINYINT,

    @prachar TINYINT,

    @aachar_sahita TINYINT,

    @live_voting TINYINT,

    @sleep_send TINYINT,

    @meta_wtsp TINYINT,

    @AI TINYINT

AS

BEGIN

    SET NOCOUNT ON;



    -- 1. Update tbl_app

    UPDATE [dbo].[tbl_app]

    SET 

        vidhansabha_no = @vidhansabha_no,

        vidhansabha_name = @vidhansabha_name,

        total_voter = @total_voter,

        candidate_no = @candidate_no,

        candidate_name = @candidate_name,

        party_short_name = @party_short_name,

        party_full_name = @party_full_name,

        party_logo_png = @party_logo_png,

        party_logo_jpg = @party_logo_jpg,

        slip_message = @slip_message,

        sms_slip_message = @sms_slip_message,

        invitation_message = @invitation_message,

        offline_status = @offline_status,

        offline_db_url = @offline_db_url,

        offline_ver = @offline_ver,

        splace_url = @splace_url,

        app_link = @app_link,

        app_ver = @app_ver,

        popup_status = @popup_status,

        popup_url = @popup_url,

        -- We typically don't change create_by, but we can log the editor

        modify_by = @update_by, 

        modify_date = dbo.get_date()

    WHERE app_id = @app_id;



    -- 2. Update module_rights_management

    UPDATE [dbo].[module_rights_management]

    SET 

        call_center = @call_center,

        prachar = @prachar,

        aachar_sahita = @aachar_sahita,

        live_voting = @live_voting,

        sleep_send = @sleep_send,

        meta_wtsp = @meta_wtsp,

        AI = @AI,

        update_date = dbo.get_date()

    WHERE app_id = @app_id;



    -- Return the affected ID to confirm success

    SELECT @app_id AS app_id;

END



alter PROCEDURE [dbo].sel_app_sp

    @app_id INT

AS

BEGIN

   SET NOCOUNT ON;



    SELECT 

        -- tbl_app Columns

        a.app_id,

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

        a.invitation_message,

        a.offline_status,

        a.offline_db_url,

        a.offline_ver,

        a.splace_url,

        a.app_link,

        a.app_ver,

        a.status,

        a.popup_status,

        a.popup_url,



        -- Module Rights Columns (Joined)

        ISNULL(m.call_center, 0) AS call_center,

        ISNULL(m.prachar, 0) AS prachar,

        ISNULL(m.aachar_sahita, 0) AS aachar_sahita,

        ISNULL(m.live_voting, 0) AS live_voting,

        ISNULL(m.sleep_send, 0) AS sleep_send,

        ISNULL(m.meta_wtsp, 0) AS meta_wtsp,

        ISNULL(m.AI, 0) AS AI

    FROM 

        [dbo].[tbl_app] a

    LEFT JOIN 

        [dbo].[module_rights_management] m ON a.app_id = m.app_id

    WHERE 

        a.app_id = @app_id;

END





create proc dis_all_address_sp

(

	@app_id int

)

as

begin

	select 

		add_uni,

		add_eng,

		total_voter

	from 

		tbl_address as a

	where

		a.app_id=@app_id

end





--------------------------------------

------- Display Booth Wise Voter -----

--------------------------------------

--dis_polling_location_wise_voter_sp 'BHARAT RATNALNDIRA GANDHI VIDYA MANDIR, ROOM NO 81, VEER SAVARKAR NAGAR,GR.FIR. THANE, 400604'

alter proc dis_address_wise_voter_sp

(

	@app_id int,

	@address nvarchar(max)

)

as

begin

	SET NOCOUNT ON;



	select 

		r.id,

		r.eng_f_name+' ('+(f_name)+')' as eng_f_name,

		r.f_eng_surname+' ('+(f_surname)+')' as f_eng_surname,

		r.eng_m_name+' ('+(m_name)+')' as eng_m_name,

		r.eng_surname+' ('+(surname)+')' as eng_surname,

		r.part_no,

		r.eng_localityid,

		r.part_no as booth_no,

		right(r.contact_no,10) as contact_no,

		r.idcard_no,

		r.slnoinpart,

		r.eng_polling_location,

		r.sex,

		r.eng_house_no

	from 

		tbl_voting_record as r

	where

		(eng_localityid=@address or localityid=@address)

		and r.app_id=@app_id

	order by

		slnoinpart

end





-------------------------------

--- Display Surname Group -----

-------------------------------

create proc dis_volunteer_slip_sending_count_sp

(

	@app_id int

)

as

begin

;with sl as

(

	select

		app_id,

		user_id,

		count(user_id) as total

	from

		vw_get_user_wise_uniq_sleep_send

	where

		app_id=@app_id

	group by

		app_id,

		user_id

)



select

	u.user_id,

	u.user_type,

	u.name,

	u.mobile_no,

	case u.photo when '' then dbo.get_server_path()+'img/admin/user.png' else dbo.get_server_path()+'img/admin/'+photo end as photo_path,

	s.total

from

	sl as s

	join tbl_user as u

on

	s.user_id=u.user_id

order by

	s.total desc



	

end







-------------------------------

--- Display Surname Group -----

-------------------------------

create proc ins_offline_user_sp

(

	@app_id int,

	@user_id int

)

as

begin



	delete from tbl_offline_user where user_id=@user_id and app_id=@app_id



	insert into tbl_offline_user

	values

	(

		@app_id,

		@user_id,

		dbo.get_date(),

		null

	)



	declare @syc_id int =@@IDENTITY

	select @syc_id as syc_id

end









-------------------------------

--- Display Surname Group -----

-------------------------------

create proc offline_syc_complete_sp

(

	@syc_id int

)

as

begin

	update tbl_offline_user

	set

		end_time=dbo.get_date()

	where

		id=@syc_id



		

	select 'ok'

end







-----------------------------------

------ Call Center Survey ---------

-----------------------------------

create PROC dis_booth_wise_call_center_survey_dash_sp

(

	@app_id int

)

AS

BEGIN

    SET NOCOUNT ON; -- This stops the "X rows affected" message, slightly boosting performance



    SELECT 

        b.booth_no, 

        ISNULL(s.nr, 0) AS nr,

        ISNULL(s.wm, 0) AS wm,

        ISNULL(s.p, 0) AS p,

        ISNULL(s.n, 0) AS n,

        ISNULL(s.c, 0) AS c,

        ISNULL(s.d, 0) AS d,

        (ISNULL(s.nr, 0) + ISNULL(s.wm, 0) + ISNULL(s.p, 0) + ISNULL(s.n, 0) + ISNULL(s.c, 0) + ISNULL(s.d, 0)) AS total

    FROM tbl_booth b

    LEFT JOIN 

    (

        -- Conditional Aggregation is much faster than PIVOT for 100M+ rows

        SELECT 

            booth_no,

            SUM(CASE WHEN voter_status = 'nr' THEN 1 ELSE 0 END) AS nr,

            SUM(CASE WHEN voter_status = 'wm' THEN 1 ELSE 0 END) AS wm,

            SUM(CASE WHEN voter_status = 'p' THEN 1 ELSE 0 END) AS p,

            SUM(CASE WHEN voter_status = 'n' THEN 1 ELSE 0 END) AS n,

            SUM(CASE WHEN voter_status = 'c' THEN 1 ELSE 0 END) AS c,

            SUM(CASE WHEN voter_status = 'd' THEN 1 ELSE 0 END) AS d

        FROM get_call_central_uniq_survey_view where app_id=@app_id

        GROUP BY booth_no

    ) s ON b.booth_no = s.booth_no

	where b.app_id=@app_id

    ORDER BY b.booth_no;



END







-----------------------------------

------ Call Center Survey ---------

-----------------------------------

create PROC dis_date_wise_call_center_survey_dash_sp

(

    @app_id int,         -- Added app_id parameter

    @month datetime

)

AS

BEGIN

    SET NOCOUNT ON;



    SELECT 

        FORMAT(d.date, 'dd MMM, yyyy') AS date, 

        ISNULL(s.nr, 0) AS nr,

        ISNULL(s.wm, 0) AS wm,

        ISNULL(s.p, 0) AS p,

        ISNULL(s.n, 0) AS n,

        ISNULL(s.c, 0) AS c,

        ISNULL(s.d, 0) AS d,

        (ISNULL(s.nr, 0) + ISNULL(s.wm, 0) + ISNULL(s.p, 0) + ISNULL(s.n, 0) + ISNULL(s.c, 0) + ISNULL(s.d, 0)) AS total

    FROM get_all_date_by_month(@month) d

    LEFT JOIN 

    (

        -- Using Conditional Aggregation for maximum speed on 100M+ rows

        SELECT 

            CAST(create_date AS DATE) AS create_date, 

            SUM(CASE WHEN voter_status = 'nr' THEN 1 ELSE 0 END) AS nr,

            SUM(CASE WHEN voter_status = 'wm' THEN 1 ELSE 0 END) AS wm,

            SUM(CASE WHEN voter_status = 'p' THEN 1 ELSE 0 END) AS p,

            SUM(CASE WHEN voter_status = 'n' THEN 1 ELSE 0 END) AS n,

            SUM(CASE WHEN voter_status = 'c' THEN 1 ELSE 0 END) AS c,

            SUM(CASE WHEN voter_status = 'd' THEN 1 ELSE 0 END) AS d

        FROM get_call_central_uniq_survey_view

        WHERE app_id = @app_id  -- Filter 1: By App ID

          

          -- Filter 2: Performance Boost! Only scan records for this specific month

          AND create_date >= DATEADD(month, DATEDIFF(month, 0, @month), 0)

          AND create_date < DATEADD(month, DATEDIFF(month, 0, @month) + 1, 0)

          

        GROUP BY CAST(create_date AS DATE)

    ) s ON d.date = s.create_date

    ORDER BY d.date;

END





-----------------------------------

------ Call Center Survey ---------

-----------------------------------

create proc ins_call_center_survey

(

	@app_id int,

	@voter_idcard varchar(100),

	@voter_status varchar(10),

	@note nvarchar(max),

	@create_by int

)

as

begin

	insert into tbl_call_center_survey

	values

	(

		@app_id,

		@voter_idcard,

		@voter_status,

		@note,

		@create_by,

		1,

		dbo.get_date()

	)



	select 'ok'

end







-----------------------------------

------ Call Center Survey ---------

-----------------------------------

create PROC dis_booth_wise_voter_list_for_call_center_sp

(

    @app_id INT,

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

        r.eng_localityid,

        r.eng_polling_location,

        r.idcard_no,

        RIGHT(r.contact_no, 10) AS contact_no,

        r.part_no,

        r.eng_house_no,

        ISNULL(s.voter_status, '') AS voter_status,

        ISNULL(s.create_by, 0) AS survey_by_id,

        ISNULL(s.note, '') AS note,

        CASE WHEN s.survey_id IS NULL THEN 0 ELSE 1 END AS survey

    FROM

        tbl_voting_record AS r

        

        -- OUTER APPLY is exponentially faster here. It runs this tiny subquery 

        -- ONLY for the voters in this specific booth.

        OUTER APPLY

        (

            SELECT TOP 1 

                survey_id,    -- Grabs the ID to check if it exists

                voter_status, 

                create_by, 

                note

            FROM tbl_call_center_survey 

            WHERE voter_idcard = r.idcard_no 

              AND app_id = @app_id

            ORDER BY create_date DESC -- Ensures we only get their absolute latest survey

        ) AS s

        

    WHERE

        r.part_no = @booth_no

		and r.app_id=@app_id;

END



-----------------------------------

------ Call Center Survey ---------

-----------------------------------

--dis_date_wise_call_center_survey_voter_sp 1,'27 Mar, 2026'

alter PROC dis_date_wise_call_center_survey_voter_sp

(

    @app_id INT,

    @date DATETIME

)

AS

BEGIN

    SET NOCOUNT ON;



    -- Step 1: Grab only the unique surveys for this specific Date and App

    WITH DailySurveys AS

    (

        SELECT 

            voter_idcard,

            voter_status,

            survey_id,

            note,

            create_by,

            ROW_NUMBER() OVER (PARTITION BY voter_idcard ORDER BY create_date DESC) AS rn

        FROM tbl_call_center_survey

        WHERE app_id = @app_id -- 1st Table Filtered

          AND create_date >= CAST(@date AS DATE)

          AND create_date < DATEADD(day, 1, CAST(@date AS DATE))

    )

    

    -- Step 2: Join that small daily list to the massive Voter and Admin tables

    SELECT

        v.id,

        v.slnoinpart,

        v.idcard_no,

        v.eng_f_name,

        v.f_eng_surname,

        v.eng_m_name,

        v.eng_surname,

        v.eng_localityid,

        v.eng_polling_location,

        v.contact_no,

        v.part_no,

        v.eng_house_no,

        ISNULL(s.voter_status, '') AS voter_status,

        ISNULL(s.survey_id, 0) AS survey_id,

        ISNULL(s.note, '') AS note

    FROM

        DailySurveys s

        -- 2nd Table Filtered directly on the JOIN

        INNER JOIN tbl_voting_record v 

            ON s.voter_idcard = v.idcard_no 

            AND v.app_id = @app_id 

            

     

    WHERE

        s.rn = 1 

        AND v.idcard_no != '';



END



-----------------------------------

------ Call Center Survey ---------

-----------------------------------

alter PROC dis_booth_wise_call_center_survey_voter_sp

(

    @app_id INT,

    @booth_no INT

)

AS

BEGIN

    SET NOCOUNT ON;



    SELECT

        v.id,

        v.slnoinpart,

        v.idcard_no,

        v.eng_f_name,

        v.f_eng_surname,

        v.eng_m_name,

        v.eng_surname,

        v.eng_localityid,

        v.eng_polling_location,

        v.contact_no,

        v.part_no,

        v.eng_house_no,

        ISNULL(s.voter_status, '') AS voter_status,

        ISNULL(s.survey_id, 0) AS survey_id,

        ISNULL(s.note, '') AS note

    FROM tbl_voting_record v

    

    -- CROSS APPLY acts like an INNER JOIN. It will strictly return voters 

    -- who have a matching survey, grabbing only their absolute latest one!

    CROSS APPLY 

    (

        SELECT TOP 1 

            survey_id,

            voter_status,

            note,

            create_by

        FROM tbl_call_center_survey

        WHERE voter_idcard = v.idcard_no

          AND app_id = @app_id -- Secured by App ID

        ORDER BY create_date DESC

    ) s

    

   

        

    WHERE 

        v.part_no = @booth_no 

        AND v.app_id = @app_id -- Base table secured by App ID

        AND v.idcard_no != '';



END





------------------------------

------- User Wise ------

------------------------------

alter PROC dis_user_wise_call_center_survey_voter_sp

(

    @app_id INT,

    @user_id INT

)

AS

BEGIN

    SET NOCOUNT ON;



    -- Step 1: Instantly isolate ONLY the surveys done by this specific user

    WITH UserSurveys AS

    (

        SELECT 

            voter_idcard,

            voter_status,

            survey_id,

            note,

            create_by,

            -- Ensures if this user called the same person twice, we only show their latest call

            ROW_NUMBER() OVER (PARTITION BY voter_idcard ORDER BY create_date DESC) AS rn

        FROM tbl_call_center_survey

        WHERE create_by = @user_id 

          AND app_id = @app_id -- 1st Table Secured

    )

    

    -- Step 2: Join that user's tiny list of surveys to the master tables

    SELECT

        v.id,

        v.slnoinpart,

        v.idcard_no,

        v.eng_f_name,

        v.f_eng_surname,

        v.eng_m_name,

        v.eng_surname,

        v.eng_localityid,

        v.eng_polling_location,

        v.contact_no,

        v.part_no,

        v.eng_house_no,

        ISNULL(s.voter_status, '') AS voter_status,

        ISNULL(s.survey_id, 0) AS survey_id,

        ISNULL(s.note, '') AS note

    FROM

        UserSurveys s

        

        -- 2nd Table Secured

        INNER JOIN tbl_voting_record v 

            ON s.voter_idcard = v.idcard_no 

            AND v.app_id = @app_id

            

      

    WHERE

        s.rn = 1 

        AND v.idcard_no != '';



END





------------------------------

------- User Wise ------

------------------------------

alter PROC dis_user_wise_call_center_survey_dash_sp

(

    @app_id INT,

    @date DATETIME = NULL

)

AS

BEGIN

    SET NOCOUNT ON;



    SELECT 

        u.user_id,

        u.name,

        u.mobile_no,

        ISNULL(s.nr, 0) AS nr,

        ISNULL(s.wm, 0) AS wm,

        ISNULL(s.p, 0) AS p,

        ISNULL(s.n, 0) AS n,

        ISNULL(s.c, 0) AS c,

        ISNULL(s.d, 0) AS d,

        (ISNULL(s.nr, 0) + ISNULL(s.wm, 0) + ISNULL(s.p, 0) + ISNULL(s.n, 0) + ISNULL(s.c, 0) + ISNULL(s.d, 0)) AS total

    FROM tbl_user u

    -- Join directly to our grouped calculations

    INNER JOIN 

    (

        -- Step 2: Group the unique records by user and count the statuses

        SELECT 

            create_by,

            SUM(CASE WHEN voter_status = 'nr' THEN 1 ELSE 0 END) AS nr,

            SUM(CASE WHEN voter_status = 'wm' THEN 1 ELSE 0 END) AS wm,

            SUM(CASE WHEN voter_status = 'p' THEN 1 ELSE 0 END) AS p,

            SUM(CASE WHEN voter_status = 'n' THEN 1 ELSE 0 END) AS n,

            SUM(CASE WHEN voter_status = 'c' THEN 1 ELSE 0 END) AS c,

            SUM(CASE WHEN voter_status = 'd' THEN 1 ELSE 0 END) AS d

        FROM 

        (

            -- Step 1: Isolate the unique surveys, properly filtered by Date and App ID

            SELECT 

                create_by, 

                voter_status,

                ROW_NUMBER() OVER (PARTITION BY voter_idcard ORDER BY create_date DESC) AS rn

            FROM tbl_call_center_survey

            WHERE app_id = @app_id -- Security 1st

              -- SARGable optional date filter (Uses Indexes Instantly)

              AND (

                  @date IS NULL 

                  OR 

                  (create_date >= CAST(@date AS DATE) AND create_date < DATEADD(day, 1, CAST(@date AS DATE)))

              )

        ) AS UniqueSurveys

        WHERE rn = 1

        GROUP BY create_by

    ) s ON u.user_id = s.create_by

    WHERE u.app_id = @app_id -- Security 2nd

    ORDER BY u.name;



END





------------------------------

------- User Wise ------

------------------------------

create PROC dis_admin_call_center_survey_dashboard_sp

(

    @app_id INT

)

AS

BEGIN

    SET NOCOUNT ON;



    -- ==========================================

    -- TABLE 0: OVERALL (ALL-TIME) DASHBOARD

    -- ==========================================

    WITH UniqueAllTime AS (

        SELECT 

            voter_status,

            ROW_NUMBER() OVER (PARTITION BY voter_idcard ORDER BY create_date DESC) AS rn

        FROM tbl_call_center_survey

        WHERE app_id = @app_id -- Multi-tenant security

    )

    SELECT

        ISNULL(SUM(CASE WHEN voter_status = 'P' THEN 1 ELSE 0 END), 0) AS P,

        ISNULL(SUM(CASE WHEN voter_status = 'N' THEN 1 ELSE 0 END), 0) AS N,

        ISNULL(SUM(CASE WHEN voter_status = 'D' THEN 1 ELSE 0 END), 0) AS D,

        ISNULL(SUM(CASE WHEN voter_status = 'C' THEN 1 ELSE 0 END), 0) AS C,	

        ISNULL(SUM(CASE WHEN voter_status = 'NR' THEN 1 ELSE 0 END), 0) AS NR,

        ISNULL(SUM(CASE WHEN voter_status = 'WM' THEN 1 ELSE 0 END), 0) AS WM

    FROM UniqueAllTime

    WHERE rn = 1;



    -- ==========================================

    -- TABLE 1: TODAY'S DASHBOARD

    -- ==========================================

    -- By filtering the date INSIDE the CTE, SQL only sorts today's records (blazing fast)

    WITH UniqueToday AS (

        SELECT 

            voter_status,

            ROW_NUMBER() OVER (PARTITION BY voter_idcard ORDER BY create_date DESC) AS rn

        FROM tbl_call_center_survey

        WHERE app_id = @app_id

          -- Index-friendly (SARGable) Date logic for exactly "Today"

          AND create_date >= CAST(dbo.get_date() AS DATE)

          AND create_date < DATEADD(day, 1, CAST(dbo.get_date() AS DATE))

    )

    SELECT

        ISNULL(SUM(CASE WHEN voter_status = 'P' THEN 1 ELSE 0 END), 0) AS P,

        ISNULL(SUM(CASE WHEN voter_status = 'N' THEN 1 ELSE 0 END), 0) AS N,

        ISNULL(SUM(CASE WHEN voter_status = 'D' THEN 1 ELSE 0 END), 0) AS D,

        ISNULL(SUM(CASE WHEN voter_status = 'C' THEN 1 ELSE 0 END), 0) AS C,	

        ISNULL(SUM(CASE WHEN voter_status = 'NR' THEN 1 ELSE 0 END), 0) AS NR,

        ISNULL(SUM(CASE WHEN voter_status = 'WM' THEN 1 ELSE 0 END), 0) AS WM

    FROM UniqueToday

    WHERE rn = 1;



END





-------------------------------

--- Display Surname Group -----

-------------------------------

create proc upd_voter_mobile_sp

(

	@app_id int,

	@voter_id varchar(50),

	@mobile_no varchar(12),

	@modify_by int

)

as

begin



	insert into tbl_log

	values

	(	

		@app_id,

		@voter_id,

		@modify_by,

		'MBC',

		dbo.get_date()

	)

	

	

	update tbl_voting_record

	set

		contact_no=@mobile_no

	where

		idcard_no=@voter_id

		and app_id=@app_id



	select 'ok'

end



alter proc dis_voter_capation_wise_voter_sp
(
	@app_id  INT,
	@user_id INT
)
as
begin
 ;WITH FamilyRanking AS (
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
            r.family_id, -- કુટુંબ ઓળખવા માટે
            ISNULL(s.survey_id, 0) AS survey_id,
            s.voter_available,
            s.voter_status,
            s.not_available_reason,
            
            -- કુટુંબમાં સૌથી મોટી ઉંમર વાળાને ક્રમ ૧ આપવા માટે (જો ઉંમર સરખી હોય તો સીરીયલ નંબર પ્રમાણે)
            ROW_NUMBER() OVER (
                PARTITION BY r.family_id 
                ORDER BY CAST(r.age AS INT) DESC, CAST(r.slnoinpart AS INT) ASC
            ) AS AgeRank,
            
            -- તે જ કુટુંબમાં કુલ કેટલા સભ્યો છે તેનો કાઉન્ટ
            COUNT(1) OVER (PARTITION BY r.family_id) AS family_member_count

        FROM dbo.tbl_user AS u WITH (NOLOCK)
        INNER JOIN dbo.tbl_voting_record AS r WITH (NOLOCK)
            ON  r.app_id      = u.app_id
            AND r.part_no    = u.booth_no
            AND CAST(r.slnoinpart AS INT) >= CAST(u.start_voter_no AS INT)
            AND CAST(r.slnoinpart AS INT) <= CAST(u.end_voter_no AS INT)
        LEFT JOIN dbo.tbl_voter_survey AS s WITH (NOLOCK)
            ON  s.voter_idcard = r.idcard_no
            AND s.app_id       = r.app_id
            AND s.status       = 1
            AND s.is_latest    = 1
        WHERE u.user_id   = @user_id
          AND u.app_id    = @app_id
          AND u.status    = 1
          AND u.user_type = 'VC'
    )
    
    -- ૨. હવે મેઈન સિલેક્ટમાં માત્ર સૌથી મોટી ઉંમર વાળા (AgeRank = 1) મતદારો જ ફિલ્ટર થશે
    SELECT
        id,
        slnoinpart,
        eng_f_name,
        f_eng_surname,
        eng_m_name,
        eng_surname,
        part_no,
        booth_no,
        contact_no,
        idcard_no,
        sex,
        age,
        eng_house_no,
        eng_localityid,
        eng_polling_location,
        family_id,
        family_member_count, -- કુટુંબના કુલ સભ્યોની સંખ્યા
        survey_id,
        voter_available,
        voter_status,
        not_available_reason,
		AgeRank
    FROM 
        FamilyRanking
    
    ORDER BY
        CAST(slnoinpart AS INT);
end



--dis_cadre_dash_sp 1, 1
alter PROCEDURE [dbo].[dis_cadre_dash_sp]
(
    @app_id  INT,
    @user_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH contact AS (
        SELECT COUNT(user_id) AS contact_group
        FROM dbo.tbl_contact_group
        WHERE user_id = @user_id
          AND app_id = @app_id
    ),
    surname AS (
        SELECT COUNT(user_id) AS surname_group
        FROM dbo.tbl_surname_group
        WHERE user_id = @user_id
          AND app_id = @app_id
    ),
    my_member AS (
        SELECT COUNT(user_id) AS my_member
        FROM dbo.tbl_my_group
        WHERE user_id = @user_id
          AND app_id = @app_id
    ),
    slip_send AS (
        SELECT COUNT(user_id) AS slip_send
        FROM dbo.vw_get_user_wise_uniq_sleep_send
        WHERE user_id = @user_id
          AND app_id = @app_id
    )
    SELECT
        contact_group,
        surname_group,
        my_member,
        slip_send
    FROM contact, surname, my_member, slip_send;

	
select
	title,
	content,
	show_status,
	CASE media_type 
        WHEN 'i' THEN dbo.get_server_path() + 'img/popup/images/' + m.media_url 
        WHEN 'a' THEN dbo.get_server_path() + 'img/popup/audio/' + m.media_url 
        ELSE m.media_url -- YouTube, FB વગેરે ડાયરેક્ટ લિંક્સ માટે બેકઅપ
    END AS media_url_path
from
	tbl_PopupAlert as p
	join tbl_PopupAlertMedia as m on p.popup_id=m.popup_id and m.status=1
where
	p.status=1
	and p.is_active=1
	and p.app_id=@app_id
END
GO

--get_all_match_surname_list 3, 'vaghasiya'
CREATE OR ALTER PROCEDURE [dbo].[get_all_match_surname_list]
(
    @app_id       INT,
    @search_input VARCHAR(100)
)
AS
BEGIN
  
 DECLARE @CleanInput VARCHAR(100) = REPLACE(REPLACE(REPLACE(REPLACE(@search_input, 'w', 'v'), 'h', ''), 'y', ''), 'i', '');

SELECT eng_surname
FROM tbl_surname
WHERE app_id = @app_id
  AND LEFT(eng_surname, 1) = LEFT(@search_input, 1) -- ફાસ્ટ પર્ફોર્મન્સ માટે
  AND (
        -- લોજિક ૧: ઓરિજિનલ લેવેનસ્ટેઈન ડિસ્ટન્સ (જો ૨ અક્ષરની ભૂલ હોય)
        dbo.fn_GetLevenshteinDistance(eng_surname, @search_input) <= 2 
        
        OR 
        
        -- લોજિક ૨: જો 'H', 'W', 'Y', 'I' ની ભૂલો હોય તો તેને કાઢીને ચેક કરશે (આનાથી એક્યુરેસી વધી જશે)
        dbo.fn_GetLevenshteinDistance(
            REPLACE(REPLACE(REPLACE(REPLACE(eng_surname, 'w', 'v'), 'h', ''), 'y', ''), 'i', ''), 
            @CleanInput
        ) <= 1
  )
GROUP BY eng_surname
ORDER BY MIN(dbo.fn_GetLevenshteinDistance(eng_surname, @search_input)) ASC;
END
GO


alter PROC dis_shaktikendra_wise_survey_dash_sp
(
	 @app_id int,
	 @survey_by varchar(10)
)
AS
BEGIN

;WITH s AS
(
    SELECT
        s.survey_by,
        CASE 
            WHEN s.voter_available = 0 THEN 'NA'
            ELSE s.voter_status
        END AS voter_status,
        COUNT(1) AS total
    FROM vw_user_latest_voter_survey AS s
    WHERE
        s.status = 1
		AND s.app_id = @app_id
    GROUP BY
        s.survey_by,
        CASE 
            WHEN s.voter_available = 0 THEN 'NA'
            ELSE s.voter_status
        END
),

p AS
(
    SELECT
        survey_by,
        ISNULL([P],0)  AS P,
        ISNULL([N],0)  AS N,
        ISNULL([D],0)  AS D,
        ISNULL([C],0)  AS C,
        ISNULL([NA],0) AS NA
    FROM s
    PIVOT
    (
        SUM(total)
        FOR voter_status IN ([P],[N],[D],[C],[NA])
    ) pv
)

SELECT
    u.user_id,
    u.name,
	u.[user_type],
	dbo.fn_get_designation(u.[user_type]) AS designation,
    u.mobile_no,
    u.photo,
	CASE ISNULL(u.photo,'') WHEN '' THEN '' ELSE dbo.get_server_path()+'img/admin/'+u.photo END AS photo_path,
    ISNULL(p.P,0)  AS P,
    ISNULL(p.N,0)  AS N,
    ISNULL(p.D,0)  AS D,
    ISNULL(p.C,0)  AS C,
    ISNULL(p.NA,0) AS NA,
	ISNULL(P,0)+ISNULL(N,0)+ISNULL(D,0)+ISNULL(C,0)+ISNULL(NA,0) AS total_survey
FROM p
JOIN tbl_user AS u ON p.survey_by = u.user_id
WHERE u.app_id = @app_id
  AND u.[user_type] = @survey_by -- Filter added here to only include 'SP' user types

END


create PROC dis_karykarta_wise_survey_dash_sp
(
	 @app_id int
)
AS
BEGIN

;WITH s AS
(
    SELECT
        s.survey_by,
        CASE 
            WHEN s.voter_available = 0 THEN 'NA'
            ELSE s.voter_status
        END AS voter_status,
        COUNT(1) AS total
    FROM vw_user_latest_voter_survey AS s
    WHERE
        s.status = 1
		AND s.app_id = @app_id
    GROUP BY
        s.survey_by,
        CASE 
            WHEN s.voter_available = 0 THEN 'NA'
            ELSE s.voter_status
        END
),

p AS
(
    SELECT
        survey_by,
        ISNULL([P],0)  AS P,
        ISNULL([N],0)  AS N,
        ISNULL([D],0)  AS D,
        ISNULL([C],0)  AS C,
        ISNULL([NA],0) AS NA
    FROM s
    PIVOT
    (
        SUM(total)
        FOR voter_status IN ([P],[N],[D],[C],[NA])
    ) pv
)

SELECT
    u.user_id,
    u.name,
	u.[user_type],
	dbo.fn_get_designation(u.[user_type]) AS designation,
    u.mobile_no,
    u.photo,
	CASE ISNULL(u.photo,'') WHEN '' THEN '' ELSE dbo.get_server_path()+'img/admin/'+u.photo END AS photo_path,
    ISNULL(p.P,0)  AS P,
    ISNULL(p.N,0)  AS N,
    ISNULL(p.D,0)  AS D,
    ISNULL(p.C,0)  AS C,
    ISNULL(p.NA,0) AS NA,
	ISNULL(P,0)+ISNULL(N,0)+ISNULL(D,0)+ISNULL(C,0)+ISNULL(NA,0) AS total_survey
FROM p
JOIN tbl_user AS u ON p.survey_by = u.user_id
WHERE u.app_id = @app_id
  AND u.[user_type] = 'K' -- Filter added here to only include 'SP' user types

END




--dis_booth_pramukh_wise_survey_dash_sp 1,'BP'
alter PROC dis_booth_pramukh_wise_survey_dash_sp
(
	 @app_id int,
	 @survey_by varchar(10)
)
AS
BEGIN

-- 1. Summarize survey metrics grouped by the booth number
;WITH s AS
(
    SELECT
        s.booth_no,
        CASE 
            WHEN s.voter_available = 0 THEN 'NA'
            ELSE s.voter_status
        END AS voter_status,
        COUNT(1) AS total
    FROM vw_user_latest_voter_survey AS s
    WHERE
        s.status = 1
		AND s.app_id = @app_id
    GROUP BY
        s.booth_no,
        CASE 
            WHEN s.voter_available = 0 THEN 'NA'
            ELSE s.voter_status
        END
),

-- 2. Pivot the survey status counts for each booth
p AS
(
    SELECT
        booth_no,
        ISNULL([P],0)  AS P,
        ISNULL([N],0)  AS N,
        ISNULL([D],0)  AS D,
        ISNULL([C],0)  AS C,
        ISNULL([NA],0) AS NA
    FROM s
    PIVOT
    (
        SUM(total)
        FOR voter_status IN ([P],[N],[D],[C],[NA])
    ) pv
)

-- 3. Combine Booth Master, User Profile ('BP'), and Survey Metrics
SELECT
    u.user_id,
    u.name,
	u.[user_type],
	dbo.fn_get_designation(u.[user_type]) AS designation,
    u.mobile_no,
    u.photo,
	CASE ISNULL(u.photo,'') WHEN '' THEN '' ELSE dbo.get_server_path()+'img/admin/'+u.photo END AS photo_path,
	b.booth_no AS [Booth No],
	ISNULL(b.total_voter, 0) AS [Total Voter],
    ISNULL(p.P, 0)  AS P,
    ISNULL(p.N, 0)  AS N,
    ISNULL(p.D, 0)  AS D,
    ISNULL(p.C, 0)  AS C,
    ISNULL(p.NA, 0) AS NA,
	-- Total completed surveys
	(ISNULL(p.P,0) + ISNULL(p.N,0) + ISNULL(p.D,0) + ISNULL(p.C,0) + ISNULL(p.NA,0)) AS total_survey,
	-- Calculate remaining voters safely
	CASE 
		WHEN (ISNULL(b.total_voter, 0) - (ISNULL(p.P,0) + ISNULL(p.N,0) + ISNULL(p.D,0) + ISNULL(p.C,0) + ISNULL(p.NA,0))) < 0 THEN 0
		ELSE (ISNULL(b.total_voter, 0) - (ISNULL(p.P,0) + ISNULL(p.N,0) + ISNULL(p.D,0) + ISNULL(p.C,0) + ISNULL(p.NA,0)))
	END AS [remain]
FROM tbl_booth AS b
JOIN tbl_user AS u ON b.booth_no = u.booth_no AND b.app_id = u.app_id
LEFT JOIN p ON b.booth_no = p.booth_no
WHERE u.app_id = @app_id
  AND u.[user_type] = @survey_by -- Targeting Booth Pramukhs only

END

alter PROC dis_karykarta_wise_survey_dash_sp
(
	 @app_id int,
	 @survey_by varchar(10)
)
AS
BEGIN

;WITH s AS
(
    SELECT
        s.survey_by,
        CASE 
            WHEN s.voter_available = 0 THEN 'NA'
            ELSE s.voter_status
        END AS voter_status,
        COUNT(1) AS total
    FROM vw_user_latest_voter_survey AS s
    WHERE
        s.status = 1
		AND s.app_id = @app_id
    GROUP BY
        s.survey_by,
        CASE 
            WHEN s.voter_available = 0 THEN 'NA'
            ELSE s.voter_status
        END
),

p AS
(
    SELECT
        survey_by,
        ISNULL([P],0)  AS P,
        ISNULL([N],0)  AS N,
        ISNULL([D],0)  AS D,
        ISNULL([C],0)  AS C,
        ISNULL([NA],0) AS NA
    FROM s
    PIVOT
    (
        SUM(total)
        FOR voter_status IN ([P],[N],[D],[C],[NA])
    ) pv
)

SELECT
    u.user_id,
    u.name,
	u.[user_type],
	dbo.fn_get_designation(u.[user_type]) AS designation,
    u.mobile_no,
    u.photo,
	CASE ISNULL(u.photo,'') WHEN '' THEN '' ELSE dbo.get_server_path()+'img/admin/'+u.photo END AS photo_path,
    ISNULL(p.P,0)  AS P,
    ISNULL(p.N,0)  AS N,
    ISNULL(p.D,0)  AS D,
    ISNULL(p.C,0)  AS C,
    ISNULL(p.NA,0) AS NA,
	ISNULL(P,0)+ISNULL(N,0)+ISNULL(D,0)+ISNULL(C,0)+ISNULL(NA,0) AS total_survey
FROM p
JOIN tbl_user AS u ON p.survey_by = u.user_id
WHERE u.app_id = @app_id
  AND u.[user_type] = @survey_by

END


CREATE OR ALTER PROCEDURE dbo.dis_booth_wise_survey_for_call_center
(
    @app_id INT,
    @booth_no INT,
    @user_id INT -- લોગઇન થયેલ યુઝર આઈડી
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.[id],
        v.[slnoinpart],
        v.[eng_f_name],
        v.[f_eng_surname],
        v.[eng_m_name],
        v.[eng_surname],
        v.[eng_localityid],
        v.[eng_polling_location],
        v.[idcard_no],
        v.[contact_no],
        v.[part_no],
        v.[eng_house_no],
        ISNULL(s.[survey_id], 0) AS [survey_id],
        s.[voter_available],
        s.[voter_status],
        s.[not_available_reason],
        u.[name],
        dbo.fn_get_designation(u.[user_type]) AS [designation]
    FROM
        dbo.[tbl_voting_record] AS v WITH (NOLOCK) -- મેઈન ટેબલ વોટિંગ રેકોર્ડ રાખ્યું જેથી બૂથના બધા વોટર્સ આવે
        
        -- LEFT JOIN કરવાથી જેનો સર્વે નથી થયો તેનો ડેટા પણ ખાલી (NULL) આવશે, પણ વોટર લિસ્ટમાંથી ગાયબ નહીં થાય
        LEFT JOIN dbo.[vw_user_latest_voter_survey] AS s WITH (NOLOCK) 
            ON s.[voter_idcard] = v.[idcard_no] 
            AND s.[app_id] = v.[app_id]
            AND s.survey_by_designation = 'CL'
            
        -- યુઝર ટેબલને પણ LEFT JOIN કર્યું જેથી જો સર્વે ન થયો હોય તો યુઝરનું નામ NULL આવે પણ રો (row) બતાવે
        LEFT JOIN dbo.[tbl_user] AS u WITH (NOLOCK) 
            ON s.[survey_by] = u.[user_id]
    WHERE
        v.app_id = @app_id
        AND v.part_no = @booth_no
	order by
		CAST(v.[slnoinpart] AS INT) ASC
END


alter PROCEDURE dis_call_center_dash_sp
    @user_id INT,
    @app_id INT
AS
BEGIN
    -- Stops SQL Server from sending row-count messages, improving performance
    SET NOCOUNT ON;

    -- ==========================================
    -- RESULT SET 1: Booth and Voter Metrics
    -- ==========================================
    SELECT 
        COUNT(b.booth_no)  AS total_booth,
        SUM(b.total_voter) AS total_voter    
FROM 
        tbl_user_booth AS ub
        JOIN tbl_booth AS b ON ub.booth_no = b.booth_no AND b.app_id = @app_id
    WHERE 
        ub.user_id = @user_id
        AND ub.status = 1;


    -- ==========================================
    -- RESULT SET 2: Survey Progress Metrics
    -- ==========================================
    SELECT 
        COUNT(s.survey_id) AS total_survey,
        COUNT(CASE WHEN CAST(s.survey_date AS DATE) = CAST(GETDATE() AS DATE) THEN s.survey_id END) AS today_survey
    FROM 
        tbl_user_booth AS ub
        JOIN vw_uniq_voter_survey AS s ON ub.booth_no = s.booth_no
    WHERE 
        ub.user_id = @user_id
        AND ub.status = 1
        AND s.status = 1;
END
GO


CREATE PROCEDURE dbo.sp_GetVoterSurveyCountByMonth
    @app_id INT,
    @month DATETIME
AS
BEGIN
    -- ક્વેરી પર્ફોર્મન્સ સુધારવા માટે
    SET NOCOUNT ON;

    SELECT 
        FORMAT(d.[date], 'dd, MMM, yyyy') AS [date],
        CAST(d.[date] AS DATE) AS d,
        ISNULL(s.total, 0) AS total
    FROM 
        dbo.get_all_date_by_month(@month) AS d
    LEFT JOIN 
    (
        -- સર્વે કાઉન્ટને પહેલા જ ગ્રુપ કરી લીધું જેથી જોઈન ફાસ્ટ થાય
        SELECT 
            CAST(create_date AS DATE) AS survey_date,
            COUNT(*) AS total
        FROM 
            dbo.vw_date_wise_latest_voter_survey
        WHERE 
            app_id = @app_id
        GROUP BY 
            CAST(create_date AS DATE)
    ) AS s ON d.[date] = s.survey_date
    ORDER BY 
        d;
END;
GO


CREATE PROCEDURE dbo.sp_GetVoterSurveyCountByMonthOnlyCallCenter
    @app_id INT,
    @month DATETIME
AS
BEGIN
    -- ક્વેરી પર્ફોર્મન્સ સુધારવા માટે
    SET NOCOUNT ON;

    SELECT 
        FORMAT(d.[date], 'dd, MMM, yyyy') AS [date],
        CAST(d.[date] AS DATE) AS d,
        ISNULL(s.total, 0) AS total
    FROM 
        dbo.get_all_date_by_month(@month) AS d
    LEFT JOIN 
    (
        -- સર્વે કાઉન્ટને પહેલા જ ગ્રુપ કરી લીધું જેથી જોઈન ફાસ્ટ થાય
        SELECT 
            CAST(create_date AS DATE) AS survey_date,
            COUNT(*) AS total
        FROM 
            dbo.vw_date_wise_latest_voter_survey_only_call_center
        WHERE 
            app_id = @app_id
        GROUP BY 
            CAST(create_date AS DATE)
    ) AS s ON d.[date] = s.survey_date
    ORDER BY 
        d;
END;
GO


CREATE OR ALTER PROCEDURE dbo.dis_voter_captain_voter_sp
(
    @app_id INT,
    @user_id INT
)
AS
BEGIN
    SET NOCOUNT ON; -- બિનજરૂરી મેસેજીસ બંધ કરીને એક્ઝિક્યુશન ફાસ્ટ કરશે

    DECLARE @start_no INT = 0, @end_no INT = 0, @booth_no INT = 0;

    -- ૧. જે-તે યુઝર (વોટર કેપ્ટન) નો બૂથ નંબર અને વોટર લિસ્ટની રેન્જ પકડીએ
    SELECT
        @booth_no = booth_no,
        @start_no = start_voter_no,
        @end_no = end_voter_no
    FROM
        dbo.tbl_user WITH (NOLOCK)
    WHERE
        app_id = @app_id
        AND user_id = @user_id
        AND status = 1; -- એક્ટિવ યુઝર હોય તેનો જ ડેટા લેવો સેફ રેહશે

    -- ૨. હવે તે જ બૂથ અને તે રેન્જ વચ્ચેના વોટર્સનો પ્યોર ડેટા ફિલ્ટર કરીએ
    SELECT
        r.id,
        r.f_name AS eng_f_name,
        r.f_surname AS f_eng_surname,
        r.m_name AS eng_m_name,
        r.surname AS eng_surname,
        r.part_no,
        r.eng_localityid,
        r.part_no AS booth_no,
        RIGHT(RTRIM(r.contact_no), 10) AS contact_no, -- સ્પેસ રીમૂવ કરીને છેલ્લેથી ૧૦ આંકડા પકડાશે
        r.idcard_no,
        r.slnoinpart,
        r.eng_polling_location,
        r.sex,
        r.age,
        r.eng_house_no,
        ISNULL(s.voter_available, '') AS voter_available,
        ISNULL(s.voter_status, '') AS voter_status,
        ISNULL(s.not_available_reason, '') AS not_available_reason
    FROM
        dbo.tbl_voting_record AS r WITH (NOLOCK)
        LEFT JOIN dbo.tbl_voter_survey AS s WITH (NOLOCK) 
            ON r.idcard_no = s.voter_idcard 
            AND s.app_id = @app_id 
            AND s.status = 1 
            AND s.is_latest = 1
    WHERE
        r.app_id = @app_id      -- ૧. પ્રાઈમરી ફિલ્ટર (એપ આઈડી)
        AND r.part_no = @booth_no -- ૨. સેકન્ડરી ફિલ્ટર (બૂથ નંબર)
        
        -- જો ડેટાબેઝમાં slnoinpart કોલમ VARCHAR હોય, તો સાચું ફિલ્ટર કરવા માટે CAST કરવું જરૂરી છે
        AND CAST(r.slnoinpart AS INT) BETWEEN @start_no AND @end_no
    ORDER BY
        CAST(r.slnoinpart AS INT); -- સીરીયલ નંબર પ્રમાણે જ લિસ્ટ સોર્ટ થઈને આવશે
END


CREATE PROC dis_booth_wise_social_media_summary_sp
    @app_id INT
AS
BEGIN
    SET NOCOUNT ON;

    WITH s AS 
    (
        SELECT
            r.part_no,
            COUNT(s.id) AS total_social_records,
            -- Counts rows where fb is not null and has an actual text value
            SUM(CASE WHEN ISNULL(s.fb, '') <> '' THEN 1 ELSE 0 END) AS total_fb_links,
            -- Counts rows where insta is not null and has an actual text value
            SUM(CASE WHEN ISNULL(s.insta, '') <> '' THEN 1 ELSE 0 END) AS total_insta_links
        FROM
            tbl_social_media_link AS s
            INNER JOIN tbl_voting_record AS r ON s.idcard_no = r.idcard_no
        WHERE 
            s.app_id = @app_id
        GROUP BY
            r.part_no
    )

    SELECT 
        b.booth_no,
        b.total_voter,
        -- ISNULL handles cases where a booth has zero matching records in the CTE
        ISNULL(s.total_social_records, 0) AS total_social_records,
        ISNULL(s.total_fb_links, 0)       AS total_fb_links,
        ISNULL(s.total_insta_links, 0)    AS total_insta_links
    FROM
        tbl_booth AS b
        LEFT JOIN s ON b.booth_no = s.part_no
    ORDER BY 
        b.booth_no;
END


CREATE PROC dis_booth_wise_facebook_users_sp
    @app_id INT,
    @booth_no INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.id,
        r.f_name AS eng_f_name,
        r.f_surname AS f_eng_surname,
        r.m_name AS eng_m_name,
        r.surname AS eng_surname,
        r.part_no,
        r.eng_localityid,
        r.part_no AS booth_no,
        RIGHT(RTRIM(r.contact_no), 10) AS contact_no, -- સ્પેસ રીમૂવ કરીને છેલ્લેથી ૧૦ આંકડા પકડાશે
        r.idcard_no,
        r.slnoinpart,
        r.eng_polling_location,
        r.sex,
        r.age,
        r.eng_house_no,
        s.fb
    FROM
        tbl_Voting_record AS r
        INNER JOIN tbl_social_media_link AS s ON r.idcard_no = s.idcard_no
    WHERE
        s.app_id = @app_id
        AND r.part_no = @booth_no
        AND s.fb IS NOT NULL 
        AND s.fb <> '';
END


CREATE PROC dis_booth_wise_insta_users_sp
    @app_id INT,
    @booth_no INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.id,
        r.f_name AS eng_f_name,
        r.f_surname AS f_eng_surname,
        r.m_name AS eng_m_name,
        r.surname AS eng_surname,
        r.part_no,
        r.eng_localityid,
        r.part_no AS booth_no,
        RIGHT(RTRIM(r.contact_no), 10) AS contact_no, -- સ્પેસ રીમૂવ કરીને છેલ્લેથી ૧૦ આંકડા પકડાશે
        r.idcard_no,
        r.slnoinpart,
        r.eng_polling_location,
        r.sex,
        r.age,
        r.eng_house_no,
        s.insta
    FROM
        tbl_Voting_record AS r
        INNER JOIN tbl_social_media_link AS s ON r.idcard_no = s.idcard_no
    WHERE
        s.app_id = @app_id
        AND r.part_no = @booth_no
        AND s.insta IS NOT NULL 
        AND s.insta <> '';
END

alter PROCEDURE [dbo].[ins_popup_alert_with_media_sp]
    @app_id INT,
    @UserId BIGINT,
    @Title NVARCHAR(250),
    @Content NVARCHAR(MAX),
	@show_status int,
    @IsActive int,
    @MediaList MediaTypeTable READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- કોઈ પણ એરર આવે તો આખી ટ્રાન્ઝેક્શન રોલબેક થઈ જશે

    BEGIN TRANSACTION;
    BEGIN TRY 

        -- ૧. જો આ નવું પોપ-અપ એક્ટિવ કરવાનું હોય, તો પહેલા જૂના બધા જ એક્ટિવ પોપ-અપ બંધ કરો
        IF @IsActive = 1
        BEGIN
            UPDATE dbo.tbl_PopupAlert
            SET is_active = 0,
                modify_date = dbo.get_date(),
                modify_by = CAST(@UserId AS INT)
            WHERE app_id = @app_id AND is_active = 1 AND [status] = 1;
        END

        -- ૨. માસ્ટર ટેબલમાં પોપ-અપ ઇન્સર્ટ કરીએ (with create_date)
        INSERT INTO dbo.tbl_PopupAlert (app_id, user_id, title, content,show_status, is_active, create_by, create_date)
        VALUES (@app_id, @UserId, @Title, @Content,@show_status, @IsActive, CAST(@UserId AS INT), dbo.get_date());

        DECLARE @PopupId BIGINT = SCOPE_IDENTITY();

        -- ૩. ચાઇલ્ડ ટેબલમાં મલ્ટિપલ મીડિયા આઇટમ્સ ઇન્સર્ટ કરીએ (with create_date)
        INSERT INTO dbo.tbl_PopupAlertMedia (popup_id, media_type, media_url, create_by, create_date)
        SELECT @PopupId, media_type, media_url, CAST(@UserId AS INT), dbo.get_date()
        FROM @MediaList;

        -- જો બધું પ્રોપર સક્સેસ જાય તો ડેટા કમિટ કરો
        COMMIT TRANSACTION;
        
        SELECT 'ok' AS [status];

    END TRY
    BEGIN CATCH
        -- જો કોઈ પણ એરર આવે તો ટ્રાન્ઝેક્શન રોલબેક કરો
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH
END


alter PROCEDURE [dbo].[upd_popup_alert_with_media_sp]
    @app_id INT,
    @UserId BIGINT,
    @PopupId BIGINT,
    @Title NVARCHAR(250),
    @Content NVARCHAR(MAX),
	@show_status int,
    @IsActive int,
    @MediaList MediaTypeTable READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- કોઈ પણ એરર આવે તો આખી ટ્રાન્ઝેક્શન રોલબેક થઈ જશે

    BEGIN TRANSACTION;
    BEGIN TRY 

        -- ૧. જો આ પોપ-અપને એક્ટિવ કરવાનું હોય, તો બાકીના બધા જ જૂના એક્ટિવ પોપ-અપ બંધ કરો
        IF @IsActive = 1
        BEGIN
            UPDATE dbo.tbl_PopupAlert
            SET is_active = 0,
                modify_date = dbo.get_date(),
                modify_by = CAST(@UserId AS INT)
            WHERE app_id = @app_id AND popup_id <> @PopupId AND is_active = 1 AND [status] = 1;
        END

        -- ૨. માસ્ટર ટેબલમાં પોપ-અપનો ડેટા અપડેટ કરીએ
        UPDATE dbo.tbl_PopupAlert
        SET title = @Title,
            content = @Content,
			show_status=@show_status,
            is_active = @IsActive,
            modify_by = CAST(@UserId AS INT),
            modify_date = dbo.get_date()
        WHERE popup_id = @PopupId AND app_id = @app_id;

        -- ૩. ચાઇલ્ડ ટેબલમાંથી આ પોપ-અપના જૂના બધા જ મીડિયા રેકોર્ડ્સ ડીલીટ કરીએ
        --DELETE FROM dbo.tbl_PopupAlertMedia 
        --WHERE popup_id = @PopupId;

        -- ૪. નવી મીડિયા આઇટમ્સ (with create_date) ફરીથી ઇન્સર્ટ કરીએ
        INSERT INTO dbo.tbl_PopupAlertMedia (popup_id, media_type, media_url, create_by, create_date)
        SELECT @PopupId, media_type, media_url, CAST(@UserId AS INT), dbo.get_date()
        FROM @MediaList;

        -- જો બધું પ્રોપર સક્સેસ જાય તો ડેટા કમિટ કરો
        COMMIT TRANSACTION;
        
        SELECT 'ok' AS [status];

    END TRY
    BEGIN CATCH
        -- જો કોઈ પણ એરર આવે તો ટ્રાન્ઝેક્શન રોલબેક કરો
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

    END CATCH
END

CREATE PROCEDURE [dbo].[dlt_popup_alert_sp]
    @app_id INT,
    @UserId BIGINT,
    @PopupId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- કોઈ પણ એરર આવે તો આખી ટ્રાન્ઝેક્શન રોલબેક થઈ જશે

    BEGIN TRANSACTION;
    BEGIN TRY 

        -- ૧. માસ્ટર ટેબલમાં સોફ્ટ ડીલીટ (status = 0 અને ઓડિટ લોગ્સ સેટ કરીએ)
        UPDATE dbo.tbl_PopupAlert
        SET [status] = 0,
            is_active = 0, -- ડીલીટ થાય એટલે ઓટોમેટિક ડિસ્પ્લે થવાનું બંધ થઈ જાય
            delete_by = CAST(@UserId AS INT),
            delete_date = dbo.get_date()
        WHERE popup_id = @PopupId AND app_id = @app_id;

        -- ૨. ચાઇલ્ડ ટેબલમાં પણ તે પોપ-અપના બધા જ મીડિયા સોફ્ટ ડીલીટ કરીએ
        UPDATE dbo.tbl_PopupAlertMedia
        SET [status] = 0,
            create_by = CAST(@UserId AS INT) -- અથવા જો તમે ચાઇલ્ડમાં અલગથી delete_by રાખ્યું હોય તો ત્યાં સેટ કરી શકો
        WHERE popup_id = @PopupId;

        -- જો બંને જગ્યાએ પ્રોપર અપડેટ થઈ જાય તો કમિટ કરો
        COMMIT TRANSACTION;
        
        SELECT 'ok' AS [status];

    END TRY
    BEGIN CATCH
        -- જો કોઈ પણ એરર આવે તો રોલબેક કરો
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

    END CATCH
END

--[sel_popup_alert_for_edit_sp] 1,3
alter PROCEDURE [dbo].[sel_popup_alert_for_edit_sp]
    @app_id INT,
    @PopupId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -- ૧. DATASET Table[0]: માસ્ટર ડેટા (પોપ-અપની મેઈન વિગતો)
    SELECT 
        popup_id,
        app_id,
        user_id,
        title,
        content,
		show_status,
        is_active
    FROM 
        dbo.tbl_PopupAlert WITH (NOLOCK)
    WHERE 
        popup_id = @PopupId 
        AND app_id = @app_id 
        AND [status] = 1;

    -- ૨. DATASET Table[1]: ચાઇલ્ડ ડેટા (ઇમેજ અને ઓડિયો માટે સર્વર પાથ સાથે)
    SELECT 
        media_id,
        popup_id,
        media_type,
        media_url, -- ઓરિજિનલ ફાઇલનું નામ (ટેક્સ્ટબોક્સ/ગ્રીડમાં બતાવવા માટે)
        
        -- તમારા લોજિક મુજબ ઈમેજ અને ઓડિયો માટે સર્વર પાથ એટેચ કર્યો
        CASE media_type 
            WHEN 'i' THEN dbo.get_server_path() + 'img/popup/images/' + media_url 
            WHEN 'a' THEN dbo.get_server_path() + 'img/popup/audio/' + media_url 
            ELSE media_url -- YouTube, FB વગેરે ડાયરેક્ટ લિંક્સ માટે બેકઅપ
        END AS media_url_path
    FROM 
        dbo.tbl_PopupAlertMedia WITH (NOLOCK)
    WHERE 
        popup_id = @PopupId 
        AND [status] = 1;
END

 --[dis_popup_alert_all_sp] 1
alter PROCEDURE [dbo].[dis_popup_alert_all_sp]
    @app_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- સિંગલ ડેટા સેટ: બધા જ પોપ-અપ લિસ્ટ ડેટા એકસાથે મળશે
    SELECT 
        p.popup_id,
        p.app_id,
        p.user_id,
        p.title,
        p.content,
		p.show_status,
        p.is_active,
        format(p.create_date,'dd MMM, yyyy') as create_date,
        -- ક્યા યુઝરે બનાવ્યું તેનું નામ
        ISNULL(u.name, 'Admin') AS created_by_name,
        
        -- આ પોપ-અપમાં ટોટલ કેટલા મીડિયા એટેચ છે તેનો કાઉન્ટ
        (SELECT COUNT(1) FROM dbo.tbl_PopupAlertMedia WITH (NOLOCK) WHERE popup_id = p.popup_id AND [status] = 1) AS total_media_count
    FROM 
        dbo.tbl_PopupAlert AS p WITH (NOLOCK)
        LEFT JOIN dbo.tbl_user AS u WITH (NOLOCK) ON p.user_id = u.user_id
    WHERE 
        p.app_id = @app_id 
        AND p.[status] = 1 -- માત્ર એક્ટિવ (સોફ્ટ ડીલીટ ન થયેલા) રેકોર્ડ્સ
    ORDER BY 
        p.is_active DESC,    -- લાઈવ પોપ-અપ સૌથી પહેલા ઉપર દેખાશે
        p.popup_id DESC;    -- ત્યારબાદ બાકીના લેટેસ્ટ ક્રમમાં નીચે ગોઠવાશે
END



alter PROCEDURE dlt_popup_alert_media_sp
    @media_id BIGINT,
    @delete_by INT -- Passing the user ID who is performing the deletion to log/update it
AS
BEGIN
    SET NOCOUNT ON;

    -- Update the status to 0 (Soft Delete)
    UPDATE tbl_PopupAlertMedia
    SET 
        [status] = 0,
        [create_by] = @delete_by,             -- Optional: Updates who modified/deleted it
        [create_date] = dbo.get_date()            -- Optional: Timestamp of deletion
    WHERE 
        media_id = @media_id 
        AND [status] = 1;  

	select 'ok' 
END


CREATE PROCEDURE [dbo].[dis_scheme_beneficiary_dash_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Result Set 1: કુલ યુનિક લાભાર્થીઓનો આંકડો (Total Unique Beneficiaries)
    SELECT 
        COUNT(DISTINCT b.voter_idcard) AS total
    FROM 
        dbo.tbl_scheme_beneficiary AS b WITH (NOLOCK)
        INNER JOIN dbo.tbl_gov_scheme AS s WITH (NOLOCK) 
            ON s.scheme_id = b.scheme_id 
            AND s.status = 1
    WHERE
        b.status = 1
        AND b.app_id = @app_id;


    -- Result Set 2: યોજના વાઈઝ બ્રેકઅપ કાઉન્ટ (Scheme-wise Breakdown Count)
    SELECT 
        s.scheme_id,
        s.scheme_short_name,
        s.scheme_name,
        COUNT_BIG(1) AS total -- હાઈ-વોલ્યુમ ડેટાસેટ માટે COUNT_BIG બેસ્ટ રહેશે
    FROM 
        dbo.tbl_scheme_beneficiary AS b WITH (NOLOCK)
        INNER JOIN dbo.tbl_gov_scheme AS s WITH (NOLOCK) 
            ON s.scheme_id = b.scheme_id 
            AND s.status = 1
    WHERE
        b.status = 1
        AND b.app_id = @app_id
    GROUP BY
        s.scheme_id,
        s.scheme_short_name,
        s.scheme_name
    ORDER BY 
        total DESC; -- વધારે લાભાર્થી વાળી સ્કીમ ઉપર દેખાશે

END;
GO


CREATE PROCEDURE [dbo].[dis_booth_wise_beneficiary_dash_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- ૧. સેફ્ટી ચેક: જો અગાઉનું કોઈ સેશન અટકેલું હોય તો ટેમ્પ ટેબલ ડ્રોપ કરો
    IF OBJECT_ID('tempdb..#TempBen') IS NOT NULL 
        DROP TABLE #TempBen;

    -- ૨. લાભાર્થીઓનો ડેટા એગ્રીગેટ કરીને સીધો ટેમ્પ ટેબલમાં ઇન્સર્ટ કરો
    SELECT 
        r.part_no AS booth_no,
        COUNT(DISTINCT b.voter_idcard) AS total_beneficiaries
    INTO #TempBen
    FROM 
        dbo.tbl_scheme_beneficiary AS b WITH (NOLOCK)
        INNER JOIN dbo.tbl_gov_scheme AS s WITH (NOLOCK) 
            ON s.scheme_id = b.scheme_id 
            AND s.status = 1
        INNER JOIN dbo.tbl_voting_record AS r WITH (NOLOCK) 
            ON b.voter_idcard = r.idcard_no 
            AND r.app_id = @app_id
    WHERE
        b.status = 1
        AND b.app_id = @app_id
    GROUP BY
        r.part_no;

    -- ૩. ટેમ્પ ટેબલ પર ક્લસ્ટર્ડ ઇન્ડેક્સ બનાવો (આનાથી LEFT JOIN સુપરફાસ્ટ થશે)
    CREATE CLUSTERED INDEX IX_TempBen_Booth ON #TempBen(booth_no);

    -- ૪. ફાઇનલ માસ્ટર બૂથ ટેબલ સાથે લેફ્ટ જોઈન કરીને રિઝલ્ટ સેટ આપો
    SELECT
        b.booth_no,
        b.total_voter,
        ISNULL(t.total_beneficiaries, 0) AS total_beneficiaries
    FROM
        dbo.tbl_booth AS b WITH (NOLOCK)
        LEFT JOIN #TempBen AS t ON b.booth_no = t.booth_no
    WHERE
        b.app_id = @app_id
    ORDER BY 
        TRY_CAST(b.booth_no AS INT);

    -- ૫. પ્રોસિજર પૂરી થતા પહેલા મેમરી ક્લીનઅપ
    IF OBJECT_ID('tempdb..#TempBen') IS NOT NULL 
        DROP TABLE #TempBen;

END;
GO


CREATE PROCEDURE [dbo].[sel_scheme_beneficiary_by_booth_sp]
(
    @app_id INT,
    @booth_no VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        v.[id],
        v.[slnoinpart],
        v.[eng_f_name],
        v.[f_eng_surname],
        v.[eng_m_name],
        v.[eng_surname],
        v.[eng_localityid],
        v.[eng_polling_location],
        v.[idcard_no],
        RIGHT(RTRIM(v.[contact_no]), 10) AS [contact_no],
        v.[part_no],
        v.[eng_house_no],
        ISNULL(sr.[survey_id], 0) AS [survey_id],
        ISNULL(sr.[voter_available], -1) AS [voter_available],
        sr.[voter_status],
        sr.[not_available_reason]
FROM 
    dbo.tbl_scheme_beneficiary AS b WITH (NOLOCK)
    INNER JOIN dbo.tbl_gov_scheme AS s WITH (NOLOCK) 
        ON s.scheme_id = b.scheme_id 
        AND s.status = 1
    INNER JOIN dbo.tbl_voting_record AS v WITH (NOLOCK) 
        ON b.voter_idcard = v.idcard_no 
        AND v.app_id = @app_id
    LEFT JOIN dbo.vw_uniq_voter_survey AS sr WITH (NOLOCK)
        ON sr.voter_idcard = b.voter_idcard 
        AND sr.app_id = @app_id
WHERE
    b.status = 1
    AND b.app_id = @app_id
    AND v.part_no = @booth_no
ORDER BY 
    TRY_CAST(v.[slnoinpart] AS INT);
END;
GO


--[dis_address_wise_beneficiary_dash_sp] 1
CREATE PROCEDURE [dbo].[dis_address_wise_beneficiary_dash_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.[id] AS [address_id],
        a.[add_uni],
        a.[add_eng],
        a.[total_voter],
        ISNULL(ben.total_beneficiaries, 0) AS [total_beneficiaries]
    FROM dbo.tbl_address AS a WITH (NOLOCK)
    LEFT JOIN 
    (
        -- અંદરની સબ-ક્વેરીમાં માસ્ટર એડ્રેસ આઈડી (addr.id) પર ગ્રુપિંગ
        SELECT 
            addr.id AS [address_master_id],
            COUNT(DISTINCT b.voter_idcard) AS total_beneficiaries
        FROM dbo.tbl_scheme_beneficiary AS b WITH (NOLOCK)
        INNER JOIN dbo.tbl_gov_scheme AS s WITH (NOLOCK) 
            ON s.scheme_id = b.scheme_id 
            AND s.status = 1
        INNER JOIN dbo.tbl_voting_record AS v WITH (NOLOCK) 
            ON b.voter_idcard = v.idcard_no 
            AND v.app_id = @app_id
        -- માસ્ટર એડ્રેસના ઇંગ્લિશ કોલમ (add_eng) સાથે ટેક્સ્ટ મેચિંગ
        INNER JOIN dbo.tbl_address AS addr WITH (NOLOCK)
            ON v.eng_localityid = addr.add_eng 
            AND addr.app_id = @app_id
        WHERE
            b.status = 1
            AND b.app_id = @app_id
        GROUP BY 
            addr.id
    ) AS ben ON a.id = ben.address_master_id
    WHERE
        a.app_id = @app_id
    ORDER BY 
        [total_beneficiaries] DESC, 
        a.[id];

END;
GO

--[sel_scheme_beneficiary_by_address_sp] 1,N'રામાપીરના મંદિર પાસે, રાધેશ્યામ ગૌશાળા પાસે, પાણીના ટાંકા સામે, રૈયાધાર, રૈયા-42, રાજકોટ'
alter PROCEDURE [dbo].[sel_scheme_beneficiary_by_address_sp]
(
    @app_id INT,
    @address_text NVARCHAR(max) -- વેબ ડેશબોર્ડ કે ગ્રીડમાંથી સિલેક્ટ થયેલું આખું એડ્રેસ અહીં પાસ થશે
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        v.[id],
        v.[slnoinpart],
        v.[eng_f_name],
        v.[f_eng_surname],
        v.[eng_m_name],
        v.[eng_surname],
        v.[eng_localityid],
        v.[eng_polling_location],
        v.[idcard_no],
        RIGHT(RTRIM(v.[contact_no]), 10) AS [contact_no], -- ૧૦ આંકડાનો મોબાઈલ નંબર સેફ્ટી સાથે
        v.[part_no] AS [booth_no],
        v.[eng_house_no],
        ISNULL(sr.[survey_id], 0) AS [survey_id],
        ISNULL(sr.[voter_available], -1) AS [voter_available], -- જો સર્વે બાકી હોય તો -1 (Pending) દેખાશે
        sr.[voter_status],
        sr.[not_available_reason]
    FROM 
        dbo.tbl_scheme_beneficiary AS b WITH (NOLOCK)
        INNER JOIN dbo.tbl_gov_scheme AS s WITH (NOLOCK) 
            ON s.scheme_id = b.scheme_id 
            AND s.status = 1
        INNER JOIN dbo.tbl_voting_record AS v WITH (NOLOCK) 
            ON b.voter_idcard = v.idcard_no 
            AND v.app_id = @app_id
        LEFT JOIN dbo.vw_uniq_voter_survey AS sr WITH (NOLOCK) -- LEFT JOIN જેથી બાકી સર્વે વાળા પણ લિસ્ટમાં દેખાય
            ON sr.voter_idcard = b.voter_idcard 
            AND sr.app_id = @app_id
    WHERE
        b.status = 1
        AND b.app_id = @app_id
        -- એડ્રેસ ટેક્સ્ટના પર્ફેક્ટ જોઈન અને સ્પેસ સેફ્ટી માટે LTRIM/RTRIM નો ઉપયોગ કર્યો છે
        AND LTRIM(RTRIM(v.eng_localityid)) = LTRIM(RTRIM(@address_text))
    ORDER BY 
        TRY_CAST(v.[part_no] AS INT),            -- પહેલા બૂથ વાઇઝ ક્રમમાં ગોઠવાશે
        TRY_CAST(v.[slnoinpart] AS INT);         -- પછી સીરીયલ નંબર (SlNoInPart) મુજબ ગોઠવાશે
END; 
GO