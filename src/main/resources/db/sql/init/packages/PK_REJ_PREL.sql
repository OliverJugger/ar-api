CREATE OR REPLACE package ARTHUS.PK_REJ_PREL as

TYPE t_rej_prel IS RECORD ( dat_crea       varchar(256),
                            motif_rej      varchar(256),
                            reference      varchar(256),
                            bdx_prelev     number,
                            motif_pay      varchar(256),
                            nom_debit      varchar(256),
                            code_devise    varchar(256),
                            type_rej       varchar(5),
                            montant_rej    varchar(256),
                            numfact        varchar(256),
                            mt_facture     varchar(256),
                            date_eche_fact DATE,
                            num_querable   NUMBER,
                            nom_querable   VARCHAR(256),
                            Numadhesion    VARCHAR(256),
                            Numgar         NUMBER,
                            Numencais      encaismt.numencaismt%TYPE,
                            lib_motif_rej  varchar(256),
                            code_action    varchar(256),
                            lib_code_action varchar(256),
                            respon_action    varchar(256),
                            annulation       varchar(3),
                            msg_erreur       varchar(256),
                            nom_fich         varchar(256)
                            );
--tableau qui recupere les données des fichiers rejets
TYPE TAB_REJ_prel IS TABLE OF t_rej_prel index by binary_integer;

TYPE TYP_XML_TAB is table of XMLTYPE index by binary_integer;
PROCEDURE P_INS_journal(
        P_niv  IN NUMBER,
        p_journal IN OUT JOURNAL_ADM%ROWTYPE,
        P_msg  IN VARCHAR2,
        p_msg2 IN VARCHAR2 := NULL);
FUNCTION f_get_journal(i_traitement varchar2) RETURN journal_adm%rowtype;

PROCEDURE P_REJ_PREL (i_traitement IN VARCHAR2, i_nom_repertoire_in IN VARCHAR2, i_nom_repertoire_done IN VARCHAR2, i_nom_repertoire_out IN VARCHAR2,i_nom_fic_csv IN VARCHAR2, i_sess  IN journal_adm.id_session%type,io_journal IN OUT journal_adm%rowtype, o_erreur OUT NUMBER) ;
PROCEDURE P_REJ_PREL_AUTO;
PROCEDURE P_DECOUP_XML(i_fic IN VARCHAR2, i_rep_in IN VARCHAR2, o_tab_xml OUT TYP_XML_TAB);
PROCEDURE P_IMPORT_REJ_PREL(i_fic_rep IN VARCHAR2,i_fic_xml IN XMLTYPE, i_rep_in IN VARCHAR2,io_tab_rejprel IN OUT TAB_REJ_PREL, o_erreur OUT NUMBER);
PROCEDURE P_GEN_FIC_REJ_PREL(io_tab_rejprel IN TAB_REJ_PREL,i_fichier_export IN VARCHAR2 ,i_repertoire IN VARCHAR2,io_entete IN OUT NUMBER);
PROCEDURE P_INS_AUTO_FLUX_COMMIT (I_DAT       IN DATE,I_NOM       IN VARCHAR2,I_SESSION    IN NUMBER,I_FICHIER       IN VARCHAR2,I_STAT   IN VARCHAR2,I_MSG      IN VARCHAR2,I_MAIL_ENVOI   IN NUMBER Default 0);
PROCEDURE P_ENVOI_MAIL_REJ_PREL (I_traitement in varchar2);
END;

package  BODY  PK_REJ_PREL as
/*===========================================================================*/
/* Procedure    : f_get_journal.sql                                    */
/* Domaine      : Prélèvement                                                */
/* Auteur       : ARTHUS                                                     */
/* Création     : 08/12/2021                                                 */
/* Description  : remonte les traces du traiement vers l'écran forms         */
/*===========================================================================*/
/* Entreé    :                                                               */
/* Sortie    :                                                               */
/*===========================================================================*/
FUNCTION f_get_journal(i_traitement varchar2) RETURN journal_adm%rowtype
IS
io_journal journal_adm%rowtype;
BEGIN
    io_journal.id_session := sid;
    io_journal.idligne := 0;
    io_journal.nom_traitement := nvl(i_traitement,'PV08T');

    RETURN  io_journal;
END f_get_journal;

--P_INS_journal est recodé pour passer io_journal qui permettra de remonter les traces au niveau de l'écran ba21
PROCEDURE P_INS_journal(
        P_niv  IN NUMBER,
        p_journal IN OUT JOURNAL_ADM%ROWTYPE,
        P_msg  IN VARCHAR2,
        p_msg2 IN VARCHAR2 := NULL)
  IS
  BEGIN
      --dbms_output.put_line(P_msg||' '||P_msg2);
     IF p_journal.niv_msg >= P_niv THEN
        p_journal.idligne := p_journal.idligne +1;
       -- dbms_output.put_line(P_msg||' '||P_msg2);
        PK_trace.P_INS_journal_adm ( I_nom_traitement => p_journal.nom_traitement, I_session => p_journal.id_session, I_niv_msg => P_niv, I_msg_adm => P_msg||' '||P_msg2, I_idligne => p_journal.idligne);
     END IF;
  END P_INS_journal;

PROCEDURE P_REJ_PREL(i_traitement IN VARCHAR2, i_nom_repertoire_in IN VARCHAR2, i_nom_repertoire_done IN VARCHAR2, i_nom_repertoire_out IN VARCHAR2,i_nom_fic_csv IN VARCHAR2, i_sess  IN journal_adm.id_session%type, io_journal IN OUT journal_adm%rowtype, o_erreur OUT NUMBER)
/*===========================================================================*/
/* Procedure    : P_REJ_PREL.sql                                    */
/* Domaine      : Prélèvement                                                */
/* Auteur       : ARTHUS                                                     */
/* Création     : 18/11/2021                                                 */
/* Description  : Importation des fichiers de rejets de prélèvement          */
/*===========================================================================*/
/* Entreé    :                                                               */
/* Sortie    :                                                               */
/*===========================================================================*/
IS


  loc_io_tab_rj_prv        TAB_REJ_PREL;
  directory_path_in        all_directories.DIRECTORY_PATH%type;
  last_char                varchar2(1);
  C_listFiles              SYS_REFCURSOR;
  loc_file_repert          varchar2 (200);
  f_name                   varchar2(200);
  loc_err_imp               NUMBER ;
  loc_fichier              VARCHAR2(100);
  tab_fics_xml             TYP_XML_TAB;
  loc_init_t_rj_prel       TAB_REJ_PREL;
  i                        NUMBER :=0;
  l_statut                 VARCHAR2(2);
  l_msg                    VARCHAR2(250);
  l_motif_echec           varchar2(50);
  io_entet                NUMBER;

  nb_fic_ko                NUMBER :=0;
  loc_nomfic_ko            varchar2 (200);
  loc_nb_fic_deplac        NUMBER :=0;

  CURSOR c_fichier_ko(p_session IN auto_flux.idsession%TYPE) IS
    select distinct nomfic
    from auto_flux
    where statut='KO'
    and message like '%ECHEC du traitement d''int%'
    and envoi_mail =0
    and idsession=p_session
    and nomtrt=i_traitement
    ;

    r_fichier_ko c_fichier_ko%ROWTYPE;
