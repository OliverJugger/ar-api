CREATE OR REPLACE PACKAGE ARTHUS.pk_cheq_piece AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_cheq_piece.sql	1.1	01/11/21
-- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des constantes publiques --
-- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --
-- -- TYPES PUBLIQUES ---------------------------------------------------------
-- Aucun
-- ------------------------------------------------- Fin des types publiques --
-- -- VARIABLES PUBLIQUES -----------------------------------------------------
-- Aucune
-- --------------------------------------------- Fin des variables publiques --
-- -- PROCEDURES PUBLIQUES ----------------------------------------------------
--
PROCEDURE P_affec_piece(I_numedit      IN decaismt.numedit%TYPE,
		 	I_Num_bque     IN compte.numcpte%TYPE,
			I_prem_cheq    IN Number,
			I_dern_cheq    IN Number,
			I_num_chequier IN Number,
			I_code_pays    IN Number DEFAULT 1);
--
----------------------------------------------------------------------------
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_cheq_piece AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_cheq_piece.sql	1.1	01/11/21
-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --
-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
   E_echec_affect  EXCEPTION;
--
-- ---------------------------------------------- Fin des exceptions privees --
-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --
-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
-- Aucune
-- -------------------------------------- Fin des variables globales privees --
-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
FUNCTION F_CTRL_cheq_annul(I_num_bque     IN Pnul.numcpte%TYPE,
			   I_num_chequier IN Pnul.numchq%TYPE,
			   I_num_cheque   IN Pnul.refpmt%TYPE) RETURN BOOLEAN;
--
--
PROCEDURE P_UPD_decaismt(I_numdecaismt   IN  decaismt.numdecaismt%TYPE,
			 I_num_bque      IN  decaismt.numcpte%TYPE,
		     	 I_num_chequier  IN  decaismt.numchq%TYPE,
		     	 I_num_cheque    IN  decaismt.refpmt%TYPE,
			 O_maj_decaismt  OUT BOOLEAN);
--
--
PROCEDURE P_INS_pnul(I_num_bque     IN Pnul.numcpte%TYPE,
		     I_num_chequier IN Pnul.numchq%TYPE,
		     I_numdecaismt  IN Pnul.numdecaismt%TYPE,
		     I_numaffec     IN Pnul.numaffec%TYPE,
		     I_num_cheque   IN Pnul.refpmt%TYPE,
		     I_mdchq	    IN Prmt.mdchq%TYPE
		     );
--
--
PROCEDURE P_ERREUR(I_code_msg    IN mess_erreur.code_msg%TYPE,
		   I_liste_param IN VARCHAR2,
		   I_code_pays   IN Number,
		   I_ERR_Others  IN BOOLEAN DEFAULT FALSE);
--
-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--
PROCEDURE P_affec_piece(I_numedit      IN decaismt.numedit%TYPE,
		 	I_Num_bque     IN compte.numcpte%TYPE,
			I_prem_cheq    IN Number,
			I_dern_cheq    IN Number,
			I_num_chequier IN Number,
			I_code_pays    IN Number DEFAULT 1) IS
--
  CURSOR C_prmt IS
	SELECT mdchq
	FROM   prmt;
--
  CURSOR C_affec_dcpt IS
	SELECT	affec_dcpt.numaffec,
		affec_dcpt.numdecaismt,
		affec_dcpt.nbpage
	FROM	decaismt,affec_dcpt
	WHERE	affec_dcpt.numedit     = I_numedit
	And	affec_dcpt.numdecaismt = decaismt.numdecaismt
	AND	decaismt.refpmt is null
	ORDER BY affec_dcpt.numordre;
--
  CURSOR C_count_feuillet(P_numdecaismt Number) IS
	SELECT count(*) nb_feuillet
	FROM   Pnul
	WHERE  numdecaismt = P_numdecaismt;
--
  Rec_C_prmt C_prmt%ROWTYPE;
  Rec_C_affec_dcpt C_affec_dcpt%ROWTYPE;
  Rec_C_count_feuillet C_count_feuillet%ROWTYPE;
--
  L_test VARCHAR2(1);
  L_compteur_cheq     NUMBER;
  L_compteur_feuillet NUMBER;
  L_maj_decaismt      BOOLEAN;
  L_code_msg          mess_erreur.code_msg%TYPE;
  L_num_piece         Varchar2(10);
