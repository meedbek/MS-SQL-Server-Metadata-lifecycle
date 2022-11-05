--my objectifs is to find the hiearchie of each stored procedures 

--we start by listing the concerned programmeble_objects

select id, ID_table from metadata.programmable_objects

--create a table that will store the hiearchie with all the components

drop table lineage.objects_hiearchie

create table lineage.objects_hiearchie (
	ID_object nchar(10),
	type nvarchar(50),
	content text,
	name nvarchar(100),
	ID_parent nchar(10),
	object_database_id nchar(10),
	parent_database_id nchar(10),
	depth int)


--load into the hiearchie table
delete from lineage.objects_hiearchie

WITH previous(referencing_id, referenced_id, referencing_database, referenced_database, depth)   
AS (  
-- This section provides the value for the root of the hierarchy  

select NULL as referencing_id, cast(t1.id_object as int) as referenced_id, NULL as referencing_database, cast(t1.object_database_id as int) as referenced_database, 0 as depth 
from metadata.programmable_objects t1

UNION ALL   
-- This section provides values for all nodes except the root  
SELECT d.referencing_id, d.referenced_id, cast(b1.id as int), cast(b2.id as int), p.depth + 1
FROM dbo.dependencies AS d 
inner join metadata.databases b1 on d.database_name = b1.Nom
inner join metadata.databases b2 on d.referenced_database_name = b2.Nom
JOIN previous AS p   
   ON d.referencing_id = p.referenced_id and b1.ID = p.referenced_database
where d.referenced_id is not null
--where exists (select * from dbo.objects_table o where d.referenced_id = o.object_id and d.referenced_database_name = o.database_name and  o.type_desc in ('SQL_INLINE_TABLE_VALUED_FUNCTION' ,'SQL_SCALAR_FUNCTION' ,'SQL_STORED_PROCEDURE', 'SQL_TABLE_VALUED_FUNCTION')) -- i dont think this is necessary
--and p.depth < 50 -- add it when u wanna stop
)
insert into lineage.objects_hiearchie(ID_object, ID_parent, object_database_id, parent_database_id, depth) 
select previous.referenced_id, previous.referencing_id, referenced_database, referencing_database, previous.depth
from previous --where previous.referencing_id IS NOT NULL

--the table stores a lot of repetitive relationship due to cycles so we need to delete them
--just skip this phase it was all for nothing 

--first do some math lol 
select count(*) from (select count(*) from lineage.objects_hiearchie group by referenced_id, referencing_id) as t
select count(*) from lineage.objects_hiearchie
--then delete 

--i have a better solution i'll create a second table
select top 0 * 
into lineage.optm_objects_hiearchie 
from lineage.objects_hiearchie

--then i ll insert non duplicated referenced and referenced pairs

insert into lineage.optm_objects_hiearchie(ID_object, ID_parent, object_database_id, parent_database_id, depth)
select ID_object, ID_parent, object_database_id, parent_database_id, min(depth) from lineage.objects_hiearchie 
group by ID_object, ID_parent, object_database_id, parent_database_id

-- hope this works :) :)
select * from lineage.objects_hiearchie

-- complete table data

UPDATE lineage.objects_hiearchie 
set type = x.type, content = x.content, name = x.name
from  (select  t4.object_id, t4.type_desc as type, t5.text as content, t4.name as name, t4.database_name 
	from dbo.objects_table t4 
	left outer join dbo.comments_table t5 on t4.object_id =  t5.id and t4.database_name = t5.database_name) x
where id_object = x.object_id and object_database_id in (select id from metadata.databases where nom = x.database_name)

select distinct type from metadata.programmable_objects
select distinct type_desc from dbo.objects_table 
select * from lineage.objects_hiearchie

----------------------------------------------------------------------------------------- 

--i think you would need another table similar to the lineage.objects_hierarchie

drop table lineage.full_objects_hierachie

select top 0 * 
into lineage.full_objects_hierachie
from lineage.objects_hiearchie


--same code to add data to the table but this time we gonna include all elements in dbo.dependencies

delete from lineage.full_objects_hierachie

WITH previous(referencing_id, referenced_id, referencing_database, referenced_database, depth)   
AS (  

	select  NULL, cast(t1.object_id as int), NULL, cast(t2.ID as int), 0
	from dbo.objects_table t1 
	inner join metadata.databases t2 on t1.database_name = t2.Nom
	where t1.type_desc in (select distinct t4.type_desc
		from dbo.dependencies t6 
		inner join dbo.objects_table t4 on t6.referencing_id= t4.object_id and t6.database_name = t4.database_name)

	UNION ALL   

	SELECT d.referencing_id, d.referenced_id, cast(b1.id as int), cast(b2.id as int), p.depth + 1
	FROM dbo.dependencies AS d 
	inner join metadata.databases b1 on d.database_name = b1.Nom
	inner join metadata.databases b2 on d.referenced_database_name = b2.Nom
	JOIN previous AS p   
		ON d.referencing_id = p.referenced_id and b1.ID = p.referenced_database
	where d.referenced_id is not null
)
insert into lineage.full_objects_hierachie(ID_object, ID_parent, object_database_id, parent_database_id, depth) 
select previous.referenced_id, previous.referencing_id, referenced_database, referencing_database, previous.depth
from previous 

-- complete table data

UPDATE lineage.full_objects_hierachie
set type = x.type, content = x.content, name = x.name
from  (select  t4.object_id, t4.type_desc as type, t5.text as content, t4.name as name, t4.database_name 
	from dbo.objects_table t4 
	left outer join dbo.comments_table t5 on t4.object_id =  t5.id and t4.database_name = t5.database_name) x
where id_object = x.object_id and object_database_id in (select id from metadata.databases where nom = x.database_name)
