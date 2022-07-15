-- PostgreSQL database dump
-- Urban fluctuations in the north-central region of the Nile Delta:
-- 4000 years of river and urban development in Egypt.
-- Israel Hinojosa Baliño (2022)
-- Dumped from database version 12.11
-- Dumped by pg_dump version 14.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: f_ishiba_create_geom(); Type: FUNCTION; Schema: public; Owner: ishiba
--

CREATE FUNCTION public.f_ishiba_create_geom() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF
(NEW.longitude IS DISTINCT FROM OLD.longitude OR NEW.latitude IS DISTINCT FROM OLD.latitude
)
THEN
    NEW.geom = (st_transform(st_setsrid(st_makepoint(NEW.longitude::float8,NEW.latitude::float8),4326),32636));
    NEW.easting = (st_x(NEW.geom));
    NEW.northing = (st_y(NEW.geom));
ELSIF
(NEW.easting IS DISTINCT FROM OLD.easting OR NEW.northing IS DISTINCT FROM OLD.northing
)
THEN
    NEW.geom = st_setsrid(st_makepoint(NEW.easting::float8, NEW.northing::float8), 32636);
    NEW.longitude = (st_x(st_transform(st_setsrid((NEW.geom),32636),4326)));
    NEW.latitude = (st_y(st_transform(st_setsrid((NEW.geom),32636),4326)));
ELSIF
(NEW.geom IS DISTINCT FROM OLD.geom
)
THEN
    NEW.longitude = (st_x(st_transform(st_setsrid((NEW.geom),32636),4326)));
    NEW.latitude = (st_y(st_transform(st_setsrid((NEW.geom),32636),4326)));
    NEW.easting = (st_x(NEW.geom));
    NEW.northing = (st_y(NEW.geom));
END IF;
RETURN new;
END;
$$;


ALTER FUNCTION public.f_ishiba_create_geom() OWNER TO postgres;

--
-- Name: FUNCTION f_ishiba_create_geom(); Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON FUNCTION public.f_ishiba_create_geom() IS 'This function populates LonLat if input UTM, or conversely populate UTM if input LonLat. Then create point geometry in UTM 36N WGS84 using input values OR Updates LonLat and UTM if Geometry changes';


--
-- Name: f_ishiba_exceptions_add(); Type: FUNCTION; Schema: public; Owner: ishiba
--

CREATE FUNCTION public.f_ishiba_exceptions_add() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF (NEW.name IS NULL) THEN
   RAISE EXCEPTION 'You have to add at least the name of the site';
END IF;
IF (NEW.geom IS NULL) THEN
   RAISE EXCEPTION 'For this database, you need a location, either add coordinates manually (LonLat or UTM) or with a GIS program. Please note that the datum is WGS84, 36N.';
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.f_ishiba_exceptions_add() OWNER TO postgres;

--
-- Name: FUNCTION f_ishiba_exceptions_add(); Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON FUNCTION public.f_ishiba_exceptions_add() IS 'Raise warning messages if no name or geometry is added when creating new site';


--
-- Name: f_ishiba_populatewith_geom(); Type: FUNCTION; Schema: public; Owner: ishiba
--

CREATE FUNCTION public.f_ishiba_populatewith_geom() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF NEW.geom IS NOT NULL THEN
    NEW.longitude = (st_x(st_transform(st_setsrid((NEW.geom),32636),4326)));
    NEW.latitude = (st_y(st_transform(st_setsrid((NEW.geom),32636),4326)));
    NEW.easting = (st_x(NEW.geom));
    NEW.northing = (st_y(NEW.geom));
END IF;
RETURN new;
END;
$$;


ALTER FUNCTION public.f_ishiba_populatewith_geom() OWNER TO postgres;

--
-- Name: FUNCTION f_ishiba_populatewith_geom(); Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON FUNCTION public.f_ishiba_populatewith_geom() IS 'This function populate LonLat and UTM if the point is added directly in a GIS program';


