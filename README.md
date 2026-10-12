# Semana 9 - Base de Datos: Evaluación Final Transversal (Asociación Nacional de Fútbol Profesional - ANFP)

Evaluación Final Transversal individual desarrollada con Oracle SQL Developer y SQL Developer Data Modeler. A partir de un caso de negocio se diseña un Modelo Entidad-Relación Extendido (notación Barker), se transforma en un Modelo Relacional normalizado, se implementa mediante un script DDL con sus restricciones (PK, FK, UN, CK y valores por defecto), se pueblan las tablas usando IDENTITY y objetos SEQUENCE, y finalmente se recupera información con la sentencia SELECT.

## Contexto de negocio

La ANFP administra las competencias de fútbol profesional en Chile y necesita gestionar la información de jugadores, clubes, entrenadores y demás actores vinculados a los procesos de contratación. Hoy esa información está repartida en planillas independientes, lo que genera duplicidad de datos, inconsistencias y dificultades para su administración. Se diseñó una base de datos relacional normalizada que centraliza la información de los trabajadores de cada club (jugadores y personal de planta), su historial de clubes, los idiomas que dominan, la escuela de fútbol donde se formaron y la asociación a la que pertenecen. El desarrollo se organizó en cuatro fases:

| Fase | Descripción |
|---|---|
| Fase 1 | Diseño del Modelo Entidad-Relación Extendido (MER-E) en notación Barker, con supertipo y subtipos. |
| Fase 2 | Transformación del MER-E a un Modelo Relacional (MR) normalizado con PK y FK simples y compuestas. |
| Fase 3 | Script DDL: creación de tablas en orden de dependencia, restricciones con nombre representativo y poblamiento de REGION, COMUNA, ASOCIACION, NACIONALIDAD y CLUB_FUTBOL. |
| Fase 4 | Recuperación de datos: dos informes sobre asociaciones y patrimonio de los clubes. |

## Contenido del repositorio

| Archivo / carpeta | Descripción |
|---|---|
| `GabrielUrra_Basededatos_Semana9.sql` | Script completo (Fases 3 y 4), listo para ejecutar con F5 en SQL Developer conectado como `PRY2204_S9`. |
| `GabrielUrra_Basededatos_Semana9.dmd` | Diseño del modelo (MER-E y MR) en SQL Developer Data Modeler. |
| `GabrielUrra_Basededatos_Semana9/` | Carpeta de datos del diseño (necesaria para abrir el `.dmd`). |
| `GabrielUrra_Basededatos_Semana9.zip` | Respaldo comprimido del diseño. |
| `GabrielUrra_Basededatos_semana9.pdf` | Documento de entrega con el desarrollo de las fases y los modelos. |

## Entidades identificadas

Se implementaron 12 tablas: REGION, NACIONALIDAD, ASOCIACION, CLUB_FUTBOL, ESCUELA_FUTBOL e IDIOMA como tablas fuertes; COMUNA, que depende de REGION; TRABAJADOR como supertipo que reúne los datos del formulario de inscripción; JUGADOR y PERSONAL_PLANTA como sus subtipos; HISTORIAL_CLUB, que registra el período de permanencia de cada jugador en cada club; y JUGADOR_IDIOMA como entidad asociativa que resuelve la relación N:M entre JUGADOR e IDIOMA.

### REGION

| Atributo | Tipo | Clave |
|---|---|---|
| id_region | NUMBER(2) | PK |
| nombre | VARCHAR2(50) | Obligatorio |

### COMUNA

| Atributo | Tipo | Clave |
|---|---|---|
| id_comuna | NUMBER(4) | PK |
| id_region | NUMBER(2) | FK → REGION |
| nombre | VARCHAR2(50) | Obligatorio |

### NACIONALIDAD

| Atributo | Tipo | Clave |
|---|---|---|
| id_nacion | NUMBER(3) IDENTITY (inicia en 210, incrementa de 2 en 2) | PK |
| descripcion | VARCHAR2(30) | Obligatorio (único) |

### ASOCIACION

| Atributo | Tipo | Clave |
|---|---|---|
| id_asociacion | NUMBER(3) | PK |
| nombre_asociacion | VARCHAR2(60) | Obligatorio |
| fecha_creacion | DATE — CHECK (>= 31/12/1980) | Obligatorio |
| tipo_asociacion | CHAR(1) — CHECK (P, A), DEFAULT 'P' | Obligatorio |

### CLUB_FUTBOL

