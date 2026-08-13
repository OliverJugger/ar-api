CREATE FUNCTION ARTHUS.F_TEST_POUR_SPPRIMER_CORRES(
                                      i_numcoress        NUMBER,
                                      i_numsinistre      NUMBER,
                                      i_natcorrespondant NUMBER)
  RETURN NUMBER
IS
  o_testdestinataire       NUMBER:=1;
  v_Quantite_interlocuteur NUMBER:=0;
  -- va contenir le nombre d'itÃ©ration du correspondant
  v_exist_piece            NUMBER:=0;
  v_exist_courrier         NUMBER:=0;


BEGIN
   --premierement on regarde si il n'y a pas de doublons sur le correspondant
  SELECT COUNT(numcorres)
  INTO v_Quantite_interlocuteur
  FROM correspondant
  WHERE entite  = i_numsinistre
  AND nat_corres= i_natcorrespondant
  ;

  IF v_Quantite_interlocuteur>1 THEN
  -- si on a plus que 1 correspondant pour le type et le sinistre dÃ©ini
    o_testdestinataire      :=0;
    RETURN o_testdestinataire;
  END IF;

  BEGIN
  --ensuite on verifie si aucune piece n'existe pour le  correspondant
    SELECT 1
    INTO v_exist_piece
    FROM dual
    WHERE EXISTS
      (SELECT 1
      FROM v_envoi_dest
      WHERE etendue     = 1
      AND clef          = i_numsinistre
      AND numindiv_dest = i_numcoress
      );
  EXCEPTION
    WHEN No_data_found THEN
      o_testdestinataire := 0;
  END;

  IF v_exist_piece     =1 THEN
    o_testdestinataire:=1;
    RETURN o_testdestinataire;
  END IF;

  BEGIN
  --enfin on verifie qu'il n'y a pas de courrier
    SELECT 1
    INTO v_exist_courrier
    FROM dual
    WHERE EXISTS
      (SELECT 1
      FROM pieces
      WHERE numindiv_dest= i_numcoress
      AND entite         = i_numsinistre
      AND contexte       = 1
      );
  EXCEPTION
  WHEN No_data_found THEN
    o_testdestinataire := 0;
  END;

  IF v_exist_courrier  =1 THEN
    o_testdestinataire:=1;
    RETURN o_testdestinataire;
  END IF;
  RETURN 0;
END;