BEGIN
    IF io_journal.nom_traitement IS NULL THEN
      io_journal.id_session := sid;
      io_journal.idligne := 0;
      io_journal.nom_traitement := i_traitement;
    END IF;

     BEGIN
      SELECT DECODE(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
      INTO io_journal.niv_msg
      FROM PARAM_BATCH
      WHERE NUMBATCH = io_journal.nom_traitement;
    EXCEPTION
      WHEN OTHERS THEN io_journal.niv_msg:=3;
    END;

  --dbms_output.put_line('debut traitement P_REJ_PREL' );
  l_msg :='debut de traitement '|| TO_CHAR(Sysdate, 'hh24:mi');
  --pour faire remonter les traces vers l'écran au lancement de PV08T via ba21, utilisation de P_INS_journal avec io_journal
  P_INS_journal(1,io_journal, l_msg );
  -- Récupération des chemins physiques en base
  SELECT upper(directory_path) , substr( upper(directory_path) , length(upper(directory_path)) , 1 )
  INTO directory_path_in , last_char
  FROM all_directories
  WHERE directory_name = i_nom_repertoire_in ;

  --verification du dernier caractère du chemin physique
  if last_char <> '\' then --'
      directory_path_in := directory_path_in ||'\'; --'
  end if;

--parcourir le repertoire IN pour lire les fichiers et importer les fichiers

 --listes les fichiers présents --'
  sys.PK_EXT_UTILS.ListFiles(directory_path_in,C_listFiles);
  BEGIN --'
    LOOP
      FETCH C_listFiles INTO f_name; --'
      EXIT WHEN C_listFiles%NOTFOUND; --'

      loc_file_repert := replace(REPLACE(f_name,directory_path_in),'\') ; --'
    --découpage du fichier physique
    --dbms_output.put_line('avant decoupage xml' );
      BEGIN
        P_DECOUP_XML(loc_file_repert ,i_nom_repertoire_in, tab_fics_xml);
        IF tab_fics_xml.COUNT =0 THEN
          l_msg :='Découpage du fichier impossible '|| loc_file_repert||' '||TO_CHAR(Sysdate, 'hh24:mi')||' tab_fics_xml.COUNT '||tab_fics_xml.COUNT;
          l_statut :='KO';
          P_INS_journal(1,io_journal, l_msg );
          l_motif_echec :='Découpage du fichier impossible';
          l_msg := 'ECHEC du traitement d''intégration du fichier '|| loc_file_repert|| 'au motif :'|| l_motif_echec;
          P_INS_AUTO_FLUX_COMMIT ( sysdate,
                        i_traitement,
                        SID,
                        loc_file_repert,
                        l_statut,
                        l_msg ,
                        0);
         CONTINUE ;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          --dbms_output.put_line('Fin KO P_REJ_PREL '||SUBSTR (SQLERRM (SQLCODE), 1, 20) );
          l_msg :='Découpage du fichier impossible '|| loc_file_repert||' '||TO_CHAR(Sysdate, 'hh24:mi')||SUBSTR (SQLERRM (SQLCODE), 1, 20);
          l_statut :='KO';
          P_INS_journal(1,io_journal, l_msg );
          l_motif_echec :='Découpage du fichier impossible';
          l_msg := 'ECHEC du traitement d''intégration du fichier '|| loc_file_repert|| 'au motif :'|| l_motif_echec;
          P_INS_AUTO_FLUX_COMMIT ( sysdate,
                        i_traitement,
                        SID,
                        loc_file_repert,
                        l_statut,
                        l_msg ,
                        0);
         CONTINUE ;
      END ;

      --dbms_output.put_line('apres decoupage xml'||loc_err_decoup );

      for i IN 1 .. tab_fics_xml.COUNT LOOP
        --pour chaque fichier xml (provenant du découpage), on recupere les données avec P_import_rej_prel
        --Récupération des données du fichier xml
        --dbms_output.put_line('avant imp_rej_prel ' );
        BEGIN
          P_IMPORT_REJ_PREL(loc_file_repert, tab_fics_xml(i),i_nom_repertoire_in,loc_io_tab_rj_prv, loc_err_imp);
          IF loc_err_imp < 0 THEN
           o_erreur := -1 ;
          end if;
        EXCEPTION
          WHEN OTHERS THEN
          ROLLBACK;
          l_msg :='Traitement du '||i||'ème XML impossible '|| loc_file_repert||' '||TO_CHAR(Sysdate, 'hh24:mi')||SUBSTR (SQLERRM (SQLCODE), 1, 20);
          l_statut :='KO';
          P_INS_journal(1,io_journal, l_msg );
          l_motif_echec :='Traitement du '||i||'ème XML impossible';
          l_msg := 'ECHEC du traitement d''intégration du fichier '|| loc_file_repert|| 'au motif :'|| l_motif_echec;
          P_INS_AUTO_FLUX_COMMIT ( sysdate,
                        i_traitement,
                        SID,
                        loc_file_repert,
                        l_statut,
                        l_msg ,
                        0);
          CONTINUE ;

        END;
        --dbms_output.put_line('apres imp_rej_prel i '||i||' erreur ' ||loc_err_imp);
      end loop;


        --dbms_output.put_line('i_nom_fic_csv '||i_nom_fic_csv );
        --generation du fichier csv de sortie (un seul fichier csv par lancement de traitement)
      BEGIN
        P_GEN_FIC_REJ_PREL(loc_io_tab_rj_prv,i_nom_fic_csv, i_nom_repertoire_out, io_entet);
      EXCEPTION
        WHEN OTHERS THEN
        --dbms_output.put_line('Fin KO P_REJ_PREL '||SUBSTR (SQLERRM (SQLCODE), 1, 20) );
        o_erreur := -1;
        ROLLBACK;
        l_msg :='Traitement ecriture fichier CSV impossible '||TO_CHAR(Sysdate, 'hh24:mi')||SUBSTR (SQLERRM (SQLCODE), 1, 20);
        l_statut :='KO';
        P_INS_journal(1,io_journal, l_msg );
        l_motif_echec :='écriture fichier CSV impossible';
        l_msg := 'ECHEC du traitement d''intégration du fichier '|| loc_file_repert|| 'au motif :'|| l_motif_echec;
        P_INS_AUTO_FLUX_COMMIT ( sysdate,
                        i_traitement,
                        SID,
                        loc_file_repert,
                        l_statut,
                        l_msg ,
                        0);
        CONTINUE ;
      END;
        --dbms_output.put_line('apres gen_fic_csv loc_err_gen_csv '||loc_err_gen_csv );
        --remise à vide du tableau
        loc_io_tab_rj_prv :=loc_init_t_rj_prel;
        --dbms_output.put_line('apres reintit count '||loc_io_tab_rj_prv.count );

        select count(distinct nomfic) into nb_fic_ko
        from auto_flux
        where statut='KO'
        and message like '%ECHEC du traitement d''int%'
        and envoi_mail =0
        and idsession=SID
        and nomtrt=i_traitement
        ;
        loc_nb_fic_deplac :=0;
        IF nb_fic_ko >0 THEN
        -- deplacement du fichier physique traité
          FOR r_fichier_ko IN c_fichier_ko(SID) LOOP
            loc_nomfic_ko := r_fichier_ko.nomfic;
            IF loc_file_repert=loc_nomfic_ko THEN
             --on ne deplace pas le fichier non traité
              l_msg :='Fichier '||loc_file_repert||' non traité pas de deplacement vers le repertoire DONE';
              loc_nb_fic_deplac :=0;
              P_INS_journal(1,io_journal, l_msg );
            ELSE --fichier traité
              BEGIN
                UTL_FILE.FCOPY  (i_nom_repertoire_in , loc_file_repert, i_nom_repertoire_done,loc_file_repert);
                UTL_FILE.FREMOVE(i_nom_repertoire_in,loc_file_repert);
                l_msg :='fichier '||loc_file_repert||' déplacé dans répertoire des traitées DONE';
                loc_nb_fic_deplac :=1;
                P_INS_journal(1,io_journal, l_msg );
              EXCEPTION
                WHEN OTHERS THEN
                ROLLBACK;
                l_msg :='Déplacement fichier XML impossible '||loc_file_repert||' '||TO_CHAR(Sysdate, 'hh24:mi')||SUBSTR (SQLERRM (SQLCODE), 1, 20);
                l_statut :='KO';
                P_INS_journal(1,io_journal, l_msg );
                l_motif_echec :='Déplacement fichier XML impossible';
                l_msg := 'ECHEC du traitement d''intégration du fichier '|| loc_file_repert ||'au motif :'|| l_motif_echec;
                P_INS_AUTO_FLUX_COMMIT ( sysdate,
                                i_traitement,
                                SID,
                                loc_file_repert,
                                l_statut,
                                l_msg ,
                                0);
                CONTINUE ;
              END;
            END IF;
          END LOOP;
        ELSE --aucun fichier non traité sur cette session donc on deplace tous les fichiers traités
          -- deplacement du fichier physique traité
          l_msg :='session '||SID||' aucun fichier ko donc deplacement de tous les fichiers';
          P_INS_journal(2,io_journal, l_msg );
          BEGIN
            UTL_FILE.FCOPY  (i_nom_repertoire_in , loc_file_repert, i_nom_repertoire_done,loc_file_repert);
            UTL_FILE.FREMOVE(i_nom_repertoire_in,loc_file_repert);
            l_msg :='session '||SID||' fichier '||loc_file_repert||' déplacé dans répertoire des traitées DONE';
            loc_nb_fic_deplac :=1;
            P_INS_journal(1,io_journal, l_msg );
          EXCEPTION
            WHEN OTHERS THEN
            ROLLBACK;
            l_msg :='Déplacement fichier XML impossible '||loc_file_repert||' '||TO_CHAR(Sysdate, 'hh24:mi')||SUBSTR (SQLERRM (SQLCODE), 1, 20);
            l_statut :='KO';
            P_INS_journal(1,io_journal, l_msg );
            l_motif_echec :='Déplacement fichier XML impossible';
            l_msg := 'ECHEC du traitement d''intégration du fichier '|| loc_file_repert ||'au motif :'|| l_motif_echec;
            P_INS_AUTO_FLUX_COMMIT ( sysdate,
                            i_traitement,
                            SID,
                            loc_file_repert,
                            l_statut,
                            l_msg ,
                            0);
            CONTINUE ;
          END;
        END IF;--nb_fic_ko


      COMMIT;
          --dbms_output.put_line('apres commit ');
      IF loc_nb_fic_deplac >0 THEN
        l_msg :='Import du fichier de rejet de prélèvement '|| loc_file_repert||' reussi';
        l_statut :='OK';
        P_INS_journal(1,io_journal, l_msg );
        l_msg :='Le traitement d''intégration du fichier '|| loc_file_repert ||' s''est déroulé correctement. Les informations de l''intégration du fichier sont dans le rapport '||i_nom_fic_csv;
        P_INS_AUTO_FLUX_COMMIT ( sysdate,
                          i_traitement,
                          SID,
                          loc_file_repert,
                          l_statut,
                          l_msg ,
                          0);

      END IF;
      END LOOP;
      CLOSE C_listFiles;

  END;
  -- le traitement manuel ne doit pas envoyer de mail, mise à jour envoi_mail à 1 afin que le traitement automatique qui tourne le matin ne ramasse pas les mails crées lors de l'import manuel
  IF i_traitement='PV08T' THEN --import manuel des rejets de prelevement
    update auto_flux set envoi_mail=1 where idsession=SID and nomtrt=i_traitement and envoi_mail=0;
    commit;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    CLOSE C_listFiles;
    --dbms_output.put_line('Fin KO P_REJ_PREL '||SUBSTR (SQLERRM (SQLCODE), 1, 20) );
    o_erreur := -1;
    l_msg := 'Fin anomale'|| TO_CHAR(Sysdate, 'hh24:mi')||SUBSTR (SQLERRM (SQLCODE), 1, 80);
    P_INS_journal(1,io_journal, l_msg );
END P_REJ_PREL;

PROCEDURE P_REJ_PREL_AUTO
/*===========================================================================*/
/* Procedure    : P_REJ_PREL_AUTO.sql                                        */
/* Domaine      : Prélèvement                                                */
/* Auteur       : ARTHUS                                                     */
/* Création     : 18/11/2021                                                 */
/* Description  : Importation automatique des fichiers de rejets de prélèvement  */
/*===========================================================================*/
/* Entreé    :                                                               */
/* Sortie    :                                                               */
/*===========================================================================*/
IS
  v_nom_fic_exp			       typ_batch.RESSOURCE%TYPE;
  v_nom_repertoire_in	     typ_batch.REPERTOIRE%TYPE;
  v_nom_repertoire_done    typ_batch.REPERTOIRE%TYPE :='REJET_PRELEVEMENT_DONE';
  v_nom_repertoire_out	   typ_batch.REPERTOIRE%TYPE;
  loc_fichier              VARCHAR2(100);
  l_numlig                 NUMBER :=0;
  l_msg                    journal_adm.msg_adm%TYPE;
  l_erreur                 number;
  L_io_journal             journal_adm%rowtype ;
BEGIN
  L_io_journal.id_session := sid;
  L_io_journal.idligne := 0;
  L_io_journal.nom_traitement := 'P_REJ_PREL_AUTO';
  --dbms_output.put_line('debut traitement P_REJ_PREL_AUTO' );
  --utilisation de pk_trace.P_INS_journal_adm classique dans toutes les autres procedures
  l_msg :='debut de traitement '|| TO_CHAR(Sysdate, 'hh24:mi');
  P_INS_journal(1,L_io_journal, l_msg );
-- Récupération du repertoire paramétré sur le traitement
  begin
    select repertoire into v_nom_repertoire_in
    from typ_batch
    where batchid = upper('PV08T')
    and repertoire is not null ;
  Exception
    WHEN NO_DATA_FOUND THEN
      l_msg :='Répertoire non paramétré sur PV08T';
      P_INS_journal(1,L_io_journal, l_msg );
      RETURN; --on ne doit pas continuer si le repertoire n'est pas indiqué
  end ;
  begin
    --Recupération du repertoire d''export pour le depot du fichier csv --'
    select repertoire,ressource into v_nom_repertoire_out, v_nom_fic_exp
    from typ_batch
    where batchid = upper('PV09T')
    and repertoire is not null ;
  exception
    WHEN NO_DATA_FOUND THEN
      l_msg :='Nom de fichier/repertoire non paramétré sur PV09T';
      P_INS_journal(1,L_io_journal, l_msg );
      RETURN; --on ne doit pas continuer si le repertoire d''export/le nom du fichier n'est pas indiqué
  end;
  --Nom du fichier csv exporté est normalisé : YYYYMMDD_HHMM_Rapport_Integration_rejet_prelevement -->#DT_#HR_Rapport_Integration_rejet_prelevement.csv
  SELECT REPLACE (REPLACE (v_nom_fic_exp, '#DT', to_char(sysdate,'YYYYMMDD')),
                '#HR',
                TO_CHAR (SYSDATE, 'HH24MI')
                  )

  INTO loc_fichier
  FROM DUAL;


  P_REJ_PREL(i_traitement =>'P_REJ_PREL_AUTO'
            , i_nom_repertoire_in =>v_nom_repertoire_in
            , i_nom_repertoire_done =>v_nom_repertoire_done
            , i_nom_repertoire_out =>v_nom_repertoire_out
            , i_nom_fic_csv => loc_fichier
            , i_sess =>L_io_journal.id_session
            , io_journal => L_io_journal
            , o_erreur =>l_erreur)
            ;
  --envoi du mail de rapport de traitement
  P_ENVOI_MAIL_REJ_PREL ('P_REJ_PREL_AUTO');

  IF l_erreur <0 THEN
	  l_msg := TO_CHAR(Sysdate, 'dd/mm/yyyy - hh24:mi')||' - Fin anormale du traitement '||substr(sqlerrm(sqlcode),1,20);

	ELSE
		l_msg := TO_CHAR(Sysdate, 'dd/mm/yyyy - hh24:mi') || ' - fin normale du traitement';
	END IF;
	P_INS_journal(1,L_io_journal, l_msg );

EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('Fin KO P_REJ_PREL_AUTO '||SUBSTR (SQLERRM (SQLCODE), 1, 20) );
    l_erreur :=-1;
    l_msg :='Fin anomale'|| TO_CHAR(Sysdate, 'hh24:mi')||SUBSTR (SQLERRM (SQLCODE), 1, 80);
    P_INS_journal(1,L_io_journal, l_msg );
END P_REJ_PREL_AUTO;

--------------------
/*==================================================================================*/
/* Procedure   : P_DECOUP_XML.sql                                                   */
/* Domaine     : Prélèvement                                                        */
/* Auteur      : ARTHUS                                                             */
/* Création    : 18/11/2021                                                         */
/* Description : Un ficher physique peut contenir n fichier xml, cette procédure    */
/*             a pour but de découper un fichier physique en plusieurs fichier xml  */
/*==================================================================================*/
/* Entreé    :                                                                      */
/* Sortie    :                                                                      */
/*==================================================================================*/
PROCEDURE P_DECOUP_XML(i_fic IN VARCHAR2, i_rep_in IN VARCHAR2, o_tab_xml OUT TYP_XML_TAB)
IS
  --TYPE TYP_XML_TAB is table of XMLTYPE index by binary_integer;
  loc_bfile         BFILE;
  fLen              NUMBER;
  loc_clobfile      CLOB;
  loc_clobxml       CLOB;
  --t_xml             TYP_XML_TAB;
  i_Xml             NUMBER;
  i_Xml_PosDeb   NUMBER;
  i_Xml_PosFin   NUMBER;
  l_numlig       NUMBER :=0;

BEGIN

  --dbms_output.put_line('Debut traitement P_DECOUP_XML');
  l_numlig :=l_numlig+1;
  pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_DECOUP_XML',
                            I_session     =>SID,
                            I_niv_msg     =>1,
                            I_msg_adm     =>'debut decoupage du fichier '||i_fic||' '|| TO_CHAR(Sysdate, 'hh24:mi'),
                            I_date        =>sysdate,
                            I_idligne	    =>l_numlig);
  loc_bfile:= bfilename(i_rep_in,i_fic);--bfilename('REJET_PRELEVEMENT_IN','PSRHSBC_CONCAT.XML');
  --loc_xml_source := new xmltype(loc_bfile, nls_charset_id('UTF-8'));

  DBMS_LOB.OPEN(loc_bfile, dbms_lob.file_readonly);
  fLen := dbms_lob.getlength(loc_bfile);
  --dbms_output.put_line('longueur=' ||fLen );

  DBMS_LOB.CREATETEMPORARY (loc_clobfile, FALSE) ;
  --dbms_output.put_line('Ici' );
  DBMS_LOB.LOADFROMFILE(loc_clobfile, loc_bfile, DBMS_LOB.LOBMAXSIZE );

  i_Xml := 1;
  WHILE i_Xml <= 1000 LOOP
     -- identification de la position du i_Xml-ième "<?xml"
     i_Xml_PosDeb := DBMS_LOB.INSTR(loc_clobfile,'<?xml', 1, i_Xml );
     -- S'il n'y a pas de i_Xml-ième "<?xml", on sort de la boucle
     IF i_Xml_PosDeb IS NULL OR i_Xml_PosDeb <= 0 THEN
       EXIT;
     END IF;
     -- identification de la position du (i_Xml +1)-ième "<?xml"
     i_Xml_PosFin := DBMS_LOB.INSTR(loc_clobfile,'<?xml', 1, i_Xml +1 ) -1 ;
     -- S'il n'y a pas de (i_Xml +1)-ième "<?xml", on indique la position de fin de fichier
     IF i_Xml_PosFin IS NULL  OR i_Xml_PosFin <= 0 THEN
        i_Xml_PosFin := fLen ;
     END IF;
     --dbms_output.put_line('xml n°' || i_Xml || ' de ' || i_Xml_PosDeb || ' a '|| i_Xml_PosFin );

     DBMS_LOB.CREATETEMPORARY (loc_clobxml, FALSE) ;
     DBMS_LOB.COPY(dest_lob    => loc_clobxml
                 , src_lob     => loc_clobfile
                 , amount      => i_Xml_PosFin - i_Xml_PosDeb +1
                 , dest_offset => 1
                 , src_offset  => i_Xml_PosDeb ) ;
     --t_xml(i_Xml) := xmltype.createxml( loc_clobxml);
     o_tab_xml(i_Xml) := xmltype.createxml( loc_clobxml);

     --dbms_output.put_line(t_xml(i_Xml).getstringval() );
     --dbms_output.put_line(o_tab_xml(i_Xml).getstringval() );
     --dbms_output.put_line('-------------------------------------------------');
     DBMS_LOB.FREETEMPORARY (loc_clobxml);

     i_Xml := i_Xml + 1;
  END LOOP;

  DBMS_LOB.FREETEMPORARY (loc_clobfile);
  dbms_lob.close(loc_bfile);
  --fermeture du fichier s'il est ouvert sinon Oracle le verrouille et impossible de le deplacer ou supprimer
  IF loc_bfile IS NOT NULL AND DBMS_LOB.ISOPEN(loc_bfile) = 1 THEN
    dbms_lob.close(loc_bfile);
  END IF;

  --dbms_output.put_line('Fin traitement P_DECOUP_XML' );
  l_numlig :=l_numlig+1;
  pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_DECOUP_XML',
                              I_session     =>SID,
                              I_niv_msg     =>1,
                              I_msg_adm     =>'Fin de découpage du fichier :'||i_fic,
                              I_date        =>sysdate,
                              I_idligne	    =>l_numlig);

