CREATE OR REPLACE PACKAGE ARTHUS.PK_PRDG_FONCT IS
/*===========================================================================*/
/* Package      : PK_PRDG_FONCT.sql                                          */
/* Domaine      : Statistiques et pilotage                                   */
/* Version      : V1.0                                                       */
/* Auteur       : ACA                                                        */
/* Création     : 26/11/2010                                                 */
/* Description  : Package des fonctions spécifiques au projet PRDG.          */
/*              : Permet de contituer différents segments (INT,ENS,...)      */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/

/* ==========================================================================*/
-- TYPES PUBLIQUES
  TYPE T_CHAR_TAB IS TABLE OF VARCHAR2(50) INDEX BY binary_integer;

-- PROCEDURES ET FONCTIONS PUBLIQUES
    FUNCTION F_get_segment (
    p_idsegment IN prdgsegment.idsegment%TYPE,
    p_ligne     IN PK_PRDG_DYNAMIC_CURSOR.T_CLES,
    p_niv       IN NUMBER,
    p_cle       IN VARCHAR2,
    p_cle2      IN VARCHAR2,
    p_seqsgt    IN NUMBER,
    p_datedeb      IN DATE,
    p_datefin      IN DATE,
    p_nomflux IN VARCHAR2)
    RETURN T_CHAR_TAB;
  FUNCTION F_get_transco_prdg (p_iddonnee IN prdgdonnee.iddonnee%TYPE, p_cle IN VARCHAR2)
    RETURN VARCHAR2;
/* ========================== Fin des Procedures publiques ==================*/
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_PRDG_FONCT AS

-- PROCEDURES ET FONCTIONS PRIVEES
  FUNCTION F_get_org (p_numorg IN pers_organisme.numorg%TYPE) RETURN NUMBER;
  FUNCTION F_get_indiv (p_numindiv IN individu.numindiv%TYPE) RETURN T_CHAR_TAB;
  FUNCTION F_get_contrat (p_numgar IN NUMBER) RETURN T_CHAR_TAB;
  FUNCTION F_get_totaux (p_ligne IN PK_PRDG_DYNAMIC_CURSOR.T_CLES, p_pr IN VARCHAR2, p_nomflux IN VARCHAR2, p_datedeb IN DATE, p_datefin IN DATE) RETURN VARCHAR2 ;
  FUNCTION F_get_garantie ( p_numsin IN sin_prev.nosin%TYPE) RETURN T_CHAR_TAB;
  FUNCTION F_get_arret_detail (p_numsin IN sin_prev.nosin%TYPE, p_date IN DATE)    RETURN T_CHAR_TAB;
  FUNCTION F_get_contact (p_numindiv IN individu.numindiv%TYPE) RETURN T_CHAR_TAB;
  FUNCTION F_get_sinistre_prev (p_numsin IN sin_prev.nosin%TYPE,p_date IN DATE) RETURN T_CHAR_TAB;
  PROCEDURE P_get_histo_sinistre_prev (p_numsin IN sin_prev.nosin%TYPE, p_etat IN histo_sntr_prev.etat%TYPE,p_type IN NUMBER,p_date IN DATE,
                                        io_motif IN OUT varchar2, io_debut IN OUT VARCHAR2 ,io_saisie IN OUT VARCHAR2);
  FUNCTION F_get_piece (p_numsin IN sin_prev.nosin%TYPE, p_nopiece IN pieces.nopiece%TYPE, p_date IN DATE) RETURN varchar2;
  FUNCTION F_get_reglement (    p_ligne     IN PK_PRDG_DYNAMIC_CURSOR.T_CLES) RETURN T_CHAR_TAB;
  FUNCTION f_get_salaire (p_numsin sntr_prev.nosin%TYPE, p_sal IN varchar2, p_date IN DATE) RETURN NUMBER;
