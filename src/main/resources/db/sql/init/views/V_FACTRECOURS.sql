CREATE FORCE VIEW ARTHUS.V_FACTRECOURS AS
select
    recours_sinistre.numrecours,
    recours_sinistre.codfrais,
    recours_sinistre.datsin,
    recours_sinistre.mtfrais,
    recours_sinistre.mtremb,
    recours_sinistre.mtreel,
    recours_sinistre.mtrecour,
    recours_sinistre.datdcpt,
    recours_sinistre.numdec,
    recours_facture.creation datfact,
    recours_facture.numordre,
    recours_facture.montant,
    recours_facture.description,
    recours.numorg,
    recours.numassu,
    recours.creation datcrea,
    recours.ref_ext,
    recours.conso,
    acte.libelle,
    orgns.nom orgns_nom,
    orgns.adr1 orgns_adr1,
    orgns.adr2 orgns_adr2,
    orgns.codpos orgns_codpos,
    orgns.ville orgns_ville,
    indvs.nom indvs_nom,
    indvs.prenom indvs_prenom,
    indvs.adr1 indvs_adr1,
    indvs.adr2 indvs_adr2,
    indvs.codpos indvs_codpos,
    indvs.ville indvs_ville
from   recours_sinistre,
       recours_facture,
       recours,
       acte,
       indvs,
       orgns
where
       recours.numrecours=recours_facture.numrecours
and    recours_facture.etat=1
and    recours_facture.numrecours=recours_sinistre.numrecours
and    recours_facture.numordre=recours_sinistre.numfact
and    recours_sinistre.codfrais=acte.codfrais
and    recours.numorg=orgns.numorg
and    recours.numassu=indvs.numindiv
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FACTRECOURS FOR ARTHUS.V_FACTRECOURS
