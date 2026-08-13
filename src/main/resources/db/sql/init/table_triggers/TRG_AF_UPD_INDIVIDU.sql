CREATE TRIGGER ARTHUS."TRG_AF_UPD_INDIVIDU"
after update of nom, nomjf, caisse, regime, guichetorg, matorg, datnais, datnais_regime, guichetpmt, prenom, cless, rang, natur
                , regime2 , caisse2 , matorg2 , cless2 -- M0006399
on individu
for each row
   WHEN (
  ( nvl(new.caisse, '0') != nvl(old.caisse, '0') ) or
  ( nvl(new.guichetorg, '0') != nvl(old.guichetorg, '0') ) or
  ( nvl(new.matorg, '0') != nvl(old.matorg, '0') ) or
  ( nvl(new.cless, 0) != nvl(old.cless, 0) ) or
  ( nvl(new.regime, '0') != nvl(old.regime, '0') ) or
  ( nvl(new.caisse2, '0') != nvl(old.caisse2, '0') ) or
  ( nvl(new.guichetorg2, '0') != nvl(old.guichetorg2, '0') ) or
  ( nvl(new.matorg2, '0') != nvl(old.matorg2, '0') ) or
  ( nvl(new.cless2, 0) != nvl(old.cless2, 0) ) or
  ( nvl(new.regime2, '0') != nvl(old.regime2, '0') ) or
  ( nvl(new.rang, 0) != nvl(old.rang, 0) ) or
  ( nvl(new.natur, 0) != nvl(old.natur, 0) ) or
  ( nvl(new.nom, '0') != nvl(old.nom, '0') ) or
  ( nvl(new.prenom, '0') != nvl(old.prenom, '0') ) or
  ( nvl(new.nomjf, '0') != nvl(old.nomjf, '0') ) or
  ( nvl(new.datnais, sysdate) != nvl(old.datnais, sysdate) ) or
  ( nvl(new.datnais_regime, '0') != nvl(old.datnais_regime, '0') ) or
  ( nvl(new.guichetpmt, '0') in ('-1', '-2', '-3', '-4', '-5', '-6') )
      ) DECLARE
CST_SCCS   CONSTANT VARCHAR2(120) := '@(#)trg_af_upd_individu.sql  1.6    01/05/18';
CURSOR  C_adhesion IS
  select  distinct
    idadhesion,
    numgar,
    min(datapli)  datapli,
    MAX(NVL(datper,E2D('31/12/3000'))) datper
  from   adhesion
  where   numindiv=:new.numindiv
  and   etat in(
    select code from lble
    where mnemo='ETIN'
    and sens=0
        )
  and   nvl(datper,sysdate)>=sysdate
  and  datapli != nvl(datper,datapli+1)
  and  rang = 1
  and  (:new.guichetpmt = '-4' AND PK_QTTC.f_sel_numgar(numgar)IN (SELECT numgar FROM porte_contrat WHERE numutil = -1)
   OR
       (NVL(:new.guichetpmt,'0') <> '-4'))

  group by
    idadhesion,
    numgar
  ;

CURSOR  C_porte(P_numgar number) IS
  select  distinct
    porte_param.numporte,
    contrat.numinterm  numsoc,
    contrat.numorg,
    1  type_modif
  from   parporte,
    contrat,
    porte_contrat,
    porte_param
  Where  contrat.numorg + 0 = parporte.numorg
  and  contrat.numinterm + 0 = parporte.numsoc
  and  parporte.numreg  = :new.regime
  and  parporte.numcaisse = :new.caisse
  and  parporte.ouverte = 1
  and  parporte.numporte  = porte_param.numporte
  and  contrat.numgar    = porte_contrat.numgar
  and  porte_contrat.numporte  = porte_param.numporte
  and  porte_contrat.numgar  = PK_QTTC.f_sel_numgar(P_numgar)
  and   not exists (
    select 1 from param_tiers_payant  /* Sauf Sante Pharma */
    where param_tiers_payant.numporte=porte_param.numporte
    )
  and  porte_param.batch_export is not null
  ;