/* ========================== Fin des Procedures privées ====================*/
/*===========================================================================*/

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom         :  F_get_segment                                              */
/* Type        :  Public                                                     */
/* Description :                                                             */
/* Entree      :  p_idsegment, no du segment PRDG (voir table PRDGSEGMENT)   */
/*                p_cle, clé segment (numindiv, numgar,... selon le segment) */
/*                p_cle2, clé segment (numindiv, numgar,... selon le segment)*/
/*                p_seqsgt, sequence du  segment : occurence du segment      */
/* Sortie      :                                                             */
/* Retour      :  T_CHAR_TAB, tableau des données du segment                 */
/*---------------------------------------------------------------------------*/
  FUNCTION F_get_segment (
    p_idsegment IN prdgsegment.idsegment%TYPE,
    p_ligne     IN PK_PRDG_DYNAMIC_CURSOR.T_CLES,
    p_niv       IN NUMBER,
    p_cle       IN VARCHAR2,
    p_cle2      IN VARCHAR2,
    p_seqsgt    IN NUMBER,
    p_datedeb      IN DATE,
    p_datefin      IN DATE,
    p_nomflux IN VARCHAR2)
    RETURN T_CHAR_TAB

  IS

    l_numindiv NUMBER;
    t_contrat  T_CHAR_TAB;
    t_indiv    T_CHAR_TAB;
    t_contact  T_CHAR_TAB;
    t_segment  T_CHAR_TAB;
    t_dossier_prev  T_CHAR_TAB;
    t_sinistre_prev T_CHAR_TAB;
    t_gar_prev      T_CHAR_TAB;
    --t_arret         T_CHAR_TAB;
    t_arret_det     T_CHAR_TAB;
    t_regl T_CHAR_TAB;
    t_total  T_CHAR_TAB;

    CURSOR C_segment IS
      SELECT numordre, iddonnee
      FROM PRDGSGDO
      WHERE idsegment = p_idsegment
      ORDER BY numordre ;

    R_segment C_segment%ROWTYPE;


  BEGIN
    CASE p_idsegment
      WHEN 2 THEN --STE
        t_indiv := F_get_indiv(p_cle);
      WHEN 3 THEN --STD
        t_indiv := F_get_indiv(F_get_org(p_cle2));
      WHEN 4 THEN --STF
        t_indiv := F_get_indiv(p_cle);
      WHEN 6 THEN --INT
        IF p_seqsgt = 1 THEN
          t_indiv := F_get_indiv(p_cle);
        ELSIF p_seqsgt=2 THEN
          t_indiv :=  F_get_indiv(F_get_org(p_cle2));
        END IF;
      WHEN 8 THEN --CTA
        t_contact := F_get_contact(p_cle);
        t_indiv := F_get_indiv(p_cle); --TO DO revoir donnee 39
      WHEN 10 THEN NULL;--TOT
      WHEN 11  THEN --ENS
        BEGIN
          SELECT numcli INTO l_numindiv FROM contrat WHERE numgar = p_ligne.cle(1);
          t_contrat := F_get_contrat(p_ligne.cle(1));
          t_indiv := F_get_indiv(l_numindiv);
        EXCEPTION
           WHEN OTHERS THEN RETURN t_segment; --TO DO Gérer
        END;
      WHEN  21 THEN --ENS
        BEGIN
          SELECT numcli INTO l_numindiv FROM contrat WHERE numgar = p_ligne.cle(1);
          t_contrat := F_get_contrat(p_ligne.cle(1));
          t_indiv := F_get_indiv(l_numindiv);
        EXCEPTION
           WHEN OTHERS THEN RETURN t_segment; --TO DO Gérer
        END;
      WHEN 12 THEN NULL;--EXE
      WHEN 13 THEN NULL;--CRE DCS
      WHEN 22 THEN NULL; --CRE ADS
      WHEN 14 THEN     --'SAT'  -- Dossier sinistre
        --t_dossier_prev    := F_get_dossier_sinistre (p_ligne.cle(8));
         dbms_output.put_line('SAT-'||p_ligne.cle(9));
         t_sinistre_prev := F_get_sinistre_prev(p_ligne.cle(9),p_datefin);
      WHEN 15 THEN --'ZAT'  -- Sous dossier sinistre
        t_indiv := F_get_indiv(p_cle);
        t_sinistre_prev := F_get_sinistre_prev(p_ligne.cle(9),p_datefin);
        t_gar_prev :=F_get_garantie(p_ligne.cle(9));
        t_arret_det := F_get_arret_detail(p_ligne.cle(9),p_datefin);
      WHEN 16 THEN NULL;--'BEN' -- Bénéficiaire final
        t_sinistre_prev := F_get_sinistre_prev(p_ligne.cle(9),p_datefin);
      WHEN 17 THEN NULL;--'REG'  -- Règlement
        t_regl := F_get_reglement(p_ligne);
      WHEN 18 THEN NULL;--'BER' -- Bénéficiaire du règlement
        t_regl := F_get_reglement(p_ligne);
      WHEN 19 THEN      --'DES'
        t_regl := F_get_reglement(p_ligne);
      ELSE
        RETURN t_segment;
    END CASE;
     -- dbms_output.put_line( ' Avant OPen SEGMeNT'||p_idsegment);
    OPEN C_segment;
     --dbms_output.put_line( ' Aprés OPen SEGMeNT'||p_idsegment);
    LOOP
      BEGIN
      FETCH C_segment INTO R_segment;

      EXIT WHEN C_segment%NOTFOUND;

      -- dbms_output.put_line( 'seg'||p_idsegment);
       --dbms_output.put_line( 'seg'||p_idsegment||'-'||R_segment.iddonnee);

      CASE R_segment.iddonnee
        /*WHEN 1 THEN
          t_segment(R_segment.numordre) := l_nomSegment;*/
        WHEN 10 THEN
          t_segment(R_segment.numordre) := t_indiv(1);
        WHEN 16 THEN
          t_segment(R_segment.numordre) := t_indiv(1);
        WHEN 28 THEN
          t_segment(R_segment.numordre) := t_indiv(1);
        WHEN 30 THEN
          t_segment(R_segment.numordre) := t_indiv(2);
        WHEN 33 THEN
          t_segment(R_segment.numordre) := t_indiv(3);
        WHEN 34 THEN
          t_segment(R_segment.numordre) := t_indiv(4);
        WHEN 35 THEN
          t_segment(R_segment.numordre) := substr(trim(t_indiv(5)||' '||t_indiv(6)||' '||t_indiv(7)),0,50);
        WHEN 36 THEN
          t_segment(R_segment.numordre) := t_indiv(9);
        WHEN 37 THEN
          t_segment(R_segment.numordre) := t_indiv(8);
        WHEN 38 THEN
          t_segment(R_segment.numordre) := t_indiv(10);
        WHEN 39 THEN
          t_segment(R_segment.numordre) := t_indiv(2);
        WHEN 40 THEN
          t_segment(R_segment.numordre) := NVL(t_contact(1),t_contact(2));
        WHEN 41 THEN
          t_segment(R_segment.numordre) :=t_contact(3);
        WHEN 42 THEN
          t_segment(R_segment.numordre) :=t_contact(4);
        WHEN 44 THEN
          t_segment(R_segment.numordre) := p_ligne.total;
        --WHEN 46 THEN
        --  t_segment(R_segment.numordre) := p_ligne.cle(7);--devise tot to do transco
        WHEN 48 THEN
          t_segment(R_segment.numordre) := t_contrat(1);
        WHEN 49 THEN
          t_segment(R_segment.numordre) := p_ligne.cle(1);
        WHEN 50 THEN
          t_segment(R_segment.numordre) :=t_indiv(1);
        /*WHEN 51 THEN --TO DO identifiant tiers
          t_segment(R_segment.numordre) :=t_indiv(1);*/
        WHEN 53 THEN
          t_segment(R_segment.numordre) :=p_ligne.cle(2);
        WHEN 54 THEN
          t_segment(R_segment.numordre) :=p_ligne.cle(3);
        WHEN 55 THEN
          t_segment(R_segment.numordre) :=p_ligne.cle(4);
        WHEN 56 THEN
          t_segment(R_segment.numordre) :=p_ligne.cle(5);
        WHEN 57 THEN
          t_segment(R_segment.numordre) :=p_ligne.cle(6);
        WHEN 59 THEN
          t_segment(R_segment.numordre) :=p_ligne.total;--total CRE DCS simplifié
        WHEN 256 THEN
          t_segment(R_segment.numordre) :=t_segment(R_segment.numordre-1);--correpond à la donnée 257
        WHEN 257 THEN
          t_segment(R_segment.numordre) :=F_get_totaux(p_ligne,p_cle2,p_nomflux,p_datedeb,p_datefin);--total CRE plusieurs segments
        WHEN 60 THEN
          t_segment(R_segment.numordre) :=p_ligne.cle(7);--devise dde
        WHEN 62 THEN
          t_segment(R_segment.numordre) :='';--mt converti
        WHEN 63 THEN
          t_segment(R_segment.numordre) :='';--devise dde converti
        WHEN 64 THEN
          t_segment(R_segment.numordre) :='';
        WHEN 65 THEN
          t_segment(R_segment.numordre) :='';
          -- DEBUT ADS  -- SAT
        WHEN 67 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(1);
        WHEN 68 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(2);
        WHEN 69 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(3);
        WHEN 70 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(4);
        WHEN 71 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(5);
        WHEN 225 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(101);
        WHEN 226 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(102);
        WHEN 227 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(103);
        WHEN 72 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(6);
        WHEN 73 THEN --sexe
          t_segment(R_segment.numordre) :=t_sinistre_prev(7);
        WHEN 74 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(8);
        WHEN 75 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(9);--'0';

       /* WHEN 79 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(13); --todo transco mais fac*/
        WHEN 80 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(14);--'0';
        WHEN 81 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(15);--'0';
        WHEN 82 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(16);--null;
        WHEN 83 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(17);--'0';
        WHEN 84 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(18);--'0';
        WHEN 85 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(19);--'0';
        WHEN 86 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(20);--'0';
        WHEN 87 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(21);--'0';
        WHEN 88 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(22);--'0';
        WHEN 89 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(23);--'0';
        WHEN 90 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(24);--'0';
        WHEN 91 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(25);--'0';
        WHEN 92 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(26);--'0';
          --FIN SAT
        WHEN 93 THEN
           t_segment(R_segment.numordre) := p_ligne.cle(9);--t_sinistre_prev(27);
        WHEN 94 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(28);
        WHEN 95 THEN
          t_segment(R_segment.numordre) :='01/01/2017';  -- TODO : a valoriser  fake value

        WHEN 97 THEN
          t_segment(R_segment.numordre) :=t_gar_prev(4);
        WHEN 98 THEN
          t_segment(R_segment.numordre) :='0';  -- TODO : a valoriser  fake value
        WHEN 99 THEN
          t_segment(R_segment.numordre) :=t_gar_prev(1);

        WHEN 102 THEN
          t_segment(R_segment.numordre) :=t_gar_prev(2);  -- Base lim rupture O
        WHEN 103 THEN
          t_segment(R_segment.numordre) :=t_gar_prev(3);--% lim rupture O

        WHEN 108 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(42);--date ouverture
        WHEN 109 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(43);  --motif ouverture
        WHEN 110 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(44);  -- date de clôture
        WHEN 111 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(45);  --motif de cloture
        WHEN 112 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(46) ;  -- date de reprise si zat 18 = RE donnée 109
        WHEN 113 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(47);  -- date de dernière rechute
        WHEN 114 THEN
          IF t_sinistre_prev(45) ='INV' OR t_sinistre_prev(44) IS NULL THEN --valorisée uniquement si sinistre cloturée hors motif INV
            t_segment(R_segment.numordre) :=NULL;
          ELSE
            t_segment(R_segment.numordre) :=t_arret_det(9);
          END IF;
        WHEN 115 THEN
          t_segment(R_segment.numordre) :=null;
        WHEN 116 THEN
          t_segment(R_segment.numordre) := t_sinistre_prev(50);
        WHEN 117 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(51);
        WHEN 119 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (53);
        WHEN 120 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (54);
        WHEN 121 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (55);

        WHEN 123 THEN
          t_segment(R_segment.numordre) :=t_arret_det(1);

        WHEN 124 THEN
          t_segment(R_segment.numordre) :='0';  -- TODO : a valoriser  fake value
        WHEN 125 THEN
          t_segment(R_segment.numordre) :='0';  -- TODO : a valoriser  fake value

        WHEN 127 THEN
          t_segment(R_segment.numordre) := t_sinistre_prev (90);
        WHEN 128 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (104);
        WHEN 129 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (105);
        WHEN 130 THEN
          t_segment(R_segment.numordre) :=t_arret_det(2);
        WHEN 131 THEN
          t_segment(R_segment.numordre) :=t_arret_det(3);


        WHEN 135 THEN
          t_segment(R_segment.numordre) :=t_arret_det(4);
            dbms_output.put_line('----135 : '||t_arret_det(4));
        WHEN 136 THEN
          t_segment(R_segment.numordre) :=t_arret_det(5);
        WHEN 137 THEN
          t_segment(R_segment.numordre) :=t_arret_det(6);
        WHEN 138 THEN
          t_segment(R_segment.numordre) :=t_arret_det(7);

        WHEN 141 THEN
          t_segment(R_segment.numordre) := t_arret_det(8);
        WHEN 142 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (76);  -- TODO : a valoriser  fake value
        WHEN 143 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (77);  -- TODO : a valoriser  fake value
        WHEN 144 THEN
          t_segment(R_segment.numordre) :='0';  -- TODO : a valoriser  fake value
        WHEN 145 THEN
          t_segment(R_segment.numordre) := t_arret_det(10);
        WHEN 146 THEN
          t_segment(R_segment.numordre) := t_arret_det(11);
        WHEN 147 THEN
          t_segment(R_segment.numordre) := t_arret_det(12);
        WHEN 148 THEN
          t_segment(R_segment.numordre) := t_arret_det(13);
        WHEN 149 THEN
          t_segment(R_segment.numordre) := t_arret_det(14);

        WHEN 151 THEN
          t_segment(R_segment.numordre) :='0';  -- TODO : a valoriser  fake value
        WHEN 152 THEN
          t_segment(R_segment.numordre) :='0';  -- TODO : a valoriser  fake value
        WHEN 153 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (53);
        WHEN 154 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (54);
        WHEN 155 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (55);
        WHEN 156 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (90);
        WHEN 232 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (104);
        WHEN 233 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (105);
        WHEN 234 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (106);
        WHEN 235 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (107);

        WHEN 158 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev (92);
        WHEN 161 THEN
          t_segment(R_segment.numordre) :=t_sinistre_prev(5);



        WHEN 173 THEN
          t_segment(R_segment.numordre) := t_regl(7) ;--Qualifiant mt
        WHEN 174 THEN
          t_segment(R_segment.numordre) := t_regl(7) ;--Montant
        WHEN 175 THEN
          t_segment(R_segment.numordre) := t_regl(8) ;--Période indemnisée hors franchise
        WHEN 176 THEN
          t_segment(R_segment.numordre) := t_regl(9) ;
        WHEN 177 THEN
          t_segment(R_segment.numordre) := t_regl(10) ;
        WHEN 178 THEN
          t_segment(R_segment.numordre) := t_regl(11) ;--Ref rglt

        WHEN 181 THEN
          t_segment(R_segment.numordre) := t_regl(15) ;--Qualif mt taxe
        WHEN 182 THEN
          t_segment(R_segment.numordre) := t_regl(15) ;--Mt taxe
        WHEN 183 THEN
          t_segment(R_segment.numordre) := t_regl(17) ;--Qualif rbt ss
        WHEN 184 THEN
          t_segment(R_segment.numordre) := t_regl(17) ;--Mt rbt SS
        WHEN 185 THEN
          t_segment(R_segment.numordre) := t_regl(19) ;--Qualif indem ss
        WHEN 186 THEN
          t_segment(R_segment.numordre) := t_regl(19) ;--Mt indemn SS
        WHEN 187 THEN
          t_segment(R_segment.numordre) := t_regl(21) ;--Qualif AR
        WHEN 188 THEN
          t_segment(R_segment.numordre) := t_regl(21) ;--Mt AR
        WHEN 189 THEN
          t_segment(R_segment.numordre) := t_regl(22) ;--Mt Brut
        WHEN 190 THEN
          t_segment(R_segment.numordre) := t_regl(23) ;--Mt net

        WHEN 192 THEN
          t_segment(R_segment.numordre) := t_regl(7) ;--Mt prest jour limitée = montant ?
        WHEN 193 THEN
          t_segment(R_segment.numordre) := t_regl(26) ;--Top mi temps

        WHEN 196 THEN
          t_segment(R_segment.numordre) := t_regl(28) ;--Motif annulation rglt
        WHEN 197 THEN
          t_segment(R_segment.numordre) := t_regl(29) ;--Type destinaire règlement (assuré, tuteur,société)
        WHEN 198 THEN
          t_segment(R_segment.numordre) := t_regl(30) ;--ID destinataire
        WHEN 199 THEN
          t_segment(R_segment.numordre) := t_regl(31) ;--Nom
        WHEN 200 THEN
          t_segment(R_segment.numordre) := t_regl(32) ;--Prénom
        WHEN 201 THEN
          t_segment(R_segment.numordre) := t_regl(33) ;--Nomnaiss
        WHEN 202 THEN
          t_segment(R_segment.numordre) := t_regl(34) ;--Ad n° rue
        WHEN 203 THEN
          t_segment(R_segment.numordre) := t_regl(35) ;--Ad nom rue
        WHEN 204 THEN
          t_segment(R_segment.numordre) := t_regl(36) ;--Ad compl
        WHEN 205 THEN
          t_segment(R_segment.numordre) := t_regl(37) ;--Ad ville
        WHEN 206 THEN
          t_segment(R_segment.numordre) := t_regl(38) ;--Ad code pos
        WHEN 207 THEN
          t_segment(R_segment.numordre) := t_regl(39) ;--Pays
        WHEN 208 THEN
          t_segment(R_segment.numordre) := t_regl(40) ;--Moyen de paiement
       /* WHEN 209 THEN
          t_segment(R_segment.numordre) := t_regl(41) ;--Type de béné
        WHEN 210 THEN
          t_segment(R_segment.numordre) := t_regl(42) ;--Id béné
        WHEN 211 THEN
          t_segment(R_segment.numordre) := t_regl(43) ;--Nom
        WHEN 212 THEN
          t_segment(R_segment.numordre) := t_regl(44) ;--Prénom
        WHEN 213 THEN
          t_segment(R_segment.numordre) := t_regl(45) ;--Nomnaiss
        WHEN 214 THEN
          t_segment(R_segment.numordre) := t_regl(46) ;--Ad n° rue
        WHEN 215 THEN
          t_segment(R_segment.numordre) := t_regl(47) ;--Ad nom rue
        WHEN 216 THEN
          t_segment(R_segment.numordre) := t_regl(48) ;--Ad compl
        WHEN 217 THEN
          t_segment(R_segment.numordre) := t_regl(49) ;--Ad ville
        WHEN 218 THEN
          t_segment(R_segment.numordre) := t_regl(50) ;--Ad code pos
        WHEN 219 THEN
          t_segment(R_segment.numordre) := t_regl(51) ;--Pays*/


        ELSE
        --dbms_output.put_line('Dans le ESLE seg'||p_idsegment);
          t_segment(R_segment.numordre) := '';
      END CASE;

     EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('ERR seg'||p_idsegment||'['||R_segment.numordre||']='||R_segment.iddonnee|| ' cle = ['||p_cle||']' || SQLERRM);
     END;

    END LOOP;
    CLOSE C_segment;
    RETURN t_segment;

    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('ERR seg'||p_idsegment||'-'||R_segment.iddonnee|| ' cle = ['||p_cle||']' || SQLERRM);
        IF C_segment%ISOPEN THEN
          CLOSE C_segment;
        END IF;
        RETURN t_segment;
  END F_get_segment;
  /*===========================================================================*/

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_get_org                                                 */
/* Type         :  Privé                                                     */
/* Description  :  Fonction qui retourne le numéro de l'individu             */
/* Entree       :  p_numorg, numéro de l'organisme assureur                  */
/* Sortie       :                                                            */
/* Retour       :  number                                                    */
/*---------------------------------------------------------------------------*/

  FUNCTION F_get_org (p_numorg IN pers_organisme.numorg%TYPE)
    RETURN NUMBER IS
    loc_numindiv pers_organisme.numindiv%TYPE;

  BEGIN

    SELECT numindiv into loc_numindiv
    FROM pers_organisme
    WHERE numorg = p_numorg;
    RETURN loc_numindiv;
  END F_get_org;

