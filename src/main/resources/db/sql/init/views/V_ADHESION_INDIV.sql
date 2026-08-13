CREATE FORCE VIEW ARTHUS.V_ADHESION_INDIV AS
select distinct adhesion.numgar,
adhesion.numindiv,
refcie,
adhe_cntrt.idadhesion,
adhe_cntrt.ref_ext,
adhe_cntrt.date_adhe,
adhe_cntrt.date_fin_adhe
from adhesion,grnts,adhe_cntrt
where adhesion.numgar=grnts.numgar
and   adhesion.idadhesion=adhe_cntrt.idadhesion
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ADHESION_INDIV FOR ARTHUS.V_ADHESION_INDIV
