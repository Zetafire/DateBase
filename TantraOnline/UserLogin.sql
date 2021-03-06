USE [UserLogin]
GO
/****** Object:  Table [dbo].[FanArt]    Script Date: 09/21/2014 18:02:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FanArt](
	[FanID] [int] IDENTITY(1,1) NOT NULL,
	[AccountID] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[ImgName] [varchar](50) NULL,
	[ImgBin] [image] NULL,
	[ImgTmbBin] [image] NULL,
	[ImgContentType] [varchar](50) NULL,
	[DateSubmitted] [datetime] NULL,
	[Approved] [bit] NULL,
 CONSTRAINT [PK_FanArt] PRIMARY KEY CLUSTERED 
(
	[FanID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Email_temp]    Script Date: 09/21/2014 18:02:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Email_temp](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Email] [varchar](255) NULL,
	[clave] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[dt_verstamp007]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	This procedure returns the version number of the stored
**    procedures used by the the Microsoft Visual Database Tools.
**	Version is 7.0.05.
*/
create procedure [dbo].[dt_verstamp007]
as
	select 7005
GO
/****** Object:  StoredProcedure [dbo].[dt_verstamp006]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	This procedure returns the version number of the stored
**    procedures used by legacy versions of the Microsoft
**	Visual Database Tools.  Version is 7.0.00.
*/
create procedure [dbo].[dt_verstamp006]
as
	select 7000
GO
/****** Object:  StoredProcedure [dbo].[dt_vcsenabled]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_vcsenabled]

as

set nocount on

declare @iObjectId int
select @iObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

    declare @iReturn int
    exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 raiserror('', 16, -1) /* Can't Load Helper DLLC */
GO
/****** Object:  StoredProcedure [dbo].[FanArtGetImageAdmin]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[FanArtGetImageAdmin]
	@FanId 	AS INT,
	@Fld AS VARCHAR(50),
	@Approved AS INT 
AS
SET NOCOUNT ON
IF @Approved = 0
	EXEC ('SELECT FanID, ImgName, '+ @Fld +', ImgContentType FROM FanArt WITH (NOLOCK) WHERE FanId = '+@FanId)
ELSE
	EXEC ('SELECT FanID, ImgName, '+ @Fld +', ImgContentType FROM FanArt WITH (NOLOCK) WHERE Approved = 1 AND FanId = '+@FanId)
GO
/****** Object:  StoredProcedure [dbo].[FanArtGetImage]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[FanArtGetImage]
	@FanId 	AS INT,
	@Fld AS VARCHAR(50)

AS
SET NOCOUNT ON
EXEC ('SELECT FanID, ImgName, '+ @Fld +', ImgContentType FROM FanArt WITH (NOLOCK) WHERE Approved = 1 AND FanId = '+@FanId)
GO
/****** Object:  Table [dbo].[gametbl]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[gametbl](
	[Gamelogin] [varchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GameLogin_temp]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GameLogin_temp](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[UserID] [nvarchar](50) NOT NULL,
	[IP] [nvarchar](15) NOT NULL,
	[LogDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[dt_displayoaerror]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dt_displayoaerror]
    @iObject int,
    @iresult int
as

set nocount on

declare @vchOutput      varchar(255)
declare @hr             int
declare @vchSource      varchar(255)
declare @vchDescription varchar(255)

    exec @hr = master.dbo.sp_OAGetErrorInfo @iObject, @vchSource OUT, @vchDescription OUT

    select @vchOutput = @vchSource + ': ' + @vchDescription
    raiserror (@vchOutput,16,-1)

    return
GO
/****** Object:  StoredProcedure [dbo].[dt_setpropertybyid]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	If the property already exists, reset the value; otherwise add property
**		id -- the id in sysobjects of the object
**		property -- the name of the property
**		value -- the text value of the property
**		lvalue -- the binary value of the property (image)
*/
create procedure [dbo].[dt_setpropertybyid]
	@id int,
	@property varchar(64),
	@value varchar(255),
	@lvalue image
as
	set nocount on
	declare @uvalue nvarchar(255) 
	set @uvalue = convert(nvarchar(255), @value) 
	if exists (select * from dbo.dtproperties 
			where objectid=@id and property=@property)
	begin
		--
		-- bump the version count for this row as we update it
		--
		update dbo.dtproperties set value=@value, uvalue=@uvalue, lvalue=@lvalue, version=version+1
			where objectid=@id and property=@property
	end
	else
	begin
		--
		-- version count is auto-set to 0 on initial insert
		--
		insert dbo.dtproperties (property, objectid, value, uvalue, lvalue)
			values (@property, @id, @value, @uvalue, @lvalue)
	end
GO
/****** Object:  StoredProcedure [dbo].[dt_getpropertiesbyid_vcs]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[dt_getpropertiesbyid_vcs]
    @id       int,
    @property varchar(64),
    @value    varchar(255) = NULL OUT

as

    set nocount on

    select @value = (
        select value
                from dbo.dtproperties
                where @id=objectid and @property=property
                )
GO
/****** Object:  StoredProcedure [dbo].[dt_getpropertiesbyid_u]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	Retrieve properties by id's
**
**	dt_getproperties objid, null or '' -- retrieve all properties of the object itself
**	dt_getproperties objid, property -- retrieve the property specified
*/
create procedure [dbo].[dt_getpropertiesbyid_u]
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '')
		select property, version, uvalue, lvalue
			from dbo.dtproperties
			where  @id=objectid
	else
		select property, version, uvalue, lvalue
			from dbo.dtproperties
			where  @id=objectid and @property=property
GO
/****** Object:  StoredProcedure [dbo].[dt_getpropertiesbyid]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	Retrieve properties by id's
**
**	dt_getproperties objid, null or '' -- retrieve all properties of the object itself
**	dt_getproperties objid, property -- retrieve the property specified
*/
create procedure [dbo].[dt_getpropertiesbyid]
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '')
		select property, version, value, lvalue
			from dbo.dtproperties
			where  @id=objectid
	else
		select property, version, value, lvalue
			from dbo.dtproperties
			where  @id=objectid and @property=property
GO
/****** Object:  StoredProcedure [dbo].[dt_getobjwithprop_u]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	Retrieve the owner object(s) of a given property
*/
create procedure [dbo].[dt_getobjwithprop_u]
	@property varchar(30),
	@uvalue nvarchar(255)
as
	set nocount on

	if (@property is null) or (@property = '')
	begin
		raiserror('Must specify a property name.',-1,-1)
		return (1)
	end

	if (@uvalue is null)
		select objectid id from dbo.dtproperties
			where property=@property

	else
		select objectid id from dbo.dtproperties
			where property=@property and uvalue=@uvalue
GO
/****** Object:  StoredProcedure [dbo].[dt_getobjwithprop]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	Retrieve the owner object(s) of a given property
*/
create procedure [dbo].[dt_getobjwithprop]
	@property varchar(30),
	@value varchar(255)
as
	set nocount on

	if (@property is null) or (@property = '')
	begin
		raiserror('Must specify a property name.',-1,-1)
		return (1)
	end

	if (@value is null)
		select objectid id from dbo.dtproperties
			where property=@property

	else
		select objectid id from dbo.dtproperties
			where property=@property and value=@value
GO
/****** Object:  StoredProcedure [dbo].[dt_generateansiname]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
**	Generate an ansi name that is unique in the dtproperties.value column 
*/ 
create procedure [dbo].[dt_generateansiname](@name varchar(255) output) 
as 
	declare @prologue varchar(20) 
	declare @indexstring varchar(20) 
	declare @index integer 
 
	set @prologue = 'MSDT-A-' 
	set @index = 1 
 
	while 1 = 1 
	begin 
		set @indexstring = cast(@index as varchar(20)) 
		set @name = @prologue + @indexstring 
		if not exists (select value from dtproperties where value = @name) 
			break 
		 
		set @index = @index + 1 
 
		if (@index = 10000) 
			goto TooMany 
	end 
 
Leave: 
 
	return 
 
TooMany: 
 
	set @name = 'DIAGRAM' 
	goto Leave
GO
/****** Object:  StoredProcedure [dbo].[dt_dropuserobjectbyid]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	Drop an object from the dbo.dtproperties table
*/
create procedure [dbo].[dt_dropuserobjectbyid]
	@id int
as
	set nocount on
	delete from dbo.dtproperties where objectid=@id
GO
/****** Object:  StoredProcedure [dbo].[dt_droppropertiesbyid]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	Drop one or all the associated properties of an object or an attribute 
**
**	dt_dropproperties objid, null or '' -- drop all properties of the object itself
**	dt_dropproperties objid, property -- drop the property
*/
create procedure [dbo].[dt_droppropertiesbyid]
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '')
		delete from dbo.dtproperties where objectid=@id
	else
		delete from dbo.dtproperties 
			where objectid=@id and property=@property
GO
/****** Object:  StoredProcedure [dbo].[dt_adduserobject_vcs]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[dt_adduserobject_vcs]
    @vchProperty varchar(64)

as

set nocount on

declare @iReturn int
    /*
    ** Create the user object if it does not exist already
    */
    begin transaction
        select @iReturn = objectid from dbo.dtproperties where property = @vchProperty
        if @iReturn IS NULL
        begin
            insert dbo.dtproperties (property) VALUES (@vchProperty)
            update dbo.dtproperties set objectid=@@identity
                    where id=@@identity and property=@vchProperty
            select @iReturn = @@identity
        end
    commit
    return @iReturn
GO
/****** Object:  StoredProcedure [dbo].[dt_adduserobject]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	Add an object to the dtproperties table
*/
create procedure [dbo].[dt_adduserobject]
as
	set nocount on
	/*
	** Create the user object if it does not exist already
	*/
	begin transaction
		insert dbo.dtproperties (property) VALUES ('DtgSchemaOBJECT')
		update dbo.dtproperties set objectid=@@identity 
			where id=@@identity and property='DtgSchemaOBJECT'
	commit
	return @@identity
GO
/****** Object:  StoredProcedure [dbo].[dnn_GetTantraNews]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dnn_GetTantraNews]

@Type INT,
@NumberOfResults INT

AS

DECLARE @SSQL AS NVARCHAR(1000)

SET @SSQL = 'SELECT TOP ' + CAST(@NumberOfResults AS NVARCHAR) + ' NewsID, Title, Body, DateAdded, GroupID, Display FROM NewsItem WITH (NOLOCK) WHERE GroupID = ' + CAST(@Type AS NVARCHAR) + ' AND Display = 1 ORDER BY DateAdded DESC'
EXEC(@SSQL)
GO
/****** Object:  Table [dbo].[DiyanaBanAct]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DiyanaBanAct](
	[COL1] [nvarchar](255) NULL,
	[USERID] [nvarchar](255) NULL,
	[Col2] [nvarchar](255) NULL,
	[Col3] [nvarchar](255) NULL,
	[Character] [nvarchar](255) NULL,
	[Col4] [nvarchar](255) NULL,
	[Col5] [float] NULL,
	[Col6] [nvarchar](255) NULL,
	[Col7] [float] NULL,
	[Col8] [float] NULL,
	[Col9] [float] NULL,
	[Col10] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BugReport]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BugReport](
	[BugId] [int] IDENTITY(1,1) NOT NULL,
	[AccountID] [int] NULL,
	[Description] [varchar](3000) NULL,
	[ImgName1] [nvarchar](50) NULL,
	[ImgBin1] [image] NULL,
	[ImgTmbBin1] [image] NULL,
	[ImgContentType1] [varchar](50) NULL,
	[ImgName2] [varchar](50) NULL,
	[ImgBin2] [image] NULL,
	[ImgTmbBin2] [image] NULL,
	[ImgContentType2] [varchar](50) NULL,
	[ImgName3] [varchar](50) NULL,
	[ImgBin3] [image] NULL,
	[ImgTmbBin3] [image] NULL,
	[ImgContentType3] [nvarchar](50) NULL,
	[DateSubmitted] [datetime] NULL,
	[Fixed] [bit] NULL,
	[Qualified] [smallint] NULL,
	[ActionTime] [datetime] NULL,
 CONSTRAINT [PK_BugReport] PRIMARY KEY CLUSTERED 
(
	[BugId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[BugGetReport]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[BugGetReport]
	@BugId 	AS INT,
	@Fld		AS VARCHAR(50),
	@ContentType   AS VARCHAR(50)
AS
SET NOCOUNT ON

EXEC ('SELECT '+ @ContentType +' , '+ @Fld 
	+' FROM BugReport WITH (NOLOCK) WHERE BugId = '+ @BugId)
GO
/****** Object:  Table [dbo].[Candidate]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Candidate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Candidate] [nvarchar](50) NOT NULL,
	[Server] [nvarchar](50) NOT NULL,
	[GMPercent] [int] NULL,
 CONSTRAINT [PK_Candidate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_Candidate] UNIQUE NONCLUSTERED 
(
	[Candidate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Council]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Council](
	[IDX] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](50) NOT NULL,
	[Server1] [nvarchar](50) NULL,
	[Character1] [nvarchar](50) NULL,
	[Level1] [nvarchar](3) NULL,
	[Server2] [nvarchar](50) NULL,
	[Character2] [nvarchar](50) NULL,
	[Level2] [nvarchar](3) NULL,
	[Server3] [nvarchar](50) NULL,
	[Character3] [nvarchar](50) NULL,
	[Level3] [nvarchar](3) NULL,
	[RegDate] [datetime] NULL,
	[Selected] [bit] NULL,
 CONSTRAINT [PK_Council] PRIMARY KEY CLUSTERED 
(
	[IDX] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cities]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cities](
	[ID] [int] IDENTITY(100,1) NOT NULL,
	[CityName] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Cities] PRIMARY KEY CLUSTERED 
(
	[CityName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Account_waitvip]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Account_waitvip](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [varchar](50) NULL,
	[fechareg] [datetime] NULL,
 CONSTRAINT [PK_Account_waitvip] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Account_temp]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account_temp](
	[ID] [int] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[UserID] [nvarchar](50) NULL,
	[Password] [nvarchar](70) NULL,
	[UserKey] [nvarchar](7) NULL,
	[Blocked] [tinyint] NOT NULL,
	[BlockedDate] [datetime] NULL,
	[BlockedEndDate] [datetime] NULL,
	[UnBlockedDate] [datetime] NULL,
	[SecretQuestion] [nvarchar](50) NULL,
	[Answer] [nvarchar](50) NULL,
	[Firstname] [nvarchar](30) NOT NULL,
	[MI] [nvarchar](1) NULL,
	[Lastname] [nvarchar](30) NOT NULL,
	[Birthday] [datetime] NULL,
	[Sex] [tinyint] NULL,
	[Address] [nvarchar](100) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[Country] [nvarchar](50) NULL,
	[MobileNo] [nvarchar](15) NULL,
	[HomeNo] [nvarchar](15) NULL,
	[WherePlay] [nvarchar](100) NULL,
	[InternetCon] [nvarchar](100) NULL,
	[ISPCafe] [nvarchar](100) NULL,
	[MMORPG] [nvarchar](500) NULL,
	[PowerChar] [nvarchar](500) NULL,
	[PrevExp] [nvarchar](500) NULL,
	[AboutTantra] [nvarchar](100) NULL,
	[RegIPAddress] [nvarchar](15) NULL,
	[ActivationKey] [uniqueidentifier] NOT NULL,
	[DateRegistered] [datetime] NULL,
	[Activated] [bit] NULL,
	[SMSReg] [bit] NULL,
	[CloseBeta] [bit] NULL,
	[Vote] [tinyint] NULL,
	[CreditCardPaymentErrorCount] [tinyint] NOT NULL,
	[LastCreditCardPaymentErrorDate] [datetime] NOT NULL,
	[Confirmed] [smallint] NOT NULL,
	[AllowCreditCard] [bit] NULL,
	[School] [nvarchar](50) NULL,
	[SpamMail] [tinyint] NULL,
	[RejectMail] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Account_paramx]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Account_paramx](
	[param] [varchar](20) NOT NULL,
	[valorx] [varchar](50) NULL,
 CONSTRAINT [PK_Account_paramx] PRIMARY KEY CLUSTERED 
(
	[param] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Account_ordenes]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Account_ordenes](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[user_id] [nvarchar](50) NULL,
	[order_date] [datetime] NULL,
	[order_tanys] [int] NULL,
	[last_balance] [int] NULL,
	[user_orden] [varchar](150) NULL,
 CONSTRAINT [PK_Account_ordenes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Account_fb]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Account_fb](
	[id] [nvarchar](15) NOT NULL,
	[first_name] [nvarchar](30) NULL,
	[last_name] [nvarchar](30) NULL,
	[gender] [varchar](8) NULL,
	[link] [nvarchar](50) NULL,
	[email] [nvarchar](50) NOT NULL,
	[registerdate] [datetime] NULL,
	[IP] [nvarchar](15) NULL,
	[adminlvl] [smallint] NULL,
 CONSTRAINT [PK_Account_fb] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Account]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[UserID] [nvarchar](50) NULL,
	[Password] [nvarchar](70) NULL,
	[UserKey] [nvarchar](7) NULL,
	[Blocked] [tinyint] NOT NULL,
	[BlockedDate] [datetime] NULL,
	[BlockedEndDate] [datetime] NULL,
	[UnBlockedDate] [datetime] NULL,
	[SecretQuestion] [nvarchar](50) NULL,
	[Answer] [nvarchar](50) NULL,
	[Firstname] [nvarchar](30) NOT NULL,
	[MI] [nvarchar](1) NULL,
	[Lastname] [nvarchar](30) NOT NULL,
	[Birthday] [datetime] NULL,
	[Sex] [tinyint] NULL,
	[Address] [nvarchar](100) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[Country] [nvarchar](50) NULL,
	[MobileNo] [nvarchar](15) NULL,
	[HomeNo] [nvarchar](15) NULL,
	[WherePlay] [nvarchar](100) NULL,
	[InternetCon] [nvarchar](100) NULL,
	[ISPCafe] [nvarchar](100) NULL,
	[MMORPG] [nvarchar](500) NULL,
	[PowerChar] [nvarchar](500) NULL,
	[PrevExp] [nvarchar](500) NULL,
	[AboutTantra] [nvarchar](100) NULL,
	[RegIPAddress] [nvarchar](15) NULL,
	[ActivationKey] [uniqueidentifier] NULL,
	[DateRegistered] [datetime] NULL,
	[Activated] [bit] NULL,
	[SMSReg] [bit] NULL,
	[CloseBeta] [bit] NULL,
	[Vote] [tinyint] NULL,
	[CreditCardPaymentErrorCount] [tinyint] NOT NULL,
	[LastCreditCardPaymentErrorDate] [datetime] NULL,
	[Confirmed] [smallint] NOT NULL,
	[AllowCreditCard] [bit] NULL,
	[School] [nvarchar](50) NULL,
	[SpamMail] [tinyint] NULL,
	[RejectMail] [tinyint] NULL,
	[UnsubsMail] [bit] NULL,
	[Testaccount] [bit] NULL,
	[IsUserCreated] [bit] NOT NULL,
	[Epoint] [int] NULL,
	[Admin] [smallint] NULL,
	[Bpoint] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Account_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_Account_Email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ActivationEmail_Account]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ActivationEmail_Account](
	[userId] [varchar](500) NOT NULL,
 CONSTRAINT [PK_ActivationEmail_Account] PRIMARY KEY CLUSTERED 
(
	[userId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[AdminDBReindex]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminDBReindex]  AS

declare @name as varchar(100)
declare sp cursor for 
select name from sysobjects where xtype = 'U' and status >= 0

open sp

fetch next from sp into @name
while @@fetch_status = 0
begin
	DBCC DBREINDEX (@name, '', 50)
	fetch next from sp into @name
end
close sp
deallocate sp
GO
/****** Object:  Table [dbo].[Blocked_Accounts_Details]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Blocked_Accounts_Details](
	[INDEX] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](50) NULL,
	[Email] [varchar](50) NULL,
	[ImgName1] [varchar](25) NULL,
	[Img1] [image] NULL,
	[TImg1] [image] NULL,
	[ImgCnt1] [varchar](50) NULL,
	[ImgName2] [varchar](25) NULL,
	[Img2] [image] NULL,
	[TImg2] [image] NULL,
	[ImgCnt2] [varchar](50) NULL,
	[ImgName3] [varchar](25) NULL,
	[Img3] [image] NULL,
	[TImg3] [image] NULL,
	[ImgCnt3] [varchar](50) NULL,
	[Description] [varchar](1000) NULL,
	[GMUserId] [varchar](50) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Penalty] [varchar](25) NULL,
 CONSTRAINT [PK_Blocked_Accounts_Details] PRIMARY KEY CLUSTERED 
(
	[INDEX] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BugDraw]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BugDraw](
	[IDX] [int] IDENTITY(1,1) NOT NULL,
	[BugId] [int] NOT NULL,
	[AccountID] [int] NULL,
	[UserID] [nvarchar](50) NULL,
	[DateSubmitted] [datetime] NULL,
	[Qualified] [smallint] NULL,
	[Selected] [bit] NULL,
 CONSTRAINT [PK_BugDraw] PRIMARY KEY CLUSTERED 
(
	[BugId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].['Bill_intPlayer]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].['Bill_intPlayer](
	[USERID] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BanAct]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BanAct](
	[USERID] [nvarchar](255) NOT NULL,
	[EMAIL] [nvarchar](255) NULL,
	[Sent] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[AdminSPRecompile]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* Programmer: Richard Tibang  */
CREATE PROC  [dbo].[AdminSPRecompile]  AS

declare @name as varchar(100)
declare sp cursor for 
select name from sysobjects where xtype = 'P' and status >= 0

open sp

fetch next from sp into @name
while @@fetch_status = 0
begin
	exec sp_recompile  @name
	fetch next from sp into @name
end
close sp
deallocate sp
GO
/****** Object:  Table [dbo].[AccountUpdateLog]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AccountUpdateLog](
	[Index] [bigint] IDENTITY(1,1) NOT NULL,
	[AdminUserID] [varchar](25) NOT NULL,
	[UserId] [varchar](25) NOT NULL,
	[Date] [datetime] NOT NULL,
	[PrevValue] [varchar](50) NOT NULL,
	[NewValue] [varchar](50) NOT NULL,
	[FieldChanged] [varchar](50) NOT NULL,
	[Remarks] [varchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UniversityList]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UniversityList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[UnivName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_UniversityList] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[dbNotify_DatabaseBackup]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE Proc [dbo].[dbNotify_DatabaseBackup]    
as    
/*         
   Description: Script to notify success backup via email    
   Usage: Monitoring DB Backup    
         
*/          
    
Declare @Msg nvarchar(4000)    
Declare @Date1 smalldatetime    
Declare @Priority nvarchar(10)    
Declare @Subject nvarchar(200)    
Declare @Logfile nvarchar(1000)    
    
set @Subject = 'Userlogin s: Database Full Backup Report ' + convert(nvarchar(100),getdate(), 100)    
--set @LogFile = 'E:\Backup.log'    
    
Set @Msg = '    
Dear Administrators, 
    
  Userlogin Database has been backed up successfully for @Date1.:    
    
Thank You, 
   
Webdb01 Server   /  DBA
    
NOTE: This is a system generated email, please do not reply.    
    
'    
    
    
    
set @Msg = Replace(@Msg,'@Date1',convert(datetime,getdate(),130))    
    
    
Print @Msg    
    
    
    
declare @rc int    
exec @rc = master.dbo.xp_smtp_sendmail    
    @FROM       = N'tantradb@tantra.com.ph',    
    @FROM_NAME  = N'WEBDB01 Server',    
    @replyto    = N'francis_delrosario@abs.pinoycentral.com,ryan_samaniego@abs.pinoycentral.com,allan_lacson@abs.pinoycentral.com,zosimo_carlos@abs.pinoycentral.com',
    @TO         = N'francis_delrosario@abs.pinoycentral.com,ryan_samaniego@abs.pinoycentral.com,allan_lacson@abs.pinoycentral.com,zosimo_carlos@abs.pinoycentral.com' ,       
    @CC         = N'rommel_cuya@abs.pinoycentral.com',  
    @priority   = N'Normal',    
    @subject    = @Subject ,    
    @type       = N'text/plain',    
    @message    = @Msg,    
    @attachment = @LogFile,    
    @timeout    = 10000,    
    @server     = N'203.115.180.11'
GO
/****** Object:  Table [dbo].[ManasBanAct]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ManasBanAct](
	[COL1] [nvarchar](255) NULL,
	[USERID] [nvarchar](255) NULL,
	[Col2] [nvarchar](255) NULL,
	[Col3] [nvarchar](255) NULL,
	[Character] [nvarchar](255) NULL,
	[Col4] [nvarchar](255) NULL,
	[Col5] [float] NULL,
	[Col6] [nvarchar](255) NULL,
	[Col7] [float] NULL,
	[Col8] [float] NULL,
	[Col9] [float] NULL,
	[Col10] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MailListBacolod]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailListBacolod](
	[ID] [varchar](52) NULL,
	[Email] [nvarchar](255) NULL,
	[Sent] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MailList1]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailList1](
	[id] [int] NOT NULL,
	[email] [nvarchar](50) NOT NULL,
	[sent] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MailList03012006]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailList03012006](
	[ID] [varchar](52) NULL,
	[Email] [nvarchar](255) NULL,
	[Sent] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MailList_temp]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailList_temp](
	[id] [int] NOT NULL,
	[email] [nvarchar](50) NOT NULL,
	[sent] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MailList_NAct]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailList_NAct](
	[ID] [varchar](52) NULL,
	[Email] [nvarchar](255) NULL,
	[Sent] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MailList]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailList](
	[id] [int] NOT NULL,
	[email] [nvarchar](50) NOT NULL,
	[sent] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LogGame]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogGame](
	[Registered] [varchar](255) NULL,
	[Gamelogin] [varchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[KriyaBanAct]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KriyaBanAct](
	[COL1] [nvarchar](255) NULL,
	[USERID] [nvarchar](255) NULL,
	[Col2] [nvarchar](255) NULL,
	[Col3] [nvarchar](255) NULL,
	[Character] [nvarchar](255) NULL,
	[Col4] [nvarchar](255) NULL,
	[Col5] [nvarchar](255) NULL,
	[Col6] [nvarchar](255) NULL,
	[Col7] [float] NULL,
	[Col8] [float] NULL,
	[Col9] [float] NULL,
	[Col10] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IPLookup]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IPLookup](
	[IP_From] [bigint] NULL,
	[IP_To] [bigint] NULL,
	[Country_Code2] [char](2) NULL,
	[Country_Code3] [char](3) NULL,
	[Country] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[k3a_DisableGeneratedAccounts]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[k3a_DisableGeneratedAccounts]

@prefix NVARCHAR(50),
@resultCode INT OUT

AS

DECLARE @sql AS NVARCHAR(800)
SET @resultCode = 0

SET @sql = 'UPDATE Account SET 
Blocked = 1,
BlockedDate = getdate(),
BlockedEndDate = DATEADD(YEAR, 5, getdate())
WHERE userId IN(SELECT userId FROM [203.115.180.25].K3Admin.dbo.tblCreatedUserLog
WHERE userId LIKE ''' + @prefix + '%'')'
EXEC (@sql)

IF @@ROWCOUNT > 0
BEGIN
	SET @resultCode = 1
END
GO
/****** Object:  StoredProcedure [dbo].[k3a_CheckIfPrefixExist]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[k3a_CheckIfPrefixExist]

@prefix NVARCHAR(50)

AS

DECLARE @sql AS NVARCHAR(800)


SET @sql = 'SELECT COUNT(userId) FROM Account WITH (NOLOCK) WHERE userId LIKE ''' + @prefix + '%'''

EXEC(@sql)
GO
/****** Object:  Table [dbo].[NewsItem]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NewsItem](
	[NewsID] [int] IDENTITY(1,1) NOT NULL,
	[GroupID] [int] NULL,
	[Title] [varchar](6000) NULL,
	[Body] [varchar](6000) NULL,
	[Display] [bit] NOT NULL,
	[DateAdded] [datetime] NULL,
 CONSTRAINT [PK_NewsItem] PRIMARY KEY CLUSTERED 
(
	[NewsID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NewsGroup]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsGroup](
	[GroupID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NULL,
	[ImageName] [nvarchar](50) NULL,
 CONSTRAINT [PK_NewsGroup] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[PartUpdate]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[PartUpdate]
	@ID		 	AS INT, 
	@BusinessName 	AS nvarchar (100), 
	@TypeOfBusiness 	AS nvarchar (30), 
	@Address	 	AS nvarchar (100), 
	@City	 		AS nvarchar (100), 
	@TelephoneNo	 	AS nvarchar (15), 
	@MobileNo	 	AS nvarchar (12), 
	@Email 			AS nvarchar (50), 
	@ContactPerson		AS nvarchar (50),
	@BestTimeVisit		AS nvarchar (50),
	@RegIPAddress 		AS nvarchar (15),
	@result 			AS INT OUTPUT
AS
SET @result = 0
SET NOCOUNT ON
IF EXISTS(SELECT * FROM Partner WITH(NOLOCK) WHERE ID <> @ID AND BusinessName = @BusinessName)
BEGIN
	SET @result = -101
END
ELSE --IF EXISTS(SELECT * FROM Partner WITH(NOLOCK) WHERE ID = @ID AND BusinessName = @BusinessName)
BEGIN
	
	UPDATE Partner  SET BusinessName = @BusinessName, TypeOfBusiness = @TypeOfBusiness, 
			Address = @Address, City = @City, TelephoneNo = @TelephoneNo, 
			MobileNo = @MobileNo, Email = @Email, ContactPerson = @ContactPerson,
			BestTimeVisit = @BestTimeVisit, RegIPAddress = @RegIPAddress
	WHERE [ID] = @ID
END
IF @@ERROR <> 0
		SET @result = -99 /* Unknown error while adding record */
