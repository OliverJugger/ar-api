CREATE FUNCTION ARTHUS.F_STR_TO_NUMBER( i_str IN VARCHAR2 )
RETURN NUMBER
IS

/*---------------------------------------------------------------------------*/
/* Nom          :  F_STR_TO_NUMBER                                           */
/* Description  :  convertir une chaine de caractères en number en appelant
                   la fonction native oracle TO_NUMBER + gestion d'exception */
/* Entree       :  chaine de caractère                                       */
/* Retour       :  number                                                    */
/*---------------------------------------------------------------------------*/
  l_num NUMBER;
BEGIN
  l_num := to_number( i_str );
  RETURN l_num;
EXCEPTION
  WHEN value_error
  THEN
    RETURN NULL;
END F_STR_TO_NUMBER;
