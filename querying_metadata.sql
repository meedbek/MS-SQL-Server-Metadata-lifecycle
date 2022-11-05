--extract available data bases
USE TEST;
GO 

SELECT name, database_id, create_date  
FROM sys.databases; 


--extract tables 
SELECT TOP 0 *
INTO infoTables
FROM INFORMATION_SCHEMA.TABLES;

DECLARE DatabaseNames CURSOR FOR SELECT name FROM sys.databases;
DECLARE @dbName VARCHAR(50)

OPEN DatabaseNames  
FETCH NEXT FROM DatabaseNames INTO @dbName     

WHILE @@FETCH_STATUS = 0  
BEGIN  

      EXECUTE('USE ' + @dbName + ';INSERT INTO TEST.dbo.infoTables SELECT * FROM INFORMATION_SCHEMA.TABLES')
      FETCH NEXT FROM DatabaseNames INTO @dbName 
END  

CLOSE DatabaseNames  
DEALLOCATE DatabaseNames 


SELECT * FROM infoTables

--extract columns metadata

SELECT TOP 0 *
INTO tables_metadata
FROM INFORMATION_SCHEMA.COLUMNS;

DECLARE DatabaseNames CURSOR FOR SELECT name FROM sys.databases;
DECLARE @dbName2 VARCHAR(50);


OPEN DatabaseNames  
FETCH NEXT FROM DatabaseNames INTO @dbName2     

WHILE @@FETCH_STATUS = 0  
BEGIN  

      EXECUTE('USE ' + @dbName2 + ';INSERT INTO TEST.dbo.tables_metadata SELECT * FROM INFORMATION_SCHEMA.COLUMNS')
      FETCH NEXT FROM DatabaseNames INTO @dbName2 
END  

CLOSE DatabaseNames  
DEALLOCATE DatabaseNames 

select * from tables_metadata

--extract tables or views contraints

--I've created the table Constraints using the below query

DECLARE DatabaseNames CURSOR FOR SELECT name FROM sys.databases;
DECLARE @dbName3 VARCHAR(50);


OPEN DatabaseNames  
FETCH NEXT FROM DatabaseNames INTO @dbName3    