GO
/****** Object:  StoredProcedure [dbo].[PartRegister]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PartRegister]
	@BusinessName 	AS nvarchar (100), 
	@TypeOfBusiness 	AS nvarchar (30), 
	@Address	 	AS nvarchar (100), 
	@City	 		AS nvarchar (100), 
	@TelephoneNo	 	AS nvarchar (15), 
	@MobileNo	 	AS nvarchar (12), 
	@Email 			AS nvarchar (50), 
	@ContactPerson		AS nvarchar (50),
	@BestTimeVisit		AS nvarchar (50),
	@RegIPAddress 		AS nvarchar (15),
	@result 			AS INT OUTPUT
AS
SET @result = 0
SET NOCOUNT ON
IF NOT EXISTS(SELECT * FROM Partner WITH(NOLOCK) WHERE BusinessName = @BusinessName)
BEGIN
	
	INSERT INTO Partner (BusinessName, TypeOfBusiness, Address, City, TelephoneNo, 
			MobileNo, Email, ContactPerson, BestTimeVisit, RegIPAddress)
	VALUES (@BusinessName, @TypeOfBusiness, @Address, @City, @TelephoneNo, 
			@MobileNo, @Email, @ContactPerson, @BestTimeVisit, @RegIPAddress)
	IF @@ERROR <>0
		SET @result = -99 /* Unknown error while adding record */
END
ELSE
BEGIN 
	SET @result = -1
END
GO
/****** Object:  StoredProcedure [dbo].[PartPagedSelectedItems]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[PartPagedSelectedItems]
	(
	 @Page int,
	 @RecsPerPage int,
	 @City AS NVARCHAR(100)
	)
AS
-- We don't want to return the # of rows inserted
-- into our temporary table, so turn NOCOUNT ON
SET NOCOUNT ON

--Create a temporary table
CREATE TABLE #TempItems
(
	ID int IDENTITY,
	PartID INT,
	BusinessName varchar(100),
	TypeOfBusiness varchar(30),
	Address varchar(100),
	City varchar(100),
	TelephoneNo varchar(15),
	MobileNo varchar(12),
	Email varchar(50),
	ContactPerson varchar(50),
	BestTimeVisit varchar(50),
	DateReg DATETIME,
	Status int,
	DisplayToWebsite int
)

-- Insert the rows from tblItems into the temp. table
IF @City = 'All' --Select all 
BEGIN
	INSERT INTO #TempItems (PartID, BusinessName, TypeOfBusiness, Address, City, TelephoneNo, 
			MobileNo, Email, ContactPerson, BestTimeVisit, DateReg, Status, DisplayToWebsite)
	
	SELECT [ID] AS PartID, BusinessName, TypeOfBusiness, Address, City, TelephoneNo, 
			MobileNo, Email, ContactPerson, BestTimeVisit, DateReg, Status, DisplayToWebsite
	FROM Partner   order by [Id] DESC
END
ELSE
BEGIN
	INSERT INTO #TempItems (PartID, BusinessName, TypeOfBusiness, Address, City, TelephoneNo, 
			MobileNo, Email, ContactPerson, BestTimeVisit, DateReg, Status, DisplayToWebsite)
	
	SELECT [ID] AS PartID, BusinessName, TypeOfBusiness, Address, City, TelephoneNo, 
			MobileNo, Email, ContactPerson, BestTimeVisit, DateReg, Status, DisplayToWebsite
	FROM Partner   
	WHERE City = @City
	order by [Id] DESC
END

-- Find out the first and last record we want
DECLARE @FirstRec int, @LastRec int
SELECT @FirstRec = (@Page - 1) * @RecsPerPage
SELECT @LastRec = (@Page * @RecsPerPage + 1)

-- Now, return the set of paged records, plus, an indication of we
-- have more records or not!
SELECT *,
       MoreRecords = 
	(
	 SELECT COUNT(*) 
	 FROM #TempItems TI
	 WHERE TI.ID >= @LastRec
	) 
FROM #TempItems
WHERE ID > @FirstRec AND ID < @LastRec
GO
/****** Object:  StoredProcedure [dbo].[PartGetPartner]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[PartGetPartner]
	@ID AS INT,
	@BusinessName 	AS nvarchar (100) OUTPUT, 
	@TypeOfBusiness	AS nvarchar (30) OUTPUT,
	@Address		AS nvarchar (100) OUTPUT,
	@City			AS nvarchar (100) OUTPUT,
	@TelephoneNo		AS nvarchar (15) OUTPUT,
	@MobileNo		AS nvarchar (12) OUTPUT,
	@Email			AS nvarchar (50) OUTPUT,		
	@ContactPerson		AS nvarchar (50) OUTPUT,
	@BestTimeVisit		AS nvarchar (50) OUTPUT,
	@DateReg		AS DATETIME OUTPUT,
	@RegIPAddress		AS nvarchar (15) OUTPUT,
	@Status			AS INT  OUTPUT,
	@result			AS INT  OUTPUT
AS
SET NOCOUNT ON
SET @result  = 0
SELECT @BusinessName 	= BusinessName,
	@TypeOfBusiness 	= TypeOfBusiness,
	@Address	= Address,
	@City 		= City,
	@TelephoneNo 	= TelephoneNo,
	@MobileNo	= MobileNo,
	@Email		= Email,
	@ContactPerson = ContactPerson,
	@BestTimeVisit  = BestTimeVisit,
	@DateReg	= DateReg,
	@RegIPAddress	= RegIPAddress,
	@Status		= Status
FROM Partner WITH(NOLOCK) WHERE ID = @ID
IF @@ROWCOUNT <=  0
	SET @result = -99
GO
/****** Object:  StoredProcedure [dbo].[PartGetAllPartners]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[PartGetAllPartners]
	@City AS NVARCHAR(100)
AS
IF (@City = 'All')
	SELECT * FROM Partner WITH(NOLOCK)
ELSE 
	SELECT * FROM Partner WITH(NOLOCK) WHERE City = @City
GO
/****** Object:  StoredProcedure [dbo].[PartAction]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[PartAction]
	@Id 	AS INT,
	@Status 	AS INT
AS
SET NOCOUNT ON
UPDATE Partner SET Status = @Status, ActionTime = GETDATE() WHERE ID  = @Id
GO
/****** Object:  Table [dbo].[tblUserExceptions]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserExceptions](
	[userId] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tblUserExceptions] PRIMARY KEY CLUSTERED 
(
	[userId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbluser520]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbluser520](
	[UserID] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblProduct]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblProduct](
	[PID] [int] IDENTITY(1,1) NOT NULL,
	[productId] [int] NOT NULL,
	[productName] [varchar](100) NOT NULL,
	[productAmount] [int] NOT NULL,
	[productTypeId] [int] NOT NULL,
	[Display] [tinyint] NOT NULL,
 CONSTRAINT [PK_tblProductInfo] PRIMARY KEY CLUSTERED 
(
	[productId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_tblProduct_2] UNIQUE NONCLUSTERED 
(
	[PID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TantraMoney]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TantraMoney](
	[World] [tinyint] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Money] [bigint] NOT NULL,
 CONSTRAINT [PK_TantraMoney] PRIMARY KEY CLUSTERED 
(
	[World] ASC,
	[Date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmptbl]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmptbl](
	[USERID] [nvarchar](255) NULL,
	[AMOUNT] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].['tmpDecLog']    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].['tmpDecLog'](
	[USERID] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpBanAct]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpBanAct](
	[USERID] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[reactivationLog]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[reactivationLog](
	[rId] [int] IDENTITY(1,1) NOT NULL,
	[userId] [nvarchar](50) NULL,
	[reactivationTime] [datetime] NOT NULL,
 CONSTRAINT [PK_reactivationLog] PRIMARY KEY CLUSTERED 
(
	[rId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[dnn_GetUserTopUpTransactions]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dnn_GetUserTopUpTransactions]

@UserID NVARCHAR(50)

AS

EXEC [203.115.180.23].BillCrux_Phil.dbo.procGetUserTopupTransaction @UserID
GO
/****** Object:  StoredProcedure [dbo].[dnn_GetUserTotalTopupByMonth]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dnn_GetUserTotalTopupByMonth]

@UserID NVARCHAR(50),
@Month INT,
@Year INT,
@TopUpAmount INT OUT

AS

SET @TopUpAmount = 0

EXEC [203.115.180.23].BillCrux_Phil.dbo.procGetUserTopUpTotalByMonth @UserID, @Month, @Year, @TopUpAmount OUTPUT
GO
/****** Object:  StoredProcedure [dbo].[dnn_GetUserPurchaseTransactions]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dnn_GetUserPurchaseTransactions]

@UserID NVARCHAR(50)

AS

DECLARE @cpId  AS INT
DECLARE @startDt AS DATETIME
DECLARE @endDt AS DATETIME

SET @cpId = 1
SET @startDt = '2006-05-01 00:00:00'
SET @endDt = getdate()

EXEC [203.115.180.23].BillCrux_Phil.dbo.procGetUserPurchaseTransaction @UserID, @cpId, @startDt, @endDt
GO
/****** Object:  StoredProcedure [dbo].[dnn_GetUserCashBalance]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dnn_GetUserCashBalance]

@UserID NVARCHAR(50)

AS

EXEC [203.115.180.23].BillCrux_Phil.dbo.procGetUserBalanceOnly @UserID
GO
/****** Object:  StoredProcedure [dbo].[dnn_GetUserGameTime]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dnn_GetUserGameTime]

@UserID NVARCHAR(50),
@GameServiceId SMALLINT

AS

IF @GameServiceId IS NULL
BEGIN
	SET @GameServiceId = 1
END


EXEC [203.115.180.23].BillCrux_Phil.dbo.procGetGameServiceInfo @UserID, @GameServiceId
GO
/****** Object:  StoredProcedure [dbo].[GetBlockEvidenceImg]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[GetBlockEvidenceImg]
	@INDEX 	AS INT,
	@Fld		AS VARCHAR(50),
	@ContentType   AS VARCHAR(50)
AS
SET NOCOUNT ON

EXEC ('SELECT '+ @ContentType +' , '+ @Fld 
	+' FROM Blocked_Accounts_Details WITH (NOLOCK) WHERE [INDEX] = '+ @INDEX)
GO
/****** Object:  StoredProcedure [dbo].[k3a_GetUsersWithPrefix]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[k3a_GetUsersWithPrefix]

@prefix NVARCHAR(50)

AS

DECLARE @sql AS NVARCHAR(800)


SET @sql = 'SELECT userId, [Password], userKey FROM Account WITH (NOLOCK) WHERE userId LIKE ''' + @prefix + '%'''

EXEC(@sql)
GO
/****** Object:  Table [dbo].[SamadiBanAct]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SamadiBanAct](
	[COL1] [nvarchar](255) NULL,
	[USERID] [nvarchar](255) NULL,
	[Col2] [nvarchar](255) NULL,
	[Col3] [nvarchar](255) NULL,
	[Character] [nvarchar](255) NULL,
	[Col4] [nvarchar](255) NULL,
	[Col5] [float] NULL,
	[Col6] [nvarchar](255) NULL,
	[Col7] [float] NULL,
	[Col8] [float] NULL,
	[Col9] [float] NULL,
	[Col10] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Regtbl]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Regtbl](
	[Registerd] [varchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[RegistrationPerArea_sp]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[RegistrationPerArea_sp]
@Date1 datetime,
@date2 datetime

 AS

SELECT     city,COUNT(*) Num_rec
FROM         Account
WHERE     (DateRegistered BETWEEN @Date1 AND @Date2)
group by city
order by city
GO
/****** Object:  StoredProcedure [dbo].[k3a_GetBlockedAccounts]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[k3a_GetBlockedAccounts]

AS

SELECT UserId, Blocked, BlockedDate, BlockedEndDate FROM Account WITH (NOLOCK)
WHERE Blocked = 1
ORDER BY UserId DESC
GO
/****** Object:  StoredProcedure [dbo].[getAllBlocked]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*CREATE PROCEDURE [OWNER].[PROCEDURE NAME] AS


CREATE PROCEDURE AccountGetBlockedStatus
	@ID 			AS INT,
	@Blocked		AS INT OUTPUT,
	@BlockedEndDate	AS DATETIME OUTPUT
AS
SET NOCOUNT ON

SELECT @Blocked = Blocked, @BlockedEndDate = BlockedEndDate FROM Account WHERE [ID] = @ID
GO
*/


CREATE PROCEDURE [dbo].[getAllBlocked]
               @blocked as int,
               @userid  as nvarchar(50) output,
               @email as nvarchar(50) output,
               @firstname as nvarchar(30) output,
               @mi as nvarchar(1) output,
               @lastname as nvarchar(30) output,
               @blockeddate as datetime output,
               @blockedenddate as datetime output,
               @address as nvarchar(100) output,
               @city as nvarchar(50) output,
               @country as nvarchar(50) output,
               @regipaddress as nvarchar(15) output,
               @dateregistered as datetime output
AS
SET NOCOUNT ON


SELECT @userid=userid, @email=email, @firstname=firstname, @mi=mi, @lastname=lastname,  @blockeddate=blockeddate, @blockedenddate=blockedenddate, @address=address, @city=city,  @country=country, @regipaddress=regipaddress, @dateregistered=dateregistered FROM Account WHERE 
[blocked] = @blocked
GO
/****** Object:  StoredProcedure [dbo].[PRM_logReactivatedUser]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRM_logReactivatedUser]

@userId VARCHAR(50)

AS

INSERT INTO reactivationLog(userID) VALUES(@userId)
GO
/****** Object:  StoredProcedure [dbo].[prm_GetUserId]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[prm_GetUserId]

@key VARCHAR(1000),
@resultCode INT OUT,
@userId NVARCHAR(50) OUT

AS

DECLARE @akey UNIQUEIDENTIFIER

SET @akey = CAST(RTRIM(LTRIM(@key)) AS UNIQUEIDENTIFIER)

SET @resultCode = 0

SELECT @userId = userId
FROM Account WITH (NOLOCK)
WHERE ActivationKey = @key

IF @@ROWCOUNT = 1
BEGIN
	SET @resultCode = 1
END
GO
/****** Object:  StoredProcedure [dbo].[tcrm_UpdateProfile]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[tcrm_UpdateProfile]

@UserID NVARCHAR(50),
@SecretQuestion NVARCHAR(50),
@Answer NVARCHAR(50),
@FirstName NVARCHAR(30),
@MI NVARCHAR(1),
@LastName NVARCHAR(30),
@Birthday DATETIME,
@Sex TINYINT,
@Address NVARCHAR(100),
@City NVARCHAR(50),
@State NVARCHAR(50),
@Country NVARCHAR(50),
@MobileNo NVARCHAR(15),
@HomeNo NVARCHAR(15),
@returnCode INT OUT

AS

SET @returnCode = 0

UPDATE Account
SET 	SecretQuestion 	= @SecretQuestion,
	Answer 		= @Answer,
	FirstName	= @FirstName,
	MI		= @MI,
	LastName	= @LastName,
	Birthday		= @Birthday,
	Sex		= @Sex,
	Address		= @Address,
	City		= @City,
	State		= @State,
	Country		= @Country,
	MobileNo	= @MobileNo,
	HomeNo	= @HomeNo
WHERE UserID = @UserID

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SET @returnCode = 1
END
GO
/****** Object:  StoredProcedure [dbo].[tcrm_GetProfile]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[tcrm_GetProfile]

@UserID NVARCHAR(50)

AS

SELECT UserID, Email, [Password], UserKey, Blocked, BlockedDate, BlockedEndDate, UnblockedDate,SecretQuestion,
	 Answer, FirstName, MI, LastName, Birthday, Sex, Address, City, State, Country, MobileNo, HomeNo, Activated,
	 ActivationKey, RegIPAddress, DateRegistered
FROM Account WITH (NOLOCK)
WHERE UserID = @UserID
GO
/****** Object:  StoredProcedure [dbo].[TantraGameLogin_noblocked]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[TantraGameLogin_noblocked]
	@UserId	AS NVARCHAR(50),
	@Password	AS NVARCHAR(70)  OUTPUT,
	@ID		AS INT 		      OUTPUT,
	@UserKey	AS NVARCHAR(7)    OUTPUT,
	@Email		AS NVARCHAR(50)  OUTPUT,
	@result 		AS INT 		     OUTPUT
AS

IF EXISTS (SELECT * FROM Account WITH (NOLOCK) WHERE UserId = @UserId AND Activated = 1  AND Blocked = 0 )
BEGIN	
	SELECT @Password = [Password], @ID = [ID], @UserKey = UserKey, @Email = Email
	FROM Account WITH (NOLOCK) WHERE UserId = @UserId
	SET @result  = 0
END
ELSE
BEGIN
	SET @result = -99 --Invalid userid, or not yet activated 
END
GO
/****** Object:  StoredProcedure [dbo].[TantraGameLogin]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[TantraGameLogin]
	@UserId	AS NVARCHAR(50),
	@Password	AS NVARCHAR(70)  OUTPUT,
	@ID		AS INT 		      OUTPUT,
	@UserKey	AS NVARCHAR(7)    OUTPUT,
	@Email		AS NVARCHAR(50)  OUTPUT,
	@result 		AS INT 		     OUTPUT
AS
SET NOCOUNT ON
declare @isUserCreated as bit
DECLARE @BlockedEndDate DATETIME, @NoOfDaysBlocked INT
IF EXISTS (SELECT * FROM Account WITH (NOLOCK) WHERE UserId = @UserId AND Activated = 1  )
BEGIN	
	SELECT @isUserCreated=isUserCreated,@Password = [Password], @ID = [ID], @UserKey = UserKey, @Email = Email, @BlockedEndDate= BlockedEndDate
	FROM Account WITH (NOLOCK) WHERE UserId = @UserId

              	
	SET @NoOfDaysBlocked = DATEDIFF(day, getdate(), @BlockedEndDate ) 
	--PRINT @NoOfDaysBlocked
	IF @NoOfDaysBlocked >= 0   /* User still blocked  */
	BEGIN 
		SET @result = -100
		RETURN
	END
	ELSE
	BEGIN
		UPDATE Account SET Blocked = 0 WHERE UserId = @UserId
		SET @result  = 0
	END

	-- Added user creation check
	set @result = @isUserCreated	                          
END
ELSE
BEGIN
	SET @result = -99 --Invalid userid, or not yet activated 
END
GO
/****** Object:  StoredProcedure [dbo].[TantraAdminGetUserInformation]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
SP Name: TantraAdminGetEmail
Parameter: UserID
Description: get a user's profile from Account table
*/
CREATE PROCEDURE [dbo].[TantraAdminGetUserInformation]

@UserID NVARCHAR(50)
AS

SELECT Email
FROM Account WITH (NOLOCK)
WHERE UserID = @UserID
GO
/****** Object:  StoredProcedure [dbo].[TantraAdminCheckUsername]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TantraAdminCheckUsername]

@UserID NVARCHAR(50),
@resultCode INT OUT

AS

SET @resultCode = 0

SELECT @resultCode = COUNT(UserID)
FROM Account WITH (NOLOCK)
WHERE UserID = @UserID
GO
/****** Object:  StoredProcedure [dbo].[NewsUpdate]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[NewsUpdate] 
	@NewsId 	AS INT,
	@GroupId 	AS INT,
	@Title		AS VARCHAR(6000),
	@Body		AS VARCHAR(6000),
	@Display	AS INT
AS

UPDATE NewsItem SET GroupId = @GroupId, Title = @Title, 
	Body = @Body, Display = @Display
WHERE NewsId = @NewsId
GO
/****** Object:  StoredProcedure [dbo].[NewsGetItemForEdit]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[NewsGetItemForEdit]
	@NewsId AS INT
AS

SELECT * FROM NewsItem WITH (NOLOCK) 
WHERE NewsId = @NewsId
GO
/****** Object:  StoredProcedure [dbo].[NewsGetAllNewsDisplay]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[NewsGetAllNewsDisplay]
	@IsDisplayAll AS INT
AS
IF @IsDisplayAll = 0
	SELECT * FROM NewsItem WITH (NOLOCK) ORDER BY NewsId DESC
ELSE
	SELECT * FROM NewsItem WITH (NOLOCK) WHERE Display = 1 ORDER BY NewsId DESC
GO
/****** Object:  StoredProcedure [dbo].[NewsAdd]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[NewsAdd]
	@GroupId 	AS INT,
	@Title		AS VARCHAR(6000),
	@Body		AS VARCHAR(6000),
	@Display	AS INT
AS

INSERT INTO NewsItem (GroupId, Title, Body, Display) 
VALUES (@GroupId, @Title, @Body, @Display)
GO
/****** Object:  StoredProcedure [dbo].[K3_checkUser]    Script Date: 09/21/2014 18:02:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[K3_checkUser]

@username NVARCHAR(50),
@password NVARCHAR(70)

AS

SELECT * FROM Account
WHERE UserID = @username
AND password = @password
GO
/****** Object:  UserDefinedFunction [dbo].[IPToCountry]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[IPToCountry] (@IPAddress varchar(50))  
RETURNS varchar(100) AS  
BEGIN 

Declare @IPNumber bigint, @i int, @ilast int, @country varchar(100)
--SET @IPAddress = '222.126.37.173'

SET @i = 0
SET @i = CharIndex('.',@IPAddress)
SET @IPNumber = CAST(SUBSTRING(@IPAddress,1,@i -1) AS bigint) * (256*256*256)
SET @ilast = @i 
SET @i = CharIndex('.',@IPAddress,@ilast + 1)
SET @IPNumber = @IPNumber + CAST(SUBSTRING(@IPAddress,@ilast + 1,@i - @ilast - 1) AS bigint) * (256*256)
SET @ilast = @i 
SET @i = CharIndex('.',@IPAddress,@ilast + 1)
SET @IPNumber = @IPNumber + CAST(SUBSTRING(@IPAddress,@ilast + 1,@i - @ilast - 1) AS bigint) * (256)
SET @ilast = @i 
SET @IPNumber = @IPNumber + CAST(SUBSTRING(@IPAddress,@ilast + 1,len(@IPAddress) - @ilast ) AS bigint)

SELECT @country = [Country] FROM [dbo].[IPLookup] 
WHERE [IP_From] <= @IPNumber and [IP_To] >= @IPNumber

Return @country

END
GO
/****** Object:  StoredProcedure [dbo].[Insert_Status]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Insert_Status]
    @Account nvarchar(50),
    @Status int
AS
BEGIN
	UPDATE Account SET Status=@Status WHERE UserID=@Account
END
GO
/****** Object:  StoredProcedure [dbo].[getUsersForReactivation]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getUsersForReactivation] AS


SELECT a.userid,b.email,b.activationkey
FROM alim.reactivate_promo_user a, Account b
WHERE a.userid = b.userid
GO
/****** Object:  StoredProcedure [dbo].[getProductInfo]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getProductInfo]
	@productTypeId	AS INT
AS

DECLARE @Display TINYINT
SET @Display = 1 -- show all 1

SELECT PID, productId, productName, productAmount
FROM tblProduct WITH(READUNCOMMITTED)
WHERE productTypeId = @productTypeId
AND Display  = @Display
ORDER BY productAmount ASC
GO
/****** Object:  StoredProcedure [dbo].[GetNewsItem]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetNewsItem]
	@GroupId AS INT,
	@NewsId AS INT
AS
SET NOCOUNT ON
IF @NewsId = 0
	SELECT * FROM NewsItem WITH (NOLOCK) WHERE GroupId = @GroupId 
	AND Display = 1 ORDER BY NewsID DESC
ELSE
	SELECT * FROM NewsItem WITH (NOLOCK) WHERE GroupId = @GroupId 
	AND NewsId = @NewsId AND Display = 1 ORDER BY NewsID DESC
GO
/****** Object:  StoredProcedure [dbo].[GetNewsGroup]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[GetNewsGroup]
	@GroupId	AS INT
AS
SET NOCOUNT ON

IF @GroupId = 0
	SELECT * FROM NewsGroup  WITH (NOLOCK)
ELSE
	SELECT * FROM NewsGroup  WITH (NOLOCK) WHERE GroupId = @GroupId
GO
/****** Object:  StoredProcedure [dbo].[K3P_checkUser]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[K3P_checkUser]

@username NVARCHAR(50),
@password NVARCHAR(70),
@returnCode INT OUTPUT

AS

SET @returnCode = 0

SELECT @returnCode = COUNT(userID) FROM Account
WHERE UserID = @username
AND password = @password

RETURN @returnCode
GO
/****** Object:  StoredProcedure [dbo].[AccountUpdatePassword]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
--System Developer/DBA Richard Tibang chardtc@yahoo.com
CREATE PROC [dbo].[AccountUpdatePassword]
	@Email		AS NVARCHAR(50), 
	@Password 	AS NVARCHAR(60),
	@UserID	AS NVARCHAR(40) OUTPUT,
	@result 		AS INT OUTPUT
AS
SET NOCOUNT ON
UPDATE Account SET [password] = @Password, IsUserCreated=0 WHERE Email = @Email
IF @@ROWCOUNT = 1
BEGIN
	SELECT @UserID = UserID FROM Account WHERE Email = @Email
	SET @result = 0	
END
ELSE
	SET @result = -1
GO
/****** Object:  StoredProcedure [dbo].[TW_registerUser]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
SP Name: TW_registerUser
Output Param: Result, ActivationKey
Description: registers a user to Account table
Date: 2006/01/02 17:04
Author: bin
*/
CREATE PROCEDURE [dbo].[TW_registerUser]
@Email NVARCHAR(50),
@UserID NVARCHAR(50),
@Password NVARCHAR(40),
@SecretQuestion NVARCHAR(50),
@Answer NVARCHAR(50),
@Firstname NVARCHAR(30),
@MI NVARCHAR(1),
@Lastname NVARCHAR(30),
@Birthday DATETIME,
@Sex TINYINT,
@Address NVARCHAR(100),
@City NVARCHAR(50),
@State NVARCHAR(50),
@Country NVARCHAR(50),
@MobileNo NVARCHAR(15),
@HomeNo NVARCHAR(15),
@WherePlay NVARCHAR(100),
@InternetCon NVARCHAR(100),
@ISPCafe NVARCHAR(100),
@MMORPG NVARCHAR(500),
@PowerChar NVARCHAR(500),
@PrevExp NVARCHAR(500),
@AboutTantra NVARCHAR(100),
@RegIpAddress NVARCHAR(15),
@School NVARCHAR(50) = NULL,
@UserKey NVARCHAR(7)

AS

DECLARE @ActivationKey UNIQUEIDENTIFIER
DECLARE @Result INT

SET @Result = 0
SET NOCOUNT ON
IF NOT EXISTS(SELECT Email FROM Account WITH (NOLOCK) WHERE Email = @Email)
BEGIN
	IF EXISTS (SELECT UserID FROM Account WITH (NOLOCK) WHERE UserID = @UserID)
	BEGIN
		SET @Result = -2
		RETURN--exit	
	END

	SET @ActivationKey = NEWID() 
	INSERT INTO Account (Email, UserID, [Password], SecretQuestion, Answer, Firstname, mi, Lastname, Birthday, Sex, Address,
		City, State, Country, MobileNo, HomeNo, WherePlay, InternetCon, ISPCafe, 
		MMORPG, PowerChar, PrevExp, AboutTantra, RegIPAddress, School,  ActivationKey, UserKey)
	VALUES (@Email, @UserID, @Password, @SecretQuestion, @Answer, @Firstname, @mi, @Lastname, @Birthday, @Sex, @Address,
		@City, @State, @Country, @MobileNo, @HomeNo, @WherePlay, @InternetCon, @ISPCafe, 
		@MMORPG, @PowerChar, @PrevExp, @AboutTantra, @RegIPAddress, @School, @ActivationKey, @UserKey)
	IF @@ERROR <> 0
		SET @Result = -99 /* Unknown error while adding record */