| Atributo | Tipo | Clave |
|---|---|---|
| id_club | NUMBER(4) — DEFAULT SEQ_CLUB_FUTBOL.NEXTVAL (inicia en 703, incrementa de 4 en 4) | PK |
| nombre_club | VARCHAR2(50) | Obligatorio (único) |
| patrimonio | NUMBER(14) — CHECK (>= 0), DEFAULT 0 | Obligatorio |
| ubicacion_calle | VARCHAR2(80) | Obligatorio |
| tipo_club | VARCHAR2(15) — CHECK (Profesional, Amateur), DEFAULT 'Profesional' | Obligatorio |

### ESCUELA_FUTBOL

| Atributo | Tipo | Clave |
|---|---|---|
| id_escuela | VARCHAR2(10) | PK |
| nombre_escuela | VARCHAR2(50) | Obligatorio |
| capacidad | NUMBER(5) — CHECK (> 0) | Obligatorio |
| fecha_fundacion | DATE | Obligatorio |

### IDIOMA

| Atributo | Tipo | Clave |
|---|---|---|
| id_idioma | NUMBER(3) | PK |
| nombre_idioma | VARCHAR2(30) | Obligatorio (único) |

### TRABAJADOR (supertipo)

| Atributo | Tipo | Clave |
|---|---|---|
| nro_inscripcion | NUMBER(9) | PK |
| rut | NUMBER(8) | Obligatorio (único) |
| dv | CHAR(1) — CHECK (0-9, K) | Obligatorio |
| nombres | VARCHAR2(40) | Obligatorio |
| apellido_paterno | VARCHAR2(25) | Obligatorio |
| apellido_materno | VARCHAR2(25) | Opcional |
| sueldo_base | NUMBER(10) — CHECK (> 0) | Obligatorio |
| fecha_nacimiento | DATE | Obligatorio |
| genero | CHAR(1) — CHECK (M, F, O) | Obligatorio |
| estado_civil | VARCHAR2(15) — CHECK (Soltero, Casado, Divorciado, Viudo, Conviviente) | Obligatorio |
| email | VARCHAR2(60) | Opcional (único) |
| fono_movil | VARCHAR2(15) | Obligatorio |
| direccion | VARCHAR2(80) | Obligatorio |
| id_comuna | NUMBER(4) | FK → COMUNA |
| id_nacion | NUMBER(3) | FK → NACIONALIDAD |
| tipo_trabajador | CHAR(1) — CHECK (J, P) | Obligatorio |

### JUGADOR (subtipo de TRABAJADOR)

| Atributo | Tipo | Clave |
|---|---|---|
| nro_inscripcion | NUMBER(9) | PK / FK → TRABAJADOR |
| puesto | VARCHAR2(20) — CHECK (Arquero, Defensa, Mediocampista, Delantero) | Obligatorio |
| monto_premios | NUMBER(12) — CHECK (>= 0), DEFAULT 0 | Obligatorio |
| id_asociacion | NUMBER(3) | FK → ASOCIACION |
| id_escuela | VARCHAR2(10) | FK → ESCUELA_FUTBOL (opcional) |
| anio_fin_amateur | NUMBER(4) — CHECK (1900-2100) | Opcional |

### PERSONAL_PLANTA (subtipo de TRABAJADOR)

| Atributo | Tipo | Clave |
|---|---|---|
| nro_inscripcion | NUMBER(9) | PK / FK → TRABAJADOR |
| horas_trabajadas | NUMBER(4) — CHECK (>= 0) | Opcional |
| valor_hora_extra | NUMBER(8) — CHECK (>= 0) | Opcional |

### HISTORIAL_CLUB

| Atributo | Tipo | Clave |
|---|---|---|
| nro_inscripcion | NUMBER(9) | PK / FK → JUGADOR |
| id_club | NUMBER(4) | PK / FK → CLUB_FUTBOL |
| fecha_inicio | DATE | PK |
| fecha_termino | DATE — CHECK (> fecha_inicio) | Opcional (NULL = club actual) |

### JUGADOR_IDIOMA (entidad asociativa)

| Atributo | Tipo | Clave |
|---|---|---|
| nro_inscripcion | NUMBER(9) | PK / FK → JUGADOR |
| id_idioma | NUMBER(3) | PK / FK → IDIOMA |
| nivel_dominio | VARCHAR2(10) — CHECK (Basico, Intermedio, Avanzado, Nativo) | Obligatorio |

## Relaciones

