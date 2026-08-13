CREATE OR REPLACE PACKAGE ARTHUS.PK_TRACE AS
-- Chaine de reconnaissance SCCS
-- %W%	%E%
--
-- ============================================================================
-- CONSTANTES PUBLIQUE
-- Aucune
-- ============================ Fin des Constantes Publiques ===============

-- ============================================================================
-- EXCEPTIONS PUBLIQUES
-- Aucune
-- ============================ Fin des Exceptions Publiques ==================

-- ============================================================================
-- ========================== Fin des types publiques =========================

-- ============================================================================
-- VARIABLES PUBLIQUES
--
-- ========================== Fin des Variables publiques =====================

-- ============================================================================
-- PROCEDURES ET FONCTIONS PUBLIQUES

PROCEDURE P_INS_journal_adm
              ( I_nom_traitement journal_adm.nom_traitement%TYPE,
                I_session        journal_adm.id_session%TYPE,
                I_niv_msg        journal_adm.niv_msg%TYPE,
                I_msg_adm        journal_adm.msg_adm%TYPE,
                I_date           journal_adm.date_adm%TYPE DEFAULT SYSDATE,
		I_idligne	journal_adm.idligne%Type Default 0);
--
-- Retourne le message de mess_erreur integrant les parametres ainsi que le type
--
PROCEDURE P_AFF_mess_err
          ( I_code_msg    IN  NUMBER,
            I_code_pays   IN  NUMBER,
            I_liste_param IN  VARCHAR2 DEFAULT '|',
            O_type_msg    OUT mess_erreur.Type_msg%TYPE,
            O_lib_msg     OUT mess_erreur.lib_msg%TYPE);
--
-- Retourne le message de mess_err_calc integrant les parametres ainsi que le type
--
PROCEDURE P_SEL_mess_err_calc (
			I_idfonction	IN	mess_err_calc.idfonction%Type,
			I_code_msg    	IN  	NUMBER,
			I_code_pays   	IN  	NUMBER,
			I_liste_param 	IN  	VARCHAR2 DEFAULT '|',
			O_type_msg    	OUT 	mess_err_calc.Type_msg%TYPE,
			O_lib_msg     	OUT 	mess_err_calc.lib_msg%TYPE
			);
--
FUNCTION F_AFF_mess_err
           ( I_code_msg    IN NUMBER,
             I_code_pays   IN NUMBER,
             I_liste_param IN VARCHAR2 DEFAULT '|')RETURN VARCHAR2;
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_TRACE AS
-- Chaine de reconnaissance SCCS
-- %W%	%E%

-- ============================================================================
-- CONSTANTES PRIVEES
--
-- ========================== Fin des constantes privees ======================

-- ============================================================================
-- -- EXCEPTIONS PRIVEES
-- Aucune
-- ========================== Fin des exceptions privees ======================

-- ============================================================================
-- TYPES PRIVEES
-- Aucun
-- ========================== Fin des types privees ===========================

-- ============================================================================
-- VARIABLES GLOBALES PRIVEES
--@global
G_erreur		journal_adm.msg_adm%Type;
-- Flag de commit ou rollback a retourner a Forms
G_commit	Boolean := FALSE;
G_rollback	Boolean := FALSE;
G_auto_valide	Boolean := FALSE;
--
-- ===================== Fin des variables globales privees ===================

-- ============================================================================
-- DEFINITION DES PROCEDURES PRIVEES
--
-- ============== Fin des definitions des procedures privees =================

-- ============================================================================
-- CORPS DES PROCEDURES PUBLIQUES
--
FUNCTION F_AFF_mess_err
         (I_code_msg    IN NUMBER,
          I_code_pays   IN NUMBER,
          I_liste_param IN VARCHAR2 DEFAULT '|')RETURN VARCHAR2
