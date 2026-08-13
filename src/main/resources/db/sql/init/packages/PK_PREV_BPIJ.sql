CREATE OR REPLACE package ARTHUS.PK_PREV_BPIJ as

PROCEDURE P_IMPORT_BPIJ(i_traitement varchar2, io_journal IN OUT journal_adm%ROWTYPE, o_erreur out number) ;
PROCEDURE P_LANCER_BPIJ(i_fichier IN XMLTYPE, i_num_remise IN NUMBER, i_nom_fichier IN VARCHAR2, io_journal journal_adm%rowtype);

PROCEDURE P_INS_ASSU_PRESTIJ    (i_assprestij IN OUT assu_prestij%ROWTYPE, i_numsinext IN prest_ij.numsinext%TYPE, io_journal journal_adm%rowtype);
PROCEDURE P_INS_DECLA_PRESTIJ   (infos  decla_prestij%rowtype   );
PROCEDURE P_INS_PREST_IJ        (infos  prest_ij%rowtype        );
PROCEDURE P_INS_REMISE_PRESTIJ  (infos  remise_prestij%rowtype  );

FUNCTION F_NEXT_ID_ASSU_PRESTIJ   return number;
FUNCTION F_NEXT_ID_DECLA_PRESTIJ  return number;
FUNCTION F_NEXT_ID_PREST_IJ       return number;
FUNCTION F_NEXT_ID_REMISE_PRESTIJ return number;

-- Fonction d'analyse du fichier xml a importer
FUNCTION F_NB_DECLARE (i_fichier IN XMLTYPE) RETURN XMLTYPE;
FUNCTION F_NB_CAISSE  (i_fichier IN XMLTYPE, i_current_Declare IN NUMBER) RETURN XMLTYPE;
FUNCTION F_NB_ASSURE  (i_fichier IN XMLTYPE, i_current_Declare IN NUMBER, i_current_Caisse IN NUMBER) RETURN XMLTYPE;
FUNCTION F_NB_ASSURANCE (i_fichier IN XMLTYPE, i_current_Declare IN NUMBER, i_current_Caisse IN NUMBER, i_current_Assure IN NUMBER) RETURN XMLTYPE;
FUNCTION F_NB_PRESTATION(i_fichier IN XMLTYPE, i_current_Declare IN NUMBER, i_current_Caisse IN NUMBER, i_current_Assure IN NUMBER, i_current_Assurance IN NUMBER) RETURN XMLTYPE;

--------------------------------------------------------------------------------
----------------------------Identification des entites--------------------------
--------------------------------------------------------------------------------
PROCEDURE P_IDENTIFICATION_ENTITES  (i_numremise remise_prestij.numremise%type);
PROCEDURE P_IDENTIFIE_SOCIETE_DECLA (i_iddecla DECLA_PRESTIJ.iddeclaration%type);
PROCEDURE P_IDENTIFIE_INDIVIDU      (i_idassu_prestij assu_prestij.idassu_prestij%type, o_erreur out number);
PROCEDURE P_RATTACHE_SINISTRE_EXIST (i_numremise remise_prestij.numremise%type);
PROCEDURE P_RATTACHE_SNTR_EXIST     (i_idassu number, i_nosin  number, o_erreur out number);
PROCEDURE P_INTEGRE_DECLA( i_idassu ASSU_PRESTIJ.Idassu_prestij%type , o_erreur  out number);
-- rattachement de bpij a des rappel et a des sinistre
PROCEDURE P_CREER_RAPPELS           (i_numremise remise_prestij.numremise%type);
PROCEDURE IMPORT_PERIODES_SINITRES  (i_idassu_prestij number, o_nbintegre OUT NUMBER, o_status OUT NUMBER);
FUNCTION  F_VALIDE_RAPPEL(i_idrappel number, i_numporte number) return number;
PROCEDURE P_ANNUL_IMPORT(i_numremise number, i_journal journal_adm%rowtype, o_erreur IN OUT number);
--UTILS
PROCEDURE P_INS_journal(
        P_niv  IN NUMBER,
        p_journal IN OUT JOURNAL_ADM%ROWTYPE,
        P_msg  IN VARCHAR2,
        p_msg2 IN VARCHAR2 default NULL);
PROCEDURE P_SEND_RAPPORT ;
FUNCTION  F_NEXT_ARRET RETURN number;
FUNCTION  F_CODE2TYPE(i_code_prest varchar2) return number;
FUNCTION  F_CODE_CAUSE_ARRET(i_code varchar2) return number;
FUNCTION  IS_ALREADY_DONE(i_filename varchar2) return number ;
FUNCTION  F_DOUBLONS_BPIJ (i_numindiv in number, i_date_debut in date, i_fin IN DATE)  return number;
FUNCTION  F_GET_JOURNAL(i_traitement varchar2) RETURN journal_adm%rowtype;
PROCEDURE SET_RAPPEL_ERREUR( i_idrappel IN RAPPEL.idrappel%TYPE, i_code_err  IN RAPPEL.code_err%TYPE, i_etat IN RAPPEL.etat%TYPE);
PROCEDURE P_INS_HISTO_RAPPEL(i_idrappel number, i_commentaire varchar2, i_codeerr number);
END PK_PREV_BPIJ;

package  BODY      PK_PREV_BPIJ as
--global de log
g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE  DEFAULT 'PJT2T';
g_msg_adm                   journal_adm.msg_adm%TYPE;   -- ajout du paramêtre en entrée de la procédure
g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
g_niv_msg                   journal_adm.niv_msg%TYPE:= 1; -- ajout du paramêtre en entrée de la procédure
g_max_msg                   journal_adm.niv_msg%TYPE          := 1;
g_idligne                   journal_adm.idligne%TYPE          := 0;
g_erreur                    journal_adm.msg_adm%TYPE;

exc_schema_xml_invalide EXCEPTION;

PROCEDURE P_IMPORT_BPIJ(i_traitement varchar2, io_journal IN OUT journal_adm%ROWTYPE, o_erreur out number) IS
  C_listFiles                     SYS_REFCURSOR;
  loc_file                        varchar2 (200);
  loc_file_repert                 varchar2 (200);
  directory_path                  varchar2 (200);
  f_name                          varchar2(200);
  current_zip_file  BLOB;
  fl pk_as_zip.file_list;
  l_file BLOB;
  loc_fichizebfile BFILE;
  loc_xml_source xmltype;
  loc_numremise number;

  --validation xsd
  --loc_xsd_corps xmltype;
  --loc_test_valide  number;
  loc_repertoire typ_batch.repertoire%TYPE;
  loc_repertoire_done typ_batch.repertoire%TYPE;
  loc_repertoire_histo typ_batch.repertoire%TYPE;
  loc_repertoire_err typ_batch.repertoire%TYPE;


--loc_journal journal_adm%rowtype := f_get_journal(i_traitement);


