/****** Object:  Table [dbo].[ProductsOnInvoice]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProductsOnInvoice](
	[ProductsOnInvoiceID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductTransactionID] [int] NULL,
	[ProductPrice] [money] NOT NULL,
	[OrderBy] [varchar](100) NULL,
	[Reference] [varchar](100) NULL,
	[ProductName] [varchar](100) NULL,
	[ProductDescription] [varchar](max) NULL,
	[ProductType] [varchar](50) NULL,
	[FileNum] [varchar](50) NULL,
	[DateOrdered] [smalldatetime] NULL,
	[FName] [varchar](255) NULL,
	[LName] [varchar](255) NULL,
	[MName] [varchar](255) NULL,
	[SSN] [varchar](50) NULL,
	[ExternalInvoiceNumber] [varchar](50) NULL,
	[OriginalClientID] [int] NULL,
	[CoFName] [varchar](255) NULL,
	[CoLName] [varchar](255) NULL,
	[CoMName] [varchar](255) NULL,
	[CoSSN] [varchar](50) NULL,
	[VendorID] [int] NULL,
 CONSTRAINT [PK_ProductsOnInvoice] PRIMARY KEY CLUSTERED 
(
	[ProductsOnInvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ProductsOnInvoice_FileNum]    Script Date: 11/21/2016 9:44:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_ProductsOnInvoice_FileNum] ON [dbo].[ProductsOnInvoice]
(
	[FileNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProductsOnInvoice_InvoiceID]    Script Date: 11/21/2016 9:44:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_ProductsOnInvoice_InvoiceID] ON [dbo].[ProductsOnInvoice]
(
	[InvoiceID] ASC
)
INCLUDE ( 	[ProductPrice]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProductsOnInvoice_ProductID]    Script Date: 11/21/2016 9:44:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_ProductsOnInvoice_ProductID] ON [dbo].[ProductsOnInvoice]
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProductsOnInvoice_ProductTransactionID]    Script Date: 11/21/2016 9:44:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_ProductsOnInvoice_ProductTransactionID] ON [dbo].[ProductsOnInvoice]
(
	[ProductTransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductsOnInvoice]  WITH CHECK ADD  CONSTRAINT [FK_ProductsOnInvoice_Invoices] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[Invoices] ([InvoiceID])
GO
ALTER TABLE [dbo].[ProductsOnInvoice] CHECK CONSTRAINT [FK_ProductsOnInvoice_Invoices]
GO
ALTER TABLE [dbo].[ProductsOnInvoice]  WITH CHECK ADD  CONSTRAINT [FK_ProductsOnInvoice_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[ProductsOnInvoice] CHECK CONSTRAINT [FK_ProductsOnInvoice_Products]
GO