EXCEPTION
  WHEN OTHERS THEN
  --fermeture du fichier s'il est ouvert sinon Oracle le verrouille et impossible de le deplacer ou supprimer
    IF loc_bfile IS NOT NULL AND DBMS_LOB.ISOPEN(loc_bfile) = 1 THEN
      dbms_lob.close(loc_bfile);
    END IF;
    l_numlig :=l_numlig+1;
    pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_DECOUP_XML',
                              I_session     =>SID,
                              I_niv_msg     =>1,
                              I_msg_adm     =>'Fin anormale découpage du fichier :'||i_fic,
                              I_date        =>sysdate,
                              I_idligne	    =>l_numlig);
END P_DECOUP_XML;


---------------

/*===========================================================================*/
/* Procedure    : P_IMPORT_REJ_PREL.sql                                    */
/* Domaine      : Prélèvement                                                */
/* Auteur       : ARTHUS                                                     */
/* Création     : 18/11/2021                                                 */
/* Description  : Importation des fichiers de rejets de prélèvement          */
/*===========================================================================*/
/* Entreé    :                                                               */
/* Sortie    :                                                               */
/*===========================================================================*/
PROCEDURE P_IMPORT_REJ_PREL(i_fic_rep IN VARCHAR2,i_fic_xml IN XMLTYPE, i_rep_in IN VARCHAR2,io_tab_rejprel IN OUT tab_rej_prel , o_erreur OUT NUMBER) IS
  loc_xml_source    XMLTYPE;
  loc_namespace    VARCHAR2(100) :='xmlns="urn:iso:std:iso:20022:tech:xsd:camt.054.001.02"';
  loc_TxDtls        XMLTYPE;
  loc_Ntfctn         XMLTYPE;
  loc_Ntry           XMLTYPE;
  loc_balise_amt      XMLTYPE;
  loc_code_devise     VARCHAR2(256);
  loc_dat_crea       VARCHAR2(256);
  loc_montant_rej    VARCHAR2(256);
  loc_ref_rp         VARCHAR2(256);
  loc_motif_pay      VARCHAR2(256);
  loc_motif_pay_brut VARCHAR2(256);
  loc_msg_erreur     VARCHAR2(256);
  loc_annulation     VARCHAR2(3);
  loc_motif_rejet_transco      VARCHAR2(2);
  loc_debiteur      VARCHAR2(256);
  loc_nom_debit      VARCHAR2(256);
  cpt_Ntfctn          NUMBER :=0;
  cpt_Ntry            NUMBER :=0;
  cpt_TxDtls          NUMBER :=0;
  cpt                 NUMBER :=0;
  l_numlig            NUMBER :=0;
  loc_erreur          VARCHAR2(100);
  loc_numencais       NUMBER(10) :=0;
  loc_typrj           VARCHAR2(2);
  loc_type_rej        VARCHAR2(15);
  loc_motif_rej     VARCHAR2(5);--MD01
  loc_lib_motif_rej VARCHAR2(256);
  loc_action        VARCHAR2(2);
  loc_lib_action    VARCHAR2(256);
  loc_respon_action VARCHAR2(256);
  LOC_QUERABLE      NUMBER;
  loc_nb_prel         NUMBER;
  loc_nb_encais_affect NUMBER;
  loc_nb_encais_annul      NUMBER;
  loc_num_bdx_prelev   prelevement.numremise%TYPE;

  flag_fact           NUMBER;

  CURSOR c_factures(p_reference IN VARCHAR2) IS
  select  pvd.numprelev,
        qg.idadhesion,
        qg.numgar,
        pvd.numfact,
        qg.numquerable num_querable,
        f_nom(qg.numquerable) nom_querable,
        f.echeance
        ,f.montant
  from qttc_global qg, facture f, prelevement_detail pvd
  where pvd.numfact=f.numfact
  and qg.numquit=pvd.numfact
  and f.codope=pvd.codope
  and f.codope=4
  and pvd.numprelev=substr(p_reference,7) --2827768--refer
  --Ajout d'un tri sur le numfact afin de s'appuyer sur flag_fact pour afficher qu'une seule fois le montant rejet (uniquement sur la premiere facture) si plusieurs factures pour la reference de prelev traité
  order by numfact
  ;
