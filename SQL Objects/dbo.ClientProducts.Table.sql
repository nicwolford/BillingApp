/****** Object:  Table [dbo].[ClientProducts]    Script Date: 11/21/2016 9:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientProducts](
	[ClientProductsID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ClientID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[IncludeOnInvoice] [tinyint] NOT NULL CONSTRAINT [DF_ClientProducts_IncludeOnInvoice]  DEFAULT ((0)),
	[SalesPrice] [money] NULL,
	[ImportsAtBaseOrSales] [bit] NULL,
	[BaseCommission] [money] NULL,
 CONSTRAINT [PK_ClientProducts] PRIMARY KEY CLUSTERED 
(
	[ClientProductsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO
