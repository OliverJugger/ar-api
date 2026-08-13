CREATE OR REPLACE package ARTHUS.PK_EXTRACTION_AUTO
AS

PROCEDURE P_LIST_CHARGE_CLI(i_date  IN DATE DEFAULT SYSDATE);
PROCEDURE P_LIST_SOCIETE_CLI(i_date  IN DATE DEFAULT SYSDATE);
PROCEDURE P_LIST_LIEN_CLI_CDC(i_date  IN DATE DEFAULT SYSDATE);
PROCEDURE P_LIST_LIEN_PROD_CDC(i_date  IN DATE DEFAULT SYSDATE);
PROCEDURE P_LIST_CONTRAT(i_date  IN DATE DEFAULT SYSDATE);
PROCEDURE P_LIST_GARANTIE(i_date  IN DATE DEFAULT SYSDATE);
PROCEDURE P_LIST_TARIF(i_date  IN DATE DEFAULT SYSDATE);
PROCEDURE P_LIST_PREST(i_date  IN DATE DEFAULT SYSDATE);
PROCEDURE P_LANCE_EXTRACT_AUTO(i_date  IN DATE DEFAULT SYSDATE);

END PK_EXTRACTION_AUTO;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_EXTRACTION_AUTO
AS
--Procédure de lancement automatique des extractions
PROCEDURE P_LANCE_EXTRACT_AUTO(i_date  IN DATE DEFAULT SYSDATE)
IS
BEGIN
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LANCE_EXTRACT_AUTO',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Debut de traitement '||sysdate,
                              I_idligne  => 1);
  P_LIST_CHARGE_CLI(i_date);
  P_LIST_SOCIETE_CLI(i_date);
  P_LIST_LIEN_CLI_CDC(i_date);
  P_LIST_LIEN_PROD_CDC(i_date);
  P_LIST_CONTRAT(i_date);
  P_LIST_GARANTIE(i_date);
  P_LIST_TARIF(i_date);
  P_LIST_PREST(i_date);

  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LANCE_EXTRACT_AUTO',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Fin de traitement '||sysdate,
                              I_idligne  => 1);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LANCE_EXTRACT_AUTO',
                                I_session  => SID,
                                I_niv_msg  => 1,
                                I_msg_adm  => substr('Echec de l''extraction : '||sqlerrm,1,100),
                                I_idligne  => 1);

END P_LANCE_EXTRACT_AUTO;

--Extraction de la LISTE DES CHARGES DE CLIENTELE + APPORTEUR
PROCEDURE P_LIST_CHARGE_CLI(i_date  IN DATE DEFAULT SYSDATE)
IS
  list_charge_cli   CLOB;
  loc_repertoire  VARCHAR2(20):='EXTRANET_PARTENAIRE';
  loc_fichier     VARCHAR2(50);

BEGIN

  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_CHARGE_CLI',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Debut de traitement '||sysdate,
                              I_idligne  => 1);
  loc_fichier   :='Liste_CDC_'||TO_CHAR(SYSDATE,'YYYY-MM-DD-hh24miss')||'.csv';

  SELECT dbms_xmlgen.CONVERT(xmlagg(xmlelement(e,TRANSLATE(liste
                                                              ,'àèéêêëçâîïùûôÀÂÉÈÊËÎÏÙÛÇÔ'
                                                              ,'aeeeeecaiiuuoAAEEEEIIUUCO')
                                                              ,'').EXTRACT('//text()')).GetClobVal(),1) INTO list_charge_cli
  FROM (--LISTE DES CHARGES DE CLIENTELE + APPORTEUR
      SELECT DISTINCT
      i.nom ||';'||
      i.prenom ||';'||
      a.numindiv||';'||
      decode (TYPE_APPORT,1,'APPORTEUR',10, 'CDC','Autre')||';'||
      f_coordonne_contact(a.numindiv,4,1)||CHR(13)||CHR(10) liste
      FROM apporteur a, individu i
      WHERE a.numindiv = i.numindiv
      AND a.ETENDUE =2
      AND  i_date BETWEEN debut AND NVL(fin,i_date)
  );
  --ajout de l'entete du fichier
  list_charge_cli:='CdcNom;CdcPrénom;CDC ARTHUS;Apport;Email'||CHR(13)||CHR(10)||list_charge_cli;
  IF list_charge_cli IS NOT NULL THEN
    DBMS_XSLPROCESSOR.clob2file( list_charge_cli
                                 , loc_repertoire
                                 , loc_fichier
                                );
  END IF;
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_CHARGE_CLI',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Fin normale de traitement '||sysdate,
                              I_idligne  => 2);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_CHARGE_CLI',
                                I_session  => SID,
                                I_niv_msg  => 1,
                                I_msg_adm  => substr('Echec de l''extraction : '||sqlerrm,1,100),
                                I_idligne  => 1);
