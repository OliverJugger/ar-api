CREATE TRIGGER ARTHUS.TRG_IUD_ADHESION
FOR INSERT OR UPDATE OR DELETE ON ADHESION
COMPOUND TRIGGER



  TYPE ty_adhesion   IS TABLE OF adhesion%ROWTYPE;
  t_adhesion         ty_adhesion := ty_adhesion();

  TYPE ty_action     IS TABLE OF VARCHAR2(20);
  t_action           ty_action   := ty_action();

  loc_numporte       pk_types.t_table;
  i                  NUMBER;
  j                  NUMBER;
  loc_idporte        NUMBER;
  loc_type           NUMBER DEFAULT 11; /* Fin de couverture */
  loc_type_porte     NUMBER;
  loc_transmis       NUMBER;
  loc_last_idporte   NUMBER;
  cpt_adhe           NUMBER;
  ETAT_ADHE          NUMBER;
  cpt_log            NUMBER :=0;
  loc_etat           number;
  loc_numassu        number;
  loc_mouvement      varchar2(1) default 'C';
  loc_typadr         number;
  loc_old_param_tp   gar_param_tp.idparam_tp%type;
  loc_new_param_tp   gar_param_tp.idparam_tp%type;
  loc_old_datper     date;


Cursor   C_old_idparam_tp (v_idadhesion adhesion.idadhesion%TYPE)
is
select   idparam_tp, datper
from   control_adhesion
where   idadhesion = v_idadhesion
order by nvl(datper, sysdate) desc;


CURSOR  C_new_idparam_tp (v_numgar adhesion.numgar%TYPE, v_numfor adhesion.numfor%TYPE)
    IS
SELECT  idparam_tp
  FROM  gar_param_tp
 WHERE  numfor = pk_qttc.f_sel_numfor(pk_qttc.f_sel_numgar(v_numgar), v_numfor)
   AND  numgar = pk_qttc.f_sel_numgar(v_numgar);


CURSOR C_matorg_individu (v_numindiv individu.numindiv%TYPE)
    IS
 SELECT DISTINCT matorg,matorg2
   FROM individu
  WHERE individu.numindiv = v_numindiv;

  rec_matorg_individu  C_matorg_individu%ROWTYPE;

-- -- -- -- --
-- 1er
-- -- -- -- --
BEFORE STATEMENT IS BEGIN
    -- initialisation du tableau permettant de ne plus utiliser la vue materialisée
    t_adhesion := ty_adhesion();
    t_action   := ty_action();
END BEFORE STATEMENT;

