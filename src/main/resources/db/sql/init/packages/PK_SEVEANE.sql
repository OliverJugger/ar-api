CREATE OR REPLACE PACKAGE ARTHUS.PK_SEVEANE
AS

FUNCTION F_CRTL_DROIT (P_Question IN XMLTYPE) RETURN XMLTYPE;

FUNCTION F_DEMANDE_PEC (P_Question IN XMLTYPE) RETURN XMLTYPE;

FUNCTION F_CONFIRM_PEC (P_Question IN XMLTYPE) RETURN XMLTYPE;

FUNCTION F_ANNUL_PEC (P_Question IN XMLTYPE) RETURN XMLTYPE;

-- ------------------------------------------------- Fin des procedures publiques --
END PK_SEVEANE;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_SEVEANE
As

/******************************************************************************/
-- F_CRTL_DROIT -- Fonction de contrôle de droits
--
-- Paramètres entrée
--             doc_xml : Document XML d'entrée
-- sortie
--             Document XML de sortie
/******************************************************************************/
FUNCTION F_CRTL_DROIT (P_Question IN XMLTYPE)
RETURN XMLTYPE IS

  -- Déclaration des variables locales
  v_xml        xmltype;

BEGIN

  -- Appel traitement contrôle de droits
  v_xml := PK_TP_GROUPAMA.F_CRTL_DROIT(p_xml => p_Question);

  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN
       RETURN v_xml;
END F_CRTL_DROIT;

/******************************************************************************/
-- F_DEMANDE_PEC -- Fonction de demande de prise en charge
--
-- Paramètres entrée
--             doc_xml : Document XML d'entrée
-- sortie
--             Document XML de sortie
/******************************************************************************/
FUNCTION F_DEMANDE_PEC (P_Question IN XMLTYPE)
RETURN XMLTYPE IS

  -- Déclaration des variables locales
  v_xml        xmltype;

BEGIN

  -- Appel traitement contrôle de droits
  v_xml := PK_TP_GROUPAMA.F_DEMANDE_PEC(p_xml => p_Question);

  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN
       RETURN v_xml;
END F_DEMANDE_PEC;


/******************************************************************************/
-- F_CONFIRM_PEC -- Fonction de demande de prise en charge
--
-- Paramètres entrée
--             doc_xml : Document XML d'entrée
-- sortie
--             Document XML de sortie
/******************************************************************************/
FUNCTION F_CONFIRM_PEC (P_Question IN XMLTYPE)
RETURN XMLTYPE IS

  -- Déclaration des variables locales
  v_xml        xmltype;

BEGIN

  -- Appel traitement contrôle de droits
  v_xml := PK_TP_GROUPAMA.F_CONFIRM_PEC(p_xml => p_Question);

  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN
       RETURN v_xml;
END F_CONFIRM_PEC;


/******************************************************************************/
-- F_ANNUL_PEC -- Fonction d'annulation de prise en charge
--
-- Paramètres entrée
--             doc_xml : Document XML d'entrée
-- sortie
--             Document XML de sortie
/******************************************************************************/
FUNCTION F_ANNUL_PEC (P_Question IN XMLTYPE)
RETURN XMLTYPE IS

  -- Déclaration des variables locales
  v_xml        xmltype;

BEGIN

  -- Appel traitement contrôle de droits
  v_xml := PK_TP_GROUPAMA.F_ANNUL_PEC(p_xml => p_Question);

  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN
       RETURN v_xml;
END F_ANNUL_PEC;

END PK_SEVEANE;
/
