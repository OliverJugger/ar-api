CREATE PROCEDURE ARTHUS.CHARGE_PREV (a_nosin IN NUMBER, t_donnee OUT pk_texte.donnee)
IS

  -- Mantis n°3142 : Récupération d'information dans la table des Saisies d'Arrêt
  --ABO Capra /Gerep récupération de la date de prise en charge en 22
  s_LST_PERIOD_NS   VARCHAR2(4000);
  s_MASK_LST_PERIOD VARCHAR2(64);
  s_Paragraphe      VARCHAR2(4000);
  l_gest_calc       NUMBER(3);
  l_test            NUMBER(1);

  t_texte pk_texte.donnee;
  nb NUMBER :=0;
  -- PHA ajout distinct p.numligne, dans les 2 curseurs, car si il y a plusieurs bénéficiares valides, les lignes étaient multipliées.
  CURSOR C_postit_prest(p_nosin in NUMBER) IS
  SELECT distinct p.numligne, p.TEXTE
  FROM POST_IT p, repartition r , frml_prest f , repartition_bene b
  WHERE p.etendue = 14
  AND r.nosin = p_nosin
  AND r.valide='O'
  AND NVL(r.gest_calc,2) = 1
  AND r.idrepartition = b.idrepartition
  AND b.valide='O'
  AND f.numfor = r.numfor
  AND f.valide = 'O'
  AND p.clef = f.idformule
  AND f.debut in (SELECT max(debut) FROM frml_prest fp WHERE fp.numfor=r.numfor AND fp.valide='O')
  AND b.debut in (SELECT max(debut) FROM repartition_bene rb WHERE rb.idrepartition = b.idrepartition AND rb.valide='O')
  ORDER BY p.numligne;


  CURSOR C_postit_reval(p_nosin in NUMBER) IS
  SELECT distinct p.numligne, p.TEXTE
  FROM POST_IT p, repartition r , frml_reval f , repartition_bene b
  WHERE p.etendue = 14
  AND r.nosin = p_nosin
  AND r.valide='O'
  AND NVL(r.gest_calc,2) = 1
  AND r.idrepartition = b.idrepartition
  AND b.valide='O'
  AND f.numfor = r.numfor
  AND f.valide = 'O'
  AND p.clef = f.idformule
  AND f.debut in (SELECT max(debut) FROM frml_reval fp WHERE fp.numfor=r.numfor AND fp.valide='O')
  AND b.debut in (SELECT max(debut) FROM repartition_bene rb WHERE rb.idrepartition = b.idrepartition AND rb.valide='O')
  ORDER BY p.numligne;

