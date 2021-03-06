/****** Object:  Table [dbo].[InvoiceSplit]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceSplit](
	[InvoiceSplitID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ClientID] [int] NOT NULL,
 CONSTRAINT [PK_InvoiceSplit] PRIMARY KEY CLUSTERED 
(
	[InvoiceSplitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[InvoiceSplit]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceSplit_Clients] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ClientID])
GO
ALTER TABLE [dbo].[InvoiceSplit] CHECK CONSTRAINT [FK_InvoiceSplit_Clients]
GO
