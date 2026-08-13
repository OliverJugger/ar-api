CREATE PROCEDURE ARTHUS."P_COMPUTE_EC" (a_montant IN NUMBER, a_numvirement IN NUMBER)
IS
   ratio_ec                NUMBER                          := NULL;
   local_mt                NUMBER                          := 0;
   delta_ec                NUMBER                          := 0;
   somme_ec                NUMBER                          := 0;
   last_numsin             NUMBER                          := 0;
   last_numaffec           NUMBER                          := 0;
   last_numdecaismt        NUMBER                          := 0;

--
   CURSOR c_verif_ec
   IS
      SELECT ALL SUM (remise_op_detail.montant_ct)
            FROM remise_op_detail
           WHERE remise_op_detail.numvirement = a_numvirement;

/*
      SELECT SUM ( REMISE_OP_DETAIL.MONTANT )
               FROM REMISE_OP_DETAIL, DECOMPTE, AFFECTATION, SINISTRE
               WHERE REMISE_OP_DETAIL.NUMVIREMENT = a_numvirement
                AND ((REMISE_OP_DETAIL.NUMDECAISMT = AFFECTATION.NUMDECAISMT)
                AND (AFFECTATION.NUMAFFEC = DECOMPTE.NUMDEC)
                AND (DECOMPTE.NUMDEC = SINISTRE.NUMDEC));
*/
--
-- Il afut commenter .MONTANT pour la remplacer utéruerement par MONTANT_CT
   CURSOR c_extract_numdecaismt
   IS
      SELECT ALL remise_op_detail.numdecaismt, affectation.numaffec,
                 decompte.monnaie, sinistre.numassu, sinistre.numsin,
                 sinistre.numfor, decaismt.montant, releve_compte.sens,
                 releve_compte.TYPE, releve_compte.devise,
                 releve_compte.idreleve_compte, sinistre_dev.mtreel_ct
            FROM remise_op_detail,
                 decompte,
                 affectation,
                 sinistre,
                 decaismt,
                 releve_compte,
                 sinistre_dev
           WHERE remise_op_detail.numvirement = a_numvirement
             AND (    (remise_op_detail.numdecaismt = affectation.numdecaismt
                      )
                  AND (affectation.numaffec = decompte.numdec)
                  AND (decompte.numdec = sinistre.numdec)
                  AND (decaismt.numdecaismt = remise_op_detail.numdecaismt)
                  AND (remise_op_detail.numvirement =
                                                    releve_compte.num_ecriture
                      )
                  AND (sinistre_dev.numsin = sinistre.numsin)
                 );

   r_extract_numdecaismt   c_extract_numdecaismt%ROWTYPE;
