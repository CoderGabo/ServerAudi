PGDMP          -                {            avicola    11.2    11.2 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            �           1262    28337    avicola    DATABASE     �   CREATE DATABASE avicola WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Chinese (Simplified)_China.936' LC_CTYPE = 'Chinese (Simplified)_China.936';
    DROP DATABASE avicola;
             postgres    false            �            1255    29688    actualizar_usuario()    FUNCTION       CREATE FUNCTION public.actualizar_usuario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.contraseña <> OLD.contraseña THEN
        NEW.error := 0;
        NEW.hora := NULL;
        NEW.bloqueado := FALSE;
    END IF;
    RETURN NEW;
END;
$$;
 +   DROP FUNCTION public.actualizar_usuario();
       public       postgres    false            �            1255    29689    asignar_lote(integer, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.asignar_lote(galpon_id integer, lote_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    disponible INT;
		lote_cant INT;
BEGIN
    -- Obtener la capacidad disponible del galpón
    SELECT capacidad_libre INTO disponible
    FROM galpon
    WHERE id_galpon = galpon_id;
		
		-- Obtener la cantidad del lote
    SELECT cantidad INTO lote_cant
    FROM lote
    WHERE id_lote = lote_id;

    -- Verificar si el galpón tiene suficiente capacidad
    IF disponible >= lote_cant THEN
        -- Actualizar la capacidad disponible del galpón
        UPDATE galpon
        SET capacidad_libre = disponible - lote_cant
        WHERE id_galpon = galpon_id;

        -- actualizar el lote 
        UPDATE lote 
				SET id_galpon = galpon_id
				WHERE id_lote = lote_id;
    ELSE
        -- Imprimir mensaje de error
        RAISE EXCEPTION 'El galpón no tiene suficiente capacidad para asignar el lote';
    END IF;
END;
$$;
 H   DROP PROCEDURE public.asignar_lote(galpon_id integer, lote_id integer);
       public       postgres    false            �            1255    29690    check_error_trigger()    FUNCTION     �   CREATE FUNCTION public.check_error_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.error = 3 THEN
        NEW.bloqueado = TRUE;
    END IF;
    RETURN NEW;
END;
$$;
 ,   DROP FUNCTION public.check_error_trigger();
       public       postgres    false            �            1255    29691    fn_archivado_lote()    FUNCTION     I  CREATE FUNCTION public.fn_archivado_lote() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	mortalidad INTEGER;
BEGIN
	IF NEW.fecha_salida IS NOT NULL THEN
		-- actualizar el estado de archivado
		UPDATE lote
		SET archivado = true
		WHERE id_lote = NEW.id_lote;
		
		-- mortalidad del lote
		SELECT SUM(cantidad_defuncion) INTO mortalidad
		FROM ambiente
		WHERE id_lote = NEW.id_lote;
		
		-- actualizar capacidad disponible
		UPDATE galpon 
		SET capacidad_libre = capacidad_libre + OLD.cantidad - mortalidad
		WHERE id_galpon = OLD.id_galpon;
	END IF;
	RETURN NEW;
END; $$;
 *   DROP FUNCTION public.fn_archivado_lote();
       public       postgres    false            �            1255    29692    fn_cantidad_libre_galpon()    FUNCTION     �  CREATE FUNCTION public.fn_cantidad_libre_galpon() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	IF OLD.id_galpon IS NOT NULL THEN
		UPDATE galpon 
		SET capacidad_libre = capacidad_libre + OLD.cantidad 
		WHERE id_galpon = OLD.id_galpon;
	ELSE
		UPDATE galpon 
		SET capacidad_libre = capacidad_libre - NEW.cantidad 
		WHERE id_galpon = NEW.id_galpon;
	END IF;
	RETURN NEW;
END; $$;
 1   DROP FUNCTION public.fn_cantidad_libre_galpon();
       public       postgres    false            �            1255    29693    fn_cuarentena_galpon()    FUNCTION       CREATE FUNCTION public.fn_cuarentena_galpon() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF NEW.fecha_salida IS NOT NULL THEN
		-- actualizar el estado de cuarentena
		UPDATE galpon
		SET en_cuar = FALSE
		WHERE id_galpon = NEW.id_galpon;
	END IF;
	RETURN NEW;
END; $$;
 -   DROP FUNCTION public.fn_cuarentena_galpon();
       public       postgres    false            �            1255    29694    fn_cuarentena_galpon_ins()    FUNCTION     �   CREATE FUNCTION public.fn_cuarentena_galpon_ins() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	
		-- actualizar el estado de cuarentena
		UPDATE galpon
		SET en_cuar = TRUE
		WHERE id_galpon = NEW.id_galpon;
	
	RETURN NEW;
END; $$;
 1   DROP FUNCTION public.fn_cuarentena_galpon_ins();
       public       postgres    false            �            1255    29695    fn_defuncion_ambiente()    FUNCTION     �  CREATE FUNCTION public.fn_defuncion_ambiente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	idGalpon INTEGER;
BEGIN
	
		--  galpon donde se encuentra alojado el lote
		SELECT id_galpon INTO idGalpon
		FROM lote
		WHERE id_lote = NEW.id_lote;
		
		IF tg_op = 'INSERT' THEN
		-- actualizar capacidad disponible
			UPDATE galpon 
			SET capacidad_libre = capacidad_libre + NEW.cantidad_defuncion
			WHERE id_galpon = idGalpon;
			
			-- actualizar mortalidad lote
			UPDATE lote 
	SET mortalidad = mortalidad + NEW.cantidad_defuncion 
	WHERE id_lote = NEW.id_lote;
		ELSE
			-- actualizar capacidad disponible
			UPDATE galpon 
			SET capacidad_libre = capacidad_libre - OLD.cantidad_defuncion + NEW.cantidad_defuncion
			WHERE id_galpon = idGalpon;
			
			--actualizar mortalidad lote
			UPDATE lote 
	SET mortalidad = mortalidad - OLD.cantidad_defuncion +  NEW.cantidad_defuncion 
	WHERE id_lote = NEW.id_lote;
	END IF;
	
	RETURN NEW;
END; $$;
 .   DROP FUNCTION public.fn_defuncion_ambiente();
       public       postgres    false            �            1255    29896    fn_incubadora_disp()    FUNCTION     O  CREATE FUNCTION public.fn_incubadora_disp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	IF NEW.finalizado = TRUE THEN
    UPDATE incubadora
		SET disponible = TRUE
		WHERE id_inc = NEW.id_inc;
  ELSE
    UPDATE incubadora
		SET disponible = FALSE
		WHERE id_inc = NEW.id_inc;
  END IF;

	RETURN NEW;
END; $$;
 +   DROP FUNCTION public.fn_incubadora_disp();
       public       postgres    false            �            1259    29913    alimentacion    TABLE     �   CREATE TABLE public.alimentacion (
    id_alim integer NOT NULL,
    fecha date NOT NULL,
    alimento character varying(255) NOT NULL,
    cantidad integer NOT NULL,
    id_galpon integer
);
     DROP TABLE public.alimentacion;
       public         postgres    false            �            1259    29911    alimentacion_id_alim_seq    SEQUENCE     �   CREATE SEQUENCE public.alimentacion_id_alim_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.alimentacion_id_alim_seq;
       public       postgres    false    225            �           0    0    alimentacion_id_alim_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.alimentacion_id_alim_seq OWNED BY public.alimentacion.id_alim;
            public       postgres    false    224            �            1259    29696    ambiente    TABLE     �   CREATE TABLE public.ambiente (
    id_galpon integer NOT NULL,
    fecha timestamp without time zone NOT NULL,
    temperatura real,
    humedad real
);
    DROP TABLE public.ambiente;
       public         postgres    false            �            1259    29699    ave    TABLE     b   CREATE TABLE public.ave (
    id integer NOT NULL,
    especie character varying(255) NOT NULL
);
    DROP TABLE public.ave;
       public         postgres    false            �            1259    29702 
   ave_id_seq    SEQUENCE     �   CREATE SEQUENCE public.ave_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE public.ave_id_seq;
       public       postgres    false    197            �           0    0 
   ave_id_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE public.ave_id_seq OWNED BY public.ave.id;
            public       postgres    false    198            �            1259    29704    bitacora    TABLE     �   CREATE TABLE public.bitacora (
    id_log integer NOT NULL,
    username character varying(255) NOT NULL,
    fecha timestamp without time zone,
    operacion character varying(255)
);
    DROP TABLE public.bitacora;
       public         postgres    false            �            1259    29710    bitacora_id_log_seq    SEQUENCE     �   CREATE SEQUENCE public.bitacora_id_log_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.bitacora_id_log_seq;
       public       postgres    false    199            �           0    0    bitacora_id_log_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.bitacora_id_log_seq OWNED BY public.bitacora.id_log;
            public       postgres    false    200            �            1259    29712 
   cuarentena    TABLE     �   CREATE TABLE public.cuarentena (
    id_cuar integer NOT NULL,
    fecha_ingreso date NOT NULL,
    fecha_salida date,
    razon character varying(255) NOT NULL,
    id_galpon integer NOT NULL
);
    DROP TABLE public.cuarentena;
       public         postgres    false            �            1259    29715    cuarentena_id_cuar_seq    SEQUENCE     �   CREATE SEQUENCE public.cuarentena_id_cuar_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.cuarentena_id_cuar_seq;
       public       postgres    false    201            �           0    0    cuarentena_id_cuar_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.cuarentena_id_cuar_seq OWNED BY public.cuarentena.id_cuar;
            public       postgres    false    202            �            1259    29824 
   enfermedad    TABLE     ~   CREATE TABLE public.enfermedad (
    id_enf integer NOT NULL,
    nombre character varying(255) NOT NULL,
    sintoma text
);
    DROP TABLE public.enfermedad;
       public         postgres    false            �            1259    29822    enfermedad_id_enf_seq    SEQUENCE     �   CREATE SEQUENCE public.enfermedad_id_enf_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.enfermedad_id_enf_seq;
       public       postgres    false    217            �           0    0    enfermedad_id_enf_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.enfermedad_id_enf_seq OWNED BY public.enfermedad.id_enf;
            public       postgres    false    216            �            1259    29717    galpon    TABLE     �   CREATE TABLE public.galpon (
    id_galpon integer NOT NULL,
    dimension character varying(50) NOT NULL,
    capacidad integer NOT NULL,
    capacidad_libre integer,
    en_cuar boolean DEFAULT false
);
    DROP TABLE public.galpon;
       public         postgres    false            �            1259    29721    galpon_id_galpon_seq    SEQUENCE     �   CREATE SEQUENCE public.galpon_id_galpon_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.galpon_id_galpon_seq;
       public       postgres    false    203            �           0    0    galpon_id_galpon_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.galpon_id_galpon_seq OWNED BY public.galpon.id_galpon;
            public       postgres    false    204            �            1259    29723    galpon_vacuna    TABLE     �   CREATE TABLE public.galpon_vacuna (
    id integer NOT NULL,
    id_galpon integer NOT NULL,
    id_vac integer NOT NULL,
    fecha date NOT NULL
);
 !   DROP TABLE public.galpon_vacuna;
       public         postgres    false            �            1259    29726    galpon_vacuna_id_seq    SEQUENCE     �   CREATE SEQUENCE public.galpon_vacuna_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.galpon_vacuna_id_seq;
       public       postgres    false    205            �           0    0    galpon_vacuna_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.galpon_vacuna_id_seq OWNED BY public.galpon_vacuna.id;
            public       postgres    false    206            �            1259    29885    huevo    TABLE     �   CREATE TABLE public.huevo (
    id_huevo integer NOT NULL,
    fec_coleccion date,
    bueno integer,
    podrido integer,
    id_lote integer
);
    DROP TABLE public.huevo;
       public         postgres    false            �            1259    29883    huevo_id_huevo_seq    SEQUENCE     �   CREATE SEQUENCE public.huevo_id_huevo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.huevo_id_huevo_seq;
       public       postgres    false    223            �           0    0    huevo_id_huevo_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.huevo_id_huevo_seq OWNED BY public.huevo.id_huevo;
            public       postgres    false    222            �            1259    29858 
   incubacion    TABLE       CREATE TABLE public.incubacion (
    id_incub integer NOT NULL,
    inicio timestamp without time zone,
    finalizacion timestamp without time zone,
    nro_huevos integer,
    nro_eclosionado integer,
    finalizado boolean DEFAULT false,
    id_inc integer
);
    DROP TABLE public.incubacion;
       public         postgres    false            �            1259    29856    incubacion_id_incub_seq    SEQUENCE     �   CREATE SEQUENCE public.incubacion_id_incub_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.incubacion_id_incub_seq;
       public       postgres    false    221            �           0    0    incubacion_id_incub_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.incubacion_id_incub_seq OWNED BY public.incubacion.id_incub;
            public       postgres    false    220            �            1259    29835 
   incubadora    TABLE     n   CREATE TABLE public.incubadora (
    id_inc integer NOT NULL,
    disponible boolean DEFAULT true NOT NULL
);
    DROP TABLE public.incubadora;
       public         postgres    false            �            1259    29833    incubadora_id_inc_seq    SEQUENCE     �   CREATE SEQUENCE public.incubadora_id_inc_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.incubadora_id_inc_seq;
       public       postgres    false    219            �           0    0    incubadora_id_inc_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.incubadora_id_inc_seq OWNED BY public.incubadora.id_inc;
            public       postgres    false    218            �            1259    29728    lote    TABLE     �  CREATE TABLE public.lote (
    id_lote integer NOT NULL,
    nombre character varying(50) NOT NULL,
    cantidad integer NOT NULL,
    mortalidad integer DEFAULT 0,
    fecha_ingreso date,
    origen character(1),
    fecha_salida date,
    destino character(1),
    descripcion character varying(255),
    archivado boolean DEFAULT false,
    id_ave integer,
    id_galpon integer
);
    DROP TABLE public.lote;
       public         postgres    false            �            1259    29733    lote_id_lote_seq    SEQUENCE     �   CREATE SEQUENCE public.lote_id_lote_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.lote_id_lote_seq;
       public       postgres    false    207            �           0    0    lote_id_lote_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.lote_id_lote_seq OWNED BY public.lote.id_lote;
            public       postgres    false    208            �            1259    29735 	   mort_lote    TABLE     �   CREATE TABLE public.mort_lote (
    fecha timestamp without time zone NOT NULL,
    id_lote integer NOT NULL,
    cantidad_defuncion integer DEFAULT 0
);
    DROP TABLE public.mort_lote;
       public         postgres    false            �            1259    29739    rol    TABLE     �   CREATE TABLE public.rol (
    id_rol integer NOT NULL,
    nombre character varying(50) NOT NULL,
    permisos character varying(255)[]
);
    DROP TABLE public.rol;
       public         postgres    false            �            1259    29745    rol_id_rol_seq    SEQUENCE     �   CREATE SEQUENCE public.rol_id_rol_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.rol_id_rol_seq;
       public       postgres    false    210            �           0    0    rol_id_rol_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.rol_id_rol_seq OWNED BY public.rol.id_rol;
            public       postgres    false    211            �            1259    29747    usuario    TABLE        CREATE TABLE public.usuario (
    id_user integer NOT NULL,
    nombre_usuario character varying(40) NOT NULL,
    "contraseña" character varying(70) NOT NULL,
    error smallint DEFAULT 0,
    hora timestamp without time zone,
    bloqueado boolean DEFAULT false,
    id_rol integer
);
    DROP TABLE public.usuario;
       public         postgres    false            �            1259    29752    usuario_id_user_seq    SEQUENCE     �   CREATE SEQUENCE public.usuario_id_user_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.usuario_id_user_seq;
       public       postgres    false    212            �           0    0    usuario_id_user_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.usuario_id_user_seq OWNED BY public.usuario.id_user;
            public       postgres    false    213            �            1259    29754    vacuna    TABLE     �   CREATE TABLE public.vacuna (
    id_vac integer NOT NULL,
    nombre character varying(255) NOT NULL,
    descripcion character varying(255)
);
    DROP TABLE public.vacuna;
       public         postgres    false            �            1259    29760    vacuna_id_vac_seq    SEQUENCE     �   CREATE SEQUENCE public.vacuna_id_vac_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.vacuna_id_vac_seq;
       public       postgres    false    214            �           0    0    vacuna_id_vac_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.vacuna_id_vac_seq OWNED BY public.vacuna.id_vac;
            public       postgres    false    215            �
           2604    29916    alimentacion id_alim    DEFAULT     |   ALTER TABLE ONLY public.alimentacion ALTER COLUMN id_alim SET DEFAULT nextval('public.alimentacion_id_alim_seq'::regclass);
 C   ALTER TABLE public.alimentacion ALTER COLUMN id_alim DROP DEFAULT;
       public       postgres    false    225    224    225            �
           2604    29762    ave id    DEFAULT     `   ALTER TABLE ONLY public.ave ALTER COLUMN id SET DEFAULT nextval('public.ave_id_seq'::regclass);
 5   ALTER TABLE public.ave ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    198    197            �
           2604    29763    bitacora id_log    DEFAULT     r   ALTER TABLE ONLY public.bitacora ALTER COLUMN id_log SET DEFAULT nextval('public.bitacora_id_log_seq'::regclass);
 >   ALTER TABLE public.bitacora ALTER COLUMN id_log DROP DEFAULT;
       public       postgres    false    200    199            �
           2604    29764    cuarentena id_cuar    DEFAULT     x   ALTER TABLE ONLY public.cuarentena ALTER COLUMN id_cuar SET DEFAULT nextval('public.cuarentena_id_cuar_seq'::regclass);
 A   ALTER TABLE public.cuarentena ALTER COLUMN id_cuar DROP DEFAULT;
       public       postgres    false    202    201            �
           2604    29827    enfermedad id_enf    DEFAULT     v   ALTER TABLE ONLY public.enfermedad ALTER COLUMN id_enf SET DEFAULT nextval('public.enfermedad_id_enf_seq'::regclass);
 @   ALTER TABLE public.enfermedad ALTER COLUMN id_enf DROP DEFAULT;
       public       postgres    false    217    216    217            �
           2604    29765    galpon id_galpon    DEFAULT     t   ALTER TABLE ONLY public.galpon ALTER COLUMN id_galpon SET DEFAULT nextval('public.galpon_id_galpon_seq'::regclass);
 ?   ALTER TABLE public.galpon ALTER COLUMN id_galpon DROP DEFAULT;
       public       postgres    false    204    203            �
           2604    29766    galpon_vacuna id    DEFAULT     t   ALTER TABLE ONLY public.galpon_vacuna ALTER COLUMN id SET DEFAULT nextval('public.galpon_vacuna_id_seq'::regclass);
 ?   ALTER TABLE public.galpon_vacuna ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    206    205            �
           2604    29888    huevo id_huevo    DEFAULT     p   ALTER TABLE ONLY public.huevo ALTER COLUMN id_huevo SET DEFAULT nextval('public.huevo_id_huevo_seq'::regclass);
 =   ALTER TABLE public.huevo ALTER COLUMN id_huevo DROP DEFAULT;
       public       postgres    false    223    222    223            �
           2604    29861    incubacion id_incub    DEFAULT     z   ALTER TABLE ONLY public.incubacion ALTER COLUMN id_incub SET DEFAULT nextval('public.incubacion_id_incub_seq'::regclass);
 B   ALTER TABLE public.incubacion ALTER COLUMN id_incub DROP DEFAULT;
       public       postgres    false    221    220    221            �
           2604    29838    incubadora id_inc    DEFAULT     v   ALTER TABLE ONLY public.incubadora ALTER COLUMN id_inc SET DEFAULT nextval('public.incubadora_id_inc_seq'::regclass);
 @   ALTER TABLE public.incubadora ALTER COLUMN id_inc DROP DEFAULT;
       public       postgres    false    219    218    219            �
           2604    29767    lote id_lote    DEFAULT     l   ALTER TABLE ONLY public.lote ALTER COLUMN id_lote SET DEFAULT nextval('public.lote_id_lote_seq'::regclass);
 ;   ALTER TABLE public.lote ALTER COLUMN id_lote DROP DEFAULT;
       public       postgres    false    208    207            �
           2604    29768 
   rol id_rol    DEFAULT     h   ALTER TABLE ONLY public.rol ALTER COLUMN id_rol SET DEFAULT nextval('public.rol_id_rol_seq'::regclass);
 9   ALTER TABLE public.rol ALTER COLUMN id_rol DROP DEFAULT;
       public       postgres    false    211    210            �
           2604    29769    usuario id_user    DEFAULT     r   ALTER TABLE ONLY public.usuario ALTER COLUMN id_user SET DEFAULT nextval('public.usuario_id_user_seq'::regclass);
 >   ALTER TABLE public.usuario ALTER COLUMN id_user DROP DEFAULT;
       public       postgres    false    213    212            �
           2604    29770    vacuna id_vac    DEFAULT     n   ALTER TABLE ONLY public.vacuna ALTER COLUMN id_vac SET DEFAULT nextval('public.vacuna_id_vac_seq'::regclass);
 <   ALTER TABLE public.vacuna ALTER COLUMN id_vac DROP DEFAULT;
       public       postgres    false    215    214            �          0    29913    alimentacion 
   TABLE DATA               U   COPY public.alimentacion (id_alim, fecha, alimento, cantidad, id_galpon) FROM stdin;
    public       postgres    false    225            �          0    29696    ambiente 
   TABLE DATA               J   COPY public.ambiente (id_galpon, fecha, temperatura, humedad) FROM stdin;
    public       postgres    false    196            �          0    29699    ave 
   TABLE DATA               *   COPY public.ave (id, especie) FROM stdin;
    public       postgres    false    197            �          0    29704    bitacora 
   TABLE DATA               F   COPY public.bitacora (id_log, username, fecha, operacion) FROM stdin;
    public       postgres    false    199            �          0    29712 
   cuarentena 
   TABLE DATA               \   COPY public.cuarentena (id_cuar, fecha_ingreso, fecha_salida, razon, id_galpon) FROM stdin;
    public       postgres    false    201            �          0    29824 
   enfermedad 
   TABLE DATA               =   COPY public.enfermedad (id_enf, nombre, sintoma) FROM stdin;
    public       postgres    false    217            �          0    29717    galpon 
   TABLE DATA               [   COPY public.galpon (id_galpon, dimension, capacidad, capacidad_libre, en_cuar) FROM stdin;
    public       postgres    false    203            �          0    29723    galpon_vacuna 
   TABLE DATA               E   COPY public.galpon_vacuna (id, id_galpon, id_vac, fecha) FROM stdin;
    public       postgres    false    205            �          0    29885    huevo 
   TABLE DATA               Q   COPY public.huevo (id_huevo, fec_coleccion, bueno, podrido, id_lote) FROM stdin;
    public       postgres    false    223            �          0    29858 
   incubacion 
   TABLE DATA               u   COPY public.incubacion (id_incub, inicio, finalizacion, nro_huevos, nro_eclosionado, finalizado, id_inc) FROM stdin;
    public       postgres    false    221            �          0    29835 
   incubadora 
   TABLE DATA               8   COPY public.incubadora (id_inc, disponible) FROM stdin;
    public       postgres    false    219            �          0    29728    lote 
   TABLE DATA               �   COPY public.lote (id_lote, nombre, cantidad, mortalidad, fecha_ingreso, origen, fecha_salida, destino, descripcion, archivado, id_ave, id_galpon) FROM stdin;
    public       postgres    false    207            �          0    29735 	   mort_lote 
   TABLE DATA               G   COPY public.mort_lote (fecha, id_lote, cantidad_defuncion) FROM stdin;
    public       postgres    false    209            �          0    29739    rol 
   TABLE DATA               7   COPY public.rol (id_rol, nombre, permisos) FROM stdin;
    public       postgres    false    210            �          0    29747    usuario 
   TABLE DATA               i   COPY public.usuario (id_user, nombre_usuario, "contraseña", error, hora, bloqueado, id_rol) FROM stdin;
    public       postgres    false    212            �          0    29754    vacuna 
   TABLE DATA               =   COPY public.vacuna (id_vac, nombre, descripcion) FROM stdin;
    public       postgres    false    214            �           0    0    alimentacion_id_alim_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.alimentacion_id_alim_seq', 1, true);
            public       postgres    false    224            �           0    0 
   ave_id_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.ave_id_seq', 4, true);
            public       postgres    false    198            �           0    0    bitacora_id_log_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.bitacora_id_log_seq', 60, true);
            public       postgres    false    200            �           0    0    cuarentena_id_cuar_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.cuarentena_id_cuar_seq', 3, true);
            public       postgres    false    202            �           0    0    enfermedad_id_enf_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.enfermedad_id_enf_seq', 3, true);
            public       postgres    false    216            �           0    0    galpon_id_galpon_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.galpon_id_galpon_seq', 5, true);
            public       postgres    false    204            �           0    0    galpon_vacuna_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.galpon_vacuna_id_seq', 12, true);
            public       postgres    false    206            �           0    0    huevo_id_huevo_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.huevo_id_huevo_seq', 4, true);
            public       postgres    false    222            �           0    0    incubacion_id_incub_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.incubacion_id_incub_seq', 4, true);
            public       postgres    false    220            �           0    0    incubadora_id_inc_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.incubadora_id_inc_seq', 3, true);
            public       postgres    false    218            �           0    0    lote_id_lote_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.lote_id_lote_seq', 7, true);
            public       postgres    false    208            �           0    0    rol_id_rol_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.rol_id_rol_seq', 2, true);
            public       postgres    false    211            �           0    0    usuario_id_user_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.usuario_id_user_seq', 8, true);
            public       postgres    false    213            �           0    0    vacuna_id_vac_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.vacuna_id_vac_seq', 5, true);
            public       postgres    false    215                       2606    29918    alimentacion alimentacion_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.alimentacion
    ADD CONSTRAINT alimentacion_pkey PRIMARY KEY (id_alim);
 H   ALTER TABLE ONLY public.alimentacion DROP CONSTRAINT alimentacion_pkey;
       public         postgres    false    225            �
           2606    29772    ambiente ambiente_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.ambiente
    ADD CONSTRAINT ambiente_pkey PRIMARY KEY (id_galpon, fecha);
 @   ALTER TABLE ONLY public.ambiente DROP CONSTRAINT ambiente_pkey;
       public         postgres    false    196    196            �
           2606    29774    ave ave_pkey 
   CONSTRAINT     J   ALTER TABLE ONLY public.ave
    ADD CONSTRAINT ave_pkey PRIMARY KEY (id);
 6   ALTER TABLE ONLY public.ave DROP CONSTRAINT ave_pkey;
       public         postgres    false    197            �
           2606    29776    bitacora bitacora_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.bitacora
    ADD CONSTRAINT bitacora_pkey PRIMARY KEY (id_log);
 @   ALTER TABLE ONLY public.bitacora DROP CONSTRAINT bitacora_pkey;
       public         postgres    false    199            �
           2606    29778    cuarentena cuarentena_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.cuarentena
    ADD CONSTRAINT cuarentena_pkey PRIMARY KEY (id_cuar);
 D   ALTER TABLE ONLY public.cuarentena DROP CONSTRAINT cuarentena_pkey;
       public         postgres    false    201                       2606    29832    enfermedad enfermedad_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.enfermedad
    ADD CONSTRAINT enfermedad_pkey PRIMARY KEY (id_enf);
 D   ALTER TABLE ONLY public.enfermedad DROP CONSTRAINT enfermedad_pkey;
       public         postgres    false    217            �
           2606    29780    galpon galpon_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.galpon
    ADD CONSTRAINT galpon_pkey PRIMARY KEY (id_galpon);
 <   ALTER TABLE ONLY public.galpon DROP CONSTRAINT galpon_pkey;
       public         postgres    false    203                       2606    29890    huevo huevo_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.huevo
    ADD CONSTRAINT huevo_pkey PRIMARY KEY (id_huevo);
 :   ALTER TABLE ONLY public.huevo DROP CONSTRAINT huevo_pkey;
       public         postgres    false    223                       2606    29864    incubacion incubacion_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.incubacion
    ADD CONSTRAINT incubacion_pkey PRIMARY KEY (id_incub);
 D   ALTER TABLE ONLY public.incubacion DROP CONSTRAINT incubacion_pkey;
       public         postgres    false    221                       2606    29841    incubadora incubadora_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.incubadora
    ADD CONSTRAINT incubadora_pkey PRIMARY KEY (id_inc);
 D   ALTER TABLE ONLY public.incubadora DROP CONSTRAINT incubadora_pkey;
       public         postgres    false    219                       2606    29782    lote lote_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.lote
    ADD CONSTRAINT lote_pkey PRIMARY KEY (id_lote);
 8   ALTER TABLE ONLY public.lote DROP CONSTRAINT lote_pkey;
       public         postgres    false    207                       2606    29784    mort_lote mort_lote_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.mort_lote
    ADD CONSTRAINT mort_lote_pkey PRIMARY KEY (fecha, id_lote);
 B   ALTER TABLE ONLY public.mort_lote DROP CONSTRAINT mort_lote_pkey;
       public         postgres    false    209    209                       2606    29786    rol rol_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id_rol);
 6   ALTER TABLE ONLY public.rol DROP CONSTRAINT rol_pkey;
       public         postgres    false    210                       2606    29788 "   usuario usuario_nombre_usuario_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_nombre_usuario_key UNIQUE (nombre_usuario);
 L   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_nombre_usuario_key;
       public         postgres    false    212            	           2606    29790    usuario usuario_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_user);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public         postgres    false    212                       2606    29792    vacuna vacuna_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.vacuna
    ADD CONSTRAINT vacuna_pkey PRIMARY KEY (id_vac);
 <   ALTER TABLE ONLY public.vacuna DROP CONSTRAINT vacuna_pkey;
       public         postgres    false    214                        2620    29793    usuario error_trigger    TRIGGER     �   CREATE TRIGGER error_trigger BEFORE INSERT OR UPDATE ON public.usuario FOR EACH ROW WHEN ((new.error = 3)) EXECUTE PROCEDURE public.check_error_trigger();
 .   DROP TRIGGER error_trigger ON public.usuario;
       public       postgres    false    241    212    212                       2620    29794    lote trg_archivado_lote    TRIGGER     �   CREATE TRIGGER trg_archivado_lote BEFORE UPDATE OF fecha_salida ON public.lote FOR EACH ROW EXECUTE PROCEDURE public.fn_archivado_lote();
 0   DROP TRIGGER trg_archivado_lote ON public.lote;
       public       postgres    false    242    207    207                       2620    29795    lote trg_cantidad_libre_galpon    TRIGGER     �   CREATE TRIGGER trg_cantidad_libre_galpon BEFORE UPDATE OF id_galpon ON public.lote FOR EACH ROW EXECUTE PROCEDURE public.fn_cantidad_libre_galpon();
 7   DROP TRIGGER trg_cantidad_libre_galpon ON public.lote;
       public       postgres    false    243    207    207                       2620    29796     cuarentena trg_cuarentena_galpon    TRIGGER     �   CREATE TRIGGER trg_cuarentena_galpon BEFORE UPDATE OF fecha_salida ON public.cuarentena FOR EACH ROW EXECUTE PROCEDURE public.fn_cuarentena_galpon();
 9   DROP TRIGGER trg_cuarentena_galpon ON public.cuarentena;
       public       postgres    false    201    244    201                       2620    29797 $   cuarentena trg_cuarentena_galpon_ins    TRIGGER     �   CREATE TRIGGER trg_cuarentena_galpon_ins AFTER INSERT ON public.cuarentena FOR EACH ROW EXECUTE PROCEDURE public.fn_cuarentena_galpon_ins();
 =   DROP TRIGGER trg_cuarentena_galpon_ins ON public.cuarentena;
       public       postgres    false    201    245                       2620    29798     mort_lote trg_defuncion_ambiente    TRIGGER     �   CREATE TRIGGER trg_defuncion_ambiente BEFORE INSERT OR UPDATE OF cantidad_defuncion ON public.mort_lote FOR EACH ROW EXECUTE PROCEDURE public.fn_defuncion_ambiente();
 9   DROP TRIGGER trg_defuncion_ambiente ON public.mort_lote;
       public       postgres    false    209    246    209            "           2620    29897    incubacion trg_incubadora_disp    TRIGGER     �   CREATE TRIGGER trg_incubadora_disp AFTER UPDATE OF finalizado ON public.incubacion FOR EACH ROW EXECUTE PROCEDURE public.fn_incubadora_disp();
 7   DROP TRIGGER trg_incubadora_disp ON public.incubacion;
       public       postgres    false    221    226    221            !           2620    29799 "   usuario trigger_actualizar_usuario    TRIGGER     �   CREATE TRIGGER trigger_actualizar_usuario BEFORE UPDATE OF "contraseña" ON public.usuario FOR EACH ROW EXECUTE PROCEDURE public.actualizar_usuario();
 ;   DROP TRIGGER trigger_actualizar_usuario ON public.usuario;
       public       postgres    false    212    227    212                       2606    29919 (   alimentacion alimentacion_id_galpon_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.alimentacion
    ADD CONSTRAINT alimentacion_id_galpon_fkey FOREIGN KEY (id_galpon) REFERENCES public.galpon(id_galpon);
 R   ALTER TABLE ONLY public.alimentacion DROP CONSTRAINT alimentacion_id_galpon_fkey;
       public       postgres    false    2815    225    203                       2606    29891    huevo huevo_id_lote_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY public.huevo
    ADD CONSTRAINT huevo_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote);
 B   ALTER TABLE ONLY public.huevo DROP CONSTRAINT huevo_id_lote_fkey;
       public       postgres    false    223    2817    207                       2606    29865 !   incubacion incubacion_id_inc_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.incubacion
    ADD CONSTRAINT incubacion_id_inc_fkey FOREIGN KEY (id_inc) REFERENCES public.incubadora(id_inc);
 K   ALTER TABLE ONLY public.incubacion DROP CONSTRAINT incubacion_id_inc_fkey;
       public       postgres    false    2831    219    221                       2606    29800     mort_lote mort_lote_id_lote_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mort_lote
    ADD CONSTRAINT mort_lote_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote);
 J   ALTER TABLE ONLY public.mort_lote DROP CONSTRAINT mort_lote_id_lote_fkey;
       public       postgres    false    207    209    2817                       2606    29805    usuario usuario_id_rol_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES public.rol(id_rol);
 E   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_id_rol_fkey;
       public       postgres    false    210    212    2821            �   "   x�3�4202�50�50��M̬�9�b���� O�:      �   o   x�]ͻ�@���ļ�Gg�E��a9�5�7X����y`/��k"�H���� �(a�O'�5�V�����>Sm�CZZ?�L�xX�7����x�{ҭq�����T�R�">      �   >   x�3�tO����KT(��KM�/J�2�����WHIUH.�L̫J�2D�����r��qqq ��      �   �  x���ˎ�0���Sx7�"_��;	�DY���'q[C�N2hx+����i&�q:j�v��>��'��w�_#�oH�����Lq����_Mg����5uu-�L1��ccK;���Z�����?��7�yj�Q׏m�ʳ���3e|6	̸"R�]�H�չ�Evݠ�mqo���v%�PN�Z��4��h�f���0���]1HE �>?���b���)Ϧ��;%��r% J,�H�����me�}����y~j{�)�>-���zcr��$����9*�
