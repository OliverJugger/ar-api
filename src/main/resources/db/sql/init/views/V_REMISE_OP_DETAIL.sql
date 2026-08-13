CREATE FORCE VIEW ARTHUS.V_REMISE_OP_DETAIL AS
SELECT compte.numsoc, remise_op.numremise,
             remise_op.numremise
          || ' du '
          || TO_CHAR (remise_op.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_op.nombre
          || ' Ordres de Paiements' lib_remise,
          remise_op.numcpte, decaismt.codope, remise_op_detail.numvirement,
          decaismt.numbene, v_lib_affec.lib_affec lib_vire,
          v_lib_affec.numaffec numaffec, v_lib_affec.codapli codapli,
          v_lib_affec.montant montant_piece,
          v_lib_affec.monnaie monnaie_piece,
          v_lib_affec.montant_d montant_piece_d,
          v_lib_affec.monnaie_d monnaie_piece_d, remise_op_detail.montant,
          remise_op_detail.monnaie, remise_op_detail.montant_d,
          remise_op_detail.monnaie_d, remise_op_detail.montant_ct,
          remise_op_detail.monnaie_ct,
          DECODE(remise_op_detail.bban,NULL,
          decode(remise_op_detail.typ_bq_etrg, null, '', remise_op_detail.codbque_etrg||' ')
          ||decode(remise_op_detail.typ_gui_etrg, null, '', remise_op_detail.guichet_etrg||' ')
          ||remise_op_detail.compte_etrg
          ||' '
          ||decode(remise_op_detail.typ_cle_etrg, null, '', remise_op_detail.clerib_etrg||' '),
          ARTHUS.pk_sepa.f_afficher_compte(remise_op_detail.bic, remise_op_detail.clef_iban||remise_op_detail.bban, remise_op_detail.intitule, 'IBAN+INTITULE LONG')
          ||remise_op_detail.intitule
          ) rib,
          compte.numcpte || ' - ' || compte.libcompte lib_compte,
          ope.code || ' - ' || ope.libelle lib_ope, decaismt.numdecaismt
     FROM compte,
          libelle ope,
          decaismt,
          v_lib_affec,
          remise_op,
          remise_op_detail
    WHERE ope.code = decaismt.codope
      AND ope.mnemo = 'OPE'
      AND compte.numcpte = remise_op.numcpte
      AND remise_op_detail.numremise = remise_op.numremise
      AND remise_op_detail.numdecaismt = decaismt.numdecaismt
      AND decaismt.numdecaismt = v_lib_affec.numdecaismt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_OP_DETAIL FOR ARTHUS.V_REMISE_OP_DETAIL