END P_LIST_CHARGE_CLI;

--Extraction de la LISTE DES SOCIETES CLIENTES
PROCEDURE P_LIST_SOCIETE_CLI(i_date  IN DATE DEFAULT SYSDATE)
IS

  list_societe_cli   CLOB;
  loc_repertoire  VARCHAR2(20):='EXTRANET_PARTENAIRE';
  loc_fichier     VARCHAR2(50);

BEGIN

  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_SOCIETE_CLI',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Debut de traitement '||sysdate,
                              I_idligne  => 1);
  loc_fichier   :='Liste_SOCIETE_'||TO_CHAR(SYSDATE,'YYYY-MM-DD-hh24miss')||'.csv';

  SELECT dbms_xmlgen.CONVERT(xmlagg(xmlelement(e,TRANSLATE(liste
                                                              ,'àèéêêëçâîïùûôÀÂÉÈÊËÎÏÙÛÇÔ'
                                                              ,'aeeeeecaiiuuoAAEEEEIIUUCO')
                                                              ,'').EXTRACT('//text()')).GetClobVal(),1) INTO list_societe_cli
  FROM (
      SELECT DISTINCT
      c.numcli
      ||';'|| m.SIRET
      ||';'|| f_nom(c.numcli)
      ||';'|| c.numprod
      ||';'|| pk_libelle.f_lib('PROD',c.numprod)||CHR(13)||CHR(10) liste
      FROM contrat c
      ,pers_morale m
      ,v_GAR_CNTRT g
      WHERE pk_histo_contrat.f_sel_etat(c.numgar) = 1
      AND m.numindiv = c.numcli
      AND c.numgar=g.numgar
      AND i_date BETWEEN g.debut AND NVL(g.fin,i_date)
      AND g.numgar= c.numgar
      AND g.valide ='O'
    )
;
  list_societe_cli :='NUMCLI;SIRET;CLIENT;NUMPRODUIT;LIBELLÉ_PDT'||CHR(13)||CHR(10)||list_societe_cli;
  IF list_societe_cli IS NOT NULL THEN -- s'il nya pas de données, on genere un fichier comportant l'entête uniquement
    DBMS_XSLPROCESSOR.clob2file( list_societe_cli
                                 , loc_repertoire
                                 , loc_fichier
                                );
  END IF;
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_SOCIETE_CLI',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Fin normale de traitement '||sysdate,
                              I_idligne  => 2);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_SOCIETE_CLI',
                                I_session  => SID,
                                I_niv_msg  => 1,
                                I_msg_adm  => substr('Echec de l''extraction : '||sqlerrm,1,100),
                                I_idligne  => 1);
END P_LIST_SOCIETE_CLI;

--Extraction de la LISTE LIEN CLIENT ET CHARGE DE CLIENTELE
PROCEDURE P_LIST_LIEN_CLI_CDC(i_date  IN DATE DEFAULT SYSDATE)
IS

  list_lien_cli_cdc   CLOB;
  loc_repertoire  VARCHAR2(20):='EXTRANET_PARTENAIRE';
  loc_fichier     VARCHAR2(50);

 BEGIN
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_LIEN_CLI_CDC',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Debut de traitement '||sysdate,
                              I_idligne  => 1);
  loc_fichier   :='Lien_CLIENT_CDC_'||TO_CHAR(SYSDATE,'YYYY-MM-DD-hh24miss')||'.csv';

  SELECT dbms_xmlgen.CONVERT(xmlagg(xmlelement(e,TRANSLATE(liste
                                                              ,'àèéêêëçâîïùûôÀÂÉÈÊËÎÏÙÛÇÔ'
                                                              ,'aeeeeecaiiuuoAAEEEEIIUUCO')
                                                              ,'').EXTRACT('//text()')).GetClobVal(),1) INTO list_lien_cli_cdc
  FROM (--LIEN CLIENT ET CHARGE DE CLIENTELE
      SELECT DISTINCT
      a.numindiv
      ||';'||c.numcli ||CHR(13)||CHR(10) liste
      FROM apporteur a, contrat c
      WHERE pk_histo_contrat.f_sel_etat(c.numgar) = 1
      AND a.ETENDUE =2
      AND a.cle = c.numgar
      AND i_date BETWEEN a.debut AND NVL(a.fin,i_date)
    )
