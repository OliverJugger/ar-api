CREATE PROCEDURE ARTHUS.P_LOCK_USER_INACTIF
/*===========================================================================*/
/* Procedure    : P_LOCK_USER_INACTIF.sql                                    */
/* Domaine      : Paramètre/système/utilisateur                              */
/* Version      : V1.0                                                       */
/* Auteur       : PHA                                                        */
/* Création     : 11/08/2014                                                 */
/* Description  : Lock utilisateurs Arthus dont la date de fin est passée    */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
IS

--
   CURSOR c_user_fin
   IS
    SELECT u.nom FROM UTILISATEURS u, dba_users d 
                 WHERE NVL(u.date_fin,SYSDATE+1)<SYSDATE
                   AND d.username = u.nom
                   AND ACCOUNT_STATUS NOT LIKE '%LOCKED%' ;

r_user_fin   c_user_fin%ROWTYPE;
v_sql VARCHAR2(200);
--
BEGIN

--

  OPEN c_user_fin;

  LOOP
    FETCH c_user_fin INTO r_user_fin;

    EXIT WHEN c_user_fin%NOTFOUND;

    BEGIN
      v_sql := 'ALTER USER '||r_user_fin.nom||' ACCOUNT LOCK';
      EXECUTE IMMEDIATE v_sql;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;

  END LOOP;

  CLOSE c_user_fin;

EXCEPTION WHEN OTHERS THEN NULL;

END P_LOCK_USER_INACTIF;
/
