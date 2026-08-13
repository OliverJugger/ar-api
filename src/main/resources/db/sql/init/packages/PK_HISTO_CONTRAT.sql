CREATE OR REPLACE PACKAGE ARTHUS.PK_HISTO_CONTRAT
AS

/*============================================================================*/
/* PACKAGE      : PK_HISTO_CONTRAT.sql                                        */
/* Domaine      : Historisation du contrat                                    */
/* Version      :                                                             */
/* Auteur       :                                                             */
/* CrÃ©ation     : 25/10/2011                                                  */
/* Description  : gestion de la personne                                      */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/*============================================================================*/
/*   SDA  25/10/2011                                                          */
/*   mise en place cartouche + mise au norme nomenclature pk                  */
/*   ajout des functions lot 2 - commisionnement unique                       */
/*   F_INSERT_HISTO_CONTRAT                                                   */
/*   PHA 06/02/2017 modification f_sel_etat pour qu'Ã  la date de rÃ©siliation, */
/*                 l'Ã©tat ne soit pas 3 pour calcul santÃ© MANTIS 0003802      */
/*============================================================================*/


--
PROCEDURE p_sel_etat_motif (
  i_numgar   IN       histo_contrat.numgar%TYPE,
  io_debut   IN OUT   histo_contrat.debut%TYPE,
  o_etat     OUT      histo_contrat.etat%TYPE,
  o_motif    OUT      histo_contrat.motif%TYPE
);