�̑X����bb��d�8��/�h����<i_��.�F��D�`��+f�bDA	{�7�K�X�h4≹����mtmC��x��EO�n��Q�x�E�!{ȹG����Tt��oĵx���=�90�����{%��h��.�����4�ߛ�q�����4�M�+|�al2�C"�x�T�+����]4�M9<�u�x���\I�R���)<2�W"���"����?މ�_��٦�iƍ�H���f�������
�sm�s��� '�6�R��LbŘ_NГ9������y����Lb��GP�}9$�I���˸iL��pg�-cDo���n��M��Ё���YV��F2�Y� <LX�S���?�R#��$wi���Ӈeu�-5����k�G9}{����n      �   <   x�3�4202�50�5��3M9�R�R�3��RRR��R�rSSSR�c�8�b���� �<      �   �   x���AN!��p
0�D��.5�Mt���؂Fo�ҵG��Y�%F��M!?�����|��-���*��}�)��C%	Tl�x
�t�������
�O�}}���:���qF�$�Xh<$�)4\���ծ,�,� �{&%�����Gw��~6b�f��;��-[Q�d#���qL��JNfz߳i���]��N�L�,h(VpWj��'ދ��=7H?�[;�}��_@!���q��W�tZ���`�����_O��      �   D   x�3�4�02�4450�i\����F !��!P���gaj1F�43�,�2A6��-F��� l�c      �   (   x�3�4B##c]S]c.NcN�����1W� x�      �   ;   x�Mʱ !�����^迎��F��r�V���
}m`��kAfY8^�u�w:�@      �   K   x�3�4202�50�54Q00�24�22�����*�Y�[���8-8K8����-�L,8c�@J�dPI� "g      �      x�3�,�2�L�2�1z\\\ 5�      �   \   x�}ͱ	�@D�x�
8ٝ��+0MM�O�	�ö/�!+Tz�H$fL�o���HKM��򇚔F�w�T��L���S!�      �   <   x�5ɱ�0����L�,��T��	j���J���:�n���Z��F��c4���]
�      �   �   x�m�1�0E��,�ހ�		Y�Ĕ�Į������X<��?��9�����ڼ��0�p��FG��B�+`� HںaY�mv��E/>������[�����)�d��_�=4�9$u�Z���V���vu��-P+�l��A{����,wN���-�l^�wf������Hc�      �   �  x�M�˒�0 �u��Y# �Y�7�" ��H�1 䕀��S������S]-�<�����pC
2�}��F���6q�/`�"Uy����_4����!x�m�<�(���K9׉RP+ e��?5fn����k�X15Vr�ٳ0Z���KH�?o���f��Ϡ�X���A&K������<VJ_}*)�4���3���2@�nE�"o%�Wm����<�	e�b^><j���&�ù�y)"ҹ�>�����}M�i�(��?N#Np�U��,R�:��*6M��u�B��JBH5:�����=⨀'Iv�+{p�ڬ�f���b��js&<aC�J��|&�D𸃛9���A��Z�9D<~;Pw��3X�E��K�ǫ6���j���7������SCD|Q9W�\>Eoj .2��X���c'�d)������!%��¼�7h��{���O��Z��j���l��7�X,~ WI��      �   N   x�3��M,J����2��,*M�ITp,�L,	s:���f�d+x楥&'g�'��L8�R˓�KrRA�=... �TP      �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            �           1262    28337    avicola    DATABASE     �   CREATE DATABASE avicola WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Chinese (Simplified)_China.936' LC_CTYPE = 'Chinese (Simplified)_China.936';
    DROP DATABASE avicola;
             postgres    false            �            1255    29688    actualizar_usuario()    FUNCTION       CREATE FUNCTION public.actualizar_usuario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.contraseña <> OLD.contraseña THEN
        NEW.error := 0;
        NEW.hora := NULL;
        NEW.bloqueado := FALSE;
    END IF;
    RETURN NEW;
END;
$$;
 +   DROP FUNCTION public.actualizar_usuario();
       public       postgres    false            �            1255    29689    asignar_lote(integer, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.asignar_lote(galpon_id integer, lote_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    disponible INT;
		lote_cant INT;
BEGIN
    -- Obtener la capacidad disponible del galpón
    SELECT capacidad_libre INTO disponible
    FROM galpon
    WHERE id_galpon = galpon_id;
		
		-- Obtener la cantidad del lote
    SELECT cantidad INTO lote_cant
    FROM lote
    WHERE id_lote = lote_id;

    -- Verificar si el galpón tiene suficiente capacidad
    IF disponible >= lote_cant THEN
        -- Actualizar la capacidad disponible del galpón
        UPDATE galpon
        SET capacidad_libre = disponible - lote_cant
        WHERE id_galpon = galpon_id;

        -- actualizar el lote 
        UPDATE lote 
				SET id_galpon = galpon_id
				WHERE id_lote = lote_id;
    ELSE
        -- Imprimir mensaje de error
        RAISE EXCEPTION 'El galpón no tiene suficiente capacidad para asignar el lote';
    END IF;
END;
$$;
 H   DROP PROCEDURE public.asignar_lote(galpon_id integer, lote_id integer);
       public       postgres    false            �            1255    29690    check_error_trigger()    FUNCTION     �   CREATE FUNCTION public.check_error_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.error = 3 THEN
        NEW.bloqueado = TRUE;
    END IF;
    RETURN NEW;
END;
$$;
 ,   DROP FUNCTION public.check_error_trigger();
       public       postgres    false            �            1255    29691    fn_archivado_lote()    FUNCTION     I  CREATE FUNCTION public.fn_archivado_lote() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	mortalidad INTEGER;
BEGIN
	IF NEW.fecha_salida IS NOT NULL THEN
		-- actualizar el estado de archivado
		UPDATE lote
		SET archivado = true
		WHERE id_lote = NEW.id_lote;
		
		-- mortalidad del lote
		SELECT SUM(cantidad_defuncion) INTO mortalidad
		FROM ambiente
		WHERE id_lote = NEW.id_lote;
		
		-- actualizar capacidad disponible
		UPDATE galpon 
		SET capacidad_libre = capacidad_libre + OLD.cantidad - mortalidad
		WHERE id_galpon = OLD.id_galpon;
	END IF;
	RETURN NEW;
END; $$;
 *   DROP FUNCTION public.fn_archivado_lote();
       public       postgres    false            �            1255    29692    fn_cantidad_libre_galpon()    FUNCTION     �  CREATE FUNCTION public.fn_cantidad_libre_galpon() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	IF OLD.id_galpon IS NOT NULL THEN
		UPDATE galpon 
		SET capacidad_libre = capacidad_libre + OLD.cantidad 
		WHERE id_galpon = OLD.id_galpon;
	ELSE
		UPDATE galpon 
		SET capacidad_libre = capacidad_libre - NEW.cantidad 
		WHERE id_galpon = NEW.id_galpon;
	END IF;
	RETURN NEW;
END; $$;
 1   DROP FUNCTION public.fn_cantidad_libre_galpon();
       public       postgres    false            �            1255    29693    fn_cuarentena_galpon()    FUNCTION       CREATE FUNCTION public.fn_cuarentena_galpon() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF NEW.fecha_salida IS NOT NULL THEN
		-- actualizar el estado de cuarentena
		UPDATE galpon
		SET en_cuar = FALSE
		WHERE id_galpon = NEW.id_galpon;
	END IF;
	RETURN NEW;
END; $$;
 -   DROP FUNCTION public.fn_cuarentena_galpon();
       public       postgres    false            �            1255    29694    fn_cuarentena_galpon_ins()    FUNCTION     �   CREATE FUNCTION public.fn_cuarentena_galpon_ins() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	
		-- actualizar el estado de cuarentena
		UPDATE galpon
		SET en_cuar = TRUE
		WHERE id_galpon = NEW.id_galpon;
	
	RETURN NEW;
END; $$;
 1   DROP FUNCTION public.fn_cuarentena_galpon_ins();
       public       postgres    false            �            1255    29695    fn_defuncion_ambiente()    FUNCTION     �  CREATE FUNCTION public.fn_defuncion_ambiente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	idGalpon INTEGER;
BEGIN
	
		--  galpon donde se encuentra alojado el lote
		SELECT id_galpon INTO idGalpon
		FROM lote
		WHERE id_lote = NEW.id_lote;
		
		IF tg_op = 'INSERT' THEN
		-- actualizar capacidad disponible
			UPDATE galpon 
			SET capacidad_libre = capacidad_libre + NEW.cantidad_defuncion
			WHERE id_galpon = idGalpon;
			
			-- actualizar mortalidad lote
			UPDATE lote 
	SET mortalidad = mortalidad + NEW.cantidad_defuncion 
	WHERE id_lote = NEW.id_lote;
		ELSE
			-- actualizar capacidad disponible
			UPDATE galpon 
			SET capacidad_libre = capacidad_libre - OLD.cantidad_defuncion + NEW.cantidad_defuncion
			WHERE id_galpon = idGalpon;
			
			--actualizar mortalidad lote
			UPDATE lote 
	SET mortalidad = mortalidad - OLD.cantidad_defuncion +  NEW.cantidad_defuncion 
	WHERE id_lote = NEW.id_lote;
	END IF;
	
	RETURN NEW;
END; $$;
 .   DROP FUNCTION public.fn_defuncion_ambiente();
       public       postgres    false            �            1255    29896    fn_incubadora_disp()    FUNCTION     O  CREATE FUNCTION public.fn_incubadora_disp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	IF NEW.finalizado = TRUE THEN
    UPDATE incubadora
		SET disponible = TRUE
		WHERE id_inc = NEW.id_inc;
  ELSE
    UPDATE incubadora
		SET disponible = FALSE
		WHERE id_inc = NEW.id_inc;
  END IF;

	RETURN NEW;
END; $$;
 +   DROP FUNCTION public.fn_incubadora_disp();
       public       postgres    false            �            1259    29913    alimentacion    TABLE     �   CREATE TABLE public.alimentacion (
    id_alim integer NOT NULL,
    fecha date NOT NULL,
    alimento character varying(255) NOT NULL,
    cantidad integer NOT NULL,
    id_galpon integer
);
     DROP TABLE public.alimentacion;
       public         postgres    false            �            1259    29911    alimentacion_id_alim_seq    SEQUENCE     �   CREATE SEQUENCE public.alimentacion_id_alim_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.alimentacion_id_alim_seq;
       public       postgres    false    225            �           0    0    alimentacion_id_alim_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.alimentacion_id_alim_seq OWNED BY public.alimentacion.id_alim;
            public       postgres    false    224            �            1259    29696    ambiente    TABLE     �   CREATE TABLE public.ambiente (
    id_galpon integer NOT NULL,
    fecha timestamp without time zone NOT NULL,
    temperatura real,
    humedad real
);
    DROP TABLE public.ambiente;
       public         postgres    false            �            1259    29699    ave    TABLE     b   CREATE TABLE public.ave (
    id integer NOT NULL,
    especie character varying(255) NOT NULL
);
    DROP TABLE public.ave;
       public         postgres    false            �            1259    29702 
   ave_id_seq    SEQUENCE     �   CREATE SEQUENCE public.ave_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE public.ave_id_seq;
       public       postgres    false    197            �           0    0 
   ave_id_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE public.ave_id_seq OWNED BY public.ave.id;
            public       postgres    false    198            �            1259    29704    bitacora    TABLE     �   CREATE TABLE public.bitacora (
    id_log integer NOT NULL,
    username character varying(255) NOT NULL,
    fecha timestamp without time zone,
    operacion character varying(255)
);
    DROP TABLE public.bitacora;
       public         postgres    false            �            1259    29710    bitacora_id_log_seq    SEQUENCE     �   CREATE SEQUENCE public.bitacora_id_log_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.bitacora_id_log_seq;
       public       postgres    false    199            �           0    0    bitacora_id_log_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.bitacora_id_log_seq OWNED BY public.bitacora.id_log;
            public       postgres    false    200            �            1259    29712 
   cuarentena    TABLE     �   CREATE TABLE public.cuarentena (
    id_cuar integer NOT NULL,
    fecha_ingreso date NOT NULL,
    fecha_salida date,
    razon character varying(255) NOT NULL,
    id_galpon integer NOT NULL
);
    DROP TABLE public.cuarentena;
       public         postgres    false            �            1259    29715    cuarentena_id_cuar_seq    SEQUENCE     �   CREATE SEQUENCE public.cuarentena_id_cuar_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.cuarentena_id_cuar_seq;
       public       postgres    false    201            �           0    0    cuarentena_id_cuar_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.cuarentena_id_cuar_seq OWNED BY public.cuarentena.id_cuar;
            public       postgres    false    202            �            1259    29824 
   enfermedad    TABLE     ~   CREATE TABLE public.enfermedad (
    id_enf integer NOT NULL,
    nombre character varying(255) NOT NULL,
    sintoma text
);
    DROP TABLE public.enfermedad;
       public         postgres    false            �            1259    29822    enfermedad_id_enf_seq    SEQUENCE     �   CREATE SEQUENCE public.enfermedad_id_enf_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.enfermedad_id_enf_seq;
       public       postgres    false    217            �           0    0    enfermedad_id_enf_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.enfermedad_id_enf_seq OWNED BY public.enfermedad.id_enf;
            public       postgres    false    216            �            1259    29717    galpon    TABLE     �   CREATE TABLE public.galpon (
    id_galpon integer NOT NULL,
    dimension character varying(50) NOT NULL,
    capacidad integer NOT NULL,
    capacidad_libre integer,
    en_cuar boolean DEFAULT false
);
    DROP TABLE public.galpon;
       public         postgres    false            �            1259    29721    galpon_id_galpon_seq    SEQUENCE     �   CREATE SEQUENCE public.galpon_id_galpon_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.galpon_id_galpon_seq;
       public       postgres    false    203            �           0    0    galpon_id_galpon_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.galpon_id_galpon_seq OWNED BY public.galpon.id_galpon;
            public       postgres    false    204            �            1259    29723    galpon_vacuna    TABLE     �   CREATE TABLE public.galpon_vacuna (
    id integer NOT NULL,
    id_galpon integer NOT NULL,
    id_vac integer NOT NULL,
    fecha date NOT NULL
);
 !   DROP TABLE public.galpon_vacuna;
       public         postgres    false            �            1259    29726    galpon_vacuna_id_seq    SEQUENCE     �   CREATE SEQUENCE public.galpon_vacuna_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.galpon_vacuna_id_seq;
       public       postgres    false    205            �           0    0    galpon_vacuna_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.galpon_vacuna_id_seq OWNED BY public.galpon_vacuna.id;
            public       postgres    false    206            �            1259    29885    huevo    TABLE     �   CREATE TABLE public.huevo (
    id_huevo integer NOT NULL,
    fec_coleccion date,
    bueno integer,
    podrido integer,
    id_lote integer
);
    DROP TABLE public.huevo;
       public         postgres    false            �            1259    29883    huevo_id_huevo_seq    SEQUENCE     �   CREATE SEQUENCE public.huevo_id_huevo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.huevo_id_huevo_seq;
       public       postgres    false    223            �           0    0    huevo_id_huevo_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.huevo_id_huevo_seq OWNED BY public.huevo.id_huevo;
            public       postgres    false    222            �            1259    29858 
   incubacion    TABLE       CREATE TABLE public.incubacion (
    id_incub integer NOT NULL,
    inicio timestamp without time zone,
    finalizacion timestamp without time zone,
    nro_huevos integer,
    nro_eclosionado integer,
    finalizado boolean DEFAULT false,
    id_inc integer
);
    DROP TABLE public.incubacion;
       public         postgres    false            �            1259    29856    incubacion_id_incub_seq    SEQUENCE     �   CREATE SEQUENCE public.incubacion_id_incub_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.incubacion_id_incub_seq;
       public       postgres    false    221            �           0    0    incubacion_id_incub_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.incubacion_id_incub_seq OWNED BY public.incubacion.id_incub;
            public       postgres    false    220            �            1259    29835 
   incubadora    TABLE     n   CREATE TABLE public.incubadora (
    id_inc integer NOT NULL,
    disponible boolean DEFAULT true NOT NULL
);
    DROP TABLE public.incubadora;
       public         postgres    false            �            1259    29833    incubadora_id_inc_seq    SEQUENCE     �   CREATE SEQUENCE public.incubadora_id_inc_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.incubadora_id_inc_seq;
       public       postgres    false    219            �           0    0    incubadora_id_inc_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.incubadora_id_inc_seq OWNED BY public.incubadora.id_inc;
            public       postgres    false    218            �            1259    29728    lote    TABLE     �  CREATE TABLE public.lote (
    id_lote integer NOT NULL,
    nombre character varying(50) NOT NULL,
    cantidad integer NOT NULL,
    mortalidad integer DEFAULT 0,
    fecha_ingreso date,
    origen character(1),
    fecha_salida date,
    destino character(1),
    descripcion character varying(255),
    archivado boolean DEFAULT false,
    id_ave integer,
    id_galpon integer
);
    DROP TABLE public.lote;
       public         postgres    false            �            1259    29733    lote_id_lote_seq    SEQUENCE     �   CREATE SEQUENCE public.lote_id_lote_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.lote_id_lote_seq;
       public       postgres    false    207            �           0    0    lote_id_lote_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.lote_id_lote_seq OWNED BY public.lote.id_lote;
            public       postgres    false    208            �            1259    29735 	   mort_lote    TABLE     �   CREATE TABLE public.mort_lote (
    fecha timestamp without time zone NOT NULL,
    id_lote integer NOT NULL,
    cantidad_defuncion integer DEFAULT 0
);
    DROP TABLE public.mort_lote;
       public         postgres    false            �            1259    29739    rol    TABLE     �   CREATE TABLE public.rol (
    id_rol integer NOT NULL,
    nombre character varying(50) NOT NULL,
    permisos character varying(255)[]
);
    DROP TABLE public.rol;
       public         postgres    false            �            1259    29745    rol_id_rol_seq    SEQUENCE     �   CREATE SEQUENCE public.rol_id_rol_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.rol_id_rol_seq;
       public       postgres    false    210            �           0    0    rol_id_rol_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.rol_id_rol_seq OWNED BY public.rol.id_rol;
            public       postgres    false    211            �            1259    29747    usuario    TABLE        CREATE TABLE public.usuario (
    id_user integer NOT NULL,
    nombre_usuario character varying(40) NOT NULL,
    "contraseña" character varying(70) NOT NULL,
    error smallint DEFAULT 0,
    hora timestamp without time zone,
    bloqueado boolean DEFAULT false,
    id_rol integer
);
    DROP TABLE public.usuario;
       public         postgres    false            �            1259    29752    usuario_id_user_seq    SEQUENCE     �   CREATE SEQUENCE public.usuario_id_user_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.usuario_id_user_seq;
       public       postgres    false    212            �           0    0    usuario_id_user_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.usuario_id_user_seq OWNED BY public.usuario.id_user;
            public       postgres    false    213            �            1259    29754    vacuna    TABLE     �   CREATE TABLE public.vacuna (
    id_vac integer NOT NULL,
    nombre character varying(255) NOT NULL,
    descripcion character varying(255)
);
    DROP TABLE public.vacuna;
       public         postgres    false            �            1259    29760    vacuna_id_vac_seq    SEQUENCE     �   CREATE SEQUENCE public.vacuna_id_vac_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.vacuna_id_vac_seq;
       public       postgres    false    214            �           0    0    vacuna_id_vac_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.vacuna_id_vac_seq OWNED BY public.vacuna.id_vac;
            public       postgres    false    215            �
           2604    29916    alimentacion id_alim    DEFAULT     |   ALTER TABLE ONLY public.alimentacion ALTER COLUMN id_alim SET DEFAULT nextval('public.alimentacion_id_alim_seq'::regclass);
 C   ALTER TABLE public.alimentacion ALTER COLUMN id_alim DROP DEFAULT;
       public       postgres    false    225    224    225            �
           2604    29762    ave id    DEFAULT     `   ALTER TABLE ONLY public.ave ALTER COLUMN id SET DEFAULT nextval('public.ave_id_seq'::regclass);
 5   ALTER TABLE public.ave ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    198    197            �
           2604    29763    bitacora id_log    DEFAULT     r   ALTER TABLE ONLY public.bitacora ALTER COLUMN id_log SET DEFAULT nextval('public.bitacora_id_log_seq'::regclass);
 >   ALTER TABLE public.bitacora ALTER COLUMN id_log DROP DEFAULT;
       public       postgres    false    200    199            �
           2604    29764    cuarentena id_cuar    DEFAULT     x   ALTER TABLE ONLY public.cuarentena ALTER COLUMN id_cuar SET DEFAULT nextval('public.cuarentena_id_cuar_seq'::regclass);
 A   ALTER TABLE public.cuarentena ALTER COLUMN id_cuar DROP DEFAULT;
       public       postgres    false    202    201            �
           2604    29827    enfermedad id_enf    DEFAULT     v   ALTER TABLE ONLY public.enfermedad ALTER COLUMN id_enf SET DEFAULT nextval('public.enfermedad_id_enf_seq'::regclass);
 @   ALTER TABLE public.enfermedad ALTER COLUMN id_enf DROP DEFAULT;
       public       postgres    false    217    216    217            �
           2604    29765    galpon id_galpon    DEFAULT     t   ALTER TABLE ONLY public.galpon ALTER COLUMN id_galpon SET DEFAULT nextval('public.galpon_id_galpon_seq'::regclass);
 ?   ALTER TABLE public.galpon ALTER COLUMN id_galpon DROP DEFAULT;
       public       postgres    false    204    203            �
           2604    29766    galpon_vacuna id    DEFAULT     t   ALTER TABLE ONLY public.galpon_vacuna ALTER COLUMN id SET DEFAULT nextval('public.galpon_vacuna_id_seq'::regclass);
 ?   ALTER TABLE public.galpon_vacuna ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    206    205            �
           2604    29888    huevo id_huevo    DEFAULT     p   ALTER TABLE ONLY public.huevo ALTER COLUMN id_huevo SET DEFAULT nextval('public.huevo_id_huevo_seq'::regclass);
 =   ALTER TABLE public.huevo ALTER COLUMN id_huevo DROP DEFAULT;
       public       postgres    false    223    222    223            �
           2604    29861    incubacion id_incub    DEFAULT     z   ALTER TABLE ONLY public.incubacion ALTER COLUMN id_incub SET DEFAULT nextval('public.incubacion_id_incub_seq'::regclass);
 B   ALTER TABLE public.incubacion ALTER COLUMN id_incub DROP DEFAULT;
       public       postgres    false    221    220    221            �
           2604    29838    incubadora id_inc    DEFAULT     v   ALTER TABLE ONLY public.incubadora ALTER COLUMN id_inc SET DEFAULT nextval('public.incubadora_id_inc_seq'::regclass);
 @   ALTER TABLE public.incubadora ALTER COLUMN id_inc DROP DEFAULT;
       public       postgres    false    219    218    219            �
           2604    29767    lote id_lote    DEFAULT     l   ALTER TABLE ONLY public.lote ALTER COLUMN id_lote SET DEFAULT nextval('public.lote_id_lote_seq'::regclass);
 ;   ALTER TABLE public.lote ALTER COLUMN id_lote DROP DEFAULT;
       public       postgres    false    208    207            �
           2604    29768 
   rol id_rol    DEFAULT     h   ALTER TABLE ONLY public.rol ALTER COLUMN id_rol SET DEFAULT nextval('public.rol_id_rol_seq'::regclass);
 9   ALTER TABLE public.rol ALTER COLUMN id_rol DROP DEFAULT;
       public       postgres    false    211    210            �
           2604    29769    usuario id_user    DEFAULT     r   ALTER TABLE ONLY public.usuario ALTER COLUMN id_user SET DEFAULT nextval('public.usuario_id_user_seq'::regclass);
 >   ALTER TABLE public.usuario ALTER COLUMN id_user DROP DEFAULT;
       public       postgres    false    213    212            �
           2604    29770    vacuna id_vac    DEFAULT     n   ALTER TABLE ONLY public.vacuna ALTER COLUMN id_vac SET DEFAULT nextval('public.vacuna_id_vac_seq'::regclass);
 <   ALTER TABLE public.vacuna ALTER COLUMN id_vac DROP DEFAULT;
       public       postgres    false    215    214            �          0    29913    alimentacion 
   TABLE DATA               U   COPY public.alimentacion (id_alim, fecha, alimento, cantidad, id_galpon) FROM stdin;
    public       postgres    false    225   �       �          0    29696    ambiente 
   TABLE DATA               J   COPY public.ambiente (id_galpon, fecha, temperatura, humedad) FROM stdin;
    public       postgres    false    196   �       �          0    29699    ave 
   TABLE DATA               *   COPY public.ave (id, especie) FROM stdin;
    public       postgres    false    197   n       �          0    29704    bitacora 
   TABLE DATA               F   COPY public.bitacora (id_log, username, fecha, operacion) FROM stdin;
    public       postgres    false    199   �       �          0    29712 
   cuarentena 
   TABLE DATA               \   COPY public.cuarentena (id_cuar, fecha_ingreso, fecha_salida, razon, id_galpon) FROM stdin;
    public       postgres    false    201   �       �          0    29824 
   enfermedad 
   TABLE DATA               =   COPY public.enfermedad (id_enf, nombre, sintoma) FROM stdin;
    public       postgres    false    217   �       �          0    29717    galpon 
   TABLE DATA               [   COPY public.galpon (id_galpon, dimension, capacidad, capacidad_libre, en_cuar) FROM stdin;
    public       postgres    false    203   �       �          0    29723    galpon_vacuna 
   TABLE DATA               E   COPY public.galpon_vacuna (id, id_galpon, id_vac, fecha) FROM stdin;
    public       postgres    false    205   ,       �          0    29885    huevo 
   TABLE DATA               Q   COPY public.huevo (id_huevo, fec_coleccion, bueno, podrido, id_lote) FROM stdin;
    public       postgres    false    223   d       �          0    29858 
   incubacion 
   TABLE DATA               u   COPY public.incubacion (id_incub, inicio, finalizacion, nro_huevos, nro_eclosionado, finalizado, id_inc) FROM stdin;
    public       postgres    false    221   �       �          0    29835 
   incubadora 
   TABLE DATA               8   COPY public.incubadora (id_inc, disponible) FROM stdin;
    public       postgres    false    219   
       �          0    29728    lote 
   TABLE DATA               �   COPY public.lote (id_lote, nombre, cantidad, mortalidad, fecha_ingreso, origen, fecha_salida, destino, descripcion, archivado, id_ave, id_galpon) FROM stdin;
    public       postgres    false    207   1       �          0    29735 	   mort_lote 
   TABLE DATA               G   COPY public.mort_lote (fecha, id_lote, cantidad_defuncion) FROM stdin;
    public       postgres    false    209   �       �          0    29739    rol 
   TABLE DATA               7   COPY public.rol (id_rol, nombre, permisos) FROM stdin;
    public       postgres    false    210   �       �          0    29747    usuario 
   TABLE DATA               i   COPY public.usuario (id_user, nombre_usuario, "contraseña", error, hora, bloqueado, id_rol) FROM stdin;
    public       postgres    false    212   �       �          0    29754    vacuna 
   TABLE DATA               =   COPY public.vacuna (id_vac, nombre, descripcion) FROM stdin;
    public       postgres    false    214   �       �           0    0    alimentacion_id_alim_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.alimentacion_id_alim_seq', 1, true);
            public       postgres    false    224            �           0    0 
   ave_id_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.ave_id_seq', 4, true);
            public       postgres    false    198            �           0    0    bitacora_id_log_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.bitacora_id_log_seq', 60, true);
            public       postgres    false    200            �           0    0    cuarentena_id_cuar_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.cuarentena_id_cuar_seq', 3, true);
            public       postgres    false    202            �           0    0    enfermedad_id_enf_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.enfermedad_id_enf_seq', 3, true);
            public       postgres    false    216            �           0    0    galpon_id_galpon_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.galpon_id_galpon_seq', 5, true);
            public       postgres    false    204            �           0    0    galpon_vacuna_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.galpon_vacuna_id_seq', 12, true);
            public       postgres    false    206            �           0    0    huevo_id_huevo_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.huevo_id_huevo_seq', 4, true);
            public       postgres    false    222            �           0    0    incubacion_id_incub_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.incubacion_id_incub_seq', 4, true);
            public       postgres    false    220            �           0    0    incubadora_id_inc_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.incubadora_id_inc_seq', 3, true);
            public       postgres    false    218            �           0    0    lote_id_lote_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.lote_id_lote_seq', 7, true);
            public       postgres    false    208            �           0    0    rol_id_rol_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.rol_id_rol_seq', 2, true);
            public       postgres    false    211            �           0    0    usuario_id_user_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.usuario_id_user_seq', 8, true);
            public       postgres    false    213            �           0    0    vacuna_id_vac_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.vacuna_id_vac_seq', 5, true);
            public       postgres    false    215                       2606    29918    alimentacion alimentacion_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.alimentacion
    ADD CONSTRAINT alimentacion_pkey PRIMARY KEY (id_alim);
 H   ALTER TABLE ONLY public.alimentacion DROP CONSTRAINT alimentacion_pkey;
       public         postgres    false    225            �
           2606    29772    ambiente ambiente_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.ambiente
    ADD CONSTRAINT ambiente_pkey PRIMARY KEY (id_galpon, fecha);
 @   ALTER TABLE ONLY public.ambiente DROP CONSTRAINT ambiente_pkey;
       public         postgres    false    196    196            �
           2606    29774    ave ave_pkey 
   CONSTRAINT     J   ALTER TABLE ONLY public.ave
    ADD CONSTRAINT ave_pkey PRIMARY KEY (id);
 6   ALTER TABLE ONLY public.ave DROP CONSTRAINT ave_pkey;
       public         postgres    false    197            �
           2606    29776    bitacora bitacora_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.bitacora
    ADD CONSTRAINT bitacora_pkey PRIMARY KEY (id_log);
 @   ALTER TABLE ONLY public.bitacora DROP CONSTRAINT bitacora_pkey;
       public         postgres    false    199            �
           2606    29778    cuarentena cuarentena_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.cuarentena
    ADD CONSTRAINT cuarentena_pkey PRIMARY KEY (id_cuar);
 D   ALTER TABLE ONLY public.cuarentena DROP CONSTRAINT cuarentena_pkey;
       public         postgres    false    201                       2606    29832    enfermedad enfermedad_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.enfermedad
    ADD CONSTRAINT enfermedad_pkey PRIMARY KEY (id_enf);
 D   ALTER TABLE ONLY public.enfermedad DROP CONSTRAINT enfermedad_pkey;
       public         postgres    false    217            �
           2606    29780    galpon galpon_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.galpon
    ADD CONSTRAINT galpon_pkey PRIMARY KEY (id_galpon);
 <   ALTER TABLE ONLY public.galpon DROP CONSTRAINT galpon_pkey;
       public         postgres    false    203                       2606    29890    huevo huevo_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.huevo
    ADD CONSTRAINT huevo_pkey PRIMARY KEY (id_huevo);
 :   ALTER TABLE ONLY public.huevo DROP CONSTRAINT huevo_pkey;
       public         postgres    false    223                       2606    29864    incubacion incubacion_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.incubacion
    ADD CONSTRAINT incubacion_pkey PRIMARY KEY (id_incub);
 D   ALTER TABLE ONLY public.incubacion DROP CONSTRAINT incubacion_pkey;
       public         postgres    false    221                       2606    29841    incubadora incubadora_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.incubadora
    ADD CONSTRAINT incubadora_pkey PRIMARY KEY (id_inc);
 D   ALTER TABLE ONLY public.incubadora DROP CONSTRAINT incubadora_pkey;
       public         postgres    false    219                       2606    29782    lote lote_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.lote
    ADD CONSTRAINT lote_pkey PRIMARY KEY (id_lote);
 8   ALTER TABLE ONLY public.lote DROP CONSTRAINT lote_pkey;
       public         postgres    false    207                       2606    29784    mort_lote mort_lote_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.mort_lote
    ADD CONSTRAINT mort_lote_pkey PRIMARY KEY (fecha, id_lote);
 B   ALTER TABLE ONLY public.mort_lote DROP CONSTRAINT mort_lote_pkey;
       public         postgres    false    209    209                       2606    29786    rol rol_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id_rol);
 6   ALTER TABLE ONLY public.rol DROP CONSTRAINT rol_pkey;
       public         postgres    false    210                       2606    29788 "   usuario usuario_nombre_usuario_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_nombre_usuario_key UNIQUE (nombre_usuario);
 L   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_nombre_usuario_key;
       public         postgres    false    212            	           2606    29790    usuario usuario_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_user);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public         postgres    false    212                       2606    29792    vacuna vacuna_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.vacuna
    ADD CONSTRAINT vacuna_pkey PRIMARY KEY (id_vac);
 <   ALTER TABLE ONLY public.vacuna DROP CONSTRAINT vacuna_pkey;
       public         postgres    false    214                        2620    29793    usuario error_trigger    TRIGGER     �   CREATE TRIGGER error_trigger BEFORE INSERT OR UPDATE ON public.usuario FOR EACH ROW WHEN ((new.error = 3)) EXECUTE PROCEDURE public.check_error_trigger();
 .   DROP TRIGGER error_trigger ON public.usuario;
       public       postgres    false    241    212    212                       2620    29794    lote trg_archivado_lote    TRIGGER     �   CREATE TRIGGER trg_archivado_lote BEFORE UPDATE OF fecha_salida ON public.lote FOR EACH ROW EXECUTE PROCEDURE public.fn_archivado_lote();
 0   DROP TRIGGER trg_archivado_lote ON public.lote;
       public       postgres    false    242    207    207                       2620    29795    lote trg_cantidad_libre_galpon    TRIGGER     �   CREATE TRIGGER trg_cantidad_libre_galpon BEFORE UPDATE OF id_galpon ON public.lote FOR EACH ROW EXECUTE PROCEDURE public.fn_cantidad_libre_galpon();
 7   DROP TRIGGER trg_cantidad_libre_galpon ON public.lote;
       public       postgres    false    243    207    207                       2620    29796     cuarentena trg_cuarentena_galpon    TRIGGER     �   CREATE TRIGGER trg_cuarentena_galpon BEFORE UPDATE OF fecha_salida ON public.cuarentena FOR EACH ROW EXECUTE PROCEDURE public.fn_cuarentena_galpon();
 9   DROP TRIGGER trg_cuarentena_galpon ON public.cuarentena;
       public       postgres    false    201    244    201                       2620    29797 $   cuarentena trg_cuarentena_galpon_ins    TRIGGER     �   CREATE TRIGGER trg_cuarentena_galpon_ins AFTER INSERT ON public.cuarentena FOR EACH ROW EXECUTE PROCEDURE public.fn_cuarentena_galpon_ins();
 =   DROP TRIGGER trg_cuarentena_galpon_ins ON public.cuarentena;
       public       postgres    false    201    245                       2620    29798     mort_lote trg_defuncion_ambiente    TRIGGER     �   CREATE TRIGGER trg_defuncion_ambiente BEFORE INSERT OR UPDATE OF cantidad_defuncion ON public.mort_lote FOR EACH ROW EXECUTE PROCEDURE public.fn_defuncion_ambiente();
 9   DROP TRIGGER trg_defuncion_ambiente ON public.mort_lote;
       public       postgres    false    209    246    209            "           2620    29897    incubacion trg_incubadora_disp    TRIGGER     �   CREATE TRIGGER trg_incubadora_disp AFTER UPDATE OF finalizado ON public.incubacion FOR EACH ROW EXECUTE PROCEDURE public.fn_incubadora_disp();
 7   DROP TRIGGER trg_incubadora_disp ON public.incubacion;
       public       postgres    false    221    226    221            !           2620    29799 "   usuario trigger_actualizar_usuario    TRIGGER     �   CREATE TRIGGER trigger_actualizar_usuario BEFORE UPDATE OF "contraseña" ON public.usuario FOR EACH ROW EXECUTE PROCEDURE public.actualizar_usuario();
 ;   DROP TRIGGER trigger_actualizar_usuario ON public.usuario;
       public       postgres    false    212    227    212                       2606    29919 (   alimentacion alimentacion_id_galpon_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.alimentacion
    ADD CONSTRAINT alimentacion_id_galpon_fkey FOREIGN KEY (id_galpon) REFERENCES public.galpon(id_galpon);
 R   ALTER TABLE ONLY public.alimentacion DROP CONSTRAINT alimentacion_id_galpon_fkey;
       public       postgres    false    2815    225    203                       2606    29891    huevo huevo_id_lote_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY public.huevo
    ADD CONSTRAINT huevo_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote);
 B   ALTER TABLE ONLY public.huevo DROP CONSTRAINT huevo_id_lote_fkey;
       public       postgres    false    223    2817    207                       2606    29865 !   incubacion incubacion_id_inc_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.incubacion
    ADD CONSTRAINT incubacion_id_inc_fkey FOREIGN KEY (id_inc) REFERENCES public.incubadora(id_inc);
 K   ALTER TABLE ONLY public.incubacion DROP CONSTRAINT incubacion_id_inc_fkey;
       public       postgres    false    2831    219    221                       2606    29800     mort_lote mort_lote_id_lote_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mort_lote
    ADD CONSTRAINT mort_lote_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote);
 J   ALTER TABLE ONLY public.mort_lote DROP CONSTRAINT mort_lote_id_lote_fkey;
       public       postgres    false    207    209    2817                       2606    29805    usuario usuario_id_rol_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES public.rol(id_rol);
 E   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_id_rol_fkey;
       public       postgres    false    210    212    2821           