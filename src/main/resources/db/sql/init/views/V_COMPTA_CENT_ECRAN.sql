CREATE FORCE VIEW ARTHUS.V_COMPTA_CENT_ECRAN AS
SELECT   idcompta, idcptacent, numsoc, codope, rolesoc, journal, compte,
            sens, monnaie_d, montant_d, DECODE (sens, 'D', montant_d) debit,
            DECODE (sens, 'C', montant_d) credit, montant, scdope, libelle,
            datope, refpiece, echeance, nature, axana1, axana2, axana3,
            axana4, axana5, zonex1, zonex2, zonex3, zonex4, zonex5, zonex6,
            zonex7, zonex8, zonex9, zonex10, zonex11, zonex12, zonex13,
            zserv1, zserv2, zserv3, zserv4, zserv5, monnaie
       FROM compta_central
   ORDER BY idcompta,
            codope,
            scdope,
            journal,
            refpiece,
            sens DESC,
            compte,
            libelle,
            montant
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_CENT_ECRAN FOR ARTHUS.V_COMPTA_CENT_ECRAN
