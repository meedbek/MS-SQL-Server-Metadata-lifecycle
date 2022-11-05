--dependencies

-- first thing first explore dbo.dependencies

select * from dbo.dependencies

--then try to match referenced_schema_name with and referenced_entity_name with the database tables

select referenced_schema_name, referenced_entity_name, referenced_database_name,  t2.table_name, t3.Nom
from dbo.dependencies t1
inner join metadata.tables_views t2 on lower(t1.referenced_schema_name) = lower(t2.schema_name) and lower(t1.referenced_entity_name) = lower(t2.table_name)
inner join metadata.databases t3 on t1.referenced_database_name = t3.Nom 

--now try to to find all objects that references a certain table

select t4.database_name, t4.name, t5.text, t4.type_desc 
from dbo.dependencies t6 
inner join dbo.objects_table t4 on t6.referencing_id = t4.object_id and t6.database_name = t4.database_name
left outer join dbo.comments_table t5 on t4.object_id =  t5.id
where lower(t6.referenced_schema_name) = lower('ASFIM') and lower(t6.referenced_entity_name) = lower('ASFIM_COLLECTE_VALO')

select * from dbo.objects_table
select * from dbo.comments_table
select * from metadata.programmable_objects

--alimentation des dependencies

select * from metadata.programmable_objects

--checking if two object can have more than one dependencie
select count(*) from dbo.dependencies 
group by referenced_id, referencing_id, database_name, referenced_database_name, referencing_minor_id, referenced_minor_id
having count(*) <> 1

insert into metadata.programmable_objects
select distinct t1.referencing_id, t2.ID
from dbo.dependencies t1
inner join metadata.tables_views t2 on lower(t1.referenced_schema_name) = lower(t2.schema_name) and lower(t1.referenced_entity_name) = lower(t2.table_name)
inner join metadata.databases t3 on t1.referenced_database_name = t3.Nom

delete from metadata.programmable_objects

--the problem with this is that this is an n to n relationship so i have to add another table
--go back to altering tables sql file
--i think i should create a temp table that will store this data then store it into the two tables 


CREATE SEQUENCE metadata.programmable_objects_identity
    START WITH 1  
    INCREMENT BY 1 ;  
GO 

alter sequence metadata.programmable_objects_identity
restart


select  t4.object_id,min(t4.type_desc) as type_desc , min(t5.text) as text, min(t4.name) as name, t2.ID as ID_table, t7.id as id_database
into #temp_tables_objects
from dbo.dependencies t6 
inner join dbo.objects_table t4 on t6.referencing_id = t4.object_id and t6.database_name = t4.database_name
inner join metadata.databases t7 on t7.nom = t6.database_name
inner join metadata.databases t3 on t6.referenced_database_name = t3.Nom
inner join metadata.tables_views t2 on lower(t6.referenced_schema_name) = lower(t2.schema_name) and lower(t6.referenced_entity_name) = lower(t2.table_name) and t3.id = t2.ID_database
inner join dbo.comments_table t5 on t4.object_id =  t5.id
GROUP BY t4.object_id, t2.ID, t7.id


drop table #temp_tables_objects
select * from #temp_tables_objects  where object_id='1003150619'

select * from metadata.programmable_objects

--fill programmable_objects

select * from metadata.programmable_objects
delete from metadata.programmable_objects

insert into metadata.programmable_objects
select next value for metadata.programmable_objects_identity , type_desc, text, name, ID_database, object_id
from #temp_tables_objects
group by type_desc, text, name, ID_database, object_id

--fill tables_objects

select * from metadata.tables_PO
delete from metadata.tables_PO

insert into metadata.tables_PO
select t1.id_table, t2.ID
from #temp_tables_objects t1
inner join metadata.programmable_objects t2
on t1.object_id = t2.ID_object and t1.id_database = t2.object_database_id