;
  --Ajout de l'entête
  list_lien_cli_cdc := 'CDC ARTHUS;Numcli'||CHR(13)||CHR(10)|| list_lien_cli_cdc;
  IF list_lien_cli_cdc IS NOT NULL THEN
    DBMS_XSLPROCESSOR.clob2file( list_lien_cli_cdc
                                 , loc_repertoire
                                 , loc_fichier
                                );
  END IF;
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_LIEN_CLI_CDC',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Fin normale de traitement '||sysdate,
                              I_idligne  => 2);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_LIEN_CLI_CDC',
                                I_session  => SID,
                                I_niv_msg  => 1,
                                I_msg_adm  => substr('Echec de l''extraction : '||sqlerrm,1,100),
                                I_idligne  => 1);
END P_LIST_LIEN_CLI_CDC;

--EXTRACTION de la LISTE DES LIEN PRODUIT ET CHARGE DE CLIENTELE
PROCEDURE P_LIST_LIEN_PROD_CDC(i_date  IN DATE DEFAULT SYSDATE)
IS

  list_lien_prod_cdc   CLOB;
  loc_repertoire  VARCHAR2(20):='EXTRANET_PARTENAIRE';
  loc_fichier     VARCHAR2(50);

BEGIN
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_LIEN_PROD_CDC',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Debut de traitement '||sysdate,
                              I_idligne  => 1);
  loc_fichier   :='Lien_PRODUIT_CDC_'||TO_CHAR(SYSDATE,'YYYY-MM-DD-hh24miss')||'.csv';

  SELECT dbms_xmlgen.CONVERT(xmlagg(xmlelement(e,TRANSLATE(liste
                                                              ,'àèéêêëçâîïùûôÀÂÉÈÊËÎÏÙÛÇÔ'
                                                              ,'aeeeeecaiiuuoAAEEEEIIUUCO')
                                                              ,'').EXTRACT('//text()')).GetClobVal(),1) INTO list_lien_prod_cdc
  FROM (--LIEN PRODUIT ET CHARGE DE CLIENTELE
      SELECT DISTINCT
      a.numindiv
      ||';'||c.numprod ||CHR(13)||CHR(10) liste
      FROM apporteur a, contrat c
      WHERE pk_histo_contrat.f_sel_etat(c.numgar) = 1
      AND a.ETENDUE =2
      AND a.cle = c.numgar
      AND i_date BETWEEN a.debut AND NVL(a.fin,i_date)
    )
;
  --Ajout de l'entête
  list_lien_prod_cdc :='CDC ARTHUS;numproduit'||CHR(13)||CHR(10)||list_lien_prod_cdc;
  IF list_lien_prod_cdc IS NOT NULL THEN
    DBMS_XSLPROCESSOR.clob2file( list_lien_prod_cdc
                                 , loc_repertoire
                                 , loc_fichier
                                );
  END IF;
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_LIEN_PROD_CDC',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Fin normale de traitement '||sysdate,
                              I_idligne  => 2);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_LIEN_PROD_CDC',
                                I_session  => SID,
                                I_niv_msg  => 1,
                                I_msg_adm  => substr('Echec de l''extraction : '||sqlerrm,1,100),
                                I_idligne  => 1);
END P_LIST_LIEN_PROD_CDC;


--EXTRACTION de la LISTE DES CONTRATS
PROCEDURE P_LIST_CONTRAT(i_date  IN DATE DEFAULT SYSDATE)
IS
  list_cntrt   CLOB;
  loc_repertoire  VARCHAR2(20):='EXTRANET_PARTENAIRE';
  loc_fichier     VARCHAR2(50);
