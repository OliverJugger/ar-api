CREATE FUNCTION ARTHUS.f_nom_reso (
                             a_numporte IN NUMBER,
                             a_longueur IN NUMBER DEFAULT 32
                           )
RETURN VARCHAR2
AS
/*=========================================================================
Fonction     : F_NOM_RESO
Domaine      : tout
Version      : V1.0
Auteur       : PBO
Création     : 19/10/2020
Description  : fonction permettant de ramener le nom d'un réseau de soins
               a partir du numéro de porte du réseau
==========================================================================
Evolution    :
Auteur       :
Date         :
Commentaire  :
==========================================================================
Correction   :
==========================================================================*/

loc_nom_reso    VARCHAR2(100);

BEGIN

  BEGIN

    SELECT nom
      INTO  loc_nom_reso
      FROM  individu, libelle
        WHERE mnemo = 'RES_SANTE'
          AND sens  = a_numporte
           AND individu.numindiv = libelle.code;
    EXCEPTION
      WHEN No_data_found THEN
        loc_nom_reso := 'Réseau de soins inexistant...';
      WHEN OTHERS THEN
        loc_nom_reso := SUBSTR(SQLERRM, 1, a_longueur);

  END;

RETURN ( loc_nom_reso );

END	f_nom_reso;
