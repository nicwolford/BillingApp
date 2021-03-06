/****** Object:  Table [dbo].[InvoicePayments]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoicePayments](
	[InvoicePaymentID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[PaymentID] [int] NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[QBTransactionID] [varchar](50) NOT NULL,
	[Amount] [money] NOT NULL,
	[ManualEntry] [bit] NULL CONSTRAINT [DF_InvoicePayments_ManualEntry]  DEFAULT ((0)),
	[ManualUserID] [int] NULL,
 CONSTRAINT [PK_InvoicePayments] PRIMARY KEY CLUSTERED 
(
	[InvoicePaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [IX_InvoicePayments_InvoiceID]    Script Date: 11/21/2016 9:44:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_InvoicePayments_InvoiceID] ON [dbo].[InvoicePayments]
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
GO
/****** Object:  Index [IX_InvoicePayments_PaymentID]    Script Date: 11/21/2016 9:44:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_InvoicePayments_PaymentID] ON [dbo].[InvoicePayments]
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
GO
