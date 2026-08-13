CREATE OR REPLACE PACKAGE ARTHUS.PK_PORTE
AS
/*============================================================================*/
/* Package      : PK_PORTE.sql                                                */
/* Domaine      : PORTE                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : SDA                                                         */
/* Création     : ??/??/???                                                   */
/* Description  :                                                             */
/*              :                                                             */
/*              :                                                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :   SDA                                                       */
/* Date         :   28/11/2011                                                */
/* Commentaire  :   M3379                                                     */
/*============================================================================*/
/* Evolution    :   Ajout de la catégorie pour la gestion des centres de      */
/*                  santé dans la fonction f_carte_tp                         */
/* Auteur       :   JBO                                                       */
/* Date         :   09/10/2012                                                */
/*============================================================================*/
/* Evolution    : f_ouverte : colonne sens pour la recherche de la porte      */
/* Auteur       : JBO                                                         */
/* Date         : 27/08/2014                                                  */
/* Commentaire  : Projet P201407002_P201203001_Tiers_Payant_Hospitalier_GEREP */
/*============================================================================*/
/*Correction   : PHA / 23/08/2016 / utilisation trigger en 11G : plus besoin  */
/*               des vues matérialisées                                       */
/*============================================================================*/
/* Evolution    : P_DMNDE_CONTRAT_MASSIF : ajout produitDebut, produitFin     */
/* Auteur       : JBO                                                         */
/* Date         : 06/11/2017                                                  */
/* Commentaire  : Projet P201709001_EA_Adhesion_Ind_GEREP                     */
/*============================================================================*/

  TYPE TAB_Cond IS TABLE OF VARCHAR2(200) INDEX BY  BINARY_INTEGER;

--
-- Test si la porte est ouverte
--@pub
   FUNCTION f_ouverte (
      i_numporte    IN   parporte.numporte%TYPE,
      i_numreg      IN   parporte.numreg%TYPE,
      i_numsoc      IN   parporte.numsoc%TYPE,
      i_numorg      IN   parporte.numorg%TYPE,
      i_numcaisse   IN   parporte.numcaisse%TYPE
   )
      RETURN BOOLEAN;

--
-- Recherche de l'ouvreur de droits
--
   FUNCTION f_ouvreur_de_droits (i_matorg IN individu.matorg%TYPE)
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (f_ouvreur_de_droits, WNDS, WNPS);

--
-- Test si la prestation est couverte par une carte TP
--

FUNCTION f_carte_tp (
   i_numindiv     IN   individu.numindiv%TYPE,
   i_codfrais     IN   natfrais.codfrais%TYPE,
   i_datsin       IN   DATE,
   i_idadhesion   IN   adhe_cntrt.idadhesion%TYPE DEFAULT 0,
   i_numporte     IN   porte_param.numporte%TYPE DEFAULT NULL,
   i_categorie    IN   acte_tp.categorie%TYPE DEFAULT NULL,
   i_TAB_Cond     IN   TAB_Cond
)
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (f_carte_tp, WNDS, WNPS);

--
-- Insere une demande de carte Tiers payant
--
   PROCEDURE p_ins_demande_tp (
      i_numporte     IN   param_tiers_payant.numporte%TYPE,
      i_idadhesion   IN   porte_adhesion.idadhesion%TYPE,
      i_numgar       IN   param_tiers_payant.numgar%TYPE,
      i_numindiv     IN   porte_adhesion.numindiv%TYPE,
      i_debut        IN   DATE,
      i_fin          IN   DATE DEFAULT NULL,
      i_type         IN   porte_adhesion.TYPE%TYPE,
      i_numfor       IN   NUMBER DEFAULT NULL,
      i_fin_ayd      IN   DATE DEFAULT NULL
   );

--
-- Demande Tiers payant massive
--
  PROCEDURE p_dmnde_contrat_massif( i_traitement   IN  JOURNAL_ADM.NOM_TRAITEMENT%TYPE,
                                    i_numporte     IN  param_tiers_payant.numporte%TYPE,
                                    i_numprodDeb   IN  contrat_ref.numprod%TYPE,
                                    i_numprodFin   IN  contrat_ref.numprod%TYPE,
                                    i_numgarDeb    IN  param_tiers_payant.numgar%TYPE,
                                    i_numgarFin    IN  param_tiers_payant.numgar%TYPE,
                                    i_numcli       IN  contrat.numcli%TYPE,
                                    i_carte        IN  param_tiers_payant.code_lettre%TYPE,
                                    i_debut        IN  DATE,
                                    i_session      IN  NUMBER DEFAULT 1,
                                    i_niv_msg      IN  NUMBER DEFAULT 1,
                                    o_found        OUT NUMBER,
                                    o_erreur       OUT VARCHAR2
                                    );

--
-- Demande Tiers payant globale contrat
--
   PROCEDURE p_dmnde_contrat (
      i_numporte     IN       param_tiers_payant.numporte%TYPE,
      i_numgar       IN       param_tiers_payant.numgar%TYPE,
      i_debut        IN       DATE,
      o_nb_demande   OUT      NUMBER
   );

--
-- Demande Tiers payant automatise adhesion
--
   PROCEDURE p_dmnde_renouv (
      i_numporte      IN       param_tiers_payant.numporte%TYPE,
      i_deb_contrat   IN       porte_contrat.numgar%TYPE,
      i_fin_contrat   IN       porte_contrat.numgar%TYPE,
      o_nb_demande    OUT      NUMBER
   );

--
-- Gestion des anomalies
--
   PROCEDURE p_gest_ano (
      i_numindiv   IN       individu.numindiv%TYPE,
      i_numassu    IN       individu.numassu%TYPE,
      i_matorg     IN       individu.matorg%TYPE,
      i_cless      IN       individu.cless%TYPE,
      i_datnais    IN       individu.datnais%TYPE,
      i_regime     IN       individu.regime%TYPE,
      i_caisse     IN       individu.caisse%TYPE,
      i_rang       IN       individu.rang%TYPE,
      i_idporte    IN       porte_adhesion.idporte%TYPE,
      o_type_ano   OUT      NUMBER
   );

--
-- Recherche de l'idparam_tp
--
   FUNCTION f_sel_idparam_tp (
      i_numgar   IN   gar_param_tp.numgar%TYPE,
      i_numfor   IN   gar_param_tp.numfor%TYPE
   )
      RETURN NUMBER;


  PROCEDURE P_INS_journal(i_niv in NUMBER,
                          i_msg in VARCHAR2,
                          i_msg2 in varchar2 := null
                         );


-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_PORTE
AS
/*============================================================================*/
/* Package      : PK_PORTE.sql                                                */
/* Domaine      : PORTE                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : SDA                                                         */
/* Création     : ??/??/???                                                   */
/* Description  :                                                             */
/*              :                                                             */
/*              :                                                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :   SDA                                                       */
/* Date         :   28/11/2011                                                */
/* Commentaire  :   M3379                                                     */
/*============================================================================*/
/* Evolution    :   Ajout de la catégorie pour la gestion des centres de      */
/*                  santé dans la fonction f_carte_tp                         */
/* Auteur       :   JBO                                                       */
/* Date         :   09/10/2012                                                */
/*============================================================================*/
/* Evolution    : f_ouverte : colonne sens pour la recherche de la porte      */
/* Auteur       : JBO                                                         */
/* Date         : 27/08/2014                                                  */
/* Commentaire  : Projet P201407002_P201203001_Tiers_Payant_Hospitalier_GEREP */
/*============================================================================*/
/*Correction   : trigramme / date / commentaire                               */
/*============================================================================*/

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
--@glob
-- Parametres de la demande Tiers payant
   g_numporte     param_tiers_payant.numporte%TYPE;
   g_idadhesion   porte_adhesion.idadhesion%TYPE;
   g_numgar       param_tiers_payant.numgar%TYPE;
   g_numindiv     porte_adhesion.numindiv%TYPE;
   g_numindiv_init      porte_adhesion.numindiv%TYPE;
   g_numindiv_adhesion	adhesion.numindiv%TYPE;
   g_debut        DATE;
   g_type         porte_adhesion.TYPE%TYPE;
   g_numfor       adhesion.numfor%TYPE;
   g_debval       DATE;         -- date de debut de validite de l'attestation
   g_finval       DATE;         -- date de fin de validite de l'attestation
   g_ad_sans_od   BOOLEAN                              := FALSE;
--
-- Infos assures
--
   g_numassu      individu.numassu%TYPE;
   g_matorg       individu.matorg%TYPE;
   g_cless        individu.cless%TYPE;
   g_datnais      individu.datnais%TYPE;
   g_regime       individu.regime%TYPE;
   g_caisse       individu.caisse%TYPE;
   g_rang         individu.rang%TYPE;
   g_codpos       pers_adresse.codpos%TYPE;
--
-- Informations porte
--
   g_idparam_tp   param_tiers_payant.idparam_tp%TYPE;
   g_fract        param_tiers_payant.period%TYPE;
   g_renouv       param_tiers_payant.renouv%TYPE;
--
-- Infos contrat
--
   g_eche_anniv   contrat.eche_anniv%TYPE;
   g_numsoc       contrat.numinterm%TYPE;
   g_numorg       contrat.numorg%TYPE;
--
-- Infos porte_adhesion
--
   g_fin          DATE;
   g_idporte      porte_adhesion.idporte%TYPE;
   g_nb_demande   NUMBER                               := 0;


    -- Variables de P_INS_journal
    G_nom_traitement  journal_adm.nom_traitement%TYPE;--  'SP07T';
    G_niv_msg         journal_adm.niv_msg%TYPE;
    G_idligne         journal_adm.idligne%TYPE;
    G_session         journal_adm.id_session%TYPE;
    g_msg_adm         journal_adm.msg_adm%TYPE;

