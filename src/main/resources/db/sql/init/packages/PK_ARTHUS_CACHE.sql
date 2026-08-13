CREATE OR REPLACE PACKAGE ARTHUS.PK_ARTHUS_CACHE AS
/*===========================================================================*/
/* Package      : PK_ARTHUS_CACHE.sql                                           */
/* Domaine      : Editique                                                   */
/* Version      : V1.0                                                       */
/* Auteur       : ARTHUS                                                     */
/* Création     : 22/12/2021                                                 */
/* Description  : Package utilisé pour la mise en cache des compteurs        */
/*                                    du webservice boardcounter             */
/*              :                                                            */
/*              :                                                            */
FUNCTION F_GET_CACHED_VALUE (I_TYPE IN ARTHUS_CACHE.TYPE_CACHE%TYPE, I_CLE IN ARTHUS_CACHE.CLE%TYPE) RETURN ARTHUS_CACHE.VALEUR%TYPE;
FUNCTION F_GET_DELAY (I_TYPE IN ARTHUS_CACHE.TYPE_CACHE%TYPE) RETURN NUMBER;
PROCEDURE P_INVALID_VALUE (I_TYPE IN ARTHUS_CACHE.TYPE_CACHE%TYPE, I_CLE IN ARTHUS_CACHE.CLE%TYPE);
PROCEDURE P_REFRESH_PEREMPTION (I_TYPE IN ARTHUS_CACHE.TYPE_CACHE%TYPE, I_CLE IN ARTHUS_CACHE.CLE%TYPE);
PROCEDURE P_REFRESH_CACHE (I_TYPE IN ARTHUS_CACHE.TYPE_CACHE%TYPE, I_CLE IN ARTHUS_CACHE.CLE%TYPE);


END PK_ARTHUS_CACHE;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_ARTHUS_CACHE AS

FUNCTION F_GET_CACHED_VALUE (I_TYPE IN ARTHUS_CACHE.TYPE_CACHE%TYPE, I_CLE IN ARTHUS_CACHE.CLE%TYPE)
RETURN ARTHUS_CACHE.VALEUR%TYPE
IS
  loc_TYPE  ARTHUS_CACHE.TYPE_CACHE%TYPE;
  loc_arthus_cache ARTHUS_CACHE%ROWTYPE;
  loc_valeur       ARTHUS_CACHE.VALEUR%TYPE;
  l_req            varchar2(1000);
  loc_deb          number;
  loc_tps_calcul   number;

BEGIN
  DBMS_OUTPUT.put_line ('bco 0');

  loc_deb:=DBMS_UTILITY.GET_TIME ;

  loc_TYPE := UPPER(I_TYPE);

  begin
    select *
    into loc_arthus_cache
    from ARTHUS_CACHE where TYPE_CACHE=loc_TYPE and CLE=I_CLE;
  exception
    when no_data_found then
      loc_arthus_cache.DATE_PEREMPTION := e2d('01/01/1900');
      loc_arthus_cache.TYPE_CACHE      := NULL;
  end;

  DBMS_OUTPUT.put_line ('bco 1');

  if loc_arthus_cache.DATE_PEREMPTION > sysdate then --non périmé TODO loc_date_perempt is null=non périmé?
    DBMS_OUTPUT.put_line ('bco 1b');
    RETURN loc_arthus_cache.VALEUR ;
  END IF ;
  DBMS_OUTPUT.put_line ('bco 2');

  l_req := 'select '|| loc_TYPE || '(' || I_CLE || ') from dual';

  DBMS_OUTPUT.put_line ('bco 2b:' || l_req);
  EXECUTE IMMEDIATE l_req into loc_valeur;

  loc_tps_calcul:=DBMS_UTILITY.GET_TIME- loc_deb;

  DBMS_OUTPUT.put_line ('bco 3:'|| loc_valeur);
  --le delai ajouté est de 12h à la date du jour
  loc_arthus_cache.DATE_PEREMPTION :=sysdate + F_GET_DELAY(loc_TYPE);

  DBMS_OUTPUT.put_line ('bco 4');

  IF loc_arthus_cache.TYPE_CACHE IS NOT NULL THEN
  DBMS_OUTPUT.put_line ('bco 5');

    Update arthus_cache
    set date_peremption = loc_arthus_cache.DATE_PEREMPTION,
        valeur          = loc_valeur ,
        DATE_MODIF      = sysdate,
        TPS_CALCUL      = loc_tps_calcul
    where TYPE_CACHE=loc_TYPE and CLE=I_CLE;
    DBMS_OUTPUT.put_line ('bco 6');
  ELSE
   DBMS_OUTPUT.put_line ('bco 7');
    loc_arthus_cache.CLE           := I_CLE;
    loc_arthus_cache.TYPE_CACHE    := loc_TYPE;
    loc_arthus_cache.VALEUR        := loc_valeur;
    loc_arthus_cache.DATE_CREATION := sysdate;
    loc_arthus_cache.DATE_MODIF    := sysdate;
    loc_arthus_cache.TPS_CALCUL    := loc_tps_calcul;
   DBMS_OUTPUT.put_line ('bco 8');

    insert into ARTHUS_CACHE values loc_arthus_cache ;
   DBMS_OUTPUT.put_line ('bco 9');


  END IF;

   DBMS_OUTPUT.put_line ('bco 10');

  RETURN loc_arthus_cache.VALEUR ;

