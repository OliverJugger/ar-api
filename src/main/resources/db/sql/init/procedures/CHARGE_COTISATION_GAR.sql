CREATE PROCEDURE ARTHUS."CHARGE_COTISATION_GAR" (
   i_cle        IN       pk_texte.clefs,
   i_contexte   IN       NUMBER,
   o_donnee     OUT      pk_texte.donnee
)
IS
   o_donnee_indvs    pk_texte.donnee;
   o_donnee_gar      pk_texte.donnee;
   l_fin             DATE;

   CURSOR c_coti_gar
   IS
      SELECT   qttc_gar.numquit, qttc_gar.debut, qttc_gar.fin,
               qttc_gar.mt_net_d, mone.libelle, qttc_gar.mt_ttc_d, i_cle (1),
               qttc_gar.mt_affec_d, 0, qttc_gar.numindiv
          FROM qttc_global, qttc_gar, mone
         WHERE qttc_gar.numquit = i_cle (0)
           AND qttc_gar.numindiv = i_cle (1)
           AND i_contexte = 33
           AND qttc_gar.numquit = qttc_global.numquit
           AND qttc_gar.monnaie_d = mone.codmon
           AND qttc_global.prelev = 1
      GROUP BY qttc_gar.numquit,
               qttc_gar.debut,
               qttc_gar.fin,
               qttc_gar.numindiv,
               mone.libelle
      UNION
      SELECT   qttc_gar.numquit, qttc_gar.debut, qttc_gar.fin,
               qttc_gar.mt_net_d, mone.libelle, qttc_gar.mt_ttc_d, i_cle (1),
               qttc_gar.mt_affec_d, 0, qttc_gar.numfor
          FROM qttc_global, qttc_gar, mone
         WHERE qttc_gar.numquit = i_cle (0)
           AND qttc_gar.numfor = i_cle (1)
           AND i_contexte = 34
           AND qttc_gar.numquit = qttc_global.numquit
           AND qttc_gar.monnaie_d = mone.codmon
           AND qttc_global.prelev = 1
      GROUP BY qttc_gar.numquit,
               qttc_gar.debut,
               qttc_gar.fin,
               qttc_gar.numfor,
               mone.libelle
      UNION
      SELECT   qttc_gar.numquit, qttc_gar.debut, qttc_gar.fin,
               qttc_gar.mt_net_d, mone.libelle, qttc_gar.mt_ttc_d,
--    I_cle(2),
                                                                  i_cle (1),
               qttc_gar.mt_affec_d, qttc_gar.numindiv, qttc_gar.numfor
          FROM qttc_global, qttc_gar, mone
         WHERE qttc_gar.numquit = i_cle (0)
           AND qttc_gar.numindiv = i_cle (1)
           AND qttc_gar.numfor = i_cle (2)
           AND i_contexte = 35
           AND qttc_gar.numquit = qttc_global.numquit
           AND qttc_gar.monnaie_d = mone.codmon
           AND qttc_global.prelev = 1
      GROUP BY qttc_gar.numquit,
               qttc_gar.debut,
               qttc_gar.fin,
               qttc_gar.numfor,
               mone.libelle,
               qttc_gar.numindiv;

   rec_c_coti_gar    c_coti_gar%ROWTYPE;

   CURSOR c_coti_gar1
   IS
      SELECT   0 nbre, a.debut, l_fin, qttc_gar.mt_net_d, mone.libelle,
               qttc_gar.mt_ttc_d, qttc_gar.numquit, i_cle (1),
               qttc_gar.mt_affec_d, 0, qttc_gar.numindiv
          FROM qttc_global, qttc_global a, qttc_gar, mone
         WHERE i_contexte = 33
           AND qttc_gar.numquit = qttc_global.numquit
           AND qttc_global.prelev = 2
           AND qttc_global.numgar = a.numgar
           AND qttc_global.numindiv = a.numindiv
           AND a.numquit = i_cle (0)
           AND qttc_gar.numindiv = i_cle (1)
           AND qttc_gar.monnaie_d = mone.codmon
           AND qttc_global.debut BETWEEN a.debut AND l_fin
      GROUP BY a.debut, l_fin, qttc_gar.numindiv, mone.libelle
      UNION
      SELECT   0, a.debut, l_fin, qttc_gar.mt_net_d, mone.libelle,
               qttc_gar.mt_ttc_d, qttc_gar.numquit, i_cle (1),
               qttc_gar.mt_affec_d, 0, qttc_gar.numfor
          FROM qttc_global, qttc_global a, qttc_gar, mone
         WHERE i_contexte = 34
           AND qttc_gar.numquit = qttc_global.numquit
           AND qttc_global.prelev = 2
           AND qttc_global.numgar = a.numgar
           AND qttc_global.numindiv = a.numindiv
           AND a.numquit = i_cle (0)
           AND qttc_gar.numfor = i_cle (1)
           AND qttc_gar.monnaie_d = mone.codmon
           AND qttc_global.debut BETWEEN a.debut AND l_fin
      GROUP BY a.debut, l_fin, qttc_gar.numfor, mone.libelle
      UNION
      SELECT   0, a.debut, l_fin, qttc_gar.mt_net_d, mone.libelle,
               qttc_gar.mt_ttc_d, qttc_gar.numquit, i_cle (2),

