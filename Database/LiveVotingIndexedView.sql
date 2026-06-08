
/* Materialized: voted_count only (MAX not allowed in indexed view here) */
create VIEW [dbo].[vw_live_voting_by_booth]
WITH SCHEMABINDING
AS
    SELECT
        lv.[app_id],
        lv.[part_no],
        COUNT_BIG(*) AS [voted_count]
    FROM [dbo].[tbl_live_voting] AS lv
    GROUP BY lv.[app_id], lv.[part_no];
GO

CREATE UNIQUE CLUSTERED INDEX [UX_vw_live_voting_by_booth]
    ON [dbo].[vw_live_voting_by_booth] ([app_id], [part_no]);
GO


