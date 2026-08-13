CREATE OR REPLACE PACKAGE ARTHUS.pk_gdp8b
AS
  /*===========================================================================*/
  /* Vue          : PACKAGE PK_GDP8B                                           */
  /* Domaine      : Prestation Santé                                           */
  /* Version      : V1.0                                                       */
  /* Auteur       : Arthus                                                     */
  /* Création     : DD/MM/AAAA                                                 */
  /* Description  : Tt. constit. dde de rembt prestations soins santé          */
  /*===========================================================================*/
  /* Evolution    :                                                            */
  /* Auteur       :                                                            */
  /* Date         :                                                            */
  /* Commentaire  :                                                            */
  /*===========================================================================*/
  /* Correction   : PHA / Mantis 4574 : Gestion unicité numdcptcie             */
  /*===========================================================================*/
--
   PROCEDURE p_gdp8b (
      i_deb_numsoc   IN       contrat.numinterm%TYPE DEFAULT NULL,
      i_fin_numsoc   IN       contrat.numinterm%TYPE DEFAULT NULL,
      i_deb_numorg   IN       contrat.numorg%TYPE DEFAULT NULL,
      i_fin_numorg   IN       contrat.numorg%TYPE DEFAULT NULL,
      i_deb_refcie   IN       contrat.refcie_chapeau%TYPE DEFAULT NULL,
      i_fin_refcie   IN       contrat.refcie_chapeau%TYPE DEFAULT NULL,
      i_deb_numgar   IN       contrat.numgar%TYPE DEFAULT NULL,
      i_fin_numgar   IN       contrat.numgar%TYPE DEFAULT NULL,
      i_deb_datbut   IN       DATE DEFAULT NULL,
      i_fin_datbut   IN       DATE DEFAULT NULL,
      i_param1       IN       NUMBER DEFAULT 0,
      i_session      IN       NUMBER DEFAULT 1,
      i_niv_msg      IN       NUMBER DEFAULT 1,
      i_pause        IN       NUMBER DEFAULT 0,
      o_found        OUT      NUMBER,
      o_erreur       OUT      VARCHAR2
   );
--


-- 08/06/2010 : pha
-- correction des ruptures et ajout d'une mise à jour des sinistres à 0 lorsque le décompte en'estpas créé (étant négatif)
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
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_gdp8b
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
   PROCEDURE p_corps_traitement;

--
   PROCEDURE p_entete_traitement;

--
   PROCEDURE p_pied_montant;

--
   PROCEDURE p_pied_ref_cptcie;

--
   PROCEDURE p_pied_ref_cptcie_negatif;

--
   PROCEDURE p_next_numdcptcie;

--
   PROCEDURE p_insert_dcptcie;

--
   PROCEDURE p_update_sinistre;

--
   PROCEDURE p_update_sinistre_annul;

--
   PROCEDURE P_update_decaismt; -- ACA 18082010

--
   PROCEDURE P_update_pnul;     -- ACA 18082010

--
   PROCEDURE p_sinistre_maj;

--
   PROCEDURE p_sinistre_annul_maj;

--
   PROCEDURE p_ins_journal;

--
   PROCEDURE p_fin_traitement;

--
-- ----------------------------- Fin des declarations des procedures privees --

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
-- Aucune
-- ---------------------------------- Fin des corps des procedures publiques --
--
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --

   -- Variables globales privées
--
   g_numdcptcie                NUMBER                            := 1;
   g_codope_cie                NUMBER                            := 12;
--
-- parametres du traitement
   g_numsoc_deb                contrat.numinterm%TYPE;
   g_numsoc_fin                contrat.numinterm%TYPE;
   g_numorg_deb                contrat.numorg%TYPE;
   g_numorg_fin                contrat.numorg%TYPE;
   g_refcie_deb                contrat.refcie_chapeau%TYPE;
   g_refcie_fin                contrat.refcie_chapeau%TYPE;
   g_numgar_deb                contrat.numgar%TYPE;
   g_numgar_fin                contrat.numgar%TYPE;
   g_date_butoir               compte_client.datope%TYPE;
-- variables traitement
   g_init                      BOOLEAN                           := FALSE;
   g_societe                   contrat.numinterm%TYPE;
   g_garantie                  v_assur_delegat.numfor%TYPE;
   g_ass_contrat               contrat.numorg%TYPE;
   g_ass_garantie              v_assur_delegat.numass%TYPE;
   g_decompte                  dcpt.numdec%TYPE;
   g_montant                   dcpt.montant%TYPE;
   g_monnaie                   dcpt.monnaie%TYPE;
   g_montant_d                 dcpt.montant_d%TYPE;
   g_monnaie_d                 dcpt.monnaie_d%TYPE;
   g_mnt_total                 dcpt.montant%TYPE;
   g_mnt_tot_d                 dcpt.montant%TYPE;
   g_pre_numsoc                contrat.numinterm%TYPE;
   g_pre_gar                   v_assur_delegat.numfor%TYPE;
   g_pre_numass                v_assur_delegat.numass%TYPE;
   g_pre_decompte              dcpt.numdec%TYPE;
   g_numutil                   utilisateurs.numutil%TYPE         := f_numutil;
-- ACA 18082010
   g_decaismt                  decaismt.numdecaismt%type;
   g_pnul                        pnul.numdecaismt%type;
-- ACA fin
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
                                                           DEFAULT 'pk_gdp8b';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_idligne                   journal_adm.idligne%TYPE          := 0;
   g_erreur                    journal_adm.msg_adm%TYPE;
   g_rowcount                  NUMBER                            := 0;

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
-- CTT 31/03/2005

   ------------------------------------------------------------------
