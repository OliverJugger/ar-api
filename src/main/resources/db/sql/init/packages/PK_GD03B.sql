CREATE OR REPLACE PACKAGE ARTHUS.PK_GD03B
AS
/*===========================================================================*/
/* Package      : PK_GD03B.sql                                               */
/* Domaine      : Prestation                                                 */
/* Version      : V1.0                                                       */
/* Auteur       : ???                                                        */
/* Création     : 01/01/1990                                                 */
/* Description  : Constitution des décomptes                                 */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : PHA / 17/05/2017 / M0005311: Decaissement en Cheque manuel */
/*                                  au lieu de virement manuel pour le CETIP */
/*===========================================================================*/
   PROCEDURE p_gd03b (
      i_numporte   IN       VARCHAR2 DEFAULT NULL,
      i_param1     IN       VARCHAR2 DEFAULT NULL,
      i_session    IN       NUMBER DEFAULT 1,
      i_niv_msg    IN       NUMBER DEFAULT 1,
      i_pause      IN       NUMBER DEFAULT 0,
      o_found      OUT      NUMBER,
      o_erreur     OUT      VARCHAR2
   );
--

--
-- Chaine de reconnaissance SCCS
-- %W%   %E%

-- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des constantes publiques --

-- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --

-- -- TYPES PUBLIQUES ---------------------------------------------------------
-- Aucun
-- ------------------------------------------------- Fin des types publiques --

-- -- VARIABLES PUBLIQUES -----------------------------------------------------
-- Aucune
-- --------------------------------------------- Fin des variables publiques --

-- -- PROCEDURES PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des procedures publiques --
END PK_GD03B;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_GD03B
AS
-- Chaine de reconnaissance SCCS
-- %W%   %E%

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
-- -------------------------------------- Fin des variables globales privees --

   -- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
--
   PROCEDURE p_traitement_principal;

--
   PROCEDURE p_entete_decompte;

--
   PROCEDURE p_ligne_sntr;

--
   PROCEDURE p_pied_decompte;

--
   PROCEDURE p_retention;

--
   PROCEDURE p_pas_retention;

--
   PROCEDURE p_pas_decaismt;

--
   PROCEDURE p_rech_modpmt;

--
   PROCEDURE p_debut_traitement;

--
   PROCEDURE p_fin_traitement;

--
   PROCEDURE p_ins_journal;

--
   PROCEDURE p_get_porte_param;

--
-- ----------------------------- Fin des declarations des procedures privees --

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
-- Aucune
-- ---------------------------------- Fin des corps des procedures publiques --
--
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --
   g_trait_entete              VARCHAR2 (1);
   g_client                    NUMBER (3);
   g_numporte                  NUMBER (3);
   g_param1                    param_batch.param1%TYPE           DEFAULT NULL;
   g_nblig                     NUMBER (5);
   g_niv_rupt                  NUMBER (2);
----
--
--                   Declaration des variables
--
   g_text1                     VARCHAR2 (60);
   g_text2                     VARCHAR2 (60);
   g_text3                     VARCHAR2 (60);
   g_seq                       NUMBER (3);
   g_montant                   NUMBER (10, 2);
--                   coordonnees des modes de payement
--
   g_numdecaismt               decaismt.numdecaismt%TYPE;
--G_numdecaismt      NUMBER(9);
   g_prmt_mdvrt                NUMBER (2);
   g_prmt_mdchq                NUMBER (2);
   g_prmt_dfdev                NUMBER (3);
--
   g_prmt_trouve               VARCHAR2 (1);
--
--                        coordonnees d'un assure
--
   g_bene_nompre               VARCHAR2 (62);
--G_bene_nompre      VARCHAR2(30);
   g_bene_modpmt               NUMBER (2);
   g_bene_modpmt_old           NUMBER (2);
--
   g_bene_modpmt_trouve        VARCHAR2 (1);
--
--                        coordonnees d'un sinistre
--
   g_sntr_idcompte             NUMBER (3);
   g_sntr_idcompte_old         NUMBER (3);
   g_sntr_numsin               NUMBER (10);
   g_sntr_codfrais             VARCHAR2 (5);
   g_sntr_rubrique             VARCHAR2 (5);
   g_sntr_numindiv             NUMBER (7);
   g_sntr_datsin               VARCHAR2 (11);
   g_sntr_mtprest              NUMBER (11, 2);
   g_sntr_mtremb               NUMBER (11, 2);
   g_sntr_mtfrais              NUMBER (11, 2);
   g_sntr_mtprest_d            NUMBER (11, 2);
   g_sntr_mtremb_d             NUMBER (11, 2);
   g_sntr_mtfrais_d            NUMBER (11, 2);
   g_sntr_datsai               VARCHAR2 (11);
   g_min_datsai                VARCHAR2 (11);
   g_sntr_nbacte               NUMBER (6, 2);
   g_sntr_autrb                NUMBER (10, 2);
   g_sntr_autrb_d              NUMBER (10, 2);
   g_sntr_mtfran               NUMBER (8, 2);
   g_sntr_sens                 NUMBER (1);
   g_flag_remb                 NUMBER (1);
   g_flag_remb_old             NUMBER (1);
   g_sntr_mtmax                NUMBER (10, 2);
   g_sntr_mtreel               NUMBER (11, 2);
   g_sntr_mtreel_d             NUMBER (11, 2);
   g_sntr_numdec               NUMBER (9);
   g_sntr_mtreel_ct            NUMBER (11, 2);
   g_sntr_numgar               NUMBER (7);
   g_sntr_numgar_ref           NUMBER (7);
   g_sntr_idadhesion           NUMBER (7);
   g_sntr_numgar_old           NUMBER (7);
   g_sntr_numgar_ref_old       NUMBER (7);
   g_sntr_idadhesion_old       NUMBER (7);
   g_sntr_numfor               NUMBER (7);
   g_sntr_numfor_old           NUMBER (7);
   g_sntr_numfor_ref           NUMBER (7);
   g_sntr_numfor_ref_old       NUMBER (7);
   g_sntr_numassu              NUMBER (7);
   g_sntr_numassu_old          NUMBER (7);
   g_sntr_numbene              NUMBER (7);
   g_sntr_numdest              NUMBER (9);
                                         -- Destinataire courrier du décompte
   g_sntr_numdest_old          NUMBER (9);
   g_sntr_roledest             NUMBER (3);
                                 -- Role du Destinataire courrier du décompte
   g_sntr_roledest_old         NUMBER (3);
   g_sntr_numbene_old          NUMBER (7);
   g_sntr_username             NUMBER (7);
   g_sntr_numsoc               NUMBER (7);
   g_sntr_numsoc_old           NUMBER (7);
   g_sntr_numorg               NUMBER (7);
   g_sntr_numorg_old           NUMBER (7);
   g_porte_numutil             NUMBER (7);
   g_sntr_username_old         NUMBER (7);
   g_sntr_typbene              NUMBER (2);
   g_sntr_typbene_old          NUMBER (2);
   g_porte_rgltauto            VARCHAR2 (1);
