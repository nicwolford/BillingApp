/****** Object:  StoredProcedure [dbo].[S1_Invoices_SQLJobCreateInvoicesForClient]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Invoices_SQLJobCreateInvoicesForClient]
(
	@StartTransactionDate datetime,
	@EndTransactionDate datetime,
	@InvoiceDate datetime,
	@ClientID int,
	@UserId int
)
AS
BEGIN

;with jobSchedule as (
select @StartTransactionDate as StartTransactionDate,
	   @EndTransactionDate as EndTransactionDate,
	   @InvoiceDate as InvoiceDate,
	   @ClientID as ClientID,
	   0 as [Started],
	   0 as Done,
	   @UserId as UserId,
	   convert(datetime,convert(varchar(255),getdate(),100),100) as DateEntered --Code 100 = Date Per Minute
)
insert into SQLJobCreateInvoicesForClient(StartTransactionDate,
                                          EndTransactionDate,
								          InvoiceDate,
								          ClientID,
										  [Started],
										  Done,
										  UserId,
										  DateEntered)
select js.StartTransactionDate,
       js.EndTransactionDate,
	   js.InvoiceDate,
	   js.ClientID,
	   js.[Started],
	   js.Done,
	   js.UserId,
	   js.DateEntered
  from jobSchedule js
  where not exists(select scifc.Done
                     from SQLJobCreateInvoicesForClient scifc
					 where scifc.StartTransactionDate = js.StartTransactionDate and
					       scifc.EndTransactionDate = js.EndTransactionDate and
						   scifc.InvoiceDate = js.InvoiceDate and
						   scifc.ClientID = js.ClientID and
						   scifc.DateEntered = js.DateEntered)

--IF (@@ROWCOUNT > 0)
--BEGIN
--EXEC msdb.dbo.sp_start_job N'Run S1_Invoices_SQLJobCreateInvoicesForClientDOWORK';
--END

END


GO