END
ELSE
BEGIN 
	SET @Result = -1
END

SELECT @ActivationKey AS ActivationKey, @Result As Result
GO
/****** Object:  StoredProcedure [dbo].[TW_getUserProfile]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
SP Name: TW_getUserProfile
Parameter: UserID
Description: get a user's profile from Account table
*/
CREATE PROCEDURE [dbo].[TW_getUserProfile]

@UserID NVARCHAR(50)
AS

SELECT *
FROM Account
WHERE UserID = @UserID
GO
/****** Object:  StoredProcedure [dbo].[TW_checkIfUserExists]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
SP Name: TW_checkIfUserExists
Parameter: UserID, Email
Description: check if user/email exists
Date: 2006/01/04 12:25
Author: bin
*/
CREATE PROCEDURE [dbo].[TW_checkIfUserExists]

@UserID NVARCHAR(50),
@Email NVARCHAR(50)

AS

DECLARE @UserIDCount TINYINT
DECLARE @EmailCount TINYINT
DECLARE @Result TINYINT
SET @UserIDCount = 0
SET @EmailCount = 0
SET @Result = 0

SELECT @UserIDCount = COUNT(UserID)
FROM Account
WHERE UserID = @UserID

SELECT @EmailCount = COUNT(Email)
FROM Account
WHERE Email = @Email

If @UserIDCount > 0
BEGIN
SET @Result = @Result + 1
END

If @EmailCount > 0
BEGIN
SET @Result = @Result + 2
END

SELECT @Result AS Result
GO
/****** Object:  StoredProcedure [dbo].[TW_changePassword]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TW_changePassword]

@userId NVARCHAR(50),
@Email NVARCHAR(50),
@password NVARCHAR(70),
@returnCode INT OUT

AS

SET @returnCode = 0

UPDATE Account SET password = @password
WHERE userId = @userId
AND Email = @Email

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
SET @returnCode = 1
END

RETURN @returnCode
GO
/****** Object:  StoredProcedure [dbo].[UnivGetAll]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[UnivGetAll] AS

SELECT * FROM UniversityList WITH (NOLOCK) ORDER BY UnivName
GO
/****** Object:  StoredProcedure [dbo].[AccountUpdateCreditCardPaymentStatus]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[AccountUpdateCreditCardPaymentStatus]
(
	@userId  as nvarchar(50),
	@success as bit
)

as 

declare @errorCount as tinyInt
if @success = 0 --False
  update Account set @errorCount = CreditCardPaymentErrorCount = CreditCardPaymentErrorCount + 1, LastCreditCardPaymentErrorDate=GetDate() where userId=@userId
else
  update Account set @errorCount = CreditCardPaymentErrorCount = 0 where userId=@userId
return @errorCount
GO
/****** Object:  StoredProcedure [dbo].[AccountSMSReg]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--Programmer/DBA: Richard Tibang chardtc@yahoo.com
CREATE PROCEDURE [dbo].[AccountSMSReg]
	@Email 			AS nvarchar (50), 
	@UserID		AS nvarchar (50), 
	@Password		AS nvarchar (60), 
	@Firstname 		AS nvarchar (30),
	@Lastname 		AS nvarchar (30), 
	@result 			AS INT OUTPUT, 
	@ActivationKey		AS UNIQUEIDENTIFIER OUTPUT,
	@SecretQuestion	AS nvarchar (50),
	@SecretAnswer 		AS nvarchar (50),
	@MobileNo		AS nvarchar (15)
AS
--DECLARE @ActivationKey AS UNIQUEIDENTIFIER
SET @result = 0
SET NOCOUNT ON
IF NOT EXISTS(SELECT * FROM Account WITH (NOLOCK) WHERE Email = @Email)
BEGIN
	IF EXISTS(SELECT * FROM Account WITH (NOLOCK) WHERE UserID = @UserID)
	BEGIN
		SET @result = -2
		RETURN
	END

	SET @ActivationKey = NEWID() 
	INSERT INTO Account (Email, UserID, [Password], Firstname, MI, Lastname, SecretQuestion, Answer, ActivationKey, SMSReg, UserKey, City, State, Birthday, Address, HomeNo, MobileNo)
	VALUES (@Email, @UserID, @Password, @Firstname, '', @Lastname, @SecretQuestion, @SecretAnswer, @ActivationKey, 1,  '1111111', '', '', '1/1/1950', '', '', @MobileNo) -- 1 SMS Reg

	IF @@ERROR <> 0
		SET @result = -99 /* Unknown error occured while adding record */
	ELSE
		SET @result = @@IDENTITY
END
ELSE
BEGIN 
	SET @result = -1
END
GO
/****** Object:  StoredProcedure [dbo].[AccountSetVote]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[AccountSetVote]
	@ID 	AS INT,
	@Vote 	AS INT
AS
SET NOCOUNT ON
UPDATE Account SET Vote = @Vote WHERE [ID] = @ID
GO
/****** Object:  StoredProcedure [dbo].[AccountRequestActLink]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AccountRequestActLink]
	@Email		AS NVARCHAR(50),
	@UserID	AS NVARCHAR(50) OUTPUT,
	@Password	AS NVARCHAR(30) OUTPUT,
	@ActivationKey	AS UNIQUEIDENTIFIER OUTPUT,
	@result 		AS INT OUTPUT
AS
DECLARE @Activated AS BIT
SET @result = 0
SET NOCOUNT ON
--IF EXISTS (SELECT email FROM Account WHERE Email = @Email)
SELECT @UserID = UserID, @Password = [Password], @ActivationKey = ActivationKey,  
	@Activated = Activated
FROM Account WITH (NOLOCK)  WHERE Email = @Email	
IF @@ROWCOUNT = 1
BEGIN
	IF @Activated = 1
		SET @result = -101 /* Account already activated */
	ELSE BEGIN
		SET @result = 0 /* Ok send reg link */
	END
END
ELSE
BEGIN
	SET @result = -99 /* Not found */
END
GO
/****** Object:  StoredProcedure [dbo].[AccountRegisterSMSUpdate2]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AccountRegisterSMSUpdate2]
	@Email 			AS nvarchar (50), 
	@UserID		AS nvarchar (50), 
	@Password 		AS nvarchar (70),
	@SecretQuestion	AS nvarchar (50),
	@Answer 		AS nvarchar (50),
	@Firstname 		AS nvarchar (30),
	@mi 			AS nvarchar (1),
	@Lastname 		AS nvarchar (30), 
	@Birthday 		AS datetime, 
	@Sex 			AS tinyint, 
	@Address 		AS nvarchar (100),
	@City 			AS nvarchar (50), 
	@State 			AS nvarchar (50), 
	@Country 		AS nvarchar (50), 
	@MobileNo 		AS nvarchar (15), 
	@HomeNo 		AS nvarchar (15), 
	@WherePlay 		AS nvarchar (100), 
	@InternetCon 		AS nvarchar (100),
	@ISPCafe 		AS nvarchar (100),
	@MMORPG 		AS nvarchar (500),
	@PowerChar 		AS nvarchar (500),
	@PrevExp 		AS nvarchar (500),
	@AboutTantra 		AS nvarchar (100),
	@RegIPAddress 		AS nvarchar (15),
	@School		AS nvarchar(50),
	@ActivationKey		AS UNIQUEIDENTIFIER OUTPUT,
	@result 			AS INT OUTPUT,
	@UserKey 		AS nvarchar (7)
AS
SET @result = 0
SET NOCOUNT ON
IF EXISTS(SELECT Email FROM Account WITH (NOLOCK) WHERE Email = @Email)
BEGIN
	UPDATE Account SET [Password] = @Password, SecretQuestion = @SecretQuestion, 
		Answer = @Answer, Firstname = @Firstname, mi = @mi, Lastname = @Lastname, Birthday = @Birthday,
		Sex = @Sex, Address = @Address, City = @City, State = @State, Country = @Country, MobileNo = @MobileNo, 
		HomeNo =@HomeNo, WherePlay = @WherePlay, InternetCon = @InternetCon, ISPCafe = @ISPCafe, MMORPG = @MMORPG, 
		PowerChar = @PowerChar, PrevExp = @PrevExp, AboutTantra = @AboutTantra, RegIPAddress = @RegIPAddress, School=@School, UserKey = @UserKey
	WHERE Email = @Email
	SELECT @ActivationKey = ActivationKey FROM Account WHERE Email = @Email
	IF @@ERROR <>0
		SET @result = -99 /* Unknown error while adding record */
END
ELSE
BEGIN 
	SET @result = -1
END
GO
/****** Object:  StoredProcedure [dbo].[AccountRegisterSMSUpdate]    Script Date: 09/21/2014 18:02:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AccountRegisterSMSUpdate]
	@Email 			AS nvarchar (50), 
	@UserID		AS nvarchar (50), 
	@Password 		AS nvarchar (70),
	@SecretQuestion	AS nvarchar (50),
	@Answer 		AS nvarchar (50),
	@Firstname 		AS nvarchar (30),
	@mi 			AS nvarchar (1),
	@Lastname 		AS nvarchar (30), 
	@Birthday 		AS datetime, 
	@Sex 			AS tinyint, 
	@Address 		AS nvarchar (100),
	@City 			AS nvarchar (50), 
	@State 			AS nvarchar (50), 
	@Country 		AS nvarchar (50), 
	@MobileNo 		AS nvarchar (15), 
	@HomeNo 		AS nvarchar (15), 
	@WherePlay 		AS nvarchar (100), 
	@InternetCon 		AS nvarchar (100),
	@ISPCafe 		AS nvarchar (100),
	@MMORPG 		AS nvarchar (500),
	@PowerChar 		AS nvarchar (500),
	@PrevExp 		AS nvarchar (500),
	@AboutTantra 		AS nvarchar (100),
	@RegIPAddress 		AS nvarchar (15),
	@ActivationKey		AS UNIQUEIDENTIFIER OUTPUT,
	@result 			AS INT OUTPUT,
	@UserKey 		AS nvarchar (7)
AS
SET @result = 0
SET NOCOUNT ON
IF EXISTS(SELECT Email FROM Account WITH (NOLOCK) WHERE Email = @Email)
BEGIN
	UPDATE Account SET [Password] = @Password, SecretQuestion = @SecretQuestion, 
		Answer = @Answer, Firstname = @Firstname, mi = @mi, Lastname = @Lastname, Birthday = @Birthday,
		Sex = @Sex, Address = @Address, City = @City, State = @State, Country = @Country, MobileNo = @MobileNo, 
		HomeNo =@HomeNo, WherePlay = @WherePlay, InternetCon = @InternetCon, ISPCafe = @ISPCafe, MMORPG = @MMORPG, 
		PowerChar = @PowerChar, PrevExp = @PrevExp, AboutTantra = @AboutTantra, RegIPAddress = @RegIPAddress, UserKey = @UserKey
	WHERE Email = @Email
	SELECT @ActivationKey = ActivationKey FROM Account WHERE Email = @Email
	IF @@ERROR <>0
		SET @result = -99 /* Unknown error while adding record */
END
ELSE
BEGIN 
	SET @result = -1
END
GO
/****** Object:  StoredProcedure [dbo].[AccountRegister2]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
--Programmer/DBA: Richard Tibang chardtc@yahoo.com
CREATE PROCEDURE [dbo].[AccountRegister2]
	@Email 			AS nvarchar (50), 
	@UserID		AS nvarchar (50),
	@Password 		AS nvarchar (40),
	@SecretQuestion	AS nvarchar (50),
	@Answer 		AS nvarchar (50),
	@Firstname 		AS nvarchar (30),
	@mi 			AS nvarchar (1),
	@Lastname 		AS nvarchar (30), 
	@Birthday 		AS datetime, 
	@Sex 			AS tinyint, 
	@Address 		AS nvarchar (100),
	@City 			AS nvarchar (50), 
	@State 			AS nvarchar (50), 
	@Country 		AS nvarchar (50), 
	@MobileNo 		AS nvarchar (15), 
	@HomeNo 		AS nvarchar (15), 
	@WherePlay 		AS nvarchar (100), 
	@InternetCon 		AS nvarchar (100),
	@ISPCafe 		AS nvarchar (100),
	@MMORPG 		AS nvarchar (500),
	@PowerChar 		AS nvarchar (500),
	@PrevExp 		AS nvarchar (500),
	@AboutTantra 		AS nvarchar (100),
	@RegIPAddress 		AS nvarchar (15),
	@School		AS nvarchar(50) = null,
	@ActivationKey		AS UNIQUEIDENTIFIER OUTPUT,
	@result 			AS INT OUTPUT,
	@UserKey 		AS nvarchar (7)	
AS
SET @result = 0
SET NOCOUNT ON
IF NOT EXISTS(SELECT Email FROM Account WITH (NOLOCK) WHERE Email = @Email)
BEGIN
	IF EXISTS (SELECT UserID FROM Account WITH (NOLOCK) WHERE UserID = @UserID)
	BEGIN
		SET @result = -2
		RETURN--exit	
	END

	SET @ActivationKey = NEWID() 
	INSERT INTO Account (Email, UserID, [Password], SecretQuestion, Answer, Firstname, mi, Lastname, Birthday, Sex, Address,
		City, State, Country, MobileNo, HomeNo, WherePlay, InternetCon, ISPCafe, 
		MMORPG, PowerChar, PrevExp, AboutTantra, RegIPAddress, School,  ActivationKey, UserKey)
	VALUES (@Email, @UserID, @Password, @SecretQuestion, @Answer, @Firstname, @mi, @Lastname, @Birthday, @Sex, @Address,
		@City, @State, @Country, @MobileNo, @HomeNo, @WherePlay, @InternetCon, @ISPCafe, 
		@MMORPG, @PowerChar, @PrevExp, @AboutTantra, @RegIPAddress, @School, @ActivationKey, @UserKey)
	IF @@ERROR <>0
		SET @result = -99 /* Unknown error while adding record */

END
ELSE
BEGIN 
	SET @result = -1
END
GO
/****** Object:  StoredProcedure [dbo].[AccountRegister]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
--Programmer/DBA: Richard Tibang chardtc@yahoo.com
CREATE PROCEDURE [dbo].[AccountRegister]
	@Email 			AS nvarchar (50), 
	@UserID		AS nvarchar (50),
	@Password 		AS nvarchar (40),
	@SecretQuestion	AS nvarchar (50),
	@Answer 		AS nvarchar (50),
	@Firstname 		AS nvarchar (30),
	@mi 			AS nvarchar (1),
	@Lastname 		AS nvarchar (30), 
	@Birthday 		AS datetime, 
	@Sex 			AS tinyint, 
	@Address 		AS nvarchar (100),
	@City 			AS nvarchar (50), 
	@State 			AS nvarchar (50), 
	@Country 		AS nvarchar (50), 
	@MobileNo 		AS nvarchar (15), 
	@HomeNo 		AS nvarchar (15), 
	@WherePlay 		AS nvarchar (100), 
	@InternetCon 		AS nvarchar (100),
	@ISPCafe 		AS nvarchar (100),
	@MMORPG 		AS nvarchar (500),
	@PowerChar 		AS nvarchar (500),
	@PrevExp 		AS nvarchar (500),
	@AboutTantra 		AS nvarchar (100),
	@RegIPAddress 		AS nvarchar (15),
	@ActivationKey		AS UNIQUEIDENTIFIER OUTPUT,
	@result 			AS INT OUTPUT,
	@UserKey 		AS nvarchar (7)	
AS
SET @result = 0
SET NOCOUNT ON
IF NOT EXISTS(SELECT Email FROM Account WITH (NOLOCK) WHERE Email = @Email)
BEGIN
	IF EXISTS (SELECT UserID FROM Account WITH (NOLOCK) WHERE UserID = @UserID)
	BEGIN
		SET @result = -2
		RETURN--exit	
	END

	SET @ActivationKey = NEWID() 
	INSERT INTO Account (Email, UserID, [Password], SecretQuestion, Answer, Firstname, mi, Lastname, Birthday, Sex, Address,
		City, State, Country, MobileNo, HomeNo, WherePlay, InternetCon, ISPCafe, 
		MMORPG, PowerChar, PrevExp, AboutTantra, RegIPAddress, ActivationKey, UserKey)
	VALUES (@Email, @UserID, @Password, @SecretQuestion, @Answer, @Firstname, @mi, @Lastname, @Birthday, @Sex, @Address,
		@City, @State, @Country, @MobileNo, @HomeNo, @WherePlay, @InternetCon, @ISPCafe, 
		@MMORPG, @PowerChar, @PrevExp, @AboutTantra, @RegIPAddress, @ActivationKey, @UserKey)
	IF @@ERROR <>0
		SET @result = -99 /* Unknown error while adding record */

END
ELSE
BEGIN 
	SET @result = -1
END
GO
/****** Object:  StoredProcedure [dbo].[AccountLoginUserID2]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[AccountLoginUserID2]
	@UserID	AS NVARCHAR(50), 
	@Password	AS NVARCHAR(70),
	@result 		AS INT OUTPUT,
	@ID		AS INT OUTPUT,
	@Email		AS NVARCHAR(50) OUTPUT,
	@Firstname	AS NVARCHAR(30) OUTPUT,
	@mi		AS NVARCHAR(1) OUTPUT,
	@Lastname	AS NVARCHAR(30) OUTPUT,
	@Birthday	AS DATETIME 	    OUTPUT,
	@Sex		AS INT 		    OUTPUT,
	@Address	AS NVARCHAR(100) OUTPUT,
	@City		AS NVARCHAR(50) OUTPUT,
	@State		AS NVARCHAR(50) OUTPUT,
	@Country	AS NVARCHAR(50) OUTPUT,
	@MobileNo	AS NVARCHAR(15) OUTPUT,
	@HomeNo	AS NVARCHAR(15) OUTPUT,
	@SecretQuestion  AS NVARCHAR(50) OUTPUT,
	@Answer	AS NVARCHAR(50) OUTPUT,
	@Activated	AS BIT OUTPUT,
	@UserKey	AS NVARCHAR(7) OUTPUT,
	@Blocked	AS INT OUTPUT,
	@BlockedEndDate AS NVARCHAR(30) OUTPUT
AS
SET  NOCOUNT ON
SET @result = 0

/*WHERE [id] = @id AND [passwd] COLLATE SQL_Latin1_General_CP1_CS_AS = @passwd*/

SELECT @ID = [ID], @UserKey = UserKey, @Email = Email, @Firstname = Firstname, @mi = mi, @Lastname = Lastname, @Birthday= Birthday, @Sex = Sex, 
	@Address = Address, @City = City,  @State = State, @Country = country, @MobileNo = MobileNo, @HomeNo = HomeNo, 
	@SecretQuestion = SecretQuestion, @Answer = Answer, @Activated = activated, @UserID = UserID,
	@Blocked = Blocked, @BlockedEndDate = BlockedEndDate
FROM Account WHERE UserID = @UserID AND [Password] COLLATE SQL_Latin1_General_CP1_CS_AS = @Password 
IF @@ROWCOUNT = 1
	SET @result = 0 --Success 
ELSE
BEGIN
	SET @result = -1/* Failed */	
END
GO
/****** Object:  StoredProcedure [dbo].[AccountLoginUserID]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AccountLoginUserID]
	@UserID	AS NVARCHAR(50), 
	@Password	AS NVARCHAR(70),
	@result 		AS INT OUTPUT,
	@ID		AS INT OUTPUT,
	@Email		AS NVARCHAR(50) OUTPUT,
	@Firstname	AS NVARCHAR(30) OUTPUT,
	@mi		AS NVARCHAR(1) OUTPUT,
	@Lastname	AS NVARCHAR(30) OUTPUT,
	@Birthday	AS DATETIME 	    OUTPUT,
	@Sex		AS INT 		    OUTPUT,
	@Address	AS NVARCHAR(100) OUTPUT,
	@City		AS NVARCHAR(50) OUTPUT,
	@State		AS NVARCHAR(50) OUTPUT,
	@Country	AS NVARCHAR(50) OUTPUT,
	@MobileNo	AS NVARCHAR(15) OUTPUT,
	@HomeNo	AS NVARCHAR(15) OUTPUT,
	@SecretQuestion  AS NVARCHAR(50) OUTPUT,
	@Answer	AS NVARCHAR(50) OUTPUT,
	@Activated	AS BIT OUTPUT,
	@UserKey	AS NVARCHAR(7) OUTPUT
AS
SET  NOCOUNT ON
SET @result = 0

/*WHERE [id] = @id AND [passwd] COLLATE SQL_Latin1_General_CP1_CS_AS = @passwd*/

SELECT @ID = [ID], @UserKey = UserKey, @Email = Email, @Firstname = Firstname, @mi = mi, @Lastname = Lastname, @Birthday= Birthday, @Sex = Sex, 
	@Address = Address, @City = City,  @State = State, @Country = country, @MobileNo = MobileNo, @HomeNo = HomeNo, 
	@SecretQuestion = SecretQuestion, @Answer = Answer, @Activated = activated, @UserID = UserID
FROM Account WHERE UserID = @UserID AND [Password] COLLATE SQL_Latin1_General_CP1_CS_AS = @Password 
IF @@ROWCOUNT = 1
	SET @result = 0 --Success 
ELSE
BEGIN
	SET @result = -1/* Failed */	
END
GO
/****** Object:  StoredProcedure [dbo].[AccountLoginForTopUp1]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
create   PROCEDURE [dbo].[AccountLoginForTopUp1]
	@UserID	AS NVARCHAR(50), 
	--@Password	AS NVARCHAR(70),
	@result 		AS INT OUTPUT,
	@ID		AS INT OUTPUT,
	@Email		AS NVARCHAR(50) OUTPUT,
	@Firstname	AS NVARCHAR(30) OUTPUT,
	@mi		AS NVARCHAR(1) OUTPUT,
	@Lastname	AS NVARCHAR(30) OUTPUT,
	@Birthday	AS DATETIME 	    OUTPUT,
	@Sex		AS INT 		    OUTPUT,
	@Address	AS NVARCHAR(100) OUTPUT,
	@City		AS NVARCHAR(50) OUTPUT,
	@State		AS NVARCHAR(50) OUTPUT,
	@Country	AS NVARCHAR(50) OUTPUT,
	@MobileNo	AS NVARCHAR(15) OUTPUT,
	@HomeNo	AS NVARCHAR(15) OUTPUT,
	@SecretQuestion  AS NVARCHAR(50) OUTPUT,
	@Answer	AS NVARCHAR(50) OUTPUT,
	@Activated	AS BIT OUTPUT,
	@UserKey	AS NVARCHAR(7) OUTPUT,
	@IsBlocked      as tinyInt output,
	@AllowCreditCard as bit output
AS
SET  NOCOUNT ON
SET @result = 0

/*WHERE [id] = @id AND [passwd] COLLATE SQL_Latin1_General_CP1_CS_AS = @passwd*/

SELECT @ID = [ID], @UserKey = UserKey, @Email = Email, @Firstname = Firstname, @mi = mi, @Lastname = Lastname, @Birthday= Birthday, @Sex = Sex, 
	@Address = Address, @City = City,  @State = State, @Country = country, @MobileNo = MobileNo, @HomeNo = HomeNo, 
	@SecretQuestion = SecretQuestion, @Answer = Answer, @Activated = activated, @UserID = UserID, @IsBlocked = Blocked, @AllowCreditCard=AllowCreditCard
FROM Account WHERE UserID = @UserID 
--AND [Password] COLLATE SQL_Latin1_General_CP1_CS_AS = @Password 
IF @@ROWCOUNT = 1
	SET @result = 0 --Success 
ELSE
BEGIN
	SET @result = -1/* Failed */	
END
GO
/****** Object:  StoredProcedure [dbo].[AccountLoginForTopUp]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE [dbo].[AccountLoginForTopUp]
	@UserID	AS NVARCHAR(50), 
	@Password	AS NVARCHAR(70),
	@result 		AS INT OUTPUT,
	@ID		AS INT OUTPUT,
	@Email		AS NVARCHAR(50) OUTPUT,
	@Firstname	AS NVARCHAR(30) OUTPUT,
	@mi		AS NVARCHAR(1) OUTPUT,
	@Lastname	AS NVARCHAR(30) OUTPUT,
	@Birthday	AS DATETIME 	    OUTPUT,
	@Sex		AS INT 		    OUTPUT,
	@Address	AS NVARCHAR(100) OUTPUT,
	@City		AS NVARCHAR(50) OUTPUT,
	@State		AS NVARCHAR(50) OUTPUT,
	@Country	AS NVARCHAR(50) OUTPUT,
	@MobileNo	AS NVARCHAR(15) OUTPUT,
	@HomeNo	AS NVARCHAR(15) OUTPUT,
	@SecretQuestion  AS NVARCHAR(50) OUTPUT,
	@Answer	AS NVARCHAR(50) OUTPUT,
	@Activated	AS BIT OUTPUT,
	@UserKey	AS NVARCHAR(7) OUTPUT,
	@IsBlocked      as tinyInt output,
	@AllowCreditCard as bit output
AS
SET  NOCOUNT ON
SET @result = 0

/*WHERE [id] = @id AND [passwd] COLLATE SQL_Latin1_General_CP1_CS_AS = @passwd*/

SELECT @ID = [ID], @UserKey = UserKey, @Email = Email, @Firstname = Firstname, @mi = mi, @Lastname = Lastname, @Birthday= Birthday, @Sex = Sex, 
	@Address = Address, @City = City,  @State = State, @Country = country, @MobileNo = MobileNo, @HomeNo = HomeNo, 
	@SecretQuestion = SecretQuestion, @Answer = Answer, @Activated = activated, @UserID = UserID, @IsBlocked = Blocked, @AllowCreditCard=AllowCreditCard
FROM Account WHERE UserID = @UserID AND [Password] COLLATE SQL_Latin1_General_CP1_CS_AS = @Password 
IF @@ROWCOUNT = 1
	SET @result = 0 --Success 
ELSE
BEGIN
	SET @result = -1/* Failed */	
END
GO
/****** Object:  StoredProcedure [dbo].[AccountLogin2]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[AccountLogin2]
	@Email		AS NVARCHAR(50),
	@Password	AS NVARCHAR(70),
	@result 		AS INT OUTPUT,
	@ID		AS INT OUTPUT,
	@Firstname	AS NVARCHAR(30) OUTPUT,
	@mi		AS NVARCHAR(1) OUTPUT,
	@Lastname	AS NVARCHAR(30) OUTPUT,
	@Birthday	AS DATETIME 	    OUTPUT,
	@Sex		AS INT 		    OUTPUT,
	@Address	AS NVARCHAR(100) OUTPUT,
	@City		AS NVARCHAR(50) OUTPUT,
	@State		AS NVARCHAR(50) OUTPUT,
	@Country	AS NVARCHAR(50) OUTPUT,
	@MobileNo	AS NVARCHAR(15) OUTPUT,
	@HomeNo	AS NVARCHAR(15) OUTPUT,
	@SecretQuestion  AS NVARCHAR(50) OUTPUT,
	@Answer	AS NVARCHAR(50) OUTPUT,
	@Activated	AS BIT OUTPUT,
	@UserID	AS NVARCHAR(50) OUTPUT,
	@UserKey	AS NVARCHAR(7) OUTPUT,
	@Blocked	AS INT OUTPUT,
	@BlockedEndDate AS DATETIME OUTPUT
AS
SET  NOCOUNT ON
SET @result = 0
SELECT @ID = [ID], @UserKey = UserKey, @Firstname = Firstname, @mi = mi, @Lastname = Lastname, @Birthday= Birthday, @Sex = Sex, 
	@Address = Address, @City = City,  @State = State, @Country = country, @MobileNo = MobileNo, @HomeNo = HomeNo, 
	@SecretQuestion = SecretQuestion, @Answer = Answer, @Activated = activated, @UserID = UserID, 
	@Blocked = Blocked, @BlockedEndDate = BlockedEndDate
FROM Account WHERE Email = @Email AND [Password] COLLATE SQL_Latin1_General_CP1_CS_AS = @Password 
IF @@ROWCOUNT = 1
	SET @result = 0 --Success 
ELSE
BEGIN
	SET @result = -1/* Failed */	