--
--
FUNCTION f_sel_etat (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (f_sel_etat, WNDS, WNPS);

--
--
FUNCTION f_sel_motif (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (f_sel_motif, WNDS, WNPS);

--
--
FUNCTION f_sel_date_resil (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN DATE;

PRAGMA RESTRICT_REFERENCES (f_sel_date_resil, WNDS, WNPS);

--
--
FUNCTION f_sel_date_debut (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN DATE;

PRAGMA RESTRICT_REFERENCES (f_sel_date_debut, WNDS, WNPS);

--
FUNCTION f_sel_date_effet (i_numgar IN histo_contrat.numgar%TYPE)
  RETURN DATE;

PRAGMA RESTRICT_REFERENCES (f_sel_date_effet, WNDS, WNPS);

--
--
FUNCTION f_sel_debut_etat (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_etat     IN   histo_contrat.etat%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN DATE;

PRAGMA RESTRICT_REFERENCES (f_sel_debut_etat, WNDS, WNPS);

--
--
FUNCTION f_sel_datsai (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN DATE;

PRAGMA RESTRICT_REFERENCES (f_sel_datsai, WNDS, WNPS);

--
--
FUNCTION F_INSERT_HISTO_CONTRAT (
            i_HISTO_CONTRAT  IN HISTO_CONTRAT%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION F_NUMGAR
RETURN NUMBER;
/*************    ProcÃ©dure servant a mettre a jour un mot de passe portÃ© par le contrat, dans le contexte de l'espace RH et de l'affiliation en ligne (BIA 03/08/2018)
 ****************/
PROCEDURE P_UPDATE_MDP_CNTRT(i_numgar IN contrat.numgar%type, o_pwd OUT VARCHAR2);


PROCEDURE P_UPDATE_MDP_MASSE(
     												 I_Traitement IN FILE_EDITION.BATCHID%TYPE,
						                 I_numgardeb IN NUMBER,
						                 I_numgarfin IN NUMBER,
						                 I_session IN FILE_EDITION.NUMEDIT%TYPE,
						                 I_niv_msg IN NUMBER,
						                 l_err IN NUMBER
     ) ;

  -- M0006541
  FUNCTION F_verif_annul_etat(
    I_numgar IN histo_contrat.numgar%TYPE,
	I_debut  IN histo_contrat.debut%TYPE,
	I_datsai IN histo_contrat.datsai%TYPE,
    I_etat   IN histo_contrat.etat%TYPE
    )
  RETURN NUMBER;
--
----------------------------------------------------------------------------
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_HISTO_CONTRAT
AS

-- M0006541 - renvoi 0 si annulation possible sinon n° message bloquant à afficher
FUNCTION F_verif_annul_etat(
    I_numgar IN histo_contrat.numgar%TYPE,
	I_debut  IN histo_contrat.debut%TYPE,
	I_datsai IN histo_contrat.datsai%TYPE,
    I_etat   IN histo_contrat.etat%TYPE)
RETURN NUMBER
IS
  loc_ctrl number default 0 ;
begin
  -- verification dernier etat
  begin
    select count(*) into loc_ctrl
	from histo_contrat
	where numgar = I_numgar
	and debut >= I_debut
	and datsai >= I_datsai
	and etat != I_etat
	and annul = 'N'
	;
	if loc_ctrl > 0 then
	  return 2379 ;
	end if;
  end;

  -- verification pas le dernier etat
  begin
    select count(*) into loc_ctrl
	from histo_contrat
	where numgar = I_numgar
	and annul = 'N'
	;
	if loc_ctrl = 1 then
	  return 2380 ;
	end if;
  end ;
  return 0 ;
end F_verif_annul_etat;

/*-----------------------------------------------------------------------------*/
/* PROCEDURE                                                                   */
/* Nom          :  p_sel_etat_motif                                            */
/* Type         :                                                              */
/* Description  :  selection du motif et de l'etat d'un contrat                */
/* Entree       :  i_numgar   IN       histo_contrat.numgar%TYPE,              */
/*                 io_debut   IN OUT   histo_contrat.debut%TYPE,               */
/*                                                                             */
/* Sortie       :  io_debut   IN OUT   histo_contrat.debut%TYPE,               */
/*                 o_etat     OUT      histo_contrat.etat%TYPE,                */
/*                 o_motif    OUT      histo_contrat.motif%TYPE                */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

PROCEDURE p_sel_etat_motif (
  i_numgar   IN       histo_contrat.numgar%TYPE,
  io_debut   IN OUT   histo_contrat.debut%TYPE,
  o_etat     OUT      histo_contrat.etat%TYPE,
  o_motif    OUT      histo_contrat.motif%TYPE
)
IS
  CURSOR c_histo_contrat
  IS
     SELECT   debut, etat, motif
         FROM histo_contrat
        WHERE numgar = i_numgar
          AND debut <= NVL (io_debut, debut)
          and annul = 'N' -- MUR M0006541
     ORDER BY debut DESC, datsai DESC;

--
  rec_c_histo_contrat   c_histo_contrat%ROWTYPE;
--
BEGIN
  OPEN c_histo_contrat;

  FETCH c_histo_contrat
   INTO rec_c_histo_contrat;

  CLOSE c_histo_contrat;

  --
  io_debut := rec_c_histo_contrat.debut;
  o_etat := rec_c_histo_contrat.etat;
  o_motif := rec_c_histo_contrat.motif;
--
END;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_sel_etat                                                  */
/* Type         :                                                              */
/* Description  :  retourne l'etat d'un contrat                                */
/* Entree       :  i_numgar   IN   histo_contrat.numgar%TYPE,                  */
/*                 i_debut    IN   DATE DEFAULT SYSDATE                        */
/*                                                                             */
/* Sortie       :  NUMBER                                                      */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_sel_etat (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN NUMBER
IS
  CURSOR c_histo_contrat
   IS
      SELECT etat
          FROM histo_contrat
         WHERE numgar = i_numgar
           AND ((etat > 1 AND debut+1 <= i_debut)
                OR
                (etat < 2 AND debut <= i_debut))
           and annul = 'N' -- MUR M0006541
      ORDER BY debut DESC, datsai DESC;

--
  l_etat   histo_contrat.etat%TYPE;
--
BEGIN
  OPEN c_histo_contrat;

  FETCH c_histo_contrat
   INTO l_etat;

  CLOSE c_histo_contrat;

  RETURN l_etat;
END;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_sel_motif                                                 */
/* Type         :                                                              */
/* Description  :  retourne le motif d'un contrat                              */
/* Entree       :  i_numgar   IN   histo_contrat.numgar%TYPE,                  */
/*                 i_debut    IN   DATE DEFAULT SYSDATE                        */
/*                                                                             */
/* Sortie       :  NUMBER                                                      */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

--
FUNCTION f_sel_motif (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN NUMBER
IS
  CURSOR c_histo_contrat
  IS
     SELECT   motif
         FROM histo_contrat
        WHERE numgar = i_numgar AND debut <= i_debut
        and annul = 'N' -- MUR M0006541
     ORDER BY debut DESC, datsai DESC;

--
  l_motif   histo_contrat.motif%TYPE;
--
BEGIN
  OPEN c_histo_contrat;

  FETCH c_histo_contrat
   INTO l_motif;

  CLOSE c_histo_contrat;

  RETURN l_motif;
END;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_sel_date_resil                                            */
/* Type         :                                                              */
/* Description  :  retourne la date de rÃƒÂ©siliation d'un contrat                */
/* Entree       :  i_numgar   IN   histo_contrat.numgar%TYPE,                  */
/*                 i_debut    IN   DATE DEFAULT SYSDATE                        */
/*                                                                             */
/* Sortie       :  DATE                                                        */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/
--
FUNCTION f_sel_date_resil (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN DATE
IS
  CURSOR c_histo_contrat
  IS
     /* MUR M0006541
     SELECT   debut
         FROM histo_contrat
        WHERE numgar = i_numgar
          AND etat = 3
          AND NOT EXISTS (
                 SELECT 1
                   FROM histo_contrat a
                  WHERE a.numgar = histo_contrat.numgar
                    AND a.debut >= histo_contrat.debut
                    AND a.etat = 1
                    AND a.datsai > histo_contrat.datsai)
     ORDER BY debut DESC, datsai DESC;
     */
     SELECT   debut
          FROM histo_contrat
         WHERE numgar = i_numgar
           AND etat = 3
           AND annul = 'N'
      ORDER BY debut DESC, datsai DESC;

--
  l_debut   histo_contrat.debut%TYPE;
--
BEGIN
  OPEN c_histo_contrat;

  FETCH c_histo_contrat
   INTO l_debut;

  IF (c_histo_contrat%NOTFOUND)
  THEN
-- L_debut:='01-jan-3000';
     l_debut := TRUNC(SYSDATE + 1825);
  END IF;

  CLOSE c_histo_contrat;

  RETURN l_debut;
END;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_sel_date_debut                                            */
/* Type         :                                                              */
/* Description  :  retourne la date de dÃƒÂ©but d'un contrat                      */
/* Entree       :  i_numgar   IN   histo_contrat.numgar%TYPE,                  */
/*                 i_debut    IN   DATE DEFAULT SYSDATE                        */
/*                                                                             */
/* Sortie       :  DATE                                                        */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/
--
FUNCTION f_sel_date_debut (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN DATE
IS
  CURSOR c_histo_contrat
  IS
     SELECT   debut
         FROM histo_contrat
        WHERE numgar = i_numgar AND etat = 1
        and annul = 'N' -- MUR M0006541
     ORDER BY debut ASC;

--
  l_debut   histo_contrat.debut%TYPE;
--
BEGIN
  OPEN c_histo_contrat;

  FETCH c_histo_contrat
   INTO l_debut;

  CLOSE c_histo_contrat;

  RETURN l_debut;
END;

--
/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_sel_date_effet                                            */
/* Type         :                                                              */
/* Description  :  retourne la date d'effet d'un contrat                       */
/* Entree       :  i_numgar   IN   histo_contrat.numgar%TYPE,                  */
/*                                                                             */
/*                                                                             */
/* Sortie       :  DATE                                                        */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/
FUNCTION f_sel_date_effet (i_numgar IN histo_contrat.numgar%TYPE)
  RETURN DATE
IS
  CURSOR c_histo_contrat
  IS
     SELECT   debut
         FROM histo_contrat
        WHERE numgar = i_numgar AND etat IN (0, 1)
        and annul = 'N' -- MUR M0006541
     ORDER BY etat DESC, debut ASC;

--
  l_debut   histo_contrat.debut%TYPE;
--
BEGIN
  OPEN c_histo_contrat;

  FETCH c_histo_contrat
   INTO l_debut;

  CLOSE c_histo_contrat;

  RETURN l_debut;
END;


/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_sel_debut_etat                                            */
/* Type         :                                                              */
/* Description  :  retourne date debut de la situation                         */
/* Entree       :  i_numgar   IN   histo_contrat.numgar%TYPE,                  */
/*                                                                             */
/*                                                                             */
/* Sortie       :  DATE                                                        */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/
FUNCTION f_sel_debut_etat (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_etat     IN   histo_contrat.etat%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN DATE
IS
  CURSOR c_histo_contrat
  IS
     SELECT   debut
         FROM histo_contrat
        WHERE numgar = i_numgar AND etat = i_etat AND debut <= i_debut
        and annul = 'N' -- MUR M0006541
     ORDER BY debut DESC, datsai DESC;

--
  l_debut   histo_contrat.debut%TYPE;
--
BEGIN
  OPEN c_histo_contrat;

  FETCH c_histo_contrat
   INTO l_debut;

  CLOSE c_histo_contrat;

  RETURN l_debut;
END;


/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_sel_datsai                                                */
/* Type         :                                                              */
/* Description  :  retourne date de saisie de l'ÃƒÂ©tat ÃƒÂ  une date                */
/* Entree       :  i_numgar   IN   histo_contrat.numgar%TYPE,                  */
/*                                                                             */
/*                                                                             */
/* Sortie       :  DATE                                                        */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/
FUNCTION f_sel_datsai (
  i_numgar   IN   histo_contrat.numgar%TYPE,
  i_debut    IN   DATE DEFAULT SYSDATE
)
  RETURN DATE
IS
  CURSOR c_histo_contrat
  IS
     SELECT   datsai
         FROM histo_contrat
        WHERE numgar = i_numgar AND debut <= i_debut
        and annul = 'N' -- MUR M0006541
     ORDER BY debut DESC, datsai DESC;

--
  l_debut   histo_contrat.debut%TYPE;
--
BEGIN
  OPEN c_histo_contrat;

  FETCH c_histo_contrat
   INTO l_debut;

  CLOSE c_histo_contrat;

  RETURN l_debut;
END;

/*---------------------------------------------------------------------------  */
/* FONCTION                                                                    */
/* Nom          :  F_INSERT_HISTO_CONTRAT                                      */
/* Type         :                                                              */
/* Description  :  Recoit un flux xml et renvoi un flux xml                    */
/*                                                                             */
/* Entree       :  i_HISTO_CONTRAT  IN HISTO_CONTRAT%ROWTYPE                   */
/*                                                                             */
/* Retour       :  BOOLEAN                                                     */
/*             :                                                               */
/*---------------------------------------------------------------------------  */
FUNCTION F_INSERT_HISTO_CONTRAT (

         i_HISTO_CONTRAT  IN HISTO_CONTRAT%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN


     Insert into HISTO_CONTRAT VALUES i_HISTO_CONTRAT;
     RETURN true;

EXCEPTION
  WHEN OTHERS THEN
       RETURN false;
END F_INSERT_HISTO_CONTRAT;

/*---------------------------------------------------------------------------  */
/* FONCTION                                                                    */
/* Nom          :  F_NUMGAR                                                    */
/* Type         :                                                              */
/* Description  :  Retourne un  numgar pour enregistrement d'un nouveau        */
/*                   contrat dans CONTRAT_REF et  HISTO_CONTRAT                */
/* Entree       :                                                              */
/*                                                                             */
/* Retour       :  NUMBER                                                      */
/*             :                                                               */
/*---------------------------------------------------------------------------  */
FUNCTION F_NUMGAR
RETURN NUMBER
IS
  v_numgar number;
BEGIN

     select max(numgar)+1 into v_numgar from HISTO_CONTRAT;
     RETURN v_numgar;

EXCEPTION
  WHEN OTHERS THEN
       RETURN 0;
END F_NUMGAR;





 /*******************************/


PROCEDURE P_UPDATE_MDP_CNTRT(i_numgar IN contrat.numgar%type, o_pwd OUT VARCHAR2)

IS
loc_id_variable NUMBER;
loc_pwd VARCHAR2(30);
LOC_ENTENDU NUMBER(3);
l_mdp_exists NUMBER :=1;
l_eligible NUMBER;
BEGIN

  SELECT count(1) INTO l_eligible
  FROM CONTRAT_REF
  WHERE numgar = i_numgar
  AND typgar = 1 -- groupe ouvert
  AND TYPE_CONTRAT = 1 -- SantÃƒÂ©
  AND EXISTS (select 1    -- il existe une garantie de base ouverte et valide sur le contrat
              from formule f, gar_cntrt g
              where f.typgar = 1
                  and g.numgar = i_numgar
                   and f.numfor = g.numfor
                  and sysdate between debut and nvl(fin, sysdate)
                  and f.valide = 'O'
                  and obli_bene is not null )   -- composition familiale paramÃƒÂ©trÃƒÂ©e
 AND EXISTS (select 1 FROM PORTE_CONTRAT WHERE numgar = i_numgar and numporte = F_PORTE_EA)   -- porte ouverte sur l'espace assurÃƒÂ© (25 chez gerep)
 AND PORTEFEUILLE not in (9,10,11)    -- dehors les saisonniers
  ;


  loc_id_variable :=  F_FIND_VAR('MDPCNTRT');
   select etendue INTO LOC_ENTENDU
   from def_variable
   where idvariable = loc_id_variable;
  -- fermeture de l'ancien mot de passe

  -- verifier q'un mot de passe existe

 /* SELECT count(1)
    INTO l_mdp_exists
    FROM  val_variable
    WHERE fin IS NULL
    AND CLEF = i_numgar
    AND idvariable = loc_id_variable
    AND etendue = LOC_ENTENDU ;
                               */
    -- gÃƒÂ©nÃƒÂ©ration du  mot de passe en alpha numÃƒÂ©ric
  SELECT dbms_random.string('x', 15)
  INTO  loc_pwd
  FROM DUAL;


  /*
  -- VERSION sans historisation

  MERGE INTO val_variable v
    USING ( USING (
    select 1 from dual
           ) vv

    on(    v.fin IS NULL
            AND v.CLEF = i_numgar
            AND v.idvariable = loc_id_variable
            AND v.etendue =LOC_ENTENDU)
  WHEN MATCHED THEN
     UPDATE val_variable
        SET valeur = loc_pwd
            USERMAJ = F_NUMUTIL,
            DATEMAJ = sysdate
        WHERE fin IS NULL
        AND CLEF = i_numgar
        AND idvariable = loc_id_variable
        AND etendue =LOC_ENTENDU
  WHEN NOT MATCHED THEN
     Insert into VAL_VARIABLE (IDVARIABLE,ETENDUE,CLEF,STATIQUE,DEBUT,FIN,VALIDE,VALEUR,NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
    values (loc_id_variable,LOC_ENTENDU,i_numgar,'O',sysdate,null,'O',loc_pwd,null,f_numutil,sysdate,null,null);
    ;    */

 if l_mdp_exists  =1 THEN

  UPDATE val_variable
  SET FIN = sysdate,
      VALIDE = 'N',
      USERMAJ = F_NUMUTIL,
      DATEMAJ = sysdate
  WHERE fin IS NULL
  AND CLEF = i_numgar
  AND idvariable = loc_id_variable
  AND etendue =LOC_ENTENDU ;
 END IF;
  Insert into VAL_VARIABLE (IDVARIABLE,ETENDUE,CLEF,STATIQUE,DEBUT,FIN,VALIDE,VALEUR,NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
    values (loc_id_variable,LOC_ENTENDU,i_numgar,'O',sysdate,null,'O',loc_pwd,null,f_numutil,sysdate,null,null);

  commit;
 o_pwd := loc_pwd;


END P_UPDATE_MDP_CNTRT;

   /***********************************************************************/
-- Comme son nom l'indique cette procÃƒÂ©dure est appelÃƒÂ©e par la BA21 pour mettre a jour en masse les mots de passe portÃƒÂ©s par les contrats pour l'espace assurÃƒÂ©
PROCEDURE P_UPDATE_MDP_MASSE(
     												 I_Traitement IN FILE_EDITION.BATCHID%TYPE,
						                 I_numgardeb IN NUMBER,
						                 I_numgarfin IN NUMBER,
						                 I_session IN FILE_EDITION.NUMEDIT%TYPE,
						                 I_niv_msg IN NUMBER,
						                 l_err IN NUMBER
     )
  IS
   CURSOR C_CONTRATS_a_UPD (p_numgardeb NUMBER,p_numgarfin NUMBER) IS
     SELECT numgar
     from contrat_ref
     where numgar between p_numgardeb and nvl(p_numgarfin, p_numgardeb)
     --AND NUMCLI = NUMQUERABLE
     and exists (
              select distinct 1
              FROM PORTE_contrat p
              WHERE p.numgar = contrat_ref.numgar
              AND numporte = F_PORTE_EA )
         ;
   l_pwd VARCHAR2(500);
   l_ligne number   := 2;
 BEGIN

 FOR r_contrat_to_upd IN  C_CONTRATS_a_UPD (i_numgardeb ,i_numgarfin )    LOOP
       BEGIN
        l_pwd := null;
       	PK_TRACE.P_ins_journal_adm (
                 I_nom_traitement => I_Traitement,I_session=> I_Session,I_niv_msg => 1,
                 I_msg_adm => 'Mise a jour du contrat '||r_contrat_to_upd.numgar ,
                 I_date => Sysdate, I_idligne        => l_ligne
                 );
        l_ligne:=l_ligne+1;
        P_UPDATE_MDP_CNTRT(r_contrat_to_upd.numgar, l_pwd) ;

      	PK_TRACE.P_ins_journal_adm (
             I_nom_traitement => I_Traitement,
             I_session        => I_Session,
             I_niv_msg        => 1,
             I_msg_adm        => 'Nouveau mot de passe = '||l_pwd ,
             I_date           => Sysdate,
             I_idligne        => l_ligne
             );
        l_ligne:=l_ligne+1;
     EXCEPTION
     WHEN OTHERS THEN
      PK_TRACE.P_ins_journal_adm (
             I_nom_traitement => I_Traitement,
             I_session        => I_Session,
             I_niv_msg        => 1,
             I_msg_adm        => 'Erreur  = '||SQLERRM,
             I_date           => Sysdate,
             I_idligne        => l_ligne
             );
       l_ligne:=l_ligne+1;
  END;
END LOOP;

 END P_UPDATE_MDP_MASSE;

END pk_histo_contrat;
/
