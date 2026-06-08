CREATE TABLE tbl_group_chat_message
(
    message_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
    app_id           INT NOT NULL,              -- fixed group = this app
    sender_user_id   INT NOT NULL,            -- tbl_user.user_id
    msg_type         VARCHAR(20) NOT NULL,      -- TEXT | IMAGE | VIDEO | FILE | AUDIO
    message_text     NVARCHAR(MAX) NULL,      -- text or caption
    file_path        NVARCHAR(1000) NULL,     -- uploads/chat/1/xxx.jpg
    file_name        NVARCHAR(500) NULL,
    file_ext         NVARCHAR(20) NULL,
    file_size        BIGINT NULL,
    file_type        NVARCHAR(50) NULL,       -- image | video | document
    reply_to_msg_id  BIGINT NULL,
    status           BIT NOT NULL DEFAULT 1,    -- 1=active, 0=deleted
    create_date      DATETIME NOT NULL DEFAULT GETDATE(),
    delete_by        INT NULL,
    delete_date      DATETIME NULL
);

CREATE INDEX IX_group_chat_msg_app_msgid
ON tbl_group_chat_message (app_id, message_id DESC);