--
-- Le corps des différentes procedures
--
------------------------------------------------------------------
--
--
   PROCEDURE p_gdp8b (
      i_deb_numsoc   IN       contrat.numinterm%TYPE DEFAULT NULL,
      i_fin_numsoc   IN       contrat.numinterm%TYPE DEFAULT NULL,
      i_deb_numorg   IN       contrat.numorg%TYPE DEFAULT NULL,
      i_fin_numorg   IN       contrat.numorg%TYPE DEFAULT NULL,
      i_deb_refcie   IN       contrat.refcie_chapeau%TYPE DEFAULT NULL,
      i_fin_refcie   IN       contrat.refcie_chapeau%TYPE DEFAULT NULL,
      i_deb_numgar   IN       contrat.numgar%TYPE DEFAULT NULL,
      i_fin_numgar   IN       contrat.numgar%TYPE DEFAULT NULL,
      i_deb_datbut   IN       DATE DEFAULT NULL,
      i_fin_datbut   IN       DATE DEFAULT NULL,
      i_param1       IN       NUMBER DEFAULT 0,
      i_session      IN       NUMBER DEFAULT 1,
      i_niv_msg      IN       NUMBER DEFAULT 1,
      i_pause        IN       NUMBER DEFAULT 0,
      o_found        OUT      NUMBER,
      o_erreur       OUT      VARCHAR2
   )
   IS
      CURSOR c_sel_dcpt
      IS
------------------------------------------------------------------
--
-- Prestations payées
--
------------------------------------------------------------------
-- changement du curseur : reprise V6 PHA 22/03/2011
   SELECT   vs_grnts.numinterm       societe,
         v_assur_delegat.numass   ass_contrat,
         dcpt.numdec            decompte,
         v_assur_delegat.numass   ass_garantie,
         v_assur_delegat.numfor   garantie,
         sinistre.mtreel         montant,
         sinistre.monnaie      monnaie
       ,decaismt_prest.numdecaismt numdecaismt -- ACA 18082010
       ,null                       numpnul     -- ACA 18082010
   FROM            dcpt,
         decaismt   decaismt_prest,
         affectation   affectation_prest,
                  vs_grnts,
                  sinistre,
                  v_assur_delegat
   where   dcpt.numgar   = vs_grnts.numgar
   and      dcpt.numdec = affectation_prest.numaffec
   and      affectation_prest.codope    = 1
   and      decaismt_prest.numdecaismt    = affectation_prest.numdecaismt
   and      decaismt_prest.codope       = 1
   and      decaismt_prest.flagpay+0   = 1
   and    sinistre.NUMDEC    = dcpt.numdec
   -- and    sinistre.numdcptcie   = 0                                   -- ACA 18082010 M3224
   and    (sinistre.numdcptcie   = 0 or decaismt_prest.numdcptcie = 0) -- ACA 18082010 M3224
   and    sinistre.numfor    = v_assur_delegat.numfor
   and      vs_grnts.numinterm between nvl(G_numsoc_deb,vs_grnts.numinterm) and nvl(G_numsoc_fin,nvl(G_numsoc_deb,vs_grnts.numinterm))
   and    v_assur_delegat.numass between nvl(G_numorg_deb,v_assur_delegat.numass)   and nvl(G_numorg_fin,nvl(G_numorg_deb,v_assur_delegat.numass))
   and      vs_grnts.refcie_chapeau||'-' between nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-')   and   nvl(G_refcie_fin,nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-'))
   and      vs_grnts.numgar between nvl(G_numgar_deb,vs_grnts.numgar) and nvl(G_numgar_fin,nvl(G_numgar_deb,vs_grnts.numgar))
   and      trunc(decaismt_prest.datpay) <= G_date_butoir
UNION ALL
-- Prestations payées mais affectation annulée
   SELECT   vs_grnts.numinterm       societe,
         v_assur_delegat.numass   ass_contrat,
         dcpt.numdec            decompte,
         v_assur_delegat.numass   ass_garantie,
         v_assur_delegat.numfor   garantie,
         sinistre.mtreel         montant,
         sinistre.monnaie      monnaie
       ,decaismt_prest.numdecaismt numdecaismt -- ACA 18082010
       ,null                       numpnul     -- ACA 18082010
   FROM            dcpt,
         decaismt   decaismt_prest,
         affectation_annul   affectation_prest,
         pnul, -- PHA 17/11/2010
                  vs_grnts,
                  sinistre,
                  v_assur_delegat
   where   dcpt.numgar   = vs_grnts.numgar
   and      dcpt.numdec = affectation_prest.numaffec
   and      affectation_prest.codope    = 1
   and      decaismt_prest.numdecaismt    = affectation_prest.numdecaismt
   and      decaismt_prest.codope       = 1
   and      decaismt_prest.flagpay+0   = 1
   and    sinistre.NUMDEC    = dcpt.numdec
   and   pnul.numdecaismt = decaismt_prest.numdecaismt -- PHA 17/11/2010
   -- and    sinistre.numdcptcie   = 0                                   -- ACA 18082010 M3224
   and    ((sinistre.numdcptcie   = 0) or (pnul.numdcptcie_init = 0 AND pnul.numdcptcie_sin_init = sinistre.numdcptcie)) -- ACA 18082010 M3224 -- PNULL  PHA 17/11/2010
   and    sinistre.numfor    = v_assur_delegat.numfor
   and      vs_grnts.numinterm between nvl(G_numsoc_deb,vs_grnts.numinterm) and nvl(G_numsoc_fin,nvl(G_numsoc_deb,vs_grnts.numinterm))
   and    v_assur_delegat.numass between nvl(G_numorg_deb,v_assur_delegat.numass)   and nvl(G_numorg_fin,nvl(G_numorg_deb,v_assur_delegat.numass))
   and      vs_grnts.refcie_chapeau||'-' between nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-')   and   nvl(G_refcie_fin,nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-'))
   and      vs_grnts.numgar between nvl(G_numgar_deb,vs_grnts.numgar) and nvl(G_numgar_fin,nvl(G_numgar_deb,vs_grnts.numgar))
   and      trunc(decaismt_prest.datpay) <= G_date_butoir
  AND NOT EXISTS (SELECT 1 FROM sinistre_annul WHERE numsin = sinistre.numsin AND numdec = sinistre.numdec)
