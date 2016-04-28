--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE account (
    account_id integer NOT NULL,
    username character varying(100),
    first_name character varying(100),
    last_name character varying(100),
    last_access timestamp without time zone,
    cookie_string text
);


ALTER TABLE account OWNER TO postgres;

--
-- Name: account_account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE account_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE account_account_id_seq OWNER TO postgres;

--
-- Name: account_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE account_account_id_seq OWNED BY account.account_id;


--
-- Name: cvterm; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cvterm (
    cvterm_id integer NOT NULL,
    name character varying(100),
    unit character varying(40),
    description character varying(100)
);


ALTER TABLE cvterm OWNER TO postgres;

--
-- Name: cvterm_cvterm_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cvterm_cvterm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cvterm_cvterm_id_seq OWNER TO postgres;

--
-- Name: cvterm_cvterm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cvterm_cvterm_id_seq OWNED BY cvterm.cvterm_id;


--
-- Name: file; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE file (
    file_id integer NOT NULL,
    filepath character varying(200),
    filename character varying(100),
    account_id bigint
);


ALTER TABLE file OWNER TO postgres;

--
-- Name: file_file_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE file_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE file_file_id_seq OWNER TO postgres;

--
-- Name: file_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE file_file_id_seq OWNED BY file.file_id;


--
-- Name: location; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE location (
    location_id integer NOT NULL,
    name character varying(100),
    geolocation point
);


ALTER TABLE location OWNER TO postgres;

--
-- Name: location_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE location_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE location_location_id_seq OWNER TO postgres;

--
-- Name: location_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE location_location_id_seq OWNED BY location.location_id;


--
-- Name: measurement; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE measurement (
    measurement_id integer NOT NULL,
    "time" timestamp without time zone,
    type_id bigint,
    value real,
    file_id bigint,
    sensor_id bigint
);


ALTER TABLE measurement OWNER TO postgres;

--
-- Name: measurement_measurement_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE measurement_measurement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE measurement_measurement_id_seq OWNER TO postgres;

--
-- Name: measurement_measurement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE measurement_measurement_id_seq OWNED BY measurement.measurement_id;


--
-- Name: sensor; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sensor (
    sensor_id integer NOT NULL,
    station_id integer NOT NULL
);


ALTER TABLE sensor OWNER TO postgres;

--
-- Name: station; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE station (
    station_id integer NOT NULL,
    name character varying(100),
    coordinates point,
    location_id bigint
);


ALTER TABLE station OWNER TO postgres;

--
-- Name: station_station_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE station_station_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE station_station_id_seq OWNER TO postgres;

--
-- Name: station_station_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE station_station_id_seq OWNED BY station.station_id;


--
-- Name: account_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY account ALTER COLUMN account_id SET DEFAULT nextval('account_account_id_seq'::regclass);


--
-- Name: cvterm_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cvterm ALTER COLUMN cvterm_id SET DEFAULT nextval('cvterm_cvterm_id_seq'::regclass);


--
-- Name: file_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY file ALTER COLUMN file_id SET DEFAULT nextval('file_file_id_seq'::regclass);


--
-- Name: location_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location ALTER COLUMN location_id SET DEFAULT nextval('location_location_id_seq'::regclass);


--
-- Name: measurement_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY measurement ALTER COLUMN measurement_id SET DEFAULT nextval('measurement_measurement_id_seq'::regclass);


--
-- Name: station_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY station ALTER COLUMN station_id SET DEFAULT nextval('station_station_id_seq'::regclass);


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY account (account_id, username, first_name, last_name, last_access, cookie_string) FROM stdin;
\.


--
-- Name: account_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('account_account_id_seq', 1, false);


--
-- Data for Name: cvterm; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY cvterm (cvterm_id, name, unit, description) FROM stdin;
12	temp	°C	Temperature
13	rh	%	Relative Humidity
14	dp	°C	Dew Point
16	rain	mm	Precipitation
15	intensity	LUX	Intensity
\.


--
-- Name: cvterm_cvterm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('cvterm_cvterm_id_seq', 16, true);


--
-- Data for Name: file; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY file (file_id, filepath, filename, account_id) FROM stdin;
\.


--
-- Name: file_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('file_file_id_seq', 11, true);


--
-- Data for Name: location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY location (location_id, name, geolocation) FROM stdin;
\.


--
-- Name: location_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('location_location_id_seq', 3, true);


--
-- Data for Name: measurement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY measurement (measurement_id, "time", type_id, value, file_id, sensor_id) FROM stdin;
\.


