CREATE PROCEDURE ARTHUS.P_REPRISE_SIN_PREV_SAL_AN_MOY (p_ref in varchar2,
							 p_date date,
							 p_salbrut in varchar2,
							 p_basej varchar2,
							 p_revaloj varchar2,
							 p_ta varchar2,
							 p_tb varchar2,
							 p_salnet varchar2,
							 p_nbenf varchar2,
							 p_maintien varchar2,
							 p_libfor varchar2
               -- , p_NomDeMaGarantie varchar2
							 ) IS
--pdate_dernier jour indemnisé +1
--1ère étape création de la couverture identique à celle de l'incapacité déjà existente en fonction du numéro de dossier
--2ème étape création de la répartition sur la nouvelle garantie pour le sinistre

--pdate_dernier jour indemnisé +1

	v_numindiv individu.numindiv%TYPE;
	v_idadhesion adhesion.idadhesion%TYPE;
	v_numfor adhesion.numfor%TYPE;
    v_numgar  contrat_ref.numgar%TYPE;
	v_numcli contrat_ref.numcli%TYPE;
	v_numfor_calc adhesion.numfor%TYPE;
	v_idrepartition repartition.idrepartition%TYPE;
    v_idrepartition_old repartition.idrepartition%TYPE;
	v_nosin sntr_prev.nosin%TYPE;
	v_surv sntr_prev.survenance%TYPE;
	R_ARRET DELEG_ARRET%ROWTYPE;
    v_frml frml_prest.idformule%TYPE;

	exc_fin exception;



