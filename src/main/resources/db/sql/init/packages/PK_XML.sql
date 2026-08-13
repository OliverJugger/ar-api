CREATE OR REPLACE package ARTHUS.PK_XML as
/*===========================================================================*/
/* Package      : PK_XML.sql                                                  */
/* Domaine      : PACKAGE WEBSERVICES                                        */
/* Version      : V1.0                                                       */
/* Auteur       :                                                            */
/* Création     :                                                            */
/* Description  : Package des fonctions spécifiques  à l'utilisation de      */
/*                webservices                                                */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :  SEVEANE / SPSANTE /CU                                     */
/* Auteur       :  XHUE/ABO/SDA                                              */
/* Date         :  18/05/2011                                                */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : ABO 28/11/2014 ajout du ç dans le translate                */
/*===========================================================================*/

-- Procédure initialisant un nouveau document XML
PROCEDURE new_xml;

-- Procédure ajoutant  un élément de type "paragraphe"
PROCEDURE add_element(p_pere in varchar2, p_element in varchar2);

-- Procédure ajoutant une balise et son contenu
PROCEDURE add_data(p_pere in varchar2, p_bal in varchar2, p_data in varchar2,p_utf8 IN BOOLEAN default TRUE);

-- Procédure ajoutant/modifiant une balise et son contenu
PROCEDURE merge_data(p_pere in varchar2, p_bal in varchar2, p_data in varchar2,p_utf8 IN BOOLEAN default TRUE);

-- Procédure fournissant le document XML construit
FUNCTION get_xml(p_racine in varchar2 default 'Racine', p_xmlns in varchar2 default null,p_utf8 in boolean default true) return xmltype;

-- Procédure fournissant le contenu d'une balise
FUNCTION extract_data(p_doc_xml in xmltype,
                      p_bal in varchar2,
                      p_oc in integer := NULL,
                      p_isxmlns in integer :=0) RETURN varchar2;

FUNCTION extract_data2(p_doc_xml in xmltype,
p_bal in varchar2,
p_xmlns in varchar2 ) RETURN varchar2;

-- Procédure extrayant une partie d'un document XML
FUNCTION extract_part(p_doc_xml in xmltype, p_bal in varchar2) return xmltype;

-- fonction extrayant l'attribut xmlns du balise
FUNCTION GET_XMLNS(p_doc_xml in xmltype,
                   P_Bal In Varchar2,
                   p_rang in number default 1)return varchar2;

/* insert un element a l'endroit indiqué, accepte un valeur a inserer entre les balises   */
FUNCTION APPENDCHILD( doc IN XMLTYPE,
                     path  IN VARCHAR2,
                     children IN VARCHAR2,
                     xmlns IN VARCHAR2,
                     child_val IN VARCHAR2 DEFAULT ''
                    )
                    RETURN XMLTYPE;
/* surcharge de la fonction appendChild pour inserer directement un objet XML */
FUNCTION APPENDCHILDXML( doc IN  XMLTYPE,
                     path  IN VARCHAR2,
                     children IN VARCHAR2,
                     xmlns IN VARCHAR2,
                     child_val IN XMLTYPE DEFAULT NULL
                    )
                    RETURN XMLTYPE;

-- Déclarations Variables Globales
vg_xmlns VARCHAR2(1000); -- Namespaces utilisés
vg_outxmlns VARCHAR2(10);
vg_xmlnsRac BOOLEAN;
END PK_XML;
/

CREATE OR REPLACE package body ARTHUS.PK_XML as

