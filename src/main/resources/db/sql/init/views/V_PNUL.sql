CREATE FORCE VIEW ARTHUS.V_PNUL AS
SELECT pnul.numcpte, pnul.numchq, pnul.numdecaismt, pnul.numaffec,
          pnul.modpmt, pnul.datpay, pnul.datannul, pnul.motif, pnul.userid,
		  pnul.refpmt,
		  -- TLE - 15/04/2014 - MANTIS 3613
		  --TRANSLATE (util.pseudo, '.', '@') nomid,
		  TRANSLATE (util.INITIALES, '.', '@') nomid,
          decaismt.montant, decaismt.monnaie, decaismt.montant_d,
          decaismt.monnaie_d, vs_compte.numsoc,
          pnul.numcpte || ' ' || pnul.numchq numbanq,
		  -- TLE - 15/04/2014 - MANTIS 3613
          TRANSLATE (vs_compte.numcpte || ' ' || vs_compte.libcompte,-- || ' ' || vs_compte.compte,
                     '.',
                     '@'
                    ) lib_banq,
          TRANSLATE (modpmt.libelle, '.', '@') lib_modpmt,
          TO_CHAR (pnul.datannul, 'dd/mm/yy') datanu,
          TRANSLATE (DECODE (pnul.motif,
										 0, motif.libelle || ' N° ' || pnul.numaffec,
										 1, motif.libelle,
										 motif.libelle || ' N° ' || pnul.numaffec
                            ),
                     '.',
                     '@'
                    ) lib_anu,
		  motif.libelle MOTIF_ANNU,
          decaismt.numbene, f_nom (decaismt.numbene) nombene
     FROM pnul, vs_compte, util, decaismt, libelle motif, libelle modpmt
    WHERE vs_compte.numcpte = pnul.numcpte
      AND decaismt.numdecaismt(+) = pnul.numdecaismt
      AND util.numutil = pnul.userid
      AND motif.mnemo = 'PNUL'
      AND motif.code = pnul.motif
      AND modpmt.mnemo = 'MOPM'
      AND modpmt.code = pnul.modpmt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PNUL FOR ARTHUS.V_PNUL