Rec_C_adhesion  C_adhesion%ROWTYPE;
Rec_C_porte   C_porte%ROWTYPE;
L_type_modif   Number;
L_Oidporte  porte_adhesion.idporte%Type;
L_Otransmis  porte_adhesion.transmis%Type;
L_Omouvement  porte_adhesion.mouvement%Type;
L_Otype    porte_adhesion.type%Type;
L_Ofound    Boolean;
L_mouvement  porte_adhesion.mouvement%Type Default Null;
L_idporte   Number;
i     Number;
i_flag  Number:=0;
i_flagSS  Number:=0;
l_datper  Date;

BEGIN
/* Determination du type de modif */
If   ( nvl(:new.caisse, '0') != nvl(:old.caisse, '0') ) then
  L_type_modif := 2;
Elsif   ( nvl(:new.caisse2, '0') != nvl(:old.caisse2, '0') ) then
  L_type_modif := 2;
  i_flagSS:=1;
Elsif   ( nvl(:new.guichetorg, '0') != nvl(:old.guichetorg, '0') ) then
  L_type_modif := 32;
Elsif   ( nvl(:new.guichetorg2, '0') != nvl(:old.guichetorg2, '0') ) then
  L_type_modif := 32;
  i_flagSS:=1;
Elsif   ( nvl(:new.regime, '0') != nvl(:old.regime, '0') ) then
  L_type_modif := 2;
Elsif   ( nvl(:new.regime2, '0') != nvl(:old.regime2, '0') ) then
  L_type_modif := 2;
  i_flagSS:=1;
Elsif  ( nvl(:new.matorg, '0') != nvl(:old.matorg, '0') ) then
  L_type_modif := 3;
Elsif  ( nvl(:new.matorg2, '0') != nvl(:old.matorg2, '0') ) then
  L_type_modif := 3;
  i_flagSS:=1;
Elsif  ( nvl(:new.cless, 0) != nvl(:old.cless, 0) ) then
  L_type_modif := 3;
Elsif  ( nvl(:new.cless2, 0) != nvl(:old.cless2, 0) ) then
  L_type_modif := 3;
  i_flagSS:=1;
Elsif  ( nvl(:new.rang, 0) != nvl(:old.rang, 0) ) then
  L_type_modif := 3;
Elsif  ( nvl(:new.natur, 0) != nvl(:old.natur, 0) ) then
  L_type_modif := 3;
Elsif  ( nvl(:new.datnais, sysdate) != nvl(:old.datnais, sysdate) ) then
  L_type_modif := 15;
Elsif  ( nvl(:new.datnais_regime, '0') != nvl(:old.datnais_regime, '0') ) then
  L_type_modif := 15;
Elsif   ( nvl(:new.nom, '0') != nvl(:old.nom, '0') ) then
  L_type_modif := 4;
Elsif   ( nvl(:new.prenom, '0') != nvl(:old.prenom, '0') ) then
  L_type_modif := 4;
Elsif  ( nvl(:new.nomjf, '0') != nvl(:old.nomjf, '0') ) then
  L_type_modif := 5;
Elsif   ( :new.guichetpmt = '-1' ) then
  L_type_modif := 6;
  i_flagSS:=1;
Elsif   ( :new.guichetpmt = '-2' ) then
  -- rejet noemie sur matorg
  L_type_modif := 30;
  i_flagSS:=1;
Elsif   ( :new.guichetpmt = '-3' ) then
  -- rejet noemie sur matorg
  L_type_modif := 31;
  i_flagSS:=1;
Elsif   ( :new.guichetpmt = '-4' ) then
  -- ajout porte contrat
  L_type_modif := 6;
  i_flagSS:=1;
Elsif   ( :new.guichetpmt = '-5' ) then
  -- rejet noemie sur matorg2
  L_type_modif := 30;
  i_flagSS:=5;
Elsif   ( :new.guichetpmt = '-6' ) then
  -- rejet noemie sur matorg2
  L_type_modif := 31;
  i_flagSS:=6;