/*===========================================================================*/

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_get_indiv                                               */
/* Type         :  Privé                                                     */
/* Description  :  Fonction qui retourne un tableau contenant toutes les     */
/*                 données spécifiques à l'individu passé en paramètre       */
/* Entree       :  p_numindiv, numéro d'individu (PR,DG ou souscripteur)     */
/* Sortie       :                                                            */
/* Retour       :  T_CHAR_TAB, tableau des données de l'individu             */
/*---------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------
  Tableau retourné :
  ( 1) : N° de SIRET sur 14 caractères
  ( 2) : Nom de l'individu
  ( 3) : Adresse ligne 1 - numéro
  ( 4) : Adresse ligne 2 - nom de la rue/avenue...
  ( 5) : Adresse ligne 3 - précisions (par exemple la boîte postale ou des compléments d'adresse)
  ( 6) : Ville ('INCONNUE' par défaut)
  ( 7) : Code postal ('00000' par défaut)
  ( 8) : Code pays (ISO 3166-1 alpha-2)
-----------------------------------------------------------------------------*/

  FUNCTION F_get_indiv(p_numindiv IN individu.numindiv%TYPE)
    RETURN T_CHAR_TAB
  IS
    tab_indiv T_CHAR_TAB;

    CURSOR C_get_indiv IS
      SELECT
         CASE WHEN pm.siret IS NULL THEN '99999200100019' ELSE TO_CHAR(pm.siret) END      siret
        ,i.nom                                                                              nom
        ,TO_CHAR(a.no_voie)                                                             no_voie
        ,CASE WHEN tv.libelle IS NULL THEN '' ELSE tv.libelle || ' ' END || a.nom_voie nom_voie
        ,a.comp_adresse                                                                 av_voie
        ,a.adresse_2                                                                    ap_voie
        ,CASE WHEN a.flag_cedex ='N' THEN '' ELSE 'cedex ' || a.no_cedex END              cedex
        ,CASE WHEN a.ville IS NULL THEN 'INCONNU' ELSE a.ville END                        ville
        ,CASE WHEN a.codpos IS NULL THEN '00000' ELSE a.codpos END                    cd_postal
        ,nvl(p.codeiso,'999')                                                                pays
      FROM            individu     i
      LEFT OUTER JOIN pers_morale  pm ON pm.numindiv = i.numindiv
      LEFT OUTER JOIN pers_adresse a  ON a.idadresse = pk_personne.f_idadresse (i.numindiv, 0, sysdate, 'O', 0, -1 )
      LEFT OUTER JOIN libelle_bis  tv ON (tv.mnemo = 'TYPE_VOIE' and tv.code = a.type_voie)
      LEFT OUTER JOIN pays         p  ON p.codpays = a.codpays
      WHERE i.numindiv = p_numindiv
    ;
R_get_indiv C_get_indiv%rowtype;

  BEGIN


    OPEN C_get_indiv;
    FETCH C_get_indiv INTO R_get_indiv;
    tab_indiv ( 1) := R_get_indiv.siret;
    tab_indiv ( 2) := R_get_indiv.nom;
    tab_indiv ( 3) := R_get_indiv.no_voie;
    tab_indiv ( 4) := R_get_indiv.nom_voie;
    tab_indiv ( 5) := R_get_indiv.av_voie;
    tab_indiv ( 6) := R_get_indiv.ap_voie;
    tab_indiv ( 7) := R_get_indiv.cedex;
    tab_indiv ( 8) := R_get_indiv.cd_postal;
    tab_indiv ( 9) := R_get_indiv.ville;
    tab_indiv ( 10) := R_get_indiv.pays;

    CLOSE C_get_indiv;

    RETURN ( tab_indiv );

    exception when others then
    dbms_output.put_line('Erreur dans f_get_indiv ' || SQLERRM);

  END F_get_indiv;
/*===========================================================================*/
  FUNCTION F_get_reglement ( p_ligne     IN PK_PRDG_DYNAMIC_CURSOR.T_CLES) RETURN T_CHAR_TAB
  IS
    tab_regl T_CHAR_TAB;

    -- MUR M0006701 modification du curseur
	CURSOR C_get_regl IS
select
  DEBUT , FIN , sum(MTPREST)  MTPREST, BASE_REGIME , MT_SS , BASE_AUTRE , MI_TEMPS , DUREE , max(DATOPE) DATOPE, TYPE_DEST , TYPE_BENE , NUMDEST
  , BENE_NUM , BENE_NOM , BENE_PRENOM , BENE_NOMNAISS , BENE_NOM_VOIE , BENE_COMP_ADRESSE , BENE_CODPOS , BENE_PAYS , BENE_VILLE , DEST_NUM , DEST_NOM , DEST_PRENOM , DEST_NOMNAISS , DEST_NOM_VOIE , DEST_COMP_ADRESSE , DEST_CODPOS , DEST_PAYS , DEST_VILLE
