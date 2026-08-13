CREATE FORCE VIEW ARTHUS.V_REMISE_VIRE AS
SELECT vs_compte.numsoc, societe.refsoc, societe.nom nom_soc,
          remise_vire.numremise,
             remise_vire.numremise
          || ' du '
          || TO_CHAR (remise_vire.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_vire.nombre
          || ' virements' lib_remise,
          remise_vire.datrem datrem,
          TO_CHAR (remise_vire.datrem, 'dd/mm/yy') edatrem,
          remise_vire.numcpte numcpte,
          vs_compte.numcpte || ' - ' || vs_compte.libcompte lib_compte,
          remise_vire.nombre, remise_vire.valide,
          remise_vire.datvalide datvalide,
          TO_CHAR (remise_vire.datvalide, 'dd/mm/yy') edatvalide,
          remise_vire.datedit datedit,
          TO_CHAR (remise_vire.datedit, 'dd/mm/yy') edatedit,
          remise_vire.datdisk datdisk,
          TO_CHAR (remise_vire.datdisk, 'dd/mm/yy') edatdisk,
          remise_vire.numutil, util.nom, util.pseudo, remise_vire.montant,
          remise_vire.monnaie, remise_vire.montant_d, remise_vire.monnaie_d,
          remise_vire.numdest numdest,
          DECODE (remise_vire.numdest,
                  '', '',
                     remise_vire.numdest
                  || ' - '
                  || ARTHUS.pk_personne.f_nom (remise_vire.numdest, 32)
                 ) lib_dest,
          remise_vire.natrem natrem
          , date_valeur
     FROM remise_vire, vs_compte, util, societe
    WHERE vs_compte.numcpte = remise_vire.numcpte
      AND vs_compte.numsoc = societe.numsoc
      AND remise_vire.numutil = util.numutil(+)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_VIRE FOR ARTHUS.V_REMISE_VIRE
