/****** Object:  Table [dbo].[BillingPackagePrinted]    Script Date: 11/21/2016 9:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillingPackagePrinted](
	[BillingPackagePrintedID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[BillingContactID] [int] NOT NULL,
	[PackageEndDate] [datetime] NOT NULL,
	[PrintedOn] [datetime] NOT NULL,
	[PrintedByUser] [int] NOT NULL,
	[EmailGuid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_BillingPackagePrinted] PRIMARY KEY CLUSTERED 
(
	[BillingPackagePrintedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO
