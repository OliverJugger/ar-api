CREATE OR REPLACE PACKAGE ARTHUS."PK_WS_CLEAN_DEMANDE"
  as
  /*=========================================================================
  PAckage      : PK_WS_WEB_BACK
  Domaine      : INTERFACE WEB - webservice
  Version      : V1.0
  Auteur       : SDA
  Création     : 17/04/2012
  Description  :
  ==========================================================================
  Evolution    :
  Auteur       :
  Date         :
  Commentaire  :


  */


  FUNCTION delete_rappel(i_idrappel rappel.idrappel%type, i_reference number) return number;

  END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_WS_CLEAN_DEMANDE" as

  FUNCTION delete_rappel(i_idrappel rappel.idrappel%type, i_reference number) return number
  IS
   loc_rappel rappel%rowtype;
   l_idadhesion number;
  BEGIN

    SELECT * INTO loc_rappel
    FROM rappel
    WHERE
    idrappel in(
        select max(idrappel)
        from rappel r2
        where  r2.idrappel = i_idrappel
            OR r2.reference = to_char(i_reference));

    IF loc_rappel.type  = 6  THEN -- ajout d'un contact
       IF loc_rappel.etat <> 4 THEN
          DELETE Contact
          where numindiv = loc_rappel.numbene
          AND type = to_number(F_GET_VALUE_IN_TABLE('Type', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)))
          AND NATURE  = to_number(F_GET_VALUE_IN_TABLE('NATURE', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)))
          AND  FLAG = 'O';

           UPDATE CONTACT SET FLAG = 'O' WHERE IDCONTACT in ( -- réouverture de la potentielle coordonées préalablement fermée
           select  idcontact  from Contact
              where numindiv = loc_rappel.numbene
              AND type = to_number(F_GET_VALUE_IN_TABLE('Type', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)))
              AND NATURE  = to_number(F_GET_VALUE_IN_TABLE('NATURE', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)))
              AND flag = 'N'
              order by idcontact desc
              fetch first 1 row only -- on prend le premier
          )
           ;

       END IF;

      delete rappel where idrappel = loc_rappel.idrappel;

    ELSIF loc_rappel.type IN (20, 26) THEN -- souscription optionnelle ou souscription de base
     l_idadhesion := to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)))  ;

     delete adhesion where idadhesion =   l_idadhesion;
     delete adhe_cntrt where idadhesion = l_idadhesion;
     delete adhe_cntrt_membre where idadhesion = l_idadhesion;

     delete rappel where type in ( 20,23,24,25,26)
     and  (
       to_number(F_GET_VALUE_IN_TABLE('Idadhesion_base', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire)))= l_idadhesion
       OR to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire)))= l_idadhesion
       OR reference = i_reference )
     ;
    commit;


    ELSIF loc_rappel.type IN (22,13) THEN -- ajout d'individu ou de beneficiaire
      IF  loc_rappel.numbene  is not null THEN
        DELETE individu WHERE numindiv = loc_rappel.numbene;
      END IF;
      DELETE RAPPEL WHERE idrappel = loc_rappel.idrappel;

      COMMIT;
    END IF;

  return 0;

  EXCEPTION
  when NO_DATA_FOUND THEN
    RETURN -1;
    WHEN Too_MANY_ROWS THEN
    RETURN 2;
  END;



END PK_WS_CLEAN_DEMANDE;
/
