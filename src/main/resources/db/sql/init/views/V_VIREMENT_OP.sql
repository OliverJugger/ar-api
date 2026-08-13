CREATE FORCE VIEW ARTHUS.V_VIREMENT_OP AS
SELECT   compte.numsoc, remise_op.numremise, remise_op.numcpte,
            remise_op_detail.numvirement,
            remise_op.numcpte || ' ' || compte.libcompte lib_compte,
               remise_op.numremise
            || ' du '
            || TO_CHAR (remise_op.datrem, 'dd/mm/yyyy')
            || ' - '
            || remise_op.nombre
            || ' Ordres de Paiements' lib_remise,
			  decode(remise_op_detail.typ_bq_etrg, null, '', remise_op_detail.codbque_etrg||' ')
            ||decode(remise_op_detail.typ_gui_etrg, null, '', remise_op_detail.guichet_etrg||' ')
            ||remise_op_detail.compte_etrg
            ||' '
			||decode(remise_op_detail.typ_cle_etrg, null, '', remise_op_detail.clerib_etrg||' ')
            ||remise_op_detail.intitule rib,
            SUM (NVL (remise_op_detail.montant, 0)) montant,
            remise_op_detail.monnaie,
            SUM (NVL (remise_op_detail.montant_d, 0)) montant_d,
            remise_op_detail.monnaie_d, remise_op.datdisk
       FROM remise_op, remise_op_detail, compte
      WHERE compte.numcpte = remise_op.numcpte
        AND remise_op_detail.numremise = remise_op.numremise
   GROUP BY compte.numsoc,
            remise_op.numremise,
            remise_op.numcpte,
            remise_op_detail.numvirement,
            compte.libcompte,
            remise_op.numremise
            || ' du '
            || TO_CHAR (remise_op.datrem, 'dd/mm/yyyy')
            || ' - '
            || remise_op.nombre
            || ' Ordres de Paiements',
			 decode(remise_op_detail.typ_bq_etrg, null, '', remise_op_detail.codbque_etrg||' ')
            ||decode(remise_op_detail.typ_gui_etrg, null, '', remise_op_detail.guichet_etrg||' ')
            ||remise_op_detail.compte_etrg
            ||' '
			||decode(remise_op_detail.typ_cle_etrg, null, '', remise_op_detail.clerib_etrg||' ')
            ||remise_op_detail.intitule,
            remise_op.datdisk,
            remise_op_detail.monnaie,
            remise_op_detail.monnaie_d
GO
CREATE OR REPLACE PUBLIC SYNONYM V_VIREMENT_OP FOR ARTHUS.V_VIREMENT_OP
