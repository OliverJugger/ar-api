CREATE FORCE VIEW ARTHUS.V_GS20 AS
SELECT sinistre_sante.num_dossier,
    sinistre_sante.numligne,
    histo_dossier.debut,
    histo_dossier.etat,
    f_lble('ET_DOSSP',histo_dossier.etat) libEtatDoss,
    histo_dossier.motif,
    f_lble('HISTO_D'
    ||histo_dossier.etat,histo_dossier.motif) libMotifDoss,
    sinistre_sante.situation,
    f_lble('ET_DOSSPL',sinistre_sante.situation) libSituLigne,
    sinistre_sante.motif MotifLigne,
    f_lble('HISTO_DL'
    ||sinistre_sante.situation,sinistre_sante.motif) libMotifLigne,
    sinistre_sante.numutil,
    utilisateurs.nom
  FROM sinistre_sante,
    histo_dossier,
    utilisateurs
  WHERE sinistre_sante.num_dossier= histo_dossier.num_dossier
  AND sinistre_sante.numutil      =utilisateurs.numutil
  AND histo_dossier.debut         =
    (SELECT MAX(debut)
    FROM histo_dossier
    WHERE num_dossier=sinistre_sante.num_dossier
    )
  ORDER BY num_dossier,
    numligne
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GS20 FOR ARTHUS.V_GS20