--
   g_porte_trouve              VARCHAR2 (1);
--
   g_sntr_rowid                VARCHAR2 (18);
   g_sum_mtfrais               NUMBER (11, 2);
   g_sum_mtremb                NUMBER (11, 2);
   g_sum_autrb                 NUMBER (10, 2);
   g_sum_mtfrais_d             NUMBER (11, 2);
   g_sum_mtremb_d              NUMBER (11, 2);
   g_sum_autrb_d               NUMBER (10, 2);
   g_sum_mtreel_ct             NUMBER (10, 2);
--
--                       coordonnees d'une franchise ou
--                       d'un plafond annuel de remboursement
--
   g_cal_codfrais              VARCHAR2 (4);
   g_cal_datapli               VARCHAR2 (11);
   g_cal_datper                VARCHAR2 (11);
   g_cal_datref                VARCHAR2 (11);
   g_cal_numfor                NUMBER (7);
   g_cal_typfran               NUMBER (2);
   g_cal_nbactes               NUMBER (3, 2);
   g_cal_montant               NUMBER (11, 2);
   g_cal_numorg                NUMBER (2);
   g_cal_indice                NUMBER (2);
   g_cal_nbindice              NUMBER (5);
   g_cal_taux                  NUMBER (3, 2);
   g_cal_frequence             NUMBER (2);
   g_cal_etendue               NUMBER (2);
   g_cal_domaine               NUMBER (2);
--
--                        coordonnees de la table de travail
--
   g_tmp_mtprest               NUMBER (11, 2);
   g_tmp_mtprest_d             NUMBER (11, 2);
   g_tmp_code1                 NUMBER (1);
   g_tmp_mtfran                NUMBER (8, 2);
   g_tmp_sens                  NUMBER (1);
   g_tmp_reste                 NUMBER (10, 2);
   g_tmp_code2                 NUMBER (1);
   g_tmp_mtmax                 NUMBER (10, 2);
   g_tmp_numsin                NUMBER (10);
   g_test_rib                  NUMBER (10);
--
--
--                        variables
--
--   sntr_numassu_old   =  Variable contenant le numero de l'assure
--             principal faisant l'objet du decompte.
--
--   sntr_numbene_old   =  Variable permettant de gerer la rupture sur le
--             beneficiaire en lecture de la table sinistres.
--
--   sntr_numgar_old    =  Variable permettant de gerer la rupture sur
--             garantie en lecture de la table des sinistres.
--
--   assure    = Numero d'un individu.
--
--   numdec    = Prochain numero de decompte a attribuer.
--
--   cdatapli  = Date d'application de la couverture de
--               l'individu.
--
--   filiat    = Type de filiation unissant l'assure principal
--               a un ayant-droit.
--
--   datsoins  = Date des soins en format europeen.
--
--   result    = Variable contenant le resultat de la
--               procedure de calcul.
--
--   prest     = Montant de la prestation complementaire.
--
--   mtfran    = Franchise a appliquer.
--
--   franat    = Montant de la franchise deja atteinte.
--
--   mtmax     = Plafond annuel de remboursement a appliquer.
--
--   max       = Plafond annuel de remboursement a appliquer.
--
--   maxat     = Montant reel des sinistres deja payes.
--
--   nbacte    = Nombre d'actes deja rembourses.
--
--   nbacte1   = Nombre d'actes a rembourser sur un sinistre quand
--               ce dernier depasse le plafond en nombre d'actes.
--
--   mtind     = Montant d'un indice.
--
--   mtind1    = Montant d'un incice.
--
--   indidate  = Date de reference pour la recherche
--               d'un indice.
--
--   vartr     = Variable de travail.
--
--   nbenrg    = Nombre d'enregistrements ramenes par un 'select'
--               sur la table CRRR1.
--
--   text      = Texte du courrier a editer.
--
--   nbpag     = Nombre de pages editees par decompte.
--
--   monnaie   = Code devise applique au decompte.
--
--   mtregl    = Montant d'un decompte.
--
--   signe     = Variable contenant le signe d'un montant.
--
--   sntr_typbene_old = Variable contenant le type du beneficiaire du decompte
--                        1 = assure
--                        2 = tiers-payant.
--                        3 = pharmacie
--                        4 = hospitaux
--
--   longueur  = Variable contenant le nombre de caracteres du montant
--               du cheque en lettres.
--
   g_assure                    NUMBER (7);
   g_numdec                    NUMBER (9);
   g_result                    NUMBER (7, 2);
   g_prest                     NUMBER (7, 2);
   g_mtfran                    NUMBER (7, 2);
   g_franat                    NUMBER (7, 2);
   g_maxat                     NUMBER (7, 2);
   g_max                       NUMBER (7, 2);
   g_nbacte                    NUMBER (6, 2);
   g_nbacte1                   NUMBER (6, 2);
   g_mtmax                     NUMBER (7, 2);
   g_mtind                     NUMBER (7, 2);
   g_mtind1                    NUMBER (7, 2);
   g_datsoins                  VARCHAR2 (6);
   g_cdatapli                  VARCHAR2 (11);
   g_filiat                    VARCHAR2 (4);
   g_indidate                  VARCHAR2 (11);
   g_text                      VARCHAR2 (60);
   g_signe                     VARCHAR2 (1);
--
   g_vartr                     NUMBER (3);
   g_nbenrg                    NUMBER (5);
--
   g_nbpag                     NUMBER (3);
   g_nbpag_old                 NUMBER (3);
   g_monnaie                   NUMBER (3);
   g_monnaie_old               NUMBER (3);
   g_monnaie_d                 NUMBER (3);
   g_monnaie_old_d             NUMBER (3);
   g_monnaie_ct                NUMBER (3);
   g_monnaie_old_ct            NUMBER (3);
   g_num_dossier               VARCHAR2 (15);
   g_num_dossier_old           VARCHAR2 (15);
   g_mtregl                    NUMBER (11, 2);
   g_mtregl_d                  NUMBER (11, 2);
--
   g_longueur                  NUMBER (2);
   g_idrib                     NUMBER (9);
   g_idtexte                   NUMBER (9);
--
   g_idrib_trouve              VARCHAR2 (1);
--
--
   g_sntr_flagam               VARCHAR (2);
   g_nature_porte              NUMBER (3);
   g_type_circuit              NUMBER (3);