End if;
/*  On fetch les adhesions de l'assure  */
Open C_adhesion;
Loop
  /* On fetch les portes pour lesquelles on doit transmettre  */
  Fetch C_adhesion Into Rec_C_adhesion;
  Exit When C_adhesion%NotFound;
  Open C_porte( Rec_C_adhesion.numgar );
  Loop
    Fetch C_porte Into Rec_C_porte;
    Exit When C_porte%NotFound;

     /* positionnement de la date de fn */
      l_datper := Rec_C_adhesion.datper;
      IF l_datper = E2D('31/12/3000') THEN
        l_datper := NULL;
      END IF;

      /* Recherche de la derniere info transmise */
      pk_noemie.P_SEL_porte_adhesion (
        I_numporte  => Rec_C_porte.numporte,
        I_numindiv  => :new.numindiv,
        I_idadhesion  => Rec_C_adhesion.idadhesion,
        I_matorg      => :new.matorg,
        I_transmis  => Null,
        I_mouvement  => Null,
        O_idporte  => L_Oidporte,
        O_transmis  => L_Otransmis,
        O_mouvement  => L_Omouvement,
        O_type    => L_Otype,
        O_found    => L_Ofound);

      If ( NOT L_Ofound or :new.guichetpmt = '-2' ) then
        /* Jamais transmis -> creation ou rejet */
        L_mouvement := 'C';
      Else
        /* Deja transmis */
        If ( L_Otransmis = 1 or :new.guichetpmt = '-3' ) then
          /* Changement de caisse */
          If ( L_type_modif = 2 ) then
            L_mouvement := 'C';
          /*Changement de centre*/
          Elsif ( L_type_modif = 32 ) then
            L_mouvement := 'C';
          Elsif ( L_type_modif = 15 ) then
            L_mouvement := 'C';
          /* Devient ouvreur de droit */
          -- Rectification : changement de N° SS
          Elsif ( L_type_modif = 3 ) then
            L_mouvement := 'C';
          Else
          /* Modification  ou signalement */
          L_mouvement := 'M';
          End if;
       /* else
          IF ( L_type_modif = 15 ) THEN
            L_mouvement := 'C';
          END IF;*/
        End if;
      End if;
/*
      pk_trace.p_ins_journal_adm ('TRG_AF_UPD_INDIVIDU',
                                sid,
                                3,
                                'L_Oidporte: '||to_char(L_Oidporte)||',L_mouvement:'||to_char(L_mouvement)||',L_type_modif:'||to_char(L_type_modif)||',L_Otransmis:'||to_char(L_Otransmis)
                                ,SYSDATE,1
                               );
*/
      If ( L_mouvement Is Not Null ) then
          -- vérification que aucun mouvement n a déjà été transmis pour le 1er SS
          IF f_type_porte(Rec_C_porte.numporte) =1 THEN

            -- Recheche pour la porte 1 noemie : circuit 1
            SELECT COUNT(*) INTO i_flag
              FROM porte_adhesion, noemie
             WHERE porte_adhesion.numporte = Rec_C_porte.numporte
               AND noemie.idporte=porte_adhesion.idporte
               AND noemie.matorg=NVL(:new.matorg,noemie.matorg)
               AND noemie.caisse=NVL(:new.caisse,noemie.caisse)
               and noemie.orgbase=NVL(:new.regime,noemie.orgbase)
               AND porte_adhesion.numindiv = :new.numindiv
               AND porte_adhesion.idadhesion = Rec_C_adhesion.idadhesion
               AND porte_adhesion.mouvement='C'
               AND porte_adhesion.fin is null
               AND noemie.natur=2 -- uniquement sur les ayants droits
             --  AND porte_adhesion.type in(1,6) -- uniquement pour une nouvelle adhesion ou ouverture de la porte NOEMIE
               AND porte_adhesion.transmis = 1;
          END IF;
          IF f_type_porte(Rec_C_porte.numporte) =4 THEN

            -- Recheche pour la porte 18 TP Hospi : circuit 4
            SELECT COUNT(*)
              INTO i_flag
              FROM porte_adhesion, demande_tp, demande_tp_ad
             WHERE porte_adhesion.numporte = Rec_C_porte.numporte
               AND demande_tp.idporte=porte_adhesion.idporte
               AND demande_tp.matorg=NVL(:new.matorg,demande_tp.matorg)
               AND demande_tp.caisse=NVL(:new.caisse,demande_tp.caisse)
               and demande_tp.regime=NVL(:new.regime,demande_tp.regime)
               AND porte_adhesion.numindiv = :new.numindiv
               AND porte_adhesion.idadhesion =Rec_C_adhesion.idadhesion
               AND porte_adhesion.mouvement='C'
               AND porte_adhesion.fin is null
               AND porte_adhesion.transmis = 1
               AND demande_tp_ad.idporte=porte_adhesion.idporte -- test avec idporte= 2749145
               AND DECODE (demande_tp_ad.numindiv, demande_tp.numindiv, 1, 2)=2;-- uniquement sur les ayants droits

          END IF;

        IF L_type_modif = 15 THEN
          IF TRIM(:new.matorg2) IS NOT NULL THEN
            i_flagSS:=1;
          END IF;
          i_flag:=0;
        END IF;
