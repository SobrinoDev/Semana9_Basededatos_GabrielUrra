-- =====================================================================
-- PRY2204 - EFT Semana 9 - Caso ANFP
-- Ejecutar conectado como PRY2204_S9
-- =====================================================================

-- ---------------------------------------------------------------------
-- Limpieza (permite re-ejecutar el script sin errores)
-- ---------------------------------------------------------------------
BEGIN
  FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN (
      'JUGADOR_IDIOMA','HISTORIAL_CLUB','JUGADOR','PERSONAL_PLANTA','TRABAJADOR',
      'IDIOMA','ESCUELA_FUTBOL','CLUB_FUTBOL','ASOCIACION','NACIONALIDAD','COMUNA','REGION'))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
  FOR s IN (SELECT sequence_name FROM user_sequences WHERE sequence_name = 'SEQ_CLUB_FUTBOL') LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
  END LOOP;
END;
/

-- FASE 3: CREACION DE TABLAS (orden de dependencia)

CREATE SEQUENCE seq_club_futbol START WITH 703 INCREMENT BY 4 NOCACHE;

-- ---------- Tablas sin claves foraneas ----------
CREATE TABLE region (
  id_region  NUMBER(2)     CONSTRAINT region_pk PRIMARY KEY,
  nombre     VARCHAR2(50)  CONSTRAINT region_nombre_nn NOT NULL
);

CREATE TABLE nacionalidad (
  id_nacion    NUMBER(3) GENERATED ALWAYS AS IDENTITY (START WITH 210 INCREMENT BY 2)
               CONSTRAINT nacionalidad_pk PRIMARY KEY,
  descripcion  VARCHAR2(30) CONSTRAINT nacionalidad_desc_nn NOT NULL
               CONSTRAINT nacionalidad_desc_un UNIQUE
);

