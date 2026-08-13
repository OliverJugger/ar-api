CREATE OR REPLACE package ARTHUS.PK_WS as
/*===========================================================================*/
/* Package      : PK_WS.sql                                                  */
/* Domaine      : PACKAGE WEBSERVICES                                        */
/* Version      : V1.0                                                       */
/* Auteur       :                                                            */
/* Création     :                                                            */
/* Description  : Package des fonctions spécifiques  à l'utilisation de      */
/*                webservices                                                */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :  mise en place commentaire entête                          */
/* Auteur       :  SDA                                                       */
/* Date         :  18/05/2011                                                */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : FNI / 02/09/2014                                           */
/* Commentaire  : Demande de ABO du 08/08/2014 -                             */
/*                modification de insert_flux pour qu'elle renvoie la porte. */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  insert_flux                                               */
/* Type         :  Privé                                                     */
/* Description  :  INSERT UN FLUX XML                                        */
/*                 I_type_apport, Type d'apporteur                           */
/* Entree/Sortie:  p_id_type,p_id_flux_tiers,p_doc_xml                       */
/* Retour       :  p_cod_err                                                 */
/*              :                                                            */
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  add_xml                                                   */
/* Type         :  Privé                                                     */
/* Description  :                                                            */
/* Entree       :  p_id_type,p_id_flux,p_doc_xml                             */
/*                                                                           */
/* Entree/Sortie:                                                            */
/* Retour       :  p_cod_err                                                 */
/*                                                                           */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  is_flux_valid                                             */
/* Type         :  Privé                                                     */
/* Description  :                                                            */
/*                                                                           */
/* Entree/Sortie:  p_id_type,p_id_flux_tiers,p_doc_xml                       */
/* Retour       :  Boolean                                                   */
/*              :                                                            */
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  appel_ws                                                  */
/* Type         :  Privé                                                     */
/* Description  :                                                            */
/*                                                                           */
/* Entree/Sortie:  p_id_type,p_doc_xml                                       */
/* Retour       :  XMLTYPE                                                   */
/*              :                                                            */
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  MAJ_statut                                                */
/* Type         :  Privé                                                     */
/* Description  :                                                            */
/* Entree       :  p_id_type,p_statut,p_detail_err                           */
/*                                                                           */
/* Entree/Sortie:                                                            */
/* Retour       :  p_cod_err                                                 */
/*                                                                           */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  get_detail                                                */
/* Type         :  Privé                                                     */
/* Description  :                                                            */
/* Entree       :  p_id_flux                                                  */
/*                                                                           */
/* Entree/Sortie:                                                            */
/* Retour       :  ,p_detail_err                                             */
/*                                                                           */
/*                                                                           */
/*---------------------------------------------------------------------------*/


FUNCTION insert_flux(p_id_type in type_flux.id_type%type,
                     p_id_flux_tiers flux.id_flux_tiers%type,
                     p_doc_xml in xmltype,
                     p_cod_err out char,
					           p_porte   out number) return number;

PROCEDURE add_xml(p_id_type in type_flux.id_type%type,
                  p_id_flux in flux.id_flux%type,
                  p_doc_xml in xmltype,
                  p_cod_err out char);

FUNCTION is_flux_valid(p_doc_xml in xmltype,
                       p_id_type in type_flux.id_type%type,
                       p_id_flux in flux.id_flux%type:=null) return boolean;

FUNCTION appel_ws(p_id_type in type_flux.id_type%type,
                  p_doc_xml in xmltype) return XMLTYPE;

PROCEDURE MAJ_statut(p_id_flux in flux.id_flux%type,
                     p_statut in flux.statut%type,
                     p_detail_err in flux.detail_err%type := null,                     
                     p_delai   in number default null );

FUNCTION get_detail_err(p_id_flux in flux.id_flux%type) return varchar2;
                     
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_WS as

