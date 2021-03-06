/****** Object:  Table [dbo].[InvoiceBillingContacts]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceBillingContacts](
	[InvoiceBillingContactID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[BillingContactID] [int] NOT NULL,
	[IsPrimaryBillingContact] [bit] NOT NULL,
 CONSTRAINT [PK_InvoiceBillingContacts] PRIMARY KEY CLUSTERED 
(
	[InvoiceBillingContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [IX_InvoiceBillingContacts_BillingContactID]    Script Date: 11/21/2016 9:44:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_InvoiceBillingContacts_BillingContactID] ON [dbo].[InvoiceBillingContacts]
(
	[BillingContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
GO
/****** Object:  Index [IX_InvoiceBillingContacts_InvoiceID]    Script Date: 11/21/2016 9:44:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_InvoiceBillingContacts_InvoiceID] ON [dbo].[InvoiceBillingContacts]
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvoiceBillingContacts]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceBillingContacts_BillingContacts] FOREIGN KEY([BillingContactID])
REFERENCES [dbo].[BillingContacts] ([BillingContactID])
GO
ALTER TABLE [dbo].[InvoiceBillingContacts] CHECK CONSTRAINT [FK_InvoiceBillingContacts_BillingContacts]
GO
ALTER TABLE [dbo].[InvoiceBillingContacts]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceBillingContacts_Invoices] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[Invoices] ([InvoiceID])
GO
ALTER TABLE [dbo].[InvoiceBillingContacts] CHECK CONSTRAINT [FK_InvoiceBillingContacts_Invoices]
GO