IS
         w_lib_msg       VARCHAR2(255) := NULL; -- Lib du message de la base
      --
         CURSOR C_MESSAGE IS
            SELECT lib_msg
            FROM   mess_erreur
            WHERE  code_msg  = I_code_msg
            AND    code_pays = I_code_pays;
      --
         l_liste_param   VARCHAR2(255);   -- Liste de travail des parametres
         l_param         VARCHAR2(255);   -- parametre extrait
         l_lib_msg_aff   VARCHAR2(255);   -- Lib du message affiche
         l_pipe          NUMBER;          -- Position du premier |
         l_arobase       NUMBER;          -- Position du premier @
      --
      BEGIN
      -- Controle de la liste des parametres
       L_liste_param := I_liste_param;
       IF SUBSTR(l_liste_param, LENGTH(l_liste_param), 1) != '|' THEN
            l_liste_param := I_liste_param||'|';
       END IF;
      --
      -- Recherche du message
         OPEN c_message;
         FETCH c_message INTO w_lib_msg;
         IF c_message%NOTFOUND THEN
               l_lib_msg_aff := F_AFF_mess_err
                                      (I_code_msg  => 0,
				       I_code_pays => I_code_pays,
				       I_liste_param => to_char(I_code_msg));
         ELSE
         -- Remplacement des parametres
         --
         -- Tant qu'il existe des | dans la liste et des @ dans le message
            l_pipe := INSTR(l_liste_param, '|');
            l_arobase := INSTR(w_lib_msg, '@');
            WHILE (l_pipe > 0 AND l_arobase > 0) LOOP
               -- Extraction du parametre
                  l_param := SUBSTR(l_liste_param, 1, l_pipe - 1);
                  l_liste_param := SUBSTR(l_liste_param, l_pipe + 1);
               -- Concatenation du debut du message jusqu'au premier @
               -- avec le parametre
               l_lib_msg_aff := l_lib_msg_aff
                              ||SUBSTR(w_lib_msg, 1, l_arobase - 1)
                              ||l_param;
               w_lib_msg := SUBSTR(w_lib_msg, l_arobase + 1);
               -- Recherche des | et @ suivants
               l_pipe := INSTR(l_liste_param, '|');
               l_arobase := INSTR(w_lib_msg, '@');
            END LOOP;
            --
             -- Concatenation de la fin du message
             L_lib_msg_aff := L_lib_msg_aff||w_lib_msg;
             --
         /*   IF I_code_msg BETWEEN 20000 AND 20999 THEN
              -- Message utilisateur ORACLE, sur 5 pos.
                l_lib_msg_aff := 'E'||TO_CHAR(I_code_msg)||': '||
                                 l_lib_msg_aff||w_lib_msg;
              ELSE
                l_lib_msg_aff := 'E'||LPAD(TO_CHAR(I_code_msg), 4, '0')||': '||
                                  l_lib_msg_aff||w_lib_msg;
              END IF;
        */
         END IF;
         --
         -- Affichage du message
         RETURN l_lib_msg_aff;
      END;
--
PROCEDURE P_AFF_mess_err
          ( I_code_msg    IN  NUMBER,
            I_code_pays   IN  NUMBER,
            I_liste_param IN  VARCHAR2 DEFAULT '|',
            O_type_msg    OUT mess_erreur.Type_msg%TYPE,
            O_lib_msg     OUT mess_erreur.lib_msg%TYPE)
IS
         w_lib_msg       VARCHAR2(255) := NULL; -- Lib du message de la base
         w_type_msg      Number(2)     := NULL;  -- Type de message
      --
         CURSOR C_MESSAGE IS
            SELECT lib_msg,type_msg
            FROM   mess_erreur
            WHERE  code_msg  = I_code_msg
            AND    code_pays = I_code_pays;
      --
         l_liste_param   VARCHAR2(255);   -- Liste de travail des parametres
         l_param         VARCHAR2(255);   -- parametre extrait
         l_lib_msg_aff   VARCHAR2(255);   -- Lib du message affiche
         l_pipe          NUMBER;          -- Position du premier |
         l_arobase       NUMBER;          -- Position du premier @
      --
      BEGIN
      -- Controle de la liste des parametres
       L_liste_param := I_liste_param;
       IF SUBSTR(l_liste_param, LENGTH(l_liste_param), 1) != '|' THEN
            l_liste_param := I_liste_param||'|';
       END IF;
      --
      -- Recherche du message
         OPEN c_message;
         FETCH c_message INTO w_lib_msg,w_type_msg;
         IF c_message%NOTFOUND THEN
                P_AFF_mess_err (I_code_msg    => 0,
			        I_code_pays   => I_code_pays,
			        I_liste_param => to_char(I_code_msg),
                                O_Type_msg    => w_type_msg,
                                O_lib_msg     => L_lib_msg_aff);
         ELSE
         -- Remplacement des parametres
         --
         -- Tant qu'il existe des | dans la liste et des @ dans le message
            l_pipe := INSTR(l_liste_param, '|');
            l_arobase := INSTR(w_lib_msg, '@');
            WHILE (l_pipe > 0 AND l_arobase > 0) LOOP
               -- Extraction du parametre
                  l_param := SUBSTR(l_liste_param, 1, l_pipe - 1);
                  l_liste_param := SUBSTR(l_liste_param, l_pipe + 1);
               -- Concatenation du debut du message jusqu'au premier @
               -- avec le parametre
               l_lib_msg_aff := l_lib_msg_aff
                              ||SUBSTR(w_lib_msg, 1, l_arobase - 1)
                              ||l_param;
               w_lib_msg := SUBSTR(w_lib_msg, l_arobase + 1);
               -- Recherche des | et @ suivants
               l_pipe := INSTR(l_liste_param, '|');
               l_arobase := INSTR(w_lib_msg, '@');
            END LOOP;
            --
            -- Concatenation de la fin du message
            IF I_code_msg BETWEEN 20000 AND 20999 THEN
            -- Message utilisateur ORACLE, sur 5 pos.
               l_lib_msg_aff := 'E'||TO_CHAR(I_code_msg)||': '||
                                l_lib_msg_aff||w_lib_msg;
            ELSE
              l_lib_msg_aff := 'E'||LPAD(TO_CHAR(I_code_msg), 4, '0')||': '||
                                l_lib_msg_aff||w_lib_msg;
            END IF;
         END IF;
         --
         -- Affichage du message
         O_lib_msg  := L_lib_msg_aff;
         O_type_msg := w_type_msg;
      END;