--
-- Name: f_ishiba_update_xy(); Type: FUNCTION; Schema: public; Owner: ishiba
--

CREATE FUNCTION public.f_ishiba_update_xy() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF NEW.longitude IS NOT NULL THEN
        NEW.geom = (st_transform(st_setsrid(st_makepoint(NEW.longitude::float8,NEW.latitude::float8),4326),32636));
        NEW.easting = (st_x(NEW.geom));
NEW.northing = (st_y(NEW.geom));
  ELSIF NEW.easting IS NOT NULL THEN
        NEW.geom = st_setsrid(st_makepoint(NEW."easting"::float8, NEW."northing"::float8), 32636);
        NEW.longitude = (st_x(st_transform(st_setsrid((NEW.geom),32636),4326)));
NEW.latitude = (st_y(st_transform(st_setsrid((NEW.geom),32636),4326)));
   end if;
RETURN new;
END;
$$;


ALTER FUNCTION public.f_ishiba_update_xy() OWNER TO postgres;

--
-- Name: FUNCTION f_ishiba_update_xy(); Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON FUNCTION public.f_ishiba_update_xy() IS 'This function update LanLon or UTM, if one or the other are corrected. This also updates the geometry';

--
-- Name: eessite_id_seq; Type: SEQUENCE; Schema: public; Owner: ishiba
--

CREATE SEQUENCE public.eessite_id_seq
    START WITH 745
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.eessite_id_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: eessite; Type: TABLE; Schema: public; Owner: ishiba
--

CREATE TABLE public.eessite (
    id integer DEFAULT nextval('public.eessite_id_seq'::regclass) NOT NULL,
    name character varying(254),
    capital character(1),
    nomant01 character varying(255),
    nomant02 character varying(255),
    location character varying(254),
    extent character varying(254),
    no_ double precision,
    notes text,
    literature text,
    latitudedm character varying(254),
    longituded character varying(254),
    latitude double precision,
    longitude double precision,
    fieldsy character varying(25),
    site character varying(50),
    easting double precision,
    northing double precision,
    update character(1),
    geom public.geometry(Point,32636)
)
WITH (autovacuum_enabled='true');


ALTER TABLE public.eessite OWNER TO postgres;

--
-- Name: COLUMN eessite.id; Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON COLUMN public.eessite.id IS 'consecutivo';


--
-- Name: governors; Type: TABLE; Schema: public; Owner: ishiba
--

CREATE TABLE public.governors (
    id integer NOT NULL,
    govid character varying(255),
    shortper_id integer,
    shortperids character varying(255),
    lonperiod character varying(255),
    medperiod character varying(255),
    shoperiod character varying(255),
    rulers character varying(255),
    govttype character varying(255),
    "advisor " character varying(255),
    notes1 character varying(255),
    year01 double precision,
    year02 character varying(255),
    notes2 character varying(255),
    capital character varying(255),
    notes3years character varying(255)
);


ALTER TABLE public.governors OWNER TO postgres;

--
-- Name: COLUMN governors."advisor "; Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON COLUMN public.governors."advisor " IS 'cihuacoatl';


--
-- Name: COLUMN governors.year02; Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON COLUMN public.governors.year02 IS 'e.g. Hijr';


--
-- Name: lonper; Type: TABLE; Schema: public; Owner: ishiba
--

CREATE TABLE public.lonper (
    id integer NOT NULL,
    idtext character varying(255),
    idkey integer,
    lonperiod character varying(255)
);


ALTER TABLE public.lonper OWNER TO postgres;

--
-- Name: medper; Type: TABLE; Schema: public; Owner: ishiba
--

CREATE TABLE public.medper (
    id integer NOT NULL,
    idtext character varying(255),
    idkey integer,
    lonperiod character varying(255),
    idmed character varying(255),
    medperiod character varying(255),
    idmedf character varying(255),
    startdate date,
    enddate date,
    startdaypositive date,
    enddaypositive date,
    starcheo character(7),
    enarcheo character(7),
    startjs character(13),
    endjs character(13)
);