UNION ALL
-- Prestations payées mais décompte annulé
   SELECT   vs_grnts.numinterm       societe,
         v_assur_delegat.numass   ass_contrat,
         dcpt.numdec            decompte,
         v_assur_delegat.numass   ass_garantie,
         v_assur_delegat.numfor   garantie,
         sinistre.mtreel         montant,
         sinistre.monnaie      monnaie
       ,decaismt_prest.numdecaismt numdecaismt -- ACA 18082010
       ,null                       numpnul     -- ACA 18082010
   FROM decompte_annul dcpt,
         pnul   decaismt_prest,
         affectation_annul   affectation_prest,
                  vs_grnts,
         sinistre_annul sinistre, -- sinistre_annul ?
                  v_assur_delegat
   where   dcpt.numgar   = vs_grnts.numgar
   and      dcpt.numdec = affectation_prest.numaffec
   and      affectation_prest.codope    = 1
   and      decaismt_prest.numdecaismt    = affectation_prest.numdecaismt
   and      decaismt_prest.codope       = 1
--   and      decaismt_prest.flagpay+0   = 1 PHA 16/11/2010 (PNUL à la place de decaismt)
   and    sinistre.NUMDEC    = dcpt.numdec
   -- and    sinistre.numdcptcie   = 0                                   -- ACA 18082010 M3224
   and    ((sinistre.numdcptcie_init   = 0 or sinistre.numdcptcie_init   = -1) or (decaismt_prest.numdcptcie_init = 0 AND decaismt_prest.numdcptcie_sin_init = sinistre.numdcptcie)) -- ACA 18082010 M3224 + PHA 16/11/2010 numdcptcie_init = 0
   and    sinistre.numfor    = v_assur_delegat.numfor
   and      vs_grnts.numinterm between nvl(G_numsoc_deb,vs_grnts.numinterm) and nvl(G_numsoc_fin,nvl(G_numsoc_deb,vs_grnts.numinterm))
   and    v_assur_delegat.numass between nvl(G_numorg_deb,v_assur_delegat.numass)   and nvl(G_numorg_fin,nvl(G_numorg_deb,v_assur_delegat.numass))
   and      vs_grnts.refcie_chapeau||'-' between nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-')   and   nvl(G_refcie_fin,nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-'))
   and      vs_grnts.numgar between nvl(G_numgar_deb,vs_grnts.numgar) and nvl(G_numgar_fin,nvl(G_numgar_deb,vs_grnts.numgar))
   and      trunc(decaismt_prest.datpay) <= G_date_butoir
UNION all
------------------------------------------------------------------
--
-- Annulations
--
------------------------------------------------------------------
   SELECT   vs_grnts.numinterm          societe,
         v_assur_delegat.numass      ass_contrat,
         dcpt.numdec               decompte,
         v_assur_delegat.numass      ass_garantie,
         v_assur_delegat.numfor      garantie,
         -sinistre.mtreel         montant,
         sinistre.monnaie         monnaie
       ,null                       numdecaismt -- ACA 18082010
     ,decaismt_prest.numdecaismt numpnul     -- ACA 18082010
   FROM   decompte_annul      dcpt,
         pnul                    decaismt_prest,
         affectation_annul     affectation_prest,
                        vs_grnts,
         sinistre_annul        sinistre,
                        v_assur_delegat
   where   dcpt.numgar      = vs_grnts.numgar
   and      dcpt.numdec     = affectation_prest.numaffec
   and      affectation_prest.codope    = 1
   and      decaismt_prest.numdecaismt    = affectation_prest.numdecaismt
   and      decaismt_prest.codope       = 1
   and    sinistre.NUMDEC    = dcpt.numdec
   -- and    sinistre.numdcptcie   = 0                                   -- ACA 18082010 M3224
   and    (sinistre.numdcptcie   = -1 or sinistre.numdcptcie   = 0)--  or (decaismt_prest.numdcptcie = 0 and decaismt_prest.numdcptcie_sin = sinistre.numdcptcie) ) -- ACA 18082010 M3224 + PHA 05/11/2010 pour -1
   and    sinistre.numfor    = v_assur_delegat.numfor
   and      vs_grnts.numinterm between nvl(G_numsoc_deb,vs_grnts.numinterm)   and nvl(G_numsoc_fin,nvl(G_numsoc_deb,vs_grnts.numinterm))
   and    v_assur_delegat.numass between nvl(G_numorg_deb,v_assur_delegat.numass)   and nvl(G_numorg_fin,nvl(G_numorg_deb,v_assur_delegat.numass))
   and      vs_grnts.refcie_chapeau||'-' between nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-')   and nvl(G_refcie_fin,nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-'))
   and      vs_grnts.numgar between nvl(G_numgar_deb,vs_grnts.numgar) and nvl(G_numgar_fin,nvl(G_numgar_deb,vs_grnts.numgar))
   and      trunc(decaismt_prest.datannul) <= G_date_butoir
