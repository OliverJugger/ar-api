CREATE FUNCTION ARTHUS.F_DUPLIQUE_DOSSIER_SANTE( i_num_dossier dossier_sante.num_dossier%type) return NUMBER
IS
l_dossier DOSSIER_SANTE%ROWTYPE;
BEGIN

	SELECT * INTO l_dossier
	FROM dossier_sante
	WHERE num_dossier = i_num_dossier;
	-- rÃ©cuperation de l'identifiant du nouveau dossier
	SELECT PK_CALCUL_DOSSIER.f_num_dossier(sysdate)
	INTO l_dossier.num_dossier
	FROM dual;
	-- modification des information du dossier dupliquÃ©
	SELECT l_dossier.ref_dossier||'-'||(count(*)+1) INTO l_dossier.ref_dossier
		FROM dependance
		WHERE TYPE = 27
		AND numenvers = i_num_dossier;

	l_dossier.numutil := f_numutil();
	l_dossier.creation := sysdate;
	l_dossier.dateouv := sysdate;


	INSERT INTO dossier_sante VALUES l_dossier;

	INSERT INTO dependance(numde, role, numenvers, datapli, datper, type)
			VALUES ( l_dossier.num_dossier, 3,i_num_dossier , sysdate, null, 27);

	COMMIT;
	RETURN l_dossier.num_dossier;

EXCEPTION
WHEN OTHERS THEN
RETURN NULL;

END F_DUPLIQUE_DOSSIER_SANTE;