--
BEGIN
  OPEN  C_prmt;
  FETCH C_prmt INTO Rec_C_prmt;
  IF C_prmt%NOTFOUND THEN
     CLOSE C_prmt;
     L_code_msg := 20003;
     Raise E_echec_affect;
  END IF;
  CLOSE C_prmt;
  --
  LOCK TABLE Pnul     IN SHARE UPDATE MODE;
  LOCK TABLE Decaismt IN SHARE UPDATE MODE;
  LOCK TABLE Chequier IN SHARE UPDATE MODE;
  --
  OPEN C_affec_dcpt;
  L_compteur_cheq := I_prem_cheq;
  WHILE L_compteur_cheq <= I_dern_cheq
  LOOP
     IF NOT(F_CTRL_cheq_annul(I_num_bque     => I_num_bque,
			  I_num_chequier => I_num_chequier,
			  I_num_cheque   => L_compteur_cheq)) 	THEN
       FETCH C_affec_dcpt INTO Rec_C_affec_dcpt;
       IF C_affec_dcpt%NOTFOUND THEN
          CLOSE C_affec_dcpt;
          L_code_msg := 20007;
	  Raise E_echec_affect;
       ELSE
	  IF Rec_C_affec_dcpt.nbpage > 1 THEN
	     OPEN C_count_feuillet(P_numdecaismt =>
						Rec_C_affec_dcpt.numdecaismt);
	     FETCH C_count_feuillet INTO Rec_C_count_feuillet;
	     CLOSE C_count_feuillet;
	     L_compteur_feuillet := Rec_C_count_feuillet.nb_feuillet+1;
  	     --
	     WHILE L_compteur_feuillet < Rec_C_affec_dcpt.nbpage
	     LOOP
     		IF NOT(F_CTRL_cheq_annul
				(I_num_bque     => I_num_bque,
				 I_num_chequier => I_num_chequier,
	 			 I_num_cheque       => L_compteur_cheq))  THEN
		   --
		   -- INSERTION dans Pnul des cheques barrees
		   P_INS_pnul(
			I_num_bque     => I_num_bque,
		     	I_num_chequier => I_num_chequier,
			I_numdecaismt  => Rec_C_affec_dcpt.numdecaismt,
			I_numaffec     => Rec_C_affec_dcpt.numaffec,
			I_num_cheque   => L_compteur_cheq,
			I_mdchq		=> Rec_C_prmt.mdchq);
		   --
		   L_compteur_cheq := L_compteur_cheq+1;
		   L_compteur_feuillet := L_compteur_feuillet + 1;
		ELSE
		  L_compteur_feuillet := Rec_C_affec_dcpt.nbpage;
		END IF;
		IF L_compteur_cheq > I_dern_cheq THEN
		   L_num_piece := to_char(Rec_C_affec_dcpt.numaffec);
		   L_code_msg := 20002;
		   Raise E_echec_affect;
		END IF;
	     END LOOP;
	     --
	     IF L_compteur_cheq > I_dern_cheq THEN
		 L_code_msg := 20005;
		 Raise E_echec_affect;
	     END IF;
	  END IF;    -- Fin nbpage > 1
	  --
   	  P_UPD_decaismt(I_numdecaismt   => Rec_C_affec_dcpt.numdecaismt,
			 I_num_bque      => I_num_bque,
		     	 I_num_chequier  => I_num_chequier,
		     	 I_num_cheque    => L_compteur_cheq,
			 O_maj_decaismt  => L_maj_decaismt);
   	 IF NOT L_maj_decaismt THEN
	    L_code_msg := 20006;
	    Raise E_echec_affect;
	 END IF;
        END IF;   -- Fin C_affec_dcpt%FOUND
      END IF;   -- Fin NOT(F_CTRL_cheq_annul)
      L_compteur_cheq := L_compteur_cheq+1;
  END LOOP;
  CLOSE C_affec_dcpt;
  --
  L_compteur_cheq := L_compteur_cheq-1;
  IF L_compteur_cheq > I_dern_cheq THEN
	L_code_msg := 20002;
	L_num_piece := to_char(Rec_C_affec_dcpt.numaffec);
	Raise E_echec_affect;
  END IF;
  --
  UPDATE chequier
  SET    derchq = L_compteur_cheq
  WHERE  numchq = I_num_chequier;
  IF SQL%NOTFOUND THEN
     L_code_msg := 20004;
     Raise E_echec_affect;
  END IF;
  --
  UPDATE chequier
  SET    Fin = SYSDATE
  WHERE  numchq = I_num_chequier
  AND    derchq >= premchq+nbrechq-1;