BEGIN
  loc_xml_source := i_fic_xml;

  l_numlig :=l_numlig+1;
  pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_IMPORT_REJ_PREL',
                            I_session     =>SID,
                            I_niv_msg     =>1,
                            I_msg_adm     =>'debut de traitement '|| TO_CHAR(Sysdate, 'hh24:mi'),
                            I_date        =>sysdate,
                            I_idligne	    =>l_numlig);

  --dbms_output.put_line(loc_xml_source.getstringval() );
  cpt_Ntfctn :=1;
  cpt :=io_tab_rejprel.COUNT +1;
  WHILE loc_xml_source.existsNode('//Ntfctn[' || cpt_Ntfctn || ']', loc_namespace ) = 1 LOOP
    loc_Ntfctn := loc_xml_source.extract('//Ntfctn[' || cpt_Ntfctn || ']', loc_namespace);--Ntfctn
    --io_tab_rejprel(cpt_Ntfctn).dat_crea:= pk_xml.extract_data2(loc_Ntfctn,'//CreDtTm',loc_namespace);
    loc_dat_crea:= pk_xml.extract_data2(loc_Ntfctn,'//CreDtTm',loc_namespace);
    --dbms_output.put_line('loc_dat_crea '||loc_dat_crea );
    -- /Document/BkToCstmrDbtCdtNtfctn/Ntfctn//TxDtls
    cpt_Ntry :=1;
    --dbms_output.put_line('rko '||loc_Ntfctn.existsNode('//Ntry[' || cpt_Ntry || ']', loc_namespace ));
    WHILE loc_Ntfctn.existsNode('//Ntry[' || cpt_Ntry || ']', loc_namespace ) = 1 LOOP
      --en fait dans Ntry, il ya deux balise Amt --> Ntry/Amt (qu'on veut) et Ntry/NtryDtls/TxDtls/AmtDtls/Amt
      loc_Ntry := loc_Ntfctn.extract('//Ntry[' || cpt_Ntry || ']', loc_namespace);
      --loc_balise_ccy := loc_Ntfctn.extract('//Ntry[' || cpt_Ntry || ']/Amt/@Ccy', loc_namespace).getstringval();
      loc_balise_amt :=loc_Ntfctn.extract('//Ntry[' || cpt_Ntry || ']/Amt', loc_namespace);
      --io_tab_rejprel(cpt_Ntry).montant_rej :=pk_xml.extract_data2(loc_balise_amt,'/Amt',loc_namespace);-- montant 298.11
      loc_montant_rej :=pk_xml.extract_data2(loc_balise_amt,'/Amt',loc_namespace);-- montant 298.11
      --dbms_output.put_line('loc_montant_rej '||loc_montant_rej );
      loc_code_devise:= pk_xml.extract_data2(loc_balise_amt,'/Amt/@Ccy',loc_namespace);--EUR
      --test sur l'existance d'au moins une balise TxDtls dans le fichier xml
      --dbms_output.put_line('rko TxDtls='||loc_Ntry.existsNode('//TxDtls[' || cpt_TxDtls || ']', loc_namespace ));
      IF loc_Ntry.existsNode('//TxDtls[' || 1 || ']', loc_namespace )=0 THEN
        loc_annulation :='Non';
        loc_msg_erreur :='Identification du prélèvement impossible';
        --les infos prelev(motif de paiement) et le debiteur sont renseignés quand la reference de prelev est introuvable mais si la balise TxDtls est absente, on aura pas le nom du debiteur ni le motif de paiement car ces données sont dans le bloc TxDtls
          io_tab_rejprel(cpt).dat_crea        :=   loc_dat_crea;
          io_tab_rejprel(cpt).motif_rej       :=   null;
          io_tab_rejprel(cpt).reference       :=   null;
          io_tab_rejprel(cpt).bdx_prelev      :=   null;
          io_tab_rejprel(cpt).motif_pay       :=   null; --=infos prelevement
          io_tab_rejprel(cpt).nom_debit       :=   null;
          io_tab_rejprel(cpt).code_devise     :=   loc_code_devise;
          io_tab_rejprel(cpt).type_rej        :=   null;
          io_tab_rejprel(cpt).montant_rej     :=   loc_montant_rej;
          io_tab_rejprel(cpt).numfact         :=   null;
          io_tab_rejprel(cpt).mt_facture      :=   null;
          io_tab_rejprel(cpt).date_eche_fact  :=  null;
          io_tab_rejprel(cpt).num_querable    :=  null;
          io_tab_rejprel(cpt).nom_querable    :=  null;
          io_tab_rejprel(cpt).Numadhesion     :=  null;
          io_tab_rejprel(cpt).Numgar          :=  null;
          io_tab_rejprel(cpt).Numencais       :=  null;
          io_tab_rejprel(cpt).lib_motif_rej   :=  null;
          io_tab_rejprel(cpt).code_action     :=  null;
          io_tab_rejprel(cpt).lib_code_action := null;
          io_tab_rejprel(cpt).respon_action   := null;
          io_tab_rejprel(cpt).annulation      := loc_annulation;
          io_tab_rejprel(cpt).msg_erreur      := loc_msg_erreur;
          io_tab_rejprel(cpt).nom_fich        := i_fic_rep;
      END IF;
      cpt_TxDtls := 1;

      WHILE loc_Ntry.existsNode('//TxDtls[' || cpt_TxDtls || ']', loc_namespace ) = 1 LOOP
        --dbms_output.put_line('Lecture branche TxDtls[' ||cpt_TxDtls || ']' );
        loc_TxDtls := loc_Ntry.extract('//TxDtls[' || cpt_TxDtls || ']', loc_namespace);
        --dbms_output.put_line(loc_TxDtls.getstringval() );
        --dbms_output.put_line('ref '||loc_ref_rp );
        loc_ref_rp := pk_xml.extract_data2(loc_TxDtls,'//EndToEndId',loc_namespace);
        --dbms_output.put_line('loc_ref_rp '||loc_ref_rp ); --REF - 2455912
        --reinitialisation du n°de bordereaux de prelev
        loc_num_bdx_prelev :=null;
        IF loc_ref_rp IS NULL THEN --balise EndToEndId absente
            loc_annulation :='Non';
            loc_msg_erreur :='Identification du prélèvement impossible';
            --ne pas renseigner le motif d'annulation, ni le code action, ni le libelle action,ni le responsable action, ni le numencaismt si prelev non identifié dans le fichier xml ou inexistant dans Arthus
            loc_lib_motif_rej :=null;
            loc_lib_action :=null;
            loc_action :=null;
            loc_respon_action :=null;
            loc_numencais :=null;

        ELSE

          loc_motif_rej:= pk_xml.extract_data2(loc_TxDtls,'//Cd',loc_namespace);
          --dbms_output.put_line('motif_rej'||loc_motif_rej); --MD01
          --dbms_output.put_line('tab.motif_rej '||io_tab_rejprel(cpt_TxDtls).motif_rej); --MD01

          --determination si rejet B2B ou B2C (balise <Ntry><BkTxCd><Prtry><Cd> B3 pour B2C et B4 pour B2B
          loc_typrj := pk_xml.extract_data2(loc_Ntry,'//Prtry/Cd',loc_namespace);
          --dbms_output.put_line('loc_typrj '||loc_typrj);
          select decode(loc_typrj,'B3','B2C','B4','B2B',' ') into loc_type_rej
          from dual;

          IF loc_motif_rej IS NOT NULL THEN -- balise <Rsn><Cd> et <Cd> presente
            --transcodification du motif de rejet en motif arthus
            loc_motif_rejet_transco := F_GET_TRANSCO (p_tiers =>'SEPA',
                                              p_mnemo =>loc_type_rej||'REJTANN',
                                              p_val   =>loc_motif_rej,--io_tab_rejprel(cpt_TxDtls).motif_rej,
                                              p_sens  =>1);
            IF loc_motif_rejet_transco IS NULL THEN --motif introuvable dans arthus
              loc_motif_rejet_transco :='99';--libelle =Code rejet SEPA non identifié dans Arthus
              loc_msg_erreur :='Motif de rejet SEPA inconnu';
              --dbms_output.put_line('loc_msg_erreur '||loc_msg_erreur);
            END IF;
          --END IF;

          --dbms_output.put_line('loc_lib_motif_rej '||loc_lib_motif_rej);

            --transcodification du code action de gestion en code arthus --> pour le fichier csv
            loc_action :=F_GET_TRANSCO (p_tiers =>'SEPA',
                          p_mnemo =>loc_type_rej||'REJTACT',
                          p_val   =>loc_motif_rej,
                          p_sens  =>1) ;
            begin
              select libelle
              into loc_lib_action
              from libelle where mnemo='PREVACT' and code=to_number(loc_action);
            exception
            --si pas de code_action en base, on ne met rien dans loc_action=null, n'existe pas de code_action par defaut comme pour le motif-- ok Sylvie
              when no_data_found then loc_lib_action :='Aucun code action gestion paramétré pour le motif '|| loc_motif_rej;
              when too_many_rows then loc_lib_action :='Plusieurs codes action gestion paramétrés pour le motif '|| loc_motif_rej;
              when others then loc_lib_action :='Erreur technique sur la transco du code action pour motif '|| loc_motif_rej;
            end;

            begin
              select decode(sens,1,'Cotisation',2,'Affiliation','Aucun')
              into loc_respon_action
              from libelle where mnemo='PREVACT'
              and code=to_number(loc_action);
            exception
              --si pas de code_action en base, on ne met rien dans loc_action=null, n'existe pas de code_action par defaut comme pour le motif-- ok Sylvie
              when no_data_found then loc_respon_action :='Aucun responsable paramétré pour action'|| loc_action;
              when too_many_rows then loc_lib_action :='Plusieurs responsables paramétrés pour action'|| loc_action;
              when others then loc_lib_action :='Erreur technique sur la transco du respon. gestion pour action'|| loc_action;

            end;
          ELSE --loc_motif_rej est vide car balise <Rsn><Cd> et <Cd> absence
            loc_msg_erreur :='Motif de rejet SEPA absent du fichier';
            loc_motif_rejet_transco :='99';
          END IF;--loc_motif_rej balise <Rsn><Cd> et <Cd>
          --determination du libelle du motif de rejet
          select libelle
          into loc_lib_motif_rej
          from libelle where mnemo='PREVANN' and code=to_number(loc_motif_rejet_transco);

          --identification du prelevement
          select count(numprelev) , count(numencaismt)
          into loc_nb_prel, loc_nb_encais_affect
          from prelevement
          where numprelev=substr(loc_ref_rp,7);
          --dbms_output.put_line('loc_nb_prel '||loc_nb_prel);
          IF loc_nb_prel=0 THEN
            loc_msg_erreur :='N° de prélèvement inexistant dans Arthus';
            loc_annulation :='Non';
            --ne pas renseigner le motif d'annulation,ni le code action, ni le libelle action, ni le responsable action, ni le numencaismt si prelev non identifié dans le fichier xml ou inexistant dans Arthus
            loc_lib_motif_rej :=null;
            loc_lib_action :=null;
            loc_action :=null;
            loc_respon_action :=null;
            loc_numencais :=null;
          ELSE--prelevement identifié
            --recherche du bordereau de prelevement
            begin
              select numremise into loc_num_bdx_prelev
              from prelevement where numprelev=substr(loc_ref_rp,7);
            exception
              when no_data_found then loc_num_bdx_prelev :=null;
              when others then loc_num_bdx_prelev :=null;
                l_numlig :=l_numlig+1;
                pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_IMPORT_REJ_PREL',
                                    I_session     =>SID,
                                    I_niv_msg     =>1,
                                    I_msg_adm     =>'Echec de la recherche du bdx de prelev pour le rejet '||substr(loc_ref_rp,7)|| substr(sqlerrm,1,30),
                                    I_date        =>sysdate,
                                    I_idligne	    =>l_numlig);
            end;
          --un prelèvement n'est pas affecté lorsque le numencaismt est =null dans la table prelevement
            IF loc_nb_encais_affect =0 THEN -- prelevement non affecté
              loc_msg_erreur :='Prélèvement non affecté';
              loc_annulation :='Non';
              --dbms_output.put_line('rko numprelev '||substr(/*io_tab_rejprel(cpt_TxDtls).reference*/loc_ref_rp,7)||' loc_msg_erreur '||loc_msg_erreur||' annul '||loc_annulation);
            ELSE --prelev affecté
            --recherche de l'encaissement avec la reference de rejet
              begin
                select numencaismt into loc_numencais --nvl ne gere pas l'exception no_data!
                from prelevement where numprelev=substr(loc_ref_rp,7);
              exception
                when others then loc_numencais :=0; --impossible d'avoir no_data_found car loc_nb_encais_affect>0 donc il ya au moins un encaismt
                l_numlig :=l_numlig+1;
                pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_IMPORT_REJ_PREL',
                                I_session     =>SID,
                                I_niv_msg     =>1,
                                I_msg_adm     =>'Echec de la recherche de l''encaissement pour le prelevement '|| loc_ref_rp,
                                I_date        =>sysdate,
                                I_idligne	    =>l_numlig);
              end;

              IF nvl(loc_numencais,0) <>0 THEN --encaismt trouvé
                --vérification que le prelev n'est pas déjà annulé
                --un prélèvement est annulé quand son numencaismt est présent dans la table annul_encais OK ABO
                select count(numencaismt)
                into loc_nb_encais_annul
                from annul_encais
                where numencaismt=loc_numencais;

                IF loc_nb_encais_annul >0 THEN--prelevement a déjà été annulé
                  loc_msg_erreur :='Prélèvement déjà annulé';
                  loc_annulation :='Non';

                ELSE --prelevement non annulé
                --annulation de l'encaissement
                  pk_import_virement.P_ANNUL_encaismt(i_numencais            =>loc_numencais
                                                    , i_motif_annul          =>to_number(loc_motif_rejet_transco)
                                                    , o_erreur               =>loc_erreur
                                                    , i_annul_encaismt_actif =>'O'
                                                    );

                  IF loc_erreur is null then
                    loc_annulation :='Oui';
                    loc_msg_erreur :='';--pas de message si l'annulation s'est bien passée
                    --dbms_output.put_line('rko numprelev '||substr(/*io_tab_rejprel(cpt_TxDtls).reference*/loc_ref_rp,7)||' loc_msg_erreur '||loc_msg_erreur||' annul '||loc_annulation);
                  ELSE
                    loc_annulation :='Non';
                    loc_msg_erreur :='Annulation impossible'||substr(loc_erreur,1,20);
                  END IF;--loc_erreur
                END IF;--loc_nb_encais_annul

              END IF;--nvl(loc_numencais,0) <>0
            END IF;--recherche affectation
          END IF;--prelev identifié
        END IF;--loc_ref_rp is null (balise EndToEndId absente dans le fichier xml)
        IF loc_ref_rp is null or loc_nb_prel=0 THEN
          --les infos prelev(motif de paiement) et le debiteur sont renseignés quand la reference de prelev est introuvable ou le prelev inexistant dans Arthus
          loc_motif_pay_brut:= pk_xml.extract_data2(loc_TxDtls,'//Ustrd',loc_namespace);
          --dbms_output.put_line('loc_motif_pay_brut '|| loc_motif_pay_brut); --GEREP COTISATIONS TRIMESTRE 1
          --encodage du motif de paiement en windows 1252 sur les caracères spec.
          loc_motif_pay :=CONVERT(loc_motif_pay_brut,'we8mswin1252','utf8');
          --dbms_output.put_line('loc_motif_pay '|| loc_motif_pay);

          loc_debiteur:= pk_xml.extract_data2(loc_TxDtls,'//Dbtr/Nm',loc_namespace);
          --encodage du nom du debiteur en windows 1252 sur les caracères spec.
          loc_nom_debit :=CONVERT(loc_debiteur,'we8mswin1252','utf8');
          --dbms_output.put_line('loc_nom_debit '||loc_nom_debit ); --STE DURA-LINE
        ELSE
          loc_motif_pay :='';
          loc_nom_debit :='';
        END IF;
        --suite retour SYLVIE, près prelev identif/ou non identif
        --alimentation du tableau de sortie
        flag_fact :=0;
        for rec_fact in c_factures(loc_ref_rp) loop
          flag_fact :=flag_fact+1; --au moins une facture presente sur la reference loc_ref_rp
          io_tab_rejprel(cpt).dat_crea      :=    loc_dat_crea;
          io_tab_rejprel(cpt).motif_rej     :=    loc_motif_rej;
          io_tab_rejprel(cpt).reference     :=    loc_ref_rp;
          io_tab_rejprel(cpt).bdx_prelev    :=    loc_num_bdx_prelev;
          io_tab_rejprel(cpt).motif_pay     :=    loc_motif_pay;--=infos prelevement
          io_tab_rejprel(cpt).nom_debit     :=    loc_nom_debit;
          io_tab_rejprel(cpt).code_devise   :=    loc_code_devise;
          io_tab_rejprel(cpt).type_rej      :=    loc_type_rej;
          --io_tab_rejprel(cpt).montant_rej   :=    loc_montant_rej;
          io_tab_rejprel(cpt).numfact         :=    rec_fact.numfact;
          dbms_output.put_line('flag_fact '||flag_fact );
          if flag_fact=1 then --afficher une seule fois le montant du rejet si plusieurs factures pour le meme rejet (attention ne pas utiliser cpt car c compteur des lignes du fichier csv et non celui des factures)
            io_tab_rejprel(cpt).montant_rej :=    loc_montant_rej;
            dbms_output.put_line('flag_fact '||flag_fact||' numfact '||io_tab_rejprel(cpt).numfact||' montant_rej '||io_tab_rejprel(cpt).montant_rej );
          else
            io_tab_rejprel(cpt).montant_rej :=null;
            dbms_output.put_line('flag_fact '||flag_fact||' numfact '||io_tab_rejprel(cpt).numfact||' montant_rej '||io_tab_rejprel(cpt).montant_rej );
          end if;

          io_tab_rejprel(cpt).mt_facture      :=    rec_fact.montant;
          io_tab_rejprel(cpt).date_eche_fact  :=  rec_fact.echeance;
          io_tab_rejprel(cpt).num_querable    :=  rec_fact.num_querable;
          io_tab_rejprel(cpt).nom_querable    :=  rec_fact.nom_querable;
          io_tab_rejprel(cpt).Numadhesion     :=  rec_fact.idadhesion;
          io_tab_rejprel(cpt).Numgar          :=    rec_fact.numgar;
          io_tab_rejprel(cpt).Numencais       :=    loc_numencais;
          io_tab_rejprel(cpt).lib_motif_rej   :=    loc_lib_motif_rej;
          io_tab_rejprel(cpt).code_action     :=    loc_action;
          io_tab_rejprel(cpt).lib_code_action :=  loc_lib_action;
          io_tab_rejprel(cpt).respon_action   :=  loc_respon_action;
          io_tab_rejprel(cpt).annulation      :=  loc_annulation;
          io_tab_rejprel(cpt).msg_erreur      :=  loc_msg_erreur;
          io_tab_rejprel(cpt).nom_fich        :=  i_fic_rep;

          cpt := cpt + 1;
        end loop;

        IF flag_fact =0 THEN
          io_tab_rejprel(cpt).dat_crea        :=   loc_dat_crea;
          io_tab_rejprel(cpt).motif_rej       :=   loc_motif_rej;
          io_tab_rejprel(cpt).reference       :=   loc_ref_rp;
          io_tab_rejprel(cpt).bdx_prelev      :=   loc_num_bdx_prelev;
          io_tab_rejprel(cpt).motif_pay       :=   loc_motif_pay; --=infos prelevement
          io_tab_rejprel(cpt).nom_debit       :=   loc_nom_debit;
          io_tab_rejprel(cpt).code_devise     :=   loc_code_devise;
          io_tab_rejprel(cpt).type_rej        :=   loc_type_rej;
          io_tab_rejprel(cpt).montant_rej     :=   loc_montant_rej;
          io_tab_rejprel(cpt).numfact         :=   null;
          io_tab_rejprel(cpt).mt_facture      :=   null;
          io_tab_rejprel(cpt).date_eche_fact  :=  null;
          io_tab_rejprel(cpt).num_querable    :=  null;
          io_tab_rejprel(cpt).nom_querable    :=  null;
          io_tab_rejprel(cpt).Numadhesion     :=  null;
          io_tab_rejprel(cpt).Numgar          :=  null;
          io_tab_rejprel(cpt).Numencais       :=  loc_numencais;
          io_tab_rejprel(cpt).lib_motif_rej   :=  loc_lib_motif_rej;
          io_tab_rejprel(cpt).code_action     :=  loc_action;
          io_tab_rejprel(cpt).lib_code_action := loc_lib_action;
          io_tab_rejprel(cpt).respon_action   := loc_respon_action;
          io_tab_rejprel(cpt).annulation      := loc_annulation;
          io_tab_rejprel(cpt).msg_erreur      := loc_msg_erreur;
          io_tab_rejprel(cpt).nom_fich        := i_fic_rep;

          cpt := cpt + 1;
        END IF;
        cpt_TxDtls := cpt_TxDtls + 1;
      END LOOP; --TxDtls
      cpt_Ntry := cpt_Ntry + 1;
    END LOOP;--Ntry
    cpt_Ntfctn := cpt_Ntfctn + 1;
  END LOOP;--Ntfctn
  --dbms_output.put_line('Fin traitement P_IMPORT_REJ_PREL' );
  o_erreur :=1;
  l_numlig :=l_numlig+1;
  pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_IMPORT_REJ_PREL',
                            I_session     =>SID,
                            I_niv_msg     =>1,
                            I_msg_adm     =>'fin de traitement '|| TO_CHAR(Sysdate, 'hh24:mi'),
                            I_date        =>sysdate,
                            I_idligne	    =>l_numlig);
