USE [master]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_WhoIsPrimary]
@ag sysname, 
@id uniqueidentifier
WITH EXECUTE AS OWNER
AS
BEGIN
DECLARE @PrimaryReplica sysname
DECLARE @name sysname;
SET @id = CONVERT(uniqueidentifier,@id)
SELECT @name = name FROM msdb.dbo.sysjobs WHERE job_id = @id
SELECT
    @PrimaryReplica = hags.primary_replica
  FROM sys.dm_hadr_availability_group_states hags
  INNER JOIN sys.availability_groups ag ON ag.group_id = hags.group_id
  WHERE ag.name = @ag;
    IF UPPER(@PrimaryReplica) = UPPER(@@SERVERNAME)
    PRINT'CheckPassed'; -- primary
	ELSE
	EXEC msdb.dbo.sp_stop_job @job_name = @name;
END
GO