--
-- Flag de commit ou rollback a retourner a Forms
   g_commit                    BOOLEAN                           := FALSE;
   g_rollback                  BOOLEAN                           := FALSE;
   g_auto_valide               BOOLEAN                           := FALSE;
--
   g_flag_test                 NUMBER;
   g_proc                      VARCHAR2 (80);
-- Variables de P_INS_journal
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                           DEFAULT 'pk_gd03B';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_idligne                   journal_adm.idligne%TYPE          := 0;
   g_erreur                    journal_adm.msg_adm%TYPE;

-- G_niv_msg prend les Valeurs :
-- 0 --> Message d'erreurs (Erreur ORACLE)
-- 1 --> Message informatif(tout se passe bien)
-- 2 et + Niveau de detail
---------------------- Fin des variables globales privees --
----------------------------------------------------------------------------
--
-- DEFINITION DES CURSEURS PRIVES ------------------------------------------
--@curs
--
----------------------------------------------------------------------------
/*
------   CURSEUR PRINCIPAL (Sinistres non decomptes)    -----
On ne traite plus qu'un seul curseur pour tous les typbene
(Assures, Tiers-payant, Pharmacies, Hopitaux)
CTT : 20/11/2006 : Pour eviter que des lignes de devis ne soient
decomptees... sntr.sens != -1
*/
   CURSOR c_sntr
   IS
      SELECT   sntr.numsin, '0' num_dossier, sntr.codfrais, ntfrs.rubrique,
               sntr.numgar, grnts.numgar_ref, sntr.idadhesion, sntr.numfor,
               sntr.numindiv, sntr.datsin, sntr.mtprest, sntr.mtremb,
               sntr.mtfrais, trunc(sntr.datsai) datsai, sntr.nbacte, sntr.autrb,
               sntr.mtfran, sntr.sens, sntr.mtmax, sntr.mtreel, sntr.numdec,
               sntr.numassu, sntr.numbene, f_dcpt_dest (sntr.numsin) numdest,
               f_dcpt_roledest (sntr.numsin) roledest, sntr.ROWID,
               sntr.typbene, sntr.username, sntr.flagam,
               (indvs.nom || ' ' || indvs.prenom) nompre,
               grnts.numinterm numsoc, grnts.numorg, frmls.compte,
               f_sntr_remb (sntr.numsin) flag_remb, sntr.monnaie,
                                                                 --prmt.dfdev
               sinistre_dev.dev_out monnaie_d,
               sinistre_dev.mtprest_out mtprest_d,
               sinistre_dev.mtremb_out mtremb_d,
               sinistre_dev.mtfrais_out mtfrais_d,
               sinistre_dev.autrb_out autrb_d,
               sinistre_dev.mtreel_out mtreel_d,
               sinistre_dev.mtreel_ct mtreel_ct,
               sinistre_dev.dev_ct monnaie_ct
          FROM sntr, sinistre_dev, contrat grnts, indvs, frmls, ntfrs, prmt
         WHERE sntr.numdec = 0
           AND sntr.numsin = sinistre_dev.numsin
           AND sntr.codfrais = ntfrs.codfrais
           AND sntr.numgar = grnts.numgar
           AND sntr.username =
                  DECODE (g_param1,
                          1, sntr.username,
                          -1, g_porte_numutil,
                          2, g_porte_numutil, -- PBO Frais de réseaux de soins
                          sntr.username
                         )
           AND sntr.flagam = DECODE (g_param1, -1, 'p', 1, 'a', sntr.flagam)
           AND indvs.numindiv = sntr.numbene
           AND pk_qttc.f_sel_numfor (sntr.numgar, sntr.numfor) + 0 =
                                                                  frmls.numfor
           AND (sntr.sens != -1 OR sntr.sens IS NULL)
      ORDER BY sntr.monnaie,                                    -- prmt.dfdev,
               monnaie_d,
               frmls.compte,
               sntr.typbene,
               numdest,
               roledest,
               grnts.numorg,
               grnts.numcli,
               grnts.numgar,
               indvs.nom,
               sntr.idadhesion,
               flag_remb,
               trunc(sntr.datsai);

--

   ------------------------------------------------------------------
--
-- Le corps des différentes procedures
--
------------------------------------------------------------------
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_gd03b                                                   */
/* Type         :  Public                                                    */
/* Description  :  Sélection et traitement des prestations concernées        */
/* Entree       :  I_numporte, description                                   */
/*                 I_param1, description                                     */
/*                 I_session, description                                    */
/*                 I_niv_msg, description                                    */
/*                 I_pause, description                                      */
/* Entree/Sortie:                                                            */
/* Sortie       :  O_found, description                                      */
/*                 O_erreur, description                                     */
/* Retour       :  sans objet                                                */
/*---------------------------------------------------------------------------*/
   PROCEDURE p_gd03b (
      i_numporte   IN       VARCHAR2 DEFAULT NULL,
      i_param1     IN       VARCHAR2 DEFAULT NULL,
      i_session    IN       NUMBER DEFAULT 1,
      i_niv_msg    IN       NUMBER DEFAULT 1,
      i_pause      IN       NUMBER DEFAULT 0,
      o_found      OUT      NUMBER,
      o_erreur     OUT      VARCHAR2
   )
   IS
      r_sntr   c_sntr%ROWTYPE;
      iderr    VARCHAR2 (2);
   BEGIN
      --
      o_found := 1;
      g_erreur := NULL;
      --
      g_numporte := i_numporte;
      g_param1 := i_param1;
      --
      g_max_msg := i_niv_msg;
      g_session := i_session;

      --G_idligne     := F_max_idligne(I_session => G_session);

      -- OUVERTURE du Curseur
      --
      IF NOT c_sntr%ISOPEN
      THEN
         p_debut_traitement;
      END IF;

   --
   -- LECTURE D'1 Ligne dans la table principale
   --
