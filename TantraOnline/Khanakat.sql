USE [Khanakat]
GO
/****** Object:  Table [dbo].[Cash]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cash](
	[Parent_Account] [int] NOT NULL,
	[Taney] [int] NULL,
	[Brahman_Point] [int] NULL,
	[Event_Point] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ban_Win]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ban_Win](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Account] [varchar](50) NOT NULL,
	[Reason] [int] NOT NULL,
	[Date] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Account_root]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account_root](
	[id] [int] IDENTITY(1000000,1) NOT NULL,
	[email] [nvarchar](50) NOT NULL,
	[password] [nvarchar](32) NOT NULL,
	[first_name] [nvarchar](30) NOT NULL,
	[last_name] [nvarchar](30) NOT NULL,
	[gender] [int] NOT NULL,
	[register_date] [datetime] NOT NULL,
	[IP] [nvarchar](15) NOT NULL,
	[user_lvl] [smallint] NOT NULL,
 CONSTRAINT [PK_Account_fb] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Account]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Parent_Account] [int] NOT NULL,
	[UserID] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](70) NOT NULL,
	[UserKey] [nvarchar](7) NOT NULL,
	[Blocked] [tinyint] NOT NULL,
	[Blocked_Date] [datetime] NULL,
	[Blocked_Time] [int] NULL,
	[MI] [nvarchar](1) NOT NULL,
	[Country] [nvarchar](50) NULL,
	[IP] [nvarchar](15) NOT NULL,
	[Date_Registered] [datetime] NOT NULL,
	[Activated] [bit] NOT NULL,
	[Log_Date] [datetime] NOT NULL,
	[IsAdmin] [bit] NOT NULL,
 CONSTRAINT [PK_Account_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TantraMail]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TantraMail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Account] [varchar](25) NOT NULL,
	[Content] [varchar](256) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TantraItem]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TantraItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[World] [int] NOT NULL,
	[Account] [varchar](50) NOT NULL,
	[ItemIndex] [int] NOT NULL,
	[ItemCount] [smallint] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TantraBackup05]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TantraBackup05](
	[idx] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](40) NOT NULL,
	[CharacterName] [varchar](40) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](40) NULL,
	[GuildId] [int] NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](40) NULL,
	[Name2] [varchar](40) NULL,
	[Name3] [varchar](40) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL,
	[Blocked] [tinyint] NOT NULL,
	[Account] [binary](7124) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TantraBackup04]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TantraBackup04](
	[idx] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](40) NOT NULL,
	[CharacterName] [varchar](40) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](40) NULL,
	[GuildId] [int] NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](40) NULL,
	[Name2] [varchar](40) NULL,
	[Name3] [varchar](40) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL,
	[Blocked] [tinyint] NOT NULL,
	[Account] [binary](7124) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TantraBackup03]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TantraBackup03](
	[idx] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](52) NOT NULL,
	[CharacterName] [varchar](20) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](20) NULL,
	[GuildID] [int] NOT NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](20) NULL,
	[Name2] [varchar](20) NULL,
	[Name3] [varchar](20) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL,
	[Blocked] [tinyint] NOT NULL,
	[Account] [binary](7124) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TantraBackup02]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TantraBackup02](
	[idx] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](40) NOT NULL,
	[CharacterName] [varchar](40) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](40) NULL,
	[GuildId] [int] NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](40) NULL,
	[Name2] [varchar](40) NULL,
	[Name3] [varchar](40) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL,
	[Blocked] [tinyint] NOT NULL,
	[Account] [binary](7124) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TantraBackup01]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TantraBackup01](
	[idx] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](40) NOT NULL,
	[CharacterName] [varchar](40) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](40) NULL,
	[GuildId] [int] NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](40) NULL,
	[Name2] [varchar](40) NULL,
	[Name3] [varchar](40) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL,
	[Blocked] [tinyint] NOT NULL,
	[Account] [binary](7124) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TantraBackup00]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TantraBackup00](
	[idx] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](40) NOT NULL,
	[CharacterName] [varchar](40) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](20) NULL,
	[GuildID] [int] NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](40) NULL,
	[Name2] [varchar](40) NULL,
	[Name3] [varchar](40) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL,
	[Blocked] [tinyint] NOT NULL,
	[Account] [binary](7124) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Reset_Table_00]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Reset_Table_00](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Reset_Char] [varchar](50) NOT NULL,
	[Reset_Date] [date] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Reset_Config]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reset_Config](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[chakra_points] [int] NOT NULL,
	[rupiah] [nvarchar](25) NULL,
	[brahmanpoint] [nvarchar](50) NULL,
	[item_1] [nvarchar](6) NULL,
	[item_2] [nvarchar](6) NULL,
	[item_3] [nvarchar](6) NULL,
	[taneys] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GMLog]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GMLog](
	[LogIndex] [int] IDENTITY(1,1) NOT NULL,
	[GMID] [varchar](25) NOT NULL,
	[SaveDate] [datetime] NOT NULL,
	[Description] [varchar](2048) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GMInfo]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GMInfo](
	[GMID] [char](20) NOT NULL,
	[GMPassword] [char](20) NOT NULL,
	[GMName] [char](20) NOT NULL,
	[GMLevel] [smallint] NOT NULL,
	[GMPart] [char](30) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GameInfo05]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GameInfo05](
	[UserID] [varchar](40) NOT NULL,
	[CharacterName] [varchar](40) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](40) NULL,
	[GuildID] [int] NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](40) NULL,
	[Name2] [varchar](40) NULL,
	[Name3] [varchar](40) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GameInfo04]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GameInfo04](
	[UserID] [varchar](40) NOT NULL,
	[CharacterName] [varchar](40) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](40) NULL,
	[GuildID] [int] NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](40) NULL,
	[Name2] [varchar](40) NULL,
	[Name3] [varchar](40) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GameInfo03]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GameInfo03](
	[UserID] [varchar](40) NOT NULL,
	[CharacterName] [varchar](40) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](20) NULL,
	[GuildID] [int] NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](40) NULL,
	[Name2] [varchar](40) NULL,
	[Name3] [varchar](40) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GameInfo02]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GameInfo02](
	[UserID] [varchar](40) NOT NULL,
	[CharacterName] [varchar](40) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](40) NULL,
	[GuildID] [int] NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](40) NULL,
	[Name2] [varchar](40) NULL,
	[Name3] [varchar](40) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GameInfo01]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GameInfo01](
	[UserID] [varchar](40) NOT NULL,
	[CharacterName] [varchar](40) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](40) NULL,
	[GuildID] [int] NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](40) NULL,
	[Name2] [varchar](40) NULL,
	[Name3] [varchar](40) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GameInfo00]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GameInfo00](
	[UserID] [varchar](40) NOT NULL,
	[CharacterName] [varchar](40) NOT NULL,
	[CharacterLevel] [smallint] NOT NULL,
	[BrahmanPoint] [int] NOT NULL,
	[MBrahmanPoint] [int] NOT NULL,
	[Tribe] [smallint] NOT NULL,
	[Trimurity] [smallint] NOT NULL,
	[GuildName] [varchar](20) NULL,
	[GuildID] [int] NULL,
	[GuildRank] [smallint] NOT NULL,
	[curtime] [datetime] NOT NULL,
	[Name1] [varchar](40) NULL,
	[Name2] [varchar](40) NULL,
	[Name3] [varchar](40) NULL,
	[Level1] [smallint] NOT NULL,
	[Level2] [smallint] NOT NULL,
	[Level3] [smallint] NOT NULL,
	[TotalMoney] [float] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Game_Login_Access]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Game_Login_Access](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Account] [varchar](50) NOT NULL,
	[IP] [nvarchar](15) NOT NULL,
	[Date] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WebShop]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WebShop](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[item_id] [varchar](5) NOT NULL,
	[item_category] [varchar](50) NOT NULL,
	[item_pack] [bit] NOT NULL,
	[item_count] [int] NULL,
	[item_taney] [int] NULL,
	[show] [bit] NOT NULL,
 CONSTRAINT [PK_webshop] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Web_Mail]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Web_Mail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[mail_parent] [int] NULL,
	[mail_from] [varchar](256) NOT NULL,
	[mail_to] [varchar](256) NOT NULL,
	[mail_title] [varchar](256) NULL,
	[mail_text] [varchar](2048) NOT NULL,
	[mail_read] [bit] NOT NULL,
	[mail_status] [smallint] NOT NULL,
	[mail_date] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Web_Enviroment]    Script Date: 09/03/2015 23:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Web_Enviroment](
	[id] [int] NULL,
	[web_name] [varchar](50) NULL,
	[web_smtp_host] [varchar](50) NULL,
	[web_smtp_mail] [varchar](50) NULL,
	[web_smtp_port] [int] NULL,
	[web_smtp_user] [varchar](50) NULL,
	[web_smtp_pass] [varchar](50) NULL,
	[web_ranking_top] [bit] NOT NULL,
	[web_ranking_count] [nchar](10) NULL,
	[web_ranking_perfil] [bit] NOT NULL,
	[web_edit_job] [bit] NULL,
	[web_edit_lvl] [bit] NULL,
	[web_edit_zone] [bit] NOT NULL,
	[web_edit_zone_x] [nchar](10) NULL,
	[web_edit_zone_y] [nchar](10) NULL,
	[web_max_account_count] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[UCPData]    Script Date: 09/03/2015 23:30:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UCPData]
AS
SELECT     dbo.Account.Parent_Account, dbo.Account.ID, dbo.Account.Password, dbo.Account.MI, dbo.Account.IP, dbo.Account.Date_Registered, dbo.Account.Activated, 
                      dbo.Account.Log_Date, dbo.Account.Blocked, dbo.Account.Blocked_Date, dbo.Account.Blocked_Time, dbo.Account.UserID, dbo.Account.UserKey, dbo.Account.Country, 
                      dbo.TantraBackup00.idx, dbo.TantraBackup00.CharacterName, dbo.TantraBackup00.CharacterLevel, dbo.TantraBackup00.BrahmanPoint, 
                      dbo.TantraBackup00.MBrahmanPoint, dbo.TantraBackup00.Tribe, dbo.TantraBackup00.Trimurity, dbo.TantraBackup00.GuildName, dbo.TantraBackup00.GuildID, 
                      dbo.TantraBackup00.GuildRank, dbo.TantraBackup00.curtime, dbo.TantraBackup00.Name1, dbo.TantraBackup00.Name2, dbo.TantraBackup00.Name3, 
                      dbo.TantraBackup00.Level1, dbo.TantraBackup00.Level2, dbo.TantraBackup00.Level3, dbo.TantraBackup00.TotalMoney, dbo.Cash.Taney
FROM         dbo.Account FULL OUTER JOIN
                      dbo.Cash ON dbo.Account.Parent_Account = dbo.Cash.Parent_Account FULL OUTER JOIN
                      dbo.TantraBackup00 ON dbo.Account.UserID = dbo.TantraBackup00.UserID
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[43] 4[21] 2[23] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Account"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 184
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "Cash"
            Begin Extent = 
               Top = 151
               Left = 272
               Bottom = 270
               Right = 470
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TantraBackup00"
            Begin Extent = 
               Top = 6
               Left = 274
               Bottom = 179
               Right = 472
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1875
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UCPData'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UCPData'
GO
/****** Object:  View [dbo].[Control_Game_Login]    Script Date: 09/03/2015 23:30:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Control_Game_Login]
AS
SELECT     MAX(Account) AS Account, COUNT(Date) AS Date, IP
FROM         dbo.Game_Login_Access
WHERE     (Date > GETDATE() - 1)
GROUP BY IP
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[33] 4[28] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Game_Login_Access"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 150
               Right = 283
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1830
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Control_Game_Login'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Control_Game_Login'
GO
/****** Object:  View [dbo].[Cash_Info]    Script Date: 09/03/2015 23:30:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Cash_Info]
AS
SELECT     dbo.Account_root.id, dbo.Account_root.email, dbo.Cash.Taney, dbo.Cash.Brahman_Point, dbo.Cash.Event_Point
FROM         dbo.Account_root FULL OUTER JOIN
                      dbo.Cash ON dbo.Account_root.id = dbo.Cash.Parent_Account
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Account_root"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "Cash"
            Begin Extent = 
               Top = 6
               Left = 274
               Bottom = 125
               Right = 472
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Cash_Info'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Cash_Info'
GO
/****** Object:  View [dbo].[Ranking_00_Guild]    Script Date: 09/03/2015 23:30:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Ranking_00_Guild]
AS
SELECT     TOP (100) PERCENT GuildID, SUM(BrahmanPoint) AS TotalBrahmanPoint, GuildName, Trimurity
FROM         dbo.TantraBackup00
GROUP BY GuildID, GuildName, Trimurity
HAVING      (GuildID > 0)
ORDER BY TotalBrahmanPoint DESC
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[29] 4[33] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "TantraBackup00"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 196
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 780
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Ranking_00_Guild'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Ranking_00_Guild'
GO
/****** Object:  View [dbo].[Ranking_00]    Script Date: 09/03/2015 23:30:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Ranking_00]
AS
SELECT     dbo.TantraBackup00.*, dbo.Account.IsAdmin
FROM         dbo.TantraBackup00 INNER JOIN
                      dbo.Account ON dbo.TantraBackup00.UserID = dbo.Account.UserID
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "TantraBackup00"
            Begin Extent = 
               Top = 51
               Left = 44
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Account"
            Begin Extent = 
               Top = 36
               Left = 300
               Bottom = 155
               Right = 498
            End
            DisplayFlags = 280
            TopColumn = 11
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1950
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Ranking_00'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Ranking_00'
GO
/****** Object:  StoredProcedure [dbo].[procOrderOnlyByItemBill]    Script Date: 09/03/2015 23:30:28 ******/
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
DECLARE @point   AS INT    
DECLARE @adminLogId   AS INT     
DECLARE @transactionId  AS INT    
    
    
---------------------------------------------------------------------------------------------------------------------    
DECLARE @Parent_Account  as INT    
DECLARE @cashAmount  as int    
DECLARE @pointToCashAmount as int    
DECLARE @userTypeId   as tinyInt        
DECLARE @cashBalance  as int    
DECLARE @pointToCashBalance as int    
DECLARE @holdCashBalance  as int    
DECLARE @pointBalance  as int    
DECLARE @now   as datetime    
DECLARE @transactionTypeId  as tinyInt    
DECLARE @canOrder   as bit    
DECLARE @productTypeId  as tinyInt    
DECLARE @errorSave   as int    
DECLARE @productPoint  as  int    
    
    
SET @adminLogId   = NULL    
SET @chargeTransactionId  = NULL    
    