BEGIN
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_CONTRAT',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Debut de traitement '||sysdate,
                              I_idligne  => 1);
  loc_fichier   :='Liste_CONTRAT_'||TO_CHAR(SYSDATE,'YYYY-MM-DD-hh24miss')||'.csv';

  SELECT dbms_xmlgen.CONVERT(xmlagg(xmlelement(e,TRANSLATE(liste
                                                              ,'àèéêêëçâîïùûôÀÂÉÈÊËÎÏÙÛÇÔ'
                                                              ,'aeeeeecaiiuuoAAEEEEIIUUCO')
                                                              ,'').EXTRACT('//text()')).GetClobVal(),1) INTO list_cntrt
  FROM (--LISTE DES CONTRATS
        SELECT DISTINCT
        c.refcie
        ||';'|| pk_libelle.f_lib('TYP_CONT',c.type_contrat)
        ||';'|| c.numgar
        ||';'|| c.numcli
        ||';'|| c.numprod
        ||';'|| pk_libelle.f_lib('PROD',c.numprod)
        ||';'|| decode(p.numporte, 20,'DSN', null)
        ||';'|| pk_libelle.f_lib('COLLEGE', c.college)
        ||';'|| pk_libelle.f_lib('GESCO',c.gest_cotis)
        ||';'|| pk_libelle.f_lib('TYPQ',c.typequit )
        ||';'|| pk_libelle.f_lib('TYPC',c.type_calc)
        ||';'|| F_VAL_VAR_ALL(c.numgar,1496,SYSDATE)
        ||';'|| F_VAL_VAR_ALL(c.numgar,1497,SYSDATE)
        ||';'||F_VAL_VAR_ALL(c.numgar,2036,SYSDATE)
        ||CHR(13)||CHR(10) liste
        FROM contrat c LEFT OUTER JOIN porte_contrat p ON (p.numgar = c.numgar and p.numporte =20)
        ,pers_morale m
        ,v_GAR_CNTRT g
        WHERE pk_histo_contrat.f_sel_etat(c.numgar) = 1
        AND m.numindiv = c.numcli
        AND c.numgar=g.numgar
        AND sysdate BETWEEN g.debut AND NVL(g.fin,sysdate)
        AND g.numgar= c.numgar
        AND g.valide ='O'
        );
  --ajout de l'entete
  list_cntrt :='N° contrat juridique;Risque;Numgar;Numcli;Numproduit;Libellé_Pdt;DSN;College;Gestion_cotis;Cot_niveau_appel;Cot_niveau_calcul;Taux_apport;Taux_gestion;Taux_assureur'||CHR(13)||CHR(10)||list_cntrt;
  IF list_cntrt IS NOT NULL THEN
    DBMS_XSLPROCESSOR.clob2file( list_cntrt
                                 , loc_repertoire
                                 , loc_fichier
                                );
  END IF;
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_CONTRAT',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Fin normale de traitement '||sysdate,
                              I_idligne  => 2);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'P_LIST_CONTRAT',
          I_session  => SID,
          I_niv_msg  => 1,
          I_msg_adm  => substr('Echec de l''extraction : '||sqlerrm,1,100),
          I_idligne  => 1);
END P_LIST_CONTRAT;


--Extraction de la LISTE DES GARANTIES (REGIME)
PROCEDURE P_LIST_GARANTIE(i_date  IN DATE DEFAULT SYSDATE)
IS
  list_garantie   CLOB;
  loc_repertoire  VARCHAR2(20):='EXTRANET_PARTENAIRE';
  loc_fichier     VARCHAR2(50);