---------
      LOOP
         FETCH c_sntr
          INTO r_sntr;

         EXIT WHEN c_sntr%NOTFOUND;
         --G_niv_msg := 3;
         --G_msg_adm := 'Fetch numsin = ' || to_char(R_sntr.numsin) ;
         --P_INS_journal;
         o_found := 1;
         --
         iderr := '00';
         g_sntr_numsin := r_sntr.numsin;
         iderr := '01';
         g_num_dossier := r_sntr.num_dossier;
         iderr := '02';
         g_sntr_codfrais := r_sntr.codfrais;
         iderr := '03';
         g_sntr_rubrique := r_sntr.rubrique;
         iderr := '04';
         g_sntr_numgar := r_sntr.numgar;
         iderr := '05';
         g_sntr_numgar_ref := r_sntr.numgar_ref;
         iderr := '06';
         g_sntr_idadhesion := r_sntr.idadhesion;
         iderr := '07';
         g_sntr_numfor := r_sntr.numfor;
         iderr := '08';
         g_sntr_numindiv := r_sntr.numindiv;
         iderr := '09';
         g_sntr_datsin := r_sntr.datsin;
         iderr := '10';
         g_sntr_mtprest := r_sntr.mtprest;
         iderr := '11';
         g_sntr_mtremb := r_sntr.mtremb;
         iderr := '12';
         g_sntr_mtfrais := r_sntr.mtfrais;
         iderr := '13';
         g_sntr_mtprest_d := r_sntr.mtprest_d;
         iderr := '14';
         g_sntr_mtremb_d := r_sntr.mtremb_d;
         iderr := '15';
         g_sntr_mtfrais_d := r_sntr.mtfrais_d;
         iderr := '16';
         g_sntr_datsai := r_sntr.datsai;
         iderr := '17';
         g_sntr_nbacte := r_sntr.nbacte;
         iderr := '18';
         g_sntr_autrb := r_sntr.autrb;
         iderr := '19';
         g_sntr_autrb_d := r_sntr.autrb_d;
         iderr := '20';
         g_sntr_mtfran := r_sntr.mtfran;
         iderr := '21';
         g_sntr_sens := r_sntr.sens;
         iderr := '22';
         g_sntr_mtmax := r_sntr.mtmax;
         iderr := '23';
         g_sntr_mtreel := r_sntr.mtreel;
         iderr := '24';
         g_sntr_mtreel_d := r_sntr.mtreel_d;
         iderr := '25';
         g_sntr_numdec := r_sntr.numdec;
         iderr := '26';
         g_sntr_numassu := r_sntr.numassu;
         iderr := '27';
         g_sntr_numbene := r_sntr.numbene;
         iderr := '28';
         g_sntr_rowid := r_sntr.ROWID;
         iderr := '29';
         g_sntr_typbene := r_sntr.typbene;
         iderr := '30';
         g_sntr_username := r_sntr.username;
         iderr := '31';
         g_sntr_flagam := r_sntr.flagam;
         iderr := '32';
         g_bene_nompre := r_sntr.nompre;
         iderr := '33';
         g_sntr_numsoc := r_sntr.numsoc;
         iderr := '34';
         g_sntr_numorg := r_sntr.numorg;
         iderr := '35';
         g_sntr_idcompte := r_sntr.compte;
         iderr := '36';
         g_flag_remb := r_sntr.flag_remb;
         iderr := '37';
         g_monnaie := r_sntr.monnaie;
         iderr := '38';                                              --dfdev;
         g_monnaie_d := r_sntr.monnaie_d;
         iderr := '39';
         g_sntr_numdest := r_sntr.numdest;
         iderr := '40';
         g_sntr_roledest := r_sntr.roledest;
         iderr := '41';
         g_sntr_mtreel_ct := r_sntr.mtreel_ct;
         iderr := '42';
         g_monnaie_ct := r_sntr.monnaie_ct;
         --
         iderr := '43';
         -- Alimentation  des variables G_nature_porte et G_type_circuit
         p_get_porte_param;
         p_traitement_principal;
      END LOOP;

      g_niv_msg := 3;
      g_msg_adm := 'Fin Curseur';
      p_ins_journal;
---------
      o_found := 0;
      p_fin_traitement;
      o_erreur := g_erreur;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
	     rollback;
         g_niv_msg := 0;
         g_msg_adm :=
                 'PK_GD03B - ' || iderr || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         o_erreur := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;

         -- FERMETURE du Curseur jpf 06/11/2004
         CLOSE c_sntr;
   END;
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Traitement_principal                                    */
/* Type         :  Privé                                                     */
/* Description  :  Gestion de l'en-tête, gestion du sinistre                 */
/* Entree       :                                                            */
/* Entree/Sortie:                                                            */
/* Sortie       :                                                            */
/* Retour       :  sans objet                                                */
/*---------------------------------------------------------------------------*/

   PROCEDURE p_traitement_principal
   IS
   BEGIN
      IF g_trait_entete IS NULL
      THEN
---------
      /*G_niv_msg := 3;
      G_msg_adm   := 'Jalon 2a';
      P_INS_journal;*/
---------
      --
         p_entete_decompte;
         --
         g_trait_entete := '1';
      --
      END IF;

---------
      /*G_niv_msg := 3;
      G_msg_adm   := 'Jalon 2b';
      P_INS_journal;*/
---------
      p_ligne_sntr;
   END p_traitement_principal;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ENTETE_decompte                                         */
/* Type         :  Privé                                                     */
/* Description  :  Gestion des paramètres globaux                            */
/* Entree       :                                                            */
/* Entree/Sortie:                                                            */
/* Sortie       :                                                            */
/* Retour       :  sans objet                                                */
/*---------------------------------------------------------------------------*/
   PROCEDURE p_entete_decompte
   IS
   BEGIN
--
      g_proc := 'P_ENTETE_decompte';

--
   --  Attribution prochain numero de decompte
/* ACA 16082010 M3224
     Ajout d'une séquence pour le numéro de décompte
     SELECT NVL(MAX(numdec),0)+1
     INTO   G_numdec
     FROM   dcpt;*/
     SELECT NUMDEC.nextval
     INTO   G_numdec
     FROM   dual;
/* ACA fin */

      --
      g_niv_msg := 3;
      g_msg_adm := 'P_ENTETE_decompte, numdec=' || g_numdec;
      p_ins_journal;

      SELECT client
        INTO g_client
        FROM parametres;

   --
   /*IF G_client = 2 --mis en commentaire par JPF 17062004 par demande GLB/PN
      THEN
         G_idtexte := f_idtexte(2,G_sntr_numgar,28,'','','');
         IF G_idtexte IS NULL
            THEN
               G_niv_msg := 2;
          G_msg_adm :=
         'Le texte d`édition des décomptes maladie pour le contrat '
         ||G_sntr_numgar||', n`a pas été validé.';
          P_INS_journal;
          -- Fin ecriture dans le Journal
          G_niv_msg  := 2;
          G_msg_adm  := 'Le décompte N° ' ||G_numdec|| ' ne sera pas édité.';
          P_INS_journal;
          -- Fin ecriture dans le Journal
         END IF;
   END IF;*/
   --
---------
/*    G_niv_msg   := 3;
      G_msg_adm   := 'Jalon 3';
      P_INS_journal;*/
---------
      p_rech_modpmt;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END p_entete_decompte;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_LIGNE_sntr                                              */
