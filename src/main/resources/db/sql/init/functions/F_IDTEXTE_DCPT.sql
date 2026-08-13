CREATE FUNCTION ARTHUS."F_IDTEXTE_DCPT" (
   a_contexte   IN   NUMBER,
   a_numero     IN   NUMBER,
   a_code       IN   NUMBER,
   a_modpmt     IN   NUMBER,
   a_typedest   IN   NUMBER DEFAULT NULL
)
   RETURN NUMBER
AS
   idtexte   NUMBER;
BEGIN
   SELECT valide_texte.idtexte
     INTO idtexte
     FROM valide_texte, param_texte
    WHERE valide_texte.idtexte = param_texte.idtexte
      AND valide_texte.contexte = a_contexte
      AND valide_texte.numero = a_numero
      AND param_texte.code = a_code
      AND valide_texte.mod_pmt = a_modpmt
	    AND NVL(valide_texte.type_dest,15) = NVL(a_typedest,15)  --15 adhérent par défaut
    --  AND valide_texte.type_dest=15
      ; 

   RETURN idtexte;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN NULL;
END f_idtexte_dcpt;
