CREATE FORCE VIEW ARTHUS.V_ECHEANCE_LBEN AS
select b.idcalcul,
       a.nosin,
       b.debut,
       b.fin,
       c.numdec,
       c.montant mnt_dcpte,
       d.numdecaismt,
       b.numbene,
       sum( f_total_histo(e.idhisto, -2) )   montant ,
       sum( f_total_histo(e.idhisto, 0) )    reval,
       sum( f_total_histo(e.idhisto, -3) )   dedu    ,
       (
                sum( f_total_histo(e.idhisto, -1) )+
                sum( f_total_histo(e.idhisto, 0) )
       ) montant_remb,
       sum( f_total_histo(e.idhisto, -1) )   mt_base,
       sum( f_total_histo_d(e.idhisto, -2) )   montant_d,
       sum( f_total_histo_d(e.idhisto, 0) )    reval_d,
       sum( f_total_histo_d(e.idhisto, -3) )   dedu_d,
       (
                sum( f_total_histo_d(e.idhisto, -1) )+
                sum( f_total_histo_d(e.idhisto, 0) )
       ) montant_remb_d,
       sum( f_total_histo_d(e.idhisto, -1) )   mt_base_d,
       f.numgar
from repartition a,
     histo_calcul b,
     decompte_prev c,
     affectation d,
     histo_jours e,
     adhe_cntrt f,
     compte_tiers g,
     compensation h,
     compte_tiers i
where a.idrepartition=b.idrepartition
and   e.idcalcul = b.idcalcul
and   b.numdec=c.numdec
and   g.codope=2
and   g.cle= c.numdec
and   d.numaffec=c.numdec
and   h.idmvt=g.idmvt
and   h.idcomp=i.idmvt
and   f.idadhesion=c.idadhesion
and   d.codope=10
Group by
        b.idcalcul,
	b.numbene,
	f.numgar,
	c.numdec,
	c.montant,
        a.nosin,
	d.numdecaismt,
	b.debut,
	b.fin
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ECHEANCE_LBEN FOR ARTHUS.V_ECHEANCE_LBEN