SET @productPoint  = 0     
SET @pointToCashAmount = 0    
    
SET @errorSave = 0    
SET @cashAmount = @unitPrice * @quantity    
SET @transactionTypeId = 2 --??      
--Parent Account Select    
SELECT    
 @Parent_Account = Parent_Account  
FROM Account WITH (READUNCOMMITTED)      
WHERE UserID = @userId    
IF @Parent_Account IS NULL OR @@ROWCOUNT <> 1     
 BEGIN    
  SET @transactionId = -201 --user ??
  SELECT @transactionId AS transactionId    
  RETURN    
 END    
     
    
-- ??    
    
SELECT
 @cashBalance = Taney
FROM Cash WITH (READUNCOMMITTED)
WHERE Parent_Account = @Parent_Account
    
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
      
 --WebShop Log Insert    
 INSERT webshop_log(idaccount, itemid, cantidad, cash, cashtype)    
 VALUES(@userId, @productId, @quantity, @cashAmount, @orderTypeId)    
 SET @errorSave = @errorSave + @@ERROR      
    
 --Cash Update    
 UPDATE Cash SET Taney=@cashBalance WHERE Parent_Account = @Parent_Account    
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
/****** Object:  StoredProcedure [dbo].[procGetUserBalanceOnly]    Script Date: 09/03/2015 23:30:28 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGetUserBalanceOnly]
	@userId	AS	nvarchar(64)	
AS

DECLARE @cashBalance	AS	INT
DECLARE @Parent_Account	AS	INT

SELECT @Parent_Account = Parent_Account FROM Account
WHERE UserID = @userId

SELECT @cashBalance = Taney FROM Cash 
WHERE Parent_Account = @Parent_Account
IF(@@ROWCOUNT = 0)
	SET @cashBalance = -1

SELECT @cashBalance AS cashBalance
GO
/****** Object:  StoredProcedure [dbo].[hb_tan_gp_userinfo_se]    Script Date: 09/03/2015 23:30:28 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[hb_tan_gp_userinfo_se]
	@userId	AS	nvarchar(64)	
AS

DECLARE @cashBalance	AS	INT
DECLARE @Parent_Account	AS	INT

SELECT @Parent_Account = Parent_Account FROM Account
WHERE UserID = @userId

SELECT @cashBalance = Taney FROM Cash 
WHERE Parent_Account = @Parent_Account
IF(@@ROWCOUNT = 0)
	SET @cashBalance = -1

SELECT @cashBalance AS cashBalance
GO
/****** Object:  StoredProcedure [dbo].[hb_tan_gp_applyinfo_userinfo_in]    Script Date: 09/03/2015 23:30:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[hb_tan_gp_applyinfo_userinfo_in]    
 @userId   as NVARCHAR(52)       
, @userIp   as varchar(17)    
, @contentCode   as int   -- ?????    
, @contentTypeCode  as varchar(3)  --TYPEODE " I0 " ?? ??? ???    
, @productId   as int    
, @quantity   as int    
, @unitPrice   as int  -- ?????    
, @sinvalor   as VARCHAR(3)  -- ??    
, @userkey   as NVARCHAR(7)       
AS    
---------------------------------------------------------------------------------------------------------------------    
DECLARE @chargeTransactionId AS INT    
DECLARE @point   AS INT    
DECLARE @adminLogId   AS INT     
DECLARE @transactionId  AS INT    
    
    
---------------------------------------------------------------------------------------------------------------------    
DECLARE @Parent_Account  as INT    
DECLARE @orderTypeId   as tinyInt
DECLARE @cashAmount  as int    
DECLARE @pointToCashAmount as int    
DECLARE @userTypeId   as tinyInt        
DECLARE @cashBalance  as int    
DECLARE @pointToCashBalance as int    
DECLARE @holdCashBalance  as int    
DECLARE @pointBalance  as int    
DECLARE @now   as datetime    
DECLARE @transactionTypeId  as tinyInt    
DECLARE @canOrder   as bit    
DECLARE @productTypeId  as tinyInt    
DECLARE @errorSave   as int   
DECLARE @eventId   as int 
DECLARE @productPoint  as  int    
    
    
SET @adminLogId   = NULL    
SET @chargeTransactionId  = NULL    
    
SET @productPoint  = 0     
SET @pointToCashAmount = 0    
    
SET @errorSave = 0    
SET @cashAmount = @unitPrice * @quantity    
SET @transactionTypeId = 2 --??      
--Parent Account Select    
SELECT    
 @Parent_Account = Parent_Account  
FROM Account WITH (READUNCOMMITTED)      
WHERE UserID = @userId    
IF @Parent_Account IS NULL OR @@ROWCOUNT <> 1     
 BEGIN    
  SET @transactionId = -201 --user ??
  SELECT @transactionId AS transactionId    
  RETURN    
 END    
     
    
-- ??    
    
SELECT
 @cashBalance = Taney
FROM Cash WITH (READUNCOMMITTED)
WHERE Parent_Account = @Parent_Account
    
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
      
 --WebShop Log Insert    
 INSERT webshop_log(idaccount, itemid, cantidad, cash, cashtype)    
 VALUES(@userId, @productId, @quantity, @cashAmount, @orderTypeId)    
 SET @errorSave = @errorSave + @@ERROR      
    
 --Cash Update    
 UPDATE Cash SET Taney=@cashBalance WHERE Parent_Account = @Parent_Account    
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
/****** Object:  View [dbo].[GMLogView]    Script Date: 09/03/2015 23:30:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[GMLogView]
AS
SELECT   dbo.GMLog.LogIndex, dbo.GMLog.GMID, dbo.GMInfo.GMName, 
                dbo.GMInfo.GMLevel, dbo.GMLog.SaveDate, dbo.GMLog.Description
FROM      dbo.GMInfo INNER JOIN
                dbo.GMLog ON dbo.GMInfo.GMID = dbo.GMLog.GMID
GO
