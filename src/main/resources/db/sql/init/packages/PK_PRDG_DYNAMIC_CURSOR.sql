CREATE OR REPLACE PACKAGE ARTHUS.PK_PRDG_DYNAMIC_CURSOR IS
/*===========================================================================*/
/* Package      : PK_PRDG_DYNAMIC_CURSOR.sql                                 */
/* Domaine      : Statistiques et pilotage                                   */
/* Version      : V1.0                                                       */
/* Auteur       : ACA                                                        */
/* Création     : 26/11/2010                                                 */
/* Description  : Package des fonctions spécifiques au projet PRDG.          */
/*              : Permet de contituer différents segments (INT,ENS,...)      */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/

/* ==========================================================================*/
-- TYPES PUBLIQUES
  TYPE TYPE_TAB IS VARRAY (15) OF VARCHAR2(50);

  TYPE T_CLES IS RECORD ( total NUMBER(11,2)
                         ,CLE TYPE_TAB := TYPE_TAB(1,2,3,4,5,6,7,8,9,10)
                         );

-- PROCEDURES ET FONCTIONS PUBLIQUES
  PROCEDURE p_open_dyncur (
          gd_risque  IN     VARCHAR2,
          nom_flux   IN     VARCHAR2,
          num_pr     IN     NUMBER,
          datdeb     IN     DATE,
          datfin     IN     DATE,
          crs        IN OUT INTEGER);

  FUNCTION f_fetch_dyncur (
          crs        IN OUT INTEGER)
        RETURN T_CLES;

  PROCEDURE p_write_rst_dyncur (
          rst        IN T_CLES);

  FUNCTION f_total_flux (
          gd_risque  IN     VARCHAR2,
          nom_flux   IN     VARCHAR2,
          num_pr     IN     NUMBER,
          datdeb     IN     DATE,
          datfin     IN     DATE)
        RETURN NUMBER;

  PROCEDURE testCursor (
          gd_risque  IN     VARCHAR2,
          nom_flux   IN     VARCHAR2,
          num_pr     IN     NUMBER,
          datdeb     IN     DATE,
          datfin     IN     DATE,
          crs        IN OUT INTEGER
          );
/* ========================== Fin des Procedures publiques ==================*/

END PK_PRDG_DYNAMIC_CURSOR;
/

CREATE OR REPLACE package body ARTHUS.PK_PRDG_DYNAMIC_CURSOR as

-- PROCEDURES ET FONCTIONS PRIVEES
  PROCEDURE p_close_dyncur (
          crs        IN OUT INTEGER);
/* ========================== Fin des Procedures privées ====================*/
/*===========================================================================*/

   PROCEDURE p_open_dyncur (
          gd_risque  IN     VARCHAR2,
          nom_flux   IN     VARCHAR2,
          num_pr     IN     NUMBER,
          datdeb     IN     DATE,
          datfin     IN     DATE,
          crs        IN OUT INTEGER
          )
   IS
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  p_open_dyncur                                             */
/* Type         :  Public                                                    */
/* Description  :  Procédure de création d'un curseur de clés de ruptures    */
/*                 en fonction du flux et du preneur de risques passés en    */
/*                 paramètres.                                               */
/* Entree       :  gd_risque, 01:prévoyance 02:santé                         */
/*                 nom_flux, nom du flux PRDG concerné (voir table PRDGFLUX) */
/*                 num_pr, numéro du preneur de risques                      */
/*                 datdeb, début de période concernée                        */
/*                 datfin, fin de période concernée                          */
/*                 crs, référence de curseur                                 */
/* Sortie       :  crs, curseur construit dynamiquement                      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
     stmt VARCHAR2(500);
     ignore INTEGER;
     rst T_CLES;
     format varchar2(10) :='dd/mm/yyyy';
   BEGIN
     -- open cursor on source table
     crs := dbms_sql.open_cursor;

     stmt := 'select sum(MONTANT) total,CLE1,CLE2,CLE3,CLE4,CLE5,CLE6,CLE7,CLE8,CLE9,CLE10'
          || ' from v_prdg_' || nom_flux
          || ' where gd_risque = ' || gd_risque
          || ' and pr = ' || num_pr
          || ' and datope between to_date(''' || to_char(datdeb,format) ||''',''' || format ||''') and to_date(''' || to_char(datfin, format) ||''',''' || format ||''')'
          || ' group by CLE1,CLE2,CLE3,CLE4,CLE5,CLE6,CLE7,CLE8,CLE9,CLE10'
          || ' order by CLE1,CLE2,CLE3,CLE4,CLE5,CLE6,CLE7,CLE8,CLE9,CLE10'
          ;
     dbms_output.put_line(stmt);

     -- parse the statement
     dbms_sql.parse(crs, stmt,dbms_sql.NATIVE);

     -- define the column type
     dbms_sql.define_column(crs, 1, rst.total);
     for i in 1..10 loop
       dbms_sql.define_column(crs, i+1, rst.cle(i), 50);
     end loop;

     ignore := dbms_sql.execute(crs);

     --OPEN crs FOR stmt;
   END p_open_dyncur;
--
/*===========================================================================*/
--
   FUNCTION f_fetch_dyncur (
          crs        IN OUT INTEGER)
        RETURN T_CLES
   IS
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  f_fetch_dyncur                                            */
/* Type         :  Public                                                    */
/* Description  :  Procédure de lecture d'un curseur dynamique               */
/* Entree       :  crs, référence du curseur à lire                          */
/* Sortie       :  crs, référence du curseur lu                              */
/* Retour       :  T_CLES, record contenant les cles de rupture du flux      */
/*---------------------------------------------------------------------------*/
      rst T_CLES;
   BEGIN
      -- Fetch a row from the source table

      IF dbms_sql.fetch_rows(crs) > 0 THEN
        -- get column values of the row
        dbms_sql.column_value(crs, 1, rst.total);
        FOR i in 1..10 loop
          dbms_sql.column_value(crs, i+1, rst.cle(i));
        END LOOP;
        RETURN rst;
      ELSE

        -- No more rows
        --RETURN NULL;
        p_close_dyncur(crs);
        RETURN rst;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
        IF dbms_sql.is_open(crs) THEN
          p_close_dyncur(crs);
          RETURN NULL;
        END IF;

        RAISE;
   END f_fetch_dyncur;
