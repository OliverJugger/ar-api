CREATE OR REPLACE PACKAGE ARTHUS.PK_PREV_GESTIP AS

      --  Procédure appelée par le JOB.
      -- Cette procédure insére une ligne dans remise_externe afin de taguer les mouvements générés
    TYPE t_conc IS RECORD (nom libelle_bis.libelle%TYPE, code libelle_bis.code%TYPE, SIRET pers_morale.siret%TYPE, entete3 pers_organisme.entete3%TYPE);


    --------------------------------------------------------------------------------
    -----------------------------Constitution des mouvements------------------------
    --------------------------------------------------------------------------------

    	--Cette procédure parcours tous les mouvements sur le domaine prévoyance,
      --en faisant appel à deux fonctionnalités plus fines dédiées aux contrats avec et sans franchise eet au fermture de dossier/adhésion.
     PROCEDURE P_CONSTIT_MOUVEMENT(i_date_mouvement DATE ); --Cette procédure parcours tous les mouvements sur le domaine prévoyance, en faisant appel à deux fonctionnalités plus fines dédiées aux contrats avec et sans franchise.
     PROCEDURE P_CONSTIT_MVT_CLOSE_ADHE(i_date_mouvement DATE , i_numporte NUMBER);

    --: Procédure parcourant chaque dossier dont sa periode de fin de franchise est arrivée.
    --La table répartition, gar_prev, et dossier_sinistre permettent de remonter les cas concernés.
    --L’insertion d’un mouvement dans la table porte_adhesion pour l’adhésion concerné est déclenchée pur chaque individu.
    PROCEDURE P_CONSTIT_MVT_FRANCHISE(i_date_mouvement DATE , i_numporte NUMBER);

    --Procédure parcourant toutes les adhésions prévoyances créées au jours J-1,
    --ou en vigueur au jour j afin d’insérer un mouvement dans la table porte_adhesion (Opération CRE) .
    PROCEDURE P_CONSTIT_MVT_SIMPLE(i_date_mouvement DATE , i_numporte NUMBER );


    PROCEDURE P_INSERT_PORTE_ADHESION(i_numindiv number,
                                      i_idadhesion number,
                                      i_idcouveture number,
                                      i_mouvement varchar2,
                                      i_type number,
                                      i_debut date,
                                      i_datper date)   ;

     -------------------------------------------------------------------------------
    -----------------------------Constitution Forcage global------------------------
    --------------------------------------------------------------------------------
  -- p_creer_mouvement_contrat permet de generer un mouvement GESTIP
  --             soit sur tous les adhérents couverts pour les contrats ouverts à la porte 29.
  --             soit sur tous les sinistres ouverts pour les contrats ouverts à la porte 28.
  -- Prend en paramètre un contrat, ouvert sur la porte 28 ou 29.
  -- et un mouvement particulier (pk_PREV_GESTIP.g_OPE_CRE, pk_PREV_GESTIP.g_OPE_SUP, pk_PREV_GESTIP.g_OPE_CRE_SUP)
    PROCEDURE P_CREER_MOUVEMENT_CONTRAT(i_numgar number, i_mouvement varchar2);
    --------------------------------------------------------------------------------
    --------------------------Génération des firchiers xml finaux ------------------
    --------------------------------------------------------------------------------
    -- Traitement Général
    PROCEDURE P_GENERER_GESTIP(i_traitement varchar2, i_date_mouvement date, io_journal IN OUT journal_adm%rowtype, o_erreur in out number);
    --Appele 1 fois en valorisant le numremise
    PROCEDURE P_GENERER_FICHIER(i_date_mouvement IN date, i_num_remise IN NUMBER, i_concentrateur t_conc,io_journal in out journal_adm%rowtype);
    -- Procédure qui annule un borderau GESTIP
    PROCEDURE P_ANNUL_BDX(i_traitement varchar2,i_numremise number, io_journal IN OUT journal_adm%rowtype);
    -- Génere l'entete xml d'un fichier gestip
    FUNCTION F_GENERER_ENT_GESTIP(i_num_remise IN NUMBER,  i_adresse_document IN VARCHAR2, i_concentrateur t_conc , io_journal IN OUT journal_adm%rowtype) RETURN XMLTYPE;
    --Génére le corps xml d'un fichier gestip
    FUNCTION F_GENERER_CORPS_GESTIP(  i_date_mouvement IN date
                                    , i_num_remise IN NUMBER
                                    , i_adresse_document IN VARCHAR2
                                    , i_concentrateur t_conc
                                    , io_journal IN OUT journal_adm%rowtype ) RETURN XMLTYPE;

    --------------------------------------------------------------------------------
    ---------------Fonction utiles a la valorisation des balises XML----------------
    --------------------------------------------------------------------------------

    FUNCTION F_TRANCOD_MOUVEMENT_OPE(mouvement varchar2) return VARCHAR2;
    FUNCTION F_GET_MOUVEMENT_SALARIER(i_date_mouvement IN date, i_numindiv number) return VARCHAR2;
    FUNCTION F_GET_MOUVEMENT_ADHESION(i_idadhesion number) RETURN VARCHAR2;
    FUNCTION F_GET_MOUVEMENT_ENTREPRISE(i_numcli number) RETURN VARCHAR2;
    FUNCTION F_SEL_NEXT_IDPORTE return number;
    FUNCTION F_GET_CONCENT_ID(format number default 0, i_nomconcentrateur varchar2 default null)RETURN VARCHAR2;
    FUNCTION F_GET_DATE RETURN VARCHAR2;
    FUNCTION F_GET_CLE_ACCES (i_code libelle_bis.code%TYPE) RETURN VARCHAR2;
    FUNCTION f_GET_SIRET_CONCENT(i_concentrateur individu.nom%type) RETURN NUMBER;

    --------------------------------------------------------------------------------
    --------------------------Fonction de génération unitaire XML-------------------
    --------------------------------------------------------------------------------

    FUNCTION F_GETXML_ENTREPRISE(i_numIndiv IN individu.numindiv%TYPE) RETURN XMLTYPE;
    FUNCTION F_GETXML_SALARIE(i_date_mouvement IN date, i_idporte NUMBER) RETURN XMLTYPE;
    FUNCTION F_GETXML_PREVOYANCE(i_idporte IN porte_adhesion.idporte%TYPE) RETURN XMLTYPE;


    PROCEDURE P_TAG_PORTE_ADHESION(p_idporte number, p_numrerise number);
    PROCEDURE P_INS_journal(
                            P_niv  IN NUMBER,
                            p_journal IN OUT JOURNAL_ADM%ROWTYPE,
                            P_msg  IN VARCHAR2,
                            p_msg2 IN VARCHAR2 default NULL);


    --------------------------------------------------------------------------------
    ------------------------------------Globals de package -------------------------
    --------------------------------------------------------------------------------
    FUNCTION F_OPE_CRE  RETURN VARCHAR2 ;  -- opération de création pour gestip
    FUNCTION F_OPE_SUP    RETURN VARCHAR2; -- opération de suppresion pour gestip
    FUNCTION F_OPE_SUPCRE  RETURN VARCHAR2 ;-- opération de mise a jour pour gestip
    FUNCTION F_PORTE_GESTIP RETURN NUMBER;
    FUNCTION CLOB2BLOB(aclob CLOB) RETURN BLOB;

    FUNCTION F_GET_JOURNAL(i_traitement varchar2) RETURN journal_adm%rowtype;
    g_xmlns CONSTANT varchar2(100) := 'xmlns="urn:.cnamts:tlsemp:GESTIP"';


    g_traitement varchar2(20);

    G_type_mvt_franchise number:=0; -- defini la valeur des type de porte_adhesion pour les cas d'adhésions franchisées controlées

    END PK_PREV_GESTIP;

