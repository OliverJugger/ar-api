CREATE FORCE VIEW ARTHUS.V_ARTHUS_PACK AS
Select	nvl(package_name, 'NULL')	package_name
From	user_arguments
Group by
	package_name
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ARTHUS_PACK FOR ARTHUS.V_ARTHUS_PACK
