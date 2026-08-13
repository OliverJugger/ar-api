CREATE procedure ARTHUS.P_livre_libelle ( I_client IN NUMBER)
Is
--
-- Ensemble des mnemos servant pour la recherches des libelles a livrer
-- chez les differents clients.
  Cursor C_fetch_libelle IS
	 Select	 mnemo, type
	 From	 livre_libelle
	 Where	 client = I_client
	 And     statut = 1
	 For Update of statut;
--
-- Recherche si existence donnees sytemes
  Cursor C_exist_systeme(P_mnemo Varchar2) IS
	SELECT 	'X'
 	FROM 	lble
 	WHERE	mnemo = P_mnemo
	AND     Sens = -2;
--
  Cursor C_exist_systeme_lbleb(P_mnemo Varchar2) IS
	  SELECT  'X'
	  FROM    libelle_bis
	  WHERE   mnemo = P_mnemo
	  AND     Sens = -2;
--
  Cursor C_exist_systeme_lblee(P_mnemo Varchar2) IS
	  SELECT  'X'
	  FROM    lble_ext
	  WHERE   mnemo = P_mnemo
	  AND     code = -2;
--
  Cursor C_exist_systeme_lblebe(P_mnemo Varchar2) IS
	  SELECT  'X'
	  FROM    lble_bis_ext
	  WHERE   mnemo = P_mnemo
	  AND     code = '-2';


-- Recherche des libelles systemes
  Cursor C_lble_systeme(P_mnemo Varchar2) IS
	SELECT 	mnemo,
 		code,
 		f_double_quote(libelle) libelle,
 		sens,
 		tableau,
 		codapli,
 		creation,
 		maj,
		codlangue
 	FROM 	lble
 	WHERE	mnemo = P_mnemo;
--
  Cursor C_lble_systeme_lbleb(P_mnemo Varchar2) IS
	SELECT  mnemo,
		code,
		f_double_quote(libelle) libelle,
		sens,
		tableau,
		codapli,
		codlangue
	FROM    libelle_bis
	WHERE   mnemo = P_mnemo;
--
  Cursor C_lble_systeme_lblee(P_mnemo Varchar2) IS
	  SELECT  mnemo,
		  code,
		  f_double_quote(libelle) libelle,
		  sens,
		  tableau,
		  codlangue,
		  appli
	  FROM    lble_ext
	  WHERE   mnemo = P_mnemo;
--
  Cursor C_lble_systeme_lblebe(P_mnemo Varchar2) IS
	SELECT  mnemo,
		code,
		f_double_quote(libelle) libelle,
		sens,
		tableau,
		codlangue,
		appli
	FROM    lble_bis_ext
	WHERE   mnemo = P_mnemo;

-- Recherche entete libelle utilisateur
  Cursor C_lble_utilisateur(P_mnemo Varchar2) IS
	SELECT 	mnemo,
 		code,
 		f_double_quote(libelle) libelle,
 		sens,
 		tableau,
 		codapli,
 		creation,
 		maj,
		codlangue
 	FROM 	lble
 	WHERE	mnemo = P_mnemo
	AND     Sens  >= 0
	AND     code  <= -2;
--
Cursor C_lble_utilisateur_lbleb(P_mnemo Varchar2) IS
	SELECT  mnemo,
		code,
		f_double_quote(libelle) libelle,
		sens,
		tableau,
		codapli,
		codlangue
	FROM    libelle_bis
	WHERE   mnemo = P_mnemo
	AND     Sens  >= 0
	AND     code  in ( '-2', '-3', '-4');
--
-- JPF 20/11/2006
/*Cursor C_lble_utilisateur_lblee(P_mnemo Varchar2) IS     lble_ext  et lble_bis_ext = codif système
	SELECT  mnemo,
		code,
		f_double_quote(libelle) libelle,
		sens,
		tableau,
		codlangue,
		appli
	FROM    lble_ext
	WHERE   mnemo = P_mnemo
	AND     Sens  >= -1
	AND     code  = -2;
--
Cursor C_lble_utilisateur_lblebe(P_mnemo Varchar2) IS
	SELECT  mnemo,
		code,
		f_double_quote(libelle) libelle,
		sens,
		tableau,
		codlangue,
		appli
	FROM    lble_bis_ext
	WHERE   mnemo = P_mnemo
	AND     Sens  >= -1
	AND     code  = -2;*/
--
  Rec_c_fetch_libelle  		C_fetch_libelle%Rowtype;
  Rec_c_lble_systeme 		C_lble_systeme%Rowtype;
  Rec_c_lble_systeme_lbleb      C_lble_systeme_lbleb%Rowtype;
  Rec_c_lble_systeme_lblee      C_lble_systeme_lblee%Rowtype;
  Rec_c_lble_systeme_lblebe     C_lble_systeme_lblebe%Rowtype;

  Rec_c_lble_utilisateur 	C_lble_utilisateur%Rowtype;
  Rec_c_lble_utilisateur_lbleb  C_lble_utilisateur_lbleb%Rowtype;
/*  Rec_c_lble_utilisateur_lblee  C_lble_utilisateur_lblee%Rowtype;
  Rec_c_lble_utilisateur_lblebe C_lble_utilisateur_lblebe%Rowtype;*/    -- JPF 20/11/2006
--
  L_date_jour     Date default SYSDATE;
  L_test          Varchar2(1);
--
BEGIN
  -- Variable de reconnaissance SCCS
  -- @(#)P_livre_libelle.sql	1.3	03/03/28
  OPEN C_fetch_libelle;
  LOOP
    FETCH C_fetch_libelle into Rec_c_fetch_libelle;
    EXIT WHEN C_fetch_libelle%NOTFOUND;

	If (Rec_c_fetch_libelle.type = 1) then    -- LIBELLE
    --
		    OPEN C_exist_systeme(Rec_c_fetch_libelle.mnemo);
		    FETCH C_exist_systeme INTO L_test;
		    IF C_exist_systeme%FOUND THEN   -- Existence donnees systemes
		       -- Suppression donnees systemes
		       DBMS_OUTPUT.put_line( 'Delete Lble where mnemo = '''||
			   			      Rec_c_fetch_libelle.mnemo ||''';' );
		       -- Recherche des libelles systemes
		       OPEN C_lble_systeme(Rec_c_fetch_libelle.mnemo);
		       LOOP
		          FETCH C_lble_systeme into Rec_c_lble_systeme;
		          EXIT WHEN C_lble_systeme%NOTFOUND;
		          DBMS_OUTPUT.put_line( 'Insert Into Lble'||
		             '( MNEMO,CODE ,LIBELLE ,SENS ,TABLEAU ,CODAPLI ,CREATION ,MAJ,CODLANGUE)' );
		          --
		          DBMS_OUTPUT.put_line( 'Values( '''||
				          	Rec_c_lble_systeme.mnemo||''','''||
		 		   		Rec_c_lble_systeme.code||''','''||
		 				Rec_c_lble_systeme.libelle||''','''||
		 				Rec_c_lble_systeme.sens||''','''||
		 				Rec_c_lble_systeme.tableau||''','''||
		 				Rec_c_lble_systeme.codapli||''','||
		 				'To_DATE('''||TO_CHAR(Rec_c_lble_systeme.creation,'DD/MM/YYYY')||' '',''DD/MM/YYYY''), '||
		 				'To_DATE('''||TO_CHAR(Rec_c_lble_systeme.maj,'DD/MM/YYYY')     ||' '',''DD/MM/YYYY''), '||
						Rec_c_lble_systeme.codlangue||
						');' );
		       END LOOP;
		       CLOSE C_lble_systeme;
		    ELSE
		      -- Recherche entete libelle utilisateur
		      OPEN C_lble_utilisateur(Rec_c_fetch_libelle.mnemo);
		      FETCH C_lble_utilisateur into Rec_c_lble_utilisateur;
		      IF C_lble_utilisateur%FOUND THEN
			       -- Suppression donnees utilisateur d'entete
			       DBMS_OUTPUT.put_line( 'Delete Lble where mnemo = '''||
				   			      Rec_c_fetch_libelle.mnemo ||''' AND Sens  >= 0 AND code <= -2;' );
					LOOP			  --
				         DBMS_OUTPUT.put_line( 'Insert Into Lble'||
				             '( MNEMO,CODE ,LIBELLE ,SENS ,TABLEAU ,CODAPLI ,CREATION ,MAJ,CODLANGUE)' );
				         --
				         DBMS_OUTPUT.put_line( 'Values( '''||
						         	Rec_c_lble_utilisateur.mnemo||''','''||
				 		   		Rec_c_lble_utilisateur.code||''','''||
				 				Rec_c_lble_utilisateur.libelle||''','''||
				 				Rec_c_lble_utilisateur.sens||''','''||
				 				Rec_c_lble_utilisateur.tableau||''','''||
				 				Rec_c_lble_utilisateur.codapli||''','||
				 				'To_DATE('''||TO_CHAR(Rec_c_lble_utilisateur.creation,'DD/MM/YYYY')||' '',''DD/MM/YYYY''), '||
				 				'To_DATE('''||TO_CHAR(Rec_c_lble_utilisateur.maj,'DD/MM/YYYY')     ||' '',''DD/MM/YYYY''), '||
								Rec_c_lble_utilisateur.codlangue||
								');' );
						FETCH C_lble_utilisateur into Rec_c_lble_utilisateur;
						EXIT WHEN C_lble_utilisateur%NOTFOUND;
					END LOOP;
			   END IF;
		       CLOSE C_lble_utilisateur;
		    END IF;
		    CLOSE C_exist_systeme;
		    --

    elsif (Rec_c_fetch_libelle.type=2) then       -- LIBELLE_BIS
			OPEN C_exist_systeme_lbleb(Rec_c_fetch_libelle.mnemo);
			FETCH C_exist_systeme_lbleb INTO L_test;
			IF C_exist_systeme_lbleb%FOUND THEN   -- Existence donnees systemes
			-- Suppression donnees systemes
				DBMS_OUTPUT.put_line( 'Delete Libelle_bis where mnemo = '''||
				Rec_c_fetch_libelle.mnemo ||''';' );
			-- Recherche des libelles systemes
				OPEN C_lble_systeme_lbleb(Rec_c_fetch_libelle.mnemo);
				LOOP
					FETCH C_lble_systeme_lbleb into Rec_c_lble_systeme_lbleb;
					EXIT WHEN C_lble_systeme_lbleb%NOTFOUND;
					DBMS_OUTPUT.put_line( 'Insert Into Libelle_bis'||
					'( MNEMO,CODE ,LIBELLE ,SENS ,TABLEAU ,CODAPLI,CODLANGUE)' );
					--
					DBMS_OUTPUT.put_line( 'Values( '''||
						    Rec_c_lble_systeme_lbleb.mnemo||''','''||
						    Rec_c_lble_systeme_lbleb.code||''','''||
						    Rec_c_lble_systeme_lbleb.libelle||''','''||
						    Rec_c_lble_systeme_lbleb.sens||''','''||
						    Rec_c_lble_systeme_lbleb.tableau||''','''||
						    Rec_c_lble_systeme_lbleb.codapli||''','''||
							Rec_c_lble_systeme_lbleb.codlangue||
						   ''');' );
				END LOOP;
				CLOSE C_lble_systeme_lbleb;
			ELSE
			-- Recherche entete libelle utilisateur
				OPEN C_lble_utilisateur_lbleb(Rec_c_fetch_libelle.mnemo);
				FETCH C_lble_utilisateur_lbleb into Rec_c_lble_utilisateur_lbleb;
				IF C_lble_utilisateur_lbleb%FOUND THEN

					DBMS_OUTPUT.put_line( 'Delete Libelle_bis where mnemo = '''||
			   			      Rec_c_fetch_libelle.mnemo ||''' AND Sens  >= 0 AND code in ( ''-2'', ''-3'', ''-4'');' );
					LOOP
						DBMS_OUTPUT.put_line( 'Insert Into Libelle_bis'||
						   '( MNEMO,CODE ,LIBELLE ,SENS ,TABLEAU ,CODAPLI ,CODLANGUE)' );

						DBMS_OUTPUT.put_line( 'Values( '''||
						       Rec_c_lble_utilisateur_lbleb.mnemo||''','''||
						       Rec_c_lble_utilisateur_lbleb.code||''','''||
						       Rec_c_lble_utilisateur_lbleb.libelle||''','''||
						       Rec_c_lble_utilisateur_lbleb.sens||''','''||
						       Rec_c_lble_utilisateur_lbleb.tableau||''','''||
						       Rec_c_lble_utilisateur_lbleb.codapli||''','''||
							   Rec_c_lble_utilisateur_lbleb.codlangue||
						       ''');' );
						FETCH C_lble_utilisateur_lbleb into Rec_c_lble_utilisateur_lbleb;
						EXIT WHEN C_lble_utilisateur_lbleb%NOTFOUND;
					END LOOP;
				END IF;
				CLOSE C_lble_utilisateur_lbleb;
			END IF;
			CLOSE C_exist_systeme_lbleb;
			--

	elsif Rec_c_fetch_libelle.type = 3 then      -- LBLE_EXT
			--
		    	OPEN C_exist_systeme_lblee(Rec_c_fetch_libelle.mnemo);
			FETCH C_exist_systeme_lblee INTO L_test;
			IF C_exist_systeme_lblee%FOUND THEN   -- Existence donnees systemes
			-- Suppression donnees systemes
				DBMS_OUTPUT.put_line( 'Delete Lble_ext where mnemo = '''||
							Rec_c_fetch_libelle.mnemo ||''';' );
				-- Recherche des libelles systemes
				OPEN C_lble_systeme_lblee(Rec_c_fetch_libelle.mnemo);
				LOOP
				FETCH C_lble_systeme_lblee into Rec_c_lble_systeme_lblee;
				EXIT WHEN C_lble_systeme_lblee%NOTFOUND;
				DBMS_OUTPUT.put_line( 'Insert Into Lble_ext'||
				'( MNEMO,CODE ,LIBELLE ,SENS ,TABLEAU ,CODLANGUE ,APPLI)' );
				--
				DBMS_OUTPUT.put_line( 'Values( '''||
						    Rec_c_lble_systeme_lblee.mnemo||''','''||
						    Rec_c_lble_systeme_lblee.code||''','''||
						    Rec_c_lble_systeme_lblee.libelle||''','''||
						    Rec_c_lble_systeme_lblee.sens||''','''||
						    Rec_c_lble_systeme_lblee.tableau||''','''||
						    Rec_c_lble_systeme_lblee.codlangue||''','''||
							Rec_c_lble_systeme_lblee.appli||
							''');' );
				END LOOP;
				CLOSE C_lble_systeme_lblee;
			ELSE
				null;   -- JPF 20/11/2006
			/*-- Recherche entete libelle utilisateur
				OPEN C_lble_utilisateur_lblee(Rec_c_fetch_libelle.mnemo);
				FETCH C_lble_utilisateur_lblee into Rec_c_lble_utilisateur_lblee;
			     	IF C_lble_utilisateur_lblee%FOUND THEN
				--
					DBMS_OUTPUT.put_line( 'Insert Into Lble_ext'||
				     '( MNEMO,CODE ,LIBELLE ,SENS ,TABLEAU ,CODLANGUE ,APPLI)' );
				--
					DBMS_OUTPUT.put_line( 'Values( '''||
					       Rec_c_lble_utilisateur_lblee.mnemo||''','''||
					       Rec_c_lble_utilisateur_lblee.code||''','''||
					       Rec_c_lble_utilisateur_lblee.libelle||''','''||
					       Rec_c_lble_utilisateur_lblee.sens||''','''||
			 	       	   Rec_c_lble_utilisateur_lblee.tableau||''','''||
						   Rec_c_lble_utilisateur_lblee.codlangue||''','''||
						   Rec_c_lble_utilisateur_lblee.appli||
					       ''');' );
				END IF;
				CLOSE C_lble_utilisateur_lblee;*/
			END IF;
			CLOSE C_exist_systeme_lblee;
			--

	elsif Rec_c_fetch_libelle.type = 4 then      -- LBLE_BIS_EXT
			--
		    	OPEN C_exist_systeme_lblebe(Rec_c_fetch_libelle.mnemo);
			FETCH C_exist_systeme_lblebe INTO L_test;
			IF C_exist_systeme_lblebe%FOUND THEN   -- Existence donnees systemes
			-- Suppression donnees systemes
				DBMS_OUTPUT.put_line( 'Delete Lble_bis_ext where mnemo = '''||
							Rec_c_fetch_libelle.mnemo ||''';' );
			-- Recherche des libelles systemes
				OPEN C_lble_systeme_lblebe(Rec_c_fetch_libelle.mnemo);
				LOOP
				FETCH C_lble_systeme_lblebe into Rec_c_lble_systeme_lblebe;
				EXIT WHEN C_lble_systeme_lblebe%NOTFOUND;
				DBMS_OUTPUT.put_line( 'Insert Into Lble_bis_ext'||
				'( MNEMO,CODE ,LIBELLE ,SENS ,TABLEAU ,CODLANGUE ,APPLI)' );
			--
				DBMS_OUTPUT.put_line( 'Values( '''||
					    Rec_c_lble_systeme_lblebe.mnemo||''','''||
					    Rec_c_lble_systeme_lblebe.code||''','''||
					    Rec_c_lble_systeme_lblebe.libelle||''','''||
					    Rec_c_lble_systeme_lblebe.sens||''','''||
					    Rec_c_lble_systeme_lblebe.tableau||''','''||
					    Rec_c_lble_systeme_lblebe.codlangue||''','''||
						Rec_c_lble_systeme_lblebe.appli||
						''');' );
				END LOOP;
				CLOSE C_lble_systeme_lblebe;
			ELSE
				null;   -- JPF 20/11/2006
			/* -- Recherche entete libelle utilisateur
				OPEN C_lble_utilisateur_lblebe(Rec_c_fetch_libelle.mnemo);
				FETCH C_lble_utilisateur_lblebe into Rec_c_lble_utilisateur_lblebe;
				IF C_lble_utilisateur_lblebe%FOUND THEN
				--
				DBMS_OUTPUT.put_line( 'Insert Into Lble_bis_ext'||
				     '( MNEMO,CODE ,LIBELLE ,SENS ,TABLEAU ,CODLANGUE ,APPLI )' );
				--
				DBMS_OUTPUT.put_line( 'Values( '''||
					       Rec_c_lble_utilisateur_lblebe.mnemo||''','''||
					       Rec_c_lble_utilisateur_lblebe.code||''','''||
					       Rec_c_lble_utilisateur_lblebe.libelle||''','''||
					       Rec_c_lble_utilisateur_lblebe.sens||''','''||
					       Rec_c_lble_utilisateur_lblebe.tableau||''','''||
						   Rec_c_lble_utilisateur_lblebe.codlangue||''','''||
						   Rec_c_lble_utilisateur_lblebe.appli||
					      ''');' );
				END IF;
				CLOSE C_lble_utilisateur_lblebe;*/
			END IF;
			CLOSE C_exist_systeme_lblebe;
			--
	END IF; -- de If (Rec_c_fetch_libelle.type=1) then


	-- Mise a jour de l'enregistrement courant
	Update  livre_libelle
	Set     Statut = 2,
	    date_livre = L_date_jour
    Where   current of C_Fetch_libelle;
    --
  END LOOP;
  CLOSE C_fetch_libelle;
  --
  COMMIT;
  --
END P_livre_libelle;
/
