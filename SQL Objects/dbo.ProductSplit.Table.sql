/****** Object:  Table [dbo].[ProductSplit]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductSplit](
	[ProductSplitID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[InvoiceSplitID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
 CONSTRAINT [PK_ProductSplit] PRIMARY KEY CLUSTERED 
(
	[ProductSplitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[ProductSplit]  WITH CHECK ADD  CONSTRAINT [FK_ProductSplit_InvoiceSplit] FOREIGN KEY([InvoiceSplitID])
REFERENCES [dbo].[InvoiceSplit] ([InvoiceSplitID])
GO
ALTER TABLE [dbo].[ProductSplit] CHECK CONSTRAINT [FK_ProductSplit_InvoiceSplit]
GO