--
BEGIN
   BEGIN
      OPEN c_verif_ec;

      FETCH c_verif_ec
       INTO local_mt;

      IF local_mt <> a_montant
      THEN
         ratio_ec := (a_montant / local_mt);
         delta_ec := (a_montant - local_mt);
      ELSE
         ratio_ec := 1;
      END IF;

      CLOSE c_verif_ec;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END;

   --
   -- message ('ECART'||Ratio_EC); Pause;
   IF ratio_ec IS NOT NULL             /* Initialiser à Null par définition */
   THEN
      BEGIN
         OPEN c_extract_numdecaismt;

         LOOP
            FETCH c_extract_numdecaismt
             INTO r_extract_numdecaismt;

            EXIT WHEN c_extract_numdecaismt%NOTFOUND;
            last_numsin := r_extract_numdecaismt.numsin;
            last_numaffec := r_extract_numdecaismt.numaffec;
            last_numdecaismt := r_extract_numdecaismt.numdecaismt;

            /* MAJ Table des Affectations */
            -- message ('Montant de base -> '|| R_Extract_numdecaismt.MTREEL ); Pause;
            UPDATE affectation
               SET affectation.montant_ec =
                        (  affectation.montant_ct
                         - ROUND ((affectation.montant_ct * ratio_ec), 2)
                        )
                      * -1,
                   affectation.type_ec = r_extract_numdecaismt.TYPE,
                   affectation.sens_ec = r_extract_numdecaismt.sens,
                   affectation.devise_ec = r_extract_numdecaismt.devise
             WHERE affectation.numdecaismt = r_extract_numdecaismt.numdecaismt;

            /* MAJ Table des Décomptes */
            UPDATE decompte
               SET decompte.montant_ec =
                        (  decompte.montant_ct
                         - ROUND ((decompte.montant_ct * ratio_ec), 2)
                        )
                      * -1,
                   decompte.type_ec = r_extract_numdecaismt.TYPE,
                   decompte.sens_ec = r_extract_numdecaismt.sens,
                   decompte.devise_ec = r_extract_numdecaismt.devise
             WHERE decompte.numdec = r_extract_numdecaismt.numaffec;

            /* MAJ Table des Décaissements */
            UPDATE decaismt
               SET decaismt.montant_ec =
                        (  decaismt.montant_ct
                         - ROUND ((decaismt.montant_ct * ratio_ec), 2)
                        )
                      * -1,
                   decaismt.type_ec = r_extract_numdecaismt.TYPE,
                   decaismt.sens_ec = r_extract_numdecaismt.sens,
                   decaismt.devise_ec = r_extract_numdecaismt.devise,
                   decaismt.idreleve_compte =
                                         r_extract_numdecaismt.idreleve_compte
             WHERE decaismt.numdecaismt = r_extract_numdecaismt.numdecaismt;

            /* MAJ Table des Remise_OP_Detail */
            UPDATE remise_op_detail
               SET remise_op_detail.montant_ec =
                        (  remise_op_detail.montant_ct
                         - ROUND ((remise_op_detail.montant_ct * ratio_ec), 2)
                        )
                      * -1,
                   remise_op_detail.type_ec = r_extract_numdecaismt.TYPE,
                   remise_op_detail.sens_ec = r_extract_numdecaismt.sens,
                   remise_op_detail.devise_ec = r_extract_numdecaismt.devise,
                   remise_op_detail.idreleve_compte =
                                         r_extract_numdecaismt.idreleve_compte
             WHERE remise_op_detail.numdecaismt =
                                             r_extract_numdecaismt.numdecaismt;

            /* MAJ Table des ECARTS PIECES */
            BEGIN
               -- message('SQL%ROWCOUNT -> '||C_Extract_numdecaismt%ROWCOUNT); PAUSE;
               --
               local_mt :=
                    (  r_extract_numdecaismt.mtreel_ct
                     - ROUND ((r_extract_numdecaismt.mtreel_ct * ratio_ec), 2)
                    )
                  * -1;
               somme_ec := local_mt + somme_ec;

               --
               -- Message('Somme_EC -> '||Somme_EC||'Local_MT -> '||Local_MT); Pause;
               --
               INSERT INTO ecart_piece
                           (codope, numpiece, montant,
                            monnaie, type_ecart,
                            sens_ecart,
                            numassureur, numbdx,
                            date_ope
                           )
                    VALUES (1, r_extract_numdecaismt.numsin, local_mt,
                            r_extract_numdecaismt.devise, 1,
                            r_extract_numdecaismt.sens,
                            f_assureur_ct (r_extract_numdecaismt.numfor), 0,
                            SYSDATE
                           );
            EXCEPTION
               WHEN OTHERS
               THEN
                  UPDATE ecart_piece
                     SET montant = local_mt
                   WHERE ecart_piece.numpiece = r_extract_numdecaismt.numsin;
            END;
         END LOOP;

         CLOSE c_extract_numdecaismt;

         --
         -- Correction de l'écart sur le dernier enregistrement
         --
         BEGIN
            -- message('Delta_EC / Somme_EC -EP-> '||Delta_EC||' / '||Somme_EC);Pause;
            IF delta_ec = somme_ec
            THEN
               NULL;
            ELSE
               UPDATE ecart_piece
                  SET montant = montant + (delta_ec - somme_ec)
                WHERE ecart_piece.numpiece = last_numsin;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         --
         BEGIN
            SELECT SUM (affectation.montant_ec)
              INTO somme_ec
              FROM affectation
             WHERE affectation.numdecaismt = last_numdecaismt;

            -- message('Delta_EC / Somme_EC -AFFECTATION-> '||Delta_EC||' / '||Somme_EC);Pause;
            IF delta_ec = somme_ec
            THEN
               NULL;
            ELSE
               UPDATE affectation
                  SET affectation.montant_ec =
                                affectation.montant_ec
                                + (delta_ec - somme_ec)
                WHERE affectation.numdecaismt = last_numdecaismt;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         --
         BEGIN
            SELECT SUM (decompte.montant_ec)
              INTO somme_ec
              FROM decompte
             WHERE decompte.numdec = last_numaffec;

            -- message('Delta_EC / Somme_EC -DECOMPTE-> '||Delta_EC||' / '||Somme_EC);Pause;
            IF delta_ec = somme_ec
            THEN
               NULL;
            ELSE
               UPDATE decompte
                  SET decompte.montant_ec =
                                   decompte.montant_ec
                                   + (delta_ec - somme_ec)
                WHERE decompte.numdec = last_numaffec;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         --
         BEGIN
            SELECT SUM (decaismt.montant_ec)
              INTO somme_ec
              FROM decaismt
             WHERE decaismt.numdecaismt = last_numdecaismt;

            -- message('Delta_EC / Somme_EC -DECAISMT-> '||Delta_EC||' / '||Somme_EC);Pause;
            IF delta_ec = somme_ec
            THEN
               NULL;
            ELSE
               UPDATE decaismt
                  SET decaismt.montant_ec =
                                   decaismt.montant_ec
                                   + (delta_ec - somme_ec)
                WHERE decaismt.numdecaismt = last_numdecaismt;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         --
         BEGIN
            SELECT SUM (remise_op_detail.montant_ec)
              INTO somme_ec
              FROM remise_op_detail
             WHERE remise_op_detail.numdecaismt = last_numdecaismt;

            -- message('Delta_EC / Somme_EC -ROD-> '||Delta_EC||' / '||Somme_EC);Pause;
            IF delta_ec = somme_ec
            THEN
               NULL;
            ELSE
               UPDATE remise_op_detail
                  SET remise_op_detail.montant_ec =
                           remise_op_detail.montant_ec
                           + (delta_ec - somme_ec)
                WHERE remise_op_detail.numdecaismt = last_numdecaismt;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      --Commit;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
   END IF;
END;
/
