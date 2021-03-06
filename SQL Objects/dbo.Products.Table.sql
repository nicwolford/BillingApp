/****** Object:  Table [dbo].[Products]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ProductCode] [varchar](50) NOT NULL,
	[ProductName] [varchar](255) NOT NULL,
	[BaseCost] [money] NULL,
	[BaseCommission] [money] NULL,
	[IncludeOnInvoice] [tinyint] NOT NULL,
	[Employment] [smallmoney] NULL,
	[Tenant] [smallmoney] NULL,
	[Business] [smallmoney] NULL,
	[Volunteer] [smallmoney] NULL,
	[Other] [smallmoney] NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY],
 CONSTRAINT [IX_Products_ProductCode] UNIQUE NONCLUSTERED 
(
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
