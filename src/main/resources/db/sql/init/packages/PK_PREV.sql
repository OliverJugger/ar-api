CREATE OR REPLACE PACKAGE ARTHUS."PK_PREV"
AS

   FUNCTION f_sel_flag_remb (i_numdec IN NUMBER)
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (f_sel_flag_remb, WNDS, WNPS);

   PROCEDURE p_annul_histo_calcul (
      i_idcalcul   IN       histo_calcul.idcalcul%TYPE,
      o_idannul    OUT      histo_annul.idannul%TYPE
   );

   PROCEDURE ins_histo_calcul (
      a_idcalcul        IN   NUMBER,
      a_idrepartition   IN   NUMBER,
      a_numbene         IN   NUMBER,
      a_debut           IN   DATE,
      a_fin             IN   DATE,
      a_numbene_dest    IN   NUMBER
   );

   PROCEDURE ins_histo_jours (
      a_idhisto          IN   NUMBER,
      a_idcalcul         IN   NUMBER,
      a_debut            IN   DATE,
      a_fin              IN   DATE,
      a_valeur           IN   NUMBER,
      a_valeur_d         IN   NUMBER,
      a_valeur_reval     IN   NUMBER,
      a_valeur_reval_d   IN   NUMBER,
      a_monnaie          IN   NUMBER,
      a_monnaie_d        IN   NUMBER
   );

   PROCEDURE ins_histo_dedu (
      a_idhisto     IN   NUMBER,
      a_typdedu     IN   NUMBER,
      a_valeur      IN   NUMBER,
      a_valeur_d    IN   NUMBER,
      a_monnaie     IN   NUMBER,
      a_monnaie_d   IN   NUMBER
   );

   PROCEDURE ins_histo_regul (
      a_idcalcul       IN   NUMBER,
      a_new_idcalcul   IN   NUMBER,
      a_debut          IN   DATE DEFAULT NULL,
      a_fin            IN   DATE DEFAULT NULL
   );

   PROCEDURE ins_arret_regul (
      a_new_idcalcul    IN   NUMBER,
      a_idrepartition   IN   NUMBER,
      a_numbene         IN   NUMBER,
      a_debut           IN   DATE,
      a_fin             IN   DATE
   );

   PROCEDURE P_transfert_dossier (
	a_traitement	IN	JOURNAL_ADM.NOM_TRAITEMENT%TYPE,
    a_gest_source   IN  NUMBER,
	a_from_dir		IN 	DOSSIER_SINISTRE.IDDOSSIER%TYPE,
	a_to_dir		IN 	DOSSIER_SINISTRE.IDDOSSIER%TYPE,
    a_gest_dest		IN  NUMBER,
	a_session		IN	file_edition.numedit%Type,
	a_niv_msg		IN	NUMBER
   );

   FUNCTION SEL_CORRES_BY_TYPE_DEST(
      a_entite_numsin IN CORRESPONDANT.ENTITE%TYPE,
      a_contexte_corres IN CORRESPONDANT.CONTEXTE%TYPE,
      a_type_dest IN HISTO_DEST.TYPE_DEST%TYPE,
	  numbene_dest IN HISTO_DEST.NUMBENE_DEST%TYPE
   ) RETURN NUMBER;

   FUNCTION CLOTURE_SINISTRE(
   	a_risq_deb    IN NUMBER,
   	a_risq_fin    IN NUMBER,
    a_cause_deb	  IN NUMBER,
    a_cause_fin   IN NUMBER,
    a_delais_mois_deb  IN NUMBER,
    a_typ_motif   IN NUMBER,
    a_session     IN file_edition.numedit%Type,
    a_niv_msg		 IN	NUMBER		Default 1,
    a_nom_traitement IN PARAM_BATCH.NUMBATCH%TYPE
   )RETURN BOOLEAN;