/* Type         :  Privé                                                     */
/* Description  :  Gestion des ruptures, mise à jour des courriers et des    */
/*              :  sinistres                                                 */
/* Entree       :                                                            */
/* Entree/Sortie:                                                            */
/* Sortie       :                                                            */
/* Retour       :  sans objet                                                */
/*---------------------------------------------------------------------------*/
   PROCEDURE p_ligne_sntr
   IS
      iderrl   VARCHAR2 (2);
   BEGIN
--
      g_proc := 'P_LIGNE_sntr';
      g_niv_msg := 3;
      g_msg_adm := 'Traitement ligne - NUMSIN=' || g_sntr_numsin;
      p_ins_journal;

--
   -- Rupture sur devise
      IF g_monnaie_old != g_monnaie
      THEN
         g_niv_rupt := 1;
         p_pied_decompte;
         p_entete_decompte;
      -- Rupture sur devise_d
      ELSIF g_monnaie_old_d != g_monnaie_d
      THEN
         g_niv_rupt := 2;
         p_pied_decompte;
         p_entete_decompte;
      -- Rupture sur numero de compte
      ELSIF g_sntr_idcompte_old != g_sntr_idcompte
      THEN
         g_niv_rupt := 3;
         p_pied_decompte;
         p_entete_decompte;
      -- Rupture sur numero de beneficiaire
      ELSIF g_sntr_numbene_old != g_sntr_numbene
      THEN
         g_niv_rupt := 4;
         p_pied_decompte;
         p_entete_decompte;
      -- Rupture sur numero de destinataire
      ELSIF g_sntr_numdest_old != g_sntr_numdest
      THEN
         g_niv_rupt := 5;
         p_pied_decompte;
         p_entete_decompte;
      -- Rupture sur le role du destinataire
      ELSIF g_sntr_roledest_old != g_sntr_roledest
      THEN
         g_niv_rupt := 6;
         p_pied_decompte;
         p_entete_decompte;
      -- Rupture sur numero d'adhesion  ( 28/02/2007 ctt : mais pas de rupture si Tiers Payant Etendu)
      ELSIF g_sntr_idadhesion_old != g_sntr_idadhesion
      THEN
         IF g_nature_porte != 3
         THEN
            g_niv_rupt := 7;
            p_pied_decompte;
            p_entete_decompte;
         END IF;
      -- Rupture sur flag_remb
      ELSIF g_flag_remb_old != g_flag_remb
      THEN
         g_niv_rupt := 8;
         p_pied_decompte;
         p_entete_decompte;
      END IF;

      -- Manu le 30/12/NUMBER(1)7 Ajout rupture sur numgar pour la porte 3 Cetip.
      -- Manu le 31/03/NUMBER(2) Bug ent_valdeb1 et non ent_valdeb3
      -- ctt 28/02/2007 : Rupture si Cetip
      -- ctt 27/06/2007 : IF G_sntr_flagam = 'p' AND G_type_circuit = 2 AND G_nature_porte !=  3 : le test sur la nature inutile
      -- PBO 08/10/2020 : g_param1 = 2 pour les frais de réseaux de soins
      IF g_sntr_flagam = 'p' AND g_type_circuit = 2 OR g_param1 = 2
      THEN
         -- Rupture sur numero de contrat
         IF g_sntr_numgar_old != g_sntr_numgar
         THEN
            g_niv_rupt := 9;
            p_pied_decompte;
            p_entete_decompte;
         END IF;
      END IF;

      --
      g_niv_msg := 3;
      g_msg_adm := 'Traitement ligne Av MAJ MT';
      p_ins_journal;
      g_tmp_mtprest := g_sntr_mtreel;
      g_tmp_mtprest_d := g_sntr_mtreel_d;
      g_tmp_code1 := 0;
      g_tmp_mtfran := 0;
      g_tmp_sens := 0;
      g_tmp_reste := 0;
      g_tmp_code2 := 0;
      g_tmp_mtmax := 0;
      g_tmp_numsin := g_sntr_numsin;
      g_tmp_mtprest := g_tmp_mtprest + g_mtregl;
      g_tmp_mtprest_d := g_tmp_mtprest_d + g_mtregl_d;
      --
      /*IF G_tmp_sens != 1
        THEN
           G_tmp_mtprest := G_tmp_mtprest + G_tmp_mtfran;
      ELSE
           G_tmp_mtprest := G_tmp_mtprest - G_tmp_mtfran;
      END IF;   JPF 13/10/2004*/
      --
      g_niv_msg := 3;
      g_msg_adm := 'Traitement ligne Av MAJ SUM';
      p_ins_journal;
      g_niv_msg := 3;
      g_msg_adm := 'NUMSIN=' || g_sntr_numsin;
      p_ins_journal;
      g_mtregl := g_tmp_mtprest - g_tmp_mtmax;
      iderrl := '01';
      g_mtregl_d := g_tmp_mtprest_d - g_tmp_mtmax;
      iderrl := '02';
      --
      g_sum_mtfrais := g_sum_mtfrais + g_sntr_mtfrais;
      iderrl := '03';
      g_sum_mtremb := g_sum_mtremb + g_sntr_mtremb;
      iderrl := '04';
      g_sum_autrb := g_sum_autrb + g_sntr_autrb;
      iderrl := '05';
      g_sum_mtfrais_d := g_sum_mtfrais_d + g_sntr_mtfrais_d;
      iderrl := '06';
      g_sum_mtremb_d := g_sum_mtremb_d + g_sntr_mtremb_d;
      iderrl := '07';
      g_sum_autrb_d := g_sum_autrb_d + g_sntr_autrb_d;
      iderrl := '08';
      g_sum_mtreel_ct := g_sum_mtreel_ct + g_sntr_mtreel_ct;
      g_niv_msg := 3;
      g_msg_adm := 'Traitement ligne Apres MAJ SUM';
      p_ins_journal;

-- --------------------------------------------------------------------------
--  On met a jour Courrier de l'acte
--  --------------------------------------------------------------------------
      UPDATE crrr
         SET crrr.numdec = g_numdec
       WHERE crrr.numsin = g_sntr_numsin
         AND crrr.numdec = 0
         AND crrr.text IS NOT NULL;

-- --------------------------------------------------------------------------
-- On met a jour le courrier individuel
-- --------------------------------------------------------------------------
      UPDATE crrr
         SET crrr.numdec = g_numdec
       WHERE crrr.numdec = 0
         AND (   crrr.numindiv = g_sntr_numindiv
              OR crrr.numindiv = f_numassu (g_sntr_numindiv)
             )
         AND crrr.codfrais IS NULL
         AND crrr.datsin IS NULL
         AND crrr.numsin IS NULL
         AND crrr.text IS NOT NULL;

