CREATE FORCE VIEW ARTHUS.V_QTTC_GLOB AS
select		qttc_global.numgar,
		qttc_global.numquit,
		to_char(qttc_global.datemis,'dd/mm/yy') edatemis,
		to_char(qttc_global.debut,'dd/mm/yy') edebut,
		to_char(qttc_global.fin,'dd/mm/yy') efin,
		grnts.refcie,
		qttc_global.mt_ttc,
		qttc_global.mt_affec
from		qttc_global,
		grnts
where		grnts.numgar	=	qttc_global.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_GLOB FOR ARTHUS.V_QTTC_GLOB