EXCEPTION
  WHEN OTHERS THEN
  --dbms_output.put_line('Fin KO P_IMPORT_REJ_PREL' );
  o_erreur :=-1;
  l_numlig :=l_numlig+1;
  pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_IMPORT_REJ_PREL',
                              I_session     =>SID,
                              I_niv_msg     =>1,
                              I_msg_adm     =>'Erreur de génération du fichier csv pour le rejet :',
                              I_date        =>sysdate,
                              I_idligne	    =>l_numlig);

END P_IMPORT_REJ_PREL;

/*===========================================================================*/
/* Procedure    : P_GEN_FIC_REJ_PREL.sql                                     */
/* Domaine      : Prélèvement                                                */
/* Auteur       : ARTHUS                                                     */
/* Création     : 18/11/2021                                                 */
/* Description  : ....          */
/*===========================================================================*/
/* Entreé    :                                                               */
/* Sortie    :                                                               */
/*===========================================================================*/

PROCEDURE P_GEN_FIC_REJ_PREL(io_tab_rejprel IN tab_rej_prel,i_fichier_export IN VARCHAR2 ,i_repertoire IN VARCHAR2, io_entete IN OUT NUMBER) IS
  l_numlig    NUMBER :=0;
  loc_repertoire  VARCHAR2(10);
  loc_fichier     UTL_FILE.FILE_TYPE;
  loc_entete     VARCHAR2(500);
  loc_contenu    VARCHAR2(1000);
  i              number :=0;

