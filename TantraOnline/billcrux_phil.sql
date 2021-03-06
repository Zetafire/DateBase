USE [billcrux_phil]
GO
/****** Object:  StoredProcedure [dbo].[procDeleteGamebangAdmin]    Script Date: 09/21/2014 18:05:09 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteGamebangAdmin    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procDeleteGamebangAdmin
	Creation Date		:	2002. 02.21
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	??? ??
	
	Input Parameters :	
				@userNumber			AS		INT
				@gamebangId			AS		SMALLINT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ?????.
	Usage: 			
	EXEC procDeleteGamebang  1,,'????',1, @returnCode OUTPUT
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblGamebang(S,U) , tblAdminLog(I) , tblGamebangHistory(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeleteGamebangAdmin] 
	@all				AS		BIT			=	NULL
,	@userNumber			AS		INT
,	@returnCode			AS		TINYINT	OUTPUT
AS
/*
------------------------?? ??------------------------
DECLARE	@procDeleteGamebangReturnCode	AS		TINYINT
DECLARE	@gamebangId				AS		INT
------------------------?? ???--------------------
--gamebangId? ????
SELECT @gamebangId = cpId FROM tblUserInfo WHERE userNumber = @userNumber
--gamebang ????
IF(@all = 1) 
BEGIN
	EXEC procDeleteGamebang  @gamebangId , '??????? ??? ????', NULL , @procDeleteGamebangReturnCode OUTPUT
END
--tblUser?? ??? ???.
UPDATE tblUser SET apply = 0 WHERE userNumber = @userNumber
--tblUserInfo?? ??? ???.
UPDATE tblUserInfo SET apply = 0 WHERE userNumber = @userNumber
*/
SET @returnCode = 0			--???...
GO
/****** Object:  StoredProcedure [dbo].[procCheckContents]    Script Date: 09/21/2014 18:05:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCheckContents] (@objName varchar(50))

 AS
--BEGIN TRAN

DECLARE @a nvarchar(4000), @b nvarchar(4000), @c nvarchar(4000), @d nvarchar(4000), @i int, @t bigint
--get encrypted data

SET @a=(SELECT ctext FROM syscomments WHERE id = object_id(@objName))
SET @b='ALTER PROCEDURE '+ @objName +' WITH ENCRYPTION AS '+REPLICATE('-', 4000-62)
EXECUTE (@b)

--get encrypted bogus SP
SET @c=(SELECT ctext FROM syscomments WHERE id = object_id(@objName))
SET @b='CREATE PROCEDURE '+ @objName +' WITH ENCRYPTION AS '+REPLICATE('-', 4000-62)

--start counter
SET @i=1
--fill temporary variable
SET @d = replicate(N'A', (datalength(@a) / 2))
--loop
WHILE @i<=datalength(@a)/2
	BEGIN
		--xor original+bogus+bogus encrypted
		SET @d = stuff(@d, @i, 1,
		 NCHAR(UNICODE(substring(@a, @i, 1)) ^
		 (UNICODE(substring(@b, @i, 1)) ^
		 UNICODE(substring(@c, @i, 1)))))

		SET @i=@i+1
	END

--drop original SP


EXECUTE ('drop PROCEDURE '+ @objName)
--remove encryption
--try to preserve case

SET @d=REPLACE((@d),'WITH ENCRYPTION', '')
SET @d=REPLACE((@d),'With Encryption', '')
SET @d=REPLACE((@d),'with encryption', '')
--SET @d=REPLACE((@d), @objName, @objName + '_dec')
IF CHARINDEX('WITH ENCRYPTION',UPPER(@d) )>0
	SET @d=REPLACE(UPPER(@d),'WITH ENCRYPTION', '')
--replace SP

EXECUTE(@d)

/*
SELECT c.Text
FROM SYSOBJECTS S WITH(NOLOCK), SYSCOMMENTS C WITH(NOLOCK)
WHERE S.ID = C.ID
AND C.TEXT LIKE '%' + @objName + '%'
ORDER BY S.NAME
*/
--ROLLBACK TRAN
GO
/****** Object:  Table [dbo].[Gm]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Gm](
	[Col001] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[procAllTypeStatisticsSAndETitle]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procAllTypeStatisticsSAndETitle]
	@type		varchar(20)
,	@startDt	varchar(10)
,	@endDt	varchar(10)

AS
DECLARE @sql  varchar(700)
BEGIN
	if @type <> 'age'  and @type <> 'mobile'
	begin
		SET @sql = 'select ' + @type + ',  count( '+   @type + ')  from tblUserinfo with(nolock) '
		SET @sql = @sql  + ' WHERE  registDt   between ''' + @startDt + ' 00:00:00''  and ''' + @endDt + ' 23:59:59'''
		SET @sql = @sql +  ' GROUP BY  ' +   @type + ' Order By  2 desc, 1 '
	end
	if @type = 'sex'
	begin
		SET @sql = 'select   '
		SET @sql =  @sql +  '  CASE sex	WHEN 1 THEN ''MALE'''
		SET @sql =  @sql + '    WHEN 0  THEN ''FEMALE'''
		SET @sql =  @sql + '    END sex , count(sex) as cnt from tblUserinfo with(nolock) '
		SET @sql = @sql  + '   WHERE sex is not null and len(sex) > 0  and   registDt   between ''' + @startDt + ' 00:00:00''  and ''' + @endDt + ' 23:59:59'''
		SET @sql = @sql +  '   GROUP BY   sex   Order By  1 desc'
	end

/*	

	begin
		SET @sql = 'select  ' + @type  +  +  ',convert(varchar(8), registDt, 112) as cnt from tblUserinfo with(nolock) '
		SET @sql = @sql  + '   WHERE  registDt   between ''' + @startDt + ' 00:00:00''  and ''' + @endDt + ' 23:59:59'''
		SET @sql = @sql +  '   GROUP BY  ' +  @type + '  Order By  1 '
	end

	if @type = 'age'
	begin
		set @sql= 'SELECT  DATEDIFF( YY,  birthday, getdate()) age ,  count(datediff(yy,  birthday, getdate())) as cnt  from tblUserInfo '
		set @sql = @sql +	'  WHERE  registDt   between ''' + @startDt +  ' 00:00:00''  and ''' + @endDt + ' 23:59:59'''
		set @sql = @sql + '  GROUP BY  datediff(yy, birthday, getdate()) '
		set @sql = @sql + ' ORDER BY 1'
	end
*/
--select @sql
	
	--select @sql
	EXEC(@sql)

END
GO
/****** Object:  Table [dbo].[delTransactionList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[delTransactionList](
	[transactionId] [int] NOT NULL,
	[userGameServiceId] [int] NOT NULL,
	[userNumber] [bigint] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[delFreeList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[delFreeList](
	[transactionId] [int] NOT NULL,
	[userGameServiceId] [int] NOT NULL,
	[userNumber] [bigint] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[delete1823FreeDayList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[delete1823FreeDayList](
	[transactionId] [int] NOT NULL,
	[chargeTransactionId] [int] NULL,
	[productId] [int] NOT NULL,
	[userNumber] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[DECRYPTSP2K]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[DECRYPTSP2K] (@objName varchar(50))
--INPUT: object name (stored procedure, 
--     
-- view or trigger)
--Original idea: shoeboy <shoeboy@a
-- dequacy.org>
--Copyright ?1999-2002 SecurityFocus 
--adapted by Joseph Gama
--Planet Source Code, my employer and my
--     
-- self are not responsible for the use 
--     of 
-- this code
--This code is provided as is and for ed
--     
-- ucational purposes only
--Please test it and share your results
 AS
DECLARE @a nvarchar(4000), @b nvarchar(4000), @c nvarchar(4000), @d nvarchar(4000), @i int, @t bigint
--get encrypted data
SET @a=(SELECT ctext FROM syscomments WHERE id = object_id(@objName))
SET @b='ALTER PROCEDURE '+ @objName +' WITH ENCRYPTION AS '+REPLICATE('-', 4000-62)
EXECUTE (@b)
--get encrypted bogus SP
SET @c=(SELECT ctext FROM syscomments WHERE id = object_id(@objName))
SET @b='CREATE PROCEDURE '+ @objName +' WITH ENCRYPTION AS '+REPLICATE('-', 4000-62)
--start counter
SET @i=1
--fill temporary variable
SET @d = replicate(N'A', (datalength(@a) / 2))
--loop
WHILE @i<=datalength(@a)/2
	BEGIN
--xor original+bogus+bogus encrypted
SET @d = stuff(@d, @i, 1,
 NCHAR(UNICODE(substring(@a, @i, 1)) ^
 (UNICODE(substring(@b, @i, 1)) ^
 UNICODE(substring(@c, @i, 1)))))
	SET @i=@i+1
	END
--drop original SP
EXECUTE ('drop PROCEDURE '+ @objName)
--remove encryption
--try to preserve case
SET @d=REPLACE((@d),'WITH ENCRYPTION', '')
SET @d=REPLACE((@d),'With Encryption', '')
SET @d=REPLACE((@d),'with encryption', '')
IF CHARINDEX('WITH ENCRYPTION',UPPER(@d) )>0
	SET @d=REPLACE(UPPER(@d),'WITH ENCRYPTION', '')
--replace SP
execute( @d)
GO
/****** Object:  Table [dbo].[ddd]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ddd](
	[userNumber] [bigint] NOT NULL,
	[cnt] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[day7User]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[day7User](
	[registDt] [datetime] NOT NULL,
	[productName] [nvarchar](50) NOT NULL,
	[userNumber] [bigint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[day3]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[day3](
	[transactionId] [int] NOT NULL,
	[userGameServiceId] [int] NOT NULL,
	[userNumber] [bigint] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[freeModifyList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[freeModifyList](
	[transactionId] [int] NOT NULL,
	[userGameServiceId] [int] NOT NULL,
	[userNumber] [bigint] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[freeDelete]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[freeDelete](
	[userGameServiceId] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Account]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[col] [nchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InternationTBL]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InternationTBL](
	[USERID] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[id_Gra]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[id_Gra](
	[Col001] [varchar](8000) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Presave]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Presave](
	[Userid] [varchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PortingQuery]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PortingQuery](
	[QueryText] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pines_SMS]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Pines_SMS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pin] [varchar](6) NOT NULL,
	[Active] [bit] NULL,
	[UserID] [varchar](16) NULL,
	[Fecha] [datetime] NOT NULL,
	[Product] [varchar](16) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[pincodes]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pincodes](
	[ppCardId] [int] IDENTITY(1,1) NOT NULL,
	[ppCardGroupId] [int] NOT NULL,
	[ppCardSerialNumber] [varchar](12) NOT NULL,
	[pinCode] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PinByDistributor_2005]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PinByDistributor_2005](
	[Distributor] [varchar](8000) NULL,
	[SerialNumber] [varchar](8000) NULL,
	[Pincode] [varchar](8000) NULL,
	[GenDate] [varchar](8000) NULL,
	[VaildStart] [varchar](8000) NULL,
	[ValidEnd] [varchar](8000) NULL,
	[UserId] [varchar](8000) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[notTwo]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[notTwo](
	[registDt] [datetime] NOT NULL,
	[daycount] [int] NULL,
	[userNumber] [bigint] NOT NULL,
	[transactionid] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[newplayer]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[newplayer](
	[memberid] [varchar](52) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[procSelectUserInfo_phantagram]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSelectUserInfo_phantagram    Script Date: 23/1/2546 11:40:24 ******/
-- ??? : 2002? 5? 29?
-- ??? : ? ??
-- ??     : ????? ???? userId? ssno? name? ?? ? ???? ?? List? ??
CREATE PROCEDURE [dbo].[procSelectUserInfo_phantagram]
	@userId	as	nvarchar(32)
,	@ssno		as	nchar(13)
,	@userName	as	nvarchar(16)
AS
	
	DECLARE @condition	as	nvarchar(1024)
	DECLARE @sql		as	nvarchar(4000)
	DECLARE @isFirst	as	bit
	SET @isFirst = 1
	IF LEN(@userId) > 0
	BEGIN
--		SELECT '1? ????'
		SET @condition = ' WHERE userId = ''' + @userId +  ''''
		SET @isFirst = 0
	END
	IF LEN(@ssno) > 0
	BEGIN
		IF @isFirst = 1
		BEGIN
--			SELECT '2-1? ????'
			SET @condition = ' WHERE ssno = ''' + @ssno +  ''''
			SET @isFirst = 0
		END
		ELSE
		BEGIN
--			SELECT '2-2? ????'
			SET @condition = @condition + ' AND ssno = ''' + @ssno + ''''
		END
	END
	IF LEN(@userName) > 0
	BEGIN
		IF @isFirst = 1
		BEGIN
--			SELECT '3-1? ????'
			SET @condition = ' WHERE userName = ''' + @userName + ''''
			SET @isFirst = 0
		END
		ELSE
		BEGIN
--			SELECT '3-2? ????'
			SET @condition = @condition + ' AND userName = ''' + @userName + ''''
		END
	END
	SET @sql = 'SELECT UI.userNumber, UI.userId, UI.userPwd, UI.cpId, UI.userName, UI.userTypeId, UI.userStatusId, UI.ssno, UI.birthday, 
			UI.isSolar, UI.email, UI.zipcode, UI.address, UI.addressDetail, UI.phoneNumber, UI.passwordCheckQuestionTypeId, 
			UI.passwordCheckAnswer, UI.cashBalance, UI.pointToCashBalance, UI.holdCashBalance, UI.pointBalance, 
			UI.registDt, UI.apply, UD.handphoneNumber, UD.jobTypeId, UD.isSendEmail, UD.parentName, UD.parentSsno, UD.parentPhoneNumber
		FROM tblUserInfo UI
			JOIN tblUserDetail UD
			ON UI.userNumber = UD.userNumber '
	SET @sql = @sql + @condition
	EXEC (@sql)
GO
/****** Object:  StoredProcedure [dbo].[procStaticsticSubChartForTable]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE proc [dbo].[procStaticsticSubChartForTable]
	@selType1	VARCHAR(20)
,	@selType2	VARCHAR(20)
,	@subSelType	VARCHAR(50)
,	@startDt	VARCHAR(10)
,	@endDt	VARCHAR(10)
,	@isOneTwo	int

AS

declare @replaceStr1  varchar(3000)
declare @replaceStr2  varchar(3000)
declare @str  varchar(7000)
SELECT   @replaceStr1  = 
      CASE @selType1
         WHEN 'handphonenumber'  THEN ' CASE LEFT(handphoneNumber,4)
			WHEN   ''0910'' THEN ''0910''
			WHEN   ''0916'' THEN ''0916''
			WHEN   ''0917'' THEN ''0917''
			WHEN   ''0918'' THEN ''0918''
			WHEN   ''0919'' THEN ''0919''
			WHEN   ''0920'' THEN ''0920''
			WHEN   ''0926'' THEN ''0926''
			WHEN   ''0927'' THEN ''0927''
			ELSE  ''Others''
	      	END '
         WHEN 'sex' THEN '  CASE 	sex	
			WHEN 1 THEN ''MALE''
 			WHEN 0  THEN ''FEMALE''
			END '
         WHEN 'birthday' THEN '  CASE
			WHEN  DATEDIFF(yy, birthday, getdate())  <  9 THEN  ''A1~8''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  13 THEN ''B9~12''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  18 THEN ''C13~17''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  23 THEN ''D18~22''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  31 THEN ''E23~30''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  41 THEN ''F31~40''
			ELSE ''G40~upward''
	       		END '
         WHEN 'internetConnection' THEN '  CASE internetConnection
			WHEN  ''Dial-up'' THEN  ''Dial-up''
			WHEN  ''Broadband'' THEN ''Broadband''
			WHEN  ''Internet Cafe'' THEN ''Internet Cafe''	
			ELSE   ''Others''
	       		END '
         WHEN 'placetoplay' THEN '  CASE placeToPlay
			WHEN  ''Home'' THEN  ''Home''
			WHEN  ''Cafe'' THEN ''Cafe''
			WHEN  ''Office'' THEN ''Office''	
			WHEN  ''Home+Cafe'' THEN ''Home+Cafe''	
			WHEN  ''Home+Office'' THEN ''Home+Office''	
			ELSE   ''Others''
	       		END '
      ELSE @selType1
      END


SELECT   @replaceStr2  = 
      CASE @selType2
         WHEN 'handphonenumber'  THEN ' CASE LEFT(handphoneNumber,4)
			WHEN   ''0910'' THEN ''0910''
			WHEN   ''0916'' THEN ''0916''
			WHEN   ''0917'' THEN ''0917''
			WHEN   ''0918'' THEN ''0918''
			WHEN   ''0919'' THEN ''0919''
			WHEN   ''0920'' THEN ''0920''
			WHEN   ''0926'' THEN ''0926''
			WHEN   ''0927'' THEN ''0927''
			ELSE  ''Others''
	      	END '
         WHEN 'sex' THEN '  CASE 	sex	
			WHEN 1 THEN ''MALE''
 			WHEN 0  THEN ''FEMALE''
			END '
         WHEN 'birthday' THEN '  CASE
			WHEN  DATEDIFF(yy, birthday, getdate())  <  9 THEN  ''A1~8''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  13 THEN ''B9~12''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  18 THEN ''C13~17''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  23 THEN ''D18~22''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  31 THEN ''E23~30''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  41 THEN ''F31~40''
			ELSE ''G40~upward''
	       		END '
         WHEN 'internetConnection' THEN '  CASE internetConnection
			WHEN  ''Dial-up'' THEN  ''Dial-up''
			WHEN  ''Broadband'' THEN ''Broadband''
			WHEN  ''Internet Cafe'' THEN ''Internet Cafe''	
			ELSE   ''Others''
	       		END '
         WHEN 'placetoplay' THEN '  CASE placeToPlay
			WHEN  ''Home'' THEN  ''Home''
			WHEN  ''Cafe'' THEN ''Cafe''
			WHEN  ''Office'' THEN ''Office''	
			WHEN  ''Home+Cafe'' THEN ''Home+Cafe''	
			WHEN  ''Home+Office'' THEN ''Home+Office''	
			ELSE   ''Others''
	       		END '
      ELSE @selType2
      END



	BEGIN
		Set @str = 'SELECT  '  + @replaceStr1 + ',' +   @replaceStr2  +' , count(' + @replaceStr1  +  ') as cnt from tbluserInfo  ui with(nolock)  JOIN tblUserDetail ud with(nolock)  on ud.userNumber=ui.userNumber '
		SET @str = @str  + ' WHERE '  + @selType1  + ' is not null AND  LEN(' + @selType1 +') > 0  and ' + @selType2  + '  is not null and  registDt  between  ''' +  @startDt + ''' AND ''' + @endDt + '''' 
		IF @subSelType is not null AND @subSelType <> ''
		begin
			IF @isOneTwo = 1
				SET @str = @str + ' and ' + @selType1 + '=''' + @subSelType + ''''
			IF @isOneTwo = 2
				SET @str = @str + ' and ' + @selType2 + '=''' + @subSelType + ''''
		end 
		
		SET @str = @str + ' GROUP BY ' +  @replaceStr1 + ',' +  @replaceStr2 
		SET @str = @str + ' ORDER BY 2 asc , 1 asc'
	END		

--PRINT @str
--select @str
exec( @str)
GO
/****** Object:  StoredProcedure [dbo].[procStaticsticSubChart]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE proc [dbo].[procStaticsticSubChart]
	@selType1	VARCHAR(20)
,	@selType2	VARCHAR(20)
,	@subSelType	VARCHAR(50)
,	@startDt	VARCHAR(10)
,	@endDt	VARCHAR(10)
,	@isOneTwo	int	

AS

declare @replaceStr1  varchar(3000)
declare @replaceStr2  varchar(3000)
declare @str  varchar(8000)
SELECT   @replaceStr1  = 
      CASE @selType1
            WHEN 'handphonenumber'  THEN 'CASE LEFT(handphoneNumber,4) 
			WHEN  ''0910'' THEN ''0910''
			WHEN  ''0916'' THEN ''0916''
			WHEN  ''0917'' THEN ''0917''
			WHEN  ''0918'' THEN ''0918''
			WHEN  ''0919'' THEN ''0919''
			WHEN  ''0920'' THEN ''0920''
			WHEN  ''0926'' THEN ''0926''
			WHEN  ''0927'' THEN ''0927''
			ELSE ''Others''
	       		END '
         WHEN 'sex' THEN '  CASE 	sex	
			WHEN 1 THEN ''MALE''
 			WHEN 0  THEN ''FEMALE''
			END '
         WHEN 'birthday' THEN '  CASE
			WHEN  DATEDIFF(yy, birthday, getdate())  <  9 THEN  ''A1~8''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  13 THEN ''B9~12''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  18 THEN ''C13~17''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  23 THEN ''D18~22''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  31 THEN ''E23~30''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  41 THEN ''F31~40''
			ELSE ''G40~upward''
	       		END '
         WHEN 'internetconnection' THEN '  CASE internetConnection
			WHEN  ''Dial-up'' THEN  ''Dial-up''
			WHEN  ''Broadband'' THEN ''Broadband''
			WHEN  ''Internet Cafe'' THEN ''Internet Cafe''	
			ELSE   ''Others''
	       		END '
         WHEN 'placetoplay' THEN '  CASE placeToPlay
			WHEN  ''Home'' THEN  ''Home''
			WHEN  ''Cafe'' THEN ''Cafe''
			WHEN  ''Office'' THEN ''Office''	
			WHEN  ''Home+Cafe'' THEN ''Home+Cafe''	
			WHEN  ''Home+Office'' THEN ''Home+Office''	
			ELSE   ''Others''
	       		END '
      ELSE @selType1
      END


SELECT   @replaceStr2  = 
      CASE @selType2
        WHEN 'handphonenumber'  THEN 'CASE LEFT(handphoneNumber,4) 
			WHEN  ''0910'' THEN ''0910''
			WHEN  ''0916'' THEN ''0916''
			WHEN  ''0917'' THEN ''0917''
			WHEN  ''0918'' THEN ''0918''
			WHEN  ''0919'' THEN ''0919''
			WHEN  ''0920'' THEN ''0920''
			WHEN  ''0926'' THEN ''0926''
			WHEN  ''0927'' THEN ''0927''
			ELSE ''Others''
	       		END '
         WHEN 'sex' THEN '  CASE 	sex	
			WHEN 1 THEN ''MALE''
 			WHEN 0  THEN ''FEMALE''
			END '
         WHEN 'birthday' THEN '  CASE
			WHEN  DATEDIFF(yy, birthday, getdate())  <  9 THEN  ''A1~8''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  13 THEN ''B9~12''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  18 THEN ''C13~17''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  23 THEN ''D18~22''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  31 THEN ''E23~30''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  41 THEN ''F31~40''
			ELSE ''G40~upward''
	       		END '
         WHEN 'internetconnection' THEN '  CASE internetConnection
			WHEN  ''Dial-up'' THEN  ''Dial-up''
			WHEN  ''Broadband'' THEN ''Broadband''
			WHEN  ''Internet Cafe'' THEN ''Internet Cafe''	
			ELSE   ''Others''
	       		END '
         WHEN 'placetoplay' THEN '  CASE placeToPlay
			WHEN  ''Home'' THEN  ''Home''
			WHEN  ''Cafe'' THEN ''Cafe''
			WHEN  ''Office'' THEN ''Office''	
			WHEN  ''Home+Cafe'' THEN ''Home+Cafe''	
			WHEN  ''Home+Office'' THEN ''Home+Office''	
			ELSE   ''Others''
	       		END '

      ELSE @selType2
      END



/*
	IF @selType1 = 'handphonenumber' 
	BEGIN
		Set @str = 'SELECT   SUBSTRING(handphoneNumber, 1,3),' +   @selType2  + ', count( SUBSTRING(handphoneNumber, 1,3)) as cnt from tbluserInfo  ui with(nolock)  JOIN tblUserDetail ud with(nolock)  on ud.userNumber=ui.userNumber '
		SET @str = @str  + ' WHERE  SUBSTRING(handphoneNumber, 1,3)  is not null AND  LEN(SUBSTRING(handphoneNumber, 1,3)  > 0  and ' + @selType2  + '  is not null and  registDt  between  ''' +  @startDt + ''' AND ''' + @endDt + '''' 
		SET @str = @str + ' GROUP BY  SUBSTRING(handphoneNumber, 1,3) ,' +  @selType2
		SET @str = @str + ' ORDER BY SUBSTRING(handphoneNumber, 1,3)'
	END
	IF @selType2 = 'handphonenumber' 
	BEGIN
		Set @str = 'SELECT  '  + @selType1 + ',   SUBSTRING(handphoneNumber, 1,3), count(' + @selType1  +  ') as cnt from tbluserInfo  ui with(nolock)  JOIN tblUserDetail ud with(nolock)  on ud.userNumber=ui.userNumber '
		SET @str = @str  + ' WHERE '  + @selType1  + ' is not null AND  LEN(' + @selType1 +') > 0  and    SUBSTRING(handphoneNumber, 1,3)   is not null and  registDt  between  ''' +  @startDt + ''' AND ''' + @endDt + '''' 
		SET @str = @str + ' GROUP BY ' +  @selType1 + ', SUBSTRING(handphoneNumber, 1,3) '
		SET @str = @str + ' ORDER BY  ' + @selType1 
	END
*/
	BEGIN
		Set @str = 'SELECT  '  + @replaceStr1 + ',' +   @replaceStr2  +' , count(' + @replaceStr1  +  ') as cnt from tbluserInfo  ui with(nolock)  JOIN tblUserDetail ud with(nolock)  on ud.userNumber=ui.userNumber '
		--SET @str = @str  + ' WHERE '  + @selType1  + ' is not null AND   ' + @selType2  + '  is not null and  registDt  between  ''' +  @startDt + ''' AND ''' + @endDt + '''' 
		SET @str = @str  + ' WHERE '  + @selType1  + ' is not null AND  LEN(' + @selType1 +') > 0  and ' + @selType2  + '  is not null and  registDt  between  ''' +  @startDt + ''' AND ''' + @endDt + '''' 
		IF @subSelType is not null AND @subSelType <> ''
		begin
			IF @isOneTwo = 1
				SET @str = @str + ' and ' + @selType1 + '=''' + @subSelType + ''''
			IF @isOneTwo = 2
				SET @str = @str + ' and ' + @selType2 + '=''' + @subSelType + ''''
		end 
		
		SET @str = @str + ' GROUP BY ' +  @replaceStr1 + ',' +  @replaceStr2 
		SET @str = @str + ' ORDER BY 1 , 2 '
	END		

--select @str
exec( @str)
GO
/****** Object:  StoredProcedure [dbo].[procStaticstic]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procStaticstic]
	@selType1	VARCHAR(20)
,	@selType2	VARCHAR(20)
,	@startDt	VARCHAR(10)
,	@endDt	VARCHAR(10)

AS

declare @replaceStr1  varchar(1000)
declare @replaceStr2  varchar(1000)
declare @str  varchar(2000)
SELECT   @replaceStr1  = 
      CASE @selType1
         WHEN 'handphonenumber' THEN  ' left(handphoneNumber,3) '
         WHEN 'sex' THEN '  CASE 	sex	
			WHEN 1 THEN ''MALE''
 			WHEN 0  THEN ''FEMALE''
			END '
         WHEN 'birthday' THEN '  CASE
			WHEN  DATEDIFF(yy, birthday, getdate())  <  9 THEN  ''A1~8''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  13 THEN ''B9~12''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  18 THEN ''C13~17''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  23 THEN ''D18~22''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  31 THEN ''E23~30''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  41 THEN ''F31~40''
			ELSE ''40~upward''
	       		END '
      END


SELECT   @replaceStr2  = 
      CASE @selType2
         WHEN 'handphonenumber' THEN  ' left(handphoneNumber,3) '
         WHEN 'sex' THEN '  CASE 	sex	
			WHEN 1 THEN ''MALE''
 			WHEN 0  THEN ''FEMALE''
			END '
         WHEN 'birthday' THEN '  CASE
			WHEN  DATEDIFF(yy, birthday, getdate())  <  9 THEN  ''A1~8''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  13 THEN ''B9~12''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  18 THEN ''C13~17''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  23 THEN ''D18~22''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  31 THEN ''E23~30''
			WHEN  DATEDIFF(yy, birthday, getdate())  <  41 THEN ''F31~40''
			ELSE ''40~upward''
	       		END '
      END



/*
	IF @selType1 = 'handphonenumber' 
	BEGIN
		Set @str = 'SELECT   SUBSTRING(handphoneNumber, 1,3),' +   @selType2  + ', count( SUBSTRING(handphoneNumber, 1,3)) as cnt from tbluserInfo  ui with(nolock)  JOIN tblUserDetail ud with(nolock)  on ud.userNumber=ui.userNumber '
		SET @str = @str  + ' WHERE  SUBSTRING(handphoneNumber, 1,3)  is not null AND  LEN(SUBSTRING(handphoneNumber, 1,3)  > 0  and ' + @selType2  + '  is not null and  registDt  between  ''' +  @startDt + ''' AND ''' + @endDt + '''' 
		SET @str = @str + ' GROUP BY  SUBSTRING(handphoneNumber, 1,3) ,' +  @selType2
		SET @str = @str + ' ORDER BY SUBSTRING(handphoneNumber, 1,3)'
	END
	IF @selType2 = 'handphonenumber' 
	BEGIN
		Set @str = 'SELECT  '  + @selType1 + ',   SUBSTRING(handphoneNumber, 1,3), count(' + @selType1  +  ') as cnt from tbluserInfo  ui with(nolock)  JOIN tblUserDetail ud with(nolock)  on ud.userNumber=ui.userNumber '
		SET @str = @str  + ' WHERE '  + @selType1  + ' is not null AND  LEN(' + @selType1 +') > 0  and    SUBSTRING(handphoneNumber, 1,3)   is not null and  registDt  between  ''' +  @startDt + ''' AND ''' + @endDt + '''' 
		SET @str = @str + ' GROUP BY ' +  @selType1 + ', SUBSTRING(handphoneNumber, 1,3) '
		SET @str = @str + ' ORDER BY  ' + @selType1 
	END
*/
	BEGIN
		Set @str = 'SELECT  '  + @replaceStr1 + ',' +   @replaceStr2  + ', count(' + @replaceStr1  +  ') as cnt from tbluserInfo  ui with(nolock)  JOIN tblUserDetail ud with(nolock)  on ud.userNumber=ui.userNumber '
		SET @str = @str  + ' WHERE '  + @selType1  + ' is not null AND  LEN(' + @selType1 +') > 0  and ' + @selType2  + '  is not null and  registDt  between  ''' +  @startDt + ''' AND ''' + @endDt + '''' 
		SET @str = @str + ' GROUP BY ' +  @replaceStr1 + ',' +  @replaceStr2
		SET @str = @str + ' ORDER BY 1 desc'
	END		

--select @str
exec( @str)
GO
/****** Object:  StoredProcedure [dbo].[procInsertUserSample]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[procInsertUserSample]
as

/*
declare 	@userNumber				as	int	
declare @msg					nvarchar(40)
exec procInsertUser 'nonoYes1', 1, '1111', 'Kim', 'g', 'hyun', '11344', 2, '1976-01-10', 'address', '01010-12', 'adfasd@hoe.com', 'korea', 'seoul','asdfasd', 'passtype', 'passAnswer', '2423', 1000, 1, 1, @userNumber output, @msg output
select  @userNumber , @msg 

*/
GO
/****** Object:  Table [dbo].[TantraTestAccount]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TantraTestAccount](
	[ID] [int] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[UserID] [nvarchar](50) NULL,
	[Password] [nvarchar](70) NULL,
	[UserKey] [nvarchar](7) NULL,
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
	[Vote] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tantra]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tantra](
	[ID] [int] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[UserID] [nvarchar](50) NULL,
	[Password] [nvarchar](70) NULL,
	[UserKey] [nvarchar](7) NULL,
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
	[Vote] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[procInsertUserSync]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
???? ???? ?? ??? insert ?? ?? ?? ??? ?? ??? ?? sp
*/
CREATE PROCEDURE [dbo].[procInsertUserSync]
	@userId				as	nvarchar(50)		
as
/*
DECLARE @password				as	nvarchar(70)		
,	@userSurName				as	nvarchar(64)	
,	@MI					as	nvarchar(1)
,	@userFirstName				as	nvarchar(64)
,	@userKey				as	nvarchar(7)
,	@sex					as	int	
,	@birthday				as	nvarchar(16)		
,	@address				as	nvarchar(64)			
,	@phoneNumber			as	nvarchar(16)	
,	@email					as	nvarchar(64)	
,	@nation				as	nvarchar(64)	
,	@city					as	nvarchar(64)	
,	@state					as	nvarchar(64)	
,	@passwordCheckQuestionTypeId	as	nvarchar(64)
,	@passwordCheckAnswer		as	nvarchar(64)	
,	@handPhoneNumber			as	nvarchar(64)
,	@jobTypeId				as	nvarchar(64)
,	@getMail				as 	bit
,	@gameServiceId			as	smallint	
,	@cpId					as	int
,	@userNumber				as int
, @msg						as varchar(100)

		SELECT 
			 @password = [password]
			, @userSurName = Lastname
			, @MI = MI
			, @userFirstName = Firstname
			, @userKey = UserKey
			, @sex= case sex
					when 1 then 1
					when 2 then 0
				end
			, @birthday = Birthday 
			, @address = ADDRESS
			, @phoneNumber =HomeNo
			, @email = Email
			, @nation = country 
			, @city = city
			, @state = state
			, @passwordCheckQuestionTypeId = SecretQuestion 
			, @passwordCheckAnswer = Answer
			, @handPhoneNumber=MobileNo
			, @jobTypeId=''
			, @getMail = 1
			, @gameServiceId = 1
		             , @cpId=1
		FROM  UserLogin.dbo.Account  where  Activated=1 AND UserID=@userId
		
		

	BEGIN TRAN

		EXEC procInsertUser @userId 
			,@cpId 
			,@password 
			,@userSurName 
			,@MI 
			,@userFirstName 
			,@userKey 
			,@sex  
			,@birthday 
			,@address 
			,@phoneNumber 
			,@email 
			,@nation 
			,@city	
			,@state 
			,@passwordCheckQuestionTypeId 
			,@passwordCheckAnswer 
			,@handPhoneNumber
			,@jobTypeId
			,@getMail
			,@gameServiceId
			,@userNumber	OUTPUT
			,@msg		OUTPUT
			
		
		IF @@ERROR <> 0 
		BEGIN
			SET @userNumber = -1 
			ROLLBACK
			RETURN
		END
		COMMIT
GO
*/
GO
/****** Object:  Table [dbo].[validEndDtTemp]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[validEndDtTemp](
	[ppCardGroupId] [int] NULL,
	[validEndDt] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[upList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[upList](
	[transactionId] [int] NOT NULL,
	[userGameServiceId] [int] NOT NULL,
	[userNumber] [bigint] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[up]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[up](
	[transactionId] [int] NOT NULL,
	[userGameServiceId] [int] NOT NULL,
	[userNumber] [bigint] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[until0731]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[until0731](
	[userNumber] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[twopay]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[twopay](
	[cnt] [int] NULL,
	[userNumber] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[webshop_log]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[webshop_log](
	[ordenid] [int] IDENTITY(1,1) NOT NULL,
	[idaccount] [nvarchar](18) NOT NULL,
	[itemid] [int] NOT NULL,
	[cantidad] [smallint] NOT NULL,
	[cash] [int] NOT NULL,
	[cashtype] [int] NOT NULL,
	[fecha] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[webshop]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[webshop](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[iditem] [varchar](5) NULL,
	[preciobp] [int] NULL,
	[itemdescription] [varchar](160) NULL,
	[defensa] [int] NULL,
	[chakra_hp] [int] NULL,
	[chakra_tp] [int] NULL,
	[chakra_np] [int] NULL,
	[chakra_mp] [int] NULL,
	[chakras_total] [int] NULL,
	[hp] [int] NULL,
	[tp] [int] NULL,
	[np] [int] NULL,
	[mp] [int] NULL,
	[recupera_hp] [int] NULL,
	[recupera_tp] [int] NULL,
	[resistencias] [int] NULL,
	[evacion] [int] NULL,
	[exito] [int] NULL,
	[golpe_poderoso] [int] NULL,
	[preciotaneys] [int] NULL,
	[absorcion] [int] NULL,
	[reflejo] [int] NULL,
	[rango_attack_a] [int] NULL,
	[rango_attack_b] [int] NULL,
	[def_ignored] [int] NULL,
	[porcent_attack_a] [int] NULL,
	[porcent_attack_b] [int] NULL,
	[velocidad_attack] [int] NULL,
	[movimiento] [int] NULL,
	[weapon_upgrade] [int] NULL,
	[max_count] [int] NULL,
	[lvl_request] [int] NULL,
	[resist_sleep] [int] NULL,
	[resist_stun] [int] NULL,
	[resist_chaya] [int] NULL,
	[resist_ambaka] [int] NULL,
	[icon] [varchar](50) NULL,
	[itemname] [varchar](50) NULL,
	[categoria] [int] NULL,
	[pack] [bit] NULL,
	[mostrar] [bit] NULL,
	[for_server] [int] NULL,
	[precioeventpoint] [int] NULL,
	[prioridad] [varchar](5) NULL,
	[defense_porcent_increase] [varchar](2) NULL,
 CONSTRAINT [PK_webshop] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TmpSchool]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TmpSchool](
	[USERID] [nvarchar](255) NULL,
	[COUNTRY] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tempTestUerNumber]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempTestUerNumber](
	[userId] [nvarchar](52) NOT NULL,
	[userNumber] [int] NOT NULL,
	[userTypeId] [tinyint] NOT NULL,
	[userStatusId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblXXX]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblXXX](
	[a] [int] IDENTITY(1,1) NOT NULL,
	[b] [nvarchar](10) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblWebItemDescription]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblWebItemDescription](
	[transactionId] [int] NOT NULL,
	[description] [varchar](200) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblVirtualIpAddrHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblVirtualIpAddrHistory](
	[virtualIpAddrHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[virtualIpAddrId] [int] NOT NULL,
	[ipAddrId] [int] NOT NULL,
	[isRealIp] [bit] NOT NULL,
	[virtualIpAddr] [nvarchar](11) NOT NULL,
	[virtualStartIp] [tinyint] NOT NULL,
	[virtualEndIp] [tinyint] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [bit] NOT NULL,
	[adminLogId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblVirtualIpAddr]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblVirtualIpAddr](
	[virtualIpAddrId] [int] IDENTITY(1,1) NOT NULL,
	[ipAddrId] [int] NOT NULL,
	[isRealIp] [bit] NOT NULL,
	[virtualIpAddr] [nvarchar](11) NOT NULL,
	[virtualStartIp] [tinyint] NOT NULL,
	[virtualEndIp] [tinyint] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserInfoMatchingReward]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserInfoMatchingReward](
	[tempId] [int] NOT NULL,
	[userNumber] [int] NOT NULL,
	[rewardedCashBalance] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserInfoHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserInfoHistory](
	[userInfoHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[userId] [nvarchar](52) NOT NULL,
	[userPwd] [nvarchar](70) NULL,
	[userKey] [nvarchar](7) NULL,
	[cpId] [int] NOT NULL,
	[userSurName] [nvarchar](64) NOT NULL,
	[MI] [nvarchar](50) NULL,
	[userFirstName] [nvarchar](64) NOT NULL,
	[userTypeId] [tinyint] NULL,
	[userStatusId] [tinyint] NULL,
	[gameServiceId] [smallint] NOT NULL,
	[ssno] [nchar](13) NULL,
	[sex] [bit] NULL,
	[birthday] [smalldatetime] NULL,
	[isSolar] [bit] NULL,
	[email] [nvarchar](64) NOT NULL,
	[zipcode] [nchar](6) NULL,
	[address] [nvarchar](256) NULL,
	[nation] [nvarchar](64) NULL,
	[state] [nvarchar](50) NULL,
	[city] [nvarchar](50) NULL,
	[phoneNumber] [nvarchar](64) NULL,
	[passwordCheckQuestionTypeId] [nvarchar](64) NULL,
	[passwordCheckAnswer] [nvarchar](64) NULL,
	[cashBalance] [int] NULL,
	[pointToCashBalance] [int] NULL,
	[holdCashBalance] [int] NULL,
	[pointBalance] [int] NULL,
	[registDt] [datetime] NULL,
	[apply] [bit] NULL,
	[updateDt] [datetime] NULL,
	[adminLogId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserInfoGuild]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserInfoGuild](
	[userInfoGuild] [int] NOT NULL,
	[userNumber] [int] NOT NULL,
	[guildId] [int] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserInfo_debug]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUserInfo_debug](
	[userNumber] [int] NOT NULL,
	[userId] [nvarchar](52) NOT NULL,
	[userPwd] [nvarchar](70) NULL,
	[userKey] [nvarchar](7) NULL,
	[cpId] [int] NOT NULL,
	[userSurName] [nvarchar](64) NOT NULL,
	[MI] [nvarchar](1) NULL,
	[userFirstName] [nvarchar](64) NULL,
	[userTypeId] [tinyint] NULL,
	[userStatusId] [tinyint] NULL,
	[gameServiceId] [smallint] NOT NULL,
	[ssno] [nchar](13) NULL,
	[sex] [bit] NULL,
	[birthday] [smalldatetime] NULL,
	[isSolar] [bit] NULL,
	[email] [nvarchar](64) NULL,
	[zipcode] [nchar](6) NULL,
	[nation] [nvarchar](64) NULL,
	[address] [nvarchar](256) NULL,
	[city] [char](50) NULL,
	[state] [nvarchar](50) NULL,
	[phoneNumber] [nvarchar](33) NULL,
	[passwordCheckQuestionTypeId] [nvarchar](64) NULL,
	[passwordCheckAnswer] [nvarchar](64) NULL,
	[cashBalance] [int] NULL,
	[pointToCashBalance] [int] NULL,
	[holdCashBalance] [int] NULL,
	[pointBalance] [int] NULL,
	[registDt] [datetime] NULL,
	[apply] [tinyint] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUserInfo]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUserInfo](
	[userNumber] [int] NOT NULL,
	[userId] [nvarchar](52) NOT NULL,
	[userPwd] [nvarchar](70) NULL,
	[userKey] [nvarchar](7) NULL,
	[cpId] [int] NOT NULL,
	[userSurName] [nvarchar](64) NOT NULL,
	[MI] [nvarchar](1) NULL,
	[userFirstName] [nvarchar](64) NULL,
	[userTypeId] [tinyint] NULL,
	[userStatusId] [tinyint] NULL,
	[gameServiceId] [smallint] NOT NULL,
	[ssno] [nchar](13) NULL,
	[sex] [bit] NULL,
	[birthday] [smalldatetime] NULL,
	[isSolar] [bit] NULL,
	[email] [nvarchar](64) NULL,
	[zipcode] [nchar](6) NULL,
	[nation] [nvarchar](64) NULL,
	[address] [nvarchar](256) NULL,
	[city] [char](50) NULL,
	[state] [nvarchar](50) NULL,
	[phoneNumber] [nvarchar](33) NULL,
	[passwordCheckQuestionTypeId] [nvarchar](64) NULL,
	[passwordCheckAnswer] [nvarchar](64) NULL,
	[cashBalance] [int] NULL,
	[pointToCashBalance] [int] NULL,
	[holdCashBalance] [int] NULL,
	[pointBalance] [int] NULL,
	[registDt] [datetime] NULL,
	[apply] [tinyint] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUserGameServiceTerm]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserGameServiceTerm](
	[userGameServiceId] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserGameServiceHistoryBackup]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserGameServiceHistoryBackup](
	[transactionId] [int] NOT NULL,
	[userGameServiceId] [int] NOT NULL,
	[userNumber] [bigint] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserGameServiceHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserGameServiceHistory](
	[transactionId] [int] NOT NULL,
	[userGameServiceId] [int] NOT NULL,
	[userNumber] [bigint] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserGameServiceExpireDateHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserGameServiceExpireDateHistory](
	[userGameServiceExpireDateHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[userGameServiceId] [int] NOT NULL,
	[userNumber] [int] NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL,
	[updateDt] [datetime] NOT NULL,
	[expireDtTypeId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserGameServiceBosangUserFixedTime]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserGameServiceBosangUserFixedTime](
	[userGameServiceId] [int] NULL,
	[userNumber] [int] NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserGameServiceBosangUserFixedTerm]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserGameServiceBosangUserFixedTerm](
	[userGameServiceId] [int] NULL,
	[userNumber] [int] NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserGameServiceAdjustmentHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserGameServiceAdjustmentHistory](
	[userGameServiceAddHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[periodTypeId] [int] NOT NULL,
	[addInt] [int] NOT NULL,
	[registDt] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserGameService]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserGameService](
	[userGameServiceId] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserEventApply]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserEventApply](
	[userEventId] [int] NOT NULL,
	[userNumber] [int] NOT NULL,
	[apply] [bit] NOT NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserDetail]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserDetail](
	[userNumber] [int] NOT NULL,
	[handphoneNumber] [nvarchar](34) NULL,
	[jobTypeId] [nvarchar](50) NULL,
	[isSendEmail] [bit] NULL,
	[parentName] [nvarchar](16) NULL,
	[parentSsno] [nchar](13) NULL,
	[parentPhoneNumber] [nvarchar](16) NULL,
	[placeToPlay] [nvarchar](40) NULL,
	[internetConnection] [nvarchar](30) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUserCashBalance_061124]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserCashBalance_061124](
	[userNumber] [int] NOT NULL,
	[userId] [nvarchar](52) NOT NULL,
	[cashBalance] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUser]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUser](
	[userNumber] [int] IDENTITY(20,1) NOT NULL,
	[userId] [nvarchar](52) NOT NULL,
	[userPwd] [nvarchar](100) NULL,
	[cpId] [int] NOT NULL,
	[userTypeId] [tinyint] NULL,
	[userStatusId] [tinyint] NULL,
	[gameServiceId] [smallint] NULL,
	[apply] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUpdateUserGameServicePrev]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUpdateUserGameServicePrev](
	[userGameServiceId] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUpdateUserGameServicehistoryPrev]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUpdateUserGameServicehistoryPrev](
	[transactionId] [int] NOT NULL,
	[userGameServiceId] [int] NOT NULL,
	[userNumber] [bigint] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUpdateUserGameService]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUpdateUserGameService](
	[userNumber] [int] NOT NULL,
	[ppt] [int] NULL,
	[ppm] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTransfer]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTransfer](
	[transactionId] [int] NOT NULL,
	[receivedTransactionId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTransactionBackUP]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTransactionBackUP](
	[transactionId] [int] NOT NULL,
	[transactionTypeId] [tinyint] NOT NULL,
	[userNumber] [int] NOT NULL,
	[cpId] [int] NOT NULL,
	[cashAmount] [int] NOT NULL,
	[pointToCashAmount] [int] NOT NULL,
	[pointAmount] [int] NOT NULL,
	[cashBalance] [int] NOT NULL,
	[pointToCashBalance] [int] NOT NULL,
	[pointBalance] [int] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[adminLogId] [int] NULL,
	[peerTransactionId] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTransaction]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTransaction](
	[transactionId] [int] IDENTITY(2100,1) NOT NULL,
	[transactionTypeId] [tinyint] NOT NULL,
	[userNumber] [int] NOT NULL,
	[cpId] [int] NOT NULL,
	[cashAmount] [int] NOT NULL,
	[pointToCashAmount] [int] NOT NULL,
	[pointAmount] [int] NOT NULL,
	[cashBalance] [int] NOT NULL,
	[pointToCashBalance] [int] NOT NULL,
	[pointBalance] [int] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[adminLogId] [int] NULL,
	[peerTransactionId] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTempTest]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblTempTest](
	[num] [char](10) NULL,
	[dates] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblTempGameservice]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTempGameservice](
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL,
	[userNumber] [int] NOT NULL,
	[userGameServiceId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblStatistics]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblStatistics](
	[statisticsId] [int] NOT NULL,
	[cntRegistUser] [int] NOT NULL,
	[cntPayUser] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSettlementTemp]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSettlementTemp](
	[productId] [int] NULL,
	[productTypeId] [tinyint] NULL,
	[productCheck] [tinyint] NULL,
	[productName] [nvarchar](50) NULL,
	[productTypeDescript] [nvarchar](50) NULL,
	[totalChargeAmountPayment] [int] NULL,
	[totalChargeAmountCancel] [int] NULL,
	[settlementAmount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSettlementProductMap]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSettlementProductMap](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[settlementTypeId] [tinyint] NOT NULL,
	[productTypeId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSettlementChargeMap]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSettlementChargeMap](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[settlementTypeId] [tinyint] NOT NULL,
	[chargeTypeId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRewardGameTimeToTaney]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRewardGameTimeToTaney](
	[tempId] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[cashBalance] [int] NOT NULL,
	[rewardedDay] [int] NOT NULL,
	[restMin] [int] NOT NULL,
	[rewardedCashBalance] [int] NULL,
	[expireDt] [smalldatetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRejectWord]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRejectWord](
	[rejectWordId] [int] IDENTITY(1,1) NOT NULL,
	[rejectWord] [nvarchar](40) NOT NULL,
	[descript] [nvarchar](50) NOT NULL,
	[rejectWordTypeId] [tinyint] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[adminNumber] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRefundRequest]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRefundRequest](
	[refundRequestId] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[requestCashAmount] [int] NOT NULL,
	[bankName] [nvarchar](20) NULL,
	[accountNumber] [nvarchar](32) NULL,
	[depositor] [nvarchar](50) NULL,
	[memo] [nvarchar](100) NULL,
	[processStatus] [tinyint] NULL,
	[registDt] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRefund]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRefund](
	[transactionId] [int] NOT NULL,
	[refundRequestId] [int] NOT NULL,
	[refundAmount] [int] NULL,
	[bankName] [nvarchar](20) NULL,
	[accountNumber] [nvarchar](32) NULL,
	[depositor] [nvarchar](32) NULL,
	[adminLogId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRecoverdRewardUserMatching]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRecoverdRewardUserMatching](
	[userNumber] [int] NOT NULL,
	[cashBalance] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPromoEvent]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPromoEvent](
	[transactionId] [int] NOT NULL,
	[userNumber] [int] NOT NULL,
	[preLimitTime] [int] NULL,
	[preUsedTime] [int] NULL,
	[LimitTime] [int] NULL,
	[usedTime] [int] NULL,
	[expiredTime] [int] NULL,
	[expiredDt] [datetime] NOT NULL,
	[isExpired] [bit] NOT NULL,
	[realExpiredDt] [datetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblProductHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductHistory](
	[productHistoryId] [int] IDENTITY(1000,1) NOT NULL,
	[productId] [int] NOT NULL,
	[gameServiceId] [smallint] NULL,
	[productCode] [nvarchar](10) NOT NULL,
	[productTypeId] [tinyint] NOT NULL,
	[productName] [nvarchar](50) NOT NULL,
	[productAmount] [int] NOT NULL,
	[productPoint] [int] NOT NULL,
	[ipCount] [tinyint] NULL,
	[periodTypeId] [tinyint] NULL,
	[productPeriod] [int] NULL,
	[limitTime] [int] NULL,
	[applyStartTime] [nchar](4) NULL,
	[applyEndTime] [nchar](4) NULL,
	[playableMinutes] [smallint] NULL,
	[registDt] [datetime] NOT NULL,
	[adminLogId] [int] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblProduct]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProduct](
	[productId] [int] IDENTITY(1000,1) NOT NULL,
	[gameServiceId] [smallint] NULL,
	[productCode] [nvarchar](10) NULL,
	[productTypeId] [tinyint] NOT NULL,
	[productName] [nvarchar](50) NOT NULL,
	[productAmount] [int] NOT NULL,
	[productPoint] [int] NOT NULL,
	[ipCount] [tinyint] NULL,
	[periodTypeId] [tinyint] NULL,
	[productPeriod] [int] NULL,
	[limitTime] [int] NULL,
	[applyStartTime] [nchar](4) NULL,
	[applyEndTime] [nchar](4) NULL,
	[playableMinutes] [smallint] NULL,
	[registDt] [datetime] NOT NULL,
	[adminLogId] [int] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPPcardUserInfoMappingBackUp]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPPcardUserInfoMappingBackUp](
	[ppCardUserInfoId] [int] NOT NULL,
	[ppCardId] [int] NOT NULL,
	[userNumber] [int] NOT NULL,
	[transactionId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPpCardUserInfoMapping]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPpCardUserInfoMapping](
	[ppCardUserInfoId] [int] IDENTITY(1,1) NOT NULL,
	[ppCardId] [int] NOT NULL,
	[userNumber] [int] NOT NULL,
	[transactionId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPpCardSale]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPpCardSale](
	[ppcardSaleId] [int] IDENTITY(1,1) NOT NULL,
	[chongphanId] [int] NOT NULL,
	[productId] [int] NOT NULL,
	[quntity] [int] NOT NULL,
	[price] [money] NOT NULL,
	[registDt] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPpCardReturnList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPpCardReturnList](
	[returnId] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[adminNumber] [int] NOT NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPpCardInjusticeList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPpCardInjusticeList](
	[num] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPpcardGroupBackup]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPpcardGroupBackup](
	[ppCardGroupId] [int] NOT NULL,
	[productId] [int] NOT NULL,
	[howManyPeople] [int] NOT NULL,
	[quantity] [int] NOT NULL,
	[createDt] [smalldatetime] NOT NULL,
	[validStartDt] [smalldatetime] NULL,
	[validEndDt] [smalldatetime] NULL,
	[adminNumber] [int] NOT NULL,
	[chongphanId] [int] NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPpCardGroup]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPpCardGroup](
	[ppCardGroupId] [int] IDENTITY(1,1) NOT NULL,
	[productId] [int] NOT NULL,
	[howManyPeople] [int] NOT NULL,
	[quantity] [int] NOT NULL,
	[createDt] [smalldatetime] NOT NULL,
	[validStartDt] [smalldatetime] NULL,
	[validEndDt] [smalldatetime] NULL,
	[adminNumber] [int] NOT NULL,
	[chongphanId] [int] NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPpCardForTantra]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblPpCardForTantra](
	[ppCardId] [int] IDENTITY(1,1) NOT NULL,
	[ppCardGroupId] [int] NOT NULL,
	[ppCardSerialNumber] [varchar](15) NOT NULL,
	[PINCode] [varchar](9) NOT NULL,
	[productCode] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblPpCardFailList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPpCardFailList](
	[num] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[ppCardSerialNumber] [nvarchar](20) NOT NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPpCardBillCollect]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPpCardBillCollect](
	[billCollectId] [int] IDENTITY(1,1) NOT NULL,
	[chongphanId] [int] NOT NULL,
	[price] [money] NOT NULL,
	[registDt] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPPCardBackUP]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblPPCardBackUP](
	[ppCardId] [int] NOT NULL,
	[ppCardGroupId] [int] NOT NULL,
	[ppCardSerialNumber] [varchar](12) NOT NULL,
	[pinCode] [varchar](40) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblPpCard]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblPpCard](
	[ppCardId] [int] IDENTITY(1,1) NOT NULL,
	[ppCardGroupId] [int] NOT NULL,
	[ppCardSerialNumber] [varchar](12) NOT NULL,
	[pinCode] [varchar](40) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblPostToChongphan]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPostToChongphan](
	[postToChongphanId] [int] IDENTITY(1,1) NOT NULL,
	[sido] [nvarchar](50) NOT NULL,
	[gugun] [nvarchar](50) NOT NULL,
	[chongphanId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPost]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPost](
	[zipCode] [nvarchar](10) NOT NULL,
	[sido] [nvarchar](20) NOT NULL,
	[gugun] [nvarchar](20) NOT NULL,
	[dong] [nvarchar](40) NULL,
	[bungi] [nvarchar](20) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPackage]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPackage](
	[transactionId] [int] NOT NULL,
	[userNumber] [int] NOT NULL,
	[productId] [int] NOT NULL,
	[validDt] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblOrderPPVDetail]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblOrderPPVDetail](
	[orderPPVDetailId] [int] IDENTITY(1,1) NOT NULL,
	[transactionId] [int] NOT NULL,
	[contentCode] [int] NOT NULL,
	[contentName] [varchar](50) NULL,
	[point] [int] NOT NULL,
	[unitPrice] [int] NOT NULL,
	[quantity] [smallint] NOT NULL,
	[userIp] [varchar](17) NOT NULL,
	[contentTypeCode] [varchar](3) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblOrderBackup]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOrderBackup](
	[transactionId] [int] NOT NULL,
	[chargeTransactionId] [int] NULL,
	[productId] [int] NOT NULL,
	[orderNumber] [nvarchar](32) NULL,
	[orderTypeId] [tinyint] NULL,
	[primeCost] [int] NULL,
	[eventId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblOrder]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOrder](
	[transactionId] [int] NOT NULL,
	[chargeTransactionId] [int] NULL,
	[productId] [int] NOT NULL,
	[orderNumber] [nvarchar](32) NULL,
	[orderTypeId] [tinyint] NULL,
	[primeCost] [int] NULL,
	[eventId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblNPpCardGroup]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblNPpCardGroup](
	[ppCardGroupId] [int] IDENTITY(1,1) NOT NULL,
	[productId] [int] NOT NULL,
	[howManyPeople] [int] NOT NULL,
	[quantity] [int] NOT NULL,
	[createDt] [smalldatetime] NOT NULL,
	[validStartDt] [smalldatetime] NULL,
	[validEndDt] [smalldatetime] NULL,
	[adminNumber] [int] NOT NULL,
	[chongphanId] [int] NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblNPpCard]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblNPpCard](
	[ppCardId] [int] IDENTITY(1,1) NOT NULL,
	[ppCardGroupId] [int] NOT NULL,
	[ppCardSerialNumber] [varchar](12) NOT NULL,
	[pinCode] [varchar](40) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblModifyDatas]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblModifyDatas](
	[userId] [nvarchar](52) NOT NULL,
	[userNumber] [int] NOT NULL,
	[userSurName] [nvarchar](64) NOT NULL,
	[userFirstName] [nvarchar](64) NULL,
	[transactionId] [int] NOT NULL,
	[rightProductId] [int] NOT NULL,
	[wrongProductId] [int] NOT NULL,
	[wrongAmount] [int] NULL,
	[rightAmount] [int] NOT NULL,
	[chargeTransactionId] [int] NULL,
	[ppCardGroupId] [int] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblIpAddrHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblIpAddrHistory](
	[ipAddrHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[ipAddrId] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[ipAddr] [nvarchar](11) NOT NULL,
	[startIp] [tinyint] NOT NULL,
	[endIp] [tinyint] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [bit] NOT NULL,
	[adminLogId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblIpAddr]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblIpAddr](
	[ipAddrId] [int] IDENTITY(1,1) NOT NULL,
	[gamebangId] [int] NOT NULL,
	[ipAddr] [nvarchar](11) NOT NULL,
	[startIp] [tinyint] NOT NULL,
	[endIp] [tinyint] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGuildProduct]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGuildProduct](
	[guildProductId] [int] NOT NULL,
	[guildId] [int] NOT NULL,
	[productId] [int] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGuild]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGuild](
	[guildId] [int] NOT NULL,
	[gameGuildCode] [nvarchar](20) NULL,
	[guildName] [nchar](10) NULL,
	[applay] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGameService]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGameService](
	[gameServiceId] [smallint] IDENTITY(1,1) NOT NULL,
	[gameServiceName] [nvarchar](50) NOT NULL,
	[cpId] [int] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGamebangSettlementHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGamebangSettlementHistory](
	[gamebangSettelmentHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[transactionId] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[receipt] [int] NOT NULL,
	[chargeTypeId] [tinyint] NOT NULL,
	[startDt] [smalldatetime] NOT NULL,
	[endDt] [smalldatetime] NOT NULL,
	[registDt] [smalldatetime] NOT NULL,
	[adminLogId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGamebangSettlement]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGamebangSettlement](
	[transactionId] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[receipt] [int] NOT NULL,
	[chargeTypeId] [tinyint] NOT NULL,
	[startDt] [smalldatetime] NOT NULL,
	[endDt] [smalldatetime] NOT NULL,
	[registDt] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGamebangHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGamebangHistory](
	[gamebangHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[gamebangId] [int] NOT NULL,
	[gamebangName] [nvarchar](32) NULL,
	[bizNumber] [nvarchar](16) NULL,
	[address] [nvarchar](64) NULL,
	[zipcode] [nchar](6) NULL,
	[phoneNumber] [nvarchar](16) NULL,
	[presidentSurname] [nvarchar](64) NULL,
	[presidentFirstName] [nvarchar](64) NULL,
	[limitTime] [int] NULL,
	[ipCount] [tinyint] NULL,
	[depositAmount] [int] NOT NULL,
	[apply] [bit] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[adminLogId] [int] NULL,
	[ssno] [nvarchar](13) NULL,
	[item] [nvarchar](50) NULL,
	[bizStatus] [nvarchar](50) NULL,
	[cellPhone] [nvarchar](18) NULL,
	[email] [nvarchar](100) NULL,
	[manageCode] [nvarchar](20) NULL,
	[gamebangTypeId] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGamebangGameServiceReservation]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGamebangGameServiceReservation](
	[transactionId] [int] NOT NULL,
	[gamebangGameServiceId] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[productId] [int] NOT NULL,
	[startDt] [datetime] NOT NULL,
	[updateDt] [datetime] NOT NULL,
	[isUpdate] [bit] NOT NULL,
	[isCancel] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGamebangGameServiceHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGamebangGameServiceHistory](
	[transactionId] [int] NOT NULL,
	[gamebangGameServiceId] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[gamebangPaymentTypeId] [tinyint] NOT NULL,
	[ipCount] [tinyint] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGamebang]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGamebang](
	[gamebangId] [int] NOT NULL,
	[gamebangName] [nvarchar](32) NOT NULL,
	[bizNumber] [nvarchar](16) NULL,
	[address] [nvarchar](64) NULL,
	[zipcode] [nchar](6) NULL,
	[phoneNumber] [nvarchar](16) NULL,
	[presidentSurname] [nvarchar](64) NULL,
	[presidentFirstName] [nvarchar](64) NULL,
	[limitTime] [int] NOT NULL,
	[ipCount] [tinyint] NOT NULL,
	[depositAmount] [int] NOT NULL,
	[apply] [bit] NOT NULL,
	[ssno] [nvarchar](13) NULL,
	[item] [nvarchar](50) NULL,
	[bizStatus] [nvarchar](50) NULL,
	[cellPhone] [nvarchar](18) NULL,
	[email] [nvarchar](100) NULL,
	[manageCode] [nvarchar](20) NULL,
	[gamebangTypeId] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGameAccessLogWed]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblGameAccessLogWed](
	[wednesdayId] [bigint] IDENTITY(1,1) NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[userNumber] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[realIp] [varchar](15) NOT NULL,
	[virtualIp] [varchar](15) NOT NULL,
	[loginDt] [datetime] NOT NULL,
	[logoutDt] [datetime] NOT NULL,
	[regularUsedMinutes] [int] NOT NULL,
	[dcRealUsedMinutes] [int] NOT NULL,
	[dcApplyUsedMinutes] [int] NOT NULL,
	[totalRealUsedMinutes] [int] NOT NULL,
	[totalApplyUsedMinutes] [int] NOT NULL,
	[userPaymentTypeId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblGameAccessLogTue]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblGameAccessLogTue](
	[tuesdayId] [bigint] IDENTITY(1,1) NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[userNumber] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[realIp] [varchar](15) NOT NULL,
	[virtualIp] [varchar](15) NOT NULL,
	[loginDt] [datetime] NOT NULL,
	[logoutDt] [datetime] NOT NULL,
	[regularUsedMinutes] [int] NOT NULL,
	[dcRealUsedMinutes] [int] NOT NULL,
	[dcApplyUsedMinutes] [int] NOT NULL,
	[totalRealUsedMinutes] [int] NOT NULL,
	[totalApplyUsedMinutes] [int] NOT NULL,
	[userPaymentTypeId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblGameAccessLogThu]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblGameAccessLogThu](
	[thursdayId] [bigint] IDENTITY(1,1) NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[userNumber] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[realIp] [varchar](15) NOT NULL,
	[virtualIp] [varchar](15) NOT NULL,
	[loginDt] [datetime] NOT NULL,
	[logoutDt] [datetime] NOT NULL,
	[regularUsedMinutes] [int] NOT NULL,
	[dcRealUsedMinutes] [int] NOT NULL,
	[dcApplyUsedMinutes] [int] NOT NULL,
	[totalRealUsedMinutes] [int] NOT NULL,
	[totalApplyUsedMinutes] [int] NOT NULL,
	[userPaymentTypeId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblGameAccessLogSun]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblGameAccessLogSun](
	[sundayId] [bigint] IDENTITY(1,1) NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[userNumber] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[realIp] [varchar](15) NOT NULL,
	[virtualIp] [varchar](15) NOT NULL,
	[loginDt] [datetime] NOT NULL,
	[logoutDt] [datetime] NOT NULL,
	[regularUsedMinutes] [int] NOT NULL,
	[dcRealUsedMinutes] [int] NOT NULL,
	[dcApplyUsedMinutes] [int] NOT NULL,
	[totalRealUsedMinutes] [int] NOT NULL,
	[totalApplyUsedMinutes] [int] NOT NULL,
	[userPaymentTypeId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblGameAccessLogSat]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblGameAccessLogSat](
	[saturdayId] [bigint] IDENTITY(1,1) NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[userNumber] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[realIp] [varchar](15) NOT NULL,
	[virtualIp] [varchar](15) NOT NULL,
	[loginDt] [datetime] NOT NULL,
	[logoutDt] [datetime] NOT NULL,
	[regularUsedMinutes] [int] NOT NULL,
	[dcRealUsedMinutes] [int] NOT NULL,
	[dcApplyUsedMinutes] [int] NOT NULL,
	[totalRealUsedMinutes] [int] NOT NULL,
	[totalApplyUsedMinutes] [int] NOT NULL,
	[userPaymentTypeId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblGameAccessLogMon]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblGameAccessLogMon](
	[mondayId] [bigint] IDENTITY(1,1) NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[userNumber] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[realIp] [varchar](15) NOT NULL,
	[virtualIp] [varchar](15) NOT NULL,
	[loginDt] [datetime] NOT NULL,
	[logoutDt] [datetime] NOT NULL,
	[regularUsedMinutes] [int] NOT NULL,
	[dcRealUsedMinutes] [int] NOT NULL,
	[dcApplyUsedMinutes] [int] NOT NULL,
	[totalRealUsedMinutes] [int] NOT NULL,
	[totalApplyUsedMinutes] [int] NOT NULL,
	[userPaymentTypeId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblGameAccessLogFri]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblGameAccessLogFri](
	[fridayId] [bigint] IDENTITY(1,1) NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[userNumber] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[realIp] [varchar](15) NOT NULL,
	[virtualIp] [varchar](15) NOT NULL,
	[loginDt] [datetime] NOT NULL,
	[logoutDt] [datetime] NOT NULL,
	[regularUsedMinutes] [int] NOT NULL,
	[dcRealUsedMinutes] [int] NOT NULL,
	[dcApplyUsedMinutes] [int] NOT NULL,
	[totalRealUsedMinutes] [int] NOT NULL,
	[totalApplyUsedMinutes] [int] NOT NULL,
	[userPaymentTypeId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblGameAccessLog]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGameAccessLog](
	[gameAccessLogId] [bigint] IDENTITY(1,1) NOT NULL,
	[gameServiceId] [smallint] NOT NULL,
	[userNumber] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[realIp] [nvarchar](15) NOT NULL,
	[virtualIp] [nvarchar](15) NOT NULL,
	[loginDt] [smalldatetime] NOT NULL,
	[logoutDt] [smalldatetime] NOT NULL,
	[regularUsedMinutes] [int] NOT NULL,
	[dcRealUsedMinutes] [int] NOT NULL,
	[dcApplyUsedMinutes] [int] NOT NULL,
	[totalRealUsedMinutes] [int] NOT NULL,
	[totalApplyUsedMinutes] [int] NOT NULL,
	[userPaymentType] [tinyint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDutyDatas]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDutyDatas](
	[userId] [nvarchar](52) NOT NULL,
	[userNumber] [int] NOT NULL,
	[userSurName] [nvarchar](64) NOT NULL,
	[userFirstName] [nvarchar](64) NULL,
	[transactionId] [int] NOT NULL,
	[rightProductId] [int] NOT NULL,
	[wrongProductId] [int] NOT NULL,
	[wrongAmount] [int] NULL,
	[rightAmount] [int] NOT NULL,
	[chargeTransactionId] [int] NULL,
	[ppCardGroupId] [int] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDutyData]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDutyData](
	[originProductId] [int] NOT NULL,
	[productAmount] [int] NOT NULL,
	[primeCost] [int] NULL,
	[cashAmount] [int] NOT NULL,
	[chargeTransactionId] [int] NULL,
	[ppCardGroupId] [int] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[transactionId] [int] NOT NULL,
	[rightProductId] [int] NOT NULL,
	[wrongProductId] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDeleteUserGameServiceHistoryDataList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDeleteUserGameServiceHistoryDataList](
	[transactionId] [int] NOT NULL,
	[userGameServiceId] [int] NOT NULL,
	[userNumber] [bigint] NOT NULL,
	[gameServiceId] [int] NOT NULL,
	[startDt] [smalldatetime] NULL,
	[endDt] [smalldatetime] NULL,
	[limitTime] [int] NOT NULL,
	[usedLimitTime] [int] NOT NULL,
	[applyStartTime] [nchar](4) NOT NULL,
	[applyEndTime] [nchar](4) NOT NULL,
	[playableMinutes] [smallint] NOT NULL,
	[usedPlayableMinutes] [smallint] NOT NULL,
	[expireDt] [smalldatetime] NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDeleteTransactionDataList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDeleteTransactionDataList](
	[transactionId] [int] NOT NULL,
	[transactionTypeId] [tinyint] NOT NULL,
	[userNumber] [int] NOT NULL,
	[cpId] [int] NOT NULL,
	[cashAmount] [int] NOT NULL,
	[pointToCashAmount] [int] NOT NULL,
	[pointAmount] [int] NOT NULL,
	[cashBalance] [int] NOT NULL,
	[pointToCashBalance] [int] NOT NULL,
	[pointBalance] [int] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[adminLogId] [int] NULL,
	[peerTransactionId] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDeleteOrderDataList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDeleteOrderDataList](
	[transactionId] [int] NOT NULL,
	[chargeTransactionId] [int] NULL,
	[productId] [int] NOT NULL,
	[orderNumber] [nvarchar](32) NULL,
	[orderTypeId] [tinyint] NULL,
	[primeCost] [int] NULL,
	[eventId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDeleteChargeDataList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDeleteChargeDataList](
	[transactionId] [int] NOT NULL,
	[chargeTypeId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDeleteCardDataList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblDeleteCardDataList](
	[transactionId] [int] NOT NULL,
	[chargeCardDepositTempId] [int] NOT NULL,
	[nameOnCard] [varchar](50) NULL,
	[transactionNumber] [nvarchar](30) NOT NULL,
	[email] [nvarchar](100) NOT NULL,
	[pgAmount] [decimal](10, 2) NOT NULL,
	[productAmount] [int] NOT NULL,
	[dateOfTransaction] [datetime] NOT NULL,
	[chongphanId] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblDcRate]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDcRate](
	[dcRateId] [int] NOT NULL,
	[dcStartTime] [nchar](4) NOT NULL,
	[dcEndTime] [nchar](4) NOT NULL,
	[dcRate] [numeric](8, 3) NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCpHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCpHistory](
	[cpHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[cpId] [int] NOT NULL,
	[cpName] [nvarchar](32) NOT NULL,
	[bizNumber] [nvarchar](16) NOT NULL,
	[address] [nvarchar](64) NOT NULL,
	[zipcode] [nchar](6) NOT NULL,
	[phoneNumber] [nvarchar](16) NOT NULL,
	[presidentName] [nvarchar](16) NOT NULL,
	[apply] [bit] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[adminLogId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCpChongphanHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCpChongphanHistory](
	[cpChongphanHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[cpChongphanId] [int] NOT NULL,
	[cpId] [int] NOT NULL,
	[chongphanId] [int] NOT NULL,
	[apply] [bit] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[adminLogId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCpChongphan]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCpChongphan](
	[cpChongphanId] [int] IDENTITY(1,1) NOT NULL,
	[cpId] [int] NOT NULL,
	[chongphanId] [int] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCp]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCp](
	[cpId] [int] NOT NULL,
	[cpName] [nvarchar](32) NOT NULL,
	[bizNumber] [nvarchar](16) NOT NULL,
	[address] [nvarchar](64) NOT NULL,
	[zipcode] [nchar](6) NOT NULL,
	[phoneNumber] [nvarchar](16) NOT NULL,
	[presidentName] [nvarchar](16) NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCompany]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCompany](
	[cpId] [int] IDENTITY(1,1) NOT NULL,
	[tblName] [nvarchar](16) NOT NULL,
	[registDt] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeWhereType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeWhereType](
	[whereTypeId] [int] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](40) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeUserType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeUserType](
	[userTypeId] [tinyint] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](100) NOT NULL,
	[isFreeId] [bit] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [smallint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[procGetUserStatusType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserStatusType    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserStatusType]
as
SELECT 
	userStatusTypeId, descript 
FROM 
	tblCodeUserStatusType with (nolock)
WHERE 
	apply = 1
ORDER BY
	userStatusTypeId
GO
/****** Object:  Table [dbo].[tblCodeUserStatus]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeUserStatus](
	[userStatusId] [tinyint] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](100) NOT NULL,
	[canGameLogin] [bit] NOT NULL,
	[canWebLogin] [bit] NOT NULL,
	[canOrder] [bit] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [smallint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeUserEvent]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblCodeUserEvent](
	[userEventId] [int] IDENTITY(1,1) NOT NULL,
	[description] [varchar](100) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblCodeTransactionType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeTransactionType](
	[transactionTypeId] [tinyint] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](50) NOT NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeSettlementType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeSettlementType](
	[settlementTypeId] [tinyint] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](50) NOT NULL,
	[registDt] [smalldatetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeRejectWordType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeRejectWordType](
	[rejectWordTypeId] [tinyint] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](50) NOT NULL,
	[registDt] [smalldatetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeRefundProcessStatus]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeRefundProcessStatus](
	[refundProcessStatusId] [tinyint] NOT NULL,
	[descript] [nvarchar](64) NOT NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeProductType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeProductType](
	[productTypeId] [tinyint] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](50) NOT NULL,
	[isGame] [bit] NOT NULL,
	[isGamebangProduct] [bit] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodePeriodType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodePeriodType](
	[periodTypeId] [tinyint] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](30) NOT NULL,
	[registDt] [smalldatetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodePasswordCheckType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodePasswordCheckType](
	[passwordCheckQuestionTypeId] [int] IDENTITY(1000,1) NOT NULL,
	[descript] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeOrderType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeOrderType](
	[orderTypeId] [tinyint] NOT NULL,
	[descript] [nvarchar](64) NOT NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeJobType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeJobType](
	[jobTypeId] [smallint] IDENTITY(1000,1) NOT NULL,
	[jobCode] [nvarchar](15) NOT NULL,
	[descript] [nvarchar](30) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeGamebangType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeGamebangType](
	[gamebangTypeId] [tinyint] NOT NULL,
	[descript] [nvarchar](100) NOT NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeGamebangPaymentType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeGamebangPaymentType](
	[gamebangPaymentTypeId] [tinyint] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](50) NOT NULL,
	[registDt] [smalldatetime] NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeExpireDtType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblCodeExpireDtType](
	[expireDtTypeId] [int] IDENTITY(1,1) NOT NULL,
	[descript] [varchar](50) NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblCodeErrorNumber]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeErrorNumber](
	[ErrorNum] [smallint] NOT NULL,
	[ErrorDescription] [nvarchar](50) NOT NULL,
	[producer] [nvarchar](12) NOT NULL,
	[codeExplanation] [nvarchar](128) NOT NULL,
	[registDt] [smalldatetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeConnectionType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeConnectionType](
	[connectionTypeId] [int] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](40) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeChargeType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeChargeType](
	[chargeTypeId] [tinyint] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](50) NOT NULL,
	[commission] [numeric](5, 2) NOT NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeAdminType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeAdminType](
	[adminTypeId] [smallint] IDENTITY(1,1) NOT NULL,
	[adminGroupTypeId] [tinyint] NOT NULL,
	[adminGradeTypeId] [tinyint] NOT NULL,
	[registDt] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeAdminGroupType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeAdminGroupType](
	[adminGroupTypeId] [tinyint] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](50) NOT NULL,
	[linkedTable] [nvarchar](32) NOT NULL,
	[registDt] [smalldatetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCodeAdminGradeType]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCodeAdminGradeType](
	[adminGradeTypeId] [tinyint] IDENTITY(1,1) NOT NULL,
	[descript] [nvarchar](50) NOT NULL,
	[registDt] [smalldatetime] NOT NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblChongphanHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblChongphanHistory](
	[chongphanHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[chongphanId] [int] NOT NULL,
	[chongphanName] [nvarchar](32) NOT NULL,
	[bizNumber] [nvarchar](16) NOT NULL,
	[address] [nvarchar](64) NOT NULL,
	[zipcode] [nchar](6) NOT NULL,
	[phoneNumber] [nvarchar](16) NOT NULL,
	[presidentName] [nvarchar](16) NOT NULL,
	[commission] [numeric](9, 2) NOT NULL,
	[bondDate] [smalldatetime] NULL,
	[expiryDate] [smalldatetime] NULL,
	[apply] [bit] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[adminLogId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblChongphanGamebangHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblChongphanGamebangHistory](
	[chongphanGamebangHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[chongphanGamebangId] [int] NOT NULL,
	[chongphanId] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[apply] [bit] NOT NULL,
	[registDt] [datetime] NOT NULL,
	[adminLogId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblChongphanGamebang]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblChongphanGamebang](
	[chongphanGamebangId] [int] IDENTITY(1,1) NOT NULL,
	[chongphanId] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[apply] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblChongphanBank]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblChongphanBank](
	[chongphanBankId] [int] IDENTITY(1,1) NOT NULL,
	[chongphanId] [int] NOT NULL,
	[bankName] [nvarchar](32) NOT NULL,
	[account] [nvarchar](32) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblChargeTransferAccount]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblChargeTransferAccount](
	[transactionId] [int] NOT NULL,
	[chargeTransferAccountTempId] [int] NOT NULL,
	[bankName] [nvarchar](8) NULL,
	[bankCode] [nvarchar](4) NULL,
	[accnt_No] [nvarchar](50) NULL,
	[depositorName] [nvarchar](10) NULL,
	[depositorSsno] [nchar](13) NULL,
	[amount] [int] NOT NULL,
	[pay_Date] [nvarchar](14) NULL,
	[pay_Yn] [nvarchar](8) NULL,
	[isRepayment] [bit] NOT NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblChargeMobile]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblChargeMobile](
	[transactionId] [int] NOT NULL,
	[tId] [nvarchar](20) NOT NULL,
	[phoneNumber] [nvarchar](20) NOT NULL,
	[isARS] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblChargeCardDepositTemp]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblChargeCardDepositTemp](
	[chargeCardDepositTempId] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[amount] [int] NOT NULL,
	[productId] [int] NOT NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblChargeCardDeposit]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblChargeCardDeposit](
	[transactionId] [int] NOT NULL,
	[chargeCardDepositTempId] [int] NOT NULL,
	[nameOnCard] [varchar](50) NULL,
	[transactionNumber] [nvarchar](30) NOT NULL,
	[email] [nvarchar](100) NOT NULL,
	[pgAmount] [decimal](10, 2) NOT NULL,
	[productAmount] [int] NOT NULL,
	[dateOfTransaction] [datetime] NOT NULL,
	[chongphanId] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblChargeBankCms]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblChargeBankCms](
	[transactionId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCharge]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCharge](
	[transactionId] [int] NOT NULL,
	[chargeTypeId] [tinyint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblBoSangUserList2005042728]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblBoSangUserList2005042728](
	[userId] [varchar](60) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblBoSangUserList20050416]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblBoSangUserList20050416](
	[userId] [varchar](60) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblBosangUserList]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblBosangUserList](
	[userId] [varchar](60) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblBlockedUserManagement]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBlockedUserManagement](
	[blockedUserId] [int] IDENTITY(1,1) NOT NULL,
	[userNumber] [int] NOT NULL,
	[oldPassword] [nvarchar](32) NOT NULL,
	[oldUserStatusId] [tinyint] NOT NULL,
	[endDt] [smalldatetime] NOT NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblBankDepositConfirmHistory]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBankDepositConfirmHistory](
	[bankDepositConfirmHistoryIdId] [int] IDENTITY(1,1) NOT NULL,
	[bankDepositConfirmId] [int] NOT NULL,
	[gamebangId] [int] NOT NULL,
	[productId] [int] NULL,
	[transactionId] [int] NULL,
	[startDate] [smalldatetime] NULL,
	[depositAmount] [int] NOT NULL,
	[depositer] [nvarchar](50) NOT NULL,
	[bankName] [nvarchar](50) NOT NULL,
	[depositDate] [smalldatetime] NOT NULL,
	[confirmType] [tinyint] NOT NULL,
	[misPrice] [int] NOT NULL,
	[memo] [nvarchar](500) NULL,
	[registDt] [datetime] NOT NULL,
	[adminLogId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblBankDepositConfirm]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBankDepositConfirm](
	[bankDepositConfirmId] [int] IDENTITY(1,1) NOT NULL,
	[gamebangId] [int] NOT NULL,
	[productId] [int] NULL,
	[transactionId] [int] NULL,
	[startDate] [smalldatetime] NULL,
	[depositAmount] [int] NOT NULL,
	[depositer] [nvarchar](50) NOT NULL,
	[bankName] [nvarchar](50) NOT NULL,
	[depositDate] [smalldatetime] NOT NULL,
	[confirmType] [tinyint] NOT NULL,
	[misPrice] [int] NOT NULL,
	[memo] [nvarchar](500) NULL,
	[registDt] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblBakupPpCardGroup]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBakupPpCardGroup](
	[ppCardGroupId] [int] IDENTITY(1,1) NOT NULL,
	[productId] [int] NOT NULL,
	[howManyPeople] [int] NOT NULL,
	[quantity] [int] NOT NULL,
	[createDt] [smalldatetime] NOT NULL,
	[validStartDt] [smalldatetime] NULL,
	[validEndDt] [smalldatetime] NULL,
	[adminNumber] [int] NOT NULL,
	[chongphanId] [int] NULL,
	[apply] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblBakupPpCard]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblBakupPpCard](
	[ppCardId] [int] IDENTITY(1,1) NOT NULL,
	[ppCardGroupId] [int] NOT NULL,
	[ppCardSerialNumber] [varchar](12) NOT NULL,
	[pinCode] [varchar](40) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblAuctionDescription]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblAuctionDescription](
	[transactionId] [int] NOT NULL,
	[description] [varchar](200) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblAdminSession]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAdminSession](
	[adminNumber] [int] NOT NULL,
	[adminSessionId] [int] NOT NULL,
	[loginIp] [nvarchar](15) NOT NULL,
	[cpId] [int] NOT NULL,
	[adminId] [nvarchar](16) NOT NULL,
	[adminName] [nvarchar](20) NOT NULL,
	[adminGroup] [smallint] NOT NULL,
	[adminGrade] [smallint] NOT NULL,
	[registDt] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblAdminLog]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAdminLog](
	[adminLogId] [int] IDENTITY(1,1) NOT NULL,
	[adminActionType] [nvarchar](12) NOT NULL,
	[adminActionTable] [nvarchar](100) NOT NULL,
	[adminNumber] [int] NOT NULL,
	[memo] [nvarchar](200) NOT NULL,
	[registDt] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblAdmin]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAdmin](
	[adminNumber] [int] IDENTITY(1,1) NOT NULL,
	[adminId] [nvarchar](32) NOT NULL,
	[adminPwd] [nvarchar](16) NOT NULL,
	[adminTypeId] [smallint] NOT NULL,
	[adminName] [nvarchar](20) NOT NULL,
	[cpId] [int] NULL,
	[registDt] [datetime] NOT NULL,
	[apply] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_TempUsedTime]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_TempUsedTime](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[gamebangId] [int] NOT NULL,
	[usedTime] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[TantraUploaderPpCardInsert]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TantraUploaderPpCardInsert]
       @ppCardGroupId      int
,      @pinCode            varchar(40)
,      @ppCardSerialNumber varchar(12)
 AS

INSERT INTO tblPpCard(ppCardGroupId,  pinCode, ppCardSerialNumber) VALUES( @ppCardGroupId , @pinCode,  @ppCardSerialNumber )
GO
/****** Object:  StoredProcedure [dbo].[TantraUploaderPPCardGroupInsert]    Script Date: 09/21/2014 18:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[TantraUploaderPPCardGroupInsert]
       @productId   int
,      @quantity    int
,      @createDt    smalldatetime
,      @validStartDt smalldatetime
,      @validEndDt  smalldatetime
,      @distributorId      int
 AS

INSERT INTO tblPpCardGroup(productId, howManyPeople, quantity, createDt,validStartDt, validEndDt, adminNumber, chongphanId, apply) 
VALUES(@productId, 1 , @quantity, @createDt , @validStartDt , @validEndDt ,1 , @distributorId , 1)

IF @@ERROR <> 0 
	return 0
ELSE
	return @@identity
GO
/****** Object:  View [dbo].[viewUserSales]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[viewUserSales]
AS
SELECT 
	T.transactionId 		AS	transactionId
,	T.transactionTypeId 	AS 	transactionTypeId
, 	CTT.descript 		AS 	transactionTypeDescript 
, 	T.userNumber 		AS 	userNumber
, 	ABS(T.cashAmount) 	AS 	cashAmount 
, 	T.cashBalance 		AS 	cashBalance
, 	T.pointBalance 		AS 	pointBalance
, 	T.registDt 		AS 	registDt
,	T.peerTransactionId 	AS 	peerTransactionId
, 	O.productId 		AS 	productId
, 	C.chargeTypeId 		AS 	chargeTypeId
FROM tblTransaction T JOIN tblCodeTransactionType CTT ON T.transactionTypeId = CTT.transactionTypeId
LEFT OUTER JOIN tblOrder O ON T.transactionId = O.transactionId
LEFT OUTER JOIN tblCharge C ON T.transactionId = C.transactionId
WHERE T.transactionTypeId IN (2 , 6 , 8)
GO
/****** Object:  View [dbo].[viewTransactionForCancel]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewTransactionForCancel]
AS
SELECT   dbo.tblTransaction.transactionId, dbo.tblTransaction.peerTransactionId, 
                dbo.tblTransaction.userNumber, dbo.tblTransaction.transactionTypeId, 
                dbo.tblCharge.chargeTypeId, dbo.tblOrder.productId, 
                dbo.tblProduct.productTypeId, dbo.tblProduct.ipCount
FROM      dbo.tblTransaction INNER JOIN
                dbo.tblOrder ON 
                dbo.tblTransaction.transactionId = dbo.tblOrder.transactionId INNER JOIN
                dbo.tblCharge ON 
                dbo.tblOrder.chargeTransactionId = dbo.tblCharge.transactionId INNER JOIN
                dbo.tblProduct ON dbo.tblOrder.productId = dbo.tblProduct.productId
GO
/****** Object:  View [dbo].[viewPpCard]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[viewPpCard]
AS
SELECT 
	PC.ppCardId, PC.ppCardGroupId, PC.ppCardSerialNumber, PCG.productId, PCG.howManyPeople, PCG.createDt, PCG.validStartDt, PCG.validEndDt, PCG.adminNumber, PCG.chongPhanId, PCG.apply
FROM tblPpCard PC WITH (NOLOCK) JOIN tblPpCardGroup PCG WITH (NOLOCK) ON PC.ppCardGroupId = PCG.ppCardGroupId
GO
/****** Object:  View [dbo].[viewIpList]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewIpList]
AS
SELECT v.virtualIpAddrId , v.ipAddrId , v.isRealIp , v.virtualIpAddr , v.virtualStartIp , v.virtualEndIp , r.gamebangId , r.ipAddr, r.startIp, r.endIp
FROM tblVirtualIpAddr v LEFT OUTER JOIN tblIpAddr r
ON v.ipAddrId = r.ipAddrId
WHERE v.apply = 1 AND r.apply = 1
GO
/****** Object:  View [dbo].[viewGamebangSalesList]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewGamebangSalesList]
AS
SELECT   dbo.tblTransaction.transactionId, dbo.tblTransaction.transactionTypeId, 
                dbo.tblTransaction.userNumber, dbo.tblTransaction.cpId, 
                dbo.tblTransaction.cashAmount, dbo.tblTransaction.peerTransactionId, 
                dbo.tblUserInfo.cpId AS gamebangId , 
                dbo.tblGamebangGameServiceHistory.startDt, 
                dbo.tblGamebangGameServiceHistory.endDt, 
                dbo.tblGameService.gameServiceName, 
                dbo.tblCodeGamebangPaymentType.descript AS gamebangPaymentTypeName, 
                dbo.tblCodeTransactionType.descript AS transactionTypeName, 
                dbo.tblTransaction.registDt, dbo.tblProduct.productName, 
                dbo.tblGamebangGameServiceHistory.limitTime, 
                dbo.tblGamebangGameServiceHistory.usedLimitTime, 
                dbo.tblProduct.limitTime AS productLimitTime, 
	   ISNULL(dbo.tblCharge.chargeTypeId,0) AS chargeTypeId
FROM     dbo.tblTransaction INNER JOIN dbo.tblCodeTransactionType ON dbo.tblTransaction.transactionTypeId = dbo.tblCodeTransactionType.transactionTypeId
	  INNER JOIN dbo.tblUserInfo ON dbo.tblTransaction.userNumber = dbo.tblUserInfo.userNumber AND dbo.tblUserInfo.userTypeId = 9 AND dbo.tblUserInfo.apply = 1
	  LEFT OUTER JOIN 
	  (dbo.tblGamebangGameServiceHistory INNER JOIN dbo.tblGameService ON dbo.tblGamebangGameServiceHistory.gameServiceId = dbo.tblGameService.gameServiceId
	  INNER JOIN dbo.tblCodeGamebangPaymentType ON dbo.tblGamebangGameServiceHistory.gamebangPaymentTypeId = dbo.tblCodeGamebangPaymentType.gamebangPaymentTypeId
	  INNER JOIN dbo.tblOrder ON dbo.tblGamebangGameServiceHistory.transactionId = dbo.tblOrder.transactionId 
	  INNER JOIN dbo.tblProduct ON dbo.tblOrder.productId = dbo.tblProduct.productId)
	  ON dbo.tblTransaction.transactionId = dbo.tblGamebangGameServiceHistory.transactionId 
	  LEFT OUTER JOIN dbo.tblCharge ON dbo.tblTransaction.transactionId = dbo.tblCharge.transactionId
GO
/****** Object:  View [dbo].[viewGamebangGameServiceListForReminTime]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewGamebangGameServiceListForReminTime]
AS
SELECT   dbo.tblGamebangGameService.gamebangGameServiceId, 
                dbo.tblGamebangGameService.gamebangId, 
                dbo.tblGamebangGameService.limitTime, 
                dbo.tblGamebangGameService.usedLimitTime, 
                dbo.tblGamebangGameService.limitTime - dbo.tblGamebangGameService.usedLimitTime
                 AS remainTime, dbo.tblGameService.gameServiceName, 
                dbo.tblGamebang.gamebangName, dbo.tblGamebang.bizNumber, 
                dbo.tblGamebang.manageCode, dbo.tblChongphanGamebang.chongphanId, 
                ISNULL(dbo.tblChongphan.chongphanName, '???..') 
                AS chongphanName
FROM      dbo.tblGamebang INNER JOIN
                dbo.tblGamebangGameService ON 
                dbo.tblGamebang.gamebangId = dbo.tblGamebangGameService.gamebangId INNER
                 JOIN
                dbo.tblGameService ON 
                dbo.tblGamebangGameService.gameServiceId = dbo.tblGameService.gameServiceId
                 LEFT OUTER JOIN
                dbo.tblChongphanGamebang ON 
                dbo.tblGamebang.gamebangId = dbo.tblChongphanGamebang.gamebangId LEFT OUTER
                 JOIN
                dbo.tblChongphan ON 
                dbo.tblChongphanGamebang.chongphanId = dbo.tblChongphan.chongphanId
WHERE   (dbo.tblGamebang.apply = 1)
GO
/****** Object:  View [dbo].[viewGamebangGameService]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewGamebangGameService]
AS
SELECT   dbo.tblGamebangGameService.gamebangGameServiceId AS gamebangGameServiceId,
                 dbo.tblGamebangGameService.gamebangId AS gamebangId, 
                dbo.tblGameService.gameServiceName AS gameServiceName, 
                dbo.tblCp.cpName AS cpName, 
                dbo.tblCodeGamebangPaymentType.descript AS gamebangPaymentType, 
                dbo.tblGamebangGameService.ipCount AS ipCount, 
                dbo.tblGamebangGameService.startDt AS startDt, 
                dbo.tblGamebangGameService.endDt AS endDt, 
                dbo.tblGamebangGameService.limitTime AS limitTime, 
                dbo.tblGamebangGameService.usedLimitTime AS usedLimitTime
FROM      dbo.tblGamebangGameService INNER JOIN
                dbo.tblGameService ON 
                dbo.tblGamebangGameService.gameServiceId = dbo.tblGameService.gameServiceId
                 INNER JOIN
                dbo.tblCp ON dbo.tblGameService.cpId = dbo.tblCp.cpId INNER JOIN
                dbo.tblCodeGamebangPaymentType ON 
                dbo.tblGamebangGameService.gamebangPaymentTypeId = dbo.tblCodeGamebangPaymentType.gamebangPaymentTypeId
GO
/****** Object:  View [dbo].[viewGamebangChongphanList]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewGamebangChongphanList]
AS
SELECT   dbo.tblChongphanGamebang.chongphanGamebangId, 
                ISNULL(dbo.tblChongphan.chongphanName, '????.') AS chongphanName, 
                dbo.tblGamebang.gamebangName, dbo.tblChongphanGamebang.chongphanId, 
                dbo.tblGamebang.gamebangId, dbo.tblGamebang.apply, 
                dbo.tblGamebang.bizNumber, dbo.tblGamebang.phoneNumber, 
                dbo.tblGamebang.presidentSurname + dbo.tblGamebang.presidentFirstName as presidentName, 
	  dbo.tblGamebang.cellPhone, 
                dbo.tblGamebang.address, dbo.tblGamebang.manageCode, 
                dbo.tblGamebang.gamebangTypeId
FROM      dbo.tblGamebang WITH (nolock) LEFT OUTER JOIN
                dbo.tblChongphanGamebang WITH (nolock) ON 
                dbo.tblChongphanGamebang.gamebangId = dbo.tblGamebang.gamebangId LEFT OUTER
                 JOIN
                dbo.tblChongphan WITH (nolock) ON 
                dbo.tblChongphan.chongphanId = dbo.tblChongphanGamebang.chongphanId
WHERE   (dbo.tblGamebang.apply = 1)
GO
/****** Object:  View [dbo].[viewBankDepositList]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[viewBankDepositList]
AS
SELECT   
	BDC.bankDepositConfirmId, 
	BDC.gamebangId, 
	BDC.startDate, 
	BDC.depositAmount, 
	BDC.depositer, 
	BDC.bankName, 
	BDC.depositDate, 
	BDC.confirmType, 
	BDC.misPrice, 
	P.productName, 
	P.productAmount, 
	P.productPeriod, 
	CPT.descript, 
	BDC.transactionId, 
	P.limitTime, 
	P.ipCount, 
	P2.productName AS inProductName, 
	P2.productId AS inProductId
FROM      
	tblBankDepositConfirm BDC LEFT OUTER JOIN tblProduct P2 ON BDC.productId = P2.productId
	LEFT OUTER JOIN (
		tblOrder O JOIN tblProduct P ON O.productId = P.productId 
		JOIN tblCodePeriodType CPT ON P.periodTypeId = CPT.periodTypeId
	) ON BDC.transactionId = O.chargeTransactionId
GO
/****** Object:  View [dbo].[VIEW1]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW1]
AS
SELECT DISTINCT 
                      TOP 100 PERCENT dbo.tblUser.userId, dbo.tblUserInfo.nation, dbo.tblUserInfo.userSurName, dbo.tblUserInfo.userFirstName, dbo.tblUserInfo.email, 
                      dbo.tblUserInfo.address, dbo.tblUserInfo.city, dbo.tblUserInfo.phoneNumber, dbo.tblUserDetail.placeToPlay, 
                      dbo.tblUserDetail.internetConnection
FROM         dbo.tblPpCardUserInfoMapping INNER JOIN
                      dbo.tblPpCard ON dbo.tblPpCardUserInfoMapping.ppCardId = dbo.tblPpCard.ppCardId INNER JOIN
                      dbo.tblUser ON dbo.tblPpCardUserInfoMapping.userNumber = dbo.tblUser.userNumber INNER JOIN
                      dbo.tblPpCardGroup ON dbo.tblPpCard.ppCardGroupId = dbo.tblPpCardGroup.ppCardGroupId INNER JOIN
                      dbo.tblChongphan ON dbo.tblPpCardGroup.chongphanId = dbo.tblChongphan.chongphanId INNER JOIN
                      dbo.tblProduct ON dbo.tblPpCardGroup.productId = dbo.tblProduct.productId INNER JOIN
                      dbo.tblTransaction ON dbo.tblPpCardUserInfoMapping.transactionId = dbo.tblTransaction.transactionId INNER JOIN
                      dbo.tblUserInfo ON dbo.tblPpCardUserInfoMapping.userNumber = dbo.tblUserInfo.userNumber AND 
                      dbo.tblUser.userNumber = dbo.tblUserInfo.userNumber INNER JOIN
                      dbo.tblUserDetail ON dbo.tblUser.userNumber = dbo.tblUserDetail.userNumber
WHERE     (MONTH(dbo.tblTransaction.registDt) = 12) AND (DAY(dbo.tblTransaction.registDt) BETWEEN 1 AND 31)
ORDER BY dbo.tblUserInfo.userFirstName
GO
/****** Object:  View [dbo].[trnsumuser_view]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[trnsumuser_view]
AS
SELECT     dbo.tblUserInfo.userSurName, dbo.tblUserInfo.MI, dbo.tblUserInfo.userFirstName, dbo.tblUserInfo.userId, dbo.tblTransaction.cashBalance, 
                      dbo.tblTransaction.registDt, dbo.tblUserInfo.userNumber
FROM         dbo.tblUserInfo INNER JOIN
                      dbo.tblTransaction ON dbo.tblUserInfo.userNumber = dbo.tblTransaction.userNumber
GO
/****** Object:  View [dbo].[trans2]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[trans2]
AS
SELECT     dbo.tblUserInfo.userId, dbo.tblUserInfo.userSurName, dbo.tblUserInfo.MI, dbo.tblUserInfo.userFirstName, dbo.tblUserGameService.startDt, 
                      dbo.tblUserGameService.endDt, dbo.tblTransaction.cashBalance, dbo.tblTransaction.registDt
FROM         dbo.tblUserInfo INNER JOIN
                      dbo.tblUserGameService ON dbo.tblUserInfo.userNumber = dbo.tblUserGameService.userNumber INNER JOIN
                      dbo.tblTransaction ON dbo.tblUserInfo.userNumber = dbo.tblTransaction.userNumber
GO
/****** Object:  StoredProcedure [dbo].[TopUpPerArea_Sp]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TopUpPerArea_Sp]
@Date1 Datetime,
@Date2 Datetime


AS

SELECT     distinct dbo.tblUserInfo.city, count(distinct dbo.tblTransaction.userNumber) as total
FROM         dbo.tblTransaction INNER JOIN
                      dbo.tblUserInfo ON dbo.tblTransaction.userNumber = dbo.tblUserInfo.userNumber
WHERE     (dbo.tblTransaction.cashAmount > 0) and (dbo.tblTransaction.registDt >= @date1 and dbo.tblTransaction.registDt <= @Date2)
group by  dbo.tblUserInfo.city
order by  dbo.tblUserInfo.city
asc
GO
/****** Object:  StoredProcedure [dbo].[procUpdateGamebangGameServiceReservationUpdate]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE  [dbo].[procUpdateGamebangGameServiceReservationUpdate]
AS
-- =============================================
-- Declare and using a KEYSET cursor
-- =============================================
DECLARE @now DATETIME
--SET @now= getdate()
SET @now= left(Convert(varchar(10), getdate(), 21),10) + ' 00:00:00'
DECLARE uCursor CURSOR

KEYSET
FOR  SELECT transactionId, gamebangGameServiceId, gamebangId, gameserviceId ,startDt   FROM tblGamebangGameServiceReservation gr  with(nolock)  WHERE updateDt <= @now  and isUpdate=0 and isCancel=0
DECLARE @productId		INT
DECLARE @startDt		DATETIME
DECLARE @endDt		DATETIME
DECLARE @preOrderDt	DATETIME
DECLARE @ipCount		INT
--DECLARE @limitTime		INT
--DECLARE @gamebangLimitTime	INT
--DECLARE @usedLimitTime	INT
DECLARE @periodTypeId	INT
DECLARE @productPeriod	INT
DECLARE @transactionId 	INT
DECLARE @gamebangId	INT
DECLARE @gameserviceId	INT
DECLARE @historyStartDt 	DATETIME
DECLARE @gamebangGameServiceId INT
DECLARE @gamebangPaymentTypeId	TINYINT

OPEN uCursor
BEGIN TRAN
FETCH NEXT FROM uCursor INTO  @transactionId, @gamebangGameServiceId, @gamebangId, @gameserviceId, @startDt
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
			--SELECT @gamebangPaymentTypeId=gamebangPaymentTypeId, @startDt=startDt, @endDt=endDt, @gamebangLimitTime=limitTime	, @ipCount =ipCount FROM tblGamebangGameServiceHistory with(rowLock)
			SELECT @gamebangPaymentTypeId=gamebangPaymentTypeId, @startDt=startDt, @endDt=endDt,  @ipCount =ipCount FROM tblGamebangGameServiceHistory with(rowLock)
			WHERE gamebangId = @gamebangId AND gameServiceId = @gameServiceId and transactionid=@transactionId
	
				--	UPDATE tblGamebangGameService		SET gamebangPaymentTypeId=@gamebangPaymentTypeId,limitTime=@gamebangLimitTime,registDt=@now,ipCount=@ipCount , startDt=@startDt ,endDt = @endDt
					UPDATE tblGamebangGameService		SET gamebangPaymentTypeId=@gamebangPaymentTypeId, registDt=@now,ipCount=@ipCount , startDt=@startDt ,endDt = @endDt
					WHERE gamebangGameServiceId = @gamebangGameServiceId and gamebangId=@gamebangId
					
					IF @@ERROR = 0 
						Update  tblGamebangGameServiceReservation set isUpdate=1  WHERE transactionId=@transactionid
	END
	
	FETCH NEXT FROM uCursor INTO  @transactionId, @gamebangGameServiceId, @gamebangId, @gameserviceId, @startDt
	
END
	--Update  tblGamebangGameServiceReservation set isUpdate=1  WHERE updateDt <= @now  and isUpdate=0 and isCancel=0
COMMIT

CLOSE uCursor
DEALLOCATE uCursor
GO
/****** Object:  StoredProcedure [dbo].[procUpdateGamebangAdmin]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procUpdateGamebangAdmin    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procUpdateGamebangAdmin
	Creation Date		:	2002. 2. 21
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	??? ??(???)? ??
	Input Parameters :	
		@userNumber			AS		INT
		@userPwd			AS		nvarchar(32)
		@userName			AS		nvarchar(16)
		@ssno				as	nchar(13)
		@email				AS		nvarchar(32)
	
		@gamebangName		AS		nvarchar(32)
		@zipCode			as	nchar(6)
		@address			AS		nvarchar(64)
		@tel				AS		nvarchar(32)
		@bizNumber			AS		nvarchar(16)
		@presidentName		AS		nvarchar(16)
		@depositAmount		AS		INT
		@chongphanId			AS		INT
	return?:
		@returnCode		AS		TINYINT			
	Return Status:		1: ?? ??
				2: ?? ??? ????.
				3: ?? ??? ?????.
		
	Nothing
	Usage: 			
	Call by		:	
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateGamebangAdmin]
	@userNumber			AS		INT
,	@userId			AS		nvarchar(32)
,	@gamebangId			AS		INT
,	@userPwd			AS		nvarchar(32)
,	@userSurName			AS		nvarchar(64)
,	@userFirstName			AS		nvarchar(64)
,	@ssno				as	nchar(13)
,	@sex				as	int
,	@email				AS		nvarchar(32)
,	@returnCode			AS		TINYINT		OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@procUpdateGamebangReturnCode	AS		TINYINT
------------------------?? ???--------------------
IF(EXISTS(SELECT userNumber FROM tblUserInfo WHERE userId = @userId AND userTypeId = 9 AND userNumber <> @userNumber)) 		--???? ?? ????.
	BEGIN
		SET @returnCode = 2
		RETURN
	END
ELSE															--???? ???? ??? ????.
	BEGIN
		UPDATE tblUser
		SET	userId = @userId , userPwd = @userPwd
		WHERE userNumber = @userNumber
		
		UPDATE tblUserInfo
		SET
			userId = @userId
		,	userPwd = @userPwd 						-- password
		,	userSurName = @userSurName						-- userName
		,	userFirstName = @userFirstName						-- userName
		,	ssno = @ssno 							-- ??????
		,	email = @email 	
		,	sex = @sex							-- E-mail
		,	registDt = getdate()						-- registDt
		WHERE userNumber = @userNumber
	
		INSERT INTO 
			tblUserInfoHistory (userNumber, userId, userPwd, cpId, userSurName, userFirstName, userTypeId, userStatusId, gameServiceId, ssno, sex,
			birthday, isSolar, email, zipcode, nation, address, phoneNumber, passwordCheckQuestionTypeId, 
			passwordCheckAnswer, cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply)
		SELECT 
			userNumber, userId, userPwd, cpId, userSurName, userFirstName, userTypeId, userStatusId, gameServiceId, ssno, sex,
			birthday, isSolar,	email, zipcode, nation, address, phoneNumber, passwordCheckQuestionTypeId, 
			passwordCheckAnswer, cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply 
		FROM tblUserInfo with (nolock)
		WHERE userNumber = @userNumber
				
		SET @returnCode = 1
	END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateChongphan]    Script Date: 09/21/2014 18:05:13 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procUpdateChongphan    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procUpdateGamebang
	Creation Date		:	2002. 01.25
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	?? ??
	
	Input Parameters :	
				@chongphanId			AS		TINYINT	
				@chongphanName		AS		nvarchar(32)
				@zipCode			as	nchar(6)
				@address			AS		nvarchar(64)
				@phoneNumber			AS		nvarchar(32)
				@presidentName		AS		nvarchar(16)
				@commission			AS		FLOAT(53)
				@memo				AS		nvarchar(200)
				@adminNumber			AS		TINYINT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ?????.
				
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblChongphan(S,U)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateChongphan]
	@chongphanId			AS	INT	
,	@chongphanName		AS	nvarchar(32) 	 = null
,	@zipcode			as	nchar(6)  	 = null
,	@address			AS	nvarchar(64) 	  = null
,	@phoneNumber		AS	nvarchar(32)	  
,	@bizNumber			AS	nvarchar(16)	  = null
,	@presidentName		AS	nvarchar(16)
,	@commission			AS	NUMERIC(9,2)	
,	@memo			AS	nvarchar(200)
,	@adminNumber		AS	INT
,	@bondDate			as	smalldatetime
,	@expiryDate			AS	smalldatetime
,	@returnCode			AS	TINYINT	OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
UPDATE tblChongphan
SET
	chongphanName = @chongphanName
,	zipcode = @zipcode
,	address = @address
,	phoneNumber = @phoneNumber
,	presidentName = @presidentName
,	bizNumber = @bizNumber
,	commission = @commission
,	bondDate = @bondDate
,	expiryDate = @expiryDate
WHERE chongphanId = @chongphanId
--tblAdminLog? ???
INSERT INTO tblAdminLog 
	VALUES(
		'Amend'
	,	'tblChongphan'
	,	@adminNumber
	,	@memo +  'Modify'
	,	GETDATE()
	)
SET @adminLogId = @@IDENTITY
--tblGamebangHistory? ???.
INSERT INTO tblChongphanHistory 
	SELECT chongphanId , chongphanName , bizNumber , address , zipcode , phoneNumber , presidentName , commission, bondDate, expiryDate,  apply , GETDATE() , @adminLogId 
	FROM tblChongphan 
	WHERE chongphanId = @chongphanId
--EXEC procUpdateCpChongphan @cpId , @chongphanId , @memo , @adminNumber
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procUpdateBankDepositConfirm]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateBankDepositConfirm    Script Date: 23/1/2546 11:40:25 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procUpdateBankDepositConfirm
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	??? ?? ??
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateBankDepositConfirm]
	@bankDepositConfirmId			AS		INT
,	@transactionId				as		int
,	@startDate				as		smalldatetime
,	@depositAmount			as		int
,	@depositer				as		nvarchar(50)
,	@bankName				as		nvarchar(50)
,	@depositDate				as		smalldatetime
,	@confirmType				AS		TINYINT
,	@misPrice				AS		INT
,	@memo					AS		nvarchar(500)
,	@adminNumber				AS		INT
,	@returnCode				AS		TINYINT		OUTPUT
AS
DECLARE	@adminLogId		AS		INT
IF(EXISTS(SELECT * FROM tblBankDepositConfirm WHERE transactionId = @transactionId AND bankDepositConfirmId <>@bankDepositConfirmId ))	--?? transactionId? tblBankDepositConfirm ? ???
	BEGIN
		SET @returnCode = 3
		RETURN
	END
ELSE IF(EXISTS(SELECT * FROM tblTransaction WHERE transactionId = @transactionId AND transactionTypeId = 1))		--?? transactionId? tblTransaction? ???
	BEGIN
		UPDATE tblBankDepositConfirm 
		SET 
			transactionId = @transactionId
		,	startDate = @startDate
		,	depositAmount = @depositAmount
		,	depositer = @depositer
		,	bankName = @bankName
		,	depositDate = @depositDate
			
		,	confirmType = @confirmType 
		,	misPrice = @misPrice 
		,	memo = @memo 
		,	registDt = GETDATE()
		WHERE bankDepositConfirmId = @bankDepositConfirmId
		
		--tblAdminLog? ???
		INSERT INTO tblAdminLog 
			VALUES(
				'Amend'
			,	'tblBankDepositConfirm'
			,	@adminNumber
			,	@memo
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY
		
		INSERT INTO tblBankDepositConfirmHistory 
			SELECT bankDepositConfirmId, gamebangId, productId , transactionId, startDate, depositAmount, depositer, bankName, depositDate, confirmType,misPrice ,  memo , registDt ,@adminLogId
			FROM tblBankDepositConfirm 
			WHERE bankDepositConfirmId = @bankDepositConfirmId
		
		SET @returnCode = 1
	END
ELSE
	BEGIN
		SET @returnCode = 2
		RETURN
	END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateAdminAuthControl]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procUpdateAdminAuthControl]
	@adminTypeId		AS		int
,	@menuId		AS		int
,	@writable		AS		bit
,	@opt			AS		smallint
,	@result			AS		int	OUTPUT	
AS
DECLARE @menuCount	as	int
DECLARE @sortId		AS	int
SELECT @menuCount = COUNT(menuId) FROM tblCodeAdminTypeMenu	 
WHERE adminTypeId = @adminTypeId and menuId = @menuId
IF @opt  = 10 
	GOTO UPDATE_ADMINAUTH
ELSE IF @opt = 20
	GOTO DELETE_ADMINAUTH
ELSE
	GOTO FAIL_OPT
/***********************************************************************************/
		UPDATE_ADMINAUTH:
/***********************************************************************************/
IF (@menuCount =  0)
BEGIN
	SELECT @sortId = max(sortId) FROM tblCodeAdminTypeMenu WHERE adminTypeId = @adminTypeId
	INSERT INTO  tblCodeAdminTypeMenu (adminTypeId, menuId, sortId, writable) 
	VALUES(@adminTypeId, @menuId, (@sortId+1), @writable)
END
ELSE IF(@menuCount =  1)
BEGIN
	UPDATE tblCodeAdminTypeMenu
	SET	writable = @writable
	WHERE adminTypeId = @adminTypeId AND	 menuId = @menuId
END
IF (@@ERROR <> 0 )
	SET @result = -501
ELSE
	SET @result = 0
GOTO RESULT
/***********************************************************************************/
		DELETE_ADMINAUTH:
/***********************************************************************************/
IF (@menuCount = 0 ) 
BEGIN
	SET @result = -502
	GOTO RESULT
END
ELSE
BEGIN
	DELETE FROM tblCodeAdminTypeMenu WHERE adminTypeId = @adminTypeId and menuId = @menuId
END
IF (@@ERROR <> 0 )
	SET @result = -501
ELSE
	SET @result = 0
GOTO RESULT
/***********************************************************************************/
		FAIL_OPT:
/***********************************************************************************/
	SET @result = -503
	GOTO RESULT
/***********************************************************************************/
		RESULT:
/***********************************************************************************/
RETURN
GO
/****** Object:  StoredProcedure [dbo].[procUnblockUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procUnblockUser    Script Date: 23/1/2546 11:40:28 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procUnblockUser
	Creation Date		:	2002-07-30
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	?? ??? ???? ???
	
******************************Optional Item******************************
	Input Parameters	:	
					@endDt		AS	SMALLDATETIME
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUnblockUser]
	@endDt		AS	SMALLDATETIME
AS
UPDATE tblUserInfo 
SET userPwd = BUM.oldPassword , userStatusId = BUM.oldUserStatusId
FROM tblBlockedUserManagement BUM WITH (READUNCOMMITTED)
WHERE tblUserInfo.userNumber= BUM.userNumber AND BUM.endDt <= @endDt
UPDATE tblUser 
SET userPwd = BUM.oldPassword , userStatusId = BUM.oldUserStatusId
FROM tblBlockedUserManagement BUM WITH (READUNCOMMITTED)
WHERE tblUser.userNumber= BUM.userNumber AND BUM.endDt <= @endDt
DELETE FROM tblBlockedUserManagement WHERE endDt <= @endDt
GO
/****** Object:  StoredProcedure [dbo].[procInsertUserStatusCode]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertUserStatusCode    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertUserStatusCode]
@descript			as		nvarchar(100)		,
@canGameLogin		as		bit			,
@canWebLogin			as		bit			,
@canOrder			as		bit			,
@apply				as		bit			,
@adminNumber			as		int
as
INSERT INTO
	tblCodeUserStatus
VALUES (
	@descript		,
	@canGameLogin	,
	@canWebLogin		,
	@canOrder		,
	getdate()		,
	@apply
	)
GO
/****** Object:  StoredProcedure [dbo].[procUpdateCp]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateCp    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procUpdateCp
	Creation Date		:	2002. 02.17
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	CP ??
	
	Input Parameters :	
				@cpId				AS		INT	
				@cpName			AS		nvarchar(32)
				@zipCode			as	nchar(6)
				@address			AS		nvarchar(64)
				@phoneNumber			AS		nvarchar(32)
				@presidentName		AS		nvarchar(16)
				@memo				AS		nvarchar(200)
				@adminNumber			AS		TINYINT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ?????.
				
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateCp]
	@cpId				AS		INT	
,	@cpName			AS		nvarchar(32)
,	@zipcode			as	nchar(6)
,	@address			AS		nvarchar(64)
,	@phoneNumber			AS		nvarchar(32)
,	@presidentName		AS		nvarchar(16)
,	@memo				AS		nvarchar(200)
,	@adminNumber			AS		INT
,	@returnCode			AS		TINYINT	OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
UPDATE tblCp
SET
	cpName = @cpName
,	zipcode = @zipcode
,	address = @address
,	phoneNumber = @phoneNumber
,	presidentName = @presidentName
WHERE cpId = @cpId
--tblAdminLog? ???
INSERT INTO tblAdminLog 
	VALUES(
		'Amend'
	,	'tblCp'
	,	@adminNumber
	,	@memo
	,	GETDATE()
	)
SET @adminLogId = @@IDENTITY
--tblGamebangHistory? ???.
INSERT INTO tblCpHistory 
	SELECT cpId , cpName , bizNumber , address , zipcode , phoneNumber , presidentName , apply , GETDATE() , @adminLogId 
	FROM tblCp 
	WHERE cpId = @cpId
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procUpDateExpireDt]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
?? ??? ? ??? ?? 
?? ??? ?? ?? ????? ??
usedLimitTime  ?  limitTime? ???? ??.
*/
CREATE proc [dbo].[procUpDateExpireDt]

AS
declare @now  datetime
set @now = getdate()

INSERT tblUserGameServiceExpireDateHistory(userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, expireDt,  registDt, updateDt, expireDtTypeId)
SELECT userGameServiceId, userNumber, gameServiceId,startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, expireDt, registDt, @now, 1
FROM tblUserGameService with(rowLock) WHERE userGameServiceId  in 
(
	SELECT userGameServiceId  FROM tblUserGameService where limitTime - usedLimitTime > 0  and expireDt <@now and expireDt is not null
)

UPDATE tblUserGameService set usedLimitTime=limitTime  where limitTime - usedLimitTime > 0  and expireDt < @now    and expireDt is not null
--UPDATE tblUserGameService set usedLimitTime=limitTime  , expireDt =null where limitTime - usedLimitTime > 0  and expireDt < @now    and expireDt is not null
GO
/****** Object:  StoredProcedure [dbo].[procUpdateEmail]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE procedure [dbo].[procUpdateEmail]
	@userid as nvarchar(50),
	@newemail as nvarchar(50)
as
	update tblUserInfo set Email = @newemail where userid=@userid
	update tblUserInfoHistory set Email = @newemail where userid=@userid

if @@Error=0
	return 1
else
	return -1
GO
/****** Object:  StoredProcedure [dbo].[procUpdateDcRate]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateDcRate    Script Date: 23/1/2546 11:40:25 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procUpdateDcRate 
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	?? ??? ??
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateDcRate] 
	@dcRateId		AS		INT
,	@dcStartTime		as	nchar(4)
,	@dcEndTime		as	nchar(4)
,	@dcRate		AS		NUMERIC(8,3)
,	@apply			AS		BIT
,	@returnCode		AS		TINYINT		OUTPUT
AS
UPDATE tblDcRate 
SET 
	dcStartTime = @dcStartTime
,	dcEndTime = @dcEndTime
,	dcRate = @dcRate
,	apply = @apply
WHERE dcRateId = @dcRateId
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procUpdateRejectWord]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateRejectWord    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procUpdateRejectWord
	Creation Date		:	2002. 02.20
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	???? ??
	
	Input Parameters :	
				@rejectWordId		AS		INT
				@rejectWord		AS		nvarchar(40)
				@descript		AS		nvarchar(50)
				@rejectTypeId		AS		TINYINT
				@adminNumber		AS		INT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ?????.
				2: ?? ??? ????? ??.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateRejectWord] 
	@rejectWordId			AS		INT
,	@rejectWord			AS		nvarchar(40)
,	@descript			AS		nvarchar(50)
,	@rejectWordTypeId		AS		TINYINT
,	@adminNumber			AS		INT
,	@returnCode			AS		TINYINT		OUTPUT
AS
IF(EXISTS(SELECT * FROM tblRejectWord WHERE rejectWord = @rejectWord AND rejectWordTypeId = @rejectWordTypeId AND rejectWordId <>@rejectWordId))
	BEGIN
		SET @returnCode = 2		--?? ??? ?????.
	END
ELSE
	BEGIN
		UPDATE tblRejectWord
		SET 
			rejectWord = @rejectWord
		,	descript = @descript
		,	rejectWordTypeId = @rejectWordTypeId
		,	registDt = GETDATE()
		,	adminNumber = @adminNumber
		WHERE rejectWordId = @rejectWordId
		
		SET @returnCode = 1		--????? ??
	END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateRefundRequest]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateRefundRequest    Script Date: 23/1/2546 11:40:25 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procUpdateRefundRequest 
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	?? ?? ??
	
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateRefundRequest] 
	@refundRequestId		AS		INT
,	@returnCode			AS		TINYINT		OUTPUT
AS
UPDATE tblRefundRequest 
SET processStatus = 3 
WHERE refundRequestId = @refundRequestId
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procUpdateRealIpAddr]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateRealIpAddr    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procUpdateRealIpAddr
	Creation Date		:	2002. 01.26
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	IP??
	
	Input Parameters :	
				@ipAddrId			AS		INT
				@virtualIpAddrId			AS		INT
				@ipAddr			AS		nvarchar(11)
				@startIp			AS		TINYINT
				@endIp				AS		TINYINT
				@adminNumber			AS		INT
				@memo				AS		nvarchar(200)
	Output Parameters:	
				@returnCode			AS		INT	OUTPUT
				
	Return Status:		
				0 : ?? ??.
				?? : ?? ?????? ipAddrId
	Usage		:	
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblIpAddr(S,I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateRealIpAddr]
	@ipAddrId			AS		INT
,	@virtualIpAddrId			AS		INT
,	@ipAddr			AS		nvarchar(11)
,	@startIp			AS		TINYINT
,	@endIp				AS		TINYINT
,	@adminNumber			AS		INT
,	@memo				AS		nvarchar(200)
,	@returnCode			AS		INT		OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@checkIpAddrId		AS		INT
DECLARE	@adminLogId			AS		INT
------------------------?? ?? ?-------------------
SELECT @checkIpAddrId = ipAddrId FROM tblIpAddr WHERE ipAddrId <> @ipAddrId AND ipAddr = @ipAddr AND (startIp  <= @endIp AND endIp >= @startIp) AND apply = 1
IF(@checkIpAddrId IS NULL)
	BEGIN
		--tblIpAddr ??
		UPDATE tblIpAddr
			SET ipAddr = @ipAddr
			,	startIp = @startIp
			,	endIp = @endIp
			,	registDt = GETDATE()
			WHERE ipAddrId = @ipAddrId
		
		INSERT INTO tblAdminLog 
			VALUES(
				'Registration'
			,	'tblIpAddr'
			,	@adminNumber
			,	'REALLIP Registration'
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY
		INSERT INTO tblIpAddrHistory
			SELECT ipAddrId, gamebangId, ipAddr, startIp, endIp, GETDATE(), apply , @adminLogId 
			FROM tblIpAddr
			WHERE ipAddrId = @ipAddrId
		
		--tblVirtualIp ??
		UPDATE tblVirtualIpAddr
			SET virtualIpAddr = @ipAddr
			,	 virtualStartIp = @startIp
			,	 virtualEndIp = @endIp
			,	registDt = GETDATE()
			WHERE virtualIpAddrId = @virtualIpAddrId
		INSERT INTO tblAdminLog 
			VALUES(
				'Amend'
			,	'tblVirtualIpAddr'
			,	@adminNumber
			,	@memo
			,	GETDATE()
			)
		SET @adminLogId = @@IDENTITY
	
		INSERT INTO tblVirtualIpAddrHistory
			SELECT virtualIpAddrId , ipAddrId , isRealIp , virtualIpAddr , virtualStartIp , virtualEndIp , registDt , apply , @adminLogId
			FROM tblVirtualIpAddr
			WHERE virtualIpAddrId = @virtualIpAddrId
		SET @returnCode = 0
	END
ELSE
	BEGIN
		SET @returnCode = @checkIpAddrId
	END
GO
/****** Object:  StoredProcedure [dbo].[procUpdatePpCard]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdatePpCard    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procUpdatePpCard
	Creation Date		:	2002. 12. 26
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	PPCard? ??
	Input Parameters :	
			
	return?:
		rtnValue 		as		int : ?? ??
	Return Status:		
		Integer
	Usage: 			
		exec procInsertCard 10, '1234123412345678', 1000, 1, 0400, '????', 9982732724, 'KF200204050000001234'
	Call by		:	PP?? ?? ???
				PGCardService.CardManager	
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I), tblChargeCardDeposit(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdatePpCard]
	@ppCardGroupId	as	int
,	@productId 		as 	int
,	@validStartDt 		as 	smallDatetime
,	@validEndDt 		as 	smallDatetime
,	@howManyPeople	as	int
,	@adminNumber		as 	int
,	@rtnValue		as	int output
AS
DECLARE @userCount as int
SELECT @userCount = count(ppCardUserInfoId) FROM tblPpCardUserInfoMapping PCUM WITH(NOLOCK) JOIN tblPpCard PC WITH(NOLOCK) ON PCUM.ppCardId = PC.ppCardId
WHERE ppCardGroupId = @ppCardGroupId
IF @userCount <> 0 
	SET @rtnValue = 1
ELSE
	BEGIN
		UPDATE tblPpCardGroup 
		SET 
			productId = @productId, 
			howManyPeople = @howManyPeople, 
			validStartDt = @validStartDt, 
			validEndDt = @validEndDt, 
			adminNumber = @adminNumber
		WHERE 
			ppCardGroupId = @ppCardGroupId
		IF @@ERROR = 0
			SET @rtnValue = 99
		ELSE
			SET @rtnValue = 0
	END
GO
/****** Object:  StoredProcedure [dbo].[procUpdatePostToChongphanId]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdatePostToChongphanId    Script Date: 23/1/2546 11:40:25 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procUpdatePostToChongphanId
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	
	
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdatePostToChongphanId]
	@newPostToChongphanId		AS		INT
,	@newChongphanId			AS		INT
,	@returnCode				AS		TINYINT	OUTPUT
AS
UPDATE tblPostToChongphan
SET chongphanId = @newChongphanId
WHERE postToChongphanId = @newPostToChongphanId
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procUpdatePostToChongphan]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdatePostToChongphan    Script Date: 23/1/2546 11:40:25 ******/
/*
??? : ???
?? : ??? ??? ?? ??
*/
CREATE PROCEDURE [dbo].[procUpdatePostToChongphan] 
	@postToChongphanId		AS		INT
,	@chongphanId			AS		INT
,	@returnCode			AS		TINYINT
AS
DECLARE	@checkChongphanId		AS		INT	
SELECT @checkChongphanId = chongphanId
FROM tblPostToChongphan 
WHERE postToChongphanId = @postToChongphanId
IF(@chongphanId <> @checkChongphanId)
	BEGIN
		UPDATE tblPostToChongphan 
		SET chongphanId = @chongphanId
		WHERE postToChongphanId = @postToChongphanId
		SET @returnCode = 1
		RETURN
	END
ELSE
	BEGIN
		--????? ??. 
		SET @returnCode = 2
		RETURN
	END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateUserStatusCode]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateUserStatusCode    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateUserStatusCode]
@userStatusId 			as		int			,
@descript			as		nvarchar(100)		,
@canGameLogin		as		bit			,
@canWebLogin			as		bit			,
@canOrder			as		bit			,
@apply				as		bit
as
UPDATE 
	tblCodeUserStatus
SET
	descript = @descript			,
	canGameLogin = @canGameLogin	,
	canWebLogin = @canWebLogin		,
	canOrder = @canOrder			,
	apply = @apply
WHERE 
	userStatusId = @userStatusId
GO
/****** Object:  StoredProcedure [dbo].[procUpdateUserPassword2]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateUserPassword2    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procUpdateUserPassword2
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	???? ?? ??
	Input Parameters :	
		@userId				as	nvarchar(32)		
		@cpId					as	int			
		@password				as	nvarchar(32)		
		@userName				as	nvarchar(16)		
		@ssno					as	nvarchar(13)		
		@birthday				as	smalldatetime		
		@isSolar				as	bit			
		@zipcode				as	nchar(6)			
		@address				as	nvarchar(64)		
		@addressDetail				as	nvarchar(64)		
		@phoneNumber				as	nvarchar(16)		
		@email					as	nvarchar(64)		
		@passwordCheckQuestionTypeId	as	int
		@passwordCheckAnswer		as	nvarchar(64)		
		@userNumber				as	int		OUTPUT
			
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
		EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateUserPassword2]
	@userId			as	nvarchar(32)
,	@cpId				as	int
,	@newPassword			as	nvarchar(32)
,	@msg				as	nvarchar(64)	OUTPUT
as
	UPDATE tblUser SET userPwd = @newPassword WHERE userId = @userId AND cpId = @cpId
	UPDATE tblUserInfo SET userPwd = @newPassword WHERE userId = @userId AND cpId = @cpId
	SET @msg = 'Password changed.' 
	RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[procUpdateUserPassword]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateUserPassword    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procUpdateUserPassword
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	???? ?? ??
	Input Parameters :	
		@userId				as	nvarchar(32)		
		@cpId					as	int			
		@password				as	nvarchar(32)		
		@userName				as	nvarchar(16)		
		@ssno					as	nvarchar(13)		
		@birthday				as	smalldatetime		
		@isSolar				as	bit			
		@zipcode				as	nchar(6)			
		@address				as	nvarchar(64)		
		@addressDetail				as	nvarchar(64)		
		@phoneNumber				as	nvarchar(16)		
		@email					as	nvarchar(64)		
		@passwordCheckQuestionTypeId	as	int
		@passwordCheckAnswer		as	nvarchar(64)		
		@userNumber				as	int		OUTPUT
			
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
		EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateUserPassword]
	@userId			as	nvarchar(32)
,	@cpId				as	int
,	@password			as	nvarchar(32)
,	@newPassword			as	nvarchar(32)
,	@msg				as	nvarchar(64)	OUTPUT
as
	DECLARE @oldPassword	as	nvarchar(32)
	
	SELECT @oldPassword = userPwd
	FROM tblUserInfo
	WHERE userId = @userId AND cpId = @cpId	
	IF @password <> @oldPassword
	BEGIN
		SET @msg = 'Incorrect password.' 
		RETURN 1
	END
	ELSE
	BEGIN
		UPDATE tblUser SET userPwd = @newPassword WHERE userId = @userId AND cpId = @cpId
		UPDATE tblUserInfo SET userPwd = @newPassword WHERE userId = @userId AND cpId = @cpId
		SET @msg = 'Password changed.' 
		RETURN 0
	END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateUserGameServiceForAdminOld]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procUpdateUserGameServiceForAdminOld]
	@userNumber 		as varchar(300)
,	@TimeAndDay		as int
,	@addInt 		as int
,	@gameServiceId	as int
,	@returnCode		as int output
	

 AS
DECLARE  @endDt datetime
DECLARE @sql  varchar( 600)
DECLARE @upNum int
DECLARe @limitTime int
DECLARE @upNumber int
set @upNum = -1

	/*'select  @endDt=endDt , @limitTime=limitTime  from tblUserGameService where userNumber=@userNumber and gameServiceId=@gameServiceId
	/IF @@ROWCOUNT = 0 
	BEGIN
		SET  @returnCode = -1
		return
	END*/
	IF @TimeAndDay = 1   --TERM
	BEGIN
		--set @endDt = Dateadd(dd, @addInt , @endDt)  
		--set @sql = 'UPDATE tblUserGameService	SET  endDt =''' + dateadd(dd, @addInt,  Convert(varchar(20), endDt, 20)) + ''', registDt =GETDATE()  WHERE userNumber in  (' +  CONVERT(VARCHAR(300), @userNumber)  + ')  and gameServiceId =' +  Convert(varchar(2),  @gameServiceId)
		
		WHILE @upNum <> 0 
		begin
			set @upNum = CHARINDEX(',', @userNumber)
			IF @upNum <> 0 
			BEGIN
				SET @upNumber = Convert(int, substring(@userNumber , 1, @upNum -1))
				UPDATE tblUserGameService	SET  endDt = dateadd(dd, @addInt,   endDt)  , registDt =GETDATE()  WHERE userNumber =  @upNumber   and gameServiceId = @gameServiceId
				SET @userNumber = SUBSTRING(@userNumber , @upNum+ 1 , len(@userNumber))
			END
			ELSE
				UPDATE tblUserGameService	SET  endDt = dateadd(dd, @addInt,   endDt)  , registDt =GETDATE()  WHERE userNumber =  @upNumber   and gameServiceId = @gameServiceId
			
		end	
		
	END 
	ELSE
	BEGIN
		--set @limitTime = @limitTime +@addInt
		--set @sql = 'UPDATE tblUserGameService	SET  limitTime=limitTime ' + Convert(varchar(5), limitTime)  + ', registDt =GETDATE()  WHERE userNumber in  (' +  @userNumber  + ')  and gameServiceId =' +  Convert(varchar(2),  @gameServiceId)
		UPDATE tblUserGameService	SET  limitTime=limitTime + @addInt  , registDt =GETDATE()  WHERE userNumber in  (  @userNumber  )  and gameServiceId = @gameServiceId
	END




	IF @@ERROR <>0 
	BEGIN
		SET  @returnCode = -2
		return
	END
		SET  @returnCode = 1


/*	

	select  @endDt=endDt  from tblUserGameService where userNumber=@userNumber and gameServiceId=@gameServiceId
	IF @@ROWCOUNT = 0 
	BEGIN
		SET  @returnCode = 0
		return
	END
	IF @TimeAndDay = 1   --TERM
	BEGIN

		IF @endDt < getdate() 
		begin	
			UPDATE tblUserGameService
			SET  endDt =dateadd(dd, @addInt, getdate())  , registDt =GETDATE() WHERE userNumber in ( @userNumber ) and gameServiceId = @gameServiceId
			IF @@ERROR <>0 
			BEGIN
				SET  @returnCode = 0
				return
			END
				SET  @returnCode = 1

		end
		ELSE
		BEGIN
			UPDATE tblUserGameService	SET  endDt = Dateadd(dd, @addInt, @endDt ), registDt =GETDATE() WHERE userNumber in  ( @userNumber )  and gameServiceId = @gameServiceId
			IF @@ERROR <>0 
			BEGIN
				SET  @returnCode = 0
				return
			END
				SET  @returnCode = 1

		END
		
	END 
	ELSE
	BEGIN
			UPDATE tblUserGameService	SET  limitTime=limitTime + @addInt , registDt =GETDATE() WHERE userNumber  in ( @userNumber )  and gameServiceId = @gameServiceId			
			IF @@ERROR <>0 
			BEGIN
				SET  @returnCode = 0
				return
			END
				SET  @returnCode = 1
	END
GO
*/
GO
/****** Object:  StoredProcedure [dbo].[procUpdateUserGameServiceForAdmin]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procUpdateUserGameServiceForAdmin]
	@userNumbers		as varchar(500)
,	@TimeAndDay		as int
,	@addInt 		as int
,	@gameServiceId	as int
,	@returnCode		as int output
	

 AS
DECLARE  @endDt datetime 
,	@userNumber int
, 	@sql  varchar( 600)
,	@upNum int
,	@isNext  bit
,	@periodTypeId  INT
,	@now smalldatetime

	set @now = getdate()
	IF @TimeAndDay = 1   --TERM
	BEGIN
		set @sql = 'UPDATE tblUserGameService	SET  endDt =dateadd(dd, ' +convert(varchar(3),  @addInt) + ', Convert(varchar(20), endDt, 20)) , registDt =GETDATE()  WHERE userNumber in  (' +  CONVERT(VARCHAR(300), @userNumbers )  + ')  and gameServiceId =' +  Convert(varchar(2),  @gameServiceId)
		SET @periodTypeId = 2
	END 
	ELSE
	BEGIN
		set @sql = 'UPDATE tblUserGameService	SET  limitTime=limitTime+' + convert(varchar(3), @addInt)   + ', registDt =GETDATE()  WHERE userNumber in  (' +  @userNumbers  + ')  and gameServiceId =' +  Convert(varchar(2),  @gameServiceId)
		SET @periodTypeId = 4
	END

	EXEC(@sql)

	


	--- History ?? 
	SET  @isNext = 1
	WHILE @isNext = 1 
	BEGIN
		SET @upNum = CHARINDEX(',', @userNumbers )
		IF  @upNum = 0  --??? ??? ?? ?? ??? ??
		begin
			INSERT INTO  tblUserGameServiceAdjustmentHistory ( userNumber, periodTypeId, addInt, registDt)
			VALUES(@userNumber , @periodTypeId , @addInt, @now )
			set @isNext = 0	
			BREAK
		end
		BEGIN	-- ?? ?? ??? ?? ???? INSERT ?? ??
			SET @userNumber = SUBSTRING(@userNumbers, 1, @upNum-1)
			SET @userNumbers = SUBSTRING(@userNumbers, @upNum  + 1 , len(@userNumbers) - len(@upNum))
			INSERT INTO  tblUserGameServiceAdjustmentHistory ( userNumber, periodTypeId, addInt, registDt)
			VALUES(@userNumber , @periodTypeId , @addInt, @now )
		END

	END
	
	IF @@ERROR <>0 
	BEGIN
		SET  @returnCode = -2
		return
	END
		SET  @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procUpdateUserGameServiceFixedTimeEmpty]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
???: ???
emial : iBeliveKim@n-cash.net
???: 2005-04-07
1.  ???? ?? :  ??? ??? ?? ??? ?? ??? ???? ?? ??? ???.
2. ??? ??(???? ,????) ?? ?? ??? ??? ?? ??? ???? ??
3. ??? expireDt ??? ??


??? ?? ?? ??? limitTime ? usedLimitTime ?? ??? ??
???? ??
*/
CREATE PROC [dbo].[procUpdateUserGameServiceFixedTimeEmpty]
	@userNumber 	INT
,	@expireDtTypeId INT
AS

	IF EXISTS( SELECT *  FROM tblUserGameService with(READUNCOMMITTED) WHERE  userNumber=@userNumber)
	BEGIN
		INSERT tblUserGameServiceExpireDateHistory(userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, expireDt,  registDt, updateDt, expireDtTypeId)
		SELECT userGameServiceId, userNumber, gameServiceId,startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, expireDt, registDt, getdate(), @expireDtTypeId
		FROM tblUserGameService with(rowLock) WHERE userNumber=@userNumber	and expireDt is not null
		UPDATE tblUserGameService set usedLimitTime=limitTime  where userNumber=@userNumber  and limitTime-usedLimitTime > 0 and expireDt is not null
--		UPDATE tblUserGameService set usedLimitTime=limitTime , expireDt=null where userNumber=@userNumber  and limitTime-usedLimitTime > 0 and expireDt is not null
	END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateUserGameService]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Declare and using a KEYSET cursor
-- =============================================

CREATE PROC [dbo].[procUpdateUserGameService]
	@userNumber int
as
DECLARE upCursor CURSOR
KEYSET
FOR
SELECT   isnull(productPeriod, 0) productPeriod, isnull(periodTypeId,0) periodTypeId,  isnull(p.limitTime,0)  limitTime , t.transactionid  transactionid , t.registDt 
		from tblTransaction  t with(nolock) 
		join tblOrder o with(nolock) on o.transactionId=t.transactionId
		join tblProduct p with(nolock) on p.productId=o.productId
		--join tblUserGameServiceHistory ugh with(nolock) on ugh.transactionId=o.transactionId
		where o.productId <> 1021 and peerTransactionId IS NULL AND t.userNumber=@userNumber
		and t.registDt >'2005-03-03 00:00:00'
		order by t.transactionId asc 

DECLARE @transactionId int
DECLARE @prevTransactionid int
DECLARE @limitTime	INT
DECLARE @prevLimitTime int
DECLARE @productPeriod int
DECLARE @registDt  datetime
DECLARE @startDt    datetime
DECLARE @endDt	    datetime
DECLARE @expireDt  datetime
DECLARE @periodTypeId INT

SET @prevTransactionId = 0

OPEN upCursor

FETCH NEXT FROM upCursor  INTO  @productPeriod ,@periodTypeId,  @limitTime,  @transactionId, @registDt
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN

		IF @registDt < '2005-03-19 00:00:00' --?? ?? ?? ?????
		BEGIN
			IF @prevTransactionId =  0   --????
			BEGIN
				--IF @periodTypeId IS NULL OR @productPeriod IS null  --?? ??

				IF @limitTime=0   --??
					BEGIN
						Set @startDt= '2005-03-31 00:00:00'
						UPDATE tblUserGameServiceHistory set startDt = @startDt , endDt=Dateadd(dd, @productPeriod * 2 ,  @startDt), limitTime = 0 ,expireDt = Null  where transactionId=@transactionId
					END
				ELSE  
					BEGIN
						Set @startDt= '2005-03-31 00:00:00'

						UPDATE  tblUserGameServiceHistory set startDt = Null, endDt = Null , limitTime=@limitTime * 2 , expireDt=Dateadd(dd, 7, @startDt )  where transactionId=@transactionId
					END

			END 
			ELSE
			BEGIN

				IF @limitTime=0   --??
				BEGIN
					SELECT @startDt=startDt, @endDt = endDt ,@prevLimitTime = isNull(limitTime,0) ,@expireDt = expireDt From tblUserGameServiceHistory with(nolock) where transactionId=@prevTransactionId	
					IF @endDt is null
					BEGIN
						SET @endDt = '2005-03-31 00:00:00'
					END
			
					UPDATE tblUserGameServiceHistory set startDt = @endDt  , endDt=Dateadd(dd, @productPeriod * 2 ,  @endDt) , limitTime=@prevLimitTime , expireDt=@expireDt where transactionId=@transactionId
				END				
				ELSE 

				BEGIN
					SELECT @startDt=startDt, @endDt = endDt ,@prevLimitTime = isNull(limitTime,0) ,@expireDt = expireDt From tblUserGameServiceHistory with(nolock) where transactionId=@prevTransactionId	
	
					IF @expireDt  is null 
					BEGIN
						set @expireDt = '2005-03-31 00:00:00'
						UPDATE  tblUserGameServiceHistory set startDt = @endDt , endDt=@endDt,  limitTime= @prevLimitTime + (@limitTime * 2) , expireDt=Dateadd(dd, 7, @expireDt )  where transactionId=@transactionId
					END
					ELSE
					BEGIN
						UPDATE  tblUserGameServiceHistory set startDt = @endDt , endDt=@endDt,  limitTime= @prevLimitTime + (@limitTime * 2) , expireDt=Dateadd(dd, 1, @expireDt )  where transactionId=@transactionId
					END

				END

			END


		END
		ELSE  
		BEGIN
			IF @prevTransactionId =  0   --????
			BEGIN
			
				--IF @periodTypeId IS NULL OR @productPeriod IS null   --?? ??
				IF @limitTime  =  0   --??
				BEGIN		
					Set @endDt =  '2005-03-31 00:00:00'											
					UPDATE tblUserGameServiceHistory set startDt = @endDt  , endDt=DateAdd(dd,@productPeriod, @endDt) , limitTime=0 , expireDt=Null where transactionId=@transactionId
					--UPDATE tblUserGameServiceHistory set startDt =' 2005-03-31 00:00:00'	  , endDt=DateAdd(dd,@productPeriod, '2005-03-31 00:00:00') , limitTime=0 , expireDt=Null where transactionId=@transactionId
				END
				ELSE  
				BEGIN
					Set @endDt =  '2005-03-31 00:00:00'	
					UPDATE  tblUserGameServiceHistory set startDt=Null , endDt=Null, limitTime=@limitTime , expireDt=Dateadd(dd, 7, @endDt)  where transactionId=@transactionId
				END
			END 
			ELSE
			BEGIN


				--IF @periodTypeId IS NULL OR @productPeriod IS null  --?? ??
				IF @limitTime =  0   --??
				BEGIN
					SELECT  @endDt=endDt ,@prevLimitTime=isNull(limitTime,0) ,@expireDt=expireDt From tblUserGameServiceHistory with(nolock) where transactionId=@prevTransactionId	
					IF @endDt is null
					BEGIN
						SET @endDt = '2005-03-31 00:00:00'
					END
					UPDATE tblUserGameServiceHistory set startDt=@endDt  ,endDt=Dateadd(dd, @productPeriod ,  @endDt) ,limitTime= @prevLimitTime ,  expireDt=@expireDt  where transactionId=@transactionId
				END		

				ELSE  
				BEGIN
					SELECT @startDt=startDt, @endDt=endDt ,@prevLimitTime=isNull(limitTime,0) ,@expireDt=expireDt From tblUserGameServiceHistory with(nolock) where transactionId=@prevTransactionId	
					IF @expireDt  is null 
					begin
						set @expireDt = '2005-03-31 00:00:00'
					end
					UPDATE  tblUserGameServiceHistory set startDt=@startDt  ,endDt=@endDt ,limitTime= @prevLimitTime + @limitTime  , expireDt=Dateadd(dd, 1, @expireDt)  where transactionId=@transactionId
				END


	
			END


		END

	END


		SET  @prevTransactionId = @transactionId 
		SET  @limitTime =0	

	FETCH NEXT FROM upCursor  INTO  @productPeriod ,@periodTypeId,  @limitTime,  @transactionId, @registDt
END
		
	SELECT @limitTime = isNull(limitTime,0) ,  @endDt = endDt , @expireDt=expireDt  From tblUserGameServiceHistory with(nolock) where transactionId=@prevTransactionId	
	--IF EXISTS(SELECT   * from tblTransaction  t with(nolock)  join tblOrder o with(nolock) on o.transactionId=t.transactionId join tblProduct p with(nolock) on p.productId=o.productId	where o.productId <> 1021 and peerTransactionId IS NULL AND t.userNumber=@userNumber and productPeriod is not null and t.registDt >'2005-03-04 00:00:00'  )
	IF @endDt  IS NOT NULL
	BEGIN
		SET @startDt = '2005-03-31 00:00:00'
		UPDATE tblUserGameService SET startDt=@startDt  , endDt=@endDt, limitTime=@limitTime ,  expireDt=@expireDt  where userNumber=@userNumber		
	END
	ELSE
	BEGIN
		SET @startDt = null
		SET @endDt = null
		IF @limitTime IS NULL OR @limitTime = NULL
		   SET @limitTime =0
		UPDATE tblUserGameService SET startDt=@startDt  , endDt=@endDt, limitTime=@limitTime ,  expireDt=@expireDt  where userNumber=@userNumber		
	END

CLOSE upCursor
DEALLOCATE upCursor
GO
/****** Object:  View [dbo].[Productname_view]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Productname_view]
AS
SELECT     dbo.tblChongphan.chongphanName, dbo.tblProduct.productName, COUNT(dbo.tblProduct.productName) AS TOTAL, dbo.tblTransaction.registDt
FROM         dbo.tblPpCardUserInfoMapping INNER JOIN
                      dbo.tblPpCard ON dbo.tblPpCardUserInfoMapping.ppCardId = dbo.tblPpCard.ppCardId INNER JOIN
                      dbo.tblUser ON dbo.tblPpCardUserInfoMapping.userNumber = dbo.tblUser.userNumber INNER JOIN
                      dbo.tblPpCardGroup ON dbo.tblPpCard.ppCardGroupId = dbo.tblPpCardGroup.ppCardGroupId INNER JOIN
                      dbo.tblChongphan ON dbo.tblPpCardGroup.chongphanId = dbo.tblChongphan.chongphanId INNER JOIN
                      dbo.tblProduct ON dbo.tblPpCardGroup.productId = dbo.tblProduct.productId INNER JOIN
                      dbo.tblTransaction ON dbo.tblPpCardUserInfoMapping.transactionId = dbo.tblTransaction.transactionId
GROUP BY dbo.tblChongphan.chongphanName, dbo.tblProduct.productName, dbo.tblTransaction.registDt
GO
/****** Object:  StoredProcedure [dbo].[procUserSalesDetailForUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procUserSalesDetailForUser    Script Date: 23/1/2546 11:40:28 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procUserSalesDetailForUser
	Creation Date		:	2002-07-05
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	??? ?? ?? ??
	
******************************Optional Item******************************
	Input Parameters	:	
					@transactionId			AS	INT
					@transactionTypeId		AS	TINYINT			
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUserSalesDetailForUser]
	@transactionId			AS	INT
,	@transactionTypeId		AS	TINYINT
AS
DECLARE	@productId		AS	INT
DECLARE	@startDt		AS	DATETIME
DECLARE	@endDt		AS	DATETIME
IF(@transactionTypeId = 1) 		--??
	BEGIN
		SELECT descript FROM tblCodeChargeType WITH (NOLOCK) WHERE chargeTypeId = (SELECT chargeTypeId FROM tblCharge WHERE transactionId = @transactionId)
	END
ELSE IF(@transactionTypeId = 2)		--??
	BEGIN
		SELECT @productId = productId FROM tblOrder WITH (NOLOCK) WHERE transactionId = @transactionId
		IF(@productId = 100)		--????
			BEGIN
				SELECT @productId , contentName , unitPrice , quantity , point FROM tblOrderPPVDetail WITH (NOLOCK) WHERE transactionId = @transactionId
			END
		ELSE				--????
			BEGIN
				SELECT @startDt = startDt , @endDt = endDt FROM tblUserGameServiceHistory WITH (NOLOCK) WHERE transactionId = @transactionId
				SELECT @productId , productName , @startDt , @endDt FROM tblProduct WITH (NOLOCK) WHERE productId = @productId
			END
	END
ELSE IF(@transactionTypeId IN (5, 6))		--?? ?? ??
	BEGIN
		SELECT peerTransactionId FROM tblTransaction WITH (NOLOCK) WHERE transactionId = @transactionId
	END
ELSE IF(@transactionTypeId = 8)		--??
	BEGIN
		SELECT bankName + ' refund request complete.' FROM tblRefund WITH (NOLOCK) WHERE transactionId = @transactionId
				--'?? ?? ?? ?????.'
	END
GO
/****** Object:  StoredProcedure [dbo].[procUserSalesDetail]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUserSalesDetail    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUserSalesDetail]
@transactionId		as	int
as
DECLARE 	@chargeTransactionId		as		int
DECLARE	@chargeTypeId 		as		tinyint
SELECT 
	@chargeTransactionId = chargeTransactionId 
FROM 
	tblOrder 
WHERE 
	transactionId = @transactionId
SELECT 
	@chargeTypeId = chargeTypeId 
FROM 
	tblCharge 
WHERE 
	transactionId = @chargeTransactionId
SELECT 
	t.transactionId , ctt.transactionTypeId, ctt.descript, 
	ui.userId, c.cpName, t.cashAmount, 
	gs.gameServiceName ,p.productName,
	t.registDt, t.peerTransactionId, ugsh.startDt
FROM 
	tblTransaction t with (nolock) , 
	tblUserInfo ui with (nolock), 
	tblCodeTransactionType ctt with (nolock), 
	tblCp c with (nolock), 
	tblOrder o with (nolock),
	tblUserGameServiceHistory ugsh with (nolock),
	tblGameService gs with (nolock),
	tblProduct p with (nolock)
WHERE 
	t.transactionTypeId = ctt.transactionTypeId
	AND t.userNumber = ui.userNumber
	AND t.cpId = c.cpId
	AND t.transactionId = ugsh.transactionId
	AND t.transactionId = o.transactionId
	AND o.productId = p.productId
	AND ugsh.transactionId = o.transactionId
	AND gs.gameServiceId = ugsh.gameServiceId
	AND ctt.transactionTypeId in (2)
ORDER BY t.registDt desc
GO
/****** Object:  StoredProcedure [dbo].[procUserNeeds]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUserNeeds    Script Date: 23/1/2546 11:40:28 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	
	
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUserNeeds]
	@userNumber		AS	INT
,	@cashBalance		AS	INT				OUTPUT
,	@userId		AS	nvarchar(32)			OUTPUT
,	@userCpId		AS	INT				OUTPUT
AS
SELECT @cashBalance = cashBalance ,  @userId = userId , @userCpId = cpId FROM tblUserInfo WHERE userNumber = @userNumber AND userTypeId <> 9
GO
/****** Object:  StoredProcedure [dbo].[procUserNeed]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUserNeed    Script Date: 23/1/2546 11:40:28 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	
	
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUserNeed]
	@userNumber		AS	INT
,	@cashBalance		AS	INT				OUTPUT
,	@userId		AS	nvarchar(32)			OUTPUT
AS
SELECT @cashBalance = cashBalance ,  @userId = userId FROM tblUserInfo WHERE userNumber = @userNumber
GO
/****** Object:  StoredProcedure [dbo].[procInsertUserHistory]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertUserHistory    Script Date: 23/1/2546 11:40:27 ******/
CREATE PROCEDURE [dbo].[procInsertUserHistory]
	@userNumber as int
 AS
	INSERT INTO 
		tblUserInfoHistory (userNumber, userId, userPwd,userKey, cpId, userSurName, MI , userFirstName, userTypeId, userStatusId, gameServiceId, ssno, sex,
		birthday, isSolar, email, zipcode, nation, address, phoneNumber, passwordCheckQuestionTypeId, 
		passwordCheckAnswer, cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply)
	SELECT 
		userNumber, userId, userPwd,userKey, cpId, userSurName, MI, userFirstName, userTypeId, userStatusId, gameServiceId, ssno, sex,
		birthday, isSolar,	email, zipcode, nation, address, phoneNumber, passwordCheckQuestionTypeId, 
		passwordCheckAnswer, cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply 
	FROM tblUserInfo with (nolock)
	WHERE userNumber = @userNumber
GO
/****** Object:  StoredProcedure [dbo].[procInsertUserGmaeServiceNewUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE proc [dbo].[procInsertUserGmaeServiceNewUser]
		@userId				nvarchar(40)
,		@DayAndMinute		nchar(2)			--ex)Day - dd, Minute - mm
,		@addInt				int
		
AS
declare @userNumber					int
declare @gameServiceId			smallint
declare @startDt						smalldatetime
declare	@endDt							smalldatetime
declare @limitTime					int
declare	@usedLimitTime			int
declare	@applyStartTime			nchar(4)
declare	@applyEndTime				nchar(4)
declare	@playableMinutes		smallint
declare	@usedPlayableMinutes	smallint
declare	@expireDt						smalldatetime
declare	@registDt						datetime

SELECT @userNumber=userNumber FROM tblUserInfo where userId=@userId
IF @userNumber is null 
BEGIN
	return
END


IF UPPER(@DayAndMinute) = 'D' OR UPPER(@DayAndMinute) = 'DD' 
BEGIN
	SELECT @startDt = GETDATE(), @endDt = Dateadd(dd, @addInt, getdate()) , @limitTime = 0	
END
IF UPPER(@DayAndMinute) = 'M' OR UPPER(@DayAndMinute) = 'MM'
BEGIN
	SELECT @startDt = null, @endDt = null , @limitTime = @addInt
END
select @gameServiceId = 1 , @usedLimitTime=0, @applyStartTime='0000', @applyEndTime='2400', @playableMinutes=0, @usedPlayableMinutes=0, @registDt=GETDATE()
INSERT INTO tblUserGameService( userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, expireDt, registDt)
VALUES( @userNumber, @gameServiceId ,@startDt,@endDt, @limitTime, @usedLimitTime, @applyStartTime, @applyEndTime, @playableMinutes, 
@usedPlayableMinutes, @expireDt, @registDt)
GO
/****** Object:  StoredProcedure [dbo].[procInsertUserDetail]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertUserDetail    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	?? ??
	Input Parameters :	
		@userNumber		as 	int
		@handPhoneNumber 	as	nvarchar(16)
		@jobTypeId		as	smallint
		@getMail		as	bit
		@parentName		as	nvarchar(16)
		@parentSsno		as	nchar(13)
		@parentPhoneNumber	as	nvarchar(16)
			
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
		EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertUserDetail]
	@userNumber		as 	int
,	@handPhoneNumber 	as	nvarchar(16)
,	@jobTypeId		as	smallint
,	@getMail		as	bit
,	@parentName		as	nvarchar(16)
,	@parentSsno		as	nchar(13)
,	@parentPhoneNumber	as	nvarchar(16)
as
	
	INSERT INTO tblUserDetail (userNumber, handphoneNumber, jobTypeId, 
				isSendEmail, parentName, parentSsno, parentPhoneNumber)
	VALUES (@userNumber, @handPhoneNumber, @jobTypeId, @getMail, @parentName, @parentSsno, @parentPhoneNumber)
	IF @@ERROR <> 0
	BEGIN
		RETURN 1
	END
	
		RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[procInsertChongphanGamebang]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertChongphanGamebang    Script Date: 23/1/2546 11:40:26 ******/
/*
??? : ???
??? ??? ???? ??? ????.
*/
CREATE PROCEDURE [dbo].[procInsertChongphanGamebang] 
	@gamebangId			AS		INT
,	@chongphanId			AS		INT
,	@adminNumber			AS		INT
AS
------------------------?? ??------------------------
DECLARE	@insertedId		AS		INT
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
INSERT INTO tblChongphanGamebang VALUES(@chongphanId , @gamebangId , 1)
SET @insertedId = @@IDENTITY
INSERT INTO tblAdminLog 
	VALUES(
		'Registration'
	,	'tblChongphanGamebang'
	,	@adminNumber
	,	'sole agency Gamebang Relationship Registration'
	,	GETDATE()
	)
SET @adminLogId = @@IDENTITY
INSERT INTO tblChongphanGamebangHistory 
	SELECT chongphanGamebangId , chongphanId , gamebangId , apply , GETDATE() , @adminLogId 
	FROM tblChongphanGamebang 
	WHERE chongphanGamebangId = @insertedId
GO
/****** Object:  StoredProcedure [dbo].[procInsertChongphanBank]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertChongphanBank    Script Date: 23/1/2546 11:40:25 ******/
/*
??? : ???
?? : ??? ??? ?? ??? ???? ??
*/
CREATE PROCEDURE [dbo].[procInsertChongphanBank] 
	@chongphanId		AS		INT
,	@bankName		AS		nvarchar(32)
,	@account		AS		nvarchar(32)
,	@returnCode		AS		TINYINT		OUTPUT
AS
INSERT INTO tblChongphanBank VALUES(@chongphanId , @bankName , @account)
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procInsertChongphan]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procInsertChongphan    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procInsertChongphan
	Creation Date		:	2002. 01.24
	Modify by		:	???
	E-Mail by 		:	iBeliveKim@n-cash.net
	Purpose			:	?? ??
	
	Input Parameters :	
				@chongphanName		AS		nvarchar(32)
				@bizNumber			AS		nvarchar(16)				
				@zipCode			as	nchar(6)
				@address			AS		nvarchar(64)
				@tel				AS		nvarchar(32)
				@presidentName		AS		nvarchar(16)
				@commission			AS		FLOAT(53)
				@adminNumber			AS		TINYINT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ?????.
				2: ?? ??? ?????.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblChongphan(S,I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertChongphan]
	@chongphanName		AS		nvarchar(32)
,	@bizNumber			AS		nvarchar(16)	= null			
,	@zipcode			AS		nchar(6) = null
,	@address			AS		nvarchar(64) = null
,	@tel				AS		nvarchar(32) = null
,	@presidentName		AS		nvarchar(16)
,	@commission			AS		NUMERIC(9,2) = null
,	@cpId				AS		INT	
,	@adminNumber			AS		INT
,	@bondDate			AS		smalldatetime
,	@expiryDate			AS		smalldatetime
,	@returnCode			AS		TINYINT	OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@insertedId		AS		INT
DECLARE 	@chongphanId		as		INT
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
IF(NOT EXISTS(SELECT chongphanId FROM tblChongphan WHERE bizNumber = @bizNumber AND apply = 1))			--?? ??? ???? ?? ??
	BEGIN
		--insert? id? ????.
		--EXEC procGetCompanyId 'tblChongphan' , @insertedId OUTPUT		
		INSERT INTO tblChongphan (chongphanName , bizNumber, address, zipcode, phoneNumber, presidentName, commission, bondDate , expiryDate,  apply)
		VALUES(
		--	@insertedId
			@chongphanName
		,	@bizNumber
		,	@address
		,	@zipcode
		,	@tel
		,	@presidentName
		,	@commission
		,	@bondDate
		,	@expiryDate
		,	1
		)
		SET @chongphanId = @@IDENTITY   --??? ??
		--tblAdminLog? ???
		INSERT INTO tblAdminLog 
			VALUES(
				'Registration'
			,	'tblChongphan'
			,	@adminNumber
			,	'sole Distribute Registration'
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY
	
		--tblGamebangHistory? ???.
		INSERT INTO tblChongphanHistory 
			SELECT chongphanId , chongphanName , bizNumber , address , zipcode , phoneNumber , presidentName , commission, bondDate, expiryDate, apply , GETDATE() , @adminLogId 
			FROM tblChongphan 
			WHERE chongphanId = @chongphanId
		--EXEC procInsertCpChongphan @cpId , @insertedId  , @adminNumber
		SET @returnCode = 1				--?????.
	END
ELSE
	BEGIN
		SET @returnCode = 2
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertChargeTransferAccount]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procInsertChargeTransferAccount    Script Date: 23/1/2546 11:40:26 ******/
/**********************************************
  ??? : 2002.03.07 (?)
  ??? : ???
  ?    ? : ????? ??? ??
***********************************************/
CREATE PROCEDURE [dbo].[procInsertChargeTransferAccount]
	@transactionId				as	int
,	@chargeTransferAccountTempId		as	int
,	@bankName				as	nvarchar(8)
,	@bankCode				as	nvarchar(4)
,	@accnt_No				as	nvarchar(50)
,	@depositorName			as	nvarchar(10)
,	@depositorSsno				as	nchar(13)
,	@amount				as	int
,	@pay_Date				as	nvarchar(14)
,	@pay_Yn				as	nvarchar(8)
,	@isRepayment				as	bit
 AS
	INSERT INTO tblChargeTransferAccount (transactionId, chargeTransferAccountTempId, bankName, bankCode, accnt_No, depositorName, depositorSsno, amount, pay_Date, pay_Yn, isRepayment, registDt)
	VALUES (@transactionId, @chargeTransferAccountTempId, @bankName, @bankCode, @accnt_No, @depositorName, @depositorSsno, @amount, @pay_Date, @pay_Yn, @isRepayment, getdate())
GO
/****** Object:  StoredProcedure [dbo].[procInsertChargeCardDepositTempBackup]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
@chargeCardDepositTempId   ?? 0 ?? ?? ?? 0 ??? ??? ?? ?? ????
*/
CREATE  PROCEDURE [dbo].[procInsertChargeCardDepositTempBackup]
	@userId				as	varchar(50)
,	@productId				as		int
,	@chargeCardDepositTempId		AS		INT		OUTPUT
AS
declare @amount	 int
declare @userNumber int
	SELECT @userNumber=userNumber FROM tblUserInfo with(nolock) where userId=@userId  and apply=1 and  userStatusId<> 3
	IF @userNumber  is null
	begin
		SET @chargeCardDepositTempId =  0 ---?? ?? ?? ?? ???
		RETURN 
	end

	SELECT @amount= productAmount   from tblProduct with(nolock) where productId=@productId	
	IF @amount  is null and @@rowcount = 0 
	BEGIN
		SET	@chargeCardDepositTempId = -1   ---?? ?? 
		RETURN
	END
	ELSE
	BEGIN
		INSERT tblChargeCardDepositTemp (userNumber, amount , productId, registDt) VALUES( @userNumber , @amount, @productId,getdate() )
		SET	@chargeCardDepositTempId = @@IDENTITY
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertCpChongphan]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertCpChongphan    Script Date: 23/1/2546 11:40:26 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procInsertCpChongphan 
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	CP ???? ??
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertCpChongphan] 
	@cpId 				AS		INT
,	@chongphanId 			AS		INT
,	@adminNumber			AS		INT
AS
------------------------?? ??------------------------
DECLARE	@insertedId		AS		INT
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
INSERT INTO tblCpChongphan VALUES(@cpId , @chongphanId , 1)
SET @insertedId = @@IDENTITY
INSERT INTO tblAdminLog 
	VALUES(
		'Registration'
	,	'tblCpChongphan'
	,	@adminNumber
	,	'CP sole agency Relationship Registration'
	,	GETDATE()
	)
SET @adminLogId = @@IDENTITY
INSERT INTO tblCpChongphanHistory 
	SELECT cpChongphanId , cpId , chongphanId , apply ,  GETDATE() , @adminLogId 
	FROM tblCpChongphan
	WHERE cpChongphanId = @insertedId
GO
/****** Object:  StoredProcedure [dbo].[procInsertGamebangAdmin]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertGamebangAdmin    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procInsertGamebangAdmin
	Creation Date		:	2002. 2. 21
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	??? ??(???)? ??
	Input Parameters :	
		@userId			AS		nvarchar(32)
		@userPwd			AS		nvarchar(32)
		@userName			AS		nvarchar(16)
		@ssno				as	nchar(13)
		@email				AS		nvarchar(32)
	
		@gamebangName		AS		nvarchar(32)
		@zipCode			as	nchar(6)
		@address			AS		nvarchar(64)
		@tel				AS		nvarchar(32)
		@bizNumber			AS		nvarchar(16)
		@presidentName		AS		nvarchar(16)
		@depositAmount		AS		INT
		@chongphanId			AS		INT
	return?:
		@returnCode		AS		TINYINT			
	Return Status:		1: ?? ??
				2: ?? ??? ????.
				3: ?? ??? ?????.
		
	Nothing
	Usage: 			
	Call by		:	
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertGamebangAdmin]
	@userId			AS		nvarchar(32)
,	@gamebangId			AS		INT
,	@userPwd			AS		nvarchar(32)
,	@surName			AS		nvarchar(64)
,	@firstName			AS		nvarchar(64)
,	@ssno				as	nchar(13)
,	@sex				AS		BIT
,	@email				AS		nvarchar(32)
,	@returnCode			AS		TINYINT		OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@userNumber				AS		INT
DECLARE	@procInsertGamebangReturnCode	AS		TINYINT
DECLARE	@returnGamebangId			AS		INT
------------------------?? ???--------------------
--set @userId= 'PC@' + @userId
IF(EXISTS(SELECT userNumber FROM tblUserInfo WHERE userId = @userId AND userTypeId = 9)) 
	BEGIN
		SET @returnCode = 2	
		RETURN
	END
ELSE 
	BEGIN
		INSERT INTO tblUser
			VALUES(
				@userId
			,	@userPwd
			, 	@gamebangId
			, 	9			--userTypeId	9:??????
			, 	1			--userStatusId	1:?? ???	
			, 	1
			, 	1			--apply
			) 
		
		SET @userNumber = @@IDENTITY
	INSERT INTO 
		tblUserInfo (userNumber, userId, userPwd, cpId, userTypeId, userSurName, userFirstName, gameServiceId, ssno, 
		sex, birthday, isSolar, email, zipcode, nation, address, phoneNumber, 
		passwordCheckQuestionTypeId, passwordCheckAnswer , MI)
	VALUES
		(@userNumber				,			-- ??? ??
		@userId				,			-- ID
		@userPwd				,			-- password
		@gamebangId				,			-- cpId
		9					,			-- userTypeId (9:??????)
		@surName				,			-- userName(?)
		@firstName				,			-- userName(??)
		1					,			-- ?? gameServiceId
		@ssno					,			-- ??????
		@sex					,			-- ??
		''					,			-- ????
		1					,			-- ? / ?
		@email					,			-- E-mail
		''					,			-- ????
		''					,			-- ?
		''					,			-- ????
		''					,			-- ????
		''					,			-- ???? ?? ??
		''					,			-- ???? ?? ??
		'G'
		)
		INSERT INTO tblUserInfoHistory 
			(userNumber, userId, userPwd, cpId, userSurName, userFirstName, userTypeId, userStatusId, gameServiceId, ssno, sex,
			birthday, isSolar, email, zipcode, nation, address, phoneNumber, passwordCheckQuestionTypeId, 
			passwordCheckAnswer, cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply)
		SELECT 
			userNumber, userId, userPwd, cpId, userSurName, userFirstName, userTypeId, userStatusId, gameServiceId, ssno, sex,
			birthday, isSolar,	email, zipcode, nation, address, phoneNumber, passwordCheckQuestionTypeId, 
			passwordCheckAnswer, cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply 
		FROM tblUserInfo with (nolock)
		WHERE userNumber = @userNumber
		
		INSERT INTO tblUserDetail
			VALUES(
				@userNumber 						-- ??? ??
			,	NULL	
			,	NULL
			,	NULL
			,	NULL
			,	NULL
			,	NULL
			,	NULL
			,	NULL
			)				
		SET @returnCode = 1
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertBlankUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertBlankUser    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procInsertFreeUser
	Creation Date		:	2002. 4. 1
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	?? ??
	Input Parameters :	
		@userId				as	nvarchar(32)		
		@password				as	nvarchar(32)		
		@msg					as	nvarchar(255)
			
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
		EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertBlankUser]
	@userId				as	nvarchar(32)		
,	@password				as	nvarchar(32)
,	@userTypeId				as	tinyint
,	@msg					as	nvarchar(255)		OUTPUT
as
	DECLARE @userNumber	as	int
	SELECT userId
	FROM tblUserInfo with (nolock)
	WHERE userId = @userId AND userStatusId <> 3
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg ='overlapping ID.' --'??? ??????.'
		RETURN 1
	END
	SELECT rejectWord
	FROM tblRejectWord with (nolock)
	WHERE rejectWord = @userId
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg = 'unusable ID.' --'??? ? ?? ??????.'
		RETURN 1
	END
	INSERT INTO 
		tblUser (userId, userPwd, cpId, gameServiceId)
	VALUES
		(@userId, @password, 1, 1) 
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:001' -- '????? ?? ???. ErrorCode:001'
		RETURN 1
	END
	SET @userNumber = @@IDENTITY
	INSERT INTO 
		tblUserInfo (userNumber, userId, userPwd, cpId, userSurName, userTypeId, gameServiceId, ssno, 
		birthday, isSolar, email, zipcode, address, --addressDetail, 
		phoneNumber, passwordCheckQuestionTypeId, passwordCheckAnswer)
	VALUES
		(@userNumber				,			-- ??? ??
		@userId				,			-- ID
		@password				,			-- password
		1					,			-- cpId
		'concerned company',	--'????'				,			-- userName
		@userTypeId				,			-- userTypeId
		1					,			-- ?? gameServiceId
		'1111112222222'			,			-- ??????
		'2002-03-01'				,			-- ????
		1					,			-- ? / ?
		'test@test.com'				,			-- E-mail
		'111222'				,			-- ????
		'17 Haengdang-Dong, Sungdong-Gu, Seoul',	--'????? ??? ???'		,			-- ????
--		'????'				,			-- ????
		'02-111-2222'				,			-- ????
		1					,			-- ???? ?? ??
		'aaa '								-- ???? ?? ??
		)
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:002' -- '????? ?? ???. ErrorCode:002'
		RETURN 1
	END
	INSERT INTO 
		tblUserInfoHistory (userNumber, userId, userPwd, cpId, userSurName, userTypeId, userStatusId, gameServiceId, ssno, birthday, 
			isSolar, email, zipcode, address, --addressDetail, 
		phoneNumber, passwordCheckQuestionTypeId, 
		passwordCheckAnswer, cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply)
	SELECT 
		userNumber, userId, userPwd, cpId, userSurName, userTypeId, userStatusId, gameServiceId, ssno, birthday, isSolar, 
		email, zipcode, address, --addressDetail, 
		phoneNumber, passwordCheckQuestionTypeId, 
		passwordCheckAnswer, cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply 
	FROM tblUserInfo with (nolock)
	WHERE userNumber = @userNumber
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:003' -- '????? ?? ???. ErrorCode:003'
		RETURN 1
	END
	INSERT INTO tblUserDetail (userNumber)
	VALUES (@userNumber)
GO
/****** Object:  StoredProcedure [dbo].[procInsertBankDepositConfirmNUpdate]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertBankDepositConfirmNUpdate    Script Date: 23/1/2546 11:40:27 ******/
/*
???
???? ??? ?? ??? ??? ?? ??
*/
CREATE PROCEDURE [dbo].[procInsertBankDepositConfirmNUpdate]
	@gamebangId				as		int
,	@transactionId				as		int
,	@startDate				as		smalldatetime
,	@depositAmount			as		int
,	@depositer				as		nvarchar(50)
,	@bankName				as		nvarchar(50)
,	@depositDate				as		smalldatetime
,	@confirmType				AS		TINYINT
,	@misPrice				AS		INT
,	@memo					AS		nvarchar(500)
,	@adminNumber				AS		INT
,	@returnCode				AS		TINYINT		OUTPUT
AS
DECLARE 	@insertedId 		AS	INT
DECLARE	@adminLogId		AS	INT
DECLARE	@productId		AS	INT
IF(EXISTS(SELECT * FROM tblBankDepositConfirm WHERE transactionId = @transactionId))	--?? transactionId? tblBankDepositConfirm ? ???
	BEGIN
		SET @returnCode = 3
		RETURN
	END
ELSE IF(EXISTS(SELECT * FROM tblTransaction WHERE transactionId = @transactionId AND transactionTypeId = 1))		--?? transactionId? tblTransaction? ???
	BEGIN
		SELECT @productId = O.productId FROM tblCharge C JOIN tblOrder O ON C.transactionId = O.chargeTransactionId WHERE C.transactionId = @transactionId
		IF(@productId IS NULL)
			BEGIN
				SET @returnCode = 3
				RETURN
			END
		INSERT INTO tblBankDepositConfirm 
		VALUES(
			@gamebangId
		,	@productId
		,	@transactionId
		,	@startDate
		,	@depositAmount
		,	@depositer
		,	@bankName
		,	@depositDate
		,	@confirmType
		,	@misPrice
		,	@memo	
		,	GETDATE()
		)
		
		SET @insertedId = @@IDENTITY
		
		--tblAdminLog? ???
		INSERT INTO tblAdminLog 
			VALUES(
				'Amend'
			,	'tblBankDepositConfirm'
			,	@adminNumber
			,	@memo
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY
		
		INSERT INTO tblBankDepositConfirmHistory 
			SELECT bankDepositConfirmId, gamebangId, productId,transactionId , startDate, depositAmount, depositer, bankName, depositDate, confirmType, misPrice , memo , registDt , @adminLogId
			FROM tblBankDepositConfirm 
			WHERE bankDepositConfirmId = @insertedId
		
		SET @returnCode = 1
		RETURN
	END
ELSE
	BEGIN
		SET @returnCode = 2
		RETURN
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertBankDepositConfirm]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertBankDepositConfirm    Script Date: 23/1/2546 11:40:25 ******/
/*
???
??? ?? ?? INSERT
*/
CREATE PROCEDURE [dbo].[procInsertBankDepositConfirm] 
	@gamebangId		as	int
,	@productId		as	int
,	@transactionId		as	int				=		NULL
,	@startDate		as	smalldatetime			=		NULL
,	@depositAmount	as	int
,	@depositer		as	nvarchar(50)
,	@bankName		as	nvarchar(50)
,	@depositDate		as	smalldatetime
,	@returnCode		as	tinyint			OUTPUT
AS
DECLARE @insertedId 	AS	INT
INSERT INTO tblBankDepositConfirm 
VALUES(
	@gamebangId
,	@productId
,	@transactionId
,	@startDate
,	@depositAmount
,	@depositer
,	@bankName
,	@depositDate
,	0
,	0
,	NULL
,	GETDATE()
)
SET @insertedId = @@IDENTITY
INSERT INTO tblBankDepositConfirmHistory 
	SELECT bankDepositConfirmId, gamebangId, productId , transactionId , startDate, depositAmount, depositer, bankName, depositDate, confirmType, misPrice , memo , registDt ,NULL
	FROM tblBankDepositConfirm 
	WHERE bankDepositConfirmId = @insertedId
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procInsertAdminLog]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertAdminLog    Script Date: 23/1/2546 11:40:25 ******/
/*
	Creation Date		:	2002. 2. 08.
	Written by		:	? ??
	E-Mail by 		:	windist@n-cash.net
*/
CREATE PROCEDURE [dbo].[procInsertAdminLog]
	@adminActionType	as	nchar(4)
,	@adminActionTable	as	nvarchar(100)
,	@adminNumber		as	int
,	@memo			as	nvarchar(200)
,	@adminLogId		as	int	output
as
INSERT tblAdminLog(adminActionType,adminActionTable,adminNumber,memo)
VALUES(@adminActionType,@adminActionTable,@adminNumber,@memo)
SET @adminLogId = @@IDENTITY
GO
/****** Object:  StoredProcedure [dbo].[procInsertAdminGrade]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procInsertAdminGrade]
	@adminGroupTypeId	as		int
,	@adminGradeTypeName	as		varchar(50)	
,	@adminNumber		as		int
,	@memo			as		varchar(100)
,	@result			as		int 	output
AS
	
DECLARE @registDt 		as		datetime
DECLARE @adminGradeTypeId 	as		int

SET @registDt = GETDATE()
SET @result  = 0

INSERT tblAdminLog (adminActionType, adminActionTable, adminNumber, memo, registDt)
VALUES ('??','tblCodeAdminGradeType',@adminNumber, @memo,@registDt)

SET @result = @result + @@ERROR

IF @result <> 0
BEGIN
	RETURN	
END

INSERT tblCodeAdminGradeType VALUES(@adminGradeTypeName, @registDt, 1)
SET @result = @result + @@ERROR

IF @result <> 0
BEGIN
	RETURN	
END
                  
SET @adminGradeTypeId = IDENT_CURRENT('tblCodeAdminGradeType')

INSERT tblCodeAdminType VALUES(@adminGroupTypeId, @adminGradeTypeId, @registDt)
SET @result = @result + @@ERROR

IF @result <> 0
BEGIN
	RETURN	
END
GO
/****** Object:  StoredProcedure [dbo].[procGetUserTypeId]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserTypeId    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procGetUserTypeId
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserTypeId]
@userType as tinyint
as
SELECT 
	userTypeId, descript, isFreeId, registDt, apply
FROM tblCodeUserType with (nolock)
WHERE userTypeId = @userType
GO
/****** Object:  StoredProcedure [dbo].[procGetUserTypeCodeList]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserTypeCodeList    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserTypeCodeList]
as
SELECT 
	cut.userTypeId, cut.descript, cut.isFreeId, cut.registDt, cut.apply
FROM 
	tblCodeUserType cut with(nolock)
GO
/****** Object:  StoredProcedure [dbo].[procGetUserType]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetUserType    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserType]
as
DECLARE 	@userTypeId 		as 		tinyint
-- ?? ??? ????.
SELECT 
	userTypeId, descript, @userTypeId
FROM 
	tblCodeUserType with (nolock)
WHERE
	apply = 1
GO
/****** Object:  StoredProcedure [dbo].[procGetUserTopupTransaction]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procGetUserTopupTransaction]
	@userId	AS	varchar(32)	
AS

DECLARE 
	@userNumber AS INT

SELECT @userNumber = userNumber FROM tblUserInfo WHERE userId = @userId

SELECT T.transactionId, P.productName, ABS(T.cashAmount) AS cashAmount, PC.ppCardSerialNumber, T.registDt
FROM tblTransaction T WITH (NOLOCK) 
JOIN tblUserInfo UI WITH (NOLOCK) ON T.userNumber = UI.userNumber 
JOIN tblPpCardUserInfoMapping PUI with(NOLOCK) ON T.transactionId = PUI.transactionId 
JOIN tblPpCard PC WITH(NOLOCK) ON PUI.ppCardId = PC.ppCardId 
JOIN tblPpCardGroup PCG WITH(NOLOCK) ON PC.ppCardGroupId = PCG.ppCardGroupId 
JOIN tblProduct P WITH(NOLOCK) ON PCG.productId = P.productId 
WHERE T.userNumber not in(select userNumber from tblTestuser with(NOLOCK)) AND T.userNumber = @userNumber
ORDER BY T.transactionId DESC
GO
/****** Object:  StoredProcedure [dbo].[procGetUserTopUpTotalByMonth]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procGetUserTopUpTotalByMonth]

@userId VARCHAR(32),
@month INT,
@year INT,
@totalTopUp INT OUT

AS

DECLARE @userNumber AS INT

SELECT @userNumber = userNumber FROM tblUserInfo WITH (NOLOCK) WHERE userId = @userId

SELECT @totalTopUp = SUM(ABS(T.cashAmount))
FROM tblTransaction T WITH (NOLOCK)
JOIN tblUserInfo UI WITH (NOLOCK) ON T.userNumber = UI.userNumber 
JOIN tblPpCardUserInfoMapping PUI WITH (NOLOCK) ON T.transactionId = PUI.transactionId 
JOIN tblPpCard PC WITH (NOLOCK) ON PUI.ppCardId = PC.ppCardId 
JOIN tblPpCardGroup PCG WITH (NOLOCK) ON PC.ppCardGroupId = PCG.ppCardGroupId 
WHERE T.userNumber NOT IN(SELECT userNumber FROM tblTestuser WITH (NOLOCK)) AND T.userNumber = @userNumber
And MONTH(T.registDt) = @month AND YEAR(T.registDt) = @year
GROUP BY T.userNumber
GO
/****** Object:  StoredProcedure [dbo].[procDupIdCheck]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDupIdCheck    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procDupIdCheck
	Creation Date		:	2002. 02.01
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	??? ?? ??
	
	Input Parameters :	
				@adminId			AS		nvarchar(16)
	Output Parameters:	
				@returnCode			AS		SMALLINT
				
	Return Status:		
				0: ?? ????.
				1: ?? ???? ????.
	Usage: 			
	EXEC procDupIdCheck 'gun26',@returnCode OUTPUT
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S,I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDupIdCheck]
	@adminId		AS		nvarchar(16)
,	@returnCode		AS		BIT	= 0	OUTPUT
AS
IF(EXISTS(SELECT * FROM tblUserInfo WHERE userId = @adminId AND userTypeId = 9))
	SET @returnCode = 1		
ELSE 
	SET @returnCode = 0
GO
/****** Object:  StoredProcedure [dbo].[procDeleteRejectWord]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteRejectWord    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procDeleteRejectWord 
	Creation Date		:	2002. 02.20
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	???? ??
	
	Input Parameters :	
				@rejectWordId		AS		INT
				@descript		AS		nvarchar(50)
				@rejectTypeId		AS		TINYINT
				@adminNumber		AS		INT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ?????.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeleteRejectWord] 
	@rejectWordId			AS		INT
,	@adminNumber			AS		INT
,	@returnCode			AS		TINYINT		OUTPUT
AS
DELETE FROM tblRejectWord
WHERE rejectWordId = @rejectWordId
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procDeleteProduct]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteProduct    Script Date: 23/1/2546 11:40:26 ******/
-- ************************************************************************
-- ?? ?? : 2002. 02.18
-- ?? ?? : ???
-- ??? ?? : O
-- ???? ? : 
-- ?? : ?? ??
-- RESULT ??
-- 0 : 
-- 1 : 
-- 2 : 
-- 3 : 
-- 99 : 
-- ************************************************************************
CREATE PROCEDURE [dbo].[procDeleteProduct] 
@productId 		as	int
,@adminNumber		as	int
--,@memo		as          nvarchar(200)
AS
DECLARE @adminLogId as int
INSERT 
	tblAdminLog (adminActionType, adminActionTable, adminNumber, memo, registDt)
VALUES
	('Delete','tblProduct',@adminNumber, 'Admin Product Delete',getdate())
SET @adminLogId = @@IDENTITY
UPDATE 
	tblProduct 
SET 
	adminLogId = @adminLogId, apply = 0 
WHERE 
	productId = @productId
GO
/****** Object:  StoredProcedure [dbo].[procDeletePpCard]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procDeletePpCard    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procDeletePpCard
	Creation Date		:	2003. 1. 3
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	PPCard? ??
	Input Parameters :	
			
	return?:
		rtnValue 		as		int : ?? ??
	Return Status:		
		Integer
	Usage: 			
		exec procInsertCard 10, '1234123412345678', 1000, 1, 0400, '????', 9982732724, 'KF200204050000001234'
	Call by		:	PP?? ?? ???
				PGCardService.CardManager	
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I), tblChargeCardDeposit(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeletePpCard]
	@ppCardGroupId 		as 	int
,	@rtnValue		as	int output
AS
DECLARE @userCount as int
SET @userCount = 0
SELECT @userCount = count(ppCardUserInfoId) FROM tblPpCardUserInfoMapping PCUM WITH(NOLOCK) JOIN tblPpCard PC WITH(NOLOCK) ON PCUM.ppCardId = PC.ppCardId
WHERE ppCardGroupId = @ppCardGroupId
	IF @userCount > 0 
		-- ???? ??
		SET @rtnValue = 1		
	ELSE
	BEGIN
		UPDATE tblPpCardGroup SET apply = 0 WHERE ppCardGroupId = @ppCardGroupId
		-- ????
		SET @rtnValue = 99
	END
GO
/****** Object:  StoredProcedure [dbo].[procDeleteIpAddrs]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteIpAddrs    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procDeleteIpAddrs
	Creation Date		:	2002. 02.16
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	IP????
	
	Input Parameters :	
				@gamebangId		AS		INT
				@adminNumber		AS		INT
	Output Parameters:	
			
				
	Return Status:		
			
	Usage		:	
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeleteIpAddrs]
	@gamebangId		AS		INT
,	@adminNumber		AS		INT
AS
DECLARE @adminLogId AS INT
--************************************** virtualIp ??*************************************************************************************************************************
	DECLARE cur_deleteVirtualIp CURSOR
	KEYSET
	FOR SELECT V.virtualIpAddrId FROM tblVirtualIpAddr V JOIN tblIpAddr I ON V.ipAddrId = I.ipAddrId WHERE I.gamebangId = @gamebangId AND V.apply = 1
	
	DECLARE @virtualIpAddrId  INT
	
	OPEN cur_deleteVirtualIp
	
	FETCH NEXT FROM cur_deleteVirtualIp INTO @virtualIpAddrId
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			UPDATE tblVirtualIpAddr SET apply = 0 , registDt = getdate() WHERE virtualIpAddrId = @virtualIpAddrId
			INSERT INTO tblAdminLog 
				VALUES(
					'Delete'
				,	'tblVirtualIpAddr'
				,	@adminNumber
				,	'IP delete caused by PC Bang registration cancel'
				,	GETDATE()
				)
			
			SET @adminLogId = @@IDENTITY
			
			INSERT INTO tblVirtualIpAddrHistory
				SELECT virtualIpAddrId , ipAddrId , isRealIp , virtualIpAddr , virtualStartIp , virtualEndIp , registDt , apply , @adminLogId
				FROM tblVirtualIpAddr
				WHERE virtualIpAddrId = @virtualIpAddrId
			
		END
		FETCH NEXT FROM cur_deleteVirtualIp INTO @virtualIpAddrId
	END
	
	CLOSE cur_deleteVirtualIp
	DEALLOCATE cur_deleteVirtualIp
--************************************** virtualIp ?? ?*************************************************************************************************************************
--************************************** realIp ??*************************************************************************************************************************
	DECLARE cur_deleteRealIp CURSOR
	KEYSET
	FOR SELECT ipAddrId FROM tblIpAddr WHERE gamebangId = @gamebangId AND apply = 1
	
	DECLARE @ipAddrId  INT
	
	OPEN cur_deleteRealIp
	
	FETCH NEXT FROM cur_deleteRealIp INTO @ipAddrId
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			UPDATE tblIpAddr SET apply = 0 , registDt = getdate() WHERE ipAddrId = @ipAddrId
			INSERT INTO tblAdminLog 
				VALUES(
					'Delete'
				,	'tblVirtualIpAddr'
				,	@adminNumber
				,	'IP delete caused by PC Bang registration cancel'
				,	GETDATE()
				)
			
			SET @adminLogId = @@IDENTITY
			
			INSERT INTO tblIpAddrHistory
				SELECT ipAddrId , gamebangId ,  ipAddr , startIp , endIp , registDt , apply , @adminLogId
				FROM tblIpAddr
				WHERE ipAddrId = @ipAddrId
			
		END
		FETCH NEXT FROM cur_deleteRealIp INTO @ipAddrId
	END
	
	CLOSE cur_deleteRealIp
	DEALLOCATE cur_deleteRealIp
--************************************** realIp ?? ?*************************************************************************************************************************
GO
/****** Object:  StoredProcedure [dbo].[procDeleteIpAddr]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteIpAddr    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procDeleteIpAddr
	Creation Date		:	2002. 02.16
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	IP??
	
	Input Parameters :	
				@ipAddrId			AS		INT
				@virtualIpAddrId			AS		INT
				@isRealIp			AS		BIT
				@memo				AS		nvarchar(200)
				@adminNumber			AS		INT
	Output Parameters:	
				@returnCode			AS		INT	OUTPUT
				
	Return Status:		
				1 : ?? ??.
				2 : virtualIp ??? realIp ? ?? ??? ???? ??? virtualIp? ?????.
	Usage		:	
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblIpAddr(S,I) , tblVirtualIpHistory , tblVirtualIp , tblAdminLog
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeleteIpAddr]
	@ipAddrId			AS		INT
,	@virtualIpAddrId			AS		INT
,	@isRealIp			AS		BIT
,	@memo				AS		nvarchar(200)
,	@adminNumber			AS		INT
,	@returnCode			AS		INT		OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@adminLogId			AS		INT
------------------------?? ?? ?-------------------
IF(@isRealIp = '1')
	BEGIN
		--real Ip ??
		UPDATE tblIpAddr SET apply = 0 WHERE ipAddrId = @ipAddrId
		INSERT INTO tblAdminLog 
			VALUES(
				'Delete'
			,	'tblIpAddr'
			,	@adminNumber
			,	@memo
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY
		INSERT INTO tblIpAddrHistory
			SELECT ipAddrId , gamebangId ,  ipAddr , startIp , endIp , registDt , apply , @adminLogId
			FROM tblIpAddr
			WHERE ipAddrId = @ipAddrId
		--virtual Ip ??
		UPDATE tblVirtualIpAddr SET apply = 0 WHERE ipAddrId = @ipAddrId
		INSERT INTO tblAdminLog 
			VALUES(
				'Delete'
			,	'tblVirtualIpAddr'
			,	@adminNumber
			,	@memo
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY
		
		INSERT INTO tblVirtualIpAddrHistory
			SELECT virtualIpAddrId , ipAddrId , isRealIp , virtualIpAddr , virtualStartIp , virtualEndIp , registDt , apply , @adminLogId
			FROM tblVirtualIpAddr
			WHERE ipAddrId = @ipAddrId AND isRealIp = 1
	END
ELSE
	BEGIN
		IF((SELECT COUNT(*) FROM tblVirtualIpAddr WHERE ipAddrId = @ipAddrId AND isRealIp = 0 AND apply = 1) <= 1)
			BEGIN
				--real Ip ??
				UPDATE tblIpAddr SET apply = 0 WHERE ipAddrId = @ipAddrId
				INSERT INTO tblAdminLog 
					VALUES(
						'Delete'
					,	'tblIpAddr'
					,	@adminNumber
					,	@memo
					,	GETDATE()
					)
				
				SET @adminLogId = @@IDENTITY
		
				INSERT INTO tblIpAddrHistory
					SELECT ipAddrId ,gamebangId ,  ipAddr , startIp , endIp , registDt , apply , @adminLogId
					FROM tblIpAddr
					WHERE ipAddrId = @ipAddrId
			END
		--virtual Ip ??
		UPDATE tblVirtualIpAddr SET apply = 0 WHERE virtualIpAddrId = @virtualIpAddrId
		INSERT INTO tblAdminLog 
			VALUES(
				'Delete'
			,	'tblVirtualIpAddr'
			,	@adminNumber
			,	@memo
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY
		
		INSERT INTO tblVirtualIpAddrHistory
			SELECT virtualIpAddrId , ipAddrId , isRealIp , virtualIpAddr , virtualStartIp , virtualEndIp , registDt , apply , @adminLogId
			FROM tblVirtualIpAddr
			WHERE virtualIpAddrId = @virtualIpAddrId
	END
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procGetPpcardInfoByItemBill]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Stored Procedure	:	procGetPpcardInfo
	Creation Date		:	2002. 12. 26
	Written by		:	???
	E-Mail by 		:	jjhl@n-cash.net
	Purpose			:	ppcard ?? ????
	Input Parameters :	
		@ppCardSerialNumber			as	varchar(20)		
		@ppcardId				as	int		OUTPUT
		@howManyPeople			as	int		OUTPUT
			
	return?:
		@msg					as	varchar(64)	OUTPUT
	
*/
CREATE PROCEDURE [dbo].[procGetPpcardInfoByItemBill]
	@gameServiceId			as	smallint
,	@userId				as	nvarchar(32)	
,	@ppCardSerialNumber			as	nvarchar(12)
,	@pinCode				as	nvarchar(50)
,	@ppcardId				as	int		OUTPUT
--,	@howManyPeople			as	int		OUTPUT
,	@productId				as	int		OUTPUT
,	@productAmount			as	int		OUTPUT
,	@prouductTypeId			as	TINYINT	OUTPUT
,	@returnCode				as	int		OUTPUT
as

DECLARE	@userNumber			as	int
DECLARE	@validStartDt			as	smalldatetime
DECLARE	@validEndDt			as	smalldatetime
DECLARE	@now				as	smalldatetime
DECLARE	@lastDt				as	smalldatetime
DECLARE	@rowCount			as	int
DECLARE 	@dbPINCode			as	nvarchar(40)
DECLARE 	@productPeriod			as 	int	
DECLARE 	@failStartDt			as 	smalldatetime
DECLARE 	@failEndDt			as 	smalldatetime

	SELECT @userNumber = userNumber FROM tblUserInfo WITH (NOLOCK) WHERE userId=@userId and gameServiceId = @gameServiceId
	IF @@ROWCOUNT = 0
	BEGIN
		SET @returnCode = -6	 	
		RETURN
	END	


	SET @returnCode = 1
	SET @now = getdate()
	--SET @lastDt = DATEADD (dd , -1, @now) 
	
	--SerialNumber  ??
	SELECT @ppcardId = pc.ppCardId,  @validStartDt = pcg.validStartDt, @validEndDt = pcg.validEndDt
			, @productId = pcg.productId, @productAmount = p.productAmount ,@dbPINCode=pc.PINCode
			, @productPeriod = isnull( p.productPeriod, 0) , @prouductTypeId = productTypeId 
	FROM tblPpCard pc WITH(NOLOCK)
		JOIN tblPpCardGroup pcg with(nolock) on  pc.ppCardGroupId = pcg.ppCardGroupId  
		JOIN tblProduct p WITH(NOLOCK) ON pcg.productId = p.productId 
	WHERE pc.ppCardSerialNumber = @ppCardSerialNumber   AND pcg.apply = 1

	--SerialNumber ???? ? ??
	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt) VALUES (@userNumber, @ppCardSerialNumber, getdate()) 			
		SET @returnCode = -1	 	
		RETURN
	END	
	
	IF @dbPINCode <> @pinCode 
	BEGIN
		INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt) VALUES (@userNumber, @ppCardSerialNumber, getdate()) 			
		SET @returnCode = -2 	--pinCode ???
		RETURN 
	END	

	SELECT ppCardId FROM tblPpCardUserInfoMapping WHERE ppCardId = @ppcardId
	IF @@ROWCOUNT > 0
		BEGIN
			INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt)VALUES (@userNumber, @ppCardSerialNumber, getdate()) 	
			SET @returnCode = -3		--????? ppcard 
			RETURN
		END

	--IF (@validEndDt < @now OR @validStartDt > @now) 
	IF (@validEndDt < @now) 
		BEGIN
			INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt)
			VALUES (@userNumber, @ppCardSerialNumber, getdate()) 			
			SET @returnCode = -4		-- ???? ?? ??
			RETURN
		END

	--SELECT num FROM tblPpCardFailList WHERE userNumber = @userNumber  AND registDt BETWEEN @lastDt AND @now
	--SET @failStartDt= left(Convert(varchar(10), getdate(), 21),10) + ' 00:00:00'
	--SET @failEndDt= left(Convert(varchar(10), getdate(), 21),10) + ' 00:00:00'
	--SET @failStartDt= dateadd(dd, -1, getdate())  --1day
	SET @failStartDt= dateadd(mi, -30, getdate())  --30minutes
	SELECT num FROM tblPpCardFailList WHERE userNumber = @userNumber  AND registDt BETWEEN @failStartDt AND @now
	IF @@ROWCOUNT > 4 
	BEGIN		
		SET @returnCode = -5		
		RETURN		
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertRejectWord]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertRejectWord    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procInsertRejectWord 
	Creation Date		:	2002. 02.20
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	???? ??
	
	Input Parameters :	
				@rejectWord		AS		nvarchar(40)
				@descript		AS		nvarchar(50)
				@rejectTypeId		AS		TINYINT
				@adminNumber		AS		INT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ?????.
				2: ?? ??? ????? ??.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertRejectWord] 
	@rejectWord			AS		nvarchar(40)
,	@descript			AS		nvarchar(50)
,	@rejectWordTypeId		AS		TINYINT
,	@adminNumber			AS		INT
,	@returnCode			AS		TINYINT		OUTPUT
AS
IF(EXISTS(SELECT * FROM tblRejectWord WHERE rejectWord = @rejectWord AND rejectWordTypeId = @rejectWordTypeId))
	BEGIN
		SET @returnCode = 2		--?? ??? ?????.
	END
ELSE
	BEGIN
		INSERT INTO tblRejectWord 
			VALUES(@rejectWord 
			, @descript 
			, @rejectWordTypeId 
			, GETDATE() 
			, @adminNumber)
		SET @returnCode = 1		--????? ??
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertRefundRequest]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertRefundRequest    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procInsertRefundRequest 
	Creation Date		:	2002. 04.08
	Written by		:	? ??
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	?? ?? ??
	
	Input Parameters :	
				@userNumber			AS		INT
				@requestCashAmount		AS		INT
				@bankName			AS		nvarchar(20)
				@accountNumber		AS		nvarchar(32)
				@depositor			AS		nvarchar(50)
				@memo				AS		nvarchar(100)	
	
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ?????.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertRefundRequest] 
	@userNumber			AS		INT
,	@requestCashAmount		AS		INT
,	@bankName			AS		nvarchar(20)
,	@accountNumber		AS		nvarchar(32)
,	@depositor			AS		nvarchar(50)
,	@memo				AS		nvarchar(100)
,	@returnCode			AS		TINYINT		OUTPUT
AS
INSERT INTO tblRefundRequest 
	VALUES(
		@userNumber
	,	@requestCashAmount
	,	@bankName
	,	@accountNumber
	,	@depositor
	,	@memo	
	,	1
	,	GETDATE()
	)
SET @returnCode = @@IDENTITY
GO
/****** Object:  StoredProcedure [dbo].[procInsertRealIpAddr]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertRealIpAddr    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procInsertRealIpAddr
	Creation Date		:	2002. 01.26
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	IP??
	
	Input Parameters :	
				@gamebangId			AS		SMALLINT
				@ipAddr			AS		nvarchar(11)
				@startIp			AS		TINYINT
				@endIp				AS		TINYINT
				@adminNumber			AS		INT			
	Output Parameters:	
				@returnCode			AS		INT	OUTPUT
				
	Return Status:		
				0 : ?? ??.
				?? : ?? ?????? ipAddrId
	Usage		:	EXEC procInsertRealIpAddr 1,'211.233.3',115,120,null,1,1,@returnCode	OUTPUT
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblIpAddr(S,I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertRealIpAddr]
	@gamebangId			AS		SMALLINT
,	@ipAddr			AS		nvarchar(11)
,	@startIp			AS		TINYINT
,	@endIp				AS		TINYINT
,	@adminNumber			AS		INT
,	@returnCode			AS		INT		OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@checkIpAddrId		AS		INT
DECLARE	@ipAddrId			AS		INT
DECLARE	@virtualIpAddrId			AS		INT
DECLARE	@adminLogId			AS		INT
------------------------?? ?? ?-------------------
SELECT @checkIpAddrId = ipAddrId FROM tblIpAddr WHERE ipAddr = @ipAddr AND (startIp  <= @endIp AND endIp >= @startIp) AND apply = 1
IF(@checkIpAddrId IS NULL)
	BEGIN
		--tblIpAddr ? insert
		INSERT INTO tblIpAddr
			VALUES(
				@gamebangId
			,	@ipAddr
			,	@startIp
			,	@endIp
			,	GETDATE()
			,	1
			)
		SET @ipAddrId = @@IDENTITY
		INSERT INTO tblAdminLog 
			VALUES(
				'Registration'
			,	'tblIpAddr'
			,	@adminNumber
			,	'REALIP Registration'
			,	GETDATE()
			)
		SET @adminLogId = @@IDENTITY
		INSERT INTO tblIpAddrHistory
			SELECT ipAddrId, gamebangId, ipAddr, startIp, endIp, GETDATE(), apply , @adminLogId 
			FROM tblIpAddr
			WHERE ipAddrId = @ipAddrId
		--tblVirtualIpAddr ? insert
		INSERT INTO tblVirtualIpAddr
			VALUES(
				 @ipAddrId
			,	1
			,	@ipAddr
			,	@startIp
			,	@endIp
			,	GETDATE()
			,	1
			)
		SET @virtualIpAddrId = @@IDENTITY
		INSERT INTO tblAdminLog 
			VALUES(
				'Registration'
			,	'tblVirtualIpAddr'
			,	@adminNumber
			,	'REALIP Registration'
			,	GETDATE()
			)
		SET @adminLogId = @@IDENTITY
		INSERT INTO tblVirtualIpAddrHistory
			SELECT virtualIpAddrId , ipAddrId, isRealIp , virtualIpAddr, virtualStartIp, virtualEndIp, GETDATE(), apply , @adminLogId 
			FROM tblVirtualIpAddr
			WHERE virtualIpAddrId = @virtualIpAddrId
		SET @returnCode = 0
	END
ELSE
	BEGIN
		SET @returnCode = @checkIpAddrId
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertProductForPpcard]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procInsertProductForPpcard    Script Date: 23/1/2546 11:40:26 ******/
CREATE PROCEDURE [dbo].[procInsertProductForPpcard]
-- ************************************************************************
-- ?? ?? : 2001. 10.26
-- ?? ?? : ???
-- ??? ?? : O
-- ???? ? : 
-- ?? : ? CP, IDC, Ncash ? ??? ?? SELECT
-- RESULT ??
-- 0 : ??
-- 1 : ???? ?? ??? ??
-- 2 : ???? ?? ???
-- 3 : ??? ?
-- 99 : ? ? ?? ??
-- ************************************************************************
@productCode 		as	nvarchar(10)
,@productTypeId	as	tinyint
,@productName		as	nvarchar(50)
,@productAmount	as	int
,@ipCount		as	tinyint
,@periodTypeId		as	tinyint
,@productPeriod	as	int
,@limitTime		as	int
,@applyStartTime	as	nchar(4)
,@applyEndTime	as	nchar(4)
,@playableMinutes 	as	smallint
,@adminNumber		as	int
,@apply			as	bit
,@memo		as          nvarchar(200)
,@rtnValue		as	int output
AS
DECLARE @adminLogId as int
INSERT tblAdminLog (adminActionType, adminActionTable, adminNumber, memo, registDt)
VALUES ('Registration','tblProduct',@adminNumber, @memo,getdate())
SET @adminLogId = @@IDENTITY
INSERT tblProduct (productCode, productTypeId, productName, productAmount, ipCount, periodTypeId, productPeriod,limitTime,applyStartTime,
applyEndTime,playableMinutes, registDt, adminLogId, apply)
VALUES (@productCode,@productTypeId,@productName,@productAmount,@ipCount,@periodTypeId,@productPeriod,@limitTime,@applyStartTime,
@applyEndTime,@playableMinutes,getdate(),@adminLogId,@apply)
SET @rtnValue = @@identity
GO
/****** Object:  StoredProcedure [dbo].[procInsertPpCardUserInfoMapping]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procInsertPpCardUserInfoMapping    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procInsertPpCardUserInfoMapping
	Creation Date		:	2003. 01. 04
	Written by		:	???
	E-Mail by 		:	jjhl@n-cash.net
	Purpose			:	InserttblPpCardUserInfoMapping 
	Input Parameters :	
		@ppCardSerialNumber			as	nvarchar(20)		
		@ppcardId				as	int		OUTPUT
		@howManyPeople			as	int		OUTPUT
			
	return?:
		@msg					as	nvarchar(64)	OUTPUT
	
*/
CREATE PROCEDURE [dbo].[procInsertPpCardUserInfoMapping]
	@ppcardId				as	int	
,	@userNumber				as	int		
,	@orderTransactionId			as	int		
,	@returnCode				as	int		OUTPUT
as
	SET @returnCode = 0
	IF  EXISTS(SELECT *   FROM tblPpCardUserInfoMapping where ppCardId=@ppCardId)
	BEGIN
		SET @returnCode = 1
		RETURN
	END
	INSERT INTO tblPpCardUserInfoMapping (ppCardId, userNumber, transactionId)  VALUES (@ppcardId, @userNumber, @orderTransactionId)
	IF @@ERROR <> 0
	BEGIN
		SET @returnCode = 1
	END
	SELECT @returnCode
	RETURN
GO
/****** Object:  StoredProcedure [dbo].[procInsertPpCardGroup]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
ppCard Activation ??
?? ??? ????? ?? ???? ???? 
?????
SUCCESS = 0 MORE INT VALUE
FAIL = 0
*/

CREATE PROCEDURE [dbo].[procInsertPpCardGroup]
	@productId	int
,	@quantity	int
,	@createDt	DATETIME
,	@validStartDt	DATETIME
,	@validEndDt	DATETIME
,	@chongphanId	int
,	@returnCode	int	output
 AS
INSERT INTO tblPpCardGroup
(productId, howManyPeople, quantity, createDt, validStartDt, validEndDt, adminNumber, chongphanId, apply)
VALUES(@productId, 1 , @quantity, @createDt , @validStartDt , @validEndDt , 1 , @chongphanId , 1)
--VALUES(@productId, 1 , @quantity, CONVERT(VARCHAR(10) ,@createDt, 126), CONVERT(VARCHAR(10), @validStartDt) , CONVERT(VARCHAR(10), @validEndDt) , 1 , @chongphanId , 1)

IF @@ERROR = 0 
	SET @returnCode = @@IDENTITY
ELSE
	SET @returnCode = 0
GO
/****** Object:  StoredProcedure [dbo].[procInsertPpCard]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procInsertPpCard]
	@ppCardGroupId	int
,	@ppCardSerialNumber varchar(12)
,	@pinCode		varchar(50)
,	@returnCode		int	OUTPUT
 AS

INSERT INTO tblPpCard(ppCardGroupId, ppCardSerialNumber, pinCode)
VALUES( @ppCardGroupId ,@ppCardSerialNumber  ,  @pinCode )

IF @@ERROR = 0
	SET @returnCode = 1
ELSE
	SET @returnCode = 0
GO
/****** Object:  StoredProcedure [dbo].[procInsertGamebangHistory]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procInsertGamebangHistory    Script Date: 23/1/2546 11:40:25 ******/
CREATE PROCEDURE [dbo].[procInsertGamebangHistory]
	@gamebangId	as	int
,	@adminLogId	as	int
 AS
	INSERT INTO tblGamebangHistory 
		SELECT gamebangId , gamebangName , bizNumber , address , zipcode , phoneNumber , presidentSurname, presidentFirstName , limitTime , ipCount , depositAmount , apply , GETDATE() , @adminLogId , ssno , item , bizNumber , cellPhone , email , manageCode , gamebangTypeId
		FROM tblGamebang 
		WHERE gamebangId = @gamebangId
GO
/****** Object:  StoredProcedure [dbo].[procReserveCheck]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procReserveCheck    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procReserveCheck 
	Creation Date		:	2002. 02.17
	Written by		:	? ??
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	?? ??? ??? ????
	
	Input Parameters :	
				@gamebangId			AS		SMALLINT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ???? ??? ?? ??? ,?? ??? ? ? ??.
				2: ???? ??? ??? ???? ???????(?? ??? ??) ?? ??? ???? ???.
				3: ???? ??? ??? ???? ???? ???(????) ??? ??? ? ??.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procReserveCheck] 
	@gamebangId			AS		INT
,	@returnCode			AS		TINYINT	OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@minTransactionId		AS		INT
DECLARE	@startDt			AS		SMALLDATETIME
------------------------?? ???--------------------
SELECT @minTransactionId = MIN(GGSH.transactionId)
FROM tblGamebangGameServiceHistory AS GGSH INNER JOIN tblTransaction AS T ON GGSH.transactionId = T.transactionId 
WHERE T.peerTransactionId IS NULL AND GGSH.gamebangId = @gamebangId
IF(@minTransactionId IS NULL)
	BEGIN
		--???? ??? ?? ??? ,?? ??? ? ? ??.
		SET @returnCode = 1
	END
ELSE
	BEGIN
		IF((SELECT startDt FROM tblGamebangGameServiceHistory WHERE transactionId = @minTransactionId) >GETDATE()) 
			BEGIN
				SET @returnCode = 3		--???? ??? ??? ???? ???? ???(????) ??? ??? ? ??.
			END
		ELSE
			BEGIN
				SET @returnCode = 2		--???? ??? ??? ???? ???????(?? ??? ??) ?? ??? ???? ???.				
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[procRequestGameLogin_Test]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procRequestGameLogin    Script Date: 23/1/2546 11:40:26 ******/
/*
	??? : ???
	??? : 2001.12.12(?)
*/
CREATE PROCEDURE [dbo].[procRequestGameLogin_Test]
	@gameServiceId		as	smallint
,	@userId			as	nvarchar(32)
,	@cpId				as	int
,	@userPwd			as	nvarchar(32)
,	@userRealIp			as	nvarchar(11)
,	@userRealIp4			as	tinyint
,	@userVirtualIp			as	nvarchar(11)
,	@userVirtualIp4			as	tinyint
,	@isReal			as	bit
,	@userStartDt			as	smalldatetime	output
,	@userEndDt			as	smalldatetime	output
,	@userLimitTime			as	int		output
,	@userUsedLimitTime		as	int		output		
,	@userApplyStartTime		as	nchar(4)		output
,	@userApplyEndTime		as	nchar(4)		output
,	@userPlayableMinutes		as	smallint		output
,	@userUsedPlayableMinutes	as	smallint		output
,	@gamebangId			as	int		output
,	@ipCount			as	tinyint		output
,	@gamebangStartDt		as	smalldatetime	output
,	@gamebangEndDt		as	smalldatetime	output
,	@gamebangLimitTime		as	int		output
,	@gamebangUsedLimitTime	as	int		output
,	@rtnVal			as	tinyint		output
AS
DECLARE
	@canGameLogin		as	bit
,	@isFreeId			as	bit
,	@userNumber			as	int
,	@userTypeId			as	tinyint
	/* ?? ?? ?? */
	SELECT @userStartDt = 0, @userEndDt = 0, @userLimitTime = 0, @userUsedLimitTime = 0, @userApplyStartTime = '0000', @userApplyEndTime = '0000', @userPlayableMinutes = 0, @userUsedPlayableMinutes = 0, @gamebangId = 0, @ipCount = 0, @gamebangStartDt = 0, @gamebangEndDt = 0, @gamebangLimitTime = 0, @gamebangUsedLimitTime = 0
	/* ??? ?? ?? */
	SELECT @userNumber = tu.userNumber, @canGameLogin = tus.canGameLogin, @isFreeId = tut.isFreeId
	FROM tblUser tu with (nolock), tblCodeUserStatus tus with (nolock), tblCodeUserType tut with (nolock)
	WHERE tu.userId = @userId and tu.userStatusId = tus.userStatusId and tu.userTypeId = tut.userTypeId and tu.apply = 1
--	WHERE tu.cpId = @cpId and tu.userId = @userId and tu.userPwd = @userPwd and tu.userStatusId = tus.userStatusId and tu.userTypeId = tut.userTypeId and tu.apply = 1
--	WHERE tu.cpId = @cpId and tu.userId = @userId and tu.userStatusId = tus.userStatusId and tu.userTypeId = tut.userTypeId and tu.apply = 1
	
	IF @@rowcount = 1
	BEGIN
		IF @isFreeId = 1
		BEGIN
			IF @canGameLogin = 1
			BEGIN
				/* ?? ?? ??? */
				SET @rtnVal = 2
			END
			ELSE
			BEGIN
				SET @rtnVal = 13
			END
		END
		ELSE
		BEGIN
			IF @canGameLogin = 1
			BEGIN
				/* ??? ?? ?? ?? */
				SELECT @userStartDt=isNull(startDt, 0), @userEndDt=isNull(endDt, 0), @userLimitTime=limitTime, @userUsedLimitTime=usedLimitTime, @userApplyStartTime=applyStartTime, @userApplyEndTime=applyEndTime, @userPlayableMinutes=playableMinutes, @userUsedPlayableMinutes=usedPlayableMinutes
				FROM	tblUserGameService with (nolock)
				WHERE userNumber = @userNumber and gameServiceId = @gameServiceId
select @gameServiceId as gameServiceId, @userLimitTime as userLimitTime, @userUsedLimitTime as userUsedLimitTime			
				/* IP ?? ?? ?? */
				SELECT @gamebangId = gamebangId, @ipCount=ipCount, @gamebangStartDt=isNull(startDt, 0), @gamebangEndDt=isNull(endDt, 0), @gamebangLimitTime=limitTime, @gamebangUsedLimitTime=usedLimitTime
				FROM tblGamebangGameService with (nolock)
				WHERE gameServiceId = @gameServiceId and gamebangId in
					(SELECT gamebangId FROM tblIpAddr with (nolock)  WHERE ipAddr = @userRealIp and @userRealIp4 between startIp and endIp and apply = 1 and ipAddrId in
						(SELECT ipAddrId FROM tblVirtualIpAddr with (nolock) WHERE virtualIpAddr = @userVirtualIp and @userVirtualIp4 between virtualStartIp and virtualEndIp and apply = 1))
				
				/* ?? ??? */
				SET @rtnVal = 1
			END
			ELSE
			BEGIN
				/* ?? ?? ??? ?? ??? */
				SET @rtnVal = 13
			END
		END
	END
	ELSE
	BEGIN
		/* ???? ??? ??? ?? ??? */
		SET @rtnVal = 12
	END
GO
/****** Object:  StoredProcedure [dbo].[procRegTimeStatic]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
?? ???? ?? 
*/
CREATE proc [dbo].[procRegTimeStatic]
	@startDt	varchar(10)
,	@endDt	varchar(10)

as


SELECT
	COUNT(
	CASE 	
	
		WHEN DATEPART(hour,registDt) < 2 THEN 2
		WHEN DATEPART(hour,registDt) < 4 THEN 4
		WHEN DATEPART(hour,registDt) < 6 THEN 6
		WHEN DATEPART(hour,registDt) < 8 THEN 8
		WHEN DATEPART(hour,registDt) < 10 THEN 10
		WHEN DATEPART(hour,registDt) < 12 THEN 12
		WHEN DATEPART(hour,registDt) < 14 THEN 14
		WHEN DATEPART(hour,registDt) < 16 THEN 16
		WHEN DATEPART(hour,registDt) < 18 THEN 18
		WHEN DATEPART(hour,registDt) < 20 THEN 20
		WHEN DATEPART(hour,registDt) < 22 THEN 22
		ELSE 24
	END
),
	CASE 	

		WHEN DATEPART(hour,registDt) < 2 THEN 2
		WHEN DATEPART(hour,registDt) < 4 THEN 4
		WHEN DATEPART(hour,registDt) < 6 THEN 6
		WHEN DATEPART(hour,registDt) < 8 THEN 8
		WHEN DATEPART(hour,registDt) < 10 THEN 10
		WHEN DATEPART(hour,registDt) < 12 THEN 12
		WHEN DATEPART(hour,registDt) < 14 THEN 14
		WHEN DATEPART(hour,registDt) < 16 THEN 16
		WHEN DATEPART(hour,registDt) < 18 THEN 18
		WHEN DATEPART(hour,registDt) < 20 THEN 20
		WHEN DATEPART(hour,registDt) < 22 THEN 22
		ELSE 24
	END

	
FROM tblUserInfo
WHERE registDt between @startDt and @endDt
GROUP BY 	CASE 	

		WHEN DATEPART(hour,registDt) < 2 THEN 2
		WHEN DATEPART(hour,registDt) < 4 THEN 4
		WHEN DATEPART(hour,registDt) < 6 THEN 6
		WHEN DATEPART(hour,registDt) < 8 THEN 8
		WHEN DATEPART(hour,registDt) < 10 THEN 10
		WHEN DATEPART(hour,registDt) < 12 THEN 12
		WHEN DATEPART(hour,registDt) < 14 THEN 14
		WHEN DATEPART(hour,registDt) < 16 THEN 16
		WHEN DATEPART(hour,registDt) < 18 THEN 18
		WHEN DATEPART(hour,registDt) < 20 THEN 20
		WHEN DATEPART(hour,registDt) < 22 THEN 22
		ELSE 24
	END

ORDER BY 2
GO
/****** Object:  StoredProcedure [dbo].[procRegistProduct]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procRegistProduct    Script Date: 23/1/2546 11:40:26 ******/
-- ************************************************************************
-- ?? ?? : 2002. 02.18
-- ?? ?? : ???
-- ??? ?? : O
-- ???? ? : 
-- ?? : ?? ??
-- RESULT ??
-- 0 : 
-- 1 : 
-- 2 : 
-- 3 : 
-- 99 : 
-- ************************************************************************
CREATE PROCEDURE [dbo].[procRegistProduct] 
@productCode 		as	nvarchar(10)
,@gameServiceId	as	smallint
,@productTypeId	as	tinyint
,@productName		as	nvarchar(50)
,@productAmount	as	int
,@ipCount		as	tinyint
,@periodTypeId		as	tinyint
,@productPeriod	as	int
,@limitTime		as	int
,@applyStartTime	as	nchar(4)
,@applyEndTime	as	nchar(4)
,@playableMinutes 	as	smallint
,@adminNumber		as	int
,@apply			as	bit
,@memo		as          nvarchar(200)
AS
	DECLARE @adminLogId as int
	INSERT tblAdminLog (adminActionType, adminActionTable, adminNumber, memo, registDt)
	VALUES ('Registration','tblProduct',@adminNumber, @memo,getdate())
	SET @adminLogId = @@IDENTITY
	INSERT tblProduct (productCode, gameServiceId, productTypeId, productName, productAmount, ipCount, periodTypeId, productPeriod,limitTime,applyStartTime,
	applyEndTime,playableMinutes, registDt, adminLogId, apply)
	VALUES (@productCode, @gameServiceId, @productTypeId, @productName, @productAmount, @ipCount, @periodTypeId, 
		@productPeriod, @limitTime, @applyStartTime, @applyEndTime, @playableMinutes, getdate(), @adminLogId, @apply)
GO
/****** Object:  StoredProcedure [dbo].[procRegistAdminUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procRegistAdminUser    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procRegistAdminUser
	Creation Date		:	2002. 02. 10.
	Written by		:	???
	E-Mail by 		:	jsh001@n-cash.net
	Purpose			:	??? ??
	Input Parameters :	
		@memo				as		nvarchar(255)			:	??
			
	return?	:
		@result
	Return Status:
	Usage: 			
	EXEC procAdminLogin subsub
	Call by:
		adminManager.RegistAdminUser
	Calls:
	 	Nothing
	Access Table :
	 	tblAdmin(I)
		tblCodeAdminType(s)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procRegistAdminUser]
	@cpId				as	int		,
	@adminGroup			as	smallint		,
	@adminGrade			as	smallint		,
	@adminId			as	nvarchar(32)	,
	@adminPwd			as	nvarchar(16)	,
	@adminName			as	nvarchar(16)	
as
DECLARE @result as int
DECLARE @isDupl as tinyint
DECLARE @adminTypeId as smallint
DECLARE @adminTypeCount as tinyint
	SELECT @isDupl = count(A.adminNumber) FROM tblAdmin A WHERE A.adminId = @adminId 
	IF @isDupl = 0
	  BEGIN
		SELECT @adminTypeId = adminTypeId FROM tblCodeAdminType WHERE adminGroupTypeId = @adminGroup AND adminGradeTypeId = @adminGrade ORDER BY adminTypeId DESC
		IF(@adminTypeId IS NULL OR @adminTypeId = '')
			BEGIN
				SET @result = 214
				SELECT @result
				RETURN
			END
		INSERT INTO tblAdmin (adminId, adminPwd, adminTypeId, adminName, cpId) VALUES(@adminId, @adminPwd, @adminTypeId, @adminName, @cpId)
	
		SET @result = 100
		SELECT @result
		RETURN
	  END
	ELSE
	  BEGIN
		SET @result = 214
		SELECT @result
		RETURN
	  END
GO
/****** Object:  StoredProcedure [dbo].[procRefund]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procRefund    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procRefund
	Creation Date		:	2002. 4. 04.
	Written by		:	? ??
	E-Mail by 		:	windist@n-cash.net
	Purpose			:	??
	return?:
	@transactionId		as	integer	: ?? ????ID
int refundCashAmount,String bankName,String accountNumber,String depositer, int adminNumber
*/
CREATE PROCEDURE [dbo].[procRefund]
	@refundRequestId	as	int
,	@refundCashAmount	as	int
,	@bankName		as	nvarchar(20)
,	@accountNumber	as	nvarchar(32)
,	@depositor		as	nvarchar(32)
,	@adminLogId		as	int
,	@transactionId		as	int	output
as
DECLARE @transactionTypeId		as	tinyInt
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @pointBalance		as	int
DECLARE @holdCashBalance		as	int
DECLARE @now			as	datetime
DECLARE @temp			as	int
DECLARE @errorSave			as	int
DECLARE @userNumber		as	int
DECLARE @requestCashAmount		as	int
DECLARE @cpId			as	int
DECLARE @userTypeId			as	tinyInt
DECLARE @processStatus		as	int
SET @errorSave = 0
SET @processStatus = 2 --?? ??
Set @transactionTypeId = 8 -- ?? transactionTypeId
Set @now = getDate()
SET @transactionId = 0
--SELECT tblRefundRequest
SELECT @userNumber = userNumber,@requestCashAmount = requestCashAmount
FROM tblRefundRequest with(nolock) Where refundRequestId = @refundRequestId
IF @userNumber = null
BEGIN
	SET @transactionId = -201
	RETURN
END
--SELECT tblUserInfo
SELECT
	@cpId = cpId,@userTypeId = userTypeId  ,@cashBalance = cashBalance , @pointToCashBalance = pointToCashBalance, @holdCashBalance = holdCashBalance
	,@pointBalance = pointBalance
From tblUserInfo with(rowLock) Where userNumber = @userNumber and apply = 1
	
IF @userTypeId = 9
	SET @cpId = 1
IF @cpId = null
BEGIN
	SET @transactionId = -201
	RETURN
END
--CashBalance Compute
If @refundCashAmount > (@cashBalance)
BEGIN
	SET @transactionId = -502
	RETURN
END
Else If @refundCashAmount > (@cashBalance - @holdCashBalance - @pointToCashBalance)
BEGIN
	SET @transactionId = -502
	RETURN
END
SET @cashBalance = @cashBalance -  @refundCashAmount
--INSERT tblTransaction
INSERT INTO tblTransaction( [transactionTypeId], [userNumber], [cpId], [cashAmount], [pointToCashAmount], [pointAmount], [cashBalance], [pointToCashBalance], [pointBalance], [registDt], [adminLogId], [peerTransactionId])
VALUES(@transactionTypeId, @userNumber, @cpId, -@refundCashAmount, 0, 0, @cashBalance,@pointToCashBalance, @pointBalance, @now, @adminLogId,null)
SET @transactionId = @@IDENTITY
SET @errorSave = @errorSave + @@ERROR
--INSERT tblRefund
INSERT INTO tblRefund([transactionId], [refundRequestId],[refundAmount], [bankName], [accountNumber], [depositor], [adminLogId])
VALUES(@transactionId , @refundRequestId,@refundCashAmount, @bankName, @accountNumber, @depositor, @adminLogId)
SET @errorSave = @errorSave + @@ERROR
--UPDATE tblRefundRequest
UPDATE tblRefundRequest
SET [processStatus]=@processStatus
WHERE refundRequestId = @refundRequestId
SET @errorSave = @errorSave + @@ERROR
--UPDATE tblUserInfo
UPDATE tblUserInfo
SET cashBalance = @cashBalance
WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
IF @errorSave <> 0
	SET @transactionId = -401 -- sp ERROR
GO
/****** Object:  StoredProcedure [dbo].[procReCoverRewardUserCashBalance]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procReCoverRewardUserCashBalance]
AS

SET NOCOUNT ON

DECLARE
	 @userNumber		as int
	, @cashBalance		as int


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[tblRecoverdRewardUserMatching]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
	DROP TABLE [dbo].[tblRecoverdRewardUserMatching]
END

CREATE TABLE [tblRecoverdRewardUserMatching] (
	[userNumber] [int] NOT NULL ,
	[cashBalance] [int] NULL
) ON [PRIMARY]

DECLARE rewardCursor CURSOR
FOR
	SELECT userNumber, cashBalance
	FROM tblUserCashBalance_061124

OPEN rewardCursor

FETCH NEXT FROM rewardCursor INTO @userNumber, @cashBalance

WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE tblUserInfo SET cashBalance = @cashBalance WHERE userNumber = @userNumber
	INSERT INTO tblRecoverdRewardUserMatching VALUES(@userNumber, @cashBalance)

	FETCH NEXT FROM rewardCursor INTO @userNumber, @cashBalance
END
	
CLOSE rewardCursor
DEALLOCATE rewardCursor

SELECT COUNT(*) FROM tblRecoverdRewardUserMatching
SELECT TOP 1000 * FROM tblRecoverdRewardUserMatching

SET NOCOUNT OFF
GO
/****** Object:  StoredProcedure [dbo].[procPwdCheck2]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procPwdCheck2    Script Date: 23/1/2546 11:40:27 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procPwdCheck
	Creation Date		:	2002-06-25
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	??? password ??
******************************Optional Item******************************
	Input Parameters	:	
					@userId		AS		nvarchar(32)
					@userPwd		AS		nvarchar(32)				
	Output Parameters	:	
					@returnCode		AS		TINYINT		OUTPUT		
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procPwdCheck2]
	@userId		AS		nvarchar(32)
,	@userPwd		AS		nvarchar(32)
,	@returnCode		AS		TINYINT		OUTPUT
AS
DECLARE	@checkUserPwd		AS		nvarchar(32)
SELECT @checkUserPwd = userPwd FROM tblUserInfo WHERE userId = @userId AND apply = 1
IF(@checkUserPwd <> @userPwd) 
	BEGIN
		SET @returnCode = 2
	END
ELSE
	BEGIN
		SET @returnCode = 1
	END
GO
/****** Object:  StoredProcedure [dbo].[procPwdCheck]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procPwdCheck    Script Date: 23/1/2546 11:40:27 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procPwdCheck
	Creation Date		:	2002-06-25
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	??? password ??
******************************Optional Item******************************
	Input Parameters	:	
					@userId		AS		nvarchar(32)
					@userPwd		AS		nvarchar(32)				
	Output Parameters	:	
					@returnCode		AS		TINYINT		OUTPUT		
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procPwdCheck]
	@userNumber		AS		INT
,	@userPwd		AS		nvarchar(32)
,	@returnCode		AS		TINYINT		OUTPUT
AS
DECLARE	@checkUserPwd		AS		nvarchar(32)
SELECT @checkUserPwd = userPwd FROM tblUserInfo WHERE userNumber = @userNumber AND apply = 1
IF(@checkUserPwd <> @userPwd) 
	BEGIN
		SET @returnCode = 2
	END
ELSE
	BEGIN
		SET @returnCode = 1
	END
GO
/****** Object:  StoredProcedure [dbo].[procProductSettlement3]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procProductSettlement3    Script Date: 23/1/2546 11:40:27 ******/
--????? ?? ?? ??? ?? ???
CREATE PROCEDURE [dbo].[procProductSettlement3]
	@startDt		as	datetime
,	@endDt		as	datetime
,	@cpId			as	TINYINT
 AS
declare @a as TINYINT
declare @b as TINYINT
SET @a = 0
SET @b = 0
IF @cpId = 0 
	BEGIN
		SET @a = 1
		SET @b = 2
	END
ELSE
	BEGIN
		SET @a = @cpId
	END
DELETE FROM tblSettlementTemp 
--?? ??
INSERT INTO tblSettlementTemp 
	SELECT P.productId , P.productTypeId , 1 , P.productName , PT.descript , NULL , NULL , NULL 
		FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE (P.ipCount IS NULL OR P.ipCount = 0) AND P.apply = 1 AND P.productTypeId <> 8  
--ip??
INSERT INTO tblSettlementTemp 
	SELECT DISTINCT (P.ipCount) , P.productTypeId , 2 , P.productName , PT.descript , NULL , NULL , NULL 
		FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE (P.ipCount IS NOT NULL AND P.ipCount <> 0) AND P.apply = 1 AND P.productTypeId <> 8  
--???????
INSERT INTO tblSettlementTemp 
	SELECT DISTINCT 0 , P.productTypeId , 3 , 'Penalty caused by halfway termination' , PT.descript , NULL , NULL , NULL 
		FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE P.productTypeId = 8  
--?? ????
DECLARE settle1 CURSOR
KEYSET
FOR 	SELECT P.productId FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId WHERE (P.ipCount IS NULL OR P.ipCount = 0) AND P.apply = 1 AND P.productTypeId <> 8  
DECLARE @productId INT
OPEN settle1
FETCH NEXT FROM settle1 INTO @productId
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		UPDATE tblSettlementTemp SET totalChargeAmountPayment = 
		(SELECT -ISNULL(SUM(T.cashAmount) , 0)
		FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 2
		JOIN tblProduct P ON O.productId = P.productId AND (P.ipCount IS NULL OR P.ipCount = 0) AND P.productTypeId <> 8
		JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE T.registDt between @startDt and @endDt AND P.productId = @productId  AND cpId IN (@a , @b) 
		GROUP BY P.productTypeId)
		WHERE productId = @productId AND productCheck = 1
	END
	FETCH NEXT FROM settle1 INTO @productId
END
CLOSE settle1
DEALLOCATE settle1
--?? ???? ??
DECLARE settle1 CURSOR
KEYSET
FOR 	SELECT P.productId FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId WHERE (P.ipCount IS NULL OR P.ipCount = 0) AND P.apply = 1 AND P.productTypeId <> 8  
DECLARE @productId1 INT
OPEN settle1
FETCH NEXT FROM settle1 INTO @productId1
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		UPDATE tblSettlementTemp SET totalChargeAmountCancel = 
		(SELECT ISNULL(SUM(T.cashAmount) , 0)
		FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 6
		JOIN tblProduct P ON O.productId = P.productId AND (P.ipCount IS NULL OR P.ipCount = 0) AND P.productTypeId <> 8
		JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE T.registDt between @startDt and @endDt AND P.productId = @productId1 AND cpId IN (@a , @b) 
		GROUP BY P.productTypeId)
		WHERE productId = @productId1 AND productCheck = 1
	END
	FETCH NEXT FROM settle1 INTO @productId1
END
CLOSE settle1
DEALLOCATE settle1
--??? ??
DECLARE settle1 CURSOR
KEYSET
FOR SELECT DISTINCT (P.ipCount) , P.productTypeId FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId	WHERE (P.ipCount IS NOT NULL AND P.ipCount <> 0) AND P.apply = 1 AND P.productTypeId <> 8  
DECLARE @productId2 INT
DECLARE @productTypeId2 TINYINT
OPEN settle1
FETCH NEXT FROM settle1 INTO @productId2 , @productTypeId2
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		UPDATE tblSettlementTemp SET totalChargeAmountPayment = 
		(SELECT -ISNULL(SUM(T.cashAmount) , 0)
		FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 2
		JOIN tblProduct P ON O.productId = P.productId AND (P.ipCount IS NOT NULL AND P.ipCount <> 0) AND P.productTypeId <> 8 
		JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE T.registDt between @startDt and @endDt AND P.ipCount = @productId2 AND P.productTypeId = @productTypeId2 AND cpId IN (@a , @b) 	)
		WHERE productId = @productId2 AND productTypeId= @productTypeId2 AND productCheck = 2
	END
	FETCH NEXT FROM settle1 INTO @productId2 , @productTypeId2
END
CLOSE settle1
DEALLOCATE settle1
--??? ???? ??
DECLARE settle1 CURSOR
KEYSET
FOR SELECT DISTINCT (P.ipCount) , P.productTypeId FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId	WHERE (P.ipCount IS NOT NULL AND P.ipCount <> 0) AND P.apply = 1 AND P.productTypeId <> 8  
DECLARE @productId3 INT
DECLARE @productTypeId3 TINYINT
OPEN settle1
FETCH NEXT FROM settle1 INTO @productId3 , @productTypeId3
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		UPDATE tblSettlementTemp SET totalChargeAmountCancel = 
		(SELECT ISNULL(SUM(T.cashAmount) , 0)
		FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 6
		JOIN tblProduct P ON O.productId = P.productId AND (P.ipCount IS NOT NULL AND P.ipCount <> 0)  AND P.productTypeId <> 8 
		JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE T.registDt between @startDt and @endDt AND P.ipCount = @productId3 AND P.productTypeId = @productTypeId3 AND cpId IN (@a , @b) )
		WHERE productId = @productId3 AND productTypeId= @productTypeId3 AND productCheck = 2
	END
	FETCH NEXT FROM settle1 INTO @productId3 , @productTypeId3
END
CLOSE settle1
DEALLOCATE settle1
--?? ?? ??
UPDATE tblSettlementTemp SET totalChargeAmountPayment = 
	(SELECT -ISNULL(SUM(T.cashAmount) , 0)
	FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 2
	JOIN tblProduct P ON O.productId = P.productId AND P.productTypeId = 8 
	JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
	WHERE T.registDt between @startDt and @endDt AND cpId IN (@a , @b) )
WHERE productId = 0 AND  productCheck = 3
--?? ???? ??
UPDATE tblSettlementTemp SET totalChargeAmountCancel = 
	(SELECT ISNULL(SUM(T.cashAmount) , 0)
	FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 6
	JOIN tblProduct P ON O.productId = P.productId AND P.productTypeId = 8 
	JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
	WHERE T.registDt between @startDt and @endDt AND cpId IN (@a , @b) )
WHERE productId = 0 AND  productCheck = 3
UPDATE tblSettlementTemp SET settlementAmount = totalChargeAmountPayment - totalChargeAmountCancel
--SELECT * FROM tblSettlementTemp
GO
/****** Object:  StoredProcedure [dbo].[procProductSettlement2]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procProductSettlement2    Script Date: 23/1/2546 11:40:27 ******/
-- ?? ??? ????? ?? ???? ??
CREATE PROCEDURE [dbo].[procProductSettlement2]
	@productType		as 	int
,	@startDt		as	datetime
,	@endDt		as	datetime
,	@cpId			as	TINYINT
 AS
declare @a as TINYINT
declare @b as TINYINT
SET @a = 0
SET @b = 0
IF @cpId = 0 
	BEGIN
		SET @a = 1
		SET @b = 2
	END
ELSE
	BEGIN
		SET @a = @cpId
	END
DELETE FROM tblSettlementTemp 
--?? ??
INSERT INTO tblSettlementTemp 
	SELECT P.productId , P.productTypeId , 1 , P.productName , PT.descript , NULL , NULL , NULL 
		FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE (P.ipCount IS NULL OR P.ipCount = 0) AND P.apply = 1 AND P.productTypeId <> 8  
--ip??
INSERT INTO tblSettlementTemp 
	SELECT DISTINCT (P.ipCount) , P.productTypeId , 2 , P.productName , PT.descript , NULL , NULL , NULL 
		FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE (P.ipCount IS NOT NULL AND P.ipCount <> 0) AND P.apply = 1 AND P.productTypeId <> 8  
--???????
INSERT INTO tblSettlementTemp 
	SELECT DISTINCT 0 , P.productTypeId , 3 , 'Penalty caused by halfway termination' , PT.descript , NULL , NULL , NULL
		FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE P.productTypeId = 8  
--?? ????
DECLARE settle1 CURSOR
KEYSET
FOR 	SELECT P.productId FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId WHERE (P.ipCount IS NULL OR P.ipCount = 0) AND P.apply = 1 AND P.productTypeId <> 8  
DECLARE @productId INT
OPEN settle1
FETCH NEXT FROM settle1 INTO @productId
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		UPDATE tblSettlementTemp SET totalChargeAmountPayment = 
		(SELECT -ISNULL(SUM(T.cashAmount) , 0)
		FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 2
		JOIN tblProduct P ON O.productId = P.productId AND (P.ipCount IS NULL OR P.ipCount = 0) AND P.productTypeId <> 8
		JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE T.registDt between @startDt and @endDt AND P.productId = @productId  AND cpId IN (@a , @b) and P.productTypeId = @productType
		GROUP BY P.productTypeId)
		WHERE productId = @productId AND productCheck = 1
	END
	FETCH NEXT FROM settle1 INTO @productId
END
CLOSE settle1
DEALLOCATE settle1
--?? ???? ??
DECLARE settle1 CURSOR
KEYSET
FOR 	SELECT P.productId FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId WHERE (P.ipCount IS NULL OR P.ipCount = 0) AND P.apply = 1 AND P.productTypeId <> 8  
DECLARE @productId1 INT
OPEN settle1
FETCH NEXT FROM settle1 INTO @productId1
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		UPDATE tblSettlementTemp SET totalChargeAmountCancel = 
		(SELECT ISNULL(SUM(T.cashAmount) , 0)
		FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 6
		JOIN tblProduct P ON O.productId = P.productId AND (P.ipCount IS NULL OR P.ipCount = 0) AND P.productTypeId <> 8
		JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE T.registDt between @startDt and @endDt AND P.productId = @productId1  AND cpId IN (@a , @b) and P.productTypeId = @productType
		GROUP BY P.productTypeId)
		WHERE productId = @productId1 AND productCheck = 1
	END
	FETCH NEXT FROM settle1 INTO @productId1
END
CLOSE settle1
DEALLOCATE settle1
--??? ??
DECLARE settle1 CURSOR
KEYSET
FOR SELECT DISTINCT (P.ipCount) , P.productTypeId FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId	WHERE (P.ipCount IS NOT NULL AND P.ipCount <> 0) AND P.apply = 1 AND P.productTypeId <> 8  
DECLARE @productId2 INT
DECLARE @productTypeId2 TINYINT
OPEN settle1
FETCH NEXT FROM settle1 INTO @productId2 , @productTypeId2
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		UPDATE tblSettlementTemp SET totalChargeAmountPayment = 
		(SELECT -ISNULL(SUM(T.cashAmount) , 0)
		FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 2
		JOIN tblProduct P ON O.productId = P.productId AND (P.ipCount IS NOT NULL AND P.ipCount <> 0) AND P.productTypeId <> 8 
		JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE T.registDt between @startDt and @endDt AND P.ipCount = @productId2 AND P.productTypeId = @productTypeId2  AND cpId IN (@a , @b) and P.productTypeId = @productType)
		WHERE productId = @productId2 AND productTypeId= @productTypeId2 AND productCheck = 2
	END
	FETCH NEXT FROM settle1 INTO @productId2 , @productTypeId2
END
CLOSE settle1
DEALLOCATE settle1
--??? ???? ??
DECLARE settle1 CURSOR
KEYSET
FOR SELECT DISTINCT (P.ipCount) , P.productTypeId FROM tblProduct P JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId	WHERE (P.ipCount IS NOT NULL AND P.ipCount <> 0) AND P.apply = 1 AND P.productTypeId <> 8  
DECLARE @productId3 INT
DECLARE @productTypeId3 TINYINT
OPEN settle1
FETCH NEXT FROM settle1 INTO @productId3 , @productTypeId3
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		UPDATE tblSettlementTemp SET totalChargeAmountCancel = 
		(SELECT ISNULL(SUM(T.cashAmount) , 0)
		FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 6
		JOIN tblProduct P ON O.productId = P.productId AND (P.ipCount IS NOT NULL AND P.ipCount <> 0)  AND P.productTypeId <> 8 
		JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId
		WHERE T.registDt between @startDt and @endDt AND P.ipCount = @productId3 AND P.productTypeId = @productTypeId3  AND cpId IN (@a , @b) and P.productTypeId = @productType)
		WHERE productId = @productId3 AND productTypeId= @productTypeId3 AND productCheck = 2
	END
	FETCH NEXT FROM settle1 INTO @productId3 , @productTypeId3
END
CLOSE settle1
DEALLOCATE settle1
--?? ?? ??
UPDATE tblSettlementTemp SET totalChargeAmountPayment = 
	(SELECT -ISNULL(SUM(T.cashAmount) , 0)
	FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 2
	JOIN tblProduct P ON O.productId = P.productId AND P.productTypeId = 8 
	JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId  AND cpId IN (@a , @b)
	WHERE T.registDt between @startDt and @endDt and P.productTypeId = @productType)
WHERE productId = 0 AND  productCheck = 3
--?? ???? ??
UPDATE tblSettlementTemp SET totalChargeAmountCancel = 
	(SELECT ISNULL(SUM(T.cashAmount) , 0)
	FROM tblTransaction T JOIN tblOrder O ON T.transactionId = O.transactionId AND T.transactionTypeId = 6
	JOIN tblProduct P ON O.productId = P.productId AND P.productTypeId = 8 
	JOIN tblCodeProductType PT ON P.productTypeId = PT.productTypeId  AND cpId IN (@a , @b)
	WHERE T.registDt between @startDt and @endDt and P.productTypeId = @productType)
WHERE productId = 0 AND  productCheck = 3
UPDATE tblSettlementTemp SET settlementAmount = totalChargeAmountPayment - totalChargeAmountCancel
--SELECT * FROM tblSettlementTemp
GO
/****** Object:  StoredProcedure [dbo].[procProductSettlement]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procProductSettlement    Script Date: 23/1/2546 11:40:27 ******/
CREATE PROCEDURE [dbo].[procProductSettlement]
	@checkValue		as	tinyint
,	@productType		as 	int
,	@startDt		as	datetime
,	@endDt		as	datetime
 AS
	IF @checkValue = 1  
		BEGIN
			IF @productType = 99 
				BEGIN
					select p.productId as productId, -sum(cashAmount) as amount from tblTransaction t, tblOrder o, tblProduct p
					where t.transactionId = o.transactionId and o.productId = p.productId and t.transactionTypeId = 2 and p.apply = 1
					           and t.registDt between @startDt and @endDt
					group by p.productId
				END 
			ELSE
				BEGIN
					select p.productId as productId, -sum(cashAmount) as amount from tblTransaction t, tblOrder o, tblProduct p
					where t.transactionId = o.transactionId and o.productId = p.productId and t.transactionTypeId = 2 and p.apply = 1
					           and p.productTypeId = @productType and t.registDt between @startDt and @endDt
					group by p.productId
				END 
		END
	ELSE
		BEGIN
			IF @productType = 99 
				BEGIN
					select p.productId as productId, -sum(cashAmount) as amount from tblTransaction t, tblOrder o, tblProduct p
					where t.transactionId = o.transactionId and o.productId = p.productId and p.apply = 1
					           and  o.transactionId in (select peerTransactionId from tblTransaction where transactionTypeId = 6)
					           and t.registDt between @startDt and @endDt
					group by p.productId
				END 
			ELSE
				BEGIN
					select p.productId as productId, -sum(cashAmount) as amount from tblTransaction t, tblOrder o, tblProduct p
					where t.transactionId = o.transactionId and o.productId = p.productId and p.productTypeId = @productType and p.apply = 1
					           and  o.transactionId in (select peerTransactionId from tblTransaction where transactionTypeId = 6)
					           and t.registDt between @startDt and @endDt
					group by p.productId
				END 
		END
GO
/****** Object:  StoredProcedure [dbo].[procPrivacySettlement]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procPrivacySettlement    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procPrivacySettlement
	Creation Date		:	2002. 5. 31
	Written by		:	???
	E-Mail by 		:	airpol@n-cash.net
	Purpose			:	
	Input Parameters	:
		@startDt	as 	datetime
		@endDt	as	datetime
		@chargeType	as	int
		@productType	as	int
		@cpId		as	int		
	return?			:
	Output Parameters	:	
	Return Status		:		
	Usage			: 			
	Call by			:	
	Calls			: 	
	Access Table 		: 	tblTransation, tblOrder, tblCharge, tblSettlementChargeMap,
					tblUser, tblCodeChargeType, tblProduct
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procPrivacySettlement]
	@startDt	as 	datetime
,	@endDt	as	datetime
,	@chargeType	as	INT
,	@productType	as	INT
,	@cpId		as	INT	
AS
	IF @cpId = 1000 
		BEGIN
			IF @chargeType = 0
				BEGIN
					IF @productType = 1001 
						BEGIN
							/*cp, ????, ????? ??? ??????? ?? ??? ?? ??*/
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt     /*??*/
								and sc.settlementTypeId = 1    /*??????*/
								and p.periodTypeId != 1           /*??? ???*/
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union    /*?? ??? ?? ??*/
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt    /*?? ????*/
								and sc.settlementTypeId = 1 
								and p.periodTypeId != 1     
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
					ELSE IF @productType = 0 
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 1
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 1 
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
					ELSE 
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 1 and p.productPeriod = @productType 
								and p.periodTypeId = 1 
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 1 and p.productPeriod = @productType 
								and p.periodTypeId = 1 
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
				END
			ELSE
				BEGIN
					IF @productType = 1001
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 1 
								and p.periodTypeId != 1 and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 1 
								and p.periodTypeId != 1 and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
					ELSE IF @productType = 0
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 1 
								and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 1 
								and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
					ELSE
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 1 and p.productPeriod = @productType 
								and p.periodTypeId = 1 and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 1 and p.productPeriod = @productType 
								and p.periodTypeId = 1 and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
				END	
		END
	ELSE
		BEGIN
			IF @chargeType = 0
				BEGIN
					IF @productType = 1001 
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1
								and p.periodTypeId != 1 
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1 
								and p.periodTypeId != 1 
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
					ELSE IF @productType = 0 
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1 
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
					ELSE 
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1 and p.productPeriod = @productType 
								and p.periodTypeId = 1 
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1 and p.productPeriod = @productType 
								and p.periodTypeId = 1 
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
				END
			ELSE
				BEGIN
					IF @productType = 1001
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1 
								and p.periodTypeId != 1 and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1 
								and p.periodTypeId != 1 and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
					ELSE IF @productType = 0
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1 
								and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1 
								and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
					ELSE
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1 and p.productPeriod = @productType 
								and p.periodTypeId = 1 and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0, t.cpId
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUser u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and t.cpId = @cpId and sc.settlementTypeId = 1 and p.productPeriod = @productType 
								and p.periodTypeId = 1 and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId)
							order by t.cpId, p.productId, c.chargeTypeId, amount desc 
						END
				END
		END
GO
/****** Object:  StoredProcedure [dbo].[procPreOrderOld]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procPreOrder    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procCharge
	Creation Date		:	2002. 2. 08.
	Written by		:	? ??
	E-Mail by 		:	windist@n-cash.net
	Purpose			:	??? ??
	Input Parameters :	
	
			
	return?:
	@transactionId		as	integer		:	 ?? ????ID
	Call by		:	TransactionManager.Transaction.charge
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I)	, tblUserInfo(U)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procPreOrderOld]
	@userNumber				as	int
,	@cpId					as	int
,	@gameServiceId			as	int
,	@productId				as	int
,	@chargeTransactionId	as	int
,	@orderNumber			as	nvarchar(32)
,	@orderTypeId			as	tinyInt
,	@primeCost				as	int
,	@eventId				as	int
,	@preOrderDt				as	DateTime
,	@adminLogId				as	int
,	@transactionId			as	int	output
as
DECLARE @cashAmount			as	int
DECLARE @pointToCashAmount	as	int
DECLARE @userTypeId			as	tinyInt
DECLARE @userStatusId		as	tinyInt
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @holdCashBalance	as	int
DECLARE @pointBalance		as	int
DECLARE @now				as	datetime
DECLARE @transactionTypeId	as	tinyInt
DECLARE @canOrder			as	bit
DECLARE @productTypeId		as	tinyInt
DECLARE @ipCount			as	tinyInt
DECLARE @periodTypeId		as	tinyInt
DECLARE @productPeriod		as	int
DECLARE @limitTime			as	int
DECLARE @applyStartTime		as	nchar(4)
DECLARE @applyEndTime		as	nchar(4)
DECLARE @playableMinutes		as	smallInt
DECLARE @userGameServiceId		as	int
DECLARE @startDt			as	DateTime
DECLARE @endDt			as	DateTime
DECLARE @userLimitTime		as	int
DECLARE @usedLimitTime		as	int
DECLARE @usedPlayableMinutes	as	smallInt
DECLARE @updateUserStatusId 	as	tinyInt
DECLARE @isGame			as	bit
DECLARE @temp 			as	int
DECLARE @userCpId		as	int
DECLARE @errorSave		as	int
DECLARE @gamebangId		as	int
DECLARE @historyStartDt 		as	DateTime
DECLARE @gamebangGameServiceId	as	int
DECLARE @gamebangPaymentTypeId	as	tinyInt
DECLARE @gamebangPaymentTypeId2	as	tinyInt
DECLARE @gamebangLimitTime		as	int
DECLARE @chargeTypeId		as	tinyInt
DECLARE @isGamebangProduct as bit
DECLARE @isFirst			int
SET @isFirst = 0
SET @errorSave = 0
SET @now = getDate()
SET @transactionTypeId = 2 --??
SET @updateUserStatusId = 2 --????? ?? userStatusId
--tblUser Select
SELECT
	@temp = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,
	@pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance
FROM tblUserInfo with(rowlock) WHERE userNumber = @userNumber and apply = 1
IF @temp is null
BEGIN
	Set @transactionId = -201 --user ??
	RETURN
END
--userStatus Check
SELECT @canOrder = canOrder FROM tblCodeUserStatus with(nolock) WHERE userStatusId = @userStatusId
IF @canOrder = 0
BEGIN
	Set @transactionId = -501 --???? ?? ???
	RETURN
END
	
--tblProduct SELECT
SELECT
	@cashAmount = productAmount,@productTypeId=productTypeId,@ipCount=ipCount,@periodTypeId=periodTypeId,
	@productPeriod=productPeriod,@limitTime=limitTime,@applyStartTime=applyStartTime,@applyEndTime=applyEndTime,
	@playableMinutes = playableMinutes
FROM tblProduct with(nolock) WHERE productId = @productId and apply = 1
IF @cashAmount is null
BEGIN
	Set @transactionId = -203 --????
	RETURN
END
-- ??
SET @cashBalance = @cashBalance - @cashAmount
IF @pointToCashBalance > @cashAmount
BEGIN
	SET @pointToCashAmount	=	@cashAmount
	SET @pointToCashBalance = @pointToCashBalance - @cashAmount
END
ELSE
BEGIN
	SET @pointToCashAmount	= @pointToCashBalance
	SET @pointToCashBalance = 0
	
END
			
IF @cashBalance < @holdCashBalance
BEGIN
	Set @transactionId = -502 --? ??
	RETURN
END
--Admin..
IF @adminLogId = 0
BEGIN
	SET @adminLogId = null
END
IF @chargeTransactionId = 0
BEGIN
	SET @chargeTransactionId = null
END
IF @orderNumber = ''
BEGIN
	SET @orderNumber = null
END
IF @primeCost = 0
BEGIN
	SET @primeCost = null
END
IF @eventId = 0
BEGIN
	SET @eventId = null
END
SELECT @isGame = isGame, @isGamebangProduct = isGamebangProduct FROM tblCodeProductType with(nolock) WHERE apply=1 AND productTypeId = @productTypeId
IF @isGame is null
BEGIN
	SET @transactionId = -206 --??? productType
END
--tblTransaction Insert
INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
VALUES(@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
SET @errorSave = @errorSave + @@ERROR	
--SET Return Value
SET @transactionId = @@IDENTITY
		
--tblOrder Insert
INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)
VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@productTypeId,@cashAmount,@eventId)
SET @errorSave = @errorSave + @@ERROR	
IF @errorSave <> 0
BEGIN
	SET @transactionId = -401
	RETURN
END
--??????
IF @isGame = 1
BEGIN
	IF @userTypeId <> 9 --userType Check
	BEGIN
		SET @transactionId = -509	-- ???? ????? ??.
		RETURN						-- ???? ????? ??.
	END
	ELSE
	BEGIN
		IF @isGamebangProduct = 0
		BEGIN
			SET @transactionId = -506
			RETURN
		END
		
	-- ??? ?? ??
		SET @gamebangId = @userCpId
		--tblGamebangGameService SELECT
		SELECT 
			@gamebangGameServiceId = gamebangGameServiceId,@gamebangPaymentTypeId=gamebangPaymentTypeId,
			@startDt=startDt, @endDt=endDt, @gamebangLimitTime=limitTime
		FROM tblGamebangGameService with(rowLock)
		WHERE gamebangId = @gamebangId AND gameServiceId = @gameServiceId
		
		IF @gamebangLimitTime is null
			SET @gamebangLimitTime = 0
		IF @gamebangPaymentTypeId is null
			SET @gamebangPaymentTypeId = 0
		IF @startDt is null
		BEGIN
			SET @startDt = @preOrderDt
			SET @endDt = @preOrderDt
		END
		SET @historyStartDt = @startDt
		IF (@endDt > @preOrderDt) or (@now > @preOrderDt) 
		BEGIN
			SET @transactionId = -508
			RETURN
		END
		
	/*
		periodTypeId
		1 ?
		2 ?
		3 ?
		4 ?
	*/
		--?? ??
		SET @gamebangPaymentTypeId2 = 0
		IF @productPeriod is not null
		BEGIN
			SET @gamebangPaymentTypeId2 = 1
			IF @endDt <= @preOrderDt
			BEGIN
				SET @startDt = @preOrderDt
				SET @historyStartDt = @preOrderDt
				IF @periodTypeId = 1
					SET @endDt = DATEADD(mm,@productPeriod,@startDt)
				ELSE IF @periodTypeId = 2
					SET @endDt = DATEADD(dd,@productPeriod,@startDt)
				ELSE IF @periodTypeId = 3
					SET @endDt = DATEADD(hh,@productPeriod,@startDt)
				ELSE IF @periodTypeId = 4
					SET @endDt = DATEADD(mi,@productPeriod,@startDt)
			END
			ELSE
			BEGIN
				SET @transactionId = -508 --????? ??? ???~
				RETURN
			END
		END
		SET @endDt = Left(@endDt, 10) + ' 23:59:00'
			
		IF @limitTime is not null
		BEGIN
			SET @gamebangPaymentTypeId2 = @gamebangPaymentTypeId2 + 2
			SET @limitTime = @limitTime
		END
		ELSE
			SET @limitTime = 0
		
		IF @gamebangPaymentTypeId = 2
		BEGIN
			IF @gamebangPaymentTypeId2 = 1
				SET @gamebangPaymentTypeId2 = 3
		END
		
		IF @ipCount is null
			SET @ipCount = 0
			
		IF @gamebangGameServiceId is null
		BEGIN
			--tblGamebangGameService INSERT
			INSERT tblGamebangGameService(gamebangId, gameServiceId, gamebangPaymentTypeId, 
			ipCount, startDt, endDt, limitTime, usedLimitTime, registDt)
			VALUES(@gamebangId, @gameServiceId, @gamebangPaymentTypeId2, @ipCount, @startDt, @endDt, 0, 0, @now)
			SET @gamebangGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
			set @isFirst = 1
		END
/*		ELSE
		BEGIN
			IF @startDt >= @now
			BEGIN
				--tblGamebangGameService UPDATE
				UPDATE tblGamebangGameService SET startDt=@startDt, endDt=@endDt,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END
			ELSE
			BEGIN
				SET @transactionId = -508 --????? ??? ???~
				RETURN
			END -- IF @startDt >= @now
		END --IF @gamebangGameServiceId is null
		

		
		IF @isFirst =0  --?? ??? ??? ???? ?? ?? ????? ?? INSERT ????? ?? ???? ?? ??? ?
		BEGIN
			--job INSERT
			DECLARE @job_name as sysname
			DECLARE @description as nvarchar(512)
			DECLARE @job_id as UNIQUEIDENTIFIER  
			DECLARE @command as nvarchar(3200)
			DECLARE @cmdexec_success_code as int
			DECLARE @database_name as sysname
			DECLARE @active_start_date as int
			DECLARE @active_start_time as int
			DECLARE @return	as int
			SET @job_name = @transactionId
			SET @description = '??????? JOB'
	
			SET @command = 'DECLARE @E  AS INT 
					       DECLARE @lt AS INT 
					        SELECT @lt = limitTime FROM tblGamebangGameService with(rowLock) WHERE gamebangGameServiceId = '+CAST(@gamebangGameServiceId as varchar)
							+ '  UPDATE tblGamebangGameService SET gamebangPaymentTypeId = ' + CAST(@gamebangPaymentTypeId2 as varchar)
							+ ',  ipCount = ' + CAST(@ipCount as varchar)+ ',limitTime = @lt + ' + CAST(@limitTime as varchar) 
							+ '  ,  startDt = ' + CAST(@historyStartDt  AS VARCHAR) 
							+ '  ,  endDt = ' + CAST(@endDt   AS VARCHAR) 
							+ '  WHERE gamebangGameServiceId  = ' + CAST(@gamebangGameServiceId as varchar)
							+ ' SET @E = @E + @@ERROR IF @E <> 0 SELECT 1 ELSE SELECT 0'
			SET @cmdexec_success_code = 0
					
			SET @active_start_date = CAST(CONVERT ( nchar(8),@historyStartDt ,112) as int)
			SET @active_start_time = 0
			
			SET @database_name = 'BillCrux_Phil'
			
					
			EXEC @return = [msdb].[dbo].sp_add_job @job_name,1,@description,1
						,null, null,'sa' ,2,0, 0, 0,null,null
						,null,1,@job_id OUTPUT
			IF @return = 1
			BEGIN
				SET @transactionId = -401
				RETURN
			END
			EXEC @return = [msdb].[dbo].sp_add_jobstep @job_id,null
							 , 1,'tblGamebangGameService UPDATE PreOrder'
							, 'TSQL',@command
							, null
							, @cmdexec_success_code
							, 1,0, 2, 0
							,null,@database_name
							,'sa',0,0
			IF @return = 1
			BEGIN
				SET @transactionId = -401
				RETURN
			END
			EXEC @return =  [msdb].[dbo].sp_add_jobschedule @job_id,null
							, 'tblGamebangGameService UPDATE  PreOrder'
							, 1, 1, 1, 0,0,0,0
							, @active_start_date
							, null
							, @active_start_time
							, null
			IF @return = 1
			BEGIN
				SET @transactionId = -401
				RETURN
			END
			EXEC @return = [msdb].[dbo].sp_add_jobserver @job_id,null ,N'(LOCAL)'
			IF @return = 1
			BEGIN
				SET @transactionId = -401
				RETURN
			END 
			
			-- tblGamebangGameServiceReservation Insert
		END
*/	
		INSERT tblGamebangGameServiceReservation(transactionId, gamebangGameServiceId, gamebangId, gameServiceId, productId, startDt, updateDt, isUpdate, isCancel)
		VALUES(@transactionId, @gamebangGameServiceId, @gamebangId, @gameServiceId, @productId, @startDt, @historyStartDt, 0, 0)
		SET @errorSave = @errorSave + @@ERROR

		--tblGamebangGameServiceHistory INSERT
		INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
			SELECT 
				@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId2, @ipCount, @historyStartDt, @endDt, @limitTime + @gamebangLimitTime,usedLimitTime, registDt 
			FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
		SET @errorSave = @errorSave + @@ERROR		
		--tblGamebangSettlement INSERT
		SELECT @chargeTypeId = chargeTypeId FROM tblCharge with(nolock) WHERE transactionId = @chargeTransactionId

		IF @chargeTypeId = 4 OR @chargeTypeId = 5
		BEGIN
			INSERT tblGamebangSettlement(transactionId,gamebangId,receipt,chargeTypeId,startDt,endDt,registDt)
				VALUES(@transactionId,@gamebangId,@cashAmount,@chargeTypeId,@historyStartDt,@endDt,@now)
			SET @errorSave = @errorSave + @@ERROR
			INSERT tblGamebangSettlementHistory(transactionId, gamebangId, receipt, chargeTypeId, startDt, endDt, registDt, adminLogId)
				SELECT *,@adminLogId FROM tblGamebangSettlement with(rowLock) WHERE transactionId = @transactionId
			SET @errorSave = @errorSave + @@ERROR
		END
	END	
END
--tblUserInfo Update
UPDATE tblUserInfo SET cashBalance=@cashBalance,userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
--tblUser Update
UPDATE tblUser SET userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
--tblUserHistory Insert
	INSERT INTO 
		tblUserInfoHistory 
			(userNumber, userId, userPwd, cpId, userSurName, userFirstName,  userTypeId, userStatusId, gameServiceId, ssno, sex, birthday, 
			isSolar, email, zipcode, nation, address, phoneNumber, passwordCheckQuestionTypeId, 
			passwordCheckAnswer, cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply, updateDt, adminLogId)
		SELECT 
			userNumber, userId, userPwd, cpId, userSurName, userFirstName, userTypeId, userStatusId, gameServiceId, ssno, sex, birthday, 
			isSolar, email, zipcode, nation, address, phoneNumber, passwordCheckQuestionTypeId,
 			passwordCheckAnswer,	cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply, @now, @adminLogId
		FROM tblUserInfo with (nolock)
		WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
IF @errorSave <> 0
	SET @transactionId = -401
GO
/****** Object:  StoredProcedure [dbo].[procPreOrder]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procPreOrder    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procCharge
	Creation Date		:	2002. 2. 08.
	Written by		:	? ??
	E-Mail by 		:	windist@n-cash.net
	Purpose			:	??? ??
	Input Parameters :	
	
			
	return?:
	@transactionId		as	integer		:	 ?? ????ID
	Call by		:	TransactionManager.Transaction.charge
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I)	, tblUserInfo(U)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procPreOrder]
	@userNumber				as	int
,	@cpId					as	int
,	@gameServiceId			as	int
,	@productId				as	int
,	@chargeTransactionId	as	int
,	@orderNumber			as	nvarchar(32)
,	@orderTypeId			as	tinyInt
,	@primeCost				as	int
,	@eventId				as	int
,	@preOrderDt				as	DateTime
,	@adminLogId				as	int
,	@transactionId			as	int	output
as
DECLARE @cashAmount			as	int
DECLARE @pointToCashAmount	as	int
DECLARE @userTypeId			as	tinyInt
DECLARE @userStatusId		as	tinyInt
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @holdCashBalance	as	int
DECLARE @pointBalance		as	int
DECLARE @now				as	datetime
DECLARE @transactionTypeId	as	tinyInt
DECLARE @canOrder			as	bit
DECLARE @productTypeId		as	tinyInt
DECLARE @ipCount			as	tinyInt
DECLARE @periodTypeId		as	tinyInt
DECLARE @productPeriod		as	int
DECLARE @limitTime			as	int
DECLARE @applyStartTime		as	nchar(4)
DECLARE @applyEndTime		as	nchar(4)
DECLARE @playableMinutes		as	smallInt
DECLARE @userGameServiceId		as	int
DECLARE @startDt			as	DateTime
DECLARE @endDt			as	DateTime
DECLARE @userLimitTime		as	int
DECLARE @usedLimitTime		as	int
DECLARE @usedPlayableMinutes	as	smallInt
DECLARE @updateUserStatusId 	as	tinyInt
DECLARE @isGame			as	bit
DECLARE @temp 			as	int
DECLARE @userCpId		as	int
DECLARE @errorSave		as	int
DECLARE @gamebangId		as	int
DECLARE @historyStartDt 		as	DateTime
DECLARE @gamebangGameServiceId	as	int
DECLARE @gamebangPaymentTypeId	as	tinyInt
DECLARE @gamebangPaymentTypeId2	as	tinyInt
DECLARE @gamebangLimitTime		as	int
DECLARE @chargeTypeId		as	tinyInt
DECLARE @isGamebangProduct as bit
DECLARE @isFirst			int
SET @isFirst = 0
SET @errorSave = 0
SET @now = getDate()
SET @transactionTypeId = 2 --??
SET @updateUserStatusId = 2 --????? ?? userStatusId
--tblUser Select
SELECT
	@temp = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,
	@pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance
FROM tblUserInfo with(rowlock) WHERE userNumber = @userNumber and apply = 1
IF @temp is null
BEGIN
	Set @transactionId = -201 --user ??
	RETURN
END
--userStatus Check
SELECT @canOrder = canOrder FROM tblCodeUserStatus with(nolock) WHERE userStatusId = @userStatusId
IF @canOrder = 0
BEGIN
	Set @transactionId = -501 --???? ?? ???
	RETURN
END
	
--tblProduct SELECT
SELECT
	@cashAmount = productAmount,@productTypeId=productTypeId,@ipCount=ipCount,@periodTypeId=periodTypeId,
	@productPeriod=productPeriod,@limitTime=limitTime,@applyStartTime=applyStartTime,@applyEndTime=applyEndTime,
	@playableMinutes = playableMinutes
FROM tblProduct with(nolock) WHERE productId = @productId and apply = 1
IF @cashAmount is null
BEGIN
	Set @transactionId = -203 --????
	RETURN
END
-- ??
SET @cashBalance = @cashBalance - @cashAmount
IF @pointToCashBalance > @cashAmount
BEGIN
	SET @pointToCashAmount	=	@cashAmount
	SET @pointToCashBalance = @pointToCashBalance - @cashAmount
END
ELSE
BEGIN
	SET @pointToCashAmount	= @pointToCashBalance
	SET @pointToCashBalance = 0
	
END
			
IF @cashBalance < @holdCashBalance
BEGIN
	Set @transactionId = -502 --? ??
	RETURN
END
--Admin..
IF @adminLogId = 0
BEGIN
	SET @adminLogId = null
END
IF @chargeTransactionId = 0
BEGIN
	SET @chargeTransactionId = null
END
IF @orderNumber = ''
BEGIN
	SET @orderNumber = null
END
IF @primeCost = 0
BEGIN
	SET @primeCost = null
END
IF @eventId = 0
BEGIN
	SET @eventId = null
END
SELECT @isGame = isGame, @isGamebangProduct = isGamebangProduct FROM tblCodeProductType with(nolock) WHERE apply=1 AND productTypeId = @productTypeId
IF @isGame is null
BEGIN
	SET @transactionId = -206 --??? productType
END
--tblTransaction Insert
INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
VALUES(@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
SET @errorSave = @errorSave + @@ERROR	
--SET Return Value
SET @transactionId = @@IDENTITY
		
--tblOrder Insert
INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)
VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@productTypeId,@cashAmount,@eventId)
SET @errorSave = @errorSave + @@ERROR	
IF @errorSave <> 0
BEGIN
	SET @transactionId = -401
	RETURN
END
--??????
IF @isGame = 1
BEGIN
	IF @userTypeId <> 9 --userType Check
	BEGIN
		SET @transactionId = -509	-- ???? ????? ??.
		RETURN						-- ???? ????? ??.
	END
	ELSE
	BEGIN
		IF @isGamebangProduct = 0
		BEGIN
			SET @transactionId = -506
			RETURN
		END
		
	-- ??? ?? ??
		SET @gamebangId = @userCpId
		--tblGamebangGameService SELECT
		SELECT 
			@gamebangGameServiceId = gamebangGameServiceId,@gamebangPaymentTypeId=gamebangPaymentTypeId,
			@startDt=startDt, @endDt=endDt, @gamebangLimitTime=limitTime
		FROM tblGamebangGameService with(rowLock)
		WHERE gamebangId = @gamebangId AND gameServiceId = @gameServiceId
		
		IF @gamebangLimitTime is null
			SET @gamebangLimitTime = 0
		IF @gamebangPaymentTypeId is null
			SET @gamebangPaymentTypeId = 0
		IF @startDt is null
		BEGIN
			SET @startDt = @preOrderDt
			SET @endDt = @preOrderDt
		END
		SET @historyStartDt = @startDt
		IF (@endDt > @preOrderDt) or (@now > @preOrderDt) 
		BEGIN
			SET @transactionId = -508
			RETURN
		END
		
	/*
		periodTypeId
		1 ?
		2 ?
		3 ?
		4 ?
	*/
		--?? ??
		SET @gamebangPaymentTypeId2 = 0
		IF @productPeriod is not null
		BEGIN
			SET @gamebangPaymentTypeId2 = 1
			IF @endDt <= @preOrderDt
			BEGIN
				SET @startDt = @preOrderDt
				SET @historyStartDt = @preOrderDt
				IF @periodTypeId = 1
					SET @endDt = DATEADD(mm,@productPeriod,@startDt)
				ELSE IF @periodTypeId = 2
					SET @endDt = DATEADD(dd,@productPeriod,@startDt)
				ELSE IF @periodTypeId = 3
					SET @endDt = DATEADD(hh,@productPeriod,@startDt)
				ELSE IF @periodTypeId = 4
					SET @endDt = DATEADD(mi,@productPeriod,@startDt)
			END
			ELSE
			BEGIN
				SET @transactionId = -508 --????? ??? ???~
				RETURN
			END
		END
		SET @endDt = Left(@endDt, 10) + ' 23:59:00'
			
		IF @limitTime is not null
		BEGIN
			SET @gamebangPaymentTypeId2 = @gamebangPaymentTypeId2 + 2
			SET @limitTime = @limitTime
		END
		ELSE
			SET @limitTime = 0
		
		IF @gamebangPaymentTypeId = 2
		BEGIN
			IF @gamebangPaymentTypeId2 = 1
				SET @gamebangPaymentTypeId2 = 3
		END
		
		IF @ipCount is null
			SET @ipCount = 0
			
		IF @gamebangGameServiceId is null
		BEGIN
			--tblGamebangGameService INSERT
			INSERT tblGamebangGameService(gamebangId, gameServiceId, gamebangPaymentTypeId, 
			ipCount, startDt, endDt, limitTime, usedLimitTime, registDt)
			VALUES(@gamebangId, @gameServiceId, @gamebangPaymentTypeId2, @ipCount, @startDt, @endDt, 0, 0, @now)
			SET @gamebangGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
			set @isFirst = 1
		END
/*		ELSE
		BEGIN
			IF @startDt >= @now
			BEGIN
				--tblGamebangGameService UPDATE
				UPDATE tblGamebangGameService SET startDt=@startDt, endDt=@endDt,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END
			ELSE
			BEGIN
				SET @transactionId = -508 --????? ??? ???~
				RETURN
			END -- IF @startDt >= @now
		END --IF @gamebangGameServiceId is null
		

		
		IF @isFirst =0  --?? ??? ??? ???? ?? ?? ????? ?? INSERT ????? ?? ???? ?? ??? ?
		BEGIN
			--job INSERT
			DECLARE @job_name as sysname
			DECLARE @description as nvarchar(512)
			DECLARE @job_id as UNIQUEIDENTIFIER  
			DECLARE @command as nvarchar(3200)
			DECLARE @cmdexec_success_code as int
			DECLARE @database_name as sysname
			DECLARE @active_start_date as int
			DECLARE @active_start_time as int
			DECLARE @return	as int
			SET @job_name = @transactionId
			SET @description = '??????? JOB'
	
			SET @command = 'DECLARE @E  AS INT 
					       DECLARE @lt AS INT 
					        SELECT @lt = limitTime FROM tblGamebangGameService with(rowLock) WHERE gamebangGameServiceId = '+CAST(@gamebangGameServiceId as varchar)
							+ '  UPDATE tblGamebangGameService SET gamebangPaymentTypeId = ' + CAST(@gamebangPaymentTypeId2 as varchar)
							+ ',  ipCount = ' + CAST(@ipCount as varchar)+ ',limitTime = @lt + ' + CAST(@limitTime as varchar) 
							+ '  ,  startDt = ' + CAST(@historyStartDt  AS VARCHAR) 
							+ '  ,  endDt = ' + CAST(@endDt   AS VARCHAR) 
							+ '  WHERE gamebangGameServiceId  = ' + CAST(@gamebangGameServiceId as varchar)
							+ ' SET @E = @E + @@ERROR IF @E <> 0 SELECT 1 ELSE SELECT 0'
			SET @cmdexec_success_code = 0
					
			SET @active_start_date = CAST(CONVERT ( nchar(8),@historyStartDt ,112) as int)
			SET @active_start_time = 0
			
			SET @database_name = 'BillCrux_Phil'
			
					
			EXEC @return = [msdb].[dbo].sp_add_job @job_name,1,@description,1
						,null, null,'sa' ,2,0, 0, 0,null,null
						,null,1,@job_id OUTPUT
			IF @return = 1
			BEGIN
				SET @transactionId = -401
				RETURN
			END
			EXEC @return = [msdb].[dbo].sp_add_jobstep @job_id,null
							 , 1,'tblGamebangGameService UPDATE PreOrder'
							, 'TSQL',@command
							, null
							, @cmdexec_success_code
							, 1,0, 2, 0
							,null,@database_name
							,'sa',0,0
			IF @return = 1
			BEGIN
				SET @transactionId = -401
				RETURN
			END
			EXEC @return =  [msdb].[dbo].sp_add_jobschedule @job_id,null
							, 'tblGamebangGameService UPDATE  PreOrder'
							, 1, 1, 1, 0,0,0,0
							, @active_start_date
							, null
							, @active_start_time
							, null
			IF @return = 1
			BEGIN
				SET @transactionId = -401
				RETURN
			END
			EXEC @return = [msdb].[dbo].sp_add_jobserver @job_id,null ,N'(LOCAL)'
			IF @return = 1
			BEGIN
				SET @transactionId = -401
				RETURN
			END 
			
			-- tblGamebangGameServiceReservation Insert
		END
*/		ELSE
		BEGIN
			INSERT tblGamebangGameServiceReservation(transactionId, gamebangGameServiceId, gamebangId, gameServiceId, productId, startDt, updateDt, isUpdate, isCancel)
			VALUES(@transactionId, @gamebangGameServiceId, @gamebangId, @gameServiceId, @productId, @startDt, @historyStartDt, 0, 0)
			SET @errorSave = @errorSave + @@ERROR
		END
		--tblGamebangGameServiceHistory INSERT
		INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
			SELECT 
				@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId2, @ipCount, @historyStartDt, @endDt, @limitTime + @gamebangLimitTime,usedLimitTime, registDt 
			FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
		SET @errorSave = @errorSave + @@ERROR		
		--tblGamebangSettlement INSERT
		SELECT @chargeTypeId = chargeTypeId FROM tblCharge with(nolock) WHERE transactionId = @chargeTransactionId

		IF @chargeTypeId = 4 OR @chargeTypeId = 5
		BEGIN
			INSERT tblGamebangSettlement(transactionId,gamebangId,receipt,chargeTypeId,startDt,endDt,registDt)
				VALUES(@transactionId,@gamebangId,@cashAmount,@chargeTypeId,@historyStartDt,@endDt,@now)
			SET @errorSave = @errorSave + @@ERROR
			INSERT tblGamebangSettlementHistory(transactionId, gamebangId, receipt, chargeTypeId, startDt, endDt, registDt, adminLogId)
				SELECT *,@adminLogId FROM tblGamebangSettlement with(rowLock) WHERE transactionId = @transactionId
			SET @errorSave = @errorSave + @@ERROR
		END
	END	
END
--tblUserInfo Update
UPDATE tblUserInfo SET cashBalance=@cashBalance,userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
--tblUser Update
UPDATE tblUser SET userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
--tblUserHistory Insert
	INSERT INTO 
		tblUserInfoHistory 
			(userNumber, userId, userPwd, cpId, userSurName, userFirstName,  userTypeId, userStatusId, gameServiceId, ssno, sex, birthday, 
			isSolar, email, zipcode, nation, address, phoneNumber, passwordCheckQuestionTypeId, 
			passwordCheckAnswer, cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply, updateDt, adminLogId)
		SELECT 
			userNumber, userId, userPwd, cpId, userSurName, userFirstName, userTypeId, userStatusId, gameServiceId, ssno, sex, birthday, 
			isSolar, email, zipcode, nation, address, phoneNumber, passwordCheckQuestionTypeId,
 			passwordCheckAnswer,	cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply, @now, @adminLogId
		FROM tblUserInfo with (nolock)
		WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
IF @errorSave <> 0
	SET @transactionId = -401
GO
/****** Object:  StoredProcedure [dbo].[procPpcardSettlement]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procPpcardSettlement    Script Date: 23/1/2546 11:40:27 ******/
CREATE PROCEDURE [dbo].[procPpcardSettlement]
	@checkValue		as 	tinyint
,	@startDt		as	datetime
,	@endDt		as	datetime
 
AS
	IF @checkValue = 1 
		begin
			select cc.chargeTypeId as chargeTypeId, count(*) as count, sum(cashAmount) as amount
			from tblTransaction t, tblCodeTransactionType tt, tblCodeChargeType cc, tblCharge c
			where t.transactionId= c.transactionId and t.transactionTypeId = tt.transactionTypeId and cc.chargeTypeId = c.chargeTypeId
				and t.transactionTypeId = 1 and cc.chargeTypeId = 3 and t.registDt between @startDt and @endDt
			group by cc.chargeTypeId
			order by cc.chargeTypeId 
		end 
	ELSE IF @checkValue = 2 
		begin
			select ct.chargeTypeId as chargeTypeId, count(*) as count, sum(cashAmount) as amount
			from tblTransaction t, tblCharge c, tblCodeChargeType ct 
			where t.transactionId = c.transactionId and c.chargeTypeId = ct.chargeTypeId 
				and t.transactionId in (select peerTransactionId from tblTransaction where transactionTypeId = 5 )
				and ct.chargeTypeId = 3 and t.registDt between @startDt and @endDt
			group by ct.chargeTypeId
			order by ct.chargeTypeId
		end 
	ELSE IF @checkValue = 3 
		begin 
			select ot.orderTypeId, count(*) as count, -sum(cashAmount) as amount 
			from tblTransaction t, tblOrder o, tblCodeOrderType ot, tblCodeProductType pt
			where t.transactionId = o.transactionId and o.orderTypeId = ot.orderTypeId and o.orderTypeId = pt.productTypeId
				and t.transactionTypeId = 2  and pt.productTypeId= 5 and t.registDt between @startDt and @endDt
			group by ot.descript, ot.orderTypeId
			order by ot.orderTypeId
		end
	ELSE
		begin
			select ot.orderTypeId, count(*) as count, -sum(cashAmount) as amount 
			from tblTransaction t, tblOrder o, tblCodeOrderType ot, tblCodeProductType pt
			where t.transactionId = o.transactionId and o.orderTypeId = ot.orderTypeId and o.orderTypeId = pt.productTypeId
				and t.transactionId in (select  peerTransactionId from tblTransaction where transactionTypeId = 6)
				and pt.productTypeId = 5 and t.registDt between @startDt and @endDt
			group by ot.descript, ot.orderTypeId
			order by ot.orderTypeId			
		end
GO
/****** Object:  StoredProcedure [dbo].[procPpcardSaleInsert]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procPpcardSaleInsert    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procPpcardSaleInsert
	Creation Date		:	2002. 02.01
	Written by		:	? ??
	E-Mail by 		:	jsh001@n-cash.net
	Purpose			:	ppcardsaleManager
	
	Input Parameters :	
				@adminId			AS		nvarchar(16)
	Output Parameters:	
				@returnCode			AS		SMALLINT
				
	Return Status:		
*/
CREATE PROCEDURE [dbo].[procPpcardSaleInsert]
	@saleMode		AS		tinyint
,	@chongphanId		AS		int
,	@productId		AS		int
,	@quntity		AS		int
,	@price			AS		money
AS
IF @saleMode = 1
  Begin
	INSERT INTO tblPpCardSale (chongphanId, productId, quntity, price) VALUES(@chongphanId, @productId, @quntity, @price)
  End
IF @saleMode = 2
  Begin
	INSERT INTO tblPpCardBillCollect (chongphanId, price) VALUES(@chongphanId, @price)
  End
Else
  Begin
	select 'slaeModeError'	
  End
GO
/****** Object:  StoredProcedure [dbo].[procPpCardReturnInfo]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[procPpCardReturnInfo]	
	@userNumber	as	int
,	@adminNumber	as	int
,	@memo		as	nvarchar(50)
as

delete from tblPpCardFailList where userNumber = @userNumber

insert into tblPpCardReturnList (userNumber, adminNumber, registDt) 
	values (@userNumber, @adminNumber, getdate())

INSERT INTO tblAdminLog
	VALUES ('Amend', 'tblPpCardReturnList', @adminNumber,  @memo, getdate())
GO
/****** Object:  StoredProcedure [dbo].[procPCbangSettlement]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procPCbangSettlement    Script Date: 23/1/2546 11:40:27 ******/
CREATE PROCEDURE [dbo].[procPCbangSettlement]
	@startDt	as 	datetime
,	@endDt	as	datetime
,	@chargeType	as	INT
,	@productType	as	INT
,	@cpId		as	INT	
,	@checkValue 	as 	tinyint
,	@timePay	as	nvarchar(30)
AS 
	IF @checkValue = 1 
		BEGIN
			IF @chargeType = 0
				BEGIN
					IF @productType = 1001 
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and t.cpId = @cpId 
		 						and right(productCode, 2) not in ('PA', 'PB', 'TB', 'TA', 'DB', 'DA')  and  left(productCode, 1) !='F'
								group by productCode, p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and t.cpId = @cpId 
		 						and right(productCode, 2) not in ('PA', 'PB', 'TB', 'TA', 'DB', 'DA')  and  left(productCode, 1) !='F'
								group by productCode, p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod)
							order by  t.cpId, p.productId, c.chargeTypeId, isPlus desc, amount desc 
						END
					ELSE IF @productType = 0 
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and t.cpId = @cpId and  left(productCode, 1) !='F' and right(productCode, 2) not in ('TA', 'TB')
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and t.cpId = @cpId and  left(productCode, 1) !='F' and right(productCode, 2) not in ('TA', 'TB') 
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod)
							order by t.cpId, p.productId, c.chargeTypeId, isPlus desc, amount desc 
						END
					ELSE 
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and  left(productCode, 1) !='F' and right(productCode, 2) not in ('TA', 'TB')
								and p.periodTypeId = 1 and ipCount = @productType and t.cpId = @cpId 
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and  left(productCode, 1) !='F' and right(productCode, 2) not in ('TA', 'TB')
								and p.periodTypeId = 1 and ipCount = @productType and t.cpId = @cpId 
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod)
							order by t.cpId, p.productId, c.chargeTypeId, isPlus desc, amount desc 
						END
				END
			ELSE
				BEGIN
					IF @productType = 1001
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and t.cpId = @cpId 
		 						and right(productCode, 2) not in ('PA', 'PB', 'TB', 'TA', 'DB', 'DA')  and  left(productCode, 1) !='F'
								and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and t.cpId = @cpId 
		 						and right(productCode, 2) not in ('PA', 'PB', 'TB', 'TA', 'DB', 'DA')  and  left(productCode, 1) !='F'
								and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod)
							order by t.cpId, p.productId, c.chargeTypeId, isPlus desc, amount desc 
						END
					ELSE IF @productType = 0
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and t.cpId = @cpId and  left(productCode, 1) !='F' and right(productCode, 2) not in ('TA', 'TB')
								and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and t.cpId = @cpId and  left(productCode, 1) !='F' and right(productCode, 2) not in ('TA', 'TB')
								and c.chargeTypeId = @chargeType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod)
							order by t.cpId, p.productId, c.chargeTypeId, isPlus desc, amount desc 
						END
					ELSE
						BEGIN
							select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber 
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and t.cpId = @cpId and  left(productCode, 1) !='F' and right(productCode, 2) not in ('TA', 'TB')
								and p.periodTypeId = 1 and c.chargeTypeId = @chargeType and ipCount = @productType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod
							union 
							(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0 as isPlus, t.cpId, productPeriod
								from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
								inner join tblCharge c on c.transactionId = o.chargeTransactionId 
								inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
								inner join tblUserInfo u on t.userNumber = u.userNumber
								inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
								inner join tblProduct p on p.productId = o.productId
								where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
								and sc.settlementTypeId = 2 and t.cpId = @cpId and  left(productCode, 1) !='F' and right(productCode, 2) not in ('TA', 'TB')
								and p.periodTypeId = 1 and c.chargeTypeId = @chargeType and ipCount = @productType
								group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod)
							order by t.cpId, p.productId, c.chargeTypeId, isPlus desc, amount desc 
						END
				END
		END
	ELSE
		BEGIN
			IF @chargeType = 0
				BEGIN
					select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1 as isPlus, t.cpId, productPeriod
						from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
						inner join tblCharge c on c.transactionId = o.chargeTransactionId 
						inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
						inner join tblUserInfo u on t.userNumber = u.userNumber 
						inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
						inner join tblProduct p on p.productId = o.productId
						where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
						and sc.settlementTypeId = 2 and t.cpId = @cpId 
 						and right(productCode, 2) not in ('PA', 'PB', 'DB', 'DA')  and  left(productCode, 1) !='F' and productName like + '%' + @timePay + '%' 
						group by productCode, p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod
					union 
					(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0 as isPlus, t.cpId, productPeriod
						from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
						inner join tblCharge c on c.transactionId = o.chargeTransactionId 
						inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
						inner join tblUserInfo u on t.userNumber = u.userNumber
						inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
						inner join tblProduct p on p.productId = o.productId
						where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
						and sc.settlementTypeId = 2 and t.cpId = @cpId 
 						and right(productCode, 2) not in ('PA', 'PB', 'DB', 'DA')  and  left(productCode, 1) !='F' and productName like + '%' + @timePay + '%'
						group by productCode, p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod)
					order by  t.cpId, p.productId, c.chargeTypeId, isPlus desc, amount desc 
				END
			ELSE
				BEGIN
					select sum(-t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 1 as isPlus, t.cpId, productPeriod
						from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId 
						inner join tblCharge c on c.transactionId = o.chargeTransactionId 
						inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
						inner join tblUserInfo u on t.userNumber = u.userNumber 
						inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
						inner join tblProduct p on p.productId = o.productId
						where transactionTypeId = 2 and t.registDt  between @startDt and @endDt 
						and sc.settlementTypeId = 2 and t.cpId = @cpId 
 						and right(productCode, 2) not in ('PA', 'PB', 'DB', 'DA')  and  left(productCode, 1) !='F' and productName like + '%' + @timePay + '%'
						and c.chargeTypeId = @chargeType
						group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod
					union 
					(select sum(t.cashAmount) as amount, p.productId, c.chargeTypeId,  cc.descript, p.productName, 0 as isPlus, t.cpId, productPeriod
						from tblTransaction t inner join tblOrder o on t.transactionId = o.transactionId	 
						inner join tblCharge c on c.transactionId = o.chargeTransactionId 
						inner join tblSettlementChargeMap sc on c.chargeTypeId = sc.chargeTypeId
						inner join tblUserInfo u on t.userNumber = u.userNumber
						inner join tblCodeChargeType cc on cc.chargeTypeId = c.chargeTypeId
						inner join tblProduct p on p.productId = o.productId
						where transactionTypeId = 6 and t.registDt  between @startDt and @endDt 
						and sc.settlementTypeId = 2 and t.cpId = @cpId 
 						and right(productCode, 2) not in ('PA', 'PB','DB', 'DA')  and  left(productCode, 1) !='F' and productName like + '%' + @timePay + '%'
						and c.chargeTypeId = @chargeType
						group by p.productId, c.chargeTypeId, cc.descript, p.productName, t.cpId, productPeriod)
					order by t.cpId, p.productId, c.chargeTypeId, isPlus desc, amount desc 
				END		
		END
GO
/****** Object:  StoredProcedure [dbo].[procOrderSettlement]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procOrderSettlement    Script Date: 23/1/2546 11:40:27 ******/
CREATE PROCEDURE [dbo].[procOrderSettlement]
	@checkValue 	as	tinyint
,	@startDt	as	dateTime
,	@endDt	as	dateTime
, 	@cpId		as	int
 AS
	if @checkValue = 1 
		begin 
			select pt.productTypeId, pt.descript, -sum(cashAmount) as amount 
			from tblTransaction t, tblOrder o, tblCodeProductType pt, tblSettlementProductMap s
			where t.transactionId = o.transactionId and o.orderTypeId = pt.productTypeId and pt.productTypeId = s.productTypeId
				and t.transactionTypeId = 2 and t.registDt between @startDt and @endDt and settlementTypeId = 1 and cpId = @cpId
			group by pt.descript, pt.productTypeId
			order by pt.productTypeId
		end 
	else
		begin
			select pt.productTypeId, sum(t2.cashAmount) as amount
			from tblTransaction t1 inner join tblTransaction t2  on t1.transactionId = t2.peerTransactionId
				join tblOrder o on o.transactionId = t1.transactionId 
				join tblCodeProductType pt on o.orderTypeId = pt.productTypeId 
				join tblSettlementProductMap s on s.productTypeId = pt.productTypeId
			where t2.registDt between @startDt and @endDt  and settlementTypeId = 1 and  t2.cpId = 1 
				and t2.transactionTypeId = 6
			group by pt.productTypeId
		end
GO
/****** Object:  StoredProcedure [dbo].[procOrderOnlyByItemBill]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procOrderOnlyByItemBill]    
 @userId   as NVARCHAR(52)    
, @cpId    as int    
, @gameServiceId  as int    
, @userIp   as varchar(17)    
, @contentCode   as int   -- ?????    
--, @contentName   as varchar(30)  -- ????? '?????? ??? ? ??    
, @unitPrice   as int  -- ?????    
, @primeCost   as int  -- ??    
, @quantity   as int    
, @contentTypeCode  as varchar(3)  --TYPEODE " I0 " ?? ??? ???    
, @productId   as int    
, @orderTypeId   as tinyInt   -- 4 ?????? @orderTypeId ? ????? ????? ???? ??    
, @eventId   as int    
--, @transactionId   as int output    
--with encryption     
AS    
---------------------------------------------------------------------------------------------------------------------    
DECLARE @chargeTransactionId AS INT    
DECLARE @orderNumber   AS NVARCHAR    
DECLARE @point   AS INT    
DECLARE @adminLogId   AS INT     
DECLARE @transactionId  AS INT    
    
    
---------------------------------------------------------------------------------------------------------------------    
DECLARE @userNumber  as INT    
DECLARE @cashAmount  as int    
DECLARE @pointToCashAmount as int    
DECLARE @userTypeId   as tinyInt    
DECLARE @userStatusId  as tinyInt    
DECLARE @cashBalance  as int    
DECLARE @pointToCashBalance as int    
DECLARE @holdCashBalance  as int    
DECLARE @pointBalance  as int    
DECLARE @now   as datetime    
DECLARE @transactionTypeId  as tinyInt    
DECLARE @canOrder   as bit    
DECLARE @productTypeId  as tinyInt    
DECLARE @updateUserStatusId  as tinyInt    
DECLARE @userCpId   as int    
DECLARE @errorSave   as int    
DECLARE @productPoint  as  int    
    
    
SET @adminLogId   = NULL    
SET @orderNumber   = NULL    
SET @chargeTransactionId  = NULL    
    
SET @productPoint  = 0     
SET @pointToCashAmount = 0    
    
SET @errorSave = 0    
SET @now = GETDATE()    
SET @cashAmount = @unitPrice * @quantity    
SET @transactionTypeId = 2 --??    
SET @updateUserStatusId = 2 --????? ?? userStatusId    
--tblUser Select    
SELECT    
 @userNumber = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,    
 @pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance    
FROM tblUserInfo WITH (READUNCOMMITTED)      
WHERE userId = @userId  and apply = 1    
IF @userNumber IS NULL OR @@ROWCOUNT <> 1     
 BEGIN    
  SET @transactionId = -201 --user ??
  SELECT @transactionId AS transactionId    
  RETURN    
 END    
     
    
-- ??    
    
    
SET @cashBalance = @cashBalance - @cashAmount    
    
 IF @cashBalance < 0  OR @cashBalance IS NULL    
  BEGIN    
   SET @transactionId = -502 -- ????    
   SELECT @transactionId AS transactionId    
   RETURN    
  END    
    
--Admin..    
 IF @eventId = 0    
  BEGIN    
   SET @eventId = null    
  END    
    
BEGIN TRAN     
    
 --tblTransaction Insert    
 INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,pointAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)    
 VALUES        (@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@productPoint,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)    
 SET @errorSave = @errorSave + @@ERROR     
 --SET Return Value    
 SET @transactionId = SCOPE_IDENTITY()    
      
 --tblOrder Insert    
 INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)    
 VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@orderTypeId,@primeCost,@eventId)    
 SET @errorSave = @errorSave + @@ERROR     
    
    
 INSERT tblOrderPPVDetail (transactionId, contentCode, point ,unitPrice,quantity,userIp,contentTypeCode)    
 VALUES(@transactionId, @contentCode, @cashAmount ,@unitPrice,@quantity,@userIp  ,@contentTypeCode)    
 SET @errorSave = @errorSave + @@ERROR     
    
    
 --tblUserInfo Update    
 UPDATE tblUserInfo SET cashBalance=@cashBalance,pointToCashBalance=@pointToCashBalance,pointBalance=@pointBalance,userStatusId = @updateUserStatusId WHERE userNumber = @userNumber    
 SET @errorSave = @errorSave + @@ERROR    
    
--tblUser Update    
 UPDATE tblUser SET userStatusId = @updateUserStatusId WHERE userNumber = @userNumber    
 SET @errorSave = @errorSave + @@ERROR    
    
--tblUserHistory Insert    
IF @errorSave <> 0 OR @@ERROR <> 0     
 BEGIN    
     
  SET @transactionId = -401 -- ????
  SELECT @transactionId AS transactionId       
  ROLLBACK    
  RETURN    
 END    
    
ELSE    
 BEGIN    
  SELECT @transactionId AS transactionId    
  COMMIT    
  RETURN    
 END
GO
/****** Object:  StoredProcedure [dbo].[procOrderForPPV]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procOrderForPPV    Script Date: 23/1/2546 11:40:27 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procOrderForPPV
	Creation Date		:	2002-06-24
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	?? ??? ??? ??.
******************************Optional Item******************************
	Input Parameters	:	
					@userNumber			AS		INT
					@cpId				AS		INT
					@gameServiceId		AS		INT
					@orderTypeId			AS		TINYINT
					@orderNumber			AS		nvarchar(32)
					@cashAmount			AS		INT
					@totalPoint			AS		INT
					@eventId			AS		INT
					@adminLogId			AS		INT		=	NULL
					@productId			AS		INT	
	Output Parameters	:	
					@transactionId			AS		INT		OUTPUT		
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procOrderForPPV]
	@userNumber			AS		INT
,	@cpId				AS		INT
,	@orderTypeId			AS		TINYINT
,	@orderNumber			AS		nvarchar(32)	=	NULL
,	@cashAmount			AS		INT
,	@totalPoint			AS		INT
,	@eventId			AS		INT
,	@adminLogId			AS		INT		=	NULL
,	@productId			AS		INT
,	@transactionId			AS		INT		OUTPUT
AS
DECLARE @pointToCashAmount	AS		INT
DECLARE @userStatusId		AS		INT
DECLARE @userTypeId			AS		TINYINT
DECLARE @cashBalance		AS		INT
DECLARE @pointToCashBalance	AS		INT
DECLARE @holdCashBalance		AS		INT
DECLARE @pointBalance		AS		INT
DECLARE @now			AS		DATETIME
DECLARE @transactionTypeId		AS		TINYINT
DECLARE @canOrder			AS		BIT
DECLARE @productTypeId		AS		TINYINT
DECLARE @updateUserStatusId 	AS		TINYINT
DECLARE @isGame			AS		BIT
DECLARE @temp 			AS		INT
DECLARE @userCpId			AS		INT
DECLARE @errorSave			AS		INT
DECLARE @productPoint		AS		INT
DECLARE @chargeTransactionId 	AS		INT
SET @errorSave = 0
SET @now = getDate()
SET @transactionTypeId = 2 --??
SET @chargeTransactionId = null
--tblUser Select
SELECT
	@temp = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,
	@pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance
FROM tblUserInfo with(rowlock) WHERE userNumber = @userNumber and apply = 1
IF @temp is null
BEGIN
	Set @transactionId = -201 --user ??
	RETURN
END
--userStatus Check
SELECT @canOrder = canOrder FROM tblCodeUserStatus with(nolock) WHERE userStatusId = @userStatusId
IF @canOrder = 0
	BEGIN
		Set @transactionId = -501 --???? ?? ???
		RETURN
	END
SET @cashBalance = @cashBalance - @cashAmount	--@cashAmount ? ?? ????.
IF @pointToCashBalance > @cashAmount
	BEGIN
		SET @pointToCashAmount = @cashAmount
		SET @pointToCashBalance = @pointToCashBalance - @cashAmount
	END
ELSE
	BEGIN
		SET @pointToCashAmount = @pointToCashBalance
		SET @pointToCashBalance = 0
	END
SET @pointBalance = @pointBalance + @totalPoint
			
IF @cashBalance < @holdCashBalance
BEGIN
	Set @transactionId = -502 --? ??
	RETURN
END
--Admin..
IF @adminLogId = 0
BEGIN
	SET @adminLogId = null
END
IF @chargeTransactionId = 0
BEGIN
	SET @chargeTransactionId = null
END
IF @orderNumber = ''
BEGIN
	SET @orderNumber = null
END
IF @cashAmount = 0
BEGIN
	SET @cashAmount = null
END
IF @eventId = 0
BEGIN
	SET @eventId = null
END
--tblTransaction Insert
INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,pointAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
VALUES(@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@totalPoint,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
SET @errorSave = @errorSave + @@ERROR	
--SET Return Value
SET @transactionId = @@IDENTITY
--tblOrder Insert
INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)
VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@orderTypeId,@cashAmount,@eventId)
SET @errorSave = @errorSave + @@ERROR	
--tblUserInfo Update
UPDATE tblUserInfo SET cashBalance=@cashBalance,pointToCashBalance=@pointToCashBalance,pointBalance=@pointBalance WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
IF @errorSave <> 0
BEGIN
	SET @transactionId = -401
	RETURN
END
GO
/****** Object:  StoredProcedure [dbo].[procOrderForExpireDay]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	Stored Procedure	:	procOrder
	Creation Date		:	2005. 4.19
	Modify by		:	???
	E-Mail by 		:	windist@n-cash.net
	Purpose			:	??? ??
	Input Parameters :	
	
			
	return?:
	@transactionId		as	integer		:	 ?? ????ID
	Call by		:	TransactionManager.Transaction.charge
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I)	, tblUserInfo(U)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procOrderForExpireDay]
	@userNumber				as	int
,	@cpId					as	int
,	@gameServiceId			as	int
,	@productId				as	int
,	@chargeTransactionId	as	int
,	@orderNumber			as	varChar(32)
,	@orderTypeId			as	tinyInt
,	@primeCost				as	int
,	@eventId				as	int
,	@adminLogId				as	int
,	@transactionId			as	int	output
as
DECLARE @cashAmount			as	int
DECLARE @pointToCashAmount	as	int
DECLARE @userTypeId			as	tinyInt
DECLARE @userStatusId		as	tinyInt
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @holdCashBalance	as	int
DECLARE @pointBalance		as	int
DECLARE @now				as	datetime
DECLARE @transactionTypeId	as	tinyInt
DECLARE @canOrder			as	bit
DECLARE @productTypeId		as	tinyInt
DECLARE @ipCount			as	tinyInt
DECLARE @periodTypeId		as	tinyInt
DECLARE @productPeriod		as	int
DECLARE @limitTime			as	int
DECLARE @applyStartTime		as	char(4)
DECLARE @applyEndTime		as	char(4)
DECLARE @playableMinutes	as	smallInt
DECLARE @userApplyStartTime		as	char(4)
DECLARE @userApplyEndTime		as	char(4)
DECLARE @userPlayableMinutes	as	smallInt
DECLARE @userGameServiceId	as	int
DECLARE @startDt			as	DateTime
DECLARE @endDt				as	DateTime
DECLARE @userLimitTime		as	int
DECLARE @usedLimitTime		as	int
DECLARE @usedPlayableMinutes	as	smallInt
DECLARE @updateUserStatusId 	as	tinyInt
DECLARE @isGame				as	bit
DECLARE @temp 				as	int
DECLARE @userCpId			as	int
DECLARE @errorSave			as	int
DECLARE @gamebangId			as	int
DECLARE @historyStartDt 		as	DateTime
DECLARE @gamebangGameServiceId	as	int
DECLARE @gamebangPaymentTypeId	as	tinyInt
DECLARE @gamebangLimitTime		as	int
DECLARE @chargeTypeId		as	tinyInt
DECLARE @isGamebangProduct as bit
DECLARE @productPoint	as int
DECLARE @expireDt				DATETIME
DECLARE @historyExpireDt			DATETIME
SET @errorSave = 0
SET @now = getDate()

SET @transactionTypeId = 2 --??
SET @updateUserStatusId = 2 --????? ?? userStatusId
--tblUser Select
SELECT
	@temp = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,
	@pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance
FROM tblUserInfo with(rowlock) WHERE userNumber = @userNumber and apply = 1
IF @temp is null
BEGIN
	Set @transactionId = -201 --user ??
	RETURN
END
--userStatus Check
SELECT @canOrder = canOrder FROM tblCodeUserStatus with(nolock) WHERE userStatusId = @userStatusId
IF @canOrder = 0
BEGIN
	Set @transactionId = -501 --???? ?? ???
	RETURN
END
	
--tblProduct SELECT
SELECT
	@cashAmount = p.productAmount,@productPoint=productPoint,@productTypeId=p.productTypeId,@ipCount=p.ipCount,@periodTypeId=p.periodTypeId,
	@productPeriod=p.productPeriod,@limitTime=p.limitTime,@applyStartTime=p.applyStartTime,@applyEndTime=p.applyEndTime,
	@playableMinutes =p.playableMinutes,@isGame = pt.isGame, @isGamebangProduct = isGamebangProduct
FROM tblProduct as p with(nolock),tblCodeProductType as pt with(nolock)
WHERE p.productTypeId = pt.productTypeId AND p.productId = @productId and p.apply = 1
IF @cashAmount is null
BEGIN
	Set @transactionId = -203 --????
	RETURN
END

-- ??
SET @cashBalance = @cashBalance - @cashAmount
IF @pointToCashBalance > @cashAmount
BEGIN
	SET @pointToCashAmount	=	@cashAmount
	SET @pointToCashBalance = @pointToCashBalance - @cashAmount
END
ELSE
BEGIN
	SET @pointToCashAmount	= @pointToCashBalance
	SET @pointToCashBalance = 0
END
SET @pointBalance = @pointBalance + @productPoint
			
IF @cashBalance < @holdCashBalance
BEGIN
	Set @transactionId = -502 --? ??
	RETURN
END
--Admin..
IF @adminLogId = 0
BEGIN
	SET @adminLogId = null
END
IF @chargeTransactionId = 0
BEGIN
	SET @chargeTransactionId = null
END
IF @orderNumber = ''
BEGIN
	SET @orderNumber = null
END
IF @primeCost = 0
BEGIN
	SET @primeCost = null
END
IF @eventId = 0
BEGIN
	SET @eventId = null
END
IF @isGame is null
BEGIN
	SET @transactionId = -206 --??? productType
END
--tblTransaction Insert
INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,pointAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
VALUES(@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@productPoint,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
SET @errorSave = @errorSave + @@ERROR	
--SET Return Value
SET @transactionId = @@IDENTITY
		
--tblOrder Insert
INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)
VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@productTypeId,@cashAmount,@eventId)
SET @errorSave = @errorSave + @@ERROR	
--tblUserInfo Update
UPDATE tblUserInfo SET cashBalance=@cashBalance,pointToCashBalance=@pointToCashBalance,pointBalance=@pointBalance,userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
--tblUser Update
UPDATE tblUser SET userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
--tblUserHistory Insert
IF @errorSave <> 0
BEGIN
	SET @transactionId = -401
	RETURN
END
--??????
IF @isGame = 1
BEGIN
	IF @userTypeId <> 9 --userType Check
	BEGIN
	-- ??? ??
		IF @isGamebangProduct = 1
		BEGIN
			SET @transactionId = -507
			RETURN
		END
		SELECT
			@userGameServiceId=userGameServiceId,@startDt=startDt,@endDt=endDt,@userLimitTime=limitTime,@usedLimitTime = usedLimitTime,
			@userApplyStartTime = applyStartTime, @userApplyEndTime = applyEndTime,@userPlayableMinutes=playableMinutes, @historyExpireDt=expireDt
		FROM tblUserGameService with(rowlock) WHERE userNumber = @userNumber and gameServiceId = @gameServiceId
		IF @userLimitTime is null
			SET @userLimitTime = 0
		IF @usedLimitTime is null
			SET @usedLimitTime = 0
		IF @userApplyStartTime is null
			SET @userApplyStartTime = '0000'
		IF @userApplyEndTime is null
			SET @userApplyEndTime = '2400'
		IF @userPlayableMinutes is null
			SET @userPlayableMinutes = 0
		--?? ??
		IF @productPeriod is not null
		BEGIN
			IF @startDt is null
			BEGIN
				SET @startDt = @now
				SET @endDt = @now
			END
			
			IF @endDt <= @now
			BEGIN
				SET @startDt = @now
				SET @historyStartDt = @now
			END
			ELSE
			BEGIN
				SET @historyStartDt = @endDt
			END
			
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,@productPeriod,@historyStartDt)
		END
		
		IF @limitTime is not null
			BEGIN
	
				IF @productTypeId = 8  --????? ?? ?? ?? 20?????
				BEGIN 				
					SET @userLimitTime = @userLimitTime + @limitTime
					SET @expireDt = dateadd(dd, 30,@now)
				END
				ELSE
				BEGIN
					SET @userLimitTime = @userLimitTime + @limitTime
					SET @expireDt = dateadd(dd, 7 ,@now)
					IF @historyExpireDt is not  null
					BEGIN
						IF @historyExpireDt > @expireDt  
						BEGIN
							SET @expireDt = @historyExpireDt
						END 
					END
				END
			
			END

		IF @applyStartTime is null
			SET @applyStartTime = '0000'
		IF @applyEndTime is null
			SET @applyEndTime = '2400'
		IF @playableMinutes is null
			SET @playableMinutes = 0
			
		IF @userGameServiceId is null
		BEGIN --????
			--tblUserGameService INSERT
			INSERT tblUserGameService(userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
			VALUES(@userNumber, @gameServiceId, @startDt, @endDt, @userLimitTime, 0, @applyStartTime, @applyEndTime, @playableMinutes,0, @now, @expireDt)
			SET  @userGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
		END
		ELSE
		BEGIN -- ??? ??? ??
			
			--tblUserGameService UPDATE
			UPDATE tblUserGameService
			SET startDt = @startDt, endDt = @endDt, limitTime = @userLimitTime, applyStartTime = @applyStartTime, applyEndTime = @applyEndTime, playableMinutes = @playableMinutes, registDt = @now, expireDt = @expireDt
			WHERE userNumber = @userNumber and gameServiceId = @gameServiceId
			SET @errorSave = @errorSave + @@ERROR
		END -- ??? ??? ??
					
		--tblUserGameServiceHistory Insert
		INSERT tblUserGameServiceHistory(transactionId,userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
			SELECT @transactionId,userGameServiceId, userNumber, gameServiceId,@historyStartDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt
			FROM tblUserGameService with(rowLock) WHERE userGameServiceId = @userGameServiceId
		SET @errorSave = @errorSave + @@ERROR
		
		--Package ????
		IF @productTypeId = 9 or @productTypeId = 10
		BEGIN
			INSERT tblPackage(transactionId,userNumber,productId,validDt)
				VALUES(@transactionId,@userNumber,@productId,DATEADD(mm,12,@historyStartDt))
		END
	END
	ELSE -- ?? ??
	BEGIN 
		IF @isGamebangProduct = 0
		BEGIN
			SET @transactionId = -506
			RETURN
		END
		-- ??? ?? ??
		SET @gamebangId = @userCpId
		
		--tblGamebangGameService SELECT
		SELECT 
			@gamebangGameServiceId = gamebangGameServiceId,@usedLimitTime = usedLimitTime,@startDt=startDt
			, @endDt=endDt, @gamebangLimitTime=limitTime
		FROM tblGamebangGameService with(rowLock)
		WHERE gamebangId = @gamebangId AND gameServiceId = @gameServiceId
		
		IF @gamebangLimitTime is null
			SET @gamebangLimitTime = 0
		IF @usedLimitTime is null
			SET @usedLimitTime = 0
		SET @historyStartDt = @startDt
		IF @productPeriod is not null
		BEGIN
			IF @startDt is null
			BEGIN
				SET @startDt = @now
				SET @endDt = @now
			END
			IF @endDt <= @now
			BEGIN
				SET @startDt = @now
				SET @historyStartDt = @startDt
			END
			ELSE
			BEGIN
				SET @historyStartDt = @endDt
			END
			
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,@productPeriod,@historyStartDt)
			--SET @endDt = Left(@endDt,10) + ' 00:00:00' -- ??? 00:00:00 ?? ??.
			SET @endDt = Left(@endDt, 10) + ' 23:59:00'
		END
		IF @limitTime is not null
			SET @gamebangLimitTime = @gamebangLimitTime + @limitTime
		IF @ipCount is null
			SET @ipCount = 0
			
		-- gamebangPaymentTypeId ??
		SET @gamebangPaymentTypeId = 0
		IF @startDt < @endDt AND @endDt > @now
			SET @gamebangPaymentTypeId = 1
		IF @gamebangLimitTime > @usedLimitTime
			SET @gamebangPaymentTypeId = @gamebangPaymentTypeId + 2
		
		IF @gamebangPaymentTypeId = 0
			SET  @gamebangPaymentTypeId = 2
		IF @gamebangGameServiceId is null
		BEGIN
			--tblGamebangGameService INSERT
			INSERT tblGamebangGameService(gamebangId, gameServiceId, gamebangPaymentTypeId, 
			ipCount, startDt, endDt, limitTime, usedLimitTime, registDt)
			VALUES(@gamebangId, @gameServiceId, @gamebangPaymentTypeId, @ipCount, @startDt, @endDt, @gamebangLimitTime, 0, @now)
			SET @gamebangGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
			--tblGamebangGameServiceHistory INSERT
			INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
				SELECT 
					@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
				FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
			SET @errorSave = @errorSave + @@ERROR		
		END
		ELSE
		BEGIN 
			IF @ipCount = 0 --(???)
			BEGIN
				--tblGamebangGameService UPDATE 
				UPDATE tblGamebangGameService SET gamebangPaymentTypeId=@gamebangPaymentTypeId,limitTime=@gamebangLimitTime,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END
			ELSE IF @ipCount > 0 AND @startDt = @now --(??? ??, ????)
			BEGIN
				--tblGamebangGameService UPDATE 
				UPDATE tblGamebangGameService
					SET gamebangPaymentTypeId=@gamebangPaymentTypeId,limitTime=@gamebangLimitTime,registDt=@now,ipCount=@ipCount
						,startDt= @startDt,endDt = @endDt
											
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END

/*
			IF @chargeTypeId = 4 OR @chargeTypeId = 5
			BEGIN
				INSERT tblGamebangSettlement(transactionId,gamebangId,receipt,chargeTypeId,startDt,endDt,registDt)
					VALUES(@transactionId,@gamebangId,@cashAmount,@chargeTypeId,@historyStartDt,@endDt,@now)
				SET @errorSave = @errorSave + @@ERROR
				INSERT tblGamebangSettlementHistory(transactionId, gamebangId, receipt, chargeTypeId, startDt, endDt, registDt, adminLogId)
					SELECT *,@adminLogId FROM tblGamebangSettlement with(rowLock) WHERE transactionId = @transactionId
				SET @errorSave = @errorSave + @@ERROR
			END
*/
/*			ELSE    --(??? ??, ??+??)
			BEGIN
				UPDATE tblGamebangGameService SET gamebangPaymentTypeId=@gamebangPaymentTypeId,	startDt=@startDt
					, endDt=@endDt, limitTime=@gamebangLimitTime,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
		
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				-- tblGamebangGameServiceReservation Insert
				INSERT tblGamebangGameServiceReservation(transactionId, gamebangGameServiceId, gamebangId, gameServiceId, productId, startDt, endDt, updateDt, isUpdate, isCancel)
				VALUES(@transactionId, @gamebangGameServiceId, @gamebangId, @gameServiceId, @productId, @startDt, @endDt, @historyStartDt, 0, 0)
				SET @errorSave = @errorSave + @@ERROR
			END
*/

		END
	END
END
IF @errorSave <> 0
	SET @transactionId = -401
GO
/****** Object:  StoredProcedure [dbo].[procOrderCancelBackUp]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procOrderCancel    Script Date: 23/1/2546 11:40:28 ******/
/*
	Creation Date		:	2002. 4. 03.
	Written by		:	? ??
	E-Mail by 		:	windist@n-cash.net
*/
CREATE PROCEDURE [dbo].[procOrderCancelBackUp]
	@orderTransactionId		as	int
,	@adminLogId				as	int
,	@transactionId			as	int	output
as
DECLARE @transactionTypeId	as	tinyInt
DECLARE @productId		as	int
DECLARE @productTypeId	as	tinyInt
DECLARE @periodTypeId	as	tinyInt
DECLARE @ipCount		as	tinyInt
DECLARE @productPeriod	as	int
DECLARE @startDt		as	DateTime
DECLARE @endDt		as	DateTime
DECLARE @limitTime		as	int
DECLARE @applyStartTime	as	nchar(4)
DECLARE @applyEndTime	as	nchar(4)
DECLARE @playableMinutes	as	smallInt
DECLARE @isGame			as	bit
DECLARE @isGamebangProduct	as	bit
DECLARE @userTypeId		as	tinyInt
DECLARE @cashAmount		as	int
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @pointBalance		as	int
DECLARE @now			as	datetime
DECLARE @temp			as	int
DECLARE @errorSave		as	int
DECLARE @peerTransactionId	as	int
DECLARE @userNumber		as	int
DECLARE @cpId			as	int
DECLARE @gameServiceId		as	int
DECLARE @historyTransactionId	as	int
DECLARE @userGameServiceId	as	int
DECLARE @gamebangGameServiceId	as	int
DECLARE @userLimitTime		as	int
DECLARE @gamebangLimitTime		as	int
DECLARE @userApplyStartTime	as	nchar(4)
DECLARE @userApplyEndTime	as	nchar(4)
DECLARE @usedLimitTime	as	int
DECLARE @gamebangPaymentTypeId	as	tinyInt
DECLARE @gamebangId		as	int
DECLARE @userStatusId		as	tinyInt
DECLARE @productPoint		as	int
Set @transactionTypeId = 6
Set @now = getDate()
Set @errorSave = 0
Set @userStatusId = 2
-- SELECT tblTransaction
SELECT
	@userNumber = t.userNumber,@cpId = t.cpId,@cashAmount = t.cashAmount, @peerTransactionId = t.peerTransactionId, @productId = o.productId
FROM
	tblTransaction as t with(nolock),tblOrder as o with(nolock)
WHERE
	t.transactionId = o.transactionId AND t.transactionId = @orderTransactionId AND t.peerTransactionId = null
IF @peerTransactionId is not null
BEGIN
	SET @transactionId = -505
	RETURN
END
IF @userNumber is null
BEGIN
	SET @transactionId = -207
	RETURN
END
--tblProduct SELECT
SELECT
	@cashAmount = p.productAmount,@productPoint=productPoint,@productTypeId=p.productTypeId,@ipCount=p.ipCount,@periodTypeId=p.periodTypeId,
	@productPeriod=p.productPeriod,@limitTime=p.limitTime,@applyStartTime=p.applyStartTime,@applyEndTime=p.applyEndTime,
	@playableMinutes =p.playableMinutes,@isGame = pt.isGame, @isGamebangProduct = isGamebangProduct
FROM tblProduct as p with(nolock),tblCodeProductType as pt with(nolock)
WHERE p.productTypeId = pt.productTypeId AND p.productId = @productId and p.apply = 1
IF @productTypeId is null
BEGIN
	SET @transactionId = -203
	RETURN
END
-- SELECT tblUser
SELECT
	@userStatusId = userStatusId,@userTypeId=userTypeId,@cashBalance= cashBalance ,@pointToCashBalance=pointToCashBalance,@pointBalance=pointBalance
FROM tblUserInfo WHERE userNumber = @userNumber AND apply = 1
IF @cashBalance is null
BEGIN
	SET @transactionId = -201
	RETURN
END
IF @pointBalance < @productPoint
BEGIN
	SET @pointBalance = 0
	SET @productPoint = @pointBalance
END
ELSE
	SET @pointBalance = @pointBalance - @productPoint
-- INSERT tblTransaction
INSERT
	tblTransaction(transactionTypeId, userNumber, cpId, cashAmount,pointAmount, cashBalance, pointToCashBalance, pointBalance, registDt, adminLogId, peerTransactionId)
VALUES(@transactionTypeId, @userNumber, @cpId, @cashAmount,-@productPoint, @cashBalance+@cashAmount, @pointToCashBalance, @pointBalance, @now, @adminLogId, @orderTransactionId)
SET @errorSave = @errorSave + @@ERROR
SET @transactionId = @@IDENTITY
-- UPDATE tblTransaction
UPDATE tblTransaction SET peerTransactionId = @transactionId WHERE transactionId = @orderTransactionId
SET @errorSave = @errorSave + @@ERROR
--INSERT tblOrder
INSERT tblOrder(transactionId,chargeTransactionId,productId,orderNumber,orderTypeId,primeCost,eventId)
	SELECT @transactionId,chargeTransactionId,productId,orderNumber,orderTypeId,primeCost,eventId
	FROM tblOrder with(nolock) WHERE transactionId = @orderTransactionId
SET @errorSave = @errorSave + @@ERROR
IF @errorSave <> 0 
BEGIN
	SET @transactionId = -401
	RETURN
END
IF @isGame = 1 -- ??? ????
BEGIN
	IF @userTypeId <> 9 --?? ???
	BEGIN
		
		--SELECT @userGameServiceId
		SELECT @userGameServiceId = userGameServiceId FROM tblUserGameServiceHistory with(nolock) WHERE transactionId = @orderTransactionId
		
		--SELECT tblUserGameService
		SELECT @startDt = startDt, @endDt = endDt,@userLimitTime = limitTime,@usedLimitTime=usedLimitTime
				,@userApplyStartTime = applyStartTime,@userApplyEndTime = applyEndTime
		FROM tblUserGameService with(rowlock) WHERE userGameServiceId = @userGameServiceId
		
		--SELECT tblUserGameServiceHistory
		SELECT TOP 1 @playableMinutes=ugs.playableMinutes
		FROM tblOrder as o with(nolock) , tblUserGameServiceHistory as ugs with(nolock)
		WHERE
			o.transactionId = ugs.transactionId AND o.transactionId < @orderTransactionId AND ugs.userGameServiceId = @userGameServiceId
		ORDER BY o.transactionId DESC
		--???? ??
		IF @productPeriod is not null
		BEGIN
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,-@productPeriod,@endDt)
		END
		IF @limitTime is not null
			SET @userLimitTime = @userLimitTime - @limitTime
		
		IF @endDt < @now --???????
		BEGIN
			SET @startDt = null
			SET @endDt = null
			SET @userApplyStartTime = '0000'
			SET @userApplyEndTime = '2400'
		END
		IF @playableMinutes is null
			SET @playableMinutes = 0
		
		--UPDATE tblUserGameService
		UPDATE tblUserGameService SET startDt = @startDt,endDt = @endDt,limitTime = @userLimitTime
						,applyStartTime = @userApplyStartTime,applyEndTime = @userApplyEndTime
						,playableMinutes = @playableMinutes,registDt = @now
		WHERE userGameServiceId = @userGameServiceId
		SET @errorSave = @errorSave + @@ERROR
		--INSERT tblUserGameServiceHistory
		INSERT tblUserGameServiceHistory(transactionId,userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt)
			SELECT @transactionId,userGameServiceId, userNumber, gameServiceId,@startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt
			FROM tblUserGameService with(rowLock) WHERE userGameServiceId = @userGameServiceId
		SET @errorSave = @errorSave + @@ERROR
		
		DELETE tblPackage Where transactionId = @orderTransactionId
		
		IF @startDt is null AND @userLimitTime <= @usedLimitTime and @userStatusId = 2
			SET @userStatusId = 1
	END
	ELSE --?? ????
	BEGIN
	
		--SELECT @gamebangGameServiceId
		SELECT @gamebangGameServiceId=gamebangGameServiceId
		FROM tblGamebangGameServiceHistory with(nolock)
		WHERE transactionId = @orderTransactionId
		
		--SELECT tblGamebangGameService
		SELECT @ipCount = ipCount, @startDt=startDt,@endDt = endDt,@gamebangLimitTime=limitTime,@usedLimitTime = usedLimitTime
		FROM tblGamebangGameService with(nolock)
		WHERE gamebangGameServiceId=@gamebangGameServiceId
		--?? ??
		IF @productPeriod is not null
		BEGIN
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,-@productPeriod,@endDt)
		END
		IF @limitTime is not null
			SET @gamebangLimitTime = @gamebangLimitTime - @limitTime
		
		IF @startDt > @endDt or @endDt < @now --???????
		BEGIN
			SET @startDt = null
			SET @endDt = null
			SET @ipCount = 0
		END
		
		SET @gamebangPaymentTypeId = 1
		IF @gamebangLimitTime > @usedLimitTime
		BEGIN
			IF @endDt is null --???? ????
				SET @gamebangPaymentTypeId = 0
			SET @gamebangPaymentTypeId = @gamebangPaymentTypeId + 2
		END
		--UPDATE tblGamebangGameService
		UPDATE tblGamebangGameService
			SET gamebangPaymentTypeId = @gamebangPaymentTypeId,startDt = @startDt
				,endDt = @endDt,ipCount = @ipCount,limitTime = @gamebangLimitTime ,registDt = @now
		WHERE gamebangGameServiceId = @gamebangGameServiceId
		SET @errorSave = @errorSave + @@ERROR
		
		--INSERT tblGamebangGameServiceHistory
		INSERT tblGamebangGameServiceHistory(transactionId,gamebangGameServiceId,gamebangId,gameServiceId,gamebangPaymentTypeId,ipCount
				, startDt, endDt, limitTime, usedLimitTime, registDt)
			SELECT @transactionId,gamebangGameServiceId, gamebangId, gameServiceId,gamebangPaymentTypeId,ipCount,startDt, endDt, limitTime, usedLimitTime, registDt
			FROM tblGamebangGameService with(rowLock) WHERE gamebangGameServiceId = @gamebangGameServiceId
		SET @errorSave = @errorSave + @@ERROR
		
		--UPDATE tblGamebangGameServiceReservation
		UPDATE tblGamebangGameServiceReservation SET isCancel = 1 WHERE transactionId = @orderTransactionId
		IF @errorSave <> 0
		BEGIN
			SET @transactionId = -401
			RETURN
		END
		
		IF @startDt is null and @gamebangLimitTime <= @usedLimitTime and @userStatusId = 2
			SET @userStatusId = 1
	END
END
IF @errorSave <> 0 
BEGIN
	SET @transactionId = -401
	RETURN
END
-- UPDATE USERINFO
UPDATE tblUserInfo SET cashBalance = @cashBalance+@cashAmount,userStatusId = @userStatusId,pointBalance=@pointBalance WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
-- UPDATE USER
UPDATE tblUserInfo SET userStatusId = @userStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
IF @errorSave > 0
	SET @transactionId = -401
GO
/****** Object:  StoredProcedure [dbo].[procOrderCancel]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Creation Date		:	2002. 4. 03.
	Written by		:	? ??
	E-Mail by 		:	windist@n-cash.net
*/
CREATE PROCEDURE [dbo].[procOrderCancel]
	@orderTransactionId		as	int
,	@adminLogId				as	int
,	@transactionId			as	int	output
as
DECLARE @transactionTypeId	as	tinyInt
DECLARE @productId		as	int
DECLARE @productTypeId	as	tinyInt
DECLARE @periodTypeId	as	tinyInt
DECLARE @ipCount		as	tinyInt
DECLARE @productPeriod	as	int
DECLARE @startDt		as	DateTime
DECLARE @endDt		as	DateTime
DECLARE @limitTime		as	int
DECLARE @applyStartTime	as	char(4)
DECLARE @applyEndTime	as	char(4)
DECLARE @playableMinutes	as	smallInt
DECLARE @isGame			as	bit
DECLARE @isGamebangProduct	as	bit
DECLARE @userTypeId		as	tinyInt
DECLARE @cashAmount		as	int
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @pointBalance		as	int
DECLARE @now			as	datetime
DECLARE @temp			as	int
DECLARE @errorSave		as	int
DECLARE @peerTransactionId	as	int
DECLARE @userNumber		as	int
DECLARE @cpId			as	int
DECLARE @gameServiceId		as	int
DECLARE @historyTransactionId	as	int
DECLARE @userGameServiceId	as	int
DECLARE @gamebangGameServiceId	as	int
DECLARE @userLimitTime		as	int
DECLARE @gamebangLimitTime		as	int
DECLARE @userApplyStartTime	as	char(4)
DECLARE @userApplyEndTime	as	char(4)
DECLARE @usedLimitTime	as	int
DECLARE @gamebangPaymentTypeId	as	tinyInt
DECLARE @gamebangId		as	int
DECLARE @userStatusId		as	tinyInt
DECLARE @productPoint		as	int
Set @transactionTypeId = 6
Set @now = getDate()
Set @errorSave = 0
Set @userStatusId = 2
-- SELECT tblTransaction
SELECT
	@userNumber = t.userNumber,@cpId = t.cpId,@cashAmount = t.cashAmount, @peerTransactionId = t.peerTransactionId, @productId = o.productId
FROM
	tblTransaction as t with(nolock),tblOrder as o with(nolock)
WHERE
	t.transactionId = o.transactionId AND t.transactionId = @orderTransactionId AND t.peerTransactionId = null
IF @peerTransactionId is not null
BEGIN
	SET @transactionId = -505
	RETURN
END
IF @userNumber is null
BEGIN
	SET @transactionId = -207
	RETURN
END
--tblProduct SELECT
SELECT
	@cashAmount = p.productAmount,@productPoint=productPoint,@productTypeId=p.productTypeId,@ipCount=p.ipCount,@periodTypeId=p.periodTypeId,
	@productPeriod=p.productPeriod,@limitTime=p.limitTime,@applyStartTime=p.applyStartTime,@applyEndTime=p.applyEndTime,
	@playableMinutes =p.playableMinutes,@isGame = pt.isGame, @isGamebangProduct = isGamebangProduct
FROM tblProduct as p with(nolock),tblCodeProductType as pt with(nolock)
WHERE p.productTypeId = pt.productTypeId AND p.productId = @productId and p.apply = 1
IF @productTypeId is null
BEGIN
	SET @transactionId = -203
	RETURN
END
-- SELECT tblUser
SELECT
	@userStatusId = userStatusId,@userTypeId=userTypeId,@cashBalance= cashBalance ,@pointToCashBalance=pointToCashBalance,@pointBalance=pointBalance
FROM tblUserInfo WHERE userNumber = @userNumber AND apply = 1
IF @cashBalance is null
BEGIN
	SET @transactionId = -201
	RETURN
END
IF @pointBalance < @productPoint
BEGIN
	SET @pointBalance = 0
	SET @productPoint = @pointBalance
END
ELSE
	SET @pointBalance = @pointBalance - @productPoint
-- INSERT tblTransaction
INSERT
	tblTransaction(transactionTypeId, userNumber, cpId, cashAmount,pointAmount, cashBalance, pointToCashBalance, pointBalance, registDt, adminLogId, peerTransactionId)
VALUES(@transactionTypeId, @userNumber, @cpId, @cashAmount,-@productPoint, @cashBalance+@cashAmount, @pointToCashBalance, @pointBalance, @now, @adminLogId, @orderTransactionId)
SET @errorSave = @errorSave + @@ERROR
SET @transactionId = @@IDENTITY
-- UPDATE tblTransaction
UPDATE tblTransaction SET peerTransactionId = @transactionId WHERE transactionId = @orderTransactionId
SET @errorSave = @errorSave + @@ERROR
--INSERT tblOrder
INSERT tblOrder(transactionId,chargeTransactionId,productId,orderNumber,orderTypeId,primeCost,eventId)
	SELECT @transactionId,chargeTransactionId,productId,orderNumber,orderTypeId,primeCost,eventId
	FROM tblOrder with(nolock) WHERE transactionId = @orderTransactionId
SET @errorSave = @errorSave + @@ERROR
IF @errorSave <> 0 
BEGIN
	SET @transactionId = -401
	RETURN
END
IF @isGame = 1 -- ??? ????
BEGIN
	IF @userTypeId <> 9 --?? ???
	BEGIN
		
		--SELECT @userGameServiceId
		SELECT @userGameServiceId = userGameServiceId FROM tblUserGameServiceHistory with(nolock) WHERE transactionId = @orderTransactionId
		
		--SELECT tblUserGameService
		SELECT @startDt = startDt, @endDt = endDt,@userLimitTime = limitTime,@usedLimitTime=usedLimitTime
				,@userApplyStartTime = applyStartTime,@userApplyEndTime = applyEndTime
		FROM tblUserGameService with(rowlock) WHERE userGameServiceId = @userGameServiceId
		
		--SELECT tblUserGameServiceHistory
		SELECT TOP 1 @playableMinutes=ugs.playableMinutes
		FROM tblOrder as o with(nolock) , tblUserGameServiceHistory as ugs with(nolock)
		WHERE
			o.transactionId = ugs.transactionId AND o.transactionId < @orderTransactionId AND ugs.userGameServiceId = @userGameServiceId
		ORDER BY o.transactionId DESC
		--???? ??
		IF @productPeriod is not null
		BEGIN
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,-@productPeriod,@endDt)
		END
		IF @limitTime is not null
			SET @userLimitTime = @userLimitTime - @limitTime
		
		IF @endDt < @now --???????
		BEGIN
			SET @startDt = null
			SET @endDt = null
			SET @userApplyStartTime = '0000'
			SET @userApplyEndTime = '2400'
		END
		IF @playableMinutes is null
			SET @playableMinutes = 0
		
		--UPDATE tblUserGameService
		UPDATE tblUserGameService SET startDt = @startDt,endDt = @endDt,limitTime = @userLimitTime
						,applyStartTime = @userApplyStartTime,applyEndTime = @userApplyEndTime
						,playableMinutes = @playableMinutes,registDt = @now
		WHERE userGameServiceId = @userGameServiceId
		SET @errorSave = @errorSave + @@ERROR
		--INSERT tblUserGameServiceHistory
		INSERT tblUserGameServiceHistory(transactionId,userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt)
			SELECT @transactionId,userGameServiceId, userNumber, gameServiceId,@startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt
			FROM tblUserGameService with(rowLock) WHERE userGameServiceId = @userGameServiceId
		SET @errorSave = @errorSave + @@ERROR
		
		DELETE tblPackage Where transactionId = @orderTransactionId
		
		IF @startDt is null AND @userLimitTime <= @usedLimitTime and @userStatusId = 2
			SET @userStatusId = 1
	END
	ELSE --?? ????
	BEGIN
	
		--SELECT @gamebangGameServiceId
		SELECT @gamebangGameServiceId=gamebangGameServiceId
		FROM tblGamebangGameServiceHistory with(nolock)
		WHERE transactionId = @orderTransactionId
		
		--SELECT tblGamebangGameService
		SELECT @ipCount = ipCount, @startDt=startDt,@endDt = endDt,@gamebangLimitTime=limitTime,@usedLimitTime = usedLimitTime
		FROM tblGamebangGameService with(nolock)
		WHERE gamebangGameServiceId=@gamebangGameServiceId
		--?? ??
		IF @productPeriod is not null
		BEGIN
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,-@productPeriod,@endDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,-@productPeriod,@endDt)
		END
		IF @limitTime is not null
			SET @gamebangLimitTime = @gamebangLimitTime - @limitTime
		
		IF @startDt > @endDt or @endDt < @now --???????
		BEGIN
			SET @startDt = null
			SET @endDt = null
			SET @ipCount = 0
		END
		
		SET @gamebangPaymentTypeId = 1
		IF @gamebangLimitTime > @usedLimitTime
		BEGIN
			IF @endDt is null --???? ????
				SET @gamebangPaymentTypeId = 0
			SET @gamebangPaymentTypeId = @gamebangPaymentTypeId + 2
		END
		IF NOT EXISTS( SELECT *  FROM   tblGamebangGameServiceReservation WHERE transactionId = @orderTransactionId and isUpdate = 0 and isCancel=0)
		BEGIN
			--UPDATE tblGamebangGameService
			UPDATE tblGamebangGameService
				SET gamebangPaymentTypeId = @gamebangPaymentTypeId,startDt = @startDt
					,endDt = @endDt,ipCount = @ipCount,limitTime = @gamebangLimitTime ,registDt = @now
			WHERE gamebangGameServiceId = @gamebangGameServiceId
			SET @errorSave = @errorSave + @@ERROR
		END
		--INSERT tblGamebangGameServiceHistory
		INSERT tblGamebangGameServiceHistory(transactionId,gamebangGameServiceId,gamebangId,gameServiceId,gamebangPaymentTypeId,ipCount
				, startDt, endDt, limitTime, usedLimitTime, registDt)
			SELECT @transactionId,gamebangGameServiceId, gamebangId, gameServiceId,gamebangPaymentTypeId,ipCount,startDt, endDt, limitTime, usedLimitTime, registDt
			FROM tblGamebangGameService with(rowLock) WHERE gamebangGameServiceId = @gamebangGameServiceId
		SET @errorSave = @errorSave + @@ERROR
		
		--UPDATE tblGamebangGameServiceReservation
		UPDATE tblGamebangGameServiceReservation SET isCancel = 1 WHERE transactionId = @orderTransactionId
		IF @errorSave <> 0
		BEGIN
			SET @transactionId = -401
			RETURN
		END
		
		IF @startDt is null and @gamebangLimitTime <= @usedLimitTime and @userStatusId = 2
			SET @userStatusId = 1
	END
END
IF @errorSave <> 0 
BEGIN
	SET @transactionId = -401
	RETURN
END
-- UPDATE USERINFO
UPDATE tblUserInfo SET cashBalance = @cashBalance+@cashAmount,userStatusId = @userStatusId,pointBalance=@pointBalance WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
-- UPDATE USER
UPDATE tblUserInfo SET userStatusId = @userStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
IF @errorSave > 0
	SET @transactionId = -401
GO
/****** Object:  StoredProcedure [dbo].[procOrderByItemBill_LimitDate_TEST]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procOrderByItemBill_LimitDate_TEST]
	@userNumber			as	int
,	@cpId				as	int
,	@gameServiceId		as	int
,	@productId			as	int
,	@chargeTransactionId		as	int
,	@orderNumber			as	varChar(32)
,	@orderTypeId			as	tinyInt
,	@primeCost			as	int
,	@eventId			as	int
,	@adminLogId			as	int
,	@transactionId			as	int	output
--with encryption 
as
DECLARE @cashAmount		as	int
DECLARE @pointToCashAmount	as	int
DECLARE @userTypeId			as	tinyInt
DECLARE @userStatusId		as	tinyInt
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @holdCashBalance		as	int
DECLARE @pointBalance		as	int
DECLARE @now			as	datetime
DECLARE @transactionTypeId		as	tinyInt
DECLARE @canOrder			as	bit
DECLARE @productTypeId		as	tinyInt
DECLARE @ipCount			as	tinyInt
DECLARE @periodTypeId		as	tinyInt
DECLARE @productPeriod		as	int
DECLARE @limitTime			as	int
DECLARE @applyStartTime		as	char(4)
DECLARE @applyEndTime		as	char(4)
DECLARE @playableMinutes		as	smallInt
DECLARE @userApplyStartTime		as	char(4)
DECLARE @userApplyEndTime		as	char(4)
DECLARE @userPlayableMinutes	as	smallInt
DECLARE @userGameServiceId		as	int
DECLARE @startDt			as	DateTime
DECLARE @endDt			as	DateTime
DECLARE @userLimitTime		as	int
DECLARE @usedLimitTime		as	int
DECLARE @usedPlayableMinutes	as	smallInt
DECLARE @updateUserStatusId 	as	tinyInt
DECLARE @isGame			as	bit
DECLARE @temp 			as	int
DECLARE @userCpId			as	int
DECLARE @errorSave			as	int
DECLARE @gamebangId		as	int
DECLARE @historyStartDt 		as	DateTime
DECLARE @gamebangGameServiceId	as	int
DECLARE @gamebangPaymentTypeId	as	tinyInt
DECLARE @gamebangLimitTime		as	int
DECLARE @chargeTypeId		as	tinyInt
DECLARE @isGamebangProduct 	as	bit
DECLARE @productPoint		as	int
DECLARE @expireDt			as	DATETIME
DECLARE @historyExpireDt		as	DATETIME
DECLARE @expireDayLength		as	int
-- for limit of gametime : start
DECLARE @limitDate			as	datetime
DECLARE @dateDiff			as	int
-- end

SET @errorSave = 0
SET @now = getDate()
-- for limit of gametime : start
SET @limitDate = DATEADD(Year, 1, @now)
-- end
SET @expireDayLength = 7 

SET @transactionTypeId = 2 --??
SET @updateUserStatusId = 2 --????? ?? userStatusId
--tblUser Select
SELECT
	@temp = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,
	@pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance
FROM tblUserInfo with(rowlock) WHERE userNumber = @userNumber and apply = 1
IF @temp is null
BEGIN
	Set @transactionId = -201 --user ??
	RETURN
END
--userStatus Check
SELECT @canOrder = canOrder FROM tblCodeUserStatus with(nolock) WHERE userStatusId = @userStatusId
IF @canOrder = 0
BEGIN
	Set @transactionId = -501 --???? ?? ???
	RETURN
END
	
--tblProduct SELECT
SELECT
	@cashAmount = p.productAmount,@productPoint=productPoint,@productTypeId=p.productTypeId,@ipCount=p.ipCount,@periodTypeId=p.periodTypeId,
	@productPeriod=p.productPeriod,@limitTime=p.limitTime,@applyStartTime=p.applyStartTime,@applyEndTime=p.applyEndTime,
	@playableMinutes =p.playableMinutes,@isGame = pt.isGame, @isGamebangProduct = isGamebangProduct
FROM tblProduct as p with(nolock),tblCodeProductType as pt with(nolock)
WHERE p.productTypeId = pt.productTypeId AND p.productId = @productId and p.apply = 1
IF @cashAmount is null
BEGIN
	Set @transactionId = -203 --????
	RETURN
END

-- ??
SET @cashBalance = @cashBalance - @cashAmount
IF @pointToCashBalance > @cashAmount
BEGIN
	SET @pointToCashAmount	=	@cashAmount
	SET @pointToCashBalance = @pointToCashBalance - @cashAmount
END
ELSE
BEGIN
	SET @pointToCashAmount	= @pointToCashBalance
	SET @pointToCashBalance = 0
END
SET @pointBalance = @pointBalance + @productPoint
			
IF @cashBalance < @holdCashBalance
BEGIN
	Set @transactionId = -502 --? ??
	RETURN
END
--Admin..
IF @adminLogId = 0
BEGIN
	SET @adminLogId = null
END
IF @chargeTransactionId = 0
BEGIN
	SET @chargeTransactionId = null
END
IF @orderNumber = ''
BEGIN
	SET @orderNumber = null
END
IF @primeCost = 0
BEGIN
	SET @primeCost = null
END
IF @eventId = 0
BEGIN
	SET @eventId = null
END
IF @isGame is null
BEGIN
	SET @transactionId = -206 --??? productType
END
--tblTransaction Insert
INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,pointAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
VALUES(@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@productPoint,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
SET @errorSave = @errorSave + @@ERROR	
--SET Return Value
SET @transactionId = @@IDENTITY
		
--tblOrder Insert
INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)
VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@productTypeId,@cashAmount,@eventId)
SET @errorSave = @errorSave + @@ERROR	

--tblUserInfo Update
UPDATE tblUserInfo SET cashBalance=@cashBalance,pointToCashBalance=@pointToCashBalance,pointBalance=@pointBalance,userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR

--tblUser Update
UPDATE tblUser SET userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
--tblUserHistory Insert
IF @errorSave <> 0
BEGIN
	SET @transactionId = -401
	RETURN
END
--??????
IF @isGame = 1
BEGIN
	IF @userTypeId <> 9 --userType Check
	BEGIN
	-- ??? ??
		IF @isGamebangProduct = 1
		BEGIN
			SET @transactionId = -507
			RETURN
		END
		SELECT
			@userGameServiceId=userGameServiceId,@startDt=startDt,@endDt=endDt,@userLimitTime=limitTime,@usedLimitTime = usedLimitTime,
			@userApplyStartTime = applyStartTime, @userApplyEndTime = applyEndTime,@userPlayableMinutes=playableMinutes, @historyExpireDt=expireDt
		FROM tblUserGameService with(rowlock) WHERE userNumber = @userNumber and gameServiceId = @gameServiceId
		IF @userLimitTime is null
			SET @userLimitTime = 0
		IF @usedLimitTime is null
			SET @usedLimitTime = 0
		IF @userApplyStartTime is null
			SET @userApplyStartTime = '0000'
		IF @userApplyEndTime is null
			SET @userApplyEndTime = '2400'
		IF @userPlayableMinutes is null
			SET @userPlayableMinutes = 0
		SET @expireDt = @historyExpireDt
		
		--?? ??
		IF @productPeriod is not null
		BEGIN
			IF @startDt is null
			BEGIN
				SET @startDt = @now
				SET @endDt = @now
			END
			
			IF @endDt <= @now
			BEGIN
				SET @startDt = @now
				SET @historyStartDt = @now
			END
			ELSE
			BEGIN
				SET @historyStartDt = @endDt
			END
			
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,@productPeriod,@historyStartDt)
		END
		ELSE
		BEGIN
			IF @startDt is null  
			BEGIN
				SET @startDt = NULL
				SET @endDt = NULL
				SET @historyStartDt = NULL
			END
			ELSE
			BEGIN
				SET @historyStartDt = @startDt
			END				
		END

		IF @limitTime is not null
			BEGIN
				IF @productTypeId = 8  --????? ?? ?? ??  ???
				BEGIN 	
					SET @userLimitTime = @userLimitTime + @limitTime
					SET @expireDt = dateadd(dd, @expireDayLength,@now)
				END
				ELSE
				BEGIN
					SET @userLimitTime = @userLimitTime + @limitTime
					SET @expireDt = dateadd(dd,@expireDayLength ,@now)
					IF @historyExpireDt is not  null
					BEGIN
						IF @historyExpireDt > @expireDt  
						BEGIN
							SET @expireDt = @historyExpireDt
						END 
					END
				END			
			END

		IF @applyStartTime is null
			SET @applyStartTime = '0000'
		IF @applyEndTime is null
			SET @applyEndTime = '2400'
		IF @playableMinutes is null
			SET @playableMinutes = 0

		
		--******************************************************

		--IF @now  > '2005-09-23 00:00:00' and  @now < '2005-12-01 00:00:00'
		--BEGIN
			--IF @productId = 1018
			--BEGIN
			--	IF @startDt is null
			--	BEGIN
			--		SET @startDt = @now
			--		SET @endDt = @now
			--	END
				
			--	IF @endDt <= @now
			--	BEGIN
			--		SET @startDt = @now
			--		SET @historyStartDt = @now
			--	END
			--	ELSE
			--	BEGIN
			--		SET @historyStartDt = @endDt
			--	END		
		
			--	SET @periodTypeId = 2
			--	SET @productPeriod =  3
			--	SET @userLimitTime = @userLimitTime - @limitTime
			--	SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)	
			--	SET @expireDt = null
			--END
		
		--END
		
		--******************************************************

		IF @endDt IS NOT NULL
		BEGIN
			SELECT @dateDiff = DATEDIFF(day, @endDt, @limitDate)
			IF @dateDiff > 365
			BEGIN
				SET @transactionId = -505 -- Over the limit date(1Year)
				RETURN		
			END
			--SELECT @dateDiff, @transactionId
		END
			
		IF @userGameServiceId is null
		BEGIN --????
			--tblUserGameService INSERT
			INSERT tblUserGameService(userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
			VALUES(@userNumber, @gameServiceId, @startDt, @endDt, @userLimitTime, 0, @applyStartTime, @applyEndTime, @playableMinutes,0, @now, @expireDt)
			SET  @userGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
		END
		ELSE
		BEGIN -- ??? ??? ??
			
			--tblUserGameService UPDATE
			UPDATE tblUserGameService
			SET startDt = @startDt, endDt = @endDt, limitTime = @userLimitTime, applyStartTime = @applyStartTime, applyEndTime = @applyEndTime, playableMinutes = @playableMinutes, registDt = @now, expireDt = @expireDt
			WHERE userNumber = @userNumber and gameServiceId = @gameServiceId
			SET @errorSave = @errorSave + @@ERROR
		END -- ??? ??? ??
					
		--tblUserGameServiceHistory Insert
		INSERT tblUserGameServiceHistory(transactionId,userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
			SELECT @transactionId,userGameServiceId, userNumber, gameServiceId,@historyStartDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt
			FROM tblUserGameService with(rowLock) WHERE userGameServiceId = @userGameServiceId
		SET @errorSave = @errorSave + @@ERROR

		
		--Package ????
		--IF @productTypeId = 9 or @productTypeId = 10
		--BEGIN
		--	INSERT tblPackage(transactionId,userNumber,productId,validDt)
		--		VALUES(@transactionId,@userNumber,@productId,DATEADD(mm,12,@historyStartDt))
		--END
	END
	ELSE -- ?? ??
	BEGIN 
		IF @isGamebangProduct = 0
		BEGIN
			SET @transactionId = -506
			RETURN
		END
		-- ??? ?? ??
		SET @gamebangId = @userCpId
		
		--tblGamebangGameService SELECT
		SELECT 
			@gamebangGameServiceId = gamebangGameServiceId,@usedLimitTime = usedLimitTime,@startDt=startDt
			, @endDt=endDt, @gamebangLimitTime=limitTime
		FROM tblGamebangGameService with(rowLock)
		WHERE gamebangId = @gamebangId AND gameServiceId = @gameServiceId
		
		IF @gamebangLimitTime is null
			SET @gamebangLimitTime = 0
		IF @usedLimitTime is null
			SET @usedLimitTime = 0
		SET @historyStartDt = @startDt
		IF @productPeriod is not null
		BEGIN
			IF @startDt is null
			BEGIN
				SET @startDt = @now
				SET @endDt = @now
			END
			IF @endDt <= @now
			BEGIN
				SET @startDt = @now
				SET @historyStartDt = @startDt
			END
			ELSE
			BEGIN
				SET @historyStartDt = @endDt
			END
			
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,@productPeriod,@historyStartDt)
			--SET @endDt = Left(@endDt,10) + ' 00:00:00' -- ??? 00:00:00 ?? ??.
			SET @endDt = Left(@endDt, 10) + ' 23:59:00'
		END
		IF @limitTime is not null
			SET @gamebangLimitTime = @gamebangLimitTime + @limitTime
		IF @ipCount is null
			SET @ipCount = 0
			
		-- gamebangPaymentTypeId ??
		SET @gamebangPaymentTypeId = 0
		IF @startDt < @endDt AND @endDt > @now
			SET @gamebangPaymentTypeId = 1
		IF @gamebangLimitTime > @usedLimitTime
			SET @gamebangPaymentTypeId = @gamebangPaymentTypeId + 2
		
		IF @gamebangPaymentTypeId = 0
			SET  @gamebangPaymentTypeId = 2
		IF @gamebangGameServiceId is null
		BEGIN
			--tblGamebangGameService INSERT
			INSERT tblGamebangGameService(gamebangId, gameServiceId, gamebangPaymentTypeId, 
			ipCount, startDt, endDt, limitTime, usedLimitTime, registDt)
			VALUES(@gamebangId, @gameServiceId, @gamebangPaymentTypeId, @ipCount, @startDt, @endDt, @gamebangLimitTime, 0, @now)
			SET @gamebangGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
			--tblGamebangGameServiceHistory INSERT
			INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
				SELECT 
					@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
				FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
			SET @errorSave = @errorSave + @@ERROR		
		END
		ELSE
		BEGIN 
			IF @ipCount = 0 --(???)
			BEGIN
				--tblGamebangGameService UPDATE 
				UPDATE tblGamebangGameService SET gamebangPaymentTypeId=@gamebangPaymentTypeId,limitTime=@gamebangLimitTime,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END
			ELSE IF @ipCount > 0 AND @startDt = @now --(??? ??, ????)
			BEGIN
				--tblGamebangGameService UPDATE 
				UPDATE tblGamebangGameService
					SET gamebangPaymentTypeId=@gamebangPaymentTypeId,limitTime=@gamebangLimitTime,registDt=@now,ipCount=@ipCount
						,startDt= @startDt,endDt = @endDt
											
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END
			ELSE    --(??? ??, ??+??)
			BEGIN
				UPDATE tblGamebangGameService SET gamebangPaymentTypeId=@gamebangPaymentTypeId,	startDt=@startDt
					, endDt=@endDt, limitTime=@gamebangLimitTime,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
		
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				-- tblGamebangGameServiceReservation Insert
			END



/*
			IF @chargeTypeId = 4 OR @chargeTypeId = 5
			BEGIN
				INSERT tblGamebangSettlement(transactionId,gamebangId,receipt,chargeTypeId,startDt,endDt,registDt)
					VALUES(@transactionId,@gamebangId,@cashAmount,@chargeTypeId,@historyStartDt,@endDt,@now)
				SET @errorSave = @errorSave + @@ERROR
				INSERT tblGamebangSettlementHistory(transactionId, gamebangId, receipt, chargeTypeId, startDt, endDt, registDt, adminLogId)
					SELECT *,@adminLogId FROM tblGamebangSettlement with(rowLock) WHERE transactionId = @transactionId
				SET @errorSave = @errorSave + @@ERROR
			END
*/

		END
	END
END
IF @errorSave <> 0
	SET @transactionId = -401
GO
/****** Object:  StoredProcedure [dbo].[procOrderByItemBill]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procOrderByItemBill]
	@userNumber			as	int
,	@cpId				as	int
,	@gameServiceId		as	int
,	@productId			as	int
,	@chargeTransactionId		as	int
,	@orderNumber			as	varChar(32)
,	@orderTypeId			as	tinyInt
,	@primeCost			as	int
,	@eventId			as	int
,	@adminLogId			as	int
,	@transactionId			as	int	output
--with encryption 
as
DECLARE @cashAmount		as	int
DECLARE @pointToCashAmount	as	int
DECLARE @userTypeId			as	tinyInt
DECLARE @userStatusId		as	tinyInt
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @holdCashBalance		as	int
DECLARE @pointBalance		as	int
DECLARE @now			as	datetime
DECLARE @transactionTypeId		as	tinyInt
DECLARE @canOrder			as	bit
DECLARE @productTypeId		as	tinyInt
DECLARE @ipCount			as	tinyInt
DECLARE @periodTypeId		as	tinyInt
DECLARE @productPeriod		as	int
DECLARE @limitTime			as	int
DECLARE @applyStartTime		as	char(4)
DECLARE @applyEndTime		as	char(4)
DECLARE @playableMinutes		as	smallInt
DECLARE @userApplyStartTime		as	char(4)
DECLARE @userApplyEndTime		as	char(4)
DECLARE @userPlayableMinutes	as	smallInt
DECLARE @userGameServiceId		as	int
DECLARE @startDt			as	DateTime
DECLARE @endDt			as	DateTime
DECLARE @userLimitTime		as	int
DECLARE @usedLimitTime		as	int
DECLARE @usedPlayableMinutes	as	smallInt
DECLARE @updateUserStatusId 	as	tinyInt
DECLARE @isGame			as	bit
DECLARE @temp 			as	int
DECLARE @userCpId			as	int
DECLARE @errorSave			as	int
DECLARE @gamebangId		as	int
DECLARE @historyStartDt 		as	DateTime
DECLARE @gamebangGameServiceId	as	int
DECLARE @gamebangPaymentTypeId	as	tinyInt
DECLARE @gamebangLimitTime		as	int
DECLARE @chargeTypeId		as	tinyInt
DECLARE @isGamebangProduct 	as	bit
DECLARE @productPoint		as	int
DECLARE @expireDt			as	DATETIME
DECLARE @historyExpireDt		as	DATETIME
DECLARE @expireDayLength		as	int

SET @errorSave = 0
SET @now = getDate()
SET @expireDayLength = 7 

SET @transactionTypeId = 2 --??
SET @updateUserStatusId = 2 --????? ?? userStatusId
--tblUser Select
SELECT
	@temp = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,
	@pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance
FROM tblUserInfo with(rowlock) WHERE userNumber = @userNumber and apply = 1
IF @temp is null
BEGIN
	Set @transactionId = -201 --user ??
	RETURN
END

	
--tblProduct SELECT
SELECT
	@cashAmount = p.productAmount,@productPoint=productPoint,@productTypeId=p.productTypeId,@ipCount=p.ipCount,@periodTypeId=p.periodTypeId,
	@productPeriod=p.productPeriod,@limitTime=p.limitTime,@applyStartTime=p.applyStartTime,@applyEndTime=p.applyEndTime,
	@playableMinutes =p.playableMinutes,@isGame = pt.isGame, @isGamebangProduct = isGamebangProduct
FROM tblProduct as p with(nolock),tblCodeProductType as pt with(nolock)
WHERE p.productTypeId = pt.productTypeId AND p.productId = @productId and p.apply = 1
IF @cashAmount is null
BEGIN
	Set @transactionId = -203 --????
	RETURN
END

-- ??
SET @cashBalance = @cashBalance - @cashAmount
IF @pointToCashBalance > @cashAmount
BEGIN
	SET @pointToCashAmount	=	@cashAmount
	SET @pointToCashBalance = @pointToCashBalance - @cashAmount
END
ELSE
BEGIN
	SET @pointToCashAmount	= @pointToCashBalance
	SET @pointToCashBalance = 0
END
SET @pointBalance = @pointBalance + @productPoint
			
IF @cashBalance < @holdCashBalance
BEGIN
	Set @transactionId = -502 --? ??
	RETURN
END
--Admin..
IF @adminLogId = 0
BEGIN
	SET @adminLogId = null
END
IF @chargeTransactionId = 0
BEGIN
	SET @chargeTransactionId = null
END
IF @orderNumber = ''
BEGIN
	SET @orderNumber = null
END
IF @primeCost = 0
BEGIN
	SET @primeCost = null
END
IF @eventId = 0
BEGIN
	SET @eventId = null
END
IF @isGame is null
BEGIN
	SET @transactionId = -206 --??? productType
END
--tblTransaction Insert
INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,pointAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
VALUES(@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@productPoint,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
SET @errorSave = @errorSave + @@ERROR	
--SET Return Value
SET @transactionId = @@IDENTITY
		
--tblOrder Insert
INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)
VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@productTypeId,@cashAmount,@eventId)
SET @errorSave = @errorSave + @@ERROR	

--tblUserInfo Update
UPDATE tblUserInfo SET cashBalance=@cashBalance,pointToCashBalance=@pointToCashBalance,pointBalance=@pointBalance,userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR

--tblUser Update
UPDATE tblUser SET userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
--tblUserHistory Insert
IF @errorSave <> 0
BEGIN
	SET @transactionId = -401
	RETURN
END
--??????
IF @isGame = 1
BEGIN
	IF @userTypeId <> 9 --userType Check
	BEGIN
	-- ??? ??
		IF @isGamebangProduct = 1
		BEGIN
			SET @transactionId = -507
			RETURN
		END
		SELECT
			@userGameServiceId=userGameServiceId,@startDt=startDt,@endDt=endDt,@userLimitTime=limitTime,@usedLimitTime = usedLimitTime,
			@userApplyStartTime = applyStartTime, @userApplyEndTime = applyEndTime,@userPlayableMinutes=playableMinutes, @historyExpireDt=expireDt
		FROM tblUserGameService with(rowlock) WHERE userNumber = @userNumber and gameServiceId = @gameServiceId
		IF @userLimitTime is null
			SET @userLimitTime = 0
		IF @usedLimitTime is null
			SET @usedLimitTime = 0
		IF @userApplyStartTime is null
			SET @userApplyStartTime = '0000'
		IF @userApplyEndTime is null
			SET @userApplyEndTime = '2400'
		IF @userPlayableMinutes is null
			SET @userPlayableMinutes = 0
		SET @expireDt = @historyExpireDt
		
		--?? ??
		IF @productPeriod is not null
		BEGIN
			IF @startDt is null
			BEGIN
				SET @startDt = @now
				SET @endDt = @now
			END
			
			IF @endDt <= @now
			BEGIN
				SET @startDt = @now
				SET @historyStartDt = @now
			END
			ELSE
			BEGIN
				SET @historyStartDt = @endDt
			END
			
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,@productPeriod,@historyStartDt)
		END
		ELSE
		BEGIN
			IF @startDt is null  
			BEGIN
				SET @startDt = NULL
				SET @endDt = NULL
				SET @historyStartDt = NULL
			END
			ELSE
			BEGIN
				SET @historyStartDt = @startDt
			END				
		END

		IF @limitTime is not null
			BEGIN
				IF @productTypeId = 8  --????? ?? ?? ??  ???
				BEGIN 	
					SET @userLimitTime = @userLimitTime + @limitTime
					SET @expireDt = dateadd(dd, @expireDayLength,@now)
				END
				ELSE
				BEGIN
					SET @userLimitTime = @userLimitTime + @limitTime
					SET @expireDt = dateadd(dd,@expireDayLength ,@now)
					IF @historyExpireDt is not  null
					BEGIN
						IF @historyExpireDt > @expireDt  
						BEGIN
							SET @expireDt = @historyExpireDt
						END 
					END
				END			
			END

		IF @applyStartTime is null
			SET @applyStartTime = '0000'
		IF @applyEndTime is null
			SET @applyEndTime = '2400'
		IF @playableMinutes is null
			SET @playableMinutes = 0

		
		--******************************************************

		--IF @now  > '2005-09-23 00:00:00' and  @now < '2005-12-01 00:00:00'
		--BEGIN
			--IF @productId = 1018
			--BEGIN
			--	IF @startDt is null
			--	BEGIN
			--		SET @startDt = @now
			--		SET @endDt = @now
			--	END
				
			--	IF @endDt <= @now
			--	BEGIN
			--		SET @startDt = @now
			--		SET @historyStartDt = @now
			--	END
			--	ELSE
			--	BEGIN
			--		SET @historyStartDt = @endDt
			--	END		
		
			--	SET @periodTypeId = 2
			--	SET @productPeriod =  3
			--	SET @userLimitTime = @userLimitTime - @limitTime
			--	SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)	
			--	SET @expireDt = null
			--END
		
		--END
		
		--******************************************************

			
		IF @userGameServiceId is null
		BEGIN --????
			--tblUserGameService INSERT
			INSERT tblUserGameService(userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
			VALUES(@userNumber, @gameServiceId, @startDt, @endDt, @userLimitTime, 0, @applyStartTime, @applyEndTime, @playableMinutes,0, @now, @expireDt)
			SET  @userGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
		END
		ELSE
		BEGIN -- ??? ??? ??
			
			--tblUserGameService UPDATE
			UPDATE tblUserGameService
			SET startDt = @startDt, endDt = @endDt, limitTime = @userLimitTime, applyStartTime = @applyStartTime, applyEndTime = @applyEndTime, playableMinutes = @playableMinutes, registDt = @now, expireDt = @expireDt
			WHERE userNumber = @userNumber and gameServiceId = @gameServiceId
			SET @errorSave = @errorSave + @@ERROR
		END -- ??? ??? ??
					
		--tblUserGameServiceHistory Insert
		INSERT tblUserGameServiceHistory(transactionId,userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
			SELECT @transactionId,userGameServiceId, userNumber, gameServiceId,@historyStartDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt
			FROM tblUserGameService with(rowLock) WHERE userGameServiceId = @userGameServiceId
		SET @errorSave = @errorSave + @@ERROR

		
		--Package ????
		--IF @productTypeId = 9 or @productTypeId = 10
		--BEGIN
		--	INSERT tblPackage(transactionId,userNumber,productId,validDt)
		--		VALUES(@transactionId,@userNumber,@productId,DATEADD(mm,12,@historyStartDt))
		--END
	END
	ELSE -- ?? ??
	BEGIN 
		IF @isGamebangProduct = 0
		BEGIN
			SET @transactionId = -506
			RETURN
		END
		-- ??? ?? ??
		SET @gamebangId = @userCpId
		
		--tblGamebangGameService SELECT
		SELECT 
			@gamebangGameServiceId = gamebangGameServiceId,@usedLimitTime = usedLimitTime,@startDt=startDt
			, @endDt=endDt, @gamebangLimitTime=limitTime
		FROM tblGamebangGameService with(rowLock)
		WHERE gamebangId = @gamebangId AND gameServiceId = @gameServiceId
		
		IF @gamebangLimitTime is null
			SET @gamebangLimitTime = 0
		IF @usedLimitTime is null
			SET @usedLimitTime = 0
		SET @historyStartDt = @startDt
		IF @productPeriod is not null
		BEGIN
			IF @startDt is null
			BEGIN
				SET @startDt = @now
				SET @endDt = @now
			END
			IF @endDt <= @now
			BEGIN
				SET @startDt = @now
				SET @historyStartDt = @startDt
			END
			ELSE
			BEGIN
				SET @historyStartDt = @endDt
			END
			
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,@productPeriod,@historyStartDt)
			--SET @endDt = Left(@endDt,10) + ' 00:00:00' -- ??? 00:00:00 ?? ??.
			SET @endDt = Left(@endDt, 10) + ' 23:59:00'
		END
		IF @limitTime is not null
			SET @gamebangLimitTime = @gamebangLimitTime + @limitTime
		IF @ipCount is null
			SET @ipCount = 0
			
		-- gamebangPaymentTypeId ??
		SET @gamebangPaymentTypeId = 0
		IF @startDt < @endDt AND @endDt > @now
			SET @gamebangPaymentTypeId = 1
		IF @gamebangLimitTime > @usedLimitTime
			SET @gamebangPaymentTypeId = @gamebangPaymentTypeId + 2
		
		IF @gamebangPaymentTypeId = 0
			SET  @gamebangPaymentTypeId = 2
		IF @gamebangGameServiceId is null
		BEGIN
			--tblGamebangGameService INSERT
			INSERT tblGamebangGameService(gamebangId, gameServiceId, gamebangPaymentTypeId, 
			ipCount, startDt, endDt, limitTime, usedLimitTime, registDt)
			VALUES(@gamebangId, @gameServiceId, @gamebangPaymentTypeId, @ipCount, @startDt, @endDt, @gamebangLimitTime, 0, @now)
			SET @gamebangGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
			--tblGamebangGameServiceHistory INSERT
			INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
				SELECT 
					@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
				FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
			SET @errorSave = @errorSave + @@ERROR		
		END
		ELSE
		BEGIN 
			IF @ipCount = 0 --(???)
			BEGIN
				--tblGamebangGameService UPDATE 
				UPDATE tblGamebangGameService SET gamebangPaymentTypeId=@gamebangPaymentTypeId,limitTime=@gamebangLimitTime,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END
			ELSE IF @ipCount > 0 AND @startDt = @now --(??? ??, ????)
			BEGIN
				--tblGamebangGameService UPDATE 
				UPDATE tblGamebangGameService
					SET gamebangPaymentTypeId=@gamebangPaymentTypeId,limitTime=@gamebangLimitTime,registDt=@now,ipCount=@ipCount
						,startDt= @startDt,endDt = @endDt
											
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END
			ELSE    --(??? ??, ??+??)
			BEGIN
				UPDATE tblGamebangGameService SET gamebangPaymentTypeId=@gamebangPaymentTypeId,	startDt=@startDt
					, endDt=@endDt, limitTime=@gamebangLimitTime,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
		
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				-- tblGamebangGameServiceReservation Insert
			END



/*
			IF @chargeTypeId = 4 OR @chargeTypeId = 5
			BEGIN
				INSERT tblGamebangSettlement(transactionId,gamebangId,receipt,chargeTypeId,startDt,endDt,registDt)
					VALUES(@transactionId,@gamebangId,@cashAmount,@chargeTypeId,@historyStartDt,@endDt,@now)
				SET @errorSave = @errorSave + @@ERROR
				INSERT tblGamebangSettlementHistory(transactionId, gamebangId, receipt, chargeTypeId, startDt, endDt, registDt, adminLogId)
					SELECT *,@adminLogId FROM tblGamebangSettlement with(rowLock) WHERE transactionId = @transactionId
				SET @errorSave = @errorSave + @@ERROR
			END
*/

		END
	END
END
IF @errorSave <> 0
	SET @transactionId = -401
GO
/****** Object:  StoredProcedure [dbo].[procOrderByAuctionAndWebItem_TEST]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procOrderByAuctionAndWebItem_TEST]
--	@userNumber		as	int
	@userId		as	nvarchar(52)
,	@cpId			as	int
,	@gameServiceId		as	int
,	@productId		as	int
,	@cashAmount		as	int
,	@transactionTypeId	as	tinyint
,	@description		as	varchar(200)	= NULL
,	@transactionId		as	int		output
,	@message		as	varchar(50)	output
--with encryption 
as

DECLARE @pointToCashAmount	as	int
,	@userTypeId		as	tinyInt
,	@userStatusId		as	tinyInt
,	@cashBalance		as	int
,	@pointToCashBalance	as	int
,	@holdCashBalance	as	int
,	@pointBalance		as	int
,	@now			as	datetime
--,	@transactionTypeId	as	tinyInt
,	@canOrder		as	bit
,	@productTypeId		as	tinyInt
,	@updateUserStatusId 	as	tinyInt
,	@temp 			as	int
,	@userCpId		as	int
,	@errorSave		as	int
,	@productPoint		as	int
,	@adminLogId		as	int
,	@chargeTransactionId	as	int
,	@orderNumber		as	int
,	@primeCost		as	int
,	@eventId			as	int
,	@userNumber		as	int


SET @errorSave = 0
SET @now = getDate()

--SET @transactionTypeId = 11 -- ??
--SET @transactionTypeId = 12 -- ??? ? ???

SET @updateUserStatusId = 2 --????? ?? userStatusId


--tblUser Select
SELECT
	@userNumber = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,
	@pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance
FROM tblUserInfo with(rowlock) WHERE userId = @userId and apply = 1
IF @userNumber is null
BEGIN
	SET @transactionId = -201 --user ??
	SET @message = 'Inexistent user'
	RETURN
END
--userStatus Check
SELECT @canOrder = canOrder FROM tblCodeUserStatus with(nolock) WHERE userStatusId = @userStatusId
IF @canOrder = 0
BEGIN
	SET @transactionId = -202 --???? ?? ???
	SET @message = 'The user can not payment'
	RETURN
END

IF @cashAmount is null
BEGIN
	SET @transactionId = -203 --????
	SET @message = 'Abnormal amount'
	RETURN
END
	
--tblProduct SELECT
SELECT
	@productPoint=productPoint,@productTypeId=p.productTypeId
	
FROM tblProduct as p with(nolock),tblCodeProductType as pt with(nolock)

WHERE p.productTypeId = pt.productTypeId AND p.productId = @productId and p.apply = 1
IF @productPoint is null
BEGIN
	SET @transactionId = -204 --?? ??
	SET @message = 'Inexistent productId'
	RETURN
END

-- ??
SET @cashBalance = @cashBalance - @cashAmount
IF @pointToCashBalance > @cashAmount
BEGIN
	SET @pointToCashAmount	=	@cashAmount
	SET @pointToCashBalance = @pointToCashBalance - @cashAmount
END
ELSE
BEGIN
	SET @pointToCashAmount	= @pointToCashBalance
	SET @pointToCashBalance = 0
END
SET @pointBalance = @pointBalance + @productPoint
			
IF @cashBalance < @holdCashBalance
BEGIN
	SET @transactionId = -502 --? ??
	SET @message = 'cash shortage'
	RETURN
END
--Admin..

SET @adminLogId = null
SET @chargeTransactionId = null
SET @orderNumber = null
SET @primeCost = null
SET @eventId = null

--tblTransaction Insert
INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,pointAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
VALUES(@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@productPoint,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
SET @errorSave = @errorSave + @@ERROR	
--SET Return Value
SET @transactionId = @@IDENTITY

IF @description IS NOT NULL
BEGIN
	IF @transactionTypeId = 11
	BEGIN
		INSERT INTO tblAuctionDescription(transactionId, description) VALUES(@transactionId, @description)
		SET @errorSave = @errorSave + @@ERROR	
	END
	ELSE IF @transactionTypeId = 12
	BEGIN
		INSERT INTO tblWebItemDescription(transactionId, description) VALUES(@transactionId, @description)
		SET @errorSave = @errorSave + @@ERROR	
	END
END
		
		
--tblOrder Insert
INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)
VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@productTypeId,@cashAmount,@eventId)
SET @errorSave = @errorSave + @@ERROR	

--tblUserInfo Update
UPDATE tblUserInfo SET cashBalance=@cashBalance,pointToCashBalance=@pointToCashBalance,pointBalance=@pointBalance,userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR

--tblUser Update
UPDATE tblUser SET userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR

IF @errorSave <> 0
BEGIN
	SET @transactionId = -401
	SET @message = 'Sql statement error'
	RETURN
END
ELSE
BEGIN
	SET @message = 'success'
END
GO
/****** Object:  StoredProcedure [dbo].[procOrderByAuctionAndWebItem]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procOrderByAuctionAndWebItem]
--	@userNumber		as	int
	@userId		as	nvarchar(52)
,	@cpId			as	int
,	@gameServiceId		as	int
,	@productId		as	int
,	@cashAmount		as	int
,	@transactionTypeId	as	tinyint
,	@description		as	varchar(200)	= NULL
,	@transactionId		as	int		output
,	@message		as	varchar(50)	output
--with encryption 
as

DECLARE @pointToCashAmount	as	int
,	@userTypeId		as	tinyInt
,	@userStatusId		as	tinyInt
,	@cashBalance		as	int
,	@pointToCashBalance	as	int
,	@holdCashBalance	as	int
,	@pointBalance		as	int
,	@now			as	datetime
--,	@transactionTypeId	as	tinyInt
,	@canOrder		as	bit
,	@productTypeId		as	tinyInt
,	@updateUserStatusId 	as	tinyInt
,	@temp 			as	int
,	@userCpId		as	int
,	@errorSave		as	int
,	@productPoint		as	int
,	@adminLogId		as	int
,	@chargeTransactionId	as	int
,	@orderNumber		as	int
,	@primeCost		as	int
,	@eventId			as	int
,	@userNumber		as	int


SET @errorSave = 0
SET @now = getDate()

--SET @transactionTypeId = 11 -- ??
--SET @transactionTypeId = 12 -- ??? ? ???

SET @updateUserStatusId = 2 --????? ?? userStatusId


--tblUser Select
SELECT
	@userNumber = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,
	@pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance
FROM tblUserInfo with(rowlock) WHERE userId = @userId and apply = 1
IF @userNumber is null
BEGIN
	SET @transactionId = -201 --user ??
	SET @message = 'Inexistent user'
	RETURN
END
--userStatus Check
SELECT @canOrder = canOrder FROM tblCodeUserStatus with(nolock) WHERE userStatusId = @userStatusId
IF @canOrder = 0
BEGIN
	SET @transactionId = -202 --???? ?? ???
	SET @message = 'The user can not payment'
	RETURN
END

IF @cashAmount is null
BEGIN
	SET @transactionId = -203 --????
	SET @message = 'Abnormal amount'
	RETURN
END
	
--tblProduct SELECT
SELECT
	@productPoint=productPoint,@productTypeId=p.productTypeId
	
FROM tblProduct as p with(nolock),tblCodeProductType as pt with(nolock)

WHERE p.productTypeId = pt.productTypeId AND p.productId = @productId and p.apply = 1
IF @productPoint is null
BEGIN
	SET @transactionId = -204 --?? ??
	SET @message = 'Inexistent productId'
	RETURN
END

-- ??
SET @cashBalance = @cashBalance - @cashAmount
IF @pointToCashBalance > @cashAmount
BEGIN
	SET @pointToCashAmount	=	@cashAmount
	SET @pointToCashBalance = @pointToCashBalance - @cashAmount
END
ELSE
BEGIN
	SET @pointToCashAmount	= @pointToCashBalance
	SET @pointToCashBalance = 0
END
SET @pointBalance = @pointBalance + @productPoint
			
IF @cashBalance < @holdCashBalance
BEGIN
	SET @transactionId = -502 --? ??
	SET @message = 'cash shortage'
	RETURN
END
--Admin..

SET @adminLogId = null
SET @chargeTransactionId = null
SET @orderNumber = null
SET @primeCost = null
SET @eventId = null

--tblTransaction Insert
INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,pointAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
VALUES(@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@productPoint,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
SET @errorSave = @errorSave + @@ERROR	
--SET Return Value
SET @transactionId = @@IDENTITY

IF @description IS NOT NULL
BEGIN
	IF @transactionTypeId = 11
	BEGIN
		INSERT INTO tblAuctionDescription(transactionId, description) VALUES(@transactionId, @description)
		SET @errorSave = @errorSave + @@ERROR	
	END
	ELSE IF @transactionTypeId = 12
	BEGIN
		INSERT INTO tblWebItemDescription(transactionId, description) VALUES(@transactionId, @description)
		SET @errorSave = @errorSave + @@ERROR	
	END
END
		
		
--tblOrder Insert
INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)
VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@productTypeId,@cashAmount,@eventId)
SET @errorSave = @errorSave + @@ERROR	

--tblUserInfo Update
UPDATE tblUserInfo SET cashBalance=@cashBalance,pointToCashBalance=@pointToCashBalance,pointBalance=@pointBalance,userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR

--tblUser Update
UPDATE tblUser SET userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR

IF @errorSave <> 0
BEGIN
	SET @transactionId = -401
	SET @message = 'Sql statement error'
	RETURN
END
ELSE
BEGIN
	SET @message = 'success'
END
GO
/****** Object:  StoredProcedure [dbo].[procOrderByAuction]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procOrderByAuction]
--	@userNumber		as	int
	@userId		as	nvarchar(52)
,	@cpId			as	int
,	@gameServiceId		as	int
,	@productId		as	int
,	@cashAmount		as	int
,	@transactionId		as	int		output
,	@message		as	varchar(50)	output
--with encryption 
as

DECLARE @pointToCashAmount	as	int
,	@userTypeId		as	tinyInt
,	@userStatusId		as	tinyInt
,	@cashBalance		as	int
,	@pointToCashBalance	as	int
,	@holdCashBalance	as	int
,	@pointBalance		as	int
,	@now			as	datetime
,	@transactionTypeId	as	tinyInt
,	@canOrder		as	bit
,	@productTypeId		as	tinyInt
,	@updateUserStatusId 	as	tinyInt
,	@temp 			as	int
,	@userCpId		as	int
,	@errorSave		as	int
,	@productPoint		as	int
,	@adminLogId		as	int
,	@chargeTransactionId	as	int
,	@orderNumber		as	int
,	@primeCost		as	int
,	@eventId			as	int
,	@userNumber		as	int


SET @errorSave = 0
SET @now = getDate()

SET @transactionTypeId = 11 -- ??
SET @updateUserStatusId = 2 --????? ?? userStatusId


--tblUser Select
SELECT
	@userNumber = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,
	@pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance
FROM tblUserInfo with(rowlock) WHERE userId = @userId and apply = 1
IF @userNumber is null
BEGIN
	SET @transactionId = -201 --user ??
	SET @message = 'Inexistent user'
	RETURN
END
--userStatus Check
SELECT @canOrder = canOrder FROM tblCodeUserStatus with(nolock) WHERE userStatusId = @userStatusId
IF @canOrder = 0
BEGIN
	SET @transactionId = -202 --???? ?? ???
	SET @message = 'The user can not payment'
	RETURN
END

IF @cashAmount is null
BEGIN
	SET @transactionId = -203 --????
	SET @message = 'Abnormal amount'
	RETURN
END
	
--tblProduct SELECT
SELECT
	@productPoint=productPoint,@productTypeId=p.productTypeId
	
FROM tblProduct as p with(nolock),tblCodeProductType as pt with(nolock)

WHERE p.productTypeId = pt.productTypeId AND p.productId = @productId and p.apply = 1
IF @productPoint is null
BEGIN
	SET @transactionId = -204 --?? ??
	SET @message = 'Inexistent productId'
	RETURN
END

-- ??
SET @cashBalance = @cashBalance - @cashAmount
IF @pointToCashBalance > @cashAmount
BEGIN
	SET @pointToCashAmount	=	@cashAmount
	SET @pointToCashBalance = @pointToCashBalance - @cashAmount
END
ELSE
BEGIN
	SET @pointToCashAmount	= @pointToCashBalance
	SET @pointToCashBalance = 0
END
SET @pointBalance = @pointBalance + @productPoint
			
IF @cashBalance < @holdCashBalance
BEGIN
	SET @transactionId = -502 --? ??
	SET @message = 'cash shortage'
	RETURN
END
--Admin..

SET @adminLogId = null
SET @chargeTransactionId = null
SET @orderNumber = null
SET @primeCost = null
SET @eventId = null

--tblTransaction Insert
INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,pointAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
VALUES(@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@productPoint,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
SET @errorSave = @errorSave + @@ERROR	
--SET Return Value
SET @transactionId = @@IDENTITY
		
--tblOrder Insert
INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)
VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@productTypeId,@cashAmount,@eventId)
SET @errorSave = @errorSave + @@ERROR	

--tblUserInfo Update
UPDATE tblUserInfo SET cashBalance=@cashBalance,pointToCashBalance=@pointToCashBalance,pointBalance=@pointBalance,userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR

--tblUser Update
UPDATE tblUser SET userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR

IF @errorSave <> 0
BEGIN
	SET @transactionId = -401
	SET @message = 'Sql statement error'
	RETURN
END
ELSE
BEGIN
	SET @message = 'success'
END
GO
/****** Object:  StoredProcedure [dbo].[procOrderBackUp]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	Stored Procedure	:	procOrder
	Creation Date		:	2002. 4. 03.
	Written by		:	? ??
	E-Mail by 		:	windist@n-cash.net
	Purpose			:	??? ??
	Input Parameters :	
	
			
	return?:
	@transactionId		as	integer		:	 ?? ????ID
	Call by		:	TransactionManager.Transaction.charge
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I)	, tblUserInfo(U)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procOrderBackUp]
	@userNumber				as	int
,	@cpId					as	int
,	@gameServiceId			as	int
,	@productId				as	int
,	@chargeTransactionId	as	int
,	@orderNumber			as	varChar(32)
,	@orderTypeId			as	tinyInt
,	@primeCost				as	int
,	@eventId				as	int
,	@adminLogId				as	int
,	@transactionId			as	int	output
as
DECLARE @cashAmount			as	int
DECLARE @pointToCashAmount	as	int
DECLARE @userTypeId			as	tinyInt
DECLARE @userStatusId		as	tinyInt
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @holdCashBalance	as	int
DECLARE @pointBalance		as	int
DECLARE @now				as	datetime
DECLARE @transactionTypeId	as	tinyInt
DECLARE @canOrder			as	bit
DECLARE @productTypeId		as	tinyInt
DECLARE @ipCount			as	tinyInt
DECLARE @periodTypeId		as	tinyInt
DECLARE @productPeriod		as	int
DECLARE @limitTime			as	int
DECLARE @applyStartTime		as	char(4)
DECLARE @applyEndTime		as	char(4)
DECLARE @playableMinutes	as	smallInt
DECLARE @userApplyStartTime		as	char(4)
DECLARE @userApplyEndTime		as	char(4)
DECLARE @userPlayableMinutes	as	smallInt
DECLARE @userGameServiceId	as	int
DECLARE @startDt			as	DateTime
DECLARE @endDt				as	DateTime
DECLARE @userLimitTime		as	int
DECLARE @usedLimitTime		as	int
DECLARE @usedPlayableMinutes	as	smallInt
DECLARE @updateUserStatusId 	as	tinyInt
DECLARE @isGame				as	bit
DECLARE @temp 				as	int
DECLARE @userCpId			as	int
DECLARE @errorSave			as	int
DECLARE @gamebangId			as	int
DECLARE @historyStartDt 		as	DateTime
DECLARE @gamebangGameServiceId	as	int
DECLARE @gamebangPaymentTypeId	as	tinyInt
DECLARE @gamebangLimitTime		as	int
DECLARE @chargeTypeId		as	tinyInt
DECLARE @isGamebangProduct as bit
DECLARE @productPoint	as int
DECLARE @expireDt				DATETIME
SET @errorSave = 0
SET @now = getDate()

SET @transactionTypeId = 2 --??
SET @updateUserStatusId = 2 --????? ?? userStatusId
--tblUser Select
SELECT
	@temp = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,
	@pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance
FROM tblUserInfo with(rowlock) WHERE userNumber = @userNumber and apply = 1
IF @temp is null
BEGIN
	Set @transactionId = -201 --user ??
	RETURN
END
--userStatus Check
SELECT @canOrder = canOrder FROM tblCodeUserStatus with(nolock) WHERE userStatusId = @userStatusId
IF @canOrder = 0
BEGIN
	Set @transactionId = -501 --???? ?? ???
	RETURN
END
	
--tblProduct SELECT
SELECT
	@cashAmount = p.productAmount,@productPoint=productPoint,@productTypeId=p.productTypeId,@ipCount=p.ipCount,@periodTypeId=p.periodTypeId,
	@productPeriod=p.productPeriod,@limitTime=p.limitTime,@applyStartTime=p.applyStartTime,@applyEndTime=p.applyEndTime,
	@playableMinutes =p.playableMinutes,@isGame = pt.isGame, @isGamebangProduct = isGamebangProduct
FROM tblProduct as p with(nolock),tblCodeProductType as pt with(nolock)
WHERE p.productTypeId = pt.productTypeId AND p.productId = @productId and p.apply = 1
IF @cashAmount is null
BEGIN
	Set @transactionId = -203 --????
	RETURN
END

IF @now  >  '2005-03-04 00:00:00' AND  @now < '2005-03-12 00:00:00'
BEGIN
	SET @now = '2005-03-12 00:00:00'
	SET @productPeriod = @productPeriod * 2
END 
-- ??
SET @cashBalance = @cashBalance - @cashAmount
IF @pointToCashBalance > @cashAmount
BEGIN
	SET @pointToCashAmount	=	@cashAmount
	SET @pointToCashBalance = @pointToCashBalance - @cashAmount
END
ELSE
BEGIN
	SET @pointToCashAmount	= @pointToCashBalance
	SET @pointToCashBalance = 0
END
SET @pointBalance = @pointBalance + @productPoint
			
IF @cashBalance < @holdCashBalance
BEGIN
	Set @transactionId = -502 --? ??
	RETURN
END
--Admin..
IF @adminLogId = 0
BEGIN
	SET @adminLogId = null
END
IF @chargeTransactionId = 0
BEGIN
	SET @chargeTransactionId = null
END
IF @orderNumber = ''
BEGIN
	SET @orderNumber = null
END
IF @primeCost = 0
BEGIN
	SET @primeCost = null
END
IF @eventId = 0
BEGIN
	SET @eventId = null
END
IF @isGame is null
BEGIN
	SET @transactionId = -206 --??? productType
END
--tblTransaction Insert
INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,pointAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
VALUES(@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@productPoint,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
SET @errorSave = @errorSave + @@ERROR	
--SET Return Value
SET @transactionId = @@IDENTITY
		
--tblOrder Insert
INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)
VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@productTypeId,@cashAmount,@eventId)
SET @errorSave = @errorSave + @@ERROR	
--tblUserInfo Update
UPDATE tblUserInfo SET cashBalance=@cashBalance,pointToCashBalance=@pointToCashBalance,pointBalance=@pointBalance,userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
--tblUser Update
UPDATE tblUser SET userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
--tblUserHistory Insert
IF @errorSave <> 0
BEGIN
	SET @transactionId = -401
	RETURN
END
--??????
IF @isGame = 1
BEGIN
	IF @userTypeId <> 9 --userType Check
	BEGIN
	-- ??? ??
		IF @isGamebangProduct = 1
		BEGIN
			SET @transactionId = -507
			RETURN
		END
		SELECT
			@userGameServiceId=userGameServiceId,@startDt=startDt,@endDt=endDt,@userLimitTime=limitTime,@usedLimitTime = usedLimitTime,
			@userApplyStartTime = applyStartTime, @userApplyEndTime = applyEndTime,@userPlayableMinutes=playableMinutes
		FROM tblUserGameService with(rowlock) WHERE userNumber = @userNumber and gameServiceId = @gameServiceId
		IF @userLimitTime is null
			SET @userLimitTime = 0
		IF @usedLimitTime is null
			SET @usedLimitTime = 0
		IF @userApplyStartTime is null
			SET @userApplyStartTime = '0000'
		IF @userApplyEndTime is null
			SET @userApplyEndTime = '2400'
		IF @userPlayableMinutes is null
			SET @userPlayableMinutes = 0
		--?? ??
		IF @productPeriod is not null
		BEGIN
			IF @startDt is null
			BEGIN
				SET @startDt = @now
				SET @endDt = @now
			END
			
			IF @endDt <= @now
			BEGIN
				SET @startDt = @now
				SET @historyStartDt = @now
			END
			ELSE
			BEGIN
				SET @historyStartDt = @endDt
			END
			
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,@productPeriod,@historyStartDt)
		END
		
		IF @limitTime is not null
			BEGIN
				SET @userLimitTime = @userLimitTime + @limitTime
				SET @expireDt = dateadd(dd, 7 , getdate())
			END
		ELSE
			BEGIN
				SET @expireDt = null
			END
		IF @applyStartTime is null
			SET @applyStartTime = '0000'
		IF @applyEndTime is null
			SET @applyEndTime = '2400'
		IF @playableMinutes is null
			SET @playableMinutes = 0
			
		IF @userGameServiceId is null
		BEGIN --????
			--tblUserGameService INSERT
			INSERT tblUserGameService(userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
			VALUES(@userNumber, @gameServiceId, @startDt, @endDt, @userLimitTime, 0, @applyStartTime, @applyEndTime, @playableMinutes,0, @now, @expireDt)
			SET  @userGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
		END
		ELSE
		BEGIN -- ??? ??? ??
			If @userApplyStartTime <> @applyStartTime OR @userApplyEndTime <> @applyEndTime AND @userPlayableMinutes <> @playableMinutes
			BEGIN
				IF @historyStartDt > @now
				BEGIN
					--SET @command = 'DECLARE @E as int ' + 'UPDATE tblUserGameService SET applyStartTime = ''' + @applyStartTime
					--				+ ''', applyEndTime = ''' + @applyEndTime + ''',playableMinutes = ' + @playableMinutes + ' WHERE userGameServiceId  = ' + cast(@userGameServiceId as varchar)
					--				+ ' SET @E = @E + @@ERROR IF @E <> 0 SELECT 1 ELSE SELECT 0'
					SET @errorSave = -555
				END --??? ?????? ?? 
			END --if apply  <> userApply
			
			--tblUserGameService UPDATE
			UPDATE tblUserGameService
			SET startDt = @startDt, endDt = @endDt, limitTime = @userLimitTime, applyStartTime = @applyStartTime, applyEndTime = @applyEndTime, playableMinutes = @playableMinutes, registDt = @now, expireDt = @expireDt
			WHERE userNumber = @userNumber and gameServiceId = @gameServiceId
			SET @errorSave = @errorSave + @@ERROR
		END -- ??? ??? ??
					
		--tblUserGameServiceHistory Insert
		INSERT tblUserGameServiceHistory(transactionId,userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
			SELECT @transactionId,userGameServiceId, userNumber, gameServiceId,@historyStartDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt
			FROM tblUserGameService with(rowLock) WHERE userGameServiceId = @userGameServiceId
		SET @errorSave = @errorSave + @@ERROR
		
		--Package ????
		IF @productTypeId = 9 or @productTypeId = 10
		BEGIN
			INSERT tblPackage(transactionId,userNumber,productId,validDt)
				VALUES(@transactionId,@userNumber,@productId,DATEADD(mm,12,@historyStartDt))
		END
	END
	ELSE -- ?? ??
	BEGIN 
		IF @isGamebangProduct = 0
		BEGIN
			SET @transactionId = -506
			RETURN
		END
		-- ??? ?? ??
		SET @gamebangId = @userCpId
		
		--tblGamebangGameService SELECT
		SELECT 
			@gamebangGameServiceId = gamebangGameServiceId,@usedLimitTime = usedLimitTime,@startDt=startDt
			, @endDt=endDt, @gamebangLimitTime=limitTime
		FROM tblGamebangGameService with(rowLock)
		WHERE gamebangId = @gamebangId AND gameServiceId = @gameServiceId
		
		IF @gamebangLimitTime is null
			SET @gamebangLimitTime = 0
		IF @usedLimitTime is null
			SET @usedLimitTime = 0
		SET @historyStartDt = @startDt
		IF @productPeriod is not null
		BEGIN
			IF @startDt is null
			BEGIN
				SET @startDt = @now
				SET @endDt = @now
			END
			IF @endDt <= @now
			BEGIN
				SET @startDt = @now
				SET @historyStartDt = @startDt
			END
			ELSE
			BEGIN
				SET @historyStartDt = @endDt
			END
			
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,@productPeriod,@historyStartDt)
			--SET @endDt = Left(@endDt,10) + ' 00:00:00' -- ??? 00:00:00 ?? ??.
			SET @endDt = Left(@endDt, 10) + ' 23:59:00'
		END
		IF @limitTime is not null
			SET @gamebangLimitTime = @gamebangLimitTime + @limitTime
		IF @ipCount is null
			SET @ipCount = 0
			
		-- gamebangPaymentTypeId ??
		SET @gamebangPaymentTypeId = 0
		IF @startDt < @endDt AND @endDt > @now
			SET @gamebangPaymentTypeId = 1
		IF @gamebangLimitTime > @usedLimitTime
			SET @gamebangPaymentTypeId = @gamebangPaymentTypeId + 2
		
		IF @gamebangPaymentTypeId = 0
			SET  @gamebangPaymentTypeId = 2
		IF @gamebangGameServiceId is null
		BEGIN
			--tblGamebangGameService INSERT
			INSERT tblGamebangGameService(gamebangId, gameServiceId, gamebangPaymentTypeId, 
			ipCount, startDt, endDt, limitTime, usedLimitTime, registDt)
			VALUES(@gamebangId, @gameServiceId, @gamebangPaymentTypeId, @ipCount, @startDt, @endDt, @gamebangLimitTime, 0, @now)
			SET @gamebangGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
			--tblGamebangGameServiceHistory INSERT
			INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
				SELECT 
					@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
				FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
			SET @errorSave = @errorSave + @@ERROR		
		END
		ELSE
		BEGIN 
			IF @ipCount = 0 --(???)
			BEGIN
				--tblGamebangGameService UPDATE 
				UPDATE tblGamebangGameService SET gamebangPaymentTypeId=@gamebangPaymentTypeId,limitTime=@gamebangLimitTime,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END
			ELSE IF @ipCount > 0 AND @startDt = @now --(??? ??, ????)
			BEGIN
				--tblGamebangGameService UPDATE 
				UPDATE tblGamebangGameService
					SET gamebangPaymentTypeId=@gamebangPaymentTypeId,limitTime=@gamebangLimitTime,registDt=@now,ipCount=@ipCount
						,startDt= @startDt,endDt = @endDt
											
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END

/*			ELSE    --(??? ??, ??+??)
			BEGIN
				UPDATE tblGamebangGameService SET gamebangPaymentTypeId=@gamebangPaymentTypeId,	startDt=@startDt
					, endDt=@endDt, limitTime=@gamebangLimitTime,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
		
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				-- tblGamebangGameServiceReservation Insert
				INSERT tblGamebangGameServiceReservation(transactionId, gamebangGameServiceId, gamebangId, gameServiceId, productId, startDt, endDt, updateDt, isUpdate, isCancel)
				VALUES(@transactionId, @gamebangGameServiceId, @gamebangId, @gameServiceId, @productId, @startDt, @endDt, @historyStartDt, 0, 0)
				SET @errorSave = @errorSave + @@ERROR
			END
*/

		END
	END
END
IF @errorSave <> 0
	SET @transactionId = -401
GO
/****** Object:  StoredProcedure [dbo].[procOrder]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procOrder]
	@userNumber				as	int
,	@cpId					as	int
,	@gameServiceId			as	int
,	@productId				as	int
,	@chargeTransactionId	as	int
,	@orderNumber			as	varChar(32)
,	@orderTypeId			as	tinyInt
,	@primeCost				as	int
,	@eventId				as	int
,	@adminLogId				as	int
,	@transactionId			as	int	output
--with encryption 
as
DECLARE @cashAmount			as	int
DECLARE @pointToCashAmount	as	int
DECLARE @userTypeId			as	tinyInt
DECLARE @userStatusId		as	tinyInt
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @holdCashBalance	as	int
DECLARE @pointBalance		as	int
DECLARE @now				as	datetime
DECLARE @transactionTypeId	as	tinyInt
DECLARE @canOrder			as	bit
DECLARE @productTypeId		as	tinyInt
DECLARE @ipCount			as	tinyInt
DECLARE @periodTypeId		as	tinyInt
DECLARE @productPeriod		as	int
DECLARE @limitTime			as	int
DECLARE @applyStartTime		as	char(4)
DECLARE @applyEndTime		as	char(4)
DECLARE @playableMinutes	as	smallInt
DECLARE @userApplyStartTime		as	char(4)
DECLARE @userApplyEndTime		as	char(4)
DECLARE @userPlayableMinutes	as	smallInt
DECLARE @userGameServiceId	as	int
DECLARE @startDt			as	DateTime
DECLARE @endDt				as	DateTime
DECLARE @userLimitTime		as	int
DECLARE @usedLimitTime		as	int
DECLARE @usedPlayableMinutes	as	smallInt
DECLARE @updateUserStatusId 	as	tinyInt
DECLARE @isGame				as	bit
DECLARE @temp 				as	int
DECLARE @userCpId			as	int
DECLARE @errorSave			as	int
DECLARE @gamebangId			as	int
DECLARE @historyStartDt 		as	DateTime
DECLARE @gamebangGameServiceId	as	int
DECLARE @gamebangPaymentTypeId	as	tinyInt
DECLARE @gamebangLimitTime		as	int
DECLARE @chargeTypeId		as	tinyInt
DECLARE @isGamebangProduct as bit
DECLARE @productPoint	as int
DECLARE @expireDt				DATETIME
DECLARE @historyExpireDt			DATETIME
DECLARE @expireDayLength			int

SET @errorSave = 0
SET @now = getDate()
SET @expireDayLength = 7 

SET @transactionTypeId = 2 --??
SET @updateUserStatusId = 2 --????? ?? userStatusId
--tblUser Select
SELECT
	@temp = userNumber,@userCpId = cpId, @userTypeId=userTypeId,@userStatusId=userStatusId,@cashBalance = cashBalance ,
	@pointToCashBalance = pointToCashBalance,@holdCashBalance = holdCashBalance, @pointBalance = pointBalance
FROM tblUserInfo with(rowlock) WHERE userNumber = @userNumber and apply = 1
IF @temp is null
BEGIN
	Set @transactionId = -201 --user ??
	RETURN
END
--userStatus Check
SELECT @canOrder = canOrder FROM tblCodeUserStatus with(nolock) WHERE userStatusId = @userStatusId
IF @canOrder = 0
BEGIN
	Set @transactionId = -501 --???? ?? ???
	RETURN
END
	
--tblProduct SELECT
SELECT
	@cashAmount = p.productAmount,@productPoint=productPoint,@productTypeId=p.productTypeId,@ipCount=p.ipCount,@periodTypeId=p.periodTypeId,
	@productPeriod=p.productPeriod,@limitTime=p.limitTime,@applyStartTime=p.applyStartTime,@applyEndTime=p.applyEndTime,
	@playableMinutes =p.playableMinutes,@isGame = pt.isGame, @isGamebangProduct = isGamebangProduct
FROM tblProduct as p with(nolock),tblCodeProductType as pt with(nolock)
WHERE p.productTypeId = pt.productTypeId AND p.productId = @productId and p.apply = 1
IF @cashAmount is null
BEGIN
	Set @transactionId = -203 --????
	RETURN
END

-- ??
SET @cashBalance = @cashBalance - @cashAmount
IF @pointToCashBalance > @cashAmount
BEGIN
	SET @pointToCashAmount	=	@cashAmount
	SET @pointToCashBalance = @pointToCashBalance - @cashAmount
END
ELSE
BEGIN
	SET @pointToCashAmount	= @pointToCashBalance
	SET @pointToCashBalance = 0
END
SET @pointBalance = @pointBalance + @productPoint
			
IF @cashBalance < @holdCashBalance
BEGIN
	Set @transactionId = -502 --? ??
	RETURN
END
--Admin..
IF @adminLogId = 0
BEGIN
	SET @adminLogId = null
END
IF @chargeTransactionId = 0
BEGIN
	SET @chargeTransactionId = null
END
IF @orderNumber = ''
BEGIN
	SET @orderNumber = null
END
IF @primeCost = 0
BEGIN
	SET @primeCost = null
END
IF @eventId = 0
BEGIN
	SET @eventId = null
END
IF @isGame is null
BEGIN
	SET @transactionId = -206 --??? productType
END
--tblTransaction Insert
INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,pointToCashAmount,pointAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
VALUES(@transactionTypeId,@userNumber,@cpId,-@cashAmount,-@pointToCashAmount,@productPoint,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
SET @errorSave = @errorSave + @@ERROR	
--SET Return Value
SET @transactionId = @@IDENTITY
		
--tblOrder Insert
INSERT tblOrder(transactionId, chargeTransactionId, productId, orderNumber, orderTypeId, primeCost, eventId)
VALUES(@transactionId,@chargeTransactionId, @productId, @orderNumber,@productTypeId,@cashAmount,@eventId)
SET @errorSave = @errorSave + @@ERROR	

--tblUserInfo Update
UPDATE tblUserInfo SET cashBalance=@cashBalance,pointToCashBalance=@pointToCashBalance,pointBalance=@pointBalance,userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR

--tblUser Update
UPDATE tblUser SET userStatusId = @updateUserStatusId WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
--tblUserHistory Insert
IF @errorSave <> 0
BEGIN
	SET @transactionId = -401
	RETURN
END
--??????
IF @isGame = 1
BEGIN
	IF @userTypeId <> 9 --userType Check
	BEGIN
	-- ??? ??
		IF @isGamebangProduct = 1
		BEGIN
			SET @transactionId = -507
			RETURN
		END
		SELECT
			@userGameServiceId=userGameServiceId,@startDt=startDt,@endDt=endDt,@userLimitTime=limitTime,@usedLimitTime = usedLimitTime,
			@userApplyStartTime = applyStartTime, @userApplyEndTime = applyEndTime,@userPlayableMinutes=playableMinutes, @historyExpireDt=expireDt
		FROM tblUserGameService with(rowlock) WHERE userNumber = @userNumber and gameServiceId = @gameServiceId
		IF @userLimitTime is null
			SET @userLimitTime = 0
		IF @usedLimitTime is null
			SET @usedLimitTime = 0
		IF @userApplyStartTime is null
			SET @userApplyStartTime = '0000'
		IF @userApplyEndTime is null
			SET @userApplyEndTime = '2400'
		IF @userPlayableMinutes is null
			SET @userPlayableMinutes = 0
		SET @expireDt = @historyExpireDt
		
		--?? ??
		IF @productPeriod is not null
		BEGIN
			IF @startDt is null
			BEGIN
				SET @startDt = @now
				SET @endDt = @now
			END
			
			IF @endDt <= @now
			BEGIN
				SET @startDt = @now
				SET @historyStartDt = @now
			END
			ELSE
			BEGIN
				SET @historyStartDt = @endDt
			END
			
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,@productPeriod,@historyStartDt)
		END
		ELSE
		BEGIN
			IF @startDt is null  
			BEGIN
				SET @startDt = NULL
				SET @endDt = NULL
				SET @historyStartDt = NULL
			END
			ELSE
			BEGIN
				SET @historyStartDt = @startDt
			END				
		END

		IF @limitTime is not null
			BEGIN
				IF @productTypeId = 8  --????? ?? ?? ??  ???
				BEGIN 	
					SET @userLimitTime = @userLimitTime + @limitTime
					SET @expireDt = dateadd(dd, @expireDayLength,@now)
				END
				ELSE
				BEGIN
					SET @userLimitTime = @userLimitTime + @limitTime
					SET @expireDt = dateadd(dd,@expireDayLength ,@now)
					IF @historyExpireDt is not  null
					BEGIN
						IF @historyExpireDt > @expireDt  
						BEGIN
							SET @expireDt = @historyExpireDt
						END 
					END
				END			
			END

		IF @applyStartTime is null
			SET @applyStartTime = '0000'
		IF @applyEndTime is null
			SET @applyEndTime = '2400'
		IF @playableMinutes is null
			SET @playableMinutes = 0

		
		--******************************************************

		--IF @now  > '2005-09-23 00:00:00' and  @now < '2005-12-01 00:00:00'
		--BEGIN
			--IF @productId = 1018
			--BEGIN
			--	IF @startDt is null
			--	BEGIN
			--		SET @startDt = @now
			--		SET @endDt = @now
			--	END
				
			--	IF @endDt <= @now
			--	BEGIN
			--		SET @startDt = @now
			--		SET @historyStartDt = @now
			--	END
			--	ELSE
			--	BEGIN
			--		SET @historyStartDt = @endDt
			--	END		
		
			--	SET @periodTypeId = 2
			--	SET @productPeriod =  3
			--	SET @userLimitTime = @userLimitTime - @limitTime
			--	SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)	
			--	SET @expireDt = null
			--END
		
		--END
		
		--******************************************************

			
		IF @userGameServiceId is null
		BEGIN --????
			--tblUserGameService INSERT
			INSERT tblUserGameService(userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
			VALUES(@userNumber, @gameServiceId, @startDt, @endDt, @userLimitTime, 0, @applyStartTime, @applyEndTime, @playableMinutes,0, @now, @expireDt)
			SET  @userGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
		END
		ELSE
		BEGIN -- ??? ??? ??
			
			--tblUserGameService UPDATE
			UPDATE tblUserGameService
			SET startDt = @startDt, endDt = @endDt, limitTime = @userLimitTime, applyStartTime = @applyStartTime, applyEndTime = @applyEndTime, playableMinutes = @playableMinutes, registDt = @now, expireDt = @expireDt
			WHERE userNumber = @userNumber and gameServiceId = @gameServiceId
			SET @errorSave = @errorSave + @@ERROR
		END -- ??? ??? ??
					
		--tblUserGameServiceHistory Insert
		INSERT tblUserGameServiceHistory(transactionId,userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
			SELECT @transactionId,userGameServiceId, userNumber, gameServiceId,@historyStartDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt
			FROM tblUserGameService with(rowLock) WHERE userGameServiceId = @userGameServiceId
		SET @errorSave = @errorSave + @@ERROR

		
		--Package ????
		--IF @productTypeId = 9 or @productTypeId = 10
		--BEGIN
		--	INSERT tblPackage(transactionId,userNumber,productId,validDt)
		--		VALUES(@transactionId,@userNumber,@productId,DATEADD(mm,12,@historyStartDt))
		--END
	END
	ELSE -- ?? ??
	BEGIN 
		IF @isGamebangProduct = 0
		BEGIN
			SET @transactionId = -506
			RETURN
		END
		-- ??? ?? ??
		SET @gamebangId = @userCpId
		
		--tblGamebangGameService SELECT
		SELECT 
			@gamebangGameServiceId = gamebangGameServiceId,@usedLimitTime = usedLimitTime,@startDt=startDt
			, @endDt=endDt, @gamebangLimitTime=limitTime
		FROM tblGamebangGameService with(rowLock)
		WHERE gamebangId = @gamebangId AND gameServiceId = @gameServiceId
		
		IF @gamebangLimitTime is null
			SET @gamebangLimitTime = 0
		IF @usedLimitTime is null
			SET @usedLimitTime = 0
		SET @historyStartDt = @startDt
		IF @productPeriod is not null
		BEGIN
			IF @startDt is null
			BEGIN
				SET @startDt = @now
				SET @endDt = @now
			END
			IF @endDt <= @now
			BEGIN
				SET @startDt = @now
				SET @historyStartDt = @startDt
			END
			ELSE
			BEGIN
				SET @historyStartDt = @endDt
			END
			
			IF @periodTypeId = 1
				SET @endDt = DATEADD(mm,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 2
				SET @endDt = DATEADD(dd,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 3
				SET @endDt = DATEADD(hh,@productPeriod,@historyStartDt)
			ELSE IF @periodTypeId = 4
				SET @endDt = DATEADD(mi,@productPeriod,@historyStartDt)
			--SET @endDt = Left(@endDt,10) + ' 00:00:00' -- ??? 00:00:00 ?? ??.
			SET @endDt = Left(@endDt, 10) + ' 23:59:00'
		END
		IF @limitTime is not null
			SET @gamebangLimitTime = @gamebangLimitTime + @limitTime
		IF @ipCount is null
			SET @ipCount = 0
			
		-- gamebangPaymentTypeId ??
		SET @gamebangPaymentTypeId = 0
		IF @startDt < @endDt AND @endDt > @now
			SET @gamebangPaymentTypeId = 1
		IF @gamebangLimitTime > @usedLimitTime
			SET @gamebangPaymentTypeId = @gamebangPaymentTypeId + 2
		
		IF @gamebangPaymentTypeId = 0
			SET  @gamebangPaymentTypeId = 2
		IF @gamebangGameServiceId is null
		BEGIN
			--tblGamebangGameService INSERT
			INSERT tblGamebangGameService(gamebangId, gameServiceId, gamebangPaymentTypeId, 
			ipCount, startDt, endDt, limitTime, usedLimitTime, registDt)
			VALUES(@gamebangId, @gameServiceId, @gamebangPaymentTypeId, @ipCount, @startDt, @endDt, @gamebangLimitTime, 0, @now)
			SET @gamebangGameServiceId = @@IDENTITY
			SET @errorSave = @errorSave + @@ERROR
			--tblGamebangGameServiceHistory INSERT
			INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
				SELECT 
					@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
				FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
			SET @errorSave = @errorSave + @@ERROR		
		END
		ELSE
		BEGIN 
			IF @ipCount = 0 --(???)
			BEGIN
				--tblGamebangGameService UPDATE 
				UPDATE tblGamebangGameService SET gamebangPaymentTypeId=@gamebangPaymentTypeId,limitTime=@gamebangLimitTime,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END
			ELSE IF @ipCount > 0 AND @startDt = @now --(??? ??, ????)
			BEGIN
				--tblGamebangGameService UPDATE 
				UPDATE tblGamebangGameService
					SET gamebangPaymentTypeId=@gamebangPaymentTypeId,limitTime=@gamebangLimitTime,registDt=@now,ipCount=@ipCount
						,startDt= @startDt,endDt = @endDt
											
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangId = @gamebangId and gameServiceId = @gameServiceId
				SET @errorSave = @errorSave + @@ERROR
			END
			ELSE    --(??? ??, ??+??)
			BEGIN
				UPDATE tblGamebangGameService SET gamebangPaymentTypeId=@gamebangPaymentTypeId,	startDt=@startDt
					, endDt=@endDt, limitTime=@gamebangLimitTime,registDt=@now
				WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
		
				--tblGamebangGameServiceHistory INSERT
				INSERT tblGamebangGameServiceHistory(transactionId, gamebangGameServiceId,gamebangId, gameServiceId, gamebangPaymentTypeId, ipCount, startDt, endDt, limitTime,usedLimitTime, registDt)
					SELECT 
						@transactionId, gamebangGameServiceId,gamebangId, gameServiceId, @gamebangPaymentTypeId, @ipCount, @historyStartDt, @endDt, @gamebangLimitTime,usedLimitTime, registDt 
					FROM tblGamebangGameService with(rowLock) WHERE gamebangGameServiceId = @gamebangGameServiceId
				SET @errorSave = @errorSave + @@ERROR
				-- tblGamebangGameServiceReservation Insert
			END



/*
			IF @chargeTypeId = 4 OR @chargeTypeId = 5
			BEGIN
				INSERT tblGamebangSettlement(transactionId,gamebangId,receipt,chargeTypeId,startDt,endDt,registDt)
					VALUES(@transactionId,@gamebangId,@cashAmount,@chargeTypeId,@historyStartDt,@endDt,@now)
				SET @errorSave = @errorSave + @@ERROR
				INSERT tblGamebangSettlementHistory(transactionId, gamebangId, receipt, chargeTypeId, startDt, endDt, registDt, adminLogId)
					SELECT *,@adminLogId FROM tblGamebangSettlement with(rowLock) WHERE transactionId = @transactionId
				SET @errorSave = @errorSave + @@ERROR
			END
*/

		END
	END
END
IF @errorSave <> 0
	SET @transactionId = -401
GO
/****** Object:  StoredProcedure [dbo].[procModifyAdminUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procModifyAdminUser    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procModifyAdminUser
	Creation Date		:	2002. 02. 18.
	Written by		:	???
	E-Mail by 		:	jsh001@n-cash.net
	Purpose			:	??? ??
	Input Parameters :	
		@memo				as		nvarchar(255)			:	??
			
	return?	:
	Return Status:
	Usage: 			
	Call by:
		modifyExec.asp
	Calls:
	 	Nothing
	Access Table :
	 	tblAdmin(U)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procModifyAdminUser]	
	@adminNumber				as int
,	@inputAdminName			as nvarchar(20)
,	@inputAdminPwd			as nvarchar(16)
,	@inputType				as int
as
UPDATE tblAdmin
SET adminName = @inputAdminName, adminPwd = @inputAdminPwd, adminTypeId = @inputType, registDt = getDate()
WHERE adminNumber = @adminNumber
GO
/****** Object:  StoredProcedure [dbo].[procMakeTableForRewardGameTime]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procMakeTableForRewardGameTime]
	@now as datetime
AS

-- for preparing data
-- preparation : add tempId filed as PRIMARY KEY on tblRewardGameTimeToTaney
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[tblRewardGameTimeToTaney]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
	DROP TABLE [dbo].[tblRewardGameTimeToTaney]
END

CREATE TABLE [tblRewardGameTimeToTaney] (
	[tempId] [int] IDENTITY (1, 1) PRIMARY KEY NOT NULL ,
	[userNumber] [int] NOT NULL ,
	[startDt] [smalldatetime] NULL ,
	[endDt] [smalldatetime] NULL ,
	[limitTime] [int] NOT NULL ,
	[usedLimitTime] [int] NOT NULL ,
	[cashBalance] [int] NOT NULL ,
	[rewardedDay] [int] NOT NULL ,
	[restMin] [int] NOT NULL ,
	[rewardedCashBalance] [int] NULL CONSTRAINT [DF_tblRewardGameTimeToTaney_rewardedCashBalance] DEFAULT (0),
	[expireDt] [smalldatetime] NULL ,
) ON [PRIMARY]


INSERT tblRewardGameTimeToTaney--(userNumber, startDt, endDt, limitTime, usedLimitTime, oldCashBalance, cashBalance, expireDt)
	SELECT UI.userNumber, UGS.startDt, UGS.endDt, UGS.limitTime, UGS.usedLimitTime, UI.cashBalance, 0, 0, 0, UGS.expireDt
	FROM tblUserInfo UI WITH(NOLOCK)
	JOIN tblUserGameService UGS WITH(NOLOCK) ON UI.userNumber = UGS.userNumber
	WHERE UI.apply = 1 AND 
		(
			UGS.endDt >= @now 
			OR 
			(
				UGS.expireDt IS NOT NULL AND UGS.expireDt >= @now 
				AND 
				(
					(UGS.limitTime - UGS.usedLimitTime) >= 0
				)
			)
		)
		-- Temp Cond
		--AND expireDt >= @now
GO
/****** Object:  StoredProcedure [dbo].[procLogOutAdminUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procLogOutAdminUser    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procLogOutAdminUser
	Creation Date		:	2002. 02. 16.
	Written by		:	???
	E-Mail by 		:	jsh001@n-cash.net
	Purpose			:	??? ????
	Input Parameters :	
		@adminNumber			as		int			:	??? ????
			
	return?	:
		@result
	Return Status:
	Usage: 			
	EXEC procAdminLogin subsub
	Call by:
		loginManager.logOut
	Calls:
	 	Nothing
	Access Table :
	 	tblAdminSession(D)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procLogOutAdminUser]
	@adminSessionId			as	int		,
	@result				as	int	output
as
delete from tblAdminSession where adminSessionId = @adminSessionId
set @result = 100
select @result
GO
/****** Object:  StoredProcedure [dbo].[procLoginExec]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procLoginExec    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procLoginExec
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	???? ??? ???
	Input Parameters :	
		@userId				as	nvarchar(32)		
		@cpId					as	int
		@userPwd				as	nvarchar(32)
		@userName				as	nvarchar(16)	OUTPUT
		@isUnder				as	nchar(1)		OUTPUT
		@msg					as	nvarchar(64)	OUTPUT
			
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procLoginExec]
	@userId				as	nvarchar(32)		
,	@userPwd				as	nvarchar(32)
,	@cpId					as	int		OUTPUT
,	@userName				as	nvarchar(16)	OUTPUT
,	@email					as	nvarchar(64)	OUTPUT
,	@isUnder				as	nchar(1)		OUTPUT
,	@msg					as	nvarchar(64)	OUTPUT
as
	DECLARE @confirmPassword as nvarchar(32)
	DECLARE @parentName as nvarchar(16)
	DECLARE @passwordCheckAnswer as nvarchar(64)
	DECLARE @canWebLogin as bit
/*
	-- ??? ???? CPID? ??? ?????? ???.
	SELECT @confirmPassword = UI.userPwd, @parentName = UD.parentName, @passwordCheckAnswer = UI.passwordCheckAnswer,
		@userName = UI.userName, @email = email, @canWebLogin = canWebLogin
	FROM tblUserInfo UI with (nolock), tblUserDetail UD with (nolock), tblCodeUserStatus CUS with (nolock)
	WHERE UI.userNumber = UD.userNumber AND UI.userStatusId = CUS.userStatusId 		-- join ??
		AND UI.userId = @userId AND UI.cpId = @cpId						-- ?? ??
*/
	SELECT @confirmPassword = UI.userPwd, @parentName = UD.parentName, @passwordCheckAnswer = UI.passwordCheckAnswer,
		@userName = UI.userSurName, @email = email, @canWebLogin = canWebLogin, @cpId = UI.cpId
	FROM tblUserInfo UI with (nolock), tblUserDetail UD with (nolock), tblCodeUserStatus CUS with (nolock)
	WHERE UI.userNumber = UD.userNumber AND UI.userStatusId = CUS.userStatusId 		-- join ??
		AND UI.userId = @userId AND UI.userTypeId <> 9					-- ?? ??
	IF @@ROWCOUNT <= 0
	BEGIN
		SET @msg = 'there is no ID.'
		RETURN 1
	END
	ELSE
	BEGIN
		IF @userPwd <> @confirmPassword
		BEGIN
			SET @msg = 'Incorrect password.'
			RETURN 1
		END
		ELSE
		BEGIN
			IF @canWebLogin = 0
			BEGIN
				SET @msg = 'authority not enough. impossible login.'
--						'Web? Login? ? ?? ??? ?? ??????.'
				RETURN 1
			END	
			IF @parentName IS NULL
			BEGIN
				-- ??? 14? ??? ??
				SET @isUnder = 0
			END
			ELSE
			BEGIN
				-- ??? 14? ??? ??
				SET @isUnder = 1
			END
			IF @passwordCheckAnswer = ' '
			BEGIN
				-- ?? ???? ?? ??? ???? ???? ??
				SET @msg = 'info Amend'	
				RETURN 2
			END
			ELSE
			BEGIN
				SET @msg = @passwordCheckAnswer
				RETURN 0
			END
		END
	END
GO
/****** Object:  StoredProcedure [dbo].[procLoginAdminUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procLoginAdminUser    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procLoginAdminUser
	Creation Date		:	2002. 02. 16.
	Written by		:	???
	E-Mail by 		:	jsh001@n-cash.net
	Purpose			:	??? ????
	Input Parameters :	
		@cpId				as		int			:	cp ????
		@adminSessionId			as		int			:	??? ???? ?? ???
		@loginIp			as		nvarchar(10)		:	??? ipadress
		@adminId			as		nvarchar(32)		:	??? ???
		@adminPwd			as		nvarchar(12)		:	????
		
	return?	:
		@result
	Return Status:
	Usage: 			
		
	Call by:
		LoginManager.login
	Calls:
	 	Nothing
	Access Table :
	 	tblAdmin(s)
	 	tblCodeadminType(s)
	 	tblAdminSession(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procLoginAdminUser]
	@cpId				as		int			
,	@adminSessionId		as		int		
,	@loginIp			as		nvarchar(15)		
,	@adminId			as		nvarchar(32)		
,	@adminPwd			as		nvarchar(16)
as
DECLARE @result as			int
DECLARE @islogin as			tinyint
DECLARE @isAdminPwd as		nvarchar(16)
DECLARE @adminNumber as		int
DECLARE @adminGrade as		tinyint
DECLARE @adminName as		nvarchar(32)
DECLARE @adminType	as		tinyint
DECLARE @adminGroup as		tinyint
-- ??? ??? ??? ???? ? ?? ????? ????.
	SELECT @isAdminPwd = adminPwd, @adminNumber=adminNumber, @adminName = adminName, @adminType = adminTypeId
	FROM tblAdmin
	WHERE adminId = @adminId AND cpId = @cpId	
	IF @@rowCount = 0
		BEGIN 
			SET @result = 212
			SET @adminNumber = '0'
			SET @adminType = '0'
			SET @adminGroup = '0'
			SET @adminGrade = '0'
			SET @adminName = '0'
			SELECT @result, @adminNumber, @adminType,@adminGroup, @adminGrade, @adminName
			RETURN
		END
	IF @isAdminPwd = @adminPwd
		BEGIN
			SELECT @adminGroup = adminGroupTypeId, @adminGrade=adminGradeTypeId
			FROM tblCodeAdminType
			WHERE adminTypeId = @adminType
			SET @result = 100
			SELECT @result, @adminNumber, @adminType,@adminGroup, @adminGrade, @adminName
			RETURN
		END
	ELSE
		BEGIN
			SET @result = 211
			SET @adminNumber = '0'
			SET @adminType = '0'
			SET @adminGroup = '0'
			SET @adminGrade = '0'
			SET @adminName = '0'
			SELECT @result, @adminNumber, @adminType,@adminGroup, @adminGrade, @adminName
			RETURN
		END
GO
/****** Object:  StoredProcedure [dbo].[procIsLoginAdmin]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procIsLoginAdmin    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procIsLoginAdmin
	Creation Date		:	2002. 02. 16.
	Written by		:	???
	E-Mail by 		:	jsh001@n-cash.net
	Purpose			:	??? ????
	Input Parameters :	
		@adminNumber			as		int			:	??? ????
			
	return?	:
		@result
	Return Status:
	Usage: 			
	EXEC procAdminLogin subsub
	Call by:
		loginManager.logOut
	Calls:
	 	Nothing
	Access Table :
	 	tblAdminSession(D)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procIsLoginAdmin]
	@sessionId			as	int
,	@loginIp			as	nvarchar(15)
,	@result				as	int		output
,	@cpId				as	int		output
,	@adminNumber			as	int		output
,	@adminId			as	nvarchar(32)	output
,	@adminName			as	nvarchar(20)	output
,	@adminGroup			as	tinyInt		output
,	@adminGrade			as	tinyInt		output
,	@adminType			as	smallInt		output
as
DECLARE @checkSession as int
DECLARE @checkIp as int
--  ?? ???? ??? ????. ??? ?? ??? ?? ?? ?? ??.
IF @sessionId = 0
  BEGIN
		SET @result = 216
		SET @adminNumber = 200
		SET @cpId = 200
		SET @adminId = '200'
		SET @adminName = '200'
		SET @adminGroup = 200
		SET @adminGrade = 200
		SET @adminType = 200
	SELECT @result, @adminNumber, @cpId, @adminId, @adminName, @adminGroup, @adminGrade, @adminType
	RETURN
  END
SELECT @checkSession = count(adminNumber) FROM tblAdminSession WHERE adminSessionId = @sessionId
IF @checkSession = 0
  BEGIN
	SELECT @checkIp = count(adminNumber) FROM tblAdminSession WHERE loginIp = @loginIp
	IF @checkIp = 0
	  BEGIN
		-- result 210 ? ?? ???
		SET @result = 210
		SET @adminNumber = 200
		SET @cpId = 200
		SET @adminId = '200'
		SET @adminName = '200'
		SET @adminGroup = 200
		SET @adminGrade = 200
		SET @adminType = 200
		SELECT @result, @adminNumber, @cpId, @adminId, @adminName, @adminGroup, @adminGrade, @adminType
		RETURN
	  END
	ELSE
	  BEGIN
		/*
		SELECT @adminNumber = adminNumber, @cpId = cpId, @adminId = adminId, @adminName = adminName, @adminGroup = adminGroup, @adminGrade = adminGrade
		FROM tblAdminSession
		WHERE  loginIp = @loginIp
		
		SELECT @adminType = adminTypeId
		FROM tblCodeAdminType
		WHERE cpId = @cpId and adminGroupTypeId = @adminGroup and adminGradeTypeId = @adminGrade
		UPDATE tblAdminSession SET registDt = getDate(), adminSessionId = @sessionId  WHERE loginIp = @loginIp
		*/
		DELETE FROM tblAdminSession WHERE loginIp = @loginIp
		
		SET @result = 217
		SET @adminNumber = 200
		SET @cpId = 200
		SET @adminId = '200'
		SET @adminName = '200'
		SET @adminGroup = 200
		SET @adminGrade = 200
		SET @adminType = 200
		SELECT @result, @adminNumber, @cpId, @adminId, @adminName, @adminGroup, @adminGrade, @adminType
		RETURN
	  END
  END
ELSE
  BEGIN
	SELECT @adminNumber = adminNumber
		--, @cpId = cpId
		, @adminId = adminId, @adminName = adminName, @adminGroup = adminGroup, @adminGrade = adminGrade
	FROM tblAdminSession
	WHERE adminSessionId = @sessionId 
	
	SELECT @adminType = adminTypeId
	FROM tblCodeAdminType
	WHERE 
	--cpId = @cpId and 
	adminGroupTypeId = @adminGroup and adminGradeTypeId = @adminGrade
	
	UPDATE tblAdminSession SET registDt = getdate() WHERE adminSessionId = @sessionId and loginIp = @loginIp
	SET @adminNumber 		= ISNULL(@adminNumber, 200)
	SET @adminName		= ISNULL(@adminName, 200)
	SET @adminType		= ISNULL(@adminType, 200)
	SET @adminGroup	 	= ISNULL(@adminGroup, 200)
	SET @adminGrade	 	= ISNULL(@adminGrade, 200)
	SET @cpId 			= ISNULL(@cpId, 200)
	SET @result = 100
  END	
select @result, @adminNumber, @cpId, @adminId, @adminName, @adminGroup, @adminGrade, @adminType
GO
/****** Object:  StoredProcedure [dbo].[procIsGamebangGameServiceReservation]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procIsGamebangGameServiceReservation]

	@gamebangId					int
,	@returnCode					int	OUTPUT

AS
DECLARE @endDt datetime

	IF  EXISTS (SELECT * FROM tblGamebangGameServiceReservation  with(nolock) WHERE gamebangId=@gamebangId and  isUpdate=0 and isCancel=0)   ---?? ??? ????? ??
	BEGIN
		SET @returnCode = -1  --?? ?? ??
		RETURN
	END 
	BEGIN
		SET @returnCode = 1  --?? ?? ??
	END
	SELECT @endDt=endDt FROM tblGamebangGameservice with(nolock)  where gamebangId=@gamebangId
	IF @endDt is null 
	BEGIN
		SET @returnCode = 1
	END
	ELSE
	BEGIN
		IF @endDt < getdate()
			set @returnCode = 2
		else
		  	set @returnCode = 1
		
		
	END
GO
/****** Object:  StoredProcedure [dbo].[procIsCanOrder20050406]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--?? , ?? ?? ???? ???? ??

CREATE PROC [dbo].[procIsCanOrder20050406]
	@userNumber	INT
,	@productId	INT
,	@gameServiceId	INT
,	@returnCode	INT	OUTPUT
AS

DECLARE  @isTerm  	INT
DECLARE @remainTime	INT
DECLARE @endDt 	SMALLDATETIME

--???? ???? ????
/*SELECT  @isTerm = Case IsNull(periodTypeId,0)
		WHEN   1 THEN 1
		WHEN   2 THEN 1
		WHEN   0  THEN 0	
		WHEN   3 THEN 0	
		WHEN   4 THEN 0	
		END
 FROM  tblProduct with(nolock)  where apply=1 and  productId=@productId
--1, 2 ??
--3, 4 ??
--@isTerm 1 - ?? , 0- ??
*/

SELECT  @isTerm = ISNULL(productPeriod, 0)
 FROM  tblProduct with(nolock)  where apply=1 and  productId=@productId

--0 ?? ?? 
--0 ???? ?? 


IF EXISTS(SELECT * FROM tblUserGameService WITH(READUNCOMMITTED)  WHERE userNumber=@userNumber and gameServiceId=@gameServiceId)
BEGIN
	SELECT  @endDt=endDt ,   @remainTime= ISNULL(limitTime,0) - ISNULL(usedLimitTime,0)  FROM tblUserGameService with(readuncommitted)  where userNumber=@userNumber and gameServiceId=@gameServiceId 
	
	IF @isTerm  > 0    --?? ?????
	BEGIN

--/*
		IF @remainTime > 0   --?? ??? ?? ??? ???? ?? ??? ??? ?? ??
		BEGIN
			SET @returnCode = -1   
			RETURN
		END
		ELSE
		BEGIN
			SET @returnCode = 1
			RETURN
		END
--*/
	--	SET @returnCode = 1
	END
	ELSE 
	BEGIN    --?? ?????
		IF @endDt >  GETDATE()  --?? ?? ??? ???? ?? ??? ????? ???  ?? ??
		BEGIN
			SET @returnCode = -2
			RETURN
		END
		ELSE
		BEGIN
			SET @returnCode = 1
			RETURN
		END
	END
END
ELSE
BEGIN
	SET @returnCode = 1   --?? ??????? ??, ?? ???? ?? ??
END
GO
/****** Object:  StoredProcedure [dbo].[procIsCanOrder]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--?? , ?? ?? ???? ???? ??

CREATE PROC [dbo].[procIsCanOrder]
	@userNumber		INT
,	@productId		INT
,	@gameServiceId	INT
,	@returnCode		INT	OUTPUT
AS

DECLARE  @isTerm  	INT
DECLARE @remainTime	INT
DECLARE @endDt 	SMALLDATETIME

SELECT  @isTerm = ISNULL(productPeriod, 0)
 FROM  tblProduct with(nolock)  where apply=1 and  productId=@productId

--0 ?? ?? 
--0 ???? ?? 


IF EXISTS(SELECT * FROM tblUserGameService WITH(READUNCOMMITTED)  WHERE userNumber=@userNumber and gameServiceId=@gameServiceId)
BEGIN
	SELECT  @endDt=endDt ,   @remainTime=( ISNULL(limitTime,0) - ISNULL(usedLimitTime,0))  FROM tblUserGameService with(readuncommitted)  where userNumber=@userNumber and gameServiceId=@gameServiceId 
	
	IF @isTerm  > 0    --?? ?????
	BEGIN
		IF @remainTime > 0   --?? ??? ?? ??? ???? ?? ??? ??? ?? ??
		BEGIN
			SET @returnCode =  2 --???? ?? ??? ?? ??? ???? ??????? ?
			RETURN
		END
		ELSE
		BEGIN
			SET @returnCode = 1
			RETURN
		END

	--	SET @returnCode = 1
	END
	ELSE 
	BEGIN    --?? ?????
		IF @endDt >  GETDATE()  --?? ?? ??? ???? ?? ??? ????? ???  ?? ??
		BEGIN
			SET @returnCode = -2
			RETURN
		END
		ELSE
		BEGIN
			SET @returnCode = 1
			RETURN
		END
	END
END
ELSE
BEGIN
	SET @returnCode = 1   --?? ??????? ??, ?? ???? ?? ??
END
GO
/****** Object:  StoredProcedure [dbo].[procInsertVirtualIpAddr]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertVirtualIpAddr    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procInsertVirtualIpAddr
	Creation Date		:	2002. 01.26
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	IP??
	
	Input Parameters :	
				@gamebangId			AS		SMALLINT
				@realIpAddr			AS		nvarchar(11)
				@realStartIp			AS		TINYINT
				@virtualIpAddr			AS		nvarchar(11)
				@startIp			AS		TINYINT
				@endIp				AS		TINYINT
				@ipAddrId			AS		INT
				@adminNumber			AS		INT		
	Output Parameters:	
				@returnCode			AS		INT	OUTPUT
				
	Return Status:		
				1 : ?? ??.
				2 : ?? ???? ?? realIp? ????? ??.
				3 : ?? ???? ?? virtualIp? ????? ??.
	Usage		:	EXEC procInsertRealIpAddr 1,'211.233.3',115,120,null,1,1,@returnCode	OUTPUT
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblIpAddr(S,I) , tblVirtualIpHistory , tblVirtualIp , tblAdminLog
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertVirtualIpAddr]
	@gamebangId			AS		SMALLINT
,	@realIpAddr			AS		nvarchar(11)	=	NULL
,	@realStartIp			AS		TINYINT	=	NULL
,	@virtualIpAddr			AS		nvarchar(11)
,	@startIp			AS		TINYINT
,	@endIp				AS		TINYINT
,	@adminNumber			AS		INT
,	@returnCode			AS		INT		OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@checkIpAddrId		AS		INT
DECLARE	@checkVirtualIpAddrId		AS		INT
DECLARE	@virtualIpAddrId			AS		INT
DECLARE	@adminLogId			AS		INT
DECLARE	@ipAddrId			AS		INT
DECLARE	@checkGamebangId		AS		INT
------------------------?? ?? ?-------------------
--virtualIp? ???? realIp? ???? ??.
SELECT @ipAddrId = ipAddrId , @checkGamebangId = gamebangId FROM tblIpAddr WHERE ipAddr = @realIpAddr AND startIp =  @realStartIp AND endIp = @realStartIp AND apply = 1
IF(@ipAddrId IS NOT NULL AND @checkGamebangId <> @gamebangId)			--?? ????? ? ???? realIp? ?? ??.
	BEGIN
		SET @returnCode = 4
		RETURN	
	END
IF(@ipAddrId IS NULL)		--?? ??? realIp? ????
	BEGIN
		SELECT @checkIpAddrId = ipAddrId FROM tblIpAddr WHERE ipAddr = @realIpAddr AND (@realStartIp  BETWEEN startIp AND endIp) AND apply = 1
		IF(@checkIpAddrId IS NOT NULL)		--??? realIp? ??.
			BEGIN
				SET @returnCode = 2
				RETURN		
			END
		INSERT INTO tblIpAddr
			VALUES(
				@gamebangId
			,	@realIpAddr
			,	@realStartIp
			,	@realStartIp
			,	GETDATE()
			,	1
			)
		SET @ipAddrId = @@IDENTITY
			
		INSERT INTO tblAdminLog 
			VALUES(
				'Registration'
			,	'tblIpAddr'
			,	@adminNumber
			,	'REALLIP Registration'
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY
		INSERT INTO tblIpAddrHistory
			SELECT ipAddrId, gamebangId, ipAddr, startIp, endIp, GETDATE(), apply , @adminLogId 
			FROM tblIpAddr
			WHERE ipAddrId = @ipAddrId
	END
--virtualIp ?? ??
SELECT @checkVirtualIpAddrId = virtualIpAddrId FROM tblVirtualIpAddr WHERE ipAddrId = @ipAddrId AND virtualIpAddr = @virtualIpAddr AND (virtualStartIp  <= @endIp AND virtualEndIp >= @startIp) AND apply = 1
IF(@checkVirtualIpAddrId IS NOT NULL)		--??? virtualIp? ??.
	BEGIN
		SET @returnCode = 3
		RETURN
	END
--virtualIp??
INSERT INTO tblVirtualIpAddr
	VALUES(
		@ipAddrId
	,	0			--1: realIp	0: virtualIp
	,	@virtualIpAddr
	,	@startIp
	,	@endIp
	,	GETDATE()
	,	1
	)		
SET @virtualIpAddrId = @@IDENTITY
INSERT INTO tblAdminLog 
	VALUES(
		'Registration'
	,	'tblVirtualIpAddr'
	,	@adminNumber
	,	'VIRTUALIP Registration'
	,	GETDATE()
	)
SET @adminLogId = @@IDENTITY
INSERT INTO tblVirtualIpAddrHistory
	SELECT virtualIpAddrId , ipAddrId , isRealIp , virtualIpAddr , virtualStartIp , virtualEndIp , registDt , apply , @adminLogId
	FROM tblVirtualIpAddr
	WHERE virtualIpAddrId = @virtualIpAddrId
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procTransactionDetailForRefund]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procTransactionDetailForRefund    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procTransactionDetail 
	Creation Date		:	2002. 02.28
	Written by		:	? ??
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	??? ?? ??
	
	Input Parameters :	
				@transactionId			AS			INT
	Output Parameters:	
				
	Return Status:		
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblChongphan(S,I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procTransactionDetailForRefund] 
	@transactionId			AS			INT
AS
DECLARE	@checkTransactionId		AS		INT
DECLARE	@refundAmount  		AS		INT
DECLARE	@bankName 			AS		nvarchar(20)
DECLARE	@accountNumber 		AS		nvarchar(32)
DECLARE	@depositor 			AS		nvarchar(32)
DECLARE	@registDt			AS		DATETIME
SELECT @checkTransactionId = transactionId 
	, @refundAmount = R.refundAmount 
	, @bankName = R.bankName 
	, @accountNumber = R.accountNumber 
	, @depositor = R.depositor 
	, @registDt = AL.registDt
FROM tblRefund R JOIN tblAdminLog AL ON R.adminLogId = AL.adminLogId
WHERE R.transactionId = @transactionId
IF(@checkTransactionId IS NOT NULL)						--????? ??? ??
	BEGIN
		SELECT
				@checkTransactionId					AS		checkTransactionId
			,	ISNULL(@refundAmount,0)				AS		refundAmount
			,	@bankName						AS		bankName
			,	@accountNumber					AS		accountNumber
			,	@depositor						AS		depositor
			,	@registDt						AS		registDt	
			
	END
ELSE										--????? ???? ?? ??
	BEGIN
		SELECT 
				@checkTransactionId			 		AS		checkTransactionId
			, 	'refund particulars is not exist. Please contact us.'	AS		refundDescript
			--'????? ????.????? ??????.'
	END
GO
/****** Object:  StoredProcedure [dbo].[procTransactionDetail]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procTransactionDetail    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procTransactionDetail 
	Creation Date		:	2002. 02.28
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	??? ?? ??
	
	Input Parameters :	
				@transactionId			AS			INT
	Output Parameters:	
				
	Return Status:		
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblChongphan(S,I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procTransactionDetail] 
	@transactionId			AS			INT
AS
DECLARE	@chargeTypeId			AS		INT
DECLARE	@chargeDescript		AS		nvarchar(50)
DECLARE	@chargeTransactionId		AS		INT
SELECT 
	@chargeTypeId = dbo.tblCharge.chargeTypeId, 
	@chargeDescript =  dbo.tblCodeChargeType.descript  
FROM      dbo.tblTransaction INNER JOIN dbo.tblCharge ON dbo.tblTransaction.transactionId = dbo.tblCharge.transactionId 
	   INNER JOIN dbo.tblCodeChargeType ON dbo.tblCharge.chargeTypeId = dbo.tblCodeChargeType.chargeTypeId
WHERE dbo.tblTransaction.transactionId = @transactionId
IF(@chargeTypeId = 4)						--?????
	BEGIN
			SELECT
				@chargeTypeId		 	AS		chargeTypeId
			, 	@chargeDescript  		AS		chargeDescript
			,	transactionNumber			AS		approvalNo
			,	'Issuer'				AS		cardIssuer
			,	ISNULL(registDt , '&nbsp')	AS		registDt
		FROM 
			tblChargeCardDeposit   cc with(nolock) join tblTransaction t with(nolock) on t.transactionId=cc.transactionId
		WHERE 
			t.transactionId = @chargeTransactionId
		
	END
ELSE IF(@chargeTypeId IN (5 , 6))				--??? ??
	BEGIN
		SELECT
			 	 @chargeTypeId 		AS		chargeTypeId
			,	 @chargeDescript		AS		chargeDescript
	END
ELSE IF(@chargeTypeId = 14)					--??? ????
	BEGIN
		SELECT
			 	 @chargeTypeId 		AS		chargeTypeId
			,	 @chargeDescript		AS		chargeDescript
			,	 bankName			AS		bankName
			,	accnt_No			AS		accnt_No
			,	depositorName			AS		depositorName
			,	amount				AS		amount
			,	pay_Date			AS		pay_Date
		FROM 
			tblChargeTransferAccount
		WHERE 
			transactionId = @chargeTransactionId
	END
ELSE
	BEGIN
		SELECT 
				@chargeTypeId 		AS		chargeTypeId
			, 	'other error'	AS	chargeDescript
	END
GO
/****** Object:  StoredProcedure [dbo].[procTotalSettlementTest]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procTotalSettlement    Script Date: 23/1/2546 11:40:28 ******/
CREATE  PROCEDURE [dbo].[procTotalSettlementTest]
	@startDt	as	datetime
,	@endDt	as	datetime
 AS

DECLARE @ppCardChargeAmount INT
DECLARE @ppCardCancelAmount  INT
DECLARE @ppCardTotalAmount     INT
DECLARE @pcbangChargeAmount INT
DEClARE  @pcbangCancelAmount INT
DECLARE @pcbangTotalAmount    INT
DECLARE @createCardChargeAmount INT
DECLARE @createCardCancelAmount INT
DECLARE @createCardTotalAmount INT
--(??)PPCARD
--?? ??
SELECT @ppCardChargeAmount = isNull( sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
	--JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId
where c.chargeTypeId=3  and  t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser) 

--????
SELECT @ppCardCancelAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
	--JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId
where c.chargeTypeId=3  and  t.peerTransactionId is  not null
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser)


--??? ??? ???
SELECT  @ppCardTotalAmount = isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
--	JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId
where c.chargeTypeId=3  and  t.peerTransactionId is null
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser)

--(???? ??) ??
--?? ??
SELECT @createCardChargeAmount = isNull( sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=1  and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser )


--????
SELECT @createCardCancelAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=1  and  t.transactionId in (select peerTransactionId FROM tblTransaction where transactionTypeId=5) 
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser)


--??? ??? ???
SELECT  @createCardTotalAmount = isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=1  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5) 
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser)

--(???? ?? ?)


--??
--?? ??
SELECT @pcbangChargeAmount=  isNull(sum(cashAmount), 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=5 and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser with(nolock))

--????
SELECT  @pcbangCancelAmount= isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=5  and  t.transactionId in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser with(nolock))


--??? ??? ???
SELECT @pcbangTotalAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=5  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5) 
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser with(nolock))


SELECT 
	@ppCardChargeAmount  as ppCardChargeAmount
, 	@ppCardCancelAmount  as ppCardCancelAmount 
,	@ppCardTotalAmount      as ppCardTotalAmount 
, 	@pcbangChargeAmount  as pcbangChargeAmount
, 	@pcbangCancelAmount as pcbangCancelAmount
,	@pcbangTotalAmount    as pcbangTotalAmount
,	@createCardChargeAmount  AS createCardChargeAmount
,	@createCardCancelAmount as createCardCancelAmount
, 	@createCardTotalAmount  as createCardTotalAmount
GO
/****** Object:  StoredProcedure [dbo].[procTotalSettlementOld]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procTotalSettlement    Script Date: 23/1/2546 11:40:28 ******/
CREATE PROCEDURE [dbo].[procTotalSettlementOld]
	@startDt	as	datetime
,	@endDt	as	datetime
 AS

DECLARE @ppCardChargeAmount INT
DECLARE @ppCardCancelAmount  INT
DECLARE @ppCardTotalAmount     INT
DECLARE @pcbangChargeAmount INT
DEClARE  @pcbangCancelAmount INT
DECLARE @pcbangTotalAmount    INT

--(??)PPCARD
--?? ??
SELECT @ppCardChargeAmount = isNull( sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
where c.chargeTypeId=3  and  t.registDt between @startDt and @endDt	


--????
SELECT @ppCardCancelAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
where c.chargeTypeId=3  and  t.transactionId in (select peerTransactionId FROM tblTransaction where transactionTypeId=5) and c.chargeTypeId=3
and t.registDt between @startDt and @endDt	


--??? ??? ???
SELECT  @ppCardTotalAmount = isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
where c.chargeTypeId=3  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5) and c.chargeTypeId=3
and t.registDt  between @startDt and @endDt	



--??
--?? ??
SELECT @pcbangChargeAmount=  isNull(sum(cashAmount), 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
where c.chargeTypeId=5 and  t.registDt between @startDt and @endDt	

--????
SELECT  @pcbangCancelAmount= isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
where c.chargeTypeId=5  and  t.transactionId in (select peerTransactionId FROM tblTransaction where transactionTypeId=5) and c.chargeTypeId=5
and t.registDt between @startDt and @endDt	


--??? ??? ???
SELECT @pcbangTotalAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
where c.chargeTypeId=5  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5) and c.chargeTypeId=5
and t.registDt  between @startDt and @endDt	


SELECT 
	@ppCardChargeAmount  as ppCardChargeAmount
, 	@ppCardCancelAmount  as ppCardCancelAmount 
,	@ppCardTotalAmount      as ppCardTotalAmount 
, 	@pcbangChargeAmount  as pcbangChargeAmount
, 	@pcbangCancelAmount as pcbangCancelAmount
,	@pcbangTotalAmount    as pcbangTotalAmount
GO
/****** Object:  StoredProcedure [dbo].[procTotalSettlementbak]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procTotalSettlement    Script Date: 23/1/2546 11:40:28 ******/
CREATE PROCEDURE [dbo].[procTotalSettlementbak]
	@startDt	as	datetime
,	@endDt	as	datetime
 AS
DECLARE @SumOfChargeAmountForPpCard AS int
DECLARE @SumOfChargeAmountForPcbang AS int
DECLARE @SumOfCancelAmountForPcbang AS int
SELECT  
	@SumOfChargeAmountForPpCard = isnull(sum(PCS.price), 0)
FROM 
	tblPpCardSale PCS WITH(NOLOCK)
WHERE 
	PCS.registDt > @startDt AND PCS.registDt < @endDt
SELECT 
	@SumOfChargeAmountForPcbang = isnull(sum(T.cashAmount) , 0)
FROM 
	tblTransaction T  WITH(NOLOCK) JOIN 
	tblCharge C WITH(NOLOCK) ON T.transactionId = C.transactionId
WHERE 
	T.registDt > @startDt AND T.registDt < @endDt AND C.chargeTypeId = 5 AND T.peerTransactionId is null
SELECT 
	@SumOfCancelAmountForPcbang = isnull(sum(T.cashAmount) , 0)
FROM 
	tblTransaction T  WITH(NOLOCK) JOIN 
	tblCharge C WITH(NOLOCK) ON T.transactionId = C.transactionId
WHERE 
	T.registDt > @startDt AND T.registDt < @endDt AND C.chargeTypeId = 5 AND T.peerTransactionId is not null
SELECT @SumOfChargeAmountForPpCard as ppCardSum, @SumOfChargeAmountForPcbang as pcBangSum, @SumOfCancelAmountForPcbang as pcBangCancel
GO
/****** Object:  StoredProcedure [dbo].[procTotalSettlement_old_20060828]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procTotalSettlement    Script Date: 23/1/2546 11:40:28 ******/  
CREATE PROCEDURE [dbo].[procTotalSettlement_old_20060828]
 @startDt as datetime  
, @endDt as datetime  
 AS  
  
DECLARE @ppCardChargeAmount INT  
DECLARE @ppCardCancelAmount  INT  
DECLARE @ppCardTotalAmount     INT  
DECLARE @pcbangChargeAmount INT  
DEClARE  @pcbangCancelAmount INT  
DECLARE @pcbangTotalAmount    INT  
DECLARE @createCardChargeAmount INT  
DECLARE @createCardCancelAmount INT  
DECLARE @createCardTotalAmount INT  
--(??)PPCARD  
--?? ??  
SELECT @ppCardChargeAmount = isNull( sum(
CASE WHEN registDt > '2006-07-28' and registDt < '2006-08-01'
	THEN (cashAmount / 1.2)
ELSE	cashAmount
END
) , 0) 
from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
-- JOIN  tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
-- JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId  
-- where c.chargeTypeId=3  and  t.registDt >= @startDt and t.registDt < @endDt   
-- where c.chargeTypeId=17  and  t.registDt >= @startDt and t.registDt < @endDt   
 where (c.chargeTypeId=3 or c.chargeTypeId=17) and  t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser)  
  
--????  
SELECT @ppCardCancelAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
-- JOIN  tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
-- JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId  
-- where c.chargeTypeId=3  and  t.transactionId   in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)  
--where c.chargeTypeId=17  and  t.transactionId   in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)  
 where  (c.chargeTypeId=3 or c.chargeTypeId=17)  and  t.transactionId   in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)  
and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser)  
  
  
--??? ??? ???  
SELECT  @ppCardTotalAmount = @ppCardChargeAmount - @ppCardCancelAmount
/*
SELECT  @ppCardTotalAmount = isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
 JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId  
where c.chargeTypeId=3  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5)  
and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser)  
*/
  
--(???? ??) ??  
--?? ??  
SELECT @createCardChargeAmount = isNull( sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
where c.chargeTypeId=1  and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser )  
  
  
--????  
SELECT @createCardCancelAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
where c.chargeTypeId=1  and  t.transactionId in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)   
and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser)  
  
  
--??? ??? ???  
SELECT  @createCardTotalAmount = @createCardChargeAmount - @createCardCancelAmount
/*
SELECT  @createCardTotalAmount = isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
where c.chargeTypeId=1  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5)   
and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser)  
*/  
--(???? ?? ?)  
  
  
--??  
--?? ??  
SELECT @pcbangChargeAmount=  isNull(sum(cashAmount), 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
where c.chargeTypeId=5 and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser with(nolock))  
  
--????  
SELECT  @pcbangCancelAmount= isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
where c.chargeTypeId=5  and  t.transactionId in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)  
and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser with(nolock))  
  
  
--??? ??? ???
SELECT @pcbangTotalAmount = @pcbangChargeAmount - @pcbangCancelAmount
/*  
SELECT @pcbangTotalAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
where c.chargeTypeId=5  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5)   
and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser with(nolock))  
*/  
  
SELECT   
 @ppCardChargeAmount  as ppCardChargeAmount  
,  @ppCardCancelAmount  as ppCardCancelAmount   
, @ppCardTotalAmount      as ppCardTotalAmount   
,  @pcbangChargeAmount  as pcbangChargeAmount  
,  @pcbangCancelAmount as pcbangCancelAmount  
, @pcbangTotalAmount    as pcbangTotalAmount  
, @createCardChargeAmount  AS createCardChargeAmount  
, @createCardCancelAmount as createCardCancelAmount  
,  @createCardTotalAmount  as createCardTotalAmount
GO
/****** Object:  StoredProcedure [dbo].[procTotalSettlement_old_20060413]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procTotalSettlement    Script Date: 23/1/2546 11:40:28 ******/
CREATE PROCEDURE [dbo].[procTotalSettlement_old_20060413]
	@startDt	as	datetime
,	@endDt	as	datetime
 AS

SET NOCOUNT ON


DECLARE @ppCardChargeAmount INT
DECLARE @ppCardCancelAmount  INT
DECLARE @ppCardTotalAmount     INT
DECLARE @pcbangChargeAmount INT
DEClARE  @pcbangCancelAmount INT
DECLARE @pcbangTotalAmount    INT
DECLARE @createCardChargeAmount INT
DECLARE @createCardCancelAmount INT
DECLARE @createCardTotalAmount INT
--(??)PPCARD
--?? ??
SELECT @ppCardChargeAmount = isNull( sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
	JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId
where c.chargeTypeId=3  and  t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser)

--????
SELECT @ppCardCancelAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
	JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId
where c.chargeTypeId=3  and  t.transactionId   in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser)


--??? ??? ???
SELECT  @ppCardTotalAmount = isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
	JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId
where c.chargeTypeId=3  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5)
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser)

--(???? ??) ??
--?? ??
SELECT @createCardChargeAmount = isNull( sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=1  and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser )


--????
SELECT @createCardCancelAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=1  and  t.transactionId in (select peerTransactionId FROM tblTransaction where transactionTypeId=5) 
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser)


--??? ??? ???
SELECT  @createCardTotalAmount = isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=1  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5) 
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser)

--(???? ?? ?)


--??
--?? ??
SELECT @pcbangChargeAmount=  isNull(sum(cashAmount), 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=5 and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser with(nolock))

--????
SELECT  @pcbangCancelAmount= isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=5  and  t.transactionId in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser with(nolock))


--??? ??? ???
SELECT @pcbangTotalAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)  
	JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId
	JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId
where c.chargeTypeId=5  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5) 
and t.registDt >= @startDt and t.registDt < @endDt	
and t.userNumber not in(select userNumber from tblTestUser with(nolock))


SELECT 
	@ppCardChargeAmount  as ppCardChargeAmount
, 	@ppCardCancelAmount  as ppCardCancelAmount 
,	@ppCardTotalAmount      as ppCardTotalAmount 
, 	@pcbangChargeAmount  as pcbangChargeAmount
, 	@pcbangCancelAmount as pcbangCancelAmount
,	@pcbangTotalAmount    as pcbangTotalAmount
,	@createCardChargeAmount  AS createCardChargeAmount
,	@createCardCancelAmount as createCardCancelAmount
, 	@createCardTotalAmount  as createCardTotalAmount

SET NOCOUNT OFF
GO
/****** Object:  StoredProcedure [dbo].[procTotalSettlement]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procTotalSettlement    Script Date: 23/1/2546 11:40:28 ******/  
CREATE PROCEDURE [dbo].[procTotalSettlement]  
 @startDt as datetime  
, @endDt as datetime  
 AS  
  
DECLARE @ppCardChargeAmount INT  
DECLARE @ppCardCancelAmount  INT  
DECLARE @ppCardTotalAmount     INT  
DECLARE @pcbangChargeAmount INT  
DEClARE  @pcbangCancelAmount INT  
DECLARE @pcbangTotalAmount    INT  
DECLARE @createCardChargeAmount INT  
DECLARE @createCardCancelAmount INT  
DECLARE @createCardTotalAmount INT  

--(??)PPCARD  
--?? ??  

IF @startDt  >= '2006-7-1 00:00:00' AND @startDt  < '2006-7-1 23:59:59'
BEGIN
	SELECT @ppCardChargeAmount = isNull( sum(
	CASE WHEN registDt > '2006-07-28' and registDt < '2006-08-01'
		THEN (cashAmount / 1.2)
	ELSE	cashAmount
	END
	) , 0) 
	from tblTransaction t with(nolock)    
	 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
	-- JOIN  tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
	-- JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId  
	-- where c.chargeTypeId=3  and  t.registDt >= @startDt and t.registDt < @endDt   
	-- where c.chargeTypeId=17  and  t.registDt >= @startDt and t.registDt < @endDt   
	 where (c.chargeTypeId=3 or c.chargeTypeId=17) and  t.registDt >= @startDt and t.registDt < @endDt   
	and t.userNumber not in(select userNumber from tblTestUser)  
END
ELSE IF @startDt  >= '2006-12-1 00:00:00' AND @startDt  < '2006-12-1 23:59:59'
BEGIN
	SELECT @ppCardChargeAmount = isNull( sum(
	CASE WHEN registDt > '2006-12-15 00:00' and registDt < '2006-12-25 23:59'
		THEN (cashAmount / 1.2)
	ELSE	cashAmount
	END
	) , 0) 
	from tblTransaction t with(nolock)    
	 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
	-- JOIN  tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
	-- JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId  
	-- where c.chargeTypeId=3  and  t.registDt >= @startDt and t.registDt < @endDt   
	-- where c.chargeTypeId=17  and  t.registDt >= @startDt and t.registDt < @endDt   
	 where (c.chargeTypeId=3 or c.chargeTypeId=17) and  t.registDt >= @startDt and t.registDt < @endDt   
	and t.userNumber not in(select userNumber from tblTestUser)  
END
ELSE
BEGIN
	SELECT @ppCardChargeAmount = isNull( sum(cashAmount) , 0) 
	from tblTransaction t with(nolock)    
	 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
	-- JOIN  tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
	-- JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId  
	-- where c.chargeTypeId=3  and  t.registDt >= @startDt and t.registDt < @endDt   
	-- where c.chargeTypeId=17  and  t.registDt >= @startDt and t.registDt < @endDt   
	 where (c.chargeTypeId=3 or c.chargeTypeId=17) and  t.registDt >= @startDt and t.registDt < @endDt   
	and t.userNumber not in(select userNumber from tblTestUser)  	
END	

  
--????  
SELECT @ppCardCancelAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
-- JOIN  tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
-- JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId  
-- where c.chargeTypeId=3  and  t.transactionId   in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)  
--where c.chargeTypeId=17  and  t.transactionId   in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)  
 where  (c.chargeTypeId=3 or c.chargeTypeId=17)  and  t.transactionId   in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)  
and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser)  
  
  
--??? ??? ???  
SELECT  @ppCardTotalAmount = @ppCardChargeAmount - @ppCardCancelAmount
/*
SELECT  @ppCardTotalAmount = isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
 JOIN  tblPpCardUserInfoMapping PPI with(nolock) on o.transactionId=PPI.transactionId  
where c.chargeTypeId=3  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5)  
and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser)  
*/
  
--(???? ??) ??  
--?? ??  
SELECT @createCardChargeAmount = isNull( sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
where c.chargeTypeId=1  and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser )  
  
  
--????  
SELECT @createCardCancelAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
where c.chargeTypeId=1  and  t.transactionId in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)   
and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser)  
  
  
--??? ??? ???  
SELECT  @createCardTotalAmount = @createCardChargeAmount - @createCardCancelAmount
/*
SELECT  @createCardTotalAmount = isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
where c.chargeTypeId=1  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5)   
and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser)  
*/  
--(???? ?? ?)  
  
  
--??  
--?? ??  
--SELECT @pcbangChargeAmount=  isNull(sum(cashAmount), 0) from tblTransaction t with(nolock)    
-- JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
--JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
--where c.chargeTypeId=5 and t.registDt >= @startDt and t.registDt < @endDt   
--and t.userNumber not in(select userNumber from tblTestUser with(nolock))  

SELECT @pcbangChargeAmount = 0
  
--????  
--SELECT  @pcbangCancelAmount= isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
-- JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
-- JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
--where c.chargeTypeId=5  and  t.transactionId in (select peerTransactionId FROM tblTransaction where transactionTypeId=5)  
--and t.registDt >= @startDt and t.registDt < @endDt   
--and t.userNumber not in(select userNumber from tblTestUser with(nolock))  

SELECT  @pcbangCancelAmount = 0
  
  
--??? ??? ???
SELECT @pcbangTotalAmount = @pcbangChargeAmount - @pcbangCancelAmount
/*  
SELECT @pcbangTotalAmount =  isnull(sum(cashAmount) , 0) from tblTransaction t with(nolock)    
 JOIN  tblCharge c with(nolock) ON c.transactionId=t.transactionId  
 JOIN tblOrder o with(nolock) ON o.chargeTransactionId=c.transactionId  
where c.chargeTypeId=5  and  t.transactionId NOT IN (select peerTransactionId FROM tblTransaction where transactionTypeId=5)   
and t.registDt >= @startDt and t.registDt < @endDt   
and t.userNumber not in(select userNumber from tblTestUser with(nolock))  
*/  

  
SELECT   
 @ppCardChargeAmount  as ppCardChargeAmount  
,  @ppCardCancelAmount  as ppCardCancelAmount   
, @ppCardTotalAmount      as ppCardTotalAmount   
,  @pcbangChargeAmount  as pcbangChargeAmount  
,  @pcbangCancelAmount as pcbangCancelAmount  
, @pcbangTotalAmount    as pcbangTotalAmount  
, @createCardChargeAmount  AS createCardChargeAmount  
, @createCardCancelAmount as createCardCancelAmount  
,  @createCardTotalAmount  as createCardTotalAmount
GO
/****** Object:  StoredProcedure [dbo].[procTotalProductSettlement]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procTotalProductSettlement    Script Date: 23/1/2546 11:40:26 ******/
CREATE PROCEDURE [dbo].[procTotalProductSettlement]
	@startDt	as	datetime
,	@endDt	as	datetime
 AS
	DECLARE @chargeAmount as int
	DECLARE @cancelChargeAmount as int
	DECLARE @totalAmount as int
	select @chargeAmount = isnull(sum(cashAmount), 0) 
	from tblTransaction t, tblCharge c, tblSettlementChargeMap sc
	where t.transactionId = c.transactionId and c.chargeTypeId = sc.chargeTypeId
	and t.transactionTypeId = 1 and t.registDt between @startDt and @endDt 
/*	select @cancelChargeAmount = isnull(sum(cashAmount), 0)
	from tblTransaction t, tblCharge c, tblSettlementChargeMap sc
	where t.peerTransactionId = c.transactionId and sc.chargeTypeId = c.chargeTypeId
	and t.peerTransactionId in (select transactionId from tblTransaction where transactionTypeId = 1) 
	and t.transactionTypeId = 5 and t.registDt between @startDt and @endDt
*/
	SELECT @cancelChargeAmount = SUM(cashAmount) FROM tblTransaction 
	WHERE transactionTypeId = 5 and registDt between @startDt and @endDt 
	and transactionId IN (SELECT peerTransactionId FROM tblTransaction t, tblCharge c 
	WHERE t.transactionId = c.transactionId and peerTransactionId is not null) 
/*	SELECT @chargeAmount = sum(cashAmount) FROM tblTransaction t, tblOrder o, tblProduct p
	WHERE t.transactionId = o.transactionId and o.productId = p.productId and t.transactionTypeId = 2
	           and t.registDt between @startDt and @endDt and p.apply = 1
	select @cancelChargeAmount = -sum(cashAmount)  from tblTransaction where transactionTypeId = 6 and registDt between @startDt and @endDt
	
	SELECT @cancelChargeAmount = sum(cashAmount) FROM tblTransaction t, tblOrder o, tblProduct p
	WHERE t.transactionId = o.transactionId and o.productId = p.productId 
	           and  o.transactionId in (SELECT peerTransactionId FROM tblTransaction WHERE transactionTypeId = 6)
	           and t.registDt between @startDt and @endDt and p.apply = 1
	SELECT @totalAmount = sum(cashAmount) FROM tblTransaction t, tblOrder o, tblProduct p
	WHERE t.transactionId = o.transactionId and o.productId = p.productId 
	           and  o.transactionId not in (SELECT peerTransactionId FROM tblTransaction WHERE transactionTypeId = 6)
		and t.registDt between @startDt and @endDt and p.apply = 1
	IF @chargeAmount is null 
		set @chargeAmount = 0
	IF @cancelChargeAmount is null
		set @cancelChargeAmount = 0
*/
	set @totalAmount = @chargeAmount + @cancelChargeAmount
	select @chargeAmount as a, @cancelChargeAmount as b, @totalAmount as c
GO
/****** Object:  StoredProcedure [dbo].[procTotalPpcardSettlement]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procTotalPpcardSettlement    Script Date: 23/1/2546 11:40:26 ******/
CREATE PROCEDURE [dbo].[procTotalPpcardSettlement]
	@startDt	as 	datetime
,	@endDt	as	datetime
 AS
	DECLARE @chargeAmount as int
	DECLARE @cancelChargeAmount as int
	DECLARE @totalAmount as int
	SELECT @chargeAmount = sum(cashAmount) FROM tblTransaction t, tblCharge c 
	WHERE t.transactionId = c.transactionId and t.transactionTypeId = 1 and c.chargeTypeId = 3 and t.registDt between @startDt and @endDt
	SELECT @cancelChargeAmount=sum(cashAmount) FROM tblTransaction t, tblCharge c
	WHERE t.transactionId = c.transactionId 
	and t.transactionId in (SELECT peerTransactionId FROM tblTransaction WHERE transactionTypeId = 5 ) and c.chargeTypeId = 3
	and t.registDt between @startDt and @endDt	
	SELECT @totalAmount = sum(cashAmount) FROM tblTransaction t, tblCharge c 
	WHERE t.transactionId = c.transactionId and t.transactionTypeId = 1 and c.chargeTypeId = 3  
	and t.transactionId not in (SELECT peerTransactionId FROM tblTransaction WHERE transactionTypeId = 5)
	and t.registDt between @startDt and @endDt	
	SELECT @chargeAmount , @cancelChargeAmount, @totalAmount
GO
/****** Object:  StoredProcedure [dbo].[procTotalChongphanSettlement]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procTotalChongphanSettlement    Script Date: 23/1/2546 11:40:28 ******/
CREATE PROCEDURE [dbo].[procTotalChongphanSettlement]
	@startDt 	as 	datetime
,	@endDt	as	datetime
,	@check	as	tinyint
 AS
	IF @check = 1 
		begin
			select cg.chongphanId, -sum(cashAmount)
			from tblTransaction t, tblOrder o, tblSettlementProductMap sp, tblUserInfo u, tblChongphanGamebang cg
			where u.userNumber = t.userNumber and o.transactionId = t.transactionId and sp.productTypeId = o.orderTypeId and u.cpId = cg.gamebangId
			and sp.settlementTypeId = 2 and t.transactionTypeId =2 
			and t.registDt between @startDt and @endDt
			group by cg.chongphanId
/*			select cg.chongphanId, -sum(cashAmount)
			from tblTransaction t, tblUserInfo u, tblChongphanGamebang cg where u.userNumber = t.userNumber and u.cpId = cg.gamebangId 
			 	and u.userTypeId = 9 and t.transactionTypeId = 2 
				and t.registDt between @startDt and @endDt
			group by cg.chongphanId
*/
		end
	ELSE
		begin	
			select cg.chongphanId, -sum(cashAmount)
			from tblTransaction t, tblOrder o, tblSettlementProductMap sp, tblUserInfo u, tblChongphanGamebang cg
			where u.userNumber = t.userNumber and o.transactionId = t.transactionId and sp.productTypeId = o.orderTypeId and u.cpId = cg.gamebangId
			and sp.settlementTypeId = 2 and t.transactionTypeId =6 
			and t.registDt between @startDt and @endDt
			group by cg.chongphanId
/*			select cg.chongphanId, sum(cashAmount)
			from tblTransaction t, tblUserInfo u, tblChongphanGamebang cg where u.userNumber = t.userNumber and u.cpId = cg.gamebangId 
			 	and u.userTypeId = 9 and t.transactionTypeId = 6
				and t.registDt between @startDt and @endDt
			group by cg.chongphanId
*/
		end
GO
/****** Object:  StoredProcedure [dbo].[procTestUserGameServiceUpdate]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procTestUserGameServiceUpdate    Script Date: 23/1/2546 11:40:26 ******/
CREATE PROCEDURE [dbo].[procTestUserGameServiceUpdate]
AS
DECLARE
	@startHour		as	nvarchar(2)
,	@endHour		as	nvarchar(2)
,	@startMinute		as	nvarchar(2)
,	@endMinute		as	nvarchar(2)
,	@startHourMinutes	as	nvarchar(4)
,	@endHourMinutes	as	nvarchar(4)
	/* ?? ???? 7? ???? ?? */
	SET @startHour = datepart(hh, dateadd(mi, 4, getdate()))
	SET @startMinute = datepart(mi, dateadd(mi, 4, getdate()))
	/* ?? ???? 1? ???? ??*/
	SET @endHour = datepart(hh, dateadd(mi, 1, getdate()))
	SET @endMinute = datepart(mi, dateadd(mi, 1, getdate()))
	IF len(@startHour) = 1
	BEGIN
		SET @startHour = '0' + @startHour
	END
	IF len(@endHour) = 1
	BEGIN
		SET @endHour = '0' + @endHour
	END
	IF len(@startMinute) = 1
	BEGIN
		SET @startMinute = '0' + @startMinute
	END
	IF len(@endMinute) = 1
	BEGIN
		SET @endMinute = '0' + @endMinute
	END
	SET @startHourMinutes = @startHour + @startMinute
	SET @endHourMinutes = @endHour + @endMinute
	UPDATE tblUserGameService SET limitTime = usedLimitTime + 4 WHERE userNumber in
	(
		SELECT userNumber FROM tblUser with (nolock) WHERE userId = 'ncash004'
	)
	UPDATE tblUserGameService SET endDt = dateadd(mi, 4, getdate()) WHERE userNumber in
	(
		SELECT userNumber FROM tblUser with (nolock) WHERE userId = 'ncash005'
	)
	UPDATE tblUserGameService SET playableMinutes = 4, usedPlayableMinutes = 0 WHERE userNumber in
	(
		SELECT userNumber FROM tblUser with (nolock) WHERE userId = 'ncash006'
	)
	UPDATE tblUserGameService SET applyEndTime = @startHourMinutes WHERE userNumber in
	(
		SELECT userNumber FROM tblUser with (nolock) WHERE userId = 'ncash007'
	)
	UPDATE tblUserGameService SET limitTime = usedLimitTime + 1 WHERE userNumber in
	(
		SELECT userNumber FROM tblUser with (nolock) WHERE userId = 'ncash008'
	)
	UPDATE tblUserGameService SET endDt = dateadd(mi, 1, getdate()) WHERE userNumber in
	(
		SELECT userNumber FROM tblUser with (nolock) WHERE userId = 'ncash009'
	)
	UPDATE tblUserGameService SET playableMinutes = 1, usedPlayableMinutes = 0 WHERE userNumber in
	(
		SELECT userNumber FROM tblUser with (nolock) WHERE userId = 'ncash010'
	)
	UPDATE tblUserGameService SET applyEndTime = @endHourMinutes WHERE userNumber in
	(
		SELECT userNumber FROM tblUser with (nolock) WHERE userId = 'ncash011'
	)
	UPDATE tblUserGameService SET endDt = dateadd(m, 1, getdate()) WHERE userNumber in
	(
		SELECT userNumber FROM tblUser with (nolock) WHERE userId = 'ncash012'
	)
GO
/****** Object:  StoredProcedure [dbo].[procSettlementSummary]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
??? ?? ??
*/
create proc  [dbo].[procSettlementSummary]
as


DECLARE  @createDt datetime
DECLARE  @chongphanId INT
set @createDt = '2004-09-10'
SET @chongphanId= 1
select chongphanname, sum(TOT) as [TOTSUM]
FROM 
(

	SELECT  pg.quantity, p.productAmount * sum(pg.quantity) as TOT , cp.chongphanId, cp.chongphanname
	FROM tblPpCardGroup pg 
		JOIN tblProduct p 	on p.productId=pg.productId
		JOIN tblChongPhan cp on cp.chongphanId=pg.chongphanId
	WHERE  pg.createDt > @createDt
	GROUP BY pg.productId,p.productAmount,pg.quantity ,cp.chongphanId, cp.chongphanName
)
as chongphan
--where chongphanId=@chongphanId
GROUP BY  chongphanname

















SELECT * FROM tblPpCardGroup
select * from tblPpCardUserInfoMapping



	SELECT cp.chongphanname, sum(cashAmount)   FROM tblTransaction t 
		JOIN tblPpCardUserInfoMapping pm ON pm.userNumber=t.userNumber
		JOIN tblPpCard	pc ON pc.ppCardId=pm.ppCardId
		JOIN tblPpCardGroup pg ON pg.ppCardGroupId=pc.ppCardGroupId
		JOIN tblChongphan cp ON cp.chongphanId=pg.chongphanId				
	WHERE t.transactionTypeId = 1 and t.registDt between '2004-10-10' and '2004-12-23'
	GROUP BY cp.chongphanname , t.cashAmount
	order by cp.chongphanname asc


--??? ??? ppcard ? Total Amount

	SELECT  pg.quantity, p.productAmount * sum(pg.quantity), cp.chongphanName,p.productName,cp.chongphanId
	FROM tblPpCardGroup pg 
		JOIN tblProduct p 	on p.productId=pg.productId
		JOIN tblChongPhan cp on cp.chongphanId=pg.chongphanId
	WHERE  pg.createDt > '2004-09-01'
	GROUP BY pg.productId,p.productAmount, cp.chongphanName,p.productName, pg.quantity ,cp.chongphanId
	order by cp.chongphanId 

--?? ??? ??? ?? ??? ppCard Total Amount
SELECT SUM(TOT)
FROM
(
		SELECT p.productAmount * quantity AS  TOT
		FROM tblPpCardGroup pg
			JOIN tblChongphan cp on cp.chongphanId=pg.chongphanId
			JOIN tblProduct	p  ON p.productId=pg.productId
		WHERE pg.chongphanId=1
) AS chongphan	







--select * from tblChongphan
select * from tblProduct
select * from tblPpCardGroup where  createDt > '2004-9-01'


update tblppCardGroup set productId=1020 where ppCardGroupId=133 


select * from tblMenulist m  join tblCodeAdmintypemenu c on c.menuId=m.menuId
select * from tblAdmin
--select * from tblCodeAdminGradeType
--select * from tblCodeAdminGroupType
select * from tblCodeAdmintypemenu

update tblCodeAdminTypeMenu set adminTypeId=4  where menuId=10 and adminTypeId=2 and sortId=1

select * from tblMenulist m  join tblCodeAdmintypemenu c on c.menuId=m.menuId
select * from tblAdmin
select * from tblCodeAdminTypeMenu


select * from tblPpCardGroup
select * from tblChongphan
insert into tblPpCardGroup values(1020, 1, 10, getdate(), getdate(), dateadd(m, 3, getdate()), 1, 15, 1)
GO
/****** Object:  StoredProcedure [dbo].[procSettlementProductISDistributor]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
??? ??? ???? ??? ??? ???, ? ??? ???? ??? ?????? ?? ?? 
????
*/

CREATE PROC [dbo].[procSettlementProductISDistributor]
	@productId		INT
,	@startDt		VARCHAR(10)
,	@endDt		varchar(10)
,	@isAll		INT

AS


IF @isAll = 1 
BEGIN
	SELECT  chongphanName,  totAmount, ISNULL(usedAmount, 0) AS usedAmount
	FROM
	(
	
		SELECT  p.productAmount * sum(pg.quantity) as totAmount,pg.chongphanId,cp.chongphanName
		FROM tblPpCardGroup pg   with(nolock)
			JOIN tblProduct p   with(nolock) on p.productId=pg.productId
			JOIN tblChongphan cp  with(nolock)  on  cp.chongphanId=pg.chongphanId	
		WHERE pg.productId=@productId  
		GROUP BY   pg.chongphanId, p.productAmount, chongphanName
	)
	 as  tot  LEFT OUTER JOIN 
	(
		SELECT sum(p.productAmount) as usedAmount,  cp.chongphanId
		FROM 	tblPpCardGroup pg  with(nolock)
			JOIN tblProduct p 	 with(nolock) on p.productId=pg.productId
			JOIN tblPpCard pc	 with(nolock) ON pc.ppCardGroupId=pg.ppCardGroupId
			JOIN tblPpCardUserInfoMapping pm  with(nolock)  on pm.ppCardId=pc.ppCardId
			JOIN tblChongphan cp  with(nolock) on cp.chongphanId=pg.chongphanId
		WHERE pg.productId=@productId
		GROUP BY  cp.chongphanId
	
	)   usedtot
	 ON  tot.chongphanId=usedtot.chongphanId
END
ELSE
BEGIN
	SELECT  chongphanName,  totAmount, ISNULL(usedAmount, 0) AS usedAmount
	FROM
	(
	
		SELECT  p.productAmount * sum(pg.quantity) as totAmount,pg.chongphanId,cp.chongphanName
		FROM tblPpCardGroup pg   with(nolock)
			JOIN tblProduct p   with(nolock) on p.productId=pg.productId
			JOIN tblChongphan cp  with(nolock)  on  cp.chongphanId=pg.chongphanId	
		WHERE pg.productId=@productId AND pg.createDt  between @startDt  and @endDt
		GROUP BY   pg.chongphanId, p.productAmount, chongphanName
	)
	 as  tot  LEFT OUTER JOIN 
	(
		SELECT sum(p.productAmount) as usedAmount,  cp.chongphanId
		FROM 	tblPpCardGroup pg  with(nolock)
			JOIN tblProduct p 	 with(nolock) on p.productId=pg.productId
			JOIN tblPpCard pc	 with(nolock) ON pc.ppCardGroupId=pg.ppCardGroupId
			JOIN tblPpCardUserInfoMapping pm  with(nolock)  on pm.ppCardId=pc.ppCardId
			JOIN tblChongphan cp  with(nolock) on cp.chongphanId=pg.chongphanId
		WHERE pg.productId=@productId AND pg.createDt  between @startDt  and @endDt
		GROUP BY  cp.chongphanId
	
	)   usedtot
	 ON  tot.chongphanId=usedtot.chongphanId
END
GO
/****** Object:  StoredProcedure [dbo].[procSettlementForProductEach]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
??? ??? ? ppCard ?? ??/??? ??
*/

CREATE proc [dbo].[procSettlementForProductEach]
	@startDt	datetime
,	@endDt	datetime
,	@all		int  --1?? ? ??? ? ?? 0 ?? ??? ??? ??
as

IF @all = 1
BEGIN
	SELECT totAmount , usedAmount, tot.productId, productName
	FROM
	(
		SELECT  p.productAmount * sum(pg.quantity) as totAmount , pg.productId, p.productName
		FROM tblPpCardGroup pg  with(nolock) JOIN tblProduct p  with(nolock) on p.productId=pg.productId
		GROUP BY pg.productId, p.productAmount, p.productName 
	) as  tot left outer JOIN 
	(
		SELECT p.productId , sum(p.productAmount) as usedAmount
		FROM 	tblPpCardGroup pg 
			JOIN tblProduct p   with(nolock)	on p.productId=pg.productId
			JOIN tblPpCard pc	  with(nolock) ON pc.ppCardGroupId=pg.ppCardGroupId
			JOIN tblPpCardUserInfoMapping pm  with(nolock)  on pm.ppCardId=pc.ppCardId
		GROUP BY p.productId,  p.productAmount, p.productName
	)   usedtot
	 ON tot.productId=usedtot.productId

END
ELSE
BEGIN
	SELECT  totAmount , usedAmount ,  tot.productId, productName
	FROM
	(
		--SELECT  p.productAmount * sum(pg.quantity) as totAmount , pg.productId, p.productName
		SELECT  sum( p.productAmount  * pg.quantity) as totAmount , pg.productId, p.productName
		FROM tblPpCardGroup pg   with(nolock) JOIN tblProduct p  with(nolock)  on p.productId=pg.productId
		WHERE pg.createDt  between @startDt  and @endDt
		GROUP BY pg.productId, p.productName
	) as  tot
	 left  JOIN 
	(
		--SELECT p.productId , count(pg.ppCardGroupId) * p.productAmount as usedAmount
		SELECT p.productId , sum(p.productAmount) as usedAmount
		FROM 	tblPpCardGroup pg  with(nolock)
			JOIN tblProduct p   with(nolock)	on p.productId=pg.productId
			JOIN tblPpCard pc  with(nolock)	ON pc.ppCardGroupId=pg.ppCardGroupId
			JOIN tblPpCardUserInfoMapping pm  with(nolock) on pm.ppCardId=pc.ppCardId
		WHERE pg.createDt  between @startDt  and @endDt
		GROUP BY p.productId, p.productName
		--GROUP BY p.productId, pg.ppCardGroupId, p.productName
	)   usedtot
	 ON tot.productId=usedtot.productId

	--GROUP BY tot.productId, productName

END
GO
/****** Object:  StoredProcedure [dbo].[procSettlementForOneChongphan]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
?? ? ???  ??? ??? ? ???? ?? ??
*/
CREATE proc [dbo].[procSettlementForOneChongphan]
	@chongphanId	INT
AS

select chongphanname, sum(TOT) as [TOTSUM]
FROM 
(

	SELECT  pg.quantity, p.productAmount * sum(pg.quantity) as TOT , cp.chongphanId, cp.chongphanname
	FROM tblPpCardGroup pg 
		JOIN tblProduct p 	on p.productId=pg.productId
		JOIN tblChongPhan cp on cp.chongphanId=pg.chongphanId
	GROUP BY pg.productId,p.productAmount,pg.quantity ,cp.chongphanId, cp.chongphanName
)
as chongphan
where chongphanId=@chongphanId
GROUP BY  chongphanname
GO
/****** Object:  StoredProcedure [dbo].[procSettlementForDistributorOne]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
??? ? ppCard ?? ??/??? ??
*/

CREATE proc [dbo].[procSettlementForDistributorOne]
	@chongphanId  INT
as

SELECT totAmount,  isNull(usedAmount, 0) as usedAmount,  tot.productId,  productName
FROM
(
-- ??? ??? ?? ??? ?? ?? ?? ??

	SELECT   (sum(pg.quantity) * p.productAmount) as totAmount   , pg.productId, p.productName
	FROM tblPpCardGroup pg   with(nolock)
		JOIN tblProduct p   with(nolock)  on p.productId=pg.productId
		left outer JOIN tblChongphan cp   with(nolock)  on  cp.chongphanId=pg.chongphanId
	WHERE pg.chongphanId=@chongphanId
	GROUP BY pg.productId, p.productName, p.productAmount


) as  tot  left outer JOIN 

(
---??? ??? ?? ??? ?? ??? ??? ??

	SELECT  sum(p.productAmount)  as usedAmount , p.productId
	FROM tblPpCardGroup pg   with(nolock) 
		JOIN tblPpCard pc   with(nolock) on pc.ppCardGroupId= pg.ppCardGroupId
		JOIN tblPpCardUserInfoMapping pm    with(nolock) ON pm.ppCardId=pc.ppCardId
		LEFT outer JOIN tblChongphan cp   with(nolock)  on  cp.chongphanId=pg.chongphanId
		JOIN tblProduct p   with(nolock)  on p.productId=pg.productId
	WHERE cp.chongphanId=@chongphanId
	GROUP BY   p.productId

)   used
ON tot.productId=used.productId
GO
/****** Object:  StoredProcedure [dbo].[procSettlementForDistributor]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
??? ? ppCard ?? ??/??? ??
*/

CREATE proc [dbo].[procSettlementForDistributor]
	@startDt	datetime
,	@endDt	datetime
,	@isAll		int
as

IF @isAll = 1
BEGIN
	SELECT totAmount,  isNull(usedAmount, 0) as usedAmount,  tot.chongphanId,  chongphanName
	FROM
	(
	--??? ?? ??? ?? ?? ?? ??
	
		SELECT  sum(p.productAmount * pg.quantity)  as totAmount ,  cp.chongphanName, cp.chongphanId
		FROM tblPpCardGroup pg  with(nolock)
			JOIN tblProduct p   with(nolock)  on p.productId=pg.productId
			LEFT  outer JOIN tblChongphan cp    with(nolock) on  cp.chongphanId=pg.chongphanId
		GROUP BY cp.chongphanId, cp.chongphanName
	
	) as  tot  left outer JOIN 
	
	(
	---??? ?? ??
	
		SELECT  isNull(sum(amount), 0) as usedAmount , chongphanId
		FROM 
		(	
	
			SELECT  sum(p.productAmount)  as amount , cp.chongphanId
			FROM tblPpCardGroup pg    with(nolock)
				JOIN tblPpCard pc   with(nolock) on pc.ppCardGroupId= pg.ppCardGroupId
				JOIN tblPpCardUserInfoMapping pm    with(nolock) ON pm.ppCardId=pc.ppCardId
				LEFT outer JOIN tblChongphan cp   with(nolock)  on  cp.chongphanId=pg.chongphanId
				JOIN tblProduct p   with(nolock) on p.productId=pg.productId
				GROUP BY   p.productId, cp.chongphanId
			--GROUP BY   pc.ppCardGroupId, cp.chongphanId
		) t
		GROUP BY chongphanId
	
	)   used
	ON tot.chongphanId=used.chongphanId
END
ELSE
BEGIN
	SELECT totAmount,  isNull(usedAmount, 0) as usedAmount,  tot.chongphanId,  chongphanName
	FROM
	(
	--??? ?? ??? ?? ?? ?? ??
	
		SELECT  sum(p.productAmount * pg.quantity)  as totAmount ,  cp.chongphanName, cp.chongphanId
		FROM tblPpCardGroup pg  with(nolock)
			JOIN tblProduct p   with(nolock)  on p.productId=pg.productId
			LEFT  outer JOIN tblChongphan cp    with(nolock) on  cp.chongphanId=pg.chongphanId
			WHERE pg.createDt  between @startDt  and @endDt
		GROUP BY cp.chongphanId, cp.chongphanName
	
	) as  tot  left outer JOIN 
	
	(
	---??? ?? ??
	
		SELECT  isNull(sum(amount), 0) as usedAmount , chongphanId
		FROM 
		(	
	
			SELECT  sum(p.productAmount)  as amount , cp.chongphanId
			FROM tblPpCardGroup pg    with(nolock)
				JOIN tblPpCard pc   with(nolock) on pc.ppCardGroupId= pg.ppCardGroupId
				JOIN tblPpCardUserInfoMapping pm    with(nolock) ON pm.ppCardId=pc.ppCardId
				LEFT outer JOIN tblChongphan cp   with(nolock)  on  cp.chongphanId=pg.chongphanId
				JOIN tblProduct p   with(nolock) on p.productId=pg.productId
			WHERE pg.createDt  between @startDt  and @endDt
			GROUP BY   p.productId, cp.chongphanId			
			--GROUP BY   pc.ppCardGroupId, cp.chongphanId
		) t
		GROUP BY chongphanId
	
	)   used
	ON tot.chongphanId=used.chongphanId
END
GO
/****** Object:  StoredProcedure [dbo].[procSettlementAllChongphan]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
??? ?? ???   ??? ??? ? ???? ?? ??
*/
CREATE proc [dbo].[procSettlementAllChongphan]

AS

SELECT chongphanname, sum(TOT) as [TOTSUM]  , chongphanId
FROM 
(

	SELECT  pg.quantity, p.productAmount * sum(pg.quantity) as TOT , cp.chongphanId, cp.chongphanname--, pg.ppCardGroupId
	FROM tblPpCardGroup pg 
		JOIN tblProduct p 	on p.productId=pg.productId
		JOIN tblChongPhan cp on cp.chongphanId=pg.chongphanId
--	WHERE  pg.createDt > '2004-10-01'--> @createDt
	GROUP BY pg.productId,p.productAmount,pg.quantity ,cp.chongphanId, cp.chongphanName--,pg.ppCardGroupId
)
as chongphan
--where chongphanId=@chongphanId
GROUP BY  chongphanname, chongphanId
GO
/****** Object:  StoredProcedure [dbo].[procSettlement_old]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSettlement_old    Script Date: 23/1/2546 11:40:26 ******/
CREATE PROCEDURE [dbo].[procSettlement_old]
	@checkValue 	as	tinyint
,	@startDt	as	datetime
,	@endDt	as	datetime
,	@cpId		as	int
 AS
	if @checkValue = 1 
		begin	
			select cc.chargeTypeId as chargeTypeId,  sum(cashAmount) as amount
			from tblTransaction t, tblCharge c, tblCodeChargeType cc,  tblSettlementChargeMap s
			where t.transactionId= c.transactionId and cc.chargeTypeId = c.chargeTypeId and s.chargeTypeId= c.chargeTypeId
				and t.transactionTypeId = 1 and t.registDt between @startDt and @endDt and s.settlementTypeId = 1 and  t.cpId = @cpId 
			group by cc.chargeTypeId
			order by cc.chargeTypeId 
		end 
	else 
		begin
			select ct.chargeTypeId as chargeTypeId, -sum(t2.cashAmount ) as amount
			from tblTransaction t1 inner join tblTransaction t2  on t1.transactionId = t2.peerTransactionId
				join tblCharge c on c.transactionId = t1.transactionId
				join tblCodeChargeType ct on ct.chargeTypeId = c.chargeTypeId
				join tblSettlementChargeMap s on c.chargeTypeId = s.chargeTypeId
			where t2.registDt between @startDt and @endDt  and settlementTypeId = 1 and  t2.cpId = @cpId
			group by ct.chargeTypeId
		end
GO
/****** Object:  StoredProcedure [dbo].[procSettlement]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSettlement    Script Date: 23/1/2546 11:40:25 ******/
CREATE PROCEDURE [dbo].[procSettlement]
	@startDt	as	datetime
,	@endDt	as	datetime
,	@cpId		as	int
 AS
DECLARE @SumOfChargeAmount AS int
DECLARE @SumOfCancelAmount AS int
SELECT @SumOfChargeAmount = sum(cashAmount) 
FROM tblTransaction T WITH (NOLOCK)  
WHERE T.cpId = @cpId
GO
/****** Object:  StoredProcedure [dbo].[procSelectUserPassword]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSelectUserPassword    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procSelectUserPassword
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	???? ??? ???
	Input Parameters :	
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
		EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procSelectUserPassword]
	@userId				as	nvarchar(32)		
,	@cpId					as	int
,	@userSurName				as	nvarchar(32)		OUTPUT
,	@userFirstName				as	nvarchar(32)		OUTPUT
as
	SELECT @userSurName = userSurName, @userFirstName = userFirstName
	FROM tblUserInfo with (nolock)
	WHERE userId = @userId AND cpId = @cpId
GO
/****** Object:  StoredProcedure [dbo].[procSelectUserNumberCursor]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
/*
??? userNumber  ??? ??? ????
???  procUpdateUserGameService sp?    userNumber   ? ???? ??? ????
procUpdateUserGameService ??? ?? ??? tblUserGameServiceHistory? ?? update ??
???? ??? tblUserGameService ?? update ??
*/
-- =============================================

CREATE PROC [dbo].[procSelectUserNumberCursor]

AS

DECLARE userCursor CURSOR
KEYSET
FOR SELECT   userNumber from tblUserGameService with(nolock) --where startDt > '2005-03-17 00:00:00' or limittime -usedLimitTime > 1

DECLARE @userNumber int

OPEN userCursor

FETCH NEXT FROM userCursor  INTO @userNumber
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
	--print 'ddd'
		--exec procUpdateUserGameService @userNumber
		select getdate()
	END
	FETCH NEXT FROM userCursor  INTO @userNumber	
END

CLOSE userCursor
DEALLOCATE userCursor
GO
/****** Object:  StoredProcedure [dbo].[procSelectUserInfo]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSelectUserInfo    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procSelectUserInfo
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	???? ??? ???
	Input Parameters :	
		@userId				as	nvarchar(32)		
		@cpId					as	int			
		@password				as	nvarchar(32)		
		@userName				as	nvarchar(16)		
		@ssno					as	nvarchar(13)		
		@birthday				as	smalldatetime		
		@isSolar				as	bit			
		@zipcode				as	nchar(6)			
		@address				as	nvarchar(64)		
		@addressDetail				as	nvarchar(64)		
		@phoneNumber				as	nvarchar(16)		
		@email					as	nvarchar(64)		
		@passwordCheckQuestionTypeId	as	int
		@passwordCheckAnswer		as	nvarchar(64)		
		@userNumber				as	int		OUTPUT
			
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
		EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procSelectUserInfo]
	@userId				as	nvarchar(32)		
,	@cpId					as	int
,	@userSurName				as	nvarchar(32)		OUTPUT
,	@userFirstName				as	nvarchar(32)		OUTPUT
,	@ssno					as	nchar(13)			OUTPUT
,	@birthday				as	smallDateTime		OUTPUT
,	@isSolar				as	bit			OUTPUT
,	@zipcode				as	nchar(6)			OUTPUT
,	@nation				as	nvarchar(64)		OUTPUT	  
,	@address				as	nvarchar(64)		OUTPUT
,	@phoneNumber				as	nvarchar(16)		OUTPUT
,	@email					as	nvarchar(64)		OUTPUT
,	@passwordCheckQuestionTypeId	as	int			OUTPUT
,	@passwordCheckAnswer		as	nvarchar(64)		OUTPUT
,	@handPhoneNumber			as	nvarchar(16)		OUTPUT
,	@jobTypeId				as	smallint			OUTPUT
,	@isGetMail				as	bit			OUTPUT
,	@parentName				as	nvarchar(16)		OUTPUT
,	@parentSsno				as	nchar(13)			OUTPUT
,	@parentPhoneNumber			as	nvarchar(16)		OUTPUT
as
	SELECT @userSurName = UI.userSurName, @userFirstName = UI.userFirstName, @ssno = UI.ssno, 
		@birthday = UI.birthday, @isSolar = UI.isSolar, @zipcode = UI.zipcode, @address = UI.address, 
		@nation = UI.nation, @phoneNumber = UI.phoneNumber, @email = UI.email, 
		@passwordCheckQuestionTypeId = UI.passwordCheckQuestionTypeId,
		@passwordCheckAnswer = UI.passwordCheckAnswer, @handPhoneNumber = UD.handphoneNumber,
		@jobTypeId = UD.jobTypeId, @isGetMail = UD.isSendEmail, @parentName = parentName, @parentSsno = parentSsno,
		@parentPhoneNumber = parentPhoneNumber
	FROM tblUserInfo UI, tblUserDetail UD
	WHERE UI.userNumber = UD.userNumber AND userId = @userId AND cpId = @cpId
GO
/****** Object:  StoredProcedure [dbo].[procSelectUserId]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSelectUserId    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procUpdateUser
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	???? ID? ???
	Input Parameters :	
	@userName		as	nvarchar(32)
,	@ssno			as	nchar(13)
,	@userId		as	nvarchar(32)	OUTPUT
			
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
		EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procSelectUserId]
	@userId	as	nvarchar(32)
,	@ssno		as	nchar(13)
,	@userName	as	nvarchar(16)	OUTPUT
AS
	SELECT @userName = userFirstName + ', ' + userSurName FROM tblUserInfo with (nolock) WHERE cpId = 1 AND userId = @userId
GO
/****** Object:  StoredProcedure [dbo].[procSelectUserEmail]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSelectUserEmail    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procLoginExec
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	???? ??? ???
*/
CREATE PROCEDURE [dbo].[procSelectUserEmail]
	@userId	as	nvarchar(32)
,	@cpId		as	int
,	@userPwd	as	nvarchar(32)	OUTPUT
,	@userName	as	nvarchar(16)	OUTPUT
,	@email		as	nvarchar(64)	OUTPUT
AS
	SELECT @userPwd = userPwd, @userName = userFirstName + ', ' + userSurName, @email = email
	FROM tblUserInfo with (nolock)
	WHERE cpId = @cpId AND userId = @userId
GO
/****** Object:  StoredProcedure [dbo].[procSelectSexTerm]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE proc [dbo].[procSelectSexTerm]
	@sDate	datetime 
as
declare @0107  int ,  @0107M INT ,  @0107F	INT
declare @0810 int ,  @0810M INT ,  @0810F INT
declare @1113 int ,   @1113M INT ,  @1113F INT
declare @1416 int ,   @1416M INT ,  @1416F INT
declare @1719 int ,  @1719M INT ,  @1719F INT
declare @2024 int ,  @2024M INT , @2024F INT
declare @2529 int , @2529M INT, @2529F INT
declare @3034 int,  @3034M INT, @3034F INT
declare @3539 int , @3539M  INT, @3539F INT
declare @4049 int , @4049M INT, @4049F INT
declare @5059 int , @5059M INT, @5059F INT
declare @6069 int , @6069M INT, @6069F INT
declare @7079 int , @7079M INT, @7079F INT
declare @8089 int , @8089M INT, @8089F INT
declare @9099 int , @9099M INT, @9099F INT
declare @1000 int, @1000M INT, @1000F INT
declare @totsum int
set @totsum = 0

SELECT  @1000F=count(*) , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) > 99  and   sex = 0
SELECT  @1000M=count(*) , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) > 99  AND  sex = 1

SELECT  @9099F=count(*)   , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock)Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 90 AND  datediff(year, birthday, getdate()) <= 99 AND  sex = 0
SELECT  @9099M=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 90 AND  datediff(year, birthday, getdate()) <= 99 AND  sex = 1

SELECT  @8089F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 80 AND  datediff(year, birthday, getdate()) <= 89 AND  sex = 0
SELECT  @8089M=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 80 AND  datediff(year, birthday, getdate()) <= 89 AND  sex = 1

SELECT  @7079F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 70 AND  datediff(year, birthday, getdate()) <= 79 AND  sex = 0
SELECT  @7079M=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 70 AND  datediff(year, birthday, getdate()) <= 79 AND  sex = 1

SELECT @6069F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 60 AND  datediff(year, birthday, getdate()) <= 69 AND  sex = 0
SELECT  @6069M=count(*) , @totsum=@totsum+count(*)  From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 60 AND  datediff(year, birthday, getdate()) <= 69 AND  sex = 1

SELECT @5059F=count(*) , @totsum=@totsum+count(*)  From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 50 AND  datediff(year, birthday, getdate()) <= 59 AND  sex = 0
SELECT  @5059M=count(*) , @totsum=@totsum+count(*)  From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 50 AND  datediff(year, birthday, getdate()) <= 59 AND  sex = 1

SELECT @4049F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 40 AND  datediff(year, birthday, getdate()) <= 49 AND  sex = 0
SELECT  @4049M=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 40 AND  datediff(year, birthday, getdate()) <= 49 AND  sex = 1

SELECT @3539F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 35 AND  datediff(year, birthday, getdate()) <= 39 AND  sex = 0
SELECT  @3539M=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 35 AND  datediff(year, birthday, getdate()) <= 39 AND  sex = 1

SELECT @3034F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 30 AND  datediff(year, birthday, getdate()) <= 34 AND  sex = 0
SELECT  @3034M=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 30 AND  datediff(year, birthday, getdate()) <= 34 AND  sex = 1

SELECT @2529F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 25 AND  datediff(year, birthday, getdate()) <= 29 AND  sex = 0
SELECT  @2529M=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 25 AND  datediff(year, birthday, getdate()) <= 29 AND  sex = 1

SELECT @2024F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 20 AND  datediff(year, birthday, getdate()) <= 24 AND  sex = 0
SELECT  @2024M=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 20 AND  datediff(year, birthday, getdate()) <= 24 AND  sex = 1

SELECT @1719F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 17 AND  datediff(year, birthday, getdate()) <= 19 AND  sex = 0
SELECT  @1719M=count(*) , @totsum=@totsum+count(*)  From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 17 AND  datediff(year, birthday, getdate()) <= 19 AND  sex = 1

SELECT @1416F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 14 AND  datediff(year, birthday, getdate()) <= 16 AND  sex = 0
SELECT  @1416M=count(*) , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 14 AND  datediff(year, birthday, getdate()) <= 16 AND  sex = 1

SELECT @1113F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 11 AND  datediff(year, birthday, getdate()) <= 13 AND  sex = 0
SELECT  @1113M=count(*) , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 11 AND  datediff(year, birthday, getdate()) <= 13 AND  sex = 1

SELECT @0810F=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 8 AND  datediff(year, birthday, getdate()) <= 10 AND  sex = 0
SELECT  @0810M=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 8 AND  datediff(year, birthday, getdate()) <= 10 AND  sex = 1

SELECT @0107F=count(*) , @totsum=@totsum+count(*)  From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 1 AND  datediff(year, birthday, getdate()) <= 7 AND  sex = 0
SELECT  @0107M=count(*)  , @totsum=@totsum+count(*) From tblUserInfo as ui with(nolock) Where convert(VARCHAR(8), registDt,112) =@sDate  and  datediff(year, birthday, getdate()) >= 1 AND  datediff(year, birthday, getdate()) <= 7 AND  sex = 1

	

select 
 @0107    ,  @0107M  	M0107 , @0107F	F0107
, @0810  ,  @0810M  	M0810 , @0810F 	F0810
, @1113  ,   @1113M  	M1113 , @1113F 	F1113
, @1416  ,   @1416M 	M1416 , @1416F  F1416
, @1719  ,  @1719M  	M1719	, @1719F  F1719
, @2024  ,  @2024M  	M2024 , @2024F 	F2024
, @2529  , @2529M 		M2529 , @2529F 	F2529
, @3034 ,  @3034M 		M3034	, @3034F 	F3034
, @3539  , @3539M  		M3539 , @3539F 	F3539
, @4049  , @4049M 		M4049 , @4049F 	F4049
, @5059  , @5059M 		M5059 , @5059F 	F5059
, @6069  , @6069M 		M6069 , @6069F 	F6069
, @7079  , @7079M 		M7079 , @7079F 	F7079
, @8089  , @8089M 		M8089 , @8089F 	F8089
, @9099  , @9099M 		M9099 , @9099F 	F9099
, @1000 , @1000M 			M1000 , @1000F 	F1000
, @totsum totsum
GO
/****** Object:  StoredProcedure [dbo].[procSelectProductType]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSelectProductType    Script Date: 23/1/2546 11:40:25 ******/
CREATE PROCEDURE [dbo].[procSelectProductType]
AS
	SELECT p.productTypeId, p.descript FROM tblCodeProductType p, tblSettlementProductMap s
	WHERE p.productTypeId = s.productTypeId and s.settlementTypeId = 1
GO
/****** Object:  StoredProcedure [dbo].[procSelectPpcardSaleChongphan]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSelectPpcardSaleChongphan    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procSelectPpcardSaleChongphan
	Creation Date		:	2002. 02.01
	Written by		:	? ??
	E-Mail by 		:	jsh001@n-cash.net
	Purpose			:	ppcardsaleManager
	
	Input Parameters :	
				@adminId			AS		nvarchar(16)
	Output Parameters:	
				@returnCode			AS		SMALLINT
				
	Return Status:		
				recordSet
*/
CREATE PROCEDURE [dbo].[procSelectPpcardSaleChongphan]
	@chongphanId		AS		int
AS
	DECLARE @sumQuntity		as	int
	DECLARE @sumPrice		as	money
	DECLARE @sumCollectPrice	as	money
	DECLARE @chongphanName	as	nvarchar(32)
	SELECT  @sumQuntity = sum(Pp.quntity), @sumPrice = sum(Pp.price)
	FROM tblChongphan Ch
	JOIN tblPpCardSale Pp ON Ch.chongphanId = Pp.chongphanId
	WHERE Ch.chongphanId = @chongphanId
	
	SELECT @sumCollectPrice = Sum(Cb.price)
	FROM tblChongphan Ch
	JOIN tblPpCardBillCollect Cb ON Ch.chongphanId = Cb.chongphanId
	WHERE Ch.chongphanId = @chongphanId
	SELECT @chongphanName=Ch.chongphanName
	FROM tblChongphan Ch
	WHERE Ch.chongphanId = @chongphanId
	SELECT @chongphanName, ISNULL(@sumQuntity, 0), ISNULL(@sumPrice, 0), ISNULL(@sumCollectPrice, 0)
GO
/****** Object:  StoredProcedure [dbo].[procSelectPpcardSaleAllList]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSelectPpcardSaleAllList    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procSelectPpcardSaleAllList
	Creation Date		:	2002. 02.01
	Written by		:	? ??
	E-Mail by 		:	jsh001@n-cash.net
	Purpose			:	ppcardsaleManager
	
	Input Parameters :	
				@adminId			AS		nvarchar(16)
	Output Parameters:	
				@returnCode			AS		SMALLINT
				
	Return Status:		
				recordSet
*/
CREATE PROCEDURE [dbo].[procSelectPpcardSaleAllList]
	@chongphanId		AS		int
,	@productId		AS		int
,	@startDt		AS		smalldatetime
,	@endDt		AS		smalldatetime
AS
If @chongphanId is Null and @productId is Null
  Begin
	SELECT P.ppcardSaleId, Cp.chongphanName, Pd.productName, P.quntity, Pd.productAmount, P.price, P.registDt, Cp.chongphanId, Pd.productId
	FROM tblPpCardSale P
	JOIN tblProduct Pd ON P.productId = Pd.productId
	JOIN tblChongphan Cp ON P.chongphanId = Cp.chongphanId
	WHERE P.registDt Between @startDt and @endDt
  End
IF @chongphanId is not Null and @productId is Null
  Begin
	SELECT P.ppcardSaleId, Cp.chongphanName, Pd.productName, P.quntity, Pd.productAmount, P.price, P.registDt, Cp.chongphanId, Pd.productId
	FROM tblPpCardSale P
	JOIN tblProduct Pd ON P.productId = Pd.productId
	JOIN tblChongphan Cp ON P.chongphanId = Cp.chongphanId
	WHERE P.chongphanId = @chongphanId
		AND  P.registDt Between @startDt and @endDt
  End
IF @chongphanId is Null and @productId is not Null
  Begin
	select P.ppcardSaleId, Cp.chongphanName, Pd.productName, P.quntity, Pd.productAmount, P.price, P.registDt, Cp.chongphanId, Pd.productId
	from tblPpCardSale P
	JOIN tblProduct Pd ON P.productId = Pd.productId
	JOIN tblChongphan Cp ON P.chongphanId = Cp.chongphanId
	WHERE Pd.productId = @productId
		AND  P.registDt Between @startDt and @endDt
  End
IF @chongphanId is not Null and @productId is not Null
  Begin
	select P.ppcardSaleId, Cp.chongphanName, Pd.productName, P.quntity, Pd.productAmount, P.price, P.registDt, Cp.chongphanId, Pd.productId
	from tblPpCardSale P
	JOIN tblProduct Pd ON P.productId = Pd.productId
	JOIN tblChongphan Cp ON P.chongphanId = Cp.chongphanId
	WHERE Pd.productId = @productId AND P.chongphanId = @chongphanId
		AND  P.registDt Between @startDt and @endDt
  End
GO
/****** Object:  StoredProcedure [dbo].[procSelectChongphanForGamebangReg]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSelectChongphanForGamebangReg    Script Date: 23/1/2546 11:40:25 ******/
/*
??? : ???
?? : zipcode? ??? ?? ??? ????.
*/
CREATE PROCEDURE [dbo].[procSelectChongphanForGamebangReg]
	@zipCode			as	nchar(6)
,	@returnChongphanId		AS		INT			OUTPUT
AS
DECLARE	@sido		AS		nvarchar(50)
DECLARE	@gugun	AS		nvarchar(50)
SELECT @sido = sido , @gugun = gugun
FROM tblPost
WHERE zipCode = LEFT(@zipCode,3) + '-' + RIGHT(@zipCode,3)
IF(@sido IS NOT NULL)
	BEGIN
		SELECT @returnChongphanId = chongphanId 
		FROM tblPostToChongphan
		WHERE sido = @sido AND gugun = @gugun
		
		IF(@returnChongphanId IS NULL)
			BEGIN
				SET @returnChongphanId = 0
			END
	END
ELSE
	BEGIN
		SET @returnChongphanId = 0
	END
GO
/****** Object:  StoredProcedure [dbo].[procSelectChongphan]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procSelectChongphan    Script Date: 23/1/2546 11:40:25 ******/
CREATE PROCEDURE [dbo].[procSelectChongphan]
 AS
	DECLARE @maxValue as int
	
	select @maxValue =  MAX(chongphanId) from tblChongphan where apply = 1
	SELECT @maxValue, chongphanId, chongphanName, commission FROM tblChongphan WHERE apply = 1
GO
/****** Object:  StoredProcedure [dbo].[procSelectChargeType]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procSelectChargeType    Script Date: 23/1/2546 11:40:25 ******/
CREATE PROCEDURE [dbo].[procSelectChargeType]
 AS
	SELECT s.chargeTypeId, descript, commission FROM tblCodeChargeType c, tblSettlementChargeMap s
	WHERE c.chargeTypeId = s.chargeTypeId and s.settlementTypeId = 1 and c.apply = 1
GO
/****** Object:  StoredProcedure [dbo].[procSelectAccountGetUserId]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/*
???? ???
Account ???? ???? ? ?????? UserID ? Null ? ?? ???? ????
?? ??? INSERT ?? ?? SP
*/
-- =============================================



CREATE PROC [dbo].[procSelectAccountGetUserId]

AS
--178031--Account
--176930 --Billing

--SELECT count(*)  FROM  UserLogin.dbo.Account  where Activated=1 

--select count(*) from tbluserInfo with(nolock) 

DECLARE userCursor CURSOR
KEYSET
FOR SELECT UserID FROM  UserLogin.dbo.Account  where Activated=1  and userId is not null and  userId not in (
								 SELECT a.userId FROM  UserLogin.dbo.Account a  
								join tblUser  u with(nolock) on u.userId=a.userId 	)


DECLARE @userID  nvarchar(50)

OPEN userCursor

FETCH NEXT FROM userCursor  INTO @userID
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		exec procInsertUserSync  @userID
	END
	FETCH NEXT FROM userCursor  INTO @userID	
END

CLOSE userCursor
DEALLOCATE userCursor
GO
/****** Object:  StoredProcedure [dbo].[procRewardUserCashBalance]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procRewardUserCashBalance]
AS

SET NOCOUNT ON

DECLARE
	@tempId			as int
	, @userNumber		as int
	, @rewardedCashBalance	as int


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[tblUserInfoMatchingReward]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
	DROP TABLE [dbo].[tblUserInfoMatchingReward]
END

CREATE TABLE [tblUserInfoMatchingReward] (
	[tempId] [int] PRIMARY KEY NOT NULL ,
	[userNumber] [int] NOT NULL ,
	[rewardedCashBalance] [int] NULL
) ON [PRIMARY]

DECLARE rewardCursor CURSOR
FOR
	SELECT tempId, userNumber, rewardedCashBalance
	FROM tblRewardGameTimeToTaney

OPEN rewardCursor

FETCH NEXT FROM rewardCursor INTO @tempId, @userNumber, @rewardedCashBalance

WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE tblUserInfo SET cashBalance = @rewardedCashBalance WHERE userNumber = @userNumber
	INSERT INTO tblUserInfoMatchingReward VALUES(@tempId, @userNumber, @rewardedCashBalance)

	FETCH NEXT FROM rewardCursor INTO @tempId, @userNumber, @rewardedCashBalance
END
	
CLOSE rewardCursor
DEALLOCATE rewardCursor

SELECT TOP 1000 * FROM tblUserInfoMatchingReward

SET NOCOUNT OFF
GO
/****** Object:  StoredProcedure [dbo].[procRewardGameTimeToTaney]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procRewardGameTimeToTaney]
	@targetDt as datetime
AS

CREATE TABLE [#tblRewardGameTimeToTaney] (
	[tempId] [int] PRIMARY KEY NOT NULL,
	[userNumber] [int] NOT NULL ,
	[startDt] [smalldatetime] NULL ,
	[endDt] [smalldatetime] NULL ,
	[limitTime] [int] NOT NULL ,
	[usedLimitTime] [int] NOT NULL ,
	[cashBalance] [int] NOT NULL ,
	[expireDt] [smalldatetime] NULL ,
) ON [PRIMARY]


INSERT INTO #tblRewardGameTimeToTaney 
	SELECT tempId, userNumber, startDt, endDt, limitTime, usedLimitTime, cashBalance, expireDt
	FROM tblRewardGameTimeToTaney


DECLARE
	@tempId			as int
	, @userNumber		as int
	, @startDt		as datetime
	, @endDt			as datetime
	, @limitTime		as int
	, @usedLimitTime		as int
	, @cashBalance		as int
	, @rewardedCashBalance	as int
	, @expireDt		as datetime
--	, @targetDt		as datetime
	, @dayDiff		as int
	, @hourDiff		as int
	, @taneyRatio		as int
	, @minDiff		as int
	, @addDay		as int
	, @addTaney		as int
	, @dayMin		as int
	, @cnt			as int
	, @affectedCnt		as int
	, @totalCnt		as int
	, @restMin		as int
	, @canConvertFixedTime	as int


SET @cnt = 1
SET @affectedCnt = 0
--SET @targetDt = '2006-02-13 21:03:06.700'
SET @taneyRatio = 7
SET @dayMin = 1440


SELECT @totalCnt = COUNT(*) FROM #tblRewardGameTimeToTaney

WHILE @totalCnt >= @cnt
BEGIN
	SET @addDay = 0
	SET @addTaney = 0
	SET @minDiff = 0
	SET @restMin = 0
	SET @canConvertFixedTime = 0

	SELECT @tempId = tempId, @userNumber = userNumber, @startDt = startDt, @endDt = endDt
		, @limitTime = limitTime, @usedLimitTime = usedLimitTime, @cashBalance = cashBalance, @expireDt = expireDt
	FROM #tblRewardGameTimeToTaney
	WHERE tempId = @cnt


	IF EXISTS(
		SELECT TOP 1 * FROM tblOrder  O WITH(NOLOCK)
		JOIN tblTransaction T WITH(NOLOCK) ON O.transactionId = T.transactionId
		--JOIN tblProduct P WITH(NOLOCK) ON O.productId = P.productId
		WHERE T.transactionTypeId = 2 AND O.productId NOT IN(1091, 1055, 1089, 1090, 1053, 1031, 1021)
			AND T.userNumber = @userNumber AND T.peerTransactionId IS NULL
			AND O.productId IN(1020, 1025, 1032, 1033, 1034, 1038, 1044, 1046, 1047, 1054, 1064, 1065)
			--AND P.limitTime IS NOT NULL AND P.limitTime <> 0
	)
	BEGIN
		SET @canConvertFixedTime = 1
	END

	IF @endDt IS NOT NULL AND @endDt > @targetDt
	BEGIN
		SET @minDiff = DATEDIFF(Minute, @targetDt, @endDt)
		IF @minDiff >= @dayMin
		BEGIN
			SET @addDay = @minDiff / @daymin
			SET @restMin = @minDiff % @daymin
		END
		ELSE
		BEGIN
			SET @restMin = @minDiff
		END
	END
	
	IF @expireDt IS NOT NULL AND @expireDt > @targetDt AND @limitTime > 0 AND @canConvertFixedTime = 1
	BEGIN
		SET @minDiff = (@limitTime - @usedLimitTime)
		SET @dayDiff = @minDiff / @dayMin
		IF @dayDiff > 0
		BEGIN
			SET @addDay = @addDay + @dayDiff
			SET @restMin = @restMin + (@minDiff % @daymin)
		END
		ELSE
		BEGIN
			SET @restMin = @restMin + @minDiff
		END
	END

	IF @restMin > 0
	BEGIN	
		SET @addDay = @addDay + 1

		IF @restMin > @dayMin
			SET @addDay = @addDay + 1
	END

	IF @addDay > 0
	BEGIN
		SET @addTaney = @addDay * @taneyRatio

		--UPDATE tblUserInfo SET cashBalance = cashBalance + @addTaney WHERE userNumber = @userNumber
		UPDATE tblRewardGameTimeToTaney 
			SET rewardedCashBalance = cashBalance + @addTaney, rewardedDay = @addDay, restMin = @restMin
		 WHERE userNumber = @userNumber

		SET @affectedCnt = @affectedCnt + 1
	END

	SET @cnt = @cnt + 1
	IF (@cnt % 100 = 0)
		PRINT(@cnt)

END

SELECT @totalCnt totalCount, @cnt - 1 computedCount, @affectedCnt affectedCount
SELECT TOP 1000 * FROM tblRewardGameTimeToTaney
GO
/****** Object:  StoredProcedure [dbo].[procReserveCheck4]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procReserveCheck4    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procReserveCheck 
	Creation Date		:	2002. 02.17
	Written by		:	? ??
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	?? ??? ??? ????
	
	Input Parameters :	
				@gamebangId			AS		SMALLINT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				? ?? ??? ?? ??. ???? ???? ???? ?? ?? ????.
				? IP ??? 
					1. ????? ???? ????? ???. 
					2. ??? ?? ???? ?? ??? ??.
					3. ??? ?? ??? ??? ??? ??? ?? ??? ??.
				1: ???? ??? ?? ??? ,?? ??? ? ? ??.
				2: ???? ??? ??? ???? ???????(?? ??? ??) ?? ??? ???? ???.
				3: ???? ??? ??? ???? ???? ???(????) ??? ??? ? ??.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procReserveCheck4] 
	@gamebangId			AS		INT
,	@lastEndDt			AS		SMALLDATETIME	OUTPUT
,	@returnCode			AS		TINYINT		OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@timeLastTransaction		AS		INT
DECLARE	@startDt			AS		SMALLDATETIME
DECLARE	@endDt			AS		SMALLDATETIME
------------------------?? ???--------------------
--???(IP) ??? ??
SELECT @timeLastTransaction = MAX(T.transactionId)
FROM tblGamebangGameServiceHistory GGSH INNER JOIN tblTransaction T ON GGSH.transactionId = T.transactionId
INNER JOIN tblOrder O ON T.transactionId = O.transactionId
INNER JOIN tblProduct P ON O.productId = P.productId
WHERE T.peerTransactionId IS NULL AND P.productPeriod IS NOT NULL AND GGSH.gamebangId = @gamebangId
IF(@timeLastTransaction IS NULL)
	BEGIN
		--???(??) ??? ??.		--???? ??
		SET @returnCode = 1
	END
ELSE
	BEGIN
		SELECT @startDt = startDt ,@endDt = endDt FROM tblGamebangGameServiceHistory WHERE transactionId = @timeLastTransaction
		IF(@endDt < GETDATE()) 
			BEGIN
				--??? ??? ? ????? ????? ??
				SET @returnCode = 1
			END
		ELSE
			BEGIN
				--?? ???? ?????.??(??)?? ??
				SET @lastEndDt = @endDt
				SET @returnCode = 2
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[procReserveCheck3]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procReserveCheck3    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procReserveCheck 
	Creation Date		:	2002. 02.17
	Written by		:	? ??
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	?? ??? ??? ????
	
	Input Parameters :	
				@gamebangId			AS		SMALLINT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ???? ??? ?? ??? ,?? ??? ? ? ??.
				2: ???? ??? ??? ???? ???????(?? ??? ??) ?? ??? ???? ???.
				3: ???? ??? ??? ???? ???? ???(????) ??? ??? ? ??.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procReserveCheck3] 
	@gamebangId			AS		INT
,	@returnCode			AS		TINYINT	OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@timeLastTransaction		AS		INT
DECLARE	@startDt			AS		SMALLDATETIME
DECLARE	@endDt			AS		SMALLDATETIME
------------------------?? ???--------------------
--???(??) ??? ??
SELECT @timeLastTransaction = MAX(T.transactionId)
FROM tblGamebangGameServiceHistory GGSH INNER JOIN tblTransaction T ON GGSH.transactionId = T.transactionId
INNER JOIN tblOrder O ON T.transactionId = O.transactionId
INNER JOIN tblProduct P ON O.productId = P.productId
WHERE T.peerTransactionId IS NULL AND P.productPeriod IS NOT NULL AND GGSH.gamebangId = @gamebangId
IF(@timeLastTransaction IS NULL)
	BEGIN
		--???(??) ??? ??.		--???? ??
		SET @returnCode = 1
	END
ELSE
	BEGIN
		SELECT @startDt = startDt ,@endDt = endDt FROM tblGamebangGameServiceHistory WHERE transactionId = @timeLastTransaction
		IF(@endDt < GETDATE()) 
			BEGIN
				--??? ??? ? ????? ????? ??
				SET @returnCode = 1
			END
		ELSE IF(GETDATE() BETWEEN @startDt AND @endDt )
			BEGIN
				--?? ???? ?????.???? ??
				SET @returnCode = 2
			END
		ELSE IF(@startDt > GETDATE())
			BEGIN
				--???????? ???
				IF(EXISTS(SELECT * FROM tblGamebangGameService WHERE GETDATE() BETWEEN startDt AND endDt AND gamebangId = @gamebangId))
					BEGIN
						SET @returnCode = 2		--?? ???? ?????.???? ??
					END
				ELSE
					BEGIN
						SET @returnCode = 3		--?? ?? ????.?? ???
					END
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[neverToppedupUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[neverToppedupUser]
	@startDt AS datetime
AS
-- SET @startDt = '2006-04-01 00:00:00'

SELECT userId, email, userFirstName, userSurName
FROM tblUserInfo WITH(NOLOCK)
WHERE 
userNumber NOT IN(SELECT userNumber FROM tblTestUser) AND
userNumber NOT IN(
SELECT DISTINCT(userNumber)
FROM tblCharge C WITH(NOLOCK)
JOIN tblTransaction T WITH(NOLOCK) ON C.transactionId = T.transactionId
WHERE T.registDt >= @startDt AND T.transactionTypeId = 1 AND C.chargeTypeId <> 16
AND T.TransactionId IS NOT NULL
)
GO
/****** Object:  StoredProcedure [dbo].[hb_tan_gp_userinfo_se]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[hb_tan_gp_userinfo_se]
	@userId	AS	nvarchar(64)	
AS

DECLARE @cashBalance	AS	INT
SELECT @cashBalance = cashBalance FROM tblUserInfo 
WHERE userId = @userId AND apply = 1
IF(@@ROWCOUNT = 0)
	SET @cashBalance = -1

SELECT @cashBalance AS cashBalance
GO
/****** Object:  StoredProcedure [dbo].[hb_tan_gp_applyinfo_userinfo_in]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[hb_tan_gp_applyinfo_userinfo_in]    
 @userId   as NVARCHAR(52)    
, @userIp   as varchar(17)    
, @contentCode   as varchar(3)   -- ?????
, @contentTypeCode  as varchar(3)  --TYPEODE " I0 " ?? ??? ???    
, @productId   as int    
, @quantity   as int 
, @unitPrice   as int
, @sinvalor   as VARCHAR(3)
, @userkey as NVARCHAR(7)      
AS    
---------------------------------------------------------------------------------------------------------------------    
DECLARE @chargeTransactionId AS INT    
DECLARE @orderNumber   AS NVARCHAR    
DECLARE @point   AS INT    
DECLARE @adminLogId   AS INT     
DECLARE @transactionId  AS INT    
    
    
---------------------------------------------------------------------------------------------------------------------    
DECLARE @userNumber  as INT    
DECLARE @cashAmount  as int    
DECLARE @pointToCashAmount as int    
DECLARE @userTypeId   as tinyInt    
DECLARE @userStatusId  as tinyInt    
DECLARE @cashBalance  as int    
DECLARE @pointToCashBalance as int    
DECLARE @holdCashBalance  as int    
DECLARE @pointBalance  as int    
DECLARE @now   as datetime    
DECLARE @transactionTypeId  as tinyInt    
DECLARE @canOrder   as bit    
DECLARE @productTypeId  as tinyInt    
DECLARE @updateUserStatusId  as tinyInt    
DECLARE @userCpId   as int    
DECLARE @errorSave   as int    
DECLARE @productPoint  as  int    
    
    
SET @adminLogId   = NULL    
SET @orderNumber   = NULL    
SET @chargeTransactionId  = NULL    
    
SET @productPoint  = 0     
SET @pointToCashAmount = 0    
    
SET @errorSave = 0    
SET @now = GETDATE()    
SET @cashAmount = @unitPrice * @quantity    
SET @transactionTypeId = 2 --??    
SET @updateUserStatusId = 2 --????? ?? userStatusId    
--tblUser Select    
SELECT    
 @userNumber = userNumber, @userCpId = cpId, @userTypeId = userTypeId, @userStatusId = userStatusId, @cashBalance = cashBalance ,    
 @pointToCashBalance = pointToCashBalance, @holdCashBalance = holdCashBalance, @pointBalance = pointBalance    
FROM tblUserInfo WITH (READUNCOMMITTED)      
WHERE userId = @userId  and apply = 1    
IF @userNumber IS NULL OR @@ROWCOUNT <> 1     
 BEGIN    
  SET @transactionId = -201 --user ??
  SELECT @transactionId AS transactionId    
  RETURN    
 END    
     
    
-- ??         

BEGIN TRAN   

 --tblTransaction Insert    
 INSERT tblTransaction(transactionTypeId, userNumber, cpId, cashAmount, pointToCashAmount, pointAmount, cashBalance, pointToCashBalance, pointBalance, registDt, adminLogId)    
 VALUES        (@transactionTypeId, @userNumber, @userCpId, -@cashAmount, -@pointToCashAmount, @productPoint, @cashBalance, @pointToCashBalance, @pointBalance, @now, @adminLogId)    
 SET @errorSave = @errorSave + @@ERROR     
 --SET Return Value    
 SET @transactionId = SCOPE_IDENTITY()    
  

 INSERT tblOrderPPVDetail (transactionId, contentCode, point, unitPrice, quantity, userIp, contentTypeCode)    
 VALUES(@transactionId, @productId, @cashAmount, @unitPrice, @quantity, @userIp, @contentTypeCode)    
 SET @errorSave = @errorSave + @@ERROR     
    
    
--tblUserHistory Insert    
IF @errorSave <> 0 OR @@ERROR <> 0     
 BEGIN    
     
  SET @transactionId = -401 -- ????
  SELECT @transactionId AS transactionId       
  ROLLBACK    
  RETURN    
 END    
    
ELSE    
 BEGIN 
  SELECT @transactionId AS transactionId    
  COMMIT   
  RETURN    
 END
GO
/****** Object:  StoredProcedure [dbo].[DistributorPerDat_SP]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[DistributorPerDat_SP]
@Month1 as varchar (255) ,
@Month2 as varchar(255),
@Day1 as varchar (255),
@Day2 as varchar (255),
@Year as varchar (255)

 AS


SELECT  Distinct dbo.tblProduct.productName,MOnth (dbo.tblTransaction.registDt)as month_num,day(dbo.tblTransaction.registDt) as Date, COUNT(dbo.tblChongphan.chongphanName) AS TOTAl
FROM         dbo.tblPpCardUserInfoMapping INNER JOIN
                      dbo.tblPpCard ON dbo.tblPpCardUserInfoMapping.ppCardId = dbo.tblPpCard.ppCardId INNER JOIN
                      dbo.tblUser ON dbo.tblPpCardUserInfoMapping.userNumber = dbo.tblUser.userNumber INNER JOIN
                      dbo.tblPpCardGroup ON dbo.tblPpCard.ppCardGroupId = dbo.tblPpCardGroup.ppCardGroupId INNER JOIN
                      dbo.tblChongphan ON dbo.tblPpCardGroup.chongphanId = dbo.tblChongphan.chongphanId INNER JOIN
                      dbo.tblProduct ON dbo.tblPpCardGroup.productId = dbo.tblProduct.productId INNER JOIN
                      dbo.tblTransaction ON dbo.tblPpCardUserInfoMapping.transactionId = dbo.tblTransaction.transactionId

WHERE month(dbo.tblTransaction.registDt) Between @Month1 and @month2 and day(dbo.tblTransaction.registDt) BETWEEN @Day1 AND @day2 and year(dbo.tblTransaction.registDt) = @year
GROUP BY dbo.tblProduct.productName,month(dbo.tblTransaction.registDt),day(dbo.tblTransaction.registDt)
ORDER BY dbo.tblProduct.productName
GO
/****** Object:  StoredProcedure [dbo].[Distributor_sp]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Distributor_sp] 
@date1 as datetime,
@date2 as datetime
AS


SELECT  distinct CP.chongphanName, TP.productname, Count(TP.productName)
FROM tblTransaction T WITH (NOLOCK)
JOIN tblUserInfo UI WITH (NOLOCK) ON T.userNumber = UI.userNumber 
JOIN tblPpCardUserInfoMapping PUI WITH (NOLOCK) ON T.transactionId = PUI.transactionId 
JOIN tblPpCard PC WITH (NOLOCK) ON PUI.ppCardId = PC.ppCardId 
JOIN tblPpCardGroup PCG WITH (NOLOCK) ON PC.ppCardGroupId = PCG.ppCardGroupId
JOIN tblProduct TP WITH (NOLOCK) ON PCG.productId = TP.productId 
JOIN tblchongphan CP with (nolock) on PCG.chongphanid = CP.chongphanid
WHERE T.userNumber NOT IN(SELECT userNumber FROM tblTestuser WITH (NOLOCK)) 
And T.registDt between @date1 AND @date2 
GROUP BY CP.chongphanName , TP.productname
Order by CP.chongphanName, TP.productname
GO
/****** Object:  StoredProcedure [dbo].[expirydatebyminute_sp]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
create       PROCEDURE [dbo].[expirydatebyminute_sp]
@userid varchar(50)

 AS
SELECT  usedLimitTime,  (limitTime - usedLimitTime) as remainTime  , 
expireDt  
FROM tblUserGameService where userNumber=@userid
and gameServiceId=1
GO
/****** Object:  StoredProcedure [dbo].[expirydatebyday_sp]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
create       PROCEDURE [dbo].[expirydatebyday_sp]
@userid varchar(50)

 AS

SELECT  startDt , endDt ,  DATEDIFF(dd, GETDATE(), endDt)as remainDate ,  
 DATEDIFF(MINUTE, GETDATE(), endDt) as remainDateToMinute
FROM tblUserGameService where userNumber=@userid and gameServiceId=1
GO
/****** Object:  StoredProcedure [dbo].[procChargeCancel]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	Stored Procedure	:	procChargeCancel
	Creation Date		:	2002. 2. 18.
	Written by		:	? ??
	E-Mail by 		:	windist@n-cash.net
	Purpose			:	????? ????
	Input Parameters :	
			
	return?:
	@transactionId		as	integer		:	 ???? ????ID
	Call by		:	TransactionManager.Transaction.charge
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I)	, tblUserInfo(U)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procChargeCancel]
	@chargeTransactionId	as	int
,	@adminLogId		as	int
,	@transactionId		as	int	output
as
DECLARE @transactionTypeId	as	tinyInt
DECLARE @cashAmount			as	int
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @pointBalance		as	int
DECLARE @now				as	datetime
DECLARE @temp				as	int
DECLARE @errorSave			as	int
DECLARE @peerTransactionId	as	int
DECLARE @userNumber			as	int
DECLARE @cpId				as	int
SET @errorSave = 0
Set @transactionTypeId = 5
Set @now = getDate()
-- SELECT tblTransaction
SELECT
	@userNumber = userNumber,@cpId = cpId,@cashAmount = cashAmount, @peerTransactionId = peerTransactionId
FROM
	tblTransaction
WHERE
	transactionId = @chargeTransactionId AND peerTransactionId = null
	
IF @peerTransactionId is not null
BEGIN
	SET @transactionId = -505
	RETURN
END
IF @userNumber is null
BEGIN
	SET @transactionId = -207
	RETURN
END
-- SELECT tblUser
SELECT
	@cashBalance= cashBalance ,@pointToCashBalance=pointToCashBalance,@pointBalance=pointBalance
FROM tblUserInfo WHERE userNumber = @userNumber AND apply = 1
IF @cashBalance is null
BEGIN
	SET @transactionId = -201
	RETURN
END
IF (@cashBalance-@pointToCashBalance) < @cashAmount
BEGIN
	SET @transactionId = -502
	RETURN
END
-- INSERT tblTransaction
INSERT
	tblTransaction(transactionTypeId, userNumber, cpId, cashAmount, cashBalance, pointToCashBalance, pointBalance, registDt, adminLogId, peerTransactionId)
VALUES(@transactionTypeId, @userNumber, @cpId, -@cashAmount, @cashBalance-@cashAmount, @pointToCashBalance, @pointBalance, @now, @adminLogId, @chargeTransactionId)
SET @errorSave = @errorSave + @@ERROR
SET @transactionId = @@IDENTITY
-- UPDATE tblTransaction
UPDATE tblTransaction SET peerTransactionId = @transactionId WHERE transactionId = @chargeTransactionId
SET @errorSave = @errorSave + @@ERROR
-- UPDATE USERINFO
UPDATE tblUserInfo SET cashBalance = @cashBalance-@cashAmount WHERE userNumber = @userNumber
SET @errorSave = @errorSave + @@ERROR
IF @errorSave <> 0
	SET @transactionId = -401 -- sp ERROR
GO
/****** Object:  StoredProcedure [dbo].[procChargeByItemBill]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procChargeByItemBill]
	@chargeTypeId		as	tinyInt	
,	@userNumber		as	int
,	@cpId			as	int
,	@cashAmount		as	int
,	@adminLogId		as	int
,	@transactionId		as	int	output
as
DECLARE @transactionTypeId		as	tinyInt
DECLARE @cashBalance		as	int
DECLARE @pointToCashBalance	as	int
DECLARE @pointBalance		as	int
DECLARE @now			as	datetime
DECLARE @temp			as	int
DECLARE @errorSave		as	int

SET @errorSave = 0
Set @transactionTypeId = 1
Set @now = getDate()
--user check
SELECT @temp = count(*) FROM tblUser as u with(nolock) , tblUserInfo as ui with(nolock) Where u.userNumber = ui.userNumber AND u.apply=1 AND u.userNumber = @userNumber
IF @temp = 1
BEGIN
	--cashBalance... Set
	SELECT @cashBalance = cashBalance , @pointToCashBalance = pointToCashBalance, @pointBalance = pointBalance
	FROM tblUserInfo with(rowLock) WHERE userNumber = @userNumber
	
	--??
	SET @cashBalance = @cashBalance + @cashAmount
	
	--Admin..
	IF @adminLogId = 0
	BEGIN
		SET @adminLogId = null
	END
	
	--Insert  Transaction
	INSERT tblTransaction(transactionTypeId,userNumber,cpId,cashAmount,cashBalance,pointToCashBalance,pointBalance,registDt,adminLogId)
	VALUES(@transactionTypeId,@userNumber,@cpId,@cashAmount,@cashBalance,@pointToCashBalance,@pointBalance,@now,@adminLogId)
	SET @errorSave = @errorSave + @@ERROR
	
	--SET Return Value
	SET @transactionId = @@IDENTITY
	
	--tblCharge Insert
	INSERT tblCharge(transactionId,chargeTypeId)
	VALUES(@transactionId,@chargeTypeId)
	SET @errorSave = @errorSave + @@ERROR
	
	--Update userInfo
	UPDATE tblUserInfo SET cashBalance=@cashBalance WHERE userNumber = @userNumber
	SET @errorSave = @errorSave + @@ERROR

END
ELSE
BEGIN
	Set @transactionId = -201 --user ??
END

IF @errorSave <> 0
BEGIN
	SET @transactionId = -401 -- sp ERROR
END
GO
/****** Object:  StoredProcedure [dbo].[procAllTypeStatistics]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procAllTypeStatistics]
	@type		varchar(20)
,	@selectDt	varchar(10)

AS
DECLARE @sql  varchar(500)
BEGIN
	if @type <> 'age' 
	begin
		set @sql='SELECT  ' + @type + ', ' +  ' count(' + @type + ') as [cnt] from tblUserInfo  with(nolock) '
		set @sql = @sql +	'  WHERE  registDt   between ''' + @selectDt +  ' 00:00:00''  and ''' + @selectDt + ' 23:59:59'''
		set @sql = @sql + ' group by ' + @type  + ' order by 2 desc'
	end
	if @type = 'age'
	begin
		set @sql= 'SELECT  DATEDIFF( YY,  birthday, getdate()) age ,  count(datediff(yy,  birthday, getdate())) as cnt  from tblUserInfo '
		set @sql = @sql +	'  WHERE  registDt   between ''' + @selectDt +  ' 00:00:00''  and ''' + @selectDt + ' 23:59:59'''
		set @sql = @sql + '  GROUP BY  datediff(yy, birthday, getdate()) '
		set @sql = @sql + ' ORDER BY 1'
	end

	if @type = 'mobile'
	begin
		SET @sql = 'SELECT   left(handphoneNumber, 3),  count( left(handphoneNumber, 3)) as [cnt] from tblUserInfo  ui with(nolock)  '
		SET @sql = @sql + ' JOIN tblUserDetail ud with(nolock) on ui.userNumber=ud.userNumber '
		SET @sql = @sql + ' WHERE  registDt   between ''' + @selectDt + ' 00:00:00''  and ''' + @selectDt + ' 23:59:59'''
		SET @sql = @sql + ' GROUP  BY  left(handphoneNumber, 3) order by 2 desc'
	end

	EXEC(@sql)

END




--select * from tblGameAccessLog order by logoutDt desc




select * from tblPpcard
GO
/****** Object:  StoredProcedure [dbo].[procAgeStatic]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
???? ?? 
*/
CREATE proc [dbo].[procAgeStatic]
	@startDt	varchar(10)
,	@endDt	varchar(10)

as
select  count(CASE
		WHEN  DATEDIFF(yy, birthday, getdate())  <  9 THEN '1~8'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  13 THEN '9~12'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  18 THEN '13~17'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  23 THEN '18~22'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  31 THEN '23~30'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  41 THEN '31~40'
		ELSE '40~upward'
       	END  ),
	AGE=
	CASE
		WHEN  DATEDIFF(yy, birthday, getdate())  <  9 THEN '1~8'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  13 THEN '9~12'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  18 THEN '13~17'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  23 THEN '18~22'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  31 THEN '23~30'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  41 THEN '31~40'
		ELSE '40~upward'
       	END 
	
FROM  tbluserInfo
WHERE registDt between @startDt and @endDt
GROUP BY   
	CASE
		WHEN  DATEDIFF(yy, birthday, getdate())  <  9 THEN '1~8'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  13 THEN '9~12'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  18 THEN '13~17'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  23 THEN '18~22'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  31 THEN '23~30'
		WHEN  DATEDIFF(yy, birthday, getdate())  <  41 THEN '31~40' 
		ELSE '40~upward'
       	END 
 ORDER BY 2
GO
/****** Object:  StoredProcedure [dbo].[getProductInfo]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[getProductInfo]
	@productTypeId	AS INT
AS

SELECT productId, productName, productAmount
FROM tblProduct WITH(READUNCOMMITTED)
WHERE productTypeId = @productTypeId
GO
/****** Object:  StoredProcedure [dbo].[procBosangFixedTimeUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procBosangFixedTimeUser]
as


-- =============================================
-- Declare and using a KEYSET cursor
-- =============================================
DECLARE uCursor CURSOR

KEYSET
FOR  SELECT userNumber ,userGameServiceId , dateadd(dd, 1, expireDt ) from tblUserGameService with(nolock) 	where expireDt is  not null and expireDt > '2005-04-28 00:00:00'  and limitTime is not null
	and userNumber not in(SELECT userNumber FROM tblUserGameServiceBosangUserFixedTime)

DECLARE @expireDt	DATETIME
,	@userLimitTime	int
,	@limitTime	int
, 	@userNumber 	INT
,	@userGameServiceId INT

OPEN uCursor

FETCH NEXT FROM uCursor INTO  @userNumber, @userGameServiceId, @expireDt
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN

			select  top 1 @limitTime = limitTime  FROM  tblTransaction T with(nolock) join tblCharge C with(nolock) ON C.transactionId=T.transactionId
			join tblOrder O with(nolock) ON O.chargeTransactionId=C.transactionId
			JOIN tblProduct P with(nolock) ON P.productId=O.productId
			WHERE T.userNumber=@userNumber   order by T.transactionId desc
			IF @@ROWCOUNT > 0 
				BEGIN
						INSERT tblUserGameServiceBosangUserFixedTime(userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
							SELECT userGameServiceId, userNumber, gameServiceId,startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt
							FROM tblUserGameService with(rowLock) WHERE userNumber=@userNumber
				IF @expireDt < '2005-04-29 00:00:00'
				BEGIN
					IF @limitTime is not null
					BEGIN

						UPDATE tblUserGameService set expireDt = '2005-04-29  15:00:00', limitTime=limitTime + @limitTime  where userNumber=@userNumber and userGameServiceId=@userGameServiceId 
					END
					ELSE
					BEGIN
						UPDATE tblUserGameService set expireDt = '2005-04-29  15:00:00'   where userNumber=@userNumber and userGameServiceId=@userGameServiceId 
					END
									
				END			
				ELSE
					IF @limitTime is not null
					begin
						UPDATE tblUserGameService set expireDt =@expireDt ,  limitTime=limitTime+@limitTime  where userNumber=@userNumber and userGameServiceId=@userGameServiceId 
					END
					BEGIN
						UPDATE tblUserGameService set expireDt = @expireDt  where userNumber=@userNumber and userGameServiceId=@userGameServiceId 
					END
				END
			
		
	END
	
	FETCH NEXT FROM uCursor INTO  @userNumber, @userGameServiceId, @expireDt 
	
END

CLOSE uCursor
DEALLOCATE uCursor
GO
/****** Object:  StoredProcedure [dbo].[procBosangFixedTermUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[procBosangFixedTermUser]
as

-- =============================================
-- Declare and using a KEYSET cursor
-- =============================================
DECLARE uCursor CURSOR

KEYSET
FOR  SELECT   ui.userNumber , userGameServiceId  from  tblUserInfo ui with(nolock) join tblUserGameService ug with(nolock) ON ug.userNumber=ui.userNumber
	where  ug.endDt > '2005-04-28 00:00:00'  order by   endDt desc
DECLARE @endDt		DATETIME
, 	@userNumber 	INT
,	@userGameServiceId INT

OPEN uCursor

FETCH NEXT FROM uCursor INTO  @userNumber, @userGameServiceId
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
			SELECT @endDt=DATEADD(DD, 1, endDt) from tblUserGameService with(nolock) where userNumber=@userNumber and userGameServiceId=@userGameServiceId
			IF @endDt < '2005-04-29 00:00:00'
			BEGIN
				INSERT tblUserGameServiceBosangUserFixedTerm(userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
					SELECT userGameServiceId, userNumber, gameServiceId,startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt
					FROM tblUserGameService with(rowLock) WHERE userNumber=@userNumber		
				UPDATE tblUserGameService set endDt = '2005-04-29  15:00:00' where userNumber=@userNumber and userGameServiceId=@userGameServiceId 
			END			
			ELSE
				BEGIN
				INSERT tblUserGameServiceBosangUserFixedTerm(userGameServiceId, userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
					SELECT userGameServiceId, userNumber, gameServiceId,startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt
					FROM tblUserGameService with(rowLock) WHERE userNumber=@userNumber
				UPDATE tblUserGameService set endDt =@endDt where userNumber=@userNumber and userGameServiceId=@userGameServiceId 
				END
		
	END
	
	FETCH NEXT FROM uCursor INTO  @userNumber, @userGameServiceId
	
END

CLOSE uCursor
DEALLOCATE uCursor
GO
/****** Object:  StoredProcedure [dbo].[procBlockUserManagement]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procBlockUserManagement    Script Date: 23/1/2546 11:40:26 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procBlockUserManagement
	Creation Date		:	2002-07-29
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	????? ??
	
******************************Optional Item******************************
	Input Parameters	:	
					@userNumber			AS		INT
					@userStatusId			AS		INT				
	Output Parameters	:	
					@returnUserPwd		AS		nvarchar(16)		OUTPUT
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procBlockUserManagement]
	@userNumber			AS		INT
,	@userStatusId			AS		INT
,	@userPwd			AS		nvarchar(32)
,	@blockTerm			AS		INT			= NULL
,	@returnUserPwd		AS		nvarchar(32)		OUTPUT
AS
---------------------------------??????---------------------------------
DECLARE	@blockedUserId	AS	INT
DECLARE	@newPwd		AS	nvarchar(32)
DECLARE	@oldPwd		AS	nvarchar(32)
DECLARE	@oldUserStatusId	AS	TINYINT
DECLARE	@endDt		AS	SMALLDATETIME
DECLARE	@tempDt		AS	SMALLDATETIME
---------------------------------?????-------------------------------------
SELECT @blockedUserId = blockedUserId , @oldPwd = oldPassword FROM tblBlockedUserManagement WITH (READUNCOMMITTED) WHERE userNumber = @userNumber
IF(@blockedUserId IS NULL)		--???? ??
	BEGIN
		IF(@userStatusId = 4) 	--??? ???
			BEGIN
				SELECT @oldUserStatusId = userStatusId FROM tblUserInfo WITH (READUNCOMMITTED) WHERE userNumber = @userNumber
				SET @newPwd = LEFT(NEWID() , 16)						
				SET @tempDt = DATEADD(d , @blockTerm , GETDATE())
				SELECT @endDt = CONVERT(nchar(4) , YEAR(@tempDt)) + '-' + CONVERT(nchar(2) , MONTH(@tempDt)) + '-' + CONVERT(nchar(2) , DAY(@tempDt))
				INSERT INTO tblBlockedUserManagement VALUES(@userNumber , @userPwd , @oldUserStatusId , @endDt , GETDATE())
				
				SET @returnUserPwd = @newPwd
			END
		ELSE
			BEGIN
				SET @returnUserPwd = @userPwd
			END
	END
ELSE
	BEGIN
		IF(@userStatusId = 4) 
			BEGIN
				SET @returnUserPwd = @userPwd
			END
		ELSE
			BEGIN
				DELETE FROM tblBlockedUserManagement WHERE blockedUserId = @blockedUserId
				SET @returnUserPwd = @oldPwd
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[procDeleteBankDepositConfirm]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteBankDepositConfirm    Script Date: 23/1/2546 11:40:25 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procDeleteBankDepositConfirm 
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	??? ?? ??
******************************Optional Item******************************
	Input Parameters	:	
					@bankDepositConfirmId			AS		INT
					@memo					AS		nvarchar(200)
					@adminNumber				AS		INT				
	Output Parameters	:	
					@returnCode				AS		TINYINT			OUT
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeleteBankDepositConfirm] 
	@bankDepositConfirmId			AS		INT
,	@memo					AS		nvarchar(200)
,	@adminNumber				AS		INT
,	@returnCode				AS		TINYINT			OUT
AS
DECLARE	@adminLogId		AS		INT	
UPDATE tblBankDepositConfirm 
SET confirmType = 2 , registDt = GETDATE()
WHERE bankDepositConfirmId = @bankDepositConfirmId
--tblAdminLog? ???
INSERT INTO tblAdminLog 
	VALUES(
		'Delete'
	,	'tblBankDepositConfirm'
	,	@adminNumber
	,	@memo
	,	GETDATE()
	)
SET @adminLogId = @@IDENTITY
INSERT INTO tblBankDepositConfirmHistory 
	SELECT bankDepositConfirmId, gamebangId, productId , transactionId, startDate, depositAmount, depositer, bankName, depositDate, confirmType,misPrice ,  memo , registDt ,@adminLogId
	FROM tblBankDepositConfirm 
	WHERE bankDepositConfirmId = @bankDepositConfirmId
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procDeleteAdminUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteAdminUser    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procDeleteAdminUser
	Creation Date		:	2002. 02. 18.
	Written by		:	???
	E-Mail by 		:	jsh001@n-cash.net
	Purpose			:	??? ??
	Input Parameters :	
		@memo				as		nvarchar(255)			:	??
			
	return?	:
	Return Status:
	Usage: 			
	Call by:
		modifyExec.asp
	Calls:
	 	Nothing
	Access Table :
	 	tblAdmin(U)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeleteAdminUser]	
	@adminNumber				as int
as
UPDATE tblAdmin
SET apply = 0
WHERE adminNumber = @adminNumber
GO
/****** Object:  StoredProcedure [dbo].[procDelChongphanBank]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDelChongphanBank    Script Date: 23/1/2546 11:40:24 ******/
/*
??? : ???
?? : ??? ??? ?? ??? ???? ??
*/
CREATE PROCEDURE [dbo].[procDelChongphanBank] 
	@chongphanBankId		AS		INT
,	@returnCode			AS		TINYINT		OUTPUT
AS
DELETE FROM  tblChongphanBank WHERE chongphanBankId = @chongphanBankId
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procCreatePpCardForTantra2]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreatePpCardForTantra2]
	@productId 		as 	int
,	@validStartDt 		as 	smallDatetime
,	@validEndDt 		as 	smallDatetime
,	@quantity		as	int
--,	@returnCode		as	int	OUTPUT
--,	@returnMSG		as	varchar(100) OUTPUT

AS

	DECLARE @newId as nvarchar(40)
	DECLARE @ppCardGroupId as int
	DECLARE @serialNumber as varchar(15)
	DECLARE @count  as int
	DECLARE @createDt as datetime
	DECLARE @PINCode as varchar(9)
	DECLARE @productCode as varchar(15)
	DECLARE @preProductCode as varchar(7)
	DECLARE @month as int
	DECLARE @nYY    as CHAR(2)  --????
	DECLARE @nDD   as char(2) --????
	DECLARE @nMM  as char(2) -- ????
	DECLARE @productAmount as int
	DECLARE @maxSerialNumber as bigint
	DECLARE @seqNumber as bigint

	SET @createDt = getdate()
	SET @count = 1
	SET @month = month(getdate()) 
	SET @nYY =  convert(char(2), right(year(getdate()), 2))
	SET @nMM = Month(GETDATE() )
	IF len(@nMM) = 1
		SET @nMM = '0' + @nMM
	SET @nDD = Day(GETDATE())
	IF len(@nDD) = 1
		SET @nDD = '0' + @nDD
	SELECT @productAmount = productAmount FROM tblProduct WHERE productId = @productId
	
	IF (@productAmount = 350)
		SET @preProductCode = 'AA'
	ELSE IF (@productAmount = 100)
		SET @preProductCode = 'BA'
	ELSE IF (@productAmount = 50)
		SET @preProductCode = 'CA'
	ELSE IF (@productAmount = 30)
		SET @preProductCode = 'DA'
	
	IF LEN(RTRIM(LTRIM(@preProductCode))) = 0
	BEGIN	
		--SET @returnCode = 0
		--SET @returnMSG = 'SELECT Not ProcudtCode'
		RETURN 	 
	END
	IF ( @month = 1)
		SET @preProductCode = @preProductCode + 'A'
	ELSE IF (@month = 2)
		SET @preProductCode = @preProductCode + 'B'
	ELSE IF (@month = 3)
		SET @preProductCode = @preProductCode + 'C'
	ELSE IF (@month = 4)
		SET @preProductCode = @preProductCode + 'D'
	ELSE IF (@month = 5)
		SET @preProductCode = @preProductCode + 'E'
	ELSE IF (@month = 6)
		SET @preProductCode = @preProductCode + 'F'
	ELSE IF (@month = 7)
		SET @preProductCode = @preProductCode + 'G'
	ELSE IF (@month = 8)
		SET @preProductCode = @preProductCode + 'H'
	ELSE IF (@month = 9)
		SET @preProductCode = @preProductCode + 'I'
	ELSE IF (@month = 10)
		SET @preProductCode = @preProductCode + 'J'
	ELSE IF (@month = 11)
		SET @preProductCode = @preProductCode + 'K'
	ELSE IF (@month = 12)
		SET @preProductCode = @preProductCode + 'L'

	SET @preProductCode = @preProductCode + convert(char(2), day(getdate())) + convert(char(2), right(year(getdate()), 2))

	SELECT @maxSerialNumber = max(convert(bigint, right(ppCardSerialNumber, 10))) 
	FROM tblPpCardForTantra PT join tblPpCardGroup PG on PT.ppCardGroupId = PG.ppCardGroupId
	WHERE productId = @productId

	IF @maxSerialNumber is null
		SET @maxSerialNumber = 0

	SET @seqNumber = @maxSerialNumber 

	INSERT 
		INTO tblPpCardGroup (productId, howManyPeople, quantity, createDt, validStartDt, validEndDt, adminNumber, apply) 
	VALUES
		(@productId, 1, @quantity, @createDt, @validStartDt, @validEndDt, 1, 1)

	SELECT @ppCardGroupId = @@IDENTITY
	---SET @returnCode=1
	--SET @returnMSG = 'PPCARD MAKE [ ' +  CONVERT(VARCHAR(4), @quantity) + ']  SUCCESS'
	--PRINT  'PPCARD MAKE [ ' +  CONVERT(VARCHAR(4), @quantity) + ']  SUCCESS'
	WHILE @count <= @quantity
		BEGIN
			SET @newId =  newid()
			SET @PINCode = left(replace(@newId, '-', ''),9)
			SET @productCode = LEFT(@preProductCode, 2) + right(replace(@newId, '-', ''), 7)   --productCode(CardNumber) 9?????? ???? ???? (AA ????)
			SET @seqNumber = @maxSerialNumber  + @count
			--SET @serialNumber = left(@productCode, 1) + +  right('0000000000' + convert(varchar(10), @seqNumber), 10) -- SerialNumber
			SET @serialNumber = left(@productCode, 1) + @nMM + @nDD + @nYY +  right('0000000000' + convert(varchar(10), @seqNumber), 8) -- SerialNumber
	
			INSERT INTO tblPpCardForTantra (ppCardGroupId, ppCardSerialNumber, PINCode, productCode)
			VALUES (@ppCardGroupId, @serialNumber, @PINCode, @productCode)
			--select @ppCardGroupId, @serialNumber, @PINCode, @productCode 
			IF @@ERROR = 0
				BEGIN
					SET @count = @count +1
				END
		END
GO
/****** Object:  StoredProcedure [dbo].[procCreatePpCardForTantra]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreatePpCardForTantra]
	@productId 		as 	int
,	@validStartDt 		as 	smallDatetime
,	@validEndDt 		as 	smallDatetime
,	@quantity		as	int
AS

	DECLARE @newId as nvarchar(40)
	DECLARE @ppCardGroupId as int
	DECLARE @serialNumber as varchar(11)
	DECLARE @count  as int
	DECLARE @createDt as datetime
	DECLARE @PINCode as varchar(9)
	DECLARE @productCode as varchar(15)
	DECLARE @preProductCode as varchar(7)
	DECLARE @month as int
	DECLARE @productAmount as int
	DECLARE @maxSerialNumber as bigint
	DECLARE @seqNumber as bigint

	SET @createDt = getdate()
	SET @count = 1
	SET @month = month(getdate())

	SELECT @productAmount = productAmount FROM tblProduct WHERE productId = @productId
	
	IF (@productAmount = 350)
		SET @preProductCode = 'AA'
	ELSE IF (@productAmount = 100)
		SET @preProductCode = 'BA'
	ELSE IF (@productAmount = 50)
		SET @preProductCode = 'CA'
	ELSE IF (@productAmount = 30)
		SET @preProductCode = 'DA'
	
	
	IF ( @month = 1)
		SET @preProductCode = @preProductCode + 'A'
	ELSE IF (@month = 2)
		SET @preProductCode = @preProductCode + 'B'
	ELSE IF (@month = 3)
		SET @preProductCode = @preProductCode + 'C'
	ELSE IF (@month = 4)
		SET @preProductCode = @preProductCode + 'D'
	ELSE IF (@month = 5)
		SET @preProductCode = @preProductCode + 'E'
	ELSE IF (@month = 6)
		SET @preProductCode = @preProductCode + 'F'
	ELSE IF (@month = 7)
		SET @preProductCode = @preProductCode + 'G'
	ELSE IF (@month = 8)
		SET @preProductCode = @preProductCode + 'H'
	ELSE IF (@month = 9)
		SET @preProductCode = @preProductCode + 'I'
	ELSE IF (@month = 10)
		SET @preProductCode = @preProductCode + 'J'
	ELSE IF (@month = 11)
		SET @preProductCode = @preProductCode + 'K'
	ELSE IF (@month = 12)
		SET @preProductCode = @preProductCode + 'L'

	SET @preProductCode = @preProductCode + convert(char(2), day(getdate())) + convert(char(2), right(year(getdate()), 2))

	SELECT @maxSerialNumber = max(convert(bigint, right(ppCardSerialNumber, 10))) 
--SELECT @maxSerialNumber = Convert(bigint, right(max(ppCardSerialNumber), 10))
	FROM tblPpCardForTantra PT join tblPpCardGroup PG on PT.ppCardGroupId = PG.ppCardGroupId
	WHERE productId = @productId

	IF @maxSerialNumber is null
		SET @maxSerialNumber = 0

	SET @seqNumber = @maxSerialNumber 

	--begin tran
	INSERT 
		INTO tblPpCardGroup (productId, howManyPeople, quantity, createDt, validStartDt, validEndDt, adminNumber, apply) 
	VALUES
		(@productId, 1, @quantity, @createDt, @validStartDt, @validEndDt, 1, 1)

	SELECT @ppCardGroupId = @@IDENTITY

	WHILE @count <= @quantity
		BEGIN
		SET @newId =  newid()
		SET @PINCode = left(replace(@newId, '-', ''),9)
		SET @productCode = @preProductCode + right(replace(@newId, '-', ''), 4)
		SET @seqNumber = @maxSerialNumber  + @count
		SET @serialNumber = left(@productCode, 1) + right('0000000000' + convert(varchar(10), @seqNumber), 10)

		INSERT INTO tblPpCardForTantra (ppCardGroupId, ppCardSerialNumber, PINCode, productCode)
		VALUES (@ppCardGroupId, @serialNumber, @PINCode, @productCode)
		select @ppCardGroupId, @serialNumber, @PINCode, @productCode
		
		IF @@ERROR = 0
			BEGIN
				SET @count = @count +1
			END
		END
--rollback
GO
/****** Object:  StoredProcedure [dbo].[procCreatePpCard]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procCreatePpCard    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procCreatePpCard
	Creation Date		:	2002. 12. 26
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	PPCard? ??
	Input Parameters :	
			
	return?:
		rtnValue 		as		int : ?? ??
	Return Status:		
		Integer
	Usage: 			
		exec procInsertCard 10, '1234123412345678', 1000, 1, 0400, '????', 9982732724, 'KF200204050000001234'
	Call by		:	PP?? ?? ???
				PGCardService.CardManager	
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I), tblChargeCardDeposit(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procCreatePpCard]
	@productId 		as 	int
,	@validStartDt 		as 	smallDatetime
,	@validEndDt 		as 	smallDatetime
,	@howManyPeople	as	int
,	@quantity		as	int
,	@adminNumber		as 	int
,	@rtnValue		as	int output
AS
DECLARE @newId as nvarchar(40)
DECLARE @ppCardGroupId as int
DECLARE @ppCardSerialNumber as nvarchar(20)
DECLARE @count  as int
DECLARE @createDt as datetime
SET @createDt = getdate()
SET @count = 1
INSERT 
	INTO tblPpCardGroup (productId, howManyPeople, quantity, createDt, validStartDt, validEndDt, adminNumber, apply) 
VALUES
	(@productId, @howManyPeople, @quantity, @createDt, @validStartDt, @validEndDt, @adminNumber, 1)
SELECT @ppCardGroupId = @@IDENTITY
WHILE @count <= @quantity
	BEGIN
	SET @newId =  newid()
	SET @ppCardSerialNumber = 'N' + left(replace(@newId, '-', ''),11)
	INSERT INTO tblPpCard (ppCardGroupId, ppCardSerialNumber)
	VALUES (@ppCardGroupId, @ppCardSerialNumber)
	
	IF @@ERROR = 0
		BEGIN
			SET @count = @count +1
		END
	END
	IF @count - 1 = @quantity 
		SET @rtnValue = 0
	ELSE
		SET @rtnValue = @count
GO
/****** Object:  StoredProcedure [dbo].[procConfirmUserPasswordCheckAnswer]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procConfirmUserPasswordCheckAnswer    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procConfirmUserPasswordCheckAnswer
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	???? ??? ??????? ?? ?? ??
	Input Parameters :	
		@userId				as	nvarchar(32)		
		@cpId					as	int			
		@password				as	nvarchar(32)		
		@userName				as	nvarchar(16)		
		@ssno					as	nvarchar(13)		
		@birthday				as	smalldatetime		
		@isSolar				as	bit			
		@zipcode				as	nchar(6)			
		@address				as	nvarchar(64)		
		@addressDetail				as	nvarchar(64)		
		@phoneNumber				as	nvarchar(16)		
		@email					as	nvarchar(64)		
		@passwordCheckQuestionTypeId	as	int
		@passwordCheckAnswer		as	nvarchar(64)		
		@userNumber				as	int		OUTPUT
			
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
		EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procConfirmUserPasswordCheckAnswer]
	@userId				as	nvarchar(32)
,	@ssno					as	nchar(13)
,	@passwordCheckAnswer		as	nvarchar(50)
,	@userName				as	nvarchar(16)	OUTPUT
,	@userPwd				as	nvarchar(32)	OUTPUT
,	@msg					as	nvarchar(128)	OUTPUT
AS
	DECLARE @confirmPasswordCheckAnswer	as	nvarchar(50)
	SELECT @confirmPasswordCheckAnswer = passwordCheckAnswer, @userPwd  = userPwd, @userName = userSurName
	FROM tblUserInfo
	WHERE cpId  = 1 AND userId = @userId
	IF @@ROWCOUNT <= 0
	BEGIN
		SET @msg = 'Please try again'
		RETURN 1
	END	
	IF @confirmPasswordCheckAnswer <> @passwordCheckAnswer
	BEGIN
		SET @msg = 'Incorrect answer. Try again.'
		RETURN 1
	END	
	SET @msg = 'Success'
	RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[procConfirmUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procConfirmUser    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procConfirmUser
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	???? ??? ??????? ?? ?? ??
	Input Parameters :	
		@userId				as	nvarchar(32)
		@ssno					as	nchar(13)
		@passwordCheckQuestionTypeId	as	int		OUTPUT
		@msg					as	nvarchar(128)	OUTPUT
			
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
		EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procConfirmUser]
	@userId				as	nvarchar(32)
,	@ssno					as	nchar(13)
,	@passwordCheckQuestionTypeId	as	int		OUTPUT
,	@msg					as	nvarchar(128)	OUTPUT
AS
	DECLARE @confirmUseSsno	as	nchar(13)
	SELECT @confirmUseSsno = ssno, @passwordCheckQuestionTypeId = passwordCheckQuestionTypeId
	FROM tblUserInfo with (nolock)
	WHERE userId = @userId
	IF @@ROWCOUNT <= 0
	BEGIN
		SET @msg = 'there is no ID.' --'???? ?? ID???.'
		RETURN 1
	END	
	IF @confirmUseSsno <> @ssno
	BEGIN
		SET @msg = 'residents Number of ID is discord.' --'?? ID? ??????? ???? ????.'
		RETURN 1
	END	
	SET @msg = 'Confirm'
	RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[procChongphanSettlementEach]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
??? ?? ??

*/
CREATE procedure [dbo].[procChongphanSettlementEach]
	@startDt	as	datetime
,	@endDt		as	datetime
AS


	SELECT cp.chongphanname, sum(cashAmount)   FROM tblTransaction t 
		JOIN tblPpCardUserInfoMapping pm ON pm.userNumber=t.userNumber
		JOIN tblPpCard	pc ON pc.ppCardId=pm.ppCardId
		JOIN tblPpCardGroup pg ON pg.ppCardGroupId=pc.ppCardGroupId
		JOIN tblChongphan cp ON cp.chongphanId=pg.chongphanId				
	WHERE t.transactionTypeId = 1 and t.registDt between @startDt and @endDt
	GROUP BY cp.chongphanname , t.cashAmount
	order by cp.chongphanname asc
/*
	SELECT cp.chongphanname, sum(cashAmount)   FROM tblTransaction t 
		JOIN tblCharge c 	ON c.transactionid=t.transactionId
		JOIN tblPpCardUserInfoMapping pm ON pm.userNumber=t.userNumber
		JOIN tblPpCard	pc ON pc.ppCardId=pm.ppCardId
		JOIN tblPpCardGroup pg ON pg.ppCardGroupId=pc.ppCardGroupId
		JOIN tblChongphan cp ON cp.chongphanId=pg.chongphanId				
	WHERE t.transactionTypeId = 1 and c.chargeTypeId = 3 and t.registDt between '2004-10-10' and '2004-12-23'
	GROUP BY cp.chongphanname , t.cashAmount
	order by cp.chongphanname asc

*/
GO
/****** Object:  StoredProcedure [dbo].[procCheckUserNumber]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procCheckUserNumber    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procCheckUserNumber]
@userNumber				as	int
as
	SELECT 
		userNumber 
	FROM 	
		tblUserInfo with (nolock)
	WHERE 
		userNumber = @userNumber AND
		apply = 1
GO
/****** Object:  StoredProcedure [dbo].[procCheckUser]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procCheckUser    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procCheckUser]
@userId				as	nvarchar(32)		,
@cpId					as	int			
as
	SELECT 
		userNumber 
	FROM 	
		tblUserInfo
	WHERE 
		userId = @userId AND 
		cpId = @cpId
--		apply = 1
GO
/****** Object:  StoredProcedure [dbo].[procCheckRealIpInVirtualIp]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procCheckRealIpInVirtualIp    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procCheckRealIpInVirtualIp
	Creation Date		:	2002. 01.26
	Written by		:	? ??
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	
	
	Input Parameters :	
				@virtualIpAddrId						AS		INT
				@gamebangId						AS		INT
				@realIpAddr						AS		nvarchar(11)
				@realStartIp						AS		TINYINT
				@ipAddrId						AS		INT	
				@adminNumber						AS		INT
				@memo							AS		nvarchar(200)
	Output Parameters:	
				@procCheckRealIpInVirtualIpReturnCode			AS		TINYINT			OUTPUT
				
	Return Status:		
	Usage		:	
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procCheckRealIpInVirtualIp]
	@virtualIpAddrId						AS		INT
,	@gamebangId						AS		INT
,	@realIpAddr						AS		nvarchar(11)
,	@realStartIp						AS		TINYINT
,	@ipAddrId						AS		INT	
,	@adminNumber						AS		INT
,	@memo							AS		nvarchar(200)
,	@procCheckRealIpInVirtualIpReturnCode			AS		TINYINT			OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@checkGamebangId		AS		INT
DECLARE	@checkIpAddrId		AS		INT
DECLARE	@checkIpAddrId2		AS		INT
DECLARE	@new_ipAddrId			AS		INT
DECLARE	@adminLogId			AS		INT
------------------------?? ?? ?-------------------
--virtualIp? ????? realIp? ???? ??
IF(@ipAddrId = (SELECT ipAddrId FROM tblIpAddr WHERE gamebangId = @gamebangId AND ipAddr = @realIpAddr AND startIp = @realStartIp AND endIp = @realStartIp AND apply = 1))
	BEGIN
		SET @procCheckRealIpInVirtualIpReturnCode = @ipAddrId		--????? ??.(realIp? ???? ????)
		RETURN	
	END
--**************************************virtualIp? ????? realIp? ??????********************************************************
--?? ???? ???? ??? ???? ??
SELECT @checkIpAddrId = ipAddrId , @checkGamebangId = gamebangId FROM tblIpAddr WHERE ipAddr = @realIpAddr AND startIp =  @realStartIp AND endIp = @realStartIp AND apply = 1
--?? ??? realIp? ?? ????? ?? ??????
IF(@checkIpAddrId IS NOT NULL AND @checkGamebangId <> @gamebangId)
	BEGIN
		SET @procCheckRealIpInVirtualIpReturnCode = -1		--?? ??
		RETURN	
	END
--????? ???? ?? ????? ?????
ELSE IF(@checkIpAddrId IS NOT NULL AND @checkGamebangId = @gamebangId)
	BEGIN
		--?? ???? realIpId? ? ?? virtualIp? ???? ??
		IF((SELECT COUNT(*) FROM tblVirtualIpAddr WHERE ipAddrId = @ipAddrId) <= 1)
			BEGIN
				UPDATE tblIpAddr SET apply = 0 WHERE ipAddrId = @ipAddrId
				
				INSERT INTO tblAdminLog 
					VALUES(
						'Amend'
					,	'tblIpAddr'
					,	@adminNumber
					,	@memo
					,	GETDATE()
					)
				SET @adminLogId = @@IDENTITY
		
				INSERT INTO tblIpAddrHistory
				SELECT ipAddrId ,gamebangId ,  ipAddr , startIp , endIp , registDt , apply , @adminLogId
				FROM tblIpAddr
				WHERE ipAddrId = @ipAddrId
			END
		
		SET @procCheckRealIpInVirtualIpReturnCode = @checkIpAddrId		--? ???? ???? ??
		RETURN	
		
		
	END
--????? ???? ???? ???..
ELSE IF(@checkIpAddrId IS NULL)
	BEGIN
		--?? ????.
		SELECT @checkIpAddrId2 = ipAddrId FROM tblIpAddr WHERE ipAddr = @realIpAddr AND (@realStartIp  BETWEEN startIp AND endIp) AND apply = 1
		IF(@checkIpAddrId IS NOT NULL)		--??? realIp? ??.
			BEGIN
				SET @procCheckRealIpInVirtualIpReturnCode = -2		--??? realIp? ????.
				RETURN		
			END
		
		--?? ???? realIpId? ? ?? virtualIp? ???? ??
		IF((SELECT COUNT(*) FROM tblVirtualIpAddr WHERE ipAddrId = @ipAddrId) <= 1)
			BEGIN
				UPDATE tblIpAddr SET apply = 0 WHERE ipAddrId = @ipAddrId
				
				INSERT INTO tblAdminLog 
					VALUES(
						'Amend'
					,	'tblIpAddr'
					,	@adminNumber
					,	@memo
					,	GETDATE()
					)
				SET @adminLogId = @@IDENTITY
		
				INSERT INTO tblIpAddrHistory
				SELECT ipAddrId ,gamebangId ,  ipAddr , startIp , endIp , registDt , apply , @adminLogId
				FROM tblIpAddr
				WHERE ipAddrId = @ipAddrId
			END
		
		INSERT INTO tblIpAddr
			VALUES(
				@gamebangId
			,	@realIpAddr
			,	@realStartIp
			,	@realStartIp
			,	GETDATE()
			,	1
			)
		SET @new_ipAddrId = @@IDENTITY
			
		INSERT INTO tblAdminLog 
			VALUES(
				'Registration'
			,	'tblIpAddr'
			,	@adminNumber
			,	'REALLIP Registration'
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY
		INSERT INTO tblIpAddrHistory
			SELECT ipAddrId, gamebangId, ipAddr, startIp, endIp, GETDATE(), apply , @adminLogId 
			FROM tblIpAddr
			WHERE ipAddrId = @new_ipAddrId
		
		SET @procCheckRealIpInVirtualIpReturnCode = @new_ipAddrId		--? ???? ???? ??
		RETURN		
	END
GO
/****** Object:  StoredProcedure [dbo].[procDeleteCpChongphan]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteCpChongphan    Script Date: 23/1/2546 11:40:26 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procDeleteCpChongphan
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	CP? ?? ?? ??
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeleteCpChongphan]
	@chongphanId 			AS		INT
,	@memo				AS		nvarchar(200)
,	@adminNumber			AS		INT
AS
------------------------?? ??------------------------
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
UPDATE tblCpChongphan SET apply = 0
WHERE chongphanId = @chongphanId
--tblAdminLog? ???
INSERT INTO tblAdminLog 
	VALUES(
		'Delete'
	,	'tblCpChongphan'
	,	@adminNumber
	,	@memo
	,	GETDATE()
	)
SET @adminLogId = @@IDENTITY			
INSERT INTO tblCpChongphanHistory
	SELECT cpChongphanId ,cpId ,  chongphanId , apply ,GETDATE() , @adminLogId
	FROM tblCpChongphan
	WHERE chongphanId = @chongphanId
GO
/****** Object:  StoredProcedure [dbo].[procDeleteCp]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteCp    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procDeleteCp
	Creation Date		:	2002. 02.17
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	CP ??
	
	Input Parameters :	
				@cpId				AS		SMALLINT
				@memo				AS		nvarchar(200)
				@adminNumber			AS		INT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ??(??)???.
				2: ?? apply? 0?? ?? ??.
				3: ?? ?? ?? ??? ??? ?????.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeleteCp]
	@cpId			AS		INT
,	@memo				AS		nvarchar(200)
,	@adminNumber			AS		INT
,	@returnCode			AS		TINYINT	OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
IF((SELECT apply FROM tblCp WHERE cpId = @cpId) = '0')
	BEGIN
		SET @returnCode = 2
	END
ELSE IF((SELECT COUNT(*) FROM tblCpChongphan WHERE cpId = @cpId) > 1)
	BEGIN
		SET @returnCode = 3
	END
ELSE
	BEGIN
		--tblGamebang? ????.
		UPDATE tblCp 
		SET apply = 0
		WHERE cpId = @cpId
		
		--tblAdminLog? ???
		INSERT INTO tblAdminLog 
			VALUES(
				'Delete'
			,	'tblCp'
			,	@adminNumber
			,	@memo
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY	
	
		--tblGamebangHistory? ???.
		INSERT INTO tblCpHistory 
			SELECT cpId , cpName , bizNumber , address , zipcode , phoneNumber , presidentName , apply , GETDATE() , @adminLogId 
			FROM tblCp 
			WHERE cpId = @cpId
	
		SET @returnCode = 1
	END
GO
/****** Object:  StoredProcedure [dbo].[procDeleteChongphanGamebang]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteChongphanGamebang    Script Date: 23/1/2546 11:40:26 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procDeleteChongphanGamebang 
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	?? ??? ?? ??
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeleteChongphanGamebang] 
	@gamebangId 			AS		INT
,	@memo				AS		nvarchar(200)
,	@adminNumber			AS		INT
AS
------------------------?? ??------------------------
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
UPDATE tblChongphanGamebang  SET apply = 0
WHERE gamebangId = @gamebangId
--tblAdminLog? ???
INSERT INTO tblAdminLog 
	VALUES(
		'Delete'
	,	'tblChongphanGamebang'
	,	@adminNumber
	,	@memo
	,	GETDATE()
	)
SET @adminLogId = @@IDENTITY			
INSERT INTO tblChongphanGamebangHistory
	SELECT chongphanGamebangId , chongphanId , gamebangId ,apply , GETDATE() , @adminLogId
	FROM tblChongphanGamebang
	WHERE gamebangId = @gamebangId
GO
/****** Object:  StoredProcedure [dbo].[procChargeMobile]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procChargeMobile    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procCharge
	Creation Date		:	2002. 2. 08.
	Written by		:	? ??
	E-Mail by 		:	windist@n-cash.net
	Purpose			:	????? ??
	Input Parameters :	
	@memo				as		nvarchar(255) :	??
			
	return?:
	@transactionId		as	integer	: ?? ????ID
	Call by		:	TransactionManager.Transaction.charge
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I)	, tblUserInfo(U)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procChargeMobile]
	@transactionId	as	int
,	@tId			as	nchar(18)
,	@phoneNumber	as	nvarchar(20)
,	@isARS			as	bit
,	@resultId		as	int	output
as
DECLARE @temp		as int
DECLARE @errorSave	as int
SET @errorSave = 0
SET @temp = null
SELECT @temp = transactionId FROM tblChargeMobile with(nolock) WHERE tId = @tId
IF @temp is null
BEGIN
	--Insert  Transaction
	INSERT tblChargeMobile(transactionId,tId,phoneNumber,isARS)
	VALUES(@transactionId,@tId,@phoneNumber,@isARS)
	SET @errorSave = @errorSave + @@ERROR
END
ELSE
BEGIN
	SET @resultId = -504
	RETURN
END
--SET Return Value
	
IF @errorSave <> 0
	SET @resultId = -401 -- sp ERROR
SET @resultId = @transactionId
GO
/****** Object:  StoredProcedure [dbo].[procGetPpcardInfo]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetPpcardInfo]
	@gameServiceId			as	smallint
,	@userId				as	nvarchar(32)	
,	@ppCardSerialNumber			as	nvarchar(12)
,	@pinCode				as	nvarchar(50)
,	@ppcardId				as	int		OUTPUT
--,	@howManyPeople			as	int		OUTPUT
,	@productId				as	int		OUTPUT
,	@productAmount			as	int		OUTPUT
,	@returnCode				as	int		OUTPUT
as

DECLARE	@userNumber			as	int
DECLARE	@validStartDt		as	smalldatetime
DECLARE	@validEndDt			as	smalldatetime
DECLARE	@now					as	smalldatetime
DECLARE	@lastDt				as	smalldatetime
DECLARE	@rowCount			as	int
DECLARE 	@dbPINCode			as	nvarchar(40)
DECLARE 	@productPeriod		as 	int	
declare 	@failStartDt			as 	smalldatetime
declare 	@failEndDt			as 	smalldatetime

	SELECT @userNumber = userNumber FROM tblUserInfo WITH (NOLOCK) WHERE userId=@userId and gameServiceId = @gameServiceId
	IF @@ROWCOUNT = 0
	BEGIN
		SET @returnCode = -6	 	
		RETURN
	END	


	SET @returnCode = 1
	SET @now = getdate()
	--SET @lastDt = DATEADD (dd , -1, @now) 
	
	--SerialNumber  ??
	SELECT @ppcardId = pc.ppCardId,  @validStartDt = pcg.validStartDt, @validEndDt = pcg.validEndDt
			, @productId = pcg.productId, @productAmount = p.productAmount ,@dbPINCode=pc.PINCode
			, @productPeriod = isnull( p.productPeriod, 0)
	FROM tblPpCard pc WITH(NOLOCK)
		JOIN tblPpCardGroup pcg with(nolock) on  pc.ppCardGroupId = pcg.ppCardGroupId  
		JOIN tblProduct p WITH(NOLOCK) ON pcg.productId = p.productId 
	WHERE pc.ppCardSerialNumber = @ppCardSerialNumber   AND pcg.apply = 1

	--SerialNumber ???? ? ??
	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt) VALUES (@userNumber, @ppCardSerialNumber, getdate()) 			
		SET @returnCode = -1	 	
		RETURN
	END	
	
	IF @dbPINCode <> @pinCode 
	BEGIN
		INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt) VALUES (@userNumber, @ppCardSerialNumber, getdate()) 			
		SET @returnCode = -2 	--pinCode ???
		RETURN 
	END	

	SELECT ppCardId FROM tblPpCardUserInfoMapping WHERE ppCardId = @ppcardId
	IF @@ROWCOUNT > 0
		BEGIN
			INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt)VALUES (@userNumber, @ppCardSerialNumber, getdate()) 	
			SET @returnCode = -3		--????? ppcard 
			RETURN
		END

	--IF (@validEndDt < @now OR @validStartDt > @now) 
	IF (@validEndDt < @now) 
		BEGIN
			INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt)
			VALUES (@userNumber, @ppCardSerialNumber, getdate()) 			
			SET @returnCode = -4		-- ???? ?? ??
			RETURN
		END

	--SELECT num FROM tblPpCardFailList WHERE userNumber = @userNumber  AND registDt BETWEEN @lastDt AND @now
	--SET @failStartDt= left(Convert(varchar(10), getdate(), 21),10) + ' 00:00:00'
	--SET @failEndDt= left(Convert(varchar(10), getdate(), 21),10) + ' 00:00:00'
	--SET @failStartDt= dateadd(dd, -1, getdate())  --1day
	SET @failStartDt= dateadd(mi, -30, getdate())  --30minutes
	SELECT num FROM tblPpCardFailList WHERE userNumber = @userNumber  AND registDt BETWEEN @failStartDt AND @now
	IF @@ROWCOUNT > 4 
	BEGIN		
		SET @returnCode = -5		
		RETURN		
	END
GO
/****** Object:  StoredProcedure [dbo].[procGetPpCardDetail]    Script Date: 09/21/2014 18:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetPpCardDetail    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procCreatePpCard
	Creation Date		:	2002. 12. 26
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	PPCard? ??
	Input Parameters :	
			
	return?:
		rtnValue 		as		int : ?? ??
	Return Status:		
		Integer
	Usage: 			
		exec procInsertCard 10, '1234123412345678', 1000, 1, 0400, '????', 9982732724, 'KF200204050000001234'
	Call by		:	PP?? ?? ???
				PGCardService.CardManager	
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I), tblChargeCardDeposit(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetPpCardDetail]
	@startDt 		as 	smallDatetime
,	@endDt 		as 	smallDatetime
AS
SELECT  
	PCS.chongphanId, C.chongphanName, count(PCS.ppcardSaleId) as cnt, sum(PCS.price) as sm
FROM 
	tblPpCardSale PCS WITH(NOLOCK) JOIN 
	tblChongphan C WITH(NOLOCK) ON PCS.chongphanId = C.chongphanId
WHERE PCS.registDt > @startDt AND PCS.registDt < @endDt
GROUP BY PCS.chongphanId, C.chongphanName
GO
/****** Object:  StoredProcedure [dbo].[procGetPeriodCodeList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetPeriodCodeList    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetPeriodCodeList
	Creation Date		:	2002. 2. 20.
	Written by		:	???
	E-Mail by 		:	jsh001@n-cash.net
	Purpose			:	???? - ????
	Input Parameters 	:	
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetPeriodCodeList]
as
SELECT 
	periodTypeId, descript, registDt
FROM 
	tblCodePeriodType  with(nolock)
--	tblAdmin a with (nolock) 
--WHERE 
--	cus.adminNumber = a.adminNumber
GO
/****** Object:  StoredProcedure [dbo].[procGetPcBangSumDetailbak]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetPcBangSumDetail    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procCreatePpCard
	Creation Date		:	2002. 12. 26
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	PPCard? ??
	Input Parameters :	
			
	return?:
		rtnValue 		as		int : ?? ??
	Return Status:		
		Integer
	Usage: 			
		exec procInsertCard 10, '1234123412345678', 1000, 1, 0400, '????', 9982732724, 'KF200204050000001234'
	Call by		:	PP?? ?? ???
				PGCardService.CardManager	
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I), tblChargeCardDeposit(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetPcBangSumDetailbak]
	@startDt 		as 	smallDatetime
,	@endDt 		as 	smallDatetime
AS
SELECT 
	U.cpId, CP.cpName, count(T.transactionId) as cnt, sum(T.cashAmount) as sm
FROM 
	tblTransaction T WITH(NOLOCK) JOIN 
	tblCharge C WITH(NOLOCK) ON T.transactionId = C.transactionId JOIN
	tblUser U WITH(NOLOCK) ON T.userNumber = U.userNumber JOIN
	tblCp CP WITH(NOLOCK) ON  U.cpId = CP.cpId
WHERE C.chargeTypeId = 5 AND T.registDt > @startDt AND T.registDt < @endDt AND T.peerTransactionId is null
GROUP BY U.cpId, CP.cpName
GO
/****** Object:  StoredProcedure [dbo].[procGetPcBangSumDetail]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetPcBangSumDetail    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procCreatePpCard
	Creation Date		:	2002. 12. 26
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	PPCard? ??
	Input Parameters :	
			
	return?:
		rtnValue 		as		int : ?? ??
	Return Status:		
		Integer
	Usage: 			
		exec procInsertCard 10, '1234123412345678', 1000, 1, 0400, '????', 9982732724, 'KF200204050000001234'
	Call by		:	PP?? ?? ???
				PGCardService.CardManager	
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I), tblChargeCardDeposit(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetPcBangSumDetail]
	@startDt 		as 	smallDatetime
,	@endDt 		as 	smallDatetime
AS

SELECT 
	g.gamebangId  ,  count(T.transactionId) as cnt, sum(T.cashAmount) as sm , g.gamebangName 
FROM 
	tblTransaction T WITH(NOLOCK) JOIN 
	tblCharge C WITH(NOLOCK) ON T.transactionId = C.transactionId JOIN
	tblUser U WITH(NOLOCK) ON T.userNumber = U.userNumber JOIN
	tblGamebang g with(nolock) on g.gamebangId=U.cpId

WHERE C.chargeTypeId = 5  AND T.registDt  between @startDt AND @endDt -- AND T.peerTransactionId is null
GROUP BY g.gamebangId, g.gamebangName

/*
SELECT 
	U.cpId, CP.cpName, count(T.transactionId) as cnt, sum(T.cashAmount) as sm
FROM 
	tblTransaction T WITH(NOLOCK) JOIN 
	tblCharge C WITH(NOLOCK) ON T.transactionId = C.transactionId JOIN
	tblUser U WITH(NOLOCK) ON T.userNumber = U.userNumber JOIN
	tblCp CP WITH(NOLOCK) ON  U.cpId = CP.cpId
WHERE C.chargeTypeId = 5 AND T.registDt > @startDt AND T.registDt < @endDt AND T.peerTransactionId is null
GROUP BY U.cpId, CP.cpName
*/
GO
/****** Object:  StoredProcedure [dbo].[procGetPcBangDetailbak]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetPcBangDetail    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procCreatePpCard
	Creation Date		:	2002. 12. 26
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	PPCard? ??
	Input Parameters :	
			
	return?:
		rtnValue 		as		int : ?? ??
	Return Status:		
		Integer
	Usage: 			
		exec procInsertCard 10, '1234123412345678', 1000, 1, 0400, '????', 9982732724, 'KF200204050000001234'
	Call by		:	PP?? ?? ???
				PGCardService.CardManager	
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I), tblChargeCardDeposit(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetPcBangDetailbak]
	@startDt 		as 	smallDatetime
,	@endDt 		as 	smallDatetime
AS
SELECT 
	U.cpId, CP.cpName, count(T.transactionId) as cnt, sum(T.cashAmount) as sm
FROM 
	tblTransaction T WITH(NOLOCK) JOIN 
	tblCharge C WITH(NOLOCK) ON T.transactionId = C.transactionId JOIN
	tblUser U WITH(NOLOCK) ON T.userNumber = U.userNumber JOIN
	tblCp CP WITH(NOLOCK) ON  U.cpId = CP.cpId
WHERE C.chargeTypeId = 5 AND T.registDt > @startDt AND T.registDt < @endDt
GROUP BY U.cpId, CP.cpName
GO
/****** Object:  StoredProcedure [dbo].[procGetPcBangDetail]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetPcBangDetail    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procCreatePpCard
	Creation Date		:	2002. 12. 26
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	PPCard? ??
	Input Parameters :	
			
	return?:
		rtnValue 		as		int : ?? ??
	Return Status:		
		Integer
	Usage: 			
		exec procInsertCard 10, '1234123412345678', 1000, 1, 0400, '????', 9982732724, 'KF200204050000001234'
	Call by		:	PP?? ?? ???
				PGCardService.CardManager	
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I), tblChargeCardDeposit(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetPcBangDetail]
	@startDt 		as 	smallDatetime
,	@endDt 		as 	smallDatetime
AS
SELECT 
	U.cpId, CP.cpName, count(T.transactionId) as cnt, sum(T.cashAmount) as sm
FROM 
	tblTransaction T WITH(NOLOCK) JOIN 
	tblCharge C WITH(NOLOCK) ON T.transactionId = C.transactionId JOIN
	tblUser U WITH(NOLOCK) ON T.userNumber = U.userNumber JOIN
	tblCp CP WITH(NOLOCK) ON  U.cpId = CP.cpId
WHERE C.chargeTypeId = 5 AND T.registDt > @startDt AND T.registDt < @endDt
GROUP BY U.cpId, CP.cpName
GO
/****** Object:  StoredProcedure [dbo].[procGetPcBangCancelDetail]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetPcBangCancelDetail    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procCreatePpCard
	Creation Date		:	2002. 12. 26
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	PPCard? ??
	Input Parameters :	
			
	return?:
		rtnValue 		as		int : ?? ??
	Return Status:		
		Integer
	Usage: 			
		exec procInsertCard 10, '1234123412345678', 1000, 1, 0400, '????', 9982732724, 'KF200204050000001234'
	Call by		:	PP?? ?? ???
				PGCardService.CardManager	
	Calls		: 	Nothing
	Access Table 	: 	tblTransaction(I), tblChargeCardDeposit(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetPcBangCancelDetail]
	@startDt 		as 	smallDatetime
,	@endDt 		as 	smallDatetime
AS
SELECT 
	U.cpId, CP.cpName, count(T.transactionId) as cnt, sum(T.cashAmount) as sm
FROM 
	tblTransaction T WITH(NOLOCK) JOIN 
	tblCharge C WITH(NOLOCK) ON T.transactionId = C.transactionId JOIN
	tblUser U WITH(NOLOCK) ON T.userNumber = U.userNumber JOIN
	tblCp CP WITH(NOLOCK) ON  U.cpId = CP.cpId
WHERE C.chargeTypeId = 5 AND T.registDt > @startDt AND T.registDt < @endDt AND T.peerTransactionId is not null
GROUP BY U.cpId, CP.cpName
GO
/****** Object:  StoredProcedure [dbo].[procGetPasswordCheckQuestionCode]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetPasswordCheckQuestionCode    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	???
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	?? ?? ?? select
	Input Parameters :	
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetPasswordCheckQuestionCode]
as
SELECT 
	passwordCheckQuestionTypeId, descript
FROM 
	tblCodePasswordCheckType
GO
/****** Object:  StoredProcedure [dbo].[procGetPasswordCheckQuestion]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetPasswordCheckQuestion    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetPasswordCheckQuestion]
as
SELECT 
	passwordCheckQuestionTypeId, descript
FROM 
	tblCodePasswordCheckType
GO
/****** Object:  StoredProcedure [dbo].[procGetLastEmptyTransaction]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetLastEmptyTransaction    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetLastEmptyTransaction]
@userNumber		as		int
as
SELECT 
	MAX(t.transactionId)
FROM 
	tblTransaction t with (nolock)				,
	tblOrder o with (nolock)					,
	tblCharge c with (nolock)
WHERE
	t.peerTransactionId is null AND
	t.userNumber = @userNumber AND
	t.transactionTypeId = 2 AND
	t.transactionId = o.transactionId AND
	o.chargeTransactionId = c.transactionId AND
	c.chargeTypeId not in (3)
GO
/****** Object:  StoredProcedure [dbo].[procGetJob]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetJob    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetJob
	Creation Date		:	2002. 2. 7.
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	
	Input Parameters :	
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetJob]
as
SELECT 
	jobTypeId, descript
FROM tblCodeJobType with (nolock)
GO
/****** Object:  StoredProcedure [dbo].[procGetGameServiceInfo]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procGetGameServiceInfo]
	@userId		as	nvarchar(32)
,	@gameServiceId	as	smallint
 AS
	SELECT startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPLAyableMinutes
	FROM tblUserGameService UGSH with (nolock)
		JOIN tblUserInfo UI with (nolock) ON UGSH.userNumber = UI.userNumber
	WHERE UI.userId = @userId and UGSH.gameServiceId = @gameServiceId and UI.gameServiceId = @gameServiceId
GO
/****** Object:  StoredProcedure [dbo].[procGetGameService]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetGameService    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetGameService]
@cpId			as		int
as
SELECT gs.gameServiceId, gs.gameServiceName , c.cpName
FROM 
	tblGameService gs LEFT OUTER JOIN tblCp c
ON gs.cpId = c.cpId
WHERE 
	gs.apply = 1 AND 
	c.apply = 1 AND
	gs.cpId = @cpId
GO
/****** Object:  StoredProcedure [dbo].[procGetGamebangGameServiceReservationInfo]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
??? ?? ?? ? ????
*/

CREATE proc [dbo].[procGetGamebangGameServiceReservationInfo]
	@gamebangId		int
as
SELECT  productName, productAmount, p.ipCount, t.registDt from tblGamebangGameServiceReservation gb with(rowlock)  
	JOIN  tblProduct p with(rowlock)  on p.productId=gb.productId
	JOIN tblTransaction t with(rowlock) on  t.transactionId=gb.transactionid
WHERE gb.gamebangId=@gamebangId and isUpdate =0 and isCancel=0
GO
/****** Object:  StoredProcedure [dbo].[procGetGamebangCodeList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetGamebangCodeList    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetGamebangCodeList
	Creation Date		:	2002. 2. 20.
	Written by		:	???
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters 	:	
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetGamebangCodeList]
as
SELECT 
	gamebangPaymentTypeId, descript, registDt
FROM 
	tblCodeGamebangPaymentType  with(nolock)
--	tblAdmin a with (nolock) 
--WHERE 
--	cus.adminNumber = a.adminNumber
GO
/****** Object:  StoredProcedure [dbo].[procGetErrorCodeList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetErrorCodeList    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetErrorCodeList
	Creation Date		:	2002. 2. 20.
	Written by		:	???
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters 	:	
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetErrorCodeList]
as
SELECT 
--	ErrorNum, ErrorDescription, producer, codeExplanation, registDt
	ErrorNum, ErrorDescription, codeExplanation, registDt
FROM 
	tblCodeErrorNumber with(nolock)
--	tblAdmin a with (nolock) 
--WHERE 
--	cus.adminNumber = a.adminNumber
GO
/****** Object:  StoredProcedure [dbo].[procGetDailyRevenueForMonth]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetDailyRevenueForMonth]
	@dateMonth			AS CHAR(6) -- '200611 : target month  
,	@totalChargedAmount	AS INT OUTPUT
,	@totalOrderedAmount	AS INT OUTPUT
,	@averageTopUpPerUser	AS INT OUTPUT
,	@averageOrderPerUser	AS INT OUTPUT
,	@totalUniqueTopUpTransaction	AS INT OUTPUT
,	@totalUniqueOrderTransaction	AS INT OUTPUT
,	@totalTopUpTransaction			AS INT OUTPUT
,	@totalOrderTransaction			AS INT OUTPUT
AS  
--SET @dateMonth = '200611'

SET NOCOUNT ON  
  
DECLARE   
 @startYear AS varchar(4)  
, @startMonth AS varchar(2)  
, @tempString AS varchar(20)  
, @startDt AS datetime  
, @endDt  AS datetime  
  
  
--SET @dateMonth = '200610'  
SET @startYear = LEFT(@dateMonth, 4)  
SET @startMonth = RIGHT(@dateMonth, 2)  
SET @tempString = @startYear + '-' + @startMonth + '-01'  
SET @startDt = CAST(@tempString AS DATETIME)  
SET @endDt = DATEADD(month, 1, @startDt) 

SELECT [Year], [Month], [Day] 
	, CONVERT(DECIMAL(10, 2), topupSum) AS topupSum
	, topupNoOfTrans
	, CONVERT(DECIMAL(10, 2), orderSum)AS orderSum
	, orderNoOfTrans
	, uniqueTopUpTransaction
	, uniqueOrderTransaction
	, CONVERT(DECIMAL(10, 2), averageTopUpPerUser) AS averageTopUpPerUser
	, CONVERT(DECIMAL(10, 2), averageOrderPerUser) AS averageOrderPerUser
FROM
(


	SELECT [Year], [Month], [Day] 
		, SUM(CASE WHEN transactionTypeId = 1 THEN ISNULL(Amount, 0) END) AS topupSum
		, SUM(CASE WHEN transactionTypeId = 1 THEN ISNULL(NoOfTransactions, 0) END) AS topupNoOfTrans
		, ABS(SUM(CASE WHEN transactionTypeId = 2 THEN ISNULL(Amount, 0) END)) AS orderSum
		, SUM(CASE WHEN transactionTypeId = 2 THEN ISNULL(NoOfTransactions, 0) END) AS orderNoOfTrans
		, SUM(CASE WHEN transactionTypeId = 1 THEN userCount END) AS uniqueTopUpTransaction
		, SUM(CASE WHEN transactionTypeId = 2 THEN userCount END) AS uniqueOrderTransaction
		, SUM(CASE WHEN transactionTypeId = 1 THEN averagePerUser END) AS averageTopUpPerUser
		, ABS(SUM(CASE WHEN transactionTypeId = 2 THEN averagePerUser END)) AS averageOrderPerUser
	FROM
	(  
		SELECT @startYear AS 'Year', @startMonth AS 'Month', DATEPART(dd, T.registDt) AS 'Day'  
		 , SUM(	 
			CASE WHEN T.registDt > '2006-12-15 00:00' and T.registDt < '2006-12-25 23:59'
				THEN (T.cashAmount / 1.2)
			ELSE T.cashAmount
			END
			) AS Amount	-- not event : SUM(T.cashAmount) AS Amount
		 , COUNT(*) AS NoOfTransactions
		 , COUNT(DISTINCT(T.userNumber)) AS userCount
		 , SUM(
			CASE WHEN T.registDt > '2006-12-15 00:00' and T.registDt < '2006-12-25 23:59'
				THEN (T.cashAmount / 1.2)
			ELSE T.cashAmount
			END	 	 
			 ) / COUNT(DISTINCT(T.userNumber)) AS averagePerUser	-- not event : SUM(T.cashAmount) / COUNT(DISTINCT(T.userNumber)) AS averagePerUser
		 , 1 AS transactionTypeId
		FROM tblTransaction T WITH(NOLOCK)  
		JOIN tblCharge C WITH(NOLOCK) ON T.transactionId = C.transactionId  
		JOIN tblUserInfo UI WITH(NOLOCK) ON T.userNumber = UI.userNumber  
		WHERE T.registDt >= @startDt AND T.registDt < @endDt  
		 AND T.transactionTypeId = 1 AND T.peerTransactionId IS NULL  
		 AND C.chargeTypeId = 3 AND UI.userTypeId <> 5  
		GROUP BY DATEPART(dd, T.registDt) 
		--ORDER BY DATEPART(dd, T.registDt)  
	
		UNION ALL
		
		SELECT @startYear AS 'Year', @startMonth AS 'Month', DATEPART(dd, T.registDt) AS 'Day'  
		 , SUM(T.cashAmount) AS Amount, COUNT(*) AS NoOfTransactions
		 , COUNT(DISTINCT(T.userNumber)) AS userCount, SUM(T.cashAmount) / COUNT(DISTINCT(T.userNumber)) AS averagePerUser
		 , 2 AS transactionTypeId
		FROM tblTransaction T WITH(NOLOCK) 
		JOIN tblOrder O WITH(NOLOCK) ON T.transactionId = O.transactionId
		JOIN tblUserInfo UI WITH(NOLOCK) ON T.userNumber = UI.userNumber  
		WHERE T.registDt >= @startDt AND T.registDt < @endDt  
		 AND T.transactionTypeId = 2 AND T.peerTransactionId IS NULL  AND UI.userTypeId <> 5  
		GROUP BY DATEPART(dd, T.registDt)  
		--ORDER BY DATEPART(dd, T.registDt)  
	) AS SUB2
	GROUP BY [Year], [Month], [Day]
) AS SUMDATA
ORDER BY [Day] ASC


SELECT @totalChargedAmount = SUM(
		CASE WHEN T.registDt > '2006-12-15 00:00' and T.registDt < '2006-12-25 23:59'
			THEN (T.cashAmount / 1.2)
		ELSE T.cashAmount
		END
		)	-- not event : SUM(T.cashAmount)
		, @averageTopUpPerUser = SUM(
		CASE WHEN T.registDt > '2006-12-15 00:00' and T.registDt < '2006-12-25 23:59'
			THEN (T.cashAmount / 1.2)
		ELSE T.cashAmount
		END				
		) / COUNT(DISTINCT(T.userNumber))		-- not event : SUM(T.cashAmount) / COUNT(DISTINCT(T.userNumber))
		
		, @totalUniqueTopUpTransaction = COUNT(DISTINCT(T.userNumber)), @totalTopUpTransaction = COUNT(*)
FROM tblTransaction T WITH(NOLOCK)  
JOIN tblCharge C WITH(NOLOCK) ON T.transactionId = C.transactionId  
JOIN tblUserInfo UI WITH(NOLOCK) ON T.userNumber = UI.userNumber  
WHERE T.registDt >= @startDt AND T.registDt < @endDt  
 AND T.transactionTypeId = 1 AND T.peerTransactionId IS NULL  
 AND C.chargeTypeId = 3 AND UI.userTypeId <> 5  
 
 
SELECT @totalOrderedAmount = ABS(SUM(T.cashAmount)),  @averageOrderPerUser =  ABS(SUM(T.cashAmount)) / COUNT(DISTINCT(T.userNumber))
	, @totalUniqueOrderTransaction = COUNT(DISTINCT(T.userNumber)), @totalOrderTransaction = COUNT(*)
FROM tblTransaction T WITH(NOLOCK) 
JOIN tblOrder O WITH(NOLOCK) ON T.transactionId = O.transactionId
JOIN tblUserInfo UI WITH(NOLOCK) ON T.userNumber = UI.userNumber  
WHERE T.registDt >= @startDt AND T.registDt < @endDt  
 AND T.transactionTypeId = 2 AND T.peerTransactionId IS NULL  AND UI.userTypeId <> 5  

  
SET NOCOUNT OFF
GO
/****** Object:  StoredProcedure [dbo].[procGetCp]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetCp    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetCp]
as
SELECT 
	cpId, cpName 
FROM tblCp with (nolock)
WHERE apply = 1
GO
/****** Object:  StoredProcedure [dbo].[procGetCompanyId]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetCompanyId    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetCompanyId
	Creation Date		:	2002. 02.15
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	cpid? ??
	
	Input Parameters :	
				@tblName		AS		nvarchar(16)
	Output Parameters:	
				@returnCode			AS		INT
				
	Return Status:		
				???? ??? ? ??				
	Usage: 			
	EXEC procGetCompanyId 'cp', @returnCode OUTPUT
	Call by		:	procInsertGamebang , procInsertChongphan , procInsertCp
	Calls		: 	Nothing
	Access Table 	: 	tblCompany(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetCompanyId]
	@tblName		AS		nvarchar(16)
,	@returnCode		AS		INT		OUTPUT
AS
INSERT INTO tblCompany 
	VALUES(@tblName,GETDATE())
SET @returnCode = @@IDENTITY
GO
/****** Object:  StoredProcedure [dbo].[procGetChargeCreateCardTemp]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
?? ?? ??? ????? ?? ??, ??, ?? ?? ???? ???
*/

CREATE PROCEDURE [dbo].[procGetChargeCreateCardTemp]
	@chargeCardDepositTempId	AS	INT	
,	@userNumber			AS	INT	OUTPUT
,	@productId			AS	INT	OUTPUT
,	@amount			AS	INT	OUTPUT
 
AS
	SELECT @userNumber = userNumber ,@productId = productId, @amount =amount
	FROM tblChargeCardDepositTemp  with(nolock)
	WHERE  chargeCardDepositTempId=@chargeCardDepositTempId
GO
/****** Object:  StoredProcedure [dbo].[procGetChargeCodeList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetChargeCodeList    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetChargeCodeList
	Creation Date		:	2002. 2. 20.
	Written by		:	???
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters 	:	
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetChargeCodeList]
as
SELECT 
	chargeTypeId, descript, registDt
FROM 
	tblCodeChargeType with(nolock)
--	tblAdmin a with (nolock) 
--WHERE 
--	cus.adminNumber = a.adminNumber
GO
/****** Object:  StoredProcedure [dbo].[procGetAdminGradeList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetAdminGradeList    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetAdminGradeList
	Creation Date		:	2002. 2. 20.
	Written by		:	???
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters 	:	
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetAdminGradeList]
as
SELECT 
	adminGradeTypeId, descript, registDt
FROM 
	tblCodeAdminGradeType  with(nolock)
--	tblAdmin a with (nolock) 
--WHERE 
--	cus.adminNumber = a.adminNumber
GO
/****** Object:  StoredProcedure [dbo].[procGetAdminGradeCodeList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetAdminGradeCodeList    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetAdminGradeCodeList]
as
SELECT 
	adminGradeTypeId, descript, registDt, apply
FROM 
	tblCodeAdminGradeType  with(nolock)
--	tblAdmin a with (nolock) 
--WHERE 
--	cus.adminNumber = a.adminNumber
GO
/****** Object:  StoredProcedure [dbo].[procGetAdminGoupCodeList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetAdminGoupCodeList    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetAdminGoupCodeList
	Creation Date		:	2002. 2. 20.
	Written by		:	???
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters 	:	
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetAdminGoupCodeList]
as
SELECT 
	adminGroupTypeId, descript, registDt
FROM 
	tblCodeAdminGroupType  with(nolock)
--	tblAdmin a with (nolock) 
--WHERE 
--	cus.adminNumber = a.adminNumber
GO
/****** Object:  StoredProcedure [dbo].[procGetAdminChargeType]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetAdminChargeType    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetAdminChargeType]
as
SELECT 
	chargeTypeId, descript 
FROM tblCodeChargeType with (nolock)
WHERE chargeTypeId in (7, 8, 9)
GO
/****** Object:  StoredProcedure [dbo].[procGameUsedTimeCheck]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGameUsedTimeCheck    Script Date: 23/1/2546 11:40:24 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procGameUsedTimeCheck
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	???? ???? ??
	
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGameUsedTimeCheck]
	@gamebangId			AS		INT
,	@totalGameUserTime		AS		BIGINT		OUTPUT
AS
DECLARE	@beforeTotalUsedTime		AS		INT
DECLARE	@newTotalUsedTime		AS		INT
SELECT @beforeTotalUsedTime = ISNULL(SUM(DATEDIFF(mi, loginDt, logoutDt)) , 0) 
FROM tblGameAccessLog WITH (NOLOCK) 
WHERE totalApplyUsedMinutes IS NULL AND gamebangId = @gamebangId
SELECT @newTotalUsedTime = ISNULL(SUM(totalApplyUsedMinutes ) , 0) 
FROM tblGameAccessLog 
WITH (NOLOCK) WHERE totalApplyUsedMinutes IS NOT NULL AND gamebangId = @gamebangId
SET @totalGameUserTime = @beforeTotalUsedTime + @newTotalUsedTime
GO
/****** Object:  StoredProcedure [dbo].[procGamebangSettlement]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGamebangSettlement    Script Date: 23/1/2546 11:40:27 ******/
CREATE PROCEDURE [dbo].[procGamebangSettlement]
	@startDt		as	datetime	
,	@endDt		as	datetime
,	@chongphanId		as	int
,	@check		as	tinyint 
AS
	
	if @check = 1 
		begin 
			select c.chargeTypeId,  sum(cashAmount)
			from tblTransaction t, tblCharge c, tblUserInfo u, tblChongphanGamebang cg
			where t.transactionId = c.transactionId and u.userNumber = t.userNumber and u.cpId = cg.gamebangId
				and t.transactionTypeId = 1 and  t.registDt between @startDt and @endDt  and chargeTypeId in(4,5,6) and u.userTypeId = 9
				and cg.chongphanId = @chongphanId
			group by c.chargeTypeId
		end 
	else
		begin
			select c.chargeTypeId,  sum(cashAmount)
			from tblTransaction t, tblCharge c, tblUserInfo u, tblChongphanGamebang cg
			where t.peerTransactionId = c.transactionId and u.userNumber = t.userNumber and u.cpId = cg.gamebangId
				and t.peerTransactionId in (select transactionId from tblTransaction where transactionTypeId = 1) 
				and t.transactionTypeId = 5 and  t.registDt between @startDt and @endDt  and chargeTypeId in(4,5,6) and u.userTypeId = 9
				and cg.chongphanId = @chongphanId
			group by c.chargeTypeId
		end
/*	SELECT chargeTypeId, sum(receipt) as amount FROM tblGamebangSettlement WHERE gamebangId 
	in (SELECT gamebangId FROM tblChongphanGamebang WHERE chongphanId = @chongphanId and apply = 1 )
	and startDt between @startDt and @endDt
	GROUP BY chargeTypeId
*/
GO
/****** Object:  StoredProcedure [dbo].[procGamebangMoneySettlement]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGamebangMoneySettlement    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procGamebangMoneySettlement
	Creation Date		:	2002. 5. 24
	Written by		:	???
	E-Mail by 		:	airpol@n-cash.net
	Purpose			:	
	Input Parameters :	
		@startDt	nvarchar(20)	:  ???
		@endDt	nvarchar(20)	:  ????			
		@chongphanId	int		:  ?????
		@depositAmount	int	:  (   ) ????
		@depositCancelAmount	int	:  (   ) ?? ????
	return?			:
	Output Parameters	:	
	Return Status		:		
	Usage			: 			
	Call by			:	
	Calls			: 	
	Access Table 		: 	tblBankDepositConfirm, tblChongphanGamebang, tblChongphan, tblOrder
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGamebangMoneySettlement]
	@startDt		as	nvarchar(20)	
,	@endDt		as	nvarchar(20)
,	@chongphanId		as	int
AS
	DECLARE @depositAmount as int
	DECLARE @depositCancelAmount as int
/*	?????? ?????
	(    ) ????	
*/
	
	SELECT @depositAmount = sum(depositAmount)  
	FROM tblBankDepositConfirm bc, tblChongphanGamebang cg, tblChongphan c, tblOrder o
	WHERE bc.gamebangId = cg.gamebangId and c.chongphanId = cg.chongphanId and bc.depositDate >= @startDt and  bc.depositDate < @endDt 
	and cg.chongphanId = @chongphanId and confirmType != 2 and o.transactionId = bc.transactionId
	GROUP BY c.chongphanName, cg.chongphanId
	SELECT @depositCancelAmount = sum(depositAmount)  
	FROM tblBankDepositConfirm bc, tblChongphanGamebang cg, tblChongphan c, tblOrder o
	WHERE bc.gamebangId = cg.gamebangId and c.chongphanId = cg.chongphanId and bc.registDt >= @startDt and  bc.registDt < @endDt 
	and cg.chongphanId = @chongphanId and confirmType = 2 and o.transactionId = bc.transactionId
	GROUP BY c.chongphanName, cg.chongphanId
	SELECT ISNULL(@depositAmount, 0) - ISNULL(@depositCancelAmount, 0)
GO
/****** Object:  StoredProcedure [dbo].[procGamebangLogin]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGamebangLogin    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procGamebangLogin 
	Creation Date		:	2002. 02.20
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	??? ??? ??? ????? ??
	
	Input Parameters :	
				@userId			AS		nvarchar(32)
				@userPwd			AS		nvarchar(32)
	Output Parameters:	
				@chongphanId			AS		INT		OUTPUT
				@gamebangId			AS		INT		OUTPUT
				@userNumber			AS		INT		OUTPUT
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ?? ?????.
				2: ?? ?????.
				3: ????? ???.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGamebangLogin] 
	@userId			AS		nvarchar(32)
,	@userPwd			AS		nvarchar(32)
,	@userNumber			AS		INT		OUTPUT
,	@gamebangId			AS		INT		OUTPUT
,	@chongphanId			AS		INT		OUTPUT
,	@cpId				AS		INT		OUTPUT
,	@returnCode			AS		TINYINT	OUTPUT
AS
DECLARE 	@checkUserPwd 	AS		nvarchar(32)
SELECT @checkUserPwd = userPwd , @userNumber = userNumber , @gamebangId = cpId  FROM tblUserInfo WHERE userId = @userId AND userTypeId = 9 AND apply = 1
IF(@checkUserPwd IS NULL )
	BEGIN
		SET @returnCode = 2
	END
ELSE IF(@checkUserPwd  <> @userPwd)
	BEGIN
		SET @returnCode = 3
	END
ELSE IF(@checkUserPwd  = @userPwd)
	BEGIN
		
		SELECT @chongphanId = chongphanId FROM tblChongphanGamebang WHERE gamebangId = @gamebangId AND apply = 1
		SELECT @cpId = cpId FROM tblCpChongphan WHERE chongphanId = @chongphanId
		SET @returnCode = 1
	END
GO
/****** Object:  StoredProcedure [dbo].[procGamebangCardSettlement]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGamebangCardSettlement    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procGamebangCardSettlement
	Creation Date		:	2002. 5. 24
	Written by		:	???
	E-Mail by 		:	airpol@n-cash.net
	Purpose			:	
	Input Parameters :	
		@startDt	nvarchar(20)	:  ???
		@endDt	nvarchar(20)	:  ????			
		@chongphanId	int		:  ?????
		@cardAmount		int	:  ??? ??? ??? ???? ??
		@cardCancelAmount	int	:  ????? ??? ??? ???? ??
	return?			:
	Output Parameters	:	
	Return Status		:		
	Usage			: 			
	Call by			:	
	Calls			: 	
	Access Table 		: 	tblTransaction, tblCharge, tblUserInfo, tblChongphanGamebang
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGamebangCardSettlement]
	@startDt		as	nvarchar(20)	
,	@endDt		as	nvarchar(20)
,	@chongphanId		as	int
AS
	DECLARE @cardAmount	as 	int
	DECLARE @cardCancelAmount	as	int	
/*	???? ??(@chongphanId)? 
	??????? ?????(userTypeId=9)? ?????(chargeTypeId=4)? 
             ??(transactionTypeId=1)???? ??
*/
	SELECT @cardAmount = sum(cashAmount)
	FROM tblTransaction t, tblCharge c, tblUserInfo u, tblChongphanGamebang cg
	WHERE t.transactionId = c.transactionId and u.userNumber = t.userNumber and u.cpId = cg.gamebangId
		and t.transactionTypeId = 1 and  t.registDt between @startDt and @endDt  and chargeTypeId = 4 and u.userTypeId = 9
		and cg.chongphanId = @chongphanId
/*	???? ??(@chongphanId)? ????(chargeTypeId)? ??
	??????? ?????(userTypeId=9)? ?????(chargeTypeId=4)? 
             ????? ????(peerTransactionId), ????(transactionTypeId=5)???? ??
*/
	SELECT @cardCancelAmount = sum(cashAmount)
	FROM tblTransaction t, tblCharge c, tblUserInfo u, tblChongphanGamebang cg
	WHERE t.peerTransactionId = c.transactionId and u.userNumber = t.userNumber and u.cpId = cg.gamebangId
		and t.peerTransactionId in (SELECT transactionId FROM tblTransaction WHERE transactionTypeId = 1) 
		and t.transactionTypeId = 5 and  t.registDt between @startDt and @endDt  and chargeTypeId = 4 and u.userTypeId = 9
		and cg.chongphanId = @chongphanId
	GROUP BY c.chargeTypeId
/*	??? ??? null?? 0? ?? (??? ??)	
*/
	SELECT  isnull(@cardAmount, 0) + isnull(@cardCancelAmount, 0)
GO
/****** Object:  StoredProcedure [dbo].[procGetUserStatusCodeList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserStatusCodeList    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserStatusCodeList]
as
SELECT 
	cus.userStatusId, cus.descript, cus.canGameLogin, cus.canWebLogin, cus.canOrder, cus.registDt,  cus.apply
FROM 
	tblCodeUserStatus cus with(nolock)
ORDER BY
	cus.userStatusId
GO
/****** Object:  StoredProcedure [dbo].[procGetUserStatusCode]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserStatusCode    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserStatusCode]
@userStatusId				as		int
as
SELECT 
	cus.userStatusId, cus.descript, cus.canGameLogin, cus.canWebLogin, cus.canOrder, cus.registDt, cus.apply
FROM 
	tblCodeUserStatus cus with(nolock)
	
WHERE 
	cus.userStatusId = @userStatusId
GO
/****** Object:  StoredProcedure [dbo].[procGetUserStatus]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetUserStatus    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserStatus]
as
SELECT 
	userStatusId, descript 
FROM tblCodeUserStatus with (nolock)
WHERE apply = 1
GO
/****** Object:  StoredProcedure [dbo].[procGetUserServiceInfo]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserServiceInfo    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserServiceInfo]
@userNumber				as 	int		,
@cpId					as	int
as
SELECT 
	ui.userId, gs.gameServiceName, ugs.startDt, ugs.endDt, ugs.limitTime, ugs.usedLimitTime, ugs.applyStartTime, ugs.applyEndTime, ugs.playableMinutes, ugs.usedPlayableMinutes, ugs.registDt, expireDt
FROM 
	tblUserGameService ugs with(rowlock), 
	tblUserInfo ui with(rowlock), 
	tblGameService gs with(nolock)
WHERE 
	ugs.userNumber = @userNumber
	AND ugs.userNumber = ui.userNumber
	AND ugs.gameServiceId = gs.gameServiceId
	AND ui.cpId = @cpId
GO
/****** Object:  StoredProcedure [dbo].[procGetUserSalesList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetUserSalesList    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserSalesList]
@userNumber	as	int
as
SELECT 
	t.transactionId , 				--0
	ctt.transactionTypeId, 			--1
	ctt.descript, 				--2
	ui.userId, 				--3
	c.cpName, 				--4
	t.cashAmount, 				--5
	isnull(gs.gameServiceName, ''), 		--6
	isnull(p.productName, ''),			--7
	t.registDt, 				--8
	t.peerTransactionId, 			--9
	ugsh.endDt, 				--10
	ch.chargeTypeId,			--11
	isnull(p.limitTime , 0) as limitTime,		--12
	p.productId				--13
FROM 
	tblTransaction t with (nolock) 
	LEFT OUTER JOIN tblOrder o with (nolock) ON t.transactionId = o.transactionId
	JOIN tblUserInfo ui with (nolock) ON t.userNumber = ui.userNumber
	JOIN tblCodeTransactionType ctt with (nolock) ON t.transactionTypeId = ctt.transactionTypeId
	JOIN tblCp c with (nolock) ON t.cpId = c.cpId
	LEFT OUTER JOIN tblProduct p with (nolock) ON o.productId = p.productId
	LEFT OUTER JOIN tblCharge ch with (nolock) ON ch.transactionId = t.transactionId
	-- JOIN tblCharge ch with (nolock) ON ch.transactionId =o.chargeTransactionId
	LEFT OUTER JOIN tblUserGameServiceHistory ugsh with (nolock) ON ugsh.transactionId = o.transactionId
	LEFT OUTER JOIN tblGameService gs with (nolock) ON gs.gameServiceId = ugsh.gameServiceId
WHERE 
	--ctt.transactionTypeId in (1, 2 , 8)
	ctt.transactionTypeId=1
	AND t.userNumber = @userNumber
	and t.cashAmount<>0

ORDER BY t.transactionId desc
GO
/****** Object:  StoredProcedure [dbo].[procGetUserSalesDetailForTransferAccount]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserSalesDetailForTransferAccount    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?		?? BY gun26
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserSalesDetailForTransferAccount]
@chargeTransactionId		as			int
as
--DECLARE @chargeTransactionId as int
DECLARE @startDt as datetime
DECLARE @endDt as datetime
DECLARE @chargeTypeId as int
DECLARE @chargeTypeName as nvarchar(20)
DECLARE @chargeTempId as int
DECLARE @bankName as nvarchar(8)
DECLARE @accountNumber as nvarchar(50)
DECLARE @depositorName as nvarchar(10)
DECLARE @chargeRegistDt as datetime
DECLARE @depositorSsno as nchar(13)
-- SELECT * FROM tblTransaction WHERE transactionId = @transactionId
/*
SELECT 
	@chargeTransactionId = chargeTransactionId 
FROM 
	tblOrder  with (nolock) 
WHERE 
	transactionId = @transactionId
-- ??? ?? / ? ??
SELECT 
	@startDt = startDt, @endDt = endDt 
FROM 
	tblUserGameServiceHistory  with (nolock) 
WHERE 
	transactionId = @transactionId
*/
SELECT 
	@chargeTypeName = cct.descript, @chargeTypeId = c.chargeTypeId 
FROM 
	tblCharge c with (nolock), 
	tblCodeChargeType cct with (nolock) 
WHERE 
	transactionId = @chargeTransactionId AND 
	cct.chargeTypeId = c.chargeTypeId
SELECT 
	@chargeTempId = chargeTransferAccountTempId, 
	@bankName = bankName, 
	@accountNumber = accnt_No, 
	@depositorName = depositorName, 
	@chargeRegistDt = registDt,
	@depositorSsno = depositorSsno 
FROM 
	tblChargeTransferAccount
WHERE 
	transactionId = @chargeTransactionId
SELECT 
	@chargeTypeName, @chargeTempId, @bankName, @accountNumber, @depositorName, @chargeRegistDt , @depositorSsno
GO
/****** Object:  StoredProcedure [dbo].[procGetUserSalesDetailForPpCard_backup]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetUserSalesDetailForPpCard    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserSalesDetailForPpCard_backup]
@chargeTransactionId		as			int
as
DECLARE @orderTransactionId as int
DECLARE @startDt as datetime
DECLARE @endDt as datetime
DECLARE @chargeTypeId as int
DECLARE @chargeTypeName as nvarchar(20)
DECLARE @createDt as datetime
DECLARE @ppCardId as nvarchar(20)
DECLARE @ppCardGroupId as int
DECLARE @ppCardSerialNumber as varchar(55)
-- SELECT * FROM tblTransaction WHERE transactionId = @transactionId
SELECT 
	@orderTransactionId = transactionId 
FROM 
	tblOrder  with (nolock) 
WHERE 
	chargeTransactionId = @chargeTransactionId
SELECT 
	@startDt = startDt, @endDt = endDt 
FROM 
	tblUserGameServiceHistory  with (nolock) 
WHERE 
	transactionId = @orderTransactionId
-- ??? ?? / ? ??
SELECT 
	@chargeTypeName = cct.descript, @chargeTypeId = c.chargeTypeId 
FROM 
	tblCharge c with (nolock), 
	tblCodeChargeType cct with (nolock) 
WHERE 
	transactionId = @chargeTransactionId AND 
	cct.chargeTypeId = c.chargeTypeId
SELECT @ppCardId = ppCardId FROM tblPpCardUserInfoMapping WHERE transactionId = @orderTransactionId
SELECT @ppCardGroupId = ppCardGroupId, @ppCardSerialNumber = ppCardSerialNumber FROM tblPpCard WHERE ppCardId = @ppCardId
SELECT @createDt = createDt FROM tblPpCardGroup WHERE ppCardGroupId = @ppCardGroupId
SELECT 
	@chargeTypeName, @ppCardSerialNumber, @createDt, @ppCardId, @orderTransactionId, @chargeTransactionId
GO
/****** Object:  StoredProcedure [dbo].[procGetUserSalesDetailForPpCard]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetUserSalesDetailForPpCard]
@chargeTransactionId		as			int
as
DECLARE @orderTransactionId as int
DECLARE @startDt as datetime
DECLARE @endDt as datetime
DECLARE @chargeTypeId as int
DECLARE @chargeTypeName as nvarchar(20)
DECLARE @createDt as datetime
DECLARE @ppCardId as nvarchar(20)
DECLARE @ppCardGroupId as int
DECLARE @ppCardSerialNumber as varchar(55)
-- SELECT * FROM tblTransaction WHERE transactionId = @transactionId

SELECT 
	@orderTransactionId = transactionId 
FROM 
	tblOrder  with (nolock) 
WHERE 
	chargeTransactionId = @chargeTransactionId

IF @orderTransactionId IS NULL
	SET @orderTransactionId = @chargeTransactionId

SELECT 
	@startDt = startDt, @endDt = endDt 
FROM 
	tblUserGameServiceHistory  with (nolock) 
WHERE 
	transactionId = @orderTransactionId

SELECT 
	@chargeTypeName = cct.descript, @chargeTypeId = c.chargeTypeId 
FROM 
	tblCharge c with (nolock), 
	tblCodeChargeType cct with (nolock) 
WHERE 
	transactionId = @chargeTransactionId AND 
	cct.chargeTypeId = c.chargeTypeId
SELECT @ppCardId = ppCardId FROM tblPpCardUserInfoMapping WHERE transactionId = @orderTransactionId
SELECT @ppCardGroupId = ppCardGroupId, @ppCardSerialNumber = ppCardSerialNumber FROM tblPpCard WHERE ppCardId = @ppCardId
SELECT @createDt = createDt FROM tblPpCardGroup WHERE ppCardGroupId = @ppCardGroupId
SELECT 
	@chargeTypeName, @ppCardSerialNumber, @createDt, @ppCardId, @orderTransactionId, @chargeTransactionId
GO
/****** Object:  StoredProcedure [dbo].[procGetUserSalesDetailForOrder_old_20060413]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetUserSalesDetailForOrder    Script Date: 23/1/2546 11:40:27 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procGetUserSalesDetailForOrder
	Creation Date		:	2002-07-03
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	order? ?? ?? ??
	
******************************Optional Item******************************
	Input Parameters	:	
					@transactionId			AS	INT		--orderTransactionId			
					@userNumber			AS	INT
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserSalesDetailForOrder_old_20060413]
	@transactionId			AS	INT		--orderTransactionId
,	@userNumber			AS	INT
AS
DECLARE @productId			AS	INT
DECLARE @chargeTransactionId	AS	INT
DECLARE @startDt			AS	DATETIME
DECLARE @endDt			AS	DATETIME
SELECT @productId = productId , @chargeTransactionId = chargeTransactionId
FROM tblOrder 
WHERE transactionId = @transactionId
SET @chargeTransactionId = ISNULL(@chargeTransactionId , 0)			--??? ?? ??? ?? 0? return
IF(@productId IS NULL) 			--order transaction ? ?? ??
	BEGIN
		SELECT -1 , 'Error! No order transaction.'
	END
ELSE IF(@productId = 100)		--?? ??(???)
	BEGIN
		SELECT @chargeTransactionId , 1 AS checking
	END
ELSE					--?? ??
	BEGIN
		SELECT @chargeTransactionId , 2 AS checking , startDt , endDt
		FROM tblUserGameService 
		WHERE userNumber = @userNumber
	END
GO
/****** Object:  StoredProcedure [dbo].[procGetUserSalesDetailForOrder]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetUserSalesDetailForOrder]  
 @transactionId   AS INT  --orderTransactionId  
, @userNumber   AS INT  
AS  
DECLARE @productId   AS INT  
DECLARE @chargeTransactionId AS INT  
DECLARE @startDt   AS DATETIME  
DECLARE @endDt   AS DATETIME  
SELECT @productId = productId , @chargeTransactionId = chargeTransactionId  
FROM tblOrder   
WHERE transactionId = @transactionId  
SET @chargeTransactionId = ISNULL(@chargeTransactionId , 0) 
IF(@productId IS NULL) 
 BEGIN  
  SELECT -1 , 'Error! No order transaction.'  
 END  
ELSE IF(@productId = 100)
 BEGIN  
  SELECT @chargeTransactionId , 1 AS checking  
 END  
ELSE 
 BEGIN  
  SELECT @chargeTransactionId , 2 AS checking , startDt , endDt  
  --FROM tblUserGameService   
  FROM tblUserGameServiceHistory   
--  WHERE userNumber = @userNumber  
WHERE transactionId = @transactionId
 END
GO
/****** Object:  StoredProcedure [dbo].[procGetUserSalesDetailForMobile]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserSalesDetailForMobile    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?		?? BY gun26
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserSalesDetailForMobile]
@chargeTransactionId		as			int
as
--DECLARE @chargeTransactionId as int
DECLARE @startDt as datetime
DECLARE @endDt as datetime
DECLARE @chargeTypeId as int
DECLARE @chargeTypeName as nvarchar(20)
DECLARE @tId as nvarchar(10)
DECLARE @phoneNumber as nvarchar(15)
-- SELECT * FROM tblTransaction WHERE transactionId = @transactionId
/*
SELECT 
	@chargeTransactionId = chargeTransactionId 
FROM 
	tblOrder  with (nolock) 
WHERE 
	transactionId = @transactionId
SELECT 
	@startDt = startDt, @endDt = endDt 
FROM 
	tblUserGameServiceHistory  with (nolock) 
WHERE 
	transactionId = @transactionId
-- ??? ?? / ? ??
*/
SELECT 
	@chargeTypeName = cct.descript, @chargeTypeId = c.chargeTypeId 
FROM 
	tblCharge c with (nolock), 
	tblCodeChargeType cct with (nolock) 
WHERE 
	transactionId = @chargeTransactionId AND 
	cct.chargeTypeId = c.chargeTypeId
-- SELECT * FROM tblChargeCardDeposit WHERE transactionId = @chargeTransactionId
SELECT 
	@tId = tId,
	@phoneNumber = phoneNumber
FROM 	
	tblChargeMobile with (nolock)
WHERE 
	transactionId = @chargeTransactionId
SELECT 
	@chargeTypeName,  @tId, @phoneNumber
GO
/****** Object:  StoredProcedure [dbo].[procGetUserSalesDetailForCashPpCard]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetUserSalesDetailForCashPpCard]  
@transactionId  as   int  
as  

DECLARE @startDt as datetime  
DECLARE @endDt as datetime  
DECLARE @chargeTypeId as int  
DECLARE @chargeTypeName as nvarchar(20)  
DECLARE @createDt as datetime  
DECLARE @ppCardId as nvarchar(20)  
DECLARE @ppCardGroupId as int  
DECLARE @ppCardSerialNumber as varchar(55)  

SELECT @chargeTypeName = cct.descript, @chargeTypeId = c.chargeTypeId   
FROM    tblCharge c with (nolock),   
 tblCodeChargeType cct with (nolock)   
WHERE	transactionId = @transactionId AND cct.chargeTypeId = c.chargeTypeId  

SELECT @ppCardId = ppCardId FROM tblPpCardUserInfoMapping WHERE transactionId = @transactionId  
SELECT @ppCardGroupId = ppCardGroupId, @ppCardSerialNumber = ppCardSerialNumber FROM tblPpCard WHERE ppCardId = @ppCardId  
SELECT @createDt = createDt FROM tblPpCardGroup WHERE ppCardGroupId = @ppCardGroupId  
SELECT @chargeTypeName, @ppCardSerialNumber, @createDt, @ppCardId, @transactionId
GO
/****** Object:  StoredProcedure [dbo].[procGetUserSalesDetailForCard]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetUserSalesDetailForCard    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserSalesDetailForCard]
@transactionId		as			int
as
DECLARE @billCruxTransactionId as int
DECLARE @cardNo as nvarchar(20)
DECLARE @chargeTypeId as tinyint
DECLARE @msgTypeCode as nchar(2)
DECLARE @cardIssuer as nvarchar(12)
DECLARE @approvalNo as nchar(8)
DECLARE @registDt as datetime
DECLARE @chargeTypeName as nvarchar(20)
declare @orderID int
declare @productName varchar(50)
declare @productPeriod int
declare @limitTime int


-- SELECT * FROM tblTransaction WHERE transactionId = @transactionId
-- SELECT @cardName = rtrim(LEFT(msg, 8)) FROM tblChargeCardDeposit WHERE transactionId =  @transactionId
-- SELECT * FROM tblChargeCardDeposit WHERE transactionId = @chargeTransactionId
SELECT 
	@chargeTypeName = cct.descript, @chargeTypeId = c.chargeTypeId  , @orderID=o.transactionid, @productName=productName, @productPeriod=isnull(productPeriod,0), @limitTime=isnull(limitTime,0)
FROM 
	tblCharge c with (nolock) join 	tblCodeChargeType cct with (nolock)  on cct.chargeTypeId = c.chargeTypeId
	join tblOrder o with(nolock)  on c.transactionId=o.chargeTransactionId
	join tblProduct p with(nolock) on p.productId=o.productId
WHERE 
	c.transactionId = @transactionId  
	
SELECT 

	@billCruxTransactionId =cc.transactionId, @msgTypeCode = nameOnCard , @cardNo = 'cCardNo', @cardIssuer = 'cardIssuer', @approvalNo = 'approvalNo', @registDt=registDt
FROM 
	tblChargeCardDeposit  cc  with (nolock) join tblTransaction t with(nolock) on t.transactionId=cc.transactionId
WHERE 
	cc.transactionId = @transactionId
SELECT 
	@chargeTypeName chargeType , @billCruxTransactionId, @cardIssuer, @msgTypeCode, @cardNo, @approvalNo, @registDt,
	  @productName as productName, @productPeriod as FixedTerm, @limitTime as FixedTime , startDt, endDt, limitTime, usedLimitTime
 from   tblUserGameServiceHistory  us with(nolock) 
where transactionId=@orderID
GO
/****** Object:  StoredProcedure [dbo].[procGetUserSalesDetailForAdminCharge]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserSalesDetailForAdminCharge    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?	
	modify by 		:	???
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserSalesDetailForAdminCharge]
@transactionId		as			int
as
DECLARE @chargeTypeId as int
DECLARE @chargeTypeName as nvarchar(20)
DECLARE @adminNumber as int
DECLARE @adminLogId as int
DECLARE @adminId as nvarchar(32)
-- SELECT * FROM tblTransaction WHERE transactionId = @transactionId
-- ??? ?? / ? ??
SELECT 
	@chargeTypeName = cct.descript, @chargeTypeId = c.chargeTypeId 
FROM 
	tblCharge c with (nolock), 
	tblCodeChargeType cct with (nolock) 
WHERE 
	cct.chargeTypeId = c.chargeTypeId AND 
	transactionId = @transactionId 
SELECT @adminLogId = adminLogId FROM tblTransaction WHERE transactionId = @transactionId
SELECT @adminNumber = adminNumber FROM tblAdminLog WHERE adminLogId = @adminLogId
SELECT @adminId = adminId FROM tblAdmin WHERE adminNumber = @adminNumber
SELECT 
	isNull(@chargeTypeName,'xxx'),  @adminId
GO
/****** Object:  StoredProcedure [dbo].[procGetUserSalesDetail]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetUserSalesDetail    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserSalesDetail]
@transactionId		as			int
as
SELECT 
	*
FROM 
	tblTransaction t with (nolock)
WHERE 
	t.transactionId = @transactionId
GO
/****** Object:  StoredProcedure [dbo].[procGetUserPurchaseTransaction_Test]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetUserPurchaseTransaction_Test]
	@userId		AS VARCHAR(32)
,	@cpId		AS INT -- ABS-CBN : 1
,	@startDt	AS DATETIME
,	@endDt		AS DATETIME
AS


SELECT T.transactionId , ABS(T.cashAmount) AS cashAmount , T.cashBalance, P.productName AS productName1, T.registDt, 
	T.peerTransactionId , O.productId , T.userNumber , C.cpName , 
	CASE transactionTypeId
		WHEN 11 THEN 
				CASE
				WHEN  A.description IS NULL THEN P.ProductName 
				ELSE 
					CASE O.productId
					WHEN 1089 THEN 'Bid Fee: ' + A.description 
					WHEN 1090 THEN 'Auction Final Fee: ' + A.description
					END
				END
		WHEN 12 THEN P.productName + ' ' +  W.description
		ELSE P.productName
	END AS productName
FROM tblTransaction T WITH (NOLOCK) 
JOIN tblUserInfo UI WITH (NOLOCK) ON T.userNumber = UI.userNumber 
JOIN tblOrder O WITH(NOLOCK) ON T.transactionId = O.transactionId 
JOIN tblProduct P WITH(NOLOCK) ON O.productId = P.productId 
JOIN tblCp C WITH (NOLOCK) ON T.cpId = C.cpId 
LEFT JOIN tblWebItemDescription W WITH(NOLOCK) ON T.transactionId = W.transactionId
LEFT JOIN tblAuctionDescription A WITH(NOLOCK) ON T.transactionId = A.transactionId
WHERE UI.cpId = @cpId AND T.userNumber NOT IN(SELECT userNumber FROM tblTestuser) 
	AND UI.userId = @userId AND T.registDt >= @startDt AND T.registDt < @endDt
ORDER BY T.transactionId DESC
GO
/****** Object:  StoredProcedure [dbo].[procGetUserPurchaseTransaction]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetUserPurchaseTransaction]
	@userId		AS VARCHAR(32)
,	@cpId		AS INT -- ABS-CBN : 1
,	@startDt	AS DATETIME
,	@endDt		AS DATETIME
AS


SELECT T.transactionId , ABS(T.cashAmount) AS cashAmount , T.cashBalance, P.productName AS productName1, T.registDt, 
	T.peerTransactionId , O.productId , T.userNumber , C.cpName , 
	CASE transactionTypeId
		WHEN 11 THEN 
				CASE
				WHEN  A.description IS NULL THEN P.ProductName 
				ELSE 
					CASE O.productId
					WHEN 1089 THEN 'Bid Fee: ' + A.description 
					WHEN 1090 THEN 'Auction Final Fee: ' + A.description
					END
				END
		WHEN 12 THEN 'Web Item:  ' +  W.description
		ELSE P.productName
	END AS productName
FROM tblTransaction T WITH (NOLOCK) 
JOIN tblUserInfo UI WITH (NOLOCK) ON T.userNumber = UI.userNumber 
JOIN tblOrder O WITH(NOLOCK) ON T.transactionId = O.transactionId 
JOIN tblProduct P WITH(NOLOCK) ON O.productId = P.productId 
JOIN tblCp C WITH (NOLOCK) ON T.cpId = C.cpId 
LEFT JOIN tblWebItemDescription W WITH(NOLOCK) ON T.transactionId = W.transactionId
LEFT JOIN tblAuctionDescription A WITH(NOLOCK) ON T.transactionId = A.transactionId
WHERE UI.cpId = @cpId AND T.userNumber NOT IN(SELECT userNumber FROM tblTestuser) 
	AND UI.userId = @userId AND T.registDt >= @startDt AND T.registDt < @endDt
ORDER BY T.transactionId DESC
GO
/****** Object:  StoredProcedure [dbo].[procGetUserNumberNAmount]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserNumberNAmount    Script Date: 23/1/2546 11:40:27 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procGetUserNumberNAmount
	Creation Date		:	2002-07-05
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	??? ??? ??? ?? ????
	
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserNumberNAmount]
	@userNumber		AS	INT	
,	@userId		AS	nvarchar(32)	OUTPUT
,	@cashBalance		AS	INT		OUTPUT
,	@pointBalance		AS	INT		OUTPUT
,	@availableCash		AS	INT		OUTPUT
AS
SELECT @userId = userId , @cashBalance = cashBalance , @pointBalance = pointBalance , @availableCash = cashBalance - holdCashBalance
FROM tblUserInfo WITH (NOLOCK) 
WHERE apply=1 AND userNumber = @userNumber
IF(@userId IS NULL)
	BEGIN
		SET @userNumber = -201
	END
GO
/****** Object:  StoredProcedure [dbo].[procGetUserNumber]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserNumber    Script Date: 23/1/2546 11:40:27 ******/
/*
	Creation Date		:	2002. 2. 08.
	Written by		:	? ??
	E-Mail by 		:	windist@n-cash.net
*/
CREATE PROCEDURE [dbo].[procGetUserNumber]
	@userId			as	nvarchar(32)
,	@cpId			as	int
,	@userNumber		as	int	output
as
--user check
SELECT @userNumber = userNumber FROM tblUserInfo with(nolock) Where apply=1 and userId = @userId and cpId = @cpId
IF @userNumber is null
	SET @userNumber = -201
GO
/****** Object:  StoredProcedure [dbo].[procGetUserInfo]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserInfo    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procGetUserInfo
	Creation Date		:	2002. 2. 24(???).
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	????? - ??? ??1
	Input Parameters :	
	@userNumber				as 	int		??? ?? - ?????? ??? ??
	@cpId					as	int		cpId - ???? cpId (???? ???? ??? ? ??? ???? ??)
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	/UserManager/userDetail.asp
	Calls		: 	Nothing
	Access Table 	: 	tblUserInfo (S), tblCp (S), tblCodeUserType (S), tblCodeUserStatus (S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserInfo]
@userNumber				as 	int		,
@cpId					as	int
as
SELECT 
	ui.userId, ui.userSurName, ui.userFirstName, ui.userPwd, gs.gameServiceName, ui.ssno, ui.sex, ui.birthday, 
	ui.isSolar, ui.zipcode, ui.nation, ui.address, ui.phoneNumber, ui.email, 
	ui.passwordCheckQuestionTypeId, ui.passwordCheckAnswer, ud.parentName, ud.parentSsno, ud.parentPhoneNumber, 
	ui.userNumber, ui.userTypeId, ui.userStatusId, ui.registDt, ui.apply,
	ud.handphoneNumber, ud.jobTypeId, ud.isSendEmail, ui.cashBalance, ui.pointBalance
	,ui.userKey,ui.state , ui.city, ui.MI
FROM 
	tblUserInfo ui with(rowlock), 
	tblCp c with (nolock), 
	tblUserDetail ud with (nolock),
	tblGameService gs with (nolock) 
WHERE 
	ui.userNumber = @userNumber
	AND ui.cpId = c.cpId
	AND ui.userNumber = ud.userNumber
	AND ui.cpId = @cpId 
	AND ui.gameServiceId = gs.gameServiceId
GO
/****** Object:  StoredProcedure [dbo].[procGetUserHistory]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetUserHistory    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserHistory]
@userNumber		as 	int,
@cpId			as	int
as
SELECT 
	uih.userInfoHistoryId, cut.descript, cus.descript, uih.apply, uih.updateDt, a.adminId, al.memo
--uih.cashBalance, uih.pointToCashBalance, uih.holdCashBalance, uih.pointBalance, 
FROM 
	tblUserInfoHistory uih with (nolock), 
	tblCodeUserStatus cus with (nolock), 
	tblCodeUserType cut with (nolock),
	tblAdminLog al with (nolock),
	tblAdmin a with (nolock)
WHERE 
	uih.userStatusId = cus.userStatusId 
	AND uih.userTypeId = cut.userTypeId 
	AND uih.adminLogId = al.adminLogId 
	AND al.adminNumber = a.adminNumber 
	AND uih.userNumber = @userNumber
ORDER BY 
	uih.updateDt desc
GO
/****** Object:  StoredProcedure [dbo].[procGetUserBalanceOnly]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetUserBalanceOnly]
	@userId	AS	nvarchar(64)	
AS

DECLARE @cashBalance	AS	INT
SELECT @cashBalance = cashBalance FROM tblUserInfo 
WHERE userId = @userId AND apply = 1
IF(@@ROWCOUNT = 0)
	SET @cashBalance = -1

SELECT @cashBalance AS cashBalance
GO
/****** Object:  StoredProcedure [dbo].[procGetUserBalance]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserBalance    Script Date: 23/1/2546 11:40:27 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procGetUserBalance
	Creation Date		:	2002-06-24
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	???? ?? ?? ????
******************************Optional Item******************************
	Input Parameters	:	
					@userId			AS		nvarchar(32)
					
	Output Parameters	:	
					@cashBalance			AS		INT		OUTPUT
					@pointToCashBalance		AS		INT		OUTPUT
					@holdCashBalance		AS		INT		OUTPUT
					@pointBalance			AS		INT		OUTPUT
					@userNumber			AS		INT		OUTPUT
					@returnCode			AS		TINYINT	OUTPUT			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetUserBalance]
	@userId			AS		nvarchar(200)
,	@cashBalance			AS		INT		OUTPUT
,	@pointToCashBalance		AS		INT		OUTPUT
,	@holdCashBalance		AS		INT		OUTPUT
,	@pointBalance			AS		INT		OUTPUT
,	@userNumber			AS		INT		OUTPUT
,	@returnCode			AS		TINYINT	OUTPUT
AS
SELECT @userNumber = userNumber , @cashBalance = cashBalance , @pointToCashBalance = pointToCashBalance , @holdCashBalance = holdCashBalance , @pointBalance = pointBalance
FROM tblUserInfo 
WHERE userId = @userId AND apply = 1
IF(@userNumber IS NULL)
	BEGIN
		SET @cashBalance = NULL
		SET @pointBalance = NULL
		SET @pointToCashBalance = NULL
		SET @holdCashBalance = NULL
		SET @userId = NULL
		SET @returnCode = 2
	END
ELSE
	BEGIN
		SET @returnCode = 1
	END
GO
/****** Object:  StoredProcedure [dbo].[procGetUserAuth]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetUserAuth    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procGetUserAuth
	Creation Date		:	2003. 01. 03
	Written by		:	???
	E-Mail by 		:	jjhl@n-cash.net
	Purpose			:	User??
	Input Parameters :	
		@cpId					as	int		
		@ppCardSerialNumber			as	nvarchar(20)		
		@returnCode				as	int		OUTPUT
	return?:
		@msg					as	nvarchar(64)	OUTPUT
	
*/
CREATE PROCEDURE [dbo].[procGetUserAuth]
	@cpId					as	int		
,	@userId				as	nvarchar(32)		
,	@userNumber				as	int		OUTPUT
,	@returnCode				as	int		OUTPUT
as

	SELECT @userNumber = userNumber  FROM tblUserInfo WHERE cpId = @cpId AND userId = @userId 
	IF @@ROWCOUNT = 0
		BEGIN
			SET @returnCode = 1	---???? ?? ??									
			RETURN
		END
	ELSE
	BEGIN
		SET @returnCode = 0
	END
	--SELECT  @userNumber, @returnCode
GO
/****** Object:  StoredProcedure [dbo].[procGetTransactionCodeList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetTransactionCodeList    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetTransactionCodeList
	Creation Date		:	2002. 2. 20.
	Written by		:	???
	E-Mail by 		:	jsh001@-cash.net
	Purpose			:	???? - ????
	Input Parameters 	:	
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetTransactionCodeList]
as
SELECT 
	transactionTypeId, descript, registDt
FROM 
	tblCodeTransactionType  with(nolock)
--	tblAdmin a with (nolock) 
--WHERE 
--	cus.adminNumber = a.adminNumber
GO
/****** Object:  StoredProcedure [dbo].[procGetTotalPpCardUsedYesNo]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetTotalPpCardUsedYesNo]
	@validEndDt	AS datetime
AS

SELECT
--	P.ppCardGroupId
	PR.productId
,	PR.productName
,	SUM(CASE WHEN PM.transactionId IS NOT NULL THEN 1 ELSE 0 END) AS used
,	SUM(CASE WHEN PM.transactionId IS NULL THEN 1 ELSE 0 END) AS unused
,	COUNT(*) AS total

FROM tblPpCard P WITH(NOLOCK)
JOIN tblPpCardGroup PG WITH(NOLOCK) ON P.ppCardGroupId = PG.ppCardGroupId
JOIN tblProduct PR WITH(NOLOCK) ON PG.productId = PR.productId
LEFT JOIN  tblPpCardUserInfoMapping PM WITH(NOLOCK) ON P.ppCardId = PM.ppCardId
WHERE PG.ppCardGroupId IN(
	SELECT ppCardGroupId FROM tblPpCardGroup WITH(NOLOCK)
	WHERE validEndDt < @validEndDt
--	WHERE validEndDt < '2006-9-1 00:00:00'
)

GROUP BY PR.productId, PR.productName
GO
/****** Object:  StoredProcedure [dbo].[procGetSoleAgencySalesList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetSoleAgencySalesList    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetSoleAgencySalesList]
@cpId		as	int,
@startDt	as	datetime,
@endDt	as	datetime
as
IF @startDt is null
	SET @startDt = getdate()
IF @endDt is null
	SET @endDt = '1900-01-01'
SELECT 
	transactionId , ctt.transactionTypeId, ctt.descript, u.userId, c.cpName, cashAmount, 
	pointToCashAmount, cashBalance, pointToCashBalance, pointBalance, t.registDt, 
	peerTransactionId
FROM 
	tblTransaction t with (nolock) , tblUser u with (nolock), tblCodeTransactionType ctt with (nolock), tblCp c with (nolock), tblAdmin a with (nolock)
WHERE 
	t.registDt BETWEEN @startDt AND @endDt
	AND t.transactionTypeId = ctt.transactionTypeId
	AND t.userNumber = u.userNumber
	AND t.cpId = c.cpId
GO
/****** Object:  StoredProcedure [dbo].[procGetRemainTime]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetRemainTime]
	@userId	AS	nvarchar(32)
,	@cpId		AS	int
,	@usedTime	AS	int		OUTPUT
,	@remainTime	AS	INT		OUTPUT
,	@expireDate	AS	DATETIME	OUTPUT
,	@result		as	INT		OUTPUT

AS
DECLARE @userNumber 	AS	INT

SELECT @userNumber =userNumber  from tblUserInfo WHERE userId=@userId and gameServiceId=@cpId

IF @userNumber is null
BEGIN
	SET @result = -501  --User Id does not exist.
	RETURN
END

IF NOT EXISTS (SELECT   *   FROM tblUserGameService where userNumber=@userNumber  AND  gameServiceId=@cpId )
BEGIN
	SET @result  = -503 -- Do Not Payment  /  
	RETURN
END


SELECT @usedTime=usedLimitTime,  @remainTime= limitTime - usedLimitTime  , @expireDate=expireDt  FROM tblUserGameService where userNumber=@userNumber and gameServiceId=@cpId 

IF @@ERROR  =0 
	BEGIN
		SET @result = 1 --Success
		--select  @usedTime,  @remainTime  , @expireDate
	END
ELSE
	BEGIN
		SET @result = -502	  --Stored procedure Error
		RETURN
	END
GO
/****** Object:  StoredProcedure [dbo].[procGetRemainDate]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetRemainDate]
	@userId	as	nvarchar(32)
,	@cpId		as	int
,	@startDate	as	smalldatetime	OUTPUT
,	@endDate	AS	smalldatetime	OUTPUT
,	@remainDate	as	int		OUTPUT
,	@remainDateToMinute	as	int	OUTPUT
,	@rtnValue			as	int		OUTPUT

AS
DECLARE @userNumber 	AS	INT

SELECT @userNumber =userNumber  from tblUserInfo WHERE userId=@userId and gameServiceId=@cpId

IF @userNumber is null
BEGIN
	SET @rtnValue = -501  --User Id does not exist.
	RETURN
END
 
IF NOT EXISTS (SELECT   *   FROM tblUserGameService where userNumber=@userNumber  AND  gameServiceId=@cpId )
BEGIN
	SET @rtnValue  = -503 -- Do Not Payment 
	RETURN
END


SELECT  @startDate=startDt , @endDate=endDt ,  @remainDate=DATEDIFF(dd, GETDATE(), endDt) ,  @remainDateToMinute= DATEDIFF(MINUTE, GETDATE(), endDt) FROM tblUserGameService where userNumber=@userNumber and gameServiceId=@cpId 
--SELECT  @startDate=startDt , @endDate=endDt , @remainDateToMinute= DATEDIFF(MINUTE, GETDATE(), endDt) FROM tblUserGameService where userNumber=@userNumber and gameServiceId=@cpId 
IF @@ERROR  =0 
	BEGIN
		SET @rtnValue = 1
	
	END
ELSE
	BEGIN
		SET @rtnValue = -502	  --Stored procedure Error
		RETURN
	END
GO
/****** Object:  StoredProcedure [dbo].[procGetProductPrice]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	name of create 	: goodfeel
	create date	: 2004. 6. 14
	last modify date	:

*/
CREATE PROCEDURE [dbo].[procGetProductPrice]
	@productId	as	int
,	@price		as	int	output
AS
	
	SET NOCOUNT ON

	SELECT @price = productAmount
	FROM tblProduct WITH (READUNCOMMITTED)
	WHERE productId = @productId
GO
/****** Object:  StoredProcedure [dbo].[procGetProductCodeList]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetProductCodeList    Script Date: 23/1/2546 11:40:24 ******/
/*
	Stored Procedure	:	procGetProductCodeList
	Creation Date		:	2002. 2. 20.
	Written by		:	???
	E-Mail by 		:	jsh001@n-cash.net
	Purpose			:	???? - ????
	Input Parameters 	:	
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetProductCodeList]
as
SELECT 
	productTypeId, descript, isGame, registDt, apply
FROM 
	tblCodeProductType  with(nolock)
--	tblAdmin a with (nolock) 
--WHERE 
--	cus.adminNumber = a.adminNumber
GO
/****** Object:  StoredProcedure [dbo].[procGetProductAmount]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procGetProductAmount    Script Date: 23/1/2546 11:40:26 ******/
/*
	Creation Date		:	2002. 2. 08.
	Written by		:	? ??
	E-Mail by 		:	windist@n-cash.net
*/
CREATE PROCEDURE [dbo].[procGetProductAmount]
	@productId		as	int
,	@productAmount	as	int	output
as
--user check
SELECT @productAmount = productAmount FROM tblProduct with(nolock) Where apply=1 and productId = @productId
IF @productAmount is null
	SET @productAmount = -203
GO
/****** Object:  StoredProcedure [dbo].[procGetProduct]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procGetProduct    Script Date: 23/1/2546 11:40:26 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 2. 7.
	Written by		:	? ?
	E-Mail by 		:	4jin@n-cash.net
	Purpose			:	???? - ????
	Input Parameters :	
	@startDt		as			datetime,		???
	@endDt		as			datetime,		???
	@adminNumber 		as			int			???
			
	return?:
		????
	Return Status:		
	Nothing
	Usage: 			
	EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procGetProduct]
	@isGame 		as	bit
as
IF @isGame=1
	BEGIN
/*
		SELECT 
			p.productId, p.productName, p.productAmount, p.productPeriod, cpt.descript
		FROM 
			tblCodeProductType cptt with (nolock)
			RIGHT OUTER JOIN 
			tblProduct p with (nolock) ON cptt.productTypeId = p.productTypeId
			 LEFT OUTER JOIN tblCodePeriodType cpt with (nolock) 
		ON 
			p.periodTypeId = cpt.periodTypeId 
		WHERE 
			p.apply = 1 AND 
			cptt.isGamebangProduct = 0 AND 
			p.productTypeId = 2
*/
-- ??? ?? - 2? 26?
		SELECT 
			p.productId, p.productName, p.productAmount, p.productPeriod, cpt.descript
		FROM 
			tblCodeProductType cptt with (nolock), 
			tblProduct p with (nolock) ,
			tblCodePeriodType cpt with (nolock) 
		WHERE 
			p.apply = 1 AND 
			p.periodTypeId = cpt.periodTypeId AND
			cptt.productTypeId = p.productTypeId AND
			cptt.isGamebangProduct = 0
/*
		SELECT 
			p.productId, p.productName, p.productAmount, p.productPeriod, cpt.descript
		FROM 
			tblProduct p with (nolock), 
			tblCodePeriodType cpt with (nolock)
		WHERE 
			p.periodTypeId = cpt.periodTypeId AND
			p.apply = 1 AND 
			productTypeId = 2
*/
	END
ELSE
	BEGIN
		SELECT 
			p.productId, p.productName, p.productAmount
		FROM 
			tblProduct p with (nolock)		,
			tblCodeProductType cpt with (nolock)
		WHERE 
			p.productTypeId = cpt.productTypeId AND
			p.apply = 1 AND 
			cpt.isGamebangProduct = 0 AND 
			cpt.isGame = 0
	END
GO
/****** Object:  StoredProcedure [dbo].[procGetPpcardInfoTantra]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	Stored Procedure	:	procGetPpcardInfo
	Creation Date		:	2002. 12. 26
	Written by		:	???
	E-Mail by 		:	iBeliveKim@n-cash.net
	Purpose			:	ppcard ?? ????
	Input Parameters :	
		@ppCardSerialNumber			as	varchar(20)		
		@ppcardId				as	int		OUTPUT
		@howManyPeople			as	int		OUTPUT
			
	return?:
		@msg					as	varchar(64)	OUTPUT
	
*/
CREATE PROCEDURE [dbo].[procGetPpcardInfoTantra]
	@ppCardSerialNumber			as	nvarchar(32)
,	@productAmount			as	int		OUTPUT
,	@ppCardType				as	int		OUTPUT
,	@productId				as	int		OUTPUT

as

DECLARE	@tValidStartDt			as	smalldatetime
DECLARE	@tValidEndDt			as	smalldatetime
DECLARE	@tDt				as	smalldatetime
DECLARE	@lastDt				as	smalldatetime
DECLARE	@rowCount			as	int
DECLARE	@periodType			as	int
DECLARE 	@ppCardId			AS 	INT

	SET @tDt = getdate()
	SET @lastDt = DATEADD (dd , -1, @tDt) 
	
	SELECT  
		@tValidStartDt = pcg.validStartDt, 
		@tValidEndDt = pcg.validEndDt, 
		@productId = pcg.productId, 
		@productAmount = p.productAmount  ,
		@ppCardId = pc.ppCardId
	FROM tblPpCardForTantra pc, tblPpCardGroup pcg, tblProduct p 
	WHERE pc.ppCardSerialNumber = @ppCardSerialNumber AND pc.ppCardGroupId = pcg.ppCardGroupId 
		AND pcg.productId = p.productId AND pcg.apply = 1

	IF @@ROWCOUNT = 0
	BEGIN
		SET @ppCardType  = -100
		RETURN  --ADD								
	END	

	SELECT ppCardId FROM tblPpCardUserInfoMapping WHERE   ppCardId= @ppCardId
	IF @@ROWCOUNT > 0
	BEGIN
		SET @ppCardType = -102		-- ???? ?????? ????
		RETURN
	END

	IF (@tValidEndDt < @tDt OR @tValidStartDt > @tDt) 
	BEGIN		
		SET @ppCardType = -104		--  ???? ?????? ???? ????
		RETURN
	END
	
	SELECT @periodType = ISNULL(periodTypeId, 0) FROM tblProduct where productId=@productId
	IF @periodType  = 0 
	BEGIN
		SET @ppCardType = 2
		RETURN
	END
	ELSE
	BEGIN
		SET @ppCardType = 1
	END
GO
/****** Object:  StoredProcedure [dbo].[procGetPpcardInfoOld]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Stored Procedure	:	procGetPpcardInfo
	Creation Date		:	2002. 12. 26
	Written by		:	???
	E-Mail by 		:	jjhl@n-cash.net
	Purpose			:	ppcard ?? ????
	Input Parameters :	
		@ppCardSerialNumber			as	varchar(20)		
		@ppcardId				as	int		OUTPUT
		@howManyPeople			as	int		OUTPUT
			
	return?:
		@msg					as	varchar(64)	OUTPUT
	
*/
CREATE PROCEDURE [dbo].[procGetPpcardInfoOld]
	@gameServiceId			as	smallint
,	@userId				as	nvarchar(32)		
,	@ppCardSerialNumber			as	nvarchar(32)		
,	@ppcardId				as	int		OUTPUT
,	@howManyPeople			as	int		OUTPUT
,	@productId				as	int		OUTPUT
,	@productAmount			as	int		OUTPUT
,	@returnCode				as	int		OUTPUT
as

DECLARE	@userNumber			as	int
DECLARE	@tValidStartDt			as	smalldatetime
DECLARE	@tValidEndDt			as	smalldatetime
DECLARE	@tDt				as	smalldatetime
DECLARE	@lastDt				as	smalldatetime
DECLARE	@rowCount			as	int

	SELECT @userNumber = userNumber FROM tblUserInfo WITH (NOLOCK) WHERE userId = @userId and gameServiceId = @gameServiceid

	SET @returnCode = 0
	SET @tDt = getdate()
	SET @lastDt = DATEADD (dd , -1, @tDt) 
	
	SELECT @ppcardId = pc.ppCardId, @howManyPeople= pcg.howManyPeople, @tValidStartDt = pcg.validStartDt, 
		@tValidEndDt = pcg.validEndDt, @productId = pcg.productId, @productAmount = p.productAmount 
	FROM tblPpCard pc, tblPpCardGroup pcg, tblProduct p 
	WHERE pc.ppCardSerialNumber = @ppCardSerialNumber AND pc.ppCardGroupId = pcg.ppCardGroupId 
		AND pcg.productId = p.productId AND pcg.apply = 1

	IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt)
			VALUES (@userNumber, @ppCardSerialNumber, getdate()) 			
		
			SET @returnCode = 1										
		END

	SELECT ppCardId FROM tblPpCardUserInfoMapping WHERE @ppcardId = ppCardId
	IF @@ROWCOUNT > 0
		BEGIN
			INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt)
			VALUES (@userNumber, @ppCardSerialNumber, getdate()) 	

			SET @returnCode = 3		
		END

	IF (@tValidEndDt < @tDt OR @tValidStartDt > @tDt) 
		BEGIN
			INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt)
			VALUES (@userNumber, @ppCardSerialNumber, getdate()) 	
		
			SET @returnCode = 2		
		END

	SELECT num FROM tblPpCardFailList WHERE userNumber = @userNumber  AND registDt BETWEEN @lastDt AND @tDt
	SET @rowCount = @@ROWCOUNT			
	IF  @rowCount > 4 
		BEGIN
			INSERT INTO tblPpCardInjusticeList (userNumber, registDt)
			VALUES (@userNumber, getdate()) 			
			UPDATE tblUser
			SET userStatusId = 5
			WHERE userNumber = @userNumber
			UPDATE tblUserInfo
			SET userStatusId = 5
			WHERE userNumber = @userNumber
	
			EXEC procInsertUserHistory @userNumber			
		END

	SELECT @ppcardId, @howManyPeople, @productId, @productAmount, @returnCode
	RETURN
GO
/****** Object:  StoredProcedure [dbo].[procEmailConfirmUser]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
iBeliveKim@n-cash.net
2004.12.21
User to email check  userStatusid update
*/

CREATE PROCEDURE [dbo].[procEmailConfirmUser]
	@userId				as	nvarchar(50)
,	@result				as	int		output

AS
BEGIN TRAN
	DECLARE @userNumber  as 	int
	SELECT @userNumber = userNumber FROM tblUserInfo with (nolock) WHERE userStatusId=9 and userId = @userId
	
	IF @userNumber  IS NULL
	BEGIN
		SET	@result = 0
		ROLLBACK
		RETURN
	END

	UPDATE tblUser	SET userStatusId=1	WHERE userId = @userId and gameServiceId=1 AND userStatusId=9
	IF @@ROWCOUNT = 0 
	BEGIN
		SET	@result = 0
		ROLLBACK
		RETURN	
	END	

	
	
	UPDATE tblUserInfo	SET userStatusId=1	WHERE userId = @userId and gameServiceId=1 AND userStatusId=9
	IF @@ROWCOUNT = 0 
	BEGIN
		SET	@result = 0
		ROLLBACK
		RETURN	
	END

	EXEC procInsertUserHistory @userNumber

	IF @@ERROR <> 0 
		BEGIN
			 ROLLBACK
			 SET @result = 0
			 RETURN
		END
	ELSE
		BEGIN
			COMMIT
			SET @result = 1
		END
GO
/****** Object:  StoredProcedure [dbo].[procDeleteGamebang]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteGamebang    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procDeleteGamebang
	Creation Date		:	2002. 02.15
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	??? ??
	
	Input Parameters :	
				@gamebangId			AS		SMALLINT
				@memo				AS		nvarchar(200)
				@adminNumber			AS		INT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ?????.
				2: ?? apply? 0?? ?? ??.
	Usage: 			
	EXEC procDeleteGamebang  1,,'????',1, @returnCode OUTPUT
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblGamebang(S,U) , tblAdminLog(I) , tblGamebangHistory(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeleteGamebang] 
	@gamebangId			AS		INT
,	@memo				AS		nvarchar(200)
,	@adminNumber			AS		INT					= NULL
,	@returnCode			AS		TINYINT	OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
IF((SELECT apply FROM tblGamebang WHERE gamebangId = @gamebangId) = '0')
	BEGIN
		SET @returnCode = 2
	END
ELSE
	BEGIN
		--tblGamebang? ????.
		UPDATE tblGamebang 
		SET apply = 0
		WHERE gamebangId = @gamebangId
		
		--tblAdminLog? ???
		INSERT INTO tblAdminLog 
			VALUES(
				'Delete'
			,	'tblGamebang'
			,	@adminNumber
			,	@memo
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY	
	
		--tblGamebangHistory? ???.
		EXEC procInsertGamebangHistory @gamebangId, @adminLogId
		EXEC procDeleteChongphanGamebang @gamebangId ,  @memo , @adminNumber
		EXEC procDeleteIpAddrs @gamebangId , @adminNumber						--??? ?? ??? ?? ??
		
		--???? ????.
		UPDATE tblUser SET userStatusId = 3 , apply = 0 WHERE cpId = @gamebangId
		UPDATE tblUserInfo SET userStatusId = 3 ,  apply = 0 WHERE cpId = @gamebangId
		SET @returnCode = 1
	END
GO
/****** Object:  StoredProcedure [dbo].[procChargeForRewardByAdmin]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procChargeForRewardByAdmin]
	@userId		AS nvarchar(52)
,	@cashAmount	AS int
,	@cpId 		AS int		-- ABS-CBN : 1
,	@userNumber	AS int	output
,	@cashBalance	AS int	output
,	@transactionId	AS int	output

AS

DECLARE
	@adminLogId		as int	
,	@chargeTypeId		as int
--,	@userNumber		as int
,	@chargeTransactionId	as int


SET @chargeTypeId = 20	-- gived cash-reward  by Manager

SELECT @userNumber = userNumber FROM tblUserInfo UI WITH(NOLOCK)
WHERE userId = @userId AND apply = 1

IF @userNumber IS NULL
BEGIN
	SET @transactionId = -1
	RETURN
END


EXEC procInsertAdminLog
	'Regi'		--@adminActionType	as	nchar(4)
,	'tblTransaction'	--@adminActionTable	as	nvarchar(100)
,	0		--@adminNumber		as	int
,	'Manager Charge'--@memo			as	nvarchar(200)
,	@adminLogId	output

IF @@ERROR <> 0
BEGIN
	SET @transactionId = -2
	RETURN
END

EXEC procCharge @chargeTypeId, @userNumber, @cpId, @cashAmount, @adminLogId,  @chargeTransactionId OUTPUT
IF @@ERROR <> 0 OR @chargeTransactionId < 0
BEGIN
	SET @transactionId = -3
	RETURN
END
ELSE
	SET @transactionId = @chargeTransactionId

SELECT @cashBalance = cashBalance FROM tblUserInfo WITH(NOLOCK)
WHERE userNumber = @userNumber
GO
/****** Object:  StoredProcedure [dbo].[procDeleteChongphan]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procDeleteChongphan    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procDeleteChongphan
	Creation Date		:	2002. 02.17
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	?? ??
	
	Input Parameters :	
				@gamebangId			AS		SMALLINT
				@memo				AS		nvarchar(200)
				@adminNumber			AS		INT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ??(??)???.
				2: ?? apply? 0?? ?? ??.
				3: ???????? ???? ????? ??? ????.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procDeleteChongphan]
	@chongphanId			AS		INT
,	@memo				AS		nvarchar(200)
,	@adminNumber			AS		INT
,	@returnCode			AS		TINYINT	OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
IF((SELECT apply FROM tblChongphan WHERE chongphanId = @chongphanId) = '0')
	BEGIN
		SET @returnCode = 2
	END
ELSE IF((SELECT COUNT(*) FROM tblChongphanGamebang WHERE chongphanId = @chongphanId) > 0)
	BEGIN
		SET @returnCode = 3
	END
ELSE
	BEGIN
		--tblGamebang? ????.
		UPDATE tblChongphan 
		SET apply = 0
		WHERE chongphanId = @chongphanId
		
		--tblAdminLog? ???
		INSERT INTO tblAdminLog 
			VALUES(
				'Delete'
			,	'tblChongphan'
			,	@adminNumber
			,	@memo
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY	
	
		--tblGamebangHistory? ???.
		INSERT INTO tblChongphanHistory 
			SELECT chongphanId , chongphanName , bizNumber , address , zipcode , phoneNumber , presidentName , commission , bondDate, expiryDate, apply , GETDATE() , @adminLogId 
			FROM tblChongphan 
			WHERE chongphanId = @chongphanId
	EXEC procDeleteCpChongphan @chongphanId , @memo , @adminNumber
		SET @returnCode = 1
	END
GO
/****** Object:  StoredProcedure [dbo].[expirydate6_sp]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE   PROCEDURE [dbo].[expirydate6_sp] 

@userid as varchar(50), @month1 as varchar(50)
, @month2 varchar(50)
AS

select registdt,CASHBALANCE, 
EXPIRYDATE=
case
        when cashbalance = 350 then dateadd(day,30,registdt) 
        when cashbalance = 100 then dateadd(day,7,registdt) 
	when cashbalance = 50 then dateadd(MINUTE,480,registdt) 
	when cashbalance = 30 then dateadd(MINUTE,240,registdt) 
	when cashbalance = 20 then dateadd(MINUTE,120,registdt) 
	when cashbalance = 10 then dateadd(MINUTE,60,registdt) 
    end
from trnsumuser_view
where userid=@userid and cashbalance > 0 

and registdt between @month1 and @month2 
order by registdt desc
GO
/****** Object:  StoredProcedure [dbo].[expirydate5_sp]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE [dbo].[expirydate5_sp] 

@userid as varchar(50),@d as varchar(20)

AS

select REGISTDT,CASHBALANCE, 
EXPIRYDATE=
case
        when cashbalance = 350 then dateadd(day,30,registdt) 
        when cashbalance = 100 then dateadd(day,7,registdt) 
	when cashbalance = 50 then dateadd(MINUTE,480,registdt) 
	when cashbalance = 30 then dateadd(MINUTE,240,registdt) 
	when cashbalance = 20 then dateadd(MINUTE,120,registdt) 
	when cashbalance = 10 then dateadd(MINUTE,60,registdt) 
    end
from trnsumuser_view
where userid=@userid and cashbalance > 0 AND REGISTDT > GETDATE() - cast(@d as int) order by registdt desc
GO
/****** Object:  StoredProcedure [dbo].[expirydate3_sp]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE     PROCEDURE [dbo].[expirydate3_sp] 
@userid varchar(50)
 AS

select registdt,cashbalance,expirydate =
    case
        when cashbalance = 350 then dateadd(day,30,registdt) 
        when cashbalance = 100 then dateadd(day,7,registdt) 
	when cashbalance = 50 then dateadd(minute,480,registdt) 
	when cashbalance = 30 then dateadd(minute,240,registdt) 
	when cashbalance = 20 then dateadd(minute,120,registdt) 
	when cashbalance = 10 then dateadd(minute,60,registdt) 
    end


from trnsumuser_view
where userid=@userid  and cashbalance > 0 order by registdt desc
GO
/****** Object:  StoredProcedure [dbo].[expirydate2_sp]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE       PROCEDURE [dbo].[expirydate2_sp] 
@userid varchar(50)
 AS

select top 1 *,expirydate =
    case
        when cashbalance = 350 then dateadd(day,30,registdt) 
        when cashbalance = 100 then dateadd(day,7,registdt) 
	when cashbalance = 50 then dateadd(minute,480,registdt) 
	when cashbalance = 30 then dateadd(minute,240,registdt) 
	when cashbalance = 20 then dateadd(minute,120,registdt) 
	when cashbalance = 10 then dateadd(minute,60,registdt) 
    end
,totl=
   case
        when cashbalance = 350 then datediff(day,getdate(),dateadd(day,30,registdt))
	when cashbalance = 100 then datediff(day,getdate(),dateadd(day,7,registdt))
	when cashbalance = 50 then datediff(minute,getdate(),dateadd(minute,480,registdt))   
	when cashbalance = 30 then datediff(minute,getdate(),dateadd(minute,240,registdt)) 
	when cashbalance = 20 then datediff(minute,getdate(),dateadd(minute,120,registdt)) 
	when cashbalance = 10 then datediff(minute,getdate(),dateadd(minute,60,registdt)) 
         
    end
,type=
case
        when cashbalance = 350 then 'day'
when cashbalance = 100 then  'day'
when cashbalance = 50 then 'minute'   
when cashbalance = 30 then 'minute'
when cashbalance = 20 then 'minute'
when cashbalance = 10 then 'minute'
         
    end
from trnsumuser_view
where userid=@userid  and cashbalance > 0 order by registdt desc
GO
/****** Object:  StoredProcedure [dbo].[expirydate1_sp]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE     PROCEDURE [dbo].[expirydate1_sp] 
@userid varchar(50)
 AS

select
totl=
  SUM( case
        when cashbalance = 350 AND datediff(day,getdate(),dateadd(day,30,registdt)) > 0
	THEN datediff(day,getdate(),dateadd(day,30,registdt))
	when cashbalance = 100 AND datediff(day,getdate(),dateadd(day,7,registdt)) > 0
	THEN datediff(day,getdate(),dateadd(day,7,registdt)) 
	when cashbalance = 50 AND  datediff(minute,getdate(),dateadd(minute,600,registdt)) > 0
	THEN  datediff(minute,getdate(),dateadd(minute,600,registdt)) 
	when cashbalance = 30 AND datediff(minute,getdate(),dateadd(minute,300,registdt)) > 0
	THEN Datediff(minute,getdate(),dateadd(minute,300,registdt))
	when cashbalance = 20 AND datediff(minute,getdate(),dateadd(minute,120,registdt)) > 0
	THEN datediff(minute,getdate(),dateadd(minute,120,registdt))
	when cashbalance = 10 AND  datediff(minute,getdate(),dateadd(minute,60,registdt)) > 0
	THEN datediff(minute,getdate(),dateadd(minute,60,registdt))
	ELSE 0 
         
    end)

from trnsumuser_view
where userid=@userid  and cashbalance > 0
GO
/****** Object:  StoredProcedure [dbo].[expirydate_sp]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE      PROCEDURE [dbo].[expirydate_sp] 
@userid varchar(50)
 AS

select *,expirydate =
    case
        when cashbalance = 350 then dateadd(day,30,registdt) 
        when cashbalance = 100 then dateadd(day,7,registdt) 
	when cashbalance = 50 then dateadd(minute,480,registdt) 
	when cashbalance = 30 then dateadd(minute,240,registdt) 
	when cashbalance = 20 then dateadd(minute,120,registdt) 
	when cashbalance = 10 then dateadd(minute,60,registdt) 
    end
,totl=
   case
        when cashbalance = 350 then datediff(day,getdate(),dateadd(day,30,registdt))
	when cashbalance = 100 then datediff(day,getdate(),dateadd(day,7,registdt))
	when cashbalance = 50 then datediff(minute,getdate(),dateadd(minute,480,registdt))   
	when cashbalance = 30 then datediff(minute,getdate(),dateadd(minute,240,registdt)) 
	when cashbalance = 20 then datediff(minute,getdate(),dateadd(minute,120,registdt)) 
	when cashbalance = 10 then datediff(minute,getdate(),dateadd(minute,60,registdt)) 
         
    end
,type=
case
        when cashbalance = 350 then 'day'
when cashbalance = 100 then  'day'
when cashbalance = 50 then 'minute'   
when cashbalance = 30 then 'minute'
when cashbalance = 20 then 'minute'
when cashbalance = 10 then 'minute'
         
    end
from trnsumuser_view
where userid=@userid  and cashbalance > 0 order by registdt desc
GO
/****** Object:  StoredProcedure [dbo].[eventForUnTopupedUser]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[eventForUnTopupedUser]
	@userId		as varchar(52)
--,	@userEventId	as int		-- Event For Untopuped user from April 2006 to now
,	@result		as int		output	
AS

DECLARE
	@userNumber	as int
,	@userEventId	as int
,	@startDt	as datetime
,	@transactionId	as int
,	@cashBalance	as int
,	@count		as int

SELECT @userNumber = userNumber, @cashBalance = cashBalance FROM tblUserInfo WITH(NOLOCK)
WHERE userId = @userId

IF @userNumber IS NULL
BEGIN
	SET @result = -1 -- Inexistent userId
	RETURN
END

SET @userEventId = 1 -- For untopuped user since April 2006

SELECT @count = COUNT(*) FROM tblUserEventApply WITH(NOLOCK)
WHERE userNumber = @userNumber AND userEventId = @userEventId AND apply = 1

IF @count > 0
BEGIN
	SET @result = -2 -- Already applied userId
	RETURN
END


-- FIXED
SET @startDt = '2006-04-30 23:59:59'

SELECT TOP 1 @transactionId = T.transactionId FROM tblCharge C WITH(NOLOCK)
JOIN tblTransaction T WITH(NOLOCK) ON C.transactionId = T.transactionId
WHERE T.userNumber = @userNumber AND T.registDt >= @startDt AND T.transactionTypeId = 1 
AND C.chargeTypeId <> 16
AND T.TransactionId IS NOT NULL

IF @transactionId IS NOT NULL
BEGIN
	SET @result = -3 -- Topuped userId after April 2006
	RETURN
END

BEGIN TRAN
UPDATE tblUserInfo SET cashBalance = @cashBalance + 50 WHERE userNumber = @userNumber

IF @@ROWCOUNT = 0 OR @@ERROR <> 0
BEGIN
	SET @result = -4 -- cashBalance update error
	ROLLBACK TRAN
	RETURN
END

EXEC procInsertUserHistory @userNumber

INSERT INTO tblUserEventApply(userEventId, userNumber)
VALUES(@userEventId, @userNumber)

IF @@ERROR <> 0
BEGIN
	SET @result = -5 -- Insert Failed 
	ROLLBACK TRAN
	RETURN
END

SET @transactionId = NULL
EXEC procOrder @userNumber, 1, 1, 1080, NULL, NULL, NULL, NULL, NULL, NULL, @transactionId OUTPUT
IF @transactionId IS NULL OR @@ERROR <> 0
BEGIN
	SET @result = -6 -- Order failed
	ROLLBACK TRAN
	RETURN
END
ELSE
BEGIN
	SET @result = 1
	COMMIT TRAN
END
GO
/****** Object:  StoredProcedure [dbo].[checkGameTime]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- sp that checks for a certain user's game time
-- created by: albin
-- 12/02/2005
CREATE PROCEDURE [dbo].[checkGameTime]

@UserId VARCHAR(50)

AS
SELECT userId,remainDays,(remainDate+remainTime)-(remainDays*1440) AS remainMinutes,remainTime, endDate FROM(
SELECT userId,remainDate,remainTime,(remainDate + remainTime)/1440 AS remainDays,endDate FROM(
SELECT DISTINCT CASE tblUserGameService.userNumber WHEN '' THEN '' ELSE trnsumuser_view.userId END as UserID, COALESCE(DATEDIFF(minute,GETDATE(),endDt),0) AS remainDate, (limitTime-usedLimitTime) AS remainTime, COALESCE(endDt,'01/01/1900') AS endDate
FROM tblUserGameService
INNER JOIN trnsumuser_view ON trnsumuser_view.userNumber = tblUserGameService.userNumber
WHERE trnsumuser_view.userId = @UserId AND tblUserGameService.gameServiceId = 1)Table1)Table2
GO
/****** Object:  StoredProcedure [dbo].[procReserveCheck2]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procReserveCheck2    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procReserveCheck 
	Creation Date		:	2002. 02.17
	Written by		:	? ??
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	????? ??? ????
	
	Input Parameters :	
				@gamebangId			AS		SMALLINT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ???? ??? ?? ??? ,?? ??? ? ? ??.
				2: ???? ??? ??? ???? ???????(?? ??? ??) ?? ??? ???? ???.
				3: ???? ??? ??? ???? ???? ???(????) ??? ??? ? ??.
				4 : ?? ??? ???? ??? ?????.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procReserveCheck2] 
	@gamebangId			AS		INT
,	@returnCode			AS		TINYINT	OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@maxTransactionId		AS		INT
DECLARE	@minTransactionId		AS		INT
DECLARE	@reserveReturnCode		AS		TINYINT
------------------------?? ???--------------------
EXEC procReserveCheck @gamebangId , @reserveReturnCode OUTPUT
IF(@reserveReturnCode = 3)
	BEGIN	
		SET @returnCode = 4		--?? ??? ???? ??? ?????.
	END
ELSE
	BEGIN
		SELECT @maxTransactionId = MAX(GGSH.transactionId)
		FROM tblGamebangGameServiceHistory AS GGSH INNER JOIN tblTransaction AS T ON GGSH.transactionId = T.transactionId 
		JOIN tblOrder O ON T.transactionId = O.transactionId 
		JOIN tblProduct P ON O.productId = P.productId
		WHERE T.peerTransactionId IS NULL AND GGSH.gamebangId = @gamebangId AND P.productPeriod IS NOT NULL
		
		IF(@maxTransactionId IS NULL)
			BEGIN
				--??? ?? ??? ,?? ??? ????.
				SET @returnCode = 1
			END
		ELSE
			BEGIN
				IF((SELECT endDt FROM tblGamebangGameServiceHistory WHERE transactionId = @maxTransactionId) < GETDATE()) 
					BEGIN
						SET @returnCode = 2		--???? ??? ?? ??? ,?? ??? ????.
					END
				ELSE
					BEGIN
						SET @returnCode = 3		--???? ??? ??? ???? ???????(?? ??? ??) ?? ??? ???? ???.				
					END
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertUserTest]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procInsertUserTest]
	@userId				as	nvarchar(50)		
,	@cpId					as	int			
,	@password				as	nvarchar(70)		
,	@userSurName				as	nvarchar(64)	
,	@MI					as	nvarchar(1)
,	@userFirstName				as	nvarchar(64)
,	@userKey				as	nvarchar(7)
,	@sex					as	int	
,	@birthday				as	nvarchar(16)		
,	@address				as	nvarchar(64)			
,	@phoneNumber			as	nvarchar(16)	
,	@email					as	nvarchar(64)	
,	@nation				as	nvarchar(64)	
,	@city					as	nvarchar(64)	
,	@state					as	nvarchar(64)	
,	@passwordCheckQuestionTypeId	as	nvarchar(64)
,	@passwordCheckAnswer		as	nvarchar(64)	
,	@handPhoneNumber			as	nvarchar(64)
,	@jobTypeId				as	nvarchar(64)
,	@getMail				as 	bit
,	@gameServiceId			as	smallint	
--,	@placeToPlay				as 	nvarchar(40)
--,	@internetConnection			as	nvarchar(30)
,	@userNumber				as	int		OUTPUT
,	@msg					as	nvarchar(64)	OUTPUT
as


	SELECT userId FROM tblUserInfo with (nolock) WHERE userId = @userId AND userStatusId <> 3
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg = 'overlapping ID.' --'??? ??????.'
		SET @userNumber = -1
		RETURN 1
	END
	SELECT rejectWord
	FROM tblRejectWord with (nolock)
	WHERE UPPER(rejectWord) = UPPER(@userId)
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg = 'unusable ID.' --'??? ? ?? ??????.'
		SET @userNumber = -1
		RETURN 1
	END
	INSERT INTO 
		tblUser (userId, userPwd, cpId, gameServiceId)
	VALUES
		(@userId, @password, @cpId, @gameServiceId) 
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:001' -- '????? ?? ???. ErrorCode:001'
		SET @userNumber = -1
		RETURN 1
	END
	SET @userNumber = @@IDENTITY
	IF @sex = 2
		SET @sex = 0
			
	INSERT INTO tblUserInfo (userNumber, userId, userPwd, cpId, userSurName, userFirstName, gameServiceId, ssno, 
		sex, birthday, isSolar, email, zipcode, nation, address, phoneNumber, 
		passwordCheckQuestionTypeId, passwordCheckAnswer , MI, userKey, city, state )
	VALUES 
		(@userNumber				,			-- ??? ??
		@userId				,			-- ID
		@password				,			-- password
		@cpId					,			-- cpId
		@userSurName				,			-- userName(?)
		@userFirstName				,			-- userName(??)
		@gameServiceId			,			-- ?? gameServiceId
		null					,			-- ??????
		@sex					,			-- ??
		CONVERT(smalldatetime, @birthday)	,			-- ????
		1				,			-- ? / ?
		@email					,			-- E-mail
		null				,			-- ????
		@nation				,			-- ?
		@address				,			-- ????
		@phoneNumber				,			-- ????
		@passwordCheckQuestionTypeId	,			-- ???? ?? ??
		@passwordCheckAnswer		,		-- ???? ?? ??
		@MI					,
		@userKey				,
		@city					,
		@state					
		)
	IF @@ERROR <> 0
	BEGIN

		select @userNumber, @userId	, @password	, @cpId	, @userSurName, @userFirstName , @gameServiceId	, null, @sex , CONVERT(smalldatetime, @birthday)	,1	, @email	, null	, @nation	, @address, @phoneNumber	, @passwordCheckQuestionTypeId	,@passwordCheckAnswer		,@MI	 , @userKey	, @city		, @state	
		SET @msg = 'Please, contact us. ErrorCode:002' --'????? ?? ???. ErrorCode:002'
		SET @userNumber = -1	
	
		RETURN 1
	END
	EXEC procInsertUserHistory @userNumber
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:003' -- '????? ?? ???. ErrorCode:003'
		SET @userNumber = -1
		RETURN 1
	END
	--INSERT INTO tblUserDetail (userNumber, handphoneNumber, jobTypeId, isSendEmail)
	--VALUES (@userNumber, @handPhoneNumber, @jobTypeId, @getMail)
	INSERT INTO tblUserDetail (userNumber, handphoneNumber, jobTypeId, isSendEmail ,placeToPlay, internetConnection)
	VALUES (@userNumber, @handPhoneNumber, @jobTypeId, @getMail , null, null )
	--VALUES (@userNumber, @handPhoneNumber, @jobTypeId, @getMail , @placeToPlay,@internetConnection )
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:004 '   -- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END


	DECLARE @transactionId 	as int
	DECLARE @orderTransactionid as int
	DECLARE @productId 		as int
	DECLARE @amount 		as int
	SET @productId = 1031
	set @amount = 0 
	----FreeCharge
/*
	EXEC procCharge  16 , @userNumber,  @cpId ,@amount , null, @transactionId output
	IF @transactionid < 1 
	BEGIN
		SET @msg = 'Please, contact us:msg-chargeError. ErrorCode:006' ---- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END
*/
	----FreeOrder
	--EXEC procOrder @userNumber, @cpId, @gameServiceId, @productId, @transactionId, null, null, @amount, null, null, @orderTransactionid output

		EXEC procOrder @userNumber, @cpId, @gameServiceId, @productId, null, null, null, @amount, null, null, @orderTransactionid output
			
		IF @orderTransactionid < 1 
		BEGIN
			SET @msg = 'Please, contact us:msg-OrderError. ErrorCode:007' ---- '????? ?? ???. ErrorCode:004'
			SET @userNumber = -1
			RETURN 1
		END

/*
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:008' ---- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END
*/
	RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[procInsertUserTemp]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertUser    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procGetSalesList
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	?? ??
	Input Parameters :	
		@userId				as	nvarchar(32)		
		@cpId					as	int			
		@password				as	nvarchar(32)		
		@userName				as	nvarchar(16)		
		@ssno					as	nvarchar(13)		
		@birthday				as	smalldatetime		
		@isSolar				as	bit			
		@zipcode				as	nchar(6)			
		@address				as	nvarchar(64)		
		@addressDetail				as	nvarchar(64)		
		@phoneNumber				as	nvarchar(16)		
		@email					as	nvarchar(64)		
		@passwordCheckQuestionTypeId	as	int
		@passwordCheckAnswer		as	nvarchar(64)		
		@userNumber				as	int		OUTPUT
			
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
		EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertUserTemp]
	@userId				as	nvarchar(32)		
,	@cpId					as	int			
,	@password				as	nvarchar(32)		
,	@userSurName				as	nvarchar(64)	
,	@userFirstName				as	nvarchar(64)
,	@sex					as	bit		
,	@ssno					as	nvarchar(13)		
,	@birthday				as	nvarchar(10)		
,	@zipcode				as	nchar(6)			
,	@address				as	nvarchar(64)			
,	@phoneNumber				as	nvarchar(16)		
,	@email					as	nvarchar(64)	
,	@nation				as	nvarchar(64)	
,	@passwordCheckQuestionTypeId	as	nvarchar(64)
,	@passwordCheckAnswer		as	nvarchar(64)	
,	@handPhoneNumber			as	nvarchar(64)
,	@jobTypeId				as	nvarchar(64)
,	@getMail				as 	bit
,	@gameServiceId			as	smallint	
,	@userNumber				as	int		OUTPUT
,	@msg					as	nvarchar(64)	OUTPUT
as
	SELECT userId
	FROM tblUserInfo with (nolock)
	WHERE userId = @userId AND userStatusId <> 3
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg = 'overlapping ID.' --'??? ??????.'
		RETURN 1
	END
	SELECT rejectWord
	FROM tblRejectWord with (nolock)
	WHERE UPPER(rejectWord) = UPPER(@userId)
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg = 'unusable ID.' --'??? ? ?? ??????.'
		RETURN 1
	END
	INSERT INTO 
		tblUser (userId, userPwd, userTypeId, cpId, gameServiceId)
	VALUES
		(@userId, @password, 2, @cpId, @gameServiceId) 
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:001' -- '????? ?? ???. ErrorCode:001'
		RETURN 1
	END
	SET @userNumber = @@IDENTITY
	INSERT INTO 
		tblUserInfo (userNumber, userId, userPwd, cpId, userTypeId, userSurName, userFirstName, gameServiceId, ssno, 
		sex, birthday, isSolar, email, zipcode, nation, address, phoneNumber, 
		passwordCheckQuestionTypeId, passwordCheckAnswer)
	VALUES
		(@userNumber				,			-- ??? ??
		@userId				,			-- ID
		@password				,			-- password
		@cpId					,			-- cpId
		2					,	
		@userSurName				,			-- userName(?)
		@userFirstName				,			-- userName(??)
		@gameServiceId			,			-- ?? gameServiceId
		@ssno					,			-- ??????
		@sex					,			-- ??
		CONVERT(smalldatetime, @birthday)	,			-- ????
		1				,			-- ? / ?
		@email					,			-- E-mail
		@zipcode				,			-- ????
		@nation				,			-- ?
		@address				,			-- ????
		@phoneNumber				,			-- ????
		@passwordCheckQuestionTypeId	,			-- ???? ?? ??
		@passwordCheckAnswer				-- ???? ?? ??
		)
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:002' --'????? ?? ???. ErrorCode:002'
		RETURN 1
	END
	EXEC procInsertUserHistory @userNumber
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:003' -- '????? ?? ???. ErrorCode:003'
		RETURN 1
	END
	INSERT INTO tblUserDetail (userNumber, handphoneNumber, jobTypeId, 
				isSendEmail)
	VALUES (@userNumber, @handPhoneNumber, @jobTypeId, @getMail)
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:003' -- '????? ?? ???. ErrorCode:004'
		RETURN 1
	END
	RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[procInsertGamebangForAdmin]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procInsertGamebangForAdmin]
	@gamebangName		AS		nvarchar(32)
,	@zipcode			as		nchar(6)
,	@address			AS		nvarchar(64)
,	@tel				AS		nvarchar(32)
,	@bizNumber			AS		nvarchar(16)
,	@Surname			AS		nvarchar(64)
,	@FirstName			AS		nvarchar(64)
,	@depositAmount		AS		INT
,	@chongphanId			AS		INT
,	@ssno				AS		nvarchar(13)
,	@item				AS		nvarchar(50)
,	@bizStatus			AS		nvarchar(50)
,	@cellPhone			AS		nvarchar(18)
,	@email				AS		nvarchar(100)
,	@manageCode		AS		nvarchar(20)				=	NULL
,	@gamebangTypeId		AS		TINYINT				=	NULL
,	@adminNumber		AS		INT					=	NULL
,	@returnCode			AS		TINYINT		OUTPUT
,	@returnGamebangId		AS		INT			OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@insertedId		AS		INT
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
IF(EXISTS(SELECT * FROM tblGamebang WHERE bizNumber <> 'later Registration' AND bizNumber = @bizNumber AND apply = 1 ))			--?? ??? ???? ?? ??
	BEGIN
		SET @returnCode = 2				--?? ??? ????? ??? ?? ??? ?? ??
		SET @returnGamebangId = 0
	END
ELSE IF(EXISTS(SELECT * FROM tblGamebang WHERE manageCode = @manageCode AND apply = 1 AND manageCode <> 'later Registration'))
	BEGIN
		SET @returnCode = 3				--?? ????? ??? ?? ??? ?? ??
		SET @returnGamebangId = 0
	END
ELSE
	BEGIN
		--insert? id? ????.
		EXEC procGetCompanyId 'tblGamebang' , @insertedId OUTPUT		
		SET @returnGamebangId = @insertedId
		--gamebang? ???.
		INSERT INTO tblGamebang 
			VALUES(
				@insertedId
			,	@gamebangName
			,	@bizNumber
			,	@address
			,	@zipcode
			,	@tel
			,	@Surname
			,	@FirstName
			,	0
			,	0
			,	@depositAmount
			,	1
			,	@ssno
			,	@item
			,	@bizStatus
			,	@cellPhone
			,	@email
			,	@manageCode
			,	@gamebangTypeId
			)
		IF(@adminNumber <> 0)
			BEGIN
				--tblAdminLog? ???
				INSERT INTO tblAdminLog 
					VALUES(
						'Registration'
					,	'tblGamebang'
					,	@adminNumber
					,	'gamebang Registration'
					,	GETDATE()
					)
		
				SET @adminLogId = @@IDENTITY
			END
		ELSE
			BEGIN
				SET  @adminLogId  = NULL
			END
		--tblGamebangHistory? ???.
		EXEC procInsertGamebangHistory @insertedId, @adminLogId
		
		EXEC procInsertChongphanGamebang @insertedId , @chongphanId  , @adminNumber
		--EXEC procInsertChongphanGamebang @insertedId , 1 , @adminNumber
		SET @returnCode = 1				--?????.
	END
GO
/****** Object:  StoredProcedure [dbo].[procGetPpcardInfo2]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	Stored Procedure	:	procGetPpcardInfo
	Creation Date		:	2002. 12. 26
	Written by		:	???
	E-Mail by 		:	jjhl@n-cash.net
	Purpose			:	ppcard ?? ????
	Input Parameters :	
		@ppCardSerialNumber			as	varchar(20)		
		@ppcardId				as	int		OUTPUT
		@howManyPeople			as	int		OUTPUT
			
	return?:
		@msg					as	varchar(64)	OUTPUT
	
*/
CREATE PROCEDURE [dbo].[procGetPpcardInfo2]
	@gameServiceId			as	smallint
,	@userId				as	nvarchar(32)	
,	@ppCardSerialNumber			as	nvarchar(32)
,	@pinCode				as	nvarchar(18)
,	@productCode				as	nvarchar(32)		
,	@ppcardId				as	int		OUTPUT
,	@howManyPeople			as	int		OUTPUT
,	@productId				as	int		OUTPUT
,	@productAmount			as	int		OUTPUT
,	@returnCode				as	int		OUTPUT
as

DECLARE	@userNumber			as	int
DECLARE	@tValidStartDt			as	smalldatetime
DECLARE	@tValidEndDt			as	smalldatetime
DECLARE	@tDt				as	smalldatetime
DECLARE	@lastDt				as	smalldatetime
DECLARE	@rowCount			as	int
DECLARE 	@dbPINCode			as	nvarchar(18)
DECLARE	@dbProductCode		as	nvarchar(40)

	SELECT @userNumber = userNumber FROM tblUserInfo WITH (NOLOCK) WHERE userId=@userId and gameServiceId = @gameServiceId

	SET @returnCode = 0
	SET @tDt = getdate()
	SET @lastDt = DATEADD (dd , -1, @tDt) 
	
	SELECT @ppcardId = pc.ppCardId, @howManyPeople= pcg.howManyPeople, @tValidStartDt = pcg.validStartDt,
		@tValidEndDt = pcg.validEndDt, @productId = pcg.productId, @productAmount = p.productAmount 
		,@dbPINCode=pc.PINCode , @dbProductCode=pc.productCode
	FROM tblPpCardForTantra pc, tblPpCardGroup pcg, tblProduct p 
	WHERE pc.ppCardSerialNumber = @ppCardSerialNumber AND pc.ppCardGroupId = pcg.ppCardGroupId 
		AND pcg.productId = p.productId AND pcg.apply = 1

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt)
		VALUES (@userNumber, @ppCardSerialNumber, getdate()) 			
		SET @returnCode = 1	 	
		RETURN  --ADD								
	END	
	IF @dbPINCode <> @pinCode OR @dbProductCode <> @productCode 
	BEGIN
		INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt)
		VALUES (@userNumber, @ppCardSerialNumber, getdate()) 			
		SET @returnCode = 1 	
		RETURN --ADD								
	END	

	SELECT ppCardId FROM tblPpCardUserInfoMapping WHERE @ppcardId = ppCardId
	IF @@ROWCOUNT > 0
		BEGIN
			INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt)
			VALUES (@userNumber, @ppCardSerialNumber, getdate()) 	

			SET @returnCode = 3		-- ???? ?????? ????
		END

	IF (@tValidEndDt < @tDt OR @tValidStartDt > @tDt) 
		BEGIN
			INSERT INTO tblPpCardFailList (userNumber, ppCardSerialNumber, registDt)
			VALUES (@userNumber, @ppCardSerialNumber, getdate()) 	
		
			SET @returnCode = 2		--  ???? ?????? ???? ????
		END

	SELECT num FROM tblPpCardFailList WHERE userNumber = @userNumber  AND registDt BETWEEN @lastDt AND @tDt
	SET @rowCount = @@ROWCOUNT			
	IF  @rowCount > 9
		BEGIN
			INSERT INTO tblPpCardInjusticeList (userNumber, registDt)
			VALUES (@userNumber, getdate()) 			
			UPDATE tblUser 	SET userStatusId = 5 	WHERE userNumber = @userNumber
			UPDATE tblUserInfo 	SET userStatusId = 5 	WHERE userNumber = @userNumber
	
			EXEC procInsertUserHistory @userNumber			
		END

	SELECT @ppcardId, @howManyPeople, @productId, @productAmount, @returnCode
	RETURN
GO
/****** Object:  StoredProcedure [dbo].[procInsertUserNew]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procInsertUserNew]
	@userId				as	nvarchar(50)		
,	@cpId					as	int			
,	@password				as	nvarchar(70)		
,	@userSurName				as	nvarchar(64)	
,	@MI					as	nvarchar(1)
,	@userFirstName				as	nvarchar(64)
,	@userKey				as	nvarchar(7)
,	@sex					as	int	
,	@birthday				as	nvarchar(16)		
,	@address				as	nvarchar(64)			
,	@phoneNumber			as	nvarchar(16)	
,	@email					as	nvarchar(64)	
,	@nation				as	nvarchar(64)	
,	@city					as	nvarchar(64)	
,	@state					as	nvarchar(64)	
,	@passwordCheckQuestionTypeId	as	nvarchar(64)
,	@passwordCheckAnswer		as	nvarchar(64)	
,	@handPhoneNumber			as	nvarchar(64)
,	@jobTypeId				as	nvarchar(64)
,	@getMail				as 	bit
,	@gameServiceId			as	smallint	
,	@userNumber				as	int		OUTPUT
,	@msg					as	nvarchar(64)	OUTPUT
as


	SELECT userId FROM tblUserInfo with (nolock) WHERE userId = @userId AND userStatusId <> 3
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg = 'overlapping ID.' --'??? ??????.'
		SET @userNumber = -1
		RETURN 1
	END
	SELECT rejectWord
	FROM tblRejectWord with (nolock)
	WHERE UPPER(rejectWord) = UPPER(@userId)
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg = 'unusable ID.' --'??? ? ?? ??????.'
		SET @userNumber = -1
		RETURN 1
	END
	INSERT INTO 
		tblUser (userId, userPwd, cpId, gameServiceId)
	VALUES
		(@userId, @password, @cpId, @gameServiceId) 
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:001' -- '????? ?? ???. ErrorCode:001'
		SET @userNumber = -1
		RETURN 1
	END
	SET @userNumber = @@IDENTITY
	IF @sex = 2
		SET @sex = 0
			
	INSERT INTO tblUserInfo (userNumber, userId, userPwd, cpId, userSurName, userFirstName, gameServiceId, ssno, 
		sex, birthday, isSolar, email, zipcode, nation, address, phoneNumber, 
		passwordCheckQuestionTypeId, passwordCheckAnswer , MI, userKey, city, state )
	VALUES 
		(@userNumber				,			-- ??? ??
		@userId				,			-- ID
		@password				,			-- password
		@cpId					,			-- cpId
		@userSurName				,			-- userName(?)
		@userFirstName				,			-- userName(??)
		@gameServiceId			,			-- ?? gameServiceId
		null					,			-- ??????
		@sex					,			-- ??
		CONVERT(smalldatetime, @birthday)	,			-- ????
		1				,			-- ? / ?
		@email					,			-- E-mail
		null				,			-- ????
		@nation				,			-- ?
		@address				,			-- ????
		@phoneNumber				,			-- ????
		@passwordCheckQuestionTypeId	,			-- ???? ?? ??
		@passwordCheckAnswer		,		-- ???? ?? ??
		@MI					,
		@userKey				,
		@city					,
		@state					
		)
	IF @@ERROR <> 0
	BEGIN

		select @userNumber, @userId	, @password	, @cpId	, @userSurName, @userFirstName , @gameServiceId	, null, @sex , CONVERT(smalldatetime, @birthday)	,1	, @email	, null	, @nation	, @address, @phoneNumber	, @passwordCheckQuestionTypeId	,@passwordCheckAnswer		,@MI	 , @userKey	, @city		, @state	
		SET @msg = 'Please, contact us. ErrorCode:002' --'????? ?? ???. ErrorCode:002'
		SET @userNumber = -1	
	
		RETURN 1
	END
	EXEC procInsertUserHistory @userNumber
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:003' -- '????? ?? ???. ErrorCode:003'
		SET @userNumber = -1
		RETURN 1
	END
	INSERT INTO tblUserDetail (userNumber, handphoneNumber, jobTypeId, 
				isSendEmail)
	VALUES (@userNumber, @handPhoneNumber, @jobTypeId, @getMail)
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:004 '   -- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END


	DECLARE @transactionId 	as int
	DECLARE @orderTransactionid as int
	DECLARE @productId 		as int
	DECLARE @amount 		as int
	SET @productId = 1021
	set @amount = 0 
	----FreeCharge
	EXEC procCharge  16 , @userNumber,  @cpId ,@amount , null, @transactionId output
	IF @transactionid < 1 
	BEGIN
		SET @msg = 'Please, contact us:msg-chargeError. ErrorCode:006' ---- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END

	----FreeOrder
	EXEC procOrder @userNumber, @cpId, @gameServiceId, @productId, @transactionId, null, null, @amount, null, null, @orderTransactionid output
	
	IF @orderTransactionid < 1 
	BEGIN
		SET @msg = 'Please, contact us:msg-OrderError. ErrorCode:007' ---- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END
	
/*		
	INSERT tblUserGameService(userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
	VALUES(@userNumber, @gameServiceId, getdate(), dateadd(dd, 3, GETDATE()) , 0, 0, '0000', '2400', 0,0, GETDATE() , NULL)
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:005' -- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END
*/
/*
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:008' ---- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END
*/
	RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[procInsertUser]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procInsertUser]
	@userId				as	nvarchar(50)		
,	@cpId					as	int			
,	@password				as	nvarchar(70)		
,	@userSurName				as	nvarchar(64)	
,	@MI					as	nvarchar(1)
,	@userFirstName				as	nvarchar(64)
,	@userKey				as	nvarchar(7)
,	@sex					as	int	
,	@birthday				as	nvarchar(16)		
,	@address				as	nvarchar(64)			
,	@phoneNumber			as	nvarchar(16)	
,	@email					as	nvarchar(64)	
,	@nation				as	nvarchar(64)	
,	@city					as	nvarchar(64)	
,	@state					as	nvarchar(64)	
,	@passwordCheckQuestionTypeId	as	nvarchar(64)
,	@passwordCheckAnswer		as	nvarchar(64)	
,	@handPhoneNumber			as	nvarchar(64)
,	@jobTypeId				as	nvarchar(64)
,	@getMail				as 	bit
,	@gameServiceId			as	smallint	
--,	@placeToPlay				as 	nvarchar(40)
--,	@internetConnection			as	nvarchar(30)
,	@userNumber				as	int		OUTPUT
,	@msg					as	nvarchar(64)	OUTPUT
as


	SELECT userId FROM tblUserInfo with (nolock) WHERE userId = @userId AND userStatusId <> 3
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg = 'overlapping ID.' --'??? ??????.'
		SET @userNumber = -1
		RETURN 1
	END
	SELECT rejectWord
	FROM tblRejectWord with (nolock)
	WHERE UPPER(rejectWord) = UPPER(@userId)
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg = 'unusable ID.' --'??? ? ?? ??????.'
		SET @userNumber = -1
		RETURN 1
	END
	INSERT INTO 
		tblUser (userId, userPwd, cpId, gameServiceId, Apply)
	VALUES
		(@userId, @password, @cpId, @gameServiceId, 1) 
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:001' -- '????? ?? ???. ErrorCode:001'
		SET @userNumber = -1
		RETURN 1
	END
	SET @userNumber = @@IDENTITY
	IF @sex = 2
		SET @sex = 0
			
	INSERT INTO tblUserInfo (userNumber, userId, userPwd, cpId, userSurName, userFirstName, gameServiceId, ssno, 
		sex, birthday, isSolar, email, zipcode, nation, address, phoneNumber, 
		passwordCheckQuestionTypeId, passwordCheckAnswer , MI, userKey, city, state, Apply, CashBalance, pointToCashBalance, pointBalance )
	VALUES 
		(@userNumber				,			-- ??? ??
		@userId				,			-- ID
		@password				,			-- password
		@cpId					,			-- cpId
		@userSurName				,			-- userName(?)
		@userFirstName				,			-- userName(??)
		@gameServiceId			,			-- ?? gameServiceId
		null					,			-- ??????
		@sex					,			-- ??
		CONVERT(smalldatetime, @birthday)	,			-- ????
		1				,			-- ? / ?
		@email					,			-- E-mail
		null				,			-- ????
		@nation				,			-- ?
		@address				,			-- ????
		@phoneNumber				,			-- ????
		@passwordCheckQuestionTypeId	,			-- ???? ?? ??
		@passwordCheckAnswer		,		-- ???? ?? ??
		@MI					,
		@userKey				,
		@city					,
		@state					,
		1,
		0,
		0,
		0
		)
	IF @@ERROR <> 0
	BEGIN

		select @userNumber, @userId	, @password	, @cpId	, @userSurName, @userFirstName , @gameServiceId	, null, @sex , CONVERT(smalldatetime, @birthday)	,1	, @email	, null	, @nation	, @address, @phoneNumber	, @passwordCheckQuestionTypeId	,@passwordCheckAnswer		,@MI	 , @userKey	, @city		, @state	
		SET @msg = 'Please, contact us. ErrorCode:002' --'????? ?? ???. ErrorCode:002'
		SET @userNumber = -1	
	
		RETURN 1
	END
	EXEC procInsertUserHistory @userNumber
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:003' -- '????? ?? ???. ErrorCode:003'
		SET @userNumber = -1
		RETURN 1
	END
	--INSERT INTO tblUserDetail (userNumber, handphoneNumber, jobTypeId, isSendEmail)
	--VALUES (@userNumber, @handPhoneNumber, @jobTypeId, @getMail)
	INSERT INTO tblUserDetail (userNumber, handphoneNumber, jobTypeId, isSendEmail ,placeToPlay, internetConnection)
	VALUES (@userNumber, @handPhoneNumber, @jobTypeId, @getMail , null, null )
	--VALUES (@userNumber, @handPhoneNumber, @jobTypeId, @getMail , @placeToPlay,@internetConnection )
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:004 '   -- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END

	/*
	DECLARE @transactionId 	as int
	DECLARE @orderTransactionid as int
	DECLARE @productId 		as int
	DECLARE @amount 		as int

	SET @amount = 0 
	SET @productId = 1031  

	EXEC procOrder @userNumber, @cpId, @gameServiceId, @productId, null, null, null, @amount, null, null, @orderTransactionid output
		
	IF @orderTransactionid < 1 
	BEGIN
		SET @msg = 'Please, contact us:msg-OrderError. ErrorCode:007' ---- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END
	*/


	RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[procInsertGamebang]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.procInsertGamebang    Script Date: 23/1/2546 11:40:27 ******/
/*
	Stored Procedure	:	procInsertGamebang
	Creation Date		:	2002. 01.24
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	??? ??
	
	Input Parameters :	
				@gamebangName		AS		nvarchar(32)
				@zipCode			as	nchar(6)
				@address			AS		nvarchar(64)
				@tel				AS		nvarchar(32)
				@bizNumber			AS		nvarchar(16)
				@presidentName		AS		nvarchar(16)
				@depositAmount		AS		INT
				@adminNumber			AS		INT	Output Parameters:	
	Output Parameters:	
				@returnCode			AS		TINYINT
				@returnGamebangId		AS		INT			OUTPUT
				
	Return Status:		
				@returnCode : 
					1.?? ??? ?????? ???? ?????..
					2:?? ??? ?????? ???? ????..
				@returnGamebangId : 
					??? ????
				
	Usage: 			
	EXEC procInsertGamebang '???','158050','??? ??? ??? ?????' , '02-2281-6500' ,'123-45-67890', '???' , NULL, @returnCode OUTPUT
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblGamebang(S,I) , tblAdmin(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertGamebang]
	@gamebangName		AS		nvarchar(32)
,	@zipcode			as		nchar(6)	= NULL
,	@address			AS		nvarchar(64) = NULL
,	@tel				AS		nvarchar(32) = NULL
,	@bizNumber			AS		nvarchar(16) = NULL
,	@Surname			AS		nvarchar(64) = NULL
,	@FirstName			AS		nvarchar(64) = NULL
,	@depositAmount		AS		INT	        = NULL	
,	@chongphanId			AS		INT	     = NULL
,	@ssno				AS		nvarchar(13)
,	@item				AS		nvarchar(50)
,	@bizStatus			AS		nvarchar(50)
,	@cellPhone			AS		nvarchar(18)
,	@email				AS		nvarchar(100)
,	@manageCode		AS		nvarchar(20)		=	NULL
,	@gamebangTypeId		AS		TINYINT		=	NULL
,	@adminNumber		AS		INT			=	NULL
,	@returnCode			AS		TINYINT		OUTPUT
,	@returnGamebangId		AS		INT			OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@insertedId		AS		INT
DECLARE	@adminLogId		AS		INT
DECLARE	@returnChongphanId	AS		INT
------------------------?? ???--------------------
/*IF(EXISTS(SELECT * FROM tblGamebang WHERE bizNumber <> 'later Registration' AND bizNumber = @bizNumber AND apply = 1 ))			--?? ??? ???? ?? ??
	BEGIN
		SET @returnCode = 2				--?? ??? ????? ??? ?? ??? ?? ??
		SET @returnGamebangId = 0
	END
ELSE IF(EXISTS(SELECT * FROM tblGamebang WHERE manageCode = @manageCode AND apply = 1 AND manageCode <> 'later Registration'))
	BEGIN
		SET @returnCode = 3				--?? ????? ??? ?? ??? ?? ??
		SET @returnGamebangId = 0
	END

IF(EXISTS(SELECT * FROM tblGamebang WHERE  bizNumber = @bizNumber AND apply = 1 ))			--?? ??? ???? ?? ??
BEGIN
	SET @returnCode = 2
	SET @returnGamebangId = 0
END
*/
		--insert? id? ????.
		EXEC procGetCompanyId 'tblGamebang' , @insertedId OUTPUT		
		SET @returnGamebangId = @insertedId
		--gamebang? ???.
		INSERT INTO tblGamebang 
			VALUES(
				@insertedId
			,	@gamebangName
			,	@bizNumber
			,	@address
			,	@zipcode
			,	@tel
			,	@Surname
			,	@FirstName
			,	0
			,	0
			,	@depositAmount
			,	1
			,	@ssno
			,	@item
			,	@bizStatus
			,	@cellPhone
			,	@email
			,	@manageCode
			,	@gamebangTypeId
			)

		IF @@ERROR <> 0 
		BEGIN
			SET @returnCode = 4				--?? ??? ????? ??? ?? ??? ?? ??
			SET @returnGamebangId = 0
			RETURN
		END
		IF(@adminNumber <> 0)
			BEGIN
				--tblAdminLog? ???
				INSERT INTO tblAdminLog 
					VALUES(
						'Registration'
					,	'tblGamebang'
					,	@adminNumber
					,	'gamebang Registration'
					,	GETDATE()
					)
		
				SET @adminLogId = @@IDENTITY
			END
		ELSE
			BEGIN
				SET  @adminLogId  = NULL
			END
		IF @@ERROR <> 0 
		BEGIN
			SET @returnCode = 5			--?? ??? ????? ??? ?? ??? ?? ??
			SET @returnGamebangId = 0
			RETURN
		END		
		--tblGamebangHistory? ???.
		EXEC procInsertGamebangHistory @insertedId, @adminLogId
		IF @@ERROR <> 0 
		BEGIN
			SET @returnCode =6			--?? ??? ????? ??? ?? ??? ?? ??
			SET @returnGamebangId = 0
			RETURN
		END		
		EXEC procInsertChongphanGamebang @insertedId , 1 , @adminNumber
		IF @@ERROR <> 0 
		BEGIN
			SET @returnCode =7			--?? ??? ????? ??? ?? ??? ?? ??
			SET @returnGamebangId = 0
			RETURN
		END

		SET @returnCode = 1				--?????.
GO
/****** Object:  StoredProcedure [dbo].[procInsertCreditCardOrdernNew]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
??? : ???
EMAIL :  iBeliveKim@n-cash.net
??? :  2005 - 1- 13
??? :  ??? ppcard ??? ?? sp 
???? sp??? ?? ???

*/
CREATE PROCEDURE [dbo].[procInsertCreditCardOrdernNew]
	@cpId					AS	INT		
,	@chargeCardDepositTempId		AS	INT
,	@nameOnCard				AS	VARCHAR(50)
,	@transactionNumber			AS	VARCHAR(30)
,	@email					AS	VARCHAR(100)
,	@pgAmount				AS	DECIMAL(10,2) 
, 	@dateOfTransaction			AS	DATETIME
,	@distributorId				AS	INT
,	@returnValue				AS	INT	OUTPUT
,	@msg					AS	VARCHAR(100)  OUTPUT
AS

DECLARE @userNumber	INT
DECLARE @returnCode	 INT
DECLARE @productId		INT
DECLARE @gameServiceId  	INT
DECLARE @orderNumber     	INT
DECLARE @orderTypeid      	TINYINT
DECLARE @eventId  		INT
DECLARE @adminLogId 	INT
DECLARE @ppCardId 		INT
DECLARE @productAmount	INT
DECLARE @chargeTypeId 	INT
DECLARE @transactionId	INT
DECLARE @chargeTransactionId INT
DECLARE @orderTransactionId INT
DECLARE @userId		NVARCHAR(32)		
DECLARE @errorSave		INT

SET @chargeTypeId =  1
--SET @gameServiceId =  1
SET @orderNumber= NULL
SET @orderTypeId=NULL 
SET @eventId= NULL
SET @adminLogId = 0
SET @errorSave = 0
--------------------------
	---?? ?? ?? ??? ??? ??? 
	EXEC procGetChargeCreateCardTemp  @chargeCardDepositTempId , @userNumber OUTPUT, @productId OUTPUT, @productAmount  OUTPUT
	SET @errorSave =@errorSave +  @@ERROR 
	IF @productId < 1 or @productId is null
	BEGIN
		SELECT @returnValue = -3003 , @msg = 'Can Not Order Product'
		RETURN
	END
--------------------------
	SELECT @gameServiceId =  gameServiceId  FROM tblUserInfo  with(nolock) where userNumber=@userNumber
	SET @errorSave =@errorSave +  @@ERROR 
	IF @gameServiceId  is null OR @gameServiceId = '' 
	BEGIN
		SELECT @returnValue = -3000, @msg = 'not exists User'
		RETURN
	END
		

	----??, ?? ?? ?? ,??? ???? ??? ???? ?? ??
	EXEC  procIsCanOrder  @userNumber, @productId, @gameServiceid, @returnCode output
	IF @returnCode  = -1
	BEGIN		
		SELECT  @returnValue = -1006 , @msg = 'Time Base  yet  Remain '  --??? ??? ?? ?? ?? ??
		RETURN
	END
	IF @returnCode  = -2
	BEGIN		
		SELECT  @returnValue = -1007 , @msg = 'Day Base Yet Remain'  --?? ???  ??? ?? ?? ?? ??
		RETURN
	END

	SET @errorSave =@errorSave +  @@ERROR 
/*
-1 ?? ??? ?? ????
-2 ?? ??? ?? ????
1, 2 ?? ?? ??
*/

	----??, ?? ?? ?? ,??? ???? ??? ???? ?? ?
		
BEGIN TRAN	

	--?? ?? ??
	EXEC procCharge @chargeTypeId, @userNumber, @cpId, @productAmount, @adminLogId,  @chargeTransactionId OUTPUT
	SET @errorSave =@errorSave +  @@ERROR 
	IF @chargeTransactionId < 1 
	BEGIN
		IF @chargeTransactionId  = -201
		BEGIN
			SELECT @returnValue = -2000, @msg = 'Charge Error'
			ROLLBACK
			RETURN							
		END
		IF @chargeTransactionId  = -401
		BEGIN
			SELECT @returnValue = -2001, @msg = 'INSERT ERROR'
			ROLLBACK
			RETURN							
		END
	END
	--?? ?? ?


----------------------------- ?? ?? ?? ?? ??------------------------------

	EXEC procInsertChargeCardDeposit @chargeTransactionId , @chargeCardDepositTempId , @nameOnCard , @transactionNumber, @email, @pgAmount ,@productAmount,  @dateOfTransaction, @distributorId, @returnCode OUTPUT
	SET @errorSave =@errorSave +  @@ERROR 
	IF @returnCode = 0 
	BEGIN
		SELECT @returnValue = -2001, @msg = 'CreateCard  INSERT ERROR'
		ROLLBACK
		RETURN							
	END
----------------------------- ?? ?? ?? ?? ?? ?------------------------------


	---?? ?? ??
	EXEC procOrder @userNumber, @cpId, @gameServiceId, @productId, @chargeTransactionId ,  @orderNumber, @orderTypeId, @productAmount, @eventId, @adminLogId, @orderTransactionId OUTPUT
	SET @errorSave =@errorSave +  @@ERROR 
	--EXEC procOrderForCreateCard  @userNumber, @cpId, @gameServiceId, @productId, @chargeTransactionId ,  @orderNumber, @orderTypeId, @productAmount, @eventId, @adminLogId, @orderTransactionId OUTPUT
	IF @orderTransactionId  < 1 
	BEGIN
		IF @orderTransactionId  = -201  ---apply? 0  ??? ?? ???? ?? ?? ?? ??? ???
		BEGIN
			SELECT @returnValue = -3000, @msg = 'not exists User'
			ROLLBACK
			RETURN							
		END
		IF @orderTransactionId  = -501 ---?? ?? ?? ???
		BEGIN
			SELECT @returnValue = -3001, @msg = 'Can Not Order User'
			ROLLBACK
			RETURN							
		END

		IF @orderTransactionId  = -203   --?? ?? ?? ?? 
		BEGIN
			SELECT @returnValue = -3003 , @msg = 'Can Not Order Product'
			ROLLBACK
			RETURN							
		END

		IF @orderTransactionId  = -206   --??? productType
		BEGIN
			SELECT @returnValue = -3003 , @msg = 'Can Not Order Product'
			ROLLBACK
			RETURN							
		END

		 ---DB INSERT ERROR  IN(order, userGameService, userGameServiceHistory fail ,)
		IF @orderTransactionId  = -401 
		BEGIN
			SELECT @returnValue = -3004 , @msg = 'DB INSERT ERROR'
			ROLLBACK
			RETURN							
		END

		---???? ?? ???
		---DB INSERT ERROR  IN(order, userGameService, userGameServiceHistory fail)
		SELECT @returnValue = -3005 , @msg = 'ETC ERROR'
		ROLLBACK
		RETURN	

		IF @errorSave <> 0 
		BEGIN
			SELECT @returnValue = -3005 , @msg = 'ETC ERROR'
			ROLLBACK
			RETURN
		END
							
	END
	---?? ?? ?
	ELSE
	BEGIN
		SELECT @returnValue = 1 , @msg = 'success'
		COMMIT
		RETURN
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertCp]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procInsertCp    Script Date: 23/1/2546 11:40:25 ******/
/*
	Stored Procedure	:	procInsertCp
	Creation Date		:	2002. 01.24
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	?? ??
	
	Input Parameters :	
				@cpName			AS		nvarchar(32)
				@bizNumber			AS		nvarchar(16)				
				@zipCode			as	nchar(6)
				@address			AS		nvarchar(64)
				@phoneNumber			AS		nvarchar(32)
				@presidentName		AS		nvarchar(16)
				@adminNumber			AS		TINYINT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ?????.
				2: ?? ??? ?????.
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblChongphan(S,I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procInsertCp]
	@cpName			AS		nvarchar(32)
,	@bizNumber			AS		nvarchar(16)				
,	@zipcode			as	nchar(6)
,	@address			AS		nvarchar(64)
,	@phoneNumber			AS		nvarchar(32)
,	@presidentName		AS		nvarchar(16)
,	@adminNumber			AS		INT
,	@returnCode			AS		TINYINT	OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@insertedId		AS		INT
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
IF(NOT EXISTS(SELECT cpId FROM tblCp WHERE bizNumber = @bizNumber AND apply = 1))			--?? ??? ???? ?? ??
	BEGIN
		--insert? id? ????.
		EXEC procGetCompanyId 'tblCp' , @insertedId OUTPUT		
		INSERT INTO tblCp
		VALUES(
			@insertedId
		,	@cpName
		,	@bizNumber
		,	@address
		,	@zipcode
		,	@phoneNumber
		,	@presidentName
		,	1
		)
		--tblAdminLog? ???
		INSERT INTO tblAdminLog 
			VALUES(
				'Registration'
			,	'tblCp'
			,	@adminNumber
			,	'CP Registration'
			,	GETDATE()
			)
		
		SET @adminLogId = @@IDENTITY
	
		--tblGamebangHistory? ???.
		INSERT INTO tblCpHistory 
			SELECT cpId , cpName , bizNumber , address , zipcode , phoneNumber , presidentName , apply , GETDATE() , @adminLogId 
			FROM tblCp
			WHERE cpId = @insertedId
		SET @returnCode = 1				--?????.
	END
ELSE
	BEGIN
		SET @returnCode = 2
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertUserBak]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procInsertUserBak]
	@userId				as	nvarchar(50)		
,	@cpId					as	int			
,	@password				as	nvarchar(70)		
,	@userSurName				as	nvarchar(64)	
,	@MI					as	nvarchar(1)
,	@userFirstName				as	nvarchar(64)
,	@userKey				as	nvarchar(7)
,	@sex					as	int	
,	@birthday				as	nvarchar(16)		
,	@address				as	nvarchar(64)			
,	@phoneNumber				as	nvarchar(16)	
,	@email					as	nvarchar(64)	
,	@nation				as	nvarchar(64)	
,	@city					as	nvarchar(64)	
,	@state					as	nvarchar(64)	
,	@passwordCheckQuestionTypeId	as	nvarchar(64)
,	@passwordCheckAnswer		as	nvarchar(64)	
,	@handPhoneNumber			as	nvarchar(64)
,	@jobTypeId				as	nvarchar(64)
,	@getMail				as 	bit
,	@gameServiceId			as	smallint	
,	@userNumber				as	int		OUTPUT
,	@msg					as	nvarchar(64)	OUTPUT
as
	SELECT userId
	FROM tblUserInfo with (nolock)
	WHERE userId = @userId AND userStatusId <> 3
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg = 'overlapping ID.' --'??? ??????.'
		SET @userNumber = -1
		RETURN 1
	END
	SELECT rejectWord
	FROM tblRejectWord with (nolock)
	WHERE UPPER(rejectWord) = UPPER(@userId)
	IF @@ROWCOUNT > 0
	BEGIN
		SET @msg = 'unusable ID.' --'??? ? ?? ??????.'
		SET @userNumber = -1
		RETURN 1
	END
	INSERT INTO 
		tblUser (userId, userPwd, cpId, gameServiceId)
	VALUES
		(@userId, @password, @cpId, @gameServiceId) 
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:001' -- '????? ?? ???. ErrorCode:001'
		SET @userNumber = -1
		RETURN 1
	END
	SET @userNumber = @@IDENTITY
	IF @sex = 2
		SET @sex = 0
			
	INSERT INTO tblUserInfo (userNumber, userId, userPwd, cpId, userSurName, userFirstName, gameServiceId, ssno, 
		sex, birthday, isSolar, email, zipcode, nation, address, phoneNumber, 
		passwordCheckQuestionTypeId, passwordCheckAnswer , MI, userKey, city, state )
	VALUES 
		(@userNumber				,			-- ??? ??
		@userId				,			-- ID
		@password				,			-- password
		@cpId					,			-- cpId
		@userSurName				,			-- userName(?)
		@userFirstName				,			-- userName(??)
		@gameServiceId			,			-- ?? gameServiceId
		null					,			-- ??????
		@sex					,			-- ??
		CONVERT(smalldatetime, @birthday)	,			-- ????
		1				,			-- ? / ?
		@email					,			-- E-mail
		null				,			-- ????
		@nation				,			-- ?
		@address				,			-- ????
		@phoneNumber				,			-- ????
		@passwordCheckQuestionTypeId	,			-- ???? ?? ??
		@passwordCheckAnswer		,		-- ???? ?? ??
		@MI					,
		@userKey				,
		@city					,
		@state					
		)
	IF @@ERROR <> 0
	BEGIN

		select @userNumber, @userId	, @password	, @cpId	, @userSurName, @userFirstName , @gameServiceId	, null, @sex , CONVERT(smalldatetime, @birthday)	,1	, @email	, null	, @nation	, @address, @phoneNumber	, @passwordCheckQuestionTypeId	,@passwordCheckAnswer		,@MI	 , @userKey	, @city		, @state	
		SET @msg = 'Please, contact us. ErrorCode:002' --'????? ?? ???. ErrorCode:002'
		SET @userNumber = -1	
	
		RETURN 1
	END
	EXEC procInsertUserHistory @userNumber
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:003' -- '????? ?? ???. ErrorCode:003'
		SET @userNumber = -1
		RETURN 1
	END
	INSERT INTO tblUserDetail (userNumber, handphoneNumber, jobTypeId, 
				isSendEmail)
	VALUES (@userNumber, @handPhoneNumber, @jobTypeId, @getMail)
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:004 '   -- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END

	--------------------
	INSERT tblUserGameService(userNumber, gameServiceId, startDt, endDt, limitTime, usedLimitTime, applyStartTime, applyEndTime, playableMinutes, usedPlayableMinutes, registDt, expireDt)
	VALUES(@userNumber, @gameServiceId, getdate(), dateadd(dd, 3, GETDATE()) , 0, 0, '0000', '2400', 0,0, GETDATE() , NULL)
	---------------------
		
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'Please, contact us. ErrorCode:005' -- '????? ?? ???. ErrorCode:004'
		SET @userNumber = -1
		RETURN 1
	END

	RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[procUserCheckAndOrderByItemBill]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
??? : ??? , ???
EMAIL :  dshan@n-cash.net , kalium37@n-cash.net
??? :  2006 - 3- 8
??? :  ITEM ??? ?? PPCARD ?? ?? 

REQUIRED : WITH ENCRYPT

*/
CREATE PROCEDURE [dbo].[procUserCheckAndOrderByItemBill]
	@cpId					AS	INT		
,	@userId				AS	NVARCHAR(32)		
,	@ppCardSerialNumber			AS	VARCHAR(12)
,	@pinCode				AS	VARCHAR(50)
,	@returnValue				AS	INT		OUTPUT
,	@msg					AS	VARCHAR(100) 	OUTPUT

AS

DECLARE @userNumber	INT
DECLARE @returnCode	 	INT
DECLARE @productId		INT
DECLARE @gameServiceId  	INT
DECLARE @orderNumber     	INT
DECLARE @orderTypeid      	TINYINT
DECLARE @eventId  		INT
DECLARE @adminLogId 	INT
DECLARE @ppCardId 		INT
DECLARE @productAmount	INT
DECLARE @chargeTypeId 	INT
DECLARE @transactionId	INT
DECLARE @chargeTransactionId INT
DECLARE @orderTransactionId INT
DECLARE @productTypeId	TINYINT

--SET @gameServiceId =  1
SET @orderNumber= NULL
SET @orderTypeId=NULL 
SET @eventId= NULL
SET @adminLogId = 0


	SELECT @userNumber = userNumber , @gameServiceId = gameServiceId 
	FROM tblUserInfo WITH (READUNCOMMITTED) 
	WHERE userId = @userId 
	
	IF @userNumber IS NULL  OR @@ROWCOUNT <> 1 
			BEGIN
				SET @returnValue = -3000
				SET @msg = 'not exists User'
				RETURN 
			END

	EXEC procGetPpcardInfoByItemBill @gameServiceId, @userId, @ppCardSerialNumber, @pinCode, @ppcardId OUTPUT
				,  @productId OUTPUT, @productAmount  OUTPUT ,  @productTypeId OUTPUT , @returnCode OUTPUT

	IF  @returnCode = -6   
	BEGIN
		SELECT @returnValue = -1000, @msg = 'not exists User'  --?? ?? ?? ??
		RETURN		
	END
	IF  @returnCode = -1 
	BEGIN
		SELECT @returnValue = -1001, @msg = 'ppCardSerialNumber  not exists'  --???? ppCardSerialNumber ??
		RETURN		
	END	
	IF  @returnCode = -2
	BEGIN
		SELECT @returnValue = -1002, @msg = 'PinCode not Equal '  ----pinCode ???
		RETURN		
	END	
	IF  @returnCode = -3
	BEGIN

		SELECT @returnValue = -1003, @msg = 'Already used PPCard '  ----?? ??? ppcard
		RETURN		
	END	
	IF  @returnCode = -4
	BEGIN
		SELECT @returnValue = -1004, @msg = ' validdate  Over PPCard '  ----?? ?? ??  ppcard
		RETURN		
	END	
	IF  @returnCode = -5
	BEGIN
		SELECT @returnValue = -1005, @msg = ' Haking User '  ---?? ??? ??? ?? ? 4? ??? ?? 
		RETURN		
	END	

	IF  @productTypeId  = 1 OR @productTypeId = 5 
		BEGIN

			----??, ?? ?? ?? ,??? ???? ??? ???? ?? ??
			EXEC  procIsCanOrder  @userNumber, @productId, @gameServiceid, @returnCode output
			IF @returnCode  = -1
			BEGIN		
				SELECT  @returnValue = -1006 , @msg = 'Time Base  yet  Remain '  --??? ??? ?? ?? ?? ??
				RETURN
			END
			IF @returnCode  = -2
			BEGIN		
				SELECT  @returnValue = -1007 , @msg = 'Day Base Yet Remain'  --?? ???  ??? ?? ?? ?? ??
				RETURN
			END
		
		
			BEGIN TRAN 
			DECLARE @expireDtTypeId  INT
			--??? ???? ?? ??? ????? ?? ??? ??? ??? ??---------------------------
			--??? ?? ?? ?? ??????  ?? ?? ??? ???? ?? ????
			IF @returnCode  = 2
			BEGIN		
				SET @expireDtTypeId= 3
				EXEC procUpdateUserGameServiceFixedTimeEmpty @userNumber, @expireDtTypeId				
			END	
			IF @@ERROR <> 0 
			BEGIN
				SELECT @returnValue = -3004 , @msg = 'EXpireDt  ERROR'
				ROLLBACK
				RETURN							
			END
			--??? ???? ?? ??? ????? ?? ??? ??? ??? ?----------------

			--?? ?? ??
			SET @chargeTypeId =  3 		-- ?? ?? PPCARD 
			EXEC procCharge @chargeTypeId, @userNumber, @cpId, @productAmount, @adminLogId,  @chargeTransactionId OUTPUT
			IF @chargeTransactionId < 1 
			BEGIN
				IF @chargeTransactionId  = -201
				BEGIN
					SELECT @returnValue = -2000, @msg = 'Charge Error'
					ROLLBACK
					RETURN							
				END
				IF @chargeTransactionId  = -401
				BEGIN
					SELECT @returnValue = -2001, @msg = 'IN ERROR'
					ROLLBACK
					RETURN							
				END
		
			END
			--?? ?? ?


			---?? ?? ??
			EXEC procOrderByItemBill @userNumber, @cpId, @gameServiceId, @productId, @chargeTransactionId ,  @orderNumber, @orderTypeId, @productAmount, @eventId, @adminLogId, @orderTransactionId OUTPUT
			IF @orderTransactionId  < 1 
			BEGIN
				IF @orderTransactionId  = -201  ---apply? 0  ??? ?? ???? ?? ?? ?? ??? ???
				BEGIN
					SELECT @returnValue = -3000, @msg = 'not exists User'
					ROLLBACK
					RETURN							
				END
				IF @orderTransactionId  = -501 ---?? ?? ?? ???
				BEGIN
					SELECT @returnValue = -3001, @msg = 'Can Not Order User'
					ROLLBACK
					RETURN							
				END
		
				IF @orderTransactionId  = -203   --?? ?? ?? ?? 
				BEGIN
					SELECT @returnValue = -3003 , @msg = 'Can Not Order Product'
					ROLLBACK
					RETURN							
				END
		
				IF @orderTransactionId  = -206   --??? productType
				BEGIN
					SELECT @returnValue = -3003 , @msg = 'Can Not Order Product'
					ROLLBACK
					RETURN							
				END
		
				 ---DB INSERT ERROR  IN(order, userGameService, userGameServiceHistory fail ,)
				IF @orderTransactionId  = -401 
				BEGIN
					SELECT @returnValue = -3004 , @msg = 'DB INSERT ERROR'
					ROLLBACK
					RETURN							
				END
		
				---???? ?? ???
				---DB INSERT ERROR  IN(order, userGameService, userGameServiceHistory fail)
				SELECT @returnValue = -3005 , @msg = 'ETC ERROR'
				ROLLBACK
				RETURN							
			END
			---?? ?? ?
		
		
		
			---?? ?? ??
			EXEC procInsertPpCardUserInfoMapping @ppCardId, @userNumber, @orderTRansactionId, @returnCode OUTPUT
			IF @@ERROR <> 0 
				BEGIN
					SELECT @returnValue =-10000 , @msg = 'Unknown  Error'
					ROLLBACK
					RETURN
				END
			ELSE IF @returnCode = -1
				BEGIN
					SELECT @returnValue = -4000 , @msg = 'Alredy used PpCard'
					ROLLBACK
					RETURN							
				END
			ELSE IF @returnCode = -2
				BEGIN
					SELECT @returnValue = -4001 , @msg = 'ppCardInsert  Error'
					ROLLBACK
					RETURN							
				END
			ELSE
			BEGIN
				SELECT @returnValue = 1 , @msg = 'success'
				COMMIT
				RETURN
			END


			--?? ?? ?
			
		END 
	ELSE IF @productTypeId = 10

		BEGIN
		
			BEGIN TRAN
				
				SET @chargeTypeId =  17	--ONLY ITEMBILLING CHARGETYPEID
				EXEC procChargeByItemBill @chargeTypeId	
							,	@userNumber	
							,	@cpId		
							,	@productAmount	
							,	@adminLogId		
							,	@transactionId		OUTPUT
				


				IF @@ERROR <> 0 OR @transactionId IS NULL OR @transactionId < 0 
					BEGIN
						SELECT @returnValue = -3004 , @msg = 'DB INSERT ERROR'
						ROLLBACK
						RETURN
					END

				EXEC procInsertPpCardUserInfoMapping @ppCardId, @userNumber, @transactionId, @returnCode OUTPUT
				IF @returnCode = -1 OR @@ERROR <> 0 OR @transactionId IS NULL
					BEGIN
						SELECT @returnValue = -4000 , @msg = 'Already used PpCard'
						ROLLBACK
						RETURN							
					END
				ELSE IF @returnCode = -2  
					BEGIN
						SELECT @returnValue = -4001 , @msg = 'ppCard Insert  Error'
						ROLLBACK
						RETURN							
					END
				
				ELSE 
					BEGIN
						SELECT @returnValue = 1 , @msg = 'success'
						COMMIT
					END				
		END
GO
/****** Object:  StoredProcedure [dbo].[procUserCheckAndChargeForEvent]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procUserCheckAndChargeForEvent]
	@cpId				AS	INT
,	@userId				AS	NVARCHAR(32)
,	@ppCardSerialNumber		AS	VARCHAR(12)
,	@pinCode			AS	VARCHAR(50)
,	@returnValue			AS	INT		OUTPUT
,	@msg				AS	VARCHAR(100) 	OUTPUT

AS

DECLARE @userNumber		INT
DECLARE @returnCode	 	INT
DECLARE @productId		INT
DECLARE @gameServiceId  	INT
DECLARE @orderNumber     	INT
DECLARE @orderTypeid      	TINYINT
DECLARE @eventId  		INT
DECLARE @adminLogId 		INT
DECLARE @ppCardId 		INT
DECLARE @productAmount		INT
DECLARE @chargeTypeId 		INT
DECLARE @transactionId		INT
DECLARE @chargeTransactionId 	INT
DECLARE @orderTransactionId 	INT
DECLARE @productTypeId		TINYINT
DECLARE @today			DATETIME

--SET @gameServiceId =  1
SET @orderNumber= NULL
SET @orderTypeId=NULL
SET @eventId= NULL
SET @adminLogId = 0
SET @today = GETDATE()

	SELECT @userNumber = userNumber , @gameServiceId = gameServiceId
	FROM tblUserInfo WITH (READUNCOMMITTED)
	WHERE userId = @userId

	IF @userNumber IS NULL  OR @@ROWCOUNT <> 1
			BEGIN
				SET @returnValue = -3000
				SET @msg = 'not exists User'
				RETURN
			END

	EXEC procGetPpcardInfoByItemBill @gameServiceId, @userId, @ppCardSerialNumber, @pinCode, @ppcardId OUTPUT
				,  @productId OUTPUT, @productAmount  OUTPUT ,  @productTypeId OUTPUT , @returnCode OUTPUT

	IF @today > '2006-07-21' AND @today < '2006-08-01'
	--IF @today > '2006-07-28' AND @today < '2006-08-01'
	BEGIN
		SET @productAmount = @productAmount + (@productAmount * 0.2)
	END

	IF  @returnCode = -6
	BEGIN
		SELECT @returnValue = -1000, @msg = 'not exists User'  --?? ?? ?? ??
		RETURN
	END
	IF  @returnCode = -1
	BEGIN
		SELECT @returnValue = -1001, @msg = 'ppCardSerialNumber  not exists'  --???? ppCardSerialNumber ??
		RETURN
	END
	IF  @returnCode = -2
	BEGIN
		SELECT @returnValue = -1002, @msg = 'PinCode not Equal '  ----pinCode ???
		RETURN
	END
	IF  @returnCode = -3
	BEGIN

		SELECT @returnValue = -1003, @msg = 'Already used PPCard '  ----?? ??? ppcard
		RETURN
	END
	IF  @returnCode = -4
	BEGIN
		SELECT @returnValue = -1004, @msg = ' validdate  Over PPCard '  ----?? ?? ??  ppcard
		RETURN
	END
	IF  @returnCode = -5
	BEGIN
		SELECT @returnValue = -1005, @msg = ' Haking User '  ---?? ??? ??? ?? ? 4? ??? ??
		RETURN
	END

	IF  @productTypeId  = 1 OR @productTypeId = 5
		BEGIN


			BEGIN TRAN
			--?? ?? ??
			SET @chargeTypeId =  3 		-- ?? ?? PPCARD
			EXEC procCharge @chargeTypeId, @userNumber, @cpId, @productAmount, @adminLogId,  @chargeTransactionId OUTPUT
			IF @chargeTransactionId < 1
			BEGIN
				IF @chargeTransactionId  = -201
				BEGIN
					SELECT @returnValue = -2000, @msg = 'Charge Error'
					ROLLBACK
					RETURN
				END
				IF @chargeTransactionId  = -401
				BEGIN
					SELECT @returnValue = -2001, @msg = 'IN ERROR'
					ROLLBACK
					RETURN
				END

			END
			--?? ?? ?



			---?? ?? ??
			EXEC procInsertPpCardUserInfoMapping @ppCardId, @userNumber, @chargeTransactionId, @returnCode OUTPUT
			IF @@ERROR <> 0
				BEGIN
					SELECT @returnValue =-10000 , @msg = 'Unknown  Error'
					ROLLBACK
					RETURN
				END
			ELSE IF @returnCode = -1
				BEGIN
					SELECT @returnValue = -4000 , @msg = 'Alredy used PpCard'
					ROLLBACK
					RETURN
				END
			ELSE IF @returnCode = -2
				BEGIN
					SELECT @returnValue = -4001 , @msg = 'ppCardInsert  Error'
					ROLLBACK
					RETURN
				END
			ELSE
			BEGIN
				SELECT @returnValue = 1 , @msg = 'success'
				COMMIT
				RETURN
			END


			--?? ?? ?

		END
	ELSE IF @productTypeId = 10

		BEGIN

			BEGIN TRAN

				SET @chargeTypeId =  17	--ONLY ITEMBILLING CHARGETYPEID
				EXEC procChargeByItemBill @chargeTypeId
							,	@userNumber
							,	@cpId
							,	@productAmount
							,	@adminLogId
							,	@transactionId		OUTPUT



				IF @@ERROR <> 0 OR @transactionId IS NULL OR @transactionId < 0
					BEGIN
						SELECT @returnValue = -3004 , @msg = 'DB INSERT ERROR'
						ROLLBACK
						RETURN
					END

				EXEC procInsertPpCardUserInfoMapping @ppCardId, @userNumber, @transactionId, @returnCode OUTPUT
				IF @returnCode = -1 OR @@ERROR <> 0 OR @transactionId IS NULL
					BEGIN
						SELECT @returnValue = -4000 , @msg = 'Already used PpCard'
						ROLLBACK
						RETURN
					END
				ELSE IF @returnCode = -2
					BEGIN
						SELECT @returnValue = -4001 , @msg = 'ppCard Insert  Error'
						ROLLBACK
						RETURN
					END

				ELSE
					BEGIN
						SELECT @returnValue = 1 , @msg = 'success'
						COMMIT
					END
		END
GO
/****** Object:  StoredProcedure [dbo].[procUserCheckAndCharge_Free_Test]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procUserCheckAndCharge_Free_Test]
	@cpId				AS	INT
,	@userId				AS	NVARCHAR(32)
,	@ppCardSerialNumber		AS	VARCHAR(12)
,	@pinCode			AS	VARCHAR(50)
,	@returnValue			AS	INT		OUTPUT
,	@msg				AS	VARCHAR(100) 	OUTPUT

AS

DECLARE @userNumber		INT
DECLARE @returnCode	 	INT
DECLARE @productId		INT
DECLARE @gameServiceId  	INT
DECLARE @orderNumber     	INT
DECLARE @orderTypeid      	TINYINT
DECLARE @eventId  		INT
DECLARE @adminLogId 		INT
DECLARE @ppCardId 		INT
DECLARE @productAmount		INT
DECLARE @chargeTypeId 		INT
DECLARE @transactionId		INT
DECLARE @chargeTransactionId 	INT
DECLARE @orderTransactionId 	INT
DECLARE @productTypeId		TINYINT
DECLARE @today			DATETIME

--SET @gameServiceId =  1
SET @orderNumber= NULL
SET @orderTypeId=NULL
SET @eventId= NULL
SET @adminLogId = 0
SET @today = GETDATE()

	SELECT @userNumber = userNumber , @gameServiceId = gameServiceId
	FROM tblUserInfo WITH (READUNCOMMITTED)
	WHERE userId = @userId

	IF @userNumber IS NULL  OR @@ROWCOUNT <> 1
			BEGIN
				SET @returnValue = -3000
				SET @msg = 'not exists User'
				RETURN
			END

	EXEC procGetPpcardInfoByItemBill @gameServiceId, @userId, @ppCardSerialNumber, @pinCode, @ppcardId OUTPUT
				,  @productId OUTPUT, @productAmount  OUTPUT ,  @productTypeId OUTPUT , @returnCode OUTPUT

	
	IF @today > '2006-12-15 00:00' AND @today < '2006-12-25 23:59' --AND @productTypeId <> 20
	BEGIN
		SET @productAmount = @productAmount + (@productAmount * 0.2)
	END
	

	IF  @returnCode = -6
	BEGIN
		SELECT @returnValue = -1000, @msg = 'not exists User'  --?? ?? ?? ??
		RETURN
	END
	IF  @returnCode = -1
	BEGIN
		SELECT @returnValue = -1001, @msg = 'ppCardSerialNumber  not exists'  --???? ppCardSerialNumber ??
		RETURN
	END
	IF  @returnCode = -2
	BEGIN
		SELECT @returnValue = -1002, @msg = 'PinCode not Equal '  ----pinCode ???
		RETURN
	END
	IF  @returnCode = -3
	BEGIN

		SELECT @returnValue = -1003, @msg = 'Already used PPCard '  ----?? ??? ppcard
		RETURN
	END
	IF  @returnCode = -4
	BEGIN
		SELECT @returnValue = -1004, @msg = ' validdate  Over PPCard '  ----?? ?? ??  ppcard
		RETURN
	END
	IF  @returnCode = -5
	BEGIN
		SELECT @returnValue = -1005, @msg = ' Haking User '  ---?? ??? ??? ?? ? 4? ??? ??
		RETURN
	END

	IF  @productTypeId  IN(1, 5, 20)-- Test IN(1, 5, 17)	-- Real IN(1, 5, 20)
		BEGIN


			BEGIN TRAN
			--?? ?? ??
			IF @productTypeId = 20	-- Real 20 -- TEST 17
				SET @chargeTypeId = 19		-- PromoPpCard(Free) - REAL 19 - TEST 20
			ELSE
				SET @chargeTypeId =  3 		-- ?? ?? PPCARD

			EXEC procCharge @chargeTypeId, @userNumber, @cpId, @productAmount, @adminLogId,  @chargeTransactionId OUTPUT
			IF @chargeTransactionId < 1
			BEGIN
				IF @chargeTransactionId  = -201
				BEGIN
					SELECT @returnValue = -2000, @msg = 'Charge Error'
					ROLLBACK
					RETURN
				END
				IF @chargeTransactionId  = -401
				BEGIN
					SELECT @returnValue = -2001, @msg = 'IN ERROR'
					ROLLBACK
					RETURN
				END

			END
			--?? ?? ?



			---?? ?? ??
			EXEC procInsertPpCardUserInfoMapping @ppCardId, @userNumber, @chargeTransactionId, @returnCode OUTPUT
			IF @@ERROR <> 0
				BEGIN
					SELECT @returnValue =-10000 , @msg = 'Unknown  Error'
					ROLLBACK
					RETURN
				END
			ELSE IF @returnCode = -1
				BEGIN
					SELECT @returnValue = -4000 , @msg = 'Alredy used PpCard'
					ROLLBACK
					RETURN
				END
			ELSE IF @returnCode = -2
				BEGIN
					SELECT @returnValue = -4001 , @msg = 'ppCardInsert  Error'
					ROLLBACK
					RETURN
				END
			ELSE
			BEGIN
				SELECT @returnValue = 1 , @msg = 'success'
				COMMIT
				RETURN
			END


			--?? ?? ?

		END
	ELSE IF @productTypeId = 10

		BEGIN

			BEGIN TRAN

				SET @chargeTypeId =  17	--ONLY ITEMBILLING CHARGETYPEID
				EXEC procChargeByItemBill @chargeTypeId
							,	@userNumber
							,	@cpId
							,	@productAmount
							,	@adminLogId
							,	@transactionId		OUTPUT



				IF @@ERROR <> 0 OR @transactionId IS NULL OR @transactionId < 0
					BEGIN
						SELECT @returnValue = -3004 , @msg = 'DB INSERT ERROR'
						ROLLBACK
						RETURN
					END

				EXEC procInsertPpCardUserInfoMapping @ppCardId, @userNumber, @transactionId, @returnCode OUTPUT
				IF @returnCode = -1 OR @@ERROR <> 0 OR @transactionId IS NULL
					BEGIN
						SELECT @returnValue = -4000 , @msg = 'Already used PpCard'
						ROLLBACK
						RETURN
					END
				ELSE IF @returnCode = -2
					BEGIN
						SELECT @returnValue = -4001 , @msg = 'ppCard Insert  Error'
						ROLLBACK
						RETURN
					END

				ELSE
					BEGIN
						SELECT @returnValue = 1 , @msg = 'success'
						COMMIT
					END
		END
GO
/****** Object:  StoredProcedure [dbo].[procUserCheckAndCharge]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procUserCheckAndCharge]
	@cpId				AS	INT
,	@userId				AS	NVARCHAR(32)
,	@ppCardSerialNumber		AS	VARCHAR(12)
,	@pinCode			AS	VARCHAR(50)
,	@returnValue			AS	INT		OUTPUT
,	@msg				AS	VARCHAR(100) 	OUTPUT

AS

DECLARE @userNumber		INT
DECLARE @returnCode	 	INT
DECLARE @productId		INT
DECLARE @gameServiceId  	INT
DECLARE @orderNumber     	INT
DECLARE @orderTypeid      	TINYINT
DECLARE @eventId  		INT
DECLARE @adminLogId 		INT
DECLARE @ppCardId 		INT
DECLARE @productAmount		INT
DECLARE @chargeTypeId 		INT
DECLARE @transactionId		INT
DECLARE @chargeTransactionId 	INT
DECLARE @orderTransactionId 	INT
DECLARE @productTypeId		TINYINT
DECLARE @today			DATETIME

--SET @gameServiceId =  1
SET @orderNumber= NULL
SET @orderTypeId=NULL
SET @eventId= NULL
SET @adminLogId = 0
SET @today = GETDATE()

	SELECT @userNumber = userNumber , @gameServiceId = gameServiceId
	FROM tblUserInfo WITH (READUNCOMMITTED)
	WHERE userId = @userId

	IF @userNumber IS NULL  OR @@ROWCOUNT <> 1
			BEGIN
				SET @returnValue = -3000
				SET @msg = 'not exists User'
				RETURN
			END

	EXEC procGetPpcardInfoByItemBill @gameServiceId, @userId, @ppCardSerialNumber, @pinCode, @ppcardId OUTPUT
				,  @productId OUTPUT, @productAmount  OUTPUT ,  @productTypeId OUTPUT , @returnCode OUTPUT

	
	IF @today > '2006-12-15 00:00' AND @today < '2006-12-25 23:59' --AND @productTypeId <> 20
	BEGIN
		SET @productAmount = @productAmount + (@productAmount * 0.2)
	END
	

	IF  @returnCode = -6
	BEGIN
		SELECT @returnValue = -1000, @msg = 'not exists User'  --?? ?? ?? ??
		RETURN
	END
	IF  @returnCode = -1
	BEGIN
		SELECT @returnValue = -1001, @msg = 'ppCardSerialNumber  not exists'  --???? ppCardSerialNumber ??
		RETURN
	END
	IF  @returnCode = -2
	BEGIN
		SELECT @returnValue = -1002, @msg = 'PinCode not Equal '  ----pinCode ???
		RETURN
	END
	IF  @returnCode = -3
	BEGIN

		SELECT @returnValue = -1003, @msg = 'Already used PPCard '  ----?? ??? ppcard
		RETURN
	END
	IF  @returnCode = -4
	BEGIN
		SELECT @returnValue = -1004, @msg = ' validdate  Over PPCard '  ----?? ?? ??  ppcard
		RETURN
	END
	IF  @returnCode = -5
	BEGIN
		SELECT @returnValue = -1005, @msg = ' Haking User '  ---?? ??? ??? ?? ? 4? ??? ??
		RETURN
	END

	IF  @productTypeId  IN(1, 5, 20)-- Test IN(1, 5, 17)	-- Real IN(1, 5, 20)
		BEGIN


			BEGIN TRAN
			--?? ?? ??
			IF @productTypeId = 20	-- Real 20 -- TEST 17
				SET @chargeTypeId = 19		-- PromoPpCard(Free) - REAL 19 - TEST 20
			ELSE
				SET @chargeTypeId =  3 		-- ?? ?? PPCARD

			EXEC procCharge @chargeTypeId, @userNumber, @cpId, @productAmount, @adminLogId,  @chargeTransactionId OUTPUT
			IF @chargeTransactionId < 1
			BEGIN
				IF @chargeTransactionId  = -201
				BEGIN
					SELECT @returnValue = -2000, @msg = 'Charge Error'
					ROLLBACK
					RETURN
				END
				IF @chargeTransactionId  = -401
				BEGIN
					SELECT @returnValue = -2001, @msg = 'IN ERROR'
					ROLLBACK
					RETURN
				END

			END
			--?? ?? ?



			---?? ?? ??
			EXEC procInsertPpCardUserInfoMapping @ppCardId, @userNumber, @chargeTransactionId, @returnCode OUTPUT
			IF @@ERROR <> 0
				BEGIN
					SELECT @returnValue =-10000 , @msg = 'Unknown  Error'
					ROLLBACK
					RETURN
				END
			ELSE IF @returnCode = -1
				BEGIN
					SELECT @returnValue = -4000 , @msg = 'Alredy used PpCard'
					ROLLBACK
					RETURN
				END
			ELSE IF @returnCode = -2
				BEGIN
					SELECT @returnValue = -4001 , @msg = 'ppCardInsert  Error'
					ROLLBACK
					RETURN
				END
			ELSE
			BEGIN
				SELECT @returnValue = 1 , @msg = 'success'
				COMMIT
				RETURN
			END


			--?? ?? ?

		END
	ELSE IF @productTypeId = 10

		BEGIN

			BEGIN TRAN

				SET @chargeTypeId =  17	--ONLY ITEMBILLING CHARGETYPEID
				EXEC procChargeByItemBill @chargeTypeId
							,	@userNumber
							,	@cpId
							,	@productAmount
							,	@adminLogId
							,	@transactionId		OUTPUT



				IF @@ERROR <> 0 OR @transactionId IS NULL OR @transactionId < 0
					BEGIN
						SELECT @returnValue = -3004 , @msg = 'DB INSERT ERROR'
						ROLLBACK
						RETURN
					END

				EXEC procInsertPpCardUserInfoMapping @ppCardId, @userNumber, @transactionId, @returnCode OUTPUT
				IF @returnCode = -1 OR @@ERROR <> 0 OR @transactionId IS NULL
					BEGIN
						SELECT @returnValue = -4000 , @msg = 'Already used PpCard'
						ROLLBACK
						RETURN
					END
				ELSE IF @returnCode = -2
					BEGIN
						SELECT @returnValue = -4001 , @msg = 'ppCard Insert  Error'
						ROLLBACK
						RETURN
					END

				ELSE
					BEGIN
						SELECT @returnValue = 1 , @msg = 'success'
						COMMIT
					END
		END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateVirtualIpAddr]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateVirtualIpAddr    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procUpdateVirtualIpAddr
	Creation Date		:	2002. 01.26
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	VIRTUAL IP??
	
	Input Parameters :	
				@virtualIpAddrId			AS		INT
				@realIpAddr			AS		nvarchar(11)	=	NULL
				@realStartIp			AS		TINYINT	=	NULL
				@virtualIpAddr			AS		nvarchar(11)
				@startIp			AS		TINYINT
				@endIp				AS		TINYINT
				@ipAddrId			AS		INT		=	NULL
				@adminNumber			AS		INT
				@memo				AS		nvarchar(200)
	Output Parameters:	
				@returnCode			AS		INT	OUTPUT
				
	Return Status:		
				1 : ?? ??.
				2 : ?? ???? ?? realIp? ????? ??.
				3 : ?? ???? ?? virtualIp? ????? ??.
	Usage		:	
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblIpAddr(S,I) , tblVirtualIpHistory , tblVirtualIp , tblAdminLog
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateVirtualIpAddr]
	@virtualIpAddrId			AS		INT
,	@gamebangId			AS		INT
,	@realIpAddr			AS		nvarchar(11)
,	@realStartIp			AS		TINYINT
,	@virtualIpAddr			AS		nvarchar(11)
,	@startIp			AS		TINYINT
,	@endIp				AS		TINYINT
,	@ipAddrId			AS		INT
,	@adminNumber			AS		INT
,	@memo				AS		nvarchar(200)
,	@returnCode			AS		INT		OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@checkIpAddrId				AS		INT
DECLARE	@checkVirtualIpAddrId				AS		INT
DECLARE	@adminLogId					AS		INT
DECLARE	@new_ipAddrId					AS		INT
DECLARE	@procCheckRealIpInVirtualIpReturnCode		AS		INT
------------------------?? ?? ?-------------------
EXEC procCheckRealIpInVirtualIp @virtualIpAddrId , @gamebangId , @realIpAddr , @realStartIp , @ipAddrId , @adminNumber , @memo , @procCheckRealIpInVirtualIpReturnCode OUTPUT
IF(@procCheckRealIpInVirtualIpReturnCode = -1)
	BEGIN
		SET @returnCode = 3			--??? realIp? ?? ????? ?? ??????
		RETURN
	
	END
ELSE IF(@procCheckRealIpInVirtualIpReturnCode = -2)
	BEGIN
		SET @returnCode = 4			--??? realIp? ????.
		RETURN
	END
ELSE
	BEGIN
		SET @new_ipAddrId = @procCheckRealIpInVirtualIpReturnCode
	END
--virtualIp ?? ??
SELECT @checkVirtualIpAddrId = virtualIpAddrId FROM tblVirtualIpAddr WHERE ipAddrId = @new_ipAddrId AND @virtualIpAddrId <>@virtualIpAddrId AND virtualIpAddr = @virtualIpAddr AND (virtualStartIp  <= @endIp AND virtualEndIp >= @startIp) AND apply = 1
IF(@checkVirtualIpAddrId IS NOT NULL)		--??? virtualIp? ??.
	BEGIN
		SET @returnCode = 2
		RETURN
	END
--virtual Ip ??
UPDATE tblVirtualIpAddr
	SET 
		ipAddrId = @new_ipAddrId 
	,	virtualIpAddr = @virtualIpAddr
	,	 virtualStartIp = @startIp
	,	 virtualEndIp = @endIp
	,	registDt = GETDATE()
	WHERE virtualIpAddrId = @virtualIpAddrId
INSERT INTO tblAdminLog 
	VALUES(
		'Amend'
	,	'tblVirtualIpAddr'
	,	@adminNumber
	,	@memo
	,	GETDATE()
	)
SET @adminLogId = @@IDENTITY
INSERT INTO tblVirtualIpAddrHistory
	SELECT virtualIpAddrId , ipAddrId , isRealIp , virtualIpAddr , virtualStartIp , virtualEndIp , registDt , apply , @adminLogId
	FROM tblVirtualIpAddr
	WHERE virtualIpAddrId = @virtualIpAddrId
SET @returnCode = 1
GO
/****** Object:  StoredProcedure [dbo].[procUpdateUserForAdmin]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateUserForAdmin    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procUpdateUser
	Creation Date		:	2002. 3. 18
	Written by		:	? ??
	E-Mail by 		:	goodfeel@n-cash.net
	Purpose			:	???? ??? ??
	Input Parameters :	
		@userId				as	nvarchar(32)		
		@cpId					as	int			
		@password				as	nvarchar(32)		
		@userName				as	nvarchar(16)		
		@ssno					as	nvarchar(13)		
		@birthday				as	smalldatetime		
		@isSolar				as	bit			
		@zipcode				as	nchar(6)			
		@address				as	nvarchar(64)		
		@addressDetail				as	nvarchar(64)		
		@phoneNumber				as	nvarchar(16)		
		@email					as	nvarchar(64)		
		@passwordCheckQuestionTypeId	as	int
		@passwordCheckAnswer		as	nvarchar(64)		
		@userNumber				as	int		OUTPUT
			
	return?:
	Return Status:		
		Nothing
	
	Usage: 			
		EXEC procAdminLogin subsub
	Call by		:	AdminLoginExec.asp
	Calls		: 	Nothing
	Access Table 	: 	tblAdmin(S)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/

CREATE PROCEDURE [dbo].[procUpdateUserForAdmin]
	@userNumber				as	int
,	@cpId					as	int
,	@password				as	nvarchar(70)
,	@userSurName			as	nvarchar(64)
,	@userFirstName			as	nvarchar(64)
,	@userTypeId				as	int
,	@userStatusId				as	int
,	@sex					as	bit
,	@birthday				as	nvarchar(16)
,	@nation				as	nvarchar(64)	
,	@address				as	nvarchar(200)			
,	@phoneNumber				as	nvarchar(16)		
,	@email					as	nvarchar(64)		
,	@passwordCheckQuestionTypeId	as	nvarchar(64)
,	@passwordCheckAnswer		as	nvarchar(64)		
,	@handphoneNumber 			as	nvarchar(16)
,	@jobTypeId				as	nvarchar(50)
,	@getMail				as	bit
,	@parentName				as	nvarchar(12)
,	@parentPhoneNumber			as	nvarchar(16)
,	@adminNumber			as	int
,	@memo				as	nvarchar(100)
--,	@userId				as 	nvarchar(50)
,	@city					as	nvarchar(50)
,	@state					as	nvarchar(50)
,	@userKey				as	nvarchar(7)
,	@MI					as	nvarchar(1)
,	@result					as	int	output

AS
DECLARE @adminLogId 		as int
DECLARE @now			as datetime
DEclare     @userId			as	 nvarchar(50)
--DECLARE @result			as	inT
	select @userId=userId  from tblUser where userNumber=@userNumber

BEGIN TRAN
	UPDATE 
		tblUser
	SET	
		userPwd = @password,
		cpId = @cpId,
		userTypeId = @userTypeId,
		userStatusId = @userStatusId
	WHERE
		userNumber = @userNumber		
	UPDATE 
		tblUserInfo
	SET 
		userPwd = @password,
		cpId = @cpId,
		userSurName = @userSurName,
		userFirstName = @userFirstName,
		userTypeId = @userTypeId,
		userStatusId = @userStatusId,
		sex = @sex,
		birthday = CONVERT(smalldatetime, @birthday), 
		nation = @nation,
		address = @address,
		phoneNumber = @phoneNumber, 
		email = @email, 
		passwordCheckQuestionTypeId = @passwordCheckQuestionTypeId, 
		passwordCheckAnswer = @passwordCheckAnswer
		, MI = @MI, userKey=@userKey


	WHERE 
		userNumber = @userNumber
	SET @now = getdate()	
	INSERT INTO tblAdminLog
	VALUES ('Amend', 'tblUserInfo', @adminNumber,  @memo, @now)
	SET @adminLogId = @@IDENTITY
	INSERT INTO 
		tblUserInfoHistory 
			(userNumber, userId, userPwd, cpId, userSurName, userFirstName,  userTypeId, userStatusId, gameServiceId, ssno, sex, birthday, 
			isSolar, email, zipcode,  address, phoneNumber, passwordCheckQuestionTypeId, city,nation, state, MI, userKey, 
			passwordCheckAnswer, cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply, updateDt, adminLogId)
		SELECT 
			userNumber, userId, userPwd, cpId, userSurName, userFirstName, userTypeId, userStatusId, gameServiceId, ssno, sex, birthday, 
			isSolar, email, zipcode,  address, phoneNumber, passwordCheckQuestionTypeId,city,nation, state, MI, userKey, 
 			passwordCheckAnswer,	cashBalance, pointToCashBalance, holdCashBalance, pointBalance, registDt, apply, @now, @adminLogId
		FROM tblUserInfo with (nolock)
		WHERE userNumber = @userNumber
	UPDATE 
		tblUserDetail
	SET 
		handphoneNumber = @handphoneNumber, 
		jobTypeId = @jobTypeId, 
		isSendEmail = @getMail, 
		parentPhoneNumber = @parentPhoneNumber
	WHERE 
		userNumber = @userNumber
		
	IF @@ERROR <> 0 
	BEGIN
		SET @result = 99
		rollback
		return 
	END	

	-- SELECT @userId, @userkey , @passwordCheckQuestionTypeId, @passwordCheckAnswer, @userFirstName, @MI, @userSurName, @birthday, @sex, @address, @city, @state, @nation , @handPhoneNumber, @phoneNumber
	EXEC UserLogin.dbo.AccountUpdateProfileFromBilling @userId, @userkey , @passwordCheckQuestionTypeId, @passwordCheckAnswer, @userFirstName, @MI, @userSurName, @birthday, @sex, @address, @city, @state, @nation , @handPhoneNumber, @phoneNumber, @email,  @result OUTPUT
	

	IF @result = 0
	BEGIN
		commit  TRAN 
	END
	ELSE
	BEGIN
		rollback TRAN 
	END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateUser_Test]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procUpdateUser_Test]
	@userId				as	nvarchar(50)
,	@userKey				as	nvarchar(7)
,	@firstName				as	nvarchar(30)
,	@mi					as	nvarchar(1)
,	@lastName				as	nvarchar(30)
,	@sex					as	tinyint	
,	@gameServiceId			as	int
,	@birthday				as	nvarchar(16)
--,	@zipcode				as	nchar(6)		
,	@nation				as	nvarchar(64)	
,	@city					as	nvarchar(64)
,	@state					as	nvarchar(64)
,	@address				as	nvarchar(64)		
,	@phoneNumber				as	nvarchar(16)		
,	@email					as	nvarchar(64)		
,	@passwordCheckQuestionTypeId	as	nvarchar(64)
,	@passwordCheckAnswer		as	nvarchar(64)		
,	@handPhoneNumber 			as	nvarchar(16)
,	@jobTypeId				as	nvarchar(64)
,	@getMail				as	bit
,	@result					as	int		output

AS
BEGIN TRAN
	DECLARE @userNumber  as 	int
	SELECT @userNumber = userNumber
	FROM tblUserInfo with (nolock)
	WHERE userId = @userId and gameServiceId = @gameServiceId
	UPDATE tblUserInfo
	SET birthday = CONVERT(smalldatetime, @birthday),  address = @address,
		phoneNumber = @phoneNumber, email = @email, 
		passwordCheckQuestionTypeId = @passwordCheckQuestionTypeId, passwordCheckAnswer = @passwordCheckAnswer
		, city=@city, nation = @nation ,state=@state,  userKey=@userKey , userSurName=@lastName, userFirstName=@firstName, MI=@mi
	WHERE userId = @userId and gameServiceId = @gameServiceId
	
	EXEC procInsertUserHistory @userNumber
	UPDATE tblUserDetail
	SET handphoneNumber = @handPhoneNumber, jobTypeId = @jobTypeId, isSendEmail = @getMail
	WHERE userNumber = @userNumber
	
	IF @@ERROR <> 0 
	BEGIN
	 ROLLBACK
	 SET @result = -1
	 RETURN
	END
	
	IF @sex = 0
		SET  @sex = 2

	--EXEC UserLogin.dbo.AccountUpdateProfileFromBilling @userId, @userkey , @passwordCheckQuestionTypeId, @passwordCheckAnswer, @firstName, @mi, @lastName, @birthday, @sex, @address, @city, @state, @nation , @handPhoneNumber, @phoneNumber, @result OUTPUT
	
	IF @@ERROR <> 0 
	BEGIN
		 ROLLBACK
		 SET @result = -1
		 RETURN
	END
	ELSE
	BEGIN
		COMMIT
		SET @result = 0
	END
	
	/*IF @result = 0
	BEGIN
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK
	END
	*/
GO
/****** Object:  StoredProcedure [dbo].[procUpdateUser]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[procUpdateUser]
	@userId				as	nvarchar(50)
,	@userKey				as	nvarchar(7)
,	@firstName				as	nvarchar(30)
,	@mi					as	nvarchar(1)
,	@lastName				as	nvarchar(30)
,	@sex					as	tinyint	
,	@gameServiceId			as	int
,	@birthday				as	nvarchar(16)
--,	@zipcode				as	nchar(6)		
,	@nation				as	nvarchar(64)	
,	@city					as	nvarchar(64)
,	@state					as	nvarchar(64)
,	@address				as	nvarchar(64)		
,	@phoneNumber				as	nvarchar(16)		
,	@email					as	nvarchar(64)		
,	@passwordCheckQuestionTypeId	as	nvarchar(64)
,	@passwordCheckAnswer		as	nvarchar(64)		
,	@handPhoneNumber 			as	nvarchar(16)
,	@jobTypeId				as	nvarchar(64)
,	@getMail				as	bit
,	@result					as	int		output

AS
BEGIN TRAN
	DECLARE @userNumber  as 	int
	SELECT @userNumber = userNumber
	FROM tblUserInfo with (nolock)
	WHERE userId = @userId and gameServiceId = @gameServiceId
	UPDATE tblUserInfo
	SET birthday = CONVERT(smalldatetime, @birthday),  address = @address,
		phoneNumber = @phoneNumber, email = @email, 
		passwordCheckQuestionTypeId = @passwordCheckQuestionTypeId, passwordCheckAnswer = @passwordCheckAnswer
		, city=@city, nation = @nation ,state=@state,  userKey=@userKey , userSurName=@lastName, userFirstName=@lastName, MI=@mi
	WHERE userId = @userId and gameServiceId = @gameServiceId
	
	EXEC procInsertUserHistory @userNumber
	UPDATE tblUserDetail
	SET handphoneNumber = @handPhoneNumber, jobTypeId = @jobTypeId, isSendEmail = @getMail
	WHERE userNumber = @userNumber
	
	IF @@ERROR <> 0 
	BEGIN
	 ROLLBACK
	 SET @result = -1
	 RETURN
	END
	
	IF @sex = 0
		SET  @sex = 2

	--EXEC UserLogin.dbo.AccountUpdateProfileFromBilling @userId, @userkey , @passwordCheckQuestionTypeId, @passwordCheckAnswer, @firstName, @mi, @lastName, @birthday, @sex, @address, @city, @state, @nation , @handPhoneNumber, @phoneNumber, @result OUTPUT
	
	IF @@ERROR <> 0 
	BEGIN
		 ROLLBACK
		 SET @result = -1
		 RETURN
	END
	ELSE
	BEGIN
		COMMIT
		SET @result = 0
	END
	
	/*IF @result = 0
	BEGIN
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK
	END
	*/
GO
/****** Object:  StoredProcedure [dbo].[procUpdateInjustice]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateInjustice    Script Date: 23/1/2546 11:40:28 ******/
CREATE PROCEDURE [dbo].[procUpdateInjustice]
	@memo			AS	nvarchar(50)
,	@userStatus		AS	int
,	@adminNumber		AS	int
,	@userNumber		AS	int
 AS
DECLARE @now			as datetime
	UPDATE 
		tblUser 
	SET
		userStatusId = @userStatus
	WHERE
		userNumber = @userNumber
	UPDATE 
		tblUserInfo
	SET
		userStatusId = @userStatus
	WHERE
		userNumber = @userNumber
SET @now = getdate()	
	INSERT INTO tblAdminLog
	VALUES ('Amend', 'tblUserInfo', @adminNumber,  @memo, @now)
	EXEC procInsertUserHistory @userNumber
GO
/****** Object:  StoredProcedure [dbo].[procUpdateCpChongphan]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateCpChongphan    Script Date: 23/1/2546 11:40:28 ******/
/*
******************************Essential Item******************************
	Stored Procedure	:	procUpdateCpChongphan 
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	CP? ???? ??
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateCpChongphan] 
	@cpId			AS			INT
,	@chongphanId		AS			INT
,	@memo			AS			nvarchar(200)
,	@adminNumber		AS			INT
AS
------------------------?? ??------------------------
DECLARE	@checkCpId	AS		INT
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
SELECT @checkCpId = cpId FROM tblCpChongphan WHERE chongphanId = @chongphanId
IF(@checkCpId IS NULL)
	BEGIN
		EXEC procInsertCpChongphan @cpId , @chongphanId , @adminNumber
	END
ELSE IF(@checkCpId <> @cpId)
	BEGIN
		UPDATE tblCpChongphan
		SET cpId = @cpId 
		WHERE chongphanId = @chongphanId
		--tblAdminLog? ???
		INSERT INTO tblAdminLog 
			VALUES(
				'Amend'
			,	'tblCpChongphan'
			,	@adminNumber
			,	@memo
			,	GETDATE()
			)
	
		SET @adminLogId = @@IDENTITY			
	
		INSERT INTO tblCpChongphanHistory
			SELECT cpChongphanId , cpId , chongphanId ,apply ,  GETDATE() , @adminLogId
			FROM tblCpChongphan
			WHERE chongphanId = @chongphanId
	END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateChongphanGamebang]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateChongphanGamebang    Script Date: 23/1/2546 11:40:28 ******/
/*	
******************************Essential Item******************************
	Stored Procedure	:	procUpdateChongphanGamebang 
	Creation Date		:	
	Written by		:	???
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	??? ??? ?? ??
	
******************************Optional Item******************************
	Input Parameters	:	
				
	Output Parameters	:	
			
	Return Status		:		
				
	Usage			: 			
	Call by			:	Nothing Yet
	Calls			: 	Nothing
	Access Table 		: 	
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateChongphanGamebang] 
	@gamebangId 			AS		INT
,	@chongphanId 			AS		INT
,	@memo				AS		nvarchar(200)
,	@adminNumber			AS		INT
AS
------------------------?? ??------------------------
DECLARE	@checkChongphanId	AS		INT
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
SELECT @checkChongphanId = chongphanId FROM tblChongphanGamebang WHERE gamebangId = @gamebangId
IF(@checkChongphanId IS NULL)
	BEGIN
		EXEC procInsertChongphanGamebang @gamebangId , @chongphanId , @adminNumber
	END
ELSE IF(@checkChongphanId <> @chongphanId)
	BEGIN
		UPDATE tblChongphanGamebang 
		SET chongphanId = @chongphanId 
		WHERE gamebangId = @gamebangId
		--tblAdminLog? ???
		INSERT INTO tblAdminLog 
			VALUES(
				'Amend'
			,	'tblChongphanGamebang'
			,	@adminNumber
			,	@memo
			,	GETDATE()
			)
	
		SET @adminLogId = @@IDENTITY			
	
		INSERT INTO tblChongphanGamebangHistory
			SELECT chongphanGamebangId , chongphanId , gamebangId , apply , GETDATE() , @adminLogId
			FROM tblChongphanGamebang
			WHERE gamebangId = @gamebangId
	END
GO
/****** Object:  StoredProcedure [dbo].[procTransactionForCancel]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procTransactionForCancel    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procDeleteCp
	Creation Date		:	2002. 04.02
	Written by		:	? ??
	E-Mail by 		:	gun26@n-cash.net
	Purpose			:	?? ??? transaction ??
	
	Input Parameters :	
				@gamebangId			AS		INT
	Output Parameters:	
				@returnTransactionId		AS		INT
				
	Return Status:		
				0: ??? ? ?? transactionId ? ??.
				??: ?? ??? transactionId
	Usage: 			
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	:
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procTransactionForCancel] 
	@gamebangId			AS		INT
,	@returnIpTransactionId		AS		INT		OUTPUT
,	@returnTimeTransactionId	AS		INT		OUTPUT
AS
DECLARE	@lastIpTransactionId	AS		INT
DECLARE	@lastTimeTransactionId	AS		INT
DECLARE	@startDt		AS		SMALLDATETIME
--IP?? ??
SELECT TOP 1 @lastIpTransactionId = transactionId , @startDt = startDt
FROM viewGamebangSalesList 
WHERE peerTransactionId IS NULL AND productLimitTime IS NULL AND transactionTypeId = 2 AND gamebangId = @gamebangId 
ORDER BY transactionId DESC
IF(@lastIpTransactionId IS NULL)
	BEGIN
		--??? ????? ??: ??? ??? ??.
		SET @returnIpTransactionId = 0
	END
--ELSE IF(@startDt > GETDATE())
--	BEGIN
		--???? ???? ???? ?? ??
--		SET @returnIpTransactionId = @lastIpTransactionId
--	END
--ELSE
--	BEGIN
		--???? ???? ??? ?? ?? ???
--		SET @returnIpTransactionId = 0		

ELSE
	BEGIN
		--???? ???? ??? ?? ?? ???	for cancel that not reserved product
		SET @returnIpTransactionId = @lastIpTransactionId		

	END
--?? ?? ??
SELECT TOP 1 @lastTimeTransactionId = transactionId , @startDt = startDt
FROM viewGamebangSalesList 
WHERE peerTransactionId IS NULL AND productLimitTime IS NOT NULL AND gamebangId = @gamebangId 
ORDER BY transactionId DESC
IF(@lastTimeTransactionId IS NULL)
	BEGIN
		--??? ????? ??: ??? ??? ??.
		SET @returnTimeTransactionId = 0
	END
ELSE
	BEGIN
		--??? ?? ????? ?? ???? ??????? ??? ?? ????? ???.
		SET @returnTimeTransactionId = @lastTimeTransactionId
	END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateGamebang]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.procUpdateGamebang    Script Date: 23/1/2546 11:40:28 ******/
/*
	Stored Procedure	:	procUpdateGamebang
	Creation Date		:	2002. 01.25
	Written by		:	? ??
	E-Mail by 		:	gun26@modusa.net
	Purpose			:	??? ??
	
	Input Parameters :	
				@gamebangId			AS		SMALLINT
				@gamebangName		AS		nvarchar(32)
				@zipCode			as	nchar(6)
				@address			AS		nvarchar(64)
				@tel				AS		nvarchar(32)
				@presidentName		AS		nvarchar(16)
				@limitTime			AS		INT
				@ipCount			AS		TINYINT
				@depositAmount		AS		INT
				@memo				AS		nvarchar(200)
				@adminNumber			AS		INT
	Output Parameters:	
				@returnCode			AS		TINYINT	OUTPUT
				
	Return Status:		
				1: ????? ?????.
	Usage: 			
	EXEC procUpdateGamebang  1, '???','158050','??? ??? ??? ?????' , '02-2281-6500' , '???' , 100,100,100000,'????',1, @returnCode OUTPUT
	Call by		:	Nothing Yet
	Calls		: 	Nothing
	Access Table 	: 	tblGamebang(S,U) , tblAdminLog(I) , tblGamebangHistory(I)
	S 	: 	SELECT
	I	:	INSERT
	U	:	UPDATE
	D	:	DELETE		
*/
CREATE PROCEDURE [dbo].[procUpdateGamebang] 
	@gamebangId			AS		SMALLINT
,	@gamebangName		AS		nvarchar(32)
,	@zipcode			as	nchar(6)
,	@address			AS		nvarchar(64)
,	@tel				AS		nvarchar(32)
,	@bizNumber			AS		nvarchar(16)
,	@presidentSurname		AS		nvarchar(64)
,	@presidentFirstName		AS		nvarchar(64)
,	@limitTime			AS		INT
,	@ipCount			AS		TINYINT
,	@depositAmount		AS		INT
,	@chongphanId			AS		INT
,	@ssno				AS		nvarchar(13)
,	@item				AS		nvarchar(50)
,	@bizStatus			AS		nvarchar(50)
,	@cellPhone			AS		nvarchar(18)
,	@email				AS		nvarchar(100)
,	@manageCode			AS		nvarchar(20)	=	NULL
,	@gamebangTypeId		AS		TINYINT		= 	NULL
,	@memo				AS		nvarchar(200)
,	@adminNumber			AS		INT		=             NULL
,	@returnCode			AS		TINYINT	OUTPUT
AS
------------------------?? ??------------------------
DECLARE	@adminLogId		AS		INT
------------------------?? ???--------------------
IF(EXISTS(SELECT * FROM tblGamebang WHERE bizNumber <> 'Register Later' AND bizNumber = @bizNumber AND apply = 1  AND gamebangId <> @gamebangId))			--?? ??? ???? ?? ??
	BEGIN
		SET @returnCode = 2				--?? ??? ????? ??? ?? ??? ?? ??
	END
ELSE IF(EXISTS(SELECT * FROM tblGamebang WHERE manageCode = @manageCode AND apply = 1 AND gamebangId <> @gamebangId))
	BEGIN
		SET @returnCode = 3				--?? ????? ??? ?? ??? ?? ??
	END
ELSE
	BEGIN
		IF(@adminNumber = 0 OR @adminNumber = 999 OR @adminNumber IS NULL)
			BEGIN
				--tblGamebang? ????.
				UPDATE tblGamebang 
				SET
					gamebangName = @gamebangName
				,	bizNumber = @bizNumber
				,	zipcode = @zipcode
				,	address = @address
				,	phoneNumber = @tel
				,	presidentSurname = @presidentSurname
				,	presidentFirstName = @presidentFirstName
				,	ssno = @ssno
				,	item = @item
				,	bizStatus = @bizStatus
				,	cellPhone = @cellPhone
				,	email = @email	
				,	manageCode = @manageCode
				,	gamebangTypeId = @gamebangTypeId
				WHERE gamebangId = @gamebangId
			
				SET @adminLogId = NULL
			END
		ELSE
			BEGIN
				--tblGamebang? ????.
				UPDATE tblGamebang 
				SET
					gamebangName = @gamebangName
				,	bizNumber = @bizNumber
				,	zipcode = @zipcode
				,	address = @address
				,	phoneNumber = @tel
				,	presidentSurname = @presidentSurname
				,	presidentFirstName = @presidentFirstName
				,	limitTime = @limitTime
				,	ipCount = @ipCount
				,	depositAmount = @depositAmount
				,	ssno = @ssno
				,	item = @item
				,	bizStatus = @bizStatus
				,	cellPhone = @cellPhone
				,	email = @email	
				,	manageCode = @manageCode
				,	gamebangTypeId = @gamebangTypeId
				WHERE gamebangId = @gamebangId
		
				--tblAdminLog? ???
				INSERT INTO tblAdminLog 
					VALUES(
						'Amend'
					,	'tblGamebang'
					,	@adminNumber
					,	@memo
					,	GETDATE()
					)
				
				SET @adminLogId = @@IDENTITY	
			END	
		
		
			--tblGamebangHistory? ???.
			INSERT INTO tblGamebangHistory 
				SELECT gamebangId , gamebangName , bizNumber , address , zipcode , phoneNumber , presidentSurname, presidentFirstName , limitTime , ipCount , depositAmount , apply , GETDATE() , @adminLogId , ssno , item , bizNumber , cellPhone , email , manageCode , gamebangTypeId
				FROM tblGamebang 
				WHERE gamebangId = @gamebangId
		
			EXEC procUpdateChongphanGamebang @gamebangId , @chongphanId , @memo , @adminNumber
			SET @returnCode = 1
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertUserActivated]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
BillingDB ? ?? ??? ?? ??? ?? Account db ? ??? ?? ???? ??? 
???? ??? Billing db ? INSERT ?? SP
*/
CREATE PROCEDURE [dbo].[procInsertUserActivated]
	@cpId					as	INT
,	@userId				as	nvarchar(50)		
,	@userNumber				as	int		OUTPUT
,	@msg					as	nvarchar(64)	OUTPUT
as
DECLARE @password				as	nvarchar(70)		
,	@userSurName				as	nvarchar(64)	
,	@MI					as	nvarchar(1)
,	@userFirstName				as	nvarchar(64)
,	@userKey				as	nvarchar(7)
,	@sex					as	int	
,	@birthday				as	nvarchar(16)		
,	@address				as	nvarchar(64)			
,	@phoneNumber			as	nvarchar(16)	
,	@email					as	nvarchar(64)	
,	@nation				as	nvarchar(64)	
,	@city					as	nvarchar(64)	
,	@state					as	nvarchar(64)	
,	@passwordCheckQuestionTypeId	as	nvarchar(64)
,	@passwordCheckAnswer		as	nvarchar(64)	
,	@handPhoneNumber			as	nvarchar(64)
,	@jobTypeId				as	nvarchar(64)
,	@getMail				as 	bit
,	@gameServiceId			as	smallint	



IF EXISTS(SELECT * FROM  UserLogin.dbo.Account where   Activated=1 AND UserID=@userId)
	BEGIN
		
		SELECT 
			 @password = password
			, @userSurName = Lastname
			, @MI = MI
			, @userFirstName = Firstname
			, @userKey = UserKey
			, @sex= case sex
					when 1 then 1
					when 2 then 0
				end
			, @birthday = Birthday 
			, @address = ADDRESS
			, @phoneNumber =HomeNo
			, @email = Email
			, @nation = country 
			, @city = city
			, @state = state
			, @passwordCheckQuestionTypeId = SecretQuestion 
			, @passwordCheckAnswer = Answer
			, @handPhoneNumber=MobileNo
			, @jobTypeId=''
			, @getMail = 1
			, @gameServiceId = 1
		FROM  UserLogin.dbo.Account  where  Activated=1 AND UserID=@userId
		
		

	BEGIN TRAN

		EXEC procInsertUser @userId 
			,@cpId 
			,@password 
			,@userSurName 
			,@MI 
			,@userFirstName 
			,@userKey 
			,@sex  
			,@birthday 
			,@address 
			,@phoneNumber 
			,@email 
			,@nation 
			,@city	
			,@state 
			,@passwordCheckQuestionTypeId 
			,@passwordCheckAnswer 
			,@handPhoneNumber
			,@jobTypeId
			,@getMail
			,@gameServiceId
			,@userNumber	OUTPUT
			,@msg		OUTPUT
			
		
		IF @@ERROR <> 0 
		BEGIN
			SET @userNumber = -1 
			ROLLBACK
			RETURN
		END
		COMMIT

						
	END
ELSE
	BEGIN
		SELECT @userNumber = -1, @msg = 'not exists User'	
	END
GO
/****** Object:  StoredProcedure [dbo].[procInsertChargeCardDepositTemp]    Script Date: 09/21/2014 18:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
@chargeCardDepositTempId   ?? 0 ?? ?? ?? 0 ??? ??? ?? ?? ????
*/
CREATE  PROCEDURE [dbo].[procInsertChargeCardDepositTemp]
	@userId				as	varchar(50)
,	@productId				as		int
,	@chargeCardDepositTempId		AS		INT		OUTPUT
AS
declare @cpId		int
declare @amount	 int
declare @userNumber int
declare @returnCode	int
declare @msg		varchar(100)
set @cpId = 1
/*	SELECT @userNumber=userNumber FROM tblUserInfo with(nolock) where userId=@userId  and apply=1 and  userStatusId<> 3
	IF @userNumber  is null
	begin
		SET @chargeCardDepositTempId =  0 ---?? ?? ?? ?? ???
		RETURN 
	end

*/
	IF NOT EXISTS(SELECT *  FROM tblUserInfo with(nolock) WHERE userId=@userId )
	BEGIN
		EXEC procInsertUserActivated 	@cpId, @userId  ,@userNumber OUTPUT, @msg OUTPUT
		IF @userNumber < 1 
		BEGIN
			SELECT @chargeCardDepositTempId = 0
			RETURN		
		END
	END
	ELSE
	BEGIN
		EXEC procGetUserAuth @cpId, @userId, @userNumber OUTPUT, @returnCode OUTPUT
		IF  @returnCode = 1 
		BEGIN
			SET @chargeCardDepositTempId =  0 ---?? ?? ?? ?? ???
			RETURN		
		END
	END

	SELECT @amount= productAmount   from tblProduct with(nolock) where productId=@productId	
	IF @amount  is null and @@rowcount = 0 
	BEGIN
		SET	@chargeCardDepositTempId = -1   ---?? ?? 
		RETURN
	END
	ELSE
	BEGIN
		INSERT tblChargeCardDepositTemp (userNumber, amount , productId, registDt) VALUES( @userNumber , @amount, @productId,getdate() )
		SET	@chargeCardDepositTempId = @@IDENTITY
	END
GO
/****** Object:  Default [DF_webshop_log_fecha]    Script Date: 09/21/2014 18:05:12 ******/
ALTER TABLE [dbo].[webshop_log] ADD  CONSTRAINT [DF_webshop_log_fecha]  DEFAULT (getdate()) FOR [fecha]
GO
/****** Object:  Default [DF_tblUserInfo_apply]    Script Date: 09/21/2014 18:05:12 ******/
ALTER TABLE [dbo].[tblUserInfo] ADD  CONSTRAINT [DF_tblUserInfo_apply]  DEFAULT ((0)) FOR [apply]
GO
