CREATE FORCE VIEW ARTHUS.V_DCPT_ANNUL AS
select  distinct decompte_annul.numdec,
  decompte_annul.numgar,
  decompte_annul.datpay      odatedec,
  to_char(decompte_annul.datpay,'dd/mm/yy') datedec,
  grnts.refcie,
  decompte_annul.numindiv,
  assure.nom    nom_assu,
  assure.prenom    prenom_assu,
  assure.nom||' '||assure.prenom nomassu,
  assure.matorg,
  decompte_annul.typbene,
  decompte_annul.numbene,
  decode(decompte_annul.typbene, 1, 'L''assure', 2, 'L''organisme T.P.', 3, 'Le fournisseur', 4,'L''établissement','Autre organisme') lib_bene,
  bene.nom      nom_bene,
  bene.prenom      prenom_bene,
  bene.nom||' '||bene.prenom nombene,
  to_char(decaismt.datpay,'dd/mm/yy') datpay,
  decaismt.datpay        odatpay,
  f_lble('MOPM',decaismt.modpmt) libmodpmt,
  affectation_annul.codope,
  decaismt.refpmt,
  affectation_annul.numdecaismt,
  affectation_annul.montant,
  affectation_annul.monnaie,
  affectation_annul.montant_d,
  affectation_annul.monnaie_d,
  decaismt.modpmt,
  decaismt.numcpte,
  decaismt.numchq,
  decompte_annul.numutil,
  util.pseudo,
  decaismt.datedit,
  decaismt.numedit
from  decompte_annul,
  grnts,
  indvs assure,
  indvs bene,
  affectation_annul,
  decaismt,
  util
where  decompte_annul.numgar  = grnts.numgar
and  decompte_annul.numindiv  = assure.numindiv
and  decompte_annul.numbene  = bene.numindiv
and  decompte_annul.numdec  = affectation_annul.numaffec
and  affectation_annul.codope  = 1
and  decaismt.numdecaismt(+) = affectation_annul.numdecaismt
and  util.numutil  = decompte_annul.numutil
and decompte_annul.numdec not in (SELECT numdec FROM decompte )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPT_ANNUL FOR ARTHUS.V_DCPT_ANNUL