UNION all
-- Annulation concernant les décaissements désaffectés  -- PHA 10112010
   SELECT   vs_grnts.numinterm          societe,
         v_assur_delegat.numass      ass_contrat,
         dcpt.numdec               decompte,
         v_assur_delegat.numass      ass_garantie,
         v_assur_delegat.numfor      garantie,
         -sinistre.mtreel         montant,
         sinistre.monnaie         monnaie
       ,null  numdecaismt
     ,decaismt_prest.numdecaismt numpnul
   FROM   decompte       dcpt,
         decaismt            decaismt_prest,
         affectation_annul   affectation_prest,
         pnul,  -- PHA 17/11/2010
         vs_grnts,
         sinistre,
         v_assur_delegat
   where   dcpt.numgar      = vs_grnts.numgar
   and      dcpt.numdec     = affectation_prest.numaffec
   and      affectation_prest.codope    = 1
   and      decaismt_prest.numdecaismt    = affectation_prest.numdecaismt
   and      decaismt_prest.codope       = 1
   and    sinistre.NUMDEC    = dcpt.numdec
   and   pnul.numdecaismt = decaismt_prest.numdecaismt -- PHA 17/11/2010
   -- and    sinistre.numdcptcie   = 0                                   -- ACA 18082010 M3224
   and    (sinistre.numdcptcie   = 0 or pnul.numdcptcie = 0) -- ACA 18082010 M3224
   and    sinistre.numfor    = v_assur_delegat.numfor
   and      vs_grnts.numinterm between nvl(G_numsoc_deb,vs_grnts.numinterm)   and nvl(G_numsoc_fin,nvl(G_numsoc_deb,vs_grnts.numinterm))
   and    v_assur_delegat.numass between nvl(G_numorg_deb,v_assur_delegat.numass)   and nvl(G_numorg_fin,nvl(G_numorg_deb,v_assur_delegat.numass))
   and      vs_grnts.refcie_chapeau||'-' between nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-')   and nvl(G_refcie_fin,nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-'))
   and      vs_grnts.numgar between nvl(G_numgar_deb,vs_grnts.numgar) and nvl(G_numgar_fin,nvl(G_numgar_deb,vs_grnts.numgar))
   and      trunc(pnul.datannul) <= G_date_butoir
  AND NOT EXISTS (SELECT 1 FROM sinistre_annul WHERE numsin = sinistre.numsin AND numdec = sinistre.numdec)
UNION all
------------------------------------------------------------------
--
-- Indus de prestations
--
------------------------------------------------------------------
   SELECT      vs_grnts.numinterm         societe,
         v_assur_delegat.numass        ass_contrat,
         dcpt.numdec                 decompte,
         v_assur_delegat.numass      ass_garantie,
         v_assur_delegat.numfor      garantie,
         CASE
           WHEN SUM(compte_client.montant) > 0 THEN ROUND(sinistre.mtreel*(SUM(compte_client.montant)/dcpt.montant),2)
           ELSE ROUND(-sinistre.mtreel*(SUM(compte_client.montant)/dcpt.montant),2)
         END    montant,
         sinistre.monnaie         monnaie
       ,null                 numdecaismt   -- ACA 18082010
       ,null                 numpnul       -- ACA 18082010
   FROM               dcpt,
                     compte_client,
         affectation      affectation_prest,
                     vs_grnts,
                     sinistre,
                     v_assur_delegat
   where   dcpt.numgar   = vs_grnts.numgar
   and      dcpt.numdec     = affectation_prest.numaffec
   and      compte_client.numfact = affectation_prest.numaffec
   and      compte_client.codope = 1


   and      affectation_prest.codope = 1
   and    sinistre.NUMDEC    = dcpt.numdec
   and    sinistre.numdcptcie   = 0
   and    sinistre.numfor    = v_assur_delegat.numfor
   and      vs_grnts.numinterm between nvl(G_numsoc_deb,vs_grnts.numinterm) and nvl(G_numsoc_fin,nvl(G_numsoc_deb,vs_grnts.numinterm))
   and    v_assur_delegat.numass between nvl(G_numorg_deb,v_assur_delegat.numass) and nvl(G_numorg_fin,nvl(G_numorg_deb,v_assur_delegat.numass))
   and      vs_grnts.refcie_chapeau||'-' between nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-')   and   nvl(G_refcie_fin,nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-'))
   and      vs_grnts.numgar between nvl(G_numgar_deb,vs_grnts.numgar) and nvl(G_numgar_fin,nvl(G_numgar_deb,vs_grnts.numgar))
   and      trunc(compte_client.datope)<= G_date_butoir
   GROUP BY vs_grnts.numinterm ,
            v_assur_delegat.numass ,
            dcpt.numdec ,
            v_assur_delegat.numass ,
            v_assur_delegat.numfor ,
            sinistre.mtreel,
            dcpt.montant,
            sinistre.monnaie
   ORDER
      BY   1,4,3,5
     , 8 , 9; -- ajout tri 8 et 9 pha18/11/2010