/******************************************************************************/
-- Package PK_XML : package permettant de construire un document XML
/******************************************************************************/
--
-- Exemple d'utilisation :
-- Les instructions suivantes permettent de construire un document xml et de le
-- récupérer dans la variable v_xml (de type XML_TYPE):
--
-- pk_xml.new_xml;
-- pk_xml.add_element('/', 'Contrat');
-- pk_xml.add_data('Contrat', 'Numero','1');
-- pk_xml.add_data('Contrat', 'NumAdhesion','20');
-- pk_xml.add_element('/', 'Beneficiaires');
-- pk_xml.add_element('Beneficiaires', 'Beneficiaire');
-- pk_xml.add_data('Beneficiaire', 'Identifiant','123');
-- pk_xml.add_data('Beneficiaire', 'Civilite','M');
-- pk_xml.add_data('Beneficiaire', 'Nom','Dupont');
-- pk_xml.add_data('Beneficiaire', 'Prenom','Julien');
-- pk_xml.add_element('Beneficiaires', 'Beneficiaire');
-- pk_xml.add_data('Beneficiaire', 'Identifiant','4');
-- pk_xml.add_data('Beneficiaire', 'Civilite','MME');
-- pk_xml.add_data('Beneficiaire', 'Nom','Martin');
-- pk_xml.add_data('Beneficiaire', 'Prenom','Juliette');
-- pk_xml.add_data('Contrat', 'Etat','Valide');
-- v_xml := pk_xml.get_xml;
--
-- Le document XML obtenu est le suivant:
--<Racine>
--<Contrat>
--  <Numero>1</Numero>
--  <NumAdhesion>20</NumAdhesion>
--  <Etat>Valide</Etat>
--</Contrat>
--<Beneficiaires>
--  <Beneficiaire>
--    <Identifiant>123</Identifiant>
--    <Civilite>M</Civilite>
--    <Nom>Dupont</Nom>
--    <Prenom>Julien</Prenom>
--  </Beneficiaire>
--  <Beneficiaire>
--    <Identifiant>4</Identifiant>
--    <Civilite>MME</Civilite>
--    <Nom>Martin</Nom>
--    <Prenom>Juliette</Prenom>
--  </Beneficiaire>
--</Beneficiaires>
--</Racine>
/******************************************************************************/

-- Variables Globales
vg_xml CLOB;

/*--------------------------------------------------------------------------- */
/* PROCEDURE                                                                  */
/* Nom          :  new_xml                                                    */
/* Type         :  Privé                                                      */
/* Description  :  Procédure initialisant un nouveau document XML             */
/*                                                                            */
/* Entree/Sortie:                                                             */
/* Retour       :                                                             */
/*                                                                            */
/*                                                                            */
/*--------------------------------------------------------------------------- */
PROCEDURE new_xml
is
begin
  vg_xml := null;
end;

/*--------------------------------------------------------------------------- */
/* PROCEDURE                                                                  */
/* Nom          :  add_element                                                */
/* Type         :  Privé                                                      */
/* Description  :  Procédure initialisant un nouveau document XML             */
/*                                                                            */
/* Entree/Sortie:  p_pere : nom de la balise père ('/' si racine).            */
/*                   p_element : nom de l'élément à ajouter                   */
/* Retour       :                                                             */
/*                                                                            */
/*                                                                            */
/*--------------------------------------------------------------------------- */
PROCEDURE add_element(p_pere in varchar2, p_element in varchar2)
is
  v_pos integer:=0;
begin
  if p_pere = '/' then
    -- Ajout du nouvel élément à la fin du document
     vg_xml := vg_xml||'<'||p_element||'>'||CHR(10)||'</'||p_element||'>'||CHR(10);
  else
    -- Recherche position de la fermeture de la dernière balise p_pere
    v_pos := instr(vg_xml,'</'||p_pere||'>',-1,1);
    -- Ajout du nouvel élément à la position calculée précédemment
    vg_xml := substr(vg_xml,1,v_pos-1)||
              '<'||p_element||'>'||CHR(10)||'</'||p_element||'>'||CHR(10)||
              substr(vg_xml,v_pos);
  end if;
end;