END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_PREV"
AS

  --g_devise_ref   parametres.dfdev%TYPE;

   FUNCTION f_sel_flag_remb (i_numdec IN NUMBER)
      RETURN VARCHAR2
   IS
      rec_c_calcul   histo_calcul%ROWTYPE;
      rec_c_annul    histo_annul%ROWTYPE;
      l_flag_remb    histo_annul.flag_remb%TYPE   := 'N';
   BEGIN
      FOR rec_c_calcul IN (SELECT idcalcul
                             FROM histo_calcul
                            WHERE numdec = i_numdec)
      LOOP
         FOR rec_c_annul IN (SELECT flag_remb
                               FROM histo_annul
                              WHERE idcalcul = rec_c_calcul.idcalcul)
         LOOP
            IF (rec_c_annul.flag_remb = 'O')
            THEN
               l_flag_remb := rec_c_annul.flag_remb;
            END IF;
         END LOOP;
      END LOOP;

      RETURN (l_flag_remb);
   END f_sel_flag_remb;

   PROCEDURE p_annul_histo_calcul (
      i_idcalcul   IN       histo_calcul.idcalcul%TYPE,
      o_idannul    OUT      histo_annul.idannul%TYPE
   )
   IS
      CURSOR c_calcul
      IS
         SELECT idarret.NEXTVAL idannul, idrepartition, numbene, 0 numdec,
                debut, fin, SYSDATE creation,numbene_dest
           FROM histo_calcul
          WHERE idcalcul = i_idcalcul;

      CURSOR c_prest
      IS
         SELECT idhisto.NEXTVAL idannul, idhisto, idcalcul, debut, fin,
                -montant montant, -montant_d montant_d, monnaie, monnaie_d
           FROM histo_jours
          WHERE idcalcul = i_idcalcul;

      CURSOR c_reval (p_idhisto histo_jours.idhisto%TYPE)
      IS
         SELECT idhisto, -montant montant, -montant_d montant_d, monnaie,
                monnaie_d
           FROM histo_reval
          WHERE idhisto = p_idhisto;

      CURSOR c_dedu (p_idhisto histo_jours.idhisto%TYPE)
      IS
         SELECT idhisto, typdedu, 0 numdec, -montant montant,
                -montant_d montant_d, monnaie, monnaie_d
           FROM histo_dedu
          WHERE idhisto = p_idhisto;

      rec_c_calcul   c_calcul%ROWTYPE;
      rec_c_prest    c_prest%ROWTYPE;
      rec_c_reval    c_reval%ROWTYPE;
      rec_c_dedu     c_dedu%ROWTYPE;
   BEGIN

      /*SELECT pk_devise.devise_ref
        INTO g_devise_ref
        FROM DUAL;*/


      OPEN c_calcul;

      LOOP
         FETCH c_calcul
          INTO rec_c_calcul;

         EXIT WHEN c_calcul%NOTFOUND;
         ins_histo_calcul (a_idcalcul           => rec_c_calcul.idannul,
                           a_idrepartition      => rec_c_calcul.idrepartition,
                           a_numbene            => rec_c_calcul.numbene,
                           a_debut              => rec_c_calcul.debut,
                           a_fin                => rec_c_calcul.fin,
                           a_numbene_dest       => rec_c_calcul.numbene_dest
                          );
         o_idannul := rec_c_calcul.idannul;

         OPEN c_prest;

         LOOP
            FETCH c_prest
             INTO rec_c_prest;

            EXIT WHEN c_prest%NOTFOUND;

            BEGIN
               INSERT INTO histo_jours
                           (idhisto, idcalcul,
                            debut, fin,
                            montant, monnaie,
                            monnaie_d, montant_d
                           )
                    VALUES (rec_c_prest.idannul, rec_c_calcul.idannul,
                            rec_c_prest.debut, rec_c_prest.fin,
                            rec_c_prest.montant, rec_c_prest.monnaie,
                            rec_c_prest.monnaie_d, rec_c_prest.montant_d
                           );
            END;

            OPEN c_reval (rec_c_prest.idhisto);

            LOOP
               FETCH c_reval
                INTO rec_c_reval;

               EXIT WHEN c_reval%NOTFOUND;

               BEGIN
                  INSERT INTO histo_reval
                              (idhisto, montant,
                               montant_d, monnaie,
                               monnaie_d
                              )
                       VALUES (rec_c_prest.idannul, rec_c_reval.montant,
                               rec_c_reval.montant_d, rec_c_reval.monnaie,
                               rec_c_reval.monnaie_d
                              );
               END;
            END LOOP;

            CLOSE c_reval;

            OPEN c_dedu (rec_c_prest.idhisto);

            LOOP
               FETCH c_dedu
                INTO rec_c_dedu;

               EXIT WHEN c_dedu%NOTFOUND;

               BEGIN
                  INSERT INTO histo_dedu
                              (idhisto, typdedu,
                               numdec, montant,
                               monnaie, monnaie_d,
                               montant_d
                              )
                       VALUES (rec_c_prest.idannul, rec_c_dedu.typdedu,
                               rec_c_dedu.numdec, rec_c_dedu.montant,
                               rec_c_dedu.monnaie, rec_c_dedu.monnaie_d,
                               rec_c_dedu.montant_d
                              );
               END;
            END LOOP;

            CLOSE c_dedu;
         END LOOP;

         CLOSE c_prest;
      END LOOP;

      CLOSE c_calcul;


      BEGIN
         UPDATE arret
            SET traite = 'A',
                maj = SYSDATE
          WHERE idarret = i_idcalcul;
      END;
   END p_annul_histo_calcul;

   PROCEDURE ins_histo_calcul (
      a_idcalcul        IN   NUMBER,
      a_idrepartition   IN   NUMBER,
      a_numbene         IN   NUMBER,
      a_debut           IN   DATE,
      a_fin             IN   DATE,
      a_numbene_dest    IN   NUMBER
   )
   IS
   BEGIN
      BEGIN
         INSERT INTO histo_calcul
                     (idcalcul, idrepartition, numbene, numdec, debut,
                      fin, creation, numbene_dest
                     )
              VALUES (a_idcalcul, a_idrepartition, a_numbene, 0, a_debut,
                      a_fin, SYSDATE,a_numbene_dest
                     );
      END;
   END ins_histo_calcul;

   PROCEDURE ins_histo_jours (
      a_idhisto          IN   NUMBER,
      a_idcalcul         IN   NUMBER,
      a_debut            IN   DATE,
      a_fin              IN   DATE,
      a_valeur           IN   NUMBER,
      a_valeur_d         IN   NUMBER,
      a_valeur_reval     IN   NUMBER,
      a_valeur_reval_d   IN   NUMBER,
      a_monnaie          IN   NUMBER,
      a_monnaie_d        IN   NUMBER
   )
   IS
   BEGIN

      /*SELECT pk_devise.devise_ref
        INTO g_devise_ref
        FROM DUAL;*/


      BEGIN
         INSERT INTO histo_jours
                     (idhisto, idcalcul, debut, fin, montant,
                      monnaie, monnaie_d, montant_d
                     )
              VALUES (a_idhisto, a_idcalcul, a_debut, a_fin, a_valeur,
                      a_monnaie, a_monnaie_d, a_valeur_d
                     );
      END;

      BEGIN
         INSERT INTO histo_reval
                     (idhisto, montant, montant_d,
                      monnaie, monnaie_d
                     )
              VALUES (a_idhisto, a_valeur_reval, a_valeur_reval_d,
                      a_monnaie, a_monnaie_d
                     );
      END;
   END;

   PROCEDURE ins_histo_dedu (
      a_idhisto     IN   NUMBER,
      a_typdedu     IN   NUMBER,
      a_valeur      IN   NUMBER,
      a_valeur_d    IN   NUMBER,
      a_monnaie     IN   NUMBER,
      a_monnaie_d   IN   NUMBER
   )
   IS
   BEGIN

      BEGIN
         INSERT INTO histo_dedu
                     (idhisto, typdedu, numdec, montant, monnaie,
                      monnaie_d, montant_d
                     )
              VALUES (a_idhisto, a_typdedu, 0, a_valeur, a_monnaie,
                      a_monnaie_d, a_valeur_d
                     );
      END;
   END;

   PROCEDURE ins_histo_regul (
      a_idcalcul       IN   NUMBER,
      a_new_idcalcul   IN   NUMBER,
      a_debut          IN   DATE DEFAULT NULL,
      a_fin            IN   DATE DEFAULT NULL
   )
   IS
      loc_idhisto   NUMBER;

      CURSOR fetch_histo
      IS
         SELECT histo_jours.idhisto, histo_jours.debut, histo_jours.fin,
                -1 * histo_jours.montant montant,
                -1 * histo_jours.montant_d montant_d, histo_jours.monnaie,
                histo_jours.monnaie_d
           FROM histo_jours
          WHERE histo_jours.idcalcul = a_idcalcul
            AND   LEAST (a_fin, histo_jours.fin)
                - GREATEST (a_debut, histo_jours.debut) >= 0
            AND NOT EXISTS (SELECT 1
                              FROM histo_regul
                             WHERE histo_regul.idhisto = histo_jours.idhisto)
            AND NOT EXISTS (SELECT 1
                              FROM histo_annul
                             WHERE histo_annul.idcalcul = a_idcalcul)
            AND NOT EXISTS (SELECT 1
                              FROM histo_annul
                             WHERE histo_annul.idannul = a_idcalcul);

      rec_histo     fetch_histo%ROWTYPE;
   BEGIN

      FOR rec_histo IN fetch_histo
      LOOP
         BEGIN
            SELECT idhisto.NEXTVAL
              INTO loc_idhisto
              FROM DUAL;
         END;

         BEGIN
            INSERT INTO histo_jours
                        (idhisto, idcalcul,
                         debut,
                         fin,
                         montant, monnaie,
                         monnaie_d, montant_d
                        )
                 VALUES (loc_idhisto, a_new_idcalcul,
                         GREATEST (NVL (a_debut, rec_histo.debut),
                                   rec_histo.debut
                                  ),
                         LEAST (NVL (a_fin, rec_histo.fin), rec_histo.fin),
                         rec_histo.montant, rec_histo.monnaie,
                         rec_histo.monnaie_d, rec_histo.montant_d
                        );
         END;

         BEGIN
            INSERT INTO histo_reval
                        (idhisto, montant, montant_d, monnaie, monnaie_d)
               SELECT loc_idhisto, -1 * histo_reval.montant,
                      -1 * histo_reval.montant_d, histo_reval.monnaie,
                      histo_reval.monnaie_d
                 FROM histo_reval
                WHERE histo_reval.idhisto = rec_histo.idhisto;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         BEGIN
            INSERT INTO histo_dedu
                        (idhisto, typdedu, numdec, montant, monnaie,
                         monnaie_d, montant_d)
               SELECT loc_idhisto, histo_dedu.typdedu, 0,
                      -1 * histo_dedu.montant, histo_dedu.monnaie,
                      histo_dedu.monnaie_d, -1 * histo_dedu.montant_d
                 FROM histo_dedu
                WHERE histo_dedu.idhisto = rec_histo.idhisto;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         INSERT INTO histo_regul
                     (idhisto, idhisto_regul
                     )
              VALUES (loc_idhisto, rec_histo.idhisto
                     );
      END LOOP;
   END;

   PROCEDURE ins_arret_regul (
      a_new_idcalcul    IN   NUMBER,
      a_idrepartition   IN   NUMBER,
      a_numbene         IN   NUMBER,
      a_debut           IN   DATE,
      a_fin             IN   DATE
   )
   IS
      loc_idcalcul   NUMBER;

      CURSOR fetch_histo
      IS
         SELECT histo_calcul.idcalcul
           FROM histo_calcul
          WHERE
             histo_calcul.idcalcul = a_new_idcalcul AND
             histo_calcul.idrepartition = a_idrepartition AND
             histo_calcul.numbene = a_numbene AND
             LEAST (a_fin, histo_calcul.fin)
                - GREATEST (a_debut, histo_calcul.debut) >= 0
            AND NOT EXISTS (
                            SELECT 1
                              FROM histo_annul
                             WHERE histo_annul.idcalcul =
                                                         histo_calcul.idcalcul)
            AND NOT EXISTS (SELECT 1
                              FROM histo_annul
                             WHERE histo_annul.idannul = histo_calcul.idcalcul);

      rec_histo             fetch_histo%ROWTYPE;
      rec_arret             arret%ROWTYPE;
      rec_histo_calcul      histo_calcul%ROWTYPE;
      rec_new_idarret       arret.idarret%TYPE;

   BEGIN
      FOR rec_histo IN fetch_histo
      LOOP
         BEGIN
            select idarret.NEXTVAL into rec_new_idarret from DUAL;


            SELECT * INTO rec_arret from ARRET where idarret = rec_histo.idcalcul;
            SELECT * INTO rec_histo_calcul from histo_calcul where idcalcul = rec_histo.idcalcul;
            rec_arret.idarret := rec_new_idarret;
            rec_arret.traite := 'N';

            Insert into ARRET VALUES rec_arret;
            ins_histo_calcul(rec_new_idarret,rec_histo_calcul.idrepartition,rec_histo_calcul.numbene,rec_histo_calcul.debut,rec_histo_calcul.fin,rec_histo_calcul.numbene_dest);
            ins_histo_regul (rec_histo.idcalcul, rec_new_idarret, a_debut, a_fin );
         END;


         BEGIN
            UPDATE arret
            SET traite = 'R'
            WHERE idarret = rec_histo.idcalcul;
         END;

      END LOOP;
   END;


   FUNCTION SEL_CORRES_BY_TYPE_DEST(
      a_entite_numsin IN CORRESPONDANT.ENTITE%TYPE,
      a_contexte_corres IN CORRESPONDANT.CONTEXTE%TYPE,
      a_type_dest IN HISTO_DEST.TYPE_DEST%TYPE,
	  numbene_dest IN HISTO_DEST.NUMBENE_DEST%TYPE
   ) RETURN NUMBER
      IS
     REP_NUMCORRES NUMBER := null;


	 CURSOR LAST_CORRESP IS
	 		SELECT NUMCORRES
			  FROM CORRESPONDANT
			WHERE CONTEXTE = a_contexte_corres
			  AND ENTITE = a_entite_numsin
			  AND NAT_CORRES = pk_libelle.F_LIB_SENS_BY_MNEMO('RGLTDEST',a_type_dest)
			  AND NUMCORRES = NVL(numbene_dest,NUMCORRES)
			ORDER BY ID_CORRES DESC;
	  R_LAST_CORRESP LAST_CORRESP%ROWTYPE;


   BEGIN

      IF pk_libelle.F_LIB_SENS_BY_MNEMO('RGLTDEST',a_type_dest) = 0 THEN
         RETURN NULL;
      ELSE
			OPEN LAST_CORRESP;
			FETCH LAST_CORRESP INTO R_LAST_CORRESP;
			CLOSE LAST_CORRESP;
			RETURN R_LAST_CORRESP.NUMCORRES;
      END IF;

   EXCEPTION
        WHEN OTHERS THEN
         PK_trace.P_INS_journal_adm (
                  I_nom_traitement => 'PK_PREV.SEL_CORRES_BY_TYPE_DEST',
                  I_session  => SID,
                  I_niv_msg  => 3,
                  I_msg_adm  => substr(sqlerrm,1,132),
                  I_idligne  => 1);
         RETURN NULL;
    END SEL_CORRES_BY_TYPE_DEST;


    /***************************************************************************/
    FUNCTION CLOTURE_SINISTRE(
   	a_risq_deb    IN NUMBER,
   	a_risq_fin    IN NUMBER,
    a_cause_deb	  IN NUMBER,
    a_cause_fin   IN NUMBER,
    a_delais_mois_deb  IN NUMBER,
    a_typ_motif   IN NUMBER,
    a_session     IN file_edition.numedit%Type,
    a_niv_msg		  IN	NUMBER		Default 1,
    a_nom_traitement IN PARAM_BATCH.NUMBATCH%TYPE
    )RETURN BOOLEAN
    IS

      CURSOR C_SEL_SIN (c_risq_deb IN NUMBER,c_risq_fin IN NUMBER,c_cause_deb	IN NUMBER,c_cause_fin IN NUMBER)
      IS
             SELECT SIN_PREV.NOSIN,REPARTITION.IDREPARTITION,HISTO_CALCUL.NUMDEC,MAX_HISTO_CALCUL.CALCULMAX
             FROM SIN_PREV,REPARTITION,
             HISTO_CALCUL, (SELECT HISTO_CALCUL.IDREPARTITION,MAX(HISTO_CALCUL.IDCALCUL) CALCULMAX
                           FROM HISTO_CALCUL GROUP BY HISTO_CALCUL.IDREPARTITION) MAX_HISTO_CALCUL
             WHERE  SIN_PREV.NOSIN = REPARTITION.NOSIN
             AND SIN_PREV. DATEFIN is null
             AND REPARTITION.IDREPARTITION =  MAX_HISTO_CALCUL.IDREPARTITION
             AND HISTO_CALCUL.IDCALCUL = MAX_HISTO_CALCUL.CALCULMAX
             AND NORISQ BETWEEN c_risq_deb AND nvl(c_risq_fin,NORISQ)
             AND CAUSE  BETWEEN c_cause_deb AND nvl(c_cause_fin,CAUSE)
             ORDER BY SIN_PREV.NOSIN DESC,IDREPARTITION DESC;

      CURSOR C_SEL_DCPTSIN (c_numdec IN NUMBER)
      IS
             SELECT DATEDIT FROM V_DCPTPRV
             WHERE NUMDEC = c_numdec;



      --curseur
      V_SEL_SIN C_SEL_SIN%ROWTYPE;
      V_SEL_DCPTSIN C_SEL_DCPTSIN%ROWTYPE;
       --variables
      V_TEST_DATE NUMBER := 0;
      V_TEST_FERME NUMBER := 0;
      V_LIGNE NUMBER := 1;
    BEGIN

        OPEN C_SEL_SIN(a_risq_deb,a_risq_fin,a_cause_deb,a_cause_fin);
        LOOP
        FETCH C_SEL_SIN INTO V_SEL_SIN;
              EXIT WHEN C_SEL_SIN%NOTFOUND;
              IF V_SEL_SIN.NUMDEC > 0 THEN
                 OPEN C_SEL_DCPTSIN(V_SEL_SIN.NUMDEC);
                 LOOP
                 FETCH C_SEL_DCPTSIN INTO V_SEL_DCPTSIN;
                       EXIT WHEN C_SEL_DCPTSIN%NOTFOUND;

                        V_TEST_DATE := 0;

                       IF V_SEL_DCPTSIN.DATEDIT is not null THEN

                          V_TEST_FERME := 0;

                          SELECT  ADD_MONTHS(trunc(sysdate),a_delais_mois_deb*-1) - trunc(V_SEL_DCPTSIN.DATEDIT)
                          INTO  V_TEST_DATE
                          FROM DUAL;

                          SELECT nvl(max(ETAT),99) INTO V_TEST_FERME
                          FROM HISTO_SNTR_PREV
                          WHERE NOSIN = V_SEL_SIN.NOSIN AND ETAT = 2;

                          IF V_TEST_DATE > 0 AND V_TEST_FERME = 99 THEN

                             INSERT INTO HISTO_SNTR_PREV (NOSIN,DEBUT,ETAT,MOTIF,NUMUTIL,SAISIE)
                             VALUES (V_SEL_SIN.NOSIN,sysdate,2,a_typ_motif,f_numutil,sysdate);

                             UPDATE SIN_PREV SET DATEFIN = sysdate WHERE NOSIN = V_SEL_SIN.NOSIN;

                             V_LIGNE := V_LIGNE +1;

                             PK_trace.P_INS_journal_adm (
                             I_nom_traitement => a_nom_traitement,
                             I_session  => a_session,
                             I_niv_msg  => 3,
                             I_msg_adm  => 'Fermeture du sinistre : ' || V_SEL_SIN.NOSIN,
                             I_idligne  => V_LIGNE);

                          END IF;

                       END IF;

                 END LOOP;
                 IF C_SEL_DCPTSIN%ISOPEN THEN
                    CLOSE C_SEL_DCPTSIN;
                 END IF;
              END IF;
        END LOOP;
        IF C_SEL_SIN%ISOPEN THEN
           CLOSE C_SEL_SIN;
        END IF;

        RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
         IF C_SEL_SIN%ISOPEN THEN
           CLOSE C_SEL_SIN;
         END IF;
         IF C_SEL_DCPTSIN%ISOPEN THEN
           CLOSE C_SEL_DCPTSIN;
         END IF;
         PK_trace.P_INS_journal_adm (
                  I_nom_traitement => 'PK_PREV3.CLOTURE_SINISTRE',
                  I_session  => a_session,
                  I_niv_msg  => 3,
                  I_msg_adm  => substr(sqlerrm,1,132),
                  I_idligne  => 1);
         RETURN FALSE;
    END CLOTURE_SINISTRE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_transfert_dossier                                       */