END
GO
/****** Object:  StoredProcedure [dbo].[AccountLogin]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AccountLogin]
	@Email		AS NVARCHAR(50),
	@Password	AS NVARCHAR(70),
	@result 		AS INT OUTPUT,
	@ID		AS INT OUTPUT,
	@Firstname	AS NVARCHAR(30) OUTPUT,
	@mi		AS NVARCHAR(1) OUTPUT,
	@Lastname	AS NVARCHAR(30) OUTPUT,
	@Birthday	AS DATETIME 	    OUTPUT,
	@Sex		AS INT 		    OUTPUT,
	@Address	AS NVARCHAR(100) OUTPUT,
	@City		AS NVARCHAR(50) OUTPUT,
	@State		AS NVARCHAR(50) OUTPUT,
	@Country	AS NVARCHAR(50) OUTPUT,
	@MobileNo	AS NVARCHAR(15) OUTPUT,
	@HomeNo	AS NVARCHAR(15) OUTPUT,
	@SecretQuestion  AS NVARCHAR(50) OUTPUT,
	@Answer	AS NVARCHAR(50) OUTPUT,
	@Activated	AS BIT OUTPUT,
	@UserID	AS NVARCHAR(50) OUTPUT,
	@UserKey	AS NVARCHAR(7) OUTPUT
AS
SET  NOCOUNT ON
SET @result = 0
SELECT @ID = [ID], @UserKey = UserKey, @Firstname = Firstname, @mi = mi, @Lastname = Lastname, @Birthday= Birthday, @Sex = Sex, 
	@Address = Address, @City = City,  @State = State, @Country = country, @MobileNo = MobileNo, @HomeNo = HomeNo, 
	@SecretQuestion = SecretQuestion, @Answer = Answer, @Activated = activated, @UserID = UserID
FROM Account WHERE Email = @Email AND [Password] COLLATE SQL_Latin1_General_CP1_CS_AS = @Password 
IF @@ROWCOUNT = 1
	SET @result = 0 --Success 
ELSE
BEGIN
	SET @result = -1/* Failed */	
END
GO
/****** Object:  StoredProcedure [dbo].[AccountInsertUserInBilling]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Programmer/DBA: Richard Tibang chardtc@yahoo.com
/* Function: Insert user account to Blling DB when user registered.*/
CREATE PROCEDURE [dbo].[AccountInsertUserInBilling]
	@Email	 	NVARCHAR(50), -- Email as key
	@NCashResult 	INT OUTPUT,
	@NCashMsg    	NVARCHAR(100) OUTPUT
AS
DECLARE @UserID 	NVARCHAR(50),
	@Lastname	NVARCHAR(30),
	@MI		NVARCHAR(1),
	@Firstname	NVARCHAR(30),
	@UserKey	NVARCHAR(7),
	@Sex		INT,
	@Birthday	DATETIME,
	@Address	NVARCHAR(100),
	@HomeNo	NVARCHAR(15),
	@Country	NVARCHAR(50),
	@City		NVARCHAR(50),
	@State		NVARCHAR(50),
	@SecretQuestion NVARCHAR(50),
	@Answer	NVARCHAR(50),
	@MobileNo	NVARCHAR(15)

SELECT @UserID=UserID, @Lastname=Lastname, @MI=MI, @Firstname=Firstname, @UserKey=UserKey, @Sex=Sex, @Birthday=Birthday, 
	@Address=Address, @HomeNo=HomeNo, @Email=Email, @Country=Country, @City=City, @State=State, 
	@SecretQuestion=SecretQuestion, @Answer=Answer, @MobileNo=MobileNo
FROM Account WHERE Email = @Email

	--Insert user to billing database
	EXEC BillCrux_Phil.dbo.procInsertUser 
	@UserID,	--@UserID, 
	1,		--@cpId		as	int		* cpId  = Game Product id, Ex) 1 - Tantra , 2 - RF Online
	NULL,		--@password		as	nvarchar(70)	* User PassWord	
	@Lastname, 	--@userSurName	as	nvarchar(64)	* User Last Name
	@MI, 		--@MI			as	nvarchar(1)	* User Middle Name 
	@Firstname,	--@userFirstName	as	nvarchar(64)	* User First Name
	@UserKey, 	--@userKey		as	nvarchar(7)		* UserKey
	@Sex,		--@sex			as	int						* sex Male - 1 , FeMale - 0
	@Birthday,	--@birthday		as	nvarchar(10)	* birthday ex) 2004-02-01
	@Address,	--@address		as	nvarchar(64)	* address		
	@HomeNo,	--@phoneNumber		as	nvarchar(16)	* Home TelePhone Number 
	@Email,		--@email			as	nvarchar(64)	* email
	@Country,	--@nation			as	nvarchar(64)	* Country
	@City,		--@city			as	nvarchar(64)	* State
	@State,		--@state			as	nvarchar(64)	* City
	@SecretQuestion, --@passwordCheckQuestionTypeId	as	nvarchar(64)	* PasswordCheck Question 
	@Answer,	--@passwordCheckAnswer	as	nvarchar(64)	* PasswordCheckAnswer 
	@MobileNo,	--@handPhoneNumber	as	nvarchar(64)	* Mobile-Number
	'',		--@jobTypeId		as	nvarchar(64)	* Job Description
	0,		--@getMail			as 	bit	* Membership Mailling ex) 1 - yes , 0 - no
	1, 		--@gameServiceId		as	smallint	* GameService Id Ex) 1 - Tantra , 2 - RF Online
	@NCashResult OUTPUT, --@userNumber		as	int	OUTPUT 	* Register  after Return User's Unique Number, SUCCESS : 0 MORE INT of TYPE VALUE , FAIL : -1 
	@NCashMsg    OUTPUT	--@msg			as	nvarchar(64)	OUTPUT * if Fail then return Error Message
GO
/****** Object:  StoredProcedure [dbo].[AccountGetVoteStatus]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[AccountGetVoteStatus]

	@ID 	AS INT,
	@result AS INT OUTPUT
AS
SET NOCOUNT ON
SELECT @result = Vote FROM Account WHERE [ID] = @ID
GO
/****** Object:  StoredProcedure [dbo].[AccountGetVoteCount]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[AccountGetVoteCount]

	@YesVote AS INT OUTPUT,
	@NoVote AS INT OUTPUT
AS
SET NOCOUNT ON
SELECT @YesVote = COUNT(*)  FROM Account WHERE Vote = 1
SELECT @NoVote  = COUNT(*)  FROM Account WHERE Vote = 2
GO
/****** Object:  StoredProcedure [dbo].[AccountGetUserIDIfNull]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[AccountGetUserIDIfNull]
	@Email AS NVARCHAR(50),
	@result AS INT OUTPUT
AS
DECLARE @IsUserIDNull AS NVARCHAR(50)
SET NOCOUNT ON
SELECT @IsUserIDNull = UserID FROM Account WITH (NOLOCK) WHERE Email = @Email
IF @@ROWCOUNT  = 1
	IF @IsUserIDNull IS NULL OR @IsUserIDNull = ''
		SET @result = -100 --use email for login
	ELSE
		SET @result = -101 --use user id for login
ELSE	
	SET @result = -99 --Email not-found
GO
/****** Object:  StoredProcedure [dbo].[AccountGetSMSSignUpId]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AccountGetSMSSignUpId]
	@Id		AS INT,
	@ActivationKey	AS UniqueIdentifier OUTPUT,
	@Email		AS NVARCHAR(50) OUTPUT,
	@Firstname 	AS NVARCHAR(30) OUTPUT,
	@Lastname	AS NVARCHAR(30) OUTPUT,
	@IsSMS		AS INT OUTPUT,
	@result 		AS INT OUTPUT,
	@UserID	AS NVARCHAR(50) OUTPUT
AS
DECLARE @SMSReg AS INT, @Birthday AS DATETIME
SET @result = 0
SET NOCOUNT ON

SELECT  @ActivationKey = ActivationKey, @Email = Email, @UserID = UserID, @Firstname = Firstname, @Lastname = Lastname, 
	@SMSReg = SMSReg, @Birthday = Birthday
FROM Account WITH (NOLOCK) WHERE [ID] = @Id

IF @@ROWCOUNT = 1 /* Account exist */
BEGIN
	IF @SMSReg IS NULL
		SET @IsSMS  = 0
	ELSE BEGIN
		SET @IsSMS = 1 /* is Reg thru SMS  */
	END
	IF @Birthday IS NULL
		SET @result = 0  /* not yet updated*/
	ELSE BEGIN
		SET @result = -1  /* Already updated */
	END
END
ELSE
	SET @result = -2 /* not found */
GO
/****** Object:  StoredProcedure [dbo].[AccountGetSignUpEmailById]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[AccountGetSignUpEmailById]
	@Id		AS INT,
	@ActivationKey	AS UniqueIdentifier OUTPUT,
	@Email		AS NVARCHAR(50) OUTPUT,
	@result 		AS INT OUTPUT
AS
SET @result = 0
SET NOCOUNT ON

SELECT  @ActivationKey = ActivationKey, @Email = Email FROM SignUp WHERE [ID] = @Id

IF @@ROWCOUNT > 0 /* ok */
BEGIN
	SELECT [id] FROM Account WHERE Email = @Email
	IF @@ROWCOUNT > 0
	BEGIN
		SET @result = -1 /* Already registered */
	END
	ELSE
	BEGIN
		SET @result = 0  /* Not yet registered continue... */
	END
END
ELSE
	SET @result = -2 /* not found */
GO
/****** Object:  StoredProcedure [dbo].[AccountGetSignUpEmail]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[AccountGetSignUpEmail]
	@ActivationKey	AS UniqueIdentifier,
	@Email		AS NVARCHAR(50) OUTPUT,
	@result 		AS INT OUTPUT
AS
SET @result = 0
SET NOCOUNT ON


SELECT @Email = Email FROM SignUp WITH (NOLOCK) WHERE ActivationKey = @ActivationKey

IF @@ROWCOUNT > 0 /* ok */
BEGIN
	SELECT [id] FROM Account  WITH (NOLOCK) WHERE Email = @Email
	IF @@ROWCOUNT > 0
	BEGIN
		SET @result = -1 /* Already registered */
	END
	ELSE
	BEGIN
		SET @result = 0  /* Not yet registered continue... */
	END
END
ELSE
	SET @result = -2 /* not found */
GO
/****** Object:  StoredProcedure [dbo].[AccountGetQuestionAnswer]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[AccountGetQuestionAnswer] 
	@Email		AS NVARCHAR(50), 
	@SecretQuestion AS NVARCHAR(50) OUTPUT,
	@Answer 	AS NVARCHAR(50) OUTPUT,
	@result 		AS INT 		OUTPUT,
	@UserID	AS NVARCHAR(50) OUTPUT

AS
SET NOCOUNT ON
SELECT @UserID = UserID, @SecretQuestion = SecretQuestion, @Answer = Answer 
FROM Account WITH (NOLOCK) 
WHERE Email = @Email
IF @@ROWCOUNT > 0
	SET @result = 0
ELSE
	SET @result = -1
GO
/****** Object:  StoredProcedure [dbo].[AccountGetProfile]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[AccountGetProfile]
	@Email		AS NVARCHAR(50), 
	@UserID	AS NVARCHAR(50), 
	@Birthday	AS DATETIME OUTPUT,
	@Sex		AS INT OUTPUT,
	@Address	AS NVARCHAR(100) OUTPUT,
	@City		AS NVARCHAR(50) OUTPUT,
	@State		AS NVARCHAR(50) OUTPUT,
	@Country	AS NVARCHAR(50) OUTPUT,
	@MobileNo	AS NVARCHAR(15) OUTPUT,
	@HomeNo	AS NVARCHAR(15) OUTPUT,
	@result 		AS INT OUTPUT
AS
SET NOCOUNT ON
SELECT @UserID = UserID, @Birthday= Birthday, @Sex = Sex, @Address = Address, @City = City,
	@State = State, @Country = country, @MobileNo = MobileNo, @HomeNo = HomeNo 
FROM Account WITH (NOLOCK) 
WHERE Email = @Email
IF @@ROWCOUNT > 0
	SET @result = 0
ELSE
	SET @result = -1
GO
/****** Object:  StoredProcedure [dbo].[AccountGetDetails]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[AccountGetDetails]
(
	@UserID	AS NVARCHAR(50), 
	@EMail 	as NVarchar(50) output,
	@Password	as NVarchar(70) output,
	@UserKey	as nvarchar(7) output,
	@FirstName	as nvarchar(30) output,
	@MI		as nvarchar(1) output,
	@LastName	as nvarchar(30) output,
	@CreditCardPaymentErrorCount as int output,
	@LastCreditCardPaymentErrorDate as datetime output,
	@AllowCreditCard as bit output,
	@IsBlocked as tinyint output
)		
AS
SET NOCOUNT ON
SELECT @Email = email, @Password = [password], @userKey = userkey, @FirstName=firstname, @mi=mi, @LastName=lastName, @CreditCardPaymentErrorCount=CreditcardPaymentErrorCOunt, @LastCreditCardPaymentErrorDate=LastCreditCardPaymentErrorDate, @AllowCreditCard = AllowCreditCard, @IsBlocked = blocked
FROM Account WITH (NOLOCK) 
WHERE UserId = @UserId
IF @@ROWCOUNT > 0
	return 0
ELSE
	return -1
GO
/****** Object:  StoredProcedure [dbo].[AccountGetCloseBetaStatus]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[AccountGetCloseBetaStatus]

	@Email AS NVARCHAR(50),
	@CloseBeta AS INT OUTPUT
AS
SET NOCOUNT ON
SELECT @CloseBeta = CloseBeta FROM Account WITH (NOLOCK) WHERE Email = @Email
IF @@ROWCOUNT <> 1
	SET @CloseBeta = 0
GO
/****** Object:  StoredProcedure [dbo].[AccountGetBlockedStatus]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[AccountGetBlockedStatus]
	@ID 			AS INT,
	@Blocked		AS INT OUTPUT,
	@BlockedEndDate	AS DATETIME OUTPUT
AS
SET NOCOUNT ON

SELECT @Blocked = Blocked, @BlockedEndDate = BlockedEndDate FROM Account WHERE [ID] = @ID
GO
/****** Object:  StoredProcedure [dbo].[AccountConfirmEmail]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[AccountConfirmEmail]
	@ActivationKey	AS UniqueIdentifier,
	@result 		AS INT OUTPUT
AS
	UPDATE Account SET Confirmed  = 1 WHERE ActivationKey = @ActivationKey
 if @@Error = 0
    return @@Identity
  else
    return -1
GO
/****** Object:  StoredProcedure [dbo].[AccountChangeEmail]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[AccountChangeEmail]
	@userid 	AS nvarchar(50),
	@newemail	as nvarchar(50),
	@result 	AS INT OUTPUT
AS
	UPDATE Account SET Email  = @newemail WHERE userid = @userid

 if @@Error = 0
begin
DECLARE @result2 int
             EXEC @result2=[BILLINGDB].BillCrux_Phil.dbo.procUpdateEmail  @userid, @newemail
	if(@result2<>-1)
	begin
		set @result=1
		return
	end
	else
	begin
		set @result=-1
              	return
	end
end
  else
  begin
	set @result=-1
	return	
  end
GO
/****** Object:  StoredProcedure [dbo].[AccountActivateCloseBeta]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[AccountActivateCloseBeta]

	@Email AS NVARCHAR(50)
AS
SET NOCOUNT ON
UPDATE Account SET  CloseBeta = 1 WHERE Email = @Email
GO
/****** Object:  StoredProcedure [dbo].[AccountActivate_Old]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AccountActivate_Old]
	@ActivationKey	AS UniqueIdentifier,
	@Email		AS NVARCHAR(50) OUTPUT,
	@UserID	AS NVARCHAR(50) OUTPUT,
	@Password	AS NVARCHAR(70) OUTPUT,
	@result 		AS INT OUTPUT
AS
SET @result = 0
DECLARE @Activated AS INT 
SET NOCOUNT ON
SELECT  @Activated = Activated FROM Account  WITH (NOLOCK) WHERE ActivationKey = @ActivationKey
IF @@ROWCOUNT = 1
BEGIN
	IF  (@Activated = 1) --Account already activated
	BEGIN
		SET @result = -1
		RETURN --Exit
	END
	ELSE --NOT yet activated
	BEGIN 
		UPDATE Account SET Activated  = 1 WHERE ActivationKey = @ActivationKey
		IF @@ROWCOUNT = 1 /* ok */
		BEGIN
			SELECT @Email = Email, @UserID = UserID, @Password = [Password] FROM Account  WITH (NOLOCK) WHERE ActivationKey = @ActivationKey
			SET @result = 0 /* OK, return email and password */
		END
		ELSE
			SET @result = -3  /* error */			
	END
END
ELSE
	SET @result = -2 /* NOT found */