--
/*===========================================================================*/
--
   PROCEDURE p_close_dyncur (
          crs        IN OUT INTEGER)
   IS
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  p_close_dyncur                                            */
/* Type         :  Privé                                                     */
/* Description  :  Procédure de fermeture d'un curseur dynamique             */
/* Entree       :  crs, référence du curseur à fermer                        */
/* Sortie       :  crs, référence du curseur fermé                           */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
   BEGIN
     dbms_sql.close_cursor(crs);
     --CLOSE crs;
   END p_close_dyncur;
--
/*===========================================================================*/
--
  FUNCTION f_total_flux (
          gd_risque  IN     VARCHAR2,
          nom_flux   IN     VARCHAR2,
          num_pr     IN     NUMBER,
          datdeb     IN     DATE,
          datfin     IN     DATE)
        RETURN NUMBER
  IS
/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_total_flux                                              */
/* Type         :  Public                                                    */
/* Description  :  Function qui retourne le montant total des lignes         */
/*                 concernées                                                */
/* Entree       :  gd_risque, 01:prévoyance 02:santé                         */
/*                 nom_flux, nom du flux PRDG concerné (voir table PRDGFLUX) */
/*                 num_pr, numéro du preneur de risques                      */
/*                 datdeb, début de période concernée                        */
/*                 datfin, fin de période concernée                          */
/* Sortie       :                                                            */
/* Retour       :  total, montant total du flux                              */
/*---------------------------------------------------------------------------*/
    TYPE t_crs IS REF CURSOR;
    crs t_crs;
    stmt VARCHAR2(200);
    format varchar2(10) :='dd/mm/yyyy';
    total NUMBER(11,2);
  BEGIN
    stmt := 'SELECT sum(MONTANT) total'
          || ' FROM v_prdg_' || nom_flux
          || ' WHERE gd_risque = ' || gd_risque
          || ' AND pr = ' || num_pr
          || ' AND datope BETWEEN to_date(''' || to_char(datdeb,format) ||''',''' || format ||''') AND to_date(''' || to_char(datfin, format) ||''',''' || format ||''')'
          ;
    OPEN crs FOR stmt;
    LOOP
      FETCH crs INTO total;
      EXIT WHEN crs%NOTFOUND;

      RETURN total;
    END LOOP;

    RETURN 0;
  END f_total_flux;
--
/*===========================================================================*/
--
  PROCEDURE p_write_rst_dyncur (
          rst        IN T_CLES)
  IS
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  p_write_rst_dyncur                                        */
/* Type         :  Public                                                    */
/* Description  :  Procédure d'écriture d'un record T_CLES en sortie SGDB    */
/* Entree       :                                                            */
/* Sortie       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
    strout VARCHAR(100);
  BEGIN
    strout := rst.total;
    FOR i IN 1..10 LOOP
      strout := strout || ' ' || rst.cle(i);
    END LOOP;
    dbms_output.put_line(strout);
  END p_write_rst_dyncur;
--
/*===========================================================================*/
--
   PROCEDURE testCursor (
          gd_risque  IN     VARCHAR2,
          nom_flux   IN     VARCHAR2,
          num_pr     IN     NUMBER,
          datdeb     IN     DATE,
          datfin     IN     DATE,
          crs        IN OUT INTEGER
          )
   IS
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  testCursor                                                */
/* Type         :  Public                                                    */
/* Description  :  Procédure d'exemple d'appel au curseur dynamique          */
/* Entree       :                                                            */
/* Sortie       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
     c_ruptures INTEGER;
     r_ruptures T_CLES;
   BEGIN
     dbms_output.put_line('début testCursor');

     p_open_dyncur(gd_risque,nom_flux,num_pr,datdeb,datfin,c_ruptures);
     r_ruptures := f_fetch_dyncur (c_ruptures);

     WHILE (c_ruptures IS NOT NULL) LOOP
        p_write_rst_dyncur(r_ruptures);
        r_ruptures := f_fetch_dyncur (c_ruptures);
     END LOOP;

     dbms_output.put_line('fin testCursor');
   END testCursor;

END PK_PRDG_DYNAMIC_CURSOR;
/
