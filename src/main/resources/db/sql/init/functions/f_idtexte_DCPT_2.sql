CREATE function ARTHUS.f_idtexte_DCPT_2  (a_contexte in number,
					      a_numero in number,
					      a_code in number,
					      a_modpmt in number)
RETURN	number
is
L_idtexte number;
BEGIN
begin
SELECT valide_texte.idtexte
INTO L_idtexte
FROM valide_texte, param_texte
WHERE valide_texte.idtexte = param_texte.idtexte
AND   valide_texte.contexte = a_contexte
AND   valide_texte.numero   = a_numero
AND   param_texte.code     = a_code
AND   valide_texte.mod_pmt    = a_modpmt;
Exception When others then L_idtexte:= a_numero;
End;
Return( L_idtexte);
END;
