CREATE FORCE VIEW ARTHUS.V_PARAM_BASCULE AS
Select 	table_name,
	column_name,
	data_type,
	data_precision,
	data_scale,
	2		Type
From 	cols
Where 	data_scale >= 2
and 	table_name in (
	select	tname
	from	tab
	where	tabtype = 'TABLE')
Union
Select 	table_name,
	Null,
	Null,
	0,
	0,
	1		Type
From 	cols
Where 	data_scale >= 2
and 	table_name in (
	select	tname
	from	tab
	where	tabtype = 'TABLE')
Group By
	table_name
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PARAM_BASCULE FOR ARTHUS.V_PARAM_BASCULE