BEGIN
  l_numlig :=l_numlig+1;
  pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_GEN_FIC_REJ_PREL',
                            I_session     =>SID,
                            I_niv_msg     =>1,
                            I_msg_adm     =>'debut de traitement '|| TO_CHAR(Sysdate, 'hh24:mi'),
                            I_date        =>sysdate,
                            I_idligne	    =>l_numlig);
  loc_fichier :=UTL_FILE.FOPEN(i_repertoire, i_fichier_export, 'A');
  --une seule entete est crééé pour l'ensemble des fichiers traités--> un fichier csv/lancement d'import donc une entete/lancement d'import
  IF io_entete IS NULL THEN
    loc_entete :='Nom du fichier;Périmètre;Date du rejet;Code rejet SEPA;Montant du rejet;Devise;N°facture;Date échéance facture;Montant Facture;N°quérable;Nom quérable;N°adhésion;N°Contrat;N°Encaissement;Motif annulation Arthus;Code action;Libellé code action;Responsable action;Annulation;Message;N°prélèvement;N°Bordereau de prélèvement;Infos prélèvement;Nom débiteur'|| CHR(10);
    UTL_FILE.PUT(loc_fichier, loc_entete);
    io_entete :=1;
  END IF;
  i:=1;

  FOR k IN 1 .. io_tab_rejprel.COUNT LOOP

    loc_contenu := io_tab_rejprel(i).nom_fich||';'||
                  io_tab_rejprel(i).type_rej||';'||
                  io_tab_rejprel(i).dat_crea||';'||
                  io_tab_rejprel(i).motif_rej||';'||
                  --remplacer le . par , dans les montants
                  replace(io_tab_rejprel(i).montant_rej,'.',',')||';'||
                  io_tab_rejprel(i).code_devise||';'||
                  io_tab_rejprel(i).numfact||';'||
                  to_char(io_tab_rejprel(i).date_eche_fact,'DD/MM/YYYY')||';'||
                  replace(io_tab_rejprel(i).mt_facture,'.',',')||';'||
                  io_tab_rejprel(i).num_querable||';'||
                  io_tab_rejprel(i).nom_querable||';'||
                  io_tab_rejprel(i).Numadhesion||';'||
                  to_char(io_tab_rejprel(i).Numgar)||';'||
                  to_char(io_tab_rejprel(i).Numencais)||';'||
                  io_tab_rejprel(i).lib_motif_rej||';'||
                  io_tab_rejprel(i).code_action||';'||
                  io_tab_rejprel(i).lib_code_action||';'||
                  io_tab_rejprel(i).respon_action||';'||
                  io_tab_rejprel(i).annulation||';'||
                  io_tab_rejprel(i).msg_erreur||';'||
                  io_tab_rejprel(i).reference||';'||
                  io_tab_rejprel(i).bdx_prelev||';'||
                  io_tab_rejprel(i).motif_pay ||';'||--=infos prelev
                  io_tab_rejprel(i).nom_debit
                  ;
    UTL_FILE.PUT_LINE(loc_fichier, loc_contenu);
    i :=i+1;
  END LOOP;
  UTL_FILE.FCLOSE(loc_fichier);

  l_numlig :=l_numlig+1;
  pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_GEN_FIC_REJ_PREL',
                            I_session     =>SID,
                            I_niv_msg     =>1,
                            I_msg_adm     =>'Fichier généré :'||i_fichier_export,
                            I_date        =>sysdate,
                            I_idligne	    =>l_numlig);