/*
      pk_trace.p_ins_journal_adm ('TRG_AF_UPD_INDIVIDU',
                                sid,
                                3,
                                'i_flag: '||to_char(i_flag)||',:new.matorg:'||to_char(:new.matorg)||',:new.matorg2:'||to_char(:new.matorg2)||',:new.natur:'||to_char(:new.natur)
                                ,SYSDATE,2
                               );

      pk_trace.p_ins_journal_adm ('TRG_AF_UPD_INDIVIDU',
                                sid,
                                3,
                                'i_flagSS: '||to_char(i_flagSS)||',:old.matorg2:'||to_char(:old.matorg2)||',:new.matorg2:'||to_char(:new.matorg2)||',:new.matorg2:'||to_char(:new.matorg2)
                                ,SYSDATE,3
                               );
      pk_trace.p_ins_journal_adm ('TRG_AF_UPD_INDIVIDU',
                                sid,
                                3,
                                'new.caisse: '||to_char(:new.caisse)||',:old.caisse:'||to_char(:old.caisse)
                                ,SYSDATE,4
                               );
*/
        IF i_flag = 0 THEN
        -- AND i_flagSS NOT IN (2, 3) THEN
/*
      pk_trace.p_ins_journal_adm ('TRG_AF_UPD_INDIVIDU',
                                sid,
                                3,
                                ':new.datnais OKKK: '||to_char(:new.datnais)||',:old.datnais:'||to_char(:old.datnais)
                                ,SYSDATE,5
                               );
*/
          pk_noemie.P_INS_porte_adhesion (
           I_Numporte  => Rec_C_porte.numporte,
           I_Numindiv  => :new.numindiv,
           I_Idadhesion  => Rec_C_adhesion.idadhesion,
           I_Type    => L_type_modif,
           I_Debut    => Rec_C_adhesion.datapli,
           I_Mouvement  => L_mouvement,
           I_Fin    => L_datper,
           I_numsoc  => Rec_C_porte.numsoc,
           I_numorg  => Rec_C_porte.numorg,
           I_orgbase  => :new.regime,
           I_caisse  => :new.caisse,
           I_centre  => :new.guichetorg,
           I_matorg  => :new.matorg,
           I_cless    => :new.cless,
           I_datnais  => :new.datnais,
           I_datnais_regime => :new.datnais_regime,
           I_rang    => :new.rang,
           I_natur    => :new.natur,
           I_numassu  => 0,
           I_nom    => :new.nom,
           I_prenom  => :new.prenom,
           I_nomjf    => :new.nomjf,
           O_idporte  => L_idporte
           );

        END IF;
        IF :new.natur = 2 AND :new.matorg2 IS NOT NULL AND ((i_flagSS IN (1, 5, 6) ) OR NVL(TRIM(:old.matorg2),'1')<>TRIM(:new.matorg2)) THEN