from (SELECT
      greatest(arret.debut,NVL(s.priscalc,s.prischarge)) debut,--hors franchise
      arret.fin,
      -- M0006558 ROUND (f_total_histo_d (histo_jours.idhisto, -2), 2) mtprest,
      round(F_TOTAL_IDCALCUL_D(histo_calcul.idcalcul,0) + F_TOTAL_IDCALCUL_D(histo_calcul.idcalcul,1) - F_TOTAL_IDCALCUL_D(histo_calcul.idcalcul,2),2)  mtprest,
      arret.base_regime,
      arret.base_regime *(arret.fin-arret.debut+1) mt_ss,
      arret.base_autre,
      decode(arret.type,4,'O','N') mi_temps,
      (arret.fin-arret.debut+1) duree,
      trunc(decaismt.datpay)      DATOPE,
      decode(repartition_bene.type_dest,1,'BEN',2,'ENT',3,'ASS',8,'TUT', null) type_dest,
      beneficiaire.type_bene,
      DECAISMT.numdest
      ,bene.numindiv                      bene_num
      ,bene.nom                           bene_nom
      ,bene.prenom                        bene_prenom
      ,bene.NOMJF                         bene_nomnaiss
      ,nvl(bene_adress.nom_voie,' ')      bene_nom_voie
      ,nvl(bene_adress.comp_adresse,' ')  bene_comp_adresse
      ,bene_adress.codpos                 bene_codpos
      ,decode(bene_adress.codpays,1,'FR','999')        bene_pays
      ,nvl(bene_adress.ville,' ')         bene_ville
      ,destinataire.numindiv              dest_num
      ,destinataire.nom                   dest_nom
      ,destinataire.prenom                dest_prenom
      ,destinataire.NOMJF                 dest_nomnaiss
      ,nvl(dest_adress.nom_voie,' ')      dest_nom_voie
      ,nvl(dest_adress.comp_adresse,' ')  dest_comp_adresse
      ,dest_adress.codpos                 dest_codpos
      ,decode(dest_adress.codpays,1,'FR','999')        dest_pays
      ,nvl(dest_adress.ville,' ')         dest_ville
    FROM  -- M0006558 histo_jours,
      histo_calcul,
      repartition,
      V_REPARTITION_HISTO_DEST repartition_bene,
      individu ind,
      individu destinataire,
      individu bene,
      beneficiaire,
      dossier_sinistre d,
      sntr_prev s,
      (SELECT idarret,debut,fin ,nosin,base_regime,base_autre,type
      FROM  arret ar
      UNION
      SELECT ha.idcalcul idarret ,debut,fin ,nosin,base_regime,base_autre,type
      FROM  arret ar, histo_annul ha
      WHERE ha.idannul = ar.idarret) arret,
      affectation,
      decaismt,
      pers_adresse bene_adress,
      pers_adresse dest_adress
    WHERE  repartition_bene.valide = 'O'
    AND arret.nosin = s.nosin
    AND arret.idarret = histo_calcul.idcalcul
    AND histo_calcul.idrepartition = repartition.idrepartition
    -- M0006558 AND histo_calcul.idcalcul        = histo_jours.idcalcul
    AND histo_calcul.numbene         = repartition_bene.numbene
    AND histo_calcul.numbene         = ind.numindiv
    AND repartition.idrepartition    = repartition_bene.idrepartition
    AND s.nosin = repartition.nosin
    AND s.iddossier = d.iddossier
    AND NVL(histo_calcul.numbene_dest,repartition_bene.numbene_dest) = repartition_bene.numbene_dest
    AND histo_calcul.idcalcul  = p_ligne.CLE(10)
    AND affectation.numaffec= histo_calcul.numdec
    AND affectation.NUMDECAISMT= DECAISMT.numdecaismt
    AND dest_adress.idadresse = pk_personne.f_idadresse(DECAISMT.numdest)
    AND bene_adress.idadresse = pk_personne.f_idadresse(DECAISMT.numbene)
    AND destinataire.numindiv = DECAISMT.numdest
    AND bene.numindiv = beneficiaire.numbene
    AND beneficiaire.numbene = repartition_bene.numbene
    AND beneficiaire.idadhesion=repartition.idadhesion
    AND beneficiaire.numfor=repartition.numfor
    AND beneficiaire.numindiv=d.numindiv


  UNION   -- MUR M0006701 annulation decompte - annulation calcul
        SELECT
      greatest(arret.debut,NVL(s.priscalc,s.prischarge)) debut,--hors franchise
      arret.fin,
      -- M0006558 ROUND (f_total_histo_d (histo_jours.idhisto, -2), 2) mtprest,
      - round(F_TOTAL_IDCALCUL_D(histo_calcul.idcalcul,0) + F_TOTAL_IDCALCUL_D(histo_calcul.idcalcul,1) - F_TOTAL_IDCALCUL_D(histo_calcul.idcalcul,2),2)  mtprest,
      arret.base_regime,
      arret.base_regime *(arret.fin-arret.debut+1) mt_ss,
      arret.base_autre,
      decode(arret.type,4,'O','N') mi_temps,
      (arret.fin-arret.debut+1) duree,
      trunc(histo_calcul.datannul)      DATOPE,
      decode(repartition_bene.type_dest,1,'BEN',2,'ENT',3,'ASS',8,'TUT', null) type_dest,
      beneficiaire.type_bene,
      DECAISMT2.numdest
      ,bene.numindiv                      bene_num
      ,bene.nom                           bene_nom
      ,bene.prenom                        bene_prenom
      ,bene.NOMJF                         bene_nomnaiss
      ,nvl(bene_adress.nom_voie,' ')      bene_nom_voie
      ,nvl(bene_adress.comp_adresse,' ')  bene_comp_adresse
      ,bene_adress.codpos                 bene_codpos
      ,decode(bene_adress.codpays,1,'FR','999')        bene_pays
      ,nvl(bene_adress.ville,' ')         bene_ville
      ,destinataire.numindiv              dest_num
      ,destinataire.nom                   dest_nom
      ,destinataire.prenom                dest_prenom
      ,destinataire.NOMJF                 dest_nomnaiss
      ,nvl(dest_adress.nom_voie,' ')      dest_nom_voie
      ,nvl(dest_adress.comp_adresse,' ')  dest_comp_adresse
      ,dest_adress.codpos                 dest_codpos
      ,decode(dest_adress.codpays,1,'FR','999')        dest_pays
      ,nvl(dest_adress.ville,' ')         dest_ville
    FROM
      histo_calcul_annul histo_calcul, histo_calcul hc,
      repartition,
      V_REPARTITION_HISTO_DEST repartition_bene,
      individu ind,
      individu destinataire,
      individu bene,
      beneficiaire,
      dossier_sinistre d,
      sntr_prev s,
      (SELECT idarret,debut,fin ,nosin,base_regime,base_autre,type
      FROM  arret ar
      UNION
      SELECT ha.idcalcul idarret ,debut,fin ,nosin,base_regime,base_autre,type
      FROM  arret ar, histo_annul ha
      WHERE ha.idannul = ar.idarret) arret,
      affectation_annul affectation,
      pnul decaismt, decaismt decaismt2 ,
      pers_adresse bene_adress,
      pers_adresse dest_adress
    WHERE  repartition_bene.valide = 'O'
    AND arret.nosin = s.nosin
    AND arret.idarret = histo_calcul.idcalcul
    AND histo_calcul.idrepartition = repartition.idrepartition
    -- M0006558 AND histo_calcul.idcalcul        = histo_jours.idcalcul
    AND hc.numbene         = repartition_bene.numbene
    AND hc.numbene         = ind.numindiv
    AND repartition.idrepartition    = repartition_bene.idrepartition
    AND s.nosin = repartition.nosin
    AND s.iddossier = d.iddossier
    AND NVL(hc.numbene_dest,repartition_bene.numbene_dest) = repartition_bene.numbene_dest
    AND histo_calcul.idcalcul = p_ligne.CLE(10)
    AND affectation.numaffec= histo_calcul.numdec
    AND affectation.NUMDECAISMT= DECAISMT.numdecaismt
    AND dest_adress.idadresse = pk_personne.f_idadresse(DECAISMT2.numdest)
    AND bene_adress.idadresse = pk_personne.f_idadresse(DECAISMT2.numbene)
    AND destinataire.numindiv = DECAISMT2.numdest
    AND bene.numindiv = beneficiaire.numbene
    AND beneficiaire.numbene = repartition_bene.numbene
    AND beneficiaire.idadhesion=repartition.idadhesion
    AND beneficiaire.numfor=repartition.numfor
    AND beneficiaire.numindiv=d.numindiv
	and decaismt2.numdecaismt = decaismt.numdecaismt
	and (hc.idcalcul = histo_calcul.idcalcul and  hc.creation <= histo_calcul.datannul )
  AND histo_calcul.montant >0 --7053 différenciation du recalcul / regul
  AND  decaismt2.flagpay+0   = 1
  )
