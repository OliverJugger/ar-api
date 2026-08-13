CREATE FUNCTION ARTHUS.F_PORTE_EA RETURN NUMBER
IS
o_porte number;
BEGIN

-- retour le code de la porte sépécifique a l'espace assuré
  SELECT code
    INTO o_porte
    FROM libelle
    WHERE libelle = 'Extranet' and mnemo ='RESEAU';

RETURN o_porte;
  EXCEPTION WHEN OTHERS THEN RETURN NULL;
END F_PORTE_EA;
