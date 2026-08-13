CREATE OR REPLACE PACKAGE ARTHUS.PK_virement AS
-- Chaine de reconnaissance SCCS
-- %W% Bordereau de Virement %E%

-- -- CONSTANTES PUBLIQUE -----------------------------------------------------

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
--@pub
---
FUNCTION F_fill ( I_chaine     IN Varchar2,
                  I_longueur   IN Number,
                  I_character  IN Varchar2 default ' ',
                  I_alignement IN number default 1 /* Si 1 , complete à droite */
                )
RETURN Varchar2;
---
PROCEDURE p_vire_cpte (
                I_numcpte_deb IN  compte.numcpte%type           default NULL,
                I_numcpte_fin IN  compte.numcpte%type           default NULL,
                I_codope_deb  IN  decaismt.codope%type          default NULL,
                I_codope_fin  IN  decaismt.codope%type          default NULL,
                I_niv_rupt    IN  remise_vire.natrem%type       Default 1,
                I_session     IN  NUMBER                        Default 1,
                I_niv_msg     IN  Number                        Default 1,
                O_found       OUT Number,
                O_erreur      OUT Varchar2
                       );
--
PROCEDURE p_fich_vire (
                I_numbdx_deb  IN  remise_vire.numremise%type    default NULL,
                I_numbdx_fin  IN  remise_vire.numremise%type    default NULL,
                I_niv_gen     IN  number                        Default 1,
                I_session     IN  NUMBER                        Default 1,
                I_niv_msg     IN  Number                        Default 1,
                O_found       OUT Number,
                O_erreur      OUT Varchar2
                       );
--
procedure p_crea_bban   (
                I_codbque       IN      rib.codbque%type        Default Null,
                I_guichet       IN      rib.guichet%type        Default Null,
                I_compte        IN      rib.compte%type         Default Null,
                I_clerib        IN      rib.clerib%type         Default Null,
                I_codpays       IN      rib.codpays%type        Default 1,
                O_clef_iban     OUT     rib.clef_iban%type,
                O_bban          OUT     rib.bban%type,
                O_retour        OUT     Number
                        );
--
procedure p_sel_rib   (
                I_codpays       IN      rib.codpays%type        Default 1,
                I_clef_iban     IN      rib.clef_iban%type      Default Null,
                I_bban          IN      rib.bban%type           Default Null,
                O_codbque       OUT     rib.codbque%type,
                O_guichet       OUT     rib.guichet%type,
                O_compte        OUT     rib.compte%type,
                O_clerib        OUT     rib.clerib%type,
                O_retour        OUT     Number
                        );

-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_virement AS
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
--
-- Paramètres de P_vire_cpte ; P_vire_cpte_ag
--
G_numcpte_deb   Compte.numcpte%type;
G_numcpte_fin   Compte.numcpte%type;
G_codope_deb    Decaismt.codope%type;
G_codope_fin    Decaismt.codope%type;
G_niv_rupt      Remise_vire.natrem%type:=1;
--
-- Paramètres de P_fich_vire
--
G_numbdx_deb    Remise_vire.numremise%type;
G_numbdx_fin    Remise_vire.numremise%type;
G_niv_gen       number(3):=1;
--
-- Variables de travail de P_vire_cpte
--
G_pie_decais_trouve     varchar2(1):='N';
G_min_numgar_pie                adhe_cntrt.numgar%type:=0;
G_numgar_pie            adhe_cntrt.numgar%type:=0;
G_nb_numgar_pie         number:=0;
--
G_rib                   rib%rowtype;
G_idrib                 rib.idrib%type;
G_rib_existe            varchar2(1):='N';
G_idrib_trouve          varchar2(1):='N';
G_dest_trouve           varchar2(1):='N';
--
Decais_pour_insertion   varchar2(1):='N';
vire_detail_ins         varchar2(1):='N';
premier_vire_detail     varchar2(1):='O';
dernier_vire_detail     varchar2(1):='N';
G_numremise             remise_vire.numremise%type;
G_numvirement           remise_vire_detail.numvirement%type;
--
/*
G_id_op_glb             op_global.id_op_glb%type;
G_id_op                 op_detail.id_op%type;
--
G_date_op               op_global.date_op%type;
G_nombre_op             op_global.nombre_op%type;
G_montant_op            op_global.montant_op%type; */
--
G_decais_nomdest        Varchar2(60);
--
G_codbque               remise_vire_detail.codbque%type;
G_codbque_old           remise_vire_detail.codbque%type;
G_guichet               remise_vire_detail.guichet%type;
G_guichet_old           remise_vire_detail.guichet%type;
G_compte                remise_vire_detail.compte%type;
G_compte_old            remise_vire_detail.compte%type;
G_clerib                remise_vire_detail.clerib%type;
G_clerib_old            remise_vire_detail.clerib%type;
G_intitule              remise_vire_detail.intitule%type;
G_intitule_old          remise_vire_detail.intitule%type;
--
G_numbque               pers_banque.numindiv%type:=Null;
G_numbque_old           pers_banque.numindiv%type:=Null;
--
--
-- Variables de travail de P_fich_vire
--
Premier_virement        Varchar2(1):='O';
Virement_pour_ecriture  Varchar2(1):='N';
Dernier_virement        Varchar2(1):='N';
--
G_refsoc                societe.refsoc%type;
G_numcpte               compte.numcpte%type;
G_codbque_soc           compte.codbque%type;
G_guichet_soc           compte.guichet%type;
G_compte_soc            compte.compte%type;
G_clerib_soc            compte.clerib%type;
G_emetteur              compte.emetteur%type;
G_ident                 compte.type_ident%type;
G_identifiant           compte.identifiant%type;
G_rais_soc              compte.rais_soc%type;
G_numdest_bdx           remise_vire.numdest%type;
G_natrem                remise_vire.natrem%type;
--
Ed_parenthese           Varchar2(1);
Ed_ident                Varchar2(1);
Ed_identifiant          compte.identifiant%type;
--
--- si natrem=2, destinataire = organisme bancaire
--
G_codbque_dest          pers_banque.codbque%type;
G_guichet_dest          pers_banque.guichet%type;
G_direction_dest        pers_banque.direction%type;
G_groupe_dest           pers_banque.groupe%type;
G_type_dest             pers_banque.type%type;
G_nat_place_dest        pers_banque.nat_place%type;
G_bancable_dest         pers_banque.bancable%type;
G_vir_autorise_dest     pers_banque.vir_autorise%type;
--
Bdx_pour_banque         varchar2(1):='0';
--
---
--
G_montant_virement      remise_vire_detail.montant%type;
G_min_numdecaismt       remise_vire_detail.numdecaismt%type;
--
G_montant_total         remise_vire.montant%type:=0;
--
G_datejour_ddmmy        Varchar2(6);
--
G_numbene               decaismt.numbene%type;
G_typbene               decaismt.typbene%type;
G_codope                decaismt.codope%type;
G_beneficiaire          Varchar2(18);
--
Ed_beneficiaire         Varchar2(18);
--
G_devise_ref            number(1);
G_devise_franc          number(1);
G_devise_euro           number(1);
G_monnaie               Varchar2(1);
--
G_numedit               lib_edition.numedit%type;
--
-- Variables pour génération du fichier
--
Nom_fich_vire           varchar2(20);
--


