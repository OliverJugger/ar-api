CREATE FUNCTION ARTHUS.F_CTRL_PERSONNE
   ( I_Numindiv IN NUMBER)
     RETURN VARCHAR2
     IS
--
  L_exist	Varchar2 (1);
  Loc_DB  Varchar2 (30);
--
  CURSOR C_DECAISMT
  IS
  SELECT 	'x'
  FROM		DECAISMT
  WHERE		DECAISMT.NUMBENE = I_Numindiv
			OR	DECAISMT.NUMDEST = I_Numindiv;
--
  CURSOR C_ENCAISMT
  IS
  SELECT 	'x'
  FROM		ENCAISMT
  WHERE		ENCAISMT.NUMCLI = I_Numindiv;
--
  CURSOR C_ADHE_CNTRT
  IS
  SELECT 	'x'
  FROM		ADHE_CNTRT
  WHERE		ADHE_CNTRT.NUMADHE = I_Numindiv
      OR	ADHE_CNTRT.NUMQUERABLE = I_Numindiv;
--
/*
--  CURSOR C_ADHE_COLLECTIVE
--  IS
--  SELECT 	'x'
--  FROM		ADHE_COLLECTIVE
--  WHERE		ADHE_COLLECTIVE.DESTINATAIRE = I_Numindiv
--    	OR	ADHE_COLLECTIVE.NUMCLI = I_Numindiv
--    	OR	ADHE_COLLECTIVE.NUMQUERABLE =I_Numindiv;
*/
--
/*
--  CURSOR C_ADH_GRP
--  IS
--  SELECT 	'x'
--  FROM		ADH_GRP
--  WHERE		ADH_GRP.NUMINDIV = I_Numindiv;
*/
--
  CURSOR C_DECOMPTE
  IS
  SELECT 	'x'
  FROM		DECOMPTE
  WHERE		DECOMPTE.NUMINDIV = I_Numindiv
      OR	DECOMPTE.NUMBENE  = I_Numindiv;
--
  /*
--  CURSOR C_DOSSIER_SANTE
--  IS
--  SELECT 	'x'
--  FROM		DOSSIER_SANTE
--  WHERE		DOSSIER_SANTE.NUMINDIV = I_Numindiv
--    	OR	DOSSIER_SANTE.NUMBENE  = I_Numindiv;
*/
--
  CURSOR C_DOSSIER_SINISTRE
  IS
  SELECT 	'x'
  FROM		DOSSIER_SINISTRE
  WHERE		DOSSIER_SINISTRE.NUMINDIV = I_Numindiv;
--
  CURSOR C_FACTURE
  IS
  SELECT 	'x'
  FROM		FACTURE
  WHERE		FACTURE.NUMCLI = I_Numindiv;
--
/*
--  CURSOR C_RECOURS
--  IS
--  SELECT 	'x'
--  FROM		RECOURS
--  WHERE		RECOURS.NUMASSU = I_Numindiv;
*/
--
  CURSOR C_QTTC_GLOBAL
  IS
  SELECT 	'x'
  FROM		QTTC_GLOBAL
  WHERE		QTTC_GLOBAL.NUMINDIV = I_Numindiv
      OR	QTTC_GLOBAL.NUMQUERABLE = I_Numindiv;
--
  CURSOR C_SNTR_PREV
  IS
  SELECT 	'x'
  FROM		SNTR_PREV
  WHERE		SNTR_PREV.IDCORRES = I_Numindiv;
--
  CURSOR C_CONTRAT
  IS
  SELECT 	'x'
  FROM		CONTRAT
  WHERE		CONTRAT.NUMCLI = I_Numindiv
      OR	CONTRAT.NUMINTERM = I_Numindiv
      OR	CONTRAT.DELEGATAIRE = I_Numindiv
      OR        CONTRAT.DELEG_PREST = I_Numindiv
      OR 	CONTRAT.DESTINATAIRE = I_Numindiv;
--
  CURSOR C_ADHE_CNTRT_MEMBRE
  IS
  SELECT 	'x'
  FROM		ADHE_CNTRT_MEMBRE
  WHERE		ADHE_CNTRT_MEMBRE.NUMINDIV = I_Numindiv
      OR	ADHE_CNTRT_MEMBRE.NUMBENE = I_Numindiv;