--    I_cle(1),
               qttc_gar.mt_affec_d, qttc_gar.numindiv, qttc_gar.numfor
          FROM qttc_global, qttc_global a, qttc_gar, mone
         WHERE i_contexte = 35
           AND qttc_gar.numquit = qttc_global.numquit
           AND qttc_global.prelev = 2
           AND qttc_global.numgar = a.numgar
           AND qttc_global.numindiv = a.numindiv
           AND a.numquit = i_cle (0)
           AND qttc_gar.numfor = i_cle (2)
           AND qttc_gar.numindiv = i_cle (1)
           AND qttc_gar.monnaie_d = mone.codmon
           AND qttc_global.debut BETWEEN a.debut AND l_fin
      GROUP BY a.debut,
               l_fin,
               qttc_gar.numfor,
               mone.libelle,
               qttc_gar.numindiv;

   rec_c_coti_gar1   c_coti_gar1%ROWTYPE;
BEGIN
   SELECT MAX (qttc_global.fin)
     INTO l_fin
     FROM qttc_global
    WHERE (qttc_global.numgar, qttc_global.numindiv) IN (
                                                   SELECT a.numgar,
                                                          a.numindiv
                                                     FROM qttc_global a
                                                    WHERE a.numquit =
                                                                     i_cle (0))
      AND qttc_global.prelev = 2;

   IF (i_contexte = 33)
   THEN
      charge_indvs (i_cle (1), 0, o_donnee_indvs);
      o_donnee (13) := o_donnee_indvs (2);
      o_donnee (14) := o_donnee_indvs (3);
      o_donnee (15) := o_donnee_indvs (4);
      o_donnee (16) := o_donnee_indvs (5);
      o_donnee (17) := o_donnee_indvs (6);
      o_donnee (18) := o_donnee_indvs (7);
      o_donnee (19) := o_donnee_indvs (8);
      o_donnee (20) := o_donnee_indvs (9);
      o_donnee (21) := o_donnee_indvs (10);
      o_donnee (22) := o_donnee_indvs (11);
      o_donnee (23) := o_donnee_indvs (12);
      o_donnee (24) := o_donnee_indvs (13);
      o_donnee (25) := o_donnee_indvs (14);
      o_donnee (26) := o_donnee_indvs (15);
      o_donnee (27) := o_donnee_indvs (16);
      o_donnee (28) := o_donnee_indvs (17);
      o_donnee (29) := o_donnee_indvs (18);
      o_donnee (30) := o_donnee_indvs (19);
      o_donnee (31) := o_donnee_indvs (20);
      o_donnee (32) := o_donnee_indvs (21);
      o_donnee (33) := o_donnee_indvs (22);
      o_donnee (34) := o_donnee_indvs (23);
      o_donnee (35) := o_donnee_indvs (24);
      o_donnee (36) := o_donnee_indvs (25);
      o_donnee (37) := o_donnee_indvs (26);
      o_donnee (38) := o_donnee_indvs (27);
      o_donnee (39) := o_donnee_indvs (28);
   ELSIF (i_contexte = 34)
   THEN
      charge_garantie (i_cle (1), o_donnee_gar);
      o_donnee (9) := o_donnee_gar (1);
      o_donnee (10) := o_donnee_gar (2);
      o_donnee (11) := o_donnee_gar (3);
      o_donnee (12) := o_donnee_gar (4);
   ELSIF (i_contexte = 35)
   THEN
      charge_garantie (i_cle (2), o_donnee_gar);
      o_donnee (9) := o_donnee_gar (1);
      o_donnee (10) := o_donnee_gar (2);
      o_donnee (11) := o_donnee_gar (3);
      o_donnee (12) := o_donnee_gar (4);
      charge_indvs (i_cle (1), 0, o_donnee_indvs);
      o_donnee (13) := o_donnee_indvs (2);
      o_donnee (14) := o_donnee_indvs (3);
      o_donnee (15) := o_donnee_indvs (4);
      o_donnee (16) := o_donnee_indvs (5);
      o_donnee (17) := o_donnee_indvs (6);
      o_donnee (18) := o_donnee_indvs (7);
      o_donnee (19) := o_donnee_indvs (8);
      o_donnee (20) := o_donnee_indvs (9);
      o_donnee (21) := o_donnee_indvs (10);
      o_donnee (22) := o_donnee_indvs (11);
      o_donnee (23) := o_donnee_indvs (12);
      o_donnee (24) := o_donnee_indvs (13);
      o_donnee (25) := o_donnee_indvs (14);
      o_donnee (26) := o_donnee_indvs (15);
      o_donnee (27) := o_donnee_indvs (16);
      o_donnee (28) := o_donnee_indvs (17);
      o_donnee (29) := o_donnee_indvs (18);
      o_donnee (30) := o_donnee_indvs (19);
      o_donnee (31) := o_donnee_indvs (20);
      o_donnee (32) := o_donnee_indvs (21);
      o_donnee (33) := o_donnee_indvs (22);
      o_donnee (34) := o_donnee_indvs (23);
      o_donnee (35) := o_donnee_indvs (24);
      o_donnee (36) := o_donnee_indvs (25);
      o_donnee (37) := o_donnee_indvs (26);
      o_donnee (38) := o_donnee_indvs (27);
      o_donnee (39) := o_donnee_indvs (28);
   END IF;

   IF (l_fin IS NULL)
   THEN
      OPEN c_coti_gar;

      FETCH c_coti_gar
       INTO rec_c_coti_gar;

      CLOSE c_coti_gar;

      o_donnee (1) := rec_c_coti_gar.numquit;
      o_donnee (2) := rec_c_coti_gar.debut;
      o_donnee (3) := rec_c_coti_gar.fin;
      o_donnee (4) :=
            TO_CHAR (rec_c_coti_gar.mt_net_d, '9G999G999D99')
         || ' '
         || rec_c_coti_gar.libelle;
      o_donnee (5) :=
            TO_CHAR (  rec_c_coti_gar.mt_ttc_d
                     + f_totfrais_gar_d (rec_c_coti_gar.numquit, '',
                                         i_cle (1)),
                     '9G999G999D99'
                    )
         || ' '
         || rec_c_coti_gar.libelle;
      o_donnee (6) :=
            TO_CHAR (rec_c_coti_gar.mt_affec_d, '9G999G999D99')
         || ' '
         || rec_c_coti_gar.libelle;
      o_donnee (7) := 0;
      o_donnee (8) := rec_c_coti_gar.numindiv;
   ELSE
      OPEN c_coti_gar1;

      FETCH c_coti_gar1
       INTO rec_c_coti_gar1;

      CLOSE c_coti_gar1;

      o_donnee (1) := 0;
      o_donnee (2) := rec_c_coti_gar1.debut;
      o_donnee (3) := rec_c_coti_gar1.l_fin;
      o_donnee (4) :=
            TO_CHAR (rec_c_coti_gar1.mt_net_d, '9G999G999D99')
         || ' '
         || rec_c_coti_gar1.libelle;
      o_donnee (5) :=
            TO_CHAR (  (rec_c_coti_gar1.mt_ttc_d)
                     + f_totfrais_gar_d (rec_c_coti_gar1.numquit,
                                         '',
                                         i_cle (1)
                                        ),
                     '9G999G999D99'
                    )
         || ' '
         || rec_c_coti_gar1.libelle;
      o_donnee (6) :=
            TO_CHAR (rec_c_coti_gar1.mt_affec_d, '9G999G999D99')
         || ' '
         || rec_c_coti_gar1.libelle;
      o_donnee (7) := 0;
      o_donnee (8) := rec_c_coti_gar1.numindiv;
   END IF;
END charge_cotisation_gar;
/
