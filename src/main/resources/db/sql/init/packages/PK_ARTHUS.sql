CREATE OR REPLACE PACKAGE ARTHUS.PK_ARTHUS AS
/*===========================================================================*/
/* Package      : PK_ARTHUS.sql                                              */
/* Domaine      : Technique                                                  */
/* Version      : V1.0                                                       */
/* Auteur       : VDA                                                        */
/* Création     : 01/12/2010                                                 */
/* Description  : Contient toutes les fonctions et procédures techniques     */
/*              : Oracle ou Propre à Arthus à des fins de configuration      */
/*              : ou de maintenance                                          */
/*===========================================================================*/
/* Evolution    : Ajout du champs repertoire dans l objet batch de la        */
/*                procédure P_Livre_Appli. Ce champs est nécessaire lorsqu un*/
/*                traitement utilise une directorie(export,import,repdll,etc)*/
/* Auteur       : JBO                                                        */
/* Date         : 23/07/2013                                                 */
/* Commentaire  : Suite à la mise en place du module des affiliations CAPRA  */
/*===========================================================================*/
/* Evolution    : supp de insert dans VERSION                                */
/* Auteur       : MUR                                                        */
/* Date         : 07/08/2014                                                 */
/* Commentaire  : M0004551 : Sécurité                                        */
/*===========================================================================*/
/* Evolution    : modif P_ReCompilAll                                        */
/*              : reprise des droits donnés à PUBLIC à donner à              */
/*              : ORA_ARTHUS_ROLE1 et à ORA_ARTHUS_ROLE2                     */
/* Auteur       : MUR                                                        */
/* Date         : 07/08/2014                                                 */
/* Commentaire  : M0004808 : lecture seule                                   */
/*===========================================================================*/
/* Evolition    : modif P_ReCompilAll                                        */
/*              : recompil des objets invalides de CELLULE_TECHNIQUE         */
/* Auteur       : MUR                                                        */
/* Date         : 22/06/2018                                                 */
/* Commentaire  : M0005654                                                   */
/*===========================================================================*/
/* Evolition    : modif P_ReCompilAll                                        */
/*              : suppression de la gestion des rôles et de la gestion des   */
/*              : objets invalides de CELLULE_TECHNIQUE                      */
/* Auteur       : RDU                                                        */
/* Date         : 28/09/2021                                                 */
/* Commentaire  : sécurisation des accès                                     */
/*===========================================================================*/

/* ==========================================================================*/
-- PROCEDURES ET FONCTIONS PUBLIQUES

  FUNCTION  F_NbInvalid RETURN NUMBER;
  PROCEDURE P_ReCompilAll(i_nMax IN NUMBER DEFAULT 9);
  PROCEDURE P_Livre_Appli(a_client  IN NUMBER,
                          i_version IN VARCHAR2 DEFAULT NULL,
                          a_codapli IN VARCHAR2 DEFAULT NULL);

/* ========================== Fin des Procedures publiques ==================*/


END PK_ARTHUS;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_ARTHUS AS
/*===========================================================================*/
/* Package      : PK_ARTHUS.sql                                              */
/* Domaine      : Technique                                                  */
/* Version      : V1.0                                                       */
/* Auteur       : VDA                                                        */
/* Création     : 01/12/2010                                                 */
/* Description  : Contient toutes les fonctions et procédures techniques     */
/*              : Oracle ou Propre à Arthus à des fins de configuration      */
/*              : ou de maintenance                                          */
/*===========================================================================*/
/* Evolution    : Ajout du champs repertoire dans l objet batch de la        */
/*                procédure P_Livre_Appli. Ce champs est nécessaire lorsqu un*/
/*                traitement utilise une directorie(export,import,repdll,etc)*/
/* Auteur       : JBO                                                        */
/* Date         : 23/07/2013                                                 */
/* Commentaire  : Suite à la mise en place du module des affiliations CAPRA  */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/


  -- Curseur d'éléments invalides
  CURSOR c_InvalidItem IS
    SELECT OWNER,OBJECT_NAME,OBJECT_TYPE,STATUS
      FROM ALL_OBJECTS
     WHERE OBJECT_TYPE IN ('SYNONYM','TRIGGER','FUNCTION','PROCEDURE','PACKAGE','PACKAGE BODY','VIEW', 'MATERIALIZED VIEW')
       AND STATUS         = 'INVALID'
       AND OWNER          in ('ARTHUS')
     ORDER BY  owner , OBJECT_ID DESC;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_NbInvalid                                               */
/* Type         :  Public                                                    */
/* Description  :  Récupérère le nombre d'éléments invalide de ma DB         */
/* Retour       :  nombre d'élément non valide, ou -1 si erreur              */
/*---------------------------------------------------------------------------*/
  FUNCTION F_NbInvalid RETURN NUMBER
  IS
    i_NbInvalid     NUMBER := 0;
  BEGIN

    FOR cur IN c_InvalidItem LOOP
      i_NbInvalid := i_NbInvalid+1;
    END LOOP;

    RETURN i_NbInvalid;

  EXCEPTION
    WHEN OTHERS THEN RETURN -1;
  END F_NbInvalid;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                  */