GO
/****** Object:  StoredProcedure [dbo].[AdminPivotYrTotalReg]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminPivotYrTotalReg] AS

--drop table #temp
CREATE TABLE #Temp(	
	Yr int,
	Mn int,
	Dy int,
	Cnt int
)
INSERT INTO #Temp
SELECT   YEAR(dateregistered) as Yr,  MONTH(dateregistered) as Mn, DAY(dateregistered) as Dy, COUNT(dateregistered) as Cnt 
FROM Account  WITH (NOLOCK)group by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered) 
order by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered)

--select * from #Temp

SELECT P1.*, (P1.Jan + P1.Feb + P1.Mar + P1.Apr + P1.May + P1.Jun + P1.Jul + P1.Aug + P1.Sep + P1.Oct + P1.Nov + P1.[Dec]) 
AS YearTotal
FROM (SELECT Yr,
             SUM(CASE Mn WHEN 1   THEN Cnt ELSE 0 END) AS Jan,
             SUM(CASE Mn WHEN 2   THEN Cnt ELSE 0 END) AS Feb,
             SUM(CASE Mn WHEN 3   THEN Cnt ELSE 0 END) AS Mar,
             SUM(CASE Mn WHEN 4   THEN Cnt ELSE 0 END) AS Apr,
             SUM(CASE Mn WHEN 5   THEN Cnt ELSE 0 END) AS May,
             SUM(CASE Mn WHEN 6   THEN Cnt ELSE 0 END) AS Jun,
             SUM(CASE Mn WHEN 7   THEN Cnt ELSE 0 END) AS Jul,
             SUM(CASE Mn WHEN 8   THEN Cnt ELSE 0 END) AS Aug,
             SUM(CASE Mn WHEN 9   THEN Cnt ELSE 0 END) AS Sep,
             SUM(CASE Mn WHEN 10 THEN Cnt ELSE 0 END) AS Oct,
             SUM(CASE Mn WHEN 11 THEN Cnt ELSE 0 END) AS Nov,
             SUM(CASE Mn WHEN 12 THEN Cnt ELSE 0 END) AS [Dec]
     FROM #Temp AS P
     GROUP BY Yr   ) AS P1  ORDER BY  P1.Yr
GO
/****** Object:  StoredProcedure [dbo].[AdminPivotYrTotalNotActivated]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminPivotYrTotalNotActivated] AS

--drop table #temp
CREATE TABLE #Temp(	
	Yr int,
	Mn int,
	Dy int,
	Cnt int
)
INSERT INTO #Temp
SELECT   YEAR(dateregistered) as Yr,  MONTH(dateregistered) as Mn, DAY(dateregistered) as Dy, COUNT(dateregistered) as Cnt 
FROM Account  WITH (NOLOCK) WHERE Activated = 0
group by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered) 
order by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered)

--select * from #Temp

SELECT P1.*, (P1.Jan + P1.Feb + P1.Mar + P1.Apr + P1.May + P1.Jun + P1.Jul + P1.Aug + P1.Sep + P1.Oct + P1.Nov + P1.[Dec]) 
AS YearTotal
FROM (SELECT Yr,
             SUM(CASE Mn WHEN 1   THEN Cnt ELSE 0 END) AS Jan,
             SUM(CASE Mn WHEN 2   THEN Cnt ELSE 0 END) AS Feb,
             SUM(CASE Mn WHEN 3   THEN Cnt ELSE 0 END) AS Mar,
             SUM(CASE Mn WHEN 4   THEN Cnt ELSE 0 END) AS Apr,
             SUM(CASE Mn WHEN 5   THEN Cnt ELSE 0 END) AS May,
             SUM(CASE Mn WHEN 6   THEN Cnt ELSE 0 END) AS Jun,
             SUM(CASE Mn WHEN 7   THEN Cnt ELSE 0 END) AS Jul,
             SUM(CASE Mn WHEN 8   THEN Cnt ELSE 0 END) AS Aug,
             SUM(CASE Mn WHEN 9   THEN Cnt ELSE 0 END) AS Sep,
             SUM(CASE Mn WHEN 10 THEN Cnt ELSE 0 END) AS Oct,
             SUM(CASE Mn WHEN 11 THEN Cnt ELSE 0 END) AS Nov,
             SUM(CASE Mn WHEN 12 THEN Cnt ELSE 0 END) AS [Dec]
     FROM #Temp AS P
     GROUP BY Yr ) AS P1 ORDER BY  P1.Yr
GO
/****** Object:  StoredProcedure [dbo].[AdminPivotYrTotalActivated]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminPivotYrTotalActivated] AS

--drop table #temp
CREATE TABLE #Temp(	
	Yr int,
	Mn int,
	Dy int,
	Cnt int
)
INSERT INTO #Temp
SELECT   YEAR(dateregistered) as Yr,  MONTH(dateregistered) as Mn, DAY(dateregistered) as Dy, COUNT(dateregistered) as Cnt 
FROM Account  WITH (NOLOCK) WHERE Activated = 1
group by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered) 
order by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered)

--select * from #Temp

SELECT P1.*, (P1.Jan + P1.Feb + P1.Mar + P1.Apr + P1.May + P1.Jun + P1.Jul + P1.Aug + P1.Sep + P1.Oct + P1.Nov + P1.[Dec]) 
AS YearTotal
FROM (SELECT Yr,
             SUM(CASE Mn WHEN 1   THEN Cnt ELSE 0 END) AS Jan,
             SUM(CASE Mn WHEN 2   THEN Cnt ELSE 0 END) AS Feb,
             SUM(CASE Mn WHEN 3   THEN Cnt ELSE 0 END) AS Mar,
             SUM(CASE Mn WHEN 4   THEN Cnt ELSE 0 END) AS Apr,
             SUM(CASE Mn WHEN 5   THEN Cnt ELSE 0 END) AS May,
             SUM(CASE Mn WHEN 6   THEN Cnt ELSE 0 END) AS Jun,
             SUM(CASE Mn WHEN 7   THEN Cnt ELSE 0 END) AS Jul,
             SUM(CASE Mn WHEN 8   THEN Cnt ELSE 0 END) AS Aug,
             SUM(CASE Mn WHEN 9   THEN Cnt ELSE 0 END) AS Sep,
             SUM(CASE Mn WHEN 10 THEN Cnt ELSE 0 END) AS Oct,
             SUM(CASE Mn WHEN 11 THEN Cnt ELSE 0 END) AS Nov,
             SUM(CASE Mn WHEN 12 THEN Cnt ELSE 0 END) AS [Dec]
     FROM #Temp AS P
     GROUP BY Yr ) AS P1  ORDER BY  P1.Yr
GO
/****** Object:  StoredProcedure [dbo].[AdminPivotMonthTotalReg]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminPivotMonthTotalReg] AS

--drop table #temp
CREATE TABLE #Temp(	
	Yr int,
	Mn int,
	Dy int,
	Cnt int
)
INSERT INTO #Temp
SELECT   YEAR(dateregistered) as Yr,  MONTH(dateregistered) as Mn, DAY(dateregistered) as Dy, COUNT(dateregistered) as Cnt 
FROM Account  WITH (NOLOCK)group by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered) 
order by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered)

--select * from #Temp

SELECT P1.*, 
	(P1.D1 + P1.D2 + P1.D3 + P1.D4 + P1.D5 + P1.D6 + P1.D7 + P1.D8 + P1.D9 + P1.D10 + P1.D11 + P1.D12 +
	P1.D13 + P1.D14 + P1.D15 + P1.D16 + P1.D17 + P1.D18 + P1.D19 + P1.D20 + P1.D21 + P1.D22 + P1.D23 + P1.D24 +
	P1.D25 + P1.D26 + P1.D27 + P1.D28 + P1.D29 + P1.D30 + P1.D31) 
	
AS MonthTotal
FROM (SELECT Yr, Mn, 
             SUM(CASE Dy WHEN 1   THEN Cnt ELSE 0 END) AS D1,
             SUM(CASE Dy WHEN 2   THEN Cnt ELSE 0 END) AS D2,
             SUM(CASE Dy WHEN 3   THEN Cnt ELSE 0 END) AS D3,
             SUM(CASE Dy WHEN 4   THEN Cnt ELSE 0 END) AS D4,
             SUM(CASE Dy WHEN 5   THEN Cnt ELSE 0 END) AS D5,
             SUM(CASE Dy WHEN 6   THEN Cnt ELSE 0 END) AS D6,
             SUM(CASE Dy WHEN 7   THEN Cnt ELSE 0 END) AS D7,
             SUM(CASE Dy WHEN 8   THEN Cnt ELSE 0 END) AS D8,
             SUM(CASE Dy WHEN 9   THEN Cnt ELSE 0 END) AS D9,
             SUM(CASE Dy WHEN 10 THEN Cnt ELSE 0 END) AS D10,
             SUM(CASE Dy WHEN 11 THEN Cnt ELSE 0 END) AS D11,
             SUM(CASE Dy WHEN 12 THEN Cnt ELSE 0 END) AS D12,
             SUM(CASE Dy WHEN 13 THEN Cnt ELSE 0 END) AS D13,
             SUM(CASE Dy WHEN 14 THEN Cnt ELSE 0 END) AS D14,
             SUM(CASE Dy WHEN 15 THEN Cnt ELSE 0 END) AS D15,
             SUM(CASE Dy WHEN 16 THEN Cnt ELSE 0 END) AS D16,
             SUM(CASE Dy WHEN 17 THEN Cnt ELSE 0 END) AS D17,
             SUM(CASE Dy WHEN 18 THEN Cnt ELSE 0 END) AS D18,
             SUM(CASE Dy WHEN 19 THEN Cnt ELSE 0 END) AS D19,
             SUM(CASE Dy WHEN 20 THEN Cnt ELSE 0 END) AS D20,
             SUM(CASE Dy WHEN 21 THEN Cnt ELSE 0 END) AS D21,
             SUM(CASE Dy WHEN 22 THEN Cnt ELSE 0 END) AS D22,
             SUM(CASE Dy WHEN 23 THEN Cnt ELSE 0 END) AS D23,
             SUM(CASE Dy WHEN 24 THEN Cnt ELSE 0 END) AS D24,
             SUM(CASE Dy WHEN 25 THEN Cnt ELSE 0 END) AS D25,
             SUM(CASE Dy WHEN 26 THEN Cnt ELSE 0 END) AS D26,
             SUM(CASE Dy WHEN 27 THEN Cnt ELSE 0 END) AS D27,
             SUM(CASE Dy WHEN 28 THEN Cnt ELSE 0 END) AS D28,
             SUM(CASE Dy WHEN 29 THEN Cnt ELSE 0 END) AS D29,
             SUM(CASE Dy WHEN 30 THEN Cnt ELSE 0 END) AS D30,
             SUM(CASE Dy WHEN 31 THEN Cnt ELSE 0 END) AS D31
     FROM #Temp AS P
     GROUP BY Yr, Mn ) AS P1 ORDER BY  P1.Yr
GO
/****** Object:  StoredProcedure [dbo].[AdminPivotMonthTotalNotActivated]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminPivotMonthTotalNotActivated] AS

--drop table #temp
CREATE TABLE #Temp(	
	Yr int,
	Mn int,
	Dy int,
	Cnt int
)
INSERT INTO #Temp
SELECT   YEAR(dateregistered) as Yr,  MONTH(dateregistered) as Mn, DAY(dateregistered) as Dy, COUNT(dateregistered) as Cnt 
FROM Account  WITH (NOLOCK) WHERE Activated = 0
group by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered) 
order by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered)

--select * from #Temp

SELECT P1.*, 
	(P1.D1 + P1.D2 + P1.D3 + P1.D4 + P1.D5 + P1.D6 + P1.D7 + P1.D8 + P1.D9 + P1.D10 + P1.D11 + P1.D12 +
	P1.D13 + P1.D14 + P1.D15 + P1.D16 + P1.D17 + P1.D18 + P1.D19 + P1.D20 + P1.D21 + P1.D22 + P1.D23 + P1.D24 +
	P1.D25 + P1.D26 + P1.D27 + P1.D28 + P1.D29 + P1.D30 + P1.D31) 
	
AS MonthTotal
FROM (SELECT Yr, Mn, 
             SUM(CASE Dy WHEN 1   THEN Cnt ELSE 0 END) AS D1,
             SUM(CASE Dy WHEN 2   THEN Cnt ELSE 0 END) AS D2,
             SUM(CASE Dy WHEN 3   THEN Cnt ELSE 0 END) AS D3,
             SUM(CASE Dy WHEN 4   THEN Cnt ELSE 0 END) AS D4,
             SUM(CASE Dy WHEN 5   THEN Cnt ELSE 0 END) AS D5,
             SUM(CASE Dy WHEN 6   THEN Cnt ELSE 0 END) AS D6,
             SUM(CASE Dy WHEN 7   THEN Cnt ELSE 0 END) AS D7,
             SUM(CASE Dy WHEN 8   THEN Cnt ELSE 0 END) AS D8,
             SUM(CASE Dy WHEN 9   THEN Cnt ELSE 0 END) AS D9,
             SUM(CASE Dy WHEN 10 THEN Cnt ELSE 0 END) AS D10,
             SUM(CASE Dy WHEN 11 THEN Cnt ELSE 0 END) AS D11,
             SUM(CASE Dy WHEN 12 THEN Cnt ELSE 0 END) AS D12,
             SUM(CASE Dy WHEN 13 THEN Cnt ELSE 0 END) AS D13,
             SUM(CASE Dy WHEN 14 THEN Cnt ELSE 0 END) AS D14,
             SUM(CASE Dy WHEN 15 THEN Cnt ELSE 0 END) AS D15,
             SUM(CASE Dy WHEN 16 THEN Cnt ELSE 0 END) AS D16,
             SUM(CASE Dy WHEN 17 THEN Cnt ELSE 0 END) AS D17,
             SUM(CASE Dy WHEN 18 THEN Cnt ELSE 0 END) AS D18,
             SUM(CASE Dy WHEN 19 THEN Cnt ELSE 0 END) AS D19,
             SUM(CASE Dy WHEN 20 THEN Cnt ELSE 0 END) AS D20,
             SUM(CASE Dy WHEN 21 THEN Cnt ELSE 0 END) AS D21,
             SUM(CASE Dy WHEN 22 THEN Cnt ELSE 0 END) AS D22,
             SUM(CASE Dy WHEN 23 THEN Cnt ELSE 0 END) AS D23,
             SUM(CASE Dy WHEN 24 THEN Cnt ELSE 0 END) AS D24,
             SUM(CASE Dy WHEN 25 THEN Cnt ELSE 0 END) AS D25,
             SUM(CASE Dy WHEN 26 THEN Cnt ELSE 0 END) AS D26,
             SUM(CASE Dy WHEN 27 THEN Cnt ELSE 0 END) AS D27,
             SUM(CASE Dy WHEN 28 THEN Cnt ELSE 0 END) AS D28,
             SUM(CASE Dy WHEN 29 THEN Cnt ELSE 0 END) AS D29,
             SUM(CASE Dy WHEN 30 THEN Cnt ELSE 0 END) AS D30,
             SUM(CASE Dy WHEN 31 THEN Cnt ELSE 0 END) AS D31
     FROM #Temp AS P
     GROUP BY Yr, Mn ) AS P1  ORDER BY  P1.Yr
GO
/****** Object:  StoredProcedure [dbo].[AdminPivotMonthTotalActivated]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminPivotMonthTotalActivated] AS

--drop table #temp
CREATE TABLE #Temp(	
	Yr int,
	Mn int,
	Dy int,
	Cnt int
)
INSERT INTO #Temp
SELECT   YEAR(dateregistered) as Yr,  MONTH(dateregistered) as Mn, DAY(dateregistered) as Dy, COUNT(dateregistered) as Cnt 
FROM Account  WITH (NOLOCK) WHERE Activated = 1
group by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered) 
order by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered)

--select * from #Temp

SELECT P1.*, 
	(P1.D1 + P1.D2 + P1.D3 + P1.D4 + P1.D5 + P1.D6 + P1.D7 + P1.D8 + P1.D9 + P1.D10 + P1.D11 + P1.D12 +
	P1.D13 + P1.D14 + P1.D15 + P1.D16 + P1.D17 + P1.D18 + P1.D19 + P1.D20 + P1.D21 + P1.D22 + P1.D23 + P1.D24 +
	P1.D25 + P1.D26 + P1.D27 + P1.D28 + P1.D29 + P1.D30 + P1.D31) 
	
AS MonthTotal
FROM (SELECT Yr, Mn, 
             SUM(CASE Dy WHEN 1   THEN Cnt ELSE 0 END) AS D1,
             SUM(CASE Dy WHEN 2   THEN Cnt ELSE 0 END) AS D2,
             SUM(CASE Dy WHEN 3   THEN Cnt ELSE 0 END) AS D3,
             SUM(CASE Dy WHEN 4   THEN Cnt ELSE 0 END) AS D4,
             SUM(CASE Dy WHEN 5   THEN Cnt ELSE 0 END) AS D5,
             SUM(CASE Dy WHEN 6   THEN Cnt ELSE 0 END) AS D6,
             SUM(CASE Dy WHEN 7   THEN Cnt ELSE 0 END) AS D7,
             SUM(CASE Dy WHEN 8   THEN Cnt ELSE 0 END) AS D8,
             SUM(CASE Dy WHEN 9   THEN Cnt ELSE 0 END) AS D9,
             SUM(CASE Dy WHEN 10 THEN Cnt ELSE 0 END) AS D10,
             SUM(CASE Dy WHEN 11 THEN Cnt ELSE 0 END) AS D11,
             SUM(CASE Dy WHEN 12 THEN Cnt ELSE 0 END) AS D12,
             SUM(CASE Dy WHEN 13 THEN Cnt ELSE 0 END) AS D13,
             SUM(CASE Dy WHEN 14 THEN Cnt ELSE 0 END) AS D14,
             SUM(CASE Dy WHEN 15 THEN Cnt ELSE 0 END) AS D15,
             SUM(CASE Dy WHEN 16 THEN Cnt ELSE 0 END) AS D16,
             SUM(CASE Dy WHEN 17 THEN Cnt ELSE 0 END) AS D17,
             SUM(CASE Dy WHEN 18 THEN Cnt ELSE 0 END) AS D18,
             SUM(CASE Dy WHEN 19 THEN Cnt ELSE 0 END) AS D19,
             SUM(CASE Dy WHEN 20 THEN Cnt ELSE 0 END) AS D20,
             SUM(CASE Dy WHEN 21 THEN Cnt ELSE 0 END) AS D21,
             SUM(CASE Dy WHEN 22 THEN Cnt ELSE 0 END) AS D22,
             SUM(CASE Dy WHEN 23 THEN Cnt ELSE 0 END) AS D23,
             SUM(CASE Dy WHEN 24 THEN Cnt ELSE 0 END) AS D24,
             SUM(CASE Dy WHEN 25 THEN Cnt ELSE 0 END) AS D25,
             SUM(CASE Dy WHEN 26 THEN Cnt ELSE 0 END) AS D26,
             SUM(CASE Dy WHEN 27 THEN Cnt ELSE 0 END) AS D27,
             SUM(CASE Dy WHEN 28 THEN Cnt ELSE 0 END) AS D28,
             SUM(CASE Dy WHEN 29 THEN Cnt ELSE 0 END) AS D29,
             SUM(CASE Dy WHEN 30 THEN Cnt ELSE 0 END) AS D30,
             SUM(CASE Dy WHEN 31 THEN Cnt ELSE 0 END) AS D31
     FROM #Temp AS P
     GROUP BY Yr, Mn ) AS P1  ORDER BY  P1.Yr
GO
/****** Object:  StoredProcedure [dbo].[AdminGetUserRegistered]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminGetUserRegistered]
AS
SET NOCOUNT ON
SELECT   YEAR(dateregistered) as Year,  MONTH(dateregistered) as Month, DAY(dateregistered) as Day, COUNT(dateregistered) as Count 
FROM Account  WITH (NOLOCK)group by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered) 
order by YEAR(dateregistered), MONTH(dateregistered), DAY(dateregistered)
GO
/****** Object:  StoredProcedure [dbo].[AdminGetUserNotActivated]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminGetUserNotActivated]
AS
SET NOCOUNT ON

select YEAR(dateregistered) as Year, month(dateregistered) as Month, day(dateregistered) as Day, count(dateregistered) as Count 
from Account  WITH (NOLOCK) where activated = 0
group by YEAR(dateregistered),  month(dateregistered), day(dateregistered) 
order by YEAR(dateregistered), MONTH(dateregistered), day(dateregistered)
GO
/****** Object:  StoredProcedure [dbo].[AdminGetUserActivated]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminGetUserActivated]
AS
SET NOCOUNT ON

select YEAR(dateregistered) as Year, month(dateregistered) as Month, day(dateregistered) as Day, count(dateregistered) as Count 
from Account  WITH (NOLOCK) where activated = 1
group by YEAR(dateregistered), month(dateregistered), day(dateregistered) 
order by YEAR(dateregistered), MONTH(dateregistered), day(dateregistered)
GO
/****** Object:  StoredProcedure [dbo].[AdminGetTotalUser]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminGetTotalUser]
	@TotalRegister		AS INT OUTPUT,
	@TotalActivated 		AS INT OUTPUT,
	@TotalNotActivated 	AS INT OUTPUT
AS
SET NOCOUNT ON
SELECT  @TotalRegister 	= COUNT (*) FROM Account  WITH (NOLOCK)
SELECT  @TotalActivated 	= COUNT (*) FROM Account  WITH (NOLOCK) WHERE Activated = 1
SELECT  @TotalNotActivated 	= COUNT (*) FROM Account  WITH (NOLOCK) WHERE Activated = 0
GO
/****** Object:  StoredProcedure [dbo].[AdminGetBlockedAccountUserId_new]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROCEDURE [dbo].[AdminGetBlockedAccountUserId_new] 
	@UserId 	AS NVARCHAR(50),
	@Email	 	AS NVARCHAR(50) OUTPUT,
	@FirstName 	AS NVARCHAR(30) OUTPUT,
	@MI		AS NVARCHAR(1) OUTPUT,
	@LastName	AS NVARCHAR(30) OUTPUT,
	@Blocked	AS INT OUTPUT,
	@BlockedDate	AS DATETIME OUTPUT,
	@BlockedEndDate AS DATETIME OUTPUT,
	@Birthday	AS DATETIME OUTPUT,
	@Address	AS NVARCHAR(100) OUTPUT,
	@City		AS NVARCHAR(50) OUTPUT,
	@State		AS NVARCHAR(50) OUTPUT,
	@Country	AS NVARCHAR(50) OUTPUT,
	@RegIPAddress   AS NVARCHAR(15) OUTPUT,
	@DateRegistered AS DATETIME OUTPUT,
	@Activated      AS INT OUTPUT,
	@result 	AS INT OUTPUT,
	@ID 		AS INT OUTPUT
AS
SELECT @Email=Email, @FirstName=FirstName, @MI=MI, @LastName=LastName,
	@Blocked=Blocked, @BlockedDate=BlockedDate, @BlockedEndDate=BlockedEndDate, 
	@Birthday=Birthday, @Address=Address, @City=City, @State=State, 
	@Country=Country, @RegIPAddress=RegIPAddress, @DateRegistered=DateRegistered, @Activated=Activated, @ID = [ID]
FROM Account WITH (NOLOCK)
WHERE UserId = @UserId
IF @@ROWCOUNT = 1
	SET @result = 1 --Found
ELSE
	SET @result = 0 --Not found
GO
/****** Object:  StoredProcedure [dbo].[AdminGetBlockedAccountUserId]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROCEDURE [dbo].[AdminGetBlockedAccountUserId] 
	@UserId 	AS NVARCHAR(50),
	@Email	 	AS NVARCHAR(50) OUTPUT,
	@FirstName 	AS NVARCHAR(30) OUTPUT,
	@MI		AS NVARCHAR(1) OUTPUT,
	@LastName	AS NVARCHAR(30) OUTPUT,
	@Blocked	AS INT OUTPUT,
	@BlockedDate	AS DATETIME OUTPUT,
	@BlockedEndDate AS DATETIME OUTPUT,
	@Birthday	AS DATETIME OUTPUT,
	@Address	AS NVARCHAR(100) OUTPUT,
	@City		AS NVARCHAR(50) OUTPUT,
	@State		AS NVARCHAR(50) OUTPUT,
	@Country	AS NVARCHAR(50) OUTPUT,
	@RegIPAddress  AS NVARCHAR(15) OUTPUT,
	@DateRegistered AS DATETIME OUTPUT,
	@result 		AS INT OUTPUT,
	@ID 		AS INT OUTPUT
AS
SELECT @Email=Email, @FirstName=FirstName, @MI=MI, @LastName=LastName,
	@Blocked=Blocked, @BlockedDate=BlockedDate, @BlockedEndDate=BlockedEndDate, 
	@Birthday=Birthday, @Address=Address, @City=City, @State=State, 
	@Country=Country, @RegIPAddress=RegIPAddress, @DateRegistered=DateRegistered, @ID = [ID]
FROM Account WITH (NOLOCK)
WHERE UserId = @UserId
IF @@ROWCOUNT = 1
	SET @result = 1 --Found
ELSE
	SET @result = 0 --Not found
GO
/****** Object:  StoredProcedure [dbo].[AdminGetBlockedAccountEmail_new]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AdminGetBlockedAccountEmail_new]
	@Email	 	AS NVARCHAR(50) ,
	@UserId 	AS NVARCHAR(50) OUTPUT,
	@FirstName 	AS NVARCHAR(30) OUTPUT,
	@MI		AS NVARCHAR(1) OUTPUT,
	@LastName	AS NVARCHAR(30) OUTPUT,
	@Blocked	AS INT OUTPUT,
	@BlockedDate	AS DATETIME OUTPUT,
	@BlockedEndDate AS DATETIME OUTPUT,
	@Birthday	AS DATETIME OUTPUT,
	@Address	AS NVARCHAR(100) OUTPUT,
	@City		AS NVARCHAR(50) OUTPUT,
	@State		AS NVARCHAR(50) OUTPUT,
	@Country	AS NVARCHAR(50) OUTPUT,
	@RegIPAddress  AS NVARCHAR(15) OUTPUT,
	@DateRegistered AS DATETIME OUTPUT,
	@Activated      AS INT OUTPUT,
	@result 	AS INT OUTPUT,
	@ID 		AS INT OUTPUT
AS
SELECT @UserId=UserId, @FirstName=FirstName, @MI=MI, @LastName=LastName,
	@Blocked=Blocked, @BlockedDate=BlockedDate, @BlockedEndDate=BlockedEndDate, 
	@Birthday=Birthday, @Address=Address, @City=City, @State=State, 
	@Country=Country, @RegIPAddress=RegIPAddress, @DateRegistered=DateRegistered, @Activated=Activated, @ID = [ID]
FROM Account WITH (NOLOCK)
WHERE Email = @Email
IF @@ROWCOUNT = 1
	SET @result = 1 --Found
ELSE
	SET @result = 0 --Not found
GO
/****** Object:  StoredProcedure [dbo].[AdminGetBlockedAccountEmail]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROCEDURE [dbo].[AdminGetBlockedAccountEmail]
	@Email	 	AS NVARCHAR(50) ,
	@UserId 	AS NVARCHAR(50) OUTPUT,
	@FirstName 	AS NVARCHAR(30) OUTPUT,
	@MI		AS NVARCHAR(1) OUTPUT,
	@LastName	AS NVARCHAR(30) OUTPUT,
	@Blocked	AS INT OUTPUT,
	@BlockedDate	AS DATETIME OUTPUT,
	@BlockedEndDate AS DATETIME OUTPUT,
	@Birthday	AS DATETIME OUTPUT,
	@Address	AS NVARCHAR(100) OUTPUT,
	@City		AS NVARCHAR(50) OUTPUT,
	@State		AS NVARCHAR(50) OUTPUT,
	@Country	AS NVARCHAR(50) OUTPUT,
	@RegIPAddress  AS NVARCHAR(15) OUTPUT,
	@DateRegistered AS DATETIME OUTPUT,
	@result 		AS INT OUTPUT,
	@ID 		AS INT OUTPUT
AS
SELECT @UserId=UserId, @FirstName=FirstName, @MI=MI, @LastName=LastName,
	@Blocked=Blocked, @BlockedDate=BlockedDate, @BlockedEndDate=BlockedEndDate, 
	@Birthday=Birthday, @Address=Address, @City=City, @State=State, 
	@Country=Country, @RegIPAddress=RegIPAddress, @DateRegistered=DateRegistered, @ID = [ID]
FROM Account WITH (NOLOCK)
WHERE Email = @Email
IF @@ROWCOUNT = 1
	SET @result = 1 --Found
ELSE
	SET @result = 0 --Not found
GO
/****** Object:  StoredProcedure [dbo].[AccountUpdateProfileInBilling]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
--Programmer/DBA: Richard Tibang chardtc@yahoo.com
/* Function:  Update user information in billing db*/
CREATE PROCEDURE [dbo].[AccountUpdateProfileInBilling]
	@Email	 	NVARCHAR(50), -- Email as key
	@NCashResult 	INT OUTPUT,
	@NCashMsg    	NVARCHAR(100) OUTPUT

AS
DECLARE @UserID 	NVARCHAR(50),
	@Lastname	NVARCHAR(30),
	@MI		NVARCHAR(1),
	@Firstname	NVARCHAR(30),
	@UserKey	NVARCHAR(7),
	@Sex		INT,
	@Birthday	DATETIME,
	@Address	NVARCHAR(100),
	@HomeNo	NVARCHAR(15),
	@Country	NVARCHAR(50),
	@City		NVARCHAR(50),
	@State		NVARCHAR(50),
	@SecretQuestion NVARCHAR(50),
	@Answer	NVARCHAR(50),
	@MobileNo	NVARCHAR(15)

SELECT @UserID=UserID, @Lastname=Lastname, @MI=MI, @Firstname=Firstname, @UserKey=UserKey, @Sex=Sex, @Birthday=Birthday, 
	@Address=Address, @HomeNo=HomeNo, @Email=Email, @Country=Country, @City=City, @State=State, 
	@SecretQuestion=SecretQuestion, @Answer=Answer, @MobileNo=MobileNo
FROM Account WHERE Email = @Email

EXEC [BILLINGDB].BillCrux_Phil.dbo.procUpdateUser

	@userId	
,	@userKey
,	@firstName
,	@mi
,	@lastName
,	@sex
,	1 -- @gameServiceId
,	@birthday
,	@Country --@nation
,	@city
,	@state
,	@address
,	@HomeNo --@phoneNumber
,	@Email
,	@SecretQuestion -- @passwordCheckQuestionTypeId
,	@Answer --@passwordCheckAnswer	
,	@MobileNo -- @handPhoneNumber
,	'' --@jobTypeId
,	0 --@getMail
,	@NCashResult OUTPUT
GO
/****** Object:  StoredProcedure [dbo].[AccountUpdateProfileFromBilling]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
--Programmer/DBA: Richard Tibang chardtc@yahoo.com
/* Function:  Update user information FROM Billing db. When customer service/admin update the information using NCash tool. */
CREATE PROC [dbo].[AccountUpdateProfileFromBilling]

	@UserID as nvarchar (50)  ,
	@UserKey nvarchar (7)  ,
	@SecretQuestion nvarchar (50)  ,
	@Answer nvarchar (50)  ,
	@Firstname nvarchar (30)  ,
	@MI nvarchar (1)  ,
	@Lastname nvarchar (30)  ,
	@Birthday datetime ,
	@Sex tinyint ,
	@Address nvarchar (100)  ,
	@City nvarchar (50)  ,
	@State nvarchar (50) ,
	@Country nvarchar (50)  ,
	@MobileNo nvarchar (15)  ,
	@HomeNo nvarchar (15)  ,
	@email as nvarchar (50) ,
	@result AS INT OUTPUT
AS
SET NOCOUNT ON
-------------------------------------
IF (@UserID IS NULL) OR (@UserID = '')
BEGIN
	SET @result = -99
	RETURN 
END
IF NOT EXISTS ( SELECT * FROM Account WHERE UserID = @UserID)
BEGIN
	SET @result = -99
	RETURN 
END
IF EXISTS (SELECT Email FROM Account WHERE UserID != @UserID AND Email = @email) /* Email already exist */
BEGIN
	SET @result = -99
	RETURN 	
END

UPDATE 	Account SET  UserKey = @UserKey, SecretQuestion = @SecretQuestion,
	Answer = @Answer, Firstname = @Firstname, MI = @MI, Lastname = @Lastname ,
	Birthday = @Birthday, Sex = @Sex, Address  = @Address, City = @City,
	State = @State, Country  = @Country, MobileNo  = @MobileNo, HomeNo  = @HomeNo,
	Email = @email
WHERE UserID = @UserID
IF @@ERROR = 0
	SET @result = 0
ELSE
	SET @result = -99
GO
/****** Object:  StoredProcedure [dbo].[AccountUpdateProfile_Old]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[AccountUpdateProfile_Old]
	@Email		AS NVARCHAR(50), 
	@UserID	AS NVARCHAR(50), 
	@Birthday	AS DATETIME,
	@Sex		AS INT,
	@Address	AS NVARCHAR(100),
	@City		AS NVARCHAR(50),
	@State		AS NVARCHAR(50),
	@Country	AS NVARCHAR(50),
	@MobileNo	AS NVARCHAR(15),
	@HomeNo	AS NVARCHAR(15),
	@result 		AS INT OUTPUT,
	@UserKey	AS NVARCHAR(7)
AS
SET NOCOUNT ON
-------------------------------------
IF EXISTS (SELECT * FROM Account WITH (NOLOCK) WHERE UserID = @UserID AND Email != @Email)
	SET @result = -101 --User id exist already
ELSE IF EXISTS (SELECT * FROM Account WITH (NOLOCK) WHERE UserID = @UserID AND Email = @Email)
BEGIN
	--User Id already updated, update only the profile
	UPDATE Account SET  Birthday= @Birthday, Sex = @Sex,
		Address = @Address, City = @City,
		State = @State, Country = @country,
		MobileNo = @MobileNo,	HomeNo = @HomeNo, UserKey = @UserKey 
	WHERE Email = @Email
	SET @result = 0
END
ELSE -- Update user id now
BEGIN

	UPDATE Account SET  Birthday= @Birthday, Sex = @Sex,
		Address = @Address, City = @City,
		State = @State, Country = @country,
		MobileNo = @MobileNo,	HomeNo = @HomeNo, UserKey = @UserKey  
	WHERE Email = @Email
	SET @result = 0

---	EXEC [BILLINGDB].BillCrux_Phil.dbo.procUpdateUser

END
GO
/****** Object:  StoredProcedure [dbo].[BugCritical]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[BugCritical]
	@BugId 	AS INT
AS
SET NOCOUNT ON
UPDATE BugReport SET Qualified = 6, ActionTime = GETDATE() WHERE BugID  = @BugId
GO
/****** Object:  StoredProcedure [dbo].[BlockDetailsAdd]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[BlockDetailsAdd]
	@UserID		VARCHAR(50),
	@Email			VARCHAR(50),
	@ImgName1		VARCHAR(25),
	@Img1 			Image, 
	@TImg1		Image, 
	@ImgCnt1		VARCHAR(25),

	@ImgName2 		VARCHAR(25),
	@Img2	 		Image, 
	@TImg2		Image, 
	@ImgCnt2		VARCHAR(25),

	@ImgName3 		VARCHAR(25),
	@Img3	 		Image, 
	@TImg3		Image, 
	@ImgCnt3		VARCHAR(25),

	@Description		VARCHAR(1000),
	@GMUserID		VARCHAR(50),
	@StartDate		DateTime,
	@EndDate		DateTime,
	@Penalty		VARCHAR(25),

	@result int output
AS 
 SET @result = 0
 SET NOCOUNT ON

 INSERT INTO Blocked_Accounts_Details (UserID,  Email, 
	ImgName1, Img1, TImg1, ImgCnt1, 
	ImgName2, Img2, TImg2, ImgCnt2, 
	ImgName3, Img3, TImg3, ImgCnt3, 
	[Description], GMUserID, StartDate, EndDate, Penalty)
  VALUES (@UserID,  @Email,
	@ImgName1, @Img1, @TImg1, @ImgCnt1,
	@ImgName2, @Img2, @TImg2, @ImgCnt2,
	@ImgName3, @Img3, @TImg3, @ImgCnt3,
	@Description, @GMUserID, @StartDate, @EndDate, @Penalty)
  IF @@ERROR <> 0
	SET @result = -99 --DB SP Error
GO
/****** Object:  StoredProcedure [dbo].[AdminBlockedAccount]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/* DBA/System Developer: Richard Tibang */
CREATE PROC [dbo].[AdminBlockedAccount]  
	@ID 	AS INT,
	@Blocked	AS INT, /* 0 = Normal,	1 = Blocked */
	@BlockedEndDate	AS DATETIME 
AS

IF @Blocked = 1
BEGIN
	/* Blocked user */
	UPDATE Account SET Blocked = @Blocked, BlockedDate = GETDATE(),  BlockedEndDate = @BlockedEndDate
	WHERE [ID] = @ID
END
ELSE IF @Blocked = 0
BEGIN
	/* Unblocked user */
	UPDATE Account SET Blocked = @Blocked,  BlockedEndDate = NULL, UnBlockedDate = GETDATE()
	WHERE [ID] = @ID	
END
GO
/****** Object:  StoredProcedure [dbo].[AccountUpdateUserID_Old]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
--Programmer/DBA: Richard Tibang chardtc@yahoo.com
CREATE PROC [dbo].[AccountUpdateUserID_Old]
	@Email		AS NVARCHAR(50), 
	@UserID	AS NVARCHAR(50), 	
	@result 		AS INT OUTPUT
AS
SET NOCOUNT ON
DECLARE @NCashResult INT, @NCashMsg NVARCHAR(50)
IF EXISTS (SELECT UserID FROM Account WITH (NOLOCK) WHERE UserID = @UserID)
BEGIN
	SET @result = -1
	RETURN--exit	
END

UPDATE Account SET  UserID = @UserID WHERE Email = @Email
IF @@ROWCOUNT = 1
BEGIN 
	SET @result = 0
END
ELSE
	SET @result = -1
GO
/****** Object:  StoredProcedure [dbo].[CouncilGetCandidate]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CouncilGetCandidate]  AS

--SELECT * FROM Council WHERE Selected  = 1 ORDER BY UserId
SELECT * FROM Candidate ORDER BY Candidate
GO
/****** Object:  StoredProcedure [dbo].[CouncilAdd]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CouncilAdd] 
	@UserId	AS NVARCHAR(50),
	@Server1	AS NVARCHAR(50),
	@Character1	AS NVARCHAR(50),
	@Level1		AS NVARCHAR(3),
	@Server2	AS NVARCHAR(50),
	@Character2	AS NVARCHAR(50),
	@Level2		AS NVARCHAR(3),
	@Server3	AS NVARCHAR(50),
	@Character3	AS NVARCHAR(50),
	@Level3		AS NVARCHAR(3),
	@result 		AS INT OUTPUT 
AS

IF EXISTS (SELECT * FROM Council WHERE UserId = @UserId)
BEGIN
	UPDATE Council SET UserId=@UserId, 
		Server1=@Server1, Character1=@Character1, Level1=@Level1, 
		Server2=@Server2, Character2=@Character2, Level2=@Level2, 
		Server3=@Server3, Character3=@Character3, Level3=@Level3
	WHERE UserId = @UserId	
	SET @result = 1
	RETURN
END
ELSE IF NOT EXISTS (SELECT * FROM Council WHERE UserId = @UserId)
BEGIN
	INSERT INTO Council (UserId, Server1, Character1, Level1, Server2, Character2, Level2, Server3, Character3, Level3)
	VALUES (@UserId, @Server1, @Character1, @Level1, @Server2, @Character2, @Level2, @Server3, @Character3, @Level3)
	SET @result = 0
	RETURN
END


SET @result = -99
GO
/****** Object:  StoredProcedure [dbo].[checkIfProductExists]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[checkIfProductExists]
	@productTypeId	AS INT,
	@PID	AS INT
AS

DECLARE @Display TINYINT
SET @Display = 1 -- show all 1

SELECT PID, productId, productName, productAmount
FROM tblProduct WITH(READUNCOMMITTED)
WHERE productTypeId = @productTypeId
AND PID = @PID
AND Display  = @Display
GO
/****** Object:  StoredProcedure [dbo].[CitiesGetAll]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[CitiesGetAll] AS

SELECT ID, CityName FROM Cities WITH (NOLOCK)
GO
/****** Object:  StoredProcedure [dbo].[BugWebPagedSelectedItems]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BugWebPagedSelectedItems]
	(
	 @Page int,
	 @RecsPerPage int,
	 @Status int
	)
AS
-- We don't want to return the # of rows inserted
-- into our temporary table, so turn NOCOUNT ON
SET NOCOUNT ON

--Create a temporary table
CREATE TABLE #TempItems
(
	ID int IDENTITY,
	BugID INT,
	UserID varchar(50),
	DateSubmitted DATETIME,
	Description varchar(3000),
	ImgName1 varchar(50),
	ImgName2 varchar(50),
	ImgName3 varchar(50),
	Fixed		BIT,
	Qualified	SMALLINT
)
/*
ALTER TABLE #TempItems WITH NOCHECK ADD 
	CONSTRAINT [PK_ID] PRIMARY KEY  CLUSTERED 
	(
		[ID]
	)  ON [PRIMARY] 
*/
--SET IDENTITY_INSERT #TempItems ON

