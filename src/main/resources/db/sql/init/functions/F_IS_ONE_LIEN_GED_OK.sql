CREATE FUNCTION ARTHUS.F_IS_ONE_LIEN_GED_OK(i_idrappel number, i_numporte number default 25) RETURN NUMBER IS
code_retour number :=0;

CURSOR  c_pieces IS -- récupére les id piéces de la demande.
SELECT  clef
  FROM lien_ged
  WHERE ref_ext =i_idrappel
    AND src = i_numporte;
r_pieces c_pieces%rowtype;

CURSOR  c_doc_valide(i_clef number)IS  --verifie qu'au moins un document est valide pour un idpiece donné.
SELECT etat
FROM lien_ged
WHERE clef = i_clef
AND ETAT IN(2);
r_doc_valide c_doc_valide%rowtype;

BEGIN
for r_pieces in c_pieces LOOP
    open c_doc_valide(r_pieces.clef);
    fetch c_doc_valide into r_doc_valide;
    IF c_doc_valide%NOTFOUND THEN
      code_retour := 2217;
    END IF;
    CLOSE c_doc_valide;
END LOOP;

RETURN code_retour;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  return 0;
END F_IS_ONE_LIEN_GED_OK;
