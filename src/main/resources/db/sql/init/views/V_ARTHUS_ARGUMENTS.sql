CREATE FORCE VIEW ARTHUS.V_ARTHUS_ARGUMENTS AS
Select	nvl(argument_name, 'Return')	argument_name,
	object_name,
	nvl(package_name, object_name)	package_name,
	position,
	data_type,
	default_value,
	in_out
From	user_arguments
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ARTHUS_ARGUMENTS FOR ARTHUS.V_ARTHUS_ARGUMENTS