/* Nom          :  P_ReCompilAll                                             */
/* Type         :  Public                                                    */
/* Description  :  Compilation de tous les éléments non valides              */
/* Entree       :  i_nMax, Limite d'itération à ne pas dépasser              */
/*---------------------------------------------------------------------------*/
  PROCEDURE P_ReCompilAll(i_nMax IN NUMBER DEFAULT 9)
  IS
    s_Name VARCHAR2(32) := 'PK_ARTHUS.ReCompilAll';
    i    NUMBER(1) := 0;
    nMax NUMBER(1) := NVL(i_nMax,9); -- Limite d'itération à ne pas dépasser
    i_NbInvalid     NUMBER := 0;
    i_NbInvalid_Old NUMBER := -1;
    s_Command VARCHAR2(256);

  BEGIN

      begin /* compil des objects invalides */
        IF F_NbInvalid = 0 THEN
          RAISE NO_DATA_FOUND;
        END IF;

        WHILE ((i < nMax) AND (i_NbInvalid_Old != i_NbInvalid)) LOOP
          FOR cur IN c_InvalidItem LOOP
            DBMS_OUTPUT.put_line(cur.OWNER || '.' || cur.OBJECT_NAME ) ;
            s_Command := 'ALTER @1 "@2"."@3" COMPILE @4'; -- Dynamic String Command
            BEGIN
              CASE cur.OBJECT_TYPE
                WHEN 'PACKAGE BODY' THEN s_Command := REPLACE(REPLACE(s_Command,'@1','PACKAGE'),'@4','BODY');
                ELSE s_Command := REPLACE(REPLACE(s_Command,'@1',cur.OBJECT_TYPE),'@4','');
              END CASE;
              DBMS_OUTPUT.put_line( 's_Command : ' || s_Command ) ;
              s_Command := TRIM(REPLACE(REPLACE(s_Command,'@3',cur.OBJECT_NAME),'@2',cur.OWNER));
              EXECUTE IMMEDIATE s_Command; -- Compilation de l'élément non-valide
              DBMS_OUTPUT.put_line( 'apres s_Command' ) ;
            EXCEPTION
              WHEN OTHERS THEN
                DBMS_OUTPUT.put_line(SUBSTR (SQLERRM (SQLCODE), 1, 128)) ;
            END;
          END LOOP;

          -- Vérification des éléments non-valides pour comparaison avec la fois précédente
          i_NbInvalid_Old := i_NbInvalid;
          i_NbInvalid := F_NbInvalid();
          i := i+1;
        END LOOP;
        DBMS_OUTPUT.put_line(s_Name || ' : Nb. d''éléments non-valide = '||TO_CHAR(i_NbInvalid));
      EXCEPTION
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.put_line(s_Name || ' : Tous les éléments basés sont valides !');
        WHEN OTHERS THEN
          DBMS_OUTPUT.put_line(s_Name || ' : Erreur !');
          --DBMS_OUTPUT.put_line(SUBSTR (SQLERRM (SQLCODE), 1, 128)) ;
      end ;

  END P_ReCompilAll;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Livre_Appli                                             */
