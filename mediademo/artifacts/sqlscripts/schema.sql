
/****** Object:  Table [dbo].[appearances]    Script Date: 3/25/2021 10:18:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[appearances]
(
	[referenceId] [varchar](50) NOT NULL,
	[startTime] [varchar](50) NOT NULL,
	[endTime] [varchar](50) NOT NULL,
	[startSeconds] [varchar](50) NOT NULL,
	[endSeconds] [varchar](50) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [referenceId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Campaign_Analytics]    Script Date: 3/25/2021 10:51:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Campaign_Analytics]
(
	[Region] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Campaign_Name] [varchar](50) NULL,
	[Revenue] [varchar](50) NULL,
	[Revenue_Target] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](50) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Campaign_Analytics_New]    Script Date: 3/25/2021 10:52:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Campaign_Analytics_New]
(
	[Region] [nvarchar](4000) NULL,
	[Country] [nvarchar](4000) NULL,
	[Campaign_Name] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[Revenue_Target] [nvarchar](4000) NULL,
	[City] [nvarchar](4000) NULL,
	[State] [nvarchar](4000) NULL,
	[RoleID] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[ConflictofInterest]    Script Date: 3/25/2021 10:53:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ConflictofInterest]
(
	[FiscalYear-Quarter] [varchar](20) NULL,
	[Fiscal Year] [varchar](20) NULL,
	[Fiscal Quarter] [varchar](20) NULL,
	[Country] [varchar](20) NULL,
	[Region] [varchar](50) NULL,
	[Required] [varchar](10) NULL,
	[Complete] [varchar](20) NULL,
	[Survey NC] [varchar](10) NULL,
	[Incomplete] [varchar](10) NULL,
	[Function Summary] [varchar](50) NULL,
	[Complete %] [varchar](20) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO
/****** Object:  Table [dbo].[Country]    Script Date: 3/25/2021 10:56:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Country]
(
	[ID] [varchar](10) NULL,
	[Country] [varchar](20) NULL,
	[Region] [varchar](50) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[CustomerInfo]    Script Date: 3/25/2021 10:57:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CustomerInfo]
(
	[UserName] [nvarchar](4000) NULL,
	[Gender] [nvarchar](4000) NULL,
	[Phone] [nvarchar](4000) NULL,
	[Email] [nvarchar](4000) MASKED WITH (FUNCTION = 'email()') NULL,
	[CreditCard] [nvarchar](19) MASKED WITH (FUNCTION = 'partial(0, "XXX-XXX-XXXX-", 4)') NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[emotions]    Script Date: 3/25/2021 10:57:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[emotions]
(
	[VideoId] [varchar](50) NOT NULL,
	[stype] [varchar](50) NOT NULL,
	[seenDurationRatio] [varchar](50) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[faces]    Script Date: 3/25/2021 10:57:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[faces]
(
	[VideoId] [varchar](500)  NULL,
	[id] [varchar](50)  NULL,
	[name] [varchar](500)  NULL,
	[confidence] [varchar](500)  NULL,
	[description] [varchar](300)  NULL,
	[thumbnailId] [varchar](50)  NULL,
	[referenceId] [varchar](50)  NULL,
	[referenceType] [varchar](50)  NULL,
	[title] [varchar](50)  NULL,
	[imageUrl] [varchar](100)  NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[FPA]    Script Date: 3/25/2021 10:58:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FPA]
(
	[Fiscal Year] [varchar](10) NULL,
	[Fiscal Quarter] [varchar](10) NULL,
	[Fiscal Month] [varchar](10) NULL,
	[Country] [varchar](20) NULL,
	[Forecast] [varchar](10) NULL,
	[Budget] [varchar](20) NULL,
	[Actual] [varchar](20) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[HealthCare-FactSales]    Script Date: 3/25/2021 10:58:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[HealthCare-FactSales]
(
	[CareManager] [nvarchar](4000) NULL,
	[PayerName] [nvarchar](4000) NULL,
	[CampaignName] [nvarchar](4000) NULL,
	[Region] [nvarchar](4000) NULL,
	[State] [nvarchar](4000) NULL,
	[City] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[RevenueTarget] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[HospitalEmpPIIData]    Script Date: 3/25/2021 10:59:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[HospitalEmpPIIData]
(
	[Id] [int] NULL,
	[EmpName] [nvarchar](61) NULL,
	[Address] [nvarchar](30) NULL,
	[City] [nvarchar](30) NULL,
	[County] [nvarchar](30) NULL,
	[State] [nvarchar](10) NULL,
	[Phone] [varchar](100) NULL,
	[Email] [varchar](100) NULL,
	[Designation] [varchar](20) NULL,
	[SSN] [varchar](100) NULL,
	[SSN_encrypted] [nvarchar](100) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO
/****** Object:  Table [dbo].[jsona]    Script Date: 3/25/2021 10:59:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[jsona]
(
	[list_data1] [varchar](max) NULL,
	[list_data2] [varchar](max) NULL,
	[list_data3] [int] NULL,
	[list_data4] [varchar](max) NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	CLUSTERED INDEX
	(
		[list_data3] ASC
	)
)
GO

/****** Object:  Table [dbo].[keywords]    Script Date: 3/25/2021 11:01:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[keywords]
(
	[VideoId] [varchar](50) NOT NULL,
	[id] [int] NULL,
	[text] [varchar](250) NULL,
	[confidence] [real] NULL,
	[language] [varchar](50) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[labels]    Script Date: 25-03-2021 16:39:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[labels]
(
	[VideoId] [varchar](50) NOT NULL,
	[aid] [int] NOT NULL,
	[name] [varchar](50) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[MediaEmpPIIData]    Script Date: 25-03-2021 16:40:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MediaEmpPIIData]
(
	[Id] [int] NULL,
	[EmpName] [nvarchar](61) NULL,
	[Address] [nvarchar](30) NULL,
	[City] [nvarchar](30) NULL,
	[County] [nvarchar](30) NULL,
	[State] [nvarchar](10) NULL,
	[Phone] [varchar](100) NULL,
	[Email] [varchar](100) NULL,
	[Designation] [varchar](20) NULL,
	[SSN] [varchar](100) NULL,
	[SSN_encrypted] [nvarchar](100) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Media-FactSales]    Script Date: 25-03-2021 16:41:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Media-FactSales]
(
	[CareManager] [nvarchar](4000) NULL,
	[PayerName] [nvarchar](4000) NULL,
	[CampaignName] [nvarchar](4000) NULL,
	[Region] [nvarchar](4000) NULL,
	[State] [nvarchar](4000) NULL,
	[City] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[RevenueTarget] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_CampaignAnalyticLatest]    Script Date: 25-03-2021 16:41:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_CampaignAnalyticLatest]
(
	[Region] [nvarchar](4000) NULL,
	[Country] [nvarchar](4000) NULL,
	[ProductCategory] [nvarchar](4000) NULL,
	[Campaign_ID] [nvarchar](4000) NULL,
	[Campaign_Name] [nvarchar](4000) NULL,
	[Qualification] [nvarchar](4000) NULL,
	[Qualification_Number] [nvarchar](4000) NULL,
	[Response_Status] [nvarchar](4000) NULL,
	[Responses] [nvarchar](4000) NULL,
	[Cost] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[ROI] [nvarchar](4000) NULL,
	[Lead_Generation] [nvarchar](4000) NULL,
	[Revenue_Target] [nvarchar](4000) NULL,
	[Campaign_Tactic] [nvarchar](4000) NULL,
	[Customer_Segment] [nvarchar](4000) NULL,
	[Status] [nvarchar](4000) NULL,
	[Profit] [nvarchar](4000) NULL,
	[Marketing_Cost] [nvarchar](4000) NULL,
	[CampaignID] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_CampaignData]    Script Date: 25-03-2021 16:42:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_CampaignData]
(
	[ID] [bigint] NULL,
	[CampaignName] [varchar](18) NULL,
	[CampaignTactic] [varchar](16) NULL,
	[CampaignStartDate] [datetime] NULL,
	[Expense] [decimal](10, 2) NULL,
	[MarketingCost] [decimal](10, 2) NULL,
	[Profit] [decimal](10, 2) NULL,
	[LocationID] [bigint] NULL,
	[Revenue] [decimal](10, 2) NULL,
	[RevenueTarget] [decimal](10, 2) NULL,
	[ROI] [decimal](10, 2) NULL,
	[Status] [varchar](13) NULL,
	[ProductID] [bigint] NULL,
	[Sentiment] [nvarchar](20) NULL,
	[Response] [bigint] NULL,
	[CampaignID] [bigint] NULL,
	[CampaignRowKey] [bigint] NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_CampaignData_exl]    Script Date: 25-03-2021 16:43:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_CampaignData_exl]
(
	[ID] [nvarchar](4000) NULL,
	[CampaignName] [nvarchar](4000) NULL,
	[CampaignTactic] [nvarchar](4000) NULL,
	[CampaignStartDate] [nvarchar](4000) NULL,
	[Expense] [nvarchar](4000) NULL,
	[MarketingCost] [nvarchar](4000) NULL,
	[Profit] [nvarchar](4000) NULL,
	[LocationID] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[RevenueTarget] [nvarchar](4000) NULL,
	[ROI] [nvarchar](4000) NULL,
	[Status] [nvarchar](4000) NULL,
	[ProductID] [nvarchar](4000) NULL,
	[Sentiment] [nvarchar](4000) NULL,
	[Response] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_CampaignNew4]    Script Date: 25-03-2021 16:43:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_CampaignNew4]
(
	[Id] [nvarchar](4000) NULL,
	[CampaignId] [nvarchar](4000) NULL,
	[CampaignName] [nvarchar](4000) NULL,
	[CampaignStartDate] [nvarchar](4000) NULL,
	[CampaignEndDate] [nvarchar](4000) NULL,
	[Cost] [nvarchar](4000) NULL,
	[ROI] [nvarchar](4000) NULL,
	[LeadGeneration] [nvarchar](4000) NULL,
	[RevenueTarget] [nvarchar](4000) NULL,
	[CampaignTactic] [nvarchar](4000) NULL,
	[Profit] [nvarchar](4000) NULL,
	[MarketingCost] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_Campaignproducts]    Script Date: 25-03-2021 16:43:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_Campaignproducts]
(
	[Campaign] [varchar](250) NULL,
	[ProductCategory] [varchar](250) NULL,
	[Hashtag] [varchar](250) NULL,
	[Counts] [varchar](250) NULL,
	[ProductID] [int] NULL,
	[CampaignRowKey] [bigint] NULL,
	[SelectedFlag] [varchar](40) NULL,
	[Sentiment] [varchar](20) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_Campaigns]    Script Date: 25-03-2021 16:46:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_Campaigns]
(
	[Campaigns_ID] [nvarchar](4000) NULL,
	[CampaignID] [nvarchar](4000) NULL,
	[CampaignName] [nvarchar](4000) NULL,
	[SubCampaignID] [nvarchar](4000) NULL,
	[FullAd_FileName] [nvarchar](4000) NULL,
	[HalfAd_FileName] [nvarchar](4000) NULL,
	[Logo_FileName] [nvarchar](4000) NULL,
	[SoundFile_FileName] [nvarchar](4000) NULL,
	[FullAd] [nvarchar](4000) NULL,
	[HalfAd] [nvarchar](4000) NULL,
	[Logo] [nvarchar](4000) NULL,
	[SoundFile] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_Customer]    Script Date: 25-03-2021 16:48:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_Customer]
(
	[Id] [bigint] NULL,
	[Age] [smallint] NULL,
	[Gender] [nvarchar](4000) NULL,
	[Pincode] [nvarchar](4000) NULL,
	[FirstName] [nvarchar](4000) NULL,
	[LastName] [nvarchar](4000) NULL,
	[FullName] [nvarchar](4000) NULL,
	[DateOfBirth] [nvarchar](4000) NULL,
	[Address] [nvarchar](4000) NULL,
	[Email] [nvarchar](4000) NULL,
	[Mobile] [nvarchar](4000) NULL,
	[UserName] [nvarchar](4000) NULL,
	[Customer_type] [varchar](3) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[brands]
( 
	[referenceId] [varchar](50)   NULL,
	[referenceUrl] [varchar](50)   NULL,
	[confidence] [varchar](50)   NULL,
	[description] [varchar](5000)   NULL,
	[seenDuration] [varchar](500)   NULL,
	[id] [varchar](50)   NULL,
	[name] [varchar](50)   NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO
/****** Object:  Table [dbo].[Mkt_CustomerNew]    Script Date: 25-03-2021 16:49:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_CustomerNew]
(
	[Id] [bigint] NULL,
	[Age] [smallint] NULL,
	[Gender] [nvarchar](4000) NULL,
	[Pincode] [nvarchar](4000) NULL,
	[FirstName] [nvarchar](4000) NULL,
	[LastName] [nvarchar](4000) NULL,
	[FullName] [nvarchar](4000) NULL,
	[DateOfBirth] [nvarchar](4000) NULL,
	[Address] [nvarchar](4000) NULL,
	[Email] [nvarchar](4000) NULL,
	[Mobile] [nvarchar](4000) NULL,
	[UserName] [nvarchar](4000) NULL,
	[Customer_type] [varchar](3) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_Date]    Script Date: 25-03-2021 16:49:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_Date]
(
	[Date] [date] NULL,
	[Day] [int] NULL,
	[DaySuffix] [char](2) NULL,
	[DayName] [nvarchar](30) NULL,
	[DayOfWeek] [int] NULL,
	[DayOfWeekInMonth] [tinyint] NULL,
	[DayOfYear] [int] NULL,
	[IsWeekend] [int] NULL,
	[Week] [int] NULL,
	[ISOweek] [int] NULL,
	[FirstOfWeek] [date] NULL,
	[LastOfWeek] [date] NULL,
	[WeekOfMonth] [tinyint] NULL,
	[Month] [int] NULL,
	[MonthName] [nvarchar](30) NULL,
	[FirstOfMonth] [date] NULL,
	[LastOfMonth] [date] NULL,
	[FirstOfNextMonth] [date] NULL,
	[LastOfNextMonth] [date] NULL,
	[Quarter] [int] NULL,
	[FirstOfQuarter] [date] NULL,
	[LastOfQuarter] [date] NULL,
	[Year] [int] NULL,
	[ISOYear] [int] NULL,
	[FirstOfYear] [date] NULL,
	[LastOfYear] [date] NULL,
	[IsLeapYear] [bit] NULL,
	[Has53Weeks] [int] NULL,
	[Has53ISOWeeks] [int] NULL,
	[MonthNumber] [int] NULL,
	[DateKey] [int] NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_Location]    Script Date: 25-03-2021 16:50:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_Location]
(
	[LocationId] [bigint] NULL,
	[LocationCode] [varchar](10) NULL,
	[LocationName] [varchar](2000) NULL,
	[Country] [nvarchar](50) NULL,
	[Region] [varchar](50) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO


/****** Object:  Table [dbo].[Mkt_OperationsCaseData]    Script Date: 25-03-2021 16:50:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_OperationsCaseData]
(
	[City] [nvarchar](4000) NULL,
	[CasesCreated] [nvarchar](4000) NULL,
	[CasesResolved] [nvarchar](4000) NULL,
	[CasesCancelled] [nvarchar](4000) NULL,
	[CasesPending] [nvarchar](4000) NULL,
	[SLACompliance] [nvarchar](4000) NULL,
	[SLANonCompliance] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO


/****** Object:  Table [dbo].[Mkt_Orders]    Script Date: 25-03-2021 16:56:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_Orders]
(
	[Date] [datetime] NULL,
	[Amount] [decimal](18, 2) NULL,
	[ExpectedDeliveryDate] [datetime] NULL,
	[DeliveryLocation] [nvarchar](50) NULL,
	[CustomerId] [bigint] NULL,
	[Status] [int] NULL,
	[StatusDate] [datetime] NULL,
	[ProductId] [bigint] NULL,
	[Quantity] [decimal](18, 2) NULL,
	[OrderKey] [nvarchar](50) NULL,
	[QuantityProduced] [decimal](18, 2) NULL,
	[CompletionDate] [datetime] NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_Product]    Script Date: 25-03-2021 16:57:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_Product]
(
	[ProductID] [int] NULL,
	[ProductCode] [nvarchar](50) NULL,
	[BarCode] [nvarchar](23) NULL,
	[Name] [nvarchar](100) NULL,
	[Description] [nvarchar](500) NULL,
	[Price] [decimal](10, 2) NULL,
	[Category] [nvarchar](20) NULL,
	[Thumbnail_FileName] [nvarchar](500) NULL,
	[AdImage_FileName] [nvarchar](500) NULL,
	[SoundFile_FileName] [nvarchar](500) NULL,
	[CreatedDate] [datetime2](0) NULL,
	[Dimensions] [nvarchar](50) NULL,
	[Colour] [nvarchar](50) NULL,
	[Weight] [decimal](10, 2) NULL,
	[MaxLoad] [decimal](10, 2) NULL,
	[BasePrice] [int] NULL,
	[id] [int] NULL,
	[TaxRate] [int] NULL,
	[SellingPrice] [decimal](18, 2) NULL,
	[COGS_PER] [int] NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_ProductNew]    Script Date: 25-03-2021 16:58:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_ProductNew]
(
	[ProductID] [int] NULL,
	[ProductCode] [nvarchar](50) NULL,
	[BarCode] [nvarchar](23) NULL,
	[Name] [nvarchar](100) NULL,
	[Description] [nvarchar](500) NULL,
	[Price] [decimal](10, 2) NULL,
	[Category] [nvarchar](20) NULL,
	[Thumbnail_FileName] [nvarchar](500) NULL,
	[AdImage_FileName] [nvarchar](500) NULL,
	[SoundFile_FileName] [nvarchar](500) NULL,
	[CreatedDate] [varchar](500) NULL,
	[Dimensions] [nvarchar](50) NULL,
	[Colour] [nvarchar](50) NULL,
	[Weight] [decimal](10, 2) NULL,
	[MaxLoad] [decimal](10, 2) NULL,
	[BasePrice] [int] NULL,
	[id] [int] NULL,
	[TaxRate] [int] NULL,
	[SellingPrice] [decimal](18, 2) NULL,
	[COGS_PER] [int] NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_Sales]    Script Date: 25-03-2021 16:58:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_Sales]
(
	[Date] [datetime] NULL,
	[CustomerId] [bigint] NULL,
	[DeliveryDate] [datetime] NULL,
	[ProductId] [bigint] NULL,
	[Quantity] [decimal](18, 2) NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxAmount] [decimal](18, 2) NULL,
	[TotalExcludingTax] [decimal](18, 2) NULL,
	[TotalIncludingTax] [decimal](18, 2) NULL,
	[GrossPrice] [decimal](18, 2) NULL,
	[Discount] [decimal](18, 2) NULL,
	[NetPrice] [decimal](18, 2) NULL,
	[GrossRevenue] [decimal](18, 2) NULL,
	[NetRevenue] [decimal](18, 2) NULL,
	[COGS_PER] [decimal](18, 2) NULL,
	[COGS] [decimal](18, 2) NULL,
	[GrossProfit] [decimal](18, 2) NULL,
	[OrderKey] [nvarchar](50) NULL,
	[SaleKey] [nvarchar](100) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_SalesNew]    Script Date: 25-03-2021 16:59:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_SalesNew]
(
	[Date] [date] NULL,
	[CustomerId] [bigint] NULL,
	[DeliveryDate] [date] NULL,
	[ProductId] [bigint] NULL,
	[Quantity] [decimal](18, 2) NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxAmount] [decimal](18, 2) NULL,
	[TotalExcludingTax] [decimal](18, 2) NULL,
	[TotalIncludingTax] [decimal](18, 2) NULL,
	[GrossPrice] [decimal](18, 2) NULL,
	[Discount] [decimal](18, 2) NULL,
	[NetPrice] [decimal](18, 2) NULL,
	[GrossRevenue] [decimal](18, 2) NULL,
	[NetRevenue] [decimal](18, 2) NULL,
	[COGS_PER] [decimal](18, 2) NULL,
	[COGS] [decimal](18, 2) NULL,
	[GrossProfit] [decimal](18, 2) NULL,
	[OrderKey] [nvarchar](50) NULL,
	[SaleKey] [nvarchar](100) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_vCampaignSales]    Script Date: 25-03-2021 16:59:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_vCampaignSales]
(
	[Year] [int] NULL,
	[Month] [int] NULL,
	[MonthName] [nvarchar](30) NULL,
	[CampaignRowKey] [int] NULL,
	[Profit] [decimal](38, 2) NULL,
	[Revenue] [decimal](38, 2) NULL,
	[QuantitySold] [decimal](38, 2) NULL,
	[cb] [bigint] NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Mkt_WebsiteSocialAnalyticsPBIData]    Script Date: 25-03-2021 17:00:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Mkt_WebsiteSocialAnalyticsPBIData]
(
	[Country] [nvarchar](4000) NULL,
	[Product_Category] [nvarchar](4000) NULL,
	[Product] [nvarchar](4000) NULL,
	[Channel] [nvarchar](4000) NULL,
	[Gender] [nvarchar](4000) NULL,
	[Sessions] [nvarchar](4000) NULL,
	[Device_Category] [nvarchar](4000) NULL,
	[Sources] [nvarchar](4000) NULL,
	[Conversations] [nvarchar](4000) NULL,
	[Page] [nvarchar](4000) NULL,
	[Visits] [nvarchar](4000) NULL,
	[Unique_Visitors] [nvarchar](4000) NULL,
	[Browser] [nvarchar](4000) NULL,
	[Sentiment] [nvarchar](4000) NULL,
	[Duration_min] [nvarchar](4000) NULL,
	[Region] [nvarchar](4000) NULL,
	[Customer_Segment] [nvarchar](4000) NULL,
	[Daily_Users] [nvarchar](4000) NULL,
	[Conversion_Rate] [nvarchar](4000) NULL,
	[Return_Visitors] [nvarchar](4000) NULL,
	[Tweets] [nvarchar](4000) NULL,
	[Retweets] [nvarchar](4000) NULL,
	[Hashtags] [nvarchar](4000) NULL,
	[Campaign_Name] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[ocr]    Script Date: 25-03-2021 17:00:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ocr]
(
	[VideoId] [varchar](50) NOT NULL,
	[aid] [int] NOT NULL,
	[text] [varchar](50) NOT NULL,
	[confidence] [varchar](50) NOT NULL,
	[left] [int] NOT NULL,
	[top] [int] NOT NULL,
	[width] [int] NOT NULL,
	[height] [int] NOT NULL,
	[language] [varchar](50) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[OperatingExpenses]    Script Date: 25-03-2021 17:00:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OperatingExpenses]
(
	[Class] [nvarchar](max) NULL,
	[Country] [nvarchar](max) NULL,
	[Function Summary] [nvarchar](max) NULL,
	[Line Item] [nvarchar](max) NULL,
	[P&L Classification] [nvarchar](max) NULL,
	[VTB (%)] [nvarchar](max) NULL,
	[Actual ($)] [nvarchar](max) NULL,
	[Budget ($)] [nvarchar](max) NULL,
	[VTB ($)] [nvarchar](max) NULL,
	[YoY ($)] [nvarchar](max) NULL,
	[Channel] [nvarchar](max) NULL,
	[Region] [nvarchar](max) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

/****** Object:  Table [dbo].[Sales]    Script Date: 25-03-2021 17:04:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Sales]
(
	[Fiscal Year] [nvarchar](max) NULL,
	[Fiscal Quarter] [nvarchar](max) NULL,
	[Fiscal Month] [nvarchar](max) NULL,
	[Country] [nvarchar](max) NULL,
	[Region] [nvarchar](max) NULL,
	[Customer Segment] [nvarchar](max) NULL,
	[Channel] [nvarchar](max) NULL,
	[Product] [nvarchar](max) NULL,
	[Product Category] [nvarchar](max) NULL,
	[Gross Sales] [nvarchar](max) NULL,
	[Budget] [nvarchar](max) NULL,
	[Forecast] [nvarchar](max) NULL,
	[Discount] [nvarchar](max) NULL,
	[Net Sales] [nvarchar](max) NULL,
	[COGS] [nvarchar](max) NULL,
	[Gross Profit] [nvarchar](max) NULL,
	[Half Yearly] [nvarchar](max) NULL,
	[VTB ($)] [nvarchar](max) NULL,
	[VTB (%)] [nvarchar](max) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

/****** Object:  Table [dbo].[SalesVsExpense]    Script Date: 25-03-2021 17:06:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SalesVsExpense]
(
	[Accounting Head] [varchar](5000) NULL,
	[Amount] [varchar](5000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[sentiments]    Script Date: 25-03-2021 17:12:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sentiments]
(
	[VideoId] [varchar](50) NOT NULL,
	[sentimentKey] [varchar](50) NOT NULL,
	[seenDurationRatio] [varchar](50) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[SiteSecurity]    Script Date: 25-03-2021 17:13:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SiteSecurity]
(
	[FiscalQuarter] [varchar](5000) NULL,
	[FiscalYear] [varchar](5000) NULL,
	[FiscalMonth] [varchar](5000) NULL,
	[Country] [varchar](5000) NULL,
	[Region] [varchar](5000) NULL,
	[Phase] [varchar](5000) NULL,
	[Total Vulnerabilities] [varchar](5000) NULL,
	[Total Open Vulnerabilities] [varchar](5000) NULL,
	[Status] [varchar](5000) NULL,
	[Data Classification] [varchar](5000) NULL,
	[App Scan High Risk] [varchar](5000) NULL,
	[App Scan Low Risk] [varchar](5000) NULL,
	[Host Scan high Risk] [varchar](5000) NULL,
	[Host Scan Low Risk] [varchar](5000) NULL,
	[Active Sites Not Scanned] [varchar](5000) NULL,
	[Site Status] [varchar](5000) NULL,
	[Total Vuln] [varchar](5000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO


/****** Object:  Table [dbo].[speakers]    Script Date: 25-03-2021 17:18:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[speakers]
(
	[VideoId] [varchar](50) NOT NULL,
	[Id] [int] NOT NULL,
	[name] [varchar](50) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[statistics]    Script Date: 25-03-2021 17:19:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[statistics]
(
	[VideoId] [varchar](50) NOT NULL,
	[speakerTalkToListenRatio] [varchar](50) NOT NULL,
	[speakerLongestMonolog] [varchar](50) NOT NULL,
	[speakerNumberOfFragments] [varchar](50) NOT NULL,
	[correspondenceCount] [int] NOT NULL,
	[speakerWordCount] [varchar](50) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[textualContentModeration]    Script Date: 25-03-2021 17:19:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[textualContentModeration]
(
	[VideoId] [varchar](50) NOT NULL,
	[bannedWordsCount] [int] NOT NULL,
	[bannedWordsRatio] [int] NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[thumbnails]    Script Date: 25-03-2021 17:21:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[thumbnails]
(
	[faceid] [int] NOT NULL,
	[id] [varchar](50) NOT NULL,
	[fileName] [varchar](100) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [faceid] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[topics]    Script Date: 25-03-2021 17:21:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[topics]
(
	[VideoId] [varchar](50) NOT NULL,
	[aiptcName] [varchar](50) NOT NULL,
	[iabName] [varchar](50) NOT NULL,
	[confidence] [varchar](50) NOT NULL,
	[id] [int] NOT NULL,
	[name] [varchar](50) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[transcript]    Script Date: 25-03-2021 17:22:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[transcript]
(
	[VideoId] [varchar](50) NOT NULL,
	[aid] [int] NULL,
	[text] [varchar](4000) NULL,
	[confidence] [varchar](50) NULL,
	[speakerId] [int] NULL,
	[language] [varchar](50) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[Travel_Entertainment]    Script Date: 25-03-2021 17:23:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Travel_Entertainment]
(
	[Completion Date] [nvarchar](max) NULL,
	[Month] [nvarchar](max) NULL,
	[Audit Status] [nvarchar](max) NULL,
	[Country] [nvarchar](max) NULL,
	[Status Description] [nvarchar](max) NULL,
	[Region] [nvarchar](max) NULL,
	[Serious Failed] [nvarchar](max) NULL,
	[Serious Failed Expenses] [nvarchar](max) NULL,
	[Function Summary] [nvarchar](max) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

/****** Object:  Table [dbo].[TwitterRawData]    Script Date: 25-03-2021 17:24:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TwitterRawData]
(
	[TwitterData] [varchar](5000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[videos]    Script Date: 25-03-2021 17:24:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[videos]
(
	[VideoId] [varchar](50) NOT NULL,
	[accountId] [varchar](50) NOT NULL,
	[id] [varchar](50) NOT NULL,
	[state] [varchar](50) NOT NULL,
	[moderationState] [varchar](50) NOT NULL,
	[reviewState] [varchar](50) NOT NULL,
	[privacyMode] [varchar](50) NOT NULL,
	[processingProgress] [varchar](50) NOT NULL,
	[failureCode] [varchar](50) NOT NULL,
	[failureMessage] [varchar](50) NOT NULL,
	[version] [varchar](50) NOT NULL,
	[duration] [varchar](50) NOT NULL,
	[sourceLanguage] [varchar](50) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [VideoId] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

/****** Object:  Table [dbo].[VTBByChannel]    Script Date: 25-03-2021 17:25:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[VTBByChannel]
(
	[Amount] [nvarchar](max) NULL,
	[VTB ($) by channel] [nvarchar](max) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AudienceAnalyticsGeneralKPIs]
( 
	[Content] [nvarchar](max)  NULL,
	[Before] [nvarchar](max)  NULL,
	[After] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BrandRecognitionDistribution]
( 
	[AfterChurnRatio] [nvarchar](max)  NULL,
	[BeforeChurnRatio] [nvarchar](max)  NULL,
	[AfterRevenue] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Margin]
( 
	[Month] [nvarchar](max)  NULL,
	[Margin rate] [nvarchar](max)  NULL,
	[Margin rate After] [nvarchar](max)  NULL,
	[MonthT] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MonthlyMargin]
( 
	[RecordedForMonth] [nvarchar](max)  NULL,
	[NetMargin] [nvarchar](max)  NULL,
	[SequenceNumber] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Rolling7DaysSession]
( 
	[RecordedOn] [nvarchar](max)  NULL,
	[BeforeSessionsCount] [nvarchar](max)  NULL,
	[AfterSessionsCount] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RegionalViewershipDistribution]
( 
	[Region] [nvarchar](max)  NULL,
	[Viewership] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Rolling7DaysUniqueSession]
( 
	[RecordedOn] [nvarchar](max)  NULL,
	[AfterSessionCount] [nvarchar](max)  NULL,
	[BeforeSessionCount] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Rolling7DaysViewership]
( 
	[RecordedOn] [nvarchar](max)  NULL,
	[AfterViewers] [nvarchar](max)  NULL,
	[BeforeViewers] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[VideoCategoriesDistribution]
( 
	[CategoryName] [nvarchar](max)  NULL,
	[Before] [nvarchar](max)  NULL,
	[After] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ViewershipTrend]
( 
	[RecordedOn] [nvarchar](max)  NULL,
	[AfterViewershipCount] [nvarchar](max)  NULL,
	[BeforeViewershipCount] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Confirm DDM] AS 
SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function  
FROM sys.masked_columns AS c  
JOIN sys.tables AS tbl   ON c.[object_id] = tbl.[object_id]  WHERE 
is_masked = 1 and tbl.name='CustomerInfo';

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Sp_MediaRLS] AS 
Begin	
	-- After creating the users, read access is provided to all three users on Media-FactSales table
	GRANT SELECT ON [Media-FactSales] TO MediaAdministrator, ReporterMiami, ReporterLosAngeles;  

	IF EXISts (SELECT 1 FROM sys.security_predicates sp where sp.predicate_definition='([Security].[fn_securitypredicate]([SalesRep]))')
	BEGIN
		DROP SECURITY POLICY SalesFilter;
		DROP FUNCTION Security.fn_securitypredicate;
	END
	
	IF  EXISTS (SELECT * FROM sys.schemas where name='Security')
	BEGIN	
	DROP SCHEMA Security;
	End
	
	/* Moving ahead, we Create a new schema, and an inline table-valued function. 
	The function returns 1 when a row in the SalesRep column is the same as the user executing the query (@SalesRep = USER_NAME())
	or if the user executing the query is the Manager user (USER_NAME() = 'MediaAdministrator').
	*/
end