/*         SELECT   contrat.numinterm societe,
                  v_assur_delegat.numass ass_contrat,
                  sinistre.numdec decompte,
                  v_assur_delegat.numass ass_garantie,
                  v_assur_delegat.numfor garantie, sinistre.mtreel montant,
                  sinistre.monnaie monnaie
                   ,decaismt_prest.numdecaismt numdecaismt -- ACA 18082010
                   ,null                       numpnul     -- ACA 18082010
             FROM contrat,
                  v_assur_delegat,
                  sinistre,
                  affectation affectation_prest,
                  decaismt decaismt_prest
            WHERE decaismt_prest.codope = 1
              AND decaismt_prest.flagpay + 0 = 1
              AND TRUNC (decaismt_prest.datpay) <= g_date_butoir
              AND decaismt_prest.numdecaismt = affectation_prest.numdecaismt
              AND affectation_prest.codope = 1
              AND affectation_prest.numaffec = sinistre.numdec
              AND sinistre.numgar = contrat.numgar
               -- AND    sinistre.numdcptcie   = 0                                   -- ACA 18082010 M3224
               AND    (sinistre.numdcptcie   = 0 or decaismt_prest.numdcptcie = 0) -- ACA 18082010 M3224
              AND sinistre.numfor = v_assur_delegat.numfor
              AND v_assur_delegat.numass BETWEEN NVL (g_numorg_deb,
                                                      v_assur_delegat.numass
                                                     )
                                             AND NVL
                                                   (g_numorg_fin,
                                                    NVL
                                                       (g_numorg_deb,
                                                        v_assur_delegat.numass
                                                       )
                                                   )
              AND contrat.refcie_chapeau || '-'
                     BETWEEN NVL (g_refcie_deb, contrat.refcie_chapeau) || '-'
                         AND NVL (g_refcie_fin,
                                  NVL (g_refcie_deb,
                                       contrat.refcie_chapeau
                                      )
                                 ) || '-'
              AND contrat.numgar BETWEEN NVL (g_numgar_deb, contrat.numgar)
                                     AND NVL (g_numgar_fin,
                                              NVL (g_numgar_deb,
                                                   contrat.numgar
                                                  )
                                             )
              AND contrat.numinterm BETWEEN NVL (g_numsoc_deb,
                                                 contrat.numinterm
                                                )
                                        AND NVL (g_numsoc_fin,
                                                 NVL (g_numsoc_deb,
                                                      contrat.numinterm
                                                     )
                                                )
         UNION ALL
------------------------------------------------------------------
--
-- Annulations
--
------------------------------------------------------------------
         SELECT   contrat.numinterm societe,
                  v_assur_delegat.numass ass_contrat,
                  sinistre.numdec decompte,
                  v_assur_delegat.numass ass_garantie,
                  v_assur_delegat.numfor garantie, -sinistre.mtreel montant,
                  sinistre.monnaie monnaie
                   ,null                       numdecaismt -- ACA 18082010
                 ,decaismt_prest.numdecaismt numpnul     -- ACA 18082010
             FROM contrat,
                  v_assur_delegat,
                  sinistre_annul sinistre,
                  affectation_annul affectation_prest,
                  pnul decaismt_prest
            WHERE decaismt_prest.numdecaismt = affectation_prest.numdecaismt
              AND decaismt_prest.codope = 1
              AND TRUNC (decaismt_prest.datannul) <= g_date_butoir
              AND affectation_prest.numaffec = sinistre.numdec
              AND affectation_prest.codope = 1
               -- AND sinistre.numdcptcie   = 0                                   -- ACA 18082010 M3224
               AND (sinistre.numdcptcie   = 0 or decaismt_prest.numdcptcie = 0)   -- ACA 18082010 M3224
              AND sinistre.numfor = v_assur_delegat.numfor
              AND sinistre.numgar = contrat.numgar
              AND v_assur_delegat.numass BETWEEN NVL (g_numorg_deb,
                                                      v_assur_delegat.numass
                                                     )
                                             AND NVL
                                                   (g_numorg_fin,
                                                    NVL
                                                       (g_numorg_deb,
                                                        v_assur_delegat.numass
                                                       )
                                                   )
              AND contrat.numinterm BETWEEN NVL (g_numsoc_deb,
                                                 contrat.numinterm
                                                )
                                        AND NVL (g_numsoc_fin,
                                                 NVL (g_numsoc_deb,
                                                      contrat.numinterm
                                                     )
                                                )
              AND contrat.refcie_chapeau || '-'
                     BETWEEN NVL (g_refcie_deb, contrat.refcie_chapeau ) || '-'
                         AND NVL (g_refcie_fin,
                                  NVL (g_refcie_deb,
                                       contrat.refcie_chapeau
                                      )
                                 ) || '-'
              AND contrat.numgar BETWEEN NVL (g_numgar_deb, contrat.numgar)
                                     AND NVL (g_numgar_fin,
                                              NVL (g_numgar_deb,
                                                   contrat.numgar
                                                  )
                                             )
         UNION ALL
------------------------------------------------------------------
--
-- Indus de prestations
--
------------------------------------------------------------------
         SELECT DISTINCT contrat.numinterm societe,
                         v_assur_delegat.numass ass_contrat,
                         sinistre.numdec decompte,
                         v_assur_delegat.numass ass_garantie,
                         v_assur_delegat.numfor garantie,
                         sinistre.mtreel montant, sinistre.monnaie monnaie
                          ,null                 numdecaismt   -- ACA 18082010
                          ,null                 numpnul       -- ACA 18082010
                    FROM contrat,
                         v_assur_delegat,
                         sinistre,
                         affectation affectation_prest,
                         compte_client
                   WHERE compte_client.numfact = affectation_prest.numaffec
                     AND compte_client.codope = 1
                     AND TRUNC (compte_client.datope) <= g_date_butoir
                     AND affectation_prest.numaffec = sinistre.numdec
                     AND affectation_prest.codope = 1
                     AND sinistre.numgar = contrat.numgar
                     AND sinistre.numdcptcie = 0
                     AND sinistre.numfor = v_assur_delegat.numfor
                     AND v_assur_delegat.numass
                            BETWEEN NVL (g_numorg_deb, v_assur_delegat.numass)
                                AND NVL (g_numorg_fin,
                                         NVL (g_numorg_deb,
                                              v_assur_delegat.numass
                                             )
                                        )
                     AND contrat.numinterm BETWEEN NVL (g_numsoc_deb,
                                                        contrat.numinterm
                                                       )
                                               AND NVL (g_numsoc_fin,
                                                        NVL (g_numsoc_deb,
                                                             contrat.numinterm
                                                            )
                                                       )
                     AND contrat.refcie_chapeau || '-'
                            BETWEEN NVL (g_refcie_deb,
                                         contrat.refcie_chapeau
                                        ) || '-'
                                AND NVL (g_refcie_fin,
                                         NVL (g_refcie_deb,
                                              contrat.refcie_chapeau
                                             )
                                        ) || '-'
                     AND contrat.numgar BETWEEN NVL (g_numgar_deb,
                                                     contrat.numgar
                                                    )
                                            AND NVL (g_numgar_fin,
                                                     NVL (g_numgar_deb,
                                                          contrat.numgar
                                                         )
                                                    )
                ORDER BY 1, 4, 3, 5;
*/
--
      r_sel_dcpt   c_sel_dcpt%ROWTYPE;
   BEGIN
   -- < reprise V6 PHA 22/03/2011
      SELECT   max(nvl(numdcptcie,0)) + 1 INTO G_numdcptcie
      FROM   dcptcie;
      -- Maj des "numdcptcie" à 0 (cas des bdx à 0 non créé mais dont le détail a été alimenté ...)
      UPDATE sinistre SET numdcptcie = 0 where numdcptcie >= G_numdcptcie and not exists (select 1 from dcptcie where numdcptcie = sinistre.numdcptcie);
      UPDATE sinistre_annul SET numdcptcie = 0 where numdcptcie >= G_numdcptcie and not exists (select 1 from dcptcie where numdcptcie = sinistre_annul.numdcptcie);
      UPDATE sinistre_annul SET numdcptcie_init = 0 where numdcptcie_init >= G_numdcptcie and not exists (select 1 from dcptcie where numdcptcie = sinistre_annul.numdcptcie_init);
      UPDATE decaismt SET numdcptcie = 0 where numdcptcie >= G_numdcptcie and not exists (select 1 from dcptcie where numdcptcie = decaismt.numdcptcie);
      UPDATE decaismt SET numdcptcie_sin = 0 where numdcptcie_sin >= G_numdcptcie and not exists (select 1 from dcptcie where numdcptcie = decaismt.numdcptcie_sin);
      UPDATE pnul SET numdcptcie_sin = 0 where numdcptcie_sin >= G_numdcptcie and not exists (select 1 from dcptcie where numdcptcie = pnul.numdcptcie_sin);
      UPDATE pnul SET numdcptcie_sin_init = 0 where numdcptcie_sin_init >= G_numdcptcie and not exists (select 1 from dcptcie where numdcptcie = pnul.numdcptcie_sin_init);
      UPDATE pnul SET numdcptcie = 0 where numdcptcie >= G_numdcptcie and not exists (select 1 from dcptcie where numdcptcie = pnul.numdcptcie);
      UPDATE pnul SET numdcptcie_init = 0 where numdcptcie_init >= G_numdcptcie and not exists (select 1 from dcptcie where numdcptcie = pnul.numdcptcie_init);
    -- reprise V6 PHA 22/03/2011 >
      --
      g_rowcount := 0;
      o_found := 1;
      g_erreur := NULL;
      --
      g_numsoc_deb := i_deb_numsoc;
      g_numsoc_fin := i_fin_numsoc;
      g_numorg_deb := i_deb_numorg;
      g_numorg_fin := i_fin_numorg;
      g_refcie_deb := i_deb_refcie;
      g_refcie_fin := i_fin_refcie;
      g_numgar_deb := i_deb_numgar;
      g_numgar_fin := i_fin_numgar;
      g_date_butoir := NVL (i_fin_datbut, NVL (i_deb_datbut, SYSDATE));
      --
      g_max_msg := i_niv_msg;
      g_session := i_session;
      --G_idligne     := F_max_idligne(I_session => G_session);
      g_niv_msg := 1;
      g_msg_adm :=
          'Debut du traitement : ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;
      g_msg_adm :=
            'Paramètres <'
         || TO_CHAR (g_numsoc_deb)
         || '> <'
         || TO_CHAR (g_numsoc_fin)
         || '> <'
         || TO_CHAR (g_numorg_deb)
         || '> <'
         || TO_CHAR (g_numorg_fin)
         || '> <'
         || TO_CHAR (g_refcie_deb)
         || '> <'
         || TO_CHAR (g_refcie_fin)
         || '> <'
         || TO_CHAR (g_numgar_deb)
         || '> <'
         || TO_CHAR (g_numgar_fin)
         || '> <'
         || TO_CHAR (i_deb_datbut)
         || '> <'
         || TO_CHAR (i_fin_datbut)
         || '>';
      p_ins_journal;

      --
      FOR r_sel_dcpt IN c_sel_dcpt
      LOOP
        --
        g_rowcount := c_sel_dcpt%ROWCOUNT;
        g_societe := r_sel_dcpt.societe;
        g_ass_contrat := r_sel_dcpt.ass_contrat;
        g_decompte := r_sel_dcpt.decompte;
        g_ass_garantie := r_sel_dcpt.ass_garantie;
        g_garantie := r_sel_dcpt.garantie;
        g_montant := r_sel_dcpt.montant;
        g_monnaie := r_sel_dcpt.monnaie;
        g_montant_d := r_sel_dcpt.montant;
        g_monnaie_d := r_sel_dcpt.monnaie;

        IF g_init = FALSE THEN
          g_init := TRUE;
          p_entete_traitement;
        END IF;

        --    Détail du traitement
        p_corps_traitement;
        g_mnt_total := g_mnt_total + g_montant;
        g_mnt_tot_d := g_mnt_tot_d + g_montant_d;
        -- ACA 18082010
        g_decaismt  := R_sel_dcpt.numdecaismt;
        g_pnul      := R_sel_dcpt.numpnul;
        -- ACA fin
        -- < reprise V6 PHA 22/03/2011
        P_update_pnul; -- P_update_pnul; doit être placé à chaque ligne lue dans le curseur car ne fait pas parti de la rupture decompte)
        P_update_decaismt;
        -- reprise V6 PHA 22/03/2011 >
      --
      END LOOP;

      --
      p_fin_traitement;
      o_erreur := g_erreur;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := 'pk_gdp8b - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         o_erreur := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;
   END;