-- Insert the rows from tblItems into the temp. table
IF @Status = -99 --Select all 
BEGIN
	INSERT INTO #TempItems (BugID, UserID, DateSubmitted, [Description],
			ImgName1, ImgName2, 	ImgName3, Fixed, Qualified)
	
	SELECT b.BugID, a.UserID, b.DateSubmitted, b.Description,
		b.ImgName1, b.ImgName2, b.ImgName3, b.Fixed, b.Qualified
	FROM BugReport  AS b  INNER JOIN Account  AS a ON b.AccountID = a.[ID] order by BugId DESC
END
ELSE
BEGIN
	INSERT INTO #TempItems (BugID, UserID, DateSubmitted, [Description],
			ImgName1, ImgName2, 	ImgName3, Fixed, Qualified)
	
	SELECT b.BugID, a.UserID, b.DateSubmitted, b.Description,
		b.ImgName1, b.ImgName2, b.ImgName3, b.Fixed, b.Qualified
	FROM BugReport  AS b  INNER JOIN Account  AS a ON b.AccountID = a.[ID] 
	WHERE Qualified = @Status
	ORDER BY BugId DESC
END

-- Find out the first and last record we want
DECLARE @FirstRec int, @LastRec int
SELECT @FirstRec = (@Page - 1) * @RecsPerPage
SELECT @LastRec = (@Page * @RecsPerPage + 1)

-- Now, return the set of paged records, plus, an indication of we
-- have more records or not!
SELECT *,
       MoreRecords = 
	(
	 SELECT COUNT(*) 
	 FROM #TempItems TI
	 WHERE TI.ID >= @LastRec
	) 
FROM #TempItems
WHERE ID > @FirstRec AND ID < @LastRec
--ORDER BY DateSubmitted DESC
GO
/****** Object:  StoredProcedure [dbo].[BugWebPagedItems]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BugWebPagedItems]
	(
	 @Page int,
	 @RecsPerPage int
	)
AS
-- We don't want to return the # of rows inserted
-- into our temporary table, so turn NOCOUNT ON
SET NOCOUNT ON

--Create a temporary table
CREATE TABLE #TempItems
(
	ID int IDENTITY,
	BugID INT,
	UserID varchar(50),
	DateSubmitted DATETIME,
	Description varchar(3000),
	ImgName1 varchar(50),
	ImgName2 varchar(50),
	ImgName3 varchar(50),
	Fixed		BIT,
	Qualified	SMALLINT
)
/*
ALTER TABLE #TempItems WITH NOCHECK ADD 
	CONSTRAINT [PK_ID] PRIMARY KEY  CLUSTERED 
	(
		[ID]
	)  ON [PRIMARY] 
*/
--SET IDENTITY_INSERT #TempItems ON

-- Insert the rows from tblItems into the temp. table
INSERT INTO #TempItems (BugID, UserID, DateSubmitted, [Description],
		ImgName1, ImgName2, 	ImgName3, Fixed, Qualified)

SELECT b.BugID, a.UserID, b.DateSubmitted, b.Description,
	b.ImgName1, b.ImgName2, b.ImgName3, b.Fixed, b.Qualified
FROM BugReport  AS b  INNER JOIN Account  AS a ON b.AccountID = a.[ID] order by BugId DESC

-- Find out the first and last record we want
DECLARE @FirstRec int, @LastRec int
SELECT @FirstRec = (@Page - 1) * @RecsPerPage
SELECT @LastRec = (@Page * @RecsPerPage + 1)

-- Now, return the set of paged records, plus, an indication of we
-- have more records or not!
SELECT *,
       MoreRecords = 
	(
	 SELECT COUNT(*) 
	 FROM #TempItems TI
	 WHERE TI.ID >= @LastRec
	) 
FROM #TempItems
WHERE ID > @FirstRec AND ID < @LastRec
--ORDER BY DateSubmitted DESC
GO
/****** Object:  StoredProcedure [dbo].[BugReportAdd]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[BugReportAdd]
	@AccountID		INT,
	@Description		VARCHAR(3000),
	@ImgName1 		VARCHAR(50),
	@ImgBin1 		Image, 
	@ImgTmbBin1		Image, 
	@ImgContentType1 	VARCHAR(50),

	@ImgName2 		VARCHAR(50),
	@ImgBin2 		Image, 
	@ImgTmbBin2		Image, 
	@ImgContentType2 	VARCHAR(50),

	@ImgName3 		VARCHAR(50),
	@ImgBin3 		Image, 
	@ImgTmbBin3		Image, 
	@ImgContentType3 	VARCHAR(50),

	@result int output
AS 
 SET @result = 0
 SET NOCOUNT ON

 INSERT INTO BugReport ([Description],  AccountID, 
	ImgName1, ImgBin1, ImgTmbBin1, ImgContentType1,  
	ImgName2, ImgBin2, ImgTmbBin2, ImgContentType2,
	ImgName3, ImgBin3, ImgTmbBin3, ImgContentType3, Qualified )
  VALUES (@Description,  @AccountID,
	@ImgName1, @ImgBin1, @ImgTmbBin1, @ImgContentType1,
	@ImgName2, @ImgBin2, @ImgTmbBin2, @ImgContentType2,
	@ImgName3, @ImgBin3, @ImgTmbBin3, @ImgContentType3,  -1  ) /* -1 Default value "Not Check"	*/
  IF @@ERROR <> 0
	SET @result = -99 --DB SP Error
GO
/****** Object:  StoredProcedure [dbo].[BugGetFixedUnfixedQualified]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BugGetFixedUnfixedQualified] 
	@Fixed AS INT OUTPUT, 
	@UnFixed AS INT OUTPUT,
	@Qualified AS INT OUTPUT,
	@UnQualified AS INT OUTPUT,
	@Duplicate AS INT OUTPUT
AS
SET NOCOUNT ON

SELECT @Fixed 	     = COUNT(*) FROM BugReport WITH (NOLOCK) WHERE Fixed = 1
SELECT @UnFixed   = COUNT(*) FROM BugReport WITH (NOLOCK) WHERE Fixed = 0
SELECT @Qualified  = COUNT(*) FROM BugReport WITH (NOLOCK) WHERE Qualified = 1
SELECT @UnQualified  = COUNT(*) FROM BugReport WITH (NOLOCK) WHERE Qualified = 0
SELECT @Duplicate = COUNT(*) FROM BugReport WITH (NOLOCK) WHERE Qualified = 2
GO
/****** Object:  StoredProcedure [dbo].[BugGetDescription]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[BugGetDescription]
	@BugId 	AS INT,
	@Description  	AS NVARCHAR(3000) OUTPUT
AS
SET NOCOUNT ON
SELECT @Description = [Description] FROM BugReport WHERE BugId = @BugId
GO
/****** Object:  StoredProcedure [dbo].[BugFixed]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[BugFixed]
	@BugId 	AS INT
--	@IsFixed 	AS INT /* 1= fixed, 0 unfixed */
AS
SET NOCOUNT ON
--UPDATE BugReport SET Fixed = @IsFixed WHERE BugID  = @BugId
UPDATE BugReport SET Qualified = 3, ActionTime = GETDATE() WHERE BugID  = @BugId
GO
/****** Object:  StoredProcedure [dbo].[BugDuplicate]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[BugDuplicate]
	@BugId 	AS INT
AS
SET NOCOUNT ON
UPDATE BugReport SET Qualified = 2, ActionTime = GETDATE() WHERE BugID  = @BugId
GO
/****** Object:  StoredProcedure [dbo].[BugQualified]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[BugQualified]
	@BugId 	AS INT
AS
SET NOCOUNT ON
UPDATE BugReport SET Qualified = 1, ActionTime = GETDATE() WHERE BugID  = @BugId
GO
/****** Object:  StoredProcedure [dbo].[BugPending]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[BugPending]
	@BugId 	AS INT
AS
SET NOCOUNT ON
UPDATE BugReport SET Qualified = 4, ActionTime = GETDATE() WHERE BugID  = @BugId
GO
/****** Object:  StoredProcedure [dbo].[BugPagedSelectedItemsByBugID]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BugPagedSelectedItemsByBugID]
	(
	 @Page int,
	 @RecsPerPage int,
	 @Status int,
	 @BugID INT
	)
AS
-- We don't want to return the # of rows inserted
-- into our temporary table, so turn NOCOUNT ON
SET NOCOUNT ON

--Create a temporary table
CREATE TABLE #TempItems
(
	ID int IDENTITY,
	BugID INT,
	Email varchar(50),
	DateSubmitted DATETIME,
	Description varchar(3000),
	ImgName1 varchar(50),
	ImgName2 varchar(50),
	ImgName3 varchar(50),
	Fixed		BIT,
	Qualified	SMALLINT
)
/*
ALTER TABLE #TempItems WITH NOCHECK ADD 
	CONSTRAINT [PK_ID] PRIMARY KEY  CLUSTERED 
	(
		[ID]
	)  ON [PRIMARY] 
*/
--SET IDENTITY_INSERT #TempItems ON

-- Insert the rows from tblItems into the temp. table
IF @Status = -99 --Select all 
BEGIN
	INSERT INTO #TempItems (BugID, Email, DateSubmitted, [Description],
			ImgName1, ImgName2, 	ImgName3, Fixed, Qualified)
	
	SELECT b.BugID, a.Email, b.DateSubmitted, b.Description,
		b.ImgName1, b.ImgName2, b.ImgName3, b.Fixed, b.Qualified
	FROM BugReport  AS b  INNER JOIN Account  AS a ON b.AccountID = a.[ID] 
	WHERE BugID = @BugID
	order by BugId DESC
END
ELSE
BEGIN
	INSERT INTO #TempItems (BugID, Email, DateSubmitted, [Description],
			ImgName1, ImgName2, 	ImgName3, Fixed, Qualified)
	
	SELECT b.BugID, a.Email, b.DateSubmitted, b.Description,
		b.ImgName1, b.ImgName2, b.ImgName3, b.Fixed, b.Qualified
	FROM BugReport  AS b  INNER JOIN Account  AS a ON b.AccountID = a.[ID] 
	WHERE Qualified = @Status AND 	 BugID = @BugID
	--ORDER BY BugId DESC
	ORDER BY ActionTime DESC
END

-- Find out the first and last record we want
DECLARE @FirstRec int, @LastRec int
SELECT @FirstRec = (@Page - 1) * @RecsPerPage
SELECT @LastRec = (@Page * @RecsPerPage + 1)

-- Now, return the set of paged records, plus, an indication of we
-- have more records or not!
SELECT *,
       MoreRecords = 
	(
	 SELECT COUNT(*) 
	 FROM #TempItems TI
	 WHERE TI.ID >= @LastRec
	) 
FROM #TempItems
WHERE ID > @FirstRec AND ID < @LastRec
--ORDER BY DateSubmitted DESC
GO
/****** Object:  StoredProcedure [dbo].[BugPagedSelectedItems]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BugPagedSelectedItems]
	(
	 @Page int,
	 @RecsPerPage int,
	 @Status int
	)
AS
-- We don't want to return the # of rows inserted
-- into our temporary table, so turn NOCOUNT ON
SET NOCOUNT ON

--Create a temporary table
CREATE TABLE #TempItems
(
	ID int IDENTITY,
	BugID INT,
	Email varchar(50),
	DateSubmitted DATETIME,
	Description varchar(3000),
	ImgName1 varchar(50),
	ImgName2 varchar(50),
	ImgName3 varchar(50),
	Fixed		BIT,
	Qualified	SMALLINT
)
/*
ALTER TABLE #TempItems WITH NOCHECK ADD 
	CONSTRAINT [PK_ID] PRIMARY KEY  CLUSTERED 
	(
		[ID]
	)  ON [PRIMARY] 
*/
--SET IDENTITY_INSERT #TempItems ON

-- Insert the rows from tblItems into the temp. table
IF @Status = -99 --Select all 
BEGIN
	INSERT INTO #TempItems (BugID, Email, DateSubmitted, [Description],
			ImgName1, ImgName2, 	ImgName3, Fixed, Qualified)
	
	SELECT b.BugID, a.Email, b.DateSubmitted, b.Description,
		b.ImgName1, b.ImgName2, b.ImgName3, b.Fixed, b.Qualified
	FROM BugReport  AS b  INNER JOIN Account  AS a ON b.AccountID = a.[ID] order by BugId DESC
END
ELSE
BEGIN
	INSERT INTO #TempItems (BugID, Email, DateSubmitted, [Description],
			ImgName1, ImgName2, 	ImgName3, Fixed, Qualified)
	
	SELECT b.BugID, a.Email, b.DateSubmitted, b.Description,
		b.ImgName1, b.ImgName2, b.ImgName3, b.Fixed, b.Qualified
	FROM BugReport  AS b  INNER JOIN Account  AS a ON b.AccountID = a.[ID] 
	WHERE Qualified = @Status
	--ORDER BY BugId DESC
	ORDER BY ActionTime DESC
END

-- Find out the first and last record we want
DECLARE @FirstRec int, @LastRec int
SELECT @FirstRec = (@Page - 1) * @RecsPerPage
SELECT @LastRec = (@Page * @RecsPerPage + 1)

-- Now, return the set of paged records, plus, an indication of we
-- have more records or not!
SELECT *,
       MoreRecords = 
	(
	 SELECT COUNT(*) 
	 FROM #TempItems TI
	 WHERE TI.ID >= @LastRec
	) 
FROM #TempItems
WHERE ID > @FirstRec AND ID < @LastRec
--ORDER BY DateSubmitted DESC
GO
/****** Object:  StoredProcedure [dbo].[BugPagedItems]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BugPagedItems]
	(
	 @Page int,
	 @RecsPerPage int
	)
AS
-- We don't want to return the # of rows inserted
-- into our temporary table, so turn NOCOUNT ON
SET NOCOUNT ON

--Create a temporary table
CREATE TABLE #TempItems
(
	ID int IDENTITY,
	BugID INT,
	Email varchar(50),
	DateSubmitted DATETIME,
	Description varchar(3000),
	ImgName1 varchar(50),
	ImgName2 varchar(50),
	ImgName3 varchar(50),
	Fixed		BIT,
	Qualified	SMALLINT
)
/*
ALTER TABLE #TempItems WITH NOCHECK ADD 
	CONSTRAINT [PK_ID] PRIMARY KEY  CLUSTERED 
	(
		[ID]
	)  ON [PRIMARY] 
*/
--SET IDENTITY_INSERT #TempItems ON

-- Insert the rows from tblItems into the temp. table
INSERT INTO #TempItems (BugID, Email, DateSubmitted, [Description],
		ImgName1, ImgName2, 	ImgName3, Fixed, Qualified)

SELECT b.BugID, a.Email, b.DateSubmitted, b.Description,
	b.ImgName1, b.ImgName2, b.ImgName3, b.Fixed, b.Qualified
FROM BugReport  AS b  INNER JOIN Account  AS a ON b.AccountID = a.[ID] order by BugId DESC

-- Find out the first and last record we want
DECLARE @FirstRec int, @LastRec int
SELECT @FirstRec = (@Page - 1) * @RecsPerPage
SELECT @LastRec = (@Page * @RecsPerPage + 1)

-- Now, return the set of paged records, plus, an indication of we
-- have more records or not!
SELECT *,
       MoreRecords = 
	(
	 SELECT COUNT(*) 
	 FROM #TempItems TI
	 WHERE TI.ID >= @LastRec
	) 
FROM #TempItems
WHERE ID > @FirstRec AND ID < @LastRec
--ORDER BY DateSubmitted DESC
GO
/****** Object:  StoredProcedure [dbo].[BugNotQualified]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[BugNotQualified]
	@BugId 	AS INT
AS
SET NOCOUNT ON
UPDATE BugReport SET Qualified = 0, ActionTime = GETDATE() WHERE BugID  = @BugId
GO
/****** Object:  StoredProcedure [dbo].[BugNonsense]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[BugNonsense]
	@BugId 	AS INT
AS
SET NOCOUNT ON
UPDATE BugReport SET Qualified = 5, ActionTime = GETDATE() WHERE BugID  = @BugId
GO
/****** Object:  StoredProcedure [dbo].[BugGetTopBugReport]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[BugGetTopBugReport]
	@TotalBugSubmitted AS INT OUTPUT,
	@TotalBugQualified AS INT OUTPUT,
	@Users AS VARCHAR(500) OUTPUT
AS 
SET NOCOUNT ON

DECLARE @UserID AS VARCHAR(50), 
	@Count AS INT, @Qualified AS INT

SELECT @TotalBugSubmitted = COUNT( * ) FROM BugReport WITH (READPAST)
--LECT @TotalBugQualified = COUNT( * ) FROM BugReport WITH (READPAST) WHERE Qualified = 1
SELECT @TotalBugQualified = COUNT( * ) FROM BugReport WITH (READPAST) WHERE Qualified = 3 OR Qualified = 4
/*
DECLARE bug CURSOR FOR 
SELECT TOP 10 a.UserID, COUNT(*) FROM BugReport as b WITH (READPAST)
INNER JOIN Account AS a WITH (READPAST) ON a.ID = b.AccountID
WHERE a.UserID IS NOT NULL
GROUP BY a.UserID
ORDER BY Count(a.UserID) DESC*/

DECLARE bug CURSOR FOR 
SELECT TOP 10 a.UserID, COUNT(*), 
	SUM(
	    CASE b.Qualified 
	        WHEN 3 THEN 1 -- 3=Fxed
	        WHEN 4 THEN 1 -- 4=Pending
	        WHEN 6 THEN 1 -- 6=Critical
	        ELSE 0 
	    END
	) AS Qualified 
FROM BugReport as b WITH (READPAST)
INNER JOIN Account AS a WITH (READPAST) ON a.ID = b.AccountID
WHERE a.UserID IS NOT NULL
GROUP BY a.UserID, a.ID
ORDER BY Count(a.UserID) DESC


SET @Users = ''
OPEN bug
FETCH NEXT FROM bug
INTO @UserID, @Count, @Qualified
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @Users =  @Users + '|' + @UserID + '=' + CAST (@Count as VARCHAR(5))  + '=' + CAST( @Qualified AS  VARCHAR(5))
	FETCH NEXT FROM bug
	INTO @UserID, @Count, @Qualified 
END 
CLOSE bug
DEALLOCATE bug

--PRINT @TotalBugSubmitted
--PRINT @TotalBugQualified 
--PRINT @Users
GO
/****** Object:  StoredProcedure [dbo].[BugGetStats]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BugGetStats]
	@NotCheck AS INT OUTPUT, 
	@Duplicate AS INT OUTPUT,
	@Fixed AS INT OUTPUT,
	@Pending AS INT OUTPUT,
	@Nonsense AS INT OUTPUT, -- Not-a-Bug
	@Critical AS INT OUTPUT,
	@Total AS INT OUTPUT
AS
SET NOCOUNT ON

SELECT @NotCheck   = COUNT(*) FROM BugReport WITH (NOLOCK) WHERE Qualified = -1
SELECT @Duplicate   = COUNT(*) FROM BugReport WITH (NOLOCK) WHERE Qualified = 2
SELECT @Fixed         = COUNT(*) FROM BugReport WITH (NOLOCK) WHERE Qualified = 3
SELECT @Pending     = COUNT(*) FROM BugReport WITH (NOLOCK) WHERE Qualified = 4
SELECT @Nonsense   = COUNT(*) FROM BugReport WITH (NOLOCK) WHERE Qualified = 5
SELECT @Critical   = COUNT(*) FROM BugReport WITH (NOLOCK) WHERE Qualified = 6
SELECT @Total         = COUNT(*) FROM BugReport WITH (NOLOCK)
GO
/****** Object:  Table [dbo].[CouncilPoll]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CouncilPoll](
	[IDX] [int] IDENTITY(1,1) NOT NULL,
	[Voter] [nvarchar](50) NOT NULL,
	[Candidate] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_CouncilPoll] PRIMARY KEY CLUSTERED 
(
	[IDX] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_CouncilPoll_1] UNIQUE NONCLUSTERED 
(
	[Voter] ASC,
	[Candidate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[crm_UpdateUserProfile]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[crm_UpdateUserProfile]
	@Id INT,
	@Userkey NVARCHAR(7),
	@SecretQuestion NVARCHAR(50),
	@Answer NVARCHAR(50),
	@FirstName NVARCHAR(30),
	@MI NVARCHAR(1),
	@LastName NVARCHAR(30),
	@Birthday DATETIME,
	@Sex TINYINT,
	@Address NVARCHAR(100),
	@City NVARCHAR(50),
	@State NVARCHAR(50),
	@Country NVARCHAR(50),
	@MobileNo NVARCHAR(15),
	@HomeNo NVARCHAR(15)
		
AS
	
	
	
	UPDATE Account SET
			UserKey = @Userkey,
			SecretQuestion = @SecretQuestion,
			Answer = @Answer,
			Firstname = @FirstName,
			MI = @MI,
			LastName = @LastName,
			Birthday = @Birthday,
			Sex = @Sex,
			Address = @Address,
			City = @City,
			State = @State,
			Country = @Country,
			MobileNo = @MobileNo,
			HomeNo = @HomeNo
    WHERE Id = @Id
	
	RETURN
GO
/****** Object:  StoredProcedure [dbo].[crm_GetUserProfile]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[crm_GetUserProfile]
	/*
	(
	@parameter1 int = 5,
	@parameter2 datatype OUTPUT
	)
	*/
	@Id INT
		
AS
	
	
	
	SELECT 	Id,
			Email,
			UserID,
			[Password],
			COALESCE(UserKey,'') AS UserKey,
			COALESCE(Blocked,0) AS Blocked,
			COALESCE(CAST(BlockedEndDate AS VARCHAR), '1900-01-01 00:00:00') AS BlockedEndDate,
			COALESCE(CAST(UnBlockedDate AS VARCHAR), '1900-01-01 00:00:00') AS UnBlockedDate,
			COALESCE(SecretQuestion,'') AS SecretQuestion,
			COALESCE(Answer,'') AS Answer,
			COALESCE(Firstname,'') AS Firstname,
			COALESCE(MI,'') AS MI,
			COALESCE(LastName,'') AS LastName,
			COALESCE(CAST(Birthday AS VARCHAR), '1900-01-01 00:00:00') AS Birthday,
			COALESCE(Sex,0) AS Sex,
			COALESCE(Address,'') AS Address,
			COALESCE(City,'') AS City,
			COALESCE(State, '') AS State,
			COALESCE(Country, '') AS Country,
			COALESCE(MobileNo,'') AS MobileNo,
			COALESCE(HomeNo,'') AS HomeNo,
			COALESCE(RegIPAddress,'') AS RegIPAddress,
			ActivationKey,
			COALESCE(CAST(DateRegistered AS VARCHAR), '1900-01-01 00:00:00') AS DateRegistered,
			COALESCE(Activated,0) AS Activated
	FROM Account WITH (NOLOCK)
	WHERE Id = @Id
	
	RETURN
GO
/****** Object:  StoredProcedure [dbo].[crm_GetProfile]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[crm_GetProfile]
	/*
	(
	@parameter1 int = 5,
	@parameter2 datatype OUTPUT
	)
	*/
	@SearchType INT,
	@Keyword NVARCHAR(50)
	
AS
	IF @SearchType = 1 -- Search for UserID
	BEGIN
		SET @Keyword = LTRIM(RTRIM(SUBSTRING(@Keyword, 1, 10)))
	SELECT 	Id,
			Email,
			UserID,
			UserKey,
			Blocked,
			BlockedEndDate,
			UnBlockedDate,
			SecretQuestion,
			Answer,
			Firstname,
			MI,
			LastName,
			Birthday,
			Sex,
			Address,
			City,
			State,
			Country,
			MobileNo,
			HomeNo,
			RegIPAddress,
			ActivationKey,
			DateRegistered,
			Activated
	FROM Account WITH (NOLOCK)
	WHERE UserId LIKE '' + @Keyword + '%' ORDER BY UserID ASC
	END
	ELSE IF @SearchType = 2 -- Seach for Email
	BEGIN
	SELECT 	Id,
			Email,
			UserID,
			UserKey,
			Blocked,
			BlockedEndDate,
			UnBlockedDate,
			SecretQuestion,
			Answer,
			Firstname,
			MI,
			LastName,
			Birthday,
			Sex,
			Address,
			City,
			State,
			Country,
			MobileNo,
			HomeNo,
			RegIPAddress,
			ActivationKey,
			DateRegistered,
			Activated
	FROM Account WITH (NOLOCK)
	WHERE Email LIKE '' + @Keyword + '%' ORDER BY Email ASC
	END
	ELSE IF @SearchType = 3 -- Search for Registered Ip
	BEGIN
	SELECT 	Id,
			Email,
			UserID,
			UserKey,
			Blocked,
			BlockedEndDate,
			UnBlockedDate,
			SecretQuestion,
			Answer,
			Firstname,
			MI,
			LastName,
			Birthday,
			Sex,
			Address,
			City,
			State,
			Country,
			MobileNo,
			HomeNo,
			RegIPAddress,
			ActivationKey,
			DateRegistered,
			Activated
	FROM Account WITH (NOLOCK)
	WHERE RegIPAddress LIKE '' + @Keyword + '%' ORDER BY UserID ASC
	END

	RETURN
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraRegister]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dnn_TantraRegister]
@Email NVARCHAR(50),
@UserID NVARCHAR(50),
@Password NVARCHAR(40),
@SecretQuestion NVARCHAR(50),
@Answer NVARCHAR(50),
@UserKey NVARCHAR(7),
@FirstName NVARCHAR(30),
@MI NVARCHAR(1),
@LastName NVARCHAR(30),
@Birthday DATETIME,
@Sex TINYINT,
@Address NVARCHAR(100),
@City NVARCHAR(50),
@State NVARCHAR(50),
@Country NVARCHAR(50),
@MobileNo NVARCHAR(15),
@HomeNo NVARCHAR(15),
@WherePlay NVARCHAR(100),
@InternetCon NVARCHAR(100),
@ISPCafe NVARCHAR(100),
@AboutTantra NVARCHAR(100),
@RegIPAddress NVARCHAR(15),
@ActivationKey UNIQUEIDENTIFIER OUT,
@resultCode INT OUT

AS

SET @resultCode = 0
SET NOCOUNT ON
IF NOT EXISTS(SELECT Email FROM Account WITH (NOLOCK) WHERE Email = @Email)
BEGIN
	IF EXISTS (SELECT UserID FROM Account WITH (NOLOCK) WHERE UserID = @UserID)
	BEGIN
		SET @resultCode = -2 -- UserID Exists
		RETURN -- Exits Code
	END

	SET @ActivationKey = NEWID() 
	INSERT INTO Account (Email, UserID, [Password], SecretQuestion, Answer, Firstname, mi, Lastname, Birthday, Sex, Address,
		City, State, Country, MobileNo, HomeNo, WherePlay, InternetCon, ISPCafe, 
		 AboutTantra, RegIPAddress,  ActivationKey, UserKey)
	VALUES (@Email, @UserID, @Password, @SecretQuestion, @Answer, @FirstName, @MI, @LastName, @Birthday, @Sex, @Address,
		@City, @State, @Country, @MobileNo, @HomeNo, @WherePlay, @InternetCon, @ISPCafe, 
		@AboutTantra, @RegIPAddress, @ActivationKey, @UserKey)
	IF @@ERROR = 0
	BEGIN
		SET @resultCode = 1 -- Successful
	END
	ELSE
	BEGIN
		SET @resultCode = -99 -- Unidentified error
	END
END
ELSE
BEGIN 
	SET @resultCode = -1 -- Email exists
END
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraGetUserSecretQuestion]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dnn_TantraGetUserSecretQuestion]

@Email NVARCHAR(50),
@resultCode INT OUT,
@SecretQuestion NVARCHAR(50) OUT,
@Answer NVARCHAR(50) OUT,
@UserID NVARCHAR(50) OUT

AS

SELECT @SecretQuestion = SecretQuestion, @Answer = Answer, @UserID = UserID
FROM Account WITH (NOLOCK) 
WHERE Email = @Email

SET @resultCode = @@ROWCOUNT
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraGetUserInformation]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dnn_TantraGetUserInformation]

@UserID NVARCHAR(50)

AS