group by   DEBUT , FIN /*, sum(MTPREST) */, BASE_REGIME , MT_SS , BASE_AUTRE , MI_TEMPS , DUREE /*, max(DATOPE)*/ , TYPE_DEST , TYPE_BENE , NUMDEST
  , BENE_NUM , BENE_NOM , BENE_PRENOM , BENE_NOMNAISS , BENE_NOM_VOIE , BENE_COMP_ADRESSE , BENE_CODPOS , BENE_PAYS , BENE_VILLE , DEST_NUM , DEST_NOM , DEST_PRENOM , DEST_NOMNAISS , DEST_NOM_VOIE , DEST_COMP_ADRESSE , DEST_CODPOS , DEST_PAYS , DEST_VILLE
   UNION
   --INDU part positive
    SELECT
      greatest(arret.debut,NVL(s.priscalc,s.prischarge)) debut,--hors franchise
      arret.fin,
      -- M0006558 ROUND (f_total_histo_d (histo_jours.idhisto, -2), 2) mtprest,
      round(F_TOTAL_IDCALCUL_D(histo_calcul.idcalcul,0) + F_TOTAL_IDCALCUL_D(histo_calcul.idcalcul,1) - F_TOTAL_IDCALCUL_D(histo_calcul.idcalcul,2),2)  mtprest,
      arret.base_regime,
      arret.base_regime *(arret.fin-arret.debut+1) mt_ss,
      arret.base_autre,
      decode(arret.type,4,'O','N') mi_temps,
      (arret.fin-arret.debut+1) duree,
      trunc(encaismt.datpay)      DATOPE,
      decode(repartition_bene.type_dest,1,'BEN',2,'ENT',3,'ASS',8,'TUT', null) type_dest,
      beneficiaire.type_bene,
      encaismt.numcli
      ,bene.numindiv                      bene_num
      ,bene.nom                           bene_nom
      ,bene.prenom                        bene_prenom
      ,bene.NOMJF                         bene_nomnaiss
      ,nvl(bene_adress.nom_voie,' ')      bene_nom_voie
      ,nvl(bene_adress.comp_adresse,' ')  bene_comp_adresse
      ,bene_adress.codpos                 bene_codpos
      ,decode(bene_adress.codpays,1,'FR','999')        bene_pays
      ,nvl(bene_adress.ville,' ')         bene_ville
      ,destinataire.numindiv              dest_num
      ,destinataire.nom                   dest_nom
      ,destinataire.prenom                dest_prenom
      ,destinataire.NOMJF                 dest_nomnaiss
      ,nvl(dest_adress.nom_voie,' ')      dest_nom_voie
      ,nvl(dest_adress.comp_adresse,' ')  dest_comp_adresse
      ,dest_adress.codpos                 dest_codpos
      ,decode(dest_adress.codpays,1,'FR','999')        dest_pays
      ,nvl(dest_adress.ville,' ')         dest_ville
    FROM  -- M0006558 histo_jours,
      histo_calcul,
      repartition,
      V_REPARTITION_HISTO_DEST repartition_bene,
      individu ind,
      individu destinataire,
      individu bene,
      beneficiaire,
      dossier_sinistre d,
      sntr_prev s,
      (SELECT idarret,debut,fin ,nosin,base_regime,base_autre,type
      FROM  arret ar
      UNION
      SELECT ha.idcalcul idarret ,debut,fin ,nosin,base_regime,base_autre,type
      FROM  arret ar, histo_annul ha
      WHERE ha.idannul = ar.idarret) arret,
      affectation,
      compte_client,
      encaismt,
      pers_adresse bene_adress,
      pers_adresse dest_adress
     -- histo_annul ABO
    WHERE  repartition_bene.valide = 'O'
    AND arret.nosin = s.nosin
    AND arret.idarret = histo_calcul.idcalcul
    AND histo_calcul.idrepartition = repartition.idrepartition
    -- M0006558 AND histo_calcul.idcalcul        = histo_jours.idcalcul
    AND histo_calcul.numbene         = repartition_bene.numbene
    AND histo_calcul.numbene         = ind.numindiv
    AND repartition.idrepartition    = repartition_bene.idrepartition
    AND s.nosin = repartition.nosin
    AND s.iddossier = d.iddossier
    AND NVL(histo_calcul.numbene_dest,repartition_bene.numbene_dest) = repartition_bene.numbene_dest
    AND affectation.NUMAFFEC =  histo_calcul.numdec
    AND histo_calcul.idcalcul  = p_ligne.CLE(10)
   -- AND histo_annul.idcalcul = histo_calcul.idcalcul ABO
    --AND flag_remb='O' ABO
    AND compte_client.numfact  = affectation.numaffec
    AND compte_client.codope   = 2
    AND encaismt.numencaismt = compte_client.numencaismt
    AND dest_adress.idadresse = pk_personne.f_idadresse(encaismt.numcli)
    AND bene_adress.idadresse = pk_personne.f_idadresse(histo_calcul.numbene)
    AND destinataire.numindiv = encaismt.numcli
    AND bene.numindiv = beneficiaire.numbene
    AND beneficiaire.numbene = repartition_bene.numbene
    AND beneficiaire.idadhesion=repartition.idadhesion
    AND beneficiaire.numfor=repartition.numfor
    AND beneficiaire.numindiv=d.numindiv;

    R_get_regl C_get_regl%rowtype;

  BEGIN


    IF p_ligne.cle(10) <> 'NV' THEN

    OPEN C_get_regl;

    FETCH C_get_regl INTO R_get_regl;


    tab_regl(7) := R_get_regl.mtprest ; --  iddonne [174] Montant O
    tab_regl(8) := to_char(R_get_regl.debut,'dd/mm/yyyy'); --  iddonne [175] Période indemnisée hors franchise O
    tab_regl(9) := to_char(R_get_regl.fin,'dd/mm/yyyy'); --  iddonne [176] Fin période O
    tab_regl(10) := to_char(R_get_regl.datope,'dd/mm/yyyy'); --  iddonne [177] Date rglt O
    tab_regl(11) := null; --R_get_regl.  iddonne [178] Ref rglt F


    tab_regl(15) := null; --R_get_regl.  iddonne [182] Mt taxe C
    tab_regl(17) := R_get_regl.mt_ss  ;--  iddonne [184] Mt rbt SS O  * nombre de jours
    tab_regl(19) := R_get_regl.base_regime; --R_get_regl.  iddonne [186] Mt indemn SS C
    tab_regl(21) := R_get_regl.base_autre; --R_get_regl.  iddonne [188] Mt AR C
    tab_regl(22) := f_get_salaire(p_ligne.CLE(9),'BRUT',sysdate);--189
    tab_regl(23) := f_get_salaire(p_ligne.CLE(9),'NET',sysdate);
   --- tab_regl(25) := null; --R_get_regl.  iddonne [192] Mt prest jour limitée C
    tab_regl(26) := R_get_regl.mi_temps; --R_get_regl.  iddonne [193] Top mi temps C

    tab_regl(28) := null;
    IF R_get_regl.mtprest <0 THEN
     tab_regl(28) := null; --R_get_regl.  iddonne [196] Motif annulation rglt F
    END IF;
    tab_regl(29) := R_get_regl.type_dest; --R_get_regl.  iddonne [197] Type destinataire O

    tab_regl(30) := R_get_regl.numdest;--   iddonne [198] ID destinataire F
    tab_regl(31) := R_get_regl.dest_nom;--  iddonne [199] Nom O
    tab_regl(32) := R_get_regl.dest_prenom;--   iddonne [200] Prénom C
    tab_regl(33) := R_get_regl.dest_nomnaiss;--   iddonne [201] Nomnaiss C
    IF R_get_regl.type_dest='ENT' THEN
      SELECT SIRET INTO  tab_regl(30) FROM PERS_MORALE WHERE numindiv = R_get_regl.numdest;
       tab_regl(32):=null;
       tab_regl(33):=null;
    END IF;


    tab_regl(34) := null; --R_get_regl.  iddonne [202] Ad n° rue F
    tab_regl(35) := R_get_regl.dest_nom_voie; -- iddonne [203] Ad nom rue F
    tab_regl(36) := R_get_regl.dest_comp_adresse; -- iddonne [204] Ad compl F
    tab_regl(37) := R_get_regl.dest_ville; --R_get_regl.  iddonne [205] Ad ville O
    tab_regl(38) := R_get_regl.dest_codpos; -- iddonne [206] Ad code pos O
    tab_regl(39) := R_get_regl.dest_pays; -- iddonne [207] Pays O
    tab_regl(40) := '30'; -- iddonne [208] Moyen de paiement O
    /*tab_regl(41) := f_get_transco('PRDG','TYPE_BENE',R_get_regl.type_bene,1);--  iddonne [209] Type de béné O
    tab_regl(42) := null; --R_get_regl.  iddonne [210] Id béné F
    tab_regl(43) := R_get_regl.bene_nom; --R_get_regl.  iddonne [211] Nom O
    tab_regl(44) := R_get_regl.bene_prenom; --R_get_regl.  iddonne [212] Prénom C
    tab_regl(45) := R_get_regl.bene_nomnaiss; --R_get_regl.  iddonne [213] Nomnaiss C
    tab_regl(46) := null; --R_get_regl.  iddonne [214] Ad n° rue F
    tab_regl(47) := R_get_regl.bene_nom_voie; --R_get_regl.  iddonne [215] Ad nom rue F
    tab_regl(48) := R_get_regl.bene_comp_adresse; --R_get_regl.  iddonne [216] Ad compl F
    tab_regl(49) := R_get_regl.bene_ville; --R_get_regl.  iddonne [217] Ad ville O
    tab_regl(50) := R_get_regl.bene_codpos; --R_get_regl.  iddonne [218] Ad code pos O
    tab_regl(51) := R_get_regl.bene_pays; --R_get_regl.  iddonne [219] Pays O
    */


    CLOSE C_get_regl;
    END IF;

    RETURN ( tab_regl );
    exception when others then
    pk_trace.p_ins_journal_adm (i_nom_traitement      => 'CLI_PRDG',
                               i_session             => 99,
                               i_niv_msg             => 1,
                               i_msg_adm             => substr('erreur  appel des reglement = ['||p_ligne.CLE(10)||' / '||SQLERRM||']',0,132),
                               i_idligne             => 0);

                                   RETURN ( tab_regl );
  END F_get_reglement;
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_get_sinistre_prev                                               */
/* Type         :  Privé                                                     */
/* Description  :  Fonction qui retourne un tableau contenant toutes les     */
  /*                 données spécifiques au sinistre prévoyance passé en paramètre */