--
   PROCEDURE p_corps_traitement
   IS
   BEGIN
--
      g_niv_msg := 1;
      g_msg_adm :=
            'montant <'
         || TO_CHAR (g_montant)
         || '> Totaux <'
         || TO_CHAR (g_mnt_total)
         || '><'
         || TO_CHAR (g_mnt_tot_d)
         || '>';

--P_INS_journal;
--
      IF g_societe <> g_pre_numsoc
      THEN
-- G_msg_adm   := 'Rupture societe <'||TO_CHAR(G_societe)||'><'||to_char(G_pre_numsoc)||'>';
-- P_INS_journal;
         p_pied_ref_cptcie;
         p_pied_montant;
         g_pre_numsoc := g_societe;
         -- 08/06/2010 :
         g_pre_numass := g_ass_garantie;
         g_pre_decompte := g_decompte;
         g_pre_gar := g_garantie;
      END IF;

      IF g_ass_garantie <> g_pre_numass
      THEN
-- G_msg_adm   := 'Rupture assureur garantie <'||TO_CHAR(G_ass_garantie)||'><'||to_char(G_pre_numass)||' < montant <'||TO_CHAR(G_montant)||'> Totaux <'||to_char(G_mnt_total)||'>';
-- P_INS_journal;
         p_pied_ref_cptcie;
         p_pied_montant;
         g_pre_numass := g_ass_garantie;
         -- 08/06/2010 :
         g_pre_decompte := g_decompte;
         g_pre_gar := g_garantie;
      END IF;

      IF g_decompte <> g_pre_decompte
      THEN
