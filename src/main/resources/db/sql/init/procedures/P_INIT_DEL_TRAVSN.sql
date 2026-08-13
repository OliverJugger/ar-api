CREATE PROCEDURE ARTHUS.P_INIT_DEL_TRAVSN
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
/*===========================================================================*/
/* Procedure    : P_INIT_DEL_TRAVSN.sql                                      */
/* Domaine      : Prestation santé                                           */
/* Version      : V1.0                                                       */
/* Auteur       : PHA                                                        */
/* Création     : 08/11/2011                                                 */
/* Description  : Suppression des lignes de TRAVSN qui sont obsolètes        */
/*              : i.e. lignes sans connection avec une saisie                */
/*              : suite à une sortie violente d'arthus par exemple           */
/* Si erreur de droits, se connecter en SYS et donner les droits à ARTHUS :  */
/*               grant select on v_$session to ARTHUS;                       */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/
BEGIN
  -- suppression des lignes de travsn qui portent sur des sessions inexistantes
  -- puis suppression des lignes de travsn qui portent sur des sessions perdues (username non rensigné)
  DELETE FROM travsn
             WHERE ((sid NOT IN (SELECT sid FROM v$session)) OR (sid IN (SELECT sid FROM v$session WHERE username IS NULL)));
  commit ;


EXCEPTION WHEN OTHERS THEN NULL;
END;
/