-- --------------------------------------------------------------------------
-- On met a jour l'enregistrement de la table sinistre qui
-- correspond au sinistre traite.
-- --------------------------------------------------------------------------
      UPDATE sntr
         SET sntr.mtfran = g_sntr_mtfran,
             sntr.sens = g_sntr_sens,
             sntr.mtmax = g_sntr_mtmax,
             sntr.numdec = g_numdec
       WHERE sntr.ROWID = g_sntr_rowid;

      /* Pour Do decompte SS */
      UPDATE sinistre_dev
         SET numdec = g_numdec,
             numindiv = g_sntr_numindiv
       WHERE numsin = g_sntr_numsin;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
               iderrl
            || '-'
            || TO_CHAR (SQLCODE)
            || '-'
            || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END p_ligne_sntr;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_PIED_decompte                                           */
/* Type         :  Privé                                                     */
/* Description  :  Gestion des indus de prestations suite rupture sur les    */
/*              :  sinistres                                                 */
/* Entree       :                                                            */
/* Entree/Sortie:                                                            */
/* Sortie       :                                                            */
/* Retour       :  sans objet                                                */
/*---------------------------------------------------------------------------*/
   PROCEDURE p_pied_decompte
   IS
   BEGIN
--
      g_proc := 'P_PIED_decompte';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_PIED_Decompte- rupture sur num ' || g_niv_rupt;
      p_ins_journal;

      -- Gestion des indus
      IF g_mtregl < 0 AND g_flag_remb_old = 1
      THEN
         p_pas_retention;
         g_niv_msg := 3;
         g_msg_adm :=
                   'G_mtregl < 0 and G_flag_remb_old = 1 >> Vers P_retention';
         p_ins_journal;
      ELSE
         -- Ctt 28/06/2007 Reprise modif Août 2006 : pas de seuil de rétention pour le tiers payant
         IF g_type_circuit = 2
         THEN
            p_pas_retention;
            g_niv_msg := 3;
            g_msg_adm := 'Vers P_pas_retention';
            p_ins_journal;
         ELSE
            IF    g_mtregl < 0
               OR f_param_ope_valide (g_sntr_numgar_ref_old,
                                      1,
                                      g_bene_modpmt_old,
                                      1,
                                      g_mtregl,
                                      g_min_datsai
                                     ) = 0
            THEN
               p_retention;
               g_niv_msg := 3;
               g_msg_adm :=
                   'G_mtregl < 0 OR f_param_ope_valide=0 >> Vers P_retention';
               p_ins_journal;
            ELSE
               p_pas_retention;
               g_niv_msg := 3;
               g_msg_adm := 'Vers P_pas_retention';
               p_ins_journal;
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END p_pied_decompte;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_retention                                               */
/* Type         :  Privé                                                     */
/* Description  :  Retour en arrière                                         */
/* Entree       :                                                            */
/* Entree/Sortie:                                                            */
/* Sortie       :                                                            */
/* Retour       :  sans objet                                                */
/*---------------------------------------------------------------------------*/
   PROCEDURE p_retention
   IS
   BEGIN
--
      g_proc := 'P_retention';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_retention';
      p_ins_journal;

      UPDATE sinistre
         SET numdec = 0
       WHERE numdec = g_numdec;

      UPDATE sinistre_dev
         SET numdec = 0
       WHERE numdec = g_numdec;

--
      UPDATE crrr
         SET numdec = 0
       WHERE numdec = g_numdec;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END p_retention;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_pas_retention                                           */
/* Type         :  Privé                                                     */
/* Description  :  Création du décompte, de l'affectation et du décaissement */
/* Entree       :                                                            */
/* Entree/Sortie:                                                            */
/* Sortie       :                                                            */
/* Retour       :  sans objet                                                */
/*---------------------------------------------------------------------------*/
   PROCEDURE p_pas_retention
   IS
   l_rgltauto            VARCHAR2 (1);
   BEGIN
--
    g_proc := 'P_pas_retention';
--
    g_niv_msg := 3;
    g_msg_adm := 'P_pas_retention';
    p_ins_journal;

  --ABO 02/08/2011 gestion de la devise
  IF G_bene_modpmt_trouve = 'D' Then
    G_bene_modpmt	:= 3;
    G_niv_msg		:= 1;
    G_msg_adm		:= 'Le mode de paiement du bénéficiaire N° ' ||G_sntr_numbene_old||' n''est pas valide.';
    P_INS_journal;
     -- Fin ecriture dans le Journal

     P_retention;

  ELSE
      INSERT INTO dcpt
                  (numdec, numindiv, montant, montant_d,
                   datpay, modpmt, typbene,
                   numbene, monnaie, monnaie_d,
                   nbfeuille, numgar, mtfrais,
                   mtfrais_d, mtremb, mtremb_d,
                   autrb, autrb_d, numutil, numdcptcie,
                   numdest, roledest, montant_ct,
                   devise_ct
                  )
           VALUES (g_numdec, g_sntr_numassu_old, g_mtregl, g_mtregl_d,
                   TRUNC (SYSDATE), g_bene_modpmt_old, g_sntr_typbene_old,
                   g_sntr_numbene_old, g_monnaie_old, g_monnaie_old_d,
                   g_nbpag_old, g_sntr_numgar_old, g_sum_mtfrais,
                   g_sum_mtfrais_d, g_sum_mtremb, g_sum_mtremb_d,
                   g_sum_autrb, g_sum_autrb_d, g_sntr_username_old, 0,
                   g_sntr_numdest_old, g_sntr_roledest_old, g_sum_mtreel_ct,
                   g_monnaie_old_ct
                  );
      -- M0005311: PHA 17/05/2017
      -- il faut au moins un sinistre importé pour prendre en compte le règlement paramétré
      IF g_param1 = 0 THEN
        BEGIN
          SELECT DISTINCT porte_param.rgltauto
                 INTO l_rgltauto
            FROM porte_param , sinistre
            WHERE porte_param.numutil = username
              AND numdec = g_numdec
              AND flagam = 'p' ;

        EXCEPTION
           WHEN OTHERS THEN l_rgltauto := g_porte_rgltauto;
        END;
      ELSE
         l_rgltauto := g_porte_rgltauto;
      END IF;
--
      IF g_mtregl < 0
      OR l_rgltauto = 'N' -- g_porte_rgltauto = 'N'
      OR g_param1 = 2   -- PBO Frais de réseaux de soins: on ne crée que l’affectation et pas le décaissement
      THEN
         p_pas_decaismt;
      ELSE
--
    /*SELECT   (nvl(Max(numdecaismt),0) + 1)
   INTO  G_numdecaismt
   FROM  DECAISMT;   -- JPF 01/03/2006*/