--
----
--
--@global
G_erreur                journal_adm.msg_adm%Type;
-- Flag de commit ou rollback a retourner a Forms
G_commit        Boolean := FALSE;
G_rollback      Boolean := FALSE;
G_auto_valide   Boolean := FALSE;
-- Variables de P_INS_journal
G_nom_traitement  Constant journal_adm.nom_traitement%Type default 'pk_virement';
G_msg_adm       journal_adm.msg_adm%Type;
G_session       journal_adm.id_session%Type default 1;
G_flag_test     number;
G_niv_msg       journal_adm.niv_msg%TYPE := 1;
G_max_msg       journal_adm.niv_msg%TYPE := 1;
G_idligne       journal_adm.idligne%TYPE := 0;
G_proc          Varchar2(80);
-- G_niv_msg prend les Valeurs :
--      0 --> Message d'erreurs (Erreur ORACLE)
--      1 --> Message informatif(tout se passe bien)
--      2 et + Niveau de detail
---------------------- Fin des variables globales privees --

-- -- DEFINITION DES CURSEURS PRIVES ------------------------------------------
--@curs
----- Curseur - numero compte treso (pour constitution Bordereaux)
Cursor c_numcpte Is
        Select  numcpte, libcompte
        FROM    vs_compte
        WHERE   vs_compte.numcpte
                between nvl(G_numcpte_deb,
                            vs_compte.numcpte)
                and     nvl(G_numcpte_fin,
                            nvl(G_numcpte_deb,vs_compte.numcpte)
                           );
--
---- Curseur - decaissements à prendre en compte (pour constitution Bordereaux)
--
Cursor c_decais(I_numcpte number)
IS
        SELECT  numdecaismt,
                montant,
                numbene,
                numdest,
                codope,
                modpmt
        FROM    decaismt
        WHERE   flagpay = -1
        and     numutil   + 0 >= 0
        and     montant   + 0 > 0
        and     modpmt    = 2
        AND     numcpte   + 0 = I_numcpte
        and     codope
                        between nvl(G_codope_deb,codope)
                        and     nvl(G_codope_fin,nvl(G_codope_deb,codope))
        AND NOT EXISTS (
                        select  1
                        from    remise_vire_detail
                        where   remise_vire_detail.numdecaismt = decaismt.numdecaismt)
                        order by decaismt.numcpte;
--
---- Curseur - pièces affectées à un décaissement (pour constitution Bordereaux)
--
Cursor c_pie_decais(I_numdecaismt number) IS
        SELECT  codope, numaffec
        FROM    affectation
        Where   affectation.numdecaismt=I_numdecaismt;
--
---- Curseur - virements insérés à "regrouper par compte bancaire" et par niveau de rupture de bordereau
-- (pour constitution Bordereaux)
--

Cursor c_vire_detail IS
        select  *
        from    remise_vire_detail
        where   numremise=0
        and     numvirement=0
        FOR UPDATE OF numremise, numvirement
        order by codbque,
                 guichet,
                 compte,
                 clerib,
                 intitule;
--
---- Curseur - "virements" d'un bordereau pour création de l'enregistrement détail du fichier à générer
-- (pour génération fichier virement bdx)
--
Cursor c_numbdx IS
        SELECT  societe.refsoc,
                compte.numcpte,
                compte.codbque                          codbque_soc,
                compte.guichet                          guichet_soc,
                compte.compte                           compte_soc,
                compte.clerib                           clerib_soc,
--
--              -- lpad(to_char(compte.emetteur), 6, '0')       emetteur,
                compte.emetteur,
--
                nvl(compte.type_ident,0)                ident,
                compte.identifiant,
                compte.rais_soc,
                remise_vire.numdest,
                remise_vire.natrem
        FROM    remise_vire,compte,societe
        WHERE   remise_vire.numremise = G_numbdx_deb
        AND     remise_vire.numcpte = compte.numcpte
        AND     compte.numsoc = societe.numsoc;

--
---- Curseur - "virements" d'un bordereau pour création de l'enregistrement détail du fichier à générer
-- (pour génération fichier virement bdx)
--
Cursor c_virement (I_numremise number) IS
        select          numvirement,
                        codbque,
                        guichet,
                        compte,
                        clerib,
                        Substr(translate(rpad(intitule,24),'.','@'),1, 24)      intitule,
                        sum(montant*100)                                        montant,
                        min(numdecaismt)                                        min_numdecaismt,
                        numremise
        from    remise_vire_detail
        where   numremise=I_numremise
        group by        numvirement,
                        codbque,
                        guichet,
                        compte,
                        clerib,
                        intitule,
                        numremise
        order by        numvirement;
--
---- Curseur - "décaissements" de la table des virements pour un numéro de virement (issu du curseur c_virement !)
-- (pour génération fichier virement bdx)
--
Cursor c_dec_virement (I_numvirement number) IS
        select numdecaismt
        from remise_vire_detail
        where numvirement = I_numvirement
        order by numdecaismt asc;
--
--
----------------------- Fin des curseurs prives -------------
-- -- DEFINITION DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@priv
-- Insertion dans journal_adm
Procedure P_INS_journal;
----------------------- Fin des definitions des procedures privees ---

-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
---
FUNCTION F_fill ( I_chaine     IN Varchar2,
                  I_longueur   IN Number,
                  I_character  IN Varchar2 default ' ',
                  I_alignement IN number default 1
                )
Return Varchar2
IS
L_chaine                Varchar2(250)   := I_chaine;
BEGIN
Loop
        Exit when ( Length(L_chaine) >= I_longueur );
        If (I_alignement = 1) Then
          L_chaine := L_chaine || I_character;
        Else
          L_chaine := I_character || L_chaine;
        End if;
End Loop;
--
Return (L_chaine);
END F_fill;
---
--
--------- DEBUT PROCEDURE P_VIRE_CPTE
--
-- Construction des bordereaux de virement
--
procedure p_vire_cpte   (
                I_numcpte_deb IN  compte.numcpte%type           default NULL,
                I_numcpte_fin IN  compte.numcpte%type           default NULL,
                I_codope_deb  IN  decaismt.codope%type          default NULL,
                I_codope_fin  IN  decaismt.codope%type          default NULL,
                I_niv_rupt    IN  remise_vire.natrem%type       Default 1,
                I_session     IN  NUMBER                        Default 1,
                I_niv_msg     IN  Number                        Default 1,
                O_found       OUT Number,
                O_erreur      OUT Varchar2
                        )