PACKAGE  BODY      PK_PREV_GESTIP AS
  g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE  DEFAULT 'PJT1T';
  g_msg_adm                   journal_adm.msg_adm%TYPE;   -- ajout du paramêtre en entrée de la procédure
  g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
  g_niv_msg                   journal_adm.niv_msg%TYPE := 1; -- ajout du paramêtre en entrée de la procédure
  g_max_msg                   journal_adm.niv_msg%TYPE := 1;
  g_idligne                   journal_adm.idligne%TYPE := 0;
  g_erreur                    journal_adm.msg_adm%TYPE;
  exc_schema_xml_invalide EXCEPTION;


  FUNCTION F_OPE_CRE  RETURN VARCHAR2 IS BEGIN RETURN 'C'; END;  -- opération de création pour gestip
  FUNCTION F_OPE_SUP    RETURN VARCHAR2 IS BEGIN RETURN'S'; END; -- opération de suppresion pour gestip
  FUNCTION F_OPE_SUPCRE  RETURN VARCHAR2 IS BEGIN RETURN 'M'; END;-- opération de mise a jour pour gestip

  PROCEDURE P_GENERER_GESTIP(i_traitement varchar2, i_date_mouvement date, io_journal IN OUT journal_adm%rowtype, o_erreur in out number) IS
    loc_Constit_ok number :=0;
    loc_new_numremise remise_externe.numremise%type;
    loc_concentrateur t_conc;


    CURSOR c_concentrateurs is
      select  distinct opedi.numindiv,opedi.nom,pers_morale.SIRET, libelle_bis.code code_opedi, libelle_bis.libelle nom_opedi, pers_organisme.entete3
     from   porte_adhesion,
            adhe_cntrt,
            contrat
            ,pers_organisme
            ,individu opedi
            ,pers_morale
            ,libelle_bis
      WHERE porte_adhesion.idadhesion = adhe_cntrt.idadhesion
      and porte_adhesion.numporte     in (28,29)   -- mouvement de la porte GESTIP
      AND transmis                    = 2   -- Non transmis
      AND contrat.numgar              = adhe_cntrt.numgar
      AND contrat.numorg              = pers_organisme.numorg
      and decode(pers_organisme.entete3,'FFSA',1, 'FNMF',2,'CTIP',3,0) = libelle_bis.sens
      AND libelle_bis.mnemo           = 'GESTIP_C'
      AND opedi.nom                   = libelle_bis.libelle
      AND opedi.numindiv              = pers_morale.numindiv ;

    BEGIN
      p_ins_journal( 1,io_journal, 'Debut du traitement');
      BEGIN
        P_constit_mouvement(nvl(trunc(i_date_mouvement),trunc(sysdate - 1)) );
        loc_Constit_ok := 1;
      EXCEPTION
        WHEN OTHERS THEN
          p_ins_journal(1,io_journal, 'Erreur de la constitution des mouvements, génération de fichier annulée: '||sqlerrm);
      END;

      IF loc_Constit_ok =1 THEN
       BEGIN
        -- on boucle sur la génération de fichier pour chaque concentrateur
       FOR r_concentrateur in c_concentrateurs LOOP
          loc_concentrateur.nom := r_concentrateur.nom_opedi;
          loc_concentrateur.code := r_concentrateur.code_opedi;
          loc_concentrateur.entete3 := r_concentrateur.entete3;
          loc_concentrateur.siret := r_concentrateur.siret;

          SELECT seq_numremise.nextval
          INTO loc_new_numremise
          FROM dual;

          p_ins_journal( 1,io_journal,  'Création de la remise N° '||loc_new_numremise ||' pour le concentrateur '||r_concentrateur.nom);
          INSERT INTO  remise_externe (  NUMREMISE
                                        ,DATE_REMISE
                                        ,NUMPORTE
                                        ,NOMBRE
                                        ,BATCH
                                        ,VALIDE
                                        ,NUMUTIL
                                        ,DATEDIT
                                        ,DATVALIDE
                                        ,DATE_TRANS
                                        ,NATURE
                                        )
         VALUES(                        loc_new_numremise,
                                        sysdate ,
                                        f_porte_gestip,
                                        0,
                                        null,
                                        'N',
                                        F_numutil,
                                        null,
                                        null,
                                        null,
                                        1 ) ;

          P_GENERER_FICHIER(nvl(trunc(i_date_mouvement),trunc(sysdate-1)),loc_new_numremise, loc_concentrateur,io_journal ) ;

          UPDATE remise_externe SET      NOMBRE = (select count(IDPORTE) from porte_adhesion where numremise = loc_new_numremise)
                                        ,VALIDE ='O'
                                        ,DATEDIT = sysdate
                                        ,DATVALIDE = sysdate
                                        ,DATE_TRANS = sysdate
          WHERE NUMREMISE = loc_new_numremise;

      END LOOP;
      p_ins_journal(1,io_journal,  'Fin normale du traitement');
    EXCEPTION WHEN exc_schema_xml_invalide THEN
      p_ins_journal(1,io_journal, 'Erreur de schéma, : '||sqlerrm);
      ROLLBACK;

    WHEN OTHERS THEN
      p_ins_journal(1,io_journal, 'Génération du fichier impossible ');
      p_ins_journal(1,io_journal, 'Erreur : '||sqlerrm);
      ROLLBACK;
    END;
  END IF ; --constit_ok

  COMMIT;
  END;

  -- Procédure qui annule un borderau GESTIP
  PROCEDURE P_ANNUL_BDX(i_traitement varchar2,i_numremise number, io_journal IN OUT journal_adm%rowtype) IS
    l_remise_annul remise_externe%rowtype;
    --loc_journal   journal_adm%rowtype := f_get_journal(i_traitement);
    BEGIN

      UPDATE porte_adhesion SET numremise =0, transmis=2 WHERE numremise =i_numremise AND numporte in (28,29); -- remise à blanc du numremise sans supprimer les mouvements dans porte adhesion
      DELETE FROM remise_externe WHERE numremise =  i_numremise AND numporte in (28,29);
      P_INS_journal(1,io_journal, 'Annulation reussie pour la remise :'|| i_numremise);
      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
       P_INS_journal(1,io_journal, 'Annulation impossible :'||SQLERRM);
  END;
     ---------------------------------------------------------------------------------------------------------------
     ---------------------------------------------------------------------------------------------------------------
     --------------------------------------CONSTITUTION DES MOUVEMENTS----------------------------------------------
     ---------------------------------------------------------------------------------------------------------------
     ---------------------------------------------------------------------------------------------------------------
  PROCEDURE P_constit_mouvement(i_date_mouvement DATE )
  -- Cette procédure parcours tous les mouvements sur le domaine prévoyance,
  -- en faisant appel à deux fonctionnalités plus fines dédiées aux contrats
  -- avec et sans franchise.
    IS
    BEGIN
      -- Constitution des mouvements
             -- TODO enveler les NVL aprés les phase de test
          PK_PREV_GESTIP.P_CONSTIT_MVT_SIMPLE(nvl(i_date_mouvement,trunc(sysdate)),29); --solution complète ==> ouverture d'adhésion
          PK_PREV_GESTIP.P_CONSTIT_MVT_FRANCHISE(nvl(i_date_mouvement,trunc(sysdate)),28); -- solution au plus juste ==> ouverture de sinistre
          PK_PREV_GESTIP.P_CONSTIT_MVT_CLOSE_ADHE(nvl(i_date_mouvement,trunc(sysdate)),28);
          PK_PREV_GESTIP.P_CONSTIT_MVT_CLOSE_ADHE(nvl(i_date_mouvement,trunc(sysdate)),29);
          commit;
    END;

   -- constitue les mouvements pour les ouvertures d'adhésion avec des garanties non franchisé
  PROCEDURE P_constit_mvt_simple(i_date_mouvement DATE , i_numporte NUMBER )
    IS

      CURSOR c_adhesions_prev(i_date_mouvement DATE )IS
         /* with
            g_sans_franchise      -- on selection les garanties sans franchise en avance de pahs pour la performance
              as( SELECT numfor
                  FROM  gar_prev gp
                  WHERE  gp.type_fran NOT IN(select code     -- on ne prend pas les types de franchise controle
                                            from libelle
                                            where mnemo = 'TYPE_FRAN'
                                            AND sens is not null
                                            and code >0)
                        )    */
          SELECT ac.idadhesion, a.idcouverture,  numadhe, a.datapli,a.datper
          FROM  adhe_cntrt ac,
                adhesion a,
                garanties g,
            --    g_sans_franchise,
                contrat c,
                individu i
            WHERE  ac.idadhesion = a.idadhesion
            AND ac.numadhe = a.numindiv
            AND c.numgar = ac.numgar
            AND a.numfor = g.numfor
            AND ac.numadhe = i.numindiv
            AND nvl(i.matorg, i.N_INSEE) IS NOT NULL
         --   AND c.type_contrat = 2 -- contrat prevoyance
            AND g.NAT_RISQ IN (select code FROM libelle WHERE mnemo='GESTIP_R' and code > 0) -- incapacité de travail
          --  AND a.numfor =  g_sans_franchise.numfor
            AND c.numgar_ref IN (select numgar FROM porte_contrat where numporte = i_numporte)
            AND i_date_mouvement between a.datapli and nvl(a.datper,sysdate+1)
            AND (i_date_mouvement IN (TRUNC(a.creation), TRUNC(a.maj))      -- soit il y a un mouvement dans les adhesions
                 OR  EXISTS (        -- soit l'individu a vu son nom ou prenom modifié a la date indiqué
                      SELECT individu.numindiv
                      FROM individu, individu_audit
                      WHERE trunc(individu_audit.maj)=i_date_mouvement
                        AND individu.numindiv = individu_audit.numindiv
                        AND (   individu.nom <>individu_audit.nom
                            OR  individu.prenom <>individu_audit.prenom)
                        AND i.NUMINDIV =individu.numindiv
                      )
                )
        ;

   loc_porte_adhesion porte_adhesion%rowtype;
   loc_porte_gestip porte_gestip%rowtype;
   r_adhesion c_adhesions_prev%rowtype;
  BEGIN

    FOR r_adhesion IN c_adhesions_prev(i_date_mouvement) loop


        P_insert_porte_adhesion(  i_numindiv => r_adhesion.numadhe  ,
                                  i_idadhesion =>  r_adhesion.IDADHESION ,
                                  i_idcouveture => r_adhesion.idcouverture ,
                                  i_mouvement => f_get_mouvement_adhesion(r_adhesion.idadhesion) ,
                                  i_type => 1,
                                  i_debut => r_adhesion.datapli,
                                  i_datper =>  r_adhesion.datper);

    END LOOP;
    -- Pour chaque adhésion on controle le type de mouvement a creer (CRE SUP SUPCRE)


  END P_constit_mvt_simple;

  -- Constution des mouvements franchisé (ouverture d'un dossier et creation d'un sinistre =>mouvement declencheur)
   PROCEDURE P_constit_mvt_Franchise(i_date_mouvement DATE , i_numporte NUMBER )
    IS
      CURSOR c_adhesions_prev(p_date_mouvement DATE )IS    --29/03/2018
         /*WITH
            g_avec_franchise      -- on selection les garanties avec franchise en avance de phase pour la performance
              as( SELECT gp.numfor
                  FROM  gar_prev gp, gar
                  WHERE  gp.type_fran IN(select code     -- on ne prend que les types de franchise controle
                                            from libelle
                                            where mnemo = 'TYPE_FRAN'
                                            AND sens is not null
                                            and code >0)
                      AND gp.numfor = gar.numfor
                      AND gar.gest_calc = 1 -- garanties reglées
                        )*/
            SELECT  sp.IDDOSSIER,
                    sp.NOSIN,
                    sp.survenance,
                    sp.priscalc,
                    r.idadhesion,
                    a.datapli,
                    a.datper,
                    sp.creation,
                    a.idcouverture,
                    a.numindiv
            FROM  dossier_sinistre ds,
                  sntr_prev sp,
                  repartition r ,
                  repartition_bene rb,
                --  g_avec_franchise g,
                  adhesion a,
                  contrat c,
                  individu i
            WHERE  ds.iddossier = sp.iddossier
            AND sp.NOSIN = r.NOSIN
            AND r.valide = 'O'
            AND ds.numindiv = i.numindiv
            AND nvl(i.matorg, i.N_INSEE) IS NOT NULL
            AND a.numindiv = rb.NUMBENE
            AND r.idrepartition = rb.idrepartition
            AND rb.valide = 'O'
           -- AND r.numfor = g.numfor
            AND a.idadhesion = r.idadhesion
            AND r.numfor = a.numfor --pour éviter les doublons
            AND a.numgar = c.numgar
            -- ARTGEREP-441: Date pivot est la date de création du correspondant qui est alimentée au moment de la validation de la repartition
            AND EXISTS (SELECT 1
                          FROM correspondant c
                        WHERE c.numcorres = rb.numbene
                          AND c.type_corres=6
                          AND c.entite=sp.nosin
                          AND TRUNC(c.creation) =p_date_mouvement
                          )
            -- restriction sur le risque incapacité
            AND sp.NORISQ IN (select code FROM libelle WHERE mnemo='GESTIP_R' and code > 0)
            -- Ne pas remonter les dossiers ayant un (ou +sieurs) sinistre de type incapacité de travail d'ouvert pour le même assuré
            AND NOT EXISTS(select 1--pas un autre sinistre de type incapacité d'ouvert pour le même assuré
                            from sntr_prev spr, histo_sntr_prev hspr, DOSSIER_SINISTRE dsr
                            where hspr.nosin=spr.nosin
                            and dsr.iddossier = spr.iddossier
                            AND dsr.numindiv  = ds.numindiv
                            and (hspr.saisie, hspr.debut) =(select max(hsp1.saisie), hsp1.debut
                                                            from histo_sntr_prev hsp1
                                                            where hsp1.debut<=sysdate
                                                            and hsp1.nosin=spr.nosin
                                                            and hsp1.debut =(select max(hsp2.debut)
                                                                            from histo_sntr_prev hsp2
                                                                            where hsp2.debut<=sysdate
                                                                            and hsp2.nosin=spr.nosin
                                                                            )
                                                            group by hsp1.debut
                                                            )
                            and hspr.etat<>2 --non fermé --1 en cours, 2 fermé
                            and spr.norisq IN (select code FROM libelle WHERE mnemo='GESTIP_R' and code > 0) --incapacité de travail
                            and spr.nosin<>sp.nosin --pas le meme sinistre
                          )
            AND c.numgar_ref in(select numgar from porte_contrat where numporte = i_numporte);

            --TODO amélioration : avoir une donnée sur la répartition et s'appuyer dessus plutot que sur la création du sinistre

   loc_porte_adhesion porte_adhesion%rowtype;
   loc_porte_gestip   porte_gestip%rowtype;
   r_adhesion         c_adhesions_prev%rowtype;
  BEGIN

  for r_adhesion in c_adhesions_prev(i_date_mouvement) loop


      P_insert_porte_adhesion(  i_numindiv => r_adhesion.numindiv  ,
                                i_idadhesion =>  r_adhesion.IDADHESION ,
                                i_idcouveture => r_adhesion.idcouverture ,
                                i_mouvement => f_get_mouvement_adhesion(r_adhesion.idadhesion) ,
                                i_type => G_type_mvt_franchise,
                                i_debut => r_adhesion.survenance,  --  passer la date de survenance du sinistre pour la date de rétrocession
                                i_datper =>  r_adhesion.datper);

  end loop;
    -- Pour chaque adhésion on controle le type de mouvement a creer (CRE SUP SUPCRE)


  END P_constit_mvt_Franchise;


   -- Procédure qui pour chaque fermeture d'adhésion ou de dossier génére un mouvement de suppresion
   PROCEDURE P_constit_mvt_close_adhe(i_date_mouvement DATE , i_numporte NUMBER)
      IS

      CURSOR c_adhesions_prev(i_date_mouvement DATE )IS    --29/03/2018 et --14/09/2018
            select -- fermeture de dossier prevoyance
                   r.idadhesion,
                   a.idcouverture,
                   a.numindiv,
                   a.datapli,
                   a.datper
            from  DOSSIER_SINISTRE ds,
                  SNTR_PREV sp,
                  REPARTITION r ,
                  ADHESION a,
                  REPARTITION_BENE rb,
                  contrat c,
                  individu i,
                  histo_sntr_prev histo
            WHERE ds.iddossier = sp.iddossier
            AND sp.NOSIN = r.NOSIN
            and r.valide = 'O'
            AND a.idadhesion = r.idadhesion
            AND r.numfor = a.numfor --pour éviter les doublons
            AND a.numindiv = rb.NUMBENE
            AND r.idrepartition =rb.idrepartition
            AND rb.valide = 'O'
            AND c.numgar = a.numgar
            AND ds.numindiv = i.numindiv
            AND nvl(i.matorg, i.N_INSEE) IS NOT NULL
            AND c.numgar_ref in(select numgar from porte_contrat where numporte = i_numporte)
            AND histo.debut = (select max(h.debut) from histo_sntr_prev h where trunc(debut)<= i_date_mouvement  AND h.nosin =sp.nosin) --utile ?
            --TODO fonctionner à l'inverse en regardant si une réouverture n'a pas été saisie le même jour ==> rechute
            AND trunc(histo.saisie) =i_date_mouvement
            AND histo.nosin =sp.nosin
            -- ARTGEREP-441: restriction sur le risque incapacité
            AND sp.NORISQ IN (select code FROM libelle WHERE mnemo='GESTIP_R' and code > 0)
            -- Ne pas remonter les dossiers ayant un (ou +sieurs) sinistre de type incapacité de travail d'ouvert pour le même assuré
            AND NOT EXISTS(select 1--pas un autre sinistre de type incapacité d'ouvert pour le même assuré
                            from sntr_prev spr, histo_sntr_prev hspr, DOSSIER_SINISTRE dsr
                            where hspr.nosin=spr.nosin
                            and dsr.iddossier = spr.iddossier
                            AND dsr.numindiv  = ds.numindiv
                            and (hspr.saisie, hspr.debut) =(select max(hsp1.saisie), hsp1.debut
                                                            from histo_sntr_prev hsp1
                                                            where hsp1.debut<=sysdate
                                                            and hsp1.nosin=spr.nosin
                                                            and hsp1.debut =(select max(hsp2.debut)
                                                                            from histo_sntr_prev hsp2
                                                                            where hsp2.debut<=sysdate
                                                                            and hsp2.nosin=spr.nosin
                                                                            )
                                                            group by hsp1.debut
                                                            )
                            and hspr.etat<>2 --non fermé --1 en cours, 2 fermé
                            and spr.norisq IN (select code FROM libelle WHERE mnemo='GESTIP_R' and code > 0) --incapacité de travail
                            and spr.nosin<>sp.nosin --pas le meme sinistre
                          )
            AND histo.etat=2
            UNION
          SELECT distinct ac.idadhesion, a.idcouverture,  numadhe numindiv , a.datapli,a.datper
          FROM  adhe_cntrt ac,    -- fermeture de garantie
                adhesion a,
                histo_adhesion ha,
                garanties g,
                contrat c,
                individu i
            WHERE ac.idadhesion = a.idadhesion
            AND ac.numadhe = a.numindiv
            AND c.numgar = ac.numgar
            AND c.numgar_ref in(select numgar from porte_contrat where numporte = i_numporte)
            AND a.numfor = g.numfor
            AND ac.numadhe = i.numindiv
            AND nvl(i.matorg, i.N_INSEE) IS NOT NULL
            and ha.idadhesion = a.idadhesion
            AND trunc(ha.datsai) =   i_date_mouvement
            AND ha.etat = 3 -- resilisation d'adhésion
            AND g.NAT_RISQ IN (select code FROM libelle WHERE mnemo='GESTIP_R' and code > 0);



   loc_porte_adhesion porte_adhesion%rowtype;
   loc_porte_gestip porte_gestip%rowtype;
   r_adhesion c_adhesions_prev%rowtype;
  BEGIN

  for r_adhesion in c_adhesions_prev(i_date_mouvement) loop


      P_insert_porte_adhesion(  i_numindiv => r_adhesion.numindiv  ,
                                i_idadhesion =>  r_adhesion.IDADHESION ,
                                i_idcouveture => r_adhesion.idcouverture ,
                                i_mouvement =>  F_OPE_SUP ,
                                i_type => 11,
                                i_debut => r_adhesion.datapli,
                                i_datper =>  r_adhesion.datper);

  end loop;
    -- Pour chaque adhésion on controle le type de mouvement a creer (CRE SUP SUPCRE)


   END P_constit_mvt_close_adhe;

  PROCEDURE P_insert_porte_adhesion(i_numindiv number,
                                    i_idadhesion number,
                                    i_idcouveture number,
                                    i_mouvement varchar2,
                                    i_type number,
                                    i_debut date,
                                    i_datper date) iS

   loc_porte_adhesion porte_adhesion%rowtype;
   loc_porte_gestip   porte_gestip%rowtype;