/*--------------------------------------------------------------------------- */
/* PROCEDURE                                                                  */
/* Nom          :  add_data                                                   */
/* Type         :                                                             */
/* Description  :  Procédure ajoutant une balise et son contenu               */
/*                                                                            */
/* Entree/Sortie:  p_pere : nom de la balise père ('/' si racine).            */
/*             p_bal  : nom de la nouvelle balise.                            */
/*             p_data : contenu de la balise                                  */
/*             p_utf8 : résulat au format utf8                             */
/* Retour       :                                                             */
/*                                                                            */
/*                                                                            */
/*--------------------------------------------------------------------------- */
-- Historique :
-- 20/07/2010 - X.Hue - Création
-- 30/04/2012 -  ABO  - ajout du paramètre utf8
/*--------------------------------------------------------------------------- */
PROCEDURE add_data(p_pere in varchar2, p_bal in varchar2, p_data in varchar2, p_utf8 IN BOOLEAN default TRUE)
IS
  v_pos integer:=0;
  v_posd integer:=0;
  v_pere varchar2(200);
BEGIN
  IF p_pere = '/' then
    -- Ajout la nouvelle balise à la fin du document
    IF NOT p_utf8 THEN
       vg_xml := vg_xml||'<'||p_bal||'>'||p_data||'</'||p_bal||'>'||CHR(10);
    ELSE
       vg_xml := vg_xml||'<'||p_bal||'>'||convert(p_data,'UTF8')||'</'||p_bal||'>'||CHR(10);
    END iF;
  --ABO balise père présente plusieurs fois dans le flux p_pere = 'pere1/pere2'
  ELSIF instr(p_pere,'/') >0 THEN
     v_pos := instr(p_pere,'/');
     v_pere := substr(p_pere,1,v_pos-1);--pere1
     v_posd := instr(vg_xml,'<'||v_pere||'>'); --debut

     v_pere := substr(p_pere,v_pos+1);--pere2

     v_pos := instr(vg_xml,'</'||v_pere||'>',v_posd,1);
     IF NOT p_utf8 THEN
        vg_xml := substr(vg_xml,1,v_pos-1)||
              '<'||p_bal||'>'||p_data||'</'||p_bal||'>'||CHR(10)||
              substr(vg_xml,v_pos);
     ELSE
         vg_xml := substr(vg_xml,1,v_pos-1)||
              '<'||p_bal||'>'||convert(p_data,'UTF8')||'</'||p_bal||'>'||CHR(10)||
              substr(vg_xml,v_pos);
     END IF;
  ELSE
    -- Recherche position de la fermeture de la balise p_pere
    v_pos := instr(vg_xml,'</'||p_pere||'>',-1,1);
    IF NOT p_utf8 THEN
      vg_xml := substr(vg_xml,1,v_pos-1)||
              '<'||p_bal||'>'||p_data||'</'||p_bal||'>'||CHR(10)||
              substr(vg_xml,v_pos);
    ELSE
      vg_xml := substr(vg_xml,1,v_pos-1)||
              '<'||p_bal||'>'||convert(p_data,'UTF8')||'</'||p_bal||'>'||CHR(10)||
              substr(vg_xml,v_pos);
    END IF;
  END IF;
END;


/*--------------------------------------------------------------------------- */
/* PROCEDURE                                                                  */
/* Nom          :  merge_data                                                 */
/* Type         :                                                             */
/* Description  :  Procédure ajoutant une balise et son contenu               */
/*                 Si la balise p_bal existe, cette procédure remplace le     */
/*                 contenu de cette balise par la nouvelle donnée (p_data).   */
/*                 Si la balise p_bal n'existe pas, cette procédure insère la */
/*                 nouvelle balise et son contenu.                            */
/*                 Si p_data est null alors la procédure supprime la balise   */
/*                 p_bal                                                      */
/*                                                                            */
/* Entree/Sortie: p_pere : nom de la balise père ('/' si racine).             */
/*                p_bal  : nom de la nouvelle balise.                         */
/*                p_data : contenu de la balise                               */
/*                p_utf8 : résulat au format utf8                             */
/* Retour       :                                                             */
/*                                                                            */
/*                                                                            */
/*--------------------------------------------------------------------------- */
-- Historique :
-- 20/07/2010 - X.Hue - Création
-- 30/04/2012 -  ABO  - ajout du paramètre utf8
/*--------------------------------------------------------------------------- */
PROCEDURE merge_data(p_pere in varchar2, p_bal in varchar2, p_data in varchar2,p_utf8 IN BOOLEAN default TRUE)
IS
  v_pos_p1 integer:=0; -- Position du début du contenu de la balise père
  v_pos_p2 integer:=0; -- Position de fin du contenu de la balise père
  v_pos_b1 integer:=0; -- Position du début de la balise p_bal
  v_pos_b2 integer:=0; -- Position de fin de la balise p_bal
  v_posd integer:=0;
  v_pere varchar2(200);
  v_xml    clob;
