CREATE FORCE VIEW ARTHUS.V_FORMULE AS
select formule.numfor       numfor_ref,
 formule.numprod       numprod,
 formule.numass       numass,
 gar_cntrt_ref.numfor      numfor
from formule,
 gar_cntrt_ref
where formule.numfor = gar_cntrt_ref.numfor_ref
and formule.numprod > 0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FORMULE FOR ARTHUS.V_FORMULE
