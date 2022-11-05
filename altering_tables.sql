--some testing 

USE TEST;

select top 100 * from comments_table as c where ((LOWER(c.text) LIKE '% insert%') or (LOWER(c.text) LIKE '% create view%') or (LOWER(c.text) LIKE '% merge%') )

Drop View Alimentation

CREATE VIEW Alimentation as 
select top 100 id, text from comments_table as c where ((LOWER(c.text) LIKE '% insert%') or (LOWER(c.text) LIKE '% create view%') or (LOWER(c.text) LIKE '% merge%') ) and texttype = 0


DECLARE textC CURSOR FOR SELECT text FROM Alimentation;
DECLARE @textT VARCHAR(MAX);

OPEN textC  
FETCH NEXT FROM textC INTO @textT

WHILE @@FETCH_STATUS = 0  
BEGIN 
      print @textT
END  

CLOSE textC
DEALLOCATE textC

--alter tables created using GUI
----

alter table metadata.tables_views alter column ID nchar(10) not null
alter table metadata.table_object alter column ID_table nchar(10) not null

alter table metadata.tables_views add constraint tbv_pk primary key (ID) 
alter table metadata.table_object  add constraint tot_fk foreign key (ID_table) references metadata.tables_views

alter table metadata.tables_views add schema_name nvarchar(50)

alter table metadata.colonnes add default_value nvarchar(50)

alter table metadata.tables_views drop column table_name
alter table metadata.tables_views add table_name nvarchar(128)

alter table metadata.colonnes drop column maximum_lenght
alter table metadata.colonnes add maximum_lenght int

alter table metadata.colonnes drop column datatype
alter table metadata.colonnes add datatype nvarchar(50)

alter table metadata.constraints drop column constraint_name
alter table metadata.constraints add constraint_name nvarchar(128)

alter table metadata.constraints drop column details
alter table metadata.constraints add details nvarchar(max)
--add data creating of database

alter table metadata.databases add create_date datetime

--make constraints table refer to table instead of colonnes

select * from metadata.constraints

alter table metadata.constraints drop constraint cn_fk
alter table metadata.constraints drop column ID_colonne

alter table metadata.constraints add ID_table nchar(10)
alter table metadata.constraints add constraint tablecost_fk foreign key (ID_table) references metadata.tables_views

alter table metadata.programmable_objects add name nvarchar(50)

--add dependencie id to table_object 

alter table metadata.table_object add ID nchar(10) primary key
alter table metadata.table_object drop constraint PK__table_ob__3214EC27D6440C42
alter table metadata.table_object drop column ID

--i m gonna make the connection 1 n instead of n n

alter table metadata.programmable_objects add ID_table nchar(10) foreign key references metadata.tables_views

alter table metadata.programmable_objects alter column content text

alter table lineage.objects_hiearchie add depth int

--alter metadata.columns table by adding columns noted from reporting class

alter table metadata.colonnes add null_count int
alter table metadata.colonnes add per_populated int
alter table metadata.colonnes add distc_value_count int
alter table metadata.colonnes add min_value nvarchar(50)
alter table metadata.colonnes add max_value nvarchar(50)

--alter metadata.programmable_objects

delete from metadata.programmable_objects
alter table  metadata.programmable_objects
add object_database_id nchar(10) not null

alter table metadata.programmable_objects 
drop constraint PO_pk

alter table metadata.programmable_objects
drop column object_database_id

select * from metadata.programmable_objects
alter table metadata.programmable_objects add constraint PO_pk primary key (ID,object_database_id)

--details

alter table metadata.colonnes drop column constraint_id

--alter the programmable objects table
--delete the id_table field

select * from metadata.programmable_objects
alter table metadata.programmable_objects drop constraint FK__programma__ID_ta__02084FDA
alter table metadata.programmable_objects drop column id_table
alter table metadata.programmable_objects drop constraint PO_PK
alter table metadata.programmable_objects add id_object nchar(10) 
alter table metadata.programmable_objects add constraint PK_PO primary key (ID)

--create the relation table that will connect both programmable_objects and tables_views

create table metadata.tables_PO (
	ID_table nchar(10) foreign key references metadata.tables_views(ID),
	ID_Object nchar(10) foreign key references metadata.programmable_objects(ID)
)