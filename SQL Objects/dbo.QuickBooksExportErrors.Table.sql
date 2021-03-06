/****** Object:  Table [dbo].[QuickBooksExportErrors]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[QuickBooksExportErrors](
	[QuickBooksExportErrorsID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ErrorDateTime] [datetime] NOT NULL,
	[ErrorText] [varchar](max) NULL,
 CONSTRAINT [PK_QuickBooksExportErrors] PRIMARY KEY CLUSTERED 
(
	[QuickBooksExportErrorsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
