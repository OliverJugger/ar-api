CREATE FUNCTION ARTHUS."F_SEL_INTERLOCUTEUR_DEFAUT"( -- fonction qui ramÃ©ne l'interlocuteur valide pour un type d'opÃ©ration courrier(i_codope), ou l'interlocuteur toute opÃ©ration si il existe
         i_numindiv IN INTERLOCUTEUR.NUMINDIV%TYPE, -- NÃ‚Â° de la societe
         i_codope    IN INTERLOCUTEUR.OPE_CRRR%TYPE)    -- NÃ‚Â° codope
      RETURN NUMBER                                   -- NÃ‚Â° d'interlocuteur  (INTERLOCUTEUR.INTERLOCUTEUR)
   AS
/*==============================================================================*/
/* Package      : F_SEL_INTERLOCUTEUR_DEFAUT.sql                                */
/* Domaine      : function                                                      */
/* Version      : V1.0                                                          */
/* Auteur       : CLI                                                           */
/* CrÃ©ation     : 03/07/2014                                                    */
/* Description  : Recherche de l'interlocuteur paramÃ©trÃ© par default en fonction*/
/*                du code opÃ©ration courrier et du numero de l'individu		    */
/* MANTIS       : 4552								                            */
/*==============================================================================*/
 loc_retour NUMBER DEFAULT 0;

  CURSOR c_interlocuteur
    IS
      SELECT INTERLOCUTEUR
	    FROM INTERLOCUTEUR
	    WHERE INTERLOCUTEUR.NUMINDIV = i_numindiv
	    AND INTERLOCUTEUR.OPE_CRRR  in (0,i_codope)--toute opÃ©ration ou opÃ©ration choisi
	    AND INTERLOCUTEUR.VALIDE='O'               -- seulement les interlocuteurs valides
		AND INTERLOCUTEUR.DEFAUT='O'
	   order by INTERLOCUTEUR.OPE_CRRR DESC;
  rec_c_interlocuteur c_interlocuteur%ROWTYPE;
  BEGIN
    BEGIN
      OPEN c_interlocuteur;
        FETCH c_interlocuteur INTO rec_c_interlocuteur;
         IF (c_interlocuteur%FOUND) THEN
           loc_retour := rec_c_interlocuteur.INTERLOCUTEUR;
         ELSE
           loc_retour := 0;
         END IF;
         CLOSE c_interlocuteur;
      END;
      RETURN loc_retour;
   EXCEPTION
   WHEN OTHERS THEN
      RETURN loc_retour;
   END F_SEL_INTERLOCUTEUR_DEFAUT;