END P_GEN_FIC_REJ_PREL;

/*===========================================================================*/
/* Procedure    : P_INS_AUTO_FLUX_COMMIT.sql                                 */
/* Domaine      : Prélèvement                                                */
/* Auteur       : ARTHUS                                                     */
/* Création     : 18/11/2021                                                 */
/* Description  : enregistrement dans la table auto_flux                     */
/*              avec commit via la commande PRAGMA AUTONOMOUS_TRANSACTION)   */
/*===========================================================================*/
/* Entreé    : date du traitement,nom du traitement, session, nom du fichier, */
 /*              statut, message, etat de l'envoi du mail                    */
/* Sortie    :                                                               */
/*===========================================================================*/
PROCEDURE P_INS_AUTO_FLUX_COMMIT (
                               I_DAT       IN DATE,
                               I_NOM       IN VARCHAR2,
                               I_SESSION    IN NUMBER,
                               I_FICHIER       IN VARCHAR2,
                               I_STAT   IN VARCHAR2,
                               I_MSG      IN VARCHAR2,
                               I_MAIL_ENVOI   IN NUMBER Default 0
                )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

PK_AUTO_FLUX.P_INS_AUTO_FLUX (
                               I_DATTRT       =>I_DAT,
                               I_NOMTRT       =>I_NOM,
                               I_IDSESSION    =>I_SESSION,
                               I_NOMFIC       =>I_FICHIER,
                               I_STATUT       =>I_STAT,
                               I_MESSAGE      =>I_MSG,
                               I_ENVOI_MAIL   =>I_MAIL_ENVOI
                              );
 COMMIT;