END F_GET_CACHED_VALUE;

/******************************************************************************/


FUNCTION F_GET_DELAY (I_TYPE IN ARTHUS_CACHE.TYPE_CACHE%TYPE)
RETURN NUMBER
IS
BEGIN
    RETURN 0.5;
END F_GET_DELAY;

/******************************************************************************/

PROCEDURE P_INVALID_VALUE (I_TYPE IN ARTHUS_CACHE.TYPE_CACHE%TYPE, I_CLE IN ARTHUS_CACHE.CLE%TYPE)

IS
  loc_interval NUMBER;
  loc_date_perempt DATE;
  loc_date_crea DATE;
  l_req varchar2(200);
BEGIN
  --SI i_cle IS NULL on invalid toutes les données dans le cache du type i_type
  loc_interval :=F_GET_DELAY(I_TYPE);
  /*La date de péremption est calculée à partir de la date de création (sysdate) auquel
on ajoute un délai (INTERVALLE Oracle) : type donnée voir 2ieme lien. Ce délai est déterminé à partir du type
*/
  select date_creation  into loc_date_crea from arthus_cache where type_cache=I_TYPE;

  --calcul de la date de pérempt
  select loc_interval+ loc_date_crea into loc_date_perempt
  from dual;

  l_req :='Update arthus_cache set date_peremption='||loc_date_perempt ||'where type_cache='||i_type;
  IF I_CLE IS NULL THEN
    l_req :=l_req;
  ELSE
    l_req :=l_req ||' and cle='||I_CLE;
  END IF;
  EXECUTE IMMEDIATE l_req ;
  commit;
  l_req :='';
END P_INVALID_VALUE;

/******************************************************************************/

PROCEDURE P_REFRESH_PEREMPTION (I_TYPE IN ARTHUS_CACHE.TYPE_CACHE%TYPE, I_CLE IN ARTHUS_CACHE.CLE%TYPE)

IS
loc_delai number;
loc_date_perempt date;
l_req varchar2(200);
BEGIN
  loc_delai :=F_GET_DELAY(I_TYPE);
  loc_date_perempt :=sysdate +loc_delai;
  l_req :='Update arthus_cache set date_peremption='||loc_date_perempt ||'where type_cache='||i_type||'and cle='||i_cle;
  EXECUTE IMMEDIATE l_req ;
  commit;

END P_REFRESH_PEREMPTION;
/******************************************************************************/

PROCEDURE P_REFRESH_CACHE (I_TYPE IN ARTHUS_CACHE.TYPE_CACHE%TYPE, I_CLE IN ARTHUS_CACHE.CLE%TYPE)

IS
BEGIN
  null;
END P_REFRESH_CACHE;

/******************************************************************************/

END PK_ARTHUS_CACHE;
/