-- on commence  par dézipper les fichier BPIJ
  BEGIN
    o_erreur:=0;
    P_INS_journal(1,io_journal,'- Début du traitement');
    SELECT repertoire INTO loc_repertoire FROM typ_batch where batchid = i_traitement;
    loc_repertoire_done := replace(loc_repertoire,'IN','DONE');
    loc_repertoire_histo := replace(loc_repertoire,'IN','HISTO');
    loc_repertoire_err := replace(loc_repertoire,'IN','ERR');

    SELECT upper(directory_path)
    INTO directory_path
    FROM all_directories
    WHERE directory_name =loc_repertoire ;
    P_INS_journal(1,io_journal,'- Récupération des dossiers ZIP du répertoire '||loc_repertoire );


    sys.PK_EXT_UTILS.ListFiles(directory_path,C_listFiles);

    BEGIN
      LOOP
        FETCH C_listFiles INTO f_name;
        EXIT WHEN C_listFiles%NOTFOUND;
        -- fichier present dans répertoire export
        loc_file_repert := replace(REPLACE(f_name,directory_path),'\') ;    -- '
        IF loc_file_repert NOT LIKE '%xml' THEN -- si on manipule du ZIP
          current_zip_file := PK_AS_ZIP.file2blob(loc_repertoire,replace(f_name,directory_path, ''));
          fl := pk_as_zip.get_file_list (loc_repertoire, loc_file_repert);
          IF fl.COUNT() > 0      THEN -- parcours des fichier XML du zip
            FOR i IN fl.FIRST .. fl.LAST LOOP
              l_file := pk_as_zip.GET_FILE (loc_repertoire, loc_file_repert, fl(i));
              IF fl(i)like '%xml'  AND  fl(i) NOT LIKE '%E-ENTBPIJ%' THEN -- on en prend pas l'entete
               -- creation du fichier a deziper
               P_INS_journal(1,io_journal,'Dézip de '||fl(i));

               DBMS_XSLPROCESSOR.clob2file(   blob_to_clob(l_file)      -- cast du blob en clob (il faudrait vraiment passer en 12.2)
                                     , loc_repertoire
                                     , replace(loc_file_repert,'zip')||'\'||fl(i)    --'
                                    );
               END IF;
            END LOOP;
          END IF;
          -- recopiage du zip pour historise le flux
          pk_as_zip.save_zip
            ( p_zipped_blob =>current_zip_file
            , p_dir =>loc_repertoire_histo
            , p_filename => loc_file_repert
            );
          -- suppression du dossier zip
          Utl_File.Fremove(loc_repertoire,f_name);
          -- p_ins_journal(3,loc_journal,current_zip_file);
        END IF;
      END LOOP ;
    END ;
  CLOSE C_listFiles;
  P_INS_journal(1,io_journal,'- Fin Récupération des dossiers ZIP');

  P_INS_journal(1,io_journal,'- Debut de Traitement des fichiers XML');
  -- Une fois les fichiers déziper on les importe un a un
  sys.PK_EXT_UTILS.ListFiles(directory_path,C_listFiles);

  LOOP FETCH C_listFiles INTO f_name;
    EXIT WHEN C_listFiles%NOTFOUND;
    loc_file_repert := replace(REPLACE(f_name,directory_path),'\') ;    -- '
    loc_fichizebfile:= bfilename(loc_repertoire,loc_file_repert);
    loc_xml_source := new xmltype(loc_fichizebfile, nls_charset_id('UTF-8'));
--     -- Verification de la validité du shema
--    loc_xsd_corps   := loc_xml_source.createSchemaBasedXML('ROOT_BPIJ_V02_00.xsd');
--    loc_test_valide := 1;
--    loc_test_valide := loc_xml_source.isschemavalid('ROOT_BPIJ_V02_00.xsd');
--
--    IF loc_test_valide = 0 THEN
--      BEGIN
--        xmltype.schemaValidate(loc_xsd_corps);
--      EXCEPTION
--        WHEN OTHERS THEN
--          P_INS_journal(1,io_journal,SUBSTR('Fichier '||loc_file_repert ||' non valide: '||sqlerrm,1,132));
--          P_INS_journal(1,io_journal, SUBSTR('Fichier '||loc_file_repert ||' non valide: '||sqlerrm,133,132));
--
--        --RAISE exc_schema_xml_invalide;
--      END;
--    ELSE
      IF is_already_done(loc_file_repert)= 0 THEN
        loc_numremise := f_next_id_remise_prestij;
        P_INS_journal(1,io_journal,'Import de '||loc_file_repert);
        BEGIN
          P_LANCER_BPIJ(i_fichier => loc_xml_source,
                      i_num_remise=> loc_numremise,
                      i_nom_fichier => loc_file_repert,
                      io_journal=> io_journal);
          Utl_File.FCOPY(loc_repertoire,f_name,loc_repertoire_done,f_name);
          Utl_File.Fremove(loc_repertoire,f_name);
          -- puis création des rappels
          p_creer_rappels(loc_numremise);
          -- Lancement de la procédure d'identification des individus et des sinistres en cours
          p_identification_entites(loc_numremise ) ;
          p_rattache_sinistre_exist(loc_numremise) ;
        EXCEPTION
          WHEN OTHERS THEN
          P_INS_journal(1,io_journal,'Le Fichier '||loc_file_repert ||' est en erreur ');
          P_INS_journal(1,io_journal,'ERR : '||SQLERRM);
          Utl_File.FCOPY(loc_repertoire,f_name,loc_repertoire_err,f_name);
          Utl_File.Fremove(loc_repertoire,f_name);
        END;

      ELSE
        P_INS_journal(1,io_journal,'Le Fichier '||loc_file_repert ||' a déjà été importé');
        Utl_File.FCOPY(loc_repertoire,f_name,loc_repertoire_done,f_name);
        Utl_File.Fremove(loc_repertoire,f_name);
      END IF;

--    END IF;
  END LOOP;

  COMMIT;


END P_IMPORT_BPIJ;

PROCEDURE P_LANCER_BPIJ(i_fichier IN XMLTYPE, i_num_remise IN NUMBER, i_nom_fichier IN VARCHAR2, io_journal journal_adm%rowtype) IS
loc_Identifiant         varchar2(50);
loc_parti_xml           XMLTYPE;
nb_balise_Declare       xmltype;
nb_balise_Caisse        xmltype;
nb_balise_Assure        xmltype;
nb_balise_Assurance     xmltype;
nb_balise_Prestation    xmltype;

loc_current_Declare      number(9) := 1;
loc_current_Caisse       number(9) := 1;
loc_current_Assure       number(9) := 1;
loc_current_Assurance    number(9) := 1;
loc_current_Prestation   number(9) := 1;

loc_assu_prestij assu_prestij%rowtype   ;
loc_decla_prestij decla_prestij%rowtype   ;
loc_prest_ij prest_ij%rowtype       ;
loc_remise_prestij remise_prestij%rowtype ;

loc_declare_xml                XMLTYPE;
loc_caisse_xml                XMLTYPE;
loc_assure_xml                XMLTYPE;
loc_assurance_xml                XMLTYPE;
loc_prestation_xml                XMLTYPE;
loc_xmlns                varchar2(50) := 'xmlns:ns2="www.cnamts.fr/tlsemp/IJ"';
loc_journal journal_adm%rowtype := io_journal;
loc_nat_a_integrer           NUMBER := 0 ;
loc_post VARCHAR2(100);
BEGIN
    loc_remise_prestij.numremise  :=i_num_remise;
    loc_remise_prestij.date_import :=SYSDATE;
    loc_remise_prestij.nomfichier :=i_nom_fichier;
    loc_remise_prestij.etat := 0; --importée
    p_ins_remise_prestij(loc_remise_prestij);
    p_ins_journal(3,loc_journal,'La remise à été ajouté');

    nb_balise_Declare := F_NB_DECLARE(i_fichier);
    p_ins_journal(3,loc_journal,'Le nombre de noeud Declare est de : '||nb_balise_Declare.getstringval);
--Boucle pour les declare
WHILE loc_current_Declare <= nb_balise_Declare.getstringval LOOP
        --loc_declare_xml := pk_xml.extract_part(i_fichier, 'BPIJ/Declarant/Declare['||loc_current_Declare||']');
        select EXTRACT(i_fichier,'ns2:BPIJ/ns2:Declarant/ns2:Declare['||loc_current_Declare||']',loc_xmlns)
        into loc_declare_xml from dual;
        --p_ins_journal(3,loc_journal,pk_xml.extract_data22(p_doc_xml=>loc_declare_xml,chemin=> 'ns2:Identite',xmlns=>loc_xmlns));
        loc_decla_prestij.iddeclaration:= f_next_id_decla_prestij; -- NUMBER (9) NOT NULL ,
        loc_decla_prestij.numremise    := loc_remise_prestij.numremise ; -- NUMBER (9) NOT NULL ,
        loc_decla_prestij.idexterne    := to_number(pk_xml.extract_data2(p_doc_xml=>i_fichier,p_bal=> 'ns2:BPIJ/ns2:Identification',p_xmlns => loc_xmlns)); -- NUMBER (15) ,
        loc_decla_prestij.siret        := pk_xml.extract_data2(p_doc_xml=>loc_declare_xml,p_bal=> '*/ns2:Identite',p_xmlns=>loc_xmlns); -- VARCHAR2 (20) ,
        loc_decla_prestij.raisonSociale:= pk_xml.extract_data2(p_doc_xml=>i_fichier,p_bal=> 'ns2:BPIJ/ns2:Declarant/ns2:RaisonSociale',p_xmlns => loc_xmlns); -- VARCHAR2 (100)
        p_ins_decla_prestij(loc_decla_prestij);
        p_ins_journal(3,loc_journal,pk_xml.extract_data2(p_doc_xml=>loc_declare_xml,p_bal=> 'ns2:Identite',p_xmlns=>loc_xmlns));

        --boucle pour les caisses
        loc_current_Caisse := 1;
        nb_balise_Caisse := F_NB_CAISSE(i_fichier, loc_current_Declare);
        p_ins_journal(3,loc_journal,'  Le nombre de noeud Caisse est de : '||nb_balise_Caisse.getclobval());
        WHILE loc_current_Caisse <= nb_balise_Caisse.getstringval LOOP
             select EXTRACT(i_fichier,'ns2:BPIJ/ns2:Declarant/ns2:Declare['||loc_current_Declare||']/ns2:Caisse['||loc_current_Caisse||']',loc_xmlns)
             into loc_caisse_xml from dual;
            --loc_caisse_xml := pk_xml.extract_part(i_fichier, 'ns2:BPIJ/ns2:Declarant/ns2:Declare['||loc_current_Declare||']/ns2:Caisse['||loc_current_Caisse||']');
            --boucle pour les assures
              loc_current_Assure := 1;
              nb_balise_Assure := F_NB_ASSURE(i_fichier, loc_current_Declare, loc_current_Caisse);
              p_ins_journal(3,loc_journal,'    Le nombre de noeud Assure est de : '||nb_balise_Assure.getstringval);
            WHILE loc_current_Assure <= nb_balise_Assure.getstringval LOOP
                --loc_assure_xml := pk_xml.extract_part(i_fichier, 'ns2:BPIJ/ns2:Declarant/ns2:Declare['||loc_current_Declare||']/ns2:Caisse['||loc_current_Caisse||']/ns2:Assure['||loc_current_Assure||']');
                select EXTRACT(i_fichier,'ns2:BPIJ/ns2:Declarant/ns2:Declare['||loc_current_Declare||']/ns2:Caisse['||loc_current_Caisse||']/ns2:Assure['||loc_current_Assure||']',loc_xmlns)
                into loc_assure_xml from dual;

                loc_assu_prestij.Idrappel      := NULL ;--NUMBER (9) ,
                loc_assu_prestij.numindiv      := NULL ;--NUMBER (9) ,
                loc_assu_prestij.nosin         := NULL ;--VARCHAR2 (9) ,
                loc_assu_prestij.code_err      := NULL ;--NUMBER (6) ,
                loc_assu_prestij.Code_CPAM     := pk_xml.extract_data2(p_doc_xml=>loc_caisse_xml,p_bal=> '*/ns2:CodeCPAM',p_xmlns => loc_xmlns) ;--VARCHAR2 (20) ,
                loc_assu_prestij.LIBELLE_CPAM  := pk_xml.extract_data2(p_doc_xml=>loc_caisse_xml,p_bal=> '*/ns2:Caisse/ns2:Libelle',p_xmlns => loc_xmlns)  ;--VARCHAR2 (100) ,
                loc_assu_prestij.NIR           := pk_xml.extract_data2(p_doc_xml=>loc_assure_xml,p_bal=> '*/ns2:NIR',p_xmlns => loc_xmlns)  ;--VARCHAR2 (20) ,
                loc_assu_prestij.nom           := pk_xml.extract_data2(p_doc_xml=>loc_assure_xml,p_bal=> '*/ns2:Nom',p_xmlns => loc_xmlns)  ;--VARCHAR2 (30) ,
                loc_assu_prestij.prenom        := pk_xml.extract_data2(p_doc_xml=>loc_assure_xml,p_bal=> '*/ns2:Prenom',p_xmlns => loc_xmlns) ;--VARCHAR2 (30) ,
                loc_assu_prestij.cumulassure   := to_number(pk_xml.extract_data2(p_doc_xml=>loc_assure_xml,p_bal=> '*/ns2:Cumul/ns2:Montant',p_xmlns => loc_xmlns),'999999999999D99', 'NLS_NUMERIC_CHARACTERS=''. ''') ;--NUMBER (9,2) ,
                --J466 hotfix ABO une prestation peut inclure plusieurs indus => en faire la somme ou revoir le stockage
                --loc_assu_prestij.numindu       := to_number(pk_xml.extract_data2(p_doc_xml=>loc_assure_xml,p_bal=> '*/ns2:Indu/ns2:Numero',p_xmlns => loc_xmlns)) ;--NUMBER (9) ,
                --loc_assu_prestij.montant       := to_number(pk_xml.extract_data2(p_doc_xml=>loc_assure_xml,p_bal=> '*/ns2:Indu/ns2:Montant',p_xmlns => loc_xmlns),'999999999999D99', 'NLS_NUMERIC_CHARACTERS=''. ''') ;--NUMBER (9,2)

                --boucle pour les assurances
                loc_current_Assurance := 1;
                nb_balise_Assurance := F_NB_ASSURANCE(i_fichier, loc_current_Declare, loc_current_Caisse, loc_current_Assure);
                p_ins_journal(3,loc_journal,'      Le nombre de noeud Assurance est de : '||nb_balise_Assurance.getstringval);
                WHILE loc_current_Assurance <= nb_balise_Assurance.getstringval LOOP

                    --loc_assurance_xml := pk_xml.extract_part(i_fichier, 'ns2:BPIJ/ns2:Declarant/ns2:Declare['||loc_current_Declare||']/ns2:Caisse['||loc_current_Caisse||']/ns2:Assure['||loc_current_Assure||']/ns2:Assurance['||loc_current_Assurance||']');
                    select EXTRACT(i_fichier,'ns2:BPIJ/ns2:Declarant/ns2:Declare['||loc_current_Declare||']/ns2:Caisse['||loc_current_Caisse||']/ns2:Assure['||loc_current_Assure||']/ns2:Assurance['||loc_current_Assurance||']',loc_xmlns)
                    into loc_assurance_xml from dual;

                    loc_assu_prestij.iddeclaration   := loc_decla_prestij.iddeclaration ;--NUMBER (9) NOT NULL ,
                    loc_assu_prestij.CodeNatureAssur := pk_xml.extract_data2(p_doc_xml=>loc_assurance_xml,p_bal=> '*/ns2:CodeNature',p_xmlns => loc_xmlns);


                    --boucle sur les prestations
                    loc_current_Prestation := 1;
                    nb_balise_Prestation := F_NB_PRESTATION(i_fichier, loc_current_Declare, loc_current_Caisse, loc_current_Assure, loc_current_Assurance);
                    p_ins_journal(3,loc_journal,'        Le nombre de noeud Prestation est de : '||nb_balise_Prestation.getstringval);
                    WHILE loc_current_Prestation <= nb_balise_Prestation.getstringval LOOP
                        --loc_prestation_xml := pk_xml.extract_part(i_fichier, 'ns2:BPIJ/ns2:Declarant/ns2:Declare['||loc_current_Declare||']/ns2:Caisse['||loc_current_Caisse||']/ns2:Assure['||loc_current_Assure||']/ns2:Assurance['||loc_current_Assurance||']/ns2:Prestation['||loc_current_Prestation||']');
                        select EXTRACT(i_fichier,'ns2:BPIJ/ns2:Declarant/ns2:Declare['||loc_current_Declare||']/ns2:Caisse['||loc_current_Caisse||']/ns2:Assure['||loc_current_Assure||']/ns2:Assurance['||loc_current_Assurance||']/ns2:Prestation['||loc_current_Prestation||']',loc_xmlns)
                        into loc_prestation_xml from dual;
                        -- Recherche si la nature de prest est a intégrer (libellé NAT_PREST)
                        loc_prest_ij.CodeNaturepresta  := pk_xml.extract_data2(p_doc_xml=>loc_prestation_xml,p_bal=> '*/ns2:CodeNature',p_xmlns => loc_xmlns);

                        BEGIN
                          SELECT 1
                          INTO loc_nat_a_integrer
                          FROM LIBELLE
                          WHERE LIBELLE = loc_prest_ij.CodeNaturepresta
                          AND MNEMO = 'NAT_PREST'
                          AND CODE > 0;
                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN loc_nat_a_integrer := 0;
                        END ;

                        IF loc_nat_a_integrer = 1 THEN
                          -- gestion de la création de assu_prestij
                          loc_prest_ij.numsinext         := pk_xml.extract_data2(p_doc_xml=>loc_prestation_xml,p_bal=> '*/ns2:NumSin',p_xmlns => loc_xmlns);
                          --    on créée un enreg assu_prestij par loc_assu_prestij et par loc_prest_ij.numsinext
                          p_ins_assu_prestij(loc_assu_prestij, loc_prest_ij.numsinext, loc_journal);

                          loc_prest_ij.id_prestij        := f_next_id_prest_ij;
                          loc_prest_ij.Idassu_prestij    := loc_assu_prestij.Idassu_prestij;
                          loc_prest_ij.code_err          := NULL;
                          loc_prest_ij.Libelle           := pk_xml.extract_data2(p_doc_xml=>loc_prestation_xml,p_bal=> '*/ns2:Libelle',p_xmlns => loc_xmlns);
                          loc_prest_ij.DateDebPrest      := TRUNC(TO_DATE(pk_xml.extract_data2(p_doc_xml=>loc_prestation_xml,p_bal=> '*/ns2:DateDebPrest',p_xmlns => loc_xmlns),'YYYY-MM-DD hh24:mi'));
                          loc_prest_ij.DateFinPrest      := TRUNC(TO_DATE(pk_xml.extract_data2(p_doc_xml=>loc_prestation_xml,p_bal=> '*/ns2:DateFinPrest',p_xmlns => loc_xmlns),'YYYY-MM-DD hh24:mi'));
                          loc_prest_ij.NbIJ              := to_number(pk_xml.extract_data2(p_doc_xml=>loc_prestation_xml,p_bal=> '*/ns2:NbIJ',p_xmlns => loc_xmlns));
                          loc_prest_ij.IJSub             := pk_xml.extract_data2(p_doc_xml=>loc_prestation_xml,p_bal=> '*/ns2:IJSub',p_xmlns => loc_xmlns);
                          loc_prest_ij.PU                := to_number(pk_xml.extract_data2(p_doc_xml=>loc_prestation_xml,p_bal=> '*/ns2:PU',p_xmlns => loc_xmlns),'999999999999D99', 'NLS_NUMERIC_CHARACTERS=''. ''');
                          loc_prest_ij.montant           := to_number(pk_xml.extract_data2(p_doc_xml=>loc_prestation_xml,p_bal=> '*/ns2:Montant',p_xmlns => loc_xmlns),'999999999999D99', 'NLS_NUMERIC_CHARACTERS=''. ''');

                          p_ins_prest_ij(loc_prest_ij);
                          loc_post:= '[D'||loc_current_Declare||'-C'||loc_current_Caisse||'-A'||loc_current_Assure||'-AS'||loc_current_Assurance||'-P'||loc_current_Prestation||']';
                          p_ins_journal(3,loc_journal,loc_post ||'-' || loc_prest_ij.id_prestij||' - la prestation' || loc_prest_ij.CodeNaturepresta ||
                                         ' du ' || TO_CHAR(loc_prest_ij.DateDebPrest,'DD/MM/YYYY') ||
                                         ' au ' || TO_CHAR(loc_prest_ij.DateFinPrest,'DD/MM/YYYY') ||
                                         ' a été ajoutée');
                        ELSE
                          p_ins_journal(3,loc_journal,loc_post ||'- la prestation' || loc_prest_ij.CodeNaturepresta ||
                                         ' du ' || TO_CHAR(loc_prest_ij.DateDebPrest,'DD/MM/YYYY') ||
                                         ' au ' || TO_CHAR(loc_prest_ij.DateFinPrest,'DD/MM/YYYY') ||
                                         ' n''a pas été ajoutée');
                        END IF ;
                        loc_current_Prestation := loc_current_Prestation +1;
                    END LOOP;
                    loc_current_Assurance := loc_current_Assurance + 1;
                END LOOP;
                loc_current_Assure := loc_current_Assure + 1;
            END LOOP;
            loc_current_Caisse := loc_current_Caisse + 1;
        END LOOP;
        loc_current_Declare := loc_current_Declare + 1;
    END LOOP;
END P_LANCER_BPIJ;

FUNCTION F_NB_DECLARE(i_fichier IN XMLTYPE) RETURN XMLTYPE IS
nb_balise_Declare XMLTYPE;
BEGIN
    select xmlquery('
    declare namespace ns2="www.cnamts.fr/tlsemp/IJ";
    count($doc/ns2:BPIJ/ns2:Declarant/ns2:Declare)'
              passing i_fichier as "doc"
              returning content)
        into nb_balise_Declare from dual;
    RETURN nb_balise_Declare;
END F_NB_DECLARE;

FUNCTION F_NB_CAISSE(i_fichier IN XMLTYPE, i_current_Declare IN NUMBER) RETURN XMLTYPE IS
nb_balise_Caisse XMLTYPE;
BEGIN
    select xmlquery('
    declare namespace ns2="www.cnamts.fr/tlsemp/IJ";
    count($doc/ns2:BPIJ/ns2:Declarant/ns2:Declare[$nbDeclare]/ns2:Caisse)'
              passing i_fichier as "doc", i_current_Declare as "nbDeclare"
              returning content)
              into nb_balise_Caisse from dual;
    RETURN nb_balise_Caisse;
END F_NB_CAISSE;

-- procédure qui annule l'intégration des sinistre si aucun arret n'a été calculé
PROCEDURE P_ANNUL_IMPORT(i_numremise number, i_journal journal_adm%rowtype, o_erreur IN OUT number)IS
  loc_arret_traite number;
BEGIN
    SELECT COUNT(DISTINCT 1)
    INTO loc_arret_traite
    FROM prest_ij p, arret a,assu_prestij ap, decla_prestij d
    WHERE p.IDARRET = a.IDARRET
    AND p.IDASSU_PRESTIJ= ap.IDASSU_PRESTIJ
    AND d.IDDECLARATION = ap.IDDECLARATION
    AND d.NUMREMISE = i_numremise
    and a.TRAITE ='O'
    ;

    IF loc_arret_traite <>0 THEN
     o_erreur :=123415; --TODO générer un code erreur
     return ;
   ELSE -- on annule l'import des periodes
       DELETE arret WHERE idarret IN (SELECT DISTINCT a.idarret FROM  prest_ij p, arret a,assu_prestij ap, decla_prestij d
                                                WHERE p.IDARRET = a.IDARRET
                                                AND p.IDASSU_PRESTIJ= ap.IDASSU_PRESTIJ
                                                AND d.IDDECLARATION = ap.IDDECLARATION
                                                AND d.NUMREMISE = i_numremise
                                                AND a.TRAITE ='N');

      -- il ne faut pas
      UPDATE RAPPEL SET commentaire = 'Annulation de l''import BPIJ le '||d2e(sysdate,'DD/MM/YYYY') ||' par l''utilisateur '|| F_NUMUTIL() ||CHR(10)||CHR(13)||commentaire,
                        etat = 5
                        WHERE idrappel IN (SELECT DISTINCT ap.idrappel FROM  prest_ij p, arret a,assu_prestij ap, decla_prestij d
                                                WHERE p.IDARRET = a.IDARRET
                                                AND p.IDASSU_PRESTIJ= ap.IDASSU_PRESTIJ
                                                AND d.IDDECLARATION = ap.IDDECLARATION
                                                AND d.NUMREMISE = i_numremise
                                                AND a.TRAITE ='N');
     UPDATE remise_prestij set etat = 3;-- annulation de la remise prestij

   END IF;
   COMMIT;
END P_ANNUL_IMPORT ;
FUNCTION F_NB_ASSURE(i_fichier IN XMLTYPE, i_current_Declare IN NUMBER, i_current_Caisse IN NUMBER) RETURN XMLTYPE IS
nb_balise_Assure XMLTYPE;
BEGIN
select xmlquery('
declare namespace ns2="www.cnamts.fr/tlsemp/IJ";
count($doc/ns2:BPIJ/ns2:Declarant/ns2:Declare[$nbDeclare]/ns2:Caisse[$nbCaisse]/ns2:Assure)'
              passing i_fichier as "doc", i_current_Declare as "nbDeclare", i_current_Caisse as "nbCaisse"
              returning content)
              into nb_balise_Assure from dual;
RETURN nb_balise_Assure;
END F_NB_ASSURE;


FUNCTION F_NB_ASSURANCE(i_fichier IN XMLTYPE, i_current_Declare IN NUMBER, i_current_Caisse IN NUMBER, i_current_Assure IN NUMBER) RETURN XMLTYPE IS
nb_balise_Assurance XMLTYPE;
BEGIN
    select xmlquery('
    declare namespace ns2="www.cnamts.fr/tlsemp/IJ";
    count($doc/ns2:BPIJ/ns2:Declarant/ns2:Declare[$nbDeclare]/ns2:Caisse[$nbCaisse]/ns2:Assure[$nbAssure]/ns2:Assurance)'
                      passing i_fichier as "doc", i_current_Declare as "nbDeclare", i_current_Caisse as "nbCaisse", i_current_Assure as "nbAssure"
                      returning content)
                      into nb_balise_Assurance from dual;
    RETURN nb_balise_Assurance;
END F_NB_ASSURANCE;


FUNCTION F_NB_PRESTATION(i_fichier IN XMLTYPE, i_current_Declare IN NUMBER, i_current_Caisse IN NUMBER, i_current_Assure IN NUMBER, i_current_Assurance IN NUMBER) RETURN XMLTYPE IS
nb_balise_Prestation XMLTYPE;
BEGIN
    select xmlquery('
    declare namespace ns2="www.cnamts.fr/tlsemp/IJ";
    count($doc/ns2:BPIJ/ns2:Declarant/ns2:Declare[$nbDeclare]/ns2:Caisse[$nbCaisse]/ns2:Assure[$nbAssure]/ns2:Assurance[$nbAssurance]/ns2:Prestation)'
                          passing i_fichier as "doc", i_current_Declare as "nbDeclare", i_current_Caisse as "nbCaisse", i_current_Assure as "nbAssure", i_current_Assurance as "nbAssurance"
                          returning content)
                          into nb_balise_Prestation from dual;
    RETURN nb_balise_Prestation;
END F_NB_PRESTATION;


/*********** Fonction et procédure utiles *************/
PROCEDURE P_INS_ASSU_PRESTIJ(i_assprestij IN OUT assu_prestij%ROWTYPE ,
                            i_numsinext IN prest_ij.numsinext%TYPE    ,
                            io_journal journal_adm%rowtype ) IS
loc_idassu assu_prestij.idassu_prestij%TYPE ;
loc_journal journal_adm%rowtype := io_journal;
BEGIN

-- recherche d'un enreg idassu_prestij identique portant le même numsinext
  BEGIN
    SELECT a.idassu_prestij
    INTO loc_idassu
    FROM ASSU_PRESTIJ a
    INNER JOIN PREST_IJ p ON p.idassu_prestij = a.idassu_prestij
    WHERE (  p.NUMSINEXT        = i_numsinext
          OR ( i_numsinext is NULL AND p.NUMSINEXT IS NULL ))
      AND   a.IDDECLARATION  = i_assprestij.IDDECLARATION
      AND  (a.IDRAPPEL       = i_assprestij.IDRAPPEL
        OR (a.IDRAPPEL IS NULL AND i_assprestij.IDRAPPEL IS NULL ))
      AND  (a.NUMINDIV       = i_assprestij.NUMINDIV
        OR (a.NUMINDIV IS NULL AND i_assprestij.NUMINDIV IS NULL ))
      AND  (a.NOSIN          = i_assprestij.NOSIN
        OR (a.NOSIN IS NULL AND i_assprestij.NOSIN IS NULL ))
      AND  (a.CODE_ERR       = i_assprestij.CODE_ERR
        OR (a.CODE_ERR IS NULL AND i_assprestij.CODE_ERR IS NULL ))
      AND  (a.CODE_CPAM      = i_assprestij.CODE_CPAM
        OR (a.CODE_CPAM IS NULL AND i_assprestij.CODE_CPAM IS NULL ))
      AND  (a.LIBELLE_CPAM   = i_assprestij.LIBELLE_CPAM
        OR (a.LIBELLE_CPAM IS NULL AND i_assprestij.LIBELLE_CPAM IS NULL ))
      AND  (a.CODENATUREASSUR = i_assprestij.CODENATUREASSUR
        OR (a.CODENATUREASSUR IS NULL AND i_assprestij.CODENATUREASSUR IS NULL ))
      AND  (a.NIR            = i_assprestij.NIR
        OR (a.NIR IS NULL AND i_assprestij.NIR IS NULL ))
      AND  (a.NOM            = i_assprestij.NOM
        OR (a.NOM IS NULL AND i_assprestij.NOM IS NULL ))
      AND  (a.PRENOM         = i_assprestij.PRENOM
        OR (a.PRENOM IS NULL AND i_assprestij.PRENOM IS NULL ))
      AND  (a.CUMULASSURE    = i_assprestij.CUMULASSURE
        OR (a.CUMULASSURE IS NULL AND i_assprestij.CUMULASSURE IS NULL ))
      AND  (a.NUMINDU        = i_assprestij.NUMINDU
        OR (a.NUMINDU IS NULL AND i_assprestij.NUMINDU IS NULL ))
      AND  (a.MONTANT        = i_assprestij.MONTANT
        OR (a.MONTANT IS NULL AND i_assprestij.MONTANT IS NULL ))
    FETCH FIRST 1 ROWS ONLY;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    loc_idassu := NULL;
  END ;

  IF loc_idassu is NULL THEN
    i_assprestij.idassu_prestij  := f_next_id_assu_prestij ;
    INSERT INTO ASSU_PRESTIJ VALUES i_assprestij ;
    p_ins_journal(3,loc_journal,'    L_Assure '|| i_assprestij.idassu_prestij ||' a été ajouté pour numsinext:' || i_numsinext);
  ELSE
    i_assprestij.idassu_prestij := loc_idassu ;
    p_ins_journal(3,loc_journal,'    L_Assure '|| i_assprestij.idassu_prestij ||' a été trouvé pour numsinext:' || i_numsinext);
  END IF;

END P_INS_ASSU_PRESTIJ;

PROCEDURE P_INS_DECLA_PRESTIJ(infos decla_prestij%rowtype) IS
BEGIN
  insert into decla_prestij values infos;
END P_INS_DECLA_PRESTIJ;

PROCEDURE P_INS_PREST_IJ(infos prest_ij%rowtype)  IS
BEGIN
  insert into prest_ij values infos;
END P_INS_PREST_IJ;

PROCEDURE P_INS_REMISE_PRESTIJ(infos remise_prestij%rowtype)IS
BEGIN
  insert into remise_prestij values infos;
END P_INS_REMISE_PRESTIJ;

/***************** FONCTION select de sequence **************/
FUNCTION F_NEXT_ID_ASSU_PRESTIJ   return number IS
  nextvalue NUMBER;
BEGIN
  SELECT  id_assu_prestij.nextval
  INTO nextvalue
  FROM DUAL;
  RETURN nextvalue;
END F_NEXT_ID_ASSU_PRESTIJ  ;

FUNCTION F_NEXT_ID_DECLA_PRESTIJ   return number IS
  nextvalue NUMBER;
BEGIN
  SELECT  id_decla_prestij.nextval
  INTO nextvalue
  FROM DUAL;
  RETURN nextvalue;
END F_NEXT_ID_DECLA_PRESTIJ  ;

FUNCTION F_NEXT_ID_PREST_IJ  return number
IS
nextvalue NUMBER;
  BEGIN
  SELECT  id_prest_ij.
  NEXTVAL into
  nextvalue FROM DUAL;
  RETURN nextvalue;
END F_NEXT_ID_PREST_IJ;

FUNCTION F_NEXT_ID_REMISE_PRESTIJ return number
IS
nextvalue NUMBER;
BEGIN
  SELECT  id_remise_prestij.nextval
  INTO nextvalue
  FROM DUAL;
  RETURN nextvalue;
END F_NEXT_ID_REMISE_PRESTIJ;

/************* Fin fonction sequence ************/


--------------------------------------------------------------------------------
----------------------------Identification des entites--------------------------
--------------------------------------------------------------------------------
PROCEDURE p_identification_entites(i_numremise remise_prestij.numremise%type)   IS
 CURSOR c_declarations(p_numremise number) IS
 SELECT *
 FROM DECLA_PRESTIJ
 WHERE numremise = p_numremise;

 CURSOR c_assu_prestij(p_id_decla number) IS
 SELECT *
 FROM ASSU_PRESTIJ
 WHERE iddeclaration = p_id_decla;

 loc_numindiv number;
 BEGIN
  FOR  r_declarations in  c_declarations(i_numremise )  LOOP
    PK_PREV_BPIJ.P_IDENTIFIE_SOCIETE_DECLA(r_declarations.iddeclaration);
    FOR  r_assu_prestij in      c_assu_prestij(r_declarations.iddeclaration )  LOOP
      PK_PREV_BPIJ.P_IDENTIFIE_INDIVIDU(r_assu_prestij.idassu_prestij,loc_numindiv);

    END LOOP;
  END LOOP;

  UPDATE remise_prestij
  SET etat = 1  -- taguée en tant que identification effectuée
  WHERE numremise =  i_numremise;
  COMMIT;
END p_identification_entites;
--------------------------------------------------------------------------------
PROCEDURE P_identifie_societe_decla( i_iddecla DECLA_PRESTIJ.iddeclaration%type)
IS
loc_declaratation   DECLA_PRESTIJ%rowtype;
loc_numcli pers_morale.numindiv%type;
BEGIN

  SELECT *
  INTO  loc_declaratation
  FROM   DECLA_PRESTIJ
  WHERE iddeclaration = i_iddecla;
  SELECT numindiv
  INTO  loc_numcli
  FROM pers_morale
  WHERE TRIM(UPPER(siret)) =  TRIM(UPPER(loc_declaratation.siret)) ;

  UPDATE  DECLA_PRESTIJ set numcli = loc_numcli where iddeclaration =i_iddecla ;
     commit;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   UPDATE   DECLA_PRESTIJ set numcli = -1 where iddeclaration =i_iddecla ;
   commit;
WHEN TOO_MANY_ROWS THEN
   UPDATE   DECLA_PRESTIJ set numcli = -2 where iddeclaration =i_iddecla ;
   commit;
END P_identifie_societe_decla;
--------------------------------------------------------------------------------

----------------------identification d'un individu
PROCEDURE P_identifie_individu(i_idassu_prestij assu_prestij.idassu_prestij%type, o_erreur out number)
IS
  loc_assu_prestij   assu_prestij%rowtype;
  loc_numindiv pers_morale.numindiv%type;
BEGIN

  SELECT *
  INTO    loc_assu_prestij
  FROM    assu_prestij
  WHERE   idassu_prestij = i_idassu_prestij;

  SELECT i.numindiv
  INTO  loc_numindiv
  FROM individu i
  WHERE SUBSTR(UPPER(NVL(i.matorg,i.N_INSEE)),1,13) =  TRIM(UPPER(loc_assu_prestij.nir))
  AND EXISTS (SELECT a.numindiv FROM adhesion a WHERE a.numindiv = i.numindiv AND a.typfor = 2  );

  -- mise à jour de la ligne de declaration de l'assuré prestij
  UPDATE  assu_prestij
  SET numindiv = loc_numindiv
  WHERE idassu_prestij =i_idassu_prestij ;

  -- rattachement du rappel si il existe déjà.
  update rappel set numassu = loc_numindiv
  where idrappel =loc_assu_prestij.idrappel;
  o_erreur :=0;
  COMMIT;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   UPDATE   assu_prestij set numindiv = -1 where idassu_prestij =i_idassu_prestij ;
   o_erreur :=2358;
   COMMIT;
WHEN TOO_MANY_ROWS THEN
   UPDATE   assu_prestij set numindiv = -2 where idassu_prestij =i_idassu_prestij ;
   o_erreur :=2358;
   COMMIT;
END P_identifie_individu;

--------------------------------------------------------------------------------
--impact forms pv10b
PROCEDURE IMPORT_PERIODES_SINITRES(i_idassu_prestij number , o_nbintegre OUT NUMBER, o_status OUT NUMBER)
 IS
 loc_rappel rappel%rowtype;
 loc_doubl      NUMBER;
 loc_journal JOURNAL_ADM%ROWTYPE := f_get_journal(null);
 loc_assu_prestij assu_prestij%rowtype;
 loc_flag_creation_arret BOOLEAN ;
 loc_batch param_batch%rowtype ;
 loc_commentaire HISTO_RAPPEL.COMMENTAIRE%TYPE ;

 loc_nb_subro   NUMBER :=0;
 loc_nb_doublon NUMBER :=0;
 loc_nb_neg     NUMBER :=0;
 loc_annee      NUMBER :=0;
 loc_annee_max  NUMBER :=0;
 exc_ligne_inexistante EXCEPTION;

 CURSOR    c_prestations is
 SELECT p.*,
        a.nosin,
        a.numindiv, --RKO 19/06
        a.CODENATUREASSUR
  FROM  ASSU_PRESTIJ a
  INNER JOIN PREST_IJ p ON p.idassu_prestij = a.idassu_prestij
  where
        a.idassu_prestij = i_idassu_prestij
    and a.nosin          IS NOT NULL -- declaration rattachée à un sinistre
    and p.datefinprest   IS NOT NULL
    ORDER BY p.datedebprest   asc,
             p.datefinprest asc
  FOR UPDATE OF idarret ;

  loc_arret  arret%rowtype;
  loc_remise remise_prestij%rowtype;
 BEGIN
  P_INS_journal(1,loc_journal,'debut de traitement import periodes prest IJ n° : '||i_idassu_prestij);
  o_status :=0;

  -- on récupère les informations de la ligne
  BEGIN
    SELECT *
    INTO loc_assu_prestij
    FROM assu_prestij
    WHERE idassu_prestij= i_idassu_prestij;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RAISE exc_ligne_inexistante;
  END;

  -- on récupère le paramètre d'intégration des périodes subrogées
  SELECT *
  INTO loc_batch
  FROM PARAM_BATCH pr
  WHERE pr.numbatch = g_nom_traitement ;

  -- recupération des informations de la remise, notamment pour la date de reception de l'arret
  SELECT DISTINCT  r.*
  INTO loc_remise
  FROM REMISE_PRESTIJ r,
       ASSU_PRESTIJ   a,
       DECLA_PRESTIJ  d
   WHERE a.idassu_prestij = i_idassu_prestij
   AND a.iddeclaration    = d.iddeclaration
   AND r.numremise        = d.numremise;

  o_nbintegre     := 0;
  loc_commentaire := '';
  --Boucle de creation des arrets
  FOR r_prestation in c_prestations LOOP
    BEGIN
      loc_flag_creation_arret := TRUE;
      P_INS_journal(1,loc_journal,'Traitement de la période n° : '||r_prestation.ID_PRESTIJ);
      loc_commentaire := loc_commentaire ||
                         r_prestation.CODENATUREASSUR || ' ' ||
                         r_prestation.CODENATUREPRESTA || ' ' ||
                         NVL(TO_CHAR(r_prestation.DATEDEBPREST,'DD/MM/YYYY'),'          ') || ' ' ||
                         NVL(TO_CHAR(r_prestation.DATEFINPREST,'DD/MM/YYYY'),'          ') || ' ' ||
                         ' Montant:' || r_prestation.MONTANT ;

      -- Si déjà importée
      IF r_prestation.idarret IS NOT NULL THEN
        loc_flag_creation_arret := FALSE;
        P_INS_journal(1,loc_journal,'Déjà intégrée dans ' || r_prestation.idarret || ' id: '||r_prestation.ID_PRESTIJ);
        loc_commentaire := loc_commentaire ||
                           '  Déjà intégrée !' ;
      END IF ;

      -- on signale les non subrogés lorsqu'on les intègre
      IF loc_flag_creation_arret = TRUE AND loc_batch.param1 = 'NSUBRO'  AND r_prestation.ijsub = 'false' THEN
        loc_nb_subro := loc_nb_subro + 1;
        loc_commentaire := loc_commentaire ||
                           '  Arret non subrogé ';
        P_INS_journal(1,loc_journal,'Arret non subrogé  id: '||r_prestation.ID_PRESTIJ);
      END IF ;
      -- on intègre pas les non subrogés
      IF loc_flag_creation_arret = TRUE AND loc_batch.param1 = 'SUBRO'  AND r_prestation.ijsub = 'false' THEN
        loc_flag_creation_arret := FALSE;
        loc_nb_subro            := loc_nb_subro + 1;
        P_INS_journal(1,loc_journal,'Arret non subrogé non intégré  id: '||r_prestation.ID_PRESTIJ);
        loc_commentaire := loc_commentaire ||
                           '  Arret non subrogé !' || CHR(10) ;
      END IF ;

      -- on bloque les montants negatifs
      IF loc_flag_creation_arret = TRUE AND r_prestation.montant < 0 THEN
        loc_flag_creation_arret := FALSE ;
        loc_nb_neg              := loc_nb_neg + 1 ;
        loc_commentaire := loc_commentaire ||
                           '  montant négatif !';
        P_INS_journal(1,loc_journal,'Arret non importé car montant < 0 : '||r_prestation.ID_PRESTIJ);
      END IF ;

      --RKO  19/06/2019
      -- on bloque doublons
      -- todo faire un overlap sur les arrets existants
      loc_doubl :=  F_DOUBLONS_BPIJ(r_prestation.numindiv, r_prestation.datedebprest, r_prestation.datefinprest) ;

      IF loc_flag_creation_arret = TRUE AND loc_doubl > 0 then
        loc_flag_creation_arret := FALSE;
        loc_nb_doublon          := loc_nb_doublon + 1 ;
        loc_commentaire := loc_commentaire ||
                           '  Période en doublon !';
        P_INS_journal(1,loc_journal,'attention saisie de doublons, date déjà existante : '||r_prestation.datedebprest);
      END IF;

      -- si on ne bloque pas la création de l'arret
      IF loc_flag_creation_arret = TRUE THEN
        --  gestion du cas où datedebprest est NULL
        SELECT EXTRACT(YEAR FROM NVL(r_prestation.datedebprest,r_prestation.datefinprest))
        INTO loc_annee FROM DUAL ;

        SELECT EXTRACT(YEAR FROM r_prestation.datefinprest)
        INTO loc_annee_max FROM DUAL ;
        P_INS_journal(1,loc_journal,'boucle sur années de '||loc_annee||' à '||loc_annee_max);
        -- boucle de découpage de périodes aux années civiles
        LOOP
          P_INS_journal(1,loc_journal,'traitement année '||loc_annee);
          loc_arret.IDARRET    := f_next_arret();
          loc_arret.NOSIN      := r_prestation.nosin;
          loc_arret.DEBUT      := GREATEST (r_prestation.datedebprest, TO_DATE(loc_annee || '-01-01', 'YYYY-MM-DD'));
          loc_arret.FIN        := LEAST    (r_prestation.datefinprest, TO_DATE(loc_annee || '-12-31', 'YYYY-MM-DD'));
          loc_arret.TRAITE     := 'N';
          loc_arret.TYPE       := f_code2type(r_prestation.codenaturepresta);
          loc_arret.PERIODE    := 0 ; --0 :Sur arrêts   ;1: Mensuelle ; 3: Trimestrielle
          loc_arret.CREATION   := SYSDATE;
          loc_arret.MAJ        := SYSDATE;
          loc_arret.NUMUTIL    := f_numutil();
          loc_arret.BASE_REGIME:= r_prestation.PU;
          loc_arret.RECEPTION  := loc_remise.date_import;

          BEGIN
            SELECT DISTINCT 'O'
            INTO loc_arret.CONTINU
            FROM arret a, sntr_prev s, dossier_sinistre d
            WHERE (
                (loc_arret.DEBUT-2, loc_arret.FIN) OVERLAPS (a.DEBUT, a.fin)   -- dans un sens
                OR
                (a.DEBUT-2, a.fin) OVERLAPS (loc_arret.DEBUT, loc_arret.FIN)   -- ou dans l'autre
                )
            AND d.numindiv  = r_prestation.numindiv
            AND d.iddossier = s.iddossier
            AND a.nosin     = s.nosin;
          EXCEPTION
            WHEN OTHERS THEN
              loc_arret.CONTINU := 'N';
          END;

          INSERT INTO arret VALUES loc_arret;
          UPDATE PREST_IJ SET idarret = loc_arret.IDARRET
          WHERE CURRENT OF c_prestations;
          -- PBO M0006596: on valorise la table pieces avec la date de création de l'arrêt
          UPDATE PIECES SET   daterecep = loc_arret.CREATION
                        WHERE contexte in (17,15)  -- Bénéficiaire sinistre prévoyance et Sinistre prévoyance
                        AND   entite = loc_arret.NOSIN
                        AND   nopiece = 1          -- première pièce uniquement
                        AND   daterecep is null
                        AND   datannul is null;

          o_nbintegre := o_nbintegre + 1;
          P_INS_journal(1,loc_journal,'Insertion de l''arret correspondant a l''id '||r_prestation.ID_PRESTIJ || ' pour l''année ' ||loc_annee );

          loc_annee := loc_annee + 1 ;
          EXIT WHEN loc_annee > loc_annee_max ;
        -- finBoucle de découpage de périodes aux années civiles
        END LOOP;
        loc_commentaire := loc_commentaire || CHR(10) ||
                           '   => intégré'
                           || CHR(10) ;
      ELSE
        loc_commentaire := loc_commentaire || CHR(10) ||
                           '   => non intégré'
                           || CHR(10) ;
      END IF ;

      EXCEPTION
        WHEN OTHERS THEN
         P_INS_journal(1,loc_journal,'- Problème lors de la création de la periode n° : '||r_prestation.id_prestij);
         P_INS_journal(1,loc_journal,'- Problème: '||sqlerrm);
         o_status := 2357; -- afficher un message si une erreur a été relevée
      END;
    -- finBoucle de creation des arrets
    END LOOP ;

    -- gestion de la sortie :
    --     statut du rappel
    --     message du rappel
    --     o_status
    CASE
      WHEN loc_nb_doublon > 0 AND o_nbintegre = 0 THEN
        SET_RAPPEL_ERREUR( i_idrappel =>loc_assu_prestij.idrappel, i_code_err =>  682, i_etat =>1) ;
        P_INS_HISTO_RAPPEL(i_idrappel =>loc_assu_prestij.idrappel, i_commentaire => loc_commentaire , i_codeerr => NULL);
        o_status := 682 ;

      WHEN loc_nb_doublon > 0 AND o_nbintegre > 0 THEN
        SET_RAPPEL_ERREUR( i_idrappel =>loc_assu_prestij.idrappel, i_code_err =>  682, i_etat =>1) ;
        P_INS_HISTO_RAPPEL(i_idrappel =>loc_assu_prestij.idrappel, i_commentaire => loc_commentaire , i_codeerr => NULL);
        o_status := 682 ;

      WHEN loc_nb_neg > 0 AND o_nbintegre > 0 THEN
        SET_RAPPEL_ERREUR( i_idrappel =>loc_assu_prestij.idrappel, i_code_err => 2373, i_etat =>1) ;
        P_INS_HISTO_RAPPEL(i_idrappel =>loc_assu_prestij.idrappel, i_commentaire => loc_commentaire , i_codeerr => NULL);
        o_status := 2373 ;

      WHEN loc_nb_neg > 0 AND o_nbintegre = 0 THEN
        SET_RAPPEL_ERREUR( i_idrappel =>loc_assu_prestij.idrappel, i_code_err => 2372, i_etat =>1) ;
        P_INS_HISTO_RAPPEL(i_idrappel =>loc_assu_prestij.idrappel, i_commentaire => loc_commentaire , i_codeerr => NULL);
        o_status := 2372;

      WHEN loc_nb_subro > 0 AND o_nbintegre <> loc_nb_subro THEN
        SET_RAPPEL_ERREUR( i_idrappel =>loc_assu_prestij.idrappel, i_code_err => 2367, i_etat =>3);
        P_INS_HISTO_RAPPEL(i_idrappel =>loc_assu_prestij.idrappel, i_commentaire => loc_commentaire , i_codeerr => NULL);
        o_status := 2367 ;

      WHEN loc_nb_subro > 0 AND o_nbintegre = loc_nb_subro THEN
        SET_RAPPEL_ERREUR( i_idrappel =>loc_assu_prestij.idrappel, i_code_err => 2366, i_etat =>3);
        P_INS_HISTO_RAPPEL(i_idrappel =>loc_assu_prestij.idrappel, i_commentaire => loc_commentaire , i_codeerr => NULL);
--        o_status := 2366 ;
        o_status := 0 ; -- PBO M0006599

      -- sortie par défaut
      ELSE
        SET_RAPPEL_ERREUR( i_idrappel =>loc_assu_prestij.idrappel, i_code_err => NULL, i_etat =>3);
        P_INS_HISTO_RAPPEL(i_idrappel =>loc_assu_prestij.idrappel, i_commentaire => loc_commentaire , i_codeerr => NULL);
        o_status := 0;
    END CASE ;

    P_INS_journal(1,loc_journal,'Fin de l''import des arret n° : '||i_idassu_prestij);
    COMMIT;

 EXCEPTION
   WHEN exc_ligne_inexistante THEN
      P_INS_journal(1,loc_journal,'- Problème La demande n° : '||i_idassu_prestij ||' semble inexistante');
      SET_RAPPEL_ERREUR( i_idrappel =>loc_assu_prestij.idrappel ,i_code_err =>219, i_etat =>1)  ;
      o_status:=219; -- afficher un message si une erreur a été relevée
   WHEN OTHERS THEN
      P_INS_journal(1,loc_journal,'- Problème validation demande prestij n° : '||i_idassu_prestij);
      P_INS_journal(1,loc_journal,'- Problème: '||sqlerrm);
 END;


 -----------------------------------------------
 ----- PROCEDURE de rattachement de tout les sinistre d'une remise
 PROCEDURE p_rattache_sinistre_exist(i_numremise remise_prestij.numremise%type) IS
   CURSOR c_assu_prestij IS
   SELECT a.*
  --INTO  loc_numcli
    FROM  DECLA_PRESTIJ D , assu_prestij  a
    WHERE D.numremise = i_numremise
    AND   D.iddeclaration = a.iddeclaration
    AND a.nosin is null
    and numindiv is not null
   ;
   --loc_iddossier dossier_sinistre.iddossier%type;
   loc_erreur number;
BEGIN
  FOR  r_assu_prestij in  c_assu_prestij lOOP
      p_rattache_sntr_exist(i_idassu=> r_assu_prestij.idassu_prestij, i_nosin=> null, o_erreur=> loc_erreur );
  END LOOP;
END;



 -----------
PROCEDURE p_rattache_sntr_exist(i_idassu number, i_nosin  number, o_erreur out number) IS
  loc_merge_ok number :=0;
  loc_assu_prestij assu_prestij%rowtype;
  loc_numsinext PREST_IJ.NUMSINEXT%TYPE;
  loc_nosin varchar(11);
  loc_numdossier number(16);
  loc_journal journal_adm%rowtype := f_get_journal(null);
  loc_responsable number(10);
BEGIN
  -- cas fonctionnels
  -- sinistre existant non clos => on prend le sinistre
  -- dossier existant non clos => on prend le dossier
  -- aucun dossier ni sinistre => création de dossier
  BEGIN
    SELECT *
    INTO  loc_assu_prestij
    FROM  ASSU_PRESTIJ
    WHERE IDASSU_PRESTIJ = i_idassu ;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
  END;

  BEGIN
    SELECT p.NUMSINEXT
    INTO loc_numsinext
    FROM PREST_IJ p
    WHERE P.IDASSU_PRESTIJ = i_idassu
    ORDER BY p.NUMSINEXT DESC
    FETCH FIRST 1 ROWS ONLY;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    loc_numsinext := NULL;
  END;


  IF  loc_assu_prestij.numindiv > 0 THEN
    --on recherche le dernier sinistre en cours sur un dossier ouvert
    WITH
      SINISTRES as
      (SELECT NOSIN, F_ETAT_SNTRT_BY_DATE(nosin, sysdate) etat
        FROM sntr_prev, dossier_sinistre
        WHERE dossier_sinistre.iddossier = sntr_prev.iddossier
        AND dossier_sinistre.numindiv =   loc_assu_prestij.numindiv
        AND sntr_prev.cause IN (
          SELECT to_number(val_int) FROM transco
          WHERE REGEXP_LIKE(loc_assu_prestij.CodeNatureAssur, val_ext )
          AND tiers = 'BPIJ' AND MNEMO ='CAUSE')  -- un sinistre de la même cause que celui recu
        AND nosin = nvl(i_nosin,nosin)
      )
      SELECT max(decode( F_ETAT_SNTRT_BY_DATE(sinistres.nosin, sysdate),1, nosin, null) )
      INTO loc_nosin
      FROM sinistres ;

      /*
      IF loc_nosin IS NOT NULL THEN
        SELECT NVL(numutil,createur)    --M0006543
        INTO loc_responsable
        FROM sntr_prev
        WHERE nosin = loc_nosin;
*/
   -- Remonte le gestionnaire responsable du contrat -- PBO M0006543
  IF loc_nosin IS NOT NULL THEN
   SELECT contrat.numutil
   INTO loc_responsable
    FROM sntr_prev, adhe_cntrt, contrat
      WHERE sntr_prev.nosin = loc_nosin
      AND adhe_cntrt.idadhesion = f_idadhesion_prev(sntr_prev.nosin)
      AND adhe_cntrt.numgar = contrat.numgar
      order by contrat.numutil desc
      FETCH FIRST 1 ROWS ONLY;
        BEGIN
          UPDATE assu_prestij
          SET nosin = loc_nosin
          WHERE assu_prestij.idassu_prestij = loc_assu_prestij.idassu_prestij ;

          UPDATE rappel
          SET entite= loc_nosin,
              responsable  = loc_responsable
           -- positionnement d'un modificateur par defaut pour rendre visible la donnée "responsable" sur liste corbeille
             ,modificateur = NVL(modificateur,loc_responsable)
          WHERE idrappel = loc_assu_prestij.idrappel;

          -- Si le sinistre est identifié et en etat 4 ou 1 alors le remettre en état 3
          UPDATE repartition_bene
          SET etat = 3
          WHERE idrepartition in (
                  select idrepartition
                  from repartition
                  where nosin = loc_nosin
                  and valide='O'
          )
          AND etat in (1,4)
          AND valide='O';

          -- Mise à jour de la refef externe du sinistre si non renseignée
          UPDATE SNTR_PREV
          SET REF_EXT_1 = NVL(REF_EXT_1, loc_numsinext)
          WHERE NOSIN = loc_nosin ;

          -- verification que la liaison est effective
          SELECT distinct 0
          INTO  loc_merge_ok
          FROM  assu_prestij
          WHERE idassu_prestij = i_idassu
          AND  nosin is not null  ;
          o_erreur  :=NULL;

        EXCEPTION
          WHEN OTHERS THEN
            o_erreur :=2359;
            P_INS_journal(1,loc_journal,'- Problème lors du rattachement sinistre idassu: '||i_idassu||' '||SQLERRM);
        END;
      ELSE -- loc_nosin null
        p_ins_journal(3,loc_journal,'- Recherche d''un dossier pour l''assuré '||loc_assu_prestij.numindiv);
        SELECT max(dossier_sinistre.iddossier)
        INTO loc_numdossier
        FROM  dossier_sinistre
        WHERE dossier_sinistre.numindiv =   loc_assu_prestij.numindiv
        AND dossier_sinistre.FIN is null
        AND  dossier_sinistre.cloture is null
        --AND sntr_prev.cause = loc_assu_prestij.CodeNatureAssur -- un sinistre de la même cause que celui recu
        ;
        o_erreur :=2359;
        p_ins_journal(3,loc_journal,'- Dossier trouvé  '||loc_numdossier);
        --si aucun dossier en cours alors on créé le dossier

        IF loc_numdossier IS NULL THEN
          p_ins_journal(3,loc_journal,'- Aucun dossier pour l''assuré '||loc_assu_prestij.numindiv);
          loc_numdossier := f_iddossier(sysdate);
          INSERT INTO DOSSIER_SINISTRE (IDDOSSIER,REF_EXT,NUMINDIV,
                                      ANTERIEUR,DEBUT,NUMUTIL,
                                      FIN,CLOTURE,CREATEUR,
                                      CREATION,MODIFICATEUR,MODIFICATION)
                                      VALUES
                                      (loc_numdossier,'Prestij_Noassu_'||loc_assu_prestij.numindiv, loc_assu_prestij.numindiv  ,
                                      'N',sysdate ,F_numutil,
                                      null ,null ,null ,
                                      sysdate ,f_numutil,null );
        END IF;
        --maj du rappel
        p_ins_journal(3,loc_journal,'- MAJ de la demande '|| loc_assu_prestij.idrappel ||' assuré :'||loc_assu_prestij.numindiv );
        UPDATE rappel
        SET entite= loc_numdossier, code_err = o_erreur
        WHERE numassu = loc_assu_prestij.numindiv
        AND idrappel = loc_assu_prestij.idrappel;
        COMMIT;

      END IF; --loc_nosin non null
  END IF; -- Si le numindiv est null on ne fait rien
END  p_rattache_sntr_exist;
--------------------------------------------------------------------------------
-----------------------------Import dans la corbeille---------------------------
PROCEDURE p_creer_rappels(i_numremise remise_prestij.numremise%type)   IS

CURSOR  c_assu_prestij is
 SELECT a.*
  --INTO  loc_numcli
  FROM  DECLA_PRESTIJ D , assu_prestij  a
  WHERE D.numremise = i_numremise
  AND   D.iddeclaration = a.iddeclaration
  AND   a.idrappel is null ;

  loc_rappel    rappel%ROWTYPE;
  loc_numsinext VARCHAR(50);

BEGIN

    FOR  r_assu_prestij in  c_assu_prestij lOOP
      BEGIN
        SELECT '_refext_' || p.numsinext
        INTO loc_numsinext
        FROM  prest_ij p
        WHERE p.idassu_prestij = r_assu_prestij.idassu_prestij
         and numsinext IS NOT NULL
        FETCH FIRST 1 ROWS ONLY;
      EXCEPTION WHEN NO_DATA_FOUND THEN
         loc_numsinext := NULL;
      END ;


      SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
      loc_rappel.contexte     := 16;
      loc_rappel.type         := 28;
      loc_rappel.reference    := 'Prestij'||i_numremise||'_assu_' ||r_assu_prestij.idassu_prestij||loc_numsinext;
      loc_rappel.creation     := sysdate;
      loc_rappel.createur     := F_numutil;
      loc_rappel.etat         := 1 ;
      loc_rappel.origine      := 28;
      loc_rappel.dateeffet    := sysdate;
      loc_rappel.numassu      := nvl(r_assu_prestij.numindiv,0);

      IF loc_rappel.numassu < 0 THEN
          loc_rappel.numassu :=0;
      END IF;
 -- création du commentaire

         SELECT    substr(commentaire,0,1500)
         INTO  loc_rappel.commentaire
         from
         (select
            'NIR:'      || a.nir ||';'||
            'nom:'      || a.nom ||';'||
            'prenom:'   || a.prenom ||';'||
            chr(10)||
            listagg(
            '-- Acte:'     || CODENATUREASSUR ||' ' ||CODENATUREPRESTA ||' '|| LIBELLE ||';'||
            '['         || d2e(DATEDEBPREST)||'-'|| d2e(DATEFINPREST)||'];'||
            'Nb jours:' || NBIJ ||';'||
            'Subrogé:'  || decode(IJSUB,'true', 'O','N')||';'||
            'PU:'       || PU ||';'||
            'Montant:'  || p.MONTANT ||';'||
            'RefExt:'   || numsinext ||';'
            , chr(10))
            within group (order by ID_PRESTIJ)     commentaire
          FROM PREST_IJ p, assu_prestij a
          WHERE p.idassu_prestij= a.idassu_prestij
          AND a.idassu_prestij = r_assu_prestij.idassu_prestij
          GROUP BY a.IDASSU_PRESTIJ,
                   a.nir ,
                   a.nom ,
                   a.prenom
                   );
      loc_rappel.entite := nvl(r_assu_prestij.nosin,0); -- si pas de nosin alors on met 0 pour pouvoir creer un dossier;

      INSERT INTO rappel VALUES loc_rappel;

      UPDATE  assu_prestij
      SET idrappel = loc_rappel.IDRAPPEL
      WHERE idassu_prestij = r_assu_prestij.idassu_prestij;
  END LOOP;


  commit;
END p_creer_rappels;
--------------------------------------------------------------------------------
PROCEDURE P_SEND_RAPPORT IS
 loc_message  varchar2(3600);
 loc_envoi envoi_mail%rowtype;
 BEGIN
    select LISTAGG(msg_adm, CHR(13))
            WITHIN GROUP (ORDER BY idligne) "Message"

  INTO loc_message
  FROM journal_adm
  WHERE id_session=1
  AND niv_msg =1
  AND TRUNC (DATE_ADM) = TRUNC(sysdate)
  AND nom_traitement =g_nom_traitement;
   --TODO attendre la stabilisation de la mantis 5854 pour mettre en place le multi destinataire

   -- TODO boucler sur tout les bénéficiaires de traitement
    loc_envoi.corps := loc_message;
    loc_envoi.sujet := 'Rapport d''import des BPIJ du '||d2e(sysdate) || 'sur '||F_GET_INSTANCE ;
    loc_envoi.NUMINDIV_DEST:=1;
    loc_envoi.NUMBENE:=1;
    loc_envoi.NUMUTIL:= 250;
    loc_envoi.etendue:= 0;   -- rendre le contexte dynam
    loc_envoi.clef:= 0;        -- changer le contexte
    loc_envoi.IDTEXTE:= null;
    loc_envoi.TYPE_MAIL:=4;   -- Rapport
    loc_envoi.DATE_CREATION:=SYSDATE;
    --loc_envoi.template_mail :=i_template; -- permet de savoir quel template utiliser
    PK_MAIL.CREER_MAIL(loc_envoi);
  END P_SEND_RAPPORT;



--------------------------------------------------------------------------------
FUNCTION F_VALIDE_RAPPEL(i_idrappel number, i_numporte number) return number is
  loc_rappel  rappel%rowtype;
  loc_assu_prestij assu_prestij%rowtype;
  loc_nb NUMBER;
  loc_erreur number :=0;
  loc_journal journal_adm%rowtype := f_get_journal(null);
  result                varchar2(200); -- popur le calcul des prestations
  loc_batch param_batch%rowtype;
BEGIN
    -- récuperation du rappel
    SELECT *
    INTO loc_rappel
    FROM rappel
    where idrappel = i_idrappel;
    -- récupération de la declaration assuré prestij correcpondante
    SELECT *
    INTO  loc_assu_prestij
    FROM  assu_prestij
    WHERE idrappel = i_idrappel;

    P_INTEGRE_DECLA( loc_assu_prestij.IDASSU_PRESTIJ  , loc_erreur);
    IF loc_erreur > 0 THEN RETURN loc_erreur; END IF;

    IMPORT_PERIODES_SINITRES(loc_assu_prestij.IDASSU_PRESTIJ ,loc_nb, loc_erreur);

    IF loc_erreur NOT IN (0,682,2373,2372,2367,2366) THEN RETURN loc_erreur; END IF;

    -- on récupére les information mises a jour suite a l'intégration des périodes d'arret
    IF loc_nb >0 THEN
      SELECT *
      INTO  loc_assu_prestij
      FROM  assu_prestij
      WHERE idrappel = i_idrappel;
      SELECT *
      INTO loc_batch
      FROM param_batch
      WHERE numbatch= 'ME01T';

      IF  NVL(loc_batch.param3,0) = 1 THEN
        result := pv01_proc_risq(SID, loc_batch.param5, 1, loc_assu_prestij.nosin, null, null, null, loc_batch.param1, loc_batch.param2);
      ELSE
        result := pv01_proc(SID, 1, 1, loc_assu_prestij.nosin, null,  loc_batch.param1,loc_batch.param2);
      END IF;

      IF result <> '1' THEN
        RETURN 47;
      END IF;
    END IF;
    COMMIT;
    RETURN loc_erreur;

EXCEPTION WHEN no_data_found THEN
  P_INS_journal(1,loc_journal,'- Problème : La demande n° : '||i_idrappel ||' semble inexistante');
  SET_RAPPEL_ERREUR( i_idrappel =>i_idrappel,i_code_err =>219, i_etat =>1)  ;
  RETURN 219; -- afficher un message si une erreur a été relevée

END F_VALIDE_RAPPEL;

 -----------------------------------------------------------------------------------
PROCEDURE P_INTEGRE_DECLA( i_idassu ASSU_PRESTIJ.Idassu_prestij%type , o_erreur  out number) AS
  loc_assu ASSU_PRESTIJ%rowtype;
  loc_erreur number;
  loc_erreur_global number :=0; -- par defaut ok

  exc_indiv_inconnu exception;
  exc_sntr_not_found exception;

BEGIN

  SELECT *
  INTO loc_assu
  FROM  ASSU_PRESTIJ
  WHERE Idassu_prestij =i_idassu;

  BEGIN
  -- identification de l'assuré
    P_identifie_individu(i_idassu, loc_erreur) ;
    IF loc_erreur > 0 THEN
      RAISE exc_indiv_inconnu;
    END IF;

    -- on cherche le sinistre ouvert pour le rattacher
    p_rattache_sntr_exist(i_idassu, null, loc_erreur ) ;
    IF loc_erreur > 0 THEN
      RAISE exc_sntr_not_found;
    END IF ;

    EXCEPTION
      WHEN exc_indiv_inconnu  THEN
        loc_erreur_global:=2358;
      WHEN exc_sntr_not_found  THEN
        loc_erreur_global:=2359;
  END;
 o_erreur:=loc_erreur_global;
 -- TODO faire un set-etat rappel avec le numero de message
END P_INTEGRE_DECLA;
--------------------------------------------------------------------------------
 -- retourne l'id du prochain arret
FUNCTION f_next_arret RETURN number IS
  loc_idarret number;

BEGIN
  SELECT idarret.nextval INTO loc_idarret from dual;
  RETURN loc_idarret;
END f_next_arret;

-- retourne la codification interne a arthus d'un type d'arret (utiliser Transco pour se rapprocher du standart)
FUNCTION f_code2type(i_code_prest varchar2) RETURN number
IS
BEGIN
-- TODO developper la trancodification des Code de prestation en type d'arret, par defaut on met 0 car cela correspond a des IJ.
  RETURN 0;

END f_code2type;
 -- retourne la codification interne a arthus des causes de sinistre (utiliser Transco pour se rapprocher du standard)
FUNCTION f_code_cause_arret(i_code varchar2) RETURN number IS
  o_retour number;
BEGIN
    SELECT decode ( i_code,  'AS' , 1
                            ,'AT' , 4
                            ,'MA' , 8
                            , 1
                            )
      INTO o_retour
      FROM dual;

   RETURN o_retour;

END f_code_cause_arret;
 -- retourne 0 si le fichier n'a jamais été tratié
 -- 1 si le fichier existe déjà dans le référentiel arthus
 -- 2 si un problème non prévu est survenue => trop de ligne rammner
FUNCTION IS_ALREADY_DONE (i_filename varchar2) RETURN number is
l_count number;
BEGIN
  select  count(1)
  into  l_count
  from    remise_prestij
  where nomfichier = i_filename
  AND etat <>3 ;
  return l_count;
END IS_ALREADY_DONE;

--------------------------------------------------------------------------------
--gestion des doublons sur les arrets
FUNCTION F_DOUBLONS_BPIJ(i_numindiv in number, i_date_debut in date, i_fin IN DATE) RETURN number IS
  loc_nb_doubl number;
BEGIN
  SELECT COUNT(*)
  INTO loc_nb_doubl
  FROM sin_prev sp
     , arret    a
  WHERE a.nosin = sp.nosin
   AND numindiv = i_numindiv
  -- exclusion des periodes annulées
   AND a.traite <> 'A'
   AND (
        (trunc(a.debut),trunc(a.fin)) overlaps (trunc(i_date_debut-1),trunc(i_fin))    -- dans un sens ou dans l'autre
      OR
        (trunc(i_date_debut),trunc(i_fin)) overlaps (trunc(a.debut-1),trunc(a.fin))
        );

  RETURN loc_nb_doubl;

END F_doublons_bpij;

--------------------------------------------------------------------------------
FUNCTION f_get_journal(i_traitement varchar2) RETURN journal_adm%rowtype IS
  io_journal journal_adm%rowtype;
BEGIN

    io_journal.id_session := sid;
    io_journal.idligne := 0;
    io_journal.nom_traitement :=COALESCE(i_traitement,g_nom_traitement,'PJT2T');

    RETURN  io_journal;
END f_get_journal;
--------------------------------------------------------------------------------
PROCEDURE P_INS_journal(
        P_niv  IN NUMBER,
        p_journal IN OUT JOURNAL_ADM%ROWTYPE,
        P_msg  IN VARCHAR2,
        p_msg2 IN VARCHAR2 default NULL)
  IS
  BEGIN

     IF nvl(p_journal.niv_msg,3)>= P_niv THEN
        p_journal.idligne := p_journal.idligne +1;

        PK_trace.P_INS_journal_adm ( I_nom_traitement => p_journal.nom_traitement, I_session => p_journal.id_session, I_niv_msg => P_niv, I_msg_adm => P_msg||' '||P_msg2, I_idligne => p_journal.idligne);
     END IF;
  END P_INS_journal;

PROCEDURE SET_RAPPEL_ERREUR( i_idrappel IN RAPPEL.idrappel%TYPE, i_code_err  IN RAPPEL.code_err%TYPE, i_etat IN RAPPEL.etat%TYPE)
IS
BEGIN
  UPDATE RAPPEL
    SET ETAT     = i_etat,
    CODE_ERR     = i_code_err,
    --RESPONSABLE  = F_numutil, -- PBO M0006543
    MODIFICATEUR = F_numutil,
    MAJ          = sysdate
  WHERE idrappel = i_idrappel;
 -- COMMIT;
END SET_RAPPEL_ERREUR;

PROCEDURE P_INS_HISTO_RAPPEL(i_idrappel number, i_commentaire varchar2, i_codeerr number) IS
V_IDHISTORAPPEL  number;
loc_rappel rappel%rowtype;
BEGIN
SELECT *
INTO loc_rappel
FROM RAPPEL
WHERE idrappel = i_idrappel;


        SELECT IDHISTORAPPEL.NEXTVAL INTO v_IDHISTORAPPEL FROM DUAL; -- PBO M0006431
         INSERT INTO HISTO_RAPPEL (IDRAPPEL,         ---RKO  M0005772
                  IDHISTORAPPEL,
                  CONTEXTE,
                  ENTITE,
                  TYPE,
                  REFERENCE,
                  REVISION,
                  CREATION,
                  CREATEUR,
                  MAJ,
                  MODIFICATEUR,
                  ETAT,
                  RESPONSABLE,
                  COMMENTAIRE)
          VALUES (  loc_rappel.IDRAPPEL,
                    V_IDHISTORAPPEL,
                    loc_rappel.CONTEXTE,
                    loc_rappel.ENTITE,
                    loc_rappel.TYPE,
                    loc_rappel.REFERENCE,
                    loc_rappel.REVISION,
                    loc_rappel.CREATION,
                    loc_rappel.CREATEUR,
                    sysdate,
                    F_numutil,
                    6,
                    loc_rappel.RESPONSABLE,
                    nvl(i_commentaire, pk_trace.F_AFF_mess_err(i_codeerr,1)));
END P_INS_HISTO_RAPPEL;

END PK_PREV_BPIJ;
/