--
         SELECT numdecaismt.NEXTVAL
           INTO g_numdecaismt
           FROM DUAL;

         INSERT INTO decaismt
                     (numdecaismt, codope, numcpte, montant,
                      montant_d, monnaie, monnaie_d, debit,
                      typbene, numbene,
                      modpmt,
                      numutil,
                      numedit, numdest, refpmt,
                      datpay,
                      numchq, montant_ct,
                      devise_ct
                     )
              VALUES (g_numdecaismt, 1, g_sntr_idcompte_old, g_mtregl,
                      g_mtregl_d, g_monnaie_old, g_monnaie_old_d, 0,
                      g_sntr_typbene_old, g_sntr_numbene_old,
                      g_bene_modpmt_old,
                      DECODE (f_valid (1, g_sntr_idcompte_old, g_mtregl),
                              0, 0,
                              -1
                             ),
                      0, g_sntr_numbene_old, DECODE (g_mtregl, 0, 0, NULL),
                                                             -- JPF 19/04/2005
                      DECODE (g_mtregl, 0, TRUNC (SYSDATE), NULL),
                      DECODE (g_mtregl, 0, 0, NULL), g_sum_mtreel_ct,
                      g_monnaie_old_ct
                     );

--
         INSERT INTO affectation
                     (numdecaismt, codope, numaffec, montant,
                      montant_d, monnaie, monnaie_d,
                      nbfeuille, dataffec, numcli,
                      montant_ct, devise_ct
                     )
              VALUES (g_numdecaismt, 1, NVL (g_numdec, 1), g_mtregl,
                      g_mtregl_d, g_monnaie_old, g_monnaie_old_d,
                      g_nbpag_old, TRUNC (SYSDATE), g_sntr_numbene_old,
                      g_sum_mtreel_ct, g_monnaie_old_ct
                     );
--
      END IF;
--
  END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END p_pas_retention;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Pas_decaismt                                            */
/* Type         :  Privé                                                     */
/* Description  :  Création de l'affectation seule                           */
/* Entree       :                                                            */
/* Entree/Sortie:                                                            */
/* Sortie       :                                                            */
/* Retour       :  sans objet                                                */
/*---------------------------------------------------------------------------*/
   PROCEDURE p_pas_decaismt
   IS
   BEGIN
--
      g_proc := 'P_Pas_decaismt';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_Pas_decaismt';
      p_ins_journal;
      g_numdecaismt := NULL;

      INSERT INTO affectation
                  (numdecaismt, codope, numaffec, montant,
                   montant_d, monnaie, monnaie_d, nbfeuille,
                   dataffec, numcli, montant_ct,
                   devise_ct
                  )
           VALUES (g_numdecaismt, 1, NVL (g_numdec, 1), g_mtregl,
                   g_mtregl_d, g_monnaie_old, g_monnaie_old_d, g_nbpag_old,
                   TRUNC (SYSDATE), g_sntr_numbene_old, g_sum_mtreel_ct,
                   g_monnaie_old_ct
                  );
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END p_pas_decaismt;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_rech_modpmt                                             */
/* Type         :  Privé                                                     */
/* Description  :  Recherche du mode de paiement du bénéficiaire             */
/* Entree       :                                                            */
/* Entree/Sortie:                                                            */
/* Sortie       :                                                            */
/* Retour       :  sans objet                                                */
/*---------------------------------------------------------------------------*/
   PROCEDURE p_rech_modpmt
   IS
   BEGIN
--
      g_proc := 'P_rech_modpmt';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_rech_modpmt';
      p_ins_journal;
   Begin
		G_idrib_trouve 		:= 'O';
    G_bene_modpmt_trouve	:= 'O';

    -- ABO 02/08/2011 on contrôle la devise, si non trouvé on essaye sans devise pour laissé passé les montants en erreur (négatif)
    G_idrib := f_bene_rib(G_sntr_numbene,1,G_sntr_numgar_ref,1,G_monnaie_d,sysdate); -- ACA 01/03/2011


    IF G_idrib = 0 THEN

      G_idrib := f_bene_rib(G_sntr_numbene,1,G_sntr_numgar_ref,1,null,sysdate);
      G_bene_modpmt_trouve	:= 'D';
      G_idrib_trouve 		:= 'O';
     END IF;

	Exception
	  When no_data_found then
		G_idrib 		:= Null;
		G_idrib_trouve 		:= 'N';
		G_bene_modpmt_trouve	:= 'N';
	End;

  IF G_idrib = 0 THEN
   	G_idrib 		:= Null;
		G_idrib_trouve 		:= 'N';
		G_bene_modpmt_trouve	:= 'N';
  END IF;

--
      IF g_idrib_trouve = 'O'
      THEN
         BEGIN
            g_bene_modpmt_trouve := 'O';

            SELECT modpmt
              INTO g_bene_modpmt
              FROM rib
             WHERE idrib = g_idrib;
---
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               g_bene_modpmt_trouve := 'N';
               g_bene_modpmt := NULL;
         END;

---
-- La fonction f_rib_valide gere l'exception no_data_found (retour =0) !
---
         IF    f_rib_valide (g_idrib) IN (1,2)
            OR g_bene_modpmt = 3           --avant G_bene_modpmt=1 passait tjs
         THEN
            IF g_bene_modpmt = 1 AND g_monnaie <> g_monnaie_d
            THEN
               g_bene_modpmt_trouve := 'N';
            ELSE
               g_min_datsai := g_sntr_datsai;
               g_monnaie_old := g_monnaie;
               g_num_dossier_old := g_num_dossier;
               g_monnaie_old_d := g_monnaie_d;
               g_sntr_idcompte_old := g_sntr_idcompte;
               g_sntr_numassu_old := g_sntr_numassu;
               g_sntr_numbene_old := g_sntr_numbene;
               g_sntr_numdest_old := g_sntr_numdest;
               g_sntr_roledest_old := g_sntr_roledest;
               g_sntr_numsoc_old := g_sntr_numsoc;
               g_sntr_numorg_old := g_sntr_numorg;
               g_sntr_numgar_old := g_sntr_numgar;
               g_sntr_numgar_ref_old := g_sntr_numgar_ref;
               g_sntr_idadhesion_old := g_sntr_idadhesion;
               g_sntr_typbene_old := g_sntr_typbene;
               g_sntr_username_old := g_sntr_username;
               g_flag_remb_old := g_flag_remb;
               g_bene_modpmt_old := g_bene_modpmt;
               g_nbpag_old := g_nbpag;
               g_mtregl := 0;
               g_sum_mtfrais := 0;
               g_sum_mtremb := 0;
               g_sum_autrb := 0;
               g_mtregl_d := 0;
               g_sum_mtfrais_d := 0;
               g_sum_mtremb_d := 0;
               g_sum_autrb_d := 0;
               g_nbpag := 0;
               g_sum_mtreel_ct := 0;
               g_monnaie_old_ct := g_monnaie_ct;

               -- ajout SEPA si BIC non renseigné
               IF f_rib_valide (g_idrib) = 2 AND g_sntr_mtreel> 0 THEN -- 25/10/2013 : si indus alors pas affichage du message
                 g_niv_msg := 1;
                 g_msg_adm :=
                   'Le bic pour le bénéficiaire N° '
                    || g_sntr_numbene
                    || ', '
                    || g_bene_nompre
                    || ' est invalide.';
               p_ins_journal;
               END IF;
            END IF;
         ELSE
            g_bene_modpmt_trouve := 'N';
         END IF;
      END IF;

