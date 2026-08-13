CREATE FUNCTION ARTHUS.F_GEN_PASSWD (i_profil IN UTILISATEURS.PROFIL%TYPE)
  RETURN VARCHAR2
IS

  loc_lenght_p NUMBER := 13;
  o_passwd VARCHAR2(64):='';

BEGIN

  o_passwd := DBMS_RANDOM.STRING (opt => 'P', len => loc_lenght_p ) 
           || TO_CHAR(DBMS_RANDOM.VALUE (low => 0,  high => 99 ),'FM99') ;


  -- Carcactères interdits : 
  --    @  (pose probleme dans la chaine de connexion Forms)
  --    "  (pose probleme dans la dll UT01)
  --    ^, /, \, '  (déconseillé)
  o_passwd := TRANSLATE(o_passwd, '@^\/"''','abcdef');

  RETURN o_passwd ;

EXCEPTION
  WHEN OTHERS THEN 
     RETURN ('Erreur F_GEN_PASSWD');
END F_GEN_PASSWD;