- **REGION (1,1) — COMUNA (0,N):** una región puede tener cero o muchas comunas; toda comuna pertenece exactamente a una región.
- **COMUNA (1,1) — TRABAJADOR (0,N):** una comuna puede ser la residencia de cero o muchos trabajadores; todo trabajador reside en exactamente una comuna.
- **NACIONALIDAD (1,1) — TRABAJADOR (0,N):** una nacionalidad puede corresponder a cero o muchos trabajadores; todo trabajador tiene exactamente una nacionalidad.
- **TRABAJADOR (1,1) — JUGADOR / PERSONAL_PLANTA (0,1):** jerarquía de subtipos exclusiva; cada trabajador se clasifica como jugador o personal de planta, y cada subtipo comparte la PK del trabajador.
- **ASOCIACION (1,1) — JUGADOR (0,N):** una asociación gestiona a cero o muchos jugadores; todo jugador pertenece exactamente a una asociación.
- **ESCUELA_FUTBOL (0,1) — JUGADOR (0,N):** una escuela puede haber formado a cero o muchos jugadores; un jugador registra solo su última escuela, o ninguna si no proviene de una.
- **JUGADOR (0,N) — CLUB_FUTBOL (0,N):** relación N:M a lo largo del tiempo, resuelta mediante HISTORIAL_CLUB, que registra el período de permanencia. Un jugador tiene un único club vigente (fecha_termino nula) en un momento determinado.
- **JUGADOR (0,N) — IDIOMA (0,N):** relación N:M resuelta mediante la entidad asociativa JUGADOR_IDIOMA, que además registra el nivel de dominio.

## Fase 3: Restricciones especiales

| Restricción | Tipo | Regla |
|---|---|---|
| — | IDENTITY | La PK de NACIONALIDAD se genera automáticamente, inicia en 210 e incrementa de 2 en 2. |
| SEQ_CLUB_FUTBOL | SEQUENCE | El código de CLUB_FUTBOL inicia en 703 e incrementa de 4 en 4 (usado como DEFAULT de la columna). |
| CLUB_FUTBOL_NOMBRE_UN | UNIQUE | El nombre del club no se puede repetir. |
| ASOCIACION_FECHA_CK | CHECK | La fecha de creación debe ser igual o posterior al 31/12/1980. |
| ASOCIACION_TIPO_CK | CHECK | El tipo de asociación debe ser P (profesional) o A (amateur). |
| TRABAJADOR_RUT_UN | UNIQUE | El RUT de un trabajador no se puede repetir. |
| TRABAJADOR_DV_CK | CHECK | El dígito verificador debe ser 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 o 'K'. |
| HISTORIAL_CLUB_FECHAS_CK | CHECK | La fecha de término debe ser posterior a la fecha de inicio. |

## Fase 3: Poblamiento

El script respeta el orden de dependencia (de las tablas fuertes a las más débiles):

- **REGION** — regiones 1, 2, 3, 5, 8, 13 y 16.
- **COMUNA** — comunas 101 (Santiago), 102 (Valparaíso), 103 (Concepción), 104 (Antofagasta) y 105 (Chillán).
- **ASOCIACION** — asociaciones 25 a 34, profesionales y amateurs.
- **NACIONALIDAD** — IDENTITY genera 210 (Chilena), 212 (Argentina), 214 (Peruana), 216 (Boliviana) y 218 (Brasileña).
- **CLUB_FUTBOL** — SEQ_CLUB_FUTBOL genera 703 (Colo-Colo), 707 (Universidad de Chile), 711 (Deportes Antofagasta), 715 (Huachipato) y 719 (Ñublense).

## Fase 4: Informes

### Informe 1 — Registro de asociaciones de fútbol

Lista las asociaciones profesionales (`tipo_asociacion = 'P'`) creadas desde el año 2000, mostrando el identificador concatenado con el nombre (`'ID:' || id_asociacion || ' * ' || nombre_asociacion`), la fecha de creación y el tipo. Se ordena por fecha de creación descendente.

### Informe 2 — Patrimonio de clubes de fútbol

Lista los clubes con patrimonio entre $200.000.000 y $500.000.000, mostrando su código, nombre, patrimonio en pesos y su conversión a dólares (`patrimonio / 955`). Se ordena por patrimonio ascendente.

## Consideraciones de diseño

- Todas las restricciones tienen un nombre representativo según la tabla y su tipo (`_PK`, `_FK`, `_UN`, `_CK`, `_NN`).
- Se agregaron las regiones 8 (Biobío) y 16 (Ñuble), ya que las comunas de Concepción y Chillán las referencian; sin ellas el poblamiento produciría errores de integridad referencial.
- Los datos de escuela de fútbol en JUGADOR (`id_escuela`, `anio_fin_amateur`) son opcionales, porque un jugador puede no provenir de una escuela.
- Las horas trabajadas y el valor de las horas extras de PERSONAL_PLANTA son opcionales, ya que se registran solo cuando corresponde.
- El historial de clubes usa `fecha_inicio` como parte de la PK, lo que permite que un jugador vuelva a un mismo club en otro período.
- El script comienza con un bloque PL/SQL que elimina las tablas y la secuencia si ya existen, lo que permite ejecutarlo varias veces sin errores.
