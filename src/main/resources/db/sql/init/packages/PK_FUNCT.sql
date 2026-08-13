CREATE OR REPLACE PACKAGE ARTHUS.PK_FUNCT
AS
   FUNCTION f_age (i_numindiv IN NUMBER, i_date IN DATE DEFAULT SYSDATE)
      RETURN NUMBER;

-- Pragma Restrict_References(f_age, WNDS, WNPS);
   FUNCTION f_agem (i_numindiv IN NUMBER, i_date IN DATE DEFAULT SYSDATE)
      RETURN NUMBER;

-- Pragma Restrict_References(f_ageM, WNDS, WNPS);
   FUNCTION f_round (a_valeur IN NUMBER, a_niveau IN NUMBER DEFAULT 0)
      RETURN NUMBER;

-- Pragma Restrict_References(f_round, WNDS, WNPS);
   FUNCTION f_sup (a_valeur IN NUMBER, a_niveau IN NUMBER DEFAULT 0)
      RETURN NUMBER;

-- Pragma Restrict_References(f_sup, WNDS, WNPS);
   FUNCTION f_inf (a_valeur IN NUMBER, a_niveau IN NUMBER DEFAULT 0)
      RETURN NUMBER;

-- Pragma Restrict_References(f_inf, WNDS, WNPS);
   FUNCTION f_nb_adr (
      comm_idadhesion   IN   NUMBER,
      a_numindiv        IN   NUMBER,
      a_type1           IN   NUMBER,
      a_type2           IN   NUMBER,
      a_date            IN   DATE,
      a_numfor          IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_nb_adr, WNDS, WNPS);
   FUNCTION f_nb_adr2 (
      comm_idadhesion   IN   NUMBER,
      a_numindiv        IN   NUMBER,
      a_type1           IN   NUMBER,
      a_type2           IN   NUMBER,
      a_date            IN   DATE,
      a_age             IN   NUMBER,
      a_op              IN   NUMBER,
      a_numfor          IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_nb_adr2, WNDS, WNPS);
   FUNCTION f_reg (
      comm_idadhesion   IN   NUMBER,
      a_numindiv        IN   NUMBER,
      a_numfor          IN   NUMBER,
      a_date            IN   DATE
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_reg, WNDS, WNPS);
   FUNCTION f_t_aydr (comm_idadhesion IN NUMBER, a_numindiv IN NUMBER)
      RETURN NUMBER;

-- Pragma Restrict_References(f_t_aydr, WNDS, WNPS);
   FUNCTION f_r_aydr (
      comm_idadhesion   IN   NUMBER,
      a_numindiv        IN   NUMBER,
      a_type1           IN   NUMBER,
      a_type2           IN   NUMBER,
      a_date            IN   DATE,
      a_numfor          IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_r_aydr, WNDS, WNPS);
   FUNCTION f_j_conso (
      comm_numindiv   IN   NUMBER,
      comm_numfor     IN   NUMBER,
      comm_nosin      IN   NUMBER,
      comm_numbene    IN   NUMBER,
      a_debut         IN   DATE,
      a_fin           IN   DATE,
      a_flag_sin      IN   NUMBER DEFAULT 0,
      a_flag_bene     IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_j_conso, WNDS, WNPS);
   FUNCTION f_naydr (
      comm_idadhesion   IN   NUMBER,
      a_numindiv        IN   NUMBER,
      a_type1           IN   NUMBER,
      a_type2           IN   NUMBER,
      a_date            IN   DATE,
      a_rang            IN   NUMBER DEFAULT 1,
      a_numfor          IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_naydr, WNDS, WNPS);
   FUNCTION f_arret_debut (
      a_nosin     IN   NUMBER,
      a_debut     IN   DATE,
      a_continu   IN   VARCHAR2,
      a_type      IN   NUMBER
   )
      RETURN DATE;

-- Pragma Restrict_References(f_arret_debut, WNDS, WNPS);
   FUNCTION f_pret (
      comm_idadhesion   IN   NUMBER,
      comm_numindiv     IN   NUMBER,
      a_indice          IN   NUMBER
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_pret, WNDS, WNPS);
   FUNCTION f_histo_pret (
      comm_idadhesion   IN   NUMBER,
      comm_numindiv     IN   NUMBER,
      comm_debut        IN   DATE,
      a_indice          IN   NUMBER
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_histo_pret, WNDS, WNPS);
   FUNCTION f_adhe_pret (
      comm_idadhesion   IN   NUMBER,
      comm_numindiv     IN   NUMBER,
      a_indice          IN   NUMBER
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_adhe_pret, WNDS, WNPS);
   FUNCTION f_ngroupe (comm_numindiv IN NUMBER, comm_type IN NUMBER)
      RETURN NUMBER;

-- Pragma Restrict_References(f_ngroupe, WNDS, WNPS);
   FUNCTION f_pers_sexe (comm_numindiv IN NUMBER)
      RETURN NUMBER;

-- Pragma Restrict_References(f_pers_sexe, WNDS, WNPS);
   FUNCTION f_inval (
      comm_nosin   IN   NUMBER,
      comm_debut   IN   DATE,
      a_indice     IN   NUMBER
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_inval, WNDS, WNPS);
   FUNCTION f_taux_remun (
      a_tfc        IN   NUMBER,
      a_type_tfc   IN   NUMBER,
      a_etendue    IN   NUMBER,
      a_cle        IN   NUMBER,
      a_debut      IN   DATE DEFAULT NULL,
      a_numbene    IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_taux_remun, WNDS, WNPS);
   FUNCTION f_calcul_unique (
      a_tfc         IN   NUMBER,
      a_type_tfc    IN   NUMBER,
      a_etendue     IN   NUMBER,
      a_cle         IN   NUMBER,
      a_numfor      IN   NUMBER,
      a_numindiv    IN   NUMBER,
      a_debut       IN   DATE,
      a_fin         IN   DATE,
      a_mode_calc   IN   NUMBER DEFAULT 2
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_calcul_unique, WNDS, WNPS);
   FUNCTION f_arrondi (
      a_codope    IN   NUMBER,
      a_cle       IN   NUMBER,
      a_montant   IN   NUMBER
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_arrondi, WNDS, WNPS);
   FUNCTION f_tab2 (
      a_tableau   IN   NUMBER,
      a_cle1      IN   NUMBER,
      a_cle2      IN   NUMBER,
      a_date      IN   DATE
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_tab2, WNDS, WNPS);
   FUNCTION f_acte_conso (
      i_numindiv     IN   NUMBER,
      i_idadhesion   IN   NUMBER,
      i_numfor       IN   NUMBER,
      i_nature       IN   NUMBER,
      i_codfrais     IN   VARCHAR2,
      i_debut        IN   DATE,
      i_fin          IN   DATE,
      i_etendue      IN   NUMBER DEFAULT 0,
      i_type         IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_acte_conso, WNDS, WNPS);
   FUNCTION f_appel_unique (
      i_mode_calcul   IN   NUMBER,
      i_type_qttc     IN   NUMBER,
      i_numgar        IN   qttc_global.numgar%TYPE,
      i_idadhesion    IN   qttc_global.idadhesion%TYPE
   )
      RETURN NUMBER;

-- Pragma Restrict_References(f_appel_unique, WNDS, WNPS);
   FUNCTION f_code_reass (i_numfor IN NUMBER)
      RETURN NUMBER;

-- Pragma Restrict_References(f_code_reass, WNDS, WNPS);
--
   FUNCTION f_sel_cotis_annuelle (
      i_numgar       IN   qttc_global.numgar%TYPE,
      i_idadhesion   IN   qttc_global.idadhesion%TYPE,
      i_numfor       IN   qttc_gar.numfor%TYPE,
      i_debut        IN   qttc_global.debut%TYPE
   )
      RETURN NUMBER;

--
-- Montant des capitaux verses par adherent / garantie sur la periode reassure
--
   FUNCTION f_sel_base_prev (
      i_idadhesion   IN   repartition.idadhesion%TYPE,
      i_numfor       IN   repartition.numfor%TYPE,
      i_debut        IN   DATE,
      i_fin          IN   DATE
   )
      RETURN NUMBER;

--
-- Retourne le pays des soins
   FUNCTION f_pays_soins (comm_pays_soins IN NUMBER)
      RETURN NUMBER;

