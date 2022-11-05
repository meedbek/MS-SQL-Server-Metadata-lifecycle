use test;
GO

--first problem is that I only stored SP that do reference one the tables in the databases
--second thing this should be changed to make possible searching also by schema name meaning i should add schema_name field in PO table
CREATE PROCEDURE metadata.referencedTables  
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

EXEC metadata.referencedTables @SP_name = 'Get_MASI_VOLUME'
    , @Database = 'DataWarehouse' ;
GO

--frist problem with that i stored all types of objects that may reference a specific object 
--second one is taht their is a lot of possibilites lets do one by one 

CREATE PROCEDURE metadata.following_objects
	@SP_name nvarchar(50),   
    @Database nvarchar(50)  
AS   
	WITH recursion(ID_object, type, content, name, ID_parent,object_database_id,parent_database_id,depth)   
	AS (  

		select d.*
		from lineage.objects_hiearchie d 
		inner join metadata.databases db on d.object_database_id = db.id
		where lower(name) = lower(@SP_name) and lower(db.nom) = lower(@Database) 

		UNION ALL   

		-- This section provides values for all nodes except the root  
		SELECT  d.*
		FROM lineage.objects_hiearchie d
		JOIN recursion AS p   
		   ON d.ID_parent = p.ID_object and d.parent_database_id = p.object_database_id
	)
	select * from recursion
GO  


EXEC metadata.referencedTables @SP_name = 'Insert_Compos_MBI'
    , @Database = 'ODS_DB' ;
GO

EXEC metadata.following_objects @SP_name = 'Insert_Compos_MBI'
    , @Database = 'ODS_DB' ;
GO

select * from dbo.dependencies where referencing_id = '667149422' 
select * from lineage.objects_hiearchie where ID_parent = '667149422'

--now time to write proceeding objects procedure

--this how I m gonna procede first retrive object that refer a certain table then use CTE to retreive the rest of the data
-- its the same thing as following_object not a lot of changes will be made.

--defining the procedure
CREATE PROCEDURE metadata.Proceeding_objects
	@SP_name nvarchar(50),   
    @Database nvarchar(50)  
AS   
	WITH recursion(ID_object, type, content, name, ID_parent,object_database_id,parent_database_id,depth)   
	AS (  

		select d.*
		from lineage.objects_hiearchie d 
		inner join metadata.databases db on d.object_database_id = db.id
		where lower(name) = lower(@SP_name) and lower(db.nom) = lower(@Database) 

		UNION ALL   

		-- This section provides values for all nodes except the root  
		SELECT  d.*
		FROM lineage.objects_hiearchie d
		JOIN recursion AS p   
		   ON p.ID_parent = d.ID_object and p.parent_database_id = d.object_database_id -- this is the only line i had to change
	)
	select * from recursion
GO  

--test
select * from lineage.full_objects_hierachie where depth = (select max(depth) from lineage.full_objects_hierachie)

EXEC metadata.Proceeding_objects @SP_name = 'HISTO_BENCHMARK'
    , @Database = 'ODS_DB' ;
GO
