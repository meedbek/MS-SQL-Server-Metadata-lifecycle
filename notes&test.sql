select t1.*,t2.* from metadata.tables_views t1 inner join metadata.tables_PO t3 on t1.id = t3.id_table inner join metadata.programmable_objects t2 on t2.ID = t3.ID_object where t2.id_object = '1003150619'
select t2.* from metadata.tables_PO t3  inner join metadata.programmable_objects t2 on t2.ID = t3.ID_object where t2.id_object = '1003150619'
select * from metadata.programmable_objects where id_object = '1003150619'
select * from metadata.databases where ID = 7

select * from dbo.objects_table where object_id='1003150619' 
select * from dbo.objects_table
  
select * from metadata.tables_views where table_name = 'Histo_Contrib_MBI'

select * from dbo.dependencies where referencing_id='1003150619'
select * from lineage.full_objects_hierachie where id_parent='1003150619'

  ---fonctions :
  ---tables impacté - fonctions à laquelle fait référence