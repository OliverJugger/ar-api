CREATE FUNCTION ARTHUS."F_PIECE_BLOCAGE" (a_idrepartition IN NUMBER, a_numbene IN NUMBER, a_contexte IN NUMBER default null)
   RETURN INTEGER
AS
/*============================================================================*/
/* FUNCTION     : F_PIECE_BLOCAGE.sql                                         */
/* Domaine      : Courrier                                                    */
/* Version      : V1.0                                                        */
/* Auteur       :                                                             */
/* Création     : 2007                                                        */
/* Description  : Detection d'un blocage sur les pieces d'un dossier ou bene  */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : ABO 06/06/2012 ajout du contexte pour blocage prest. sante  */
/* Correction   : PHA 25/08/2014 gestion prevoyance tout destinataire sinistre*/
/* Correction   : PHA 06/09/2016 prise en compte de la date d'annulation      */
/*============================================================================*/
   loc_blocage   INTEGER;
BEGIN
   loc_blocage := 0;

   BEGIN
      SELECT 1
        INTO loc_blocage
        FROM DUAL
       WHERE EXISTS (
                SELECT 1
                  FROM pieces
                 WHERE NVL (pieces.bloc, 'N') = 'O'
                   AND pieces.daterecep IS NULL
                   AND pieces.datannul  IS NULL
                   AND pieces.dateavis  IS NOT NULL
                   AND pieces.idrepartition = a_idrepartition
                   AND ((pieces.numbene     = a_numbene AND pieces.idrepartition = 0)
                       OR
                       (pieces.idrepartition>0))
                   AND pieces.contexte      = NVL(a_contexte,pieces.contexte));
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         loc_blocage := 0;
   END;

   RETURN (loc_blocage);
END;