--
EXCEPTION
  WHEN E_ECHEC_affect THEN
       P_ERREUR(I_code_msg     => L_code_msg,
		I_liste_param => L_num_piece,
		I_code_pays   => I_code_pays);
    --
  WHEN OTHERS THEN
       P_ERREUR(I_code_msg     => 20001,
		I_liste_param => 'Pk_cheq_piece',
		I_code_pays   => I_code_pays,
		I_ERR_Others  => TRUE);
END;
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--
FUNCTION F_CTRL_cheq_annul(I_num_bque     IN Pnul.numcpte%TYPE,
			   I_num_chequier IN Pnul.numchq%TYPE,
			   I_num_cheque   IN Pnul.refpmt%TYPE) RETURN BOOLEAN
IS
  CURSOR  C_pnul IS
	SELECT 'X'
	FROM   Pnul
	WHERE  numcpte = I_num_bque
	AND    numchq  = I_num_chequier
	AND    refpmt  = I_num_cheque;
--
  L_test Varchar2(1);
  L_exist BOOLEAN;
--
BEGIN
  OPEN  C_pnul;
  FETCH C_pnul INTO L_test;
  IF C_pnul%FOUND THEN
     L_exist := TRUE;
  ELSE
     L_exist := FALSE;
  END IF;
  CLOSE C_pnul;
  --
  RETURN(L_exist);
END;
--
--
PROCEDURE P_INS_pnul(I_num_bque     IN Pnul.numcpte%TYPE,
		     I_num_chequier IN Pnul.numchq%TYPE,
		     I_numdecaismt  IN Pnul.numdecaismt%TYPE,
		     I_numaffec     IN Pnul.numaffec%TYPE,
		     I_num_cheque   IN Pnul.refpmt%TYPE,
		     I_mdchq	    IN Prmt.mdchq%TYPE
		     )
IS
--
BEGIN
  INSERT INTO Pnul (numcpte,numchq,numdecaismt,numaffec,refpmt,modpmt,
		    datpay,datannul,motif,userid)
  VALUES(I_num_bque,I_num_chequier,I_numdecaismt,I_numaffec,
	 I_num_cheque,I_mdchq, trunc(sysdate),trunc(sysdate),0,F_numutil);
END;
-- ------------------------------------ Fin des corps des procedures privees --
--
--
PROCEDURE P_UPD_decaismt(I_numdecaismt   IN  decaismt.numdecaismt%TYPE,
			 I_num_bque      IN  decaismt.numcpte%TYPE,
		     	 I_num_chequier  IN  decaismt.numchq%TYPE,
		     	 I_num_cheque    IN  decaismt.refpmt%TYPE,
			 O_maj_decaismt  OUT BOOLEAN)
IS
BEGIN
  UPDATE decaismt
  SET    numcpte   = I_num_bque,
	 numchq    = I_num_chequier,
	 refpmt    = I_num_cheque
  WHERE  numdecaismt = I_numdecaismt;
  IF SQL%FOUND THEN
     O_maj_decaismt := TRUE;
  ELSE
     O_maj_decaismt := FALSE;
  END IF;
END;
--
--
PROCEDURE P_ERREUR(I_code_msg    IN mess_erreur.code_msg%TYPE,
		   I_liste_param IN VARCHAR2,
		   I_code_pays   IN Number,
		   I_ERR_Others  IN BOOLEAN DEFAULT FALSE)
IS
--
 L_lib_msg mess_erreur.lib_msg%TYPE;
--
BEGIN
    -- Recherche du message dans la table
    L_lib_msg:= pk_trace.F_aff_mess_err
                                   ( I_code_msg    => I_code_msg,
                                     I_code_pays   => I_code_pays,
                                     I_liste_param => I_liste_param);
    IF I_ERR_Others THEN
      -- message de la table + erreur Oracle
      L_lib_msg := L_lib_msg||Substr(sqlerrm(sqlcode),1,80 -
                                               length(L_lib_msg));
    END IF;
    --
    -- Retour du message vers les postes clients a trapper(dans Sqlforms) par
    -- le "when others" --> procedure "message_oracle" et STOP --> "RAISE
    -- Form_trigger_failure"
    RAISE_APPLICATION_ERROR((I_code_msg * -1),L_lib_msg);
--
END;
--
END;
/