-- -- -- -- --
-- 2ème
-- -- -- -- --
BEFORE EACH ROW IS BEGIN
         PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'TRG_IUD_ADHESION',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => 'chopage de couverture',
          I_idligne  => 2);
  -- incrémentation des tableau
  t_action.extend;
  t_adhesion.extend;

  -- mise à jour de valeurs
  CASE WHEN INSERTING THEN
    IF :new.IDCOUVERTURE IS NULL THEN
      SELECT  IDCOUVERTURE.nextval
            INTO  :new.IDCOUVERTURE
            FROM  Dual;
    END IF;

    :new.creation := sysdate;
    ELSE NULL;
  END CASE;


  CASE
        WHEN NOT DELETING THEN
          :new.maj      := sysdate;
          IF :new.numutil IS NULL THEN
            :new.numutil := f_numutil;
          END IF;
        ELSE
          NULL;
  END CASE;

  -- alimentation tableau t_action pour traitement spécifique postérieur dans la section AFTER STATEMENT
  CASE
        WHEN INSERTING AND :New.rang = 1 THEN
          -- en remplacement de TRG_AF_INS_ADHESION
          t_action(t_action.last) := 'INSERTRANG';

        WHEN (UPDATING('IDADHESION') AND NOT UPDATING('DATPER')) AND :New.rang = 1 THEN
          -- en remplacement de TRG_AF_INS_ADHESION
          t_action(t_action.last) := 'UPDATERANG';
        WHEN UPDATING AND nvl(:new.datper, sysdate+50000) != nvl(:old.datper, sysdate+50000) THEN
          t_action(t_action.last) := 'UPDATE DATPER';
        WHEN INSERTING THEN
          t_action(t_action.last) := 'INSERTING';
        WHEN UPDATING THEN
          t_action(t_action.last) := 'UPDATING';
        WHEN DELETING THEN
          t_action(t_action.last) := 'DELETING';
    ELSE NULL;
  END CASE;

  -- alimentation tableau t_adhesion avec les nouvelles données d'adhesion pour traitement spécifique postérieur dans la section AFTER STATEMENT

  CASE
        WHEN DELETING THEN
          t_adhesion(t_adhesion.last).numindiv       := :old.numindiv;
          t_adhesion(t_adhesion.last).numgar         := :old.numgar;
          t_adhesion(t_adhesion.last).numfor         := :old.numfor;
          t_adhesion(t_adhesion.last).datapli        := :old.datapli;
          t_adhesion(t_adhesion.last).datper         := :old.datper;
          t_adhesion(t_adhesion.last).rang           := :old.rang;
          t_adhesion(t_adhesion.last).etat           := :old.etat;
          t_adhesion(t_adhesion.last).uc             := :old.uc;
          t_adhesion(t_adhesion.last).flag_regime    := :old.flag_regime;
          t_adhesion(t_adhesion.last).regime         := :old.regime;
          t_adhesion(t_adhesion.last).typfor         := :old.typfor;
          t_adhesion(t_adhesion.last).numorg         := :old.numorg;
          t_adhesion(t_adhesion.last).dis_carence    := :old.dis_carence;
          t_adhesion(t_adhesion.last).dis_franchise  := :old.dis_franchise;
          t_adhesion(t_adhesion.last).idadhesion     := :old.idadhesion;
          t_adhesion(t_adhesion.last).numfor_carence := :old.numfor_carence;
          t_adhesion(t_adhesion.last).numutil        := :old.numutil;
          t_adhesion(t_adhesion.last).creation       := :old.creation;
          t_adhesion(t_adhesion.last).maj            := :old.maj;
          t_adhesion(t_adhesion.last).motif          := :old.motif;
          t_adhesion(t_adhesion.last).idcouverture   := :old.idcouverture;

        ELSE
          /* en remplacement de TRG_BF_UPD_ADHESION3 */
          t_adhesion(t_adhesion.last).MAJ            := :new.maj;
          t_adhesion(t_adhesion.last).NUMUTIL        := :new.numutil;
          /*                                         */
          -- alimentation du tableau pour utilisation dans after statement
          t_adhesion(t_adhesion.last).numindiv       := :new.numindiv;
          t_adhesion(t_adhesion.last).numgar         := :new.numgar;
          t_adhesion(t_adhesion.last).numfor         := :new.numfor;
          t_adhesion(t_adhesion.last).datapli        := :new.datapli;
          t_adhesion(t_adhesion.last).datper         := :new.datper;
          t_adhesion(t_adhesion.last).rang           := :new.rang;
          t_adhesion(t_adhesion.last).etat           := :new.etat;
          t_adhesion(t_adhesion.last).uc             := :new.uc;
          t_adhesion(t_adhesion.last).flag_regime    := :new.flag_regime;
          t_adhesion(t_adhesion.last).regime         := :new.regime;
          t_adhesion(t_adhesion.last).typfor         := :new.typfor;
          t_adhesion(t_adhesion.last).numorg         := :new.numorg;
          t_adhesion(t_adhesion.last).dis_carence    := :new.dis_carence;
          t_adhesion(t_adhesion.last).dis_franchise  := :new.dis_franchise;
          t_adhesion(t_adhesion.last).idadhesion     := :new.idadhesion;
          t_adhesion(t_adhesion.last).numfor_carence := :new.numfor_carence;
          -- t_adhesion(t_adhesion.last).numutil        := :new.numutil;
          t_adhesion(t_adhesion.last).creation       := :new.creation;
          -- t_adhesion(t_adhesion.last).maj            := :new.maj;
          t_adhesion(t_adhesion.last).motif          := :new.motif;
          t_adhesion(t_adhesion.last).idcouverture   := :new.idcouverture;
  END CASE;