/* Entree       :  p_numindiv, numéro d'individu (PR,DG ou souscripteur)     */
/* Sortie       :                                                            */
/* Retour       :  T_CHAR_TAB, tableau des données de l'individu             */
/*---------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------
  Tableau retourné :
  ( 1) :
  ( 2) :
  ( 3) :
  ( 4) :
  ( 5) :
  ( 6) :
  ( 7) :
  ( 8) :
-----------------------------------------------------------------------------*/

  FUNCTION F_get_sinistre_prev (p_numsin IN sin_prev.nosin%TYPE,p_date IN DATE) -- TODO :rajouter le numgar en paraméetre
    RETURN T_CHAR_TAB
  IS
    tab_sntrt T_CHAR_TAB;
    loc_debut varchar2(10);
    loc_saisie varchar2(10);
    loc_motif  varchar2(30);
    loc_BRUT   number(11,2);
    loc_BRUT_calc   number(11,2);
    loc_NET    number(11,2);


    CURSOR C_get_sntrt IS
      SELECT
      sp.nosin                       --2	ID sous dossier	4	21	O	AN	Id unique du DG 	Identifiant n°sinistre
      ,sp.cause cause_arret
      ,sp.declaration
      ,NVL(sp.priscalc,sp.prischarge) DPAC
      ,trunc(NVL(sp.MODIFICATION,sp.CREATION)) date_modif    -- 4	Date dernière modif.	27	8	O	D	Donnée modifiée dès SAT ou ZAT modifiée	Ouverture : date de saisie du dossier

      ,dest.numindiv            dest_numindiv     -- Identifiant SI	7	35	O	AN	Compléter par des blancs
      ,dest.nom                 dest_nom              -- Nom usuel	42	35	O	AN
      ,nvl(dest.prenom,' ')     dest_prenom                              -- Prénom	77	35	O	AN
      ,nvl(dest.NOMJF,' ')      dest_nomnais
      ,dest.DATNAIS             dest_datnaiss -- Nom naissance	112	35	F	AN
      ,assu.DATNAIS             assu_datnaiss                 -- Date naiss	147	8	O	D
      ,adress.no_voie           dest_no_voie
      ,nvl(adress.nom_voie,' ') dest_nom_voie
      ,nvl(adress.comp_adresse,' ') dest_comp_adresse
      ,adress.codpos                dest_codpos
      ,f_pays(adress.codpays)       dest_pays
      ,assu.sexe
      ,assu.nom
      ,assu.nomjf
      ,assu.prenom
      ,ds.iddossier   --67,'ID dossier',21,'O','AN',NULL);
      ,sp.survenance      --68,'Date de survenance',8,'O','D',NULL);
      ,ds.numindiv    numassu --71,'Identifiant SI assuré',21,'O','AN',NULL);
      ,assu.sexe     assu_sexe --73,'Sexe',1,'F','T',NULL);
      ,pk_personne.f_situ_pers(assu.numindiv, 2, sp.CREATION )  situ_fam --79,'Situation familiale',3,'F','T',NULL);
      ,adh.date_fin_adhe              --74,'Date de sortie du contrat de travail',8,'C','D',NULL);
      ,persmor.siret --75,'SIRET',14,'O','N6',NULL);
      ,gar.age_limite
      ,gar.duree_fran
      ,least(add_months(assu.DATNAIS,12*NVL(gar.age_limite,999) ), sp.survenance+1095) limit_versement
    from  SNTR_PREV sp,
          SIN sin,
          DOSSIER_SINISTRE ds,
          REPARTITION rep,
          REPARTITION_BENE rep_bene,
          individu dest,
          individu assu,
          pers_adresse adress,
          PERS_MORALE persmor,
          adhe_cntrt adh,
          gar_prev gar
    where sp.nosin = p_numsin
    AND sp.nosin = sin.nosin
    AND assu.numindiv = sin.numindiv
    AND sp.IDDOSSIER = ds.iddossier
    AND sp.nosin = rep.NOSIN
    AND gar.numfor = rep.numfor
    AND adress.idadresse = pk_personne.f_idadresse(dest.numindiv)
    AND rep.IDREPARTITION = rep_bene.IDREPARTITION
    AND rep.valide ='O'
    AND rep.idadhesion = adh.idadhesion
    AND rep_bene.NUMBENE_DEST = dest.numindiv
    AND dest.numindiv = persmor.numindiv
    ;



    R_get_sntrt C_get_sntrt%rowtype;

  BEGIN

    OPEN C_get_sntrt;

    FETCH C_get_sntrt INTO R_get_sntrt;

    tab_sntrt (1 ) := R_get_sntrt.iddossier;
    tab_sntrt (2 ) := to_char(R_get_sntrt.survenance,'dd/mm/yyyy');
    tab_sntrt (3 ) := to_char(R_get_sntrt.declaration,'dd/mm/yyyy');
    tab_sntrt (4 ) :=  NVL(f_get_transco('PRDG','CAUS',R_get_sntrt.cause_arret,1),R_get_sntrt.cause_arret); --70
    tab_sntrt (5 ) := R_get_sntrt.numassu;
    tab_sntrt (6 ) := to_char(R_get_sntrt.assu_datnaiss,'dd/mm/yyyy');
    tab_sntrt (7 ) := R_get_sntrt.assu_sexe;

    tab_sntrt (8 ) := to_char(R_get_sntrt.date_fin_adhe,'dd/mm/yyyy');-- --sortie contrat de travail
    tab_sntrt (9 ) := R_get_sntrt.siret;
    tab_sntrt (13) := R_get_sntrt.situ_fam;
    tab_sntrt (14) := '0';-- R_get_sntrt.  --TODO Obligatoire
    tab_sntrt (15) := 'II';--null;-- R_get_sntrt.
    tab_sntrt (16) := null;--R_get_sntrt.
    tab_sntrt (17) := 'N';--null;--R_get_sntrt.
    tab_sntrt (18) := null;--R_get_sntrt.
    tab_sntrt (19) := null;--R_get_sntrt.
    tab_sntrt (20) := null;--R_get_sntrt.
    tab_sntrt (21) := null;--R_get_sntrt.
    tab_sntrt (22) := null;--R_get_sntrt.
    tab_sntrt (23) := null;--R_get_sntrt.
    tab_sntrt (24) := null;--R_get_sntrt.
    tab_sntrt (25) := null;--R_get_sntrt.
    tab_sntrt (26) := null;--R_get_sntrt.
-- fin SAT
-- ZAT  correspond au sous dossier, soit le sinistre lui même
    tab_sntrt (27) := R_get_sntrt.nosin; --R_get_sntrt.  iddonne [93] ID sous dossier O
    IF tab_sntrt (4 )='MA' THEN  tab_sntrt (28):='M1';--iddonne [94]  Type de ss dossier O
    ELSE  tab_sntrt (28):=tab_sntrt (4 );
    END IF;
    tab_sntrt (29) := to_char(R_get_sntrt.date_modif,'dd/mm/yyyy');--  iddonne [95]  Date dernière modif. O

    tab_sntrt (35) := null; --R_get_sntrt.  iddonne [101] Périodicité rente C
    tab_sntrt (38) := '01'; --R_get_sntrt.  iddonne [104] Type de grand risque O
    tab_sntrt (39) := '003'; --R_get_sntrt.  iddonne [105] Type de risque O

    --R_get_sntrt.  iddonne [108] Date ouv. Ss doss O
    tab_sntrt (43):=NULL;
    tab_sntrt (42):=NULL;
    tab_sntrt (46):= NULL;

    P_get_histo_sinistre_prev(p_numsin,1,1,p_date,tab_sntrt (43),tab_sntrt (46),tab_sntrt (42));--ouverture du dossier date systeme
    tab_sntrt (43) := f_get_transco('PRDG','HISTO_MOTI',tab_sntrt (43),1); --R_get_sntrt.  iddonne [109] Motif ouverture O
    dbms_output.put_line('Ouverture sin :'||tab_sntrt (42)||'- donnée n°'||tab_sntrt (43) );
    tab_sntrt (44) := null; --R_get_sntrt.  iddonne [110] Date clôture C
    tab_sntrt (45) := null;
    P_get_histo_sinistre_prev(p_numsin,2,2,p_date,tab_sntrt (45),loc_debut,tab_sntrt (44));--fermeture du dossier
    tab_sntrt (45) := f_get_transco('PRDG','HISTO_MOTI',tab_sntrt (45),1); --R_get_sntrt.  iddonne [111] Motif clôture C
    dbms_output.put_line('Fermeture sin :'||tab_sntrt (44)||'- donnée n°'||tab_sntrt (45) );
    IF tab_sntrt(43) <>'RE' THEN
      tab_sntrt (46) := null; --iddonne [112] Date reprise C dépendante du motif ouverture ZAT 18
    END IF;
    tab_sntrt (47) := null;
    loc_debut :=null;
    loc_saisie:=null;
    dbms_output.put_line('Reprise- donnée n°'||tab_sntrt (46) );
    P_get_histo_sinistre_prev(p_numsin,1,3,p_date,loc_motif,tab_sntrt (47),loc_saisie);-- -- iddonne [113] Dernière rechute motif 19
    dbms_output.put_line('Rechute  donnée n°'||tab_sntrt (47) );
    tab_sntrt (48) := null; --R_get_sntrt.  iddonne [114] Date de fin arret C
    tab_sntrt (49) := null; --R_get_sntrt.  iddonne [115] Date conso rente C


    tab_sntrt (50) := to_char(R_get_sntrt.limit_versement,'dd/mm/yyyy'); -- --iddonne [116] Date lim vers. O déduit 1095 + age  max garantie
    tab_sntrt (51) := R_get_sntrt.duree_fran; -- iddonne [117] Durée franchise O
    tab_sntrt (52) := '0'; --R_get_sntrt.  iddonne [118] Code devise O
    loc_BRUT := f_get_salaire(p_numsin,'BRUT',sysdate);

    tab_sntrt (53) := NVL(loc_BRUT,loc_BRUT_calc); --iddonne [119]
    loc_NET :=f_get_salaire(p_numsin,'NET',sysdate);

    tab_sntrt (54) := loc_NET;  --  iddonne [120] Sal Net annuel ref. C

    IF loc_BRUT_calc IS NOT NULL THEN
      tab_sntrt (55) := 'O'; --R_get_sntrt.  iddonne [121] Top sal calculé auto O
    ELSE tab_sntrt (55) := 'N'; --pour visual PRDG ??? devrait être vide
    END IF;



    --expertise
    tab_sntrt (77):=F_get_piece (p_numsin, 54, p_date) ;-- iddonne [143] Date expertise C
    IF tab_sntrt (77) IS NOT NULL THEN   tab_sntrt (76):='O'; --iddonne [142] Top expert O
    ELSE tab_sntrt (76):='N';
    END IF;

    tab_sntrt (85) := '0'; --R_get_sntrt.  iddonne [151] TD sal BRUT O
    tab_sntrt (86) := '0'; --R_get_sntrt.  iddonne [152] TE sal BRUT O

    --Gestion des salaires
   /*
    tab_sntrt (87) := NVL(loc_BRUT,loc_BRUT_calc); --R_get_sntrt.  iddonne [153] Salaire BRUT O
    tab_sntrt (88) := loc_NET; --R_get_sntrt.  iddonne [154] Salaire net C
    IF NVL(tab_sntrt (88),0) <> 0  THEN
     tab_sntrt (89) := 'O';
    ELSE
      tab_sntrt (89) := 'N'; --R_get_sntrt.  iddonne [155] Top sal annuel O
    END IF;
    */
    tab_sntrt(90) := to_number(F_VAL_VAR_ALL(p_numsin,F_FIND_VAR('SALREFAM'),sysdate),'999999.99') ;--  iddonne [156] Decomp TA O
    tab_sntrt (104) :=to_number(F_VAL_VAR_ALL(p_numsin,F_FIND_VAR('SALREFBM'),sysdate),'999999.99') ;
    tab_sntrt (105) := to_number(F_VAL_VAR_ALL(p_numsin,F_FIND_VAR('SALREFCM'),sysdate),'999999.99');

    --M0005607 : si TB = 0 et TC non trouvé alors forcer TC = 0
    if tab_sntrt (104) = 0 and tab_sntrt (105) is null then
      tab_sntrt (105) := 0 ;
    end if ;


    tab_sntrt (106) := '0';
    tab_sntrt (107) := '0';

    tab_sntrt (91) := null; --R_get_sntrt.  iddonne [157] Code devise F

    IF R_get_sntrt.DPAC IS NOT NULL THEN
      tab_sntrt (92) := to_char(R_get_sntrt.DPAC,'dd/mm/yyyy'); --R_get_sntrt.  iddonne [158] Date pec sinistre C
    ELSE  tab_sntrt (92) := NULL;
    END IF;

    tab_sntrt (101 ) := R_get_sntrt.nom; --ne pas déplacer pour avoir la gestion d'erreur
    tab_sntrt (102 ) := R_get_sntrt.prenom;
    tab_sntrt (103 ) := R_get_sntrt.nomjf;


    CLOSE C_get_sntrt;

    RETURN ( tab_sntrt );
  EXCEPTION
    WHEN OTHERS THEN
    dbms_output.put_line('ERR sin :'||p_numsin||'- donnée n°'||tab_sntrt.count+1 ||'-'||  SQLERRM);
    pk_trace.p_ins_journal_adm (i_nom_traitement      => 'CLI_PRDG',
                               i_session             => 99,
                               i_niv_msg             => 1,
                               i_msg_adm             =>'ERR sin :'||p_numsin||'- donnée n°'||tab_sntrt.count+1 ||'-'||  SQLERRM,
                               i_idligne             => 0);

    CLOSE C_get_sntrt;
    RETURN tab_sntrt;
  END F_get_sinistre_prev;

  FUNCTION f_get_salaire (p_numsin sntr_prev.nosin%TYPE, p_sal IN varchar2, p_date IN DATE) RETURN NUMBER IS

  BEGIN
  IF p_sal ='BRUT' THEN
  RETURN to_number(NVL(
    F_VAL_VAR_ALL(p_numsin,F_FIND_VAR('SALREFM'),sysdate),
    F_VAL_VAR_ALL(p_numsin,F_FIND_VAR('SALANNUEL'),sysdate))
    ,'999999.99') ;
  ELSIF p_sal ='NET' THEN
     RETURN to_number(F_VAL_VAR_ALL(p_numsin,F_FIND_VAR('SALNET12M'),sysdate) ,'999999.99');
  ELSE RETURN NULL;
  END IF;
  END f_get_salaire;

 /*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_get_histo_sinistre_prev                                             */