--
BEGIN
  -- Contrôle des Décaissements
  OPEN C_DECAISMT;
  FETCH C_DECAISMT INTO L_exist;
  IF C_DECAISMT%FOUND
   THEN
     Loc_DB := 'DECAISSEMENT';
  ELSE
     -- Contrôle des Encaissements
     OPEN C_ENCAISMT;
     FETCH C_ENCAISMT INTO L_exist;
     IF C_ENCAISMT%FOUND
      THEN
        Loc_DB := 'ENCAISSEMENT';
     ELSE
        -- Contrôle des Adhésions
        OPEN C_ADHE_CNTRT;
        FETCH C_ADHE_CNTRT INTO L_exist;
        IF C_ADHE_CNTRT%FOUND
         THEN
           Loc_DB := 'ADHESION';
        ELSE
  	   /*
  	 -- Contrôle des Adhésions Collectives
  	 --OPEN C_ADHE_COLLECTIVE;
         --FETCH C_ADHE_COLLECTIVE INTO L_exist;
         --IF C_ADHE_COLLECTIVE%FOUND
         -- THEN
  	     --Loc_DB := 'ADHESION COLLECTIVE';
         --ELSE
  	      -- Contrôle des Adhésions de groupe
  	    --OPEN C_ADH_GRP;
  	    --FETCH C_ADH_GRP INTO L_exist;
  	    --IF C_ADH_GRP%FOUND
  	    -- THEN
  	        --Loc_DB := 'ADHESION GROUPE';
            --ELSE
  	         */
  	         -- Contrôle des Décomptes
  	         OPEN C_DECOMPTE;
  	         FETCH C_DECOMPTE INTO L_exist;
  	         IF C_DECOMPTE%FOUND
  		  THEN
  		     Loc_DB := 'DECOMPTE';
  	         ELSE
  	            /*
  	            -- Contrôle des Dossiers santés
  	          --OPEN C_DOSSIER_SANTE;
  	          --FETCH C_DOSSIER_SANTE INTO L_exist;
  	          --IF C_DOSSIER_SANTE%FOUND
  		  --  THEN
  		       --Loc_DB := 'DOSSIER SANTE';
  	          --ELSE
  		    */
  		       -- Contrôle des Dossiers Sinistres
	               OPEN C_DOSSIER_SINISTRE;
  		       FETCH C_DOSSIER_SINISTRE INTO L_exist;
  		       IF C_DOSSIER_SINISTRE%FOUND
  		         THEN
  			  Loc_DB := 'DOSSIER SINISTRE';
  		       ELSE
                          -- Contrôle des Factures émises
		          OPEN C_FACTURE;
  		          FETCH C_FACTURE INTO L_exist;
  		          IF C_FACTURE%FOUND
  		            THEN
  		             Loc_DB := 'FACTURE';
                          ELSE
  		             /*
  		             -- Contrôle des Dossiers de Recours
		           --OPEN C_RECOURS;
  		           --FETCH C_RECOURS INTO L_exist;
  		           --IF C_RECOURS%FOUND
  		           -- THEN
  			       --Loc_DB := 'RECOURS';
  		           --ELSE
  		                */
  		                -- Contrôle des Quittances émises
		                OPEN C_QTTC_GLOBAL;
  		                FETCH C_QTTC_GLOBAL INTO L_exist;
  		                IF C_QTTC_GLOBAL%FOUND
  			          THEN
  		                   Loc_DB := 'QUITTANCES';
  		                ELSE
  		                   -- Sinistres prévoyances
  			           OPEN C_SNTR_PREV;
  			           FETCH C_SNTR_PREV INTO L_exist;
  			           IF C_SNTR_PREV%FOUND
  			             THEN
  			              Loc_DB := 'SINISTRE PREVOYANCE';
  			           ELSE
  			              -- Contrats en cours
			               OPEN C_CONTRAT;
  			               FETCH C_CONTRAT INTO L_exist;
  			               IF C_CONTRAT%FOUND
  			                 THEN
  				          Loc_DB := 'CONTRAT';
  			               ELSE
  			                  -- Membre d'une adhesion sur un contrat
			                  OPEN C_ADHE_CNTRT_MEMBRE;
  			                  FETCH C_ADHE_CNTRT_MEMBRE INTO L_exist;
  			                  IF C_ADHE_CNTRT_MEMBRE%FOUND
  			                    THEN
  				                   Loc_DB := 'ADHE_CNTRT_MEMBRE';
                          ELSE
			  	                   Loc_DB := NULL;
                          END IF;
                          CLOSE C_ADHE_CNTRT_MEMBRE;
  			               END IF;
  			               CLOSE C_CONTRAT;
  			            END IF;
  			            CLOSE C_SNTR_PREV;
  		                 END IF;
  		                 CLOSE C_QTTC_GLOBAL;
  		          --  END IF;
  		          --  CLOSE C_RECOURS;
  		           END IF;
  		           CLOSE C_FACTURE;
  		        END IF;
  		        CLOSE C_DOSSIER_SINISTRE;
  	         --  END IF;
  	         --  CLOSE C_DOSSIER_SANTE;
  	          END IF;
  	          CLOSE C_DECOMPTE;
  	    -- END IF;
  	    -- CLOSE C_ADH_GRP;
         -- END IF;
  	 -- CLOSE C_ADHE_COLLECTIVE;
         END IF;
         CLOSE C_ADHE_CNTRT;
      END IF;
      CLOSE C_ENCAISMT;
   END IF;
   CLOSE C_DECAISMT;
RETURN (LTRIM (LOC_DB));
END;
