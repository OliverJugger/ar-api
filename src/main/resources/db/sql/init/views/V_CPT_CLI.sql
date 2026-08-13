CREATE FORCE VIEW ARTHUS.V_CPT_CLI AS
SELECT ALL
              encaismt.codope, codope.libelle libope, encaismt.numcpte,
              compte.numsoc, compte.libcompte, encaismt.modpmt,
              modpmt.libelle libmodpmt, encaismt.numencaismt, encaismt.numcli,
              encaismt.numcli || ' - ' || indvs.nom || ' '
              || indvs.prenom nomcli,
              encaismt.refpmt, encaismt.montant mnt_enc,
              encaismt.montant_d mnt_enc_d, encaismt.datpay,
              TO_CHAR (encaismt.datpay, 'dd/mm/yy') edatpay,
              TO_CHAR (compte_client.datope, 'dd/mm/yy') edatope,
              compte_client.idaffec, compte_client.numfact,
              compte_client.montant mnt_aff,
              compte_client.montant_d mnt_aff_d,
              compte_client.codope cptcli_ope,
              DECODE (compte_client.codope,
                      8, 'Au compte client N° ' || compte_client.numcli,
                      f_lib_piece (compte_client.numfact,
                                   compte_client.codope)
                     ) lib_aff,
              encaismt.monnaie, encaismt.monnaie_d,
              --SDA Mantis 3458
              indvs.type typeind,indvs.nom || ' ' || indvs.prenom nomclitri
         FROM libelle modpmt,
              libelle codope,
              compte,
              indvs,
              compte_client,
              encaismt
        WHERE (    modpmt.mnemo = 'MREGL'
               AND codope.mnemo = 'OPE'
               AND NOT EXISTS (
                      SELECT 1
                        FROM idaffec_regul
                       WHERE idaffec_regul.idaffec_regul =
                                                         compte_client.idaffec)
              )
          AND (    (modpmt.code = encaismt.modpmt)
               AND (codope.code = encaismt.codope)
               AND (compte.numcpte = encaismt.numcpte)
               AND (indvs.numindiv = encaismt.numcli)
               AND (compte_client.numencaismt = encaismt.numencaismt)
              )
--
   UNION ALL
--
   SELECT ALL
              encaismt.codope, codope.libelle libope, encaismt.numcpte,
              compte.numsoc, compte.libcompte, encaismt.modpmt,
              modpmt.libelle libmodpmt, encaismt.numencaismt, encaismt.numcli,
              encaismt.numcli || ' - ' || indvs.nom || ' '
              || indvs.prenom nomcli,
              encaismt.refpmt, encaismt.montant mnt_enc,
              encaismt.montant_d mnt_enc_d, encaismt.datpay,
              TO_CHAR (encaismt.datpay, 'dd/mm/yy') edatpay,
              TO_CHAR (compte_client.datope, 'dd/mm/yy') edatope,
              compte_client.idaffec, compte_client.numfact,
              compte_client.montant mnt_aff,
              compte_client.montant_d mnt_aff_d,
              compte_client.codope cptcli_ope,
              'Report sur pièce N° ' || cptcli_regul.numfact,
              encaismt.monnaie, encaismt.monnaie_d,
              --SDA Mantis 3458
              indvs.type typeind,indvs.nom || ' ' || indvs.prenom nomclitri
         FROM libelle modpmt,
              libelle codope,
              compte,
              indvs,
              idaffec_regul,
              compte_client,
              compte_client cptcli_regul,
              encaismt
        WHERE (modpmt.mnemo = 'MREGL' AND codope.mnemo = 'OPE')
          AND (    (modpmt.code = encaismt.modpmt)
               AND (codope.code = encaismt.codope)
               AND (compte.numcpte = encaismt.numcpte)
               AND (indvs.numindiv = encaismt.numcli)
               AND (idaffec_regul.idaffec_regul = compte_client.idaffec)
               AND (cptcli_regul.idaffec = idaffec_regul.idaffec)
               AND (cptcli_regul.codope = encaismt.codope)
               AND (compte_client.numencaismt = encaismt.numencaismt)
              )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CPT_CLI FOR ARTHUS.V_CPT_CLI