/* Type         :  Public                                                    */
/* Description  :  Permet de transférer un ou plueirusers dossiers sinistre  */
/*                 d'un gestionnaire à un autre.                             */
/* Entree       :  a_traitement, nom du traitement                           */
/*                 a_gest_source , numutil gestionnaire source               */
/*                 a_gest_dest, numutil gestionnaire de destination          */
/*                 a_session, session_id du demandeur                        */
/*                 a_niv_msg, niveau de trace                                */
/*---------------------------------------------------------------------------*/
	PROCEDURE P_transfert_dossier (
		a_traitement	IN	JOURNAL_ADM.NOM_TRAITEMENT%TYPE,
		a_gest_source   IN  NUMBER,
		a_from_dir		IN  DOSSIER_SINISTRE.IDDOSSIER%TYPE,
		a_to_dir		IN  DOSSIER_SINISTRE.IDDOSSIER%TYPE,
		a_gest_dest		IN  NUMBER,
		a_session		IN	file_edition.numedit%Type,
		a_niv_msg		IN	NUMBER
    ) IS
		/* Récupérer les dossiers du gestionnaire source */
		Cursor C_dossier_source IS
			Select iddossier
			From   dossier_sinistre
			Where  numutil = a_gest_source
			AND	   iddossier
			BETWEEN NVL(a_from_dir,(select min(iddossier) from dossier_sinistre where numutil = a_gest_source and	( fin >= sysdate OR fin is null )))
			AND NVL(a_to_dir,(select max(iddossier) from dossier_sinistre where numutil = a_gest_source and	( fin >= sysdate OR fin is null )))
			And		 ( fin >= sysdate OR fin is null );

		/* Récupérer les sinistres du dossier I_iddossier */
		Cursor C_sinistre_dossier ( I_iddossier IN sntr_prev.nosin%TYPE ) IS
			Select nosin
			From	 sntr_prev
			Where  iddossier = I_iddossier;


		v_nbrows  NUMBER:=0;
		v_nbrows2  NUMBER:=0;
	BEGIN

		 PK_trace.P_INS_journal_adm (
		  I_nom_traitement => 'PK_PREV.P_transfert_dossier',
		  I_session  => a_session,
		  I_niv_msg  => 1,
		  I_msg_adm  => 'DEBUT TRAITEMENT',
		  I_idligne  => 1);

		 PK_trace.P_INS_journal_adm (
		  I_nom_traitement => 'PK_PREV.P_transfert_dossier',
		  I_session  => a_session,
		  I_niv_msg  => 1,
		  I_msg_adm  => 'Paramètres: | '||a_gest_source||' | '||a_from_dir||' | '||a_to_dir||' | ' ||a_gest_dest||' | .',
		  I_idligne  => 1);


		/* Pour chaque numéro de dossier du gestionnaire source */
		For Cur_dossier IN C_dossier_source Loop

			 v_nbrows:=0;
			/* Mettre à jour la table SNTR_PREV */
			UPDATE SNTR_PREV SET NUMUTIL = 	 a_gest_dest,
								 MAJ = SYSDATE,
								 MODIFICATION = SYSDATE,
							     MODIFICATEUR = F_NUMUTIL
			WHERE IDDOSSIER = Cur_dossier.iddossier;
			v_nbrows := v_nbrows+SQL%ROWCOUNT;
			v_nbrows2 := 0;
			/* Pour chaque sinistre du dossier */
			For Cur_sinistre IN C_sinistre_dossier ( Cur_dossier.iddossier ) Loop
				/* Mettre à jour la table HISTO_SNTR_PREV */
				UPDATE HISTO_SNTR_PREV SET NUMUTIL = a_gest_dest WHERE NOSIN = Cur_sinistre.nosin;
				v_nbrows2 := v_nbrows2+SQL%ROWCOUNT;
			End Loop;
		End loop ;

		 PK_trace.P_INS_journal_adm (
			  I_nom_traitement => 'PK_PREV.P_transfert_dossier',
			  I_session  => a_session,
			  I_niv_msg  => 3,
			  I_msg_adm  => v_nbrows||' update sur sntr_prev.',
			  I_idligne  => 2);
		 PK_trace.P_INS_journal_adm (
			  I_nom_traitement => 'PK_PREV.P_transfert_dossier',
			  I_session  => a_session,
			  I_niv_msg  => 3,
			  I_msg_adm  => v_nbrows2||' update sur histo_sntr_prev.',
			  I_idligne  => 3);

		v_nbrows:=0;
		UPDATE DOSSIER_SINISTRE SET NUMUTIL = a_gest_dest WHERE IDDOSSIER in (Select iddossier
			From   dossier_sinistre
			Where  numutil = a_gest_source
			AND	   iddossier
			BETWEEN NVL(a_from_dir,(select min(iddossier) from dossier_sinistre where numutil = a_gest_source and	( fin >= sysdate OR fin is null )))
			AND NVL(a_to_dir,(select max(iddossier) from dossier_sinistre where numutil = a_gest_source and	( fin >= sysdate OR fin is null )))
			And		 ( fin >= sysdate OR fin is null ));
		  v_nbrows := SQL%ROWCOUNT;

		  IF v_nbrows=0 THEN
              PK_trace.P_INS_journal_adm (
			  I_nom_traitement => 'PK_PREV.P_transfert_dossier',
			  I_session  => a_session,
			  I_niv_msg  => 1,
			  I_msg_adm  => 'Aucun transfert de dossier',
			  I_idligne  => 4);
            ELSE
			  PK_trace.P_INS_journal_adm (
			  I_nom_traitement => 'PK_PREV.P_transfert_dossier',
			  I_session  => a_session,
			  I_niv_msg  => 1,
			  I_msg_adm  => v_nbrows||' dossier(s) transféré(s) du gestionnaire '||a_gest_source||' au gestionnaire '||a_gest_dest||'.',
			  I_idligne  => 4);
		 END IF;

		PK_trace.P_INS_journal_adm (
		  I_nom_traitement => 'PK_PREV.P_transfert_dossier',
		  I_session  => a_session,
		  I_niv_msg  => 1,
		  I_msg_adm  => 'FIN TRAITEMENT',
		  I_idligne  => 5);
	EXCEPTION
      WHEN OTHERS THEN
         PK_trace.P_INS_journal_adm (
                  I_nom_traitement => 'PK_PREV.P_transfert_dossier',
                  I_session  => a_session,
                  I_niv_msg  => 3,
                  I_msg_adm  => substr(sqlerrm,1,132),
                  I_idligne  => 6);
	END P_transfert_dossier;

END;
/