END BEFORE EACH ROW;


-- -- -- -- --
-- 3ème traitement
-- -- -- -- --
AFTER STATEMENT IS
BEGIN

j := 1;

-- boucle sur tous les enregistrements déclencheurs
FOR j IN 1 .. t_adhesion.COUNT
  LOOP

  -- en insertion
  -- en remplacement de TRG_BF_INS_ADHESION
  IF t_action(j) = 'INSERTRANG' OR t_action(j) = 'INSERTING' THEN
  /*open C_new_idparam_tp(t_adhesion(j).numgar, t_adhesion(j).numfor);
    fetch C_new_idparam_tp into loc_new_param_tp;
      -- close C_new_idparam_tp;
      if (C_new_idparam_tp%FOUND) then
      insert into control_adhesion (idadhesion, numgar, numfor, numindiv,
            idparam_tp, datapli, etat, datper)
      values (t_adhesion(j).idadhesion, t_adhesion(j).numgar, t_adhesion(j).numfor, t_adhesion(j).numindiv,
      loc_new_param_tp, t_adhesion(j).datapli, t_adhesion(j).etat, t_adhesion(j).datper);
      end if;
    close C_new_idparam_tp;*/
    Ins_beneficiaire( t_adhesion(j).idadhesion, t_adhesion(j).numfor, t_adhesion(j).numindiv );

  END IF;

  -- tous les cas : Insertion dans interface export
  -- en remplacement de TRG_AF_INS_UPD_ADHESION3
  IF t_action(j) <> 'DELETING' THEN
    PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(34, t_adhesion(j).idcouverture, t_adhesion(j).numindiv, t_adhesion(j).idadhesion);
    PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(60, t_adhesion(j).idcouverture, t_adhesion(j).numindiv, t_adhesion(j).idadhesion, t_adhesion(j).numgar);
  END IF;


  -- DELETE
  -- en remplacement de TRG_BF_DEL_ADHESION
  IF t_action(j) = 'DELETING' THEN
    PK_INS_HISTO_EXPORT.DEL_HISTO_EXPORT (34, t_adhesion(j).idcouverture);
    PK_INS_HISTO_EXPORT.DEL_HISTO_EXPORT (60, t_adhesion(j).idcouverture);
  END IF;

    -- ancien TRG_BF_UPD_ADHESION
    IF t_action(j) = 'UPDATE DATPER' THEN
      SELECT COUNT(idcouverture)
         INTO cpt_adhe FROM adhesion
                   WHERE numgar   = t_adhesion(j).numgar
                     AND numindiv = t_adhesion(j).numindiv
                     AND idcouverture <> t_adhesion(j).idcouverture
                     AND datper   is null
                     AND rang     = 1
                     AND EXISTS (SELECT 1 FROM porte_adhesion WHERE porte_adhesion.idadhesion = adhesion.idadhesion
                                                                AND porte_adhesion.numindiv   = adhesion.numindiv)
                     ;
