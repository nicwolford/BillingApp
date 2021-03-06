/****** Object:  Table [dbo].[MessageReservedWords]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MessageReservedWords](
	[MessageReservedWordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ReservedWord] [varchar](250) NOT NULL,
	[ReservedWordDisplay] [varchar](250) NOT NULL,
	[ShowInList] [tinyint] NOT NULL,
 CONSTRAINT [PK_MessageReservedWords] PRIMARY KEY CLUSTERED 
(
	[MessageReservedWordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
