/****** Object:  Table [dbo].[ClientContacts]    Script Date: 11/21/2016 9:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClientContacts](
	[ClientContactID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ClientID] [int] NULL,
	[UserID] [int] NULL,
	[ContactPrefix] [varchar](20) NULL,
	[ContactFirstName] [varchar](255) NULL,
	[ContactLastName] [varchar](255) NULL,
	[ContactSuffix] [varchar](20) NULL,
	[ContactTitle] [varchar](100) NULL,
	[ContactAddr1] [varchar](100) NULL,
	[ContactAddr2] [varchar](100) NULL,
	[ContactCity] [varchar](100) NULL,
	[ContactStateCode] [char](2) NULL,
	[ContactZIP] [varchar](10) NULL,
	[ContactBusinessPhone] [varchar](50) NULL,
	[ContactCellPhone] [varchar](50) NULL,
	[ContactHomePhone] [varchar](50) NULL,
	[ContactFax] [varchar](50) NULL,
	[ContactEmail] [varchar](255) NULL,
	[ContactStatus] [bit] NULL,
 CONSTRAINT [PK_ClientContacts] PRIMARY KEY CLUSTERED 
(
	[ClientContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [IX_ClientContacts_UserID]    Script Date: 11/21/2016 9:44:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_ClientContacts_UserID] ON [dbo].[ClientContacts]
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
GO