-- G_msg_adm   := 'Rupture decompte <'||TO_CHAR(G_decompte)||'><'||to_char(G_pre_decompte)||' < montant <'||TO_CHAR(G_montant)||'> Totaux <'||to_char(G_mnt_total)||'>';
-- P_INS_journal;
         p_pied_ref_cptcie;
         g_pre_decompte := g_decompte;
         g_pre_gar := g_garantie;
      END IF;

      IF g_garantie <> g_pre_gar
      THEN
-- G_msg_adm   := 'Rupture garantie <'||TO_CHAR(G_garantie)||'><'||to_char(G_pre_gar)||'>';
-- P_INS_journal;
         p_pied_ref_cptcie;
         g_pre_gar := g_garantie;
      END IF;
--
   END p_corps_traitement;

--
   PROCEDURE p_pied_montant
   IS
   BEGIN
-- P_INS_journal;
-- G_msg_adm := 'ecriture dcptcie <'||TO_CHAR(G_pre_numsoc)||'><'||to_char(G_pre_numass)||'><'||to_char(G_mnt_total)||'><'||to_char(G_monnaie)||'><'||to_char(G_mnt_tot_d)||'><'||to_char(G_monnaie_d)||'>';
-- P_INS_journal;
      IF g_mnt_total > 0
      THEN
         p_insert_dcptcie;
         p_next_numdcptcie;
      ELSE
-- G_msg_adm := 'remise à 0 sinistre dcpt neg. <'||TO_CHAR(G_pre_numsoc)||'><'||to_char(G_pre_numass)||'><'||to_char(G_mnt_total)||'><'||to_char(G_monnaie)||'><'||to_char(G_mnt_tot_d)||'><'||to_char(G_monnaie_d)||'>';
-- P_INS_journal;
         p_pied_ref_cptcie_negatif;
      END IF;

--
      g_mnt_total := 0;
      g_mnt_tot_d := 0;
-- G_pre_monnaie  := G_monnaie;
-- G_pre_mon_dev  := G_monnaie_d;
   END p_pied_montant;

--
--
    PROCEDURE p_pied_ref_cptcie
    IS
    BEGIN
      p_update_sinistre;
      p_update_sinistre_annul;
      -- PHA 22/03/2011 mis en commentaire reprise V6
      -- P_update_decaismt; -- ACA 18082010 M3224
      -- P_update_pnul;      -- ACA 18082010 M3224
    END p_pied_ref_cptcie;

--
--
   PROCEDURE p_pied_ref_cptcie_negatif
   IS
   BEGIN
      p_sinistre_maj;
      p_sinistre_annul_maj;
   END p_pied_ref_cptcie_negatif;

--
   PROCEDURE p_fin_traitement
   IS
   BEGIN
--
      g_proc := 'P_fin_traitement';
-- G_msg_adm := 'Fin de traitement <'||TO_CHAR(G_pre_numass)||'><'||to_char(G_pre_gar)||'><'||to_char(G_numdcptcie)||'>';
-- P_INS_journal;
--
      p_pied_ref_cptcie;
      p_pied_montant;
--
      g_niv_msg := 1;
      g_msg_adm := 'Nombre de lignes : <' || TO_CHAR (g_rowcount) || '>';
      p_ins_journal;
      g_msg_adm :=
            'Fin du traitement : ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;
      -- Fin ecriture dans le Journal
      g_init := FALSE;
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
   END;

--
-------------------------------------------------------------------------------------------------------
--
   PROCEDURE p_entete_traitement
   IS
   BEGIN
      g_pre_numsoc := g_societe;
      g_pre_decompte := g_decompte;
      g_pre_gar := g_garantie;
      g_pre_numass := g_ass_garantie;
      g_mnt_total := 0;
      g_mnt_tot_d := 0;
--
      p_next_numdcptcie;
   END p_entete_traitement;