IS
--
Rec_c_numcpte           c_numcpte%rowtype;
Rec_c_decais            c_decais%rowtype;
Rec_c_pie_decais        c_pie_decais%rowtype;
Rec_c_vire_detail       c_vire_detail%rowtype;
--
G_retour                number;
--
----
--

Begin

--
O_found         := 1;
G_erreur        := Null;
--
G_numcpte_deb   := I_numcpte_deb;
G_numcpte_fin   := I_numcpte_fin;
G_codope_deb    := I_codope_deb;
G_codope_fin    := I_codope_fin;
G_niv_rupt      := I_niv_rupt;
--
G_max_msg       := I_niv_msg;
G_session       := I_session;
--G_idligne     := F_max_idligne(I_session => G_session);
---
--
If Not c_numcpte%ISOPEN then
        G_niv_msg     := 1;
        G_msg_adm     := 'Debut du traitement le ' ||
                      to_char(Sysdate, 'dd/mm/yyyy hh24:mi');
        P_INS_journal;
--
        Open c_numcpte;
End if;
--
----
--
Fetch c_numcpte Into Rec_c_numcpte;
If ( c_numcpte%NotFound ) then
        G_niv_msg     := 1;
        G_msg_adm     := 'Fin Normale du traitement le ' ||
                      to_char(Sysdate, 'dd/mm/yyyy hh24:mi');
        P_INS_journal;
        Close c_numcpte;
        O_found := 0;
        Return;
Else
        O_found := 1;
/*
--Open c_numcpte(I_numcpte_deb,I_numcpte_fin);
--Loop
--
-- sélection du compte de trésorerie à traiter
--
--Fetch c_numcpte into Rec_c_numcpte;
--Exit when c_numcpte%notfound;
*/
        vire_detail_ins:='N';
        dernier_vire_detail:='N';
--
G_niv_msg     := 3;
G_msg_adm     := 'Jalon 1 '||'compte : '||to_char(Rec_c_numcpte.numcpte);
P_INS_journal;
--
        Open c_decais(Rec_c_numcpte.numcpte);
--
        Loop
--
           Decais_pour_insertion:='N';
--
           Fetch c_decais into Rec_c_decais;
           If c_decais%notfound Then
                Close c_decais;
                Exit;
           End if;
--
           G_pie_decais_trouve:='N';
           G_min_numgar_pie:=0;
           G_numgar_pie:=0;
           G_nb_numgar_pie:=0;
--
G_niv_msg     := 3;
G_msg_adm     := 'Jalon 2 - numdecais :'||to_char(Rec_c_decais.numdecaismt);
P_INS_journal;
--
           Open c_pie_decais(Rec_c_decais.numdecaismt);
                Loop
                  Fetch c_pie_decais into Rec_c_pie_decais;
                  If c_pie_decais%notfound then
                        Close c_pie_decais;
                        Exit;
                  Else
--
                        G_pie_decais_trouve:='O';
--
                        Begin
                                SELECT f_piece_contrat(Rec_c_pie_decais.codope,Rec_c_pie_decais.numaffec)
                                INTO G_numgar_pie
                                FROM dual;
                        Exception when no_data_found Then
                                G_numgar_pie:=0;
                        End;
--
-- G_numgar_pie:=nvl(f_piece_contrat(Rec_c_pie_decais.codope,Rec_c_pie_decais.numaffec),0);
--
                        If ((G_numgar_pie < G_min_numgar_pie)
                        and  G_numgar_pie <> 0) then
                                G_min_numgar_pie:=G_numgar_pie;
                                G_nb_numgar_pie:=G_nb_numgar_pie+1;
                        elsif G_numgar_pie > G_min_numgar_pie then
                                G_nb_numgar_pie:=G_nb_numgar_pie+1;
                        End if;
--
                  End if;
                End loop;
--
--- recherche rib
--
           If G_pie_decais_trouve='O' Then
                G_rib_existe:='N';
                G_idrib_trouve:='N';
--
                Begin
                        SELECT f_bene_rib(Rec_c_decais.numdest,Rec_c_decais.codope,G_min_numgar_pie,1)
                        INTO G_idrib
                        FROM dual;
--
                        G_idrib_trouve:='O';
--
                Exception when no_data_found Then
                        G_rib_existe:='N';
                        G_idrib_trouve:='N';
                End;
--
                If G_idrib_trouve= 'O' Then
                        Begin
                        SELECT  rib.codbque,
                                rib.guichet,
                                rib.compte,
                                rib.clerib,
                                rib.intitule,
                                rib.clef_iban,
                                rib.bban,
                                rib.bic,
                                rib.codpays
                        INTO    G_rib.codbque,
                                G_rib.guichet,
                                G_rib.compte,
                                G_rib.clerib,
                                G_rib.intitule,
                                G_rib.clef_iban,
                                G_rib.bban,
                                G_rib.bic,
                                G_rib.codpays
                        FROM    rib
                        WHERE   idrib=G_idrib
                        AND     ( rib.clerib is not null OR
                                  rib.clef_iban is not null
                                )
                                ;
--
                        G_rib_existe    := 'O';
                        G_rib.intitule  := f_desaccentue(G_rib.intitule);
                        G_rib.intitule  := upper(G_rib.intitule);
--
                        If G_rib.codbque is null
                        or G_rib.guichet is null        Then
                          If G_rib.clef_iban is null
                          or G_rib.bban is null Then
                            G_rib_existe:='N';
                            G_idrib_trouve:='N';
                          Else
                            G_rib.codpays := nvl(G_rib.codpays,1);
                            P_sel_rib ( G_rib.codpays,
                                        G_rib.clef_iban,
                                        G_rib.bban,
                                        G_rib.codbque,
                                        G_rib.guichet,
                                        G_rib.compte,
                                        G_rib.clerib,
                                        G_retour
                                    );
                          End if;
                        Else
                          If G_rib.clef_iban is null
                          or G_rib.bban is null Then
                            G_rib.codpays := nvl(G_rib.codpays,1);
                            P_crea_bban ( G_rib.codbque,
                                          G_rib.guichet,
                                          G_rib.compte,
                                          G_rib.clerib,
                                          G_rib.codpays,
                                          G_rib.clef_iban,
                                          G_rib.bban,
                                          G_retour
                                        );
                          End if;
                        End if;
--
                        Exception when no_data_found then
                                G_rib_existe:='N';
                                G_idrib_trouve:='N';
                        End;
                End if;
--
           End if;
--
--- contrôles
--
           If (G_pie_decais_trouve='N') then
--
                G_niv_msg     := 3;
                G_msg_adm     := 'Décaissement No : '||to_char(Rec_c_decais.numdecaismt)
                                ||' - aucune piece affectation';
                P_INS_journal;
--
           Elsif G_rib_existe='N' then
--
                Begin
                        Select 'O'
                        Into G_dest_trouve
                        from indvs
                        where indvs.numindiv = Rec_c_decais.numdest;