/* Type         :  Privé                                                     */
/* Description  :  Fonction qui retourne un tableau contenant toutes les     */
/*                 données spécifiques à l'individu passé en paramètre       */
/* Entree       :  p_numindiv, numéro d'individu                             */
/* Sortie       :                                                            */
/* Retour       :  T_CHAR_TAB, tableau des données des contacts              */
/*---------------------------------------------------------------------------*/

  PROCEDURE P_get_histo_sinistre_prev (p_numsin IN sin_prev.nosin%TYPE, p_etat IN histo_sntr_prev.etat%TYPE,p_type IN NUMBER,p_date IN DATE,
                                        io_motif IN OUT varchar2, io_debut IN OUT VARCHAR2,io_saisie IN OUT VARCHAR2) IS

  CURSOR C_histo_sntr  IS
    SELECT motif,debut,saisie
    FROM histo_sntr_prev
    WHERE nosin = p_numsin
    AND etat = p_etat
    AND trunc(saisie)<=p_date -- MUR M0005793 ajout trunc
    ORDER BY debut,saisie;

  CURSOR C_histo_sntr_rev  IS
    SELECT motif,debut,saisie
    FROM histo_sntr_prev h
    WHERE nosin = p_numsin
    AND etat = p_etat
    AND trunc(saisie)<=p_date -- MUR M0005793 ajout trunc
    AND NOT EXISTS (
      SELECT nosin FROM histo_sntr_prev hp
      WHERE hp.nosin=h.nosin
      AND hp.etat= 1
      AND hp.motif=19
      AND hp.debut >=h.debut)
    ORDER BY debut desc,saisie desc;

   CURSOR C_histo_sntr_rech (p_motif IN NUMBER) IS
    SELECT motif,debut,saisie
    FROM histo_sntr_prev h
    WHERE nosin = p_numsin
    AND etat = p_etat
    AND motif = p_motif
    AND trunc(saisie)<=p_date -- MUR M0005793 ajout trunc
    ORDER BY debut desc,saisie desc;
  BEGIN

  IF p_type = 1 THEN --ouverture
    FOR Rec_histo_sntr IN C_histo_sntr LOOP
      io_motif := Rec_histo_sntr.motif;
      io_debut := to_char(Rec_histo_sntr.debut,'dd/mm/yyyy');
      io_saisie := to_char(Rec_histo_sntr.saisie,'dd/mm/yyyy');
      EXIT;
    END LOOP;
  ELSIF p_type =2 THEN --fermeture
   FOR Rec_histo_sntr IN C_histo_sntr_rev LOOP
      io_motif := Rec_histo_sntr.motif;
      io_debut := to_char(Rec_histo_sntr.debut,'dd/mm/yyyy');
      io_saisie := to_char(Rec_histo_sntr.saisie,'dd/mm/yyyy');
      EXIT;
    END LOOP;
  ELSIF p_type =3 THEN --rechute
   FOR Rec_histo_sntr IN C_histo_sntr_rech(19) LOOP
      io_motif := null;
      io_debut := to_char(Rec_histo_sntr.debut,'dd/mm/yyyy');
      io_saisie := null;
      EXIT;
    END LOOP;

  END IF;

  END P_get_histo_sinistre_prev;

   /*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_get_histo_sinistre_prev                                             */
/* Type         :  Privé                                                     */
/* Description  :  Fonction qui retourne un tableau contenant toutes les     */
/*                 données spécifiques à l'individu passé en paramètre       */
/* Entree       :  p_numindiv, numéro d'individu                             */
/* Sortie       :                                                            */
/* Retour       :  T_CHAR_TAB, tableau des données des contacts              */
/*---------------------------------------------------------------------------*/

  FUNCTION F_get_piece (p_numsin IN sin_prev.nosin%TYPE, p_nopiece IN pieces.nopiece%TYPE, p_date IN DATE) RETURN varchar2 IS

    loc_recept DATE;
  BEGIN
    SELECT max(daterecep) INTO loc_recept
    FROM PIECES
    WHERE nopiece = p_nopiece
    AND CONTEXTE = 15
    AND entite = p_numsin
    AND NVL(daterecep,p_date+1) <=p_date;

    RETURN to_char(loc_recept,'dd/mm/yyyy');
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

  END F_get_piece;

/*===========================================================================*/
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_get_contact                                             */
/* Type         :  Privé                                                     */
/* Description  :  Fonction qui retourne un tableau contenant toutes les     */
/*                 données spécifiques à l'individu passé en paramètre       */
/* Entree       :  p_numindiv, numéro d'individu                             */
/* Sortie       :                                                            */
/* Retour       :  T_CHAR_TAB, tableau des données des contacts              */
/*---------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------
  Tableau retourné :
  ( 1) : Téléphone
  ( 2) : Mobile
  ( 3) : télécopie
  ( 4) : mail
  ( 5) : site web
-----------------------------------------------------------------------------*/
  FUNCTION F_get_contact (p_numindiv IN individu.numindiv%TYPE)
    RETURN T_CHAR_TAB
  IS

    tab_contact T_CHAR_TAB;

    CURSOR C_get_contact IS
      SELECT
        c.coordonnee, c.type, c.nature
      FROM contact c
      WHERE c.numindiv = p_numindiv
      AND FLAG='O'
      AND TYPE=1
      ORDER BY nature
    ;

    R_get_contact C_get_contact%rowtype;

  BEGIN
    --initialisation
    FOR i in 1..5 LOOP
      tab_contact(i):='';
    END LOOP;
    --ajout des contacts
    FOR R_get_contact  IN C_get_contact LOOP
       tab_contact( R_get_contact.nature) := R_get_contact.coordonnee;
    END LOOP;

    RETURN ( tab_contact );
  END F_get_contact;
