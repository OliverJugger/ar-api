CREATE FORCE VIEW ARTHUS.V_MODELE AS
select	table_name,
	column_name,
	data_type,
	data_length,
	data_precision,
	data_scale,
	nullable,
	column_id
from	cols
where	table_name in (
		select 	tname
		from	tab
		where 	tabtype = 'TABLE')
GO
CREATE OR REPLACE PUBLIC SYNONYM V_MODELE FOR ARTHUS.V_MODELE