--
      IF g_bene_modpmt_trouve = 'N'
      THEN
         g_bene_modpmt := 3;
         g_niv_msg := 1;
         g_msg_adm :=
               'Le mode de paiement du bénéficiaire N° '
            || g_sntr_numbene
            || ', '
            || g_bene_nompre
            || ' n''est pas valide.';
         p_ins_journal;
         -- Fin ecriture dans le Journal
         g_niv_msg := 1;
         g_msg_adm :=
               'Le décompte N° '
            || g_numdec
            || ' sera donc réglé par chèque manuel.';
         p_ins_journal;
         -- Fin ecriture dans le Journal

         /* JPF 07/01/2005 rajout par JPF */
         g_min_datsai := g_sntr_datsai;
         g_monnaie_old := g_monnaie;
         g_num_dossier_old := g_num_dossier;
         g_monnaie_old_d := g_monnaie_d;
         g_sntr_idcompte_old := g_sntr_idcompte;
         g_sntr_numassu_old := g_sntr_numassu;
         g_sntr_numbene_old := g_sntr_numbene;
         g_sntr_numdest_old := g_sntr_numdest;
         g_sntr_roledest_old := g_sntr_roledest;
         g_sntr_numsoc_old := g_sntr_numsoc;
         g_sntr_numorg_old := g_sntr_numorg;
         g_sntr_numgar_old := g_sntr_numgar;
         g_sntr_numgar_ref_old := g_sntr_numgar_ref;
         g_sntr_idadhesion_old := g_sntr_idadhesion;
         g_sntr_typbene_old := g_sntr_typbene;
         g_sntr_username_old := g_sntr_username;
         g_flag_remb_old := g_flag_remb;
         g_bene_modpmt_old := g_bene_modpmt;
         g_nbpag_old := g_nbpag;
         g_mtregl := 0;
         g_sum_mtfrais := 0;
         g_sum_mtremb := 0;
         g_sum_autrb := 0;
         g_mtregl_d := 0;
         g_sum_mtfrais_d := 0;
         g_sum_mtremb_d := 0;
         g_sum_autrb_d := 0;
         g_nbpag := 0;
         g_sum_mtreel_ct := 0;
         g_monnaie_old_ct := g_monnaie_ct;
      END IF;

--
      g_niv_msg := 3;
      g_msg_adm :=
            'P_rech_modpmt : Numbene='
         || g_sntr_numbene
         || ', Idrib='
         || g_idrib
         || ', Mopmt='
         || g_bene_modpmt;
      p_ins_journal;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END p_rech_modpmt;

--

   -- ----------------------------------------------------------------------------------------
--
-- DEBUT ET FIN DU TRAITEMENT
--
-- ----------------------------------------------------------------------------------------
   PROCEDURE p_debut_traitement
   IS
   BEGIN
--
      g_proc := 'P_debut_traitement';
--
      g_niv_msg := 1;
      g_msg_adm :=
         'Debut de traitement le ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;

   -- Fin ecriture dans le Journal
---
      BEGIN
         g_prmt_trouve := 'O';

         SELECT prmt.mdvrt, prmt.mdchq, prmt.dfdev
           INTO g_prmt_mdvrt, g_prmt_mdchq, g_prmt_dfdev
           FROM prmt;
---
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            g_prmt_trouve := 'N';
            g_prmt_mdvrt := NULL;
            g_prmt_mdchq := NULL;
            g_prmt_dfdev := NULL;
      END;

---
      BEGIN
         g_porte_trouve := 'O';

         SELECT porte_param.numutil, porte_param.rgltauto
           INTO g_porte_numutil, g_porte_rgltauto
           FROM porte_param
          WHERE porte_param.numporte = g_numporte;
---
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            g_porte_trouve := 'N';
            g_porte_numutil := NULL;
            g_porte_rgltauto := NULL;
      END;

---
      OPEN c_sntr;

      g_trait_entete := NULL;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END p_debut_traitement;

--
-- -----------------------
   PROCEDURE p_fin_traitement
   IS
   BEGIN
--
      g_proc := 'P_fin_traitement';

--
      IF g_trait_entete IS NOT NULL
      THEN
         p_pied_decompte;
      END IF;

      --
      -- FERMETURE du Curseur
      --
      CLOSE c_sntr;

      --
      g_niv_msg := 1;
      g_msg_adm :=
            'Fin Normale du traitement le '
         || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;
   -- Fin ecriture dans le Journal
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END p_fin_traitement;

--
----------------------- Fin des procedures publiques ------------------

   -- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
   PROCEDURE p_ins_journal
   IS
      l_idligne   NUMBER;
   BEGIN
--
      IF (g_niv_msg <= g_max_msg)
      THEN
         g_idligne := g_idligne + 1;

         IF (g_niv_msg = 0)
         THEN
            l_idligne := -1 * g_idligne;
         ELSE
            l_idligne := g_idligne;
         END IF;

         pk_trace.p_ins_journal_adm (i_nom_traitement      => g_nom_traitement,
                                     i_session             => g_session,
                                     i_niv_msg             => g_niv_msg,
                                     i_msg_adm             => g_msg_adm,
                                     i_idligne             => l_idligne
                                    );
      END IF;
--
   END p_ins_journal;

--
-- Procédure de recherche de la nature et type de circuit de la porte
--
   PROCEDURE p_get_porte_param
   IS
   BEGIN
      SELECT nat_porte, type_circuit
        INTO g_nature_porte, g_type_circuit
        FROM sntr_ref, sinistre_porte, porte_param
       WHERE sntr_ref.numsin = g_sntr_numsin
         AND sntr_ref.numsin_porte = sinistre_porte.numsin
         AND sinistre_porte.numporte = porte_param.numporte
         AND sinistre_porte.numremise = sntr_ref.numremise;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         g_nature_porte := 0;
         g_type_circuit := 0;
   END p_get_porte_param;
---------------- Fin des corps des procedures privees --
END;
/
