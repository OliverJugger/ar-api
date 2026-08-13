CREATE OR REPLACE PACKAGE ARTHUS.PK_AUTO_FLUX AS
/*===========================================================================*/
/* Package      : PK_AUTO_FLUX.sql                                           */
/* Domaine      : Editique                                                   */
/* Version      : V1.0                                                       */
/* Auteur       : ARTHUS                                                     */
/* Création     : 06/05/2019                                                 */
/* Description  : Package utilisé pour les imports automatiques              */
/*              :                                                            */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*                                                                           */
/*===========================================================================*/
  -- Chaine de reconnaissance SCCS
  -- %W%  %E%
  -- -- CONSTANTES PUBLIQUE -----------------------------------------------------
  -- Aucune
  -- -------------------------------------------- Fin des constantes publiques --
  -- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
  -- Aucune
  -- -------------------------------------------- Fin des exceptions publiques --
  -- -- PROCEDURES PUBLIQUES ----------------------------------------------------

PROCEDURE P_INS_AUTO_FLUX (
		I_DATTRT       IN DATE,
		I_NOMTRT       IN VARCHAR2,
		I_IDSESSION    IN NUMBER,
		I_NOMFIC       IN VARCHAR2,
		I_STATUT       IN VARCHAR2,
		I_MESSAGE      IN VARCHAR2,
		I_ENVOI_MAIL   IN NUMBER Default 0
	);

PROCEDURE P_A408T_AUTO;

Procedure P_INS_journal;

PROCEDURE P_ENVOI_MAIL_AUTO_FLUX (I_traitement in varchar2);

END PK_AUTO_FLUX;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_AUTO_FLUX AS
  -- Chaine de reconnaissance SCCS
  -- %W%  %E%
  -- -- CONSTANTES PRIVEES ------------------------------------------------------
  -- Aucune
  -- ---------------------------------------------- Fin des constantes privees --
  -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
  -- Aucune
  -- ---------------------------------------------- Fin des exceptions privees --
  -- -- TYPES PRIVEES -----------------------------------------------------------
  -- Aucun
  -- --------------------------------------------------- Fin des types privees --
  -- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
  -- Aucune
G_traitement      journal_adm.nom_traitement%TYPE ;
G_trt             auto_flux.nomtrt%TYPE;
G_session         journal_adm.id_session%TYPE ;
G_msg_adm         journal_adm.msg_adm%TYPE;
G_nbre_lignes     journal_adm.idligne%TYPE;

  -- -------------------------------------- Fin des variables globales privees --
  -- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
  --@priv
  --


PROCEDURE P_INS_AUTO_FLUX (
                               I_DATTRT       IN DATE,
                               I_NOMTRT       IN VARCHAR2,
                               I_IDSESSION    IN NUMBER,
                               I_NOMFIC       IN VARCHAR2,
                               I_STATUT       IN VARCHAR2,
                               I_MESSAGE      IN VARCHAR2,
                               I_ENVOI_MAIL   IN NUMBER Default 0
                )
IS
BEGIN
Insert Into AUTO_FLUX (
                DATTRT,
    NOMTRT,
    IDSESSION,
    NOMFIC,
    STATUT,
    MESSAGE,
    ENVOI_MAIL )
Values (
                sysdate,
                I_NOMTRT,
                I_IDSESSION,
                I_NOMFIC,
                I_STATUT,
                I_MESSAGE,
                I_ENVOI_MAIL);

END P_INS_AUTO_FLUX;

/******************************************************************************/

PROCEDURE P_A408T_AUTO
IS
--
L_idligne 					Number := 1;
L_lib_param_fin             Varchar2(100);
--
L_nom_fichier			    typ_batch.RESSOURCE%TYPE;
L_repertoire   				typ_batch.REPERTOIRE%TYPE;
I_porte                     PARAM_DMNDE.VALDEB1%TYPE := 1 ;

f_name                      varchar2(200);
directory_path              all_directories.DIRECTORY_PATH%type;
exc_continue                EXCEPTION;
C_listFiles                 SYS_REFCURSOR;
top_fic_trouv               Number;
loc_file                    varchar2(100);
loc_file_repert             varchar2(100);
--
v_nom_fichier				 typ_batch.RESSOURCE%TYPE;
v_nom_repertoire			 typ_batch.REPERTOIRE%TYPE;
L_statut                     VARCHAR2(3);

