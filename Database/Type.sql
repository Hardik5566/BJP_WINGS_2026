CREATE TYPE MediaTypeTable AS TABLE (
    media_type NVARCHAR(50),
    media_url NVARCHAR(1000)
);


-- મલ્ટિપલ મીડિયા લિસ્ટ પાસ કરવા માટેની ટેબલ ટાઇપ
CREATE TYPE dbo.UT_PopupAlertMedia AS TABLE
(
    media_type NVARCHAR(50),  -- 'image', 'youtube', 'audio', 'drive', વગેરે
    media_url NVARCHAR(1000)  -- ફાઇલનું નામ અથવા ડાયરેક્ટ લિંક
);
