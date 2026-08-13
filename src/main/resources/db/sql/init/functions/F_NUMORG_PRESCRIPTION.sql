CREATE FUNCTION ARTHUS.F_NUMORG_PRESCRIPTION (
   i_numindiv   IN   NUMBER,
   i_datsin     IN   DATE DEFAULT NULL,
   i_datbase    IN   DATE DEFAULT NULL
)
   RETURN NUMBER
AS
/*============================================================================*/
/* FONCTION     : F_NUMORG_PRESCRIPTION.sql                                   */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : DBO                                                         */
/* Création     : 17/08/2008                                                  */
/* Description  : Fonction ramenant le numorg de prescription                 */
/*============================================================================*/
/* Evolution    : Mise en place du cartouche                                  */
/* Auteur       : JBO                                                         */
/* Date         : 14/06/2012                                                  */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/*============================================================================*/
   loc_retour    NUMBER               DEFAULT 0;
   loc_numfor    NUMBER               DEFAULT 0;

   CURSOR fetch_cvrt
   IS
      SELECT   v_cvrt.numfor, v_cvrt.numorg
          FROM v_cvrt
         WHERE v_cvrt.numindiv = i_numindiv
           AND v_cvrt.typfor = 1
           AND i_datsin BETWEEN v_cvrt.datapli AND NVL (v_cvrt.datper,
                                                        i_datsin
                                                       )
      ORDER BY rang;

   loc_cvrt      fetch_cvrt%ROWTYPE;

--
   CURSOR c_orgns ( i_numorg v_cvrt.numorg%TYPE)
   IS
      SELECT prescr
        FROM orgns
       WHERE numorg = i_numorg;

   rec_c_orgns   c_orgns%ROWTYPE;
--
BEGIN
   FOR loc_cvrt IN fetch_cvrt
   LOOP
      IF loc_cvrt.numfor != 0
      THEN
         OPEN c_orgns(loc_cvrt.numorg);

         FETCH c_orgns
          INTO rec_c_orgns;

         IF c_orgns%FOUND
         THEN
            IF ADD_MONTHS (i_datsin, rec_c_orgns.prescr) >= i_datbase
            THEN
               loc_retour := 0;
            ELSE
               loc_retour := 1;
            END IF;
         ELSE                        /* pas de delai de prescription defini */
            loc_retour := 0;
         END IF;
      END IF;

      --
      EXIT;
   --
   END LOOP;

   RETURN loc_retour;
--
END F_NUMORG_PRESCRIPTION;
