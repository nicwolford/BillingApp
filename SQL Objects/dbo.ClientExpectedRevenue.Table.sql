/****** Object:  Table [dbo].[ClientExpectedRevenue]    Script Date: 11/21/2016 9:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClientExpectedRevenue](
	[ClientExpectedRevenueID] [int] IDENTITY(1,1) NOT NULL,
	[ClientID] [int] NOT NULL,
	[ExpectedMonthlyRevenue] [money] NULL,
	[AccountCreateDate] [datetime] NULL,
	[AccountOwner] [varchar](500) NULL,
	[AffiliateName] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
