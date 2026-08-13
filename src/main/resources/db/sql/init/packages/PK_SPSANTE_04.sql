CREATE OR REPLACE PACKAGE ARTHUS."PK_SPSANTE_04"
AS
/*============================================================================*/
/* PACKAGE      : PK_SPSANTE_04.sql                                           */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 27/05/2011                                                  */
/* Description  : Package vitrine du tiers payant optique SP Sante/Sintia     */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/*============================================================================*/

FUNCTION creerPEC (P_Question IN XMLTYPE) RETURN XMLTYPE;

FUNCTION validerPEC (P_Question IN XMLTYPE) RETURN XMLTYPE;

FUNCTION annulerPEC (P_Question IN XMLTYPE) RETURN XMLTYPE;

FUNCTION TesterService(i_var IN varchar2) RETURN varchar2;

-- ------------------------------------------------- Fin des procedures publiques --
END PK_SPSANTE_04;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_SPSANTE_04
As
/*============================================================================*/
/* PACKAGE      : PK_SPSANTE_04.sql                                           */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 27/05/2011                                                  */
/* Description  : Package vitrine du tiers payant optique SP Sante/Sintia     */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/*============================================================================*/

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  creerPEC                                                  */
/* Type         :  Public                                                    */
/* Description  :  Demande de prise en charge                                */
/* Entree       :  P_xml, Flux XML                                           */
/* Retour       :  Retourne le flux XML                                      */
/*---------------------------------------------------------------------------*/
FUNCTION creerPEC (P_Question IN XMLTYPE)
RETURN XMLTYPE IS

  -- Déclaration des variables locales
  v_xml        xmltype;
  l_clob     CLOB;
  l_xml_clob     CLOB;
BEGIN
l_clob :=P_Question.getClobVal();
select REPLACE(l_clob,'OiamCREQ','oiamCREQ') into l_xml_clob from dual;  --remplacement de la balise nommée a tort pas l'interface JAVA

          PK_trace.P_INS_journal_adm (
                I_nom_traitement => 'WSXXT',
                I_session  => SID,
                I_niv_msg  => 3,
                I_msg_adm  => substr('flux xml PEC',1,132),
                I_idligne  => 1);
  -- Appel traitement contrôle de droits
  v_xml := PK_SPSANTE.creerPEC(XMLTYPE(l_xml_clob));

  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN
                PK_trace.P_INS_journal_adm (
                I_nom_traitement => 'WSXXT',
                I_session  => SID,
                I_niv_msg  => 3,
                I_msg_adm  => substr(sqlerrm,1,132),
                I_idligne  => 2);
               RETURN v_xml;
END creerPEC;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  validerPEC                                                */
/* Type         :  Public                                                    */
/* Description  :  Confirmation de la prise en charge                        */
/* Entree       :  P_xml, Flux XML                                           */
/* Retour       :  Retourne le flux XML                                      */
/*---------------------------------------------------------------------------*/
FUNCTION validerPEC (P_Question IN XMLTYPE)
RETURN XMLTYPE IS

  -- Déclaration des variables locales
  v_xml         xmltype;
  l_clob        CLOB;
  l_xml_clob    CLOB;
BEGIN
 l_clob :=P_Question.getClobVal();
 select REPLACE(l_clob,'OiamCVAL','oiamCVAL') into l_xml_clob from dual;  --remplacement de la balise nommée a tort pas l'interface JAVA

  --Appel traitement contrôle de droits
  --v_xml := PK_SPSANTE.validerPEC(XMLTYPE(l_xml_clob));

  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN
       RETURN v_xml;
END validerPEC;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  annulerPEC                                                */
/* Type         :  Public                                                    */
/* Description  :  Annulation de la prise en charge                          */
/* Entree       :  P_xml, Flux XML                                           */
/* Retour       :  Retourne le flux XML                                      */
/*---------------------------------------------------------------------------*/
FUNCTION annulerPEC (P_Question IN XMLTYPE)
RETURN XMLTYPE IS

  -- Déclaration des variables locales
  v_xml        xmltype;
  l_clob        CLOB;
  l_xml_clob    CLOB;
BEGIN
l_clob :=P_Question.getClobVal();
select REPLACE(l_clob,'OiamCDEL','oiamCDEL') into l_xml_clob from dual;  --remplacement de la balise nommée a tort pas l'interface JAVA

          PK_trace.P_INS_journal_adm (
                I_nom_traitement => 'WSXXT',
                I_session  => SID,
                I_niv_msg  => 3,
                I_msg_adm  => substr('flux xml annulerPEC',1,132),
                I_idligne  => 1);
  --Appel traitement contrôle de droits
  v_xml := PK_SPSANTE.annulerPEC(XMLTYPE(l_xml_clob));

  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN
                PK_trace.P_INS_journal_adm (
                I_nom_traitement => 'WSXXT',
                I_session  => SID,
                I_niv_msg  => 3,
                I_msg_adm  => substr(sqlerrm,1,132),
                I_idligne  => 2);
               RETURN v_xml;
END annulerPEC;
-------------------------------------------------------------------------------
FUNCTION TesterService(i_var IN varchar2) RETURN varchar2
IS
I_ok varchar2(20) :='ok';
BEGIN
  I_ok := i_var;
  RETURN I_ok;
END;

END PK_SPSANTE_04;
/
