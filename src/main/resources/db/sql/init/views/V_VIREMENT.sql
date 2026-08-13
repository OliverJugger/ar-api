CREATE FORCE VIEW ARTHUS.V_VIREMENT AS
SELECT   compte.numsoc, remise_vire.numremise, remise_vire.numcpte,
            remise_vire_detail.numvirement,
            remise_vire.numcpte || ' ' || compte.libcompte lib_compte,
               remise_vire.numremise
            || ' du '
            || TO_CHAR (remise_vire.datrem, 'dd/mm/yyyy')
            || ' - '
            || remise_vire.nombre
            || ' virements' lib_remise,
            ---remise_vire_detail.codbque|| ' '|| remise_vire_detail.guichet|| ' '|| remise_vire_detail.compte|| ' '|| remise_vire_detail.clerib|| ' ' || remise_vire_detail.intitule rib,
            DECODE (REMISE_VIRE_DETAIL.BBAN, null, remise_vire_detail.codbque || ' ' || remise_vire_detail.guichet || ' ' || remise_vire_detail.compte || ' ' || remise_vire_detail.clerib || ' ' || remise_vire_detail.intitule,
			                                     REMISE_VIRE_DETAIL.CLEF_IBAN || ' ' || REMISE_VIRE_DETAIL.BBAN || ' ' ||  remise_vire_detail.intitule) RIB,
            SUM (NVL (remise_vire_detail.montant, 0)) montant,
            remise_vire_detail.monnaie,
            SUM (NVL (remise_vire_detail.montant_d, 0)) montant_d,
            remise_vire_detail.monnaie_d, remise_vire.datdisk
       FROM remise_vire, remise_vire_detail, compte
      WHERE compte.numcpte = remise_vire.numcpte
        AND remise_vire_detail.numremise = remise_vire.numremise
   GROUP BY compte.numsoc,
            remise_vire.numremise,
            remise_vire.numcpte,
            remise_vire_detail.numvirement,
            compte.libcompte,
               remise_vire.numremise
            || ' du '
            || TO_CHAR (remise_vire.datrem, 'dd/mm/yyyy')
            || ' - '
            || remise_vire.nombre
            || ' virements',
            --remise_vire_detail.codbque|| ' ' || remise_vire_detail.guichet|| ' '|| remise_vire_detail.compte|| ' '|| remise_vire_detail.clerib || ' '|| remise_vire_detail.intitule,
            DECODE (REMISE_VIRE_DETAIL.BBAN, null, remise_vire_detail.codbque || ' ' || remise_vire_detail.guichet || ' ' || remise_vire_detail.compte || ' ' || remise_vire_detail.clerib || ' ' || remise_vire_detail.intitule,
			                                     REMISE_VIRE_DETAIL.CLEF_IBAN || ' ' || REMISE_VIRE_DETAIL.BBAN || ' ' ||  remise_vire_detail.intitule),
            remise_vire.datdisk,
            remise_vire_detail.monnaie,
            remise_vire_detail.monnaie_d
GO
CREATE OR REPLACE PUBLIC SYNONYM V_VIREMENT FOR ARTHUS.V_VIREMENT
