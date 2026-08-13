CREATE FORCE VIEW ARTHUS.V_REGROUP_MANDAT AS
select
  hm.mandat
, hm.idrib
, hq.mandat_maitre
, hq.numquerable
, hq.idadhesion
, hq.numgar
, '<'||r.bic||'><'||r.bban||'><'||r.clef_iban||'>' inf_banc
, hq.idhistoquerable
from histo_mandat hm , histo_querable HQ , rib r
where hm.mandat = hq.mandat and hq.etat = 1
and r.idrib = hm.idrib
and hm.IDHISTOMANDAT = (select max(hm2.IDHISTOMANDAT) from histo_mandat hm2 where hm2.mandat = hm.mandat )
and hq.mandat = hq.mandat_maitre
-- exclusion des mandats maitres d'autres mandats
and not exists (select 1 from histo_querable HQ2 where hq2.mandat_maitre = hq.mandat and hq2.mandat != hq2.mandat_maitre   )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REGROUP_MANDAT FOR ARTHUS.V_REGROUP_MANDAT