END P_INS_AUTO_FLUX_COMMIT;

/*===========================================================================*/
/* Procedure    : P_ENVOI_MAIL_REJ_PREL.sql                                 */
/* Domaine      : Prélèvement                                                */
/* Auteur       : ARTHUS                                                     */
/* Création     : 18/11/2021                                                 */
/* Description  : envoi de rapport mail du traitement d'import des           */
/*              rejets de prelevement                                        */
/*===========================================================================*/
/* Entreé    : nom du traitement                                             */
/* Sortie    :                                                               */
/*===========================================================================*/
PROCEDURE P_ENVOI_MAIL_REJ_PREL (I_traitement in varchar2)
IS
loc_envoi      envoi_mail%ROWTYPE;
l_ERROR        VARCHAR2(200);
text           CLOB;
l_nom_machine  param_machine.nom_machine%type;
l_destinataire varchar2(60);

l_destinataire1 varchar2(60);
l_destinataire2 varchar2(60);
l_destinataire3 varchar2(60);
l_destinataire4 varchar2(60);
l_destinataire5 varchar2(60);
l_destinataire6 varchar2(60);
l_destinataire7 varchar2(60);
l_numlig       number :=0;
l_msg          journal_adm.msg_adm%TYPE;

CURSOR c_mails IS

  Select distinct message
  from auto_flux
  where nomtrt = I_traitement
  and envoi_mail = 0
  ;
l_found BOOLEAN;
BEGIN
    l_numlig :=l_numlig+1;
    l_msg :='Debut envoi mail'|| TO_CHAR(Sysdate, 'hh24:mi');
    pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_ENVOI_MAIL_REJ_PREL',
                              I_session     =>SID,
                              I_niv_msg     =>1,
                              I_msg_adm     =>l_msg,
                              I_date        =>sysdate,
                              I_idligne	    =>l_numlig);

    SELECT 1, 1, compte_mail
    INTO loc_envoi.NUMINDIV_DEST, loc_envoi.NUMBENE, loc_envoi.destinataire
    FROM param_machine
    WHERE id_machine= 'SERVEUR_MAIL';

    SELECT instance into l_nom_machine
    FROM parametres;
  --destinataires principaux
  l_destinataire1 := '<a.teixeira@gerep.fr>';
  l_destinataire2 := '<f.hardion@gerep.fr>';
  l_destinataire3 := '<l.koeltz@gerep.fr>';
  --destinataires en copie
  l_destinataire4 := '<cotisation@gerep.fr>';
  l_destinataire5 := '<p.veys@gerep.fr>';
  l_destinataire6:= '<m.bougard@gerep.fr>';
  l_destinataire7 := '<c.vayres@gerep.fr>';

  loc_envoi.sujet :='[Rapport_ARTHUS] Rejets de prelevement du '||sysdate ||' sur l''instance '||l_nom_machine;
  loc_envoi.corps := ' ' ;
  begin
      l_found := FALSE;
      FOR rec_mails IN c_mails
         LOOP
            l_found := TRUE;
            loc_envoi.corps :=  loc_envoi.corps ||'-- '||rec_mails.message||CHR(10)||CHR(13) ;
         END LOOP;
  end;

  IF NOT l_found THEN
  --ne pas envoyer de mail s'il n'ya pas de contenu
    null;
  ELSE
    pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_ENVOI_MAIL_REJ_PREL',
                            I_session     =>SID,
                            I_niv_msg     =>1,
                            I_msg_adm     =>'avant appel de transcode_template',
                            I_date        =>sysdate,
                            I_idligne	    =>l_numlig);

    GET_HTML_VARCHAR_FROM_FS('MAILS_IN', 'template_mail_rapport.html', text);
    PK_MAIL.transcode_template( template_mail=>text,
                                corps_msg =>loc_envoi.corps,
                                numindiv=>'',
                                numbene=>'',
                                sujet_msg =>loc_envoi.sujet);

    pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_ENVOI_MAIL_REJ_PREL',
                            I_session     =>SID,
                            I_niv_msg     =>1,
                            I_msg_adm     =>'avant appel de SEND_EMAIL',
                            I_date        =>sysdate,
                            I_idligne	    =>l_numlig);

    pk_mail.SEND_EMAIL(
      P_RECIPIENT     => l_destinataire1||', '||l_destinataire2||', '||l_destinataire3,
      P_CC            => l_destinataire4||', '||l_destinataire5||', '||l_destinataire6||', '||l_destinataire7,
      P_BCC           => null,
      P_SUBJECT       => '[Rapport_ARTHUS] Rejets de prelevement du '|| sysdate||' sur '||l_nom_machine,
      P_BODY          =>text,
      P_NUMUTIL       =>8,
      P_SENDER        => 'no-reply@gerep.fr',
      P_numindiv_dest=> null,
      P_ERROR        => l_ERROR);


      l_numlig :=l_numlig+1;
      l_msg :='l_ERROR'||l_ERROR;
      pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_ENVOI_MAIL_REJ_PREL',
                            I_session     =>SID,
                            I_niv_msg     =>1,
                            I_msg_adm     =>l_msg,
                            I_date        =>sysdate,
                            I_idligne	    =>l_numlig);

    if l_ERROR is null then
      update auto_flux set envoi_mail = 1
      where nomtrt = I_traitement
      and envoi_mail = 0;
      commit;
    else
      l_numlig :=l_numlig+1;
      l_msg :='Erreur d''envoi mail'||substr(sqlerrm(sqlcode),1,110);
      pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_ENVOI_MAIL_REJ_PREL',
                            I_session     =>SID,
                            I_niv_msg     =>1,
                            I_msg_adm     =>l_msg,
                            I_date        =>sysdate,
                            I_idligne	    =>l_numlig);
    end if;
  END IF; --l_found

EXCEPTION
WHEN OTHERS THEN
  l_numlig :=l_numlig+1;
  l_msg :='Echec envoi mail'||substr(sqlerrm(sqlcode),1,20);
  pk_trace.P_INS_journal_adm( I_nom_traitement =>'P_ENVOI_MAIL_REJ_PREL',
                              I_session     =>SID,
                              I_niv_msg     =>1,
                              I_msg_adm     =>l_msg,
                              I_date        =>sysdate,
                              I_idligne	    =>l_numlig);


END P_ENVOI_MAIL_REJ_PREL;

END;
/
