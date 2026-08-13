CREATE FORCE VIEW ARTHUS.V_FORCAGE AS
select
    v_societe.numsoc,
    v_societe.numinterm,
    v_societe.nom socnom,
    forcage.numsin,
    forcage.username,
    forcage.numindiv,
    forcage.codfrais,
    forcage.numgar,
    forcage.mtfrais,
    forcage.codmon,
    forcage.mtfrais_d,
    forcage.codmon_d,
    forcage.nbacte,
    forcage.datsai,
    forcage.type,
    sinistre.datsin,
    acte.libelle,
    indvs.nom||' '||indvs.prenom nom,
    util.numutil,
    util.nom utilnom,
    libelle.libelle libtype
from    v_societe,
        contrat,
        forcage,
        acte,
        indvs,
        util,
        sinistre,
        libelle
where v_societe.numsoc=contrat.numinterm
and   contrat.numgar=forcage.numgar
and   forcage.codfrais=acte.codfrais
and   forcage.numindiv=indvs.numindiv
and   forcage.username=util.numutil
and   forcage.numsin=sinistre.numsin
and   libelle.mnemo='FORCAGE'
and   libelle.code=forcage.type
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FORCAGE FOR ARTHUS.V_FORCAGE