BEGIN
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_GARANTIE',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Debut de traitement '||sysdate,
                              I_idligne  => 1);
  loc_fichier   :='Liste_GARANTIE_'||TO_CHAR(SYSDATE,'YYYY-MM-DD-hh24miss')||'.csv';

  SELECT dbms_xmlgen.CONVERT(xmlagg(xmlelement(e,TRANSLATE(liste
                                                              ,'àèéêêëçâîïùûôÀÂÉÈÊËÎÏÙÛÇÔ'
                                                              ,'aeeeeecaiiuuoAAEEEEIIUUCO')
                                                              ,'').EXTRACT('//text()')).GetClobVal(),1) INTO list_garantie
  FROM (--LISTE DES GARANTIES (REGIME)
      SELECT DISTINCT
         pk_libelle.f_lib('GARA', gar.baseopt)
        ||';'|| g.libelle
        ||';'|| g.numfor
        ||';'|| c.numgar
        ||';'|| gsap.numfor
        ||';'|| gsap.libelle
        ||';'|| pk_libelle.f_lib('ORGN', f_numorg(NVL(gar.numass, gar.numorg)))
        ||';'|| pk_libelle.f_lib('GARA', gar.baseopt)
        ||';'|| 'SANTE'
        ||CHR(13)||CHR(10) liste
      FROM contrat c
        ,pers_morale m
        ,v_GAR_CNTRT g
        ,v_all_gar gar
        ,formule gsap
      WHERE pk_histo_contrat.f_sel_etat(c.numgar) = 1
      AND m.numindiv = c.numcli
      AND c.numgar=g.numgar
      AND i_date BETWEEN g.debut AND NVL(g.fin,i_date)
      AND g.numgar= c.numgar
      AND g.valide ='O'
      AND g.numfor = gar.numfor
      AND g.numfor_ref = gsap.numfor
      UNION
      SELECT DISTINCT
         NULL
        ||';'|| g.libelle
        ||';'|| g.numfor
        ||';'|| c.numgar
        ||';'|| gsap.numfor
        ||';'|| gsap.libelle
        ||';'|| pk_libelle.f_lib('ORGN', f_numorg(NVL(gar.numass, gar.numorg)))
        ||';'|| NULL
        ||';'|| 'PREVOYANCE'
        ||CHR(13)||CHR(10) liste
      FROM contrat c
        ,pers_morale m
        ,v_GAR_CNTRT g
        ,v_all_gar gar
        ,garanties gsap
      WHERE pk_histo_contrat.f_sel_etat(c.numgar) = 1
      AND m.numindiv = c.numcli
      AND c.numgar=g.numgar
      AND i_date BETWEEN g.debut AND NVL(g.fin,i_date)
      AND g.numgar= c.numgar
      AND g.valide ='O'
      AND g.numfor = gar.numfor
      AND g.numfor_ref = gsap.numfor
    )
;
  --ajout de l'entete
  list_garantie :='Régime;LIBELLE;NUMFOR;NUMGAR;GARANTIE_PRODUIT;LIB_GAR_PRODUIT;ORGANISME;BASE_OPTION;RISQUE_G'||CHR(13)||CHR(10)||list_garantie;
  IF list_garantie IS NOT NULL THEN
    DBMS_XSLPROCESSOR.clob2file( list_garantie
                                 , loc_repertoire
                                 , loc_fichier
                                );
  END IF;
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_GARANTIE',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Fin normale de traitement '||sysdate,
                              I_idligne  => 2);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_GARANTIE',
                                I_session  => SID,
                                I_niv_msg  => 1,
                                I_msg_adm  => substr('Echec de l''extraction : '||sqlerrm,1,100),
                                I_idligne  => 1);
END P_LIST_GARANTIE;


--EXTRACTION de la LISTE DES TARIFICATIONS
PROCEDURE P_LIST_TARIF(i_date  IN DATE DEFAULT SYSDATE)
IS
  list_tarif   CLOB;
  loc_repertoire  VARCHAR2(20):='EXTRANET_PARTENAIRE';
  loc_fichier     VARCHAR2(50);