BEGIN

  IF p_pere = '/' THEN
     -- Définition des positions de début et de fin de p_pere
     v_pos_p1 := 1;
     v_pos_p2 := v_pos_p1+length(vg_xml);
  ELSIF instr(p_pere,'/') >0 THEN
     v_pos_p1 := instr(p_pere,'/');
     v_pere := substr(p_pere,1,v_pos_p1-1);--pere1

     v_posd := instr(vg_xml,'<'||v_pere||'>'); --debut
     v_pere := substr(p_pere,v_pos_p1+1);--pere2

     -- Recherche position de début du contenu de la balise v_pere
     v_pos_p1 := instr(vg_xml,'<'||v_pere||'>',v_posd,1)+length(v_pere)+3;
     -- Recherche position de fin de la balise v_pere
     v_pos_p2 := instr(vg_xml,'</'||v_pere||'>',v_posd,1);
     dbms_output.put_line('v_pos_p1 :'||v_pos_p1||' v_pos_p2 :'||v_pos_p2);
  ELSE
     -- Recherche position de début du contenu de la balise p_pere
     v_pos_p1 := instr(vg_xml,'<'||p_pere||'>',-1,1)+length(p_pere)+2;

     -- Recherche position de fin de la balise p_pere
     v_pos_p2 := instr(vg_xml,'</'||p_pere||'>',-1,1);
  END IF;

  -- Extraction du contenu de la balise père
  v_xml := SUBSTR(vg_xml,v_pos_p1,v_pos_p2-v_pos_p1);

  -- Recherche position de début de la balise p_bal
  v_pos_b1 := instr(v_xml,'<'||p_bal||'>',1,1);



  IF p_data ='@' THEN -- suppression de la balise
    IF v_pos_b1 <> 0 THEN
      -- Recherche position de début de la balise p_bal dans le fichier
      v_pos_b1 := instr(vg_xml,'<'||p_bal||'>',v_pos_p1,1);
      -- Recherche position de fin de la balise p_bal dans le fichier
      v_pos_b2 := instr(vg_xml,'</'||p_bal||'>',v_pos_p1,1) + LENGTH(p_bal) + 4; --avec CH(10)
      --dbms_output.put_line('pos1 :'||v_pos_b1||' pos2 :'||v_pos_b2);
      vg_xml := substr (vg_xml, 0,v_pos_b1-1)||substr (vg_xml, v_pos_b2);
      -- dbms_output.put_line('vg_xml :'||vg_xml);
    END IF;
  ELSIF v_pos_b1 = 0 THEN
     -- Balise inexistante - Cas ajout nouvelle balise
     add_data(p_pere, p_bal, p_data);
  ELSE
     -- Balise existante - Cas modification du contenu de la balise

     -- Calcul position début du contenu de la balise p_bal
     v_pos_b1 := v_pos_b1 + LENGTH(p_bal) + 2;

      -- Recherche position de fin de la balise p_bal
     v_pos_b2 := instr(v_xml,'</'||p_bal||'>',1,1);

     -- Modification du XML
     IF NOT p_utf8 THEN
        v_xml := substr(v_xml,1,v_pos_b1-1)|| p_data || substr(v_xml,v_pos_b2);
     ELSE
         v_xml := substr(v_xml,1,v_pos_b1-1)|| convert(p_data,'UTF8') || substr(v_xml,v_pos_b2);
     END IF;
     vg_xml := substr(vg_xml,1,v_pos_p1-1)|| v_xml || substr(vg_xml,v_pos_p2);
  END IF;

END merge_data;