CREATE TABLE asociacion (
  id_asociacion      NUMBER(3)     CONSTRAINT asociacion_pk PRIMARY KEY,
  nombre_asociacion  VARCHAR2(60)  CONSTRAINT asociacion_nombre_nn NOT NULL,
  fecha_creacion     DATE          CONSTRAINT asociacion_fecha_nn NOT NULL,
  tipo_asociacion    CHAR(1)       DEFAULT 'P' CONSTRAINT asociacion_tipo_nn NOT NULL,
  CONSTRAINT asociacion_fecha_ck CHECK (fecha_creacion >= DATE '1980-12-31'),
  CONSTRAINT asociacion_tipo_ck  CHECK (tipo_asociacion IN ('P','A'))  

CREATE TABLE club_futbol (
  id_club          NUMBER(4)     DEFAULT seq_club_futbol.NEXTVAL CONSTRAINT club_futbol_pk PRIMARY KEY,
  nombre_club      VARCHAR2(50)  CONSTRAINT club_futbol_nombre_nn NOT NULL
                                 CONSTRAINT club_futbol_nombre_un UNIQUE,
  patrimonio       NUMBER(14)    DEFAULT 0 CONSTRAINT club_futbol_patrimonio_nn NOT NULL,
  ubicacion_calle  VARCHAR2(80)  CONSTRAINT club_futbol_calle_nn NOT NULL,
  tipo_club        VARCHAR2(15)  DEFAULT 'Profesional' CONSTRAINT club_futbol_tipo_nn NOT NULL,
  CONSTRAINT club_futbol_patrimonio_ck CHECK (patrimonio >= 0),
  CONSTRAINT club_futbol_tipo_ck CHECK (tipo_club IN ('Profesional','Amateur'))
);

CREATE TABLE escuela_futbol (
  id_escuela       VARCHAR2(10)  CONSTRAINT escuela_futbol_pk PRIMARY KEY,
  nombre_escuela   VARCHAR2(50)  CONSTRAINT escuela_futbol_nombre_nn NOT NULL,
  capacidad        NUMBER(5)     CONSTRAINT escuela_futbol_cap_nn NOT NULL,
  fecha_fundacion  DATE          CONSTRAINT escuela_futbol_fecha_nn NOT NULL,
  CONSTRAINT escuela_futbol_cap_ck CHECK (capacidad > 0)
);

CREATE TABLE idioma (
  id_idioma      NUMBER(3)     CONSTRAINT idioma_pk PRIMARY KEY,
  nombre_idioma  VARCHAR2(30)  CONSTRAINT idioma_nombre_nn NOT NULL
                               CONSTRAINT idioma_nombre_un UNIQUE
);

-- Tablas con claves foraneas 
CREATE TABLE comuna (
  id_comuna  NUMBER(4)     CONSTRAINT comuna_pk PRIMARY KEY,
  id_region  NUMBER(2)     CONSTRAINT comuna_region_nn NOT NULL,
  nombre     VARCHAR2(50)  CONSTRAINT comuna_nombre_nn NOT NULL,
  CONSTRAINT comuna_region_fk FOREIGN KEY (id_region) REFERENCES region (id_region)
);

CREATE TABLE trabajador (
  nro_inscripcion   NUMBER(9)     CONSTRAINT trabajador_pk PRIMARY KEY,
  rut               NUMBER(8)     CONSTRAINT trabajador_rut_nn NOT NULL,
  dv                CHAR(1)       CONSTRAINT trabajador_dv_nn NOT NULL,
  nombres           VARCHAR2(40)  CONSTRAINT trabajador_nombres_nn NOT NULL,
  apellido_paterno  VARCHAR2(25)  CONSTRAINT trabajador_appat_nn NOT NULL,
  apellido_materno  VARCHAR2(25),
  sueldo_base       NUMBER(10)    CONSTRAINT trabajador_sueldo_nn NOT NULL,
  fecha_nacimiento  DATE          CONSTRAINT trabajador_fnac_nn NOT NULL,
  genero            CHAR(1)       CONSTRAINT trabajador_genero_nn NOT NULL,
  estado_civil      VARCHAR2(15)  CONSTRAINT trabajador_ecivil_nn NOT NULL,
  email             VARCHAR2(60),
  fono_movil        VARCHAR2(15)  CONSTRAINT trabajador_fono_nn NOT NULL,
  direccion         VARCHAR2(80)  CONSTRAINT trabajador_direccion_nn NOT NULL,
  id_comuna         NUMBER(4)     CONSTRAINT trabajador_comuna_nn NOT NULL,
  id_nacion         NUMBER(3)     CONSTRAINT trabajador_nacion_nn NOT NULL,
  tipo_trabajador   CHAR(1)       CONSTRAINT trabajador_tipo_nn NOT NULL,  
  CONSTRAINT trabajador_rut_un      UNIQUE (rut),
  CONSTRAINT trabajador_email_un    UNIQUE (email),
  CONSTRAINT trabajador_dv_ck       CHECK (dv IN ('0','1','2','3','4','5','6','7','8','9','K')),
  CONSTRAINT trabajador_sueldo_ck   CHECK (sueldo_base > 0),
  CONSTRAINT trabajador_genero_ck   CHECK (genero IN ('M','F','O')),
  CONSTRAINT trabajador_ecivil_ck   CHECK (estado_civil IN ('Soltero','Casado','Divorciado','Viudo','Conviviente')),
  CONSTRAINT trabajador_tipo_ck     CHECK (tipo_trabajador IN ('J','P')),
  CONSTRAINT trabajador_comuna_fk   FOREIGN KEY (id_comuna) REFERENCES comuna (id_comuna),
  CONSTRAINT trabajador_nacion_fk   FOREIGN KEY (id_nacion) REFERENCES nacionalidad (id_nacion)
);

CREATE TABLE jugador (
  nro_inscripcion     NUMBER(9)     CONSTRAINT jugador_pk PRIMARY KEY,
  puesto              VARCHAR2(20)  CONSTRAINT jugador_puesto_nn NOT NULL,
  monto_premios       NUMBER(12)    DEFAULT 0 CONSTRAINT jugador_premios_nn NOT NULL,
  id_asociacion       NUMBER(3)     CONSTRAINT jugador_asociacion_nn NOT NULL,
  id_escuela          VARCHAR2(10),            
  anio_fin_amateur    NUMBER(4),              
  CONSTRAINT jugador_puesto_ck     CHECK (puesto IN ('Arquero','Defensa','Mediocampista','Delantero')),
  CONSTRAINT jugador_premios_ck    CHECK (monto_premios >= 0),
  CONSTRAINT jugador_anio_ck       CHECK (anio_fin_amateur BETWEEN 1900 AND 2100),
  CONSTRAINT jugador_trabajador_fk FOREIGN KEY (nro_inscripcion) REFERENCES trabajador (nro_inscripcion),
  CONSTRAINT jugador_asociacion_fk FOREIGN KEY (id_asociacion)   REFERENCES asociacion (id_asociacion),
  CONSTRAINT jugador_escuela_fk    FOREIGN KEY (id_escuela)      REFERENCES escuela_futbol (id_escuela)
);

CREATE TABLE personal_planta (
  nro_inscripcion   NUMBER(9)  CONSTRAINT personal_planta_pk PRIMARY KEY,
  horas_trabajadas  NUMBER(4),     
  valor_hora_extra  NUMBER(8),     
  CONSTRAINT personal_planta_horas_ck CHECK (horas_trabajadas >= 0),
  CONSTRAINT personal_planta_valor_ck CHECK (valor_hora_extra >= 0),
  CONSTRAINT personal_planta_trab_fk  FOREIGN KEY (nro_inscripcion) REFERENCES trabajador (nro_inscripcion)
);

-- Historia de clubes del jugador (un club a la vez, varios en el tiempo)
CREATE TABLE historial_club (
  nro_inscripcion  NUMBER(9)  CONSTRAINT historial_club_jug_nn NOT NULL,
  id_club          NUMBER(4)  CONSTRAINT historial_club_club_nn NOT NULL,
  fecha_inicio     DATE       CONSTRAINT historial_club_fini_nn NOT NULL,
  fecha_termino    DATE,     
  CONSTRAINT historial_club_pk       PRIMARY KEY (nro_inscripcion, id_club, fecha_inicio),
  CONSTRAINT historial_club_fechas_ck CHECK (fecha_termino IS NULL OR fecha_termino > fecha_inicio),
  CONSTRAINT historial_club_jug_fk   FOREIGN KEY (nro_inscripcion) REFERENCES jugador (nro_inscripcion),
  CONSTRAINT historial_club_club_fk  FOREIGN KEY (id_club)         REFERENCES club_futbol (id_club)
);

-- Idiomas que domina cada jugador (N:M con atributo nivel)
CREATE TABLE jugador_idioma (
  nro_inscripcion  NUMBER(9)     CONSTRAINT jugador_idioma_jug_nn NOT NULL,
  id_idioma        NUMBER(3)     CONSTRAINT jugador_idioma_idi_nn NOT NULL,
  nivel_dominio    VARCHAR2(10)  CONSTRAINT jugador_idioma_nivel_nn NOT NULL,
  CONSTRAINT jugador_idioma_pk       PRIMARY KEY (nro_inscripcion, id_idioma),
  CONSTRAINT jugador_idioma_nivel_ck CHECK (nivel_dominio IN ('Basico','Intermedio','Avanzado','Nativo')),
  CONSTRAINT jugador_idioma_jug_fk   FOREIGN KEY (nro_inscripcion) REFERENCES jugador (nro_inscripcion),
  CONSTRAINT jugador_idioma_idi_fk   FOREIGN KEY (id_idioma)       REFERENCES idioma (id_idioma)
);

-- FASE 3: POBLAMIENTO (REGION, COMUNA, ASOCIACION, NACIONALIDAD, CLUB_FUTBOL)

INSERT INTO region VALUES (1,  'ARICA Y PARINACOTA Y TARAPACA');
INSERT INTO region VALUES (2,  'ANTOFAGASTA');
INSERT INTO region VALUES (3,  'ATACAMA Y COQUIMBO');
INSERT INTO region VALUES (5,  'VALPARAISO');
INSERT INTO region VALUES (8,  'BIOBIO');
INSERT INTO region VALUES (13, 'METROPOLITANA');
INSERT INTO region VALUES (16, 'NUBLE');

-- COMUNA
INSERT INTO comuna VALUES (101, 13, 'Santiago');
INSERT INTO comuna VALUES (102, 5,  'Valparaíso');
INSERT INTO comuna VALUES (103, 8,  'Concepción');
INSERT INTO comuna VALUES (104, 2,  'Antofagasta');
INSERT INTO comuna VALUES (105, 16, 'Chillán');

-- ASOCIACION
INSERT INTO asociacion VALUES (25, 'Asociación de Fútbol de Santiago',            TO_DATE('15-05-2001','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (26, 'Asociación Nacional de Fútbol Amateur',       TO_DATE('10-03-1998','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (27, 'Asociación de Fútbol de Valparaíso',          TO_DATE('21-07-1987','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (28, 'Asociación de Fútbol de Concepción',          TO_DATE('30-11-1995','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (29, 'Asociación de Fútbol de Antofagasta',         TO_DATE('25-06-2003','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (30, 'Asociación de Fútbol de Temuco',              TO_DATE('12-01-2010','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (31, 'Asociación de Fútbol de Rancagua',            TO_DATE('08-09-1999','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (32, 'Asociación de Fútbol de Puerto Montt',        TO_DATE('20-04-2005','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (33, 'Asociación de Fútbol de La Serena',           TO_DATE('14-08-2012','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (34, 'Asociación de Fútbol de Chillán',             TO_DATE('01-12-2018','DD-MM-YYYY'), 'A');

-- NACIONALIDAD (id generado por IDENTITY: 210, 212, 214, 216, 218)
INSERT INTO nacionalidad (descripcion) VALUES ('Chilena');
INSERT INTO nacionalidad (descripcion) VALUES ('Argentina');
INSERT INTO nacionalidad (descripcion) VALUES ('Peruana');
INSERT INTO nacionalidad (descripcion) VALUES ('Boliviana');
INSERT INTO nacionalidad (descripcion) VALUES ('Brasileña');

-- CLUB_FUTBOL (id generado por la secuencia: 703, 707, 711, 715, 719)
INSERT INTO club_futbol (nombre_club, patrimonio, ubicacion_calle, tipo_club) VALUES ('Colo-Colo',              580000000, 'Av. Marathon 5300',                'Profesional');
INSERT INTO club_futbol (nombre_club, patrimonio, ubicacion_calle, tipo_club) VALUES ('Universidad de Chile',   450000000, 'Av. El Parrón 0931',               'Profesional');
INSERT INTO club_futbol (nombre_club, patrimonio, ubicacion_calle, tipo_club) VALUES ('Deportes Antofagasta',   180000000, 'Avenida Angamos 01606',            'Profesional');
INSERT INTO club_futbol (nombre_club, patrimonio, ubicacion_calle, tipo_club) VALUES ('Huachipato',             220000000, 'Avenida Desiderio García 909',     'Profesional');
INSERT INTO club_futbol (nombre_club, patrimonio, ubicacion_calle, tipo_club) VALUES ('Ñublense',               170000000, 'Avenida Pedro Aguirre Cerda 1005', 'Profesional');

COMMIT;

-- FASE 4: RECUPERACION DE DATOS

SELECT 'ID:' || id_asociacion || ' * ' || nombre_asociacion AS "ASOCIACION",
       fecha_creacion                                      AS "CREADA",
       tipo_asociacion                                     AS "TIPO"
FROM   asociacion
WHERE  tipo_asociacion = 'P'
  AND  fecha_creacion >= DATE '2000-01-01'
ORDER  BY fecha_creacion DESC;

SELECT id_club                AS "CLUB",
       nombre_club            AS "NOMBRE CLUB",
       patrimonio             AS "PATRIMONIO EN PESOS",
       patrimonio / 955       AS "PATRIMONIO EN DOLARES"
FROM   club_futbol
WHERE  patrimonio BETWEEN 200000000 AND 500000000
ORDER  BY patrimonio;