-- -------------------------------------- Fin des variables globales privees --

   -- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--@priv
-- Recherche de l'ouvreur de droits
--
   PROCEDURE p_sel_ouvreur_de_droit (o_found OUT BOOLEAN);

--
-- Infos porte
--
   PROCEDURE p_sel_param_tp (o_found OUT BOOLEAN);

--
-- Infos contrat
--
   PROCEDURE p_sel_contrat;

--
-- Determination de la validite de l'attestation
--
   PROCEDURE p_sel_validite;

--
-- Insertion dans porte_adhesion et demande_tp de l'ouvreur de droits
--
   PROCEDURE p_ins_porte_adhesion;

--
-- Insertion dans demande_tp_ad des ayant-droits rattaches
--
      PROCEDURE p_ins_demande_tp_ad ( i_fin_ayd      IN   DATE DEFAULT NULL);

--
-- Recherche du code postal de la caisse
--
   PROCEDURE p_sel_codpos;

--
-- Test s'il existe un code blocage transmission
--
   FUNCTION f_test_blocage
      RETURN BOOLEAN;

--CTT 20/10/06
-- Teste si le contrat est parametre 'Toutes garanties'
--
   FUNCTION f_test_cntrt_global
      RETURN NUMBER;

-- ----------------------------- Fin des declarations des procedures privees --

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--
-- Test si la porte est ouverte
--@corpub
   FUNCTION f_ouverte (
      i_numporte    IN   parporte.numporte%TYPE,
      i_numreg      IN   parporte.numreg%TYPE,
      i_numsoc      IN   parporte.numsoc%TYPE,
      i_numorg      IN   parporte.numorg%TYPE,
      i_numcaisse   IN   parporte.numcaisse%TYPE
   )
      RETURN BOOLEAN
   IS
      CURSOR c_porte
      IS
         SELECT ouverte
           FROM parporte
          WHERE numporte = NVL(F_SENS_LIBELLE('PORTE',i_numporte),i_numporte)
            AND numreg = i_numreg
            AND numsoc = i_numsoc
            AND numorg = i_numorg
            AND numcaisse = i_numcaisse;

      CURSOR c_dpt
      IS
         SELECT ouverte
           FROM parporte
          WHERE numporte = NVL(F_SENS_LIBELLE('PORTE',i_numporte),i_numporte)
            AND numreg = i_numreg
            AND numsoc = i_numsoc
            AND numorg = i_numorg
            AND numdpt = SUBSTR (g_codpos, 1, LENGTH (numdpt));

      l_ouverte   parporte.ouverte%TYPE;
      l_retour    BOOLEAN                 := FALSE;
   BEGIN
      IF (i_numcaisse != 0)
      THEN
         OPEN c_porte;

         FETCH c_porte
          INTO l_ouverte;

         IF (c_porte%FOUND)
         THEN
            IF (l_ouverte = 1)
            THEN
               l_retour := TRUE;
            END IF;
         END IF;

         CLOSE c_porte;
      ELSE
         OPEN c_dpt;

         FETCH c_dpt
          INTO l_ouverte;

         IF (c_dpt%FOUND)
         THEN
            IF (l_ouverte = 1)
            THEN
               l_retour := TRUE;
            END IF;
         END IF;

         CLOSE c_dpt;
      END IF;

--
      RETURN (l_retour);
   END f_ouverte;

--
-- Recherche de l'ouvreur de droits
--
   FUNCTION f_ouvreur_de_droits (i_matorg IN individu.matorg%TYPE)
      RETURN NUMBER
   IS
      CURSOR c_ouvreur
      IS
         SELECT numindiv
           FROM individu
          WHERE matorg = i_matorg AND natur = 1;

      l_numindiv   individu.numindiv%TYPE;
   BEGIN
      OPEN c_ouvreur;

      FETCH c_ouvreur
       INTO l_numindiv;

      CLOSE c_ouvreur;

--
      RETURN (l_numindiv);
   END f_ouvreur_de_droits;

--
-- Insere une demande de carte Tiers payant
--
   PROCEDURE p_ins_demande_tp (
      i_numporte     IN   param_tiers_payant.numporte%TYPE,
      i_idadhesion   IN   porte_adhesion.idadhesion%TYPE,
      i_numgar       IN   param_tiers_payant.numgar%TYPE,
      i_numindiv     IN   porte_adhesion.numindiv%TYPE,
      i_debut        IN   DATE,
      i_fin          IN   DATE DEFAULT NULL,
      i_type         IN   porte_adhesion.TYPE%TYPE,
      i_numfor       IN   NUMBER DEFAULT NULL,
      i_fin_ayd      IN   DATE DEFAULT NULL
   )
   IS
      l_idparam   BOOLEAN;
      l_found     BOOLEAN;
      l_ouverte   BOOLEAN;

   BEGIN
--

      g_numporte := i_numporte;
      g_idadhesion := i_idadhesion;
      g_numgar := i_numgar;
      g_numindiv := i_numindiv;
      g_numindiv_init := i_numindiv; --ABO necessaire lors de la creation d'une nouvelle adhesion
      g_debut := i_debut;
      g_fin := i_fin;
      g_type := i_type;
      g_numfor := i_numfor;
      DBMS_OUTPUT.put_line ('debut couverture ' || g_debut);
      DBMS_OUTPUT.put_line ('fin couverture' || g_fin);
      P_INS_journal(2,'PK_PORTE debut couverture ' || g_debut);
      P_INS_journal(2,'PK_PORTE fin couverture ' || g_fin);

-- On recherche les infos ouvreur de droits
      p_sel_ouvreur_de_droit (o_found => l_found);

-- Si l'AD est isole de son OD, on doit le considerer comme assure principal
      IF (g_ad_sans_od)
      THEN
         g_numassu := g_numindiv;
      ELSE
         g_numindiv := g_numassu;
      END IF;



      IF (l_found)
      THEN

         -- On recherche les infos porte
         p_sel_param_tp (o_found => l_idparam);
         IF (l_idparam)
         THEN
            -- On determine la date de fin de validite
            p_sel_validite;
-- Dbms_output.put_line ( 'debut val' || G_debval);
-- Dbms_output.put_line ('fin val' || G_finval);
      -- On recherche le code postal de l'ouvreur de droit
            g_codpos := f_codpos (g_numindiv);
            -- On verifie si la porte est ouverte
            DBMS_OUTPUT.put_line (   'Numporte '
                                  || g_numporte
                                  || ' Numreg '
                                  || g_regime
                                  || ' Numsoc '
                                  || g_numsoc
                                  || ' Numorg '
                                  || g_numorg
                                  || ' Numcaisse '
                                  || g_caisse
                                 );
            P_INS_journal(1,'Numporte '
                          || g_numporte
                          || ' Numreg '
                          || g_regime
                          || ' Numsoc '
                          || g_numsoc
                          || ' Numorg '
                          || g_numorg
                          || ' Numcaisse '
                          || g_caisse);

            l_ouverte :=
               f_ouverte (i_numporte       => g_numporte,
                          i_numreg         => g_regime,
                          i_numsoc         => g_numsoc,
                          i_numorg         => g_numorg,
                          i_numcaisse      => 0
                         );
            DBMS_OUTPUT.put_line ('debut val' || g_debval);
            DBMS_OUTPUT.put_line ('fin val' || g_finval);
            P_INS_journal(2,'debut val' || g_debval);
            P_INS_journal(2,'fin val' || g_finval);
            --
            IF (l_ouverte)
            THEN
               IF (NOT f_test_blocage)
               THEN
                  -- Insertion dans porte_adhesion et demande_tp
                  DBMS_OUTPUT.put_line (   'debut val avant appel insert '
                                        || g_debval
                                       );
                  DBMS_OUTPUT.put_line (   'fin val avant appel insert '
                                        || g_finval
                                       );
                  P_INS_journal(2,'debut val avant appel insert '
                                || g_debval);
                  P_INS_journal(2,'fin val avant appel insert '
                                || g_finval);

                  -- ne pas insérer pour les types de porte 4 si l'année de début ne correspond pas à l'année de fin
                  IF NOT(f_type_porte(g_numporte) = 4 AND TO_CHAR(g_debval, 'YYYY') <> TO_CHAR(g_finval, 'YYYY'))
                  THEN
                    p_ins_porte_adhesion;
                    -- Insertion des ayant-droits
                    p_ins_demande_tp_ad(i_fin_ayd);
                  END IF;
               --
               -- NSD (-) 11-06-2007 Fiche humanis        G115 G_nb_demande := G_nb_demande + 1;
               --
               END IF;
            END IF;
         END IF;
      END IF;
   END p_ins_demande_tp;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  p_dmnde_contrat_massif                                    */
