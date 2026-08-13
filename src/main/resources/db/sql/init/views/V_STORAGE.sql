CREATE FORCE VIEW ARTHUS.V_STORAGE AS
select	segment_name,
	segment_type,
	tablespace_name,
	sum(bytes)*1.5 s_initial,
	sum(bytes) s_next
from	user_extents
group by segment_name,
	segment_type,
	tablespace_name
GO
CREATE OR REPLACE PUBLIC SYNONYM V_STORAGE FOR ARTHUS.V_STORAGE