WHILE @@FETCH_STATUS = 0  
BEGIN  

   EXECUTE('USE ' + @dbName3 + '

INSERT INTO TEST.dbo.Constraints select table_view,
    object_type, 
    constraint_type,
    constraint_name,
    details,
	'''+ @dbName3 +'''
from (
    select schema_name(t.schema_id) + ''.'' + t.[name] as table_view, 
        case when t.[type] = ''U'' then ''Table''
            when t.[type] = ''V'' then ''View''
            end as [object_type],
        case when c.[type] = ''PK'' then ''Primary key''
            when c.[type] = ''UQ'' then ''Unique constraint''
            when i.[type] = 1 then ''Unique clustered index''
            when i.type = 2 then ''Unique index''
            end as constraint_type, 
        isnull(c.[name], i.[name]) as constraint_name,
        substring(column_names, 1, len(column_names)-1) as [details]
    from sys.objects t
        left outer join sys.indexes i
            on t.object_id = i.object_id
        left outer join sys.key_constraints c
            on i.object_id = c.parent_object_id 
            and i.index_id = c.unique_index_id
       cross apply (select col.[name] + '', ''
                        from sys.index_columns ic
                            inner join sys.columns col
                                on ic.object_id = col.object_id
                                and ic.column_id = col.column_id
                        where ic.object_id = t.object_id
                            and ic.index_id = i.index_id
                                order by col.column_id
                                for xml path ('''') ) D (column_names)
    where is_unique = 1
    and t.is_ms_shipped <> 1
    union all 
    select schema_name(fk_tab.schema_id) + ''.'' + fk_tab.name as foreign_table,
        ''Table'',
        ''Foreign key'',
        fk.name as fk_constraint_name,
        schema_name(pk_tab.schema_id) + ''.'' + pk_tab.name
    from sys.foreign_keys fk
        inner join sys.tables fk_tab
            on fk_tab.object_id = fk.parent_object_id
        inner join sys.tables pk_tab
            on pk_tab.object_id = fk.referenced_object_id
        inner join sys.foreign_key_columns fk_cols
            on fk_cols.constraint_object_id = fk.object_id
    union all
    select schema_name(t.schema_id) + ''.'' + t.[name],
        ''Table'',
        ''Check constraint'',
        con.[name] as constraint_name,
        con.[definition]
    from sys.check_constraints con
        left outer join sys.objects t
            on con.parent_object_id = t.object_id
        left outer join sys.all_columns col
            on con.parent_column_id = col.column_id
            and con.parent_object_id = col.object_id
    union all
    select schema_name(t.schema_id) + ''.'' + t.[name],
        ''Table'',
        ''Default constraint'',
        con.[name],
        col.[name] + '' = '' + con.[definition]
    from sys.default_constraints con
        left outer join sys.objects t
            on con.parent_object_id = t.object_id
        left outer join sys.all_columns col
            on con.parent_column_id = col.column_id
            and con.parent_object_id = col.object_id) a
order by table_view, constraint_type, constraint_name')
      FETCH NEXT FROM DatabaseNames INTO @dbName3 
END  

CLOSE DatabaseNames  
DEALLOCATE DatabaseNames 




select table_view,
    object_type, 
    constraint_type,
    constraint_name,
    details
from (
    select schema_name(t.schema_id) + '.' + t.[name] as table_view, 
        case when t.[type] = 'U' then 'Table'
            when t.[type] = 'V' then 'View'
            end as [object_type],
        case when c.[type] = 'PK' then 'Primary key'
            when c.[type] = 'UQ' then 'Unique constraint'
            when i.[type] = 1 then 'Unique clustered index'
            when i.type = 2 then 'Unique index'
            end as constraint_type, 
        isnull(c.[name], i.[name]) as constraint_name,
        substring(column_names, 1, len(column_names)-1) as [details]
    from sys.objects t
        left outer join sys.indexes i
            on t.object_id = i.object_id
        left outer join sys.key_constraints c
            on i.object_id = c.parent_object_id 
            and i.index_id = c.unique_index_id
       cross apply (select col.[name] + ', '
                        from sys.index_columns ic
                            inner join sys.columns col
                                on ic.object_id = col.object_id
                                and ic.column_id = col.column_id
                        where ic.object_id = t.object_id
                            and ic.index_id = i.index_id
                                order by col.column_id
                                for xml path ('') ) D (column_names)
    where is_unique = 1
    and t.is_ms_shipped <> 1
    union all 
    select schema_name(fk_tab.schema_id) + '.' + fk_tab.name as foreign_table,
        'Table',
        'Foreign key',
        fk.name as fk_constraint_name,
        schema_name(pk_tab.schema_id) + '.' + pk_tab.name
    from sys.foreign_keys fk
        inner join sys.tables fk_tab
            on fk_tab.object_id = fk.parent_object_id
        inner join sys.tables pk_tab
            on pk_tab.object_id = fk.referenced_object_id
        inner join sys.foreign_key_columns fk_cols
            on fk_cols.constraint_object_id = fk.object_id
    union all
    select schema_name(t.schema_id) + '.' + t.[name],
        'Table',
        'Check constraint',
        con.[name] as constraint_name,
        con.[definition]
    from sys.check_constraints con
        left outer join sys.objects t
            on con.parent_object_id = t.object_id
        left outer join sys.all_columns col
            on con.parent_column_id = col.column_id
            and con.parent_object_id = col.object_id
    union all
    select schema_name(t.schema_id) + '.' + t.[name],
        'Table',
        'Default constraint',
        con.[name],
        col.[name] + ' = ' + con.[definition]
    from sys.default_constraints con
        left outer join sys.objects t
            on con.parent_object_id = t.object_id
        left outer join sys.all_columns col
            on con.parent_column_id = col.column_id
            and con.parent_object_id = col.object_id) a
order by table_view, constraint_type, constraint_name

SELECT * FROM TEST.dbo.Constraints

--extract all objects and their contents
SELECT TOP 0 *
INTO objects_table
FROM sys.objects;

alter table objects_table
add database_name nvarchar(50);

alter table objects_table
add database_name nvarchar(50);

SELECT TOP 0 *
INTO comments_table
FROM sys.syscomments;

alter table comments_table
add database_name nvarchar(50); 

DECLARE DatabaseNames CURSOR FOR SELECT name FROM sys.databases;
DECLARE @dbName4 VARCHAR(50);


OPEN DatabaseNames  
FETCH NEXT FROM DatabaseNames INTO @dbName4    

WHILE @@FETCH_STATUS = 0  
BEGIN  

      EXECUTE('USE ' + @dbName4 + ';INSERT INTO TEST.dbo.objects_table SELECT *,'''+@dbName4+''' FROM sys.objects; 
						INSERT INTO TEST.dbo.comments_table SELECT *,'''+@dbName4+''' FROM sys.syscomments');
      FETCH NEXT FROM DatabaseNames INTO @dbName4
END  

CLOSE DatabaseNames  
DEALLOCATE DatabaseNames 

--dependencies

SELECT TOP 0 *
INTO dependencies
FROM sys.sql_expression_dependencies;

alter table dependencies
add database_name nvarchar(50);


DECLARE DatabaseNames CURSOR FOR SELECT name FROM sys.databases;
DECLARE @dbName5 VARCHAR(50);


OPEN DatabaseNames  
FETCH NEXT FROM DatabaseNames INTO @dbName5 

WHILE @@FETCH_STATUS = 0  
BEGIN  

      EXECUTE('USE ' + @dbName5 + ';INSERT INTO TEST.dbo.dependencies SELECT *,'''+@dbName5+''' FROM sys.sql_expression_dependencies');
      FETCH NEXT FROM DatabaseNames INTO @dbName5
END  

CLOSE DatabaseNames  
DEALLOCATE DatabaseNames 

--testing
select * from comments_table
select * from objects_table

declare @comments nvarchar(max);
set @comments = (select top 1 text from comments_table where replace(text,'_','!') LIKE '%ASFIM!ODS%' )
print @comments


select top 1 * from comments_table where replace(text,'_','!') LIKE '%ASFIM!ODS%'

select * from objects_table
 Select Schema_Name(p.schema_id) As ProcedureSchema, p.name As ProcedureName, Schema_Name(f.schema_id) As FunctionSchema, f.name as FunctionName
 From sys.sql_expression_dependencies d
 Inner Join sys.objects p On p.object_id = d.referencing_id And p.type_desc = 'SQL_STORED_PROCEDURE'
 Inner Join sys.objects f On f.object_id = d.referenced_id And f.type In ('AF', 'FN', 'FS', 'IF', 'TF');


--https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/querying-the-sql-server-system-catalog-faq?view=sql-server-ver15

--this link contains a list of usefull queries titled querying SQL Server System Catalog