-- retourne le pays de la nationalité d'un individu
   FUNCTION f_pays_nat (comm_numindiv IN NUMBER)
      RETURN NUMBER;

-- Retourne 1 si la prestation a fait l'objet d'une PEC sur dossier
   FUNCTION f_accord (i_num_dossier IN dossier_sante.num_dossier%TYPE)
      RETURN NUMBER;

-- Retourne la date d'ouverture d'un dossier
   FUNCTION f_d_doss (i_num_dossier IN dossier_sante.num_dossier%TYPE)
      RETURN DATE;

-- Retourne la date de fin des soins sur laligne de dossier
   FUNCTION f_dp_f (
      i_num_dossier   IN   sinistre_sante.num_dossier%TYPE,
      i_numligne      IN   sinistre_sante.numligne%TYPE
   )
      RETURN DATE;

-- Retourne 1 si le dossier est de type réseau
   FUNCTION f_p_reseau (i_num_dossier IN dossier_sante.num_dossier%TYPE)
      RETURN NUMBER;

-- retourne le type d'élément sur la ligne d'un dossier
   FUNCTION f_p_typelt (
      i_num_dossier   IN   sinistre_sante.num_dossier%TYPE,
      i_numligne      IN   sinistre_sante.numligne%TYPE
   )
      RETURN NUMBER;

   FUNCTION f_p_elt (
      i_num_dossier   IN   sinistre_sante.num_dossier%TYPE,
      i_numligne      IN   sinistre_sante.numligne%TYPE
   )
      RETURN NUMBER;

END pk_funct;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_FUNCT
AS
--
   FUNCTION f_agem (i_numindiv IN NUMBER, i_date IN DATE DEFAULT SYSDATE)
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT   TO_NUMBER (TO_CHAR (i_date, 'YYYY'))
                - TO_NUMBER (TO_CHAR (datnais, 'YYYY'))
           INTO loc_retour
           FROM indvs
          WHERE numindiv = i_numindiv;
      EXCEPTION
         WHEN OTHERS
         THEN
            loc_retour := 0;
      END;

      RETURN (loc_retour);
   END f_agem;

--
--
   FUNCTION f_age (i_numindiv IN NUMBER, i_date IN DATE DEFAULT SYSDATE)
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT (MONTHS_BETWEEN (i_date, datnais)) / 12
           INTO loc_retour
           FROM indvs
          WHERE numindiv = i_numindiv;
      EXCEPTION
         WHEN OTHERS
         THEN
            loc_retour := 0;
      END;

      RETURN (loc_retour);
   END f_age;