loc_numremise               number;  -- MUR M0005937
fic_const                   varchar2(100);
fic_repert                  varchar2(100);
loc_ano                     number;
--

      -- PBO M0006621
      cursor c_reprise_numassu is
        select
          p.idporte , p.numindiv , p.idadhesion , p.numremise , p.transmis , p.debut , p.fin , p.mouvement
          , n.numassu , n.creation , n.matorg
        from porte_adhesion p
        inner join noemie n on (n.numporte = p.numporte and n.idporte = p.idporte and n.numassu = 0 and n.creation >= e2d('01/01/2020') )
        where p.numporte = 1 and p.numremise = 0 and p.transmis = 2
        and 1=1
        and p.numporte = 1
        and p.idporte = (select max(pa2.idporte) from porte_adhesion pa2
                         where pa2.numporte = p.numporte
                           and pa2.idadhesion  = p.idadhesion
                           and pa2.numindiv = p.numindiv )
        and pk_ws_web_back.f_etat_adhe_ws(p.idadhesion,sysdate) = 1   -- Adhésions en cours uniquement
       ;

      r_reprise_numassu c_reprise_numassu%rowtype ;
      LOC_numassu   NUMBER(9);


BEGIN
--
-- Debut du traitement
  G_msg_adm	:= 'Debut de traitement - ' || TO_CHAR(Sysdate, 'hh24:mi');
  G_session := SID;
  G_traitement :='P_A408T_AUTO';
  G_trt := '408';
  G_nbre_lignes := 0 ;
  loc_ano := 0;
  P_INS_journal;

       -- PBO M0006621 : maj de noemie.numassu
      for r_reprise_numassu in c_reprise_numassu loop
        begin
          begin
            SELECT ouvreur.numindiv INTO LOC_numassu
            FROM indvs, indvs ouvreur
            WHERE ouvreur.matorg = indvs.matorg
              AND ouvreur.natur = 1
              AND indvs.matorg = r_reprise_numassu.matorg
              AND indvs.numindiv = r_reprise_numassu.numindiv;
          EXCEPTION WHEN others THEN loc_numassu := 0;
          END;
          --P_INS_journal(2,'p_maj_noemie: i_idporte=' || TO_CHAR(i_idporte)|| ' i_numindiv=' || TO_CHAR(i_numindiv)|| ' i_matorg=' || i_matorg ||' => loc_numassu=' || TO_CHAR(loc_numassu));
          if loc_numassu != 0 then
            UPDATE noemie SET numassu = loc_numassu
            WHERE idporte = r_reprise_numassu.idporte
              and numindiv = r_reprise_numassu.numindiv
              AND matorg = r_reprise_numassu.matorg AND numremise = 0 AND mouvement <> 'A' ;
          end if ;
        EXCEPTION WHEN others THEN null ; -- P_INS_journal(2,'p_maj_noemie: ERREUR SQL:' || sqlerrm);
        END;
      end loop ;



  begin
  -- Récupération du repertoire, de la configuration du fichier et du chemin physique en base
      select ressource, repertoire into v_nom_fichier, v_nom_repertoire
      from typ_batch     -- A408_CPAM_#DT_#HR.txt       --EXPORT
      where batchid = upper('A408T')
      and ressource is not null
      and repertoire is not null ;
  Exception
      WHEN NO_DATA_FOUND THEN
         G_msg_adm := 'Parametrage inexistant en base ';
         P_INS_journal;
         L_lib_param_fin  :=   'Parametrage inexistant en base de données' ;
         L_statut :='KO';
         P_INS_AUTO_FLUX ( sysdate,
                        G_trt,
                        G_session,
                        v_nom_fichier,
                        L_statut,
                        L_lib_param_fin ,
                        0);
         loc_ano := 1;
  end ;

  begin
        -- chemin physisque du repertoire d'export
              SELECT upper(directory_path) INTO directory_path
              FROM all_directories
              WHERE directory_name = v_nom_repertoire
              and upper(directory_path) is not null;
          exception
                WHEN NO_DATA_FOUND THEN
                     G_msg_adm := 'Chemin physique inexistant en base de données';
                     P_INS_journal;
                     L_lib_param_fin  :=   'Export Noémie en echec : Chemin physique inexistant en base de données' ;
                     L_statut :='KO';
                     P_INS_AUTO_FLUX ( sysdate,
                                    G_trt,
                                    G_session,
                                    v_nom_fichier,
                                    L_statut,
                                    L_lib_param_fin,
                                    0);
                      loc_ano := 2;
          end;

  If loc_ano = 0 then

      begin
