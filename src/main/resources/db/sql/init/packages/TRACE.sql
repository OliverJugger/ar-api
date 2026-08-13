CREATE OR REPLACE PACKAGE ARTHUS.TRACE AS
-- Chaine de reconnaissance SCCS
-- %W%	%E%
--
-- ============================================================================
-- CONSTANTES PUBLIQUE
-- Aucune
-- ============================ Fin des Constantes Publiques ===============
-- ============================================================================
-- EXCEPTIONS PUBLIQUES
-- Aucune
-- ============================ Fin des Exceptions Publiques ==================
-- ============================================================================
-- TYPES PUBLIQUES
   Type T_R_message IS RECORD
          ( Lib_msg	mess_erreur.Lib_msg%TYPE,
            Type_msg    mess_erreur.type_msg%TYPE);
-- ========================== Fin des types publiques =========================
-- ============================================================================
-- VARIABLES PUBLIQUES
--
-- ========================== Fin des Variables publiques =====================
-- ============================================================================
-- PROCEDURES ET FONCTIONS PUBLIQUES
--
-- Traitement : Insere dans la table journal_adm les traces d'un traitemnent.
-- I_niv_msg prend 2 Valeurs 1 --> Message informatif(tout se passe bien)
--                           2 --> Message d'erreurs (Erreur ORACLE)
-- Traitement : Insere dans la table journal_adm les traces d'un traitemnent.
PROCEDURE P_INS_journal_adm
              ( I_nom_traitement journal_adm.nom_traitement%TYPE,
                I_session        journal_adm.id_session%TYPE,
                I_niv_msg        journal_adm.niv_msg%TYPE,
                I_msg_adm        journal_adm.msg_adm%TYPE,
                I_date           journal_adm.date_adm%TYPE DEFAULT SYSDATE);
--
--
-- ========================== Fin des Procedures publiques ====================
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.TRACE AS
-- Chaine de reconnaissance SCCS
-- %W%	%E%
-- ============================================================================
-- CONSTANTES PRIVEES
--
-- ========================== Fin des constantes privees ======================
-- ============================================================================
-- -- EXCEPTIONS PRIVEES
-- Aucune
-- ========================== Fin des exceptions privees ======================
-- ============================================================================
-- TYPES PRIVEES
-- Aucun
-- ========================== Fin des types privees ===========================
-- ============================================================================
-- VARIABLES GLOBALES PRIVEES
-- Aucune
-- ===================== Fin des variables globales privees ===================
-- ============================================================================
-- DEFINITION DES PROCEDURES PRIVEES
--
-- ============== Fin des definitions des procedures privees =================
-- ============================================================================
-- CORPS DES PROCEDURES PUBLIQUES
--
--
PROCEDURE P_INS_journal_adm
              ( I_nom_traitement journal_adm.nom_traitement%TYPE,
                I_session        journal_adm.id_session%TYPE,
                I_niv_msg        journal_adm.niv_msg%TYPE,
                I_msg_adm        journal_adm.msg_adm%TYPE,
                I_date           journal_adm.date_adm%TYPE DEFAULT SYSDATE)
IS
BEGIN
 --
  INSERT INTO journal_adm( nom_traitement,
                           id_session,
                           niv_msg,
                           msg_adm,
                           date_adm
                         )
  VALUES                 ( I_nom_traitement,
                           I_session,
                           I_niv_msg,
                           I_msg_adm,
                           I_date);
END;
--
-- ========================== Fin des corps des procedures publiques===========
END;
/