/* Type         :  Public                                                    */
/* Description  :  procedure de Demande Tiers payant globale massive pour une*/
/*                 fourchette de contrats et pour une porte donnée           */
/* Evolution    : P_DMNDE_CONTRAT_MASSIF : ajout produitDebut, produitFin    */
/* Auteur       : JBO                                                        */
/* Date         : 06/11/2017                                                 */
/* Commentaire  : Projet P201709001_EA_Adhesion_Ind_GEREP                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE p_dmnde_contrat_massif( i_traitement   IN  JOURNAL_ADM.NOM_TRAITEMENT%TYPE,
                                  i_numporte     IN  param_tiers_payant.numporte%TYPE,
                                  i_numprodDeb   IN  contrat_ref.numprod%TYPE,
                                  i_numprodFin   IN  contrat_ref.numprod%TYPE,
                                  i_numgarDeb    IN  param_tiers_payant.numgar%TYPE,
                                  i_numgarFin    IN  param_tiers_payant.numgar%TYPE,
                                  i_numcli       IN  contrat.numcli%TYPE,
                                  i_carte        IN  param_tiers_payant.code_lettre%TYPE,
                                  i_debut        IN  DATE,
                                  i_session      IN  NUMBER DEFAULT 1,
                                  i_niv_msg      IN  NUMBER DEFAULT 1,
                                  o_found        OUT NUMBER,
                                  o_erreur       OUT VARCHAR2
                                  )

IS

  loc_nb_demande                demande_tp_ad.idporte%TYPE:=0;

  CURSOR c_contrat
      IS
  SELECT DISTINCT pc.numgar, cr.numcli, pt.code_lettre
    FROM porte_contrat pc
       , contrat_ref cr
       , param_tiers_payant pt
   WHERE pc.numporte = i_numporte
     AND pk_histo_contrat.f_sel_etat (pc.numgar, i_debut) = 1
     AND(i_numgarDeb IS NULL OR ( pc.numgar BETWEEN pk_qttc.f_sel_numgar (i_numgarDeb) AND pk_qttc.f_sel_numgar (NVL(i_numgarFin,i_numgarDeb))))
     AND cr.numprod BETWEEN NVL(i_numprodDeb,cr.numprod) AND NVL((NVL(i_numprodFin,i_numprodDeb)),cr.numprod)
     AND cr.numcli=NVL(i_numcli,cr.numcli)
     AND pc.numgar=cr.numgar
     AND pt.code_lettre=NVL(i_carte,pt.code_lettre)
     AND pt.numgar=pc.numgar
     AND pt.numporte=pc.numporte
   ORDER BY pc.numgar;


  rec_c_contrat   c_contrat%ROWTYPE;
  o_nb_demande    NUMBER:=0;
  tot_nb_demande  NUMBER:=0;

  -- On recupere les infos tiers payant hospi.
  /*CURSOR c_exp_bene_tp_hospi (i_numgar porte_contrat.numgar%TYPE)
      IS
  SELECT d.idporte
    FROM individu i
       , demande_tp_ad d
       , demande_tp tp
       , param_tiers_payant pt
       , porte_adhesion pa
    --   , remise_externe r
   WHERE d.numindiv = i.numindiv
     AND pt.idparam_tp = tp.idparam_tp
     AND d.idporte = tp.idporte
     AND pa.idporte = d.idporte
     AND pa.transmis = 2
     AND pa.numremise = 0
     AND pa.numporte = i_numporte
     AND d.idporte > loc_nb_demande
     AND pt.numgar = i_numgar
   --  AND r.numremise= i_remise_exp
    -- AND r.numremise=pa.numremise
    -- AND r.valide = 'O'
   --ORDER BY pt.idparam_tp
          ;*/
  --r_exp_bene_tp_hospi         c_exp_bene_tp_hospi%ROWTYPE;

BEGIN

  -- Recupération des parametres du traitement
  G_nom_traitement:=i_traitement;
  G_niv_msg:=NULL;
  G_idligne:=0;
  G_session:=i_session;

  P_INS_journal(1,'Début du traitement <'||i_traitement||'> de demande massive attestation Tiers Payant');
  P_INS_journal(1,'Demande du produit <'||i_numprodDeb||'> au produit <'||i_numprodFin||'> pour la date de début : ' || to_char(i_debut,'dd/mm/yyyy'));
  P_INS_journal(1,'Demande du contrat <'||i_numgarDeb||'> au contrat <'||i_numgarFin||'>' );
  P_INS_journal(1,'Numéro de souscripteur <'||i_numcli||'>  pour le type de carte <'||i_carte||'> sur la porte <'||i_numporte||'>');


  -- Récupération de la derniere demande créée
  SELECT MAX(idporte)
    INTO loc_nb_demande
    FROM demande_tp_ad;

  -- Demande Tiers payant globale massive pour une fourchette de contrats et pour une porte donnée
  FOR rec_c_contrat IN c_contrat LOOP

    p_dmnde_contrat ( i_numporte ,
                      rec_c_contrat.numgar,
                      i_debut,
                      o_nb_demande);

    o_nb_demande:=0;
    SELECT count(d.idporte) INTO o_nb_demande
    FROM individu i
       , demande_tp_ad d
       , demande_tp tp
       , param_tiers_payant pt
       , porte_adhesion pa
    --   , remise_externe r
   WHERE d.numindiv = i.numindiv
     AND pt.idparam_tp = tp.idparam_tp
     AND d.idporte = tp.idporte
     AND pa.idporte = d.idporte
     AND pa.transmis = 2
     AND pa.numremise = 0
     AND pa.numporte = i_numporte
     AND d.idporte > loc_nb_demande
     AND pt.numgar = rec_c_contrat.numgar;

     tot_nb_demande:=tot_nb_demande+o_nb_demande;

     P_INS_journal(1,'Contrat : '||rec_c_contrat.numgar || ' nombre d''attestation : '||o_nb_demande );
  END LOOP;

 /* FOR r_exp_bene_tp_hospi IN c_exp_bene_tp_hospi(loc_nb_demande,rec_c_contrat.numgar) LOOP
    o_nb_demande:=o_nb_demande+1;
  END LOOP;*/

 -- o_found:=0;
 COMMIT;
  P_INS_journal(2,'o_found: '||o_found);
  P_INS_journal(1,'Nombre total de demandes générées : <'||tot_nb_demande||'> ');
  P_INS_journal(1,'Fin du traitement <'||i_traitement||'> ');

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'Fin du traitement <'||i_traitement||'> KO');
    P_INS_journal(1,SUBSTR(SQLERRM,1,132));
    o_found:=1;
    ROLLBACK;
END p_dmnde_contrat_massif;

--
-- Demande Tiers payant globale contrat
--@trav
   PROCEDURE p_dmnde_contrat (
      i_numporte     IN       param_tiers_payant.numporte%TYPE,
      i_numgar       IN       param_tiers_payant.numgar%TYPE,
      i_debut        IN       DATE,
      o_nb_demande   OUT      NUMBER
   )
   IS
      CURSOR c_test_ad_sans_od
      IS
         SELECT   indv_od.numindiv
             FROM individu indv_ayd, individu indv_od, adhesion adhe_ayd
            WHERE indv_ayd.numindiv = adhe_ayd.numindiv
              AND indv_ayd.matorg = indv_od.matorg
              AND indv_ayd.natur != 1
              AND indv_od.natur = 1
              AND indv_ayd.numindiv = g_numindiv
              AND adhe_ayd.numgar = i_numgar
              AND i_debut BETWEEN adhe_ayd.datapli
                              AND NVL (adhe_ayd.datper, i_debut)
              AND adhe_ayd.etat = 1
              AND NOT EXISTS (
                     SELECT 1
                       FROM adhesion adhe_od
                       WHERE adhe_od.numindiv = indv_od.numindiv
                       AND adhe_od.idadhesion = adhe_ayd.idadhesion
                        )
         GROUP BY indv_od.numindiv;

--
      CURSOR c_adhesion
      IS
         SELECT adhe_cntrt.idadhesion, adhesion.numfor, adhesion.numindiv
           FROM adhe_cntrt, adhesion
          WHERE adhe_cntrt.numgar = i_numgar
            AND i_debut BETWEEN adhesion.datapli
                            AND NVL (adhesion.datper, i_debut)
            AND f_etat_adhe (adhe_cntrt.idadhesion, i_debut) = 1
            AND adhe_cntrt.idadhesion = adhesion.idadhesion;

--
      CURSOR c_adherent
      IS
         SELECT   adhesion.numindiv,
                  GREATEST (MIN (adhesion.datapli), i_debut) debut,
                  adhesion.datper, individu.natur
             FROM individu, adhesion
            WHERE
              --individu.natur = 1
              --AND
              individu.numindiv = adhesion.numindiv
              AND  adhesion.idadhesion = g_idadhesion
              AND adhesion.numfor = g_numfor
              --AND adhesion.rang = 1
              AND adhesion.etat = 1
              AND i_debut BETWEEN adhesion.datapli
                              AND NVL (adhesion.datper, i_debut)
              AND adhesion.datapli !=
                                   NVL (adhesion.datper, adhesion.datapli + 1)
              AND (    NOT EXISTS (
                          SELECT 1
                            FROM porte_adhesion,
                                 adhesion,
                                 demande_tp,
                                 gar_param_tp
                           WHERE porte_adhesion.numporte = i_numporte
                             AND demande_tp.idporte = porte_adhesion.idporte
                             AND gar_param_tp.idparam_tp =
                                                         demande_tp.idparam_tp
                             AND gar_param_tp.numfor = g_numfor
                             AND porte_adhesion.numindiv = adhesion.numindiv
							 AND porte_adhesion.numindiv = g_numindiv_adhesion
                             AND adhesion.idadhesion = porte_adhesion.idadhesion
                             AND porte_adhesion.idadhesion = g_idadhesion
                             AND adhesion.numfor = g_numfor
                             AND i_debut BETWEEN porte_adhesion.debut
                                             AND NVL (porte_adhesion.fin,
                                                      i_debut
                                                     ))
                   AND NOT EXISTS (
                          SELECT 1
                            FROM porte_adhesion,
                                 adhesion,
                                 demande_tp,
                                 gar_param_tp
                           WHERE porte_adhesion.numporte = i_numporte
                             AND demande_tp.idporte = porte_adhesion.idporte
                             AND gar_param_tp.idparam_tp =
                                                         demande_tp.idparam_tp
                             AND gar_param_tp.numfor = 0
                             AND porte_adhesion.numindiv = adhesion.numindiv
							 AND porte_adhesion.numindiv = g_numindiv_adhesion
                             AND adhesion.idadhesion = porte_adhesion.idadhesion
                             AND porte_adhesion.idadhesion = g_idadhesion
                             AND i_debut BETWEEN porte_adhesion.debut
                                             AND NVL (porte_adhesion.fin,
                                                      i_debut
                                                     ))
                  )
         GROUP BY adhesion.numindiv, individu.natur, adhesion.datper;

      rec_c_adherent   c_adherent%ROWTYPE;
      ind_a_imprimer   BOOLEAN              := FALSE;
   BEGIN
