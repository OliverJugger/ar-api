CREATE FORCE VIEW ARTHUS.V_ORDRE_PAIEMENT AS
SELECT   sum(montant_ct) montant_ct,
         sum(montant)  montant,
         sum(montant_d)  montant_d,
         max(numdecaismt) numdec,
         numvirement numvirement,
         count(numvirement) nombre,
         numremise,
         nature,
         decode(nature,2,codbque,3,codbque_etrg) codbanque,
         decode(nature,2,guichet,3,guichet_etrg) guichetbanque,
         decode(nature,2,compte,3,compte_etrg)   comptebanque,
         decode(nature,2,clerib,3,clerib_etrg)   cleribbanque,
         decode(nature,3,typ_bq_etrg) typbanque,
         decode(nature,3,typ_gui_etrg) typguichet,
         decode(nature,3,typ_cle_etrg) typcle,
         clef_iban,
         bban,
         bic,
         monnaie_d,
         monnaie_ct,
         numcpte,
         modpmt,
         numindiv_etrg,
         codpays,
		     monnaie,
		     intitule
FROM remise_op_detail
Group By
       decode(nature,2,codbque,3,codbque_etrg),
       decode(nature,2,guichet,3,guichet_etrg),
       decode(nature,2,compte,3,compte_etrg),
       decode(nature,2,clerib,3,clerib_etrg),
       decode(nature,3,typ_bq_etrg) ,
       decode(nature,3,typ_gui_etrg),
       decode(nature,3,typ_cle_etrg),
       clef_iban,
       bban,
       bic,
       numremise,numvirement,nature,monnaie_d,monnaie_ct,numcpte,modpmt,numindiv_etrg,codpays,monnaie,intitule
ORDER By numvirement
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ORDRE_PAIEMENT FOR ARTHUS.V_ORDRE_PAIEMENT
