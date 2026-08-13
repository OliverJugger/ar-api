CREATE FORCE VIEW ARTHUS.V_HISTO_RIB AS
(SELECT idadhesion , idrib,type ,creation,suppression, u.nom
     FROM histo_rib_adhe h, util u
 WHERE
     h.createur = u.numutil )
UNION
(SELECT idadhesion, idrib, type,creation, suppression, u.nom
    FROM histo_rib_adhe h, util u
WHERE
   h.suppresseur = u.numutil)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_HISTO_RIB FOR ARTHUS.V_HISTO_RIB
