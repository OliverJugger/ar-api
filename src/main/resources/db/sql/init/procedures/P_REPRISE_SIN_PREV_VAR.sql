CREATE PROCEDURE ARTHUS.P_REPRISE_SIN_PREV_VAR (p_ref in varchar2,
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
	  AND NVL(gest_calc,2)=1
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

	--on instruit uniquement si on a eu un paiement sur le sinistre
	IF p_date IS NOT NULL THEN


    BEGIN

      dbms_output.put_line('GAN PREV_SALN1 + DDEBSAL');
      --RG formulée par Delphine le 13/12/2013 par tel
      IF v_frml = 804 THEN
        v_surv := TRUNC(add_months(v_surv,-3),'MONTH');
      ELSE v_surv := TRUNC(add_months(v_surv,-12),'MONTH');
      END IF;

      UPDATE VAL_VARIABLE SET VALEUR = (SELECT NVL( REPLACE(ROUND((  DECODE( TO_CHAR(v_surv,'MM'),1,31,2,28,3,31,4,30,5,31,6,30,7,31,8,31,9,30,10,31,11,30,12,31,0)*(replace(p_salbrut,',','.'))/365),6) ,',','.') ,'0') FROM DUAL) WHERE IDVARIABLE = F_FIND_VAR('SAL1') AND ETENDUE = 15 AND clef =v_nosin ;
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
END ;
/
