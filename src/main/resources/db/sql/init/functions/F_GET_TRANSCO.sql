CREATE FUNCTION ARTHUS.F_GET_TRANSCO (p_tiers in varchar2,
		                     p_mnemo in varchar2,
                         p_val in varchar2,
                         p_sens in integer default 1)
return VARCHAR2
/******************************************************************************/
-- F_GET_TRANSCO -- Fonction de transcodification
/******************************************************************************/
-- XHUE le 13/07/2010
/******************************************************************************/
-- Paramètres entrée
--             p_tiers : Identifiant du tiers
--             p_mnemo : Mnemo de la donnée à transcodifier
--             p_val : Valeur 
--             p_sens : si 1 renvoit val_ext si 2 renvoit val_int
-- sortie
--             Valeur externe
/******************************************************************************/
is
	CURSOR cur_transco_ext IS
    SELECT val_ext
    FROM transco
    WHERE tiers = p_tiers
    AND mnemo = p_mnemo
    AND UPPER(val_int) = UPPER(p_val);

  CURSOR cur_transco_int IS
    SELECT val_int
    FROM transco
    WHERE tiers = p_tiers
    AND mnemo = p_mnemo
    AND UPPER(val_ext) = UPPER(p_val); 

   v_val transco.val_ext%type;

BEGIN
  IF p_sens = 1 THEN
    OPEN cur_transco_ext;
    FETCH cur_transco_ext into v_val;
    CLOSE cur_transco_ext;
   
  ELSIF p_sens=2 THEN
    OPEN cur_transco_int;
    FETCH cur_transco_int into v_val;
    CLOSE cur_transco_int;
  
  END IF;
  RETURN (v_val);
END;