--
-- NSD (+) 11-06-2007 Fiche humanis G115 (Une Adhesion represente une demande TP)
      g_nb_demande := 0;                                    -- Initialisation



--
      OPEN c_adhesion;

      LOOP
         FETCH c_adhesion
          INTO g_idadhesion, g_numfor, g_numindiv_adhesion;

         EXIT WHEN c_adhesion%NOTFOUND;
         --
         -- NSD (+) 11-06-2007 Fiche humanis G115 (Une Adhesion represente une demande TP)
         g_nb_demande := g_nb_demande + 1;

         --
         OPEN c_adherent;

         LOOP
            g_ad_sans_od := FALSE;
            ind_a_imprimer := FALSE;

            FETCH c_adherent
             INTO rec_c_adherent;

            EXIT WHEN c_adherent%NOTFOUND;
            DBMS_OUTPUT.put_line (   'Adhesion '
                                  || g_idadhesion
                                  || ' adherent '
                                  || rec_c_adherent.numindiv
                                  || ' debut '
                                  || rec_c_adherent.debut
                                 );
            P_INS_journal(2,'Adhesion '
                          || g_idadhesion
                          || ' adherent '
                          || rec_c_adherent.numindiv
                          || ' debut '
                          || rec_c_adherent.debut);

            --
            IF (rec_c_adherent.natur != 1)
            THEN
               g_numindiv := rec_c_adherent.numindiv;



               OPEN c_test_ad_sans_od;

               FETCH c_test_ad_sans_od
                INTO g_numindiv;


               IF c_test_ad_sans_od%FOUND
               THEN
                  g_ad_sans_od := TRUE;
                  ind_a_imprimer := TRUE;
               ELSE
                   g_ad_sans_od := FALSE;
                   ind_a_imprimer := TRUE;
               END IF;



               CLOSE c_test_ad_sans_od;
            ELSE
               ind_a_imprimer := TRUE;
            END IF;




            --
            IF (ind_a_imprimer)
            THEN
               p_ins_demande_tp (i_numporte        => i_numporte,
                                 i_idadhesion      => g_idadhesion,
                                 i_numgar          => i_numgar,
                                 i_numindiv        => rec_c_adherent.numindiv,
                                 i_debut           => rec_c_adherent.debut,
                                 i_fin             => rec_c_adherent.datper,
                                 i_type            => 7,
                                 i_numfor          => g_numfor
                                );
            END IF;
         --
         END LOOP;

         CLOSE c_adherent;
      END LOOP;

      CLOSE c_adhesion;

/* VCR 28/12/2006
Ajout du parametre O_nb_demande pour l'affichage du nombre de demande dans la BA21 */
      o_nb_demande := g_nb_demande;
--
   END p_dmnde_contrat;

--
-- Demande Tiers payant automatise adhesion
   PROCEDURE p_dmnde_renouv (
      i_numporte      IN       param_tiers_payant.numporte%TYPE,
      i_deb_contrat   IN       porte_contrat.numgar%TYPE,
      i_fin_contrat   IN       porte_contrat.numgar%TYPE,
      o_nb_demande    OUT      NUMBER
   )
   IS
      CURSOR c_contrat
      IS
         SELECT   numgar
             FROM porte_contrat
            WHERE numporte = i_numporte
              AND pk_histo_contrat.f_sel_etat (numgar, SYSDATE) = 1
              AND numgar BETWEEN pk_qttc.f_sel_numgar (i_deb_contrat)
                             AND pk_qttc.f_sel_numgar (i_fin_contrat)
         ORDER BY numgar;

      CURSOR c_adhesion
      IS
         SELECT   pa.numindiv, pa.idadhesion, ad.numfor, pa.fin, ad.datper,
                  tp.renouv, tp.period, tp.idparam_tp
             FROM porte_adhesion pa,
                  adhe_cntrt a,
                  adhesion ad,
                  demande_tp d,
                  param_tiers_payant tp
            WHERE pa.idadhesion = a.idadhesion
              AND a.idadhesion = ad.idadhesion
              AND pa.numporte = g_numporte
              AND a.numgar = g_numgar
              AND d.idporte = pa.idporte
              AND tp.idparam_tp = d.idparam_tp
              AND NVL (ad.datper, SYSDATE) >= SYSDATE
              AND f_etat_adhe (pa.idadhesion, pa.fin + 1) != 0
              AND SYSDATE >= pa.fin - tp.renouv
         ORDER BY pa.numindiv, pa.idadhesion, pa.fin;

      rec_c_adhesion   c_adhesion%ROWTYPE;
      l_idparam        BOOLEAN;
   BEGIN
      g_numporte := i_numporte;
--
-- NSD (+) 11-06-2007 Fiche humanis G115 (Une Adhesion represente une demande TP)
      g_nb_demande := 0;                                    -- Initialisation

--
      OPEN c_contrat;

      LOOP
         FETCH c_contrat
          INTO g_numgar;

         EXIT WHEN c_contrat%NOTFOUND;
         --
         DBMS_OUTPUT.put_line (   'Traitement contrat '
                               || g_numgar
                               || ' Renouv '
                               || g_renouv
                              );
         --
         -- NSD (+) 11-06-2007 Fiche humanis G115 (Une Adhesion represente une demande TP)
         g_nb_demande := g_nb_demande + 1;

         --
         OPEN c_adhesion;

         LOOP
            FETCH c_adhesion
             INTO rec_c_adhesion;

            EXIT WHEN c_adhesion%NOTFOUND;
            --
            g_numassu := rec_c_adhesion.numindiv;
            --
            g_idparam_tp := rec_c_adhesion.idparam_tp;
            g_fract := rec_c_adhesion.period;
            g_renouv := rec_c_adhesion.renouv;
            --
            p_sel_param_tp (o_found => l_idparam);

            IF (l_idparam)
            THEN
               --
               DBMS_OUTPUT.put_line ('Numporte : ' || g_numporte);
               DBMS_OUTPUT.put_line (   'Idadhesion : '
                                     || rec_c_adhesion.idadhesion
                                    );
               -- ||Rec_c_adhesion.idadhesion);
               DBMS_OUTPUT.put_line ('Numgar : ' || g_numgar);
               DBMS_OUTPUT.put_line ('Numindiv : ' || rec_c_adhesion.numindiv);
               -- ||Rec_c_adhesion.numindiv);
               DBMS_OUTPUT.put_line ('Idebut : ' || rec_c_adhesion.fin);
               -- ||(Rec_c_adhesion.fin + 1));
               DBMS_OUTPUT.put_line ('I_type : ' || '17');
               --
               p_ins_demande_tp (i_numporte        => g_numporte,
                                 i_idadhesion      => rec_c_adhesion.idadhesion,
                                 i_numgar          => g_numgar,
                                 i_numindiv        => rec_c_adhesion.numindiv,
                                 i_debut           => (rec_c_adhesion.fin + 1
                                                      ),
                                 i_fin             => rec_c_adhesion.datper,
                                 i_type            => 17,
                                 i_numfor          => rec_c_adhesion.numfor
                                );
            END IF;
         END LOOP;

         CLOSE c_adhesion;
      END LOOP;

      CLOSE c_contrat;

/* VCR 28/12/2006
Ajout du parametre O_nb_demande pour l'affichage du nombre de demande dans la BA21 */
      o_nb_demande := g_nb_demande;
--
   END p_dmnde_renouv;

   FUNCTION f_sel_idparam_tp (
      i_numgar   IN   gar_param_tp.numgar%TYPE,
      i_numfor   IN   gar_param_tp.numfor%TYPE
   )
      RETURN NUMBER
   IS
      CURSOR c_idparam_tp
      IS
         SELECT idparam_tp
           FROM gar_param_tp
          WHERE numgar = pk_qttc.f_sel_numgar (i_numgar)
                AND numfor = i_numfor;

      l_idparamtp   gar_param_tp.idparam_tp%TYPE;
   BEGIN
      OPEN c_idparam_tp;

      FETCH c_idparam_tp
       INTO l_idparamtp;

      CLOSE c_idparam_tp;

--
      RETURN (l_idparamtp);
   END f_sel_idparam_tp;

-- ---------------------------------- Fin des corps des procedures publiques --

   -- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--@cpriv
-- Recherche de l'ouvreur de droits
--
   PROCEDURE p_sel_ouvreur_de_droit (o_found OUT BOOLEAN)
   IS
      CURSOR c_matorg
      IS
         SELECT matorg
           FROM individu
          WHERE numindiv = g_numindiv;

      CURSOR c_numassu
      IS
         SELECT numindiv, matorg, cless, datnais, regime, caisse
           FROM individu
          WHERE matorg = g_matorg AND natur = 1;

/* and Exists (
      Select   1
      From  adhe_cntrt_membre
      Where idadhesion = G_idadhesion
      and   adhe_cntrt_membre.numindiv = individu.numindiv
      );
*/
      rec_c_numassu   c_numassu%ROWTYPE;
   BEGIN
      o_found := TRUE;

