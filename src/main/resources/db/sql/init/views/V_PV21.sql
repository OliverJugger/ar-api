CREATE FORCE VIEW ARTHUS.V_PV21 AS
select	sin.numindiv,
	sin.nosin,
	sin.norisq,
	lble_risq.libelle libnorisq,
	sin.nositu,
	lble_situ_sin.libelle libnositu,
	to_char(sin.datesurv,'DD/MM/YY') datesurv
from	sin,
	libelle lble_risq ,
	libelle lble_situ_sin
where	lble_risq.mnemo='RISQ'
and	lble_risq.code = sin.norisq
and	lble_situ_sin.mnemo='SITU-SIN'
and	lble_situ_sin.code = sin.nositu
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PV21 FOR ARTHUS.V_PV21