/******************************************************************************/
-- INSERT_FLUX -- Fonction de création de flux
/******************************************************************************/
-- Paramètres entrée
--             p_id_type IN  : Identifiant du type de flux
--             p_doc_xml IN  : Document XML du flux
--             p_cod_err OUT : Code erreur   0 = OK
--                                           1 = Erreur
-- sortie
--             Identifiant du flux créé
/******************************************************************************/
-- Historique :
-- 19/07/2010 - X.Hue - Création
/******************************************************************************/
FUNCTION insert_flux(p_id_type in type_flux.id_type%type,
                     p_id_flux_tiers flux.id_flux_tiers%type,
                     p_doc_xml in xmltype,
                     p_cod_err out char,
					 p_porte   out number)

return number
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- Curseur de recherche des données de stockage xml
  cursor cur_stock is select table_stock, col_stock, ref_id_type, er, num_porte
                      from type_flux
                      where id_type = p_id_type;
  r_stock   cur_stock%rowtype;

  -- Variables locales
  v_id_flux     flux.id_flux%type;
  v_sql         varchar2(300);
  v_statut      flux.statut%type;
  v_det_err     flux.detail_err%type;

BEGIN

  p_cod_err := 0;
  

  -- Recherche des données de stockage xml (nom table + nom colonne)
  open cur_stock;
  fetch cur_stock into r_stock;
  close cur_stock;
  
  -- récupération de la porte afin de le retourner en out
  p_porte := r_stock.num_porte;
  
  -- Insertion du flux (statut 1 En cours)
  insert into flux (id_type, id_flux_tiers, statut, dat_maj)
  values (r_stock.ref_id_type, p_id_flux_tiers, 1, sysdate)
  returning id_flux into v_id_flux;

  commit;

  -- Insertion du document XML
  BEGIN
    v_sql := 'insert into '||r_stock.table_stock||' (id_flux, '||r_stock.col_stock||')'
           ||'values (:1, :2)';
    execute immediate v_sql using v_id_flux, p_doc_xml;
  /***********************************************************************
  / ** exception valable lorsqu'il y a une table qui valide le schéma)
  /***********************************************************************/
  EXCEPTION
  
    WHEN OTHERS THEN
         p_cod_err := 1;
         -- Historisation de l'erreur
         -- statut 2: Echec lors de l'insertion du XML reçu
         -- statut 4: Echec lors de l'insertion du XML à envoyer
         CASE r_stock.er
              WHEN 'R' THEN v_statut := 2; v_det_err := 'reçu: ';
              WHEN 'E' THEN v_statut := 4; v_det_err := 'envoi: ';
         END CASE;
         v_det_err := 'Echec lors de l''insertion du flux - '||sqlerrm||' - '||v_det_err||p_doc_xml.getclobval();
         MAJ_statut(v_id_flux, v_statut, v_det_err);
  END;
  commit;

  return(v_id_flux);

END insert_flux;


/******************************************************************************/
-- ADD_XML -- Procédure d'ajout de XML à un flux
/******************************************************************************/
-- Paramètres entrée
--             p_id_type : Identifiant du type de flux
--             p_id_flux : Identifiant du flux
--             p_doc_xml : Document XML du flux
--             p_cod_err : Code erreur   0 = OK
--                                       1 = Erreur
/******************************************************************************/
-- Historique :
-- 19/07/2010 - X.Hue - Création
/******************************************************************************/
PROCEDURE add_xml(p_id_type in type_flux.id_type%type,
                  p_id_flux in flux.id_flux%type,
                  p_doc_xml in xmltype,
                  p_cod_err out char)

IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- Curseur de recherche des données de stockage xml
  cursor cur_stock is select table_stock, col_stock, er
                      from type_flux
                      where id_type = p_id_type;
  r_stock     cur_stock%rowtype;

  -- Variables locales
  v_sql       varchar2(300);
  v_statut    flux.statut%type;
  v_det_err   flux.detail_err%type;

BEGIN

  p_cod_err := 0;

  -- Recherche des données de stockage xml (nom table + nom colonne)
  open cur_stock;
  fetch cur_stock into r_stock;
  close cur_stock;

  BEGIN
    -- Insertion du document XML
    v_sql := 'update '||r_stock.table_stock
          ||' set '||r_stock.col_stock||' = :1'          
          ||' where id_flux = :2';
    execute immediate v_sql using p_doc_xml, p_id_flux;
  EXCEPTION
    WHEN OTHERS THEN
         p_cod_err := 1;
         -- Historisation de l'erreur
         -- statut 2: Echec lors de l'insertion du XML reçu
         -- statut 4: Echec lors de l'insertion du XML à envoyer
         CASE r_stock.er
              WHEN 'R' THEN v_statut := 2; v_det_err := 'reçu : ';
              WHEN 'E' THEN v_statut := 4; v_det_err := 'envoi : ';
         END CASE;
         v_det_err := 'Echec lors de l''insertion du flux - '||sqlerrm||' - '||v_det_err; --||p_doc_xml.getclobval();
         MAJ_statut(p_id_flux, v_statut, v_det_err);
  END;

  commit;

