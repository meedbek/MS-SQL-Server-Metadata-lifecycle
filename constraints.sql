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


--constraintss 2sc essay
USE DataWarehouse

SELECT obj_table.NAME      AS 'table', 
        columns.NAME        AS 'column',
        obj_Constraint.NAME AS 'constraint',
        obj_Constraint.type AS 'type'

    FROM   sys.objects obj_table 
        JOIN sys.objects obj_Constraint 
            ON obj_table.object_id = obj_Constraint.parent_object_id 
        JOIN sys.sysconstraints constraints 
             ON constraints.constid = obj_Constraint.object_id 
        JOIN sys.columns columns 
             ON columns.object_id = obj_table.object_id 
            AND columns.column_id = constraints.colid 
    WHERE obj_table.NAME='table_name'
    ORDER  BY 'table'

SELECT obj_table.NAME      AS 'table', 
        columns.NAME        AS 'column',
        obj_Constraint.NAME AS 'constraint',
        obj_Constraint.type AS 'type',
        sss.name as 'schema',
        'ALTER TABLE [' + ltrim(rtrim(sss.name))+'].['+ltrim(rtrim(obj_table.name)) + '] DROP CONSTRAINT [' + obj_Constraint.NAME + '];' As 'Wrong_Implicit_Constraint',
        'ALTER TABLE [' + ltrim(rtrim(sss.name))+'].['+ltrim(rtrim(obj_table.name)) + '] ADD CONSTRAINT [' + CASE obj_Constraint.type 
        WHEN 'D' THEN 'DF' WHEN 'F' THEN 'FK' 
        WHEN 'U' THEN 'UX' WHEN 'PK' THEN 'PK' WHEN 'N' THEN 'NN' WHEN 'C' THEN 'CK' 
        END + '_' + ltrim(rtrim(obj_table.name)) + '_' + columns.NAME + ']' +
        CASE obj_Constraint.type WHEN 'D' THEN ' DEFAULT (' + dc.definition +') FOR [' + columns.NAME + ']'
        WHEN 'C' THEN ' CHECK (' + cc.definition +')'
        ELSE '' END +
        ';' As 'Right_Explicit_Constraint'
    FROM   sys.objects obj_table 
        JOIN sys.objects obj_Constraint ON obj_table.object_id = obj_Constraint.parent_object_id 
        JOIN sys.sysconstraints constraints ON constraints.constid = obj_Constraint.object_id 
        JOIN sys.columns columns ON columns.object_id = obj_table.object_id 
            AND columns.column_id = constraints.colid 
        left join sys.schemas sss on obj_Constraint.schema_id=sss.schema_id 
        left join sys.default_constraints dc on dc.object_id = obj_Constraint.object_id
        left join sys.check_constraints cc on cc.object_id = obj_Constraint.object_id
    WHERE obj_Constraint.type_desc LIKE '%CONSTRAINT'
    AND RIGHT(obj_Constraint.name,10) LIKE '[_][_]________' --match double underscore + 8 chars of anything
    AND RIGHT(obj_Constraint.name,8) LIKE '%[A-Z]%'          --Ensure alpha in last 8
    AND RIGHT(obj_Constraint.name,8) LIKE '%[0-9]%'                 --Ensure numeric in last 8
    AND RIGHT(obj_Constraint.name,8) not LIKE '%[^0-9A-Z]%' --Ensure no special chars