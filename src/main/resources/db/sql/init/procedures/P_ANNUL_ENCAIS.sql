CREATE PROCEDURE ARTHUS."P_ANNUL_ENCAIS" (i_numencaismt IN encaismt.numencaismt%TYPE)
IS
-- Variable de reconnaissance SCCS
-- %W%    %E%
   c_cptcli         compte_client%ROWTYPE;
   c_affec          qttc_affec%ROWTYPE;
   c_compte_tiers   compte_tiers%ROWTYPE;
   c_compensation   compensation%ROWTYPE;
BEGIN
-- Désaffectation de qttc_global et suppression des qttc_affec
   FOR c_cptcli IN (SELECT idaffec, codope
                      FROM compte_client
                     WHERE compte_client.numencaismt = i_numencaismt)
   LOOP
      FOR c_affec IN (SELECT numquit, montant, montant_d
                        FROM qttc_affec
                       WHERE idaffec = c_cptcli.idaffec AND idgar = 0)
      LOOP
         UPDATE qttc_global
            SET mt_affec = mt_affec - c_affec.montant,
                mt_affec_d = mt_affec_d - c_affec.montant_d
          WHERE numquit = c_affec.numquit;
      END LOOP;

      DELETE      qttc_affec
            WHERE idaffec = c_cptcli.idaffec;

      DELETE      qttc_affec_tfc
            WHERE idaffec = c_cptcli.idaffec;
   END LOOP;

--  Mise a jour du montant total affecte par garantie
   UPDATE qttc_gar
      SET qttc_gar.mt_affec =
             (SELECT SUM (NVL (qttc_affec.montant, 0))
                FROM qttc_affec
               WHERE qttc_affec.numquit = c_affec.numquit
                 AND qttc_affec.idgar = qttc_gar.idgar),
          qttc_gar.mt_affec_d =
             (SELECT SUM (NVL (qttc_affec.montant_d, 0))
                FROM qttc_affec
               WHERE qttc_affec.numquit = c_affec.numquit
                 AND qttc_affec.idgar = qttc_gar.idgar)
    WHERE qttc_gar.numquit = c_affec.numquit;

-- Suppression compte_tiers, compte_client
   FOR c_compte_tiers IN (SELECT idmvt
                            FROM compte_tiers
                           WHERE codope = 10
                             AND cle = i_numencaismt
                             AND sens = 1)
   LOOP
      FOR c_compensation IN (SELECT idcomp
                               FROM compensation
                              WHERE idmvt = c_compte_tiers.idmvt)
      LOOP
         DELETE      compensation
               WHERE idmvt = c_compte_tiers.idmvt;

         DELETE      compte_tiers
               WHERE idmvt = c_compensation.idcomp;
      END LOOP;
   END LOOP;

   DELETE      compte_client
         WHERE numencaismt = i_numencaismt;
END;
/