BEGIN
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_TARIF',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Debut de traitement '||sysdate,
                              I_idligne  => 1);
  loc_fichier   :='Liste_TARIF_'||TO_CHAR(SYSDATE,'YYYY-MM-DD-hh24miss')||'.csv';

  SELECT dbms_xmlgen.CONVERT(xmlagg(xmlelement(e,TRANSLATE(liste
                                                              ,'àèéêêëçâîïùûôÀÂÉÈÊËÎÏÙÛÇÔ'
                                                              ,'aeeeeecaiiuuoAAEEEEIIUUCO')
                                                              ,'').EXTRACT('//text()')).GetClobVal(),1) INTO list_tarif
  FROM (--LISTE DES TARIFICATIONS
      SELECT DISTINCT g.numfor,fc.debut,val.debut,
          g.numfor
        ||';'|| c.numgar
        ||';'|| fc.base
        ||';'|| fc.taux
        ||';'|| to_char(fc.debut,'dd/mm/yyyy')
        ||';'|| to_char(fc.fin ,'dd/mm/yyyy')
        ||';'|| base.lib_variable
        ||';'|| pk_libelle.f_lib('TYPCON',fc.contenu)
        ||';'|| multi.nom_variable
        ||';'|| decode(multi.etendue,7, 'Produit',2,'Contrat',NULL,'sans multiplicateur', 'Autre')
        ||';'|| to_char(val.debut,'dd/mm/yyyy')
        ||';'|| to_char(val.fin,'dd/mm/yyyy')
        ||';'|| val.valeur
        ||CHR(13)||CHR(10) liste
      FROM contrat c
        ,pers_morale m
        ,v_GAR_CNTRT g
        ,frml_prime_simple fc
        LEFT OUTER JOIN def_variable multi  ON (multi.idvariable = fc.taux)
        LEFT OUTER JOIN VAL_VARIABLE val ON (multi.idvariable = val.idvariable
                                         AND val.valide='O'
                                         AND val.etendue=multi.etendue)
        ,def_variable base
      WHERE pk_histo_contrat.f_sel_etat(c.numgar) = 1
      AND c.gest_cotis=1
      AND m.numindiv = c.numcli
      AND c.numgar=g.numgar
      AND i_date BETWEEN g.debut AND NVL(g.fin,i_date)
      AND g.numgar= c.numgar
      AND g.valide ='O'
      AND fc.numfor = g.numfor
      AND fc.valide='O'
      AND base.idvariable = fc.base
      AND ( val.clef = decode(multi.etendue,7,c.numprod,c.numgar) OR val.clef  IS NULL)
      order by g.numfor ,fc.debut,val.debut
      );
  --ajout de l'entete
  list_tarif :='NUMFOR;NUMGAR;BASE;MULTI;DEBUT_TARIF;FIN_TARIF;NOM_BASE;CONTENU;NOM_MULTI;NIV_MULTI;DEBUT_MULTI;FIN_MULTI;VAL_MULTI'||CHR(13)||CHR(10)||list_tarif;
  IF list_tarif IS NOT NULL THEN
    DBMS_XSLPROCESSOR.clob2file( list_tarif
                                 , loc_repertoire
                                 , loc_fichier
                                );
  END IF;
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_TARIF',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Fin normale de traitement '||sysdate,
                              I_idligne  => 2);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'P_LIST_TARIF',
          I_session  => SID,
          I_niv_msg  => 1,
          I_msg_adm  => substr('Echec de l''extraction : '||sqlerrm,1,100),
          I_idligne  => 1);
END P_LIST_TARIF;


--Extraction de la LISTE DES PRESTATIONS PREVOYANCE
PROCEDURE P_LIST_PREST(i_date  IN DATE DEFAULT SYSDATE)
IS
  list_prest   CLOB;
  loc_repertoire  VARCHAR2(20):='EXTRANET_PARTENAIRE';
  loc_fichier     VARCHAR2(50);