--
      OPEN c_matorg;

      FETCH c_matorg
       INTO g_matorg;

      CLOSE c_matorg;

--
      OPEN c_numassu;

      FETCH c_numassu
       INTO rec_c_numassu;

      IF (c_numassu%NOTFOUND)
      THEN
         o_found := FALSE;
      END IF;

--
      g_numassu := rec_c_numassu.numindiv;
      g_matorg := rec_c_numassu.matorg;
      g_cless := rec_c_numassu.cless;
      g_datnais := rec_c_numassu.datnais;
      g_regime := rec_c_numassu.regime;
      g_caisse := rec_c_numassu.caisse;

--
      CLOSE c_numassu;
   END p_sel_ouvreur_de_droit;

--
-- Infos porte
--
   PROCEDURE p_sel_param_tp (o_found OUT BOOLEAN)
   IS
      CURSOR c_param_tp_global
      IS
         SELECT param_tiers_payant.idparam_tp, param_tiers_payant.period,
                param_tiers_payant.renouv
           FROM param_tiers_payant, gar_param_tp
          WHERE param_tiers_payant.numporte = g_numporte
            AND param_tiers_payant.numgar = pk_qttc.f_sel_numgar (g_numgar)
            AND gar_param_tp.idparam_tp = param_tiers_payant.idparam_tp
            AND gar_param_tp.numfor = 0;

      CURSOR c_gar_param_tp
      IS
         SELECT param_tiers_payant.idparam_tp, param_tiers_payant.period,
                param_tiers_payant.renouv
           FROM param_tiers_payant, gar_param_tp
          WHERE param_tiers_payant.numporte = g_numporte
            AND param_tiers_payant.numgar = pk_qttc.f_sel_numgar (g_numgar)
            AND gar_param_tp.idparam_tp = param_tiers_payant.idparam_tp
            AND gar_param_tp.numfor =
                   pk_qttc.f_sel_numfor (pk_qttc.f_sel_numgar (g_numgar),
                                         g_numfor
                                        );

      rec_c_param_tp_global   c_param_tp_global%ROWTYPE;
      rec_c_gar_param_tp      c_gar_param_tp%ROWTYPE;
   BEGIN
      OPEN c_param_tp_global;

      FETCH c_param_tp_global
       INTO rec_c_param_tp_global;

      IF (c_param_tp_global%FOUND)
      THEN
         g_idparam_tp := rec_c_param_tp_global.idparam_tp;
         g_fract := rec_c_param_tp_global.period;
         g_renouv := rec_c_param_tp_global.renouv;
         o_found := TRUE;
      ELSE
         OPEN c_gar_param_tp;

         FETCH c_gar_param_tp
          INTO rec_c_gar_param_tp;

         IF (c_gar_param_tp%FOUND)
         THEN
            g_idparam_tp := rec_c_gar_param_tp.idparam_tp;
            g_fract := rec_c_gar_param_tp.period;
            g_renouv := rec_c_gar_param_tp.renouv;
            o_found := TRUE;

            CLOSE c_gar_param_tp;
         ELSE
            o_found := FALSE;

            CLOSE c_gar_param_tp;
         END IF;
      END IF;

      CLOSE c_param_tp_global;
   END p_sel_param_tp;

--
-- Determination de la date de fin de validite
--
/*
Procedure P_SEL_fin
IS
BEGIN
--
P_SEL_contrat;
--
If ( mod(months_between(G_debut, G_eche_anniv), G_fract) = 0 ) then
   G_fin := add_months(G_debut, G_fract) - 1;
Else
   if (G_fract in (1,3,12) ) then
   Select   add_months(trunc(G_debut, decode(G_fract,
                  1, 'MM',
                  3, 'Q',
                  12, 'Y'
                  )
               ),
            G_fract) - 1
   Into  G_fin
   From  Dual;
   elsif (G_fract = 6) then
   SELECT add_months(
                  trunc(G_debut,'Y'), decode(sign(6-to_number(to_char(G_debut,'MM'))),
                                     -1,12,
                                      0,6,
                                      1,6
                        )
                  ) - 1
   into G_fin
   FROM   DUAL;
   end if;

End if;
END P_SEL_fin;
*/
   PROCEDURE p_sel_validite
   -- XHU 07/12/2010 : Correction de bug. Si la date de péremption = date fin théorique -> la date de fin de validité est null
   IS
      l_debut_theo   DATE;
      l_fin_theo     DATE;
   BEGIN
--
      p_sel_contrat;
      g_debval := NULL;
      g_finval := NULL;


--
-- Calcul de la date de debut theorique par rapport a la date du jour
/*
If ( mod(months_between(G_debut, G_eche_anniv), G_fract) = 0 ) then
   G_fin := add_months(G_debut, G_fract) - 1;
Else*/
-- if (G_fract in (1,3,12) ) then

      -- Calcul de la date de debut theorique par rapport a la date du jour
      BEGIN
         SELECT TRUNC (SYSDATE,
                       DECODE (g_fract, 1, 'MM', 3, 'Q', 6, 'Y', 12, 'Y')
                      )
           INTO l_debut_theo
           FROM DUAL;

-- Calcul de la date de fin theorique par rapport a la date de debut theorique
         SELECT ADD_MONTHS (l_debut_theo, g_fract) - 1
           INTO l_fin_theo
           FROM DUAL;

         DBMS_OUTPUT.put_line ('fin theo' || l_fin_theo);
         DBMS_OUTPUT.put_line ('debut theo' || l_debut_theo);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_debut_theo := NULL;
            l_fin_theo := NULL;
      END;

      IF (g_debut < l_debut_theo)
      THEN
         g_debval := l_debut_theo;

         DBMS_OUTPUT.put_line ('debut val' || g_debval);

         IF (g_fin IS NULL)
         THEN
            g_finval := l_fin_theo;
            dbms_output.put_line('fin val 1' || G_finval);
         ELSIF (g_fin BETWEEN l_debut_theo AND l_fin_theo)
         THEN
            g_finval := g_fin;

            dbms_output.put_line('fin val 2' || G_finval);
         ELSIF (g_fin > l_fin_theo)
         THEN
            g_finval := l_fin_theo;

            dbms_output.put_line('fin val 3' || G_finval);
         END IF;
      ELSIF (g_debut BETWEEN l_debut_theo AND l_fin_theo)
      THEN
         g_debval := g_debut;

         IF (g_fin IS NULL)
         THEN
            g_finval := l_fin_theo;
         ELSIF (g_fin < l_fin_theo)
         THEN
            g_finval := g_fin;

            dbms_output.put_line('fin val 2 bis' || G_finval);
         ELSIF (g_fin >= l_fin_theo)                      -- 07/12/2010 ajout =
         THEN
            g_finval := l_fin_theo;
         END IF;
      ELSIF (g_debut > l_fin_theo)
      THEN
         g_debval := g_debut;

         SELECT TRUNC (g_debval,
                       DECODE (g_fract, 1, 'MM', 3, 'Q', 6, 'Y', 12, 'Y')
                      )
           INTO l_debut_theo
           FROM DUAL;

-- Calcul de la date de fin theorique par rapport a la date de debut theorique
         SELECT ADD_MONTHS (l_debut_theo, g_fract) - 1
           INTO l_fin_theo
           FROM DUAL;

         IF (g_fin IS NULL) OR (g_fin > l_fin_theo)
         THEN
            g_finval := l_fin_theo;
         ELSE
            g_finval := g_fin;
         END IF;
      END IF;
   END p_sel_validite;

--
-- Insertion dans porte_adhesion et demande_tp de l'ouvreur de droits
-- CTT 22/11/2006 : En cas de renouvellement (type 17) on remplace les eventuelles demandes en attente
--           et non transmises ( transmis = 2 )
   PROCEDURE p_ins_porte_adhesion
   IS
      CURSOR c_porte
      IS
         SELECT idporte, transmis
           FROM porte_adhesion
          WHERE numporte = g_numporte
            AND numindiv = g_numassu
            AND idadhesion = g_idadhesion
            AND numremise = 0;

      rec_c_porte   c_porte%ROWTYPE;
      l_type_ano    NUMBER;
      a_inserer     BOOLEAN           := FALSE;
   BEGIN

      OPEN c_porte;

      FETCH c_porte
       INTO rec_c_porte;

      IF (c_porte%FOUND)
      THEN
         IF (g_type = 7 OR g_type = 17)
         THEN
            IF (rec_c_porte.transmis = 2)
            THEN
               -- le debut du remplacement en cas de renouvellement (delete en cascade par trigger sur demande_tp et demande_tp_ad)
               DELETE FROM porte_adhesion
                     WHERE idporte = rec_c_porte.idporte;

               a_inserer := TRUE;
            /* VDA 04/01/2011 :
            cause : fuite de valeur globale sur g_IdPorte
            conséquence : rattachement d'un intru sur une carte TPE ne lui appartenant pas !
            */
            ELSE
              a_inserer := FALSE;
              g_idporte := rec_c_porte.idporte;
            -- VDA 04/01/2011 : Fin
            END IF;
         ELSE
            a_inserer := FALSE;
            g_idporte := rec_c_porte.idporte;
         END IF;
      ELSE
         a_inserer := TRUE;
      END IF;




      IF (a_inserer)
      THEN
         --
         SELECT NVL (MAX (idporte), 0) + 1
           INTO g_idporte
           FROM porte_adhesion;

         --
         DBMS_OUTPUT.put_line ('fin val avant insertion  ' || g_finval);

         P_INS_journal(2,'fin val avant insertion  ' || g_finval);


         INSERT INTO porte_adhesion
                     (idporte, numporte, numindiv, idadhesion, numremise,
                      transmis, TYPE, debut, mouvement, fin
                     )
              VALUES (g_idporte, g_numporte, g_numassu, g_idadhesion, 0,
                      2, g_type, g_debval, 'C', g_finval
                     );

         --
         INSERT INTO demande_tp
                     (idporte, idparam_tp, numindiv, creation,
                      matorg, cless, datnais, regime, caisse, date_trans
                     )
              VALUES (g_idporte, g_idparam_tp, g_numassu, TRUNC (SYSDATE),
                      g_matorg, g_cless, g_datnais, g_regime, g_caisse, NULL
                     );

         --
         p_gest_ano (i_numindiv      => g_numassu,
                     i_numassu       => g_numassu,
                     i_matorg        => g_matorg,
                     i_cless         => g_cless,
                     i_datnais       => g_datnais,
                     i_regime        => g_regime,
                     i_caisse        => g_caisse,
                     i_rang          => 1,
                     i_idporte       => g_idporte,
                     o_type_ano      => l_type_ano
                    );
      END IF;