/*--------------------------------------------------------------------------- */
/* FUNCTION                                                                  */
/* Nom          :  get_xml                                                    */
/* Type         :                                                             */
/* Description  :  Procédure ajoutant une balise et son contenu               */
/*                 Si la balise p_bal existe, cette procédure remplace le     */
/*                 contenu de cette balise par la nouvelle donnée (p_data).   */
/*                 Si la balise p_bal n'existe pas, cette procédure insère la */
/*                 nouvelle balise et son contenu.                            */
/*                 Si p_data est null alors la procédure supprime la balise   */
/*                 p_bal                                                      */
/*                                                                            */
/* Entree/Sortie: p_racine : nom de la balise racine à utiliser               */
/*                  ('Racine' par défaut)                                     */
/*                p_xmlns  : chaine contenant la définition des               */
/*                        namespaces utilisés                                 */
/*                p_utf8 : résulat au format utf8                             */
/*                      dans le document XML (optionnel)                      */
/* Retour       : Document XML créé                                           */
/*                                                                            */
/*                                                                            */
/*--------------------------------------------------------------------------- */

FUNCTION get_xml(p_racine in varchar2 default 'Racine',
                 p_xmlns  in varchar2 default null,
                 p_utf8 in boolean default true)
return XMLTYPE
is
  v_xml xmltype;
  v_racine_deb varchar2(500);
  v_racine_fin varchar2(500);