BEGIN
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_PREST',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Debut de traitement '||sysdate,
                              I_idligne  => 1);
  loc_fichier   :='Liste_PREV_'||TO_CHAR(SYSDATE,'YYYY-MM-DD-hh24miss')||'.csv';

  SELECT dbms_xmlgen.CONVERT(xmlagg(xmlelement(e,TRANSLATE(liste
                                                              ,'àèéêêëçâîïùûôÀÂÉÈÊËÎÏÙÛÇÔ'
                                                              ,'aeeeeecaiiuuoAAEEEEIIUUCO')
                                                              ,'').EXTRACT('//text()')).GetClobVal(),1) INTO list_prest
  FROM (--liste des sinistres prevoyance
      SELECT pk_libelle.f_lib('CAUS',s.cause)  ||';'||
      S.NOSIN ||';'||
      to_char(s.survenance,'yyyy') ||';'||
      d2e(S.SURVENANCE) ||';'||
      d2e(S. DECLARATION) ||';'||
      d2e(S.PRISCHARGE) ||';'||
      contrat.numprod ||';'||
      contrat.NUMCLI ||';'||
      PK_PERSONNE.F_NOM(contrat.NUMCLI,128,2) ||';'||
      PK_LIBELLE.F_LIB('TYP_ARRET',AR.TYPE) ||';'||
      PK_LIBELLE.F_LIB('HISTO_SITU',histo.ETAT) ||';'||
      contrat.NUMGAR ||';'||
      contrat.REFCIE ||';'||
      g.libelle ||';'||
      DS.NUMINDIV||';'||
      i.nom ||' '||
      i.prenom ||';'||
      d2e(i.datnais)
      ||CHR(13)||CHR(10) liste
      FROM   V_REPARTITION_HISTO_DEST repartition_bene,
        contrat,
        produit p,
        adhe_cntrt,
        DOSSIER_SINISTRE DS,
        repartition
        LEFT OUTER JOIN (SELECT r.nosin,r.idrepartition,
               rtrim (xmlagg (xmlelement (e, d2e(individu.datnais) || ',')).extract ('//text()'), ',') listenaissance
                FROM repartition r , repartition_bene rb, individu
                WHERE r.idrepartition = rb.idrepartition
                  AND r.gest_calc = 1
                  AND rb.valide = 'N'
                  AND r.valide = 'O'
                  --AND r.idrepartition=repartition.idrepartition
                  AND individu.numindiv = rb.numbene
                  GROUP BY r.nosin, r.idrepartition ) dateindiv ON (dateindiv.nosin = repartition.nosin AND dateindiv.idrepartition  =repartition.idrepartition )
        ,sntr_prev s
        LEFT OUTER JOIN  arret ar   ON (ar.nosin=s.nosin
          AND ar.traite<>'A'
          AND ar.debut IN (SELECT max(arret.debut)
          FROM arret
          WHERE  arret.nosin=ar.nosin
          AND arret.traite<>'A' ))
          LEFT OUTER JOIN  v_histo_jours vj ON ( ar.idarret = vj.idcalcul AND vj.fin=ar.fin ),
        garanties g ,
        histo_sntr_prev histo,
        individu i
      WHERE  repartition_bene.valide = 'O'
      AND histo.debut = (select max(h.debut) from histo_sntr_prev h where debut<= i_date  AND h.nosin =s.nosin)
      AND histo.nosin =s.nosin
      AND NOT (histo.etat=2 AND histo.motif=10) -- erreur de saisie
      AND S.IDDOSSIER = DS.IDDOSSIER
      AND DS.numindiv = i.numindiv
      AND repartition.idrepartition    = repartition_bene.idrepartition
      AND repartition.valide='O'
      AND s.nosin = repartition.nosin
      AND adhe_cntrt.numgar            = contrat.numgar
      AND adhe_cntrt.idadhesion        = repartition.idadhesion
      and p.numprod = contrat.numprod
      AND g.numfor = repartition.numfor
      AND s.norisq =4
      AND (histo.etat =1 OR (histo.etat =2 AND histo.debut >= ADD_MONTHS(TRUNC(i_date),-12)))
      );
  --Ajout de l'entête
  list_prest := 'Cause;N° Sinistre;Année (de survenance);Date Survenance;Date de DECLARATION; Date PEC Assureur;Produit;Souscripteur;Libelle Souscripteur;'
                ||'type arret;Libelle État;N° Contrat;Référence Cie;Libellé Garantie;N° Assuré;Nom Prénom Assuré;Date Naissance'||CHR(13)||CHR(10)||list_prest;
  IF list_prest IS NOT NULL THEN
    DBMS_XSLPROCESSOR.clob2file( list_prest
                                 , loc_repertoire
                                 , loc_fichier
                                );
  END IF;
  PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_PREST',
                              I_session  => SID,
                              I_niv_msg  => 1,
                              I_msg_adm  => 'Fin normale de traitement '||sysdate,
                              I_idligne  => 2);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (I_nom_traitement => 'P_LIST_PREST',
                                I_session  => SID,
                                I_niv_msg  => 1,
                                I_msg_adm  => substr('Echec de l''extraction : '||sqlerrm,1,100),
                                I_idligne  => 1);
END P_LIST_PREST;


END PK_EXTRACTION_AUTO;
/