--
   PROCEDURE p_next_numdcptcie
   IS
   BEGIN
      g_proc := 'select_numdcptcie';
      -- M0004574 PHA 08/10/2015
      SELECT NUMDCPTCIE.nextval INTO G_numdcptcie FROM dual;
      /* SELECT MAX (NVL (numdcptcie, 0)) + 1
        INTO g_numdcptcie
        FROM dcptcie; */
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
   END p_next_numdcptcie;

--
   PROCEDURE p_insert_dcptcie
   IS
   BEGIN
      g_proc := 'insert_dcptcie';

      INSERT INTO dcptcie
                  (numdcptcie, datcreat, datedeb, datefin, numsoc, numorg,
                   TYPE, montant, monnaie, valide, numutil, montant_d,
                   monnaie_d)
         SELECT NVL (g_numdcptcie, 1), TRUNC (SYSDATE), g_date_butoir,
                g_date_butoir, g_pre_numsoc, g_pre_numass, 1, g_mnt_total,
                g_monnaie, 'N', g_numutil, g_mnt_tot_d, g_monnaie_d
           FROM DUAL;
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
   END p_insert_dcptcie;

--
   PROCEDURE p_update_sinistre
   IS
   BEGIN
      g_proc := 'update_sinistre';

      UPDATE sinistre
         SET numdcptcie = NVL (g_numdcptcie, 1)
       WHERE sinistre.numdec = g_pre_decompte
         AND sinistre.numfor = g_pre_gar
         AND sinistre.numdcptcie = 0;

    	-- PHA 22/03/2011 reprise V6 update numdcptcie_init
      UPDATE	sinistre_annul
    	SET	numdcptcie_init = nvl(G_numdcptcie,1)
    	WHERE	sinistre_annul.numdec = G_pre_decompte
    	AND		sinistre_annul.numfor = G_pre_gar
    	AND		sinistre_annul.numdcptcie_init = 0;

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
   END p_update_sinistre;

--
   PROCEDURE p_update_sinistre_annul
   IS
   BEGIN
      g_proc := 'update_sinistre_annul';

--  G_msg_adm   := 'Update sinistre_annul <'||TO_CHAR(g_pre_decompte)||'><'||to_char(g_pre_gar)||'>';
--  P_INS_journal;

      UPDATE sinistre_annul
         SET numdcptcie = NVL (g_numdcptcie, 1)
       WHERE sinistre_annul.numdec = g_pre_decompte
         AND sinistre_annul.numfor = g_pre_gar
         AND (sinistre_annul.numdcptcie  = 0 or sinistre_annul.numdcptcie = -1);
         -- AND sinistre_annul.numdcptcie = 0; remplacer par ligne du dessus PHA 22/03/2011 reprise V6
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
   END p_update_sinistre_annul;

--
/* ACA 18082010 M3224 : Gestion des annulations */
PROCEDURE P_update_decaismt
IS
BEGIN
   G_proc := 'update_decaismt';
   IF g_decaismt IS NOT null Then
      UPDATE   decaismt
       SET   numdcptcie = nvl(G_numdcptcie,1)
       WHERE   decaismt.numdecaismt = g_decaismt
        AND nvl(numdcptcie,0) <= 0; -- PHA 22/03/2011 reprise V6 <= 0
    	-- < PHA 22/03/2011 reprise V6 ajout :
      UPDATE	decaismt
    	SET	numdcptcie_sin = nvl(G_numdcptcie,1)
    	WHERE	decaismt.numdecaismt = G_decaismt
        AND nvl(numdcptcie_sin,0) <= 0;
      --
      UPDATE	pnul
    	SET	numdcptcie_init = nvl(G_numdcptcie,1)
    	WHERE	pnul.numdecaismt = G_decaismt
        AND nvl(numdcptcie_init,0) <= 0;
      --
      UPDATE	pnul
    	SET	numdcptcie_sin_init = nvl(G_numdcptcie,1)
    	WHERE	pnul.numdecaismt = G_decaismt
        AND nvl(numdcptcie_sin_init,0) <= 0;
      -- PHA 22/03/2011 reprise V6 >
  END If;
Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
END P_update_decaismt;
--
PROCEDURE P_update_pnul
IS
BEGIN
   G_proc := 'update_pnul';
   IF g_pnul IS NOT null Then
      -- < PHA 22/03/2011 reprise V6 :
      UPDATE  pnul
       SET    numdcptcie = nvl(G_numdcptcie,1)
       WHERE	pnul.numdecaismt = G_pnul AND nvl(numdcptcie,0) <= 0;
       -- WHERE   pnul.numdecaismt = g_pnul;
      UPDATE	pnul
    	 SET	  numdcptcie_sin = nvl(G_numdcptcie,1)
    	 WHERE	pnul.numdecaismt = G_pnul AND nvl(numdcptcie_sin,0) <= 0;
       -- PHA 22/03/2011 reprise V6 >
  END If;
Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
END P_update_pnul;
/* ACA fin */
-- 08/06/2010 :
   PROCEDURE p_sinistre_maj
   IS
   BEGIN
      g_proc := 'update_sinistre à 0';

      UPDATE sinistre
         SET numdcptcie = 0
       WHERE sinistre.numdcptcie = g_numdcptcie;
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
   END p_sinistre_maj;

--
-- 08/06/2010 :
   PROCEDURE p_sinistre_annul_maj
   IS
   BEGIN
      g_proc := 'update_sinistre_annul à 0';

      UPDATE sinistre_annul
         SET numdcptcie = 0
       WHERE sinistre_annul.numdcptcie = g_numdcptcie;
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
   END p_sinistre_annul_maj;

-------------------------------------------------------------------------------------------------------
----------------------- Fin des procedures publiques ------------------

   -- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
   PROCEDURE p_ins_journal
   IS
      l_idligne   NUMBER;
   BEGIN
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
   END p_ins_journal;
--
---------------- Fin des corps des procedures privees --
--
END;
/