--
                        G_decais_nomdest        := pk_personne.f_nom(Rec_c_decais.numdest,32);
                        G_decais_nomdest        := f_desaccentue(G_decais_nomdest);
                        G_decais_nomdest        := upper(G_decais_nomdest);
--
                        G_niv_msg     := 3;
                        G_msg_adm     := 'Décaissement No : '||to_char(Rec_c_decais.numdecaismt)
                                        ||' - destinataire n° : '||to_char(Rec_c_decais.numdest)
                                        ||' - '||G_decais_nomdest||'- références bancaires non définies';
                        P_INS_journal;
--
                Exception when no_data_found Then
                        G_niv_msg     := 3;
                        G_msg_adm     := 'Décaissement No : '||to_char(Rec_c_decais.numdecaismt)
                                         ||' - aucun destinataire';
                        P_INS_journal;
                End;
--

           Elsif (G_nb_numgar_pie > 1 and G_min_numgar_pie <> 0) then
--
                G_niv_msg     := 3;
                G_msg_adm     := 'Décaissement No : '||to_char(Rec_c_decais.numdecaismt)
                                ||' - plusieurs contrats - '||' Références bancaires non définies';
                P_INS_journal;
--
           Else
--
                        Decais_pour_insertion:='O';
--
--- ICI Si bdx par agence, déterminer D_numbque,
---     Agence organisme bancaire => insertion décaissement
---     Exception message : banque destinatrice non organisme bancaire
--
                If G_niv_rupt=2 Then
                        Begin
                          Select numindiv
                          Into G_numbque
                          From pers_banque
                          Where codbque=G_rib.codbque
                          And   guichet=G_rib.guichet;
--
                        Decais_pour_insertion:='O';
--
                        Exception
                           When no_data_found then
                                Decais_pour_insertion:='N';
                                G_niv_msg     := 3;
                                G_msg_adm     := 'Décaissement No : '||to_char(Rec_c_decais.numdecaismt)
                                                ||' - G_idrib - '||to_char(G_idrib)
                                                ||' - Code banque - '||G_rib.codbque
                                                ||' - Guichet - '||G_rib.guichet
                                                ||' non référencé Organisme bancaire ';
                                P_INS_journal;
                        End;
                End if;
--
                If Decais_pour_insertion ='O' Then
--
--------------------------------------------
                        G_niv_msg     := 3;
                        G_msg_adm     := 'Décaissement à insérer n° '||to_char(Rec_c_decais.numdecaismt);
                        P_INS_journal;
--------------------------------------------
--
                  vire_detail_ins:='O';
--
                  INSERT INTO   remise_vire_detail(
                                numremise,
                                numcpte,
                                numvirement,
                                numdecaismt,
                                montant,
                                codbque,
                                guichet,
                                compte,
                                clerib,
                                intitule,
                                clef_iban,
                                bban,
                                bic,
                                codpays)
                        VALUES (0,
                                Rec_c_numcpte.numcpte,
                                0,
                                Rec_c_decais.numdecaismt,
                                Rec_c_decais.montant,
                                G_rib.codbque,
                                G_rib.guichet,
                                G_rib.compte,
                                G_rib.clerib,
                                G_rib.intitule,
                                G_rib.clef_iban,
                                G_rib.bban,
                                G_rib.bic,
                                G_rib.codpays);
                End if;
--
---- Fin du If des contrôles "G_pie_decais_trouve" !
--
           End if;
        End Loop;
--
---
--
        If vire_detail_ins='N' then
--
                G_niv_msg     := 2;
                G_msg_adm     := 'Compte n°: '||to_char(Rec_c_numcpte.numcpte)||' - '||Rec_c_numcpte.libcompte
                                ||' - '||'aucun virement à inserer';
                P_INS_journal;
--
        Else
--
                G_niv_msg     := 3;
                G_msg_adm     := 'Compte n°: '||to_char(Rec_c_numcpte.numcpte)||' - '||Rec_c_numcpte.libcompte
                                ||' - '||'Bordereaux à constituer';
                P_INS_journal;
--
---
--
          Open c_vire_detail;
--
          Premier_vire_detail:='O';
          Dernier_vire_detail:='N';
--
          G_codbque:=' ';
          G_guichet:=' ';
          G_compte:=' ';
          G_clerib:=' ';
          G_intitule:=' ';
          G_numbque:=Null;
--
--
          Loop
--
--<<<<<<<<<<<<<<<<
                G_niv_msg     := 3;
                G_msg_adm     := 'Avant Fetch - ';
                P_INS_journal;
--<<<<<<<<<<<<<<<<
--
                G_codbque_old:=G_codbque;
                G_guichet_old:=G_guichet;
                G_compte_old:=G_compte;
                G_clerib_old:=G_clerib;
                G_intitule_old:=G_intitule;
--
--- ICI si bdx par agence, G_numbque_old:=G_numbque
--
                G_numbque_old:=G_numbque;
--
--
                Fetch c_vire_detail into Rec_c_vire_detail;
--
                If c_vire_detail%notfound then
                  dernier_vire_detail:='O';
--------------------------------------------
                G_niv_msg     := 3;
                G_msg_adm     := 'Dernier vire detail ';
                P_INS_journal;
--------------------------------------------
                Else
                        G_codbque:=Rec_c_vire_detail.codbque;
                        G_guichet:=Rec_c_vire_detail.guichet;
                        G_compte:=Rec_c_vire_detail.compte;
                        G_clerib:=Rec_c_vire_detail.clerib;
                        G_intitule:=Rec_c_vire_detail.intitule;
--
                        G_intitule      := f_desaccentue(G_intitule);
                        G_intitule      := upper(G_intitule);
--
--- ICI si bdx par agence, select into G_numbque
--
                        If G_niv_rupt=2 Then
                          Select numindiv
                          Into G_numbque
                          From pers_banque
                          Where codbque=G_codbque
                          And   guichet=G_guichet;
--
                        End if;
--
-- ==> amorcer les valeurs
--
                        If Premier_vire_detail = 'O' Then
--
                                G_niv_msg     := 3;
                                G_msg_adm     := 'Premier vire detail ';
                                P_INS_journal;
--
                          Premier_vire_detail:='N';
--
                          G_codbque_old:=G_codbque;
                          G_guichet_old:=G_guichet;
                          G_compte_old:=G_compte;
                          G_clerib_old:=G_clerib;
                          G_intitule_old:=G_intitule;
--
--- ICI utile si bdx par agence, G_numbque_old:=G_numbque
--
                          G_numbque_old:=G_numbque;
--
                          SELECT        nvl(max(numremise),0) + 1
                          INTO  G_numremise
                          FROM  remise_vire;
--
/*                          SELECT        nvl(max(id_op_glb),0) + 1
                          INTO  G_id_op_glb
                          FROM  op_global; */
--
                          SELECT        numvirement.nextval
                          INTO  G_numvirement
                          FROM  dual;
                        End if;
