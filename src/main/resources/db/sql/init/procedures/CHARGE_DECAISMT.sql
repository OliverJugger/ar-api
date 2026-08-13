CREATE PROCEDURE ARTHUS."CHARGE_DECAISMT" (
   a_numdecaismt   IN       NUMBER,
   t_donnee        OUT      pk_texte.donnee
)
IS
-- Variable de reconnaissance SCCS
-- @(#)charge_decaismt.sql 1.5    01/09/25
--
   l_codope     NUMBER;
   l_numaffec   NUMBER;

   CURSOR c_sntr
   IS
      SELECT   username
          FROM sinistre
         WHERE numdec = l_numaffec
      ORDER BY datsai;

   CURSOR c_decaismt
   IS
      SELECT decaismt.numdecaismt,
             SUBSTR (pk_libelle.f_lib ('MOPM', decaismt.modpmt), 1, 15),
             LTRIM (TO_CHAR (decaismt.montant_d, '999999990.90')),
             mone.libelle,
             TO_CHAR (pk_devise.f_convert_euro (decaismt.montant),
                      '999999990.90'
                     ),
             mone_euro.libelle, d2e (remise_vire.datdisk),
                remise_vire_detail.codbque
             || ' '
             || remise_vire_detail.guichet
             || ' '
             || remise_vire_detail.compte,
             pk_libelle.f_lib ('USER', decaismt.numutil),
             affectation.numaffec,
                pk_libelle.f_lib ('MOPM', decaismt.modpmt)
             || ' le  '
             || d2e (remise_vire.datdisk)
             || ' sur le compte '
             || remise_vire_detail.codbque
             || ' '
             || remise_vire_detail.guichet
             || ' '
             || remise_vire_detail.compte,
             decaismt.codope, affectation.numaffec
        FROM remise_vire,
             remise_vire_detail,
             affectation,
             decaismt,
             mone,
             mone mone_euro,
             prmt
       WHERE remise_vire.numremise = remise_vire_detail.numremise
         AND remise_vire_detail.numdecaismt = decaismt.numdecaismt
         AND decaismt.numdecaismt = a_numdecaismt
         AND decaismt.monnaie_d = mone.codmon
         AND prmt.dfsoc = mone_euro.codmon
         AND decaismt.modpmt = 2
         AND decaismt.numdecaismt = affectation.numdecaismt
      UNION
      SELECT decaismt.numdecaismt,
             SUBSTR (pk_libelle.f_lib ('MOPM', decaismt.modpmt), 1, 15),
             LTRIM (TO_CHAR (decaismt.montant_d, '999999990.90')),
             mone.libelle,
             TO_CHAR (pk_devise.f_convert_euro (decaismt.montant),
                      '999999990.90'
                     ),
             mone_euro.libelle, d2e (remise_op.datdisk),
                remise_op_detail.codbque
             || ' '
             || remise_op_detail.guichet
             || ' '
             || remise_op_detail.compte,
             pk_libelle.f_lib ('USER', decaismt.numutil),
             affectation.numaffec,
                pk_libelle.f_lib ('MOPM', decaismt.modpmt)
             || ' le  '
             || d2e (remise_op.datdisk)
             || ' sur le compte '
             || remise_op_detail.codbque
             || ' '
             || remise_op_detail.guichet
             || ' '
             || remise_op_detail.compte,
             decaismt.codope, affectation.numaffec
        FROM remise_op,
             remise_op_detail,
             affectation,
             decaismt,
             mone,
             mone mone_euro,
             prmt
       WHERE remise_op.numremise = remise_op_detail.numremise
         AND remise_op_detail.numdecaismt = decaismt.numdecaismt
         AND decaismt.numdecaismt = a_numdecaismt
         AND decaismt.monnaie_d = mone.codmon
         AND prmt.dfsoc = mone_euro.codmon
         AND decaismt.modpmt = 2
         AND decaismt.numdecaismt = affectation.numdecaismt
      UNION
      SELECT decaismt.numdecaismt,
             SUBSTR (pk_libelle.f_lib ('MOPM', decaismt.modpmt), 1, 15),
             LTRIM (TO_CHAR (decaismt.montant_d, '999999990.90')),
             mone.libelle,
             TO_CHAR (pk_devise.f_convert_euro (decaismt.montant),
                      '999999990.90'
                     ),
             mone_euro.libelle, d2e (decaismt.datpay), d2e (decaismt.datedit),
             pk_libelle.f_lib ('USER', decaismt.numutil),
             affectation.numaffec,
                pk_libelle.f_lib ('MOPM', decaismt.modpmt)
             || ' N° '
             || decaismt.refpmt
             || ' du  '
             || d2e (decaismt.datedit),
             decaismt.codope, affectation.numaffec
        FROM affectation, decaismt, mone mone, mone mone_euro, prmt
       WHERE decaismt.numdecaismt = a_numdecaismt
         AND decaismt.monnaie_d = mone.codmon
         AND prmt.dfsoc = mone_euro.codmon
         AND decaismt.modpmt = 1
         AND decaismt.numdecaismt = affectation.numdecaismt
      UNION
      SELECT decaismt.numdecaismt,
             SUBSTR (pk_libelle.f_lib ('MOPM', decaismt.modpmt), 1, 15),
             LTRIM (TO_CHAR (decaismt.montant_d, '999999990.90')),
             mone.libelle,
             TO_CHAR (pk_devise.f_convert_euro (decaismt.montant),
                      '999999990.90'
                     ),
             mone_euro.libelle, d2e (decaismt.datpay), d2e (decaismt.datedit),
             pk_libelle.f_lib ('USER', decaismt.numutil),
             affectation.numaffec,
                pk_libelle.f_lib ('MOPM', decaismt.modpmt)
             || ' N° '
             || decaismt.refpmt
             || ' du  '
             || d2e (decaismt.datedit),
             decaismt.codope, affectation.numaffec
        FROM affectation, decaismt, mone mone, mone mone_euro, prmt
       WHERE decaismt.numdecaismt = a_numdecaismt
         AND decaismt.monnaie_d = mone.codmon
         AND prmt.dfsoc = mone_euro.codmon
         AND decaismt.modpmt = 3
         AND decaismt.numdecaismt = affectation.numdecaismt;

   rec_c_sntr   c_sntr%ROWTYPE;
BEGIN
   OPEN c_decaismt;

   FETCH c_decaismt
    INTO t_donnee (1), t_donnee (2), t_donnee (3), t_donnee (4),
         t_donnee (5), t_donnee (6), t_donnee (7), t_donnee (8),
         t_donnee (9), t_donnee (10), t_donnee (11), l_codope, l_numaffec;

   CLOSE c_decaismt;

   IF (l_codope = 1)
   THEN
      OPEN c_sntr;

      LOOP
         FETCH c_sntr
          INTO rec_c_sntr;

         EXIT WHEN c_sntr%NOTFOUND;
      END LOOP;

      CLOSE c_sntr;

      t_donnee (9) := pk_libelle.f_lib ('USER', rec_c_sntr.username);
   END IF;
END;
/
