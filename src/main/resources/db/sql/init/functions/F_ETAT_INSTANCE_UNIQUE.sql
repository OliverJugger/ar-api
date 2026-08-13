CREATE FUNCTION ARTHUS.F_ETAT_INSTANCE_UNIQUE (
   a_idadhesion   IN   NUMBER
)RETURN NUMBER
AS
  loc_retour NUMBER DEFAULT 0;
  cpt_histo_instance NUMBER DEFAULT 0;
  cpt_histo_total NUMBER DEFAULT 0;
BEGIN

loc_retour := 0;
cpt_histo_instance := 0;
cpt_histo_total := 0;

SELECT COUNT(etat)
INTO cpt_histo_instance
FROM HISTO_ADHESION
WHERE ETAT = 0
AND IDADHESION = a_idadhesion;

SELECT COUNT( distinct etat)
INTO cpt_histo_total
FROM HISTO_ADHESION
WHERE IDADHESION = a_idadhesion;

IF cpt_histo_instance = 1 AND cpt_histo_total = 1 THEN
    loc_retour := 1;
ELSE
    loc_retour := 0;
END IF;

RETURN loc_retour;

EXCEPTION
  WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_ETAT_INSTANCE_UNIQUE',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => substr(sqlerrm,1,132),
        I_idligne  => 1);
        RETURN 1;

END F_ETAT_INSTANCE_UNIQUE;
