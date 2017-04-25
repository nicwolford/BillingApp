/****** Object:  StoredProcedure [dbo].[S1_Log_CreateAction]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Log_CreateAction]
(
	@ActionTypeCode varchar(50),
	@LogDescription varchar(max)
)
AS

INSERT INTO ActionLog (LogDate, ActionTypeCode, LogDescription)
VALUES (GETDATE(), @ActionTypeCode, @LogDescription)
GO