--
   FUNCTION f_numgar (a_etendue IN NUMBER, a_cle IN NUMBER)
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      IF (a_etendue = 4)
      THEN
         BEGIN
            SELECT numgar
              INTO loc_retour
              FROM qttc_global
             WHERE numquit = a_cle;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;
      END IF;

      RETURN (loc_retour);
   END f_numgar;

   FUNCTION f_round (a_valeur IN NUMBER, a_niveau IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
   BEGIN
      RETURN (ROUND (a_valeur, a_niveau));
   END f_round;

   FUNCTION f_sup (a_valeur IN NUMBER, a_niveau IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      loc_valeur   NUMBER;
   BEGIN
      loc_valeur := a_valeur * POWER (10, a_niveau);

      IF (SIGN (loc_valeur) = -1)
      THEN
         loc_valeur := FLOOR (loc_valeur);
      ELSE
         loc_valeur := CEIL (loc_valeur);
      END IF;

      loc_valeur := loc_valeur / POWER (10, a_niveau);
      RETURN (loc_valeur);
   END f_sup;

   FUNCTION f_inf (a_valeur IN NUMBER, a_niveau IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      loc_valeur   NUMBER;
   BEGIN
      loc_valeur := a_valeur * POWER (10, a_niveau);

      IF (SIGN (loc_valeur) = -1)
      THEN
         loc_valeur := CEIL (loc_valeur);
      ELSE
         loc_valeur := FLOOR (loc_valeur);
      END IF;

      loc_valeur := loc_valeur / POWER (10, a_niveau);
      RETURN (loc_valeur);
   END f_inf;

/*
   Fonction NB_ADR(idadhesion, numindiv, type, date, numfor)
   Retourne le nombre d'ayant droit d'un type donne couvert sur l'adhesion
   a la date et eventuellement sur la garantie
   -------------------------------------------------------------------- */
   FUNCTION f_nb_adr (
      comm_idadhesion   IN   NUMBER,
      a_numindiv        IN   NUMBER,
      a_type1           IN   NUMBER,
      a_type2           IN   NUMBER,
      a_date            IN   DATE,
      a_numfor          IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER
   IS
      loc_nb_adr   NUMBER;
   BEGIN
      IF (comm_idadhesion = 0)
      THEN
         /* Recherche sur la fiche assure */
         BEGIN
            SELECT NVL (COUNT (*), 0)
              INTO loc_nb_adr
              FROM indvs
             WHERE indvs.numassu = a_numindiv
               AND indvs.typadr BETWEEN a_type1 AND a_type2
               AND EXISTS (
                      SELECT 1
                        FROM couverture
                       WHERE couverture.numindiv = indvs.numindiv
                         AND a_date BETWEEN couverture.datapli
                                        AND NVL (couverture.datper, a_date));
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_nb_adr := 0;
         END;
      ELSE
         /* Recherche sur l' adhesion  */
         BEGIN
            SELECT NVL (COUNT (*), 0)
              INTO loc_nb_adr
              FROM adhe_cntrt_membre affilie
             WHERE affilie.idadhesion = comm_idadhesion
               AND affilie.typadr BETWEEN a_type1 AND a_type2
               AND EXISTS (
                      SELECT 1
                        FROM couverture
                       WHERE a_date BETWEEN couverture.datapli
                                        AND NVL (couverture.datper, a_date)
                         AND couverture.numfor =
                                DECODE (a_numfor,
                                        0, couverture.numfor,
                                        a_numfor
                                       )
                         AND couverture.numindiv = affilie.numindiv
                         AND couverture.idadhesion = comm_idadhesion);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_nb_adr := 0;
         END;
      END IF;

      RETURN loc_nb_adr;
   END f_nb_adr;

/*   Fonction NB_ADR(idadhesion, numindiv, type, date, numfor)
   Retourne le nombre d'ayant droit d'un type donne couvert sur l'adhesion
   a la date et eventuellement sur la garantie
   -------------------------------------------------------------------- */
   FUNCTION f_nb_adr2 (
      comm_idadhesion   IN   NUMBER,
      a_numindiv        IN   NUMBER,
      a_type1           IN   NUMBER,
      a_type2           IN   NUMBER,
      a_date            IN   DATE,
      a_age             IN   NUMBER,
      a_op              IN   NUMBER,
      a_numfor          IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER
   IS
      loc_nb_adr2    NUMBER;
      loc_numindiv   NUMBER (9);
      loc_oprt       VARCHAR2 (3);
      loc_age        NUMBER;
      sql_stmt       VARCHAR2 (2048);
   BEGIN
/* Chargement de  l'opérateur */
      IF a_op = 1
      THEN
         loc_oprt := '= ';
      ELSIF a_op = 2
      THEN
         loc_oprt := '< ';
      ELSIF a_op = 3
      THEN
         loc_oprt := '> ';
      ELSIF a_op = 4
      THEN
         loc_oprt := '<=';
      ELSIF a_op = 5
      THEN
         loc_oprt := '>=';
      ELSE
         loc_oprt := '= ';
      END IF;

      /* Recherche de l'âge de la personne */
      BEGIN
         IF comm_idadhesion > 0
         THEN
            BEGIN
               SELECT numindiv
                 INTO loc_numindiv
                 FROM adhe_cntrt_membre
                WHERE idadhesion = comm_idadhesion;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         ELSE
            loc_numindiv := a_numindiv;
         END IF;
      END;

      loc_age := f_agem (loc_numindiv, a_date);

      /* traitement de la requête */
      IF (comm_idadhesion = 0)
      THEN
         /* Recherche sur la fiche assure */
         sql_stmt :=
               'SELECT	nvl(COUNT(*),0)
		FROM	INDVS
		WHERE	indvs.numassu	= '
            || a_numindiv
            || 'AND	indvs.typadr	between '
            || a_type1
            || ' and '
            || a_type2
            || ' AND '
            || loc_age
            || loc_oprt
            || a_age
            || ' AND	exists (select	1
		       from	couverture
			 where couverture.numindiv = INDVS.numindiv
			   and '''
            || a_date
            || ''' between couverture.datapli
					   and nvl(couverture.datper,
                                 '''
            || a_date
            || ''')
				 )';
      ELSE
         /* Recherche sur l' adhesion  */
         sql_stmt :=
               'SELECT	nvl(COUNT(*),0)
		FROM	adhe_cntrt_membre affilie
		WHERE	affilie.idadhesion	= '
            || comm_idadhesion
            || 'AND	affilie.typadr	between '
            || a_type1
            || 'and '
            || a_type2
            || ' AND '
            || loc_age
            || loc_oprt
            || a_age
            || 'AND	exists (
			select	1
			from	couverture
			where'''
            || a_date
            || '''
				between	couverture.datapli
				and	nvl(couverture.datper,
					 '''
            || a_date
            || ''')
			and	couverture.numfor = decode('
            || a_numfor
            || ',
							0, couverture.numfor,'
            || a_numfor
            || ')
			and	couverture.numindiv = affilie.numindiv
			and	couverture.idadhesion = '
            || comm_idadhesion
            || ')';
      END IF;

      EXECUTE IMMEDIATE sql_stmt
                   INTO loc_nb_adr2;

      RETURN loc_nb_adr2;
   EXCEPTION
      WHEN OTHERS
      THEN
         loc_nb_adr2 := 0;
   END f_nb_adr2;

/*
   Fonction REG(idadhesion, numindiv, numfor, date)
   Retourne le regime de base de l'assure
   -------------------------------------------------------------------- */
   FUNCTION f_reg (
      comm_idadhesion   IN   NUMBER,
      a_numindiv        IN   NUMBER,
      a_numfor          IN   NUMBER,
      a_date            IN   DATE
   )
      RETURN NUMBER
   IS
      loc_regime   NUMBER;
   BEGIN
      BEGIN
         IF (a_numfor = 0 OR comm_idadhesion = 0)
         THEN
            /* Recherche sur la fiche assure */
            SELECT indvs.orgbase
              INTO loc_regime
              FROM indvs
             WHERE indvs.numindiv = a_numindiv;
         ELSE
            /* Recherche sur la couverture   */
            SELECT NVL (MIN (cvrt.numorg), 0)
              INTO loc_regime
              FROM cvrt
             WHERE cvrt.numindiv = a_numindiv
               AND cvrt.numfor = a_numfor
               AND cvrt.idadhesion = comm_idadhesion
               AND a_date BETWEEN cvrt.datapli AND NVL (cvrt.datper, a_date);
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_regime := 0;
      END;

      RETURN loc_regime;
   END f_reg;

/*
   Fonction T_AYDR(idadhesion, numindiv)
   Retourne le type d'ayant droit d'un assure
   sur l'adhesion si comm_idadhesion renseigne, sinon sur assure
   -------------------------------------------------------------------- */
   FUNCTION f_t_aydr (comm_idadhesion IN NUMBER, a_numindiv IN NUMBER)
      RETURN NUMBER
   IS
      loc_t_aydr   NUMBER;
   BEGIN
      IF (comm_idadhesion = 0)
      THEN
         /* Recherche sur la fiche assure */
         BEGIN
            SELECT NVL (indvs.typadr, 0)
              INTO loc_t_aydr
              FROM indvs
             WHERE indvs.numindiv = a_numindiv;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_t_aydr := 0;
         END;
      ELSE
         /* Recherche sur l' adhesion  */
         BEGIN
            SELECT NVL (affilie.typadr, 0)
              INTO loc_t_aydr
              FROM adhe_cntrt_membre affilie
             WHERE affilie.numindiv = a_numindiv
               AND affilie.idadhesion = comm_idadhesion;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_t_aydr := 0;
         END;
      END IF;

      RETURN loc_t_aydr;
   END f_t_aydr;

/*
   Fonction R_AYDR(idadhesion, numindiv, type, date, numfor)
   Retourne le rang d'un ayant droit d'un type donne couvert sur l'adhesion
   a la date et eventuellement sur la garantie
   -------------------------------------------------------------------- */
   FUNCTION f_r_aydr (
      comm_idadhesion   IN   NUMBER,
      a_numindiv        IN   NUMBER,
      a_type1           IN   NUMBER,
      a_type2           IN   NUMBER,
      a_date            IN   DATE,
      a_numfor          IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER
   IS
      loc_r_aydr   NUMBER;
   BEGIN
      IF (comm_idadhesion = 0)
      THEN
         /* Recherche sur la fiche assure */
         BEGIN
            SELECT NVL (COUNT (numindiv), 0)
              INTO loc_r_aydr
              FROM indvs ayd
             WHERE ayd.numassu =
                      (SELECT numassu
                         FROM indvs princ
                        WHERE princ.numindiv = a_numindiv
                          AND princ.typadr BETWEEN a_type1 AND a_type2)
               AND ayd.typadr BETWEEN a_type1 AND a_type2
               AND (ayd.datnais + (ayd.rang / 4)) <=
                                                (SELECT datnais + (rang / 4)
                                                   FROM indvs
                                                  WHERE numindiv = a_numindiv);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_r_aydr := 0;
         END;
      ELSE
         /* Recherche sur l' adhesion  */
         BEGIN
            SELECT NVL (COUNT (affilie.numindiv), 0)
              INTO loc_r_aydr
              FROM indvs ayd, adhe_cntrt_membre affilie
             WHERE (ayd.datnais + (ayd.rang / 4)) <=
                                          (SELECT datnais + (rang / 4)
                                             FROM indvs
                                            WHERE indvs.numindiv = a_numindiv)
               AND ayd.numindiv = affilie.numindiv
               AND affilie.typadr BETWEEN a_type1 AND a_type2
               AND affilie.idadhesion = comm_idadhesion
               AND EXISTS (
                      SELECT 1
                        FROM couverture
                       WHERE a_date BETWEEN couverture.datapli
                                        AND NVL (couverture.datper, a_date)
                         AND couverture.numfor =
                                DECODE (a_numfor,
                                        0, couverture.numfor,
                                        a_numfor
                                       )
                         AND couverture.numindiv = affilie.numindiv
                         AND couverture.idadhesion = comm_idadhesion);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_r_aydr := 0;
         END;
      END IF;

      RETURN loc_r_aydr;
   END f_r_aydr;

/*
   Fonction J_CONSO(numindiv, numfor, nosin, numbene, debut, fin, flag_sin, flag_bene)
   Retourne le nombre de jours consommes au titre d'une garantie pour 1 assure
   Si flag_sin = 1 sur le sinistre. Si flag_bene = 1 pour le beneficiaire
   03/03/98 Pascal Modif sur decompte
   31/03/98 Pascal : Prise en compte du nouveau modele histo_calcul
   -------------------------------------------------------------------- */
   FUNCTION f_j_conso (
      comm_numindiv   IN   NUMBER,
      comm_numfor     IN   NUMBER,
      comm_nosin      IN   NUMBER,
      comm_numbene    IN   NUMBER,
      a_debut         IN   DATE,
      a_fin           IN   DATE,
      a_flag_sin      IN   NUMBER DEFAULT 0,
      a_flag_bene     IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER
   IS
      loc_nbj     NUMBER                := 0;

      CURSOR fetch_histo
      IS
         SELECT histo_calcul.idrepartition, histo_calcul.numbene,
                histo_jours.debut, histo_jours.fin, sin_prev.nosin
           FROM histo_calcul, histo_jours, repartition, sin_prev
          WHERE histo_calcul.idrepartition = repartition.idrepartition
            AND histo_calcul.numbene =
                   DECODE (a_flag_bene,
                           0, histo_calcul.numbene,
                           comm_numbene
                          )
            AND histo_jours.idcalcul = histo_calcul.idcalcul
            AND repartition.numfor = comm_numfor
            AND repartition.nosin = sin_prev.nosin
            AND sin_prev.numindiv = comm_numindiv
            AND NOT EXISTS (
                            SELECT 1
                              FROM histo_annul
                             WHERE histo_annul.idcalcul =
                                                         histo_calcul.idcalcul)
            AND NOT EXISTS (SELECT 1
                              FROM histo_annul
                             WHERE histo_annul.idannul = histo_calcul.idcalcul);

      histo       fetch_histo%ROWTYPE;
      loc_debut   DATE;
      loc_fin     DATE;
   BEGIN
      FOR histo IN fetch_histo
      LOOP
         IF ((a_flag_sin != 0) AND (histo.nosin != comm_nosin))
         THEN
            EXIT;
         END IF;

         IF (   (histo.debut BETWEEN a_debut AND a_fin)
             OR (histo.fin BETWEEN a_debut AND a_fin)
            )
         THEN
            loc_debut := GREATEST (a_debut, histo.debut);
            loc_fin := LEAST (a_fin, histo.fin);
            loc_nbj := loc_nbj + (loc_fin - loc_debut) + 1;
         END IF;
      END LOOP;

      RETURN loc_nbj;
   END f_j_conso;

/*
   Fonction NAYDR(idadhesion, numindiv, type1, type2, date, rang, numfor)
   Retourne le N° d'un ayant droit d'un type et de rang donne couvert
   sur l'adhesion a la date et eventuellement sur la garantie
   -------------------------------------------------------------------- */
   FUNCTION f_naydr (
      comm_idadhesion   IN   NUMBER,
      a_numindiv        IN   NUMBER,
      a_type1           IN   NUMBER,
      a_type2           IN   NUMBER,
      a_date            IN   DATE,
      a_rang            IN   NUMBER DEFAULT 1,
      a_numfor          IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER
   IS
      loc_naydr   NUMBER;
   BEGIN
      IF (comm_idadhesion = 0)
      THEN
         /* Recherche sur la fiche assure */
         BEGIN
            SELECT NVL (MIN (ayd.numindiv), 0)
              INTO loc_naydr
              FROM indvs ayd
             WHERE ayd.numassu =
                      (SELECT numassu
                         FROM indvs princ
                        WHERE princ.numindiv = a_numindiv
                          AND princ.typadr BETWEEN a_type1 AND a_type2)
               AND ayd.typadr BETWEEN a_type1 AND a_type2
               AND (   f_r_aydr (0, ayd.numindiv, a_type1, a_type2, a_date) =
                                                                        a_rang
                    OR a_rang = 0
                   );
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_naydr := 0;
         END;
      ELSE
         /* Recherche sur l' adhesion  */
         BEGIN
            SELECT NVL (MIN (affilie.numindiv), 0)
              INTO loc_naydr
              FROM indvs ayd, adhe_cntrt_membre affilie
             WHERE (   f_r_aydr (comm_idadhesion,
                                 ayd.numindiv,
                                 a_type1,
                                 a_type2,
                                 a_date,
                                 a_numfor
                                ) = a_rang
                    OR a_rang = 0
                   )
               AND ayd.numindiv = affilie.numindiv
               AND affilie.typadr BETWEEN a_type1 AND a_type2
               AND affilie.idadhesion = comm_idadhesion
               AND EXISTS (
                      SELECT 1
                        FROM couverture
                       WHERE a_date BETWEEN couverture.datapli
                                        AND NVL (couverture.datper, a_date)
                         AND couverture.numfor =
                                DECODE (a_numfor,
                                        0, couverture.numfor,
                                        a_numfor
                                       )
                         AND couverture.numindiv = affilie.numindiv
                         AND couverture.idadhesion = comm_idadhesion);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_naydr := 0;
         END;
      END IF;

      RETURN loc_naydr;
   END f_naydr;

/*
   Fonction f_arret_debut(a_nosin, a_debut)
   Date de debut d'arret d'un type donne continu ou non
*/
   FUNCTION f_arret_debut (
      a_nosin     IN   NUMBER,
      a_debut     IN   DATE,
      a_continu   IN   VARCHAR2,
      a_type      IN   NUMBER
   )
      RETURN DATE
   IS
      loc_nbjour    INTEGER         := 0;
      loc_debut     DATE            := a_debut;
      loc_continu   VARCHAR2 (1)    := a_continu;
      loc_arret     arret%ROWTYPE;
   BEGIN
      FOR loc_arret IN (SELECT   debut, fin, continu
                            FROM arret
                           WHERE fin < a_debut
                             AND nosin = a_nosin
                             AND TYPE = a_type
                        ORDER BY debut DESC)
      LOOP
         IF ((loc_continu = 'O'))
         THEN
            loc_nbjour :=
                         loc_nbjour
                         + ((loc_arret.fin - loc_arret.debut) + 1);
            loc_debut := loc_arret.debut;
            loc_continu := loc_arret.continu;
         END IF;
      END LOOP;

      RETURN (loc_debut);
   END f_arret_debut;

   FUNCTION f_pret (
      comm_idadhesion   IN   NUMBER,
      comm_numindiv     IN   NUMBER,
      a_indice          IN   NUMBER
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
      loc_idpret   NUMBER;
      prt          pret%ROWTYPE;
   BEGIN
      loc_idpret := f_adhe_pret (comm_idadhesion, comm_numindiv, 1);

      FOR prt IN (SELECT pret.type_pret, pret.duree_pret, pret.duree_differe,
                         pret.montant
                    FROM pret
                   WHERE pret.idpret = loc_idpret)
      LOOP
         IF (a_indice = 1)
         THEN
            loc_retour := prt.type_pret;
         ELSIF (a_indice = 2)
         THEN
            loc_retour := prt.duree_pret;
         ELSIF (a_indice = 3)
         THEN
            loc_retour := prt.duree_differe;
         ELSIF (a_indice = 4)
         THEN
            loc_retour := prt.duree_pret + prt.duree_differe;
         ELSIF (a_indice = 5)
         THEN
            loc_retour := prt.montant;
         ELSIF (a_indice = 6)
         THEN
            loc_retour :=
                 prt.montant
               / (100 / f_adhe_pret (comm_idadhesion, comm_numindiv, 2));
         END IF;

         EXIT;
      END LOOP;

      RETURN (loc_retour);
   END f_pret;

   FUNCTION f_histo_pret (
      comm_idadhesion   IN   NUMBER,
      comm_numindiv     IN   NUMBER,
      comm_debut        IN   DATE,
      a_indice          IN   NUMBER
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
      loc_idpret   NUMBER;
      histo        histo_pret%ROWTYPE;
   BEGIN
      loc_idpret := f_adhe_pret (comm_idadhesion, comm_numindiv, 1);

      FOR histo IN (SELECT   histo_pret.montant, histo_pret.periodicite
                        FROM histo_pret
                       WHERE histo_pret.idpret = loc_idpret
                         AND debut <= comm_debut
                    ORDER BY debut DESC)
      LOOP
         IF (a_indice = 1)
         THEN
            loc_retour := histo.montant;
         ELSIF (a_indice = 2)
         THEN
            IF (histo.periodicite = 1)
            THEN
               loc_retour := 30;
            ELSIF (histo.periodicite = 3)
            THEN
               loc_retour := 90;
            ELSIF (histo.periodicite = 6)
            THEN
               loc_retour := 180;
            ELSIF (histo.periodicite = 12)
            THEN
               loc_retour := 360;
            END IF;
         END IF;

         EXIT;
      END LOOP;

      RETURN (loc_retour);
   END f_histo_pret;

   FUNCTION f_adhe_pret (
      comm_idadhesion   IN   NUMBER,
      comm_numindiv     IN   NUMBER,
      a_indice          IN   NUMBER
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
      adhprt       adhe_pret%ROWTYPE;
   BEGIN
      FOR adhprt IN (SELECT adhe_pret.idpret, adhe_pret.pourc_assure,
                            adhe_pret.majoration
                       FROM adhe_pret
                      WHERE adhe_pret.idadhesion = comm_idadhesion
                        AND adhe_pret.numindiv = comm_numindiv)
      LOOP
         IF (a_indice = 1)
         THEN
            loc_retour := adhprt.idpret;
         ELSIF (a_indice = 2)
         THEN
            loc_retour := adhprt.pourc_assure;
         ELSIF (a_indice = 3)
         THEN
            loc_retour := adhprt.majoration;
         END IF;

         EXIT;
      END LOOP;

      RETURN (loc_retour);
   END f_adhe_pret;

   FUNCTION f_inval (
      comm_nosin   IN   NUMBER,
      comm_debut   IN   DATE,
      a_indice     IN   NUMBER
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
      inv          inval%ROWTYPE;
   BEGIN
      FOR inv IN (SELECT   inval.debut, inval.categorie, inval.taux,
                           inval.base_regime, inval.base_autre
                      FROM inval
                     WHERE inval.nosin = comm_nosin
                       AND inval.debut <= comm_debut
                  ORDER BY inval.debut DESC)
      LOOP
         IF (a_indice = 1)
         THEN
            loc_retour := d2j (inv.debut);
         ELSIF (a_indice = 2)
         THEN
            loc_retour := inv.categorie;
         ELSIF (a_indice = 3)
         THEN
            loc_retour := inv.taux;
         ELSIF (a_indice = 4)
         THEN
            loc_retour := inv.base_regime;
         ELSIF (a_indice = 5)
         THEN
            loc_retour := inv.base_autre;
         END IF;

         EXIT;
      END LOOP;

      RETURN (loc_retour);
   END f_inval;

   FUNCTION f_ngroupe (comm_numindiv IN NUMBER, comm_type IN NUMBER)
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT indvs.numindiv
           INTO loc_retour
           FROM indvs
          WHERE numassu = comm_numindiv AND typadr = comm_type;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
            RETURN (loc_retour);
         WHEN TOO_MANY_ROWS
         THEN
            loc_retour := 0;
            RETURN (loc_retour);
      END;

      RETURN (loc_retour);
   END f_ngroupe;

   FUNCTION f_pers_sexe (comm_numindiv IN NUMBER)
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT sexe
           INTO loc_retour
           FROM indvs
          WHERE numindiv = comm_numindiv;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
            RETURN (loc_retour);
      END;

      RETURN (loc_retour);
   END f_pers_sexe;

   FUNCTION f_taux_remun (
      a_tfc        IN   NUMBER,
      a_type_tfc   IN   NUMBER,
      a_etendue    IN   NUMBER,
      a_cle        IN   NUMBER,
      a_debut      IN   DATE DEFAULT NULL,
      a_numbene    IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER
   IS
      loc_retour    NUMBER             := -1;
      loc_numprod   NUMBER;
      loc_idobjet   NUMBER;
      objet_propo   NUMBER;
      loc_cle       NUMBER             := a_cle;
      loc_objet     taux_tfc%ROWTYPE;
      l_debut       DATE               := a_debut;
   BEGIN
      IF (a_tfc = 5 AND a_numbene != 0)
      THEN
         BEGIN
            SELECT taux_remun
              INTO loc_retour
              FROM apporteur
             WHERE etendue = a_etendue
               AND cle = a_cle
               AND TYPE = a_type_tfc
               AND numindiv = a_numbene
               AND a_debut BETWEEN debut AND NVL (fin, a_debut);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_retour := NULL;
            WHEN TOO_MANY_ROWS
            THEN
               loc_retour := NULL;
         END;

         IF (loc_retour IS NOT NULL)
         THEN
            RETURN (loc_retour);
         END IF;
      END IF;

      BEGIN
         IF (a_etendue = 4)
         THEN
            BEGIN
               SELECT numgar, NVL (a_debut, date_adhe)
                 INTO loc_cle, l_debut
                 FROM adhe_cntrt
                WHERE idadhesion = a_cle;
            END;
         ELSIF (a_etendue = 14)
         THEN
            BEGIN
               SELECT idobjet, objet, NVL (a_debut, creation)
                 INTO loc_idobjet, objet_propo, l_debut
                 FROM proposition
                WHERE idpropo = a_cle;
            END;

            IF (loc_idobjet = 2)
            THEN
               loc_cle := objet_propo;
            ELSE
               loc_numprod := objet_propo;
               GOTO saute_numprod;
            END IF;
         END IF;

         BEGIN
            SELECT numprod, NVL (a_debut, dateff)
              INTO loc_numprod, l_debut
              FROM contrat
             WHERE numgar = loc_cle;
         END;

         <<saute_numprod>>
         FOR loc_objet IN (SELECT   taux
                               FROM taux_tfc
                              WHERE numprod = loc_numprod
                                AND tfc = a_tfc
                                AND type_tfc = a_type_tfc
                                AND valide = 'O'
                                AND debut <= l_debut
                           ORDER BY debut DESC)
         LOOP
            loc_retour := loc_objet.taux;
            EXIT;
         END LOOP;
      END;

      IF (loc_retour = -1)
      THEN
         loc_retour := 0;
      END IF;

      RETURN (loc_retour);
   END f_taux_remun;

   FUNCTION f_calcul_unique (
      a_tfc         IN   NUMBER,
      a_type_tfc    IN   NUMBER,
      a_etendue     IN   NUMBER,
      a_cle         IN   NUMBER,
      a_numfor      IN   NUMBER,
      a_numindiv    IN   NUMBER,
      a_debut       IN   DATE,
      a_fin         IN   DATE,
      a_mode_calc   IN   NUMBER DEFAULT 2
   )
      RETURN NUMBER
/* Retourne 1 si calcul deja effectue 0 sinon */
   IS
      loc_retour      NUMBER           := 0;
      loc_numquit     NUMBER;

      CURSOR qttc_1
      IS
         SELECT   numquit
             FROM qttc_global
            WHERE numgar = a_cle
              AND comptant != 'R'
              AND debut NOT BETWEEN a_debut AND a_fin
         ORDER BY debut;

      CURSOR qttc_2
      IS
         SELECT   numquit
             FROM qttc_global
            WHERE idadhesion = a_cle
              AND comptant != 'R'
              AND debut NOT BETWEEN a_debut AND a_fin
         ORDER BY debut;

      fetch_contrat   qttc_1%ROWTYPE;
      fetch_adhe      qttc_2%ROWTYPE;
   BEGIN
/* Si periodique sort tout de suite */
      IF (a_mode_calc = 2)
      THEN
         RETURN (0);
      END IF;

      OPEN qttc_1;

      OPEN qttc_2;

      WHILE (loc_retour = 0)
      LOOP
         IF (a_etendue = 1)
         THEN
            FETCH qttc_1
             INTO loc_numquit;

            EXIT WHEN qttc_1%NOTFOUND;
         ELSE
            FETCH qttc_2
             INTO loc_numquit;

            EXIT WHEN qttc_2%NOTFOUND;
         END IF;

         IF (a_tfc = 1)
         THEN
            BEGIN
               SELECT 1
                 INTO loc_retour
                 FROM DUAL
                WHERE EXISTS (
                         SELECT 1
                           FROM qttc_taxe
                          WHERE qttc_taxe.numquit = loc_numquit
                            AND qttc_taxe.numfor = a_numfor
                            AND qttc_taxe.type_taxe = a_type_tfc
                            AND qttc_taxe.numindiv = a_numindiv);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  loc_retour := 0;
            END;
         ELSIF (a_tfc = 2)
         THEN
            BEGIN
               SELECT 1
                 INTO loc_retour
                 FROM DUAL
                WHERE EXISTS (
                         SELECT 1
                           FROM qttc_comm
                          WHERE qttc_comm.numquit = loc_numquit
                            AND qttc_comm.numfor = a_numfor
                            AND qttc_comm.type_comm = a_type_tfc
                            AND qttc_comm.numindiv = a_numindiv);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  loc_retour := 0;
            END;
         ELSIF (a_tfc = 3)
         THEN
            BEGIN
               SELECT 1
                 INTO loc_retour
                 FROM DUAL
                WHERE EXISTS (
                         SELECT 1
                           FROM qttc_frais
                          WHERE qttc_frais.numquit = loc_numquit
                            AND qttc_frais.numfor = a_numfor
                            AND qttc_frais.type_frais = a_type_tfc
                            AND qttc_frais.numindiv = a_numindiv);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  loc_retour := 0;
            END;
         ELSIF (a_tfc = 4)
         THEN
            BEGIN
               SELECT 1
                 INTO loc_retour
                 FROM DUAL
                WHERE EXISTS (
                         SELECT 1
                           FROM qttc_frais
                          WHERE qttc_frais.numquit = loc_numquit
                            AND qttc_frais.type_frais = a_type_tfc
                            AND numfor = 0);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  loc_retour := 0;
            END;
         ELSIF (a_tfc = 5)
         THEN

    BEGIN
               SELECT 1
                 INTO loc_retour
                 FROM DUAL
                WHERE EXISTS (
                         SELECT 1
                           FROM qttc_retro
                          WHERE qttc_retro.numquit = loc_numquit
                            AND qttc_retro.numfor = a_numfor
                            AND qttc_retro.type_comm = a_type_tfc
                            AND qttc_retro.numindiv = a_numindiv);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  loc_retour := 0;
            END;
         END IF;
      END LOOP;

      CLOSE qttc_1;

      CLOSE qttc_2;

      RETURN (loc_retour);
   END f_calcul_unique;

   FUNCTION f_arrondi (a_codope IN NUMBER, a_cle IN NUMBER, a_montant IN NUMBER)
      RETURN NUMBER
   IS
      loc_niveau    NUMBER;
      loc_arrondi   NUMBER;
      loc_cle       NUMBER;
   BEGIN
      IF (a_codope = 4)
      THEN
         loc_cle := f_numgar (a_codope, a_cle);

         BEGIN
            SELECT NVL (arrondi, 1)
              INTO loc_arrondi
              FROM contrat
             WHERE numgar = loc_cle;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_arrondi := 2;
         END;
      END IF;

      SELECT DECODE (loc_arrondi, 1, 2, 2, 1, 3, 0, 4, -1, 5, -2)
        INTO loc_niveau
        FROM DUAL;

      RETURN (ROUND (a_montant, loc_niveau));
   END f_arrondi;

   FUNCTION f_tab2 (
      a_tableau   IN   NUMBER,
      a_cle1      IN   NUMBER,
      a_cle2      IN   NUMBER,
      a_date      IN   DATE
   )
      RETURN NUMBER
   IS
      loc_valeur   NUMBER;
   BEGIN
      -- PHA 22/12/2017 calcul de puissance
      BEGIN
        -- fonction tab2 détournée pour calcul de puissance
        IF a_tableau = -1000 THEN
          SELECT POWER(a_cle1, a_cle2) INTO loc_valeur FROM dual;
          RETURN (loc_valeur);
        END IF;
      END;

      BEGIN

/* Valeurs par cles exactes */
         SELECT valeur
           INTO loc_valeur
           FROM tableau_double, lib_tableau
          WHERE tableau_double.idtableau = lib_tableau.idtableau
            AND TO_NUMBER (tableau_double.clef1) = ROUND (a_cle1, 2)
            AND TO_NUMBER (tableau_double.clef2) = ROUND (a_cle2, 2)
            AND lib_tableau.tableau = TO_CHAR (a_tableau)
            AND a_date BETWEEN NVL (lib_tableau.debut, a_date)
                           AND NVL (lib_tableau.fin, a_date)
            AND lib_tableau.type_tableau = 2
            AND lib_tableau.TYPE = 1;

         RETURN (loc_valeur);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
/* Valeurs par intervalles inferieurs --> cle1 */
               SELECT a.valeur
                 INTO loc_valeur
                 FROM tableau_double a, lib_tableau
                WHERE a.clef1 =
                         (SELECT MAX (TO_NUMBER (b.clef1))
                            FROM tableau_double b, lib_tableau
                           WHERE b.idtableau = lib_tableau.idtableau
                             AND TO_NUMBER (b.clef1) <= ROUND (a_cle1, 2)
                             AND TO_NUMBER (b.clef2) = ROUND (a_cle2, 2)
                             AND lib_tableau.tableau = TO_CHAR (a_tableau)
                             AND a_date BETWEEN NVL (lib_tableau.debut,
                                                     a_date)
                                            AND NVL (lib_tableau.fin, a_date)
                             AND lib_tableau.type_tableau = 2
                             AND lib_tableau.TYPE = 2)
                  AND a.clef2 = ROUND (a_cle2, 2)
                  AND lib_tableau.tableau = TO_CHAR (a_tableau)
                  AND a.idtableau = lib_tableau.idtableau
                  AND a_date BETWEEN NVL (lib_tableau.debut, a_date)
                                 AND NVL (lib_tableau.fin, a_date)
                  AND lib_tableau.type_tableau = 2
                  AND lib_tableau.TYPE = 2;

               RETURN (loc_valeur);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
/* Valeurs par intervalles inferieurs --> cle2 */
                     SELECT a.valeur
                       INTO loc_valeur
                       FROM tableau_double a, lib_tableau
                      WHERE a.clef2 =
                               (SELECT MAX (TO_NUMBER (b.clef2))
                                  FROM tableau_double b, lib_tableau
                                 WHERE b.idtableau = lib_tableau.idtableau
                                   AND TO_NUMBER (b.clef2) <=
                                                             ROUND (a_cle2, 2)
                                   AND TO_NUMBER (b.clef1) = ROUND (a_cle1, 2)
                                   AND lib_tableau.tableau =
                                                           TO_CHAR (a_tableau)
                                   AND a_date BETWEEN NVL (lib_tableau.debut,
                                                           a_date
                                                          )
                                                  AND NVL (lib_tableau.fin,
                                                           a_date
                                                          )
                                   AND lib_tableau.type_tableau = 2
                                   AND lib_tableau.TYPE = 4)
                        AND a.clef1 = ROUND (a_cle1, 2)
                        AND lib_tableau.tableau = TO_CHAR (a_tableau)
                        AND a.idtableau = lib_tableau.idtableau
                        AND a_date BETWEEN NVL (lib_tableau.debut, a_date)
                                       AND NVL (lib_tableau.fin, a_date)
                        AND lib_tableau.type_tableau = 2
                        AND lib_tableau.TYPE = 4;

                     RETURN (loc_valeur);
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        BEGIN
/* Valeurs par intervalles superieurs --> cle1 */
                           SELECT a.valeur
                             INTO loc_valeur
                             FROM tableau_double a, lib_tableau
                            WHERE a.clef1 =
                                     (SELECT MIN (TO_NUMBER (b.clef1))
                                        FROM tableau_double b, lib_tableau
                                       WHERE b.idtableau =
                                                         lib_tableau.idtableau
                                         AND TO_NUMBER (b.clef1) >=
                                                             ROUND (a_cle1, 2)
                                         AND TO_NUMBER (b.clef2) =
                                                             ROUND (a_cle2, 2)
                                         AND lib_tableau.tableau =
                                                           TO_CHAR (a_tableau)
                                         AND a_date
                                                BETWEEN NVL
                                                           (lib_tableau.debut,
                                                            a_date
                                                           )
                                                    AND NVL (lib_tableau.fin,
                                                             a_date
                                                            )
                                         AND lib_tableau.type_tableau = 2
                                         AND lib_tableau.TYPE = 3)
                              AND a.clef2 = ROUND (a_cle2, 2)
                              AND lib_tableau.tableau = TO_CHAR (a_tableau)
                              AND a.idtableau = lib_tableau.idtableau
                              AND a_date BETWEEN NVL (lib_tableau.debut,
                                                      a_date
                                                     )
                                             AND NVL (lib_tableau.fin, a_date)
                              AND lib_tableau.type_tableau = 2
                              AND lib_tableau.TYPE = 3;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              BEGIN
/* Valeurs par intervalles superieurs --> cle2 */
                                 SELECT a.valeur
                                   INTO loc_valeur
                                   FROM tableau_double a, lib_tableau
                                  WHERE a.clef2 =
                                           (SELECT MIN (TO_NUMBER (b.clef2))
                                              FROM tableau_double b,
                                                   lib_tableau
                                             WHERE b.idtableau =
                                                         lib_tableau.idtableau
                                               AND TO_NUMBER (b.clef2) >=
                                                             ROUND (a_cle2, 2)
                                               AND TO_NUMBER (b.clef1) =
                                                             ROUND (a_cle1, 2)
                                               AND lib_tableau.tableau =
                                                           TO_CHAR (a_tableau)
                                               AND a_date
                                                      BETWEEN NVL
                                                                (lib_tableau.debut,
                                                                 a_date
                                                                )
                                                          AND NVL
                                                                (lib_tableau.fin,
                                                                 a_date
                                                                )
                                               AND lib_tableau.type_tableau =
                                                                             2
                                               AND lib_tableau.TYPE = 5)
                                    AND a.clef1 = ROUND (a_cle1, 2)
                                    AND lib_tableau.tableau =
                                                           TO_CHAR (a_tableau)
                                    AND a.idtableau = lib_tableau.idtableau
                                    AND a_date BETWEEN NVL (lib_tableau.debut,
                                                            a_date
                                                           )
                                                   AND NVL (lib_tableau.fin,
                                                            a_date
                                                           )
                                    AND lib_tableau.type_tableau = 2
                                    AND lib_tableau.TYPE = 5;

                                 RETURN (loc_valeur);
                              END;
                        END;
                  END;
            END;
      END;

      RETURN (loc_valeur);
   END f_tab2;

   FUNCTION f_acte_conso (
      i_numindiv     IN   NUMBER,
      i_idadhesion   IN   NUMBER,
      i_numfor       IN   NUMBER,
      i_nature       IN   NUMBER,
      i_codfrais     IN   VARCHAR2,
                     -- suivant nature :   1=acte, 2-fam, 3=numéro de garantie
      i_debut        IN   DATE,
      i_fin          IN   DATE,
      i_etendue      IN   NUMBER DEFAULT 0,
      i_type         IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      CURSOR c_conso
      IS
         SELECT NVL (SUM (DECODE (frmls.flag_regime, 'C', nbacte, 0)),
                     0
                    ) nbacte,
                NVL (SUM (mtreel), 0) mtreel,
                NVL (SUM (DECODE (frmls.flag_regime, 'C', mtfrais, 0)),
                     0
                    ) mtfrais
           FROM sinistre, frmls, natfrais
          WHERE pk_qttc.f_sel_numfor (sinistre.numgar, sinistre.numfor) =
                                                                 frmls.numfor
            AND sinistre.codfrais = natfrais.codfrais
            AND sinistre.numindiv =
                          DECODE (i_etendue,
                                  0, i_numindiv,
                                  sinistre.numindiv
                                 )
            AND sinistre.numassu =
                   DECODE (i_etendue,
                           1, f_numassu (i_numindiv, i_idadhesion),
                           sinistre.numassu
                          )
            AND sinistre.codfrais =
                           DECODE (i_nature,
                                   0, i_codfrais,
                                   sinistre.codfrais
                                  )
            AND natfrais.rubrique =
                           DECODE (i_nature,
                                   1, i_codfrais,
                                   natfrais.rubrique
                                  )
            AND sinistre.numfor =
                   i_numfor
-- JPF 09/05/2005 sinistre.numfor   = decode(I_nature, 2, I_codfrais,I_numfor)  --JPF 02/05/2004 AND    sinistre.numfor   = I_numfor
            AND datsin BETWEEN i_debut AND i_fin
         UNION
         SELECT NVL (SUM (DECODE (frmls.flag_regime, 'C', nbacte, 0)),
                     0
                    ) nbacte,
                NVL (SUM (mtreel), 0) mtreel,
                NVL (SUM (DECODE (frmls.flag_regime, 'C', mtfrais, 0)),
                     0
                    ) mtfrais
           FROM travsn, frmls, natfrais
          WHERE pk_qttc.f_sel_numfor (travsn.numgar, travsn.numpopu) =
                                                                  frmls.numfor
            AND travsn.codfrais = natfrais.codfrais
            AND travsn.numindiv =
                            DECODE (i_etendue,
                                    0, i_numindiv,
                                    travsn.numindiv
                                   )
            AND travsn.numassu =
                   DECODE (i_etendue,
                           1, f_numassu (i_numindiv, i_idadhesion),
                           travsn.numassu
                          )
            AND travsn.codfrais =
                             DECODE (i_nature,
                                     0, i_codfrais,
                                     travsn.codfrais
                                    )
            AND natfrais.rubrique =
                           DECODE (i_nature,
                                   1, i_codfrais,
                                   natfrais.rubrique
                                  )
            AND travsn.numpopu =
                   i_numfor
-- JPF 09/05/2005 travsn.numpopu   = decode(I_nature, 2, I_codfrais,I_numfor)  -- JPF 02/05/2004 AND    travsn.numpopu   = I_numfor
            AND datsin BETWEEN i_debut AND i_fin;

      rec_c_conso   c_conso%ROWTYPE;
      l_conso       NUMBER            := 0;
   BEGIN
      OPEN c_conso;

      LOOP
         FETCH c_conso
          INTO rec_c_conso;

         EXIT WHEN c_conso%NOTFOUND;

         IF (i_type = 1)
         THEN
            IF (rec_c_conso.nbacte != 0)
            THEN
               l_conso := l_conso + rec_c_conso.nbacte;
            END IF;
         ELSIF (i_type = 2)
         THEN
            IF (rec_c_conso.mtreel != 0)
            THEN
               l_conso := l_conso + rec_c_conso.mtreel;
            END IF;
         ELSIF (i_type = 3)
         THEN
            IF (rec_c_conso.mtfrais != 0)
            THEN
               l_conso := l_conso + rec_c_conso.mtfrais;
            END IF;
         END IF;
      END LOOP;

      CLOSE c_conso;

      RETURN (l_conso);
   END f_acte_conso;

   FUNCTION f_appel_unique (
      i_mode_calcul   IN   NUMBER,
      i_type_qttc     IN   NUMBER,
      i_numgar        IN   qttc_global.numgar%TYPE,
      i_idadhesion    IN   qttc_global.idadhesion%TYPE
   )
      RETURN NUMBER
   IS
      CURSOR c_contrat
      IS
         SELECT numquit
           FROM qttc_global
          WHERE numgar = i_numgar AND comptant != 'R';

      CURSOR c_adhesion
      IS
         SELECT numquit
           FROM qttc_global
          WHERE idadhesion = i_idadhesion AND comptant != 'R';

      rec_c_contrat    c_contrat%ROWTYPE;
      rec_c_adhesion   c_adhesion%ROWTYPE;
      l_retour         NUMBER               := 0;
   BEGIN
      IF (i_mode_calcul = 1)
      THEN
         IF (i_type_qttc = 1)
         THEN
            OPEN c_contrat;

            FETCH c_contrat
             INTO rec_c_contrat;

            IF (c_contrat%FOUND)
            THEN
               l_retour := 1;
            END IF;

            CLOSE c_contrat;
         ELSE
            OPEN c_adhesion;

            FETCH c_adhesion
             INTO rec_c_adhesion;

            IF (c_adhesion%FOUND)
            THEN
               l_retour := 1;
            END IF;

            CLOSE c_adhesion;
         END IF;
      END IF;

      RETURN (l_retour);
   END f_appel_unique;

   FUNCTION f_code_reass (i_numfor IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_prev
      IS
         SELECT code_reass
           FROM garanties
          WHERE numfor = i_numfor;

      CURSOR c_sante
      IS
         SELECT code_reass
           FROM formule
          WHERE numfor = i_numfor;

      l_retour   NUMBER;
   BEGIN
      OPEN c_prev;

      FETCH c_prev
       INTO l_retour;

      IF (c_prev%NOTFOUND)
      THEN
         OPEN c_sante;

         FETCH c_sante
          INTO l_retour;

         CLOSE c_sante;
      END IF;

      CLOSE c_prev;

      RETURN (l_retour);
   END f_code_reass;

--
   FUNCTION f_sel_cotis_annuelle (
      i_numgar       IN   qttc_global.numgar%TYPE,
      i_idadhesion   IN   qttc_global.idadhesion%TYPE,
      i_numfor       IN   qttc_gar.numfor%TYPE,
      i_debut        IN   qttc_global.debut%TYPE
   )
      RETURN NUMBER
   IS
      loc_retour    NUMBER;

      CURSOR c_cotis_adhesion
      IS
         SELECT SUM (pk_funct.f_arrondi (4, qttc_gar.numquit, qttc_gar.mt_ttc)
                    ) montant,
                MIN (qttc_global.numquit) numquit,
                MIN (qttc_global.debut) debut, MAX (qttc_global.fin) fin
           FROM qttc_global, qttc_gar
          WHERE qttc_global.idadhesion = i_idadhesion
            AND qttc_global.debut BETWEEN TRUNC (i_debut, 'Y')
                                      AND   ADD_MONTHS (TRUNC (i_debut, 'Y'),
                                                        12
                                                       )
                                          - 1
            AND qttc_global.comptant != 'R'
            AND qttc_gar.numquit = qttc_global.numquit
            AND qttc_gar.numfor = i_numfor;

      CURSOR c_cotis_contrat
      IS
         SELECT SUM (pk_funct.f_arrondi (4, qttc_gar.numquit, qttc_gar.mt_ttc)
                    ) montant,
                MIN (qttc_global.numquit) numquit,
                MIN (qttc_global.debut) debut, MAX (qttc_global.fin) fin
           FROM qttc_global, qttc_gar
          WHERE qttc_global.numgar = i_numgar
            AND qttc_global.debut BETWEEN TRUNC (i_debut, 'Y')
                                      AND   ADD_MONTHS (TRUNC (i_debut, 'Y'),
                                                        12
                                                       )
                                          - 1
            AND qttc_global.comptant != 'R'
            AND qttc_gar.numquit = qttc_global.numquit
            AND qttc_gar.numfor = i_numfor;

      rec_c_cotis   c_cotis_adhesion%ROWTYPE;
   BEGIN
--
      IF (i_idadhesion != 0)
      THEN
         OPEN c_cotis_adhesion;

         FETCH c_cotis_adhesion
          INTO rec_c_cotis;
      ELSE
         OPEN c_cotis_contrat;

         FETCH c_cotis_contrat
          INTO rec_c_cotis;
      END IF;

--
      loc_retour :=
           rec_c_cotis.montant
         / f_prorata (d2j (rec_c_cotis.debut), d2j (rec_c_cotis.fin))
         * 12;
      loc_retour := pk_funct.f_arrondi (4, rec_c_cotis.numquit, loc_retour);

--
      IF (i_idadhesion != 0)
      THEN
         CLOSE c_cotis_adhesion;
      ELSE
         CLOSE c_cotis_contrat;
      END IF;

--
      RETURN (loc_retour);
   END f_sel_cotis_annuelle;

--
-- Montant des capitaux verses par adherent / garantie sur la periode reassure
--
   FUNCTION f_sel_base_prev (
      i_idadhesion   IN   repartition.idadhesion%TYPE,
      i_numfor       IN   repartition.numfor%TYPE,
      i_debut        IN   DATE,
      i_fin          IN   DATE
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;

      CURSOR c_base_prev
      IS
         SELECT SUM (NVL (decaismt.montant, 0)) montant
           FROM repartition, histo_calcul, affectation, decaismt
          WHERE repartition.idadhesion = i_idadhesion
            AND repartition.numfor = i_numfor
            AND repartition.idrepartition = histo_calcul.idrepartition
            AND affectation.codope = 2
            AND affectation.numaffec = histo_calcul.numdec
            AND affectation.numdecaismt = decaismt.numdecaismt + 0
            AND decaismt.flagpay = 1
            AND decaismt.datpay BETWEEN i_debut AND i_fin;
   BEGIN
      OPEN c_base_prev;

      FETCH c_base_prev
       INTO loc_retour;

      CLOSE c_base_prev;

      RETURN (loc_retour);
   END f_sel_base_prev;

--
   FUNCTION f_pays_soins (comm_pays_soins IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN (comm_pays_soins);
   END f_pays_soins;

--
   FUNCTION f_pays_nat (comm_numindiv IN NUMBER)
      RETURN NUMBER
   IS
      num_nat   NUMBER;
   BEGIN
      SELECT codpays
        INTO num_nat
        FROM indvs
       WHERE numindiv = comm_numindiv;

      IF num_nat IS NULL
      THEN
         num_nat := 0;
      END IF;

      RETURN (num_nat);
   END f_pays_nat;

   FUNCTION f_accord (i_num_dossier IN dossier_sante.num_dossier%TYPE)
      RETURN NUMBER
   IS
      CURSOR cur_ds
      IS
         SELECT pec
           FROM dossier_sante
          WHERE i_num_dossier = num_dossier;

      rec_ds   cur_ds%ROWTYPE;
   BEGIN
      OPEN cur_ds;

      FETCH cur_ds
       INTO rec_ds;

      IF cur_ds%NOTFOUND
      THEN
         RETURN (0);
      ELSE
         IF rec_ds.pec = 1
         THEN
            RETURN (1);
         ELSE
            RETURN (0);
         END IF;
      END IF;

      --
      CLOSE cur_ds;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (0);
   END f_accord;

   FUNCTION f_d_doss (i_num_dossier IN dossier_sante.num_dossier%TYPE)
      RETURN DATE
   IS
      CURSOR cur_ds
      IS
         SELECT dateouv
           FROM dossier_sante
          WHERE i_num_dossier = num_dossier;

      rec_ds   cur_ds%ROWTYPE;
   BEGIN
      OPEN cur_ds;

      FETCH cur_ds
       INTO rec_ds;

      IF cur_ds%NOTFOUND
      THEN
         RETURN (NULL);
      ELSE
         RETURN (rec_ds.dateouv);
      END IF;

      --
      CLOSE cur_ds;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (NULL);
   END f_d_doss;

   FUNCTION f_dp_f (
      i_num_dossier   IN   sinistre_sante.num_dossier%TYPE,
      i_numligne      IN   sinistre_sante.numligne%TYPE
   )
      RETURN DATE
   IS
      CURSOR cur_ss
      IS
         SELECT datsin_fin, datsin
           FROM sinistre_sante
          WHERE i_num_dossier = num_dossier AND i_numligne = numligne;

      rec_ss   cur_ss%ROWTYPE;
   BEGIN
      OPEN cur_ss;

      FETCH cur_ss
       INTO rec_ss;

      IF cur_ss%NOTFOUND
      THEN
         RETURN (NULL);
      ELSE
         IF rec_ss.datsin_fin IS NOT NULL
         THEN
            RETURN (rec_ss.datsin_fin);
         ELSE
            RETURN (rec_ss.datsin);
         END IF;
      END IF;

      --
      CLOSE cur_ss;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (NULL);
   END f_dp_f;

   FUNCTION f_p_reseau (i_num_dossier IN dossier_sante.num_dossier%TYPE)
      RETURN NUMBER
   IS
      CURSOR cur_ds
      IS
         SELECT type_doss
           FROM dossier_sante
          WHERE i_num_dossier = num_dossier;

      rec_ds   cur_ds%ROWTYPE;
   BEGIN
      OPEN cur_ds;

      FETCH cur_ds
       INTO rec_ds;

      IF cur_ds%NOTFOUND
      THEN
         RETURN (0);
      ELSE
         IF rec_ds.type_doss = 2
         THEN
            RETURN (1);
         ELSE
            RETURN (0);
         END IF;
      END IF;

      --
      CLOSE cur_ds;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (0);
   END f_p_reseau;

   FUNCTION f_p_typelt (
      i_num_dossier   IN   sinistre_sante.num_dossier%TYPE,
      i_numligne      IN   sinistre_sante.numligne%TYPE
   )
      RETURN NUMBER
   IS
      CURSOR cur_ss
      IS
         SELECT typ_elt
           FROM sinistre_sante
          WHERE i_num_dossier = num_dossier AND i_numligne = numligne;

      rec_ss   cur_ss%ROWTYPE;
   BEGIN
      OPEN cur_ss;

      FETCH cur_ss
       INTO rec_ss;

      IF cur_ss%NOTFOUND
      THEN
         RETURN (0);
      ELSE
         RETURN (rec_ss.typ_elt);
      END IF;

      --
      CLOSE cur_ss;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (0);
   END f_p_typelt;

   FUNCTION f_p_elt (
      i_num_dossier   IN   sinistre_sante.num_dossier%TYPE,
      i_numligne      IN   sinistre_sante.numligne%TYPE
   )
      RETURN NUMBER
   IS
      CURSOR cur_ss
      IS
         SELECT TO_NUMBER (NVL (elt_corp, 0)) elt
           FROM sinistre_sante
          WHERE i_num_dossier = num_dossier AND i_numligne = numligne;

      rec_ss   cur_ss%ROWTYPE;
   BEGIN
      OPEN cur_ss;

      FETCH cur_ss
       INTO rec_ss;

      IF cur_ss%NOTFOUND
      THEN
         RETURN (0);
      ELSE
         RETURN (rec_ss.elt);
      END IF;

      --
      CLOSE cur_ss;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (0);
   END f_p_elt;
END pk_funct;
/