END add_xml;


/******************************************************************************/
-- IS_FLUX_VALID -- Fonction de validation d'un XML
/******************************************************************************/
-- Paramètres entrée
--             p_doc_xml : Document XML à valider
--             p_id_type : Identifiant du type de flux
--             p_id_flux : Identifiant du flux
-- Sortie
--             booléen : TRUE = flux valide
--                       FALSE = flux invalide
/******************************************************************************/
-- Historique :
-- 19/07/2010 - X.Hue - Création
-- 11/08/2011-  SDA - Modification
/******************************************************************************/
FUNCTION is_flux_valid(p_doc_xml in xmltype,
                       p_id_type in type_flux.id_type%type,
                       p_id_flux in flux.id_flux%type)
return boolean
IS

  -- Curseur de recherche d'infos sur le type de flux
  cursor cur_type is select xsd, table_stock, col_stock, er
                     from type_flux
                     where id_type = p_id_type;
  r_type    cur_type%rowtype;

  v_ret       number;
  v_statut    flux.statut%type;
  v_det_err   flux.detail_err%type;
  l_xml XMLTYPE;

BEGIN

  -- Recherche infos type de flux
  open cur_type;
  fetch cur_type into r_type;
  close cur_type;

  -- Test validité XML
  v_ret := p_doc_xml.isschemavalid(r_type.xsd);

  if v_ret = 1 then
     return(TRUE);
  else
     -- Historisation de l'erreur
     -- statut 3: Echec lors de la validation du XML reçu
     -- statut 5: Echec lors de la validation du XML à envoyer
     CASE r_type.er
                WHEN 'R' THEN v_statut := 3; v_det_err := 'reçu: ';
                WHEN 'E' THEN v_statut := 5; v_det_err := 'envoi: ';
     END CASE;
     v_det_err := 'Echec De la validation du flux - '||sqlerrm||' - '|| v_det_err;
     MAJ_statut(p_id_flux, v_statut, v_det_err);

     BEGIN
         l_xml := p_doc_xml;
         l_xml := l_xml.createSchemaBasedXML(r_type.xsd);
         -- Test validité XML
         xmltype.schemaValidate(l_xml);
         return(FALSE);
     EXCEPTION
         WHEN OTHERS THEN
           v_det_err := to_char(sqlerrm); --||p_doc_xml.getclobval();
           MAJ_statut(p_id_flux, v_statut, v_det_err);
           return(FALSE);
     END;
  end if;

EXCEPTION
  when others then
       PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'is_flux_valid',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => '4-' || substr(sqlerrm,1,125),
            I_idligne  => 2);
       begin
         MAJ_statut(p_id_flux, NVL(v_statut,6), v_det_err);
       exception
         when others then null;
       end;
       return(FALSE);
END is_flux_valid;


/******************************************************************************/
-- APPEL_WS -- Fonction d'appel à un Web Service
/******************************************************************************/
-- Paramètres entrée
--             p_id_type IN  : Identifiant du type de flux
--             p_doc_xml IN  : Document XML du flux
-- Sortie
--             réponse du Web Service (document XML)
--             En cas d'erreur, le XML retourné est null
/******************************************************************************/
-- Historique :
-- 19/07/2010 - X.Hue - Création
/******************************************************************************/
FUNCTION appel_ws(p_id_type in type_flux.id_type%type,
                  p_doc_xml in xmltype)
return XMLTYPE
is
  -- Curseur de recherche de l'url et de l'entête SOAP
  cursor cur_type
  is
  select url, soap
  from type_flux
  where id_type = p_id_type;
  r_type       cur_type%rowtype;

  v_doc_xml    clob;
  soap_request clob;
  soap_respond varchar2(30000);
  http_req     utl_http.req;
  http_resp    utl_http.resp;
  resp_xml     XMLType;