--
-- CONSTITUTION ET VALIDATION DU BORDEREAU
            Pk_no04b.P_no04b(
                I_deb_numporte =>  I_porte,  --I_deb_numporte,
                I_fin_numporte =>  null,  --I_fin_numporte,
                I_param1       =>  1,
                I_param2       =>  null,
                I_session      =>  G_session,
                I_niv_msg      =>  1
                );

                  select numremise into loc_numremise -- MUR M0005937
                  from remise_externe
                  where numporte =  I_porte
                  and nature = 1
                  and valide = 'N'
                  and trunc(date_remise) = trunc (sysdate);

                  update remise_externe
                  set valide = 'O',
                  numutil = f_numutil,
                  datedit = sysdate,
                  datvalide= sysdate
                  -- MUR M0005937
                  where numremise = loc_numremise
                  and numporte = I_porte
                  and valide = 'N'
                  and trunc(date_remise) = trunc (sysdate);


                    -- Lancement de pk_a408b.P_A408B - génération du fichier
            pk_a408b.P_A408B
                  ( I_numporte => I_porte,
                    I_numsoc_deb =>  null,  --I_deb_societe,
                    I_numsoc_fin => null,  --I_fin_societe,
                    I_Repertoire =>  v_nom_repertoire,
                    I_Fichier    =>  v_nom_fichier
                  );


            top_fic_trouv := 0; --0 pour fichier non trouvé

        -- constitution du fichier attendu
            loc_file :=  replace(v_nom_fichier , '#DT' , TO_CHAR (SYSDATE, 'YYYYMMDD') ) ;   -- exemple de fichier A408_CPAM_20160809_11-46-40.txt
            loc_file :=  replace(loc_file , '#HR' , TO_CHAR (SYSDATE, 'HH24-MI-SS')) ;

        -- vérification fichier présent dans reprtoire d'export
            sys.PK_EXT_UTILS.ListFiles(directory_path,C_listFiles);

            begin
              loop
                FETCH C_listFiles INTO f_name;
                EXIT WHEN C_listFiles%NOTFOUND;
                 -- fichier present dans répertoire export
                loc_file_repert := replace(REPLACE(upper(f_name),directory_path),'\') ;
                select SUBSTR(loc_file_repert,1,18) into fic_repert from dual;
                select SUBSTR(loc_file,1,18) into fic_const from dual;
                -- verification de la presence de fic_const dans v_nom_repertoire
                if upper(fic_repert) = upper(fic_const) then
                   top_fic_trouv := 1; --fichier trouvé dans le repertoire
                   loc_file_repert :=loc_file_repert;
                   EXIT WHEN top_fic_trouv = 1 ;
                end if;
              end loop ;
            end ;
            CLOSE C_listFiles;

            if top_fic_trouv = 1 then

               /* MUR M0005937
               update remise_externe
               set date_trans = sysdate
               where numremise = numremise
               and trunc(date_remise) = trunc (sysdate);
               */

               G_msg_adm  := 'fichier généré :'|| loc_file_repert ||' '|| TO_CHAR(Sysdate, 'hh24:mi');
               P_INS_journal;

               L_lib_param_fin  :=  'Export du fichier '||loc_file_repert||' réussi.' ;
               L_statut  := 'OK';
               P_INS_AUTO_FLUX ( sysdate,
                               G_trt,
                               G_session,
                               loc_file_repert,--loc_file,
                               L_statut,
                               L_lib_param_fin ,
                               0);
            else
               G_msg_adm  := G_traitement || ' : anomalie de la génération du fichier '|| loc_file_repert;
               P_INS_journal;

               L_lib_param_fin  :=   G_traitement || ' : Export du fichier '||loc_file_repert||' en echec.' ;
               L_statut  := 'KO';
               P_INS_AUTO_FLUX ( sysdate,
                            G_trt,
                            G_session,
                            loc_file_repert,
                            L_statut,
                            L_lib_param_fin ,
                            0);
            end if ;

      End;
  End if;
  P_ENVOI_MAIL_AUTO_FLUX (I_traitement => G_trt);

   G_msg_adm  := 'fin de traitement A408T- ' || TO_CHAR(Sysdate, 'hh24:mi');
   P_INS_journal;

   COMMIT ;
EXCEPTION
   WHEN  NO_DATA_FOUND THEN
         G_msg_adm := 'Traitement Export Noémie : Aucune donnée à exporter' ;
         P_INS_journal;
         L_lib_param_fin  :=   'Traitement Export Noémie : Aucune donnée à exporter' ;
         L_statut :='KO';
         P_INS_AUTO_FLUX ( sysdate,
                        G_trt,
                        G_session,
                        v_nom_fichier,
                        L_statut,
                        L_lib_param_fin ,
                        0);
          P_ENVOI_MAIL_AUTO_FLUX (I_traitement => G_trt);
    WHEN TOO_MANY_ROWS THEN
         G_msg_adm := 'Plusieurs remises à valider manuellement';
         P_INS_journal;
         L_lib_param_fin  :=   'Export fichier Noemie en échec : Plusieurs remises à valider manuellement' ;
         L_statut :='KO';
         P_INS_AUTO_FLUX ( sysdate,
                        G_trt,
                        G_session,
                        v_nom_fichier,
                        L_statut,
                        L_lib_param_fin ,
                        0);
         P_ENVOI_MAIL_AUTO_FLUX (I_traitement => G_trt);
    WHEN OTHERS THEN
       G_msg_adm   := 'Erreur traitement. '||substr(sqlerrm(sqlcode),1,110);
       P_INS_journal;
    rollback ;

END P_A408T_AUTO;



----------------------- Fin des procedures publiques ------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
Procedure P_INS_journal
IS
BEGIN
    G_nbre_lignes := G_nbre_lignes + 1 ;
                pk_trace.P_ins_journal_adm (
                 I_nom_traitement => G_traitement,
                 I_session        => G_session,
                 I_niv_msg        => 1,
                 I_msg_adm        => G_msg_adm,
                 I_date           => Sysdate,
                 I_idligne        => G_nbre_lignes
                                );
END P_INS_journal;
/******************************************************************************/

PROCEDURE P_ENVOI_MAIL_AUTO_FLUX (I_traitement in varchar2)
IS
loc_envoi      envoi_mail%ROWTYPE;
/*select *
   from auto_flux
   where nomtrt = I_traitement
   and envoi_mail = 0;
  for update of envoi_mail;*/
l_ERROR        VARCHAR2(200);
text           CLOB;
l_nom_machine  param_machine.nom_machine%type;
l_destinataire varchar2(60);

CURSOR c_mails IS



  Select distinct message
  from auto_flux
  where nomtrt = I_traitement
  and envoi_mail = 0
  and message <> 'Aucun fichier trouvé'

  UNION ALL
    Select distinct message
    from auto_flux
    where nomtrt = I_traitement
    and envoi_mail = 0
    and message = 'Aucun fichier trouvé'
    and not exists (select 1 from auto_flux
                     where nomtrt = I_traitement
                     and envoi_mail = 0
                     and message <> 'Aucun fichier trouvé' );

BEGIN

    SELECT 1, 1, compte_mail
    INTO loc_envoi.NUMINDIV_DEST, loc_envoi.NUMBENE, loc_envoi.destinataire
    FROM param_machine
    WHERE id_machine= 'SERVEUR_MAIL';

    SELECT instance into l_nom_machine
    FROM parametres;


    l_destinataire  := 'l.koeltz@gerep.fr';
    loc_envoi.sujet :='[Rapport_ARTHUS] Rapport de l''automatisation du flux '||I_traitement|| ' - ' ||sysdate ||' sur l''instance '||l_nom_machine;
    loc_envoi.corps := ' ' ;
    begin
        FOR rec_mails IN c_mails
           LOOP
              loc_envoi.corps :=  loc_envoi.corps ||'-- '||rec_mails.message||CHR(10)||CHR(13) ;
              --update auto_flux set envoi_mail = 1 where current of c_mails;
           END LOOP;
    end;

    if loc_envoi.corps =' '
       then loc_envoi.corps := 'Aucun fichier traité';
    end if;

    GET_HTML_VARCHAR_FROM_FS('MAILS_IN', 'template_mail_rapport.html', text);
    PK_MAIL.transcode_template( template_mail=>text,
                                corps_msg =>loc_envoi.corps,
                                numindiv=>'',
                                numbene=>'',
                                sujet_msg =>loc_envoi.sujet);
    pk_mail.SEND_EMAIL(
    P_RECIPIENT     => l_destinataire,
    P_CC            => null,
    P_BCC           => null, --'Support@arthus-progiciels.com',
    P_SUBJECT       => '[Rapport_ARTHUS] Rapport d''automatisation du flux : '||I_traitement|| ' - ' ||sysdate,
    P_BODY          =>text,
    P_NUMUTIL       =>8,
    P_SENDER        => 'no-reply@gerep.fr',
    P_numindiv_dest=> null,
    P_ERROR        => l_ERROR);

    if l_ERROR is null then
        update auto_flux set envoi_mail = 1
        where nomtrt = I_traitement
        and envoi_mail = 0;
    else
    G_msg_adm   := 'Erreur d''envoi mail'||substr(sqlerrm(sqlcode),1,110);
    P_INS_journal;
    end if;
--EXCEPTION
    --WHEN  OTHERS THEN
     -- P_INS_journal(1,sqlerrm );
END P_ENVOI_MAIL_AUTO_FLUX;

---------------- Fin des corps des procedures privees --

END PK_AUTO_FLUX;
/
