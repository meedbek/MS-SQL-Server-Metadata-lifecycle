USE [TEST]
GO
/****** Object:  Schema [lineage]    Script Date: 13/10/2022 11:49:54 ******/
CREATE SCHEMA [lineage]
GO
/****** Object:  Schema [metadata]    Script Date: 13/10/2022 11:49:54 ******/
CREATE SCHEMA [metadata]
GO
/****** Object:  Table [dbo].[comments_table]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[comments_table](
	[id] [int] NOT NULL,
	[number] [smallint] NULL,
	[colid] [smallint] NOT NULL,
	[status] [smallint] NOT NULL,
	[ctext] [varbinary](8000) NULL,
	[texttype] [smallint] NULL,
	[language] [smallint] NULL,
	[encrypted] [bit] NOT NULL,
	[compressed] [bit] NOT NULL,
	[text] [nvarchar](4000) NULL,
	[database_name] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Alimentation]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Alimentation] as 
select id, text from comments_table as c where ((LOWER(c.text) LIKE '% insert%') or (LOWER(c.text) LIKE '% create view%') or (LOWER(c.text) LIKE '% merge%') ) and texttype = 0
GO
/****** Object:  Table [dbo].[Constraints]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Constraints](
	[table_view] [nvarchar](257) NULL,
	[object_type] [varchar](5) NULL,
	[constraint_type] [varchar](22) NULL,
	[constraint_name] [sysname] NULL,
	[details] [nvarchar](max) NULL,
	[database_name] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[dependencies]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dependencies](
	[referencing_id] [int] NOT NULL,
	[referencing_minor_id] [int] NOT NULL,
	[referencing_class] [tinyint] NULL,
	[referencing_class_desc] [nvarchar](60) NULL,
	[is_schema_bound_reference] [bit] NOT NULL,
	[referenced_class] [tinyint] NULL,
	[referenced_class_desc] [nvarchar](60) NULL,
	[referenced_server_name] [nvarchar](128) NULL,
	[referenced_database_name] [nvarchar](128) NULL,
	[referenced_schema_name] [nvarchar](128) NULL,
	[referenced_entity_name] [nvarchar](128) NULL,
	[referenced_id] [int] NULL,
	[referenced_minor_id] [int] NOT NULL,
	[is_caller_dependent] [bit] NOT NULL,
	[is_ambiguous] [bit] NOT NULL,
	[database_name] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[infoTables]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[infoTables](
	[TABLE_CATALOG] [nvarchar](128) NULL,
	[TABLE_SCHEMA] [sysname] NULL,
	[TABLE_NAME] [sysname] NOT NULL,
	[TABLE_TYPE] [varchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[objects_table]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[objects_table](
	[name] [sysname] NOT NULL,
	[object_id] [int] NOT NULL,
	[principal_id] [int] NULL,
	[schema_id] [int] NOT NULL,
	[parent_object_id] [int] NOT NULL,
	[type] [char](2) NULL,
	[type_desc] [nvarchar](60) NULL,
	[create_date] [datetime] NOT NULL,
	[modify_date] [datetime] NOT NULL,
	[is_ms_shipped] [bit] NOT NULL,
	[is_published] [bit] NOT NULL,
	[is_schema_published] [bit] NOT NULL,
	[database_name] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tables_metadata]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tables_metadata](
	[TABLE_CATALOG] [nvarchar](128) NULL,
	[TABLE_SCHEMA] [nvarchar](128) NULL,
	[TABLE_NAME] [sysname] NOT NULL,
	[COLUMN_NAME] [sysname] NULL,
	[ORDINAL_POSITION] [int] NULL,
	[COLUMN_DEFAULT] [nvarchar](4000) NULL,
	[IS_NULLABLE] [varchar](3) NULL,
	[DATA_TYPE] [nvarchar](128) NULL,
	[CHARACTER_MAXIMUM_LENGTH] [int] NULL,
	[CHARACTER_OCTET_LENGTH] [int] NULL,
	[NUMERIC_PRECISION] [tinyint] NULL,
	[NUMERIC_PRECISION_RADIX] [smallint] NULL,
	[NUMERIC_SCALE] [int] NULL,
	[DATETIME_PRECISION] [smallint] NULL,
	[CHARACTER_SET_CATALOG] [sysname] NULL,
	[CHARACTER_SET_SCHEMA] [sysname] NULL,
	[CHARACTER_SET_NAME] [sysname] NULL,
	[COLLATION_CATALOG] [sysname] NULL,
	[COLLATION_SCHEMA] [sysname] NULL,
	[COLLATION_NAME] [sysname] NULL,
	[DOMAIN_CATALOG] [sysname] NULL,
	[DOMAIN_SCHEMA] [sysname] NULL,
	[DOMAIN_NAME] [sysname] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [lineage].[full_objects_hierachie]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [lineage].[full_objects_hierachie](
	[ID_object] [nchar](10) NULL,
	[type] [nvarchar](50) NULL,
	[content] [text] NULL,
	[name] [nvarchar](100) NULL,
	[ID_parent] [nchar](10) NULL,
	[object_database_id] [nchar](10) NULL,
	[parent_database_id] [nchar](10) NULL,
	[depth] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [lineage].[objects_hiearchie]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [lineage].[objects_hiearchie](
	[ID_object] [nchar](10) NULL,
	[type] [nvarchar](50) NULL,
	[content] [text] NULL,
	[name] [nvarchar](100) NULL,
	[ID_parent] [nchar](10) NULL,
	[object_database_id] [nchar](10) NULL,
	[parent_database_id] [nchar](10) NULL,
	[depth] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [metadata].[colonnes]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [metadata].[colonnes](
	[ID] [nchar](10) NOT NULL,
	[nom_champ] [nvarchar](50) NULL,
	[definition] [nvarchar](50) NULL,
	[ID_table] [nchar](10) NOT NULL,
	[is_nullable] [nchar](10) NULL,
	[acceptable_values] [nvarchar](max) NULL,
	[ref_data_lineage] [nvarchar](50) NULL,
	[default_value] [nvarchar](50) NULL,
	[maximum_lenght] [int] NULL,
	[datatype] [nvarchar](50) NULL,
	[null_count] [int] NULL,
	[distc_value_count] [int] NULL,
	[min_value] [nvarchar](50) NULL,
	[max_value] [nvarchar](50) NULL,
 CONSTRAINT [cn_pk] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [metadata].[constraints]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [metadata].[constraints](
	[ID] [nchar](10) NOT NULL,
	[constraint_type] [nvarchar](50) NULL,
	[ID_table] [nchar](10) NULL,
	[constraint_name] [nvarchar](128) NULL,
	[details] [nvarchar](max) NULL,
 CONSTRAINT [cs_pk] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [metadata].[databases]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [metadata].[databases](
	[ID] [nchar](10) NOT NULL,
	[Nom] [nvarchar](50) NULL,
	[type] [nvarchar](50) NULL,
	[steward] [nvarchar](50) NULL,
	[description] [nvarchar](max) NULL,
	[ref_modèle_entité_association] [nvarchar](50) NULL,
	[create_date] [datetime] NULL,
 CONSTRAINT [db_pk] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [metadata].[programmable_objects]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [metadata].[programmable_objects](
	[ID] [nchar](10) NOT NULL,
	[type] [nvarchar](50) NULL,
	[content] [text] NULL,
	[name] [nvarchar](50) NULL,
	[object_database_id] [nchar](10) NOT NULL,
	[id_object] [nchar](10) NULL,
 CONSTRAINT [PK_PO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [metadata].[tables_PO]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [metadata].[tables_PO](
	[ID_table] [nchar](10) NULL,
	[ID_Object] [nchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [metadata].[tables_views]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [metadata].[tables_views](
	[ID] [nchar](10) NOT NULL,
	[ID_database] [nchar](10) NULL,
	[table_view] [nchar](10) NULL,
	[nb_lignes] [nchar](10) NULL,
	[description] [nchar](10) NULL,
	[steward] [nchar](10) NULL,
	[schema_name] [nvarchar](50) NULL,
	[table_name] [nvarchar](128) NULL,
 CONSTRAINT [tbv_pk] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [metadata].[colonnes]  WITH CHECK ADD  CONSTRAINT [tb_fk] FOREIGN KEY([ID_table])
REFERENCES [metadata].[tables_views] ([ID])
GO
ALTER TABLE [metadata].[colonnes] CHECK CONSTRAINT [tb_fk]
GO
ALTER TABLE [metadata].[constraints]  WITH CHECK ADD  CONSTRAINT [tablecost_fk] FOREIGN KEY([ID_table])
REFERENCES [metadata].[tables_views] ([ID])
GO
ALTER TABLE [metadata].[constraints] CHECK CONSTRAINT [tablecost_fk]
GO
ALTER TABLE [metadata].[tables_PO]  WITH CHECK ADD FOREIGN KEY([ID_Object])
REFERENCES [metadata].[programmable_objects] ([ID])
GO
ALTER TABLE [metadata].[tables_PO]  WITH CHECK ADD FOREIGN KEY([ID_table])
REFERENCES [metadata].[tables_views] ([ID])
GO
ALTER TABLE [metadata].[tables_views]  WITH CHECK ADD  CONSTRAINT [db_fk] FOREIGN KEY([ID_database])
REFERENCES [metadata].[databases] ([ID])
GO
ALTER TABLE [metadata].[tables_views] CHECK CONSTRAINT [db_fk]
GO
/****** Object:  StoredProcedure [metadata].[following_objects]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [metadata].[following_objects]
	@SP_name nvarchar(50),   
    @Database nvarchar(50)  
AS   
	WITH recursion(ID_object, type, content, name, ID_parent,object_database_id,parent_database_id,depth)   
	AS (  

		select d.*
		from lineage.full_objects_hierachie d 
		inner join metadata.databases db on d.object_database_id = db.id
		where lower(name) = lower(@SP_name) and lower(db.nom) = lower(@Database) and d.depth = 0

		UNION ALL   

		-- This section provides values for all nodes except the root  
		SELECT  d.*
		FROM lineage.full_objects_hierachie d
		JOIN recursion AS p   
		   ON d.ID_parent = p.ID_object and d.parent_database_id = p.object_database_id
		where d.depth = p.depth + 1
	)
	select * from recursion

GO
/****** Object:  StoredProcedure [metadata].[referencedTables]    Script Date: 13/10/2022 11:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [metadata].[referencedTables]  
	@SP_name nvarchar(50),   
    @Database nvarchar(50)   
AS   
	select t1.* 
	from metadata.tables_views t1 
	inner join metadata.tables_PO t3 on t1.id = t3.id_table 
	inner join metadata.programmable_objects t2 on t2.ID = t3.ID_object 
	inner join metadata.databases t4 on t4.id = t2.object_database_id
	where lower(t2.name) = lower(@SP_name) and lower(t4.Nom) =  lower(@Database)

GO
