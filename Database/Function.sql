
--------------------------------------
------ Get Current Datetime ----------
----------- 21/12/2017 ---------------
--------------------------------------
create function dbo.get_date()
returns datetime
begin
	declare @date datetime
	set @date=(select dateadd(hh,5,dateadd(mi,30,getutcdate())))
	return @date
end


------------------------------
------ Split String ----------
------------------------------
create FUNCTION SplitString
(    
    @Input NVARCHAR(MAX),
    @Character CHAR(1)
)
RETURNS @Output TABLE (
	[index] int,
    Item NVARCHAR(1000)
)
AS
BEGIN
    DECLARE @StartIndex INT, @EndIndex INT
 
    SET @StartIndex = 1
    --IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
    --BEGIN
    --    SET @Input = @Input + @Character
    --END
	declare @index int = 1
    WHILE CHARINDEX(@Character, @Input) > 0
    BEGIN
        SET @EndIndex = CHARINDEX(@Character, @Input)
         
        INSERT INTO @Output([index],Item)
        SELECT @index,SUBSTRING(@Input, @StartIndex, @EndIndex - 1)
        
		set @index=@index+1
        SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
    END
 
    RETURN
END
GO

--------------------------------------
------ Get Server Url ----------------
--------------------------------------
alter function [dbo].[get_server_path]()
returns varchar(100)
begin
	declare @server varchar(100)
	--set @server=(select 'http://'+DB_NAME()+'.mhbjplok.com/')
	set @server=(select 'http://hlele.bjpwings.com/')
	return @server
end


--------------------------------------
------ Get Server Url ----------------
--------------------------------------
alter FUNCTION dbo.fn_get_designation
(
    @user_type VARCHAR(5)
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @designation NVARCHAR(50);

    SET @designation =
        CASE UPPER(@user_type)
            WHEN 'A'  THEN N'एडमिन'
            WHEN 'SA' THEN N'सब एडमिन'
            WHEN 'BP' THEN N'बुथ प्रमुख'
            WHEN 'BS' THEN N'बुथ सह प्रमुख'
			WHEN 'WP' THEN N'वोररुम प्रमुख'
            WHEN 'BC' THEN N'बूथ कैप्टन'
            WHEN 'VC' THEN N'वोटर कैप्टन'
            WHEN 'SP' THEN N'शक्तिकेंद्र प्रमुख'
            WHEN 'K'  THEN N'कार्यकर्त्ता'
            WHEN 'CL' THEN N'कोल सेन्टर'
            WHEN 'LV' THEN N'लाइव वोटिंग'
            ELSE N'अज्ञात'
        END;

    RETURN @designation;
END;
GO



------------------------------
------ Split String ----------
------------------------------
create FUNCTION get_all_date_by_month
(    
    @month date
)
RETURNS @Output TABLE (
	[date] datetime
)
AS
BEGIN

	DECLARE @MinDate DATE = (SELECT DATEADD(month, DATEDIFF(month, 0, @month), 0))
	DECLARE @MaxDate DATE = (select EOMONTH(@month, 0))

    insert into @Output
	 SELECT  TOP (DATEDIFF(DAY, @MinDate, @MaxDate) + 1)
			Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @MinDate)
	FROM    sys.all_objects a
			CROSS JOIN sys.all_objects b;

    RETURN
END
GO



------------------------------
------ Split String ----------
------------------------------
CREATE FUNCTION dbo.fn_social_date(@CreateDate DATETIME)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Result NVARCHAR(50)
    DECLARE @Now DATETIME = GETDATE()
    DECLARE @DaysDiff INT = DATEDIFF(DAY, @CreateDate, @Now)

    IF @DaysDiff = 0
        SET @Result = FORMAT(@CreateDate, 'hh:mm tt')  -- Today → show time
    ELSE IF @DaysDiff = 1
        SET @Result = 'Yesterday ' + FORMAT(@CreateDate, 'hh:mm tt')  -- Yesterday → time
    ELSE IF @DaysDiff BETWEEN 2 AND 7
        SET @Result = CAST(@DaysDiff AS NVARCHAR(10)) + ' Days Ago'   -- 2–7 days → X Days Ago
    ELSE
        SET @Result = FORMAT(@CreateDate, 'dd MMM yyyy')              -- Older → Date

    RETURN @Result
