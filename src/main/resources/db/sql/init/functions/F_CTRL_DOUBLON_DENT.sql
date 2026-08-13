CREATE FUNCTION ARTHUS.F_CTRL_DOUBLON_DENT( i_numindiv sinistre.numindiv%TYPE,
                                                i_nodent VARCHAR2,
                                                i_date DATE,
                                                i_codfrais sinistre.codfrais%TYPE,
                                                i_numsin sinistre.numsin%TYPE,
                                                i_numdoss sinistre_sante.num_dossier%TYPE default null
                                                ) RETURN NUMBER IS
  loc_posdent VARCHAR2(50);
  loc_nb_dent number;

  CURSOR c_dent IS
   SELECT ';'||trim(to_char(sd.locdent1,'00'))||';'||trim(to_char(sd.locdent2,'00'))||';'||trim(to_char(sd.locdent3,'00'))||';'||trim(to_char(sd.locdent4,'00'))||';'
    ||trim(to_char(sd.locdent5,'00'))||';'||trim(to_char(sd.locdent6,'00'))||';' ||trim(to_char(sd.locdent7,'00'))||';'
    ||trim(to_char(sd.locdent8,'00')) ||';'||trim(to_char(sd.locdent9,'00'))||';'||trim(to_char(sd.locdent10,'00'))||';'
    ||trim(to_char(sd.locdent11,'00'))||';'||trim(to_char(sd.locdent12,'00'))||';'||trim(to_char(sd.locdent13,'00'))||';'
    ||trim(to_char(sd.locdent14,'00'))||';'||trim(to_char(sd.locdent15,'00'))||';'||trim(to_char(sd.locdent16,'00'))||';' dent

	FROM SINISTRE s , sinistre_dent sd, ntfrs_dentaire nt, ntfrs_dentaire nt2
	WHERE s.numsin <>NVL(i_numsin,0)
    AND s.numindiv = i_numindiv
	AND s.datsin >= i_date
    AND s.numsin = sd.numsin
    AND nt.codfrais = s.codfrais
    AND nt.TYPE_ACTE= nt2.TYPE_ACTE
	AND nt2.codfrais= i_codfrais
	AND NVL(nt2.doublon,0) = 1
  UNION
    SELECT ';'||trim(to_char(ss.locdent1,'00'))||';'||trim(to_char(ss.locdent2,'00'))||';'||trim(to_char(ss.locdent3,'00'))||';' ||trim(to_char(ss.locdent4,'00'))||';'
    ||trim(to_char(ss.locdent5,'00'))||';'||trim(to_char(ss.locdent6,'00'))||';' ||trim(to_char(ss.locdent7,'00'))||';'
    ||trim(to_char(ss.locdent8,'00')) ||';'||trim(to_char(ss.locdent9,'00'))||';'||trim(to_char(ss.locdent10,'00'))||';'
    ||trim(to_char(ss.locdent11,'00'))||';'||trim(to_char(ss.locdent12,'00'))||';'||trim(to_char(ss.locdent13,'00'))||';'
    ||trim(to_char(ss.locdent14,'00'))||';'||trim(to_char(ss.locdent15,'00'))||';'||trim(to_char(ss.locdent16,'00'))||';' dent

	FROM sinistre_sante ss,  ntfrs_dentaire nt, ntfrs_dentaire nt2
	WHERE ss.numindiv = i_numindiv
    AND ss.datsin >= i_date
    AND ss.num_dossier = i_numdoss
    AND i_numdoss IS NOT NULL
    AND nt.codfrais = ss.codfrais
    AND nt.TYPE_ACTE= nt2.TYPE_ACTE
    AND nt2.codfrais= i_codfrais
    AND NVL(nt2.doublon,0) = 1
  UNION
    SELECT ';'||trim(to_char(sd.locdent1,'00'))||';'||trim(to_char(sd.locdent2,'00'))||';'||trim(to_char(sd.locdent3,'00'))||';' ||trim(to_char(sd.locdent4,'00'))||';'
    ||trim(to_char(sd.locdent5,'00'))||';'||trim(to_char(sd.locdent6,'00'))||';' ||trim(to_char(sd.locdent7,'00'))||';'
    ||trim(to_char(sd.locdent8,'00')) ||';'||trim(to_char(sd.locdent9,'00'))||';'||trim(to_char(sd.locdent10,'00'))||';'
    ||trim(to_char(sd.locdent11,'00'))||';'||trim(to_char(sd.locdent12,'00'))||';'||trim(to_char(sd.locdent13,'00'))||';'
    ||trim(to_char(sd.locdent14,'00'))||';'||trim(to_char(sd.locdent15,'00'))||';'||trim(to_char(sd.locdent16,'00'))||';' dent

	FROM travsn s ,trav_saisie sd,  ntfrs_dentaire nt, ntfrs_dentaire nt2
	WHERE s.numsin <>NVL(i_numsin,0)
    AND s.numindiv = i_numindiv
	  AND s.datsin >= i_date
    AND s.numsin = sd.numsin
    AND nt.codfrais = s.codfrais
    AND nt.TYPE_ACTE= nt2.TYPE_ACTE
	  AND nt2.codfrais= i_codfrais
	  AND NVL(nt2.doublon,0) = 1
    AND s.USERNAME = sd.USERNAME
    AND s.SID = sd.SID
    AND s.NUMLIG = sd.NUMLIG
    AND s.NUMSIN is not null;
BEGIN
	--peut Ãªtre Ã  revoir en fonction de l'appel par dent ou pour une liste de dent
	IF INSTR(i_nodent,',') = 0 THEN
		loc_posdent :=TRIM(to_char(i_nodent,'00'));
	ELSE loc_posdent :=RTRIM(TRIM(i_nodent),',');
	END IF;
  loc_nb_dent := NVL(LENGTH(loc_posdent),0) - NVL(LENGTH(REPLACE(loc_posdent,',')),0);

  FOR n IN 1..loc_nb_dent+1 LOOP
    FOR REC_dent IN c_dent LOOP
        IF instr(REC_dent.dent,';'||TRIM(to_char(f_split_char(loc_posdent,n,','),'00')) ||';') <>0 THEN
        RETURN 1;--au moins une dent a Ã©tÃ© trouvÃ©e
      END IF;
    END LOOP;
  END LOOP;

	RETURN 0;
EXCEPTION
	WHEN OTHERS THEN RETURN 0;

END F_CTRL_DOUBLON_DENT;
