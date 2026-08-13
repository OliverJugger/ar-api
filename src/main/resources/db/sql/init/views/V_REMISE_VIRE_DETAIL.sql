CREATE FORCE VIEW ARTHUS.V_REMISE_VIRE_DETAIL AS
SELECT compte.numsoc, remise_vire.numremise,
             remise_vire.numremise
          || ' du '
          || TO_CHAR (remise_vire.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_vire.nombre
          || ' virements' lib_remise,
          remise_vire.numcpte, decaismt.codope,
          remise_vire_detail.numvirement, decaismt.numbene,
          v_lib_affec.lib_affec lib_vire, v_lib_affec.numaffec numaffec,
          v_lib_affec.codapli codapli, v_lib_affec.montant montant_piece,
          v_lib_affec.monnaie monnaie_piece,
          v_lib_affec.montant_d montant_piece_d,
          v_lib_affec.monnaie_d monnaie_piece_d, remise_vire_detail.montant,
          remise_vire_detail.monnaie, remise_vire_detail.montant_d,
          remise_vire_detail.monnaie_d,
		  -- MODIF TLE SEPA : si BBAN non null, on l'affiche à la place des anciennes infos : codbanque, guichet...
          --remise_vire_detail.codbque ||' '|| remise_vire_detail.guichet||' '|| remise_vire_detail.compte||' '|| remise_vire_detail.clerib||' '|| remise_vire_detail.intitule rib,
		  DECODE (REMISE_VIRE_DETAIL.BBAN, NULL, remise_vire_detail.codbque||' '|| remise_vire_detail.guichet||' '|| remise_vire_detail.compte||' '|| remise_vire_detail.clerib||' '|| remise_vire_detail.intitule,
                            REMISE_VIRE_DETAIL.CLEF_IBAN ||' '|| REMISE_VIRE_DETAIL.BBAN || ' '||  remise_vire_detail.intitule) RIB,
		  compte.numcpte || ' - ' || compte.libcompte lib_compte,
          ope.code || ' - ' || ope.libelle lib_ope, decaismt.numdecaismt
     FROM compte,
          libelle ope,
          decaismt,
          v_lib_affec,
          remise_vire,
          remise_vire_detail
    WHERE ope.code = decaismt.codope
      AND ope.mnemo = 'OPE'
      AND compte.numcpte = remise_vire.numcpte
      AND remise_vire_detail.numremise = remise_vire.numremise
      AND remise_vire_detail.numdecaismt = decaismt.numdecaismt
      AND decaismt.numdecaismt = v_lib_affec.numdecaismt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_VIRE_DETAIL FOR ARTHUS.V_REMISE_VIRE_DETAIL