--
/*                          SELECT        nvl(max(id_op),0) + 1
                          INTO  G_id_op
                          FROM  op_detail; */
--
                End if;

-- si bdx uniquement par compte de treso
--              If (dernier_vire_detail='O') and (premier_vire_detail <> 'O') Then
--
--- ICI si bdx par agence, G_numbque_old:=G_numbque
--
                If ( (Dernier_vire_detail='O')
                     Or ( (G_niv_rupt = 2) and (G_numbque <> G_numbque_old) ) )
                And (Premier_vire_detail <> 'O')  Then
--
--------------------------------------------
                G_niv_msg     := 3;
                G_msg_adm     := 'Bdx à insérer n° '||to_char(G_numremise);
                P_INS_journal;
--------------------------------------------
--
                        INSERT INTO remise_vire(
                                        numremise,
                                        numcpte,
                                        datrem,
                                        nombre,
                                        montant,
                                        valide,
                                        numdest,
                                        natrem)
                                SELECT  numremise,
                                        Rec_c_numcpte.numcpte,
                                        trunc(sysdate),
                                        count(distinct numvirement),
                                        sum(montant),
                                        'N',
                                        G_numbque_old,
                                        1
                                FROM    remise_vire_detail
                                WHERE   remise_vire_detail.numremise=G_numremise
                                GROUP BY numremise,
                                         numcpte;
--
/*                        SELECT
                                datrem,
                                nombre,
                                montant
                        INTO
                                G_date_op,
                                G_nombre_op,
                                G_montant_op
                        FROM    remise_vire
                        WHERE   remise_vire.numremise=G_numremise;
--
                        INSERT INTO op_global(
                                        id_op_glb,
                                        type_op,
                                        date_op,
                                        nombre_op,
                                        montant_op,
                                        numcpte,
                                        numdest_op,
                                        numremise,
                                        valide
                                        )
                                VALUES (
                                        G_id_op_glb,
                                        2,
                                        G_date_op,
                                        G_nombre_op,
                                        G_montant_op,
                                        Rec_c_numcpte.numcpte,
                                        G_numbque_old,
                                        G_numremise,
                                        'N'
                                        );
--
                        UPDATE op_detail
                        SET id_op_glb=G_id_op_glb
                        Where   type_op=2
                        And     id_op_glb is null;
*/
--
--
---
--
                        G_niv_msg     := 2;
                        If G_niv_rupt <> 2 Then
                                G_msg_adm    := 'Compte n°: '||to_char(Rec_c_numcpte.numcpte)||' - '
                                                ||Rec_c_numcpte.libcompte||' - '||'bordereau de virement n°'
                                                ||to_char(G_numremise);
                        Else
                                G_msg_adm    := 'Compte n°: '||to_char(Rec_c_numcpte.numcpte)||' - '
                                                ||Rec_c_numcpte.libcompte||' - Banque destinatrice n° '
                                                ||to_char(G_numbque_old)
                                                ||pk_personne.f_nom(G_numbque_old,20)
                                                ||'bordereau de virement n°'||to_char(G_numremise);
                        End if;
                        P_INS_journal;
--
                End if;
--
                If dernier_vire_detail = 'O' Then
                  Exit;
                End if;
--
--
--- SI comptes cibles différents, numéro de virement suivant
--
                If   (premier_vire_detail <> 'O')
                AND  (dernier_vire_detail <> 'O')
                AND  (  (G_codbque <> G_codbque_old)    OR
                        (G_guichet <> G_guichet_old)    OR
                        (G_compte <> G_compte_old)      OR
------------------------(G_intitule <> G_intitule_old)--OR----------
                        (G_clerib <> G_clerib_old)      )


                Then
--
                  SELECT        numvirement.nextval
                  INTO  G_numvirement
                  FROM  dual;
--
/*                  SELECT        nvl(max(id_op),0) + 1
                  INTO  G_id_op
                  FROM  op_detail; */
--
--------------------------------------------
                  G_niv_msg     := 3;
                  G_msg_adm     := 'Virement suivant n° '||to_char(G_numvirement);
                  P_INS_journal;
--------------------------------------------
--
                End if;
--
--- ICI, si bdx par compte treso et agence
--- Si Pas premier vire detail, Pas dernier virement detail, et G_numbque <> G_numbque_old ,
--- ==> max (numremise + 1)
--
                If ( G_niv_rupt = 2
                And (G_numbque <> G_numbque_old)
                And (dernier_vire_detail <> 'O')
                And (premier_vire_detail <> 'O') )  Then
--
                  SELECT        nvl(max(numremise),0) + 1
                  INTO  G_numremise
                  FROM  remise_vire;
--
/*                  SELECT        nvl(max(id_op_glb),0) + 1
                  INTO  G_id_op_glb
                  FROM  op_global; */
--
--------------------------------------------
                  G_niv_msg     := 2;
                  G_msg_adm     := 'Bdx agence suivant n° '||to_char(G_numremise);
                  P_INS_journal;
--------------------------------------------
--
                End if;
--
                If dernier_vire_detail <> 'O' Then
--<<<<<<<<<<<<<<<<
                  G_niv_msg     := 3;
                  G_msg_adm     := 'Maj decaismt n° - '||to_char(Rec_c_vire_detail.numdecaismt);
                  P_INS_journal;
--<<<<<<<<<<<<<<<<
                  UPDATE        remise_vire_detail a
                  SET   a.numremise     = G_numremise,
                        a.numvirement   = G_numvirement
                  WHERE CURRENT OF c_vire_detail;
--
/*                  Insert Into op_detail (
                                         id_op,
                                         type_op,
                                         numdecaismt,
                                         id_op_glb,
                                         numop,
                                         numcpte,
                                         montant
                                        )
                         Values
                                        (
                                         G_id_op,
                                         2,
                                         Rec_c_vire_detail.numdecaismt,
                                         Null,
                                         G_numvirement,
                                         Rec_c_numcpte.numcpte,
                                         Rec_c_vire_detail.montant
                                        ); */
--
                End if;
--
          End loop;
--
          Close c_vire_detail;
--
        End if;
/*********************
**********************
End loop;
Close c_numcpte;
**********************
*/
--
-- <fin si> du controle de fin de curseur (%notfound)
End If;
--
O_erreur := G_erreur;
--
EXCEPTION WHEN OTHERS THEN
        -- Insertion dans journal_adm du message d'erreur
        G_msg_adm    := SUBSTR(SQLERRM(SQLCODE),1,128);
        O_erreur := SUBSTR(SQLERRM(SQLCODE),1,128);
        G_niv_msg    := 0;
        P_INS_journal;
End p_vire_cpte;
--
---------
---------------- FIN PROCEDURE P_VIRE_CPTE
---------
--
--------- DEBUT PROCEDURE P_FICH_VIRE
--
-- Génération et re-génération des fichiers de virement
--

