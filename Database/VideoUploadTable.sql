/*
  File / video upload — table and stored procedures.
  Run this script on db_bjp_wings.
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'[dbo].[tbl_VideoUpload]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[tbl_VideoUpload] (
        [video_id]   BIGINT         IDENTITY(1,1) NOT NULL,
        [video_path] NVARCHAR(1000) NOT NULL,
        [file_name]  NVARCHAR(500)  NULL,
        [file_ext]   NVARCHAR(20)   NULL,
        [file_type]  NVARCHAR(50)   NULL,
        CONSTRAINT [PK_tbl_VideoUpload] PRIMARY KEY CLUSTERED ([video_id] ASC)
    );
END
GO

IF COL_LENGTH(N'dbo.tbl_VideoUpload', N'file_name') IS NULL
    ALTER TABLE [dbo].[tbl_VideoUpload] ADD [file_name] NVARCHAR(500) NULL;
GO
IF COL_LENGTH(N'dbo.tbl_VideoUpload', N'file_ext') IS NULL
    ALTER TABLE [dbo].[tbl_VideoUpload] ADD [file_ext] NVARCHAR(20) NULL;
GO
IF COL_LENGTH(N'dbo.tbl_VideoUpload', N'file_type') IS NULL
    ALTER TABLE [dbo].[tbl_VideoUpload] ADD [file_type] NVARCHAR(50) NULL;
GO

CREATE OR ALTER PROCEDURE [dbo].[ins_video_upload_sp]
(
    @video_path NVARCHAR(1000),
    @file_name  NVARCHAR(500) = NULL,
    @file_ext   NVARCHAR(20)  = NULL,
    @file_type  NVARCHAR(50)  = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[tbl_VideoUpload] ([video_path], [file_name], [file_ext], [file_type])
    VALUES (@video_path, @file_name, @file_ext, @file_type);

    SELECT
        SCOPE_IDENTITY() AS video_id,
        @video_path       AS video_path,
        @file_name        AS file_name,
        @file_ext         AS file_ext,
        @file_type        AS file_type;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[dis_video_upload_sp]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        video_id,
        video_path,
        file_name,
        file_ext,
        file_type
    FROM [dbo].[tbl_VideoUpload]
    ORDER BY video_id DESC;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[dis_all_video_sp]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        video_id,
        video_path,
        file_name,
        file_ext,
        file_type
    FROM [dbo].[tbl_VideoUpload]
    ORDER BY video_id DESC;
END
GO
