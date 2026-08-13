CREATE FORCE VIEW ARTHUS.V_ARTHUS_SOURCE AS
Select	nvl(package_name, object_name)	package_name,
	object_name
From	user_arguments
Group by
	package_name,
	object_name
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ARTHUS_SOURCE FOR ARTHUS.V_ARTHUS_SOURCE