/* Type         :  Public                                                    */
/* Description  :  Extraction des Menus Arthus pour générer Patch_Appli.sql  */
/* Entree       :  a_client, n° du client                                    */
/* Entree       :  (i_version), n° de version                                */
/* Entree       :  (a_codapli), CodeApplication Arthus                       */
/*---------------------------------------------------------------------------*/
  PROCEDURE P_Livre_Appli (
     a_client    IN   NUMBER,
     i_version   IN   VARCHAR2 DEFAULT NULL,
     a_codapli   IN   VARCHAR2 DEFAULT NULL
  )
  IS
     app           applications%ROWTYPE;
     app_desc      appli_descript%ROWTYPE;
     app_cont      appli_contexte%ROWTYPE;
     app_cli       appli_client%ROWTYPE;
     cle_int       cle_interne%ROWTYPE;
     cle_ext       cle_externe%ROWTYPE;
     prof          profil%ROWTYPE;
     batch         typ_batch%ROWTYPE;
     edition       typ_edition%ROWTYPE;
     param         param_batch%ROWTYPE;
     loc_codapli   VARCHAR2 (15);
     l_date_jour   DATE                     DEFAULT SYSDATE;
     w_version     VARCHAR2 (15);

  --
     CURSOR fetch_objet
     IS
        SELECT        codapli
                 FROM livre_appli
                WHERE client = a_client AND statut = 1
        FOR UPDATE OF statut;

  --
     loc_objet     fetch_objet%ROWTYPE;
  --
    -- M0005803
    loc_m0005803 number ;

  BEGIN
  -- Variable de reconnaissance SCCS
  -- @(#)P_livre_appli.sql    1.1    01/08/03
  -- Dbms_output.put_line( 'Set pause off' );
     DBMS_OUTPUT.put_line
           ('Alter table appli_contexte disable constraint fk1_appli_contexte;');

  -- Dbms_output.put_line( 'Alter table appli_contexte disable all triggers;' );
     FOR loc_objet IN fetch_objet
     LOOP
        loc_codapli := f_delimite (loc_objet.codapli, '''');
        --VCR/JPF 29012007
        -- Ajout du delete pour éviter l'erreur suivante :
        -- ORA-02292: violation de contrainte (ARTHUS.FK1_APPLI_CLIENT) d'intégrité - enregistrement fils exist
        DBMS_OUTPUT.put_line (   'Delete appli_client where codapli = '''|| loc_objet.codapli|| ''';');

  --
        FOR app_desc IN (SELECT '''' || codapli || '''' codapli,
                                '''' || f_double_quote (nom) || '''' nom,
                                '''' || prog || '''' prog,
                                '''' || TYPE || '''' TYPE,
                                '''' || domaine || '''' domaine,
                                '''' || etat || '''' etat,
                                '''' || auteur || '''' auteur,
                                '''' || D2E(creation) || '''' creation,
                                '''' || D2E(maj) || '''' maj,
                                '''' || VERSION || '''' VERSION
                           FROM appli_descript
                          WHERE codapli = loc_objet.codapli)
        LOOP
           DBMS_OUTPUT.put_line (   'Delete appli_descript where codapli = '''|| loc_objet.codapli|| ''';');
           DBMS_OUTPUT.put_line ('Insert Into appli_descript( CODAPLI, NOM, PROG, TYPE, DOMAINE, ETAT, AUTEUR, CREATION, MAJ, VERSION)');
           DBMS_OUTPUT.put_line (   'Values( '
                                 || app_desc.codapli
                                 || ','
                                 || app_desc.nom
                                 || ','
                                 || app_desc.prog
                                 || ','
                                 || app_desc.TYPE
                                 || ','
                                 || app_desc.domaine
                                 || ','
                                 || app_desc.etat
                                 || ','
                                 || app_desc.auteur
                                 || ','
                                 || 'E2D('|| app_desc.creation||'),'
                                 || 'E2D('|| app_desc.maj||'),'
                                 || app_desc.VERSION
                                 || ');'
                                );
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
        END LOOP;

  --VCR/JPF 29012007
  -- Ajout de la table appli_client
        FOR app_desc IN (SELECT '''' || codapli || '''' codapli,
                                '''' || fonction || '''' fonction,
                                '''' || client || '''' client,
                                '''' || etat || '''' etat,
                                   ''''
                                || D2E (creation)|| '''' creation,
                                '''' || D2E(maj) || '''' maj
                           FROM appli_client
                          WHERE codapli = loc_objet.codapli)
        LOOP
           -- VCR 29012007 Delete effectué avant appli_descript
           -- Dbms_output.put_line( 'Delete appli_client where codapli = '''|| loc_objet.codapli ||''';' );
           DBMS_OUTPUT.put_line ('Insert Into appli_client( CODAPLI, FONCTION, CLIENT, ETAT, CREATION, MAJ)');
           DBMS_OUTPUT.put_line (   'Values( '
                                 || app_desc.codapli
                                 || ','
                                 || app_desc.fonction
                                 || ','
                                 || app_desc.client
                                 || ','
                                 || app_desc.etat
                                 || ','
                                 || 'E2D('|| app_desc.creation|| '),'
                                 || 'E2D('|| app_desc.maj|| ')'
                                 || ');'
                                );
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
        END LOOP;

  --
        loc_m0005803  := 0 ; -- M0005803
        FOR app IN (SELECT '''' || codapli || '''' codapli,
                           '''' || f_double_quote (nom) || '''' nom,
                           '''' || TYPE || '''' TYPE,
                           '''' || fonction || '''' fonction,
                           '''' || sec || '''' sec, '''' || cle1 || '''' cle1,
                           '''' || cle2 || '''' cle2,
                              ''''|| D2E(creation)|| '''' creation,
                           '''' || D2E(maj) || '''' maj
                      FROM applications
                     WHERE codapli = loc_objet.codapli
                       AND fonction IN (SELECT codapli
                                          FROM appli_descript
                                         WHERE codapli = fonction AND TYPE = 1))
        LOOP
           if loc_m0005803 = 0 then -- generer le demete au premier passage seulement
             DBMS_OUTPUT.put_line ('Delete applications where codapli = '''|| loc_objet.codapli|| ''' and fonction = '|| app.fonction|| ';');
           end if ;
           loc_m0005803 := loc_m0005803 + 1 ;

           DBMS_OUTPUT.put_line ('Insert Into applications( CODAPLI, NOM, TYPE, fonction, sec, cle1, cle2,  CREATION, MAJ)');
           DBMS_OUTPUT.put_line (   'Values( '
                                 || app.codapli
                                 || ','
                                 || app.nom
                                 || ','
                                 || app.TYPE
                                 || ','
                                 || app.fonction
                                 || ','
                                 || app.sec
                                 || ','
                                 || app.cle1
                                 || ','
                                 || app.cle2
                                 || ','
                                 || 'E2D('|| app.creation|| '),'
                                 || 'E2D('|| app.maj|| ')'
                                 || ');'
                                );
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
        END LOOP;

        --JPF 26102005
        DBMS_OUTPUT.put_line (   'Delete appli_contexte where  fonction = '''|| loc_objet.codapli|| ''';');
        DBMS_OUTPUT.put_line (   'Delete appli_contexte where  codapli  = '''|| loc_objet.codapli|| ''';');

        FOR app_cont IN (SELECT '''' || codapli || '''' codapli,
                                '''' || fonction || '''' fonction,
                                '''' || ordre || '''' ordre,
                                '''' || ss_ordre || '''' ss_ordre,
                                '''' || action || '''' action,
                                '''' || cle1 || '''' cle1,
                                '''' || cle2 || '''' cle2,
                                '''' || cle3 || '''' cle3,
                                '''' || f_double_quote (libelle)
                                || '''' libelle, '''' || champ || '''' champ,
                                '''' || condition || '''' condition,
                                '''' || trig || '''' trig,
                                '''' || trig_exit || '''' trig_exit,
                                '''' || VERSION || '''' VERSION
                           FROM appli_contexte
                          WHERE fonction = loc_objet.codapli
                             OR codapli = loc_objet.codapli)
        LOOP
           --Dbms_output.put_line( 'Delete appli_contexte where fonction = '|| app_cont.fonction ||' and codapli = '|| app_cont.codapli ||';' );--JPF26102005
           DBMS_OUTPUT.put_line ('Insert Into appli_contexte( CODAPLI, FONCTION, ORDRE, SS_ORDRE, ACTION, CLE1, CLE2, CLE3, LIBELLE, CHAMP, CONDITION,TRIG,TRIG_EXIT,VERSION)');
           DBMS_OUTPUT.put_line (   'Values( '
                                 || app_cont.codapli
                                 || ','
                                 || app_cont.fonction
                                 || ','
                                 || app_cont.ordre
                                 || ','
                                 || app_cont.ss_ordre
                                 || ','
                                 || app_cont.action
                                 || ','
                                 || app_cont.cle1
                                 || ','
                                 || app_cont.cle2
                                 || ','
                                 || app_cont.cle3
                                 || ','
                                 || app_cont.libelle
                                 || ','
                                 || app_cont.champ
                                 || ','
                                 || app_cont.condition
                                 || ','
                                 || app_cont.trig
                                 || ','
                                 || app_cont.trig_exit
                                 || ','
                                 || app_cont.VERSION
                                 || ');'
                                );
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
        END LOOP;

        DBMS_OUTPUT.put_line ('Delete cle_interne where codapli = '''|| loc_objet.codapli|| ''';');

        FOR cle_int IN (SELECT '''' || codapli || '''' codapli,
                               '''' || cle || '''' cle,
                               '''' || cle_unique || '''' cle_unique,
                               '''' || BLOCK || '''' BLOCK,
                               '''' || champ || '''' champ,
                               '''' || seq || '''' seq
                          FROM cle_interne
                         WHERE codapli = loc_objet.codapli)
        LOOP
           DBMS_OUTPUT.put_line('Insert Into cle_interne( Codapli, Cle, Cle_unique, Block, Champ, Seq)');
           DBMS_OUTPUT.put_line (   'Values( '
                                 || cle_int.codapli
                                 || ','
                                 || cle_int.cle
                                 || ','
                                 || cle_int.cle_unique
                                 || ','
                                 || cle_int.BLOCK
                                 || ','
                                 || cle_int.champ
                                 || ','
                                 || cle_int.seq
                                 || ');'
                                );
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
        END LOOP;

        DBMS_OUTPUT.put_line ('Delete cle_externe where codapli = '''|| loc_objet.codapli|| ''';');

        FOR cle_ext IN (SELECT '''' || codapli || '''' codapli,
                               '''' || cle || '''' cle,
                               '''' || cle_unique || '''' cle_unique,
                               '''' || BLOCK || '''' BLOCK,
                               '''' || champ || '''' champ
                          FROM cle_externe
                         WHERE codapli = loc_objet.codapli)
        LOOP
           DBMS_OUTPUT.put_line ('Insert Into cle_externe( Codapli, Cle, Cle_unique, Block, Champ)');
           DBMS_OUTPUT.put_line (   'Values( '
                                 || cle_ext.codapli
                                 || ','
                                 || cle_ext.cle
                                 || ','
                                 || cle_ext.cle_unique
                                 || ','
                                 || cle_ext.BLOCK
                                 || ','
                                 || cle_ext.champ
                                 || ');'
                                );
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
        END LOOP;

        FOR prof IN (SELECT '''' || profil || '''' profil,
                            '''' || codapli || '''' codapli,
                            '''' || acces || '''' acces
                       FROM profil
                      WHERE codapli = loc_objet.codapli AND profil = 'ADM')
        LOOP
           DBMS_OUTPUT.put_line ('Delete profil where codapli = '''|| loc_objet.codapli|| ''' and profil = ''ADM'';');
           DBMS_OUTPUT.put_line ('Insert Into profil( Profil, Codapli, Acces) Values( '|| prof.profil|| ','|| prof.codapli|| ','|| prof.acces|| ');');
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
        END LOOP;

        FOR batch IN (SELECT '''' || batchid || '''' batchid,
                             '''' || f_double_quote (batchlib) || '''' batchlib,
                             '''' || immediat || '''' immediat,
                             '''' || priorite || '''' priorite,
                             '''' || nb_maxi || '''' nb_maxi,
                             '''' || periode || '''' periode,
                             '''' || ordre || '''' ordre,
                             '''' || arret || '''' arret,
                             '''' || userid || '''' userid,
                             '''' || simultane || '''' simultane,
                             '''' || codapli || '''' codapli,
                             '''' || param || '''' param,
                             '''' || ressource || '''' ressource,
                             '''' || seqid || '''' seqid,
                             '''' || repertoire || '''' repertoire
                        FROM typ_batch
                       WHERE batchid = loc_objet.codapli)
        LOOP
           -- JPF 18/12/2006 Dbms_output.put_line( 'Delete typ_batch where batchid = '''|| loc_objet.codapli ||''';' );
           DBMS_OUTPUT.put_line ('Insert Into typ_batch( Batchid, Batchlib, Immediat, Priorite, nb_maxi, periode, ordre, arret, userid, simultane, codapli, param, ressource, seqid, repertoire)');
           DBMS_OUTPUT.put_line (   'select '
                                 || batch.batchid
                                 || ','
                                 || batch.batchlib
                                 || ','
                                 || batch.immediat
                                 || ','
                                 || batch.priorite
                                 || ','
                                 || batch.nb_maxi
                                 || ','
                                 || batch.periode
                                 || ','
                                 || batch.ordre
                                 || ','
                                 || batch.arret
                                 || ','
                                 || batch.userid
                                 || ','
                                 || batch.simultane
                                 || ','
                                 || batch.codapli
                                 || ','
                                 || batch.param
                                 || ','
                                 || batch.ressource
                                 || ','
                                 || batch.seqid
                                 || ','
                                 || batch.repertoire
                                 || ' from dual'
                                );
           DBMS_OUTPUT.put_line (' where not exists (select 1 from typ_batch where Batchid= '''|| loc_objet.codapli|| ''');');
           DBMS_OUTPUT.put_line ('Update typ_batch set batchlib='|| batch.batchlib);DBMS_OUTPUT.put_line ('where Batchid=''' || loc_objet.codapli|| ''';');
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
        END LOOP;

        FOR edition IN (SELECT '''' || editid || '''' editid,
                               '''' || batchid || '''' batchid,
                               '''' || f_double_quote (editlib) || '''' editlib,
                               '''' || nb_char || '''' nb_char,
                               '''' || nb_ex || '''' nb_ex,
                               '''' || impid || '''' impid,
                               '''' || papid || '''' papid,
                               '''' || imp_req || '''' imp_req,
                               '''' || pap_req || '''' pap_req,
                               '''' || PURGE || '''' PURGE,
                               '''' || nb_pdg || '''' nb_pdg,
                               '''' || type_status || '''' type_status
                          FROM typ_edition
                         WHERE batchid = loc_objet.codapli)
        LOOP
           -- JPF 18/12/2006 Dbms_output.put_line( 'Delete typ_edition where batchid = '''|| loc_objet.codapli ||''';' );
           DBMS_OUTPUT.put_line('Insert Into typ_edition( Editid, Batchid, editlib, Nb_char, Nb_ex, Impid, Papid, Imp_req, Pap_req, Purge, Nb_pdg, Type_status)');
           DBMS_OUTPUT.put_line (   'select '
                                 || edition.editid
                                 || ','
                                 || edition.batchid
                                 || ','
                                 || edition.editlib
                                 || ','
                                 || edition.nb_char
                                 || ','
                                 || edition.nb_ex
                                 || ','
                                 || edition.impid
                                 || ','
                                 || edition.papid
                                 || ','
                                 || edition.imp_req
                                 || ','
                                 || edition.pap_req
                                 || ','
                                 || edition.PURGE
                                 || ','
                                 || edition.nb_pdg
                                 || ','
                                 || edition.type_status
                                 || ' from dual'
                                );
           DBMS_OUTPUT.put_line (' where not exists (select 1 from typ_edition where Batchid='''|| loc_objet.codapli|| ''');');
           DBMS_OUTPUT.put_line ('Update typ_edition set Editid='|| edition.editid|| ', Editlib ='|| edition.editlib);
           DBMS_OUTPUT.put_line (' where Batchid='''|| loc_objet.codapli|| ''' and batchid not in ');
           DBMS_OUTPUT.put_line ('(select distinct batchid from typ_edition group by batchid having count(*) > 1);');
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
        END LOOP;

        FOR param IN (SELECT '''' || numbatch || '''' numbatch,
                             '''' || f_double_quote (lib1) || '''' lib1,
                             '''' || f_double_quote (lib2) || '''' lib2,
                             '''' || f_double_quote (lib3) || '''' lib3,
                             '''' || f_double_quote (lib4) || '''' lib4,
                             '''' || f_double_quote (lib5) || '''' lib5,
                             '''' || f_double_quote (lib6) || '''' lib6,
                             '''' || f_double_quote (lib7) || '''' lib7,
                             '''' || f_double_quote (lib8) || '''' lib8,
                             '''' || f_double_quote (lib9) || '''' lib9,
                             '''' || f_double_quote (lib10) || '''' lib10,
                             '''' || typ1 || '''' typ1,
                             '''' || typ2 || '''' typ2,
                             '''' || typ3 || '''' typ3,
                             '''' || typ4 || '''' typ4,
                             '''' || typ5 || '''' typ5,
                             '''' || typ6 || '''' typ6,
                             '''' || typ7 || '''' typ7,
                             '''' || typ8 || '''' typ8,
                             '''' || typ9 || '''' typ9,
                             '''' || typ10 || '''' typ10,
                             '''' || ctrl1 || '''' ctrl1,
                             '''' || ctrl2 || '''' ctrl2,
                             '''' || ctrl3 || '''' ctrl3,
                             '''' || ctrl4 || '''' ctrl4,
                             '''' || ctrl5 || '''' ctrl5,
                             '''' || ctrl6 || '''' ctrl6,
                             '''' || ctrl7 || '''' ctrl7,
                             '''' || ctrl8 || '''' ctrl8,
                             '''' || ctrl9 || '''' ctrl9,
                             '''' || ctrl10 || '''' ctrl10,
                             '''' || valdeb1 || '''' valdeb1,
                             '''' || valdeb2 || '''' valdeb2,
                             '''' || valdeb3 || '''' valdeb3,
                             '''' || valdeb4 || '''' valdeb4,
                             '''' || valdeb5 || '''' valdeb5,
                             '''' || valdeb6 || '''' valdeb6,
                             '''' || valdeb7 || '''' valdeb7,
                             '''' || valdeb8 || '''' valdeb8,
                             '''' || valdeb9 || '''' valdeb9,
                             '''' || valdeb10 || '''' valdeb10,
                             '''' || valfin1 || '''' valfin1,
                             '''' || valfin2 || '''' valfin2,
                             '''' || valfin3 || '''' valfin3,
                             '''' || valfin4 || '''' valfin4,
                             '''' || valfin5 || '''' valfin5,
                             '''' || valfin6 || '''' valfin6,
                             '''' || valfin7 || '''' valfin7,
                             '''' || valfin8 || '''' valfin8,
                             '''' || valfin9 || '''' valfin9,
                             '''' || valfin10 || '''' valfin10,
                             '''' || mnemo1 || '''' mnemo1,
                             '''' || mnemo2 || '''' mnemo2,
                             '''' || mnemo3 || '''' mnemo3,
                             '''' || mnemo4 || '''' mnemo4,
                             '''' || mnemo5 || '''' mnemo5,
                             '''' || mnemo6 || '''' mnemo6,
                             '''' || mnemo7 || '''' mnemo7,
                             '''' || mnemo8 || '''' mnemo8,
                             '''' || mnemo9 || '''' mnemo9,
                             '''' || mnemo10 || '''' mnemo10,
                             '''' || param1 || '''' param1,
                             '''' || param2 || '''' param2,
                             '''' || param3 || '''' param3,
                             '''' || param4 || '''' param4,
                             '''' || param5 || '''' param5
                        FROM param_batch
                       WHERE numbatch = loc_objet.codapli)
        LOOP
           DBMS_OUTPUT.put_line ('Delete param_batch where numbatch = '''|| loc_objet.codapli|| ''';');
           DBMS_OUTPUT.put('Insert Into param_batch( numbatch, lib1, lib2, lib3, lib4, lib5)');
           DBMS_OUTPUT.put_line ('Values( '
                                 || param.numbatch
                                 || ','
                                 || param.lib1
                                 || ','
                                 || param.lib2
                                 || ','
                                 || param.lib3
                                 || ','
                                 || param.lib4
                                 || ','
                                 || param.lib5
                                 || ');'
                                );
           DBMS_OUTPUT.put_line ('Update param_batch Set lib6 = '
                                || param.lib6
                                || ','
                                || 'lib7 = '
                                || param.lib7
                                || ','
                                || 'lib8 = '
                                || param.lib8
                                || ','
                                || 'lib9 = '
                                || param.lib9
                                || ','
                                || 'lib10 = '
                                || param.lib10
                                || ' where numbatch = '
                                || param.numbatch
                                || ';'
                               );
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
           DBMS_OUTPUT.put_line ('Update param_batch Set typ1 = '
                                || param.typ1
                                || ','
                                || ' typ2 = '
                                || param.typ2
                                || ','
                                || ' typ3 = '
                                || param.typ3
                                || ','
                                || ' typ4 = '
                                || param.typ4
                                || ','
                                || ' typ5 = '
                                || param.typ5
                                || ','
                                || ' typ6 = '
                                || param.typ6
                                || ','
                                || ' typ7 = '
                                || param.typ7
                                || ','
                                || ' typ8 = '
                                || param.typ8
                                || ','
                                || ' typ9 = '
                                || param.typ9
                                || ','
                                || ' typ10 = '
                                || param.typ10
                                || ' where numbatch = '
                                || param.numbatch
                                || ';'
                               );
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
           DBMS_OUTPUT.put_line ('Update param_batch Set ctrl1 = '
                               || param.ctrl1
                               || ','
                               || ' ctrl2 = '
                               || param.ctrl2
                               || ','
                               || ' ctrl3 = '
                               || param.ctrl3
                               || ','
                               || ' ctrl4 = '
                               || param.ctrl4
                               || ','
                               || ' ctrl5 = '
                               || param.ctrl5
                               || ','
                               || ' ctrl6 = '
                               || param.ctrl6
                               || ','
                               || ' ctrl7 = '
                               || param.ctrl7
                               || ','
                               || ' ctrl8 = '
                               || param.ctrl8
                               || ','
                               || ' ctrl9 = '
                               || param.ctrl9
                               || ','
                               || ' ctrl10 = '
                               || param.ctrl10
                               || ' where numbatch = '
                               || param.numbatch
                               || ';'
                              );
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
           DBMS_OUTPUT.put_line ('Update param_batch Set valdeb1 = '
                             || param.valdeb1
                             || ','
                             || ' valdeb2 = '
                             || param.valdeb2
                             || ','
                             || ' valdeb3 = '
                             || param.valdeb3
                             || ','
                             || ' valdeb4 = '
                             || param.valdeb4
                             || ','
                             || ' valdeb5 = '
                             || param.valdeb5
                             || ','
                             || ' valdeb6 = '
                             || param.valdeb6
                             || ','
                             || ' valdeb7 = '
                             || param.valdeb7
                             || ','
                             || ' valdeb8 = '
                             || param.valdeb8
                             || ','
                             || ' valdeb9 = '
                             || param.valdeb9
                             || ','
                             || ' valdeb10 = '
                             || param.valdeb10
                             || ' where numbatch = '
                             || param.numbatch
                             || ';'
                            );
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
           DBMS_OUTPUT.put_line ('Update param_batch Set valfin1 = '
                             || param.valfin1
                             || ','
                             || ' valfin2 = '
                             || param.valfin2
                             || ','
                             || ' valfin3 = '
                             || param.valfin3
                             || ','
                             || ' valfin4 = '
                             || param.valfin4
                             || ','
                             || ' valfin5 = '
                             || param.valfin5
                             || ','
                             || ' valfin6 = '
                             || param.valfin6
                             || ','
                             || ' valfin7 = '
                             || param.valfin7
                             || ','
                             || ' valfin8 = '
                             || param.valfin8
                             || ','
                             || ' valfin9 = '
                             || param.valfin9
                             || ','
                             || ' valfin10 = '
                             || param.valfin10
                             || ' where numbatch = '
                             || param.numbatch
                             || ';'
                            );
  --    Dbms_output.put_line( 'Pause Presser Entrée pour continuer' );
           DBMS_OUTPUT.put_line ('Update param_batch Set mnemo1 = '
                              || param.mnemo1
                              || ','
                              || ' mnemo2 = '
                              || param.mnemo2
                              || ','
                              || ' mnemo3 = '
                              || param.mnemo3
                              || ','
                              || ' mnemo4 = '
                              || param.mnemo4
                              || ','
                              || ' mnemo5 = '
                              || param.mnemo5
                              || ','
                              || ' mnemo6 = '
                              || param.mnemo6
                              || ','
                              || ' mnemo7 = '
                              || param.mnemo7
                              || ','
                              || ' mnemo8 = '
                              || param.mnemo8
                              || ','
                              || ' mnemo9 = '
                              || param.mnemo9
                              || ','
                              || ' mnemo10 = '
                              || param.mnemo10
                              || ' where numbatch = '
                              || param.numbatch
                              || ';'
                             );
           DBMS_OUTPUT.put_line ('Update param_batch Set param1 = '
                              || param.param1
                              || ','
                              || ' param2 = '
                              || param.param2
                              || ','
                              || ' param3 = '
                              || param.param3
                              || ','
                              || ' param4 = '
                              || param.param4
                              || ','
                              || ' param5 = '
                              || param.param5
                              || ' where numbatch = '
                              || param.numbatch
                              || ';'
                             );
        END LOOP;

        -- Mise a jour de la table
        UPDATE livre_appli
           SET statut = 2,
               date_livre = l_date_jour
         WHERE CURRENT OF fetch_objet;
     --
     END LOOP;

     --Debut DBO 16/01/2008
     IF (i_version IS NOT NULL)
     THEN
        IF LENGTH (i_version) < 8
        THEN
           w_version := i_version || '.0';
        ELSE
           w_version := i_version;
        END IF;

        -- M0004551 : mur le 07/08/2014 : supp de insert dans VERSION
        /*INSERT INTO VERSION
                    (dateversion, numversion,
                     numrelease, numpatch,
                     sspatch
                    )
             VALUES (SYSDATE, SUBSTR (w_version, 1, 1),
                     SUBSTR (w_version, 3, 2), SUBSTR (w_version, 6, 2),
                     DECODE (SUBSTR (w_version, 9, 1),
                             '0', '',
                             SUBSTR (w_version, 9, 1)
                            )
                    );
        */
     END IF;

   -- Fin DBO
  --
     COMMIT;
  --
     DBMS_OUTPUT.put_line('update param_batch set lib1 = replace (lib1,chr(10),'' '') where lib1 like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('update param_batch set lib2 = replace (lib2,chr(10),'' '') where lib2 like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('update param_batch set lib3 = replace (lib3,chr(10),'' '') where lib3 like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('update param_batch set lib4 = replace (lib4,chr(10),'' '') where lib4 like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('update param_batch set lib5 = replace (lib5,chr(10),'' '') where lib5 like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('update param_batch set lib6 = replace (lib6,chr(10),'' '') where lib6 like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('update param_batch set lib7 = replace (lib7,chr(10),'' '') where lib7 like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('update param_batch set lib8 = replace (lib8,chr(10),'' '') where lib8 like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('update param_batch set lib9 = replace (lib9,chr(10),'' '') where lib9 like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('update param_batch set lib10 = replace (lib10,chr(10),'' '') where lib10 like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('update appli_descript set nom = replace (nom,chr(10),'' '') where nom like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('update applications   set nom = replace (nom,chr(10),'' '') where nom like ''%''|| CHR(10) || ''%'';');
     DBMS_OUTPUT.put_line('Alter table appli_contexte enable constraint fk1_appli_contexte;');
  -- Dbms_output.put_line( 'Alter table appli_contexte enable all triggers;' );

     -- M0004551 : mur le 07/08/2014 : supp de insert dans VERSION
     /*--Debut DBO 16/01/2008
     IF (i_version IS NOT NULL)
     THEN
        IF LENGTH (i_version) < 8
        THEN
           DBMS_OUTPUT.put_line('Insert Into Version (DATEVERSION, NUMVERSION, NUMRELEASE, NUMPATCH)');
           DBMS_OUTPUT.put_line (   'Values( '
                                 || 'E2D('''|| D2E(SYSDATE)||'''), '
                                 || SUBSTR (w_version, 1, 1)
                                 || ','
                                 || SUBSTR (w_version, 3, 2)
                                 || ','
                                 || SUBSTR (w_version, 6, 2)
                                 || ');'
                                );
        ELSE
           DBMS_OUTPUT.put_line('Insert Into Version (DATEVERSION, NUMVERSION, NUMRELEASE, NUMPATCH, SSPATCH)');
           DBMS_OUTPUT.put_line (   'Values( '
                                 || 'E2D('''|| D2E(SYSDATE)||'''), '
                                 || SUBSTR (w_version, 1, 1)
                                 || ','
                                 || SUBSTR (w_version, 3, 2)
                                 || ','
                                 || SUBSTR (w_version, 6, 2)
                                 || ','''
                                 || SUBSTR (w_version, 9, 1)
                                 || ''');'
                                );
        END IF;
     END IF;
     */

     --Fin DBO 16/01/2008
     DBMS_OUTPUT.put_line ('Commit;');
     DBMS_OUTPUT.put_line ('EXECUTE PK_ARTHUS.P_ReCompilAll();');
  END P_Livre_Appli;

END PK_ARTHUS;
/