SELECT [ID],Email,UserID,UserKey,SecretQuestion,Answer,FirstName,MI,LastName,Birthday,Sex,Address,City,State,Country,MobileNo,HomeNo,ActivationKey,DateRegistered
FROM Account WITH (NOLOCK)
WHERE UserID = @UserID
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraGetCountries]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dnn_TantraGetCountries] AS

SELECT Country
FROM tblCountry WITH (NOLOCK)
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraGetCities]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dnn_TantraGetCities] AS


SELECT City
FROM tblCity WITH (NOLOCK)
WHERE ID != 90
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraCheckUsername]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dnn_TantraCheckUsername]

@UserID AS NVARCHAR(50),
@resultCode INT OUTPUT

AS

SELECT @resultCode = COUNT(UserID) FROM Account WITH (NOLOCK)
WHERE UserID = @UserID
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraChangePassword_2]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dnn_TantraChangePassword_2]

@UserID NVARCHAR(50),
@Password NVARCHAR(70),
@NewPassword NVARCHAR(70),
@resultCode INT OUT

AS

SET @resultCode = 0

IF EXISTS(SELECT UserID FROM Account WITH (NOLOCK) WHERE UserID = @UserID AND [Password] = @Password)
BEGIN
	UPDATE Account SET [Password] = @NewPassword, IsUserCreated = 0
	WHERE UserID = @UserID AND [Password] = @Password
	IF @@ERROR = 0 AND @@ROWCOUNT = 1
	BEGIN
		SET @resultCode = 1
	END
END
ELSE -- Incorrect Password
BEGIN
	SET @resultCode = -1
END
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraChangePassword]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dnn_TantraChangePassword]

@UserID NVARCHAR(50),
@Password NVARCHAR(70),
@resultCode INT OUT

AS

SET @resultCode = 0

UPDATE Account
SET [Password] = @Password, IsUserCreated = 0
WHERE UserID = @UserID

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SET @resultCode = 1
END
GO
/****** Object:  StoredProcedure [dbo].[dnn_GetTantraNewsDetails]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dnn_GetTantraNewsDetails]

@NewsID INT

AS

SELECT NewsID, Title, Body, DateAdded, GroupID, Display FROM NewsItem WITH (NOLOCK) WHERE NewsID = @NewsID AND Display = 1
GO
/****** Object:  StoredProcedure [dbo].[CouncilGetStatus]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[CouncilGetStatus]
	@UserId	AS NVARCHAR(50),
	@Server1	AS NVARCHAR(50) OUTPUT,
	@Character1	AS NVARCHAR(50) OUTPUT,
	@Level1		AS NVARCHAR(3) OUTPUT,
	@Server2	AS NVARCHAR(50) OUTPUT,
	@Character2	AS NVARCHAR(50) OUTPUT,
	@Level2		AS NVARCHAR(3) OUTPUT,
	@Server3	AS NVARCHAR(50) OUTPUT,
	@Character3	AS NVARCHAR(50) OUTPUT,
	@Level3		AS NVARCHAR(3) OUTPUT,
	@result 		AS INT  OUTPUT
AS
SET @result = 0
IF EXISTS (SELECT * FROM Council WHERE UserId = @UserId)
BEGIN	
	SET @result = 0
	SELECT @Server1 = Server1, @Character1 = Character1, @Level1 = Level1, 
		@Server2 = Server2, @Character2 = Character2, @Level2 = Level2, 
		@Server3 = Server3, @Character3 = Character3, @Level3 = Level3
	FROM Council WHERE UserId = @UserId
END
ELSE
	SET @result = -99
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraSecretQuestionResetPassword]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dnn_TantraSecretQuestionResetPassword]

@Email NVARCHAR(50),
@NewPassword NVARCHAR(70),
@resultCode INT OUT

AS

SET @resultCode = 0

UPDATE Account
SET [Password] = @NewPassword, IsUserCreated = 0
WHERE Email = @Email

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SET @resultCode = 1
END
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraRequestActivationLink]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dnn_TantraRequestActivationLink]

@Email NVARCHAR(50),
@UserID NVARCHAR(50) OUT,
@Password NVARCHAR(70) OUT,
@ActivationKey NVARCHAR(100) OUT,
@resultCode INT OUT

AS

DECLARE @Activated AS BIT
DECLARE @ActivationKeyString AS NVARCHAR(100)

SELECT @UserID = UserID, @Password = [Password], @ActivationKeyString = ActivationKey, @Activated = Activated
FROM Account WITH (NOLOCK)
WHERE Email = @Email

SET @resultCode = @@ROWCOUNT
SET @ActivationKey = CAST(@ActivationKeyString AS UNIQUEIDENTIFIER)

IF @Activated = 1 -- Activated
BEGIN
	SET @resultCode = 9 
END
ELSE IF @Activated = 0 -- Not Activated
BEGIN
	SET @resultCode = 1
END
GO
/****** Object:  StoredProcedure [dbo].[dt_addtosourcecontrol]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_addtosourcecontrol]
    @vchSourceSafeINI varchar(255) = '',
    @vchProjectName   varchar(255) ='',
    @vchComment       varchar(255) ='',
    @vchLoginName     varchar(255) ='',
    @vchPassword      varchar(255) =''

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId = 0

declare @iStreamObjectId int
select @iStreamObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

declare @vchDatabaseName varchar(255)
select @vchDatabaseName = db_name()

declare @iReturnValue int
select @iReturnValue = 0

declare @iPropertyObjectId int
declare @vchParentId varchar(255)

declare @iObjectCount int
select @iObjectCount = 0

    exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 GOTO E_OAError


    /* Create Project in SS */
    exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
											'AddProjectToSourceSafe',
											NULL,
											@vchSourceSafeINI,
											@vchProjectName output,
											@@SERVERNAME,
											@vchDatabaseName,
											@vchLoginName,
											@vchPassword,
											@vchComment


    if @iReturn <> 0 GOTO E_OAError

    /* Set Database Properties */

    begin tran SetProperties

    /* add high level object */

    exec @iPropertyObjectId = dbo.dt_adduserobject_vcs 'VCSProjectID'

    select @vchParentId = CONVERT(varchar(255),@iPropertyObjectId)

    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSProjectID', @vchParentId , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSProject' , @vchProjectName , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSSourceSafeINI' , @vchSourceSafeINI , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSSQLServer', @@SERVERNAME, NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSSQLDatabase', @vchDatabaseName, NULL

    if @@error <> 0 GOTO E_General_Error

    commit tran SetProperties
    
    select @iObjectCount = 0;

CleanUp:
    select @vchProjectName
    select @iObjectCount
    return

E_General_Error:
    /* this is an all or nothing.  No specific error messages */
    goto CleanUp

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    goto CleanUp
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraUserLogin]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dnn_TantraUserLogin]

@UserID NVARCHAR(50),
@Password NVARCHAR(70),
@resultCode INT OUT

AS

SELECT @resultCode = COUNT(UserID)
FROM Account
WITH (NOLOCK)
WHERE UserID = @UserID
AND [Password] = @Password
GO
/****** Object:  StoredProcedure [dbo].[dt_displayoaerror_u]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dt_displayoaerror_u]
    @iObject int,
    @iresult int
as
	-- This procedure should no longer be called;  dt_displayoaerror should be called instead.
	-- Calls are forwarded to dt_displayoaerror to maintain backward compatibility.
	set nocount on
	exec dbo.dt_displayoaerror
		@iObject,
		@iresult
GO
/****** Object:  StoredProcedure [dbo].[dt_checkinobject]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_checkinobject]
    @chObjectType  char(4),
    @vchObjectName varchar(255),
    @vchComment    varchar(255)='',
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255)='',
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0,   /* 0 => AddFile, 1 => CheckIn */
    @txStream1     Text = '', /* drop stream   */ /* There is a bug that if items are NULL they do not pass to OLE servers */
    @txStream2     Text = '', /* create stream */
    @txStream3     Text = ''  /* grant stream  */