/*=================================================================================================*/
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_get_contrat                                               */
/* Type         :  Privé                                                     */
/* Description  :  Fonction qui retourne un tableau contenant toutes les     */
/*                 données spécifiques au contrat passé en paramètre         */
/* Entree       :  p_numgar, numéro de contrat                               */
/* Sortie       :                                                            */
/* Retour       :  T_CHAR_TAB, tableau des données du contrat                */
/*---------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------
  Tableau retourné :
  ( 1) : Référence du souscripteur du contrat
-----------------------------------------------------------------------------*/
  FUNCTION F_get_contrat (p_numgar IN NUMBER)
    RETURN T_CHAR_TAB
  IS

    tab_contrat T_CHAR_TAB;

    CURSOR C_get_contrat IS
      SELECT refcie
      FROM contrat c
      WHERE c.numgar = p_numgar;

    R_get_contrat C_get_contrat%rowtype;

  BEGIN

    OPEN C_get_contrat;

    FETCH C_get_contrat INTO R_get_contrat;

    tab_contrat(1) := NVL(f_get_transco('PRDG','CNTRT',p_numgar,1),R_get_contrat.refcie);

    CLOSE C_get_contrat;

    RETURN ( tab_contrat );
  END F_get_contrat;

  FUNCTION F_get_totaux (p_ligne IN PK_PRDG_DYNAMIC_CURSOR.T_CLES, p_pr IN VARCHAR2, p_nomflux IN VARCHAR2, p_datedeb IN DATE, p_datefin IN DATE)
  RETURN VARCHAR2 IS
    stmt varchar2(500);
    format varchar2(10) :='dd/mm/yyyy';
    loc_montant NUMBER;
  BEGIN
  stmt := 'SELECT sum(MONTANT) total'
          || ' FROM v_prdg_' || p_nomflux
          || ' WHERE cle1 = ' || p_ligne.cle(1)
          || ' AND cle2 = ' || p_ligne.cle(2)
          || ' AND cle3 = ' || p_ligne.cle(3)
          || ' AND pr = ' || p_pr
          || ' AND datope BETWEEN to_date(''' || to_char(p_datedeb,format) ||''',''' || format ||''') AND to_date(''' || to_char(p_datefin, format) ||''',''' || format ||''')'
          ;
   EXECUTE Immediate Stmt INTO loc_montant;
   RETURN to_char(loc_montant);
  END F_get_totaux;
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_get_garantie                                            */
/* Type         :  Privé                                                     */
/* Description  :  Fonction qui retourne un tableau contenant toutes les     */
/*                 données spécifiques à la garantie prev passés en paramètre*/
/* Entree       :  p_numfor, numéro de garantie                              */
/* Sortie       :                                                            */
/* Retour       :  T_CHAR_TAB, tableau des données                           */
/*---------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------
  Tableau retourné :
  ( 1) : Référence du souscripteur du contrat
-----------------------------------------------------------------------------*/
  FUNCTION F_get_garantie (p_numsin IN sin_prev.nosin%TYPE)
    RETURN T_CHAR_TAB
  IS

    tab_gar T_CHAR_TAB;

    CURSOR C_get_gar IS
      SELECT type_fran,type_limitation, prc_limitation,age_limite
      FROM gar_prev p, repartition r
      WHERE p.numfor = r.numfor
      AND r.valide ='O'
      AND r.nosin=p_numsin;

    R_get_gar C_get_gar%rowtype;

  BEGIN

    OPEN C_get_gar;

    FETCH C_get_gar INTO R_get_gar;

    tab_gar(1) := NVL(f_get_transco('PRDG','TYPE_FRAN',R_get_gar.type_fran,1),'PF');
    tab_gar(2) := R_get_gar.type_limitation; --SB ou SN
    tab_gar(3) := R_get_gar.prc_limitation;--<=100
    tab_gar(4) := R_get_gar.age_limite;--<=100


    CLOSE C_get_gar;

    RETURN ( tab_gar );
  END F_get_garantie;


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_get_arret_detail                                        */
/* Type         :  Privé                                                     */
/* Description  :  Fonction qui retourne un tableau contenant toutes les     */
/*                 données spécifiques à la garantie prev passés en paramètre*/
/* Entree       :  p_numfor, numéro de garantie                              */
/* Sortie       :                                                            */
/* Retour       :  T_CHAR_TAB, tableau des données                           */
/*---------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------
  Tableau retourné :
-----------------------------------------------------------------------------*/
  FUNCTION F_get_arret_detail (p_numsin IN sin_prev.nosin%TYPE,p_date IN DATE)
    RETURN T_CHAR_TAB  IS

    tab_arret T_CHAR_TAB;
    loc_nbpmss NUMBER;
    loc_TA NUMBER(11,2);
    loc_TB NUMBER(11,2);
    loc_TC NUMBER(11,2);
    loc_TD NUMBER(11,2);

    CURSOR C_calcul IS
    SELECT ar.base_regime, h.mtjour*365 base_an, h.mtreval_d/h.duree *365 reval_an, decode(ar.type,4,50,100) taux_arret, ar.fin ,
    (ar.base_regime *365 + h.mtjour*365)/12 rbt_mois
    FROM v_histo_jours h, arret ar
    WHERE ar.nosin = p_numsin
    AND ar.idarret = h.idcalcul
    AND ar.creation  <=p_date
   /* UNION
    SELECT ar.base_regime, h.mtjour*365 base_an, h.mtreval_d/h.duree *365 reval_an
    FROM v_histo_jours h, arret ar, histo_annul ha
    WHERE h.idcalcul = p_calcul
    AND ar.nosin = p_numsin
    AND ha.Idcalcul=h.idcalcul
    AND ha.idannul = ar.idarret*/
    ORDER BY Ar.debut desc
    ;--attention on a pas les arrets annulés

  BEGIN

    tab_arret(1):=0;
    tab_arret(2):=0;
    tab_arret(3):=0;
    tab_arret(4):=0;
    tab_arret(5):=0;
    tab_arret(6):=0;
    tab_arret(7):=0;
    tab_arret(8):=0;
    tab_arret(9):=null;
    tab_arret(10):=0;
    tab_arret(11):=0;
    tab_arret(12):=0;
    tab_arret(13):=0;
    tab_arret(14):=0;
    FOR R_calcul IN C_calcul LOOP
      tab_arret(1):=R_calcul.base_regime;-- 123
      tab_arret(2):=R_calcul.base_an;
      tab_arret(3):=R_calcul.reval_an;
      tab_arret(8):=R_calcul.taux_arret;
      tab_arret(9):=to_char(R_calcul.FIN,'dd/mm/yyyy');

      --décomposition par tranche
      loc_nbpmss:= R_calcul.rbt_mois /ind(1,R_calcul.FIN);
      IF loc_nbpmss < 1 THEN
          loc_TA:= R_calcul.rbt_mois;
      ELSE loc_TA:= ind(1,R_calcul.FIN);
      END IF;

      IF loc_nbpmss >1 AND loc_nbpmss <=4 THEN
        loc_TB:= R_calcul.rbt_mois -loc_TA;
      END IF;

      IF loc_nbpmss> 4 AND loc_nbpmss <=8 THEN
        loc_TB:= ind(1,R_calcul.FIN)*3;
        loc_TC:= R_calcul.rbt_mois -(loc_TA+ loc_TB);
      END IF;

      IF loc_nbpmss> 8 THEN
        loc_TC:= ind(1,R_calcul.FIN)*4;
        loc_TD :=R_calcul.rbt_mois -(loc_TA+ loc_TB+ loc_TC);
      END IF;
      dbms_output.put_line('>>>>TRANCHE '||loc_TA||'-'||loc_TB||'-'||loc_TC);
      tab_arret(10):= TRUNC(loc_TA/ind(1,R_calcul.FIN)*100);--145
      tab_arret(11):= TRUNC(loc_TB/(3*ind(1,R_calcul.FIN))*100);
      tab_arret(12):= TRUNC(loc_TC/(4*ind(1,R_calcul.FIN))*100);
      tab_arret(13):= 0;--pas possible...
      tab_arret(14):= 0;--pas possible...
      dbms_output.put_line('>>>>TAUX '||tab_arret(10)||'-'||tab_arret(11)||'-'||tab_arret(12));
    EXIT;
    END LOOP;


--todo abo périmètre à affiner ZAT 44
    SELECT NVL(ROUND(SUM(mt_base),2),0),NVL(ROUND(SUM(mt_ss),2),0),NVL(ROUND( SUM(mt_reval),2),0),NVL(ROUND(SUM(mt_ar),2),0)
    INTO tab_arret(4),tab_arret(5),tab_arret(6),tab_arret(7) from (
      SELECT h.idcalcul,h.debut,h.fin,SUM(f_total_histo_d (j.idhisto, -1)) mt_base, SUM(base_regime *(j.fin-j.debut+1)) mt_ss ,
        SUM (f_total_histo (j.idhisto, 0))mt_reval,SUM(base_autre *(j.fin-j.debut+1)) mt_ar
      FROM repartition r , histo_calcul h, affectation af, decaismt d, histo_jours j, arret ar
      WHERE r.nosin= p_numsin
      AND r.idrepartition = h.idrepartition
      AND h.idcalcul        = j.idcalcul
      AND h.numdec= af.numaffec
      AND af.codope = 2
      AND d.numdecaismt = af.numdecaismt
      AND ar.idarret = h.idcalcul
      and TRUNC(d.datpay) <=p_date
      group by h.idcalcul,h.debut,h.fin
      union
      SELECT h.idcalcul,h.debut,h.fin,SUM(f_total_histo_d (j.idhisto, -1)) mt_base, -SUM(base_regime *(j.fin-j.debut+1)) mt_ss,
        SUM (f_total_histo (j.idhisto, 0)) mt_reval,-SUM(base_autre *(j.fin-j.debut+1)) mt_ar
      FROM repartition r , histo_calcul h, affectation af, decaismt d, histo_jours j, arret ar, histo_annul ha
      WHERE r.nosin= p_numsin
      AND r.idrepartition = h.idrepartition
      AND h.idcalcul        = j.idcalcul
      AND h.numdec= af.numaffec
      AND af.codope = 2
      AND d.numdecaismt = af.numdecaismt
      AND  ar.traite='A'
      AND ha.Idcalcul=h.idcalcul
      AND ha.idannul = ar.idarret
      and TRUNC(d.datpay) <=p_date
      group by h.idcalcul,h.debut,h.fin);

  RETURN tab_arret;

  EXCEPTION
    WHEN OTHERS THEN dbms_output.put_line('ERR F_get_arret_detail-'||p_numsin ||SQLERRM);
     RETURN tab_arret;
  END F_get_arret_detail;
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_get_transco                                             */
/* Type         :  Public                                                    */
/* Description  :  Fonction qui gère la transcodification des donnees prdg   */
/*                 données spécifiques au contrat passé en paramètre         */
/* Entree       :  p_iddonnee, numéro de la donnée (cf. table PRDGDONNEE     */
/*                 p_cle, valeur de la donnée dans Arthus                    */
/* Sortie       :                                                            */
/* Retour       :  transco, valeur de la donnée transcodée pour PRDG         */
/*---------------------------------------------------------------------------*/
  FUNCTION F_get_transco_prdg (p_iddonnee IN prdgdonnee.iddonnee%TYPE, p_cle IN VARCHAR2)
    RETURN VARCHAR2
  IS

    transco VARCHAR2(20);
  BEGIN
    CASE p_iddonnee
      WHEN 55 THEN -- Type de risque
        transco := f_get_transco('PRDG','RISQ',p_cle,1);
      WHEN 60 THEN -- Code devise
        transco := f_get_transco('PRDG','DEVISE',p_cle,1);
      WHEN 63 THEN -- Code devise
        transco := f_get_transco('PRDG','DEVISE',p_cle,1);
      ELSE
        transco := null;
    END CASE;

    RETURN nvl(transco,-1);
  END F_get_transco_prdg;

END PK_PRDG_FONCT;
/