-- FORCAGE de la porte  pour tous les enreg porte_adhesion GESTIP
   loc_numporte       porte_adhesion.numporte%type := f_porte_gestip;

  BEGIN

      loc_porte_adhesion.IDPORTE     := f_sel_next_idporte;-- identifiant unique du mouvement
      loc_porte_adhesion.NUMPORTE    := loc_numporte; -- porte GESTIP
      loc_porte_adhesion.NUMINDIV    := i_numindiv;
      loc_porte_adhesion.IDADHESION  := i_idadhesion;
      loc_porte_adhesion.NUMREMISE   := 0;
      loc_porte_adhesion.TRANSMIS    := 2;
      loc_porte_adhesion.TYPE        := i_type; --0;
      loc_porte_adhesion.DEBUT       := i_debut;--r_adhesion.DATE_ADHE;
      loc_porte_adhesion.MOUVEMENT   := i_mouvement; --f_get_mouvement_adhesion(r_adhesion.idadhesion);
      loc_porte_adhesion.FIN         := i_datper;--r_adhesion.DATE_FIN_ADHE;
     -- insert into porte_adhesion values loc_porte_adhesion;
      loc_porte_gestip.idporte       := loc_porte_adhesion.IDPORTE;
      loc_porte_gestip.IDADHESION    := loc_porte_adhesion.IDADHESION;
      loc_porte_gestip.idcouverture  := i_idcouveture;

    MERGE INTO porte_adhesion
    USING DUAL
    ON (TRANSMIS=2
        AND numporte = loc_numporte
        AND NUMREMISE = 0
        AND IDADHESION = i_idadhesion
        AND NUMINDIV = i_numindiv)
    WHEN MATCHED THEN
      UPDATE SET TYPE      = i_type,
                 DEBUT     = i_debut,
                 MOUVEMENT = i_mouvement,
                 FIN       = i_datper
      --DELETE WHERE conditions2
    WHEN NOT MATCHED THEN
      INSERT ( IDPORTE
              ,NUMPORTE
              ,NUMINDIV
              ,IDADHESION
              ,NUMREMISE
              ,TRANSMIS
              ,TYPE
              ,DEBUT
              ,MOUVEMENT
              ,FIN
              )
      VALUES (loc_porte_adhesion.IDPORTE,
              loc_numporte,
              i_numindiv,
              i_idadhesion,
              0,
              2,
              i_type,
              i_debut,
              i_mouvement,
              i_datper)
      ;
      --insertion de données propre a gestip

    MERGE INTO porte_gestip
    USING (select idporte, idadhesion
            from porte_adhesion where
            TRANSMIS=0
            AND numporte = loc_numporte
            AND NUMREMISE = 0
            AND NUMINDIV = i_numindiv
            ) porte

    ON (
           porte.idporte = porte_gestip.idporte
           AND porte.IDADHESION= i_idadhesion


           )
    WHEN  NOT MATCHED THEN
      INSERT ( IDPORTE  ,IDADHESION  ,idcouverture)
      VALUES (loc_porte_gestip.idporte , loc_porte_gestip.IDADHESION, loc_porte_gestip.idcouverture )
      ;
    COMMIT;

  END P_insert_porte_adhesion;


  FUNCTION f_get_mouvement_entreprise(i_numcli number) RETURN VARCHAR2
  IS
  loc_mouvement varchar2(50) ;
  BEGIN
   -- verifie que c'est le premmier mouvement que l'on envoi.
   select 'Operation="CRE"'
    INTO loc_mouvement
     from dual
     where not exists(
     select 1
     from porte_adhesion pa,
          adhe_cntrt ac,
          contrat c
      WHERE
          pa.idadhesion = ac.idadhesion
          AND pa.numporte in (28,29)
          AND ac.numgar = c.numgar
          AND c.numcli = i_numcli
          AND numremise <> 0
          and transmis = 1
        );

     return loc_mouvement;

  EXCEPTION WHEN OTHERS THEN
      RETURN '';
  END f_get_mouvement_entreprise;


  -- retourne 0 => cre
  -- retourne 1 => sup
  -- retourne 2 => supcre (mise à jour)
  FUNCTION f_get_mouvement_salarier(i_date_mouvement IN date, i_numindiv number) RETURN VARCHAR2
  IS
  nb_distinct_mvt number;
  loc_tous_egaux varchar2(3);
  loc_tous_supp  varchar2(3);
  loc_modifie number;
  loc_mouvement VARCHAR2(1);
  loc_der_mouvement VARCHAR2(1);

  BEGIN

    SELECT COUNT( 1)
    INTO  loc_modifie
    FROM individu
    WHERE numindiv IN (  -- soit l'individu a vu son nom ou prenom modifié a la date indiquée
                        SELECT individu.numindiv
                        FROM individu, individu_audit
                        WHERE
                              individu.numindiv = i_numindiv
                          AND trunc(individu_audit.maj)= i_date_mouvement
                          AND individu.numindiv = individu_audit.numindiv
                          AND (   individu.nom <>individu_audit.nom
                              OR  individu.prenom <>individu_audit.prenom)
                            )
        ;

    -- on prend le dernier mouvement transmis
    BEGIN
      SELECT mouvement
      INTO loc_der_mouvement
     FROM  porte_adhesion pa
     WHERE pa.numporte in (28,29)
     AND pa.numindiv = i_numindiv
     AND transmis = 1
     order by idporte desc
     FETCH FIRST 1 ROWS ONLY;

    EXCEPTION WHEN NO_DATA_FOUND THEN
       loc_der_mouvement:=null;
    END ;

    -- on prend le  mouvement a émettre
    BEGIN
      SELECT mouvement
      INTO loc_mouvement
     FROM  porte_adhesion pa
     WHERE pa.numporte in (28,29)
     AND pa.numindiv = i_numindiv
     AND transmis = 2
     order by idporte desc
     FETCH FIRST 1 ROWS ONLY;

    EXCEPTION WHEN NO_DATA_FOUND THEN
       loc_mouvement:=null;
    END ;


     dbms_output.put_line('loc_mouvement='||loc_mouvement||'loc_der_mouvement='||loc_der_mouvement ||' loc_modifie='||loc_modifie ) ;
      -- si le mouvement à transmettre est suppresion
      -- alors on envoi un mouvement de suppresion
      IF loc_mouvement = 'S' THEN
        return 'Operation="'||f_trancod_mouvement_ope(F_OPE_SUP) ||'" ' ;
      -- si l'individu est modifié et que le dernier mouvement n'est pas une suppresion
      -- alors on envoi un mouvement de modification
      ELSIF loc_modifie <> 0 AND loc_der_mouvement <>'S' AND loc_der_mouvement IS NOT NULL THEN
        return 'Operation="'||f_trancod_mouvement_ope(F_OPE_SUPCRE) ||'" ' ;
      -- si l'individu n'est pas modifié et que le dernier mouvement n'est pas une suppresion
      -- alors on envoi un mouvement de modification
      ELSIF loc_modifie = 0 AND loc_der_mouvement <>'S' AND loc_der_mouvement IS NOT NULL THEN
        return  ' ' ;
      -- sinon si  le dernier mouvement transmis est une suppression,
      -- ou que l'on a jamais envoyé de mouvement auparavant
       -- alors on inscrit le salarier => OPE_CRE
      ELSIF nvl(loc_der_mouvement,'S') ='S' THEN
        return 'Operation="'||f_trancod_mouvement_ope(F_OPE_CRE) ||'"';
      END IF;
   /*

  BEGIN
    -- tous les mouvements a transmettre sont-il egaaux?
    SELECT distinct mouvement
      INTO  loc_tous_egaux
      FROM porte_adhesion
      WHERE numindiv = i_numindiv
      AND NUMPORTE in (28,29)
      AND TRANSMIS = 2
      ;

  EXCEPTION WHEN OTHERS THEN
    loc_tous_supp:= null;
  END;

  IF loc_tous_egaux = 'S' THEN  -- Tous les mouvements a transmettre sont des suppressions ?
      SELECT COUNT(1)
      INTO  nb_distinct_mvt
      FROM porte_adhesion  pa
      WHERE pa.numindiv = i_numindiv
      AND pa.NUMPORTE in (28,29)
      AND pa.TRANSMIS = 1
      AND mouvement in ('M','C')
      AND NOT EXISTS (SELECT 1      -- on prend le dernier mouvement transmis
                  FROM porte_adhesion  pa2
                  WHERE pa2.idporte > pa.idporte
                  AND pa2.idadhesion = pa.idadhesion
                  and pa2.numindiv= i_numindiv
                  AND pa2.numporte in (28,29)
                  AND pa2.transmis = 1
                  )
      ;

      IF nb_distinct_mvt > 1 THEN       -- oui on a un mouvement de création ou de modification transmis pour l'individu
        RETURN F_OPE_SUPCRE();
      ELSE   --non alors on supprime l'individu
        RETURN   F_OPE_SUP();
      END IF;

  ELSIF nvl(loc_tous_egaux,'C') = 'C' THEN   --Tous les mouvements sont des créations?
      --  Tous les derniers mouvements transmis sont des suppressions?
    BEGIN
     select distinct mouvement
      INTO  loc_tous_supp
      FROM porte_adhesion  pa
      WHERE pa.numindiv = i_numindiv
      AND pa.NUMPORTE in (28,29)
      AND pa.TRANSMIS = 1
      AND NOT EXISTS (SELECT 1      -- on prend le dernier mouvement transmis
                  FROM porte_adhesion  pa2
                  WHERE pa2.idporte > pa.idporte
                  AND pa2.idadhesion = pa.idadhesion
                  AND pa2.numporte in (28,29)
                  AND pa2.transmis = 1
                  )
      ;

      IF loc_tous_supp ='S' THEN -- on n'a envoyé de que la suppression en dernier
        RETURN F_OPE_CRE();
      ELSE   --on a de la création ou de la mise a jour alors on met a jour
        RETURN   F_OPE_SUPCRE();
      END IF;

    EXCEPTION
      WHEN no_data_found  THEN  -- si on a aucun mouvement tranmis au prealable alors c'est une création d'individu
        RETURN  F_OPE_CRE();
      WHEN  OTHERS THEN
      -- on a plusieurs type de mouvement envoyé donc on met a jour
      return F_OPE_SUPCRE();
    END;

  ELSIF   loc_tous_egaux = 'M' THEN   --si on a que de la modification alors on envoi de la modif
    RETURN F_OPE_SUPCRE();

  END IF;   */

  END f_get_mouvement_salarier;


   -- retourne 0 => cre
  -- retourne 1 => sup
  -- retourne 2 => supcre (mise à jour)
  FUNCTION f_get_mouvement_adhesion(i_idadhesion number) RETURN VARCHAR2
  IS
  o_mouvement VARCHAR2(1);
  l_current_mouvement_adhesion VARCHAR2(1);
  BEGIN
      BEGIN
      SELECT mouvement
      INTO  l_current_mouvement_adhesion
      FROM porte_adhesion
      WHERE idadhesion = i_idadhesion
      AND NUMPORTE in (28,29)
      AND TRANSMIS  = 1
      ORDER BY idporte DESC
      FETCH FIRST 1 ROWS ONLY;

      IF l_current_mouvement_adhesion in(F_OPE_CRE,F_OPE_SUPCRE) THEN
          return F_OPE_SUPCRE;
      ELSE
          return F_OPE_CRE;
      END IF;


     EXCEPTION WHEN OTHERS THEN

     RETURN F_OPE_CRE; -- aucun mouvement n'existe sur l'individu on fait une opération CRE
     END;
  END f_get_mouvement_adhesion;



  /**************************** procédure privée *********/
      function f_sel_next_idporte return number
     IS
     o_idporte number;
     BEGIN
     -- c'est historique on a pas de sequence pour porte_adhesion .... #tristesse
        SELECT NVL (MAX (idporte), 0) + 1
          INTO o_idporte
          FROM porte_adhesion;
        return   o_idporte;
     END f_sel_next_idporte;


   FUNCTION f_trancod_mouvement_ope(mouvement varchar2) return varchar2
   IS
    o_retour VARCHAR2(8);
   BEGIN
     select decode(mouvement,'C','CRE'
                             ,'S', 'SUP',
                              'M','SUPCRE', null)
      INTO o_retour FROM DUAL;

      return o_retour;
   END;


     ---------------------------------------------------------------------------------------------------------------
     ---------------------------------------------------------------------------------------------------------------
     -------------------------------------------CONSTRUCTION XML----------------------------------------------------
     ---------------------------------------------------------------------------------------------------------------
     ---------------------------------------------------------------------------------------------------------------
     FUNCTION F_GETXML_ENTREPRISE(i_numIndiv IN individu.numindiv%TYPE) RETURN XMLTYPE
          IS
              -- initialiser les variables
              loc_Reponse         XMLTYPE;
              loc_path_courant    VARCHAR2(200):= NULL;
              loc_siret pers_morale.siret%type;
          BEGIN
              BEGIN
                select SUBSTR(siret,1,14)
                into loc_siret
                from pers_morale
                where numindiv =    i_numIndiv;

              EXCEPTION WHEN OTHERS THEN loc_siret :=null;
              END;
              loc_Reponse := XMLTYPE('<Entreprise '||g_xmlns||' '||f_get_mouvement_entreprise(i_numIndiv)||'></Entreprise>');           --f_trancod_mouvement_ope(f_get_mouvement_entreprise)
              loc_path_courant :='Entreprise';
              loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>g_xmlns, path=>loc_path_courant, children=>'Identite', child_val => loc_siret);
              loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>g_xmlns, path=>loc_path_courant, children=>'RaisonSociale', child_val=> replace (pk_personne.f_nom(i_numIndiv),'&','&'||'amp;'));

              RETURN loc_Reponse;

          EXCEPTION
              WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_line(SQLERRM);

              RETURN NULL;
      END;

      FUNCTION F_GETXML_SALARIE(i_date_mouvement IN date, i_idporte number) RETURN XMLTYPE
          IS
              -- initialiser les variables
              loc_Reponse         XMLTYPE;
              loc_path_courant    VARCHAR2(200):= NULL;
              v_nom varchar2(50);
              v_prenom varchar2(50);
              v_n_insee varchar2(50);
              v_mvt varchar2(50);
              v_numindiv number(9);
          BEGIN
            select i.numindiv , nom,  prenom,  substr(nvl(n_insee,matorg),1,13)
            into    v_numindiv, v_nom,v_prenom, v_n_insee
            from individu i, porte_adhesion pa
            where pa.idporte = i_idporte
            and i.numindiv= pa.numindiv;

              loc_Reponse := XMLTYPE('<Salarie '||g_xmlns||' '||f_get_mouvement_salarier(i_date_mouvement, v_numindiv)||'></Salarie>');
              loc_path_courant :='Salarie';
              loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>g_xmlns, path=>loc_path_courant, children=>'NIR', child_val => v_n_insee);
              loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>g_xmlns, path=>loc_path_courant, children=>'Nom', child_val=> v_nom);
              loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>g_xmlns, path=>loc_path_courant, children=>'Prenom', child_val=>v_prenom);
              RETURN loc_Reponse;

          EXCEPTION
              WHEN OTHERS THEN
              RETURN NULL;
      END F_GETXML_SALARIE;

      FUNCTION F_GETXML_PREVOYANCE(i_idporte IN porte_adhesion.idporte%TYPE) RETURN XMLTYPE
          IS
              -- initialiser les variables
              loc_Reponse         XMLTYPE;
              loc_path_courant    VARCHAR2(200):= NULL;
              v_date_deb date;
              v_date_fin date;
              --v_date_debutRetro date;
              v_idCouverture number(15);
              v_mouvement varchar2(10);
              l_xmlns           VARCHAR2(50) := 'urn:.cnamts:tlsemp:GESTIP';


          BEGIN


              SELECT xmlagg(XMLELEMENT("Prevoyance",
                              XMLATTRIBUTES(l_xmlns       AS "xmlns",
                                             PK_PREV_GESTIP.f_trancod_mouvement_ope(pa.mouvement)      AS "Operation",
                                            idCouverture    AS "IdCouverture")
                            ,XMLELEMENT("DateDebut",datapli)
                             -- si mouvement différent de SUP on prend la date saisie dans porte_adhesion
                            ,CASE when nvl(pa.fin,datper) is not null
                                  then XMLELEMENT("DateFin",nvl(pa.fin,datper))
                                  else null end if,
                             -- si le mouvement est différent de SUP et sur une adhesion franchisée,
                             -- alors on passe la date de rétrocession.
                             CASE when pa.type = G_type_mvt_franchise
                                  then XMLELEMENT("DateDebutRetro",pa.debut)
                                  else null end if
                            ,XMLELEMENT("TypePE",'IJ'))
                            )
                INTO loc_Reponse
                FROM adhesion a, -- une ligne = une adhesion d'un individu unique pour un idadhesion
                     porte_adhesion pa,
                     garanties g
                WHERE a.idadhesion = pa.idadhesion
                  AND pa.idporte = i_idporte
                  AND a.numfor = g.numfor
                  -- les suppressions sont gérées exclusivement au niveau Salarie
                  AND pa.mouvement <> F_OPE_SUP
                  AND g.NAT_RISQ IN(SELECT code FROM libelle WHERE mnemo='GESTIP_R' AND code > 0) -- incapacité de travail specifique au client;
                ;
               RETURN loc_Reponse;

          /*EXCEPTION
              WHEN OTHERS THEN
              RETURN NULL;  */

      END F_GETXML_PREVOYANCE;

  FUNCTION F_GENERER_CORPS_GESTIP(
            i_date_mouvement IN date
          , i_num_remise IN NUMBER
          , i_adresse_document IN VARCHAR2
          , i_concentrateur t_conc
          , io_journal IN OUT journal_adm%rowtype
          )RETURN XMLTYPE
      IS
          -- initialiser les variables
          loc_salarie         XMLTYPE;
          loc_entreprise      XMLTYPE;
          loc_gestip          XMLTYPE;
          loc_path_courant    VARCHAR2(200):= NULL;
           -- Entreprise
          CURSOR c_xml_entreprise IS
              select
                  f_getxml_entreprise(soc.numindiv) as XMLT,
                  soc.numindiv as numindiv
              from    porte_adhesion pa, -- table de mouvement
                      adhe_cntrt     ac, -- une ligne = une adhesion d'un individu unique pour un idadhesion
                      adhesion       a , -- couverture plusieurs pour 1 idadhesion
                      contrat        c , -- table du contrat qui contient  le
                      pers_organisme po,
                      individu       soc

              where pa.numindiv = ac.numadhe
              and pa.idadhesion = ac.idadhesion
              and a.numindiv    = ac.numadhe
              and pa.numporte in (28,29)
              and ac.idadhesion = a.idadhesion
              and ac.NUMGAR     = c.NUMGAR
              and c.NUMCLI      = soc.numindiv
              AND NUMREMISE     = 0
              AND C.numorg      = po.numorg  -- jointure sur l'assureur pour récuperer le concentrateur
              AND po.ENTETE3    = i_concentrateur.entete3
              AND TRANSMIS      = 2
              group by soc.numindiv;
          -- salariers
          CURSOR c_xml_salarie(i_numIndiv in individu.numindiv%type) IS
          select
                        f_getxml_salarie(i_date_mouvement, pa.idporte) as XMLT
                        ,i.numindiv as numindiv, i.nom as nom, i.prenom as prenom, i.n_insee as n_insee, pa.idporte as idporte
                  from    porte_adhesion pa, -- table de mouvement
                          adhe_cntrt ac, -- une ligne = une adhesion d'un individu unique pour un idadhesion
                          adhesion a , -- couverture plusieurs pour 1 idadhesion
                          contrat c,  -- table du contrat qui contient  le
                          pers_organisme po,
                          pers_morale p,
                          individu i,
                          individu soc
                  where
                  pa.numindiv = ac.numadhe
                  and pa.numindiv = i.numindiv
                  and pa.numporte in (28,29)
                  and pa.idadhesion  = ac.idadhesion
                  and ac.idadhesion = a.idadhesion
                  and ac.NUMGAR = c.NUMGAR
                  and c.NUMCLI = p.numindiv
                  and c.NUMCLI = soc.numindiv
                  and c.NUMCLI = soc.numindiv
                  AND C.numorg = po.numorg  -- jointure sur l'assureur pour récuperer le concentrateur
                  AND po.ENTETE3 = i_concentrateur.entete3
                  AND NUMREMISE = 0
                  AND TRANSMIS=2
                  and soc.numindiv= i_numIndiv
                  group by i.numindiv, i.nom, i.prenom, i.n_insee,pa.idporte;

      xml_entreprise c_xml_entreprise%ROWTYPE;
      xml_salarie c_xml_salarie%ROWTYPE;
      BEGIN

        loc_gestip := XMLTYPE('<GESTIP xmlns="urn:.cnamts:tlsemp:GESTIP" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" Version="02.00" Nature="GESTIP" xsi:schemaLocation="urn:.cnamts:tlsemp:GESTIP ROOT_GESTIP_V02_01.xsd"></GESTIP>');
        loc_path_courant :='GESTIP';
        loc_gestip := pk_xml.APPENDCHILD(doc=>loc_gestip, xmlns=>g_xmlns, path=>loc_path_courant, children=>'Identification', child_val => i_adresse_document||'002');
        loc_gestip := pk_xml.APPENDCHILD(doc=>loc_gestip, xmlns=>g_xmlns, path=>loc_path_courant, children=>'Temps', child_val=> TO_CHAR(sysdate,'YYYY-MM-DD"T"HH24:MI:SS"Z"'));
        loc_gestip := pk_xml.APPENDCHILD(doc=>loc_gestip, xmlns=>g_xmlns, path=>loc_path_courant, children=>'Fonction', child_val=>'9');
        loc_gestip := pk_xml.APPENDCHILD(doc=>loc_gestip, xmlns=>g_xmlns, path=>loc_path_courant, children=>'IP', child_val=>'');
        loc_path_courant := 'GESTIP/IP';
        loc_gestip := pk_xml.APPENDCHILD(doc=>loc_gestip, xmlns=>g_xmlns, path=>loc_path_courant, children=>'Identite', child_val=>i_concentrateur.code);
        loc_gestip := pk_xml.APPENDCHILD(doc=>loc_gestip, xmlns=>g_xmlns, path=>loc_path_courant, children=>'Denomination', child_val=>pk_personne.f_nom(1));

        FOR xml_entreprise IN  c_xml_entreprise LOOP
         p_ins_journal( 3,io_journal, 'Entreprise : '||xml_entreprise.numindiv);
          loc_entreprise :=xml_entreprise.XMLT;
          FOR  xml_salarie IN c_xml_salarie(xml_entreprise.numindiv) LOOP
              p_ins_journal( 3,io_journal, 'Salarié : '||xml_salarie.numindiv);
              loc_path_courant := 'Salarie';
              loc_salarie := pk_xml.APPENDCHILDXML(doc=>xml_salarie.XMLT, xmlns=>g_xmlns, path=>loc_path_courant, children=>'Prevoyance', child_val=>f_getxml_prevoyance(xml_salarie.idporte));

              loc_path_courant := 'Entreprise';
              loc_entreprise := pk_xml.APPENDCHILDXML(doc=>loc_entreprise, xmlns=>g_xmlns, path=>loc_path_courant, children=>'Salarie', child_val=>loc_salarie);

              P_TAG_PORTE_ADHESION (xml_salarie.idporte, i_num_remise);
          END LOOP;

          loc_path_courant := 'GESTIP/IP';
          loc_gestip := pk_xml.APPENDCHILDXML(doc=>loc_gestip, xmlns=>g_xmlns, path=>loc_path_courant, children=>'Entreprise', child_val=>loc_entreprise);

        END LOOP;
              --commit;

           -- Dbms_xslprocessor.CLOB2FILE(cl => loc_gestip.getClobVal() , flocation => 'EXPORT', fname => 'TD-GESTIP-.xml');
          RETURN  loc_gestip;
      END F_GENERER_CORPS_GESTIP;

      FUNCTION F_GENERER_ENT_GESTIP(i_num_remise IN NUMBER,  i_adresse_document IN VARCHAR2, i_concentrateur t_conc , io_journal IN OUT journal_adm%rowtype) RETURN XMLTYPE
          IS
          loc_entete_gestip   XMLTYPE;
          loc_path_courant    VARCHAR2(200):= NULL;
          loc_xmlns           VARCHAR2(50) := 'xmlns="urn:cnamts:tlsemp:ENTGESTIP"';
          i_siret             pers_morale.siret%TYPE;
          loc_temps           VARCHAR2(50);

      BEGIN
         -- execute immediate('ALTER SESSION SET nls_numeric_characters = ''.,''');
          loc_temps := TO_CHAR(sysdate,'YYYY-MM-DD"T"HH24:MI:SS"Z"');


          loc_entete_gestip:= XMLTYPE('<Entete xmlns="urn:cnamts:tlsemp:ENTGESTIP"
                                                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                                                  PGMD_Profil="ENTGESTIP"
                                                  Profil_Version="02.00"
                                                  xsi:schemaLocation="urn:cnamts:tlsemp:ENTGESTIP ROOT_ENTGESTIP_V02_00.xsd">
                                              </Entete>');
          loc_path_courant :='Entete';
          loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Identification', child_val => i_adresse_document||'001');

          loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Temps', child_val=>loc_temps);
          loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Fonction', child_val=>'9');
          loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Info', child_val=>F_GET_CLE_ACCES(i_concentrateur.code));

          loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Emetteur');
              loc_path_courant :='Entete/Emetteur';
              loc_entete_gestip := pk_xml.APPENDCHILDXML(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Identite', child_val=>XMLTYPE('<Identite '||loc_xmlns||' R="SIRET">'||i_concentrateur.SIRET||'</Identite>'));
              loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Qualite', child_val=>'OPEDI');

          loc_path_courant :='Entete';
          loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Recepteur');
          loc_path_courant :='Entete/Recepteur';
              loc_entete_gestip := pk_xml.APPENDCHILDXML(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Identite', child_val=>XMLTYPE('<Identite '||loc_xmlns||' R="ORGIR">'||'010000000'||'</Identite>')); --Valeurs fixes pour la CNAMTS.
              loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Qualite', child_val=>'ACNAM');

          loc_path_courant :='Entete';
          loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Document');
              loc_path_courant :='Entete/Document';
              loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Mindex');
                  loc_path_courant :='Entete/Document/Mindex';
                  loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Profil', child_val=>'GESTIP');
                  loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Identification', child_val=>i_adresse_document||'002');
                  loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Temps', child_val=>loc_temps);
                  loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Fonction', child_val=>'9');
              loc_path_courant :='Entete/Document';
              loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Lien');
              loc_path_courant :='Entete/Document/Lien';
                  loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Adresse', child_val=>'D-GESTIP-'||i_adresse_document||'002'||'.xml');
                  loc_entete_gestip := pk_xml.APPENDCHILD(doc=>loc_entete_gestip, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'Type', child_val=>'XML');

             RETURN   loc_entete_gestip;

    EXCEPTION
    WHEN OTHERS THEN
    p_ins_journal(1,io_journal, 'Génération entête impossible ');
    p_ins_journal(1,io_journal, 'Err : '||sqlerrm);
    RETURN   loc_entete_gestip;
END F_GENERER_ENT_GESTIP;


FUNCTION F_XMLSERIALIZE(  xmldoc IN XMLTYPE ) RETURN CLOB
   IS
    o_retour CLOB;
   BEGIN
     select '<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>' || chr(10) ||
             XMLSerialize(DOCUMENT xmldoc AS CLOB INDENT SIZE=2 )
      INTO o_retour FROM DUAL;
      return o_retour;
END F_XMLSERIALIZE;

  PROCEDURE P_GENERER_FICHIER(
      i_date_mouvement IN date,
      i_num_remise IN NUMBER,
      i_concentrateur t_conc,
      io_journal in out journal_adm%rowtype)
  IS
    v_zip BLOB;
    nom_doc VARCHAR2(25);
    loc_corps_gestip xmltype;
    loc_ent_gestip xmltype;
    loc_xsd_corps xmltype;
    loc_xsd_entete xmltype;
    test_valide NUMBER :=1;

  BEGIN
    nom_doc :=i_concentrateur.code||'-'||F_GET_DATE;--17caractères

    loc_ent_gestip  :=F_GENERER_ENT_GESTIP(i_num_remise, nom_doc, i_concentrateur,io_journal) ;
    loc_corps_gestip:=F_GENERER_CORPS_GESTIP(i_date_mouvement,i_num_remise, nom_doc,i_concentrateur, io_journal);
 --      Dbms_xslprocessor.CLOB2FILE(cl => F_XMLSERIALIZE( loc_corps_gestip),
 --                                  flocation => 'EXPORT',
 --                                  fname => 'D-GESTIP-'||nom_doc||'002'||'.xml',
 --                                  csid => nls_charset_id('we8iso8859p1'));
   --on ne peut pas valider l'entete à cause du dateTime ==> Ajout du namespace spécifique Oracle dans les xsd
   --          xmlns:xdb="http://xmlns.oracle.com/xdb"
   --   et  ajout de l'annotation xdb:SQLType="TIMESTAMP WITH TIME ZONE"  pour les types dateTime
   --  => toujours insuffisant : désactivation contrôle XSD
  /*  loc_xsd_entete   :=loc_ent_gestip.createSchemaBasedXML('ROOT_ENTGESTIP_V02_00.xsd');
    test_valide     :=loc_ent_gestip.isschemavalid('ROOT_GESTIP_V02_00.xsd');
    IF test_valide   <>1 THEN
      BEGIN
        xmltype.schemaValidate(loc_xsd_entete);
      EXCEPTION
        WHEN OTHERS THEN
          p_ins_journal( 1,io_journal, SUBSTR('Erreur de validation XSD ENTETE: '||sqlerrm,1,132));
          p_ins_journal(1,io_journal, SUBSTR('Erreur de validation XSD ENTETE:'||sqlerrm,133,132)); -- Ecriture du message d'erreur sur 2 lignes
          RAISE exc_schema_xml_invalide;
      END;
    END IF;

    loc_xsd_corps   :=loc_corps_gestip.createSchemaBasedXML('ROOT_GESTIP_V02_01.xsd');
    test_valide     :=loc_corps_gestip.isschemavalid('ROOT_GESTIP_V02_01.xsd');
    IF test_valide   <>1 THEN
    BEGIN
      xmltype.schemaValidate(loc_xsd_corps);
    EXCEPTION
      WHEN OTHERS THEN
        p_ins_journal( 1,io_journal, SUBSTR('Erreur de validation XSD CORPS: '||sqlerrm,1,132));
        p_ins_journal(1,io_journal, SUBSTR('Erreur de validation XSD CORPS:'||sqlerrm,133,132)); -- Ecriture du message d'erreur sur 2 lignes
        RAISE exc_schema_xml_invalide;
    END;

     END IF; */

    PK_AS_ZIP.Add1File(v_zip, 'E-ENTGESTIP-'||nom_doc||'001'||'.xml', PK_PREV_GESTIP.CLOB2BLOB(F_XMLSERIALIZE(loc_ent_gestip)));
    PK_AS_ZIP.Add1File(v_zip, 'D-GESTIP-'||nom_doc||'002'||'.xml', PK_PREV_GESTIP.CLOB2BLOB(F_XMLSERIALIZE(loc_corps_gestip)));
    PK_AS_ZIP.Finish_Zip(v_zip);
    PK_AS_ZIP.Save_Zip(v_zip, 'DIR_XML_GESTIP', replace(nom_doc,'-','')||'.zip' );
    PK_AS_ZIP.Save_Zip(v_zip, 'DIR_HISTO_GESTIP', replace(nom_doc,'-','')||'.zip' );
    p_ins_journal(1,io_journal, 'Génération du zip:'||replace(nom_doc||'000','-','')||'.zip effectuée'); -- Ecriture du message d'erreur sur 2 lignes

 --pas mettre de when other
  END P_GENERER_FICHIER;

  FUNCTION F_GET_DATE RETURN VARCHAR2
  IS
  BEGIN
   RETURN TO_CHAR(SYSDATE, 'yyyymmddHH24MIss');--||TO_CHAR(sysdate,'DDD');
  END;

  FUNCTION F_GET_CONCENT_ID(format number default 0, i_nomconcentrateur varchar2 default null) RETURN VARCHAR2
  IS
      ctip varchar2(25);
  BEGIN
      -- TODO Si besoin creer une liste avec les différent id selone les concentrateur   avec i_nomconcentrateur
      -- sinon laisser la version sur le paramètrage du fichier
      SELECT param1
      INTO ctip
      FROM param_batch
      WHERE numbatch = 'PJT1T';

      IF format = 1 THEN
          RETURN ctip;
      ELSE
          RETURN SUBSTR(ctip,2);
      END IF;
    EXCEPTION WHEN OTHERS THEN return '000';
  END F_GET_CONCENT_ID;

   FUNCTION f_get_SIRET_CONCENT(i_concentrateur individu.nom%type) RETURN NUMBER IS
   l_siret varchar(30);
   io_journal journal_adm%rowtype :=f_get_journal(null);
   BEGIN
     SELECT pe.siret
      INTO l_siret
      FROM pers_morale pe, individu i
      where i.numindiv = pe.numindiv
      and i.nom = i_concentrateur
      ;
      return l_siret;

      EXCEPTION WHEN OTHERS THEN
      p_ins_journal(1,io_journal, 'Récuperation du Siret concenrateur'||sqlerrm);
   END f_get_SIRET_CONCENT;

  FUNCTION F_GET_CLE_ACCES (i_code libelle_bis.code%TYPE) RETURN VARCHAR2
  IS
      cle_acces varchar2(25);
  BEGIN
    IF F_GET_INSTANCE in ('GEREPP', 'SMIP') THEN
      select libelle into cle_acces from libelle_bis WHERE mnemo ='GESTIP_K'
      AND code = i_code;

      RETURN cle_acces;
    ELSE
        return 'CLEFICTIVE';
     END IF;
    EXCEPTION
      WHEN OTHERS THEN return '000';
  END;

  PROCEDURE P_TAG_PORTE_ADHESION(p_idporte number,
                                  p_numrerise number)
  IS
  BEGIN

    UPDATE PORTE_ADHESION
     SET  TRANSMIS = 1,
          NUMREMISE = p_numrerise
     WHERE  idporte = p_idporte
      AND   transmis=2 ;

  END P_TAG_PORTE_ADHESION;

  -------------------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------Procédure de forcage-----------------------------------------------------------
  -------------------------------------------------------------------------------------------------------------------------------------
  -- p_creer_mouvement_contrat permet de generer un mouvement GESTIP
  --             soit sur tous les adhérents couverts pour les contrats ouverts à la porte 29.
  --             soit sur tous les sinistres ouverts pour les contrats ouverts à la porte 28.
  --
  -- Prend en paramètre un contrat, ouvert sur la porte 28 ou 29.
  -- et un mouvement particulier (pk_PREV_GESTIP.g_OPE_CRE, pk_PREV_GESTIP.g_OPE_SUP, pk_PREV_GESTIP.g_OPE_CRE_SUP)
  PROCEDURE P_CREER_MOUVEMENT_CONTRAT(i_numgar number, i_mouvement varchar2) IS
   io_journal journal_adm%rowtype:= f_get_journal(null);
   loc_numporte NUMBER := 0 ;

  CURSOR c_adhesions_prev IS
    SELECT  ac.idadhesion,
            ac.numadhe,
            a.idcouverture,
            a.datapli,
            a.datper
    FROM  adhesion   a,
          adhe_cntrt ac,
          contrat    c,
          garanties  g
    WHERE a.idadhesion = ac.idadhesion
      AND a.numindiv   = ac.numadhe
      AND c.numgar     = ac.numgar
      AND c.numgar     = i_numgar
     -- AND c.type_contrat = 2
      AND a.numfor     = g.numfor
      AND g.NAT_RISQ in(select code from libelle where mnemo='GESTIP_R' and code > 0) -- incapacité de travail specifique au client
      AND trunc(sysdate) between a.datapli and trunc(nvl(a.datper,sysdate))
      AND c.numgar_ref in(select numgar from porte_contrat where numporte = 29) -- la porte29 gestip doit être ouverte pour ce contrat
     ;

  CURSOR c_sinistre_prev IS
    SELECT  sp.IDDOSSIER,
            sp.NOSIN,
            sp.survenance,
            sp.priscalc,
            r.idadhesion,
            a.datapli,
            a.datper,
            sp.creation,
            a.idcouverture,
            a.numindiv
    FROM contrat c
    INNER JOIN adhesion         a     ON a.numgar         = c.numgar
    INNER JOIN repartition      r     ON r.idadhesion     = a.idadhesion
                                    AND r.numfor          = a.numfor
    INNER JOIN repartition_bene rb    ON rb.idrepartition = r.idrepartition
    INNER JOIN sntr_prev        sp    ON sp.NOSIN         = r.NOSIN
    INNER JOIN histo_sntr_prev  histo ON histo.nosin      = sp.nosin
    INNER JOIN dossier_sinistre ds    ON ds.iddossier     = sp.iddossier
    INNER JOIN individu         i     ON i.numindiv       = ds.numindiv
    INNER JOIN garanties        g     ON g.numfor         = a.numfor
    WHERE c.numgar   = i_numgar
      -- faux AND sp.fin IS NULL => histo_sntr_prev
      AND r.valide   = 'O'
      AND rb.valide  = 'O'
      AND nvl(i.matorg, i.N_INSEE) IS NOT NULL
      AND a.numindiv = rb.NUMBENE
      AND histo.etat = 1
      AND histo.debut = (select max(h.debut) from histo_sntr_prev h where h.nosin =sp.nosin)
      AND g.NAT_RISQ in(select code from libelle where mnemo='GESTIP_R' and code > 0) -- incapacité de travail specifique au client
   ;


  BEGIN
    -- Détermination de la porte positionnée sur le contrat
    BEGIN
      SELECT MAX(pc.NUMPORTE)
      INTO loc_numporte
      FROM contrat c
      INNER JOIN porte_contrat pc
         ON  pc.NUMGAR   = c.numgar_ref
         AND pc.numporte in (28,29)
      WHERE c.numgar = i_numgar ;
    EXCEPTION
      WHEN OTHERS THEN
        loc_numporte := 0;
    END;

    IF   i_mouvement  in (pk_PREV_GESTIP.F_OPE_CRE , pk_PREV_GESTIP.F_OPE_SUP, pk_PREV_GESTIP.F_OPE_SUPCRE) THEN
      IF loc_numporte = 29 THEN
        FOR r_adhesion IN c_adhesions_prev loop
            P_insert_porte_adhesion(  i_numindiv    => r_adhesion.numadhe,
                                      i_idadhesion  => r_adhesion.IDADHESION ,
                                      i_idcouveture => r_adhesion.idcouverture ,
                                      i_mouvement   => i_mouvement,
                                      i_type        => 38,
                                      i_debut       => r_adhesion.datapli,
                                      i_datper      => r_adhesion.datper);
        END LOOP;
      ELSIF loc_numporte = 28 THEN
        FOR r_sinistre IN c_sinistre_prev loop
            P_insert_porte_adhesion(  i_numindiv    => r_sinistre.numindiv,
                                      i_idadhesion  => r_sinistre.IDADHESION ,
                                      i_idcouveture => r_sinistre.idcouverture ,
                                      i_mouvement   => i_mouvement,
                                      i_type        => 38,
                                      i_debut       => r_sinistre.survenance, --coherence retroactive
                                      i_datper      => NULL);
        END LOOP;
      ELSE
        p_ins_journal( 1,io_journal, 'Porte GESTIP indéterminée pour '||i_numgar );
      END IF;

    ELSE
        p_ins_journal( 1,io_journal, 'Le mouvement '||i_mouvement||' n''est pas autorisé');
    END IF;
  END P_CREER_MOUVEMENT_CONTRAT;

  FUNCTION F_PORTE_GESTIP RETURN NUMBER
  IS
  begin
       return 28;
  END F_PORTE_GESTIP ;
  --
    PROCEDURE P_INS_journal(
          P_niv  IN NUMBER,
          p_journal IN OUT JOURNAL_ADM%ROWTYPE,
          P_msg  IN VARCHAR2,
          p_msg2 IN VARCHAR2 default NULL)
    IS
    BEGIN

       IF nvl(p_journal.niv_msg,3)>= P_niv THEN
          p_journal.idligne := p_journal.idligne +1;
          dbms_output.put_line(P_msg||' '||P_msg2);
          PK_trace.P_INS_journal_adm ( I_nom_traitement => p_journal.nom_traitement, I_session => p_journal.id_session, I_niv_msg => P_niv, I_msg_adm => P_msg||' '||P_msg2, I_idligne => p_journal.idligne);
       END IF;
    END P_INS_journal;


     --------------------------------------------------------------------------------
  FUNCTION CLOB2BLOB(aclob CLOB) RETURN BLOB
  IS
    Result BLOB;
    o1 INTEGER;
    o2 INTEGER;
    c INTEGER;
    w INTEGER;
  BEGIN
    o1 := 1;
    o2 := 1;
    c := 0;
    w := 0;
    DBMS_LOB.CreateTemporary(Result, true);
    DBMS_LOB.ConvertToBlob(Result, AClob, length(AClob), o1, o2, 0, c, w);
    RETURN(Result);
  END CLOB2BLOB;

     --------------------------------------------------------------------------------
  FUNCTION f_get_journal(i_traitement varchar2) RETURN journal_adm%rowtype
  IS
  io_journal journal_adm%rowtype;
  BEGIN

      io_journal.id_session := sid;
      io_journal.idligne := 0;
      io_journal.nom_traitement :=nvl(i_traitement,g_nom_traitement);

      RETURN  io_journal;
  END f_get_journal;

END PK_PREV_GESTIP;
/