--
      CLOSE c_porte;
   END p_ins_porte_adhesion;

--
-- Insertion dans demande_tp_ad des ayant-droits rattaches
--
   PROCEDURE p_ins_demande_tp_ad ( i_fin_ayd      IN   DATE DEFAULT NULL)
   IS
      CURSOR c_ad
      IS
         SELECT numindiv, datnais, rang, typadr
           FROM individu
          WHERE ((matorg = g_matorg) OR (matorg2=g_matorg))
            AND EXISTS (
                   SELECT 1
                     FROM adhe_cntrt_membre
                    WHERE adhe_cntrt_membre.numindiv = individu.numindiv
                      AND adhe_cntrt_membre.idadhesion = g_idadhesion)
            AND EXISTS (
                   SELECT 1
                     FROM control_adhesion
                    WHERE control_adhesion.numindiv = individu.numindiv
                      AND control_adhesion.idadhesion = g_idadhesion
                      AND (   control_adhesion.datper IS NULL
                           OR control_adhesion.datper >= SYSDATE
                          )
                      AND control_adhesion.etat = 1);
      --09/11/2011 ABO correction du a l'impossibilite de consulter la table adhesion pendant exécution du trigger
      -- et ajout de l'individu concerné par la nouvelle adhesion
      CURSOR c_ad_cntrt_global
      IS
         SELECT numindiv, datnais, rang, typadr
           FROM individu
          WHERE ((matorg = g_matorg) OR (matorg2=g_matorg))
            -- and numindiv != G_numassu
            AND EXISTS (
                   SELECT 1
                     FROM adhesion
                    WHERE adhesion.numindiv = individu.numindiv
                      AND adhesion.idadhesion = g_idadhesion
                      AND g_debut BETWEEN adhesion.datapli
                                      AND NVL (adhesion.datper, g_debut)
                      AND (   adhesion.datper IS NULL
                           OR adhesion.datper >= SYSDATE
                          )
                      AND adhesion.rang = 1   -- MUR M0005778

                      )
          UNION
          SELECT numindiv, datnais, rang, typadr
           FROM individu
          WHERE ((matorg = g_matorg) OR (matorg2=g_matorg))
          AND numindiv = g_numindiv_init
          AND EXISTS (SELECT 1
                     FROM adhe_cntrt_membre
                    WHERE adhe_cntrt_membre.numindiv = individu.numindiv
                      AND adhe_cntrt_membre.idadhesion = g_idadhesion);

      CURSOR c_ad_glob
      IS
         SELECT numindiv, datnais, rang, typadr
           FROM individu
          WHERE ((matorg = g_matorg) OR (matorg2=g_matorg))
            AND EXISTS (
                   SELECT 1
                     FROM adhesion
                    WHERE adhesion.numindiv = individu.numindiv
                      AND adhesion.idadhesion = g_idadhesion
                      AND g_debut BETWEEN adhesion.datapli
                                      AND NVL (adhesion.datper, g_debut)
                      AND adhesion.datapli !=
                                   NVL (adhesion.datper, adhesion.datapli + 1)
                      AND adhesion.etat = 1
                      AND (   adhesion.datper IS NULL
                           OR adhesion.datper >= SYSDATE
                          )
                      --AND adhesion.etat = 1
                      AND adhesion.rang <> 2);

      rec_c_ad        c_ad%ROWTYPE;
      rec_c_ad_cg     c_ad_cntrt_global%ROWTYPE;
      rec_c_ad_glob   c_ad_glob%ROWTYPE;
      l_type_ano      NUMBER;
      cpt             NUMBER;

      --execption
      exc_erreur_cursor_vide  EXCEPTION;

      loc_finval     DATE;

   BEGIN

      cpt := 0;

      P_INS_journal(2,'p_ins_demande_tp_ad g_finval: ' || to_char(g_finval));

      IF (g_type in (1) AND f_test_cntrt_global = 0)
      THEN

        OPEN c_ad;
        LOOP
            cpt := cpt + 1;

            FETCH c_ad
            INTO rec_c_ad;
            --si pas de bénéficiaires, la carte doit etre effacé
            IF cpt=1 and c_ad%NOTFOUND THEN
               CLOSE c_ad;
               RAISE exc_erreur_cursor_vide;
            END IF;

            EXIT WHEN c_ad%NOTFOUND;

            -- Recupération de la date de fin d adhésion(si fermée)) de l ayant droit
            -- afin de mettre la bonne date de fin de validité de la carte
            BEGIN
               SELECT MAX(NVL(a.datper,g_finval)) INTO loc_finval
               FROM adhesion a
               WHERE a.idadhesion=g_idadhesion
                 AND a.numindiv= rec_c_ad.numindiv
                 AND NVL(a.datper,g_finval) <=g_finval;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                BEGIN
                  select pa.fin into loc_finval from porte_adhesion pa where pa.idporte=g_idporte;
                EXCEPTION
                  WHEN OTHERS THEN
                    loc_finval:=NVL(g_finval,g_fin);
                END;
               WHEN OTHERS THEN
                 loc_finval:=NVL(g_finval,g_fin);
            END;
             P_INS_journal(2,'p_ins_demande_tp_ad rec_c_ad.numindiv: ' || rec_c_ad.numindiv);
             P_INS_journal(2,'p_ins_demande_tp_ad loc_finval: ' || to_char(loc_finval));

            --
            -- ne pas insérer pour les types de porte 4 si l'année de début ne correspond pas à l'année de fin
            IF NOT(f_type_porte(g_numporte) = 4 AND TO_CHAR(g_debval, 'YYYY') <> TO_CHAR(NVL(loc_finval,g_finval), 'YYYY'))
            THEN
              INSERT INTO demande_tp_ad
                          (idporte, numindiv, datnais, rang, typadr, debut, fin)
                 SELECT g_idporte, rec_c_ad.numindiv, rec_c_ad.datnais,
                        rec_c_ad.rang, rec_c_ad.typadr, g_debval, NVL(loc_finval,g_finval)
                   FROM DUAL
                  WHERE NOT EXISTS (
                           SELECT 1
                             FROM demande_tp_ad
                            WHERE idporte = g_idporte
                              AND numindiv = rec_c_ad.numindiv);
            END IF;

            --
            g_rang := rec_c_ad.rang;
            --
            p_gest_ano (i_numindiv      => rec_c_ad.numindiv,
                        i_numassu       => g_numassu,
                        i_matorg        => g_matorg,
                        i_cless         => g_cless,
                        i_datnais       => rec_c_ad.datnais,
                        i_regime        => g_regime,
                        i_caisse        => g_caisse,
                        i_rang          => rec_c_ad.rang,
                        i_idporte       => g_idporte,
                        o_type_ano      => l_type_ano
                       );
         --
         END LOOP;

         CLOSE c_ad;
      ELSIF (g_type = 1 AND f_test_cntrt_global = 1)
      THEN

         OPEN c_ad_cntrt_global;

         LOOP
            cpt := cpt + 1;


            FETCH c_ad_cntrt_global
            INTO rec_c_ad_cg;
            --si pas de bénéficiaires, la carte doit etre effacé
            IF cpt=1 and c_ad_cntrt_global%NOTFOUND THEN
               CLOSE c_ad_cntrt_global;
               RAISE exc_erreur_cursor_vide;
            END IF;


            EXIT WHEN c_ad_cntrt_global%NOTFOUND;
            --

            -- Recupération de la date de fin d adhésion(si fermée)) de l ayant droit
            -- afin de mettre la bonne date de fin de validité de la carte
			BEGIN
                SELECT MAX(NVL(a.datper,g_finval)) INTO loc_finval
                FROM adhesion a
                 WHERE a.idadhesion=g_idadhesion
                   AND a.numindiv= rec_c_ad_cg.numindiv
                   AND NVL(a.datper,g_finval) <=g_finval;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                BEGIN
                  select pa.fin into loc_finval from porte_adhesion pa where pa.idporte=g_idporte;
                EXCEPTION
                  WHEN OTHERS THEN
                    loc_finval:=NVL(g_finval,g_fin);
                END;
               WHEN OTHERS THEN
                 loc_finval:=NVL(g_finval,g_fin);
            END;

             P_INS_journal(2,'p_ins_demande_tp_ad rec_c_ad_cg.numindiv: ' || rec_c_ad_cg.numindiv);
             P_INS_journal(2,'p_ins_demande_tp_ad loc_finval: ' || to_char(loc_finval));
			 --contexte particulier de nouvelle adhésion et nouvelle adhésion fermée dans le futur
			 --le curseur sur la vue démat ne voit pas les nouvelles lignes de l'adhésion, la date max peut donc être égale aux datper des anciennes garanties
			 --cas d'un enfant changeant de régime loc_finval = 31/21/2013 alors que g_finval = 31/12/2014
			 IF loc_finval IS NULL THEN loc_finval:=g_finval;
			 ELSE
			   SELECT greatest(loc_finval,NVL(g_finval,g_fin)) INTO loc_finval FROM DUAL;
			 END IF;

            -- ne pas insérer pour les types de porte 4 si l'année de début ne correspond pas à l'année de fin
            IF NOT(f_type_porte(g_numporte) = 4 AND TO_CHAR(g_debval, 'YYYY') <> TO_CHAR(loc_finval, 'YYYY'))
            THEN
              INSERT INTO demande_tp_ad
                          (idporte, numindiv, datnais, rang, typadr, debut, fin)
                 SELECT g_idporte, rec_c_ad_cg.numindiv, rec_c_ad_cg.datnais,
                        rec_c_ad_cg.rang, rec_c_ad_cg.typadr, g_debval, loc_finval
                   FROM DUAL
                  WHERE NOT EXISTS (
                           SELECT 1
                             FROM demande_tp_ad
                            WHERE idporte = g_idporte
                              AND numindiv = rec_c_ad_cg.numindiv);
            END IF;
            --
            g_rang := rec_c_ad_cg.rang;
            --
            p_gest_ano (i_numindiv      => rec_c_ad_cg.numindiv,
                        i_numassu       => g_numassu,
                        i_matorg        => g_matorg,
                        i_cless         => g_cless,
                        i_datnais       => rec_c_ad_cg.datnais,
                        i_regime        => g_regime,
                        i_caisse        => g_caisse,
                        i_rang          => rec_c_ad_cg.rang,
                        i_idporte       => g_idporte,
                        o_type_ano      => l_type_ano
                       );
         --
         END LOOP;

         CLOSE c_ad_cntrt_global;
      ELSE

         OPEN c_ad_glob;

         LOOP
            cpt := cpt + 1;
            FETCH c_ad_glob
            INTO rec_c_ad_glob;
            --si pas de bénéficiaires, la carte doit etre effacé
            IF cpt=1 and c_ad_glob%NOTFOUND THEN
               CLOSE c_ad_glob;
               RAISE exc_erreur_cursor_vide;
            END IF;

            EXIT WHEN c_ad_glob%NOTFOUND;

            -- Recupération de la date de fin d adhésion(si fermée)) de l ayant droit
            -- afin de mettre la bonne date de fin de validité de la carte
            -- on borne la recherche à l'année civile g_finval
            -- les doubles garanties en fin de couverture sont assuré par le TRG cpt_adhe
            -- si la date de fin spé à un ayd est passé mais qu'elle est hors borne > non prise en compte
            IF i_fin_ayd IS NOT NULL AND i_fin_ayd < g_finval AND g_numindiv_init=rec_c_ad_glob.numindiv THEN
             loc_finval := i_fin_ayd;
             P_INS_journal(2,'p_ins_demande_tp_ad rec_c_ad_glob.numindiv: ' || rec_c_ad_glob.numindiv|| ' Prise en compte de la date');
             P_INS_journal(2,'p_ins_demande_tp_ad i_fin_ayd loc_finval: ' || to_char(loc_finval));
            ELSE
              BEGIN
               -- attention la vue n'est pas à jour, pour new.dapter il reste donc une ligne sans date de fin
                SELECT MAX(NVL(a.datper,g_finval)) INTO loc_finval
                FROM adhesion a
                 WHERE a.idadhesion=g_idadhesion
                   AND a.numindiv= rec_c_ad_glob.numindiv
                   AND NVL(a.datper,g_finval) <=g_finval;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  BEGIN
                    select pa.fin into loc_finval from porte_adhesion pa where pa.idporte=g_idporte;
                  EXCEPTION
                    WHEN OTHERS THEN
                      loc_finval:=NVL(g_finval,g_fin);
                  END;
                 WHEN OTHERS THEN
                   loc_finval:=NVL(g_finval,g_fin);
                END;
            END IF;
            P_INS_journal(2,'p_ins_demande_tp_ad rec_c_ad_glob.numindiv: ' || rec_c_ad_glob.numindiv|| ' loc_finval: ' || loc_finval ||' i_fin_ayd: '||i_fin_ayd);
            --
            -- ne pas insérer pour les types de porte 4 si l'année de début ne correspond pas à l'année de fin
            IF NOT(f_type_porte(g_numporte) = 4 AND TO_CHAR(g_debval, 'YYYY') <> TO_CHAR(NVL(loc_finval,g_finval), 'YYYY'))
            THEN

              INSERT INTO demande_tp_ad
                          (idporte, numindiv, datnais, rang, typadr, debut, fin)
                 SELECT g_idporte, rec_c_ad_glob.numindiv,
                        rec_c_ad_glob.datnais, rec_c_ad_glob.rang,
                        rec_c_ad_glob.typadr, g_debval, NVL(loc_finval,g_finval)
                   FROM DUAL
                  WHERE NOT EXISTS (
                           SELECT 1
                             FROM demande_tp_ad
                            WHERE idporte = g_idporte
                              AND numindiv = rec_c_ad_glob.numindiv);
            END IF;
            --
            g_rang := rec_c_ad_glob.rang;
            --
            p_gest_ano (i_numindiv      => rec_c_ad_glob.numindiv,
                        i_numassu       => g_numassu,
                        i_matorg        => g_matorg,
                        i_cless         => g_cless,
                        i_datnais       => rec_c_ad_glob.datnais,
                        i_regime        => g_regime,
                        i_caisse        => g_caisse,
                        i_rang          => rec_c_ad_glob.rang,
                        i_idporte       => g_idporte,
                        o_type_ano      => l_type_ano
                       );
         --
         END LOOP;

         CLOSE c_ad_glob;
      END IF;
   EXCEPTION
            WHEN exc_erreur_cursor_vide THEN
            --si pas de bénéficiaires, la carte doit etre effacé
            DELETE FROM DEMANDE_TP WHERE idporte = g_idporte;
            DELETE FROM PORTE_ADHESION WHERE idporte = g_idporte;


   END p_ins_demande_tp_ad;

