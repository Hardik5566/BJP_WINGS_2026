/*
  Live voting — table definitions only.
  Natural key: (app_id, part_no, slnoinpart) — assumes part_no is unique per app_id.
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ---- tbl_live_voting ---- */
IF OBJECT_ID(N'[dbo].[tbl_live_voting]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[tbl_live_voting] (
        [vote_id]     BIGINT        IDENTITY(1,1) NOT NULL,
        [app_id]      INT           NOT NULL,
        [part_no]     INT           NOT NULL,
        [slnoinpart]  INT           NOT NULL,
        [voted_at]    DATETIME2(3)  NOT NULL DEFAULT (dbo.get_date()),
        [created_by]  INT           NULL,
        CONSTRAINT [PK_tbl_live_voting] PRIMARY KEY CLUSTERED ([vote_id] ASC),
        CONSTRAINT [UK_tbl_live_voting] UNIQUE ([app_id], [part_no], [slnoinpart])
    );
	
END
GO
