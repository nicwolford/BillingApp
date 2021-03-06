/****** Object:  Table [dbo].[ClientUsers]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientUsers](
	[ClientUsersID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UserID] [int] NOT NULL,
	[ClientID] [int] NOT NULL,
	[IsPrimaryClient] [bit] NOT NULL,
 CONSTRAINT [PK_ClientUsers] PRIMARY KEY CLUSTERED 
(
	[ClientUsersID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[ClientUsers]  WITH CHECK ADD  CONSTRAINT [FK_ClientUsers_ClientUsers] FOREIGN KEY([ClientUsersID])
REFERENCES [dbo].[ClientUsers] ([ClientUsersID])
GO
ALTER TABLE [dbo].[ClientUsers] CHECK CONSTRAINT [FK_ClientUsers_ClientUsers]
GO
