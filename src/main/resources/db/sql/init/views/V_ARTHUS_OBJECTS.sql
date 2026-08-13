CREATE FORCE VIEW ARTHUS.V_ARTHUS_OBJECTS AS
select object_name, object_type from user_objects
where  object_type in('TABLE','SEQUENCE','SYNONYM')
minus
select "OBJECT_NAME","OBJECT_TYPE" from client_objects
where  object_type in('TABLE','SEQUENCE','SYNONYM')
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ARTHUS_OBJECTS FOR ARTHUS.V_ARTHUS_OBJECTS
