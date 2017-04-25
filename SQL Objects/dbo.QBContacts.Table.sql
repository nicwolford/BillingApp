/****** Object:  Table [dbo].[QBContacts]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QBContacts](
	[ClientID] [nvarchar](255) NULL,
	[Customer] [nvarchar](255) NULL,
	[Contact] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[Fax] [nvarchar](255) NULL,
	[Street1] [nvarchar](255) NULL,
	[Street2] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[Zip] [nvarchar](255) NULL,
	[EMAIL] [nvarchar](255) NULL
) ON [PRIMARY]

GO