ALTER TABLE public.medper OWNER TO postgres;

--
-- Name: temporality; Type: TABLE; Schema: public; Owner: ishiba
--

CREATE TABLE public.temporality (
    idsite integer,
    idlon integer DEFAULT 0 NOT NULL,
    idmed integer DEFAULT 0 NOT NULL,
    idshort integer DEFAULT 0 NOT NULL,
    idgov integer DEFAULT 0 NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE public.temporality OWNER TO postgres;

--
-- Name: COLUMN temporality.id; Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON COLUMN public.temporality.id IS 'consecutivo';


--
-- Name: medarcheomode; Type: VIEW; Schema: public; Owner: ishiba
--

CREATE VIEW public.medarcheomode AS
 SELECT temporality.id,
    eessite.name,
    lonper.lonperiod,
    medper.medperiod,
    medper.startdaypositive,
    medper.enddaypositive,
    medper.starcheo,
    medper.enarcheo,
    eessite.geom,
    eessite.id AS eesid
   FROM public.eessite,
    public.temporality,
    public.lonper,
    public.medper
  WHERE ((eessite.id = temporality.idsite) AND (temporality.idmed = medper.id) AND (lonper.id = temporality.idlon));


ALTER TABLE public.medarcheomode OWNER TO postgres;

--
-- Name: medarcheomodid; Type: VIEW; Schema: public; Owner: ishiba
--

CREATE VIEW public.medarcheomodid AS
 SELECT temporality.id AS idtemp,
    eessite.no_ AS ideesof,
    eessite.id AS idint,
    eessite.name,
    lonper.lonperiod,
    medper.medperiod,
    medper.startdaypositive,
    medper.enddaypositive,
    medper.starcheo,
    medper.enarcheo,
    eessite.geom
   FROM public.eessite,
    public.temporality,
    public.lonper,
    public.medper
  WHERE ((eessite.id = temporality.idsite) AND (temporality.idmed = medper.id) AND (lonper.id = temporality.idlon));


ALTER TABLE public.medarcheomodid OWNER TO postgres;

--
-- Name: medperiodtime; Type: VIEW; Schema: public; Owner: ishiba
--

CREATE VIEW public.medperiodtime AS
 SELECT temporality.id AS "Id",
    eessite.name AS "Name",
    lonper.lonperiod AS "LonPeriod",
    medper.medperiod AS "MedPeriod",
    medper.startdaypositive,
    medper.enddaypositive,
    eessite.geom
   FROM public.eessite,
    public.temporality,
    public.lonper,
    public.medper
  WHERE ((eessite.id = temporality.idsite) AND (temporality.idmed = medper.id) AND (lonper.id = temporality.idlon));


ALTER TABLE public.medperiodtime OWNER TO postgres;

--
-- Name: shortper; Type: TABLE; Schema: public; Owner: ishiba
--

CREATE TABLE public.shortper (
    id integer NOT NULL,
    idkey character varying(255),
    lonperiod character varying(255),
    idmedtext character varying(255),
    idmedn integer,
    idmedf character varying(255),
    medperiod character varying(255),
    idshort character varying(255),
    shoperiod character varying(255),
    idshortf character varying(255)
);


ALTER TABLE public.shortper OWNER TO postgres;

--
-- Name: temporality_id_seq; Type: SEQUENCE; Schema: public; Owner: ishiba
--

CREATE SEQUENCE public.temporality_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.temporality_id_seq OWNER TO postgres;

--
-- Name: temporality_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ishiba
--

ALTER SEQUENCE public.temporality_id_seq OWNED BY public.temporality.id;


--
-- Name: temporalitytest; Type: TABLE; Schema: public; Owner: ishiba
--

CREATE TABLE public.temporalitytest (
)
INHERITS (public.temporality);


ALTER TABLE public.temporalitytest OWNER TO postgres;

--
-- Name: test; Type: VIEW; Schema: public; Owner: ishiba
--

CREATE VIEW public.test AS
 SELECT eessite.id AS idint,
    temporality.id,
    medper.medperiod AS content,
    medper.startjs AS start,
    medper.endjs AS "end"
   FROM public.eessite,
    public.temporality,
    public.lonper,
    public.medper
  WHERE ((eessite.id = temporality.idsite) AND (temporality.idmed = medper.id) AND (lonper.id = temporality.idlon));


ALTER TABLE public.test OWNER TO postgres;

--
-- Name: timeline; Type: VIEW; Schema: public; Owner: ishiba
--

CREATE VIEW public.timeline AS
 SELECT eessite.id AS idint,
    temporality.id,
    medper.medperiod AS content,
    medper.startjs AS start,
    medper.endjs AS "end"
   FROM public.eessite,
    public.temporality,
    public.lonper,
    public.medper
  WHERE ((eessite.id = temporality.idsite) AND (temporality.idmed = medper.id) AND (lonper.id = temporality.idlon));


ALTER TABLE public.timeline OWNER TO postgres;

--
-- Name: temporality id; Type: DEFAULT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporality ALTER COLUMN id SET DEFAULT nextval('public.temporality_id_seq'::regclass);


--
-- Name: temporalitytest idlon; Type: DEFAULT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporalitytest ALTER COLUMN idlon SET DEFAULT 0;


--
-- Name: temporalitytest idmed; Type: DEFAULT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporalitytest ALTER COLUMN idmed SET DEFAULT 0;


--
-- Name: temporalitytest idshort; Type: DEFAULT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporalitytest ALTER COLUMN idshort SET DEFAULT 0;


--
-- Name: temporalitytest idgov; Type: DEFAULT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporalitytest ALTER COLUMN idgov SET DEFAULT 0;


--
-- Name: temporalitytest id; Type: DEFAULT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporalitytest ALTER COLUMN id SET DEFAULT nextval('public.temporality_id_seq'::regclass);


--
-- Name: governors IdGovs; Type: CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.governors
    ADD CONSTRAINT "IdGovs" PRIMARY KEY (id);


--
-- Name: lonper IdLonPer; Type: CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.lonper
    ADD CONSTRAINT "IdLonPer" PRIMARY KEY (id);


--
-- Name: medper IdMedPer; Type: CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.medper
    ADD CONSTRAINT "IdMedPer" PRIMARY KEY (id);


--
-- Name: shortper IdShortPer; Type: CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.shortper
    ADD CONSTRAINT "IdShortPer" PRIMARY KEY (id);


--
-- Name: eessite PrimaryKey; Type: CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.eessite
    ADD CONSTRAINT "PrimaryKey" PRIMARY KEY (id);


--
-- Name: temporality TemporalityID; Type: CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporality
    ADD CONSTRAINT "TemporalityID" PRIMARY KEY (id);


--
-- Name: eessite t_ishiba_create_geom; Type: TRIGGER; Schema: public; Owner: ishiba
--

CREATE TRIGGER t_ishiba_create_geom BEFORE UPDATE ON public.eessite FOR EACH ROW EXECUTE FUNCTION public.f_ishiba_create_geom();


--
-- Name: TRIGGER t_ishiba_create_geom ON eessite; Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON TRIGGER t_ishiba_create_geom ON public.eessite IS 'Populate LonLat if input UTM, or conversely populate UTM if input LonLat. Creates point geometry in UTM 36N WGS84 per row using input values. Update LonLat and UTM if Geometry changes';


--
-- Name: eessite t_ishiba_exceptions_add; Type: TRIGGER; Schema: public; Owner: ishiba
--

CREATE TRIGGER t_ishiba_exceptions_add AFTER INSERT ON public.eessite FOR EACH ROW EXECUTE FUNCTION public.f_ishiba_exceptions_add();


--
-- Name: TRIGGER t_ishiba_exceptions_add ON eessite; Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON TRIGGER t_ishiba_exceptions_add ON public.eessite IS 'Trigger warning messages if no name or geometry is added when creating new site';


--
-- Name: eessite t_ishiba_populatewith_geom; Type: TRIGGER; Schema: public; Owner: ishiba
--

CREATE TRIGGER t_ishiba_populatewith_geom BEFORE INSERT ON public.eessite FOR EACH ROW EXECUTE FUNCTION public.f_ishiba_populatewith_geom();


--
-- Name: TRIGGER t_ishiba_populatewith_geom ON eessite; Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON TRIGGER t_ishiba_populatewith_geom ON public.eessite IS 'Populate LonLat and UTM if the point is added directly in a GIS program';


--
-- Name: eessite t_ishiba_update_xy; Type: TRIGGER; Schema: public; Owner: ishiba
--

CREATE TRIGGER t_ishiba_update_xy BEFORE INSERT ON public.eessite FOR EACH ROW EXECUTE FUNCTION public.f_ishiba_update_xy();


--
-- Name: TRIGGER t_ishiba_update_xy ON eessite; Type: COMMENT; Schema: public; Owner: ishiba
--

COMMENT ON TRIGGER t_ishiba_update_xy ON public.eessite IS 'Update LonLat or E,N if one or the other are corrected. Update geom';


--
-- Name: temporality EESsitesToTemp; Type: FK CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporality
    ADD CONSTRAINT "EESsitesToTemp" FOREIGN KEY (idsite) REFERENCES public.eessite(id);


--
-- Name: temporality GovsToTemp; Type: FK CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporality
    ADD CONSTRAINT "GovsToTemp" FOREIGN KEY (idgov) REFERENCES public.governors(id);


--
-- Name: medper LonPerToMed; Type: FK CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.medper
    ADD CONSTRAINT "LonPerToMed" FOREIGN KEY (idkey) REFERENCES public.lonper(id);


--
-- Name: temporality LonPerToTemp; Type: FK CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporality
    ADD CONSTRAINT "LonPerToTemp" FOREIGN KEY (idlon) REFERENCES public.lonper(id);


--
-- Name: shortper MedPerToShort; Type: FK CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.shortper
    ADD CONSTRAINT "MedPerToShort" FOREIGN KEY (idmedn) REFERENCES public.medper(id);


--
-- Name: temporality MedPerToTemp; Type: FK CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporality
    ADD CONSTRAINT "MedPerToTemp" FOREIGN KEY (idmed) REFERENCES public.medper(id);


--
-- Name: medper MedPer_IDKey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.medper
    ADD CONSTRAINT "MedPer_IDKey_fkey" FOREIGN KEY (idkey) REFERENCES public.lonper(id);


--
-- Name: temporality ShortPerToTemp; Type: FK CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.temporality
    ADD CONSTRAINT "ShortPerToTemp" FOREIGN KEY (idshort) REFERENCES public.shortper(id);


--
-- Name: governors ShortPerToTemp; Type: FK CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.governors
    ADD CONSTRAINT "ShortPerToTemp" FOREIGN KEY (shortper_id) REFERENCES public.shortper(id);


--
-- Name: shortper ShortPer_IdMedN_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ishiba
--

ALTER TABLE ONLY public.shortper
    ADD CONSTRAINT "ShortPer_IdMedN_fkey" FOREIGN KEY (idmedn) REFERENCES public.medper(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: ishiba
--

REVOKE ALL ON SCHEMA public FROM postgres;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO postgres;


--
-- Name: TABLE spatial_ref_sys; Type: ACL; Schema: public; Owner: _root
--

GRANT ALL ON TABLE public.spatial_ref_sys TO postgres;


--
-- PostgreSQL database dump complete
--