as

	set nocount on

	declare @iReturn int
	declare @iObjectId int
	select @iObjectId = 0
	declare @iStreamObjectId int

	declare @VSSGUID varchar(100)
	select @VSSGUID = 'SQLVersionControl.VCS_SQL'

	declare @iPropertyObjectId int
	select @iPropertyObjectId  = 0

    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    declare @iReturnValue	  int
    declare @pos			  int
    declare @vchProcLinePiece varchar(255)

    
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        if @iActionFlag = 1
        begin
            /* Procedure Can have up to three streams
            Drop Stream, Create Stream, GRANT stream */

            begin tran compile_all

            /* try to compile the streams */
            exec (@txStream1)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream2)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream3)
            if @@error <> 0 GOTO E_Compile_Fail
        end

        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAGetProperty @iObjectId, 'GetStreamObject', @iStreamObjectId OUT
        if @iReturn <> 0 GOTO E_OAError
        
        if @iActionFlag = 1
        begin
            
            declare @iStreamLength int
			
			select @pos=1
			select @iStreamLength = datalength(@txStream2)
			
			if @iStreamLength > 0
			begin
			
				while @pos < @iStreamLength
				begin
						
					select @vchProcLinePiece = substring(@txStream2, @pos, 255)
					
					exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, 'AddStream', @iReturnValue OUT, @vchProcLinePiece
            		if @iReturn <> 0 GOTO E_OAError
            		
					select @pos = @pos + 255
					
				end
            
				exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
														'CheckIn_StoredProcedure',
														NULL,
														@sProjectName = @vchProjectName,
														@sSourceSafeINI = @vchSourceSafeINI,
														@sServerName = @vchServerName,
														@sDatabaseName = @vchDatabaseName,
														@sObjectName = @vchObjectName,
														@sComment = @vchComment,
														@sLoginName = @vchLoginName,
														@sPassword = @vchPassword,
														@iVCSFlags = @iVCSFlags,
														@iActionFlag = @iActionFlag,
														@sStream = ''
                                        
			end
        end
        else
        begin
        
            select colid, text into #ProcLines
            from syscomments
            where id = object_id(@vchObjectName)
            order by colid

            declare @iCurProcLine int
            declare @iProcLines int
            select @iCurProcLine = 1
            select @iProcLines = (select count(*) from #ProcLines)
            while @iCurProcLine <= @iProcLines
            begin
                select @pos = 1
                declare @iCurLineSize int
                select @iCurLineSize = len((select text from #ProcLines where colid = @iCurProcLine))
                while @pos <= @iCurLineSize
                begin                
                    select @vchProcLinePiece = convert(varchar(255),
                        substring((select text from #ProcLines where colid = @iCurProcLine),
                                  @pos, 255 ))
                    exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, 'AddStream', @iReturnValue OUT, @vchProcLinePiece
                    if @iReturn <> 0 GOTO E_OAError
                    select @pos = @pos + 255                  
                end
                select @iCurProcLine = @iCurProcLine + 1
            end
            drop table #ProcLines

            exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
													'CheckIn_StoredProcedure',
													NULL,
													@sProjectName = @vchProjectName,
													@sSourceSafeINI = @vchSourceSafeINI,
													@sServerName = @vchServerName,
													@sDatabaseName = @vchDatabaseName,
													@sObjectName = @vchObjectName,
													@sComment = @vchComment,
													@sLoginName = @vchLoginName,
													@sPassword = @vchPassword,
													@iVCSFlags = @iVCSFlags,
													@iActionFlag = @iActionFlag,
													@sStream = ''
        end

        if @iReturn <> 0 GOTO E_OAError

        if @iActionFlag = 1
        begin
            commit tran compile_all
            if @@error <> 0 GOTO E_Compile_Fail
        end

    end

CleanUp:
	return

E_Compile_Fail:
	declare @lerror int
	select @lerror = @@error
	rollback tran compile_all
	RAISERROR (@lerror,16,-1)
	goto CleanUp

E_OAError:
	if @iActionFlag = 1 rollback tran compile_all
	exec dbo.dt_displayoaerror @iObjectId, @iReturn
	goto CleanUp
GO
/****** Object:  StoredProcedure [dbo].[dt_checkoutobject]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_checkoutobject]
    @chObjectType  char(4),
    @vchObjectName varchar(255),
    @vchComment    varchar(255),
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255),
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0/* 0 => Checkout, 1 => GetLatest, 2 => UndoCheckOut */

as

	set nocount on

	declare @iReturn int
	declare @iObjectId int
	select @iObjectId =0

	declare @VSSGUID varchar(100)
	select @VSSGUID = 'SQLVersionControl.VCS_SQL'

	declare @iReturnValue int
	select @iReturnValue = 0

	declare @vchTempText varchar(255)

	/* this is for our strings */
	declare @iStreamObjectId int
	select @iStreamObjectId = 0

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        /* Procedure Can have up to three streams
           Drop Stream, Create Stream, GRANT stream */

        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
												'CheckOut_StoredProcedure',
												NULL,
												@sProjectName = @vchProjectName,
												@sSourceSafeINI = @vchSourceSafeINI,
												@sObjectName = @vchObjectName,
												@sServerName = @vchServerName,
												@sDatabaseName = @vchDatabaseName,
												@sComment = @vchComment,
												@sLoginName = @vchLoginName,
												@sPassword = @vchPassword,
												@iVCSFlags = @iVCSFlags,
												@iActionFlag = @iActionFlag

        if @iReturn <> 0 GOTO E_OAError


        exec @iReturn = master.dbo.sp_OAGetProperty @iObjectId, 'GetStreamObject', @iStreamObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        create table #commenttext (id int identity, sourcecode varchar(255))


        select @vchTempText = 'STUB'
        while @vchTempText is not null
        begin
            exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, 'GetStream', @iReturnValue OUT, @vchTempText OUT
            if @iReturn <> 0 GOTO E_OAError
            
            if (@vchTempText = '') set @vchTempText = null
            if (@vchTempText is not null) insert into #commenttext (sourcecode) select @vchTempText
        end

        select 'VCS'=sourcecode from #commenttext order by id
        select 'SQL'=text from syscomments where id = object_id(@vchObjectName) order by colid

    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp
GO
/****** Object:  StoredProcedure [dbo].[dt_removefromsourcecontrol]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[dt_removefromsourcecontrol]

as

    set nocount on

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    exec dbo.dt_droppropertiesbyid @iPropertyObjectId, null

    /* -1 is returned by dt_droppopertiesbyid */
    if @@error <> 0 and @@error <> -1 return 1

    return 0
GO
/****** Object:  StoredProcedure [dbo].[FanArtPagedItems]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FanArtPagedItems]
	(
	 @Page int,
	 @RecsPerPage int,
	 @Approved int
	)
AS
-- We don't want to return the # of rows inserted
-- into our temporary table, so turn NOCOUNT ON
SET NOCOUNT ON

--Create a temporary table
CREATE TABLE #FanTempItems
(
	ID int IDENTITY,
	FanID INT,
	Email varchar(50),
	DateSubmitted DATETIME,
	[Description] varchar(3000),
	ImgName varchar(50),
	imgContentType varchar(50),
	Approved Bit
)

/*ALTER TABLE #FanTempItems WITH NOCHECK ADD 
	CONSTRAINT [PK_ID] PRIMARY KEY  CLUSTERED 
	(
		[ID]
	)  ON [PRIMARY] 
*/

-- Insert the rows from tblItems into the temp. table
IF (@Approved = 1)
BEGIN 
	INSERT INTO #FanTempItems (FanID, Email, DateSubmitted, [Description],
			ImgName, imgContentType, Approved)
	
	SELECT b.FanID, a.Email, b.DateSubmitted, b.Description,
		b.ImgName, b.imgContentType, b.Approved
	FROM FanArt  AS b  INNER JOIN Account  AS a ON b.AccountID = a.[ID] 
	WHERE b.Approved = 1 --show only approved fan art 
	ORDER BY FanId
END
ELSE
BEGIN
	INSERT INTO #FanTempItems (FanID, Email, DateSubmitted, [Description],
			ImgName, imgContentType, Approved)
	
	SELECT b.FanID, a.Email, b.DateSubmitted, b.Description,
		b.ImgName, b.imgContentType, Approved
	FROM FanArt  AS b  INNER JOIN Account  AS a ON b.AccountID = a.[ID] 
	--WHERE b.Approved = 1 --show only approved fan art 
	ORDER BY FanId DESC
END

-- Find out the first and last record we want
DECLARE @FirstRec int, @LastRec int
SELECT @FirstRec = (@Page - 1) * @RecsPerPage
SELECT @LastRec = (@Page * @RecsPerPage + 1)

-- Now, return the set of paged records, plus, an indication of we
-- have more records or not!
SELECT *,
       MoreRecords = 
	(
	 SELECT COUNT(*) 
	 FROM #FanTempItems TI
	 WHERE TI.ID >= @LastRec
	) 
FROM #FanTempItems
WHERE ID > @FirstRec AND ID < @LastRec
ORDER BY FanId DESC
GO
/****** Object:  StoredProcedure [dbo].[dt_whocheckedout]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_whocheckedout]
        @chObjectType  char(4),
        @vchObjectName varchar(255),
        @vchLoginName  varchar(255),
        @vchPassword   varchar(255)

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

    declare @iPropertyObjectId int

    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        declare @vchReturnValue varchar(255)
        select @vchReturnValue = ''

        exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
												'WhoCheckedOut',
												@vchReturnValue OUT,
												@sProjectName = @vchProjectName,
												@sSourceSafeINI = @vchSourceSafeINI,
												@sObjectName = @vchObjectName,
												@sServerName = @vchServerName,
												@sDatabaseName = @vchDatabaseName,
												@sLoginName = @vchLoginName,
												@sPassword = @vchPassword

        if @iReturn <> 0 GOTO E_OAError

        select @vchReturnValue

    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp
GO
/****** Object:  StoredProcedure [dbo].[FanArtGetApproved]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[FanArtGetApproved]
	@Approved AS INT OUTPUT, 
	@DisApproved AS INT OUTPUT
AS

SELECT @Approved = COUNT(*) FROM FanArt WITH (NOLOCK) WHERE Approved = 1
SELECT @DisApproved = COUNT(*) FROM FanArt WITH (NOLOCK) WHERE Approved = 0
GO
/****** Object:  StoredProcedure [dbo].[FanArtDelete]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[FanArtDelete]
	@FanId 	AS INT	
AS
SET NOCOUNT ON
DELETE FanArt WHERE FanId = @FanId
GO
/****** Object:  StoredProcedure [dbo].[FanArtApproved]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[FanArtApproved]
	@FanId 	AS INT,
	@Action AS INT
AS
SET NOCOUNT ON
UPDATE FanArt SET Approved = @Action WHERE FanID  = @FanId
GO
/****** Object:  StoredProcedure [dbo].[FanArtAdd]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[FanArtAdd]
	@AccountID		INT,
	@Description		VARCHAR(3000),
	@ImgName 		VARCHAR(50),
	@ImgBin 		Image, 
	@ImgTmbBin		Image, 
	@ImgContentType 	VARCHAR(50),

	@result int output
AS 
 SET @result = 0
 SET NOCOUNT ON

 INSERT INTO FanArt  ([Description],  AccountID, 
	ImgName, ImgBin, ImgTmbBin, ImgContentType  )
  VALUES (@Description,  @AccountID,
	@ImgName, @ImgBin, @ImgTmbBin, @ImgContentType)
  IF @@ERROR <> 0
	SET @result = -99 --DB SP Error
GO
/****** Object:  StoredProcedure [dbo].[dt_validateloginparams]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_validateloginparams]
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255)
as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchSourceSafeINI varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT

    exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 GOTO E_OAError

    exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
											'ValidateLoginParams',
											NULL,
											@sSourceSafeINI = @vchSourceSafeINI,
											@sLoginName = @vchLoginName,
											@sPassword = @vchPassword
    if @iReturn <> 0 GOTO E_OAError

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp
GO
/****** Object:  StoredProcedure [dbo].[dt_setpropertybyid_u]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	If the property already exists, reset the value; otherwise add property
**		id -- the id in sysobjects of the object
**		property -- the name of the property
**		uvalue -- the text value of the property
**		lvalue -- the binary value of the property (image)
*/
create procedure [dbo].[dt_setpropertybyid_u]
	@id int,
	@property varchar(64),
	@uvalue nvarchar(255),
	@lvalue image
as
	set nocount on
	-- 
	-- If we are writing the name property, find the ansi equivalent. 
	-- If there is no lossless translation, generate an ansi name. 
	-- 
	declare @avalue varchar(255) 
	set @avalue = null 
	if (@uvalue is not null) 
	begin 
		if (convert(nvarchar(255), convert(varchar(255), @uvalue)) = @uvalue) 
		begin 
			set @avalue = convert(varchar(255), @uvalue) 
		end 
		else 
		begin 
			if 'DtgSchemaNAME' = @property 
			begin 
				exec dbo.dt_generateansiname @avalue output 
			end 
		end 
	end 
	if exists (select * from dbo.dtproperties 
			where objectid=@id and property=@property)
	begin
		--
		-- bump the version count for this row as we update it
		--
		update dbo.dtproperties set value=@avalue, uvalue=@uvalue, lvalue=@lvalue, version=version+1
			where objectid=@id and property=@property
	end
	else
	begin
		--
		-- version count is auto-set to 0 on initial insert
		--
		insert dbo.dtproperties (property, objectid, value, uvalue, lvalue)
			values (@property, @id, @avalue, @uvalue, @lvalue)
	end
GO
/****** Object:  StoredProcedure [dbo].[dt_isundersourcecontrol]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_isundersourcecontrol]
    @vchLoginName varchar(255) = '',
    @vchPassword  varchar(255) = '',
    @iWhoToo      int = 0 /* 0 => Just check project; 1 => get list of objs */

as

	set nocount on

	declare @iReturn int
	declare @iObjectId int
	select @iObjectId = 0

	declare @VSSGUID varchar(100)
	select @VSSGUID = 'SQLVersionControl.VCS_SQL'

	declare @iReturnValue int
	select @iReturnValue = 0

	declare @iStreamObjectId int
	select @iStreamObjectId   = 0

	declare @vchTempText varchar(255)

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if (@vchProjectName = '')	set @vchProjectName		= null
    if (@vchSourceSafeINI = '') set @vchSourceSafeINI	= null
    if (@vchServerName = '')	set @vchServerName		= null
    if (@vchDatabaseName = '')	set @vchDatabaseName	= null
    
    if (@vchProjectName is null) or (@vchSourceSafeINI is null) or (@vchServerName is null) or (@vchDatabaseName is null)
    begin
        RAISERROR('Not Under Source Control',16,-1)
        return
    end

    if @iWhoToo = 1
    begin

        /* Get List of Procs in the project */
        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
												'GetListOfObjects',
												NULL,
												@vchProjectName,
												@vchSourceSafeINI,
												@vchServerName,
												@vchDatabaseName,
												@vchLoginName,
												@vchPassword

        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAGetProperty @iObjectId, 'GetStreamObject', @iStreamObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        create table #ObjectList (id int identity, vchObjectlist varchar(255))

        select @vchTempText = 'STUB'
        while @vchTempText is not null
        begin
            exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, 'GetStream', @iReturnValue OUT, @vchTempText OUT
            if @iReturn <> 0 GOTO E_OAError
            
            if (@vchTempText = '') set @vchTempText = null
            if (@vchTempText is not null) insert into #ObjectList (vchObjectlist ) select @vchTempText
        end

        select vchObjectlist from #ObjectList order by id
    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    goto CleanUp
GO
/****** Object:  StoredProcedure [dbo].[dt_getpropertiesbyid_vcs_u]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[dt_getpropertiesbyid_vcs_u]
    @id       int,
    @property varchar(64),
    @value    nvarchar(255) = NULL OUT

as

    -- This procedure should no longer be called;  dt_getpropertiesbyid_vcsshould be called instead.
	-- Calls are forwarded to dt_getpropertiesbyid_vcs to maintain backward compatibility.
	set nocount on
    exec dbo.dt_getpropertiesbyid_vcs
		@id,
		@property,
		@value output
GO
/****** Object:  StoredProcedure [dbo].[dt_validateloginparams_u]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_validateloginparams_u]
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255)
as

	-- This procedure should no longer be called;  dt_validateloginparams should be called instead.
	-- Calls are forwarded to dt_validateloginparams to maintain backward compatibility.
	set nocount on
	exec dbo.dt_validateloginparams
		@vchLoginName,
		@vchPassword
GO
/****** Object:  StoredProcedure [dbo].[dt_whocheckedout_u]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_whocheckedout_u]
        @chObjectType  char(4),
        @vchObjectName nvarchar(255),
        @vchLoginName  nvarchar(255),
        @vchPassword   nvarchar(255)

as

	-- This procedure should no longer be called;  dt_whocheckedout should be called instead.
	-- Calls are forwarded to dt_whocheckedout to maintain backward compatibility.
	set nocount on
	exec dbo.dt_whocheckedout
		@chObjectType, 
		@vchObjectName,
		@vchLoginName, 
		@vchPassword
GO
/****** Object:  StoredProcedure [dbo].[dt_isundersourcecontrol_u]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_isundersourcecontrol_u]
    @vchLoginName nvarchar(255) = '',
    @vchPassword  nvarchar(255) = '',
    @iWhoToo      int = 0 /* 0 => Just check project; 1 => get list of objs */

as
	-- This procedure should no longer be called;  dt_isundersourcecontrol should be called instead.
	-- Calls are forwarded to dt_isundersourcecontrol to maintain backward compatibility.
	set nocount on
	exec dbo.dt_isundersourcecontrol
		@vchLoginName,
		@vchPassword,
		@iWhoToo
GO
/****** Object:  StoredProcedure [dbo].[dt_checkinobject_u]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_checkinobject_u]
    @chObjectType  char(4),
    @vchObjectName nvarchar(255),
    @vchComment    nvarchar(255)='',
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255)='',
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0,   /* 0 => AddFile, 1 => CheckIn */
    @txStream1     text = '',  /* drop stream   */ /* There is a bug that if items are NULL they do not pass to OLE servers */
    @txStream2     text = '',  /* create stream */
    @txStream3     text = ''   /* grant stream  */

as	
	-- This procedure should no longer be called;  dt_checkinobject should be called instead.
	-- Calls are forwarded to dt_checkinobject to maintain backward compatibility.
	set nocount on
	exec dbo.dt_checkinobject
		@chObjectType,
		@vchObjectName,
		@vchComment,
		@vchLoginName,
		@vchPassword,
		@iVCSFlags,
		@iActionFlag,   
		@txStream1,		
		@txStream2,		
		@txStream3
GO
/****** Object:  StoredProcedure [dbo].[dt_checkoutobject_u]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_checkoutobject_u]
    @chObjectType  char(4),
    @vchObjectName nvarchar(255),
    @vchComment    nvarchar(255),
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255),
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0/* 0 => Checkout, 1 => GetLatest, 2 => UndoCheckOut */

as

	-- This procedure should no longer be called;  dt_checkoutobject should be called instead.
	-- Calls are forwarded to dt_checkoutobject to maintain backward compatibility.
	set nocount on
	exec dbo.dt_checkoutobject
		@chObjectType,  
		@vchObjectName, 
		@vchComment,    
		@vchLoginName,  
		@vchPassword,  
		@iVCSFlags,    
		@iActionFlag
GO
/****** Object:  StoredProcedure [dbo].[dt_addtosourcecontrol_u]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[dt_addtosourcecontrol_u]
    @vchSourceSafeINI nvarchar(255) = '',
    @vchProjectName   nvarchar(255) ='',
    @vchComment       nvarchar(255) ='',
    @vchLoginName     nvarchar(255) ='',
    @vchPassword      nvarchar(255) =''

as
	-- This procedure should no longer be called;  dt_addtosourcecontrol should be called instead.
	-- Calls are forwarded to dt_addtosourcecontrol to maintain backward compatibility
	set nocount on
	exec dbo.dt_addtosourcecontrol 
		@vchSourceSafeINI, 
		@vchProjectName, 
		@vchComment, 
		@vchLoginName, 
		@vchPassword
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraUpdateProfile]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dnn_TantraUpdateProfile]

@UserID NVARCHAR(50),
@FirstName NVARCHAR(50),
@MI NVARCHAR(1),
@LastName NVARCHAR(50),
@Birthday DATETIME,
@Sex TINYINT,
@Address NVARCHAR(50),
@City NVARCHAR(50),
@State NVARCHAR(50),
@Country NVARCHAR(50),
@MobileNo NVARCHAR(15),
@HomeNo NVARCHAR(15),
@resultCode INT OUT

AS

SET @resultCode = 0

	DECLARE	@Email	 	NVARCHAR(50) -- Email as key
	DECLARE	@NCashResult 	INT
	DECLARE	@NCashMsg    	NVARCHAR(100)

	SELECT @Email = Email FROM Account WITH (NOLOCK) WHERE UserId = @UserId

	UPDATE Account
	SET 	FirstName = @FirstName,
		MI = @MI,
		LastName = @LastName,
		Birthday = @Birthday,
		Sex = @Sex,
		Address = @Address,
		City = @City,
		State = @State,
		Country = @Country,
		MobileNo = @MobileNo,
		HomeNo = @HomeNo
	WHERE UserID = @UserID


IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SET @resultCode = 1
	EXEC AccountUpdateProfileInBilling @Email, @NCashResult OUTPUT, @NCashMsg OUTPUT
END
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraRegisterAndActivate]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dnn_TantraRegisterAndActivate]
@Email NVARCHAR(50),
@UserID NVARCHAR(50),
@Password NVARCHAR(40),
@SecretQuestion NVARCHAR(50),
@Answer NVARCHAR(50),
@UserKey NVARCHAR(7),
@FirstName NVARCHAR(30),
@MI NVARCHAR(1),
@LastName NVARCHAR(30),
@Birthday DATETIME,
@Sex TINYINT,
@Address NVARCHAR(100),
@City NVARCHAR(50),
@State NVARCHAR(50),
@Country NVARCHAR(50),
@MobileNo NVARCHAR(15),
@HomeNo NVARCHAR(15),
@WherePlay NVARCHAR(100),
@InternetCon NVARCHAR(100),
@ISPCafe NVARCHAR(100),
@AboutTantra NVARCHAR(100),
@RegIPAddress NVARCHAR(15),
@ActivationKey UNIQUEIDENTIFIER OUT,
@resultCode INT OUT

AS

DECLARE @NCashResult INT
DECLARE @NCashMsg VARCHAR(100)

SET @resultCode = 0
SET NOCOUNT ON
IF NOT EXISTS(SELECT Email FROM Account WITH (NOLOCK) WHERE Email = @Email)
BEGIN
	IF EXISTS (SELECT UserID FROM Account WITH (NOLOCK) WHERE UserID = @UserID)
	BEGIN
		SET @resultCode = -2 -- UserID Exists
		RETURN -- Exits Code
	END

	BEGIN TRAN
		SET @ActivationKey = NEWID() 
		INSERT INTO Account (Email, UserID, [Password], SecretQuestion, Answer, Firstname, mi, Lastname, Birthday, Sex, Address,
			City, State, Country, MobileNo, HomeNo, WherePlay, InternetCon, ISPCafe, 
			 AboutTantra, RegIPAddress,  ActivationKey, UserKey)
		VALUES (@Email, @UserID, @Password, @SecretQuestion, @Answer, @FirstName, @MI, @LastName, @Birthday, @Sex, @Address,
			@City, @State, @Country, @MobileNo, @HomeNo, @WherePlay, @InternetCon, @ISPCafe, 
			@AboutTantra, @RegIPAddress, @ActivationKey, @UserKey)

	IF @@ERROR = 0
	BEGIN
		UPDATE Account SET Activated  = 1 WHERE ActivationKey = @ActivationKey
		SELECT @Email = Email, @UserID = UserID, @Password = [Password] FROM Account  WITH (NOLOCK) WHERE ActivationKey = @ActivationKey
		--Insert user in Billing DB only when the user activated their account
		EXEC AccountInsertUserInBilling 	@Email, @NCashResult OUTPUT, @NCashMsg OUTPUT
		IF @NCashResult = -1 --Error returned while inserting data  to Billling DB
		BEGIN
			SET @resultCode = -3  /* error */
			ROLLBACK TRAN
		END
		ELSE
		BEGIN
			SET @resultCode = 1 /* OK, return email and password */
			COMMIT TRAN
		END
	END
	ELSE
	BEGIN
		SET @resultCode = -99 -- Unidentified error
	END
END
ELSE
BEGIN 
	SET @resultCode = -1 -- Email exists
END
GO
/****** Object:  StoredProcedure [dbo].[CouncilGetIfUserVoted]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[CouncilGetIfUserVoted]
	@Voter	AS NVARCHAR(50),
	@result	AS INT OUTPUT
AS
IF EXISTS ( SELECT * FROM CouncilPoll WHERE Voter = @Voter)
	SET @result = 1
ELSE 
	SET @result = 0
GO
/****** Object:  StoredProcedure [dbo].[dnn_TantraActivate]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dnn_TantraActivate]

@ActivationKey UNIQUEIDENTIFIER,
@Email NVARCHAR(50) OUT,
@UserID NVARCHAR(50) OUT,
@Password NVARCHAR(70) OUT,
@resultCode INT OUT

AS

SET @resultCode = 0

DECLARE @Activated AS INT,  @NCashResult INT, @NCashMsg NVARCHAR(100)

SET NOCOUNT ON
SELECT  @Activated = Activated
FROM Account  WITH (NOLOCK)
WHERE ActivationKey = @ActivationKey

IF @@ROWCOUNT = 1
BEGIN
	IF  (@Activated = 1) --Account already activated
	BEGIN
		SET @resultCode = -1
		RETURN --Exit
	END
	ELSE --NOT yet activated
	BEGIN 
		BEGIN TRAN
			UPDATE Account SET Activated  = 1 WHERE ActivationKey = @ActivationKey
			SELECT @Email = Email, @UserID = UserID, @Password = [Password] FROM Account  WITH (NOLOCK) WHERE ActivationKey = @ActivationKey
			--Insert user in Billing DB only when the user activated their account
			EXEC AccountInsertUserInBilling 	@Email, @NCashResult OUTPUT, @NCashMsg OUTPUT
		IF @NCashResult = -1 --Error returned while inserting data  to Billling DB
		BEGIN
			SET @resultCode = -3  /* error */
			ROLLBACK TRAN
		END
		ELSE
		BEGIN
			SET @resultCode = 1 /* OK, return email and password */
			COMMIT TRAN
		END
	END
END
ELSE
	SET @resultCode = -2 /* NOT found */
GO
/****** Object:  StoredProcedure [dbo].[CouncilVote]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CouncilVote] 
	@Voter		AS NVARCHAR(50),
	@Candidate	AS NVARCHAR(50)
AS 
--IF NOT EXISTS (SELECT * FROM  CouncilPoll WHERE Voter = @Voter)
--BEGIN 
	INSERT INTO CouncilPoll (Voter, Candidate)
	VALUES (@Voter, @Candidate)
--END
GO
/****** Object:  StoredProcedure [dbo].[CouncilGetVoteCount]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CouncilGetVoteCount] 
	
AS

/*SELECT     Candidate, COUNT(*) AS COUNT
FROM         CouncilPoll WITH (NOLOCK)
GROUP BY Candidate
ORDER BY COUNT DESC*/

SELECT     CouncilPoll.Candidate, COUNT(*) AS COUNT, Candidate.GMPercent
FROM         CouncilPoll INNER JOIN
                      Candidate ON CouncilPoll.Candidate = Candidate.Candidate
GROUP BY CouncilPoll.Candidate, Candidate.GMPercent
order by Count desc
GO
/****** Object:  StoredProcedure [dbo].[CouncilGetVote]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[CouncilGetVote] 
	@Voter		AS NVARCHAR(50)
AS 

SELECT * FROM  CouncilPoll WHERE Voter = @Voter
GO
/****** Object:  StoredProcedure [dbo].[AccountUpdateUserID]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
--Programmer/DBA: Richard Tibang chardtc@yahoo.com
CREATE PROC [dbo].[AccountUpdateUserID]
	@Email		AS NVARCHAR(50), 
	@UserID	AS NVARCHAR(50), 	
	@result 		AS INT OUTPUT
AS
SET NOCOUNT ON
DECLARE @NCashResult INT, @NCashMsg NVARCHAR(100)
IF EXISTS (SELECT UserID FROM Account WITH (NOLOCK) WHERE UserID = @UserID)
BEGIN
	SET @result = -1
	RETURN--exit	
END

UPDATE Account SET  UserID = @UserID WHERE Email = @Email
IF @@ROWCOUNT = 1
BEGIN 
	SET @result = 0
	--Insert account into Billing DB. If user id is null in Account DB the account does not exist in Billing DB.
	EXEC AccountInsertUserInBilling 	@Email, @NCashResult OUTPUT, 	@NCashMsg OUTPUT
END
ELSE
	SET @result = -1
GO
/****** Object:  StoredProcedure [dbo].[AccountUpdateProfile_new]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[AccountUpdateProfile_new]
	@Email		AS NVARCHAR(50), 
	@UserID	AS NVARCHAR(50), 
	@Firstname	AS VARCHAR(30), 
	@MI		AS VARCHAR(1), 
	@Lastname	AS VARCHAR(30), 
	@Birthday	AS DATETIME,
	@Sex		AS INT,
	@Address	AS NVARCHAR(100),
	@City		AS NVARCHAR(50),
	@State		AS NVARCHAR(50),
	@Country	AS NVARCHAR(50),
	@MobileNo	AS NVARCHAR(15),
	@HomeNo	AS NVARCHAR(15),
	@result 		AS INT OUTPUT,
	@UserKey	AS NVARCHAR(7)
AS
SET NOCOUNT ON
DECLARE  @NCashResult AS INT, @NCashMsg AS NVARCHAR(100)

IF EXISTS (SELECT * FROM Account WITH (NOLOCK) WHERE UserID = @UserID AND Email != @Email)
	SET @result = -101 --User id exist already
ELSE IF EXISTS (SELECT * FROM Account WITH (NOLOCK) WHERE UserID = @UserID AND Email = @Email)
BEGIN	
	UPDATE Account SET  Birthday= @Birthday, Sex = @Sex, Firstname = @Firstname, Lastname = @Lastname, MI = @MI,
		Address = @Address, City = @City,
		State = @State, Country = @country,
		MobileNo = @MobileNo,	HomeNo = @HomeNo, UserKey = @UserKey 
	WHERE Email = @Email
	SET @result = 0
END
ELSE -- Update user id now
BEGIN

	UPDATE Account SET  Birthday= @Birthday, Sex = @Sex, Firstname = @Firstname, Lastname = @Lastname, MI = @MI,
		Address = @Address, City = @City,
		State = @State, Country = @country,
		MobileNo = @MobileNo,	HomeNo = @HomeNo, UserKey = @UserKey  
	WHERE Email = @Email
	SET @result = 0

END

--Update profile in Billing DB
EXEC AccountUpdateProfileInBilling
	@Email, -- Email as key
	@NCashResult OUTPUT,
	@NCashMsg    OUTPUT
GO
/****** Object:  StoredProcedure [dbo].[AccountUpdateProfile]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[AccountUpdateProfile]
	@Email		AS NVARCHAR(50), 
	@UserID	AS NVARCHAR(50), 
	@Birthday	AS DATETIME,
	@Sex		AS INT,
	@Address	AS NVARCHAR(100),
	@City		AS NVARCHAR(50),
	@State		AS NVARCHAR(50),
	@Country	AS NVARCHAR(50),
	@MobileNo	AS NVARCHAR(15),
	@HomeNo	AS NVARCHAR(15),
	@result 		AS INT OUTPUT,
	@UserKey	AS NVARCHAR(7)
AS
SET NOCOUNT ON
DECLARE  @NCashResult AS INT, @NCashMsg AS NVARCHAR(100)

IF EXISTS (SELECT * FROM Account WITH (NOLOCK) WHERE UserID = @UserID AND Email != @Email)
	SET @result = -101 --User id exist already
ELSE IF EXISTS (SELECT * FROM Account WITH (NOLOCK) WHERE UserID = @UserID AND Email = @Email)
BEGIN	
	UPDATE Account SET  Birthday= @Birthday, Sex = @Sex,
		Address = @Address, City = @City,
		State = @State, Country = @country,
		MobileNo = @MobileNo,	HomeNo = @HomeNo, UserKey = @UserKey 
	WHERE Email = @Email
	SET @result = 0
END
ELSE -- Update user id now
BEGIN

	UPDATE Account SET  Birthday= @Birthday, Sex = @Sex,
		Address = @Address, City = @City,
		State = @State, Country = @country,
		MobileNo = @MobileNo,	HomeNo = @HomeNo, UserKey = @UserKey  
	WHERE Email = @Email
	SET @result = 0

END

--Update profile in Billing DB
EXEC AccountUpdateProfileInBilling
	@Email, -- Email as key
	@NCashResult OUTPUT,
	@NCashMsg    OUTPUT
GO
/****** Object:  StoredProcedure [dbo].[AccountActivate]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[AccountActivate]
	@ActivationKey	AS UniqueIdentifier,
	@Email		AS NVARCHAR(50) OUTPUT,
	@UserID	AS NVARCHAR(50) OUTPUT,
	@Password	AS NVARCHAR(70) OUTPUT,
	@result 		AS INT OUTPUT
AS
SET @result = 0
DECLARE @Activated AS INT,  @NCashResult INT, @NCashMsg NVARCHAR(100)
SET NOCOUNT ON
SELECT  @Activated = Activated FROM Account  WITH (NOLOCK) WHERE ActivationKey = @ActivationKey
IF @@ROWCOUNT = 1
BEGIN
	IF  (@Activated = 1) --Account already activated
	BEGIN
		SET @result = -1
		RETURN --Exit
	END
	ELSE --NOT yet activated
	BEGIN 
		BEGIN TRAN
			UPDATE Account SET Activated  = 1 WHERE ActivationKey = @ActivationKey
			SELECT @Email = Email, @UserID = UserID, @Password = [Password] FROM Account  WITH (NOLOCK) WHERE ActivationKey = @ActivationKey
			--Insert user in Billing DB only when the user activated their account
			EXEC AccountInsertUserInBilling 	@Email, @NCashResult OUTPUT, 	@NCashMsg OUTPUT
		IF @NCashResult = -1 --Error returned while inserting data  to Billling DB
		BEGIN
			SET @result = -3  /* error */
			ROLLBACK TRAN
		END
		ELSE
		BEGIN
			SET @result = 0 /* OK, return email and password */
			COMMIT TRAN
		END
	END
END
ELSE
	SET @result = -2 /* NOT found */
GO
/****** Object:  StoredProcedure [dbo].[TW_updateUserProfile]    Script Date: 09/21/2014 18:02:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
SP Name: TW_updateUserProfile
Parameter: UserID,Email
Description: update a user's profile from Account table
Date: 2006/01/02 16:42
Author: bin
*/
CREATE PROCEDURE [dbo].[TW_updateUserProfile]

@UserID NVARCHAR(50),
@Email NVARCHAR(50),
@Firstname NVARCHAR(30), 
@MI NVARCHAR(1), 
@Lastname NVARCHAR(30), 
@Birthday DATETIME,
@Sex INT,
@Address NVARCHAR(100),
@City NVARCHAR(50),
@State NVARCHAR(50),
@Country NVARCHAR(50),
@MobileNo NVARCHAR(15),
@HomeNo NVARCHAR(15)

AS

SET NOCOUNT ON
DECLARE  @NCashResult INT
DECLARE @NCashMsg NVARCHAR(100)

UPDATE Account SET
Birthday= @Birthday,
Sex = @Sex,
Firstname = @Firstname,
Lastname = @Lastname,
MI = @MI,
Address = @Address,
City = @City,
State = @State,
Country = @country,
MobileNo = @MobileNo,
HomeNo = @HomeNo
WHERE Email = @Email AND UserID = @UserID

EXEC AccountUpdateProfileInBilling
	@Email, -- Email as key
	@NCashResult OUTPUT,
	@NCashMsg    OUTPUT
GO
/****** Object:  StoredProcedure [dbo].[k3a_UpdateUserProfile2]    Script Date: 09/21/2014 18:02:38 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[k3a_UpdateUserProfile2]

@Email NVARCHAR(50),
@UserID NVARCHAR(50),
@FirstName NVARCHAR(50),
@MI NVARCHAR(1),
@LastName NVARCHAR(50),
@Birthday DATETIME,
@Sex TINYINT,
@Address NVARCHAR(50),
@City NVARCHAR(50),
@State NVARCHAR(50),
@Country NVARCHAR(50),
@MobileNo NVARCHAR(15),
@HomeNo NVARCHAR(15),
@userKey NVARCHAR(7),
@Answer NVARCHAR(50),
@resultCode INT OUT

AS

DECLARE	@NCashResult 	INT
DECLARE	@NCashMsg    	NVARCHAR(100)

SET @resultCode = 0

IF NOT EXISTS(SELECT userId FROM Account WITH (NOLOCK) WHERE UserId = @UserId AND Email = @Email)
BEGIN
	SET @resultCode = -101
	RETURN
END

	UPDATE Account
	SET 	FirstName = @FirstName,
		MI = @MI,
		LastName = @LastName,
		Birthday = @Birthday,
		Sex = @Sex,
		Address = @Address,
		City = @City,
		State = @State,
		Country = @Country,
		MobileNo = @MobileNo,
		HomeNo = @HomeNo,
		Userkey = @userKey,
		Answer = @Answer
	WHERE UserID = @UserID


IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SET @resultCode = 1
	EXEC AccountUpdateProfileInBilling @Email, @NCashResult OUTPUT, @NCashMsg OUTPUT
END
GO
/****** Object:  StoredProcedure [dbo].[k3a_UpdateUserProfile]    Script Date: 09/21/2014 18:02:38 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[k3a_UpdateUserProfile]

@Email NVARCHAR(50),
@UserID NVARCHAR(50),
@FirstName NVARCHAR(50),
@MI NVARCHAR(1),
@LastName NVARCHAR(50),
@Birthday DATETIME,
@Sex TINYINT,
@Address NVARCHAR(50),
@City NVARCHAR(50),
@State NVARCHAR(50),
@Country NVARCHAR(50),
@MobileNo NVARCHAR(15),
@HomeNo NVARCHAR(15),
@userKey NVARCHAR(7),
@resultCode INT OUT

AS

DECLARE	@NCashResult 	INT
DECLARE	@NCashMsg    	NVARCHAR(100)

SET @resultCode = 0

IF NOT EXISTS(SELECT userId FROM Account WITH (NOLOCK) WHERE UserId = @UserId AND Email = @Email)
BEGIN
	SET @resultCode = -101
	RETURN
END

	UPDATE Account
	SET 	FirstName = @FirstName,
		MI = @MI,
		LastName = @LastName,
		Birthday = @Birthday,
		Sex = @Sex,
		Address = @Address,
		City = @City,
		State = @State,
		Country = @Country,
		MobileNo = @MobileNo,
		HomeNo = @HomeNo,
		Userkey = @userKey
	WHERE UserID = @UserID


IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SET @resultCode = 1
	EXEC AccountUpdateProfileInBilling @Email, @NCashResult OUTPUT, @NCashMsg OUTPUT
END
GO
/****** Object:  StoredProcedure [dbo].[k3a_TantraRegisterAndActivate]    Script Date: 09/21/2014 18:02:38 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[k3a_TantraRegisterAndActivate]
@Email NVARCHAR(50),
@UserID NVARCHAR(50),
@Password NVARCHAR(40),
@SecretQuestion NVARCHAR(50),
@Answer NVARCHAR(50),
@UserKey NVARCHAR(7),
@FirstName NVARCHAR(30),
@MI NVARCHAR(1),
@LastName NVARCHAR(30),
@Birthday DATETIME,
@Sex TINYINT,
@Address NVARCHAR(100),
@City NVARCHAR(50),
@State NVARCHAR(50),
@Country NVARCHAR(50),
@MobileNo NVARCHAR(15),
@HomeNo NVARCHAR(15),
@WherePlay NVARCHAR(100),
@InternetCon NVARCHAR(100),
@ISPCafe NVARCHAR(100),
@AboutTantra NVARCHAR(100),
@RegIPAddress NVARCHAR(15),
@ActivationKey UNIQUEIDENTIFIER OUT,
@resultCode INT OUT

AS

DECLARE @NCashResult INT
DECLARE @NCashMsg VARCHAR(100)

SET @resultCode = 0
SET NOCOUNT ON
IF NOT EXISTS(SELECT Email FROM Account WITH (NOLOCK) WHERE Email = @Email)
BEGIN
	IF EXISTS (SELECT UserID FROM Account WITH (NOLOCK) WHERE UserID = @UserID)
	BEGIN
		SET @resultCode = -2 -- UserID Exists
		RETURN -- Exits Code
	END

	BEGIN TRAN
		SET @ActivationKey = NEWID() 
		INSERT INTO Account (Email, UserID, [Password], SecretQuestion, Answer, Firstname, mi, Lastname, Birthday, Sex, Address,
			City, State, Country, MobileNo, HomeNo, WherePlay, InternetCon, ISPCafe, 
			 AboutTantra, RegIPAddress,  ActivationKey, UserKey,Testaccount)
		VALUES (@Email, @UserID, @Password, @SecretQuestion, @Answer, @FirstName, @MI, @LastName, @Birthday, @Sex, @Address,
			@City, @State, @Country, @MobileNo, @HomeNo, @WherePlay, @InternetCon, @ISPCafe, 
			@AboutTantra, @RegIPAddress, @ActivationKey, @UserKey,1)

	IF @@ERROR = 0
	BEGIN
		UPDATE Account SET Activated  = 1 WHERE ActivationKey = @ActivationKey
		SELECT @Email = Email, @UserID = UserID, @Password = [Password] FROM Account  WITH (NOLOCK) WHERE ActivationKey = @ActivationKey
		--Insert user in Billing DB only when the user activated their account
		EXEC AccountInsertUserInBilling 	@Email, @NCashResult OUTPUT, @NCashMsg OUTPUT
		IF @NCashResult = -1 --Error returned while inserting data  to Billling DB
		BEGIN
			SET @resultCode = -3  /* error */
			ROLLBACK TRAN
		END
		ELSE
		BEGIN
			SET @resultCode = 1 /* OK, return email and password */
			COMMIT TRAN
		END
	END
	ELSE
	BEGIN
		SET @resultCode = -99 -- Unidentified error
	END
END
ELSE
BEGIN 
	SET @resultCode = -1 -- Email exists
END
GO
/****** Object:  StoredProcedure [dbo].[TantraToolForcedActivate]    Script Date: 09/21/2014 18:02:38 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE       PROCEDURE [dbo].[TantraToolForcedActivate]

	@Email		AS NVARCHAR(50) OUTPUT,
	@UserID	AS NVARCHAR(50) OUTPUT,
	@Password	AS NVARCHAR(70) OUTPUT,
	@result 		AS INT OUTPUT

AS

DECLARE @ActivationKey AS UNIQUEIDENTIFIER
DECLARE @Count AS INT

SET @Count = 0
DECLARE nonactivated_cursor CURSOR FOR
	SELECT Top 10 percent ActivationKey FROM Account WITH (NOLOCK)
	WHERE Activated = 0 AND UserID IS NOT NULL AND ActivationKey IS NOT NULL
	ORDER BY UserID ASC

OPEN nonactivated_cursor
FETCH NEXT FROM nonactivated_cursor INTO @ActivationKey
WHILE @@FETCH_STATUS = 0
BEGIN
	--WAITFOR DELAY '00:00:01' -- Sleep time of 2 seconds before doing an action
	PRINT @ActivationKey
	SET @Count = @Count + 1
	-- CALL AccountActivate
	EXEC AccountActivate @ActivationKey, @Email OUTPUT, @UserID OUTPUT, @Password OUTPUT, @result OUTPUT
	FETCH NEXT FROM nonactivated_cursor INTO @ActivationKey
END
CLOSE nonactivated_cursor
DEALLOCATE nonactivated_cursor

PRINT 'Total rows affected:' + CAST(@Count AS VARCHAR)
GO
/****** Object:  Default [DF_FanArt_DateSubmitted]    Script Date: 09/21/2014 18:02:33 ******/
ALTER TABLE [dbo].[FanArt] ADD  CONSTRAINT [DF_FanArt_DateSubmitted]  DEFAULT (getdate()) FOR [DateSubmitted]
GO
/****** Object:  Default [DF_FanArt_Approved]    Script Date: 09/21/2014 18:02:33 ******/
ALTER TABLE [dbo].[FanArt] ADD  CONSTRAINT [DF_FanArt_Approved]  DEFAULT ((0)) FOR [Approved]
GO
/****** Object:  Default [DF_BugReport_DateSubmitted]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[BugReport] ADD  CONSTRAINT [DF_BugReport_DateSubmitted]  DEFAULT (getdate()) FOR [DateSubmitted]
GO
/****** Object:  Default [DF_BugReport_Fixed]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[BugReport] ADD  CONSTRAINT [DF_BugReport_Fixed]  DEFAULT ((0)) FOR [Fixed]
GO
/****** Object:  Default [DF_BugReport_Qualified]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[BugReport] ADD  CONSTRAINT [DF_BugReport_Qualified]  DEFAULT ((-1)) FOR [Qualified]
GO
/****** Object:  Default [DF_Candidate_GMPercent]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Candidate] ADD  CONSTRAINT [DF_Candidate_GMPercent]  DEFAULT ((0)) FOR [GMPercent]
GO
/****** Object:  Default [DF_Council_RegDate]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Council] ADD  CONSTRAINT [DF_Council_RegDate]  DEFAULT (getdate()) FOR [RegDate]
GO
/****** Object:  Default [DF_Account_UserKey]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_UserKey]  DEFAULT ('') FOR [UserKey]
GO
/****** Object:  Default [DF_Account_Blocked]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_Blocked]  DEFAULT ((0)) FOR [Blocked]
GO
/****** Object:  Default [DF_Account_Birthday]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_Birthday]  DEFAULT (((1)/(1))/(1940)) FOR [Birthday]
GO
/****** Object:  Default [DF_Account_Sex]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_Sex]  DEFAULT ((1)) FOR [Sex]
GO
/****** Object:  Default [DF_Account_Country]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_Country]  DEFAULT (N'Philippines') FOR [Country]
GO
/****** Object:  Default [DF_Account_DateRegistered]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_DateRegistered]  DEFAULT (getdate()) FOR [DateRegistered]
GO
/****** Object:  Default [DF_Account_Activated]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_Activated]  DEFAULT ((0)) FOR [Activated]
GO
/****** Object:  Default [DF_Account_CloseBeta]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_CloseBeta]  DEFAULT ((0)) FOR [CloseBeta]
GO
/****** Object:  Default [DF_Account_Vote]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_Vote]  DEFAULT ((0)) FOR [Vote]
GO
/****** Object:  Default [DF_Account_CreditCardPaymentErrorCount]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_CreditCardPaymentErrorCount]  DEFAULT ((0)) FOR [CreditCardPaymentErrorCount]
GO
/****** Object:  Default [DF_Account_LastCreditCardPaymentErrorCount]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_LastCreditCardPaymentErrorCount]  DEFAULT (getdate()) FOR [LastCreditCardPaymentErrorDate]
GO
/****** Object:  Default [DF_Account_Confirmed]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_Confirmed]  DEFAULT ((0)) FOR [Confirmed]
GO
/****** Object:  Default [DF_Account_AllowCreditCard]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_AllowCreditCard]  DEFAULT ((0)) FOR [AllowCreditCard]
GO
/****** Object:  Default [DF_Account_SpamMail]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_SpamMail]  DEFAULT ((0)) FOR [SpamMail]
GO
/****** Object:  Default [DF_Account_RejectMail]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_RejectMail]  DEFAULT ((0)) FOR [RejectMail]
GO
/****** Object:  Default [DF_Account_UserCreated]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [DF_Account_UserCreated]  DEFAULT ((0)) FOR [IsUserCreated]
GO
/****** Object:  Default [DF_BanAct_Sent]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[BanAct] ADD  CONSTRAINT [DF_BanAct_Sent]  DEFAULT ((0)) FOR [Sent]
GO
/****** Object:  Default [DF_NewsItem_Display]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[NewsItem] ADD  CONSTRAINT [DF_NewsItem_Display]  DEFAULT ((1)) FOR [Display]
GO
/****** Object:  Default [DF_NewsItem_DateAdded]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[NewsItem] ADD  CONSTRAINT [DF_NewsItem_DateAdded]  DEFAULT (getdate()) FOR [DateAdded]
GO
/****** Object:  Default [DF_tblProduct_Display]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Display]  DEFAULT ((0)) FOR [Display]
GO
/****** Object:  Default [DF_reactivationLog_reactivationTime]    Script Date: 09/21/2014 18:02:35 ******/
ALTER TABLE [dbo].[reactivationLog] ADD  CONSTRAINT [DF_reactivationLog_reactivationTime]  DEFAULT (getdate()) FOR [reactivationTime]
GO
/****** Object:  ForeignKey [FK_CouncilPoll_Candidate]    Script Date: 09/21/2014 18:02:37 ******/
ALTER TABLE [dbo].[CouncilPoll]  WITH CHECK ADD  CONSTRAINT [FK_CouncilPoll_Candidate] FOREIGN KEY([Candidate])
REFERENCES [dbo].[Candidate] ([Candidate])
GO
ALTER TABLE [dbo].[CouncilPoll] CHECK CONSTRAINT [FK_CouncilPoll_Candidate]
GO