BEGIN

  -- Recherche URL et Entête SOAP du Web Service
  open cur_type;
  fetch cur_type into r_type;
  close cur_type;

  -- Conversion du document XML en CLOB
  v_doc_xml := p_doc_xml.getStringVal();

  -- Création du message SOAP - On insère le document XML au coeur du message SOAP,
  soap_request:= replace(r_type.soap,'<Racine/>',v_doc_xml);

  -- Appel Web Service
  http_req:= utl_http.begin_request(r_type.url, 'POST', 'HTTP/1.1');
  utl_http.set_header(http_req, 'Content-Type', 'text/xml');
  utl_http.set_header(http_req, 'Content-Length', length(soap_request));
  utl_http.set_header(http_req, 'SOAPAction', '');
  utl_http.write_text(http_req, soap_request);

  -- Réception de la réponse du Web Service
  http_resp:= utl_http.get_response(http_req);
  utl_http.read_text(http_resp, soap_respond);
  utl_http.end_response(http_resp);

  -- Conversion de la réponse en document XML
  resp_xml:= XMLType.createXML(soap_respond);

  return(resp_xml);

EXCEPTION
  WHEN OTHERS THEN
       RETURN(null);
END appel_ws;


/******************************************************************************/
-- MAJ_statut -- Procédure de MAJ du statut du flux
/******************************************************************************/
-- Paramètres entrée
--             p_id_flux    : Identifiant du flux
--             p_statut     : nouveau statut du flux
--                            0 OK
--                            1 En cours
--                            2 Erreur insertion XML reçu
--                            3 Erreur Validation XML reçu
--                            4 Erreur insertion XML envoi
--                            5 Erreur Validation XML envoi
--                            6 Erreur Autre
--             p_detail_err : Détail de l'erreur
--
-- Remarques:
-- Le statut du flux précise la première erreur rencontrée.
-- La MAJ du statut est donc possible seulement si le statut précédent
-- est 1 (En cours).
-- Detail_err historise toutes les erreurs rencontrées.
-- delai temps de traitement
/******************************************************************************/
-- Historique :
-- 19/07/2010 - X.Hue - Création
/******************************************************************************/
PROCEDURE MAJ_statut(p_id_flux in flux.id_flux%type,
                     p_statut in flux.statut%type,
                     p_detail_err in flux.detail_err%type := null,                     
                     p_delai   in number default null)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  UPDATE FLUX
  SET statut = DECODE(statut, 1, p_statut, statut),
      delai = p_delai,
      detail_err = CASE WHEN p_detail_err IS NULL THEN detail_err
                        ELSE detail_err || p_detail_err || CHR(10) || CHR(10) END
  WHERE id_flux = p_id_flux;

  COMMIT;

END MAJ_statut;

/******************************************************************************/
-- get_detail_err -- recupère le détail erreur dans FLUX
/******************************************************************************/
-- Paramètres entrée
--             p_id_flux    : Identifiant du flux
--            
-- Parametres Sortie
--              p_detail_err : Détail de l'erreur
/******************************************************************************/
-- Historique :
-- 12/08/2011 - SDA - Création
/******************************************************************************/
FUNCTION get_detail_err(p_id_flux in flux.id_flux%type)
RETURN varchar2
IS
    CURSOR c_get_detail_err(p_id_flux in flux.id_flux%type) is
    SELECT detail_err
    FROM FLUX
    WHERE id_flux = p_id_flux;

    v_c_get_detail_err c_get_detail_err%rowtype;

  BEGIN
       OPEN c_get_detail_err(p_id_flux);
       FETCH c_get_detail_err INTO v_c_get_detail_err;
       IF c_get_detail_err%FOUND THEN
           RETURN to_char(v_c_get_detail_err.detail_err);
           --RETURN replace(v_c_get_detail_err.detail_err,'','');
       ELSE
           RETURN null;
       END IF;
       CLOSE c_get_detail_err;
       
  EXCEPTION
           WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'get_detail_err',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);
            RETURN NULL;
END get_detail_err;


END PK_WS;
/
