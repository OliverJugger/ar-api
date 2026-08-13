CREATE FORCE VIEW ARTHUS.V_LIB_PARAM AS
select idparam_tp,a.numgar
from gar_param_tp a,grnts b
where a.numgar=b.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_LIB_PARAM FOR ARTHUS.V_LIB_PARAM
