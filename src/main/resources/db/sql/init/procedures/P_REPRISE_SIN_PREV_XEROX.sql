CREATE PROCEDURE ARTHUS.P_REPRISE_SIN_PREV_XEROX (p_ref in varchar2,
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

   loc_idcouv NUMBER(9);

BEGIN

	dbms_output.put_line('Debut dossier :'||p_ref);
	--recherche de l'assuré par référence ext de sinistre
	BEGIN

		SELECT d.numindiv, s.nosin, s.survenance  INTO v_numindiv, v_nosin ,v_surv
		FROM dossier_sinistre d , sntr_prev s
		WHERE  s.nosin =p_ref  -- s.ref_ext_1 = p_ref --s.nosin =p_ref
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
		WHEN NO_DATA_FOUND THEN dbms_output.put_line('Erreur aucune adhesion assuré :'||v_numindiv||' contrat :'||v_numgar);RAISE exc_fin;
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
		WHEN NO_DATA_FOUND THEN dbms_output.put_line('Erreur aucune garantie trouvé contrat :'||v_numgar);
		WHEN OTHERS THEN dbms_output.put_line('Erreur garantie contrat :'||v_numgar);
	END;

	--ouverture d'une couverture sur la nouvelle garantie par duplication de la garantie incapacité existante

	dbms_output.put_line('Insertion adhesion :'||v_idadhesion);
	dbms_output.put_line('Insertion v_numfor_calc :'||v_numfor_calc);
   SELECT IDCOUVERTURE.nextval INTO loc_idcouv FROM DUAL;
	dbms_output.put_line('Insertion loc_idcouv :'||loc_idcouv);
  INSERT INTO ADHESION (NUMINDIV,NUMGAR,NUMFOR,DATAPLI,DATPER,RANG,ETAT,
	UC,FLAG_REGIME,REGIME,TYPFOR,NUMORG,DIS_CARENCE,DIS_FRANCHISE,IDADHESION,NUMFOR_CARENCE,NUMUTIL,CREATION,MAJ,MOTIF,IDCOUVERTURE)
		SELECT NUMINDIV,NUMGAR,v_numfor_calc,DATAPLI,DATPER,RANG,ETAT,
		UC,FLAG_REGIME,REGIME,TYPFOR,NUMORG,DIS_CARENCE,DIS_FRANCHISE,IDADHESION,NUMFOR_CARENCE,NUMUTIL,CREATION,MAJ,MOTIF,loc_idcouv
		FROM adhesion
		WHERE idadhesion = v_idadhesion
		AND numindiv = v_numindiv
		AND numfor =v_numfor;

	--????Ins_bene( R_BENE.idadhesion, R_BENE.numfor,R_BENE.numindiv, R_BENE.numindiv,0 );

	--on instruit uniquement si on a eu un paiement sur le sinistre
	IF p_date IS NOT NULL THEN
	dbms_output.put_line('p_date :'||p_date);
    -- dévalidation de l'ancienne garantie
    UPDATE REPARTITION SET VALIDE = 'N' WHERE VALIDE = 'O' AND NOSIN = v_nosin AND NVL(gest_calc, 0) = 0;
		--insertion de la répartition
		SELECT IDREPARTITION.NEXTVAL INTO v_idrepartition FROM DUAL;
	  dbms_output.put_line('REPARTITION :'||v_idrepartition);
		INSERT INTO REPARTITION (IDREPARTITION,IDADHESION,NUMFOR,NOSIN,TYPE_CALC,VALIDE,PERIODE,gest_calc)
		VALUES (v_idrepartition,v_idadhesion,v_numfor_calc,v_nosin,1,'O',NULL,1);--R_BENE_GAR.type_calc =1 à vérifier

		--mise à jour date de fin de la répartition précédente
		UPDATE repartition_bene set fin = p_date-1 ,traite='O',etat=4
		WHERE idrepartition = v_idrepartition_old;

	  dbms_output.put_line('REPARTITION_BENE :'||v_idrepartition);
		--insertion de la nouvelle répartition bene
		INSERT INTO REPARTITION_BENE (IDREPARTITION,NUMBENE,DEBUT,VALIDE,TRAITE,POURCENT,
		ECHESUIV,FIN,ETAT,TYPE_DEST,NUMBENE_DEST,FRACT,NUMDEST_PJ,EXCLU_DDE_PJ,IRREVOCABLE,MODE_RGLT)
		VALUES (v_idrepartition ,v_numindiv, p_date, 'O', 'N',100,
		null,null,1,2,v_numcli,null,null,'N','N',0);

	  dbms_output.put_line('BENE_FISC :'||v_idrepartition);
		INSERT INTO BENE_FISC  (idrepartition,numbene,type_fisc,debut,valide)
		VALUES (v_idrepartition ,v_numindiv ,1 ,p_date ,'O');
		--creation du correspondant béné uniquement si non existant
	  dbms_output.put_line('CORRESPONDANT :'||v_numindiv);

	  BEGIN
		INSERT INTO CORRESPONDANT (CONTEXTE,ENTITE,NUMCORRES,TYPE_CORRES,DEFAUT_PJ_ASSU,DEFAUT_PJ_BENE,DEFAUT_RGLT_BENE,
		CREATION,CREATEUR,MODIFICATION,MODIFICATEUR,DEFAUT_SNTR,ID_CORRES,NAT_CORRES,INTERLOCUTEUR)
		SELECT 15 ,v_nosin ,v_numindiv  ,6 ,'N','N','N',p_date ,f_numutil ,p_date ,f_numutil ,'N',ID_CORRES.nextval ,4 ,v_numindiv
		FROM DUAL  where not exists (select entite from correspondant where contexte = 15 AND nat_corres = 4 AND numcorres =v_numindiv AND entite =v_nosin) ;
	 EXCEPTION
		WHEN NO_DATA_FOUND THEN dbms_output.put_line('Erreur aucun CORRESPONDANT nosin :'||v_nosin||' date:'||p_date-1);
		WHEN OTHERS THEN dbms_output.put_line('Erreur Insert CORRESPONDANT values : 15 / '||v_nosin||' / '||v_numindiv||'/ 6 / N / N / N / '
																						  ||p_date||' / '||f_numutil||' / '||p_date||' / '
																						  ||f_numutil||'/ N / IDCORRES.nextval / 4 / '||v_numindiv);
	END;
		-- destinataire de paiement :société=> pas besoin trigger
		--INSERT INTO HISTO_DEST (IDREPARTITION, NUMBENE, USERCREA, DATECREA, USERMAJ, DATEMAJ, TYPE_DEST, NUMBENE_DEST, DEBUT, FIN)
		--values (v_idrepartition, v_numindiv,f_numutil, sysdate, null,null,2,v_numcli, p_date, null);




		--gestion des arrets : duplication du dernier arret de délégation
		BEGIN
			SELECT * INTO R_ARRET
			FROM DELEG_ARRET
			WHERE fin = p_date-1
			AND nosin = v_nosin;
	    dbms_output.put_line('ARRET nosin:'||v_nosin);
		INSERT INTO ARRET VALUES (idarret.nextval ,R_ARRET.nosin,R_ARRET.debut ,R_ARRET.fin ,R_ARRET.traite,R_ARRET.continu,R_ARRET.type ,0 ,R_ARRET.creation ,R_ARRET.modification ,R_ARRET.createur
			,R_ARRET.REMB_REG_JOUR ,NULL ,NULL,R_ARRET.reception,null );

		EXCEPTION
			WHEN NO_DATA_FOUND THEN dbms_output.put_line('Erreur aucun arret trouvé nosin :'||v_nosin||' date:'||p_date);
			WHEN OTHERS THEN dbms_output.put_line('Erreur arret  nosin :'||v_nosin||' date:'||p_date);
		END;


		--génération des variables
		FETCH_FORMULE(v_numfor_calc,15,v_nosin,p_date);
		FETCH_FORMULE(v_numfor_calc,16,substr(v_nosin,0,7),p_date);

    BEGIN
      UPDATE VAL_VARIABLE SET VALEUR =nvl(replace(p_salbrut,',','.'),'0') WHERE IDVARIABLE = F_FIND_VAR('SAL1') AND ETENDUE = 15 AND clef =v_nosin ;
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
      --reprise des variables de reprise
	  dbms_output.put_line('XEROX BASEJ_FIC + REVALJ_FIC + FORC_FIC');
    -- UPDATE VAL_VARIABLE SET VALEUR =0 WHERE IDVARIABLE = F_FIND_VAR('FORC_FIC') AND ETENDUE = 15 AND clef =v_nosin ; --forcage à non
	  UPDATE VAL_VARIABLE SET VALEUR =nvl(p_basej,'0') WHERE IDVARIABLE = F_FIND_VAR('BASEJ_FIC') AND ETENDUE = 15 AND clef =v_nosin ; --forcage à non
	  UPDATE VAL_VARIABLE SET VALEUR =nvl(p_revaloj,'0') WHERE IDVARIABLE = F_FIND_VAR('REVALJ_FIC') AND ETENDUE = 15 AND clef =v_nosin ; --forcage à non
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('FORC_FIC') AND ETENDUE = 15 AND clef =v_nosin and VALEUR is null ; --forcage à non

	  dbms_output.put_line('XEROX SALXEROXTA + SALXEROXTB + SALXEROX');
      UPDATE VAL_VARIABLE SET VALEUR =nvl(replace(p_salbrut,',','.'),'0') WHERE IDVARIABLE = F_FIND_VAR('SALXEROX') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR =nvl(replace(p_ta,',','.'),'0') WHERE IDVARIABLE = F_FIND_VAR('SALXEROXTA') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR =nvl(replace(p_tb,',','.'),'0') WHERE IDVARIABLE = F_FIND_VAR('SALXEROXTB') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SALXEROXTC') AND ETENDUE = 15 AND clef =v_nosin ;
      UPDATE VAL_VARIABLE SET VALEUR ='0' WHERE IDVARIABLE = F_FIND_VAR('SALXEROXTD') AND ETENDUE = 15 AND clef =v_nosin ;

	  dbms_output.put_line('XEROX NBENFGAR + PREV_ENF1 + PREV_SALN1');
      UPDATE VAL_VARIABLE SET VALEUR =nvl(p_nbenf,'0') WHERE IDVARIABLE = F_FIND_VAR('NBENFGAR') AND ETENDUE = 15 AND clef =v_nosin ;
	  UPDATE VAL_VARIABLE SET VALEUR =nvl(p_nbenf,'0') WHERE IDVARIABLE = F_FIND_VAR('PREV_ENF1') AND ETENDUE = 15 AND clef =v_nosin ;
	  UPDATE VAL_VARIABLE SET VALEUR =nvl(replace(p_salnet,',','.'),'0')  WHERE IDVARIABLE = F_FIND_VAR('PREV_SALN1') AND ETENDUE = 15 AND clef =v_nosin ;

	EXCEPTION
      WHEN OTHERS THEN dbms_output.put_line('Erreur val :'||v_nosin|| SQLERRM);
    END;
	END IF;

	EXCEPTION
		WHEN exc_fin THEN dbms_output.put_line('Erreur FIN');
END P_REPRISE_SIN_PREV_XEROX;
/