--
-- Infos contrat
--
   PROCEDURE p_sel_contrat
   IS
      CURSOR c_contrat
      IS
         SELECT numinterm, numorg, eche_anniv
           FROM contrat
          WHERE numgar = pk_qttc.f_sel_numgar (g_numgar);

      rec_c_contrat   c_contrat%ROWTYPE;
   BEGIN
      OPEN c_contrat;

      FETCH c_contrat
       INTO rec_c_contrat;

      g_numsoc := rec_c_contrat.numinterm;
      g_numorg := rec_c_contrat.numorg;
      g_eche_anniv := rec_c_contrat.eche_anniv;

      CLOSE c_contrat;
   END p_sel_contrat;

--
-- Gestion des anomalies
--
   PROCEDURE p_gest_ano (
      i_numindiv   IN       individu.numindiv%TYPE,
      i_numassu    IN       individu.numassu%TYPE,
      i_matorg     IN       individu.matorg%TYPE,
      i_cless      IN       individu.cless%TYPE,
      i_datnais    IN       individu.datnais%TYPE,
      i_regime     IN       individu.regime%TYPE,
      i_caisse     IN       individu.caisse%TYPE,
      i_rang       IN       individu.rang%TYPE,
      i_idporte    IN       porte_adhesion.idporte%TYPE,
      o_type_ano   OUT      NUMBER
   )
   IS
      CURSOR c_indiv
      IS
         SELECT prenom
           FROM individu
          WHERE numindiv = i_numindiv;

--
      rec_c_indiv   c_indiv%ROWTYPE;
      l_type_ano    porte_adhesion.TYPE%TYPE;
   BEGIN
      l_type_ano := 0;

      IF (i_numindiv = i_numassu)
      THEN
         IF (i_matorg IS NULL)
         THEN
            l_type_ano := 25;
         ELSIF (i_cless IS NULL)
         THEN
            l_type_ano := 24;
         ELSIF (i_regime IS NULL)
         THEN
            l_type_ano := 21;
         ELSIF (i_caisse IS NULL)
         THEN
            l_type_ano := 22;
         END IF;
      ELSE
         IF (i_rang IS NULL)
         THEN
            l_type_ano := 28;
         END IF;
      END IF;

--
      IF (i_datnais IS NULL)
      THEN
         l_type_ano := 26;
      END IF;

--
      IF (l_type_ano = 0)
      THEN
         OPEN c_indiv;

         FETCH c_indiv
          INTO rec_c_indiv;

         CLOSE c_indiv;

         --
         IF (rec_c_indiv.prenom IS NULL)
         THEN
            l_type_ano := 27;
         END IF;
      END IF;

--
      IF (l_type_ano != 0)
      THEN
         UPDATE porte_adhesion
            SET transmis = 6,
                TYPE = l_type_ano
          WHERE idporte = i_idporte;
      END IF;

--
      o_type_ano := l_type_ano;
--
   END p_gest_ano;

--
-- Recherche du code postal de la caisse
--
   PROCEDURE p_sel_codpos
   IS
      CURSOR c_tp
      IS
         SELECT numindiv
           FROM pers_tierspayant
          WHERE type_tiers = 1 AND caisse = g_caisse;

      l_numindiv   pers_tierspayant.numindiv%TYPE;
   BEGIN
--
      OPEN c_tp;

      FETCH c_tp
       INTO l_numindiv;

      CLOSE c_tp;

--
      g_codpos := f_codpos (l_numindiv);
--
   END p_sel_codpos;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_carte_tp                                                */
