CREATE PROCEDURE ARTHUS.CHARGE_RELANCE (
  a_cle      IN       NUMBER,
  a_mregl    IN       NUMBER,
  a_idtexte  IN       param_texte.idtexte%TYPE DEFAULT NULL,
  t_donnee   OUT      pk_texte.donnee
)
IS
-- $Rev:: 795                                    $:  Revision du dernier commit
-- $Author:: s.calvez                            $:  Auteur du dernier commit
-- $Date: 2023-09-07 17:31:39 +0200 (jeu., 07 sept. 2023) $:  Date du dernier commit
-- $HeadURL: svn://svn2019/arthus/GEREP/trunk/dbschema/ARTHUS/PROCEDURES/CHARGE_RELANCE.sql $:  Chemin
  loc_dateMED     DATE;
  loc_numrelance  emission.numrelance%TYPE;

BEGIN
  pk_trace.p_ins_journal_adm (i_nom_traitement => 'CHARGE_RELANCE'
                             ,i_session        => sid
                             ,i_niv_msg        => 1
                             ,i_msg_adm        => 'a_cle:'||a_cle||' a_mregl:'||a_mregl||' a_idtexte:' || a_idtexte
                             ,i_idligne        => 1);

  --Gestion de la date de relance connue Ã  passer Ã  F_DATE_RELANCE
  --  on dÃ©termine le niveau de relance traitÃ© Ã  partir de idtexte.
  --  Si le niveau de relance traitÃ© est Mise en demeure (10)
  --  Alors la date de Mise en demeure est sysdate : on la passe F_DATE_RELANCE
  loc_dateMED := NULL;
  BEGIN
    IF   a_idtexte IS NOT NULL
     AND a_idtexte <> 0 THEN
      SELECT pt.nb_rel
      INTO loc_numrelance
      FROM param_texte pt
      WHERE pt.idtexte = a_idtexte;

      IF loc_numrelance = 10 THEN
        loc_dateMED := TRUNC(sysdate);
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      loc_dateMED := NULL;
    WHEN OTHERS THEN
      loc_dateMED := NULL;
  END;


  t_donnee (0)  := TO_CHAR(PK_RELANCE.F_DATE_RELANCE( i_niveau    => 0,
                                                      i_numfact   => a_cle,
                                                      i_numgar    => NULL,       -- facultatif
                                                      i_dateMED   => loc_dateMED -- facultatif
                                                      ),'DD/MM/YYYY'); 
  t_donnee (1)  := TO_CHAR(PK_RELANCE.F_DATE_RELANCE( i_niveau    => 1,
                                                      i_numfact   => a_cle,
                                                      i_numgar    => NULL,
                                                      i_dateMED   => loc_dateMED
                                                      ),'DD/MM/YYYY'); 
  t_donnee (2)  := TO_CHAR(PK_RELANCE.F_DATE_RELANCE( i_niveau    => 2,
                                                      i_numfact   => a_cle,
                                                      i_numgar    => NULL,
                                                      i_dateMED   => loc_dateMED
                                                      ),'DD/MM/YYYY'); 
  t_donnee (10) := TO_CHAR(PK_RELANCE.F_DATE_RELANCE( i_niveau    => 10,
                                                      i_numfact   => a_cle,
                                                      i_numgar    => NULL,
                                                      i_dateMED   => loc_dateMED
                                                      ),'DD/MM/YYYY'); 
  t_donnee (20) := TO_CHAR(PK_RELANCE.F_DATE_RELANCE( i_niveau    => 20,
                                                      i_numfact   => a_cle,
                                                      i_numgar    => NULL,
                                                      i_dateMED   => loc_dateMED
                                                      ),'DD/MM/YYYY'); 
  t_donnee (30) := TO_CHAR(PK_RELANCE.F_DATE_RELANCE( i_niveau    => 30,
                                                      i_numfact   => a_cle,
                                                      i_numgar    => NULL,
                                                      i_dateMED   => loc_dateMED
                                                      ),'DD/MM/YYYY'); 
END;
/