BEGIN

   SELECT sin_prev.nosin, sin_prev.iddossier, d2e (survenance),
          d2e (declaration),
          SUBSTR (pk_libelle.f_lib ('RISQ', norisq), 1, 30),
          SUBSTR (pk_libelle.f_lib ('CAUS', cause), 1, 30),
          pk_personne.f_nom (sin_prev.idcorres), util.pseudo,
          sin_prev.numclot, d2e (sin_prev.creation), d2e (sin_prev.maj),
          d2e (sin_prev.fin),
          SUBSTR (pk_libelle.f_lib ('MOTIF', motif), 1, 30),
          to_char(prischarge,'dd/mm/yyyy')
     INTO t_donnee (1), t_donnee (2), t_donnee (3),
          t_donnee (4),
          t_donnee (5),
          t_donnee (6),
          t_donnee (7), t_donnee (8),
          t_donnee (9), t_donnee (10), t_donnee (11),
          t_donnee (12),
          t_donnee (13),
            t_donnee (22)
     FROM sntr_prev sin_prev, util
    WHERE sin_prev.nosin = a_nosin AND sin_prev.numutil = util.numutil;

    -- Mantis n°3142 : Récupération de la Date de Début, Fin et Etat de la plus récente période saisie
    BEGIN
      -- PHA Mantis 4493 afficher les périodes en fonction du type de garantie DELEG/Hors DELEG
      SELECT NVL(MAX(gest_calc),2) INTO l_gest_calc
          FROM repartition
          WHERE nosin  = a_nosin
            AND valide ='O' ;

      IF l_gest_calc = 2 THEN
        SELECT D2E(Debut), D2E(Fin), Etat
          INTO t_donnee (14), t_donnee (15), t_donnee (16)
        FROM (
          SELECT DEBUT As Debut, FIN As Fin, PK_LIBELLE.f_lib('ETA_ARR_RG',ETAT) As Etat
          FROM DELEG_ARRET
          WHERE NOSIN= a_nosin
          ORDER BY D2J(FIN) DESC, D2J(RECEPTION) DESC, IDARRET DESC --KLA
        ) WHERE ROWNUM = 1;
      ELSE
        SELECT D2E(Debut), D2E(Fin), Etat
          INTO t_donnee (14), t_donnee (15), t_donnee (16)
        FROM (
          SELECT DEBUT As Debut, FIN As Fin, decode(TRAITE,'O', 'Traité', 'N', 'Non traité') As Etat
          FROM ARRET
          WHERE NOSIN= a_nosin
          ORDER BY D2J(FIN) DESC, D2J(RECEPTION) DESC, IDARRET DESC
        ) WHERE ROWNUM = 1;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        t_donnee (14) := NULL;
        t_donnee (15) := NULL;
        t_donnee (16) := NULL;
    END;

    -- Mantis n°3142 : #SIN(17) - Récupération d'une liste de période non-soldé (ETAT=1)
    BEGIN
      s_LST_PERIOD_NS := '';

      SELECT t.TEXTE INTO s_MASK_LST_PERIOD FROM TEXTE t, PARAM_TEXTE p WHERE t.IDTEXTE=p.IDTEXTE AND p.NOM_CRRR ='MSK_SIN17' AND NUMLIGNE = (SELECT MAX(NUMLIGNE) FROM TEXTE WHERE IDTEXTE = t.IDTEXTE);

      IF l_gest_calc = 0 THEN
        FOR r_PERIOD_NS IN (SELECT REPLACE(REPLACE(s_MASK_LST_PERIOD,'@1',D2E(DEBUT)),'@2',D2E(FIN)) AS "PERIODE" FROM DELEG_ARRET WHERE NOSIN= a_nosin AND ETAT = 1 ORDER BY IDARRET ASC)
        LOOP
            s_LST_PERIOD_NS := s_LST_PERIOD_NS || r_PERIOD_NS.PERIODE || CHR(10);
        END LOOP;
      ELSE
        FOR r_PERIOD_NS IN (SELECT REPLACE(REPLACE(s_MASK_LST_PERIOD,'@1',D2E(DEBUT)),'@2',D2E(FIN)) AS "PERIODE" FROM ARRET WHERE NOSIN= a_nosin AND TRAITE = 'N' ORDER BY IDARRET ASC)
        LOOP
            s_LST_PERIOD_NS := s_LST_PERIOD_NS || r_PERIOD_NS.PERIODE || CHR(10);
        END LOOP;
      END IF;

      IF TRIM(s_LST_PERIOD_NS) IS NULL THEN
        s_LST_PERIOD_NS := NULL;
      ELSE
       -- SELECT s_LST_PERIOD_NS||CHR(10)||t.TEXTE INTO s_LST_PERIOD_NS FROM TEXTE t, PARAM_TEXTE p WHERE t.IDTEXTE=p.IDTEXTE AND p.NOM_CRRR ='MSK_SIN17' AND NUMLIGNE = (SELECT MIN(NUMLIGNE) FROM TEXTE WHERE IDTEXTE = t.IDTEXTE);
        SELECT t.TEXTE||CHR(10)||s_LST_PERIOD_NS INTO s_LST_PERIOD_NS FROM TEXTE t, PARAM_TEXTE p WHERE t.IDTEXTE=p.IDTEXTE AND p.NOM_CRRR ='MSK_SIN17' AND NUMLIGNE = (SELECT MIN(NUMLIGNE) FROM TEXTE WHERE IDTEXTE = t.IDTEXTE);
      END IF;

      t_donnee (17) := s_LST_PERIOD_NS;
    EXCEPTION
      WHEN OTHERS THEN t_donnee (17) := NULL;
    END;
    --t_donnee (17) := NVL(t_donnee (17),'aucune période non-soldé');

    -- #SIN(18) - Récupération de la Date de Début de la plus ancienne (première) période saisie
    BEGIN
      SELECT D2E(Debut)
        INTO t_donnee (18)
      FROM (
        SELECT DEBUT As Debut
              FROM DELEG_ARRET
                    WHERE NOSIN= a_nosin
                    ORDER BY D2J(DEBUT) ASC
            ) WHERE ROWNUM = 1;

    EXCEPTION
      WHEN OTHERS THEN
        t_donnee (18) := NULL;
    END;

   --ABO ajout du descriptif de formule de calcul de prest et revalo   projet gerep prévoyance
  FOR nb in 22..33 LOOP
   t_donnee(nb):='';
  END LOOP;

  BEGIN
    nb:=0;

    FOR R_postit_prest IN C_postit_prest(a_nosin) LOOP
      nb:=nb+1;
      EXIT WHEN nb=8;
      t_donnee(22+nb) := R_postit_prest.texte;

    END LOOP;

    nb:=0;
    FOR R_postit_reval IN C_postit_reval(a_nosin) LOOP
      nb:=nb+1;
      EXIT WHEN nb=4;
      t_donnee(29+nb) := R_postit_reval.texte;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;


  --ABO recherche type de franchise dans gar_prev
  BEGIN
    SELECT  f_lble('TYPE_FRAN',type_fran ) INTO t_donnee (33)
    FROM repartition r, gar_prev g
    WHERE r.nosin = a_nosin
    AND r.numfor = g.numfor
    AND r.valide='O' ;
  EXCEPTION
    WHEN OTHERS THEN t_donnee (33):=''; --si on a plusieurs garanties validées pour un sinistre
  END;


  --PHA paragraphe spécifique invalidité
  l_test := 0;
  SELECT 1 INTO l_test FROM DUAL WHERE UPPER(t_donnee (5)) IN ('DECES', UPPER('décès'))
  UNION
  SELECT 0 FROM DUAL WHERE UPPER(t_donnee (5)) NOT IN ('DECES', UPPER('décès'));
  BEGIN
    s_Paragraphe:='';

    IF l_test = 0 THEN
      FOR r_PARAG IN (SELECT t.TEXTE FROM TEXTE t, PARAM_TEXTE p WHERE t.IDTEXTE=p.IDTEXTE AND p.NOM_CRRR ='MSK_SIN34' ORDER BY NUMLIGNE)
            LOOP
                s_Paragraphe := s_Paragraphe || r_PARAG.TEXTE || CHR(10);
            END LOOP;
    END IF;
    t_donnee (34):=s_Paragraphe;
  EXCEPTION
    WHEN OTHERS THEN t_donnee (34):='';
  END;

  --PHA paragraphe spécifique rente suite décès
  BEGIN
    s_Paragraphe:='';
    IF l_test = 1 THEN
      FOR r_PARAG IN (SELECT t.TEXTE FROM TEXTE t, PARAM_TEXTE p WHERE t.IDTEXTE=p.IDTEXTE AND p.NOM_CRRR ='MSK_SIN35' ORDER BY NUMLIGNE)
            LOOP
                s_Paragraphe := s_Paragraphe || r_PARAG.TEXTE || CHR(10);
            END LOOP;
    END IF;
    t_donnee (35):=s_Paragraphe;
  EXCEPTION
    WHEN OTHERS THEN t_donnee (35):='';
  END;

END;
/
