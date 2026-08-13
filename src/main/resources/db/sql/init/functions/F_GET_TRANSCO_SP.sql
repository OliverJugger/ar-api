CREATE FUNCTION ARTHUS.F_GET_TRANSCO_SP (  i_id_flux       IN       FLUX.id_flux%TYPE
                                             , i_numindiv      IN       VARCHAR2
                                             , i               IN       NUMBER)          -- 1 : 1er acte de la PEC, 2 : 2ème acte de la PEC    ....
RETURN VARCHAR2
IS

  loc_codfrais        VARCHAR2(20);
  O_acte_err_code    NUMBER:= NULL;
  loc_fin            DATE;
  loc_flux           FLUX.id_flux%TYPE:=NULL;
  loc_codfraisSPS    VARCHAR2(20); 
  loc_xml            XMLTYPE;
  loc_path_xml       VARCHAR2(100) :='oiamCREQ/partenariat/propositionClient/';
  loc_numfor         NUMBER:= NULL;
  T_ntfrs_optique     NTFRS_OPTIQUE_T:=NTFRS_OPTIQUE_T(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  T_type_monture      TYPE_MONTURE_T:=TYPE_MONTURE_T(NULL,NULL);
  T_ntfrs_vision      NTFRS_VISION_T:=NTFRS_VISION_T(NULL,NULL,NULL);
  T_ntfrs_typ_vision  NTFRS_TYP_VISION_T:=NTFRS_TYP_VISION_T(NULL,NULL,NULL);
  T_ntfrs_matiere     NTFRS_MATIERE_T:=NTFRS_MATIERE_T(NULL,NULL,NULL);
  T_ntfrs_type_sup    NTFRS_TYPE_SUP_T:=NTFRS_TYPE_SUP_T(NULL,NULL,NULL,NULL,NULL);
  T_renew_lentille    RENEW_LENTILLE_T:=RENEW_LENTILLE_T(NULL,NULL,NULL);
  loc_nature          NUMBER(1);
  loc_mtRO            NUMBER(11,2):=0;
  loc_idadhesion      adhe_cntrt.idadhesion%TYPE;
  loc_attente         NUMBER :=0;     -- afin de mettre en attente des douvle vision ou un changement de dioptrie
  loc_nbrLentilleBoite  NUMBER(3):=0;
  v_libelle            VARCHAR2(128):=NULL;
  loc_numindiv         NUMBER:=NULL;
  loc_typgar            NUMBER:=NULL;
BEGIN
  Dbms_Output.Put_Line('début' );
  -- Recherche du flux à partir de la PEC fournit par le client ou du numéro d'individu



  SELECT f.id_flux , x.doc_xml1
      , EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:priseEnChargeDetaillee[2]/mod:assure/mod:abstract_Identite','xmlns:mod="http://modele.ws.tpo.cga.com"') numindiv 
      , EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:identifiant','xmlns:mod="http://modele.ws.tpo.cga.com"') nature
    INTO loc_flux , loc_xml, loc_numindiv  , loc_codfraisSPS
    FROM xml_04_06 x, flux f
   WHERE x.id_flux = f.id_flux
   --  AND EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:priseEnChargeDetaillee[2]/mod:assure/mod:abstract_Identite','xmlns:mod="http://modele.ws.tpo.cga.com"') like '%numindiv%'
     and f.id_flux = i_id_flux
    -- AND f.statut=0
     AND f.id_type=16;
  Dbms_Output.Put_Line('Recherche de la transco pour l''individu :'|| NVL(i_numindiv,loc_numindiv));
  Dbms_Output.Put_Line('Recherche de la transco pour i_id_flux :'|| i_id_flux);

  
  Dbms_Output.Put_Line('loc_codfraisSPS :'|| loc_codfraisSPS);
  
  IF loc_codfraisSPS = 'VERRE' THEN
    loc_nature:=1;
    T_ntfrs_optique.sphere_deb :=PK_XML.EXTRACT_DATA(loc_xml,loc_path_xml || 'prestationOptique['||i||']/ametropie/sphere',null,1);
    
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:ametropie/mod:sphere','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_optique.sphere_deb 
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:ametropie/mod:cylindre','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_optique.cylindre_deb 
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:ametropie/mod:addition_deb','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_optique.addition_deb 
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:verre/mod:indice','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_optique.aminci_deb 
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:verre/mod:teinte','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_optique.teinte 
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:verre/mod:vision','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_vision.vision
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:verre/mod:type','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_typ_vision.type_vision
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:verre/mod:matiere','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_matiere.matiere
      from dual;    
      loc_attente:=loc_attente+1;
  ELSIF loc_codfraisSPS = 'MONTURE' THEN
    loc_nature:=2;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:monture/mod:type','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_type_monture.type_monture
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:monture/mod:matiere','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_matiere.matiere
      from dual;
  --  loc_attente:=loc_attente+1;
  ELSIF loc_codfraisSPS = 'LENTILLE' THEN
    loc_nature:=3;
    Dbms_Output.Put_Line('loc_nature :'|| loc_nature);
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:ametropie/mod:sphere','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_optique.sphere_deb 
      from dual;
    Dbms_Output.Put_Line('T_ntfrs_optique.sphere_deb  :'|| T_ntfrs_optique.sphere_deb );
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:ametropie/mod:cylindre','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_optique.cylindre_deb 
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:ametropie/mod:addition_deb','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_optique.addition_deb 
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:lentille/mod:famille','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_optique.famille 
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:vision','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_vision.vision
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:lentille/mod:type','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_typ_vision.type_vision
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:lentille/mod:matiere','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_ntfrs_matiere.matiere
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:lentille/mod:renouvellement','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  T_renew_lentille.code
      from dual;
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:lentille/mod:nbrLentilleBoite','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  loc_nbrLentilleBoite
      from dual;
      
  /*  IF loc_nbrLentilleBoite > 12 THEN
      raise nb_limite_lentille;
    END IF;  */
  ELSIF loc_codfraisSPS = 'PRODUIT' THEN
    v_libelle:='Les produits d entretien pour lentille ne sont pas couverts.';
   -- raise exc_produit_entretien;
  END IF;--IF loc_Tab_Acte(i).codfrais = 'VERRE' THEN


  SELECT NVL(MAX(idadhesion),0)
      INTO loc_idadhesion
   FROM  ADHE_CNTRT  a
   WHERE a.numadhe = NVL(i_numindiv,loc_numindiv)
     ;
  Dbms_Output.Put_Line('loc_idadhesion :'|| loc_idadhesion);


  SELECT NVL(MIN(f.numfor),0)  ,  min (typgar)
    INTO loc_numfor, loc_typgar
    FROM adhesion a
       , frmls f
       , defrub c
   WHERE a.idadhesion = loc_idadhesion
     AND a.numindiv = NVL(i_numindiv,loc_numindiv)
     AND a.numfor = f.numfor
     AND sysdate BETWEEN a.datapli AND nvl(a.datper, sysdate)
     AND f.valide = 'O'
     AND c.numfor = a.numfor
     AND c.codfrais like 'H%'
     AND sysdate BETWEEN c.datapli AND nvl(c.datper, sysdate)
  ORDER BY f.typgar,a.datper desc;

  Dbms_Output.Put_Line('Recherche de la transco pour le numfor :'|| loc_numfor);

  IF loc_codfraisSPS = 'PRODUIT' THEN
     --v_codfrais :='PRDT';
   --  t := t+1;
      Dbms_Output.Put_Line('On ne traite pas les codes actes produits:'|| loc_codfraisSPS);
 
  ELSE
    -- Recherche d'une Transcodification de l'acte + Contr¶le acte autorisé dans SPSante
    select EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:conditionDeRemboursement/mod:part','xmlns:mod="http://modele.ws.tpo.cga.com"') 
      into  loc_mtRO
      from dual;


    Dbms_Output.Put_Line('loc_MtRO :' || loc_MtRO);
    P_TRANSCO_CODFRAIS_SPSANTE(
                            loc_numfor,
                            loc_nature,
                            T_ntfrs_optique,
                            T_type_monture,
                            T_ntfrs_vision,
                            T_ntfrs_typ_vision,
                            T_ntfrs_matiere,
                            T_renew_lentille,
                            loc_mtRO,
                            loc_codfrais,
                            O_acte_err_code);

  END IF;
  

  
  Dbms_Output.Put_Line('loc_MtRO :' || loc_MtRO);
  Dbms_Output.Put_Line('codfrais :' || loc_codfrais);
  Dbms_Output.Put_Line('loc_fin :' || d2e(loc_fin));   
  
  Dbms_Output.Put_Line('fin ok' );
  
  RETURN loc_codfrais;

EXCEPTION
  WHEN OTHERS THEN
    Dbms_Output.Put_Line('fin ko' );     
END;


-- select d2j(sysdate) from dual;           -- 2458626
-- select d2j(e2d('30/06/2019')) from dual; -- 2458665;
