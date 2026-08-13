CREATE function ARTHUS.f_ctrl_remise_banque (p_numencaismt IN NUMBER default 1)
return number
IS
CURSOR C_REMISE_BANQUE
IS
    SELECT REMISE_BANQUE.NUMREMISE
    FROM REMISE_BANQUE
    WHERE REMISE_BANQUE.NUMENCAISMT = p_numencaismt;

REC_RB              C_REMISE_BANQUE%ROWTYPE;
FLAG_REMISE_GLOBALE PARAMETRES.CODE_RG%TYPE;
--
loc_retour		number;
--
BEGIN
--
SELECT ALL PARAMETRES.CODE_RG
INTO FLAG_REMISE_GLOBALE
FROM PARAMETRES;
--
IF FLAG_REMISE_GLOBALE = 2     -- Affectation inconditionnelle
	THEN
		loc_retour := 2;    -- Affectation acceptée
ELSE
OPEN C_REMISE_BANQUE;
FETCH C_REMISE_BANQUE INTO REC_RB;
	IF C_REMISE_BANQUE%FOUND
		THEN
			IF REC_RB.NUMREMISE > 0     -- Remise validée
				THEN
                    loc_retour := 2; 	-- Affectation acceptée
            ELSE
                    loc_retour := 1;    -- Remise non validée
            END IF;
    ELSE
        loc_retour := 2;    -- Paiement CASH, Virement, CB
    END IF;
CLOSE C_REMISE_BANQUE;
END IF;
--
Return ( loc_retour );
--
END f_ctrl_remise_banque;