-- ajout AND EXISTS pour pb double adhesion avec un mvt noemie sur 1 adhesion uniquement
-- (du coup en fonction de l'ordre de traitement des adhésions, les mvts n'étaient pas générés)
      IF (t_adhesion(j).datper is null) THEN
         loc_type := 12;
      END IF;

      /* Remise en vigueur */
      /*SDA M3379*/
      /*si adhesion en instantce a la date de saisie sysdate pas de mouvenent*/
      ETAT_ADHE := 0;
      --f_etat_instance_unique
      --return 1 adhesion en instance sans autre état
      --return 0
      ETAT_ADHE := f_etat_instance_unique(t_adhesion(j).idadhesion);

      i := 1;
      IF ETAT_ADHE = 0 THEN
        loc_numporte := f_adhesion_externe(t_adhesion(j).numgar, t_adhesion(j).numindiv);
        WHILE ( loc_numporte(i) > 0 ) LOOP
          cpt_log:=cpt_log+1;
          /* Recherche type de porte Noemie ou T.P. */
          loc_type_porte := f_type_porte(loc_numporte(i));
          /*  Recherche dernier enregistrement transmis ou a transmettre */
          loc_last_idporte := f_last_idporte(loc_numporte(i), t_adhesion(j).numindiv,t_adhesion(j).idadhesion);
          IF loc_last_idporte = -1 AND loc_type_porte = 4 THEN
            -- Numassu, pour le cas des enfants ou des conjounts lié au porteur de carte
            loc_last_idporte := f_last_idporte(loc_numporte(i), f_numassu(t_adhesion(j).numindiv),t_adhesion(j).idadhesion);
          END IF;

          --pk_trace.p_ins_journal_adm ('TRG_BF_UPD_ADHESION',sid, 3,' PORTE '||loc_numporte(i)||' numindiv: '||t_adhesion(j).numindiv||' loc_type_porte: '||loc_type_porte ||' loc_last_idporte: '||loc_last_idporte,SYSDATE,1 );

          IF (loc_last_idporte != -1) THEN
          /*  Verifions si il est transmis ou non  */
            loc_transmis := f_transmis(loc_last_idporte);
          --  pk_trace.p_ins_journal_adm ('TRG_BF_UPD_ADHESION',sid, 3,' PORTE '||loc_numporte(i)||' numindiv: '||t_adhesion(j).numindiv||' loc_transmis: '||loc_transmis ||' cpt_adhe: '||cpt_adhe ||' t_adhesion(j).datper: '||t_adhesion(j).datper,SYSDATE,2 );

            -- IF (loc_transmis > 1) THEN
            -- M0005013 remplace loc_transmis = 1 par loc_transmis IN ( 1, 7, 8)
            IF loc_transmis NOT IN ( 1, 7, 8) THEN
                /* En attente */

              IF (loc_type_porte = 1) THEN
                  /* Noemie */

                IF cpt_adhe = 0 THEN -- AND t_adhesion(j).datper IS NOT NULL THEN

                  FOR rec_matorg_individu IN C_matorg_individu (t_adhesion(j).numindiv) LOOP

                    --pk_trace.p_ins_journal_adm ('TRG_BF_UPD_ADHESION',sid, 3,' PORTE '||loc_numporte(i)||' numindiv: '||t_adhesion(j).numindiv||' t_adhesion(j).datapli: '||t_adhesion(j).datapli,SYSDATE,3 );

                    IF t_adhesion(j).datper=t_adhesion(j).datapli THEN
                    /*  Delete porte_adhesion -- Mise en commentaire car les gestionnaires préfèrent faire la suppression mannuellement pour le moment
                      Where idporte = loc_last_idporte;
                      */

                      Update  porte_adhesion
                      Set  fin = t_adhesion(j).datper,
                      type = loc_type
                      Where  idporte in ( SELECT porte_adhesion.idporte
                                              FROM porte_adhesion,noemie
                                             WHERE porte_adhesion.numporte = loc_type_porte
                                               AND porte_adhesion.idadhesion = t_adhesion(j).idadhesion
                                               AND noemie.idporte=porte_adhesion.idporte
                                               AND noemie.matorg=NVL(rec_matorg_individu.matorg,noemie.matorg)
                                               AND porte_adhesion.numindiv = t_adhesion(j).numindiv
                                               AND porte_adhesion.transmis = 2
                                               AND porte_adhesion.mouvement != 'A');


                    ELSE

                      Update  porte_adhesion
                      Set  fin = t_adhesion(j).datper,
                      type = loc_type
                      Where  idporte in ( SELECT porte_adhesion.idporte
                                              FROM porte_adhesion,noemie
                                             WHERE porte_adhesion.numporte = loc_type_porte
                                               AND porte_adhesion.idadhesion = t_adhesion(j).idadhesion
                                               AND noemie.idporte=porte_adhesion.idporte
                                               AND noemie.matorg=NVL(rec_matorg_individu.matorg,noemie.matorg)
                                               AND porte_adhesion.numindiv = t_adhesion(j).numindiv
                                               AND porte_adhesion.transmis = 2
                                               AND porte_adhesion.mouvement != 'A');

                    END IF;



                    IF rec_matorg_individu.matorg2 is not null THEN

                      IF t_adhesion(j).datper=t_adhesion(j).datapli THEN

                      Update  porte_adhesion
                      Set  fin = t_adhesion(j).datper,
                      type = loc_type
                      Where  idporte in ( SELECT porte_adhesion.idporte
                                              FROM porte_adhesion,noemie
                                             WHERE porte_adhesion.numporte = loc_type_porte
                                               AND porte_adhesion.idadhesion = t_adhesion(j).idadhesion
                                               AND noemie.idporte=porte_adhesion.idporte
                                               AND noemie.matorg=NVL(rec_matorg_individu.matorg2,noemie.matorg)
                                               AND porte_adhesion.numindiv = t_adhesion(j).numindiv
                                               AND porte_adhesion.transmis = 2
                                               AND porte_adhesion.mouvement != 'A');

                      ELSE
                        Update  porte_adhesion
                        Set  fin = t_adhesion(j).datper,
                        type = loc_type
                        Where  idporte in ( SELECT porte_adhesion.idporte
                                                FROM porte_adhesion,noemie
                                               WHERE porte_adhesion.numporte = loc_type_porte
                                                 AND porte_adhesion.idadhesion = t_adhesion(j).idadhesion
                                                 AND noemie.idporte=porte_adhesion.idporte
                                                 AND noemie.matorg=NVL(rec_matorg_individu.matorg2,noemie.matorg)
                                                 AND porte_adhesion.numindiv = t_adhesion(j).numindiv
                                                 AND porte_adhesion.transmis = 2
                                                 AND porte_adhesion.mouvement != 'A');


                      END IF;
                    END IF;
                  END LOOP;

               -- ELSE
                -- Mettre a jour la date de fin si fermeture de garantie rang 2
                END IF;
              END IF;
            -- M0005013 remplace loc_transmis = 1 par loc_transmis IN ( 1, 7, 8)
            ELSIF loc_transmis IN ( 1, 7, 8) THEN
            -- ELSIF (loc_transmis = 1) THEN


              IF (loc_type_porte) = 1 THEN

                IF cpt_adhe = 0 AND t_adhesion(j).datper IS NOT NULL THEN

                  FOR rec_matorg_individu IN C_matorg_individu (t_adhesion(j).numindiv) LOOP
                    ins_porte_annul ( loc_numporte(i), t_adhesion(j).idadhesion, t_adhesion(j).numindiv,
                    loc_type, 'M', t_adhesion(j).datper ,rec_matorg_individu.matorg);
                    IF trim(rec_matorg_individu.matorg2) is not null THEN
                      ins_porte_annul ( loc_numporte(i), t_adhesion(j).idadhesion, t_adhesion(j).numindiv,
                      loc_type, 'M', t_adhesion(j).datper ,rec_matorg_individu.matorg2);
                    END IF;

                  END LOOP;

                END IF;

              ELSIF (loc_type_porte in (2,4)) THEN

                UPDATE  porte_adhesion SET  fin = t_adhesion(j).datper,
                TYPE = loc_type WHERE  idporte = loc_last_idporte AND  fin IS NULL;
              END IF;
            END IF;



            /*TP par bénéficiaire ABO 07/08/2014 résiliation en cours d'année => nouveau mouvement ne doit pas être dans boucle de matorg*/
            IF loc_type_porte in (4) AND t_adhesion(j).datper IS NOT NULL AND cpt_adhe=0 THEN
            -- M0005013 remplace loc_transmis = 1 par loc_transmis IN ( 1, 7, 8)
              IF loc_transmis IN ( 1, 7, 8) THEN
                  --pk_trace.p_ins_journal_adm ('TRG_BF_UPD_ADHESION',sid, 3,' PORTE '||loc_numporte(i)||' numindiv: '||t_adhesion(j).numindiv||' INSERT TP HOSPI ',SYSDATE,4 );

                  pk_porte.p_ins_demande_tp (i_numporte        => loc_numporte(i),
                                             i_idadhesion      => t_adhesion(j).idadhesion,
                                             i_numgar          => t_adhesion(j).numgar,
                                             i_numindiv        => t_adhesion(j).numindiv,
                                             i_debut           => greatest (t_adhesion(j).datapli, AN(t_adhesion(j).datapli)),
                                             i_fin             => NULL,
                                             i_type            => 11, --ou 1 à vérifier
                                             i_numfor          => t_adhesion(j).numfor,
                                             i_fin_ayd         => t_adhesion(j).datper
                                             );
              ELSE

                FOR rec_matorg_individu IN C_matorg_individu (t_adhesion(j).numindiv) LOOP
                  --pk_trace.p_ins_journal_adm ('TRG_BF_UPD_ADHESION',sid, 3,' PORTE '||loc_numporte(i)||' numindiv: '||t_adhesion(j).numindiv||' MAJ TP HOSPI matorg'||rec_matorg_individu.matorg,SYSDATE,4 );
                  UPDATE porte_adhesion
                     SET fin = t_adhesion(j).datper,
                         type = loc_type
                   WHERE  idporte IN ( SELECT porte_adhesion.idporte
                                         FROM porte_adhesion,demande_tp
                                        WHERE porte_adhesion.numporte = loc_numporte(i)
                                          AND porte_adhesion.idadhesion = t_adhesion(j).idadhesion
                                          AND demande_tp.idporte=porte_adhesion.idporte
                                          AND demande_tp.matorg=rec_matorg_individu.matorg
                                          AND porte_adhesion.numindiv = t_adhesion(j).numindiv
                                          AND porte_adhesion.transmis = loc_transmis
                                          AND porte_adhesion.mouvement != 'A'
                                          AND NOT(f_type_porte(numporte) = 4 AND TO_CHAR(debut, 'YYYY') <> TO_CHAR(t_adhesion(j).datper, 'YYYY'))
                                      )
                    AND numindiv =  t_adhesion(j).numindiv;
                    -- pour les types de porte 4 si l'année de début ne correspond pas à l'année de fin => on ne fait rien

                  UPDATE demande_tp_ad
                     SET fin = t_adhesion(j).datper
                   WHERE  idporte IN ( SELECT porte_adhesion.idporte
                                         FROM porte_adhesion,demande_tp
                                        WHERE porte_adhesion.numporte = loc_numporte(i)
                                          AND porte_adhesion.idadhesion = t_adhesion(j).idadhesion
                                          AND demande_tp.idporte=porte_adhesion.idporte
                                          AND demande_tp.matorg=rec_matorg_individu.matorg
                                          AND porte_adhesion.numindiv = t_adhesion(j).numindiv
                                          AND porte_adhesion.transmis = loc_transmis
                                          AND porte_adhesion.mouvement != 'A'
                                          AND NOT(f_type_porte(numporte) = 4 AND TO_CHAR(debut, 'YYYY') <> TO_CHAR(t_adhesion(j).datper, 'YYYY'))
                                      )
                   AND numindiv = t_adhesion(j).numindiv ;
                    -- pour les types de porte 4 si l'année de début ne correspond pas à l'année de fin => on ne fait rien
                END LOOP;
              END IF;

            END IF;

          ELSE
            -- loc_last_idporte = -1 jamais transmis mais forcer un mvt de fin
            -- M0005013_Femerture_des_mvts_NOEMIE_suite_a_resiliation_massives_des_adhesions_contrat_GEREP

            IF (loc_type_porte = 1 AND cpt_adhe = 0 AND t_adhesion(j).datper IS NOT NULL AND loc_numporte(i) = 1 AND loc_type = 12) THEN

              FOR rec_matorg_individu IN C_matorg_individu (t_adhesion(j).numindiv) LOOP

                ins_force_porte_annul ( loc_numporte(i), t_adhesion(j).numgar, t_adhesion(j).idadhesion, t_adhesion(j).numindiv,
                loc_type, 'M', t_adhesion(j).datapli, t_adhesion(j).datper ,rec_matorg_individu.matorg);

                IF trim(rec_matorg_individu.matorg2) is not null THEN

                  ins_force_porte_annul ( loc_numporte(i), t_adhesion(j).numgar, t_adhesion(j).idadhesion, t_adhesion(j).numindiv,
                  loc_type, 'M', t_adhesion(j).datapli, t_adhesion(j).datper ,rec_matorg_individu.matorg2);

                END IF;

              END LOOP;

            END IF;

          END IF;
          /* loc_last_idporte (Si jamais transmis, probleme) */
          i := i +1;
        END LOOP;
      END IF;
    END IF;

    -- en remplacement de TRG_AF_INS_ADHESION
    IF t_action(j) = 'INSERTRANG' OR t_action(j) = 'UPDATERANG' THEN
       /*pk_trace.P_INS_journal_adm('AD01T',0,4,'UPDATING(DATAPLI) AND NOT UPDATING(ETAT)',sysdate);*/
      --
      -- Gestion portes externes
      --
      --  ctt 19/02/08  utilisation de numfor ??? loc_numporte := f_adhesion_externe(pk_qttc.f_sel_numfor(pk_qttc.f_sel_numgar(t_adhesion(j).numgar),t_adhesion(j).numfor), t_adhesion(j).numindiv);
      --SDA M3379
      --si adhesion en instantce a la date de saisie sysdate pas de mouvenent*/
      --f_etat_instance_unique
      --return 1 adhesion en instance sans autre état
      --return 0
      ETAT_ADHE := 0;
      ETAT_ADHE := f_etat_instance_unique(t_adhesion(j).idadhesion);

      IF ETAT_ADHE = 0 THEN
       loc_numporte := f_adhesion_externe(t_adhesion(j).numgar, t_adhesion(j).numindiv);
        i := 1;
        While ( loc_numporte(i) > 0 ) LOOP
        /*pk_trace.P_INS_journal_adm('AD01T',0,4,'UPDATING(DATAPLI) AND NOT UPDATING(ETAT)',sysdate);*/

        /* Recherche type de porte Noemie ou T.P. */

        loc_type_porte := f_type_porte(loc_numporte(i));
        loc_mouvement := 'C';

        /* Verifions si il y a deja des donnees dans porte_adhesion */

        loc_last_idporte := f_last_idporte(loc_numporte(i), t_adhesion(j).numindiv,t_adhesion(j).idadhesion);
        loc_transmis := f_transmis(loc_last_idporte);

        --pk_trace.p_ins_journal_adm ('TRG_AF_INS_ADHESION', sid, 3,'idadhesion '||t_adhesion(j).idadhesion||',porte '||loc_numporte(i)||',numindiv:'||t_adhesion(j).numindiv||',loc_last_idporte:'||loc_last_idporte ,SYSDATE,1 );
        --pk_trace.p_ins_journal_adm ('TRG_AF_INS_ADHESION',sid,3,'idadhesion '||t_adhesion(j).idadhesion||',porte '||loc_numporte(i)||',loc_type_porte:'||loc_type_porte||',loc_transmis:'||loc_transmis||'loc_mouvement'||loc_mouvement,SYSDATE,2 );
        --pk_trace.p_ins_journal_adm ('TRG_AF_INS_ADHESION',sid,3,'idadhesion '||t_adhesion(j).idadhesion||'datper '||to_char(t_adhesion(j).datper,'dd/mm/yyyy'),SYSDATE,3);
        IF (loc_last_idporte != -1) then   /* Il y a deja des donnees */

          /* Verifions s'il s'agit d'une resiliation */
          begin
          Select  type
          Into  loc_type
          From  porte_adhesion
          Where  idporte = loc_last_idporte;
          end;




          if (loc_type = 11) then    /* Il ya eu resiliation */
            if (loc_type_porte = 1) then
            --  loc_transmis := f_transmis(loc_last_idporte);
              if (loc_transmis = 2 or loc_transmis = 6) then
                begin  /* Non transmis on delete */
                Delete  porte_adhesion
                Where  idporte in ( SELECT porte_adhesion.idporte
                                      FROM porte_adhesion,noemie
                                     WHERE porte_adhesion.numporte = loc_numporte(i)
                                       AND porte_adhesion.idadhesion = t_adhesion(j).idadhesion
                                       AND noemie.idporte=porte_adhesion.idporte
                                       AND porte_adhesion.fin is not null
                                       AND porte_adhesion.numindiv = t_adhesion(j).numindiv
                                       AND porte_adhesion.transmis = 2
                                       AND porte_adhesion.mouvement != 'A');
               -- Where  idporte = loc_last_idporte;
                end;
              elsif loc_transmis IN ( 1, 7, 8) then
              /* Deja transmis on transmet une modif
                 ou en cas de rejet ou signalement Noemie */
                loc_last_idporte := -1;
                loc_mouvement := 'M';
              end if;
            elsif (loc_type_porte in (2,4)) then  /* T.P. On update fin */
              begin
              Update porte_adhesion
              Set  fin = t_adhesion(j).datper,
                type = 13
              Where  idporte = loc_last_idporte
               And   fin is null
              ;
              end;
            end if;
          end if;
        END IF;

        IF (loc_last_idporte = -1) then    /* Nouveau -> on insere  une demande */

          begin
          select max(nvl(idporte,0))+1
          into loc_idporte
          from porte_adhesion;
          end;

          If (loc_type_porte = 1) then    /* Noemie */

            ins_noemie (
              loc_numporte(i), t_adhesion(j).numindiv, t_adhesion(j).idadhesion,
              t_adhesion(j).numgar, t_adhesion(j).datapli, t_adhesion(j).datper, loc_mouvement, 1
              );

          Elsif (loc_type_porte in (2,4) and loc_mouvement = 'C' ) then    /* Tiers-payant */
            if ( t_adhesion(j).datper > sysdate or t_adhesion(j).datper is null ) then
              --pk_trace.p_ins_journal_adm ('TRG_AF_INS_ADHESION',sid,3,'idadhesion '||t_adhesion(j).idadhesion||',porte '||loc_numporte(i)||',Création carte',SYSDATE,3 );
              pk_porte.P_INS_demande_tp (
                  I_numporte    => loc_numporte(i),
                  I_idadhesion  => t_adhesion(j).idadhesion,
                  I_numgar    => t_adhesion(j).numgar,
                  I_numindiv    => t_adhesion(j).numindiv,
                  I_debut      => t_adhesion(j).datapli,
                  I_fin      => t_adhesion(j).datper,
                  I_type      => 1,
                  I_numfor    => t_adhesion(j).numfor
                  );
             end if;

          End If;    /* -> loc_type_porte */

        END IF;    /* loc_last_idporte */

        /* Rajout suite . la mise en place du parametrage par garantie */

        If (loc_type_porte in (2,4)) then /* Tiers payant */
        open C_old_idparam_tp(t_adhesion(j).idadhesion);
        fetch C_old_idparam_tp into loc_old_param_tp, loc_old_datper;
        /*open C_new_idparam_tp;
        fetch C_new_idparam_tp into loc_new_param_tp;
        close C_new_idparam_tp;*/
        /*
        insert into control_adhesion
        values (t_adhesion(j).idadhesion, t_adhesion(j).numgar, t_adhesion(j).numfor, t_adhesion(j).numindiv,
          loc_new_param_tp, t_adhesion(j).datapli, t_adhesion(j).datper);
        */
        if C_old_idparam_tp%FOUND then
          --pk_trace.p_ins_journal_adm ('TRG_AF_INS_ADHESION',sid,3,'idadhesion '||t_adhesion(j).idadhesion||',porte '||loc_numporte(i)||',controle adhésion',SYSDATE,2 );
          if (t_adhesion(j).datper > sysdate or t_adhesion(j).datper is null ) then
            if loc_transmis = 2 then    /* Non transmis on delete */
              Delete  porte_adhesion
              Where      idporte = loc_last_idporte;
            end if;

            pk_porte.P_INS_demande_tp (
                  I_numporte  => loc_numporte(i),
                  I_idadhesion  => t_adhesion(j).idadhesion,
                  I_numgar    => t_adhesion(j).numgar,
                  I_numindiv  => t_adhesion(j).numindiv,
                  I_debut    => t_adhesion(j).datapli,
                  I_fin      => t_adhesion(j).datper,
                  I_type    => 1,
                  I_numfor    => t_adhesion(j).numfor
                  );


          end if;
        end if;

        close C_old_idparam_tp;
        end if;
        i := i +1 ;
        End LOOP;
      END IF;

    END IF;
  END LOOP;

END AFTER STATEMENT;
END;