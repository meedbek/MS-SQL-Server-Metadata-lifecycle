select * from metadata.databases
select * from metadata.colonnes
select * from metadata.constraints
select * from metadata.programmable_objects
select * from metadata.table_object
select * from metadata.tables_views

-- starting with databases 

--dispaly original sys.databases columns

select * from sys.databases

  --data feed
delete from metadata.databases


insert into metadata.databases (ID, nom, create_date)
select database_id, name, create_date from sys.databases  
where name not in ('master', 'tempdb', 'model', 'msdb','TEST')




--table_view 

USE TEST

select * from dbo.infoTables
select * from metadata.tables_views

CREATE SEQUENCE metadata.tables_views_identity
    START WITH 1  
    INCREMENT BY 1 ;  
GO  

alter sequence metadata.tables_views_identity 
restart

INSERT INTO metadata.tables_views (ID, ID_database, table_view, schema_name, table_name)
select next value for metadata.tables_views_identity, t2.ID, t1.TABLE_TYPE, t1.TABLE_SCHEMA, t1.TABLE_NAME
from dbo.infoTables t1 inner join metadata.databases t2 on t1.TABLE_CATALOG = t2.Nom

--colonnes 

select * from metadata.colonnes
select * from dbo.tables_metadata

CREATE SEQUENCE metadata.colonnes_identity
    START WITH 1  
    INCREMENT BY 1 ;  
GO

alter sequence metadata.colonnes_identity
restart

insert into metadata.colonnes(ID, nom_champ, ID_table,is_nullable , datatype, maximum_lenght, default_value)
select next value for metadata.colonnes_identity, column_name,t2.ID, is_nullable, data_type, CHARACTER_MAXIMUM_LENGTH,column_default
from dbo.tables_metadata t1
inner join metadata.tables_views t2 on t1.TABLE_NAME = t2.table_name and t1.TABLE_SCHEMA = t2.schema_name
inner join metadata.databases t3 on t1.TABLE_CATALOG = t3.Nom 

select * from dbo.tables_metadata 
select * from dbo.tables_metadata

--constraints

select * from dbo.Constraints
select * from metadata.constraints

CREATE SEQUENCE metadata.constraints_identity
    START WITH 1  
    INCREMENT BY 1 ;  
GO

insert into metadata.constraints(ID, constraint_type, constraint_name, details, ID_table)
select next value for metadata.constraints_identity, constraint_type, constraint_name, t1.details, t2.ID 
from dbo.Constraints t1
inner join metadata.tables_views t2 on lower(t1.table_view) = lower(concat(t2.schema_name,'.',t2.table_name))
inner join metadata.databases t3 on t2.ID_database = t3.ID


select * from metadata.constraints

--programmable_objects

select top 100 * from dbo.dependencies

select distinct referencing_class_desc from dbo.dependencies