END
GO

--------------------------------------
------ Voting % Color Range ----------
--------------------------------------
-- SELECT * FROM dbo.fn_voting_percent_color_range();
ALTER FUNCTION dbo.fn_voting_percent_color_range()
RETURNS TABLE
AS
RETURN
(
    SELECT CAST(10.00 AS DECIMAL(10, 2)) AS upto_percent, N'#FF0000' AS color_code
    UNION ALL SELECT 20.00, N'#b80f0f'   -- Orange
    UNION ALL SELECT 50.00, N'#d68e09'   -- Gold / yellow
    UNION ALL SELECT 100.00, N'#046921'  -- Highest
);
GO

--------------------------------------
------ Levenshtein distance ----------
--------------------------------------
alter FUNCTION dbo.fn_GetLevenshteinDistance
(
    @s NVARCHAR(4000),
    @t NVARCHAR(4000)
)
RETURNS INT
AS
BEGIN
    DECLARE @s_len INT, @t_len INT, @i INT, @j INT, @s_char NCHAR, @c INT, @c_temp INT
    DECLARE @cv0 NVARCHAR(4000), @cv1 NVARCHAR(4000)
    
    SET @s_len = LEN(@s)
    SET @t_len = LEN(@t)
    SET @cv1 = ''
    
    IF @s_len = 0 RETURN @t_len
    IF @t_len = 0 RETURN @s_len
    
    SET @j = 1
    WHILE @j <= @t_len
    BEGIN
        SET @cv1 = @cv1 + NCHAR(@j)
        SET @j = @j + 1
    END
    
    SET @i = 1
    WHILE @i <= @s_len
    BEGIN
        SET @s_char = SUBSTRING(@s, @i, 1)
        SET @c = @i
        SET @cv0 = NCHAR(@i)
        SET @j = 1
        WHILE @j <= @t_len
        BEGIN
            SET @c_temp = ASCII(SUBSTRING(@cv1, @j, 1))
            IF @s_char <> SUBSTRING(@t, @j, 1) SET @c_temp = @c_temp + 1
            IF @c + 1 < @c_temp SET @c_temp = @c + 1
            IF ASCII(SUBSTRING(@cv0, @j, 1)) + 1 < @c_temp SET @c_temp = ASCII(SUBSTRING(@cv0, @j, 1)) + 1
            SET @c = @c_temp
            SET @cv0 = @cv0 + NCHAR(@c)
            SET @j = @j + 1
        END
        SET @cv1 = @cv0
        SET @i = @i + 1
    END
    RETURN @c
END;

--------------------------------------
------ Prachar Type ----------
--------------------------------------
create FUNCTION dbo.GetPracharName
(
    @type VARCHAR(50)
)
RETURNS VARCHAR(100)
AS
BEGIN
    RETURN (
        CASE LOWER(@type)
            WHEN 'sleep' THEN 'Bulk Sleep Send Cost'
            WHEN 'slipprint' THEN 'Bulk Slip Print Cost'
            WHEN 'photo' THEN 'Bulk Photo Send Cost'
            WHEN 'video' THEN 'Bulk Video Send Cost'
            WHEN 'call' THEN 'Bulk Call Cost'
            WHEN 'roadholding' THEN 'Road Holding Cost'
            WHEN 'socialmedia' THEN 'Social Media Prachar Cost'
            WHEN 'vehiclebanner' THEN 'Vehicle Banner Cost'
            WHEN 'pamphlet' THEN 'Pamphlet Distribution Cost'
            ELSE @type
        END
    );
END
GO