/*
      pk_trace.p_ins_journal_adm ('TRG_AF_UPD_INDIVIDU',
                                sid,
                                3,
                                ' IF :new.natur = 2: '
                                ,SYSDATE,6);
*/
          pk_noemie.P_INS_porte_adhesion (
            I_Numporte  => Rec_C_porte.numporte,
            I_Numindiv  => :new.numindiv,
            I_Idadhesion  => Rec_C_adhesion.idadhesion,
            I_Type    => L_type_modif,
            I_Debut    => Rec_C_adhesion.datapli,
            I_Mouvement  => L_mouvement,
            I_Fin    => L_datper,
            I_numsoc  => Rec_C_porte.numsoc,
            I_numorg  => Rec_C_porte.numorg,
            I_orgbase  => :new.regime2,
            I_caisse  => :new.caisse2,
            I_centre  => :new.guichetorg2,
            I_matorg  => :new.matorg2,
            I_cless    => :new.cless2,
            I_datnais  => :new.datnais,
            I_datnais_regime => :new.datnais_regime,
            I_rang    => :new.rang,
            I_natur    => :new.natur,
            I_numassu  => 0,
            I_nom    => :new.nom,
            I_prenom  => :new.prenom,
            I_nomjf    => :new.nomjf,
            O_idporte  => L_idporte
            );

        END IF;

      Else
/*
      pk_trace.p_ins_journal_adm ('TRG_AF_UPD_INDIVIDU',
                                sid,
                                3,
                                'else matorg:  '||to_char(:old.matorg)||',new matorg:'||to_char(:old.matorg)
                                ,SYSDATE,7);
*/
       IF i_flagSS NOT IN ( 5, 6) THEN
        --  On Update Noemie si pas deja transmis
        pk_noemie.P_UPD_noemie (
          I_Numporte  => Rec_C_porte.numporte,
          I_Numindiv  => :new.numindiv,
          I_Idadhesion  => Rec_C_adhesion.idadhesion,
          I_type    => L_type_modif,
          I_orgbase  => :new.regime,
          I_caisse  => :new.caisse,
          I_centre  => :new.guichetorg,
          I_matorg  => :new.matorg,
          i_Oldmatorg  => :old.matorg,
          I_cless    => :new.cless,
          I_datnais  => :new.datnais,
          I_datnais_regime => :new.datnais_regime,
          I_rang    => :new.rang,
          I_natur    => :new.natur,
          I_numassu  => Null,
          I_nom    => :new.nom,
          I_prenom  => :new.prenom,
          I_nomjf    => :new.nomjf
          );
        END IF;

        IF :new.natur = 2 and :new.matorg2 IS NOT NULL AND ((i_flagSS IN (1, 5, 6) ) OR TRIM(:new.matorg) IS NOT NULL) THEN
/*
      pk_trace.p_ins_journal_adm ('TRG_AF_UPD_INDIVIDU',
                                sid,
                                3,
                                'else matorg2:  '||to_char(:old.matorg2)||',new matorg2:'||to_char(:new.matorg2)
                                ,SYSDATE,8);
*/
          pk_noemie.P_UPD_noemie (
            I_Numporte  => Rec_C_porte.numporte,
            I_Numindiv  => :new.numindiv,
            I_Idadhesion  => Rec_C_adhesion.idadhesion,
            I_type    => L_type_modif,
            I_orgbase  => :new.regime2,
            I_caisse  => :new.caisse2,
            I_centre  => :new.guichetorg2,
            I_matorg  => :new.matorg2,
            i_Oldmatorg  => :old.matorg2,
            I_cless    => :new.cless2,
            I_datnais  => :new.datnais,
            I_datnais_regime => :new.datnais_regime,
            I_rang    => :new.rang,
            I_natur    => :new.natur,
            I_numassu  => Null,
            I_nom    => :new.nom,
            I_prenom  => :new.prenom,
            I_nomjf    => :new.nomjf
            );

        END IF;
      END IF;
    End Loop;  /* Du fetch_porte  */
  Close C_porte;
End Loop;  /* Du fetch_adhesion  */
Close C_adhesion;

END;