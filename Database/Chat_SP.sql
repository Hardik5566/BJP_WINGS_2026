/*
================================================================================
  GROUP CHAT — STORED PROCEDURES
================================================================================
  Table   : dbo.tbl_group_chat_message
  Group   : Fixed — one chat per app_id (all active tbl_user can chat)
  Deploy  : Run after tbl_group_chat_message table is created
================================================================================
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.ins_group_chat_message_sp
  INPUT     : app_id, sender_user_id, msg_type, message_text, file fields, reply_to_msg_id
  RESULT    : SuccessCode 1 + inserted message row (with sender name/photo)
  TEST      : ins_group_chat_message_sp 1, 5, 'TEXT', N'Hello team', NULL, NULL, NULL, NULL, NULL, NULL
------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[ins_group_chat_message_sp]
(
      @app_id           INT
    , @sender_user_id   INT
    , @msg_type         VARCHAR(20)          -- TEXT | IMAGE | VIDEO | FILE | AUDIO
    , @message_text     NVARCHAR(MAX)  = NULL
    , @file_path        NVARCHAR(1000) = NULL
    , @file_name        NVARCHAR(500)  = NULL
    , @file_ext         NVARCHAR(20)   = NULL
    , @file_size        BIGINT         = NULL
    , @file_type        NVARCHAR(50)   = NULL
    , @reply_to_msg_id  BIGINT         = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @message_id BIGINT;
    DECLARE @msg_type_u VARCHAR(20) = UPPER(LTRIM(RTRIM(ISNULL(@msg_type, ''))));

    -- 1) Validate sender
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.tbl_user
        WHERE user_id = @sender_user_id
          AND app_id  = @app_id
          AND status  = 1
    )
    BEGIN
        SELECT 0 AS SuccessCode, N'Invalid or inactive user.' AS Msg;
        RETURN;
    END

    -- 2) Validate msg_type
    IF @msg_type_u NOT IN ('TEXT', 'IMAGE', 'VIDEO', 'FILE', 'AUDIO')
    BEGIN
        SELECT 0 AS SuccessCode, N'Invalid msg_type.' AS Msg;
        RETURN;
    END

    -- 3) Validate content
    IF @msg_type_u = 'TEXT'
    BEGIN
        IF NULLIF(LTRIM(RTRIM(ISNULL(@message_text, N''))), N'') IS NULL
        BEGIN
            SELECT 0 AS SuccessCode, N'Message text is required.' AS Msg;
            RETURN;
        END
    END
    ELSE
    BEGIN
        IF NULLIF(LTRIM(RTRIM(ISNULL(@file_path, ''))), '') IS NULL
        BEGIN
            SELECT 0 AS SuccessCode, N'File path is required for media message.' AS Msg;
            RETURN;
        END
    END

    -- 4) Validate reply message (optional)
    IF @reply_to_msg_id IS NOT NULL
    BEGIN
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.tbl_group_chat_message
            WHERE message_id = @reply_to_msg_id
              AND app_id     = @app_id
              AND status     = 1
        )
        BEGIN
            SELECT 0 AS SuccessCode, N'Reply message not found.' AS Msg;
            RETURN;
        END
    END

    -- 5) Insert
    INSERT INTO dbo.tbl_group_chat_message
    (
          app_id
        , sender_user_id
        , msg_type
        , message_text
        , file_path
        , file_name
        , file_ext
        , file_size
        , file_type
        , reply_to_msg_id
        , status
        , create_date
    )
    VALUES
    (
          @app_id
        , @sender_user_id
        , @msg_type_u
        , @message_text
        , @file_path
        , @file_name
        , @file_ext
        , @file_size
        , @file_type
        , @reply_to_msg_id
        , 1
        , dbo.get_date()
    );

    SET @message_id = SCOPE_IDENTITY();

    SELECT 1 AS SuccessCode, N'Message sent.' AS Msg;

    SELECT
          m.message_id
        , m.app_id
        , m.sender_user_id
        , u.name              AS sender_name
        , u.photo             AS sender_photo
        , u.user_type         AS sender_user_type
        , dbo.fn_get_designation(u.user_type) AS sender_designation
        , m.msg_type
        , m.message_text
        , m.file_path
        , m.file_name
        , m.file_ext
        , m.file_size
        , m.file_type
        , m.reply_to_msg_id
        , m.status
        , m.create_date
    FROM dbo.tbl_group_chat_message AS m
    INNER JOIN dbo.tbl_user AS u
        ON u.user_id = m.sender_user_id
       AND u.app_id  = m.app_id
    WHERE m.message_id = @message_id;
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.dis_group_chat_messages_sp
  INPUT     :
      @app_id         INT
      @after_msg_id   BIGINT = NULL   -- poll NEW messages (message_id > after)
      @before_msg_id  BIGINT = NULL   -- load OLDER messages (message_id < before)
      @limit          INT    = 50
  RESULT    : messages ordered ASC by message_id (oldest first in result set)
  TEST      :
      dis_group_chat_messages_sp 1, NULL, NULL, 50          -- latest 50
      dis_group_chat_messages_sp 1, 100, NULL, 50           -- new after id 100
      dis_group_chat_messages_sp 1, NULL, 50, 50            -- older before id 50
------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[dis_group_chat_messages_sp]
(
      @app_id          INT
    , @after_msg_id    BIGINT = NULL
    , @before_msg_id   BIGINT = NULL
    , @limit           INT    = 50
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @limit IS NULL OR @limit <= 0 SET @limit = 50;
    IF @limit > 200 SET @limit = 200;

    ;WITH cte AS
    (
        SELECT TOP (@limit)
              m.message_id
            , m.app_id
            , m.sender_user_id
            , u.name              AS sender_name
            , u.photo             AS sender_photo
            , u.user_type         AS sender_user_type
            , dbo.fn_get_designation(u.user_type) AS sender_designation
            , m.msg_type
            , m.message_text
            , m.file_path
            , m.file_name
            , m.file_ext
            , m.file_size
            , m.file_type
            , m.reply_to_msg_id
            , rm.message_text     AS reply_message_text
            , rm.msg_type         AS reply_msg_type
            , ru.name             AS reply_sender_name
            , m.status
            , m.create_date
        FROM dbo.tbl_group_chat_message AS m
        INNER JOIN dbo.tbl_user AS u
            ON u.user_id = m.sender_user_id
           AND u.app_id  = m.app_id
        LEFT JOIN dbo.tbl_group_chat_message AS rm
            ON rm.message_id = m.reply_to_msg_id
           AND rm.app_id     = m.app_id
           AND rm.status     = 1
        LEFT JOIN dbo.tbl_user AS ru
            ON ru.user_id = rm.sender_user_id
           AND ru.app_id  = rm.app_id
        WHERE m.app_id = @app_id
          AND m.status = 1
          AND (
                (@after_msg_id IS NOT NULL AND m.message_id > @after_msg_id)
             OR (@before_msg_id IS NOT NULL AND @after_msg_id IS NULL AND m.message_id < @before_msg_id)
             OR (@after_msg_id IS NULL AND @before_msg_id IS NULL)
          )
        ORDER BY
            CASE
                WHEN @after_msg_id IS NOT NULL THEN m.message_id
                ELSE -m.message_id
            END ASC
    )
    SELECT *
    FROM cte
    ORDER BY message_id ASC;
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.del_group_chat_message_sp
  INPUT     : message_id, app_id, delete_by
  RULE      : sender can delete own message; Admin (A) / Sub-Admin (SA) can delete any
  RESULT    : SuccessCode 1 = deleted, 0 = not allowed / not found
  TEST      : del_group_chat_message_sp 10, 1, 5
------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[del_group_chat_message_sp]
(
      @message_id   BIGINT
    , @app_id       INT
    , @delete_by    INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sender_user_id INT;
    DECLARE @delete_user_type VARCHAR(10);

    SELECT
          @sender_user_id = m.sender_user_id
    FROM dbo.tbl_group_chat_message AS m
    WHERE m.message_id = @message_id
      AND m.app_id     = @app_id
      AND m.status     = 1;

    IF @sender_user_id IS NULL
    BEGIN
        SELECT 0 AS SuccessCode, N'Message not found.' AS Msg;
        RETURN;
    END

    SELECT @delete_user_type = user_type
    FROM dbo.tbl_user
    WHERE user_id = @delete_by
      AND app_id  = @app_id
      AND status  = 1;

    IF @delete_user_type IS NULL
    BEGIN
        SELECT 0 AS SuccessCode, N'Invalid delete user.' AS Msg;
        RETURN;
    END

    IF @sender_user_id <> @delete_by
       AND @delete_user_type NOT IN ('A', 'SA')
    BEGIN
        SELECT 0 AS SuccessCode, N'You can delete only your own message.' AS Msg;
        RETURN;
    END

    UPDATE dbo.tbl_group_chat_message
    SET
          status      = 0
        , delete_by   = @delete_by
        , delete_date = dbo.get_date()
    WHERE message_id = @message_id
      AND app_id     = @app_id
      AND status     = 1;

    SELECT 1 AS SuccessCode, N'Message deleted.' AS Msg;
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.dis_group_chat_user_list_sp
  INPUT     : @app_id
  RESULT    : active tbl_user list for chat sidebar / member list
  TEST      : dis_group_chat_user_list_sp 1
------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[dis_group_chat_user_list_sp]
(
    @app_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          u.user_id
        , u.app_id
        , u.name
        , u.mobile_no
        , u.user_type
        , dbo.fn_get_designation(u.user_type) AS designation
        , u.photo
        , u.booth_no
        , u.last_login
    FROM dbo.tbl_user AS u
    WHERE u.app_id = @app_id
      AND u.status = 1
    ORDER BY u.name;
END;
GO

/*------------------------------------------------------------------------------
  PROCEDURE : dbo.dis_group_chat_message_count_sp
  INPUT     : @app_id, @after_msg_id (optional)
  RESULT    : total active messages OR count of new messages after id
  TEST      :
      dis_group_chat_message_count_sp 1, NULL
      dis_group_chat_message_count_sp 1, 100
------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[dis_group_chat_message_count_sp]
(
      @app_id        INT
    , @after_msg_id  BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(1) AS total_count
    FROM dbo.tbl_group_chat_message
    WHERE app_id = @app_id
      AND status = 1
      AND (@after_msg_id IS NULL OR message_id > @after_msg_id);
END;
GO