procedure p_fich_vire   (
                I_numbdx_deb  IN  remise_vire.numremise%type    default NULL,
                I_numbdx_fin  IN  remise_vire.numremise%type    default NULL,
                I_niv_gen     IN  number                        Default 1,
                I_session     IN  NUMBER                        Default 1,
                I_niv_msg     IN  Number                        Default 1,
                O_found       OUT Number,
                O_erreur      OUT Varchar2
                        )
IS
--
Rec_c_numbdx            c_numbdx%rowtype;
Rec_c_virement          c_virement%rowtype;
Rec_c_dec_virement      c_dec_virement%rowtype;
--
G_suffixe_fich_vire     Varchar2(10);
--
Ligne_1                 Varchar2(160);
Ligne_2                 Varchar2(160);
Ligne_3                 Varchar2(160);
--
VIREMENT                UTL_FILE.FILE_TYPE;
--
----
--

Begin

--
O_found         := 1;
G_erreur        := Null;
--
G_numbdx_deb    := I_numbdx_deb;
G_numbdx_fin    := I_numbdx_fin;
G_niv_gen       := I_niv_gen;
--
G_max_msg       := I_niv_msg;
G_session       := I_session;
--G_idligne     := F_max_idligne(I_session => G_session);
---
-- DATE DU JOUR
--
Select to_char(sysdate,'ddmmy')
Into    G_datejour_ddmmy
From dual;
--
---
-- DEVISE
--
Select  pk_devise.devise_ref,
        pk_devise.franc,
        pk_devise.euro
Into    G_devise_ref,
        G_devise_franc,
        G_devise_euro
From    Dual;
--
If G_devise_ref = G_devise_euro Then
        G_monnaie:='E';
Else
        G_monnaie:='F';
End if;
--
If Not c_numbdx%ISOPEN then
        G_niv_msg     := 1;
        G_msg_adm     := 'Debut du traitement le ' ||
                      to_char(Sysdate, 'dd/mm/yyyy hh24:mi');
        P_INS_journal;
--
        Open c_numbdx;
End if;
--
----
--
        Bdx_pour_banque:='0';
--
Fetch c_numbdx Into Rec_c_numbdx;
--
If ( c_numbdx%NotFound ) then
        G_niv_msg     := 1;
        G_msg_adm     := 'Fin Normale du traitement le ' ||
                      to_char(Sysdate, 'dd/mm/yyyy hh24:mi');
        P_INS_journal;
        Close c_numbdx;
        O_found := 0;
        Return;
Else
        O_found := 1;
--
---     Données émetteur
        G_refsoc        := Rec_c_numbdx.refsoc;
        G_numcpte       := Rec_c_numbdx.numcpte;
        G_codbque_soc   := Rec_c_numbdx.codbque_soc;
        G_guichet_soc   := Rec_c_numbdx.guichet_soc;
        G_compte_soc    := Rec_c_numbdx.compte_soc;
        G_clerib_soc    := Rec_c_numbdx.clerib_soc;
        G_emetteur      := Rec_c_numbdx.emetteur;
        G_ident         := Rec_c_numbdx.ident;
        G_identifiant   := F_fill(Rec_c_numbdx.identifiant,14,' ');
        G_rais_soc      := F_fill(Rec_c_numbdx.rais_soc,24,' ');
        G_numdest_bdx   := Rec_c_numbdx.numdest;
        G_natrem        := Rec_c_numbdx.natrem;
--
        If G_natrem = 2 Then
          Begin
                Select  codbque,
                        guichet,
                        direction,
                        groupe,
                        type,
                        nat_place,
                        bancable,
                        vir_autorise
                Into    G_codbque_dest,
                        G_guichet_dest,
                        G_direction_dest,
                        G_groupe_dest,
                        G_type_dest,
                        G_nat_place_dest,
                        G_bancable_dest,
                        G_vir_autorise_dest
                From    pers_banque
                Where   numindiv = G_numdest_bdx;
--
                Bdx_pour_banque:='0';
--
          Exception
                When no_data_found Then
        -- Insertion dans journal_adm du message d'erreur
                        G_msg_adm    := 'Bdx pour banque - destinataire non organisme bancaire';
                        O_erreur := SUBSTR(SQLERRM(SQLCODE),1,128);
                        G_niv_msg    := 0;
                        P_INS_journal;
          End;
        End if;
--
/*
-- ouverture du fichier à écrire
*/
--
--      G_suffixe_fich_vire     := F_fill(to_char(G_numbdx_deb),10,'0',-1);
        G_suffixe_fich_vire     := to_char(G_numbdx_deb);
--
        Nom_fich_vire           := 'VIRE_'||G_suffixe_fich_vire;
--------Nom_fich_vire:='vire';-----------------
--
        G_niv_msg     := 1;
        G_msg_adm     := 'ouverture nom fichier :  '||Nom_fich_vire;
        P_INS_journal;
--
        VIREMENT:=UTL_FILE.FOPEN('/u1/arthus/edition/export',Nom_fich_vire,'W');
--
/*
-- fichier : écriture de l'enregistrement entete (code '03')
*/
--
        If G_ident = 0 Then
          Ed_parenthese         := F_fill('',1,' ');
          Ed_ident              := F_fill('',1,' ');
          Ed_identifiant        := F_fill('',14,' ');
        Else
          Ed_parenthese         :=')';
          Ed_ident              := to_char(G_ident);
          Ed_identifiant        := G_identifiant;
        End if;
--
------ F_fill('',8,' ')
--
        Ligne_1         := Null;
--
        Ligne_1         := '03';
        Ligne_1         := Ligne_1||'02';
        Ligne_1         := Ligne_1||F_fill('',8,' ');
        Ligne_1         := Ligne_1||F_fill(to_char(G_emetteur), 6, '0',-1);
        Ligne_1         := Ligne_1||F_fill('',1,' ');
        Ligne_1         := Ligne_1||'0';
        Ligne_1         := Ligne_1||F_fill('',5,' ');
        Ligne_1         := Ligne_1||G_datejour_ddmmy;
        Ligne_1         := Ligne_1||G_rais_soc;
        Ligne_1         := Ligne_1||F_fill(to_char(G_numbdx_deb),7,'0',-1);
        Ligne_1         := Ligne_1||F_fill('',19,' ');
        Ligne_1         := Ligne_1||G_monnaie;
        Ligne_1         := Ligne_1||F_fill('',5,' ');
        Ligne_1         := Ligne_1||G_guichet_soc;
        Ligne_1         := Ligne_1||G_compte_soc;
        Ligne_1         := Ligne_1||Ed_parenthese;
        Ligne_1         := Ligne_1||Ed_ident;
        Ligne_1         := Ligne_1||Ed_identifiant;
        Ligne_1         := Ligne_1||F_fill('',31,' ');
        Ligne_1         := Ligne_1||G_codbque_soc;
        Ligne_1         := Ligne_1||F_fill('',6,' ');
--
                G_niv_msg     := 1;
                G_msg_adm     := 'Ligne 1 - a : '||Substr(Ligne_1,1,80);
                P_INS_journal;
                G_niv_msg     := 1;
                G_msg_adm     := 'Ligne 1 - b : '||Substr(Ligne_1,81,80);
                P_INS_journal;
--
        UTL_FILE.PUT_LINE(VIREMENT,Ligne_1);
--
--
        Premier_virement:='O';
        Virement_pour_ecriture:='N';
        Dernier_virement:='N';
--
        G_montant_total:=0;
--
        G_numvirement:=Null;
        G_numbene:=Null;
--
        Open c_virement(G_numbdx_deb);
--
        Loop
--
           Virement_pour_ecriture:='N';
--
           Fetch c_virement into Rec_c_virement;
--
           If c_virement%notfound Then
                  Dernier_virement:='O';
--
--------------------------------------------
                G_niv_msg     := 3;
                G_msg_adm     := 'Dernier virement ';
                P_INS_journal;
--------------------------------------------
--
--
---- écriture de l'enregistrement fin de fichier (code '08')
--
                Ligne_3         := Null;
--
                Ligne_3         := '08';
                Ligne_3         := Ligne_3||'02';
                Ligne_3         := Ligne_3||F_fill('',8,' ');
                Ligne_3         := Ligne_3||F_fill(to_char(G_emetteur), 6, '0',-1);
                Ligne_3         := Ligne_3||F_fill('',84,' ');
                Ligne_3         := Ligne_3||lpad(to_char(G_montant_total),16,'0');
                Ligne_3         := Ligne_3||F_fill('',31,' ');
                Ligne_3         := Ligne_3||F_fill('',5,' ');
                Ligne_3         := Ligne_3||F_fill('',6,' ');
--
                G_niv_msg     := 1;
                G_msg_adm     := 'Ligne 3 - a : '||Substr(Ligne_3,1,80);
                P_INS_journal;
                G_niv_msg     := 1;
                G_msg_adm     := 'Ligne 3 - b : '||Substr(Ligne_3,81,80);
                P_INS_journal;
--
--
                UTL_FILE.PUT_LINE(VIREMENT,Ligne_3);
--
                Close c_virement;
--
--
        G_niv_msg     := 1;
        G_msg_adm     := 'fermeture fichier - '||'montant_tot :  '||to_char(G_montant_total);
        P_INS_journal;
--
                UTL_FILE.FCLOSE(VIREMENT);
--
--- mise à jour du bordereau dans la table remise_vire
--
--
                Update remise_vire
                Set datdisk = trunc(sysdate)
                Where numremise = G_numbdx_deb;
--
/*
--
--- fait il faire l'insert into lib_edition ?
--
                Insert into lib_edition (
                                        numedit,
                                        editlib)
                Values  (G_numedit,
                         'Remise virement n° '||to_char(G_numbdx_deb)
                         ||' du '||to_char(sysdate,'dd/mm/yyyy')
                        );
--
*/
                Exit;
--
           Else
--
                Virement_pour_ecriture:='O';
--
--------------------------------------------
                G_niv_msg     := 3;
                G_msg_adm     := 'N° virement = '||to_char(Rec_c_virement.numvirement);
                P_INS_journal;
--------------------------------------------
--
                G_numvirement           := Rec_c_virement.numvirement;
                G_codbque               := Rec_c_virement.codbque;
                G_guichet               := Rec_c_virement.guichet;
                G_compte                := Rec_c_virement.compte;
                G_clerib                := Rec_c_virement.clerib;
                G_intitule              := F_fill(Rec_c_virement.intitule,24,' ');
                G_montant_virement      := Rec_c_virement.montant;
                G_min_numdecaismt       := Rec_c_virement.min_numdecaismt;
                G_numremise             := Rec_c_virement.numremise;
--
                select numbene, typbene, codope
                Into G_numbene, G_typbene, G_codope
                From decaismt
                Where numdecaismt = G_min_numdecaismt;
--
                G_beneficiaire:=Null;
                If G_codope = 1 Then
                  Begin
                        SELECT f_bene_virement(G_numbene,G_typbene,G_min_numdecaismt,1)
                        INTO G_beneficiaire
                        FROM dual;
                  Exception when no_data_found Then
                        G_beneficiaire:=Null;
                  End;
                End if;
--
--
---- écriture de l'enregistrement detail (code '06')
--
                If G_ident = 0 Then
                  Ed_beneficiaire := F_fill('',18,' ');
                Else
                  Ed_beneficiaire := F_fill(G_beneficiaire,18,' ');
                End if;
--
                Ligne_2         := Null;
--
                Ligne_2         := '06';
                Ligne_2         := Ligne_2||'02';
                Ligne_2         := Ligne_2||F_fill('',8,' ');
                Ligne_2         := Ligne_2||F_fill(to_char(G_emetteur), 6, '0',-1);
                Ligne_2         := Ligne_2||F_fill(to_char(G_numbene),12,' ');
                Ligne_2         := Ligne_2||F_fill(G_intitule,24,' ');
                Ligne_2         := Ligne_2||F_fill('',20,' ');
                Ligne_2         := Ligne_2||F_fill('',4,' ');
                Ligne_2         := Ligne_2||F_fill('',8,' ');
                Ligne_2         := Ligne_2||G_guichet;
                Ligne_2         := Ligne_2||F_fill(G_compte,11,' ');
                Ligne_2         := Ligne_2||lpad(to_char(G_montant_virement),16,'0');
                Ligne_2         := Ligne_2||')';
                Ligne_2         := Ligne_2||'VIR=';
                Ligne_2         := Ligne_2||F_fill(to_char(G_numvirement),8,' ');
                Ligne_2         := Ligne_2||Ed_beneficiaire;
                Ligne_2         := Ligne_2||G_codbque;
                Ligne_2         := Ligne_2||F_fill('',6,' ');
--
                G_niv_msg     := 1;
                G_msg_adm     := 'Ligne 2 - a : '||Substr(Ligne_2,1,80);
                P_INS_journal;
                G_niv_msg     := 1;
                G_msg_adm     := 'Ligne 2 - b : '||Substr(Ligne_2,81,80);
                P_INS_journal;
--
--
                  UTL_FILE.PUT_LINE(VIREMENT,Ligne_2);
--
                  G_montant_total:=G_montant_total + G_montant_virement;
--
--- mise à jour des décaissements de la table decaismt liés à ce n° de virement
--
--
                  Open c_dec_virement(G_numvirement);
                  Loop
                        Fetch c_dec_virement into Rec_c_dec_virement;
                        Exit when c_dec_virement%notfound;

                        Update decaismt
                        Set     refpmt = G_numvirement,
                                datpay=trunc(sysdate),
                                numchq=0
                        Where  decaismt.numdecaismt = Rec_c_dec_virement.numdecaismt;
                  End Loop;
                  Close c_dec_virement;
--
--
--
-- <fin si> du controle de fin de curseur c_virement (%notfound)
           End if;
        End loop;
