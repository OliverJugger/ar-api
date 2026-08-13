CREATE OR REPLACE PACKAGE ARTHUS.PK_BATCH AS

   -- Valdeb    -> Retourne la valeur debut du parametre idparam
   -- Valfin    -> Retourne la valeur fin du parametre idparam
   -- Lib_param -> Retourne le libelle du parametre idparam
   -- Val_param -> Retourne le libelle de la valeur de parametres idparam
   -- param     -> Retourne les valeurs de paramXX de param_batch
   -- Divers    -> Retourne divers parametres (Titre, user, service, etc..)
 TYPE TypRec_Param IS RECORD
                           ( valdeb      VARCHAR2(130),
                             valfin      VARCHAR2(130),
                             lib_param   VARCHAR2(130),
                             val_param   VARCHAR2(130),
                             param       VARCHAR2(130),
                             divers      VARCHAR2(130),
                             numdest	   NUMBER(9),
	  												 numinterloc NUMBER(9)
	  												);


  TYPE TypTab_Rec_Param IS TABLE OF TypRec_Param INDEX BY BINARY_INTEGER;

  FUNCTION F_AFFIC_CHAPEAU (I_regroupement VARCHAR2,
                            I_chapeau VARCHAR2 DEFAULT NULL) RETURN BOOLEAN;

  FUNCTION F_CTRL_NB_LIGNE (I_nb_ligne NUMBER) RETURN BOOLEAN;

  FUNCTION F_LIB	(	a_mnemo 	IN VARCHAR2,
                		a_code	IN NUMBER,
                		a_retour	IN VARCHAR2	DEFAULT NULL
                		) RETURN	VARCHAR2;

  FUNCTION F_Init_Param RETURN Typtab_Rec_Param;

  PROCEDURE P_Charge_param (I_Numedit 	    IN BINARY_INTEGER,
		                        O_Tab_Rec_Param   IN OUT Typtab_Rec_Param);

  -- Procedure mettant à jour la table edition avec nombre de page
  PROCEDURE P_UPD_file_edition ( I_nbpage  IN NUMBER,
                                 I_numedit IN NUMBER);

END PK_BATCH;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_BATCH AS

  -- Fonction qui determine si on affiche ou non le code regroupement
  FUNCTION F_AFFIC_CHAPEAU (I_regroupement VARCHAR2,
                            I_chapeau VARCHAR2 DEFAULT NULL) RETURN BOOLEAN
  IS
    L_Affic_chapeau BOOLEAN;
  BEGIN
    IF I_regroupement IN ('N','n') THEN
       L_Affic_chapeau := FALSE;
    ELSIF  I_chapeau = 'sans regroupement' THEN
       L_Affic_chapeau := FALSE;
    ELSE
        L_Affic_chapeau := TRUE;
    END IF;
    RETURN L_Affic_chapeau;
  END;

  -- Fonction qui retourne un booléen permettant de savoir si l'édition ramène des lignes ou non.
  FUNCTION F_CTRL_NB_LIGNE(I_nb_ligne NUMBER) RETURN BOOLEAN
    IS
  BEGIN
    RETURN (I_nb_ligne != 0);
  END;


  FUNCTION F_Init_Param RETURN Typtab_Rec_Param
   IS
      O_Tab_Rec_Param_Init Typtab_Rec_Param;
      Rec_Param_Init   Typrec_Param;
  BEGIN
    FOR i IN 1 .. 15
    LOOP
      O_Tab_Rec_Param_Init (i) := Rec_Param_Init;
    END LOOP;
    RETURN O_Tab_Rec_Param_Init;
  END;

  FUNCTION F_LIB	(
  		a_mnemo 	IN VARCHAR2,
  		a_code	IN NUMBER,
  		a_retour	IN VARCHAR2	DEFAULT NULL
  		)
              RETURN	VARCHAR2
  IS
  loc_lib	VARCHAR2(210) := 'Indéterminée';
  BEGIN
  	BEGIN
  	SELECT libelle
  	INTO	loc_lib
  	FROM	libelle
  	WHERE	mnemo = a_mnemo
  	AND	code = a_code;
  	EXCEPTION WHEN NO_DATA_FOUND THEN
  		BEGIN
              	SELECT libelle
              	INTO   loc_lib
              	FROM   v_lble_ext
              	WHERE  mnemo = a_mnemo
              	AND    code  = a_code;
  		EXCEPTION WHEN NO_DATA_FOUND THEN
  			IF ( a_retour IS NOT NULL ) THEN
  				RAISE NO_DATA_FOUND;
  			ELSE
  				NULL;
  			END IF;
  		END;
  	END ;
    RETURN(loc_lib);
  END F_LIB;


  PROCEDURE P_Charge_param ( I_numedit 	       IN BINARY_INTEGER,
  		                       O_Tab_rec_param   IN OUT Typtab_rec_param)
  IS
    ---------------------------------------------------------------------------
    --               DECLARATION de TYPE
    -- ------------------------------------------------------------------------
    --
    TYPE Typtab_donnee IS TABLE OF VARCHAR2(130) INDEX BY BINARY_INTEGER;
    TYPE Typtab_Type_donnee IS TABLE OF VARCHAR2(2) INDEX BY BINARY_INTEGER;
    ---------------------------------------------------------------------------
    --               DECLARATION Variable de TYPE(Tables, Record)
    -- ------------------------------------------------------------------------
    -- Table de Record
    Tab_rec_param  Typtab_rec_param;
    --
    -- Table a une Dimension
    Tab_mnemo		Typtab_donnee;
    Tab_type		Typtab_type_donnee;
    --
    ---------------------------------------------------------------------------
    --               DECLARATION Variable Scalaire
    -- ------------------------------------------------------------------------
    --
    comm_numedit    BINARY_INTEGER;
    nb_char	      NUMBER;
    largeur	      BINARY_INTEGER;
    L_cellule       Util.cellule%TYPE;
    --
    ---------------------------------------------------------------------------
    --               DECLARATION CURSEUR
    -- ------------------------------------------------------------------------
    --
    -- Curseur ramenant le numero du client
    CURSOR C_parametres IS
                 SELECT  TO_CHAR(Client) Client
                 FROM    Parametres;

    -- ------------------------------------------------------------------------
    --
 BEGIN
  --
  Tab_rec_param := F_Init_param;
  --
  comm_numedit := I_numedit;
  --
  -- Numero de client se trouvant dans la table Parametres
  --
  OPEN  C_Parametres;
  FETCH C_parametres INTO Tab_rec_param(9).divers;
  CLOSE C_parametres;
  --
  BEGIN
   FOR FILE IN
      (
				SELECT	file_edition.editid,
					file_edition.batchid,
					file_edition.impid,
					file_edition.papid,
					file_edition.userid,
					file_edition.numdmnde,
					d2e(file_edition.date_demande)	date_demande
				FROM	file_edition
				WHERE	file_edition.numedit = TO_CHAR(comm_numedit)
			      )
    LOOP
				Tab_rec_param(1).divers := 'Traitement : ';
				Tab_rec_param(1).divers := Tab_rec_param(1).divers || FILE.editid;
				Tab_rec_param(3).divers := 'Demande N° ' ||TO_CHAR(comm_numedit) || ' du ' ||FILE.date_demande;

				-- Titre specifique de l'edition
				BEGIN
			        SELECT	distinct lib_edition.editlib
				  		INTO	Tab_rec_param(2).divers
				  		FROM	lib_edition
			        WHERE	lib_edition.numedit = I_numedit;
				  EXCEPTION WHEN NO_DATA_FOUND THEN Tab_rec_param(2).divers := NULL;
				END;

				-- Parametres de l'edition
				BEGIN
				  		SELECT	NVL(Tab_rec_param(2).divers, typ_edition.editlib),
				      	typ_edition.nb_char
				  		INTO	Tab_rec_param(2).divers,nb_char
			        FROM	typ_edition
				 		 	WHERE	typ_edition.editid = FILE.editid
				  		AND	      typ_edition.batchid = FILE.batchid;
				EXCEPTION WHEN NO_DATA_FOUND THEN
					Tab_rec_param(2).divers := 'Indéterminé';
					nb_char := 78;
				END;

				-- Utilisateur ayant fait la demande
				BEGIN
				  SELECT	'Demandé par : ' || util.pseudo,cellule,numutil
				  INTO	Tab_rec_param(4).divers,
				      	L_cellule,Tab_rec_param(8).divers
				  FROM	util
				  WHERE	util.nom = FILE.userid;
			        --
			    Tab_rec_param(5).divers :='Service : ' ||f_lib('CELL', L_cellule);
			        --
				EXCEPTION
			          WHEN NO_DATA_FOUND THEN
			             Tab_rec_param(4).divers := 'Demandé par : Le systeme';
			             Tab_rec_param(5).divers := 'Service : indéterminé';
			             Tab_rec_param(8).divers := '0';
				END;

				-- Donnees societe defaut de l'utilisateur
				FOR soc IN	(
					SELECT	numsoc
					FROM	util_soc,
						util
					WHERE	util_soc.defaut IS NOT NULL
					AND	util_soc.numutil = util.numutil
					AND	util.nom =FILE.userid)
				LOOP
			        IF SQL%FOUND THEN
			              BEGIN
			        	    --	Select lieu || ', le ' || trim(to_char(sysdate, 'DD month'))|| to_char(sysdate, ' YYYY'),	abrege

										SELECT lieu || ', le ' || d2e(SYSDATE),	abrege
										INTO	Tab_rec_param(6).divers,Tab_rec_param(7).divers
										FROM	societe
										WHERE	societe.numsoc = soc.numsoc;

										EXIT;

										EXCEPTION
								    		WHEN NO_DATA_FOUND THEN
								              Tab_rec_param(6).divers := 'Paris, le ' || d2e(SYSDATE);
										END;
			         END IF;
				END LOOP;
				-- Parametres du traitement
				BEGIN
				   SELECT	param_batch.lib1, param_batch.lib2, param_batch.lib3,
				      	param_batch.lib4, param_batch.lib5, param_batch.lib6,
					      param_batch.lib7, param_batch.lib8, param_batch.lib9,
					      param_batch.lib10,
					      param_batch.typ1, param_batch.typ2, param_batch.typ3,
					      param_batch.typ4, param_batch.typ5, param_batch.typ6,
					      param_batch.typ7, param_batch.typ8, param_batch.typ9,
					      param_batch.typ10,
					      param_batch.param1, param_batch.param2, param_batch.param3,
					      param_batch.param4, param_batch.param5,
					      param_batch.mnemo1, param_batch.mnemo2, param_batch.mnemo3,
					      param_batch.mnemo4, param_batch.mnemo5, param_batch.mnemo6,
					      param_batch.mnemo7, param_batch.mnemo8, param_batch.mnemo9,
					      param_batch.mnemo10
				    INTO	Tab_rec_param(1).lib_param, Tab_rec_param(2).lib_param,
			            Tab_rec_param(3).lib_param, Tab_rec_param(4).lib_param,
			            Tab_rec_param(5).lib_param, Tab_rec_param(6).lib_param,
					      	Tab_rec_param(7).lib_param, Tab_rec_param(8).lib_param,
			            Tab_rec_param(9).lib_param, Tab_rec_param(10).lib_param,
					      	Tab_type(1), Tab_type(2), Tab_type(3),
					      	Tab_type(4), Tab_type(5), Tab_type(6),
					      	Tab_type(7), Tab_type(8), Tab_type(9),
					      	Tab_type(10),
					      	Tab_rec_param(1).param, Tab_rec_param(2).param,
			            Tab_rec_param(3).param, Tab_rec_param(4).param,
			            Tab_rec_param(5).param,
					      	Tab_mnemo(1), Tab_mnemo(2), Tab_mnemo(3),
					     	 Tab_mnemo(4), Tab_mnemo(5), Tab_mnemo(6),
					     	 Tab_mnemo(7), Tab_mnemo(8), Tab_mnemo(9),
					     	 Tab_mnemo(10)
				     FROM	param_batch
				     WHERE	param_batch.numbatch = FILE.batchid;
			 --
					EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
				END;
				-- Valeur des parametres saisis
				BEGIN
				  SELECT	param_dmnde.valdeb1, param_dmnde.valdeb2, param_dmnde.valdeb3,
				      	param_dmnde.valdeb4, param_dmnde.valdeb5, param_dmnde.valdeb6,
				      	param_dmnde.valdeb7, param_dmnde.valdeb8, param_dmnde.valdeb9,
				       	param_dmnde.valdeb10,
					      param_dmnde.valfin1, param_dmnde.valfin2, param_dmnde.valfin3,
					      param_dmnde.valfin4, param_dmnde.valfin5, param_dmnde.valfin6,
				      	param_dmnde.valfin7, param_dmnde.valfin8, param_dmnde.valfin9,
			        		param_dmnde.valfin10,
			        	param_dmnde.numdest1, param_dmnde.numinterloc1,
					  		param_dmnde.numdest2, param_dmnde.numinterloc2,
					  		param_dmnde.numdest3, param_dmnde.numinterloc3,
							  param_dmnde.numdest4, param_dmnde.numinterloc4,
							  param_dmnde.numdest5, param_dmnde.numinterloc5
				   INTO	Tab_rec_param(1).valdeb, Tab_rec_param(2).valdeb,
			          Tab_rec_param(3).valdeb, Tab_rec_param(4).valdeb,
			          Tab_rec_param(5).valdeb, Tab_rec_param(6).valdeb,
				      	Tab_rec_param(7).valdeb, Tab_rec_param(8).valdeb,
			          Tab_rec_param(9).valdeb, Tab_rec_param(10).valdeb,
				      	Tab_rec_param(1).valfin, Tab_rec_param(2).valfin,
			          Tab_rec_param(3).valfin, Tab_rec_param(4).valfin,
			          Tab_rec_param(5).valfin, Tab_rec_param(6).valfin,
					      Tab_rec_param(7).valfin, Tab_rec_param(8).valfin,
			          Tab_rec_param(9).valfin, Tab_rec_param(10).valfin,
			          tab_rec_param (1).numdest, tab_rec_param (1).numinterloc,
					  		tab_rec_param (2).numdest, tab_rec_param (2).numinterloc,
					  		tab_rec_param (3).numdest, tab_rec_param (3).numinterloc,
					  		tab_rec_param (4).numdest, tab_rec_param (4).numinterloc,
					  		tab_rec_param (5).numdest, tab_rec_param (5).numinterloc
			      FROM	param_dmnde
				    WHERE	param_dmnde.numdmnde = FILE.numdmnde;

				    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
				END;
				-- Formatage des parametres
				FOR i IN 1 .. 10 LOOP
					 IF ( Tab_rec_param(i).lib_param IS NOT NULL ) THEN

				   			 Tab_rec_param(i).val_param := Tab_rec_param(i).lib_param ||' : ';

								 IF ( Tab_rec_param(i).valdeb IS NULL ) THEN
								      Tab_rec_param(i).val_param := Tab_rec_param(i).val_param ||
								        	                      'Parametre non renseigné';
								 ELSE
								     Tab_rec_param(i).val_param := Tab_rec_param(i).val_param ||' '||Tab_rec_param(i).valdeb;
								     largeur := nb_char - LENGTH(LTRIM(Tab_rec_param(i).val_param ) );

								     IF ( Tab_mnemo(i) IS NOT NULL ) THEN
												   IF ( Tab_type(i) = 'C' ) THEN
												      Tab_rec_param(i).val_param:= Tab_rec_param(i).val_param ||
										                       ' '||
										                       f_lib( Tab_mnemo(i), Tab_rec_param(i).valdeb);
												   ELSE
												      Tab_rec_param(i).val_param := Tab_rec_param(i).val_param||' '||
													         f_lib( Tab_mnemo(i), TO_NUMBER( Tab_rec_param(i).valdeb ));
											     END IF;
								     END IF;

								   	 IF ( Tab_rec_param(i).valfin IS NOT NULL ) THEN
								      	   IF ( LENGTH( Tab_rec_param(i).val_param ) > nb_char/2 ) THEN
																	Tab_rec_param(i).val_param :=SUBSTR( Tab_rec_param(i).val_param, 1,
																		(LENGTH( Tab_rec_param(i).lib_param)+nb_char)/2 );
									   			 END IF;
								      	   Tab_rec_param(i).val_param := Tab_rec_param(i).val_param ||
							                                                ' - '|| Tab_rec_param(i).valfin;
								      	   IF ( Tab_mnemo(i) IS NOT NULL ) THEN

																	IF ( Tab_type(i) = 'C' ) THEN
																   	   Tab_rec_param(i).val_param :=
														                                              Tab_rec_param(i).val_param ||' '||
																		                      f_lib( Tab_mnemo(i),
														                                                      Tab_rec_param(i).valfin );
																	ELSE
																   	   Tab_rec_param(i).val_param :=
														                                         Tab_rec_param(i).val_param ||' '||
																		                 f_lib( Tab_mnemo(i),
														                                         TO_NUMBER( Tab_rec_param(i).valfin));
															    END IF;
								      	   END IF;
								      	   IF ( LENGTH( Tab_rec_param(i).val_param ) > largeur ) THEN
									     						 Tab_rec_param(i).val_param := SUBSTR( Tab_rec_param(i).val_param, 1, nb_char );
									   			 END IF;
								   	END IF;
								 END IF;	-- Tab_rec_param(i).valdeb is Not Null
					 END IF;		-- Tab_rec_param(i).lib_param is Not Null

				END LOOP;

   END LOOP;

   EXCEPTION
   WHEN VALUE_ERROR
     THEN NULL;
  END;
  O_Tab_rec_param := Tab_rec_param;
 END P_Charge_param;

  -- Procedure mettant à jour la table edition avec nombre de page
  PROCEDURE P_UPD_file_edition ( I_nbpage  IN NUMBER,
                                 I_numedit IN NUMBER)
   IS
  BEGIN
    UPDATE file_edition
     SET    nb_page  =  I_nbpage
     WHERE  numedit  =  I_numedit;
  END;

--
-- =============================================================================
-- ---------------------------------- Fin des corps des procedures publiques --
END PK_BATCH;
/