--
-- Retourne le message de mess_err_calc integrant les parametres ainsi que le type
--
PROCEDURE P_SEL_mess_err_calc (
			I_idfonction	IN	mess_err_calc.idfonction%Type,
			I_code_msg    	IN  	NUMBER,
			I_code_pays   	IN  	NUMBER,
			I_liste_param 	IN  	VARCHAR2 DEFAULT '|',
			O_type_msg    	OUT 	mess_err_calc.Type_msg%TYPE,
			O_lib_msg     	OUT 	mess_err_calc.lib_msg%TYPE
			)
IS
--
CURSOR C_MESSAGE IS
	SELECT	lib_msg,
			type_msg
	FROM   	mess_err_calc
	WHERE  	idfonction = I_idfonction
	And		code_msg  = I_code_msg
	And    	code_pays = I_code_pays;
--
L_lib_msg       VARCHAR2(255) := NULL; -- Lib du message de la base
L_type_msg      Number(2)     := NULL;  -- Type de message
L_liste_param   VARCHAR2(255);   -- Liste de travail des parametres
L_param         VARCHAR2(255);   -- parametre extrait
L_lib_msg_aff   VARCHAR2(255);   -- Lib du message affiche
L_pipe          NUMBER;          -- Position du premier |
L_arobase       NUMBER;          -- Position du premier @
--
BEGIN
-- Controle de la liste des parametres
L_liste_param := I_liste_param;
IF SUBSTR(L_liste_param, LENGTH(L_liste_param), 1) != '|' THEN
	L_liste_param := I_liste_param||'|';
END IF;
--
-- Recherche du message
OPEN c_message;
FETCH c_message INTO L_lib_msg,L_type_msg;
IF c_message%NOTFOUND THEN
	P_AFF_mess_err (
		I_code_msg    => 0,
		I_code_pays   => I_code_pays,
		I_liste_param => to_char(I_code_msg),
		O_Type_msg    => L_type_msg,
		O_lib_msg     => L_lib_msg_aff);
ELSE
	--
	-- Remplacement des parametres
	--
	-- Tant qu'il existe des | dans la liste et des @ dans le message
	L_pipe := INSTR(L_liste_param, '|');
	L_arobase := INSTR(L_lib_msg, '@');
	WHILE (L_pipe > 0 AND L_arobase > 0) LOOP
		-- Extraction du parametre
		L_param := SUBSTR(L_liste_param, 1, L_pipe - 1);
		L_liste_param := SUBSTR(L_liste_param, L_pipe + 1);
		-- Concatenation du debut du message jusqu'au premier @
		-- avec le parametre
		L_lib_msg_aff := L_lib_msg_aff
				||SUBSTR(L_lib_msg, 1, L_arobase - 1)
				||L_param;
		L_lib_msg := SUBSTR(L_lib_msg, L_arobase + 1);
		-- Recherche des | et @ suivants
		L_pipe := INSTR(L_liste_param, '|');
		L_arobase := INSTR(L_lib_msg, '@');
	END LOOP;
	--
	-- Concatenation de la fin du message
	IF I_code_msg BETWEEN 20000 AND 20999 THEN
		-- Message utilisateur ORACLE, sur 5 pos.
		L_lib_msg_aff := 'E'||TO_CHAR(I_code_msg)||': '||
					L_lib_msg_aff||L_lib_msg;
	ELSE
		If ( L_type_msg = 0 ) then
			L_lib_msg_aff := 'E'||LPAD(TO_CHAR(I_code_msg), 4, '0')
				||': '||L_lib_msg_aff||L_lib_msg;
		Else
			L_lib_msg_aff := L_lib_msg_aff||L_lib_msg;
		End If;
	END IF;
END IF;
--
O_lib_msg  := L_lib_msg_aff;
O_type_msg := L_type_msg;
END P_SEL_mess_err_calc;
--
PROCEDURE P_INS_journal_adm
              ( I_nom_traitement journal_adm.nom_traitement%TYPE,
                I_session        journal_adm.id_session%TYPE,
                I_niv_msg        journal_adm.niv_msg%TYPE,
                I_msg_adm        journal_adm.msg_adm%TYPE,
                I_date           journal_adm.date_adm%TYPE DEFAULT SYSDATE,
		I_idligne	journal_adm.idligne%Type Default 0)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
 --
  INSERT INTO journal_adm( nom_traitement,
                           id_session,
                           niv_msg,
                           msg_adm,
                           date_adm,
			   idligne
                         )
  VALUES                 ( I_nom_traitement,
                           I_session,
                           I_niv_msg,
                           substr(I_msg_adm,1,132),
                           I_date,
			   I_idligne);
	COMMIT;
END;
--
-- ========================== Fin des corps des procedures publiques===========

END;
/
