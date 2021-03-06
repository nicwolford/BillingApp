/****** Object:  Table [dbo].[Clients]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Clients](
	[ClientID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ParentClientID] [int] NULL,
	[ClientName] [varchar](100) NOT NULL,
	[Address1] [varchar](100) NULL,
	[Address2] [varchar](100) NULL,
	[City] [varchar](100) NULL,
	[State] [char](2) NULL,
	[ZipCode] [varchar](10) NULL,
	[DoNotInvoice] [bit] NULL,
	[GetsInvoiceDetail] [bit] NULL,
	[Status] [varchar](20) NULL,
	[BillAsClientName] [varchar](100) NULL,
	[ImportClientSplitMode] [int] NULL,
	[DueText] [varchar](50) NULL,
	[BillingGroup] [int] NULL,
	[BillingNotes] [varchar](max) NULL,
	[AuditInvoices] [bit] NULL CONSTRAINT [DF_Clients_AuditInvoices]  DEFAULT ((0)),
	[Notes] [varchar](max) NULL,
	[SalesRepID] [int] NULL CONSTRAINT [DF_Clients_SalesRepID]  DEFAULT ((0)),
 CONSTRAINT [PK_Clients] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