--
-- <fin si> du controle de fin de curseur c_numbdx (%notfound)
End If;
--
O_erreur := G_erreur;
--
EXCEPTION
  WHEN UTL_FILE.INTERNAL_ERROR THEN
        -- Insertion dans journal_adm du message d'erreur
        G_msg_adm    := 'UTL_FILE.INTERNAL_ERROR';
        O_erreur := SUBSTR(SQLERRM(SQLCODE),1,128);
        G_niv_msg    := 0;
        P_INS_journal;

  WHEN UTL_FILE.INVALID_FILEHANDLE THEN
        -- Insertion dans journal_adm du message d'erreur
        G_msg_adm    := 'UTL_FILE.INVALID_FILEHANDLE';
        O_erreur := SUBSTR(SQLERRM(SQLCODE),1,128);
        G_niv_msg    := 0;
        P_INS_journal;

  WHEN UTL_FILE.INVALID_MODE THEN
        -- Insertion dans journal_adm du message d'erreur
        G_msg_adm    := 'UTL_FILE.INVALID_MODE';
        O_erreur := SUBSTR(SQLERRM(SQLCODE),1,128);
        G_niv_msg    := 0;
        P_INS_journal;

  WHEN UTL_FILE.INVALID_OPERATION THEN
        -- Insertion dans journal_adm du message d'erreur
        G_msg_adm    := 'UTL_FILE.INVALID_OPERATION';
        O_erreur := SUBSTR(SQLERRM(SQLCODE),1,128);
        G_niv_msg    := 0;
        P_INS_journal;

  WHEN UTL_FILE.INVALID_PATH THEN
        -- Insertion dans journal_adm du message d'erreur
        G_msg_adm    := 'UTL_FILE.INVALID_PATH';
        O_erreur := SUBSTR(SQLERRM(SQLCODE),1,128);
        G_niv_msg    := 0;
        P_INS_journal;

  WHEN UTL_FILE.READ_ERROR THEN
        -- Insertion dans journal_adm du message d'erreur
        G_msg_adm    := 'UTL_FILE.READ_ERROR';
        O_erreur := SUBSTR(SQLERRM(SQLCODE),1,128);
        G_niv_msg    := 0;
        P_INS_journal;

  WHEN UTL_FILE.WRITE_ERROR THEN
        -- Insertion dans journal_adm du message d'erreur
        G_msg_adm    := 'UTL_FILE.WRITE_ERROR';
        O_erreur := SUBSTR(SQLERRM(SQLCODE),1,128);
        G_niv_msg    := 0;
        P_INS_journal;

  WHEN VALUE_ERROR THEN
        G_msg_adm    := 'UTL_FILE.VALUE_ERROR';
        O_erreur := SUBSTR(SQLERRM(SQLCODE),1,128);
        G_niv_msg    := 0;
        P_INS_journal;


WHEN OTHERS THEN
        -- Insertion dans journal_adm du message d'erreur
        G_msg_adm    := SUBSTR(SQLERRM(SQLCODE),1,128);
        O_erreur := SUBSTR(SQLERRM(SQLCODE),1,128);
        G_niv_msg    := 0;
        P_INS_journal;
End p_fich_vire;
--
---------------- FIN PROCEDURE P_FICH_VIRE
--
--
--------- DEBUT PROCEDURE P_crea_bban
--
-- A partir des code banque, guichet, compte, clerib et code pays,
--
--
procedure p_crea_bban   (
                I_codbque       IN      rib.codbque%type        Default Null,
                I_guichet       IN      rib.guichet%type        Default Null,
                I_compte        IN      rib.compte%type         Default Null,
                I_clerib        IN      rib.clerib%type         Default Null,
                I_codpays       IN      rib.codpays%type        Default 1,
                O_clef_iban     OUT     rib.clef_iban%type,
                O_bban          OUT     rib.bban%type,
                O_retour        OUT     Number
                        )
IS
--
lg_bban         pays.nbcarbban%type;

Begin
--
O_retour                := 0;
--
Select  pref_iban, nbcarbban
Into    O_clef_iban, lg_bban
From pays
Where codpays = I_codpays;
--
G_rib.bban      := F_fill(I_codbque,5,'0',-1)
                 ||F_fill(I_guichet,5,'0',-1)
                 ||F_fill(I_compte,11,'0',-1)
                 ||F_fill(I_clerib,2,'0',-1)
                ;
--
O_retour                := 1;
--
Exception
        When others then
        O_retour := -1;
End p_crea_bban;
--
---------------- FIN PROCEDURE P_crea_bban
--
--
--------- DEBUT PROCEDURE P_sel_rib
--
-- A partir des code banque, guichet, compte, clerib et code pays,
--
--
procedure P_sel_rib   (
                I_codpays       IN      rib.codpays%type        Default 1,
                I_clef_iban     IN      rib.clef_iban%type      Default Null,
                I_bban          IN      rib.bban%type           Default Null,
                O_codbque       OUT     rib.codbque%type,
                O_guichet       OUT     rib.guichet%type,
                O_compte        OUT     rib.compte%type,
                O_clerib        OUT     rib.clerib%type,
                O_retour        OUT     Number
                        )
IS
--
lg_bban         pays.nbcarbban%type;
--

Begin
--
O_retour                := 0;
--
        lg_bban:=length(I_bban);
--
        O_codbque       := Substr(I_bban,1,5);
        O_codbque       := F_fill(O_codbque,5,'0',-1);
--
        O_guichet       := Substr(I_bban,6,5);
        O_guichet       := F_fill(O_guichet,5,'0',-1);
--
	O_compte        := Substr(I_bban,11,11);
	--O_compte := Substr(I_bban, 11, (TO_NUMBER(LENGTH(I_bban)) - 2));
        O_compte        := F_fill(O_compte,11,'0',-1);
--
	O_clerib        := Substr(I_bban,22,2);
	--O_clerib := Substr(I_bban, (TO_NUMBER(LENGTH(I_bban)) -1), 2);
        O_clerib        := F_fill(O_clerib,2,'0',-1);
--
        O_retour        := 1;
--
Exception
        When others then
        O_retour := -1;
End P_sel_rib;
--
---------------- FIN PROCEDURE P_sel_rib
--


--
----------------------- Fin des procedures publiques ------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
Procedure P_INS_journal
IS
L_idligne       Number;
BEGIN
If ( G_niv_msg <= G_max_msg ) then
        G_idligne := G_idligne + 1;
        If ( G_niv_msg = 0 ) then
                L_idligne := -1 * G_idligne;
        Else
                L_idligne := G_idligne;
        End If;
        PK_trace.P_INS_journal_adm (
                I_nom_traitement => G_nom_traitement,
                I_session        => G_session,
                I_niv_msg        => G_niv_msg,
                I_msg_adm        => G_msg_adm,
                I_idligne        => L_idligne);
End If;
END P_INS_journal;
---------------- Fin des corps des procedures privees --
END;
/
