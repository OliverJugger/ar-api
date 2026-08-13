CREATE FUNCTION ARTHUS.F_IDTEXTE(a_contexte   IN NUMBER,
                            a_numero     IN NUMBER,
                            a_code       IN NUMBER,
                            a_nom        IN VARCHAR2 DEFAULT '',
                            a_numrelance IN NUMBER DEFAULT NULL,
                            a_type       IN NUMBER DEFAULT NULL,
                            a_role       IN NUMBER DEFAULT NULL,
                            a_modpmt     IN NUMBER DEFAULT NULL,
                            a_nb_rel     IN NUMBER DEFAULT NULL
                            )
  RETURN NUMBER
AS
  idtexte        NUMBER;
  loc_contexte   NUMBER := a_contexte;
  old_contexte   NUMBER := a_contexte;
  comm_contexte  NUMBER := a_contexte;
  loc_code       NUMBER := a_code;
  loc_nom        VARCHAR2(9) := a_nom;
  loc_numrelance NUMBER := a_numrelance;
  loc_numero     NUMBER := a_numero;
  comm_numero    NUMBER := a_numero;
  -- Mantis n°3141
  loc_type_dest  NUMBER;
  loc_nb_rel     NUMBER := a_nb_rel;
BEGIN

/*---------------------------------------------------------------------------*/
/* FONCTION     :                                                            */
/* Nom          :  F_IDTEXTE                                                 */
/* Domaine      :  Editique                                                  */
/* Version      :  V1.0                                                      */
/* Auteur       :  ARTHUS                                                    */
/* Création     :  DD/MM/AAAA                                                */
/* Description  :  Retourne le numéro idtexte du courrier                    */
/* Entree       :  contexte, numero, code, nom, numrelance, type, role,      */
/*                 modpmt, nb_rel                                            */
/* Retour       :  idtexte, null si pas trouvé                               */

/* Description  : Expliquer le but du programme sur plusieurs lignes si      */
/*              : nécessaire                                                 */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : PHA-15/03/2016-M4993 clause sur type_dest trop restrictive */
/*---------------------------------------------------------------------------*/
  -- Gestion du Type de Destinataire
  CASE
    WHEN a_contexte = 2 AND a_code  = 2 THEN loc_type_dest := a_type;
  ELSE
    loc_type_dest := NULL;
  END CASE;
<<debut>>
  BEGIN

      SELECT DISTINCT pt.idtexte
      INTO idtexte
      FROM valide_texte vt,
        param_texte pt
      WHERE pt.idtexte    = vt.idtexte
      AND pt.contexte = loc_contexte
      AND pt.numero     = loc_numero
      AND pt.code       = loc_code
      AND pt.nom_crrr   = NVL (loc_nom, pt.nom_crrr)
      AND pt.numrelance = NVL (loc_numrelance, pt.numrelance)
      AND pt.nb_rel     = NVL (loc_nb_rel, pt.nb_rel)
      AND vt.numero     = comm_numero
      AND vt.contexte   = comm_contexte
      AND ((loc_type_dest IS NULL)
       OR (loc_type_dest < 0)
       OR (loc_type_dest >= 0 AND vt.type_dest  = loc_type_dest)
      )
      ;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (loc_contexte = 10 AND old_contexte = 10) THEN
        BEGIN
          SELECT numfor_ref,
            10,
            ''
          INTO loc_numero,
            loc_contexte,
            old_contexte
          FROM gar_cntrt
          WHERE numfor = a_numero;
          GOTO debut;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          old_contexte := '';
          GOTO debut;
        END;
      ELSIF (old_contexte IS NULL AND loc_contexte = 10)
        -- On recupere le texte garantie au niveau general
        THEN
        BEGIN
          loc_numero   := 0;
          loc_contexte := 99;
          old_contexte := '';
          GOTO debut;
        END;
      ELSIF (old_contexte IS NULL AND loc_contexte = 99)
        -- On recupere le texte du paragraphe au niveau general
        THEN
        BEGIN
          loc_numero   := 0;
          loc_contexte := -99;
          old_contexte := '';
          GOTO debut;
        END;
        -- On regarde s'il existe un texte particulier niveau produit
      ELSIF (loc_contexte = 2 AND comm_contexte != 10) THEN
        loc_contexte     := 7;
        SELECT numprod INTO loc_numero FROM contrat WHERE numgar = a_numero;
        GOTO debut;
      ELSIF (loc_contexte = 2 AND comm_contexte = 10) THEN
        loc_contexte     := 7;
        SELECT numprod
        INTO loc_numero
        FROM contrat,
          gar_cntrt
        WHERE contrat.numgar = gar_cntrt.numgar
        AND numfor           = a_numero;
        GOTO debut;
      ELSIF (loc_contexte = 7) THEN
        -- On regarde s'il existe un texte general
        loc_contexte := 99;
        loc_numero   := 0;
        GOTO debut;
      ELSIF loc_type_dest IS NOT NULL THEN
        -- Recherche d'un modèle valide, quelques soit le type de destinaire...
        loc_type_dest := NULL;
        GOTO debut;
      END IF;
    END;

  RETURN idtexte;
EXCEPTION
  WHEN TOO_MANY_ROWS THEN RETURN NULL;
END f_idtexte;