/* Type         :  Publique                                                  */
/* Description  :  Test si la prestation est couverte par une carte TP       */
/* Entree       :  i_numindiv                                                */
/*                 i_codfrais                                                */
/*                 i_datsin                                                  */
/*                 i_idadhesion                                              */
/*                 i_numporte                                                */
/*                 i_categorie                                               */
/*                 i_adeli                                                   */
/* Retour       :  numéro du bénéficiaire couverte par la carte TP           */
/*---------------------------------------------------------------------------*/
/* Evolution    :  Ajout de la catégorie pour la gestion des centres de santé*/
/* Auteur       :  JBO                                                       */
/*  Date        :  09/10/2012                                                */
/* Evolution    :  Ajout d'un tableau conditionné pour la gestion des centres*/
/*                 (N°NNI) et du TP Hospi (mode de traitement)               */
/* Auteur       :  ABO                                                       */
/*  Date        :  12/2015                                                   */
/*---------------------------------------------------------------------------*/
FUNCTION f_carte_tp (
   i_numindiv     IN   individu.numindiv%TYPE,
   i_codfrais     IN   natfrais.codfrais%TYPE,
   i_datsin       IN   DATE,
   i_idadhesion   IN   adhe_cntrt.idadhesion%TYPE DEFAULT 0,
   i_numporte     IN   porte_param.numporte%TYPE DEFAULT NULL,
   i_categorie    IN   acte_tp.categorie%TYPE DEFAULT NULL,
   i_TAB_Cond     IN   TAB_Cond
)
   RETURN NUMBER
IS
  /*ABO 21/11/2012 RG de couverture GEREP Centre pour acte ouvert avec catégorie CS
     Catégorie 	Adeli	        action
      vide 	    vide	        non couvert carte TP
      vide 	    non centre	  non couvert carte TP
      vide 	    centre	      couvert carte TP
      CS	      vide	        couvert carte TP
      CS	      centre	      couvert carte TP
      CS	      non centre	  non couvert carte TP
      OO	      centre	      non couvert carte TP


      Catégorie Mode trait. action
      vide 	    vide	        non couvert carte TP
      vide 	    2	            non couvert carte TP
      vide 	    7 ou 10	      couvert carte TP
      CP	      vide	        couvert carte TP
      CP	      7 ou 10	      couvert carte TP
      CP	      2          	  non couvert carte TP
      OO	      7 ou 10	      non couvert carte TP

	  catégorie CP, PS centre de santé, mode de traitement à 2 => NON couvert carte de TP
      */


   CURSOR c_domaine_ext
   IS
     SELECT NVL(porte_param.numbene,0) numbene, acte_tp.categorie categorie
      FROM porte_param, v_demande_tp, param_demande_tp,acte_tp
       WHERE porte_param.numporte = NVL (i_numporte, porte_param.numporte)
         AND porte_param.numporte = v_demande_tp.numporte
         AND v_demande_tp.numindiv = i_numindiv
         AND i_datsin BETWEEN v_demande_tp.debut AND v_demande_tp.fin
         AND v_demande_tp.transmis = 1
         AND param_demande_tp.idparam_tp = v_demande_tp.idparam_tp
         AND acte_tp.domaine = param_demande_tp.domaine
         AND acte_tp.codfrais = i_codfrais
         AND acte_tp.numporte = NVL (i_numporte, acte_tp.numporte)
         AND acte_tp.numporte = v_demande_tp.numporte
         AND (acte_tp.categorie = NVL(i_categorie,acte_tp.categorie) OR acte_tp.categorie IS NULL);

  CURSOR c_domaine_int
   IS
      SELECT NVL(porte_param.numbene,0) numbene, acte_tp.categorie categorie
      FROM porte_param, v_demande_tp, param_demande_tp,acte_tp
       WHERE porte_param.numporte = NVL (i_numporte, porte_param.numporte)
         AND porte_param.numporte = v_demande_tp.numporte
         AND v_demande_tp.numindiv = i_numindiv
         AND v_demande_tp.idadhesion = decode(i_idadhesion,0, v_demande_tp.idadhesion,i_idadhesion)
         AND i_datsin BETWEEN v_demande_tp.debut AND v_demande_tp.fin
         AND v_demande_tp.transmis = 1
         AND param_demande_tp.idparam_tp = v_demande_tp.idparam_tp
         AND acte_tp.domaine = param_demande_tp.domaine
         AND acte_tp.codfrais = i_codfrais
         AND acte_tp.numporte = NVL (i_numporte, acte_tp.numporte)
         AND acte_tp.numporte = v_demande_tp.numporte
        AND acte_tp.categorie IS NULL;


  CURSOR C_Condition IS
    SELECT code, libelle, sens
    FROM libelle_bis
    WHERE mnemo='CAT_MASQ'
    AND sens <>-2;


  l_numtp             pers_tierspayant.numtp%TYPE   := 0;
  v_test              NUMBER ;


BEGIN
  v_test:=0;
  IF (i_idadhesion != 0)  THEN
    FOR rec_c_domaine_int IN c_domaine_int LOOP
        l_numtp := rec_c_domaine_int.numbene;
    END LOOP;
  ELSE
     FOR rec_c_domaine_ext IN c_domaine_ext LOOP
       v_test  := 1;
       FOR Rec_Condition IN C_Condition LOOP

        BEGIN
          IF i_categorie IS NULL AND (rec_c_domaine_ext.categorie<>Rec_Condition.code AND rec_c_domaine_ext.categorie IS NOT NULL) THEN
             v_test:=0;
          ELSE

            --dbms_output.put_line('Rec_Condition.libelle:'||Rec_Condition.libelle);
            --dbms_output.put_line('loc_TAB_Cond(Rec_Condition.sens):'||to_char(i_TAB_Cond(Rec_Condition.sens))); --pose des problem de compil
            SELECT 1 INTO v_test FROM dual
            WHERE
            ( REGEXP_like(i_TAB_Cond(Rec_Condition.sens),Rec_Condition.libelle)
            AND  Rec_Condition.code =NVL(i_categorie,Rec_Condition.code))
            OR  (Rec_Condition.code=i_categorie AND i_TAB_Cond(Rec_Condition.sens) IS NULL);
          END IF;


           EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF i_categorie IS NULL AND rec_c_domaine_ext.categorie IS NULL THEN v_test:=1;
              ELSIF Rec_Condition.code=NVL(i_categorie,Rec_Condition.code) OR v_test=0 THEN v_test:=0;
              ELSE v_test:=-1;
              END IF;
            WHEN OTHERS THEN v_test:=0;
        END;
        --dbms_output.put_line('v_test'||v_test);
        IF v_test  = 1 THEN
          l_numtp := rec_c_domaine_ext.numbene;
          EXIT;
        ELSE l_numtp :=0;
        END IF;

      END LOOP;
      IF v_test =-1 AND rec_c_domaine_ext.numbene>0 THEN
        l_numtp:=rec_c_domaine_ext.numbene;
        EXIT;
      ELSIF v_test=1 THEN EXIT;
      END IF;

    END LOOP;
  END IF;
  RETURN (l_numtp);
END f_carte_tp;

--
-- Test s'il existe un code blocage transmission
--
   FUNCTION f_test_blocage
      RETURN BOOLEAN
   IS
      CURSOR c_blocage
      IS
         SELECT 1
           FROM DUAL
          WHERE EXISTS (
                   SELECT 1
                     FROM porte_adhesion
                    WHERE numporte = g_numporte
                      AND numindiv = g_numindiv
                      AND idadhesion = g_idadhesion
                      AND transmis IN (
                             SELECT code
                               FROM libelle
                              WHERE mnemo = 'ETATPRT'
                                AND code = porte_adhesion.transmis
                                AND sens = 1));

      l_blocage   BOOLEAN := FALSE;
      dummy       NUMBER;
   BEGIN
      OPEN c_blocage;

      FETCH c_blocage
       INTO dummy;

      IF (c_blocage%FOUND)
      THEN
         l_blocage := TRUE;
      ELSE
         l_blocage := FALSE;
      END IF;

--
      RETURN (l_blocage);
   END f_test_blocage;

--CTT 20/10/06
-- Teste si le contrat est parametre 'Toutes garanties'
--
   FUNCTION f_test_cntrt_global
      RETURN NUMBER
   IS
      l_cntrt_global   NUMBER := 0;
   BEGIN
      SELECT 1
        INTO l_cntrt_global
        FROM gar_param_tp
       WHERE idparam_tp = g_idparam_tp AND numfor = 0;

      RETURN (l_cntrt_global);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         l_cntrt_global := 0;
         RETURN (l_cntrt_global);
   END f_test_cntrt_global;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Public                                                    */
/* Description  :  procedure d'insertion dans journal ADM                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_journal(i_niv in NUMBER,
                        i_msg in VARCHAR2,
                        i_msg2 in varchar2 := null
                       )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF g_niv_msg IS NULL THEN
     BEGIN
       SELECT decode(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3,1)
       INTO g_niv_msg
       FROM PARAM_BATCH
       WHERE NUMBATCH = g_nom_traitement;
     EXCEPTION
       WHEN OTHERS THEN
         g_niv_msg := 1;
    END;
  END IF;

  IF g_niv_msg >= i_niv THEN
     g_idligne := g_idligne +1;
     PK_trace.P_INS_journal_adm (
        I_nom_traitement => g_nom_traitement,
        I_session  => nvl(g_session,SID),
        I_niv_msg  => i_niv,
        I_msg_adm  => substr(i_msg||' '||i_msg2,1,132),
        I_idligne  => g_idligne);
  END IF;
  COMMIT;
END P_INS_journal;

-- ------------------------------------ Fin des corps des procedures privees --
END;
/
