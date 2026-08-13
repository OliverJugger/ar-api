CREATE FORCE VIEW ARTHUS.V_EDIT_PRELEVEMENT AS
SELECT compte.numsoc, remise_prelev.numremise,
             remise_prelev.numremise
          || ' du '
          || TO_CHAR (remise_prelev.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_prelev.nombre
          || ' prélèvements' lib_remise,
          remise_prelev.numcpte, prelevement.numprelev, prelevement.montant,
          prelevement.monnaie, prelevement.montant_d, prelevement.monnaie_d,
          TO_NUMBER ('') motif_annul,
		  -- MODIF TLE SEPA : si BBAN non null, on l'affiche à la place des anciennes infos : codbanque, guichet...
          -- prelevement.codbque|| ' ' || prelevement.guichet || ' ' || prelevement.compte || ' ' || prelevement.clerib || ' ' || prelevement.intitule rib,
		   DECODE (PRELEVEMENT.BBAN, NULL, PRELEVEMENT.codbque||' '|| PRELEVEMENT.guichet||' '|| PRELEVEMENT.compte||' '|| PRELEVEMENT.clerib||' '|| PRELEVEMENT.intitule,
                                           PRELEVEMENT.CLEF_IBAN ||' '|| PRELEVEMENT.BBAN ||' '|| PRELEVEMENT.intitule ) RIB,
		  compte.numcpte || ' - ' || compte.libcompte lib_compte,
          compte.domicil,
             compte.guichet
          || ' '
          || compte.compte
          || ' '
          || compte.clerib rib_compte,
          compte.rais_soc
     FROM remise_prelev, prelevement, compte
    WHERE compte.numcpte = remise_prelev.numcpte
      AND prelevement.numremise = remise_prelev.numremise
   UNION
   SELECT compte.numsoc, remise_prelev.numremise,
             remise_prelev.numremise
          || ' du '
          || TO_CHAR (remise_prelev.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_prelev.nombre
          || ' prélèvements' lib_remise,
          remise_prelev.numcpte, prelevement.numprelev, -prelevement.montant,
          prelevement.monnaie, -prelevement.montant_d, prelevement.monnaie_d,
          annul_encais.motif motif_annul,
          'rejeté le ' || TO_CHAR (annul_encais.date_annul, 'dd/mm/yyyy') rib,
          compte.numcpte || ' - ' || compte.libcompte lib_compte,
          compte.domicil,
             compte.guichet
          || ' '
          || compte.compte
          || ' '
          || compte.clerib rib_compte,
          compte.rais_soc
     FROM remise_prelev, annul_encais, prelevement, compte
    WHERE compte.numcpte = remise_prelev.numcpte
      AND prelevement.numremise = remise_prelev.numremise
      AND annul_encais.numencaismt = prelevement.numencaismt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EDIT_PRELEVEMENT FOR ARTHUS.V_EDIT_PRELEVEMENT