begin
  if p_xmlns is not null then
     v_racine_deb := '<'||p_racine||' '||p_xmlns||'>';
  else
     v_racine_deb := '<'||p_racine||'>';
  end if;
  v_racine_fin := '</'||p_racine||'>';
  --on enleve les accents generateur erreur UTF8
  IF NOT p_utf8 THEN
   vg_xml:= TRANSLATE(vg_xml,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔÇç''','AAEEEEIIaaaaeeeeiiouuUUOCc ');
  END IF;
  v_xml := xmltype(v_racine_deb||CHR(10)||vg_xml||v_racine_fin);
  return(v_xml);
end;
/*--------------------------------------------------------------------------- */
/* FUNCTION                                                                  */
/* Nom          :  extract_data                                               */
/* Type         :                                                             */
/* Description  :  Fonction fournissant le contenu d'une balise               */
/*                                                                            */
/* Entree/Sortie: p_doc_xml : Document XML du flux                            */
/*                p_bal     : Nom de la balise                                */
/*                p_oc      : Occurrence                                      */
/*                p_isxmlns : balises préfixées                               */
/* Retour       : Donnée contenu dans la balise (VARCHAR2)                    */
/*                                                                            */
/*                                                                            */
/*--------------------------------------------------------------------------- */
-- Remarques:
-- La balise ne doit pas contenir une autre balise
/*--------------------------------------------------------------------------- */
FUNCTION extract_data(p_doc_xml in xmltype,
                      p_bal in varchar2,
                      p_oc in integer := NULL,
                      p_isxmlns in integer :=0)
return varchar2
is
  v_data varchar2(1000);
  v_bal  varchar2(1000);
  v_pos  integer;
BEGIN
  -- Inclusion de l'occurence à l'élément répétitif
  IF p_oc IS NOT NULL THEN
     v_pos := INSTR(p_bal,'/',1,1);
     v_bal := SUBSTR(p_bal,1,v_pos-1)||'['||TO_CHAR(p_oc)||']'||SUBSTR(p_bal,v_pos);
  ELSE
     v_bal := p_bal;
  END IF;

  If Vg_Outxmlns Is Not Null And P_Isxmlns = 1    Then
     If Vg_Xmlnsrac Then
       V_Bal := Replace(V_Bal,'/','/'||Vg_Outxmlns||':');
     Else
       V_Bal := Vg_Outxmlns||':'||Replace(V_Bal,'/','/'||Vg_Outxmlns||':');
     END IF;
  END IF;
  select extractvalue(p_doc_xml, '//'||v_bal, vg_xmlns)
  into v_data
  from dual;

  return TRIM(v_data);

EXCEPTION
  when others then
           return(null);
END;


/*--------------------------------------------------------------------------- */
/* FUNCTION                                                                  */
/* Nom          :  extract_part                                               */
/* Type         :                                                             */
/* Description  :  Fonction  extrayant une partie d'un document XML           */
/*                                                                            */
/* Entree/Sortie: p_doc_xml : Document XML du flux                            */
/*                p_bal     : Nom de la balise                                */
/*                                                                            */
/* Retour       : Partie extraite du XML, balise p_bal incluse (XMLTYPE)      */
/*                                                                            */
/*                                                                            */
/*--------------------------------------------------------------------------- */
FUNCTION extract_part(p_doc_xml in xmltype,
                      p_bal in varchar2)
return xmltype
is
  v_part xmltype;
BEGIN

 v_part := p_doc_xml.EXTRACT('//'||p_bal);

 return(v_part);

EXCEPTION
  when others then
       return(null);
END;

/*--------------------------------------------------------------------------- */
/* PROCEDURE                                                                  */
/* Nom          :  GET_XMLNS                                                  */
/* Type         :                                                             */
/* Description  :  Fonction  extrayant une partie d'un document XML           */
/*                                                                            */
/* Entree/Sortie: p_doc_xml : Document XML du flux                            */
/*                p_bal     : Nom de la balise                                */
/*                                                                            */
/* Retour       : Partie extraite du XML, balise p_bal incluse (XMLTYPE)      */
/*                                                                            */
/*                                                                            */
/*--------------------------------------------------------------------------- */
Function Get_Xmlns(P_Doc_Xml In Xmltype,
                   P_Bal In Varchar2,
                   p_rang in number default 1 )
return varchar2
is
  loc_xml xmltype;
  L_outxmlns varchar2(100);
  l_pos1 number;
  l_pos2 number;

BEGIN
  loc_xml:=p_doc_xml.EXTRACT(p_bal);
  L_Outxmlns := Substr(Loc_Xml.Getclobval(),0,100);
  L_Pos1:= NVL(Instr(L_Outxmlns,'<',P_Rang),0);
  l_pos2:= NVL(instr(l_outxmlns,':',l_pos1),0);
  vg_outxmlns := substr(l_outxmlns,l_pos1+1,l_pos2-l_pos1-1);--null si pas de namespace

 return(vg_outxmlns);

EXCEPTION
  when others then
       return(null);
END;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  APPENDCHILD                                               */
/* Type         :  Privee                                                    */
/* Description  :  insert un element a l'endroit indiqué, accepte un valeur a*/
/*              : inserer entre les balise                                   */
/* Entree       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION APPENDCHILD( doc IN  XMLTYPE,
                     path  IN VARCHAR2,
                     children IN VARCHAR2,
                     xmlns IN VARCHAR2,
                     child_val IN VARCHAR2 DEFAULT ''
                    )
                    RETURN XMLTYPE
IS
retour XMLTYPE;
BEGIN
 select  INSERTCHILDXML(doc,
                        path ,
                        children ,
                        XMLTYPE('<'||children||' '||xmlns||'>'||child_val||'</'||children||'>'),
                        xmlns) into retour from dual;
 return retour;
end APPENDCHILD;
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  APPENDCHILD                                               */
/* Type         :  Privee                                                    */
/* Description  :  insert un element a l'endroit indiqué, accepte un valeur a*/
/*              : inserer entre les balise                                   */
/* Entree       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION APPENDCHILDXML( doc IN  XMLTYPE,
                     path  IN VARCHAR2,
                     children IN VARCHAR2,
                     xmlns IN VARCHAR2,
                     child_val IN XMLTYPE DEFAULT NULL
                    )
                    RETURN XMLTYPE
IS
retour XMLTYPE;
BEGIN
 select  INSERTCHILDXML(doc,
                        path ,
                        children ,
                        child_val,
                        xmlns) into retour from dual;
 return retour;
end APPENDCHILDXML;


FUNCTION extract_data2(p_doc_xml in xmltype,
p_bal in varchar2,
p_xmlns in varchar2 ) RETURN varchar2

is
retour varchar2(500);

begin
      select EXTRACTVALUE(  p_doc_xml, p_bal,p_xmlns)
              into retour from dual;






return retour;
end


;
END PK_XML;
/