--
-- Name: measurement_measurement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('measurement_measurement_id_seq', 316273, true);


--
-- Data for Name: sensor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sensor (sensor_id, station_id) FROM stdin;
\.


--
-- Data for Name: station; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY station (station_id, name, coordinates, location_id) FROM stdin;
\.


--
-- Name: station_station_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('station_station_id_seq', 7, true);


--
-- Name: account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_pkey PRIMARY KEY (account_id);


--
-- Name: cvterm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cvterm
    ADD CONSTRAINT cvterm_pkey PRIMARY KEY (cvterm_id);


--
-- Name: file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_pkey PRIMARY KEY (file_id);


--
-- Name: location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY location
    ADD CONSTRAINT location_pkey PRIMARY KEY (location_id);


--
-- Name: measurement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY measurement
    ADD CONSTRAINT measurement_pkey PRIMARY KEY (measurement_id);


--
-- Name: sensor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sensor
    ADD CONSTRAINT sensor_pkey PRIMARY KEY (sensor_id);


--
-- Name: station_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY station
    ADD CONSTRAINT station_pkey PRIMARY KEY (station_id);


--
-- Name: file_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(account_id);


--
-- Name: measurement_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY measurement
    ADD CONSTRAINT measurement_file_id_fkey FOREIGN KEY (file_id) REFERENCES file(file_id);


--
-- Name: measurement_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY measurement
    ADD CONSTRAINT measurement_type_id_fkey FOREIGN KEY (type_id) REFERENCES cvterm(cvterm_id);


--
-- Name: station_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY station
    ADD CONSTRAINT station_location_id_fkey FOREIGN KEY (location_id) REFERENCES location(location_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: account; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE account FROM PUBLIC;
REVOKE ALL ON TABLE account FROM postgres;
GRANT ALL ON TABLE account TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE account TO web_usr;


--
-- Name: account_account_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE account_account_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE account_account_id_seq FROM postgres;
GRANT ALL ON SEQUENCE account_account_id_seq TO postgres;
GRANT USAGE ON SEQUENCE account_account_id_seq TO web_usr;


--
-- Name: cvterm; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE cvterm FROM PUBLIC;
REVOKE ALL ON TABLE cvterm FROM postgres;
GRANT ALL ON TABLE cvterm TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvterm TO web_usr;


--
-- Name: cvterm_cvterm_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE cvterm_cvterm_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cvterm_cvterm_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cvterm_cvterm_id_seq TO postgres;
GRANT USAGE ON SEQUENCE cvterm_cvterm_id_seq TO web_usr;


--
-- Name: file; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE file FROM PUBLIC;
REVOKE ALL ON TABLE file FROM postgres;
GRANT ALL ON TABLE file TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE file TO web_usr;


--
-- Name: file_file_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE file_file_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE file_file_id_seq FROM postgres;
GRANT ALL ON SEQUENCE file_file_id_seq TO postgres;
GRANT USAGE ON SEQUENCE file_file_id_seq TO web_usr;


--
-- Name: location; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE location FROM PUBLIC;
REVOKE ALL ON TABLE location FROM postgres;
GRANT ALL ON TABLE location TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE location TO web_usr;


--
-- Name: location_location_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE location_location_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE location_location_id_seq FROM postgres;
GRANT ALL ON SEQUENCE location_location_id_seq TO postgres;
GRANT USAGE ON SEQUENCE location_location_id_seq TO web_usr;


--
-- Name: measurement; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE measurement FROM PUBLIC;
REVOKE ALL ON TABLE measurement FROM postgres;
GRANT ALL ON TABLE measurement TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE measurement TO web_usr;


--
-- Name: measurement_measurement_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE measurement_measurement_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE measurement_measurement_id_seq FROM postgres;
GRANT ALL ON SEQUENCE measurement_measurement_id_seq TO postgres;
GRANT USAGE ON SEQUENCE measurement_measurement_id_seq TO web_usr;


--
-- Name: sensor; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE sensor FROM PUBLIC;
REVOKE ALL ON TABLE sensor FROM postgres;
GRANT ALL ON TABLE sensor TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sensor TO web_usr;


--
-- Name: station; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE station FROM PUBLIC;
REVOKE ALL ON TABLE station FROM postgres;
GRANT ALL ON TABLE station TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE station TO web_usr;


--
-- Name: station_station_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE station_station_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE station_station_id_seq FROM postgres;
GRANT ALL ON SEQUENCE station_station_id_seq TO postgres;
GRANT USAGE ON SEQUENCE station_station_id_seq TO web_usr;


--
-- PostgreSQL database dump complete
--