BEGIN

	--recherche de l'assuré par référence ext de sinistre
	BEGIN
		SELECT d.numindiv,s.nosin, s.survenance  INTO v_numindiv, v_nosin ,v_surv
		FROM dossier_sinistre d , sntr_prev s
		WHERE  s.nosin = p_ref
        AND s.iddossier = d.iddossier;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN dbms_output.put_line('Erreur aucun assuré dossier :'||p_ref);RAISE exc_fin;
		WHEN OTHERS THEN dbms_output.put_line('Erreur  assuré dossier:'||p_ref);RAISE exc_fin;
	END;

	--recherche de l'adhésion individuelle par le contrat et l'assuré
	BEGIN

	  SELECT r.idadhesion,r.numfor ,a.numgar , c.numcli, r.idrepartition
    INTO v_idadhesion, v_numfor, v_numgar, v_numcli, v_idrepartition_old
	  FROM repartition r, adhesion a , adhe_cntrt ad , contrat c
	  WHERE r.nosin = v_nosin
	  AND r.valide ='O'
	  AND NVL(gest_calc,2)=2
	  AND r.idadhesion = a.idadhesion
	  AND r.numfor = a.numfor
	  AND a.numindiv = v_numindiv
	  AND ad.idadhesion =a.idadhesion
	  AND ad.numgar = c.numgar;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN dbms_output.put_line('Erreur aucune adhesion assuré :'||v_numindiv||' contrat :'||v_numgar||' sin :'||v_nosin);RAISE exc_fin;
		WHEN OTHERS THEN dbms_output.put_line('Erreur adhesion assuré :'||v_numindiv||' contrat :'||v_numgar);RAISE exc_fin;
	END;

	-- récupération de la nouvelle garantie à calculer
	BEGIN
		SELECT g.numfor, p.idformule INTO v_numfor_calc, v_frml
		FROM garanties g, frml_prest p
		WHERE g.cle =v_numgar
		AND g.etendue = 2
		AND g.nat_risq = 4
		AND NVL(g.gest_calc,2)= 1
		AND g.numfor = p.numfor
    AND g.valide = 'O'
	AND g.libelle = NVL(p_libfor, g.libelle)
    ;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN dbms_output.put_line('Erreur aucune garantie trouvé contrat :'||v_numgar||' nosin :'||v_nosin); RAISE exc_fin;
		WHEN OTHERS THEN dbms_output.put_line('Erreur adhesion contrat :'||v_numgar||' nosin :'||v_nosin);RAISE exc_fin;
	END;

	--ouverture d'une couverture sur la nouvelle garantie par duplication de la garantie incapacité existante

  INSERT INTO ADHESION (NUMINDIV,NUMGAR,NUMFOR,DATAPLI,DATPER,RANG,ETAT,
	UC,FLAG_REGIME,REGIME,TYPFOR,NUMORG,DIS_CARENCE,DIS_FRANCHISE,IDADHESION,NUMFOR_CARENCE,NUMUTIL,CREATION,MAJ,MOTIF,IDCOUVERTURE)
		SELECT NUMINDIV,NUMGAR,v_numfor_calc,DATAPLI,DATPER,RANG,ETAT,
		UC,FLAG_REGIME,REGIME,TYPFOR,NUMORG,DIS_CARENCE,DIS_FRANCHISE,IDADHESION,NUMFOR_CARENCE,NUMUTIL,CREATION,MAJ,MOTIF,IDCOUVERTURE.nextval
		FROM adhesion
		WHERE idadhesion = v_idadhesion
		AND numindiv = v_numindiv
		AND numfor =v_numfor;
		dbms_output.put_line('insert ok adhesion garantie :'||v_numfor||' nosin :'||v_nosin);
	--????Ins_bene( R_BENE.idadhesion, R_BENE.numfor,R_BENE.numindiv, R_BENE.numindiv,0 );

	--on instruit uniquement si on a eu un paiement sur le sinistre
	IF p_date IS NOT NULL THEN
    -- dévalidation de l'ancienne garantie
    UPDATE REPARTITION SET VALIDE = 'N' WHERE VALIDE = 'O' AND NOSIN = v_nosin AND NVL(gest_calc, 2) = 2;
		--insertion de la répartition
		SELECT IDREPARTITION.NEXTVAL INTO v_idrepartition FROM DUAL;
		INSERT INTO REPARTITION (IDREPARTITION,IDADHESION,NUMFOR,NOSIN,TYPE_CALC,VALIDE,PERIODE,gest_calc)
		VALUES (v_idrepartition,v_idadhesion,v_numfor_calc,v_nosin,1,'O',NULL,1);--R_BENE_GAR.type_calc =1 à vérifier

		--mise à jour date de fin de la réparition précédente
		UPDATE repartition_bene set fin = p_date-1 ,traite='O',etat=4
		WHERE idrepartition = v_idrepartition_old;

		--insertion de la nouvelle répartition bene
		INSERT INTO REPARTITION_BENE (IDREPARTITION,NUMBENE,DEBUT,VALIDE,TRAITE,POURCENT,
		ECHESUIV,FIN,ETAT,TYPE_DEST,NUMBENE_DEST,FRACT,NUMDEST_PJ,EXCLU_DDE_PJ,IRREVOCABLE,MODE_RGLT)
		VALUES (v_idrepartition ,v_numindiv, p_date, 'O', 'N',100,
		null,null,1,2,v_numcli,null,null,'N','N',0);

		INSERT INTO BENE_FISC  (idrepartition,numbene,type_fisc,debut,valide)
		VALUES (v_idrepartition ,v_numindiv ,1 ,p_date ,'O');
		--creation du correspondant béné uniquement si non existant
		INSERT INTO CORRESPONDANT (CONTEXTE,ENTITE,NUMCORRES,TYPE_CORRES,DEFAUT_PJ_ASSU,DEFAUT_PJ_BENE,DEFAUT_RGLT_BENE,
		CREATION,CREATEUR,MODIFICATION,MODIFICATEUR,DEFAUT_SNTR,ID_CORRES,NAT_CORRES,INTERLOCUTEUR)
		SELECT 15 ,v_nosin ,v_numindiv  ,6 ,'N','N','N',p_date ,f_numutil ,p_date ,f_numutil ,'N',ID_CORRES.nextval ,4 ,v_numindiv
		FROM DUAL  where not exists (select entite from correspondant where contexte = 15 AND nat_corres = 4 AND numcorres =v_numindiv AND entite =v_nosin) ;


		-- destinataire de paiement :société=> pas besoin trigger
		--INSERT INTO HISTO_DEST (IDREPARTITION, NUMBENE, USERCREA, DATECREA, USERMAJ, DATEMAJ, TYPE_DEST, NUMBENE_DEST, DEBUT, FIN)
		--values (v_idrepartition, v_numindiv,f_numutil, sysdate, null,null,2,v_numcli, p_date, null);


		--gestion des arrets : duplication du dernier arret de délégation
		BEGIN
			SELECT * INTO R_ARRET
			FROM DELEG_ARRET
			WHERE fin = (p_date-1)
			AND nosin = v_nosin;

		INSERT INTO ARRET VALUES (idarret.nextval ,R_ARRET.nosin,R_ARRET.debut ,R_ARRET.fin ,R_ARRET.traite,R_ARRET.continu,R_ARRET.type ,0 ,R_ARRET.creation ,R_ARRET.modification ,R_ARRET.createur
			,R_ARRET.REMB_REG_JOUR ,NULL ,NULL,R_ARRET.reception ,null);

		EXCEPTION
			WHEN NO_DATA_FOUND THEN dbms_output.put_line('Erreur aucun arret trouvé nosin :'||v_nosin||' date:'||(p_date-1));
			WHEN OTHERS THEN dbms_output.put_line('Erreur arret  nosin :'||v_nosin||' date:'||(p_date-1));
		END;

		--génération des variables
		FETCH_FORMULE(v_numfor_calc,15,v_nosin,p_date);
		FETCH_FORMULE(v_numfor_calc,16,substr(v_nosin,0,7),p_date);

    BEGIN
      --reprise des variables de reprise

    -- UPDATE VAL_VARIABLE SET VALEUR =0 WHERE IDVARIABLE = F_FIND_VAR('FORC_FIC') AND ETENDUE = 15 AND clef =v_nosin ; --forcage à non
	  UPDATE VAL_VARIABLE SET VALEUR =nvl(nvl(replace(p_basej,',','.'),'0'),'0') WHERE IDVARIABLE = F_FIND_VAR('BASEJ_FIC') AND ETENDUE = 15 AND clef =v_nosin ; --forcage à non
	  UPDATE VAL_VARIABLE SET VALEUR =nvl(nvl(replace(p_revaloj,',','.'),'0'),'0') WHERE IDVARIABLE = F_FIND_VAR('REVALJ_FIC') AND ETENDUE = 15 AND clef =v_nosin ; --forcage à non
      UPDATE VAL_VARIABLE SET VALEUR = '0' WHERE IDVARIABLE = F_FIND_VAR('FORC_FIC') AND ETENDUE = 15 AND clef =v_nosin and VALEUR is null ; --forcage à non
      -- Selon delphine :Pour les contrats utilisant ce type de données, le GAN a déjà dû faire le calcul en amont
	  -- (donc de la même manière que nous ne renseignons pas 12 salaires mensuels, mais qu’un salaire en information reprise, il convient de valoriser le montant global ici aussi)
	  -- SALVARX = p_salbrut = TA+TB
	  UPDATE VAL_VARIABLE SET VALEUR = nvl(replace(p_salbrut,',','.'),'0') WHERE IDVARIABLE = F_FIND_VAR('SALVARX') AND ETENDUE = 15 AND clef =v_nosin and VALEUR is null ;

     dbms_output.put_line('insert ok 3 premiere variable');
	  /*INSERT INTO VAL_VARIABLE select F_FIND_VAR('BASEJ_FIC'),15,v_nosin,'O',p_date,NULL,'O',replace(p_basej,',','.'),NULL,f_numutil,sysdate,NULL,NULL
      FROM DUAL WHERE NOT EXISTS (SELECT v2.valeur from VAL_VARIABLE v2 WHERE idvariable =F_FIND_VAR('BASEJ_FIC') AND clef = v_nosin) ;

      INSERT INTO VAL_VARIABLE select F_FIND_VAR('REVALJ_FIC'),15,v_nosin,'O',p_date,NULL,'O',replace(p_revaloj,',','.'),NULL,f_numutil,sysdate,NULL,NULL
      FROM DUAL WHERE NOT EXISTS (SELECT v2.valeur from VAL_VARIABLE v2 WHERE idvariable =F_FIND_VAR('REVALJ_FIC') AND clef = v_nosin) ; */

-- nvl(replace(((1*p_salbrut)/12),',','.'),'0')

      dbms_output.put_line('GAN PREV_SALN1 + DDEBSAL');
      --RG formulée par Delphine le 13/12/2013 par tel
      IF v_frml = 804 THEN
        v_surv := TRUNC(add_months(v_surv,-3),'MONTH');
      ELSE v_surv := TRUNC(add_months(v_surv,-12),'MONTH');
      END IF;
  
      UPDATE VAL_VARIABLE SET VALEUR = (SELECT NVL( REPLACE(ROUND((  DECODE( TO_CHAR(v_surv,'MM'),1,31,2,28,3,31,4,30,5,31,6,30,7,31,8,31,9,30,10,31,11,30,12,31,0)*(p_salbrut)/365),6) ,',','.') ,'0') FROM DUAL) WHERE IDVARIABLE = F_FIND_VAR('SAL1') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SAL2') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SAL3') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SAL4') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SAL5') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SAL6') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SAL7') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SAL8') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SAL9') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SAL10') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SAL11') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SAL12') AND ETENDUE = 15 AND clef =v_nosin ;

      dbms_output.put_line('GAN SALNETAN + NBENFGAR + PREV_ENF1 + DFINPER1');
      UPDATE VAL_VARIABLE SET VALEUR =replace(p_salnet,',','.')  WHERE IDVARIABLE = F_FIND_VAR('SALNETAN') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR =nvl(p_nbenf,'0') WHERE IDVARIABLE = F_FIND_VAR('NBENFGAR') AND ETENDUE = 15 AND clef =v_nosin ;
	  UPDATE VAL_VARIABLE SET VALEUR =nvl(p_nbenf,'0') WHERE IDVARIABLE = F_FIND_VAR('PREV_ENF1') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR =p_maintien WHERE IDVARIABLE = F_FIND_VAR('DFINPER1') AND ETENDUE = 15 AND clef =v_nosin ;

	  dbms_output.put_line('GAN SALTAGAN12 + SALTAPREVGAN12 + SALTBGAN12 + SALTBPREVGAN12');
	  UPDATE VAL_VARIABLE SET VALEUR =nvl(p_ta,'0') WHERE IDVARIABLE = F_FIND_VAR('SALTAGAN12') AND ETENDUE = 15 AND clef =v_nosin ;
	  UPDATE VAL_VARIABLE SET VALEUR =nvl(p_ta,'0') WHERE IDVARIABLE = F_FIND_VAR('SALTAPREGAN12') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR =nvl(p_tb,'0') WHERE IDVARIABLE = F_FIND_VAR('SALTBGAN12') AND ETENDUE = 15 AND clef =v_nosin ;
	  UPDATE VAL_VARIABLE SET VALEUR =nvl(p_tb,'0') WHERE IDVARIABLE = F_FIND_VAR('SALTBPREGAN12') AND ETENDUE = 15 AND clef =v_nosin ;



      UPDATE VAL_VARIABLE SET VALEUR =to_char(v_surv,'ddmmyyyy') WHERE IDVARIABLE = F_FIND_VAR('DDEBSAL') AND ETENDUE = 15 AND clef =v_nosin ;
	  UPDATE VAL_VARIABLE SET VALEUR =replace(p_salnet,',','.')  WHERE IDVARIABLE = F_FIND_VAR('PREV_SALN1') AND ETENDUE = 15 AND clef =v_nosin ;

/*
d ' ou vient TA_FIC ??? et TB_FIC ??
      INSERT INTO VAL_VARIABLE select F_FIND_VAR('TA_FIC'),15,v_nosin,'O',p_date,NULL,'O',replace(p_ta,',','.'),NULL,f_numutil,sysdate,NULL,NULL
      FROM DUAL WHERE NOT EXISTS (SELECT v2.valeur from VAL_VARIABLE v2 WHERE idvariable =F_FIND_VAR('TA_FIC') AND clef = v_nosin) ;

	    dbms_output.put_line('insert ok 12 + 3 + 1 variables suivantes');

      INSERT INTO VAL_VARIABLE select F_FIND_VAR('TB_FIC'),15,v_nosin,'O',p_date,NULL,'O',replace(p_tb,',','.'),NULL,f_numutil,sysdate,NULL,NULL
      FROM DUAL WHERE NOT EXISTS (SELECT v2.valeur from VAL_VARIABLE v2 WHERE idvariable =F_FIND_VAR('TB_FIC') AND clef = v_nosin) ;
*/

	EXCEPTION
      WHEN OTHERS THEN dbms_output.put_line('Erreur val :'||v_nosin|| SQLERRM);RAISE exc_fin;
    END;
	END IF;

	EXCEPTION
		WHEN exc_fin THEN dbms_output.put_line('Erreur FIN');
END P_REPRISE_SIN_PREV_SAL_AN_MOY;
/
