--
-- PostgreSQL database dump
--

-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.4

-- Started on 2025-11-27 04:11:09

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 38172)
-- Name: um; Type: SCHEMA; Schema: -; Owner: umdocs_admin
--

CREATE SCHEMA um;


ALTER SCHEMA um OWNER TO umdocs_admin;

--
-- TOC entry 288 (class 1255 OID 38173)
-- Name: tri_biu_all_tabs(); Type: FUNCTION; Schema: um; Owner: umdocs_admin
--

CREATE FUNCTION um.tri_biu_all_tabs() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Set lastupdate fields on UPDATE
    IF TG_OP = 'UPDATE' THEN
        NEW.lastupdateid = CURRENT_USER;
        NEW.lastupdatedate = (CURRENT_TIMESTAMP AT TIME ZONE 'UTC');
        NEW.lastupdatedate_as_number = (TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),'YYYYMMDDHH24MISS'))::NUMERIC;
    END IF;
    
    -- Set creator fields on INSERT
    IF TG_OP = 'INSERT' THEN
        NEW.creatorid = COALESCE(NEW.creatorid, CURRENT_USER);
        NEW.createddate = COALESCE(NEW.createddate, (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'));
        NEW.createddate_as_number = COALESCE(NEW.createddate_as_number, (TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),'YYYYMMDDHH24MISS'))::NUMERIC);
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION um.tri_biu_all_tabs() OWNER TO umdocs_admin;

--
-- TOC entry 284 (class 1255 OID 38825)
-- Name: update_um_authorization_timestamp(); Type: FUNCTION; Schema: um; Owner: umdocs_admin
--

CREATE FUNCTION um.update_um_authorization_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$;


ALTER FUNCTION um.update_um_authorization_timestamp() OWNER TO umdocs_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 263 (class 1259 OID 38534)
-- Name: activity_logs; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.activity_logs (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    user_id uuid,
    action character varying(255),
    entity character varying(100),
    entity_id uuid,
    details text,
    ip_address character varying(50),
    user_agent text,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.activity_logs OWNER TO umdocs_admin;

--
-- TOC entry 269 (class 1259 OID 38671)
-- Name: api_keys; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.api_keys (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    key_name character varying(100) NOT NULL,
    key_hash text NOT NULL,
    key_prefix character varying(20),
    user_id uuid,
    service_account character varying(100),
    scopes text[],
    permissions jsonb,
    rate_limit integer,
    allowed_ips text[],
    is_active boolean DEFAULT true,
    last_used_at timestamp without time zone,
    usage_count bigint DEFAULT 0,
    expires_at timestamp without time zone,
    revoked_at timestamp without time zone,
    revoked_by uuid,
    revoked_reason text,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.api_keys OWNER TO umdocs_admin;

--
-- TOC entry 267 (class 1259 OID 38620)
-- Name: azure_ad_users; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.azure_ad_users (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    user_id uuid NOT NULL,
    azure_object_id character varying(255) NOT NULL,
    azure_tenant_id character varying(255),
    azure_upn character varying(255),
    azure_email character varying(255),
    azure_display_name character varying(255),
    azure_given_name character varying(100),
    azure_surname character varying(100),
    azure_job_title character varying(255),
    azure_department character varying(255),
    azure_groups jsonb,
    last_sync timestamp without time zone,
    sync_status character varying(50),
    is_active boolean DEFAULT true,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.azure_ad_users OWNER TO umdocs_admin;

--
-- TOC entry 254 (class 1259 OID 38333)
-- Name: facilities; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.facilities (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    facility_name character varying(255) NOT NULL,
    facility_code character varying(50),
    address text,
    phone_number character varying(20),
    email character varying(255),
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.facilities OWNER TO umdocs_admin;

--
-- TOC entry 264 (class 1259 OID 38555)
-- Name: lookup_status; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.lookup_status (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    status_code character varying(50) NOT NULL,
    status_name character varying(100) NOT NULL,
    description text,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.lookup_status OWNER TO umdocs_admin;

--
-- TOC entry 249 (class 1259 OID 38219)
-- Name: modules; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.modules (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    module_code character varying(50) NOT NULL,
    module_name character varying(255) NOT NULL,
    description text,
    display_order smallint,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.modules OWNER TO umdocs_admin;

--
-- TOC entry 265 (class 1259 OID 38573)
-- Name: oauth_providers; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.oauth_providers (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    provider_name character varying(50) NOT NULL,
    provider_display_name character varying(100) NOT NULL,
    client_id character varying(255),
    client_secret_encrypted text,
    authorization_endpoint character varying(500),
    token_endpoint character varying(500),
    userinfo_endpoint character varying(500),
    jwks_uri character varying(500),
    issuer character varying(500),
    redirect_uri character varying(500),
    scopes character varying(500),
    is_active boolean DEFAULT true,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.oauth_providers OWNER TO umdocs_admin;

--
-- TOC entry 266 (class 1259 OID 38592)
-- Name: oauth_tokens; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.oauth_tokens (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    user_id uuid NOT NULL,
    provider_id uuid NOT NULL,
    access_token text NOT NULL,
    refresh_token text,
    token_type character varying(50) DEFAULT 'Bearer'::character varying,
    expires_at timestamp without time zone NOT NULL,
    scope character varying(500),
    id_token text,
    revoked boolean DEFAULT false,
    revoked_at timestamp without time zone,
    revoked_reason character varying(255),
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.oauth_tokens OWNER TO umdocs_admin;

--
-- TOC entry 250 (class 1259 OID 38237)
-- Name: permissions; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.permissions (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    permission_key character varying(200) NOT NULL,
    permission_code character varying(100),
    permission_name character varying(255),
    description text,
    module_id uuid,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.permissions OWNER TO umdocs_admin;

--
-- TOC entry 259 (class 1259 OID 38440)
-- Name: plans; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.plans (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    plan_name character varying(255) NOT NULL,
    plan_code character varying(50) NOT NULL,
    description text,
    effective_date date,
    termination_date date,
    phone_number character varying(20),
    email character varying(255),
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.plans OWNER TO umdocs_admin;

--
-- TOC entry 262 (class 1259 OID 38504)
-- Name: provider_directory; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.provider_directory (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    provider_id uuid NOT NULL,
    plan_id uuid NOT NULL,
    specialty_id uuid,
    is_primary boolean DEFAULT false,
    start_date date,
    end_date date,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.provider_directory OWNER TO umdocs_admin;

--
-- TOC entry 261 (class 1259 OID 38476)
-- Name: providers; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.providers (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    npi character varying(20),
    first_name character varying(100),
    last_name character varying(100),
    email character varying(255),
    phone_number character varying(20),
    specialty_id uuid,
    facility_id uuid,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.providers OWNER TO umdocs_admin;

--
-- TOC entry 251 (class 1259 OID 38260)
-- Name: role_permissions; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.role_permissions (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL,
    can_read boolean DEFAULT true,
    can_create boolean DEFAULT false,
    can_update boolean DEFAULT false,
    can_delete boolean DEFAULT false,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.role_permissions OWNER TO umdocs_admin;

--
-- TOC entry 257 (class 1259 OID 38395)
-- Name: role_workflows; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.role_workflows (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    role_id uuid NOT NULL,
    workflow_id uuid NOT NULL,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.role_workflows OWNER TO umdocs_admin;

--
-- TOC entry 268 (class 1259 OID 38644)
-- Name: security_events; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.security_events (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    user_id uuid,
    event_type character varying(50) NOT NULL,
    event_severity character varying(20),
    event_description text,
    ip_address character varying(50),
    user_agent text,
    additional_data jsonb,
    resolved boolean DEFAULT false,
    resolved_by uuid,
    resolved_at timestamp without time zone,
    resolution_notes text,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.security_events OWNER TO umdocs_admin;

--
-- TOC entry 260 (class 1259 OID 38458)
-- Name: specialties; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.specialties (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    specialty_code character varying(50) NOT NULL,
    specialty_name character varying(255) NOT NULL,
    description text,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.specialties OWNER TO umdocs_admin;

--
-- TOC entry 273 (class 1259 OID 38796)
-- Name: um_authorizations; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.um_authorizations (
    id bigint NOT NULL,
    file_name character varying(255),
    file_url character varying(500),
    file_size bigint,
    file_arrival_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    authorization_number character varying(100),
    document_id character varying(100),
    patient_id character varying(100),
    member_name character varying(200),
    dob date NOT NULL,
    healthplan_id character varying(100) NOT NULL,
    health_plan character varying(200) NOT NULL,
    requesting_npi character varying(20) NOT NULL,
    requesting_name character varying(200) NOT NULL,
    servicing_name character varying(200),
    source character varying(20),
    template_type character varying(100) NOT NULL,
    priority character varying(50) NOT NULL,
    receipt_datetime timestamp without time zone NOT NULL,
    start_of_care date,
    status character varying(100),
    result character varying(100),
    assigned_user character varying(200),
    procedure_code character varying(500),
    determination character varying(50),
    md_determination character varying(50),
    escalation_date timestamp without time zone,
    escalation_type character varying(50),
    nurse_reviewer character varying(200),
    original_reviewer character varying(200),
    review_date timestamp without time zone,
    complexity character varying(20),
    form_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(200),
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(200),
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp without time zone,
    deleted_by character varying(200),
    version integer DEFAULT 1 NOT NULL,
    contract_id character varying(100)[]
);


ALTER TABLE um.um_authorizations OWNER TO umdocs_admin;

--
-- TOC entry 4810 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE um_authorizations; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON TABLE um.um_authorizations IS 'Stores utilization management authorization requests. Search/queue fields are direct columns, complete form data stored in JSONB.';


--
-- TOC entry 4811 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN um_authorizations.id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_authorizations.id IS 'Primary key - auto-incrementing unique identifier';


--
-- TOC entry 4812 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN um_authorizations.authorization_number; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_authorizations.authorization_number IS 'Unique authorization number - auto-generated if not provided';


--
-- TOC entry 4813 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN um_authorizations.document_id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_authorizations.document_id IS 'System-generated document identifier for tracking';


--
-- TOC entry 4814 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN um_authorizations.form_data; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_authorizations.form_data IS 'Complete form data in JSONB format including all 79 fields with AI values, confidence scores, and user values';


--
-- TOC entry 4815 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN um_authorizations.created_at; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_authorizations.created_at IS 'Timestamp when record was created';


--
-- TOC entry 4816 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN um_authorizations.updated_at; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_authorizations.updated_at IS 'Timestamp when record was last updated - automatically updated by trigger';


--
-- TOC entry 4817 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN um_authorizations.is_deleted; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_authorizations.is_deleted IS 'Soft delete flag - TRUE if record is deleted';


--
-- TOC entry 4818 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN um_authorizations.version; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_authorizations.version IS 'Version number for optimistic locking - automatically incremented on update';


--
-- TOC entry 272 (class 1259 OID 38795)
-- Name: um_authorizations_id_seq; Type: SEQUENCE; Schema: um; Owner: umdocs_admin
--

CREATE SEQUENCE um.um_authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE um.um_authorizations_id_seq OWNER TO umdocs_admin;

--
-- TOC entry 4819 (class 0 OID 0)
-- Dependencies: 272
-- Name: um_authorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: um; Owner: umdocs_admin
--

ALTER SEQUENCE um.um_authorizations_id_seq OWNED BY um.um_authorizations.id;


--
-- TOC entry 280 (class 1259 OID 39157)
-- Name: um_case_lock; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.um_case_lock (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    document_id character varying(100) NOT NULL,
    assigned_user character varying(255) NOT NULL,
    lock_issued timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lock_expires timestamp without time zone DEFAULT ((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) + '00:30:00'::interval),
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.um_case_lock OWNER TO umdocs_admin;

--
-- TOC entry 4820 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE um_case_lock; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON TABLE um.um_case_lock IS 'Stores document locks for intake processing to prevent concurrent edits';


--
-- TOC entry 4821 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN um_case_lock.document_id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_case_lock.document_id IS 'Unique document identifier from um_authorizations table';


--
-- TOC entry 4822 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN um_case_lock.assigned_user; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_case_lock.assigned_user IS 'User who currently holds the lock';


--
-- TOC entry 4823 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN um_case_lock.lock_issued; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_case_lock.lock_issued IS 'Timestamp when lock was issued';


--
-- TOC entry 4824 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN um_case_lock.lock_expires; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_case_lock.lock_expires IS 'Timestamp when lock automatically expires (30 minutes default)';


--
-- TOC entry 4825 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN um_case_lock.deleted; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_case_lock.deleted IS 'Soft delete flag: y/n';


--
-- TOC entry 279 (class 1259 OID 39016)
-- Name: um_config; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.um_config (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    config_key character varying(100) NOT NULL,
    config_value jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    deleted character(1) DEFAULT 'n'::bpchar,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.um_config OWNER TO umdocs_admin;

--
-- TOC entry 4826 (class 0 OID 0)
-- Dependencies: 279
-- Name: TABLE um_config; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON TABLE um.um_config IS 'Stores configuration settings for utilization management system';


--
-- TOC entry 4827 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN um_config.id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_config.id IS 'Primary key - UUID identifier';


--
-- TOC entry 4828 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN um_config.config_key; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_config.config_key IS 'Unique configuration key identifier';


--
-- TOC entry 4829 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN um_config.config_value; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_config.config_value IS 'JSON configuration value - can be string, array, object, or primitive value';


--
-- TOC entry 4830 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN um_config.is_active; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_config.is_active IS 'Indicates if the configuration setting is active';


--
-- TOC entry 4831 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN um_config.deleted; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_config.deleted IS 'Soft delete flag - n=active, y=deleted';


--
-- TOC entry 4832 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN um_config.creatorid; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_config.creatorid IS 'User who created the record';


--
-- TOC entry 4833 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN um_config.createddate; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_config.createddate IS 'Timestamp when record was created in UTC';


--
-- TOC entry 4834 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN um_config.createddate_as_number; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_config.createddate_as_number IS 'Numeric representation of created date (YYYYMMDDHH24MISS)';


--
-- TOC entry 4835 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN um_config.lastupdateid; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_config.lastupdateid IS 'User who last updated the record';


--
-- TOC entry 4836 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN um_config.lastupdatedate; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_config.lastupdatedate IS 'Timestamp when record was last updated in UTC';


--
-- TOC entry 4837 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN um_config.lastupdatedate_as_number; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_config.lastupdatedate_as_number IS 'Numeric representation of last updated date (YYYYMMDDHH24MISS)';


--
-- TOC entry 276 (class 1259 OID 38934)
-- Name: um_diagnosis_codes; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.um_diagnosis_codes (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    code_id character varying(20) NOT NULL,
    description character varying(500) NOT NULL,
    long_description text,
    is_active boolean DEFAULT true NOT NULL,
    deleted character(1) DEFAULT 'n'::bpchar,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.um_diagnosis_codes OWNER TO umdocs_admin;

--
-- TOC entry 4838 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE um_diagnosis_codes; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON TABLE um.um_diagnosis_codes IS 'Stores diagnosis codes (ICD-10) for utilization management';


--
-- TOC entry 4839 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN um_diagnosis_codes.id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_diagnosis_codes.id IS 'Primary key - UUID identifier';


--
-- TOC entry 4840 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN um_diagnosis_codes.code_id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_diagnosis_codes.code_id IS 'Diagnosis code identifier (e.g., ICD-10 code)';


--
-- TOC entry 4841 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN um_diagnosis_codes.description; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_diagnosis_codes.description IS 'Short description of the diagnosis code';


--
-- TOC entry 4842 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN um_diagnosis_codes.long_description; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_diagnosis_codes.long_description IS 'Detailed description of the diagnosis code';


--
-- TOC entry 4843 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN um_diagnosis_codes.is_active; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_diagnosis_codes.is_active IS 'Indicates if the diagnosis code is active';


--
-- TOC entry 274 (class 1259 OID 38898)
-- Name: um_health_plans; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.um_health_plans (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    contract_id character varying(50) NOT NULL,
    organization_marketing_name character varying(255) NOT NULL,
    geographic_name character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    deleted character(1) DEFAULT 'n'::bpchar,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.um_health_plans OWNER TO umdocs_admin;

--
-- TOC entry 4844 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE um_health_plans; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON TABLE um.um_health_plans IS 'Stores health plan information for utilization management system';


--
-- TOC entry 4845 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.id IS 'Primary key - UUID identifier';


--
-- TOC entry 4846 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.contract_id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.contract_id IS 'Unique contract identifier for the health plan';


--
-- TOC entry 4847 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.organization_marketing_name; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.organization_marketing_name IS 'Marketing name of the health plan organization';


--
-- TOC entry 4848 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.geographic_name; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.geographic_name IS 'Geographic coverage area name';


--
-- TOC entry 4849 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.is_active; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.is_active IS 'Indicates if the health plan is active';


--
-- TOC entry 4850 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.deleted; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.deleted IS 'Soft delete flag - n=active, y=deleted';


--
-- TOC entry 4851 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.creatorid; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.creatorid IS 'User who created the record';


--
-- TOC entry 4852 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.createddate; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.createddate IS 'Timestamp when record was created in UTC';


--
-- TOC entry 4853 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.createddate_as_number; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.createddate_as_number IS 'Numeric representation of created date (YYYYMMDDHH24MISS)';


--
-- TOC entry 4854 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.lastupdateid; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.lastupdateid IS 'User who last updated the record';


--
-- TOC entry 4855 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.lastupdatedate; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.lastupdatedate IS 'Timestamp when record was last updated in UTC';


--
-- TOC entry 4856 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN um_health_plans.lastupdatedate_as_number; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_health_plans.lastupdatedate_as_number IS 'Numeric representation of last updated date (YYYYMMDDHH24MISS)';


--
-- TOC entry 277 (class 1259 OID 38952)
-- Name: um_procedure_codes; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.um_procedure_codes (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    code_id character varying(20) NOT NULL,
    description character varying(500) NOT NULL,
    long_description text,
    group_description character varying(255),
    code_type character varying(10) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    deleted character(1) DEFAULT 'n'::bpchar,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    CONSTRAINT um_procedure_codes_code_type_check CHECK (((code_type)::text = ANY ((ARRAY['CPT'::character varying, 'REV'::character varying])::text[])))
);


ALTER TABLE um.um_procedure_codes OWNER TO umdocs_admin;

--
-- TOC entry 4857 (class 0 OID 0)
-- Dependencies: 277
-- Name: TABLE um_procedure_codes; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON TABLE um.um_procedure_codes IS 'Stores procedure codes (CPT/Revenue) for utilization management';


--
-- TOC entry 4858 (class 0 OID 0)
-- Dependencies: 277
-- Name: COLUMN um_procedure_codes.id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_procedure_codes.id IS 'Primary key - UUID identifier';


--
-- TOC entry 4859 (class 0 OID 0)
-- Dependencies: 277
-- Name: COLUMN um_procedure_codes.code_id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_procedure_codes.code_id IS 'Procedure code identifier';


--
-- TOC entry 4860 (class 0 OID 0)
-- Dependencies: 277
-- Name: COLUMN um_procedure_codes.description; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_procedure_codes.description IS 'Short description of the procedure code';


--
-- TOC entry 4861 (class 0 OID 0)
-- Dependencies: 277
-- Name: COLUMN um_procedure_codes.long_description; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_procedure_codes.long_description IS 'Detailed description of the procedure code';


--
-- TOC entry 4862 (class 0 OID 0)
-- Dependencies: 277
-- Name: COLUMN um_procedure_codes.group_description; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_procedure_codes.group_description IS 'Group or category description for the procedure code';


--
-- TOC entry 4863 (class 0 OID 0)
-- Dependencies: 277
-- Name: COLUMN um_procedure_codes.code_type; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_procedure_codes.code_type IS 'Type of procedure code: CPT or REV (Revenue)';


--
-- TOC entry 4864 (class 0 OID 0)
-- Dependencies: 277
-- Name: COLUMN um_procedure_codes.is_active; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_procedure_codes.is_active IS 'Indicates if the procedure code is active';


--
-- TOC entry 275 (class 1259 OID 38916)
-- Name: um_providers; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.um_providers (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    npi character varying(10) NOT NULL,
    full_name character varying(255) NOT NULL,
    phone character varying(20),
    fax character varying(20),
    email character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    deleted character(1) DEFAULT 'n'::bpchar,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.um_providers OWNER TO umdocs_admin;

--
-- TOC entry 4865 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE um_providers; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON TABLE um.um_providers IS 'Stores healthcare provider information for utilization management';


--
-- TOC entry 4866 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN um_providers.id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_providers.id IS 'Primary key - UUID identifier';


--
-- TOC entry 4867 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN um_providers.npi; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_providers.npi IS 'National Provider Identifier - unique 10-digit number';


--
-- TOC entry 4868 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN um_providers.full_name; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_providers.full_name IS 'Full name of the healthcare provider';


--
-- TOC entry 4869 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN um_providers.phone; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_providers.phone IS 'Provider phone number';


--
-- TOC entry 4870 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN um_providers.fax; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_providers.fax IS 'Provider fax number';


--
-- TOC entry 4871 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN um_providers.email; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_providers.email IS 'Provider email address';


--
-- TOC entry 4872 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN um_providers.is_active; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_providers.is_active IS 'Indicates if the provider is active';


--
-- TOC entry 4873 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN um_providers.deleted; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_providers.deleted IS 'Soft delete flag - n=active, y=deleted';


--
-- TOC entry 248 (class 1259 OID 38201)
-- Name: um_roles; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.um_roles (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    role_key character varying(100) NOT NULL,
    role_display_name character varying(200),
    description text,
    role_code character varying(100),
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.um_roles OWNER TO umdocs_admin;

--
-- TOC entry 278 (class 1259 OID 38971)
-- Name: um_templates; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.um_templates (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    template_name character varying(255) NOT NULL,
    template_type character varying(100) NOT NULL,
    description text,
    form_schema jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    deleted character(1) DEFAULT 'n'::bpchar,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.um_templates OWNER TO umdocs_admin;

--
-- TOC entry 4874 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE um_templates; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON TABLE um.um_templates IS 'Stores form templates for utilization management authorization requests';


--
-- TOC entry 4875 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN um_templates.id; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_templates.id IS 'Primary key - UUID identifier';


--
-- TOC entry 4876 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN um_templates.template_name; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_templates.template_name IS 'Unique name of the template';


--
-- TOC entry 4877 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN um_templates.template_type; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_templates.template_type IS 'Type/category of the template';


--
-- TOC entry 4878 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN um_templates.description; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_templates.description IS 'Description of the template purpose and usage';


--
-- TOC entry 4879 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN um_templates.form_schema; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_templates.form_schema IS 'JSON schema defining the form structure and fields';


--
-- TOC entry 4880 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN um_templates.is_active; Type: COMMENT; Schema: um; Owner: umdocs_admin
--

COMMENT ON COLUMN um.um_templates.is_active IS 'Indicates if the template is active for use';


--
-- TOC entry 252 (class 1259 OID 38288)
-- Name: um_user_roles; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.um_user_roles (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.um_user_roles OWNER TO umdocs_admin;

--
-- TOC entry 247 (class 1259 OID 38174)
-- Name: um_users; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.um_users (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    email character varying(255) NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    full_name character varying(255),
    password_hash text,
    is_active boolean DEFAULT true,
    role_name character varying(100),
    ad_username character varying(100),
    ad_object_id character varying(255),
    phone_number character varying(20),
    profession character varying(50),
    npi_number character varying(20),
    license_number character varying(50),
    license_state character varying(2),
    license_expiry_date date,
    specialty character varying(100),
    organization character varying(255),
    department character varying(100),
    account_status character varying(20) DEFAULT 'pending'::character varying,
    approved_by uuid,
    approved_at timestamp without time zone,
    last_login timestamp without time zone,
    last_login_ip character varying(45),
    mfa_enabled boolean DEFAULT false,
    mfa_secret text,
    timezone character varying(50) DEFAULT 'America/Chicago'::character varying,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.um_users OWNER TO umdocs_admin;

--
-- TOC entry 255 (class 1259 OID 38351)
-- Name: user_facility_xref; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.user_facility_xref (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    user_id uuid NOT NULL,
    facility_id uuid NOT NULL,
    is_primary boolean DEFAULT false,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.user_facility_xref OWNER TO umdocs_admin;

--
-- TOC entry 253 (class 1259 OID 38312)
-- Name: user_sessions; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.user_sessions (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    user_id uuid NOT NULL,
    access_token text NOT NULL,
    refresh_token text NOT NULL,
    ip_address character varying(50),
    user_agent text,
    expires_at timestamp without time zone,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.user_sessions OWNER TO umdocs_admin;

--
-- TOC entry 271 (class 1259 OID 38725)
-- Name: vw_system_status; Type: VIEW; Schema: um; Owner: umdocs_admin
--

CREATE VIEW um.vw_system_status AS
 SELECT 'Users'::text AS entity_type,
    count(*) AS count,
    count(
        CASE
            WHEN ((um_users.is_active = true) AND ((um_users.deleted)::text = 'n'::text)) THEN 1
            ELSE NULL::integer
        END) AS active_count
   FROM um.um_users
UNION ALL
 SELECT 'Roles'::text AS entity_type,
    count(*) AS count,
    count(
        CASE
            WHEN ((um_roles.deleted)::text = 'n'::text) THEN 1
            ELSE NULL::integer
        END) AS active_count
   FROM um.um_roles
UNION ALL
 SELECT 'Permissions'::text AS entity_type,
    count(*) AS count,
    count(
        CASE
            WHEN ((permissions.deleted)::text = 'n'::text) THEN 1
            ELSE NULL::integer
        END) AS active_count
   FROM um.permissions
UNION ALL
 SELECT 'Facilities'::text AS entity_type,
    count(*) AS count,
    count(
        CASE
            WHEN ((facilities.deleted)::text = 'n'::text) THEN 1
            ELSE NULL::integer
        END) AS active_count
   FROM um.facilities
UNION ALL
 SELECT 'OAuth Providers'::text AS entity_type,
    count(*) AS count,
    count(
        CASE
            WHEN ((oauth_providers.is_active = true) AND ((oauth_providers.deleted)::text = 'n'::text)) THEN 1
            ELSE NULL::integer
        END) AS active_count
   FROM um.oauth_providers;


ALTER VIEW um.vw_system_status OWNER TO umdocs_admin;

--
-- TOC entry 270 (class 1259 OID 38720)
-- Name: vw_user_roles; Type: VIEW; Schema: um; Owner: umdocs_admin
--

CREATE VIEW um.vw_user_roles AS
 SELECT u.id AS user_id,
    u.email,
    u.full_name,
    r.role_display_name AS role_name,
    r.role_code,
    u.is_active,
    u.account_status,
    u.last_login
   FROM ((um.um_users u
     LEFT JOIN um.um_user_roles ur ON ((u.id = ur.user_id)))
     LEFT JOIN um.um_roles r ON ((ur.role_id = r.id)))
  WHERE ((u.deleted)::text = 'n'::text);


ALTER VIEW um.vw_user_roles OWNER TO umdocs_admin;

--
-- TOC entry 258 (class 1259 OID 38419)
-- Name: workflow_logs; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.workflow_logs (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    entity_name character varying(100),
    entity_id uuid,
    action character varying(50),
    performed_by uuid,
    old_data jsonb,
    new_data jsonb,
    remarks text,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric
);


ALTER TABLE um.workflow_logs OWNER TO umdocs_admin;

--
-- TOC entry 256 (class 1259 OID 38376)
-- Name: workflows; Type: TABLE; Schema: um; Owner: umdocs_admin
--

CREATE TABLE um.workflows (
    id uuid DEFAULT (md5(((random())::text || (clock_timestamp())::text)))::uuid NOT NULL,
    workflow_key character varying(100) NOT NULL,
    workflow_name character varying(200) NOT NULL,
    description text,
    display_order smallint DEFAULT 0,
    deleted character varying(1) DEFAULT 'n'::character varying,
    creatorid character varying(30) DEFAULT CURRENT_USER,
    createddate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    createddate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    lastupdateid character varying(30) DEFAULT CURRENT_USER,
    lastupdatedate timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text),
    lastupdatedate_as_number numeric(18,0) DEFAULT (to_char((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text), 'YYYYMMDDHH24MISS'::text))::numeric,
    icon character varying(150),
    route_path character varying(150),
    button_text character varying(150),
    button_icon character varying(150)
);


ALTER TABLE um.workflows OWNER TO umdocs_admin;

--
-- TOC entry 4338 (class 2604 OID 38799)
-- Name: um_authorizations id; Type: DEFAULT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_authorizations ALTER COLUMN id SET DEFAULT nextval('um.um_authorizations_id_seq'::regclass);


--
-- TOC entry 4789 (class 0 OID 38534)
-- Dependencies: 263
-- Data for Name: activity_logs; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.activity_logs VALUES ('fdb97675-f5f1-4a72-be35-e11d1a2c43e9', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''Arunkumar.Singaram@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-06 06:28:12.69839', 20251106062812, 'CURRENT_USER', '2025-11-06 06:28:12.698567', 20251106062812);
INSERT INTO um.activity_logs VALUES ('65cbc42f-c5ca-4810-88cd-59b79769a92d', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-06 06:41:19.241484', 20251106064119, 'CURRENT_USER', '2025-11-06 06:41:19.242344', 20251106064119);
INSERT INTO um.activity_logs VALUES ('b283de2f-d352-4c62-81c8-5caacf8f7b7d', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''Arunkumar.Singaram@curanahealth.com'', ''reason'': "Unexpected system error: type object ''AuthService'' has no attribute ''_get_permissions_for_roles''", ''event'': ''login_failed''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-06 06:42:31.667978', 20251106064231, 'CURRENT_USER', '2025-11-06 06:42:31.668134', 20251106064231);
INSERT INTO um.activity_logs VALUES ('25db1bbb-cdb0-4396-9ddf-bc1302f25c4a', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals_grievances'', ''clinical_review'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-06 06:46:38.020153', 20251106064638, 'CURRENT_USER', '2025-11-06 06:46:38.020342', 20251106064638);
INSERT INTO um.activity_logs VALUES ('e44e995e-47ff-4b73-90ea-5c1cb5309a4e', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGOUT', 'auth', NULL, '{''email'': ''Arunkumar.Singaram@curanahealth.com'', ''event'': ''user_logout''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-06 07:01:24.121117', 20251106070124, 'CURRENT_USER', '2025-11-06 07:01:24.121219', 20251106070124);
INSERT INTO um.activity_logs VALUES ('779221fa-f02f-45b3-983f-30868dd149b3', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals_grievances'', ''clinical_review'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-06 10:10:53.198833', 20251106101053, 'CURRENT_USER', '2025-11-06 10:10:53.199012', 20251106101053);
INSERT INTO um.activity_logs VALUES ('14709cd3-d86c-4bc4-a9c2-503ebd97e8ca', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGOUT', 'auth', NULL, '{''email'': ''Arunkumar.Singaram@curanahealth.com'', ''event'': ''user_logout''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-06 10:15:13.729213', 20251106101513, 'CURRENT_USER', '2025-11-06 10:15:13.729321', 20251106101513);
INSERT INTO um.activity_logs VALUES ('a6f42248-098f-47b1-a394-ed4f26f79e97', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-14 10:40:47.89794', 20251114104047, 'CURRENT_USER', '2025-11-14 10:40:47.897958', 20251114104047);
INSERT INTO um.activity_logs VALUES ('2bcb2c90-b9a1-4956-80e5-58989efdcadb', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-14 10:41:15.583901', 20251114104115, 'CURRENT_USER', '2025-11-14 10:41:15.583933', 20251114104115);
INSERT INTO um.activity_logs VALUES ('c86b911b-e841-4770-bbbd-cefd91dc8152', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-14 11:01:04.919571', 20251114110104, 'CURRENT_USER', '2025-11-14 11:01:04.919709', 20251114110104);
INSERT INTO um.activity_logs VALUES ('830c2cae-8f14-458f-b653-b8aed85d7947', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-14 14:47:53.365427', 20251114144753, 'CURRENT_USER', '2025-11-14 14:47:53.36555', 20251114144753);
INSERT INTO um.activity_logs VALUES ('593ef98e-c130-4145-b157-627fc1594123', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-14 15:41:09.482243', 20251114154109, 'CURRENT_USER', '2025-11-14 15:41:09.482412', 20251114154109);
INSERT INTO um.activity_logs VALUES ('a11e08f6-fe32-4520-8d8c-bf77df81e749', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-14 16:22:22.064742', 20251114162222, 'CURRENT_USER', '2025-11-14 16:22:22.06495', 20251114162222);
INSERT INTO um.activity_logs VALUES ('6fb31a0b-e130-41e5-93a0-bb914be5b8b8', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-14 17:20:17.631814', 20251114172017, 'CURRENT_USER', '2025-11-14 17:20:17.632065', 20251114172017);
INSERT INTO um.activity_logs VALUES ('95ab06a5-6fbb-4676-9dd4-6773f7ceb4e1', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-14 18:15:42.801926', 20251114181542, 'CURRENT_USER', '2025-11-14 18:15:42.802125', 20251114181542);
INSERT INTO um.activity_logs VALUES ('93d81bad-9a73-44ab-b337-6a0184910185', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-14 18:22:07.453769', 20251114182207, 'CURRENT_USER', '2025-11-14 18:22:07.453968', 20251114182207);
INSERT INTO um.activity_logs VALUES ('20ee055e-6fe9-46c8-87a3-34e9eb91dae1', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-14 18:44:45.221055', 20251114184445, 'CURRENT_USER', '2025-11-14 18:44:45.221182', 20251114184445);
INSERT INTO um.activity_logs VALUES ('12de253e-10c5-45d5-8bb1-b234f4add570', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-14 19:30:08.457047', 20251114193008, 'CURRENT_USER', '2025-11-14 19:30:08.457186', 20251114193008);
INSERT INTO um.activity_logs VALUES ('9f3b0c4a-77f6-492d-ac40-11f75f93df7d', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-14 19:33:38.010713', 20251114193338, 'CURRENT_USER', '2025-11-14 19:33:38.010898', 20251114193338);
INSERT INTO um.activity_logs VALUES ('1dcec90c-6889-4037-92f6-d8ddead7e678', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-14 21:10:26.939332', 20251114211026, 'CURRENT_USER', '2025-11-14 21:10:26.939439', 20251114211026);
INSERT INTO um.activity_logs VALUES ('9d2b424e-7d51-4906-bf27-ce7ea79190aa', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-18 07:22:56.224346', 20251118072256, 'CURRENT_USER', '2025-11-18 07:22:56.224547', 20251118072256);
INSERT INTO um.activity_logs VALUES ('dcb5e3c7-1126-456b-be84-c16198d025c1', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-18 08:29:08.692548', 20251118082908, 'CURRENT_USER', '2025-11-18 08:29:08.692775', 20251118082908);
INSERT INTO um.activity_logs VALUES ('bf4ca452-356b-4d87-a208-aea3a33ec31d', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-18 09:37:14.752073', 20251118093714, 'CURRENT_USER', '2025-11-18 09:37:14.752299', 20251118093714);
INSERT INTO um.activity_logs VALUES ('9816467f-25c4-438b-b365-7ea6195266a6', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-18 09:57:09.011915', 20251118095709, 'CURRENT_USER', '2025-11-18 09:57:09.012026', 20251118095709);
INSERT INTO um.activity_logs VALUES ('40a0201e-edd4-42a2-b1da-a6767f7cafac', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-18 13:36:32.183275', 20251118133632, 'CURRENT_USER', '2025-11-18 13:36:32.183634', 20251118133632);
INSERT INTO um.activity_logs VALUES ('af325534-67ad-4855-9a3b-74ad3f43c93e', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''nisha.mani@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 15:17:25.267844', 20251118151725, 'CURRENT_USER', '2025-11-18 15:17:25.267864', 20251118151725);
INSERT INTO um.activity_logs VALUES ('cbb451f9-11b0-4ef9-a9fe-f6f98fbc0c18', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''nisha.mani@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 15:17:40.988194', 20251118151740, 'CURRENT_USER', '2025-11-18 15:17:40.988214', 20251118151740);
INSERT INTO um.activity_logs VALUES ('f772bc74-942d-41a4-9779-3e0f3b14b295', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''nisha.mani@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 15:17:46.131172', 20251118151746, 'CURRENT_USER', '2025-11-18 15:17:46.13119', 20251118151746);
INSERT INTO um.activity_logs VALUES ('f34fc4a9-f734-4158-8749-7f00166875e8', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''nisha.mani@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 15:17:47.370805', 20251118151747, 'CURRENT_USER', '2025-11-18 15:17:47.370839', 20251118151747);
INSERT INTO um.activity_logs VALUES ('e1bc9dc6-b784-41f9-8850-0773d4b01813', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 16:00:03.754657', 20251118160003, 'CURRENT_USER', '2025-11-18 16:00:03.754677', 20251118160003);
INSERT INTO um.activity_logs VALUES ('62a77916-8c32-4160-a7cb-e8fb1b338884', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 16:11:28.908722', 20251118161128, 'CURRENT_USER', '2025-11-18 16:11:28.90874', 20251118161128);
INSERT INTO um.activity_logs VALUES ('ad61ca98-4154-48a1-89c1-83fdf8834cc1', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-18 16:21:29.153795', 20251118162129, 'CURRENT_USER', '2025-11-18 16:21:29.154171', 20251118162129);
INSERT INTO um.activity_logs VALUES ('8ae19477-3cc4-4d64-a3b5-1c4ac5f903e8', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 16:32:28.151203', 20251118163228, 'CURRENT_USER', '2025-11-18 16:32:28.151223', 20251118163228);
INSERT INTO um.activity_logs VALUES ('8b941580-b94f-42a9-9681-65e84f4b08ca', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 16:33:15.35931', 20251118163315, 'CURRENT_USER', '2025-11-18 16:33:15.359328', 20251118163315);
INSERT INTO um.activity_logs VALUES ('9b93a73e-f04b-4557-9da0-640604c000c9', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 18:44:00.804978', 20251118184400, 'CURRENT_USER', '2025-11-18 18:44:00.804997', 20251118184400);
INSERT INTO um.activity_logs VALUES ('46f7c17a-037d-4a02-be48-127b0da6efdd', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 18:48:24.071643', 20251118184824, 'CURRENT_USER', '2025-11-18 18:48:24.071661', 20251118184824);
INSERT INTO um.activity_logs VALUES ('b99c752b-fbb0-41c9-92a4-db70539226bd', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 19:04:01.915658', 20251118190401, 'CURRENT_USER', '2025-11-18 19:04:01.915676', 20251118190401);
INSERT INTO um.activity_logs VALUES ('2f5ce21b-4686-4d8b-858a-e57e24a30c04', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-18 19:05:13.335487', 20251118190513, 'CURRENT_USER', '2025-11-18 19:05:13.335507', 20251118190513);
INSERT INTO um.activity_logs VALUES ('77c26b6f-98a5-4e7d-abb9-81cfbd3fec1e', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 09:09:42.267089', 20251119090942, 'CURRENT_USER', '2025-11-19 09:09:42.267122', 20251119090942);
INSERT INTO um.activity_logs VALUES ('213e3162-4b73-468d-a600-51983cc1dcb7', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 09:10:44.111263', 20251119091044, 'CURRENT_USER', '2025-11-19 09:10:44.111293', 20251119091044);
INSERT INTO um.activity_logs VALUES ('89d431db-ada3-48a5-9145-f8adcf0f8a3f', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 09:11:39.298292', 20251119091139, 'CURRENT_USER', '2025-11-19 09:11:39.298425', 20251119091139);
INSERT INTO um.activity_logs VALUES ('347aa379-8ceb-4658-8927-f98d93c0dd23', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 09:13:36.572668', 20251119091336, 'CURRENT_USER', '2025-11-19 09:13:36.572698', 20251119091336);
INSERT INTO um.activity_logs VALUES ('1ee9569d-2de1-4e0d-b958-97b41d1943e5', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 09:12:21.692527', 20251119091221, 'CURRENT_USER', '2025-11-19 09:12:21.692543', 20251119091221);
INSERT INTO um.activity_logs VALUES ('53ee9dc8-c773-4f5a-aedf-f913e03cfe32', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 10:17:21.358231', 20251119101721, 'CURRENT_USER', '2025-11-19 10:17:21.358279', 20251119101721);
INSERT INTO um.activity_logs VALUES ('9fcd42a4-08fa-49fb-8c6f-8e35d06e0850', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 10:17:52.445283', 20251119101752, 'CURRENT_USER', '2025-11-19 10:17:52.445302', 20251119101752);
INSERT INTO um.activity_logs VALUES ('f930951e-1a76-4f29-b0b0-f54509a7e270', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 10:18:20.080616', 20251119101820, 'CURRENT_USER', '2025-11-19 10:18:20.080632', 20251119101820);
INSERT INTO um.activity_logs VALUES ('414855ec-d251-406c-bde2-639b129ad922', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-19 10:21:18.595523', 20251119102118, 'CURRENT_USER', '2025-11-19 10:21:18.595687', 20251119102118);
INSERT INTO um.activity_logs VALUES ('c6901fe7-cc0f-4e16-b87b-e9983fd8cbdf', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 11:27:01.579706', 20251119112701, 'CURRENT_USER', '2025-11-19 11:27:01.579724', 20251119112701);
INSERT INTO um.activity_logs VALUES ('7445721f-4c35-4f8a-af46-a113c0477ddf', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 12:27:59.960772', 20251119122759, 'CURRENT_USER', '2025-11-19 12:27:59.960805', 20251119122759);
INSERT INTO um.activity_logs VALUES ('3cb2c6f9-e5b1-4987-a3f5-0afa51d00803', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 12:28:11.80025', 20251119122811, 'CURRENT_USER', '2025-11-19 12:28:11.800282', 20251119122811);
INSERT INTO um.activity_logs VALUES ('3202c8d1-0e75-4c3f-9f7b-afde573b0c69', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 12:29:35.526428', 20251119122935, 'CURRENT_USER', '2025-11-19 12:29:35.526455', 20251119122935);
INSERT INTO um.activity_logs VALUES ('f4afa467-a6c3-4294-b5c5-08979b8f0cfb', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 12:30:35.178707', 20251119123035, 'CURRENT_USER', '2025-11-19 12:30:35.178752', 20251119123035);
INSERT INTO um.activity_logs VALUES ('30c67bcf-331f-4f1a-a68c-c98fecafab76', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 12:31:26.7564', 20251119123126, 'CURRENT_USER', '2025-11-19 12:31:26.756431', 20251119123126);
INSERT INTO um.activity_logs VALUES ('27bd4286-84a0-4b06-899b-1f283bdb0ba8', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 12:32:34.755931', 20251119123234, 'CURRENT_USER', '2025-11-19 12:32:34.755962', 20251119123234);
INSERT INTO um.activity_logs VALUES ('3906ce83-fc4c-4052-a2aa-65cd4dca9e7e', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 12:33:20.253171', 20251119123320, 'CURRENT_USER', '2025-11-19 12:33:20.253203', 20251119123320);
INSERT INTO um.activity_logs VALUES ('c5e869f8-8183-40dd-bf3e-6a5326b7c21e', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-19 14:46:59.493982', 20251119144659, 'CURRENT_USER', '2025-11-19 14:46:59.494319', 20251119144659);
INSERT INTO um.activity_logs VALUES ('f559a01c-0441-4f20-b04c-7abb1781cfa6', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 15:49:56.782525', 20251119154956, 'CURRENT_USER', '2025-11-19 15:49:56.782554', 20251119154956);
INSERT INTO um.activity_logs VALUES ('7a11d3a3-14e0-41bd-9d17-98352780df76', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 15:51:19.459233', 20251119155119, 'CURRENT_USER', '2025-11-19 15:51:19.459265', 20251119155119);
INSERT INTO um.activity_logs VALUES ('148539ea-8c99-4829-b151-f5d7ff702099', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 15:51:40.098077', 20251119155140, 'CURRENT_USER', '2025-11-19 15:51:40.098109', 20251119155140);
INSERT INTO um.activity_logs VALUES ('53d4a1ed-0b5f-4c4d-9024-0b58f761ed04', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 15:52:18.102528', 20251119155218, 'CURRENT_USER', '2025-11-19 15:52:18.102558', 20251119155218);
INSERT INTO um.activity_logs VALUES ('68219e90-213a-4596-a087-bfe46f5543ea', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 16:52:11.269256', 20251119165211, 'CURRENT_USER', '2025-11-19 16:52:11.269287', 20251119165211);
INSERT INTO um.activity_logs VALUES ('38b726c4-c8e1-4c33-8984-2f3c1b616736', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 16:52:36.27771', 20251119165236, 'CURRENT_USER', '2025-11-19 16:52:36.277741', 20251119165236);
INSERT INTO um.activity_logs VALUES ('18cb7e9e-ff0a-413b-b8ee-18b132d22b9d', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 16:53:33.959663', 20251119165333, 'CURRENT_USER', '2025-11-19 16:53:33.959695', 20251119165333);
INSERT INTO um.activity_logs VALUES ('9bd6fe24-afe6-4a97-acfc-b6328dd4c903', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 16:54:17.398689', 20251119165417, 'CURRENT_USER', '2025-11-19 16:54:17.39872', 20251119165417);
INSERT INTO um.activity_logs VALUES ('f9b1ec1e-dbed-4084-a707-58ee69a93d4d', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 17:02:14.347925', 20251119170214, 'CURRENT_USER', '2025-11-19 17:02:14.347956', 20251119170214);
INSERT INTO um.activity_logs VALUES ('0f2bf185-1f8e-4d51-8da0-14b6cbe5f095', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 17:03:42.334015', 20251119170342, 'CURRENT_USER', '2025-11-19 17:03:42.334046', 20251119170342);
INSERT INTO um.activity_logs VALUES ('8458841a-eab2-4b12-a5e9-989e649b89a2', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-19 17:42:13.77154', 20251119174213, 'CURRENT_USER', '2025-11-19 17:42:13.771572', 20251119174213);
INSERT INTO um.activity_logs VALUES ('4796f66f-b8ff-4d4c-8c14-825c74a86afb', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 16:55:29.159192', 20251119165529, 'CURRENT_USER', '2025-11-19 16:55:29.159243', 20251119165529);
INSERT INTO um.activity_logs VALUES ('c966920e-1cf8-44f7-8512-f6dd460625a7', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 17:03:41.400974', 20251119170341, 'CURRENT_USER', '2025-11-19 17:03:41.401005', 20251119170341);
INSERT INTO um.activity_logs VALUES ('115e7b03-e65d-4cb4-98f3-6972ccb0592c', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 17:03:59.926666', 20251119170359, 'CURRENT_USER', '2025-11-19 17:03:59.926699', 20251119170359);
INSERT INTO um.activity_logs VALUES ('45871265-055f-49cd-a7ce-01acb08f0fca', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-19 17:38:57.881286', 20251119173857, 'CURRENT_USER', '2025-11-19 17:38:57.881492', 20251119173857);
INSERT INTO um.activity_logs VALUES ('4e6ed5e1-92aa-4521-b51b-866fe7ef663b', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-19 17:55:08.217946', 20251119175508, 'CURRENT_USER', '2025-11-19 17:55:08.217991', 20251119175508);
INSERT INTO um.activity_logs VALUES ('a9d27b8b-7889-4bb1-86af-d6f546674fcf', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '172.16.8.23', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 02:48:50.193591', 20251120024850, 'CURRENT_USER', '2025-11-20 02:48:50.193617', 20251120024850);
INSERT INTO um.activity_logs VALUES ('4c5afcb2-deb4-4047-a18d-5dde1a51a122', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 03:09:31.643445', 20251120030931, 'CURRENT_USER', '2025-11-20 03:09:31.643463', 20251120030931);
INSERT INTO um.activity_logs VALUES ('edc04bea-1e38-4d5f-ad41-3db247f8e39e', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 04:03:33.187448', 20251120040333, 'CURRENT_USER', '2025-11-20 04:03:33.188039', 20251120040333);
INSERT INTO um.activity_logs VALUES ('6fd6c80e-9bac-4b43-b59a-f615f3a84ebb', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 05:34:25.576233', 20251120053425, 'CURRENT_USER', '2025-11-20 05:34:25.576451', 20251120053425);
INSERT INTO um.activity_logs VALUES ('7303dcae-c94e-4ddb-9a1f-ed250afbcb83', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 07:36:43.542384', 20251120073643, 'CURRENT_USER', '2025-11-20 07:36:43.54281', 20251120073643);
INSERT INTO um.activity_logs VALUES ('02ae874b-987c-49db-96ec-3285740babf3', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 07:41:17.735121', 20251120074117, 'CURRENT_USER', '2025-11-20 07:41:17.735138', 20251120074117);
INSERT INTO um.activity_logs VALUES ('f94e3187-e1a4-4752-8ec0-c38b1032038f', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 08:36:03.881969', 20251120083603, 'CURRENT_USER', '2025-11-20 08:36:03.882266', 20251120083603);
INSERT INTO um.activity_logs VALUES ('bdbae838-93cf-4276-97e5-fd1f70986b52', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 09:52:17.334113', 20251120095217, 'CURRENT_USER', '2025-11-20 09:52:17.334423', 20251120095217);
INSERT INTO um.activity_logs VALUES ('813fe840-955b-4ac4-bfb8-be735bce3471', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 11:40:18.079041', 20251120114018, 'CURRENT_USER', '2025-11-20 11:40:18.079394', 20251120114018);
INSERT INTO um.activity_logs VALUES ('92cf1fa5-ef01-4634-ab6c-8c962828bdb3', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 21:45:29.480717', 20251120214529, 'CURRENT_USER', '2025-11-20 21:45:29.481013', 20251120214529);
INSERT INTO um.activity_logs VALUES ('eaf98af9-1843-4f17-bfb5-de30e65142e0', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 23:37:53.050162', 20251120233752, 'CURRENT_USER', '2025-11-20 23:37:53.050399', 20251120233752);
INSERT INTO um.activity_logs VALUES ('eb6c5cd7-2064-46e5-b135-133bd9e58c61', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '192.168.156.7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-20 23:41:12.698734', 20251120234112, 'CURRENT_USER', '2025-11-20 23:41:12.698754', 20251120234112);
INSERT INTO um.activity_logs VALUES ('6037ff53-fdac-4dd9-aecf-9133d7882b50', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '172.16.8.23', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-21 04:05:32.945541', 20251121040532, 'CURRENT_USER', '2025-11-21 04:05:32.945598', 20251121040532);
INSERT INTO um.activity_logs VALUES ('cc8c4786-d5bc-45ad-a136-c953ea528573', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '172.16.8.23', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-21 04:55:53.463613', 20251121045553, 'CURRENT_USER', '2025-11-21 04:55:53.463633', 20251121045553);
INSERT INTO um.activity_logs VALUES ('93aea846-76aa-45df-afaa-06ede20b0add', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-21 09:29:49.312025', 20251121092949, 'CURRENT_USER', '2025-11-21 09:29:49.312231', 20251121092949);
INSERT INTO um.activity_logs VALUES ('6509cb3b-4805-4d93-9253-8178f1777c98', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-21 12:57:30.916906', 20251121125730, 'CURRENT_USER', '2025-11-21 12:57:30.916925', 20251121125730);
INSERT INTO um.activity_logs VALUES ('c415d724-c54e-423b-b330-7fb0a6e7d4cb', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-21 12:58:23.75765', 20251121125823, 'CURRENT_USER', '2025-11-21 12:58:23.757681', 20251121125823);
INSERT INTO um.activity_logs VALUES ('42e37ec3-a89d-4d73-9260-6a3cd17c0ca8', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-21 12:59:48.33029', 20251121125948, 'CURRENT_USER', '2025-11-21 12:59:48.330306', 20251121125948);
INSERT INTO um.activity_logs VALUES ('dd23c470-d422-4d68-9bfa-38bef5641e0d', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-21 13:01:55.622633', 20251121130155, 'CURRENT_USER', '2025-11-21 13:01:55.622666', 20251121130155);
INSERT INTO um.activity_logs VALUES ('af5ea96d-dfa2-4c65-b553-22444c7a96b2', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-21 13:01:31.305791', 20251121130131, 'CURRENT_USER', '2025-11-21 13:01:31.305824', 20251121130131);
INSERT INTO um.activity_logs VALUES ('c1219a4e-0dde-4689-b59d-e48d5413e883', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '192.168.156.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-21 13:50:46.976345', 20251121135046, 'CURRENT_USER', '2025-11-21 13:50:46.976363', 20251121135046);
INSERT INTO um.activity_logs VALUES ('20105bb4-8cca-4f68-ab82-40f9d1a9c063', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-21 14:07:28.278491', 20251121140728, 'CURRENT_USER', '2025-11-21 14:07:28.278521', 20251121140728);
INSERT INTO um.activity_logs VALUES ('737750ca-b89f-42a1-8f41-7de6ea14a596', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-21 14:08:15.007444', 20251121140815, 'CURRENT_USER', '2025-11-21 14:08:15.007473', 20251121140815);
INSERT INTO um.activity_logs VALUES ('26498ba9-8f6c-4d9c-b74c-16d1c52efb1b', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-21 14:08:52.29021', 20251121140852, 'CURRENT_USER', '2025-11-21 14:08:52.290228', 20251121140852);
INSERT INTO um.activity_logs VALUES ('ceaa33fb-054b-48cd-954e-ebb523f5f4e8', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-21 14:09:24.897005', 20251121140924, 'CURRENT_USER', '2025-11-21 14:09:24.897038', 20251121140924);
INSERT INTO um.activity_logs VALUES ('d04111e6-9d69-404d-bcdc-9dc498432172', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-21 14:09:48.856677', 20251121140948, 'CURRENT_USER', '2025-11-21 14:09:48.85671', 20251121140948);
INSERT INTO um.activity_logs VALUES ('08f9b1fd-4421-4da2-b66a-86266e05b0b9', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.156.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-21 15:16:05.92084', 20251121151605, 'CURRENT_USER', '2025-11-21 15:16:05.920872', 20251121151605);
INSERT INTO um.activity_logs VALUES ('ca9df45e-bb39-4ecc-a7ca-d09f2af74373', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-21 15:48:10.166129', 20251121154810, 'CURRENT_USER', '2025-11-21 15:48:10.166379', 20251121154810);
INSERT INTO um.activity_logs VALUES ('bb25708e-74de-4f26-97a4-c7786ba05bbe', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '192.168.156.7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-21 15:54:26.977571', 20251121155426, 'CURRENT_USER', '2025-11-21 15:54:26.977588', 20251121155426);
INSERT INTO um.activity_logs VALUES ('4e4c6968-765a-4b43-aaeb-8c1f3a364763', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '192.168.156.7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-21 15:55:13.438199', 20251121155513, 'CURRENT_USER', '2025-11-21 15:55:13.438218', 20251121155513);
INSERT INTO um.activity_logs VALUES ('341bc0fe-13ba-4762-9ff6-bad41d7a4b77', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-21 19:47:34.690432', 20251121194734, 'CURRENT_USER', '2025-11-21 19:47:34.690669', 20251121194734);
INSERT INTO um.activity_logs VALUES ('d01c19f3-bf3a-4b7d-956f-fb72cda03dbd', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-23 18:28:37.862576', 20251123182837, 'CURRENT_USER', '2025-11-23 18:28:37.862766', 20251123182837);
INSERT INTO um.activity_logs VALUES ('39e4020a-ea3c-42ab-bc09-2b0fc1fe953a', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '10.52.0.13', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 08:10:41.832896', 20251124081041, 'CURRENT_USER', '2025-11-24 08:10:41.832914', 20251124081041);
INSERT INTO um.activity_logs VALUES ('13675e74-d8d0-4172-9676-b44a967f2e30', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-24 10:13:35.956938', 20251124101335, 'CURRENT_USER', '2025-11-24 10:13:35.957123', 20251124101335);
INSERT INTO um.activity_logs VALUES ('23284137-7e32-4786-a8e3-f7202aea310c', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 12:45:07.463177', 20251124124507, 'CURRENT_USER', '2025-11-24 12:45:07.463211', 20251124124507);
INSERT INTO um.activity_logs VALUES ('e055242d-de56-47b0-ad70-dfd2f212fc12', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 12:45:12.509921', 20251124124512, 'CURRENT_USER', '2025-11-24 12:45:12.509941', 20251124124512);
INSERT INTO um.activity_logs VALUES ('c049563a-70cd-46b8-a2c0-06bc74052d66', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.139', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 17:51:11.175144', 20251124175111, 'CURRENT_USER', '2025-11-24 17:51:11.175173', 20251124175111);
INSERT INTO um.activity_logs VALUES ('66b0208a-249c-4d17-aea6-02bc0eb7512a', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.139', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 17:51:28.206392', 20251124175128, 'CURRENT_USER', '2025-11-24 17:51:28.20642', 20251124175128);
INSERT INTO um.activity_logs VALUES ('96260d7d-2d52-45d8-81de-e68637988f91', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '192.168.157.7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-24 17:52:11.071986', 20251124175211, 'CURRENT_USER', '2025-11-24 17:52:11.072006', 20251124175211);
INSERT INTO um.activity_logs VALUES ('03c2b200-27d3-4f6c-91e2-0c7cd1a7e4a3', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.139', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 17:52:22.44279', 20251124175222, 'CURRENT_USER', '2025-11-24 17:52:22.442808', 20251124175222);
INSERT INTO um.activity_logs VALUES ('2b2ea9bc-c4df-441f-ac81-2356802f1def', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 17:52:46.363741', 20251124175246, 'CURRENT_USER', '2025-11-24 17:52:46.363759', 20251124175246);
INSERT INTO um.activity_logs VALUES ('b03c7e20-9947-4d7f-83be-597deceb22c2', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 17:55:15.791104', 20251124175515, 'CURRENT_USER', '2025-11-24 17:55:15.791135', 20251124175515);
INSERT INTO um.activity_logs VALUES ('8fa75913-35a0-4a2a-b731-1028d2b39aa7', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.139', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 18:00:46.488726', 20251124180046, 'CURRENT_USER', '2025-11-24 18:00:46.488746', 20251124180046);
INSERT INTO um.activity_logs VALUES ('15bbbbca-4d39-45b8-90f1-0b78bfc2723e', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 17:53:05.197025', 20251124175305, 'CURRENT_USER', '2025-11-24 17:53:05.197045', 20251124175305);
INSERT INTO um.activity_logs VALUES ('0bd27039-cd1d-4d10-9f96-6becc0b13307', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 17:55:23.972472', 20251124175523, 'CURRENT_USER', '2025-11-24 17:55:23.97249', 20251124175523);
INSERT INTO um.activity_logs VALUES ('d6d19321-1fdd-4ca0-a2a6-8ccdbf1a79bf', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.139', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 18:00:49.48704', 20251124180049, 'CURRENT_USER', '2025-11-24 18:00:49.487057', 20251124180049);
INSERT INTO um.activity_logs VALUES ('f2485c00-b3fa-407b-93d3-508cb4b3d0a3', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 17:53:15.743573', 20251124175315, 'CURRENT_USER', '2025-11-24 17:53:15.743592', 20251124175315);
INSERT INTO um.activity_logs VALUES ('c5e34daa-aa13-4ff8-a1d6-e903715f5a83', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.139', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 17:57:00.014103', 20251124175700, 'CURRENT_USER', '2025-11-24 17:57:00.01414', 20251124175700);
INSERT INTO um.activity_logs VALUES ('4633fee2-880c-4f17-9396-7b06757821b5', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.139', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 18:01:38.241495', 20251124180138, 'CURRENT_USER', '2025-11-24 18:01:38.241548', 20251124180138);
INSERT INTO um.activity_logs VALUES ('64d8de05-4f97-4b7b-9e46-a92da1839e58', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 17:55:06.374762', 20251124175506, 'CURRENT_USER', '2025-11-24 17:55:06.374781', 20251124175506);
INSERT INTO um.activity_logs VALUES ('08580169-30d3-4958-a792-df2fdfae013d', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.139', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 17:57:20.625911', 20251124175720, 'CURRENT_USER', '2025-11-24 17:57:20.625931', 20251124175720);
INSERT INTO um.activity_logs VALUES ('63053677-c245-4bb7-94b8-c23b69d75fcd', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '172.16.8.27', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-24 18:02:52.18727', 20251124180252, 'CURRENT_USER', '2025-11-24 18:02:52.187287', 20251124180252);
INSERT INTO um.activity_logs VALUES ('6023b484-a506-4982-ba93-db7cec3bb607', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-24 18:38:03.152166', 20251124183803, 'CURRENT_USER', '2025-11-24 18:38:03.152556', 20251124183803);
INSERT INTO um.activity_logs VALUES ('54ce041c-a2e5-4dc2-af82-8ce4b17515db', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-25 09:18:36.007584', 20251125091835, 'CURRENT_USER', '2025-11-25 09:18:36.007948', 20251125091835);
INSERT INTO um.activity_logs VALUES ('98aeae7d-3d68-4017-a9e0-e5ea97110bc6', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-25 09:19:34.820824', 20251125091934, 'CURRENT_USER', '2025-11-25 09:19:34.821937', 20251125091934);
INSERT INTO um.activity_logs VALUES ('1bc92fed-7912-4e39-a4e3-dc1853da2b5d', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-25 09:41:29.051286', 20251125094129, 'CURRENT_USER', '2025-11-25 09:41:29.051509', 20251125094129);
INSERT INTO um.activity_logs VALUES ('5e34484f-ca88-4dc4-aeab-64856a377546', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.4', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-25 10:01:55.222215', 20251125100155, 'CURRENT_USER', '2025-11-25 10:01:55.222244', 20251125100155);
INSERT INTO um.activity_logs VALUES ('3ee1f4f5-2e61-4ed5-85c1-98ec17347bf2', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''rohitt.selvakumar@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.4', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-25 10:01:58.05365', 20251125100158, 'CURRENT_USER', '2025-11-25 10:01:58.05372', 20251125100158);
INSERT INTO um.activity_logs VALUES ('15452e4b-5f7e-4766-af8a-4402b0fc0600', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.4', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-25 10:02:56.506213', 20251125100256, 'CURRENT_USER', '2025-11-25 10:02:56.506235', 20251125100256);
INSERT INTO um.activity_logs VALUES ('a60b89fd-d31b-4a56-8f6b-14668b2449eb', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.157.4', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-25 10:03:05.790876', 20251125100305, 'CURRENT_USER', '2025-11-25 10:03:05.790895', 20251125100305);
INSERT INTO um.activity_logs VALUES ('ed09a876-0d50-4c08-a006-fe7a62a89d87', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-25 12:38:39.323212', 20251125123839, 'CURRENT_USER', '2025-11-25 12:38:39.323229', 20251125123839);
INSERT INTO um.activity_logs VALUES ('f6fce701-a80e-49cc-b859-669fc00b4e8f', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-25 12:39:36.362712', 20251125123936, 'CURRENT_USER', '2025-11-25 12:39:36.36273', 20251125123936);
INSERT INTO um.activity_logs VALUES ('52e2e360-5c54-4da8-ade0-c20d2cf59d85', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-25 12:39:43.910114', 20251125123943, 'CURRENT_USER', '2025-11-25 12:39:43.910133', 20251125123943);
INSERT INTO um.activity_logs VALUES ('773095f0-8492-43d5-adb8-98a68e41096f', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-25 12:40:09.674447', 20251125124009, 'CURRENT_USER', '2025-11-25 12:40:09.674465', 20251125124009);
INSERT INTO um.activity_logs VALUES ('af6b1754-0dbb-49b0-9e71-417e9ffb1db1', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-25 12:40:27.871985', 20251125124027, 'CURRENT_USER', '2025-11-25 12:40:27.872004', 20251125124027);
INSERT INTO um.activity_logs VALUES ('120aa80c-989a-441a-aac2-1cf810f58696', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_intake@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '172.16.8.27', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-25 12:53:18.477761', 20251125125318, 'CURRENT_USER', '2025-11-25 12:53:18.47778', 20251125125318);
INSERT INTO um.activity_logs VALUES ('4c4cad62-bda4-4d8d-840a-eeb053835a33', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_intake@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '172.16.8.27', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-25 12:53:20.962492', 20251125125320, 'CURRENT_USER', '2025-11-25 12:53:20.962511', 20251125125320);
INSERT INTO um.activity_logs VALUES ('2ebc59fb-acdb-4e0f-ba50-b452201a325d', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''um_admin@curanahealth.com'', ''reason'': ''User not registered in UM system'', ''event'': ''login_failed''}', '172.16.8.23', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-26 08:31:36.39006', 20251126083136, 'CURRENT_USER', '2025-11-26 08:31:36.390078', 20251126083136);
INSERT INTO um.activity_logs VALUES ('2f5d3f37-5b9c-4e62-88c9-25324c38b7a1', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-26 09:26:36.66469', 20251126092636, 'CURRENT_USER', '2025-11-26 09:26:36.664738', 20251126092636);
INSERT INTO um.activity_logs VALUES ('842081e8-cd5b-4d2b-ad19-cb55fd025aaf', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-26 09:28:34.152228', 20251126092834, 'CURRENT_USER', '2025-11-26 09:28:34.15226', 20251126092834);
INSERT INTO um.activity_logs VALUES ('9795c98f-3a69-4309-8bf0-0f6ec4d2e214', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-26 09:30:20.055582', 20251126093020, 'CURRENT_USER', '2025-11-26 09:30:20.055616', 20251126093020);
INSERT INTO um.activity_logs VALUES ('084ac026-f38d-422a-a03f-a012a78f34ea', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-26 09:30:36.4497', 20251126093036, 'CURRENT_USER', '2025-11-26 09:30:36.449732', 20251126093036);
INSERT INTO um.activity_logs VALUES ('0a8260b2-dca9-4284-b177-c61b3400dc61', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-26 09:30:51.97358', 20251126093051, 'CURRENT_USER', '2025-11-26 09:30:51.973611', 20251126093051);
INSERT INTO um.activity_logs VALUES ('67402d1e-e2e9-4d8f-8f3e-76d7ac9f1e47', NULL, 'LOGIN_FAILED', 'auth', NULL, '{''email'': ''unknown'', ''reason'': ''Azure token validation failed'', ''event'': ''login_failed''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-26 09:30:42.44984', 20251126093042, 'CURRENT_USER', '2025-11-26 09:30:42.449874', 20251126093042);
INSERT INTO um.activity_logs VALUES ('0636c24b-7343-46be-8cee-f9c40b6c8664', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''admin''], ''workflows'': [''appeals'', ''clinical'', ''intake'', ''medical_director''], ''event'': ''login_success''}', '192.168.150.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 'n', 'CURRENT_USER', '2025-11-26 09:31:45.013135', 20251126093145, 'CURRENT_USER', '2025-11-26 09:31:45.013155', 20251126093145);
INSERT INTO um.activity_logs VALUES ('1ba8ca69-9603-4908-9b69-51efdc91df3b', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-27 02:36:16.097554', 20251127023616, 'CURRENT_USER', '2025-11-27 02:36:16.097751', 20251127023616);
INSERT INTO um.activity_logs VALUES ('6db89fb7-7ebe-47f1-98dd-4934037468d2', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'LOGIN_SUCCESS', 'auth', NULL, '{''roles'': [''intake_specialist''], ''workflows'': [''intake''], ''event'': ''login_success''}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'n', 'CURRENT_USER', '2025-11-27 05:29:46.437872', 20251127052946, 'CURRENT_USER', '2025-11-27 05:29:46.438037', 20251127052946);


--
-- TOC entry 4795 (class 0 OID 38671)
-- Dependencies: 269
-- Data for Name: api_keys; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--



--
-- TOC entry 4793 (class 0 OID 38620)
-- Dependencies: 267
-- Data for Name: azure_ad_users; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--



--
-- TOC entry 4780 (class 0 OID 38333)
-- Dependencies: 254
-- Data for Name: facilities; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.facilities VALUES ('9d16b028-7518-7525-4ff1-3214e6a7239d', 'Align Senior Care HQ', 'HQ001', '123 Main Street, Richmond, VA', '+1-804-555-0100', 'info@alignseniorcare.com', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);


--
-- TOC entry 4790 (class 0 OID 38555)
-- Dependencies: 264
-- Data for Name: lookup_status; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.lookup_status VALUES ('d7747525-6d5b-352a-c2ac-482d89f8db77', 'ACTIVE', 'Active', 'Active status', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.lookup_status VALUES ('e8e0b130-ac76-39a6-c0dd-4cfd288aa00f', 'INACTIVE', 'Inactive', 'Inactive status', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.lookup_status VALUES ('e089af86-c0f2-1bc8-5480-7fc39786ffbe', 'PENDING', 'Pending', 'Pending review', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);


--
-- TOC entry 4775 (class 0 OID 38219)
-- Dependencies: 249
-- Data for Name: modules; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.modules VALUES ('5136c8bc-0dfe-e1c0-881c-18e1364b18e6', 'AUTH', 'Authentication', 'Login, Tokens, Azure AD Integration', 1, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.modules VALUES ('048ee7e4-6701-7b01-56f7-53cafb60e120', 'USER', 'User Management', 'User Profiles and Roles', 2, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.modules VALUES ('88a2421e-10d7-1052-446a-c873f978d155', 'PLAN', 'Plan Management', 'Plans and Coverage Details', 3, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.modules VALUES ('b9a6d416-768a-b34f-5a8f-07ba701bc471', 'WORKFLOW', 'Workflow Management', 'Healthcare Workflows and Cases', 4, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);


--
-- TOC entry 4791 (class 0 OID 38573)
-- Dependencies: 265
-- Data for Name: oauth_providers; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.oauth_providers VALUES ('360c54b0-1831-c15d-8808-3968faf19d12', 'azure_ad', 'Microsoft Azure AD', NULL, NULL, 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize', 'https://login.microsoftonline.com/common/oauth2/v2.0/token', 'https://graph.microsoft.com/v1.0/me', NULL, 'https://login.microsoftonline.com/{tenant}/v2.0', NULL, NULL, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);


--
-- TOC entry 4792 (class 0 OID 38592)
-- Dependencies: 266
-- Data for Name: oauth_tokens; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--



--
-- TOC entry 4776 (class 0 OID 38237)
-- Dependencies: 250
-- Data for Name: permissions; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.permissions VALUES ('5a463285-7f88-67c3-5f3d-727b7309be09', 'read_intake_queue', 'READ_INTAKE_QUEUE', 'Read Intake Queue', 'Can view intake queue', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('8d9e209c-d511-8648-fb7e-9025757cc353', 'create_intake_case', 'CREATE_INTAKE_CASE', 'Create Intake Case', 'Can create new intake cases', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('a5932485-2eff-5205-4964-26efe07a0547', 'update_intake_case', 'UPDATE_INTAKE_CASE', 'Update Intake Case', 'Can update intake cases', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('51ff5a74-9572-4fe5-f72c-22cac1d46953', 'submit_intake_case', 'SUBMIT_INTAKE_CASE', 'Submit Intake Case', 'Can submit intake cases', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('c3b43aea-64a4-34e2-88b1-f6b234018b5e', 'read_clinical_queue', 'READ_CLINICAL_QUEUE', 'Read Clinical Queue', 'Can view clinical review queue', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('4cd51acf-87be-b685-a091-d18b2299b157', 'read_clinical_case', 'READ_CLINICAL_CASE', 'Read Clinical Case', 'Can view clinical case details', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('a8a3a316-bc9b-a85c-54a6-39333d6d5a67', 'update_clinical_case', 'UPDATE_CLINICAL_CASE', 'Update Clinical Case', 'Can update clinical cases', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('7b87669b-0b61-60b3-15cc-03362182dd8c', 'submit_clinical_determination', 'SUBMIT_CLINICAL_DETERMINATION', 'Submit Clinical Determination', 'Can submit clinical determinations', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('797f6561-e73a-f5f3-e5b7-340c3560000a', 'escalate_to_md', 'ESCALATE_TO_MD', 'Escalate to MD', 'Can escalate cases to medical director', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('685b8104-d8d9-e63a-dddf-a72f219912d6', 'read_md_queue', 'READ_MD_QUEUE', 'Read MD Queue', 'Can view medical director queue', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('6be0a2fa-85cd-a9e1-0d54-ef0de0726a91', 'read_md_case', 'READ_MD_CASE', 'Read MD Case', 'Can view medical director case details', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('31f3df6e-c84f-e1f1-be53-7b9ddaf904ce', 'update_md_case', 'UPDATE_MD_CASE', 'Update MD Case', 'Can update medical director cases', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('7e222f96-559b-d20e-00bc-d4c9dbc40d66', 'submit_md_determination', 'SUBMIT_MD_DETERMINATION', 'Submit MD Determination', 'Can submit MD determinations', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('84be9609-85b9-abd9-1172-9c294ceede78', 'read_appeals_queue', 'READ_APPEALS_QUEUE', 'Read Appeals Queue', 'Can view appeals queue', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('c8b37c14-6320-dc68-b5b9-13a765e2802d', 'create_appeals_case', 'CREATE_APPEALS_CASE', 'Create Appeals Case', 'Can create appeals cases', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('1bfbd063-b69e-5d2b-9f40-b7a690c15678', 'update_appeals_case', 'UPDATE_APPEALS_CASE', 'Update Appeals Case', 'Can update appeals cases', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('b2d02e12-d9a3-c9f5-73c9-d090d3e67712', 'submit_appeals_resolution', 'SUBMIT_APPEALS_RESOLUTION', 'Submit Appeals Resolution', 'Can submit appeals resolutions', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('5018e8c4-2c18-9f4c-082c-18b25018b75a', 'read_all_queues', 'READ_ALL_QUEUES', 'Read All Queues', 'Can view all workflow queues', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('14d8a2a3-a345-95e9-1ba4-42a599826bf0', 'manage_users', 'MANAGE_USERS', 'Manage Users', 'Can manage user accounts', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('cb975569-42ff-57f9-ce0f-5a9d02460ab8', 'manage_roles', 'MANAGE_ROLES', 'Manage Roles', 'Can manage roles and permissions', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('c3811bcf-ac7e-95d2-506b-35a4c97f6acf', 'view_statistics', 'VIEW_STATISTICS', 'View Statistics', 'Can view system statistics', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('ada8ce4c-2d7b-fd3d-a73a-557f71818edc', 'manage_system', 'MANAGE_SYSTEM', 'Manage System', 'Can manage system settings', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('5fb1aa4c-4ef9-7905-37e1-41f3f244b9de', 'auth.login', 'AUTH_LOGIN', 'Login via Azure AD or Local Exception', 'Can perform login', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('6b74a745-7440-b787-12d2-d36f7a2d1098', 'auth.manage_users', 'USER_MANAGE', 'Manage Users', 'Manage user accounts', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('6a3aad5f-fc4f-120d-85ec-7151ef42c97d', 'user.view', 'USER_VIEW', 'View Users', 'Allows viewing of user profiles', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.permissions VALUES ('874d6d56-bf47-3e32-b412-0708aa971e69', 'plan.view', 'PLAN_VIEW', 'View Plans', 'Allows viewing plan data', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);


--
-- TOC entry 4785 (class 0 OID 38440)
-- Dependencies: 259
-- Data for Name: plans; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.plans VALUES ('63f6d732-52c5-79e1-25f9-0bf7ad1eade7', 'Align Senior Care', 'PLAN001', 'Default plan for testing', NULL, NULL, '+1-804-555-0100', 'support@alignseniorcare.com', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);


--
-- TOC entry 4788 (class 0 OID 38504)
-- Dependencies: 262
-- Data for Name: provider_directory; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--



--
-- TOC entry 4787 (class 0 OID 38476)
-- Dependencies: 261
-- Data for Name: providers; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--



--
-- TOC entry 4777 (class 0 OID 38260)
-- Dependencies: 251
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.role_permissions VALUES ('39d9c917-34bb-90d9-f2da-26bdcdfcc9d0', 'd1df653b-d522-8b38-8ba3-e51e283ab5cb', '5a463285-7f88-67c3-5f3d-727b7309be09', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('4816afda-8f63-5eab-2843-5a53e7144b4f', 'd1df653b-d522-8b38-8ba3-e51e283ab5cb', '8d9e209c-d511-8648-fb7e-9025757cc353', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('3ae5459a-9ff2-85e3-04b5-42ec89ece462', 'd1df653b-d522-8b38-8ba3-e51e283ab5cb', 'a5932485-2eff-5205-4964-26efe07a0547', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('2d461e11-2b60-b8f0-4213-b3edc566faf9', 'd1df653b-d522-8b38-8ba3-e51e283ab5cb', '51ff5a74-9572-4fe5-f72c-22cac1d46953', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('e9e8040e-6d2e-36f7-51d8-6d054f9c2cca', '62f59da6-43b3-ea5c-06c8-1ec00147b702', 'c3b43aea-64a4-34e2-88b1-f6b234018b5e', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('24cc7285-2bc1-e48f-0a85-f8f640832dff', '62f59da6-43b3-ea5c-06c8-1ec00147b702', '4cd51acf-87be-b685-a091-d18b2299b157', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('c8518480-6286-1785-04ba-7abe1b7b6d0f', '62f59da6-43b3-ea5c-06c8-1ec00147b702', 'a8a3a316-bc9b-a85c-54a6-39333d6d5a67', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('8386ce67-1fd5-61c0-30eb-651b66c6277d', '62f59da6-43b3-ea5c-06c8-1ec00147b702', '7b87669b-0b61-60b3-15cc-03362182dd8c', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('4e5f791a-2599-b35d-094d-42d8789c31ad', '62f59da6-43b3-ea5c-06c8-1ec00147b702', '797f6561-e73a-f5f3-e5b7-340c3560000a', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('6a384e96-045e-1610-10eb-50ae0cf1f623', 'dea55a66-aebe-15f6-b410-17c464a6224e', '685b8104-d8d9-e63a-dddf-a72f219912d6', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('8f8d83e4-7582-8ae7-acc8-dbc345005eac', 'dea55a66-aebe-15f6-b410-17c464a6224e', '6be0a2fa-85cd-a9e1-0d54-ef0de0726a91', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('17369964-71e1-fbbd-d515-e226dfd0318d', 'dea55a66-aebe-15f6-b410-17c464a6224e', '31f3df6e-c84f-e1f1-be53-7b9ddaf904ce', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('e4f0abed-b03c-a2bf-4d83-c74453c3a53b', 'dea55a66-aebe-15f6-b410-17c464a6224e', '7e222f96-559b-d20e-00bc-d4c9dbc40d66', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('c3148817-f995-64f8-e1ea-c8159888d86e', '8fc1fb39-4ad6-8ec8-7a25-b539631ab74f', '84be9609-85b9-abd9-1172-9c294ceede78', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('a160a401-c7a6-fee8-b6b6-cc80c86ffa92', '8fc1fb39-4ad6-8ec8-7a25-b539631ab74f', 'c8b37c14-6320-dc68-b5b9-13a765e2802d', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('ec817e48-222e-812c-08a3-b3fe5e68d263', '8fc1fb39-4ad6-8ec8-7a25-b539631ab74f', '1bfbd063-b69e-5d2b-9f40-b7a690c15678', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('19d21afc-82f7-49e8-5531-e9fae02f3c17', '8fc1fb39-4ad6-8ec8-7a25-b539631ab74f', 'b2d02e12-d9a3-c9f5-73c9-d090d3e67712', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('4bb0abf8-0227-4dec-9f35-a3b6fa64c7ee', '878c5462-c1a1-2864-26de-bea23f873004', '5018e8c4-2c18-9f4c-082c-18b25018b75a', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('05c0d4d3-970c-2935-5f09-4862eea229c0', '878c5462-c1a1-2864-26de-bea23f873004', '14d8a2a3-a345-95e9-1ba4-42a599826bf0', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('7467792c-5908-a285-888b-d3391ee0be3f', '878c5462-c1a1-2864-26de-bea23f873004', 'cb975569-42ff-57f9-ce0f-5a9d02460ab8', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('69c3876a-145a-7730-9253-f66064fb8f94', '878c5462-c1a1-2864-26de-bea23f873004', 'c3811bcf-ac7e-95d2-506b-35a4c97f6acf', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('37890c54-b9b2-6efd-a25a-bd8354ac49be', '878c5462-c1a1-2864-26de-bea23f873004', 'ada8ce4c-2d7b-fd3d-a73a-557f71818edc', true, true, true, false, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('73dab7ee-006a-2840-0e61-d508eb015cb4', '878c5462-c1a1-2864-26de-bea23f873004', '6b74a745-7440-b787-12d2-d36f7a2d1098', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('5edfc3d7-1470-d7ca-53b6-24185123e063', '878c5462-c1a1-2864-26de-bea23f873004', '5fb1aa4c-4ef9-7905-37e1-41f3f244b9de', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('de7a3e0b-0a33-99d9-1a90-5e1d6819a1f6', '878c5462-c1a1-2864-26de-bea23f873004', '51ff5a74-9572-4fe5-f72c-22cac1d46953', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('60e223f1-6588-6e11-f6a8-6276ff7d2b9b', '878c5462-c1a1-2864-26de-bea23f873004', '5a463285-7f88-67c3-5f3d-727b7309be09', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('74f1ced1-03f6-08d4-51e5-600f4c4156b5', '878c5462-c1a1-2864-26de-bea23f873004', '874d6d56-bf47-3e32-b412-0708aa971e69', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('57d6a891-71ab-3cba-9363-339f345a443a', '878c5462-c1a1-2864-26de-bea23f873004', '8d9e209c-d511-8648-fb7e-9025757cc353', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('0e359a4f-90e0-52c8-4905-6483c1dacdbb', '878c5462-c1a1-2864-26de-bea23f873004', '1bfbd063-b69e-5d2b-9f40-b7a690c15678', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('f0934c17-5c2c-0e1e-e1fb-b65a78b352ab', '878c5462-c1a1-2864-26de-bea23f873004', '31f3df6e-c84f-e1f1-be53-7b9ddaf904ce', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('602df726-2051-7f0c-5fc0-6a9db2a4f78c', '878c5462-c1a1-2864-26de-bea23f873004', '7e222f96-559b-d20e-00bc-d4c9dbc40d66', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('ba69a620-3525-afa9-e075-05cf80dbc0c2', '878c5462-c1a1-2864-26de-bea23f873004', 'a5932485-2eff-5205-4964-26efe07a0547', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('d4a5f528-ad09-c6ea-511d-b69adeb06f5d', '878c5462-c1a1-2864-26de-bea23f873004', 'c3b43aea-64a4-34e2-88b1-f6b234018b5e', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('272aeb22-eaee-422d-9b7e-7a1e3654d9ce', '878c5462-c1a1-2864-26de-bea23f873004', '4cd51acf-87be-b685-a091-d18b2299b157', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('c855d643-8cc1-13bd-fe5b-2a806d89ec81', '878c5462-c1a1-2864-26de-bea23f873004', '6be0a2fa-85cd-a9e1-0d54-ef0de0726a91', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('5d10fd11-4642-ca4a-b012-cd5f11ceb5b6', '878c5462-c1a1-2864-26de-bea23f873004', '797f6561-e73a-f5f3-e5b7-340c3560000a', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('33562ff6-d066-9907-cbe8-4d106654843d', '878c5462-c1a1-2864-26de-bea23f873004', '84be9609-85b9-abd9-1172-9c294ceede78', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('fda4cb93-f9da-64ea-b4d1-a8dd4e4a2d11', '878c5462-c1a1-2864-26de-bea23f873004', '685b8104-d8d9-e63a-dddf-a72f219912d6', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('5f985a6f-11a1-7d93-5ea3-f2789a642cef', '878c5462-c1a1-2864-26de-bea23f873004', 'b2d02e12-d9a3-c9f5-73c9-d090d3e67712', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('e1e81c60-bfd6-dfa5-59c9-635003025839', '878c5462-c1a1-2864-26de-bea23f873004', 'c8b37c14-6320-dc68-b5b9-13a765e2802d', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('00086f36-c920-f341-0128-de5ed47b5a50', '878c5462-c1a1-2864-26de-bea23f873004', 'a8a3a316-bc9b-a85c-54a6-39333d6d5a67', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('b28cc48e-c090-88e0-4c3e-9da626088b46', '878c5462-c1a1-2864-26de-bea23f873004', '7b87669b-0b61-60b3-15cc-03362182dd8c', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_permissions VALUES ('5a83c549-ca5f-d23d-b386-c4d3782e8044', '878c5462-c1a1-2864-26de-bea23f873004', '6a3aad5f-fc4f-120d-85ec-7151ef42c97d', true, true, true, true, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);


--
-- TOC entry 4783 (class 0 OID 38395)
-- Dependencies: 257
-- Data for Name: role_workflows; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.role_workflows VALUES ('34a7fc44-a1b8-06b2-c4bb-32b8399e8900', '878c5462-c1a1-2864-26de-bea23f873004', 'c791247d-9bc1-cbdb-5327-cae6d4ac9efa', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_workflows VALUES ('b8853a46-0813-ffec-84d2-b7cc5fec375d', 'd1df653b-d522-8b38-8ba3-e51e283ab5cb', 'c791247d-9bc1-cbdb-5327-cae6d4ac9efa', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_workflows VALUES ('e2cc1e24-97e6-f94b-d5b0-1000eb95a28d', '878c5462-c1a1-2864-26de-bea23f873004', '70b48763-9bea-3cf1-07a0-6e025fa75075', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_workflows VALUES ('a52c306a-fa6f-741c-7895-186981a7d4ad', '62f59da6-43b3-ea5c-06c8-1ec00147b702', '70b48763-9bea-3cf1-07a0-6e025fa75075', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_workflows VALUES ('b0e7f932-67fb-32bd-30cd-b0feed533bb8', '878c5462-c1a1-2864-26de-bea23f873004', '1e14e761-9106-6813-bb70-28b5f2eca68a', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_workflows VALUES ('6a08ab4e-1d52-1bad-3697-2ce774a209a2', 'dea55a66-aebe-15f6-b410-17c464a6224e', '1e14e761-9106-6813-bb70-28b5f2eca68a', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_workflows VALUES ('03b2efe7-1cbc-a2b4-3721-5b1a4de3885f', '878c5462-c1a1-2864-26de-bea23f873004', 'a4dca8e3-ab3e-85ed-2efc-acc6eae40528', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.role_workflows VALUES ('3b0224d3-95c4-88c2-18a3-998b54318a78', '8fc1fb39-4ad6-8ec8-7a25-b539631ab74f', 'a4dca8e3-ab3e-85ed-2efc-acc6eae40528', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);


--
-- TOC entry 4794 (class 0 OID 38644)
-- Dependencies: 268
-- Data for Name: security_events; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--



--
-- TOC entry 4786 (class 0 OID 38458)
-- Dependencies: 260
-- Data for Name: specialties; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.specialties VALUES ('66bb9ec7-9e84-2666-290b-efabc3e78f2f', 'GEN', 'General Practice', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.specialties VALUES ('48149664-956c-c915-49ee-4f5dd69a19bc', 'CARD', 'Cardiology', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.specialties VALUES ('80f5a85c-7bef-76a9-0f92-c95acc1c90db', 'ORTHO', 'Orthopedics', NULL, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);


--
-- TOC entry 4797 (class 0 OID 38796)
-- Dependencies: 273
-- Data for Name: um_authorizations; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.um_authorizations VALUES (5, '20251110_141821_98f5012d.pdf', 'https://umautomationstorage.blob.core.windows.net/um-upload-doc/20251110_141821_98f5012d.pdf', 1110840, '2025-11-10 14:18:21.849321', NULL, '0b2d4e74-767f-4338-abd2-05f698a71df6', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'Upload', 'Undetermined', 'Undetermined', '2025-11-10 14:18:21.849321', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-10 14:18:21.849321', NULL, '2025-11-21 09:48:39.220989', NULL, false, NULL, NULL, 2, NULL);
INSERT INTO um.um_authorizations VALUES (6, '20251110_160352_88fc0dbc.pdf', 'https://umautomationstorage.blob.core.windows.net/um-upload-doc/20251110_160352_88fc0dbc.pdf', 1110840, '2025-11-10 16:03:52.992151', NULL, '4d5fb791-3989-4c4a-a4f6-862dce9ab098', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'Upload', 'Undetermined', 'Undetermined', '2025-11-10 16:03:52.992151', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-10 16:03:52.992151', NULL, '2025-11-21 09:48:39.220989', NULL, false, NULL, NULL, 2, NULL);
INSERT INTO um.um_authorizations VALUES (7, 'medical_document_20241110.pdf', 'https://umautomationstorage.blob.core.windows.net/um-upload-doc/medical_document_20241110.pdf', 1110840, '2025-11-10 16:39:55.278262', NULL, 'dd3f56be-65f1-4392-909e-ed6885fb6b3e', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'Upload', 'Undetermined', 'Undetermined', '2025-11-10 16:39:55.278262', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-10 16:39:55.278262', NULL, '2025-11-21 09:48:39.220989', NULL, false, NULL, NULL, 2, NULL);
INSERT INTO um.um_authorizations VALUES (8, 'medical_document_20241110.pdf', 'https://umautomationstorage.blob.core.windows.net/um-upload-doc/medical_document_20241110.pdf', 1110840, '2025-11-10 16:40:03.804418', NULL, 'a05168e0-bdde-4c71-a6b3-7a7bd8a18a9c', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'Upload', 'Undetermined', 'Undetermined', '2025-11-10 16:40:03.804418', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-10 16:40:03.804418', NULL, '2025-11-21 09:48:39.220989', NULL, false, NULL, NULL, 2, NULL);
INSERT INTO um.um_authorizations VALUES (9, 'medical_document_20241110.pdf', 'https://umautomationstorage.blob.core.windows.net/um-upload-doc/medical_document_20241110.pdf', 1110840, '2025-11-10 17:15:50.523199', NULL, 'a6ea564e-c710-4b5a-b887-4e76bed41a96', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'Fax', 'Undetermined', 'Undetermined', '2025-11-10 17:15:50.523199', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-10 17:15:50.523199', NULL, '2025-11-21 09:48:39.220989', NULL, false, NULL, NULL, 2, NULL);
INSERT INTO um.um_authorizations VALUES (10, '20251113_140001_74684a32.pdf', 'https://umautomationstorage.blob.core.windows.net/um-upload-doc/20251113_140001_74684a32.pdf', 598704, '2025-11-13 14:00:01.512281', NULL, '0887c6fc-780a-46c9-a3fa-6d5a14874850', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'Upload', 'Undetermined', 'Undetermined', '2025-11-13 14:00:01.512281', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"member_info": {"dob": {"aiNotes": "", "aiConfScore": "88%", "aiPopulated": "1980-01-15", "userPopulated": ""}, "healthPlan": {"aiNotes": "", "aiConfScore": "90%", "aiPopulated": "Blue Cross", "userPopulated": ""}, "memberName": {"aiNotes": "", "aiConfScore": "95%", "aiPopulated": "John Doe", "userPopulated": ""}, "healthplanId": {"aiNotes": "", "aiConfScore": "92%", "aiPopulated": "HP123456", "userPopulated": ""}, "authorizationNumber": {"aiNotes": "", "aiConfScore": "90%", "aiPopulated": "AUTH-2024-1234", "userPopulated": ""}}, "request_info": {"priority": {"aiNotes": "", "aiConfScore": "82%", "aiPopulated": "expedited", "userPopulated": ""}, "templateType": {"aiNotes": "", "aiConfScore": "85%", "aiPopulated": "IP Hospital (REV 0110)", "userPopulated": ""}, "startOfService": {"aiNotes": "", "aiConfScore": "75%", "aiPopulated": "2025-10-20", "userPopulated": ""}, "receivedDateTime": {"aiNotes": "", "aiConfScore": "90%", "aiPopulated": "2025-10-22T08:47:21.885Z", "userPopulated": ""}}, "diagnosis_codes": [{"code": {"aiNotes": "", "aiConfScore": "90%", "aiPopulated": "J45.909", "userPopulated": ""}, "description": {"aiNotes": "", "aiConfScore": "91%", "aiPopulated": "Unspecified asthma, uncomplicated", "userPopulated": ""}}, {"code": {"aiNotes": "", "aiConfScore": "84%", "aiPopulated": "E11.9", "userPopulated": ""}, "description": {"aiNotes": "", "aiConfScore": "83%", "aiPopulated": "Type 2 diabetes mellitus without complications", "userPopulated": ""}}], "requested_items": [{"units": {"aiNotes": "", "aiConfScore": "80%", "aiPopulated": "mg", "userPopulated": ""}, "cptRev": {"aiNotes": "", "aiConfScore": "88%", "aiPopulated": "99214", "userPopulated": ""}, "dosage": {"aiNotes": "", "aiConfScore": "80%", "aiPopulated": "10", "userPopulated": ""}, "duration": {"aiNotes": "", "aiConfScore": "81%", "aiPopulated": "30 days", "userPopulated": ""}, "frequency": {"aiNotes": "", "aiConfScore": "82%", "aiPopulated": "Daily", "userPopulated": ""}}], "request_provider_info": {"requestingFax": {"aiNotes": "", "aiConfScore": "68%", "aiPopulated": "555-123-7890", "userPopulated": ""}, "requestingEmail": {"aiNotes": "", "aiConfScore": "80%", "aiPopulated": "provider@example.com", "userPopulated": ""}, "requestingPhone": {"aiNotes": "", "aiConfScore": "72%", "aiPopulated": "555-123-4567", "userPopulated": ""}, "requestingProvider": {"aiNotes": "", "aiConfScore": "99%", "aiPopulated": "Dr. James Smith", "userPopulated": ""}, "requestingProviderNPI": {"aiNotes": "", "aiConfScore": "98%", "aiPopulated": "1234567890", "userPopulated": ""}}, "service_provider_info": {"servicingFax": {"aiNotes": "", "aiConfScore": "90%", "aiPopulated": "701-756-0124", "userPopulated": ""}, "servicingEmail": {"aiNotes": "", "aiConfScore": "98%", "aiPopulated": "servicing@example.com", "userPopulated": ""}, "servicingPhone": {"aiNotes": "", "aiConfScore": "80%", "aiPopulated": "301-256-0124", "userPopulated": ""}, "servicingProvider": {"aiNotes": "", "aiConfScore": "80%", "aiPopulated": "Jane Doe", "userPopulated": ""}, "servicingProviderNPI": {"aiNotes": "", "aiConfScore": "80%", "aiPopulated": "4845458484", "userPopulated": ""}}}', '2025-11-13 14:00:01.512281', NULL, '2025-11-21 09:48:39.220989', NULL, false, NULL, NULL, 3, NULL);
INSERT INTO um.um_authorizations VALUES (14, '20251120_225151_b30a87a0.pdf', 'https://umautomationstorage.blob.core.windows.net/um-upload-doc/20251120_225151_b30a87a0.pdf', 1914171, '2025-11-20 22:51:51.551473', NULL, '929ec345-be52-43be-bcdb-865056d062a2', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'Upload', 'Undetermined', 'Undetermined', '2025-11-20 22:51:51.393161', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-20 22:51:51.551473', NULL, '2025-11-21 09:48:39.220989', NULL, false, NULL, NULL, 2, NULL);
INSERT INTO um.um_authorizations VALUES (15, '20251120_225959_08d37993.pdf', 'https://umautomationstorage.blob.core.windows.net/um-upload-doc/20251120_225959_08d37993.pdf', 1110840, '2025-11-20 22:59:59.529625', NULL, 'c9a461b8-30d3-46c9-bd6b-2a83eca96986', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'Upload', 'Undetermined', 'Undetermined', '2025-11-20 22:59:59.400127', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-20 22:59:59.529625', NULL, '2025-11-21 09:48:39.220989', NULL, false, NULL, NULL, 2, NULL);
INSERT INTO um.um_authorizations VALUES (16, '20251121_083219_ed78a3fd.pdf', 'https://umautomationstorage.blob.core.windows.net/um-upload-doc/20251121_083219_ed78a3fd.pdf', 1914171, '2025-11-21 08:32:19.839229', NULL, 'defdd167-c5c6-4192-bcc7-e70479511add', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'Upload', 'Undetermined', 'Undetermined', '2025-11-21 08:32:19.827161', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"fields": [{"aiNotes": "", "required": false, "fieldName": "additionalNotes", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient is compliant with treatment and demonstrates good understanding of condition management.", "userPopulated": ""}, {"aiNotes": "Conditional - shown when determination is approved or partially_approved", "required": false, "fieldName": "approvedEndDate", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Conditional - shown when determination is approved or partially_approved", "required": false, "fieldName": "approvedStartDate", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "assessmentPlan", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "1. COPD exacerbation - responding well to corticosteroids and bronchodilators. Continue current treatment plan.\n2. Hypertension - stable, continue home medications\n3. Diabetes - stable, continue metformin\n4. Discharge planning - patient meets criteria for continued inpatient stay for monitoring and treatment optimization.", "userPopulated": ""}, {"aiNotes": "User assigned to process the case", "required": false, "fieldName": "assignedUser", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Sarah Johnson", "userPopulated": ""}, {"aiNotes": "Auto-generated if not provided", "required": false, "fieldName": "authorizationNumber", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "AUTH123456", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "briefClinicalCourse", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient admitted with acute COPD exacerbation. Presented with SOB and chest pain following physical exertion. Currently stable on treatment with prednisone and albuterol. Vital signs improving, O2 sat 92%. Plan for 5-day steroid course and discharge planning in progress.", "userPopulated": ""}, {"aiNotes": "AI-generated clinical rationale", "required": false, "fieldName": "clinicalRationale", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient ID: 12345, Review Type: Pre-Service, Priority: Standard. Clinical Course: Patient admitted for CHF exacerbation, stable on current treatment. Past Medical History: Hypertension, Type 2 Diabetes, prior MI. Skilled Needs: Daily monitoring of vitals, medication management. Medications: Lisinopril 10mg daily, Metformin 500mg BID, IV Lasix 40mg daily.", "userPopulated": ""}, {"aiNotes": "Case complexity level", "required": false, "fieldName": "complexity", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "High", "allowedValues": ["High", "Medium", "Standard", "Low"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "concurrentUpdates", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Day 2: Patient showing improvement in respiratory status. O2 saturation improved to 94%. Continue current treatment plan.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactEmail", "fieldSize": 100, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "mchen@metrogeneral.com", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactFacility", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Metro General Hospital", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactFax", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "(555) 123-4568", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Dr. Michael Chen", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactPhone", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "(555) 123-4567", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "criteria", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "InterQual Acute Adult Criteria for COPD exacerbation requiring inpatient level of care:\n- Acute respiratory symptoms with documented COPD\n- Oxygen saturation <95% on room air\n- Requiring systemic corticosteroids\n- Need for frequent monitoring and medication adjustment", "userPopulated": ""}, {"aiNotes": "AI-generated criteria analysis", "required": false, "fieldName": "criteriaAnalysis", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Based on analysis of clinical documentation against InterQual criteria, patient meets medical necessity for continued inpatient care.", "userPopulated": ""}, {"aiNotes": "File path for uploaded criteria document", "required": false, "fieldName": "criteriaUpload", "fieldSize": 500, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Conditional - shown when determination is denied or partially_approved", "required": false, "fieldName": "denialRationale", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Conditional - shown when mdDetermination is Denied or Partially Approved. Simple language for member letters.", "required": false, "fieldName": "denialRationaleMD", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Values: approved, partially_approved, denied, sent_to_md", "required": true, "fieldName": "determination", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["approved", "partially_approved", "denied", "sent_to_md"], "userPopulated": ""}, {"aiNotes": "Values: medical_necessity, administrative", "required": false, "fieldName": "determinationType", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "medical_necessity", "allowedValues": ["medical_necessity", "administrative"], "userPopulated": ""}, {"aiNotes": "Array of diagnosis codes", "required": false, "fieldName": "diagnosisCodes", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": [{"code": "J45.909", "confScore": "78%", "description": "Unspecified asthma, uncomplicated"}, {"code": "E11.9", "confScore": "28%", "description": "Type 2 diabetes mellitus without complications"}], "userPopulated": []}, {"aiNotes": "", "required": false, "fieldName": "dischargePlanBarriers", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Discharge planning initiated. Patient requires completion of 5-day steroid course. No identified barriers to discharge. Patient has support system at home and adequate understanding of medication regimen.", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "dob", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "88%", "aiPopulated": "1965-01-15", "userPopulated": ""}, {"aiNotes": "System-generated document identifier", "required": false, "fieldName": "documentId", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "DOC-2025-08-001", "userPopulated": ""}, {"aiNotes": "File path for uploaded document", "required": false, "fieldName": "documentUpload", "fieldSize": 500, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "escalationDate", "fieldSize": null, "fieldType": "TIMESTAMP", "aiConfScore": "", "aiPopulated": "2025-08-21T14:30:00", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "escalationReason", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Requires MD review for medical necessity of continued IV therapy and complex comorbidities requiring physician-level assessment.", "userPopulated": ""}, {"aiNotes": "Type of escalation to Medical Director", "required": false, "fieldName": "escalationType", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Nurse Review", "allowedValues": ["Nurse Review", "Appeal", "Complex Case", "Second Opinion"], "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "healthPlan", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "85%", "aiPopulated": "Medicare Advantage Plus", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "healthplanId", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "92%", "aiPopulated": "HP123456", "userPopulated": ""}, {"aiNotes": "Time elapsed since receipt - calculated field", "required": false, "fieldName": "lapseTime", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "2h 15m", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "lastTherapyCertification", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Previous therapy certification: Physical therapy completed 6 months ago for knee rehabilitation.", "userPopulated": ""}, {"aiNotes": "Values: Approved, Partially Approved, Denied", "required": true, "fieldName": "mdDetermination", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["Approved", "Partially Approved", "Denied"], "userPopulated": ""}, {"aiNotes": "Medical Director''s clinical assessment and rationale", "required": true, "fieldName": "mdNote", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Array of medication calculations with dosage details", "required": false, "fieldName": "medicationCalculations", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": [{"cptHcps": "J7506", "freqType": "days", "unitsPer": 10, "frequency": 1, "totalUnits": 20, "doseRequested": 40, "totalUnitsPerDay": 4, "frequencyDuration": 5}], "userPopulated": []}, {"aiNotes": "", "required": false, "fieldName": "medicationsIvFluids", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "1. Lisinopril 10 mg PO daily for hypertension\n2. Metformin 500 mg PO BID for diabetes\n3. Albuterol inhaler 2 puffs q4h PRN dyspnea\n4. Prednisone 40 mg PO daily x 5 days for COPD exacerbation", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "memberName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "95%", "aiPopulated": "John Doe", "userPopulated": "Arun"}, {"aiNotes": "Pre-populated in Medical Director screen from nurse review", "required": false, "fieldName": "nurseReviewNote", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient ID: 12345, Review Type: Pre-Service, Priority: Standard, Clinical Course: Patient admitted for CHF exacerbation, stable on current treatment. Past Medical History: Hypertension, Type 2 Diabetes, prior MI. Skilled Needs: Daily monitoring of vitals, medication management. Medications: Lisinopril 10mg daily, Metformin 500mg BID, IV Lasix 40mg daily. Wounds: Stage 2 pressure ulcer, left heel, 2cm x 2cm x 0.5cm, minimal exudate, treated with hydrocolloid dressing. Physical Therapy: Bed mobility MODA, transfers CGA, ambulation 50ft with walker. Determination: Sent To MD, Rationale: Requires MD review for medical necessity of continued IV therapy and complex comorbidities.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "nurseReviewer", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Sarah Johnson, RN", "userPopulated": ""}, {"aiNotes": "Original nurse reviewer who escalated the case", "required": false, "fieldName": "originalReviewer", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Sarah Johnson, RN", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "pastMedicalHistory", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Hypertension (diagnosed 2015), Type 2 Diabetes Mellitus (diagnosed 2018), Chronic Obstructive Pulmonary Disease. No prior hospitalizations for COPD exacerbation in past 12 months.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "patientId", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "12345", "userPopulated": ""}, {"aiNotes": "Physical/Occupational therapy assessment", "required": false, "fieldName": "physicalTherapy", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": {"transfers": "CGA", "ambulation": "50ft with walker", "bedMobility": "MODA"}, "userPopulated": {}}, {"aiNotes": "Low confidence - verify priority", "required": true, "fieldName": "priority", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "28%", "aiPopulated": "expedited", "allowedValues": ["Expedited Part B Med", "Expedited", "Standard Part B Med", "Standard", "Expedited Med-Service", "Standard Med-Service", "Retrospective", "Urgent"], "userPopulated": ""}, {"aiNotes": "Primary CPT/HCPCS procedure code", "required": false, "fieldName": "procedureCode", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "99214", "userPopulated": ""}, {"aiNotes": "Values: processed, processed-with-1-phi, unable-to-process", "required": false, "fieldName": "processingResult", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["processed", "processed-with-1-phi", "unable-to-process"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "radiologyDiagnostics", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Chest X-Ray (08/20/2025): No evidence of pneumonia or pneumothorax. EKG: Sinus rhythm, no acute ischemic changes. ABG pending.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "readmission", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "No readmissions in past 12 months. Low risk for 30-day readmission given patient compliance and support system.", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "receiptDateTime", "fieldSize": null, "fieldType": "TIMESTAMP", "aiConfScore": "", "aiPopulated": "2025-08-06T10:15:00", "userPopulated": ""}, {"aiNotes": "AI-recommended determination", "required": false, "fieldName": "recommendedDetermination", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Approved", "allowedValues": ["Approved", "Partially Approved", "Denied", "Sent to MD"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "requestMethod", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "fax", "allowedValues": ["phone", "email", "fax", "portal"], "userPopulated": ""}, {"aiNotes": "Array of requested items/procedures", "required": false, "fieldName": "requestedItems", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": [{"cptRev": "99214", "duration": "30 days", "frequency": "Daily", "dosageUnits": "10mg"}], "userPopulated": []}, {"aiNotes": "", "required": false, "fieldName": "requestingEmail", "fieldSize": 100, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "requestingFax", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "68%", "aiPopulated": "(555) 123-4568", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "requestingName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "87%", "aiPopulated": "Dr. Jane Smith, MD", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "requestingNpi", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "98%", "aiPopulated": "1234567890", "userPopulated": ""}, {"aiNotes": "Requesting provider NPI for display in queue", "required": false, "fieldName": "requestingNpiDisplay", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "1234567890", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "requestingPhone", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "72%", "aiPopulated": "(555) 123-4567", "userPopulated": ""}, {"aiNotes": "Final determination result", "required": false, "fieldName": "result", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["Approved", "Denied", "Partially Approved", "Sent to MD", "Pending"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "reviewDate", "fieldSize": null, "fieldType": "TIMESTAMP", "aiConfScore": "", "aiPopulated": "2025-08-21T00:00:00", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "reviewType", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "pre_service", "allowedValues": ["Pre-Service", "Concurrent", "Retrospective", "Post-Service", "Appeal"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingEmail", "fieldSize": 100, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingFax", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Servicing provider name for display in queue", "required": false, "fieldName": "servicingNameDisplay", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Metro General Hospital", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingNpi", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingPhone", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "skilledNeeds", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Continuous monitoring of respiratory status, medication administration and titration, patient education regarding COPD management and medication compliance. Requires skilled nursing assessment of response to treatment.", "userPopulated": ""}, {"aiNotes": "Document source", "required": false, "fieldName": "source", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "fax", "allowedValues": ["fax", "portal", "upload", "email"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "speechTherapy", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "No speech therapy needs identified at this time.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "startOfCare", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Case processing status", "required": false, "fieldName": "status", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "New", "allowedValues": ["New", "In Progress", "Reviewed", "Pending", "Completed", "On Hold"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "templateList", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "ip_hospital", "allowedValues": ["ip_hospital", "ip_psych_hospital", "irf", "ltac", "snf", "sip", "part_b_medications", "part_therapy", "dme", "other_part_b"], "userPopulated": ""}, {"aiNotes": "Template: IP Hospital (REV 0110)", "required": true, "fieldName": "templateType", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "ip-hospital", "allowedValues": ["IP Hospital (REV 0110)", "IP Psych Hospital (REV 0110)", "IRF (REV 0024)", "LTAC (REV 0110)", "SNF (0022)", "SIP (REV 0559)", "Part B Medications", "Part Therapy", "DME", "Other Part B Items/Services"], "userPopulated": ""}, {"aiNotes": "Conditional field shown when processingResult is unable-to-process", "required": false, "fieldName": "unableReason", "fieldSize": 500, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "ventilator", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Not applicable - patient not requiring ventilator support", "userPopulated": ""}, {"aiNotes": "Array of wound assessments", "required": false, "fieldName": "wounds", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": [{"depth": 0.5, "stage": "Stage 2", "width": 2, "length": 2, "exudate": "Minimal", "location": "Left heel", "treatment": "Hydrocolloid dressing"}], "userPopulated": []}]}', '2025-11-21 08:32:19.839229', NULL, '2025-11-24 13:46:52.556863', NULL, false, NULL, NULL, 5, NULL);
INSERT INTO um.um_authorizations VALUES (22, '20251121_160010_e526aa6d.pdf', 'https://umautomationstorage.blob.core.windows.net/um-upload-doc/20251121_160010_e526aa6d.pdf', 1914171, '2025-11-21 16:00:10.845936', NULL, 'e6850498-fe00-4195-94c3-573aca1d7455', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'Upload', 'Undetermined', 'Undetermined', '2025-11-21 16:00:10.836917', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"fields": [{"aiNotes": "", "required": false, "fieldName": "additionalNotes", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient is compliant with treatment and demonstrates good understanding of condition management.", "userPopulated": ""}, {"aiNotes": "Conditional - shown when determination is approved or partially_approved", "required": false, "fieldName": "approvedEndDate", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Conditional - shown when determination is approved or partially_approved", "required": false, "fieldName": "approvedStartDate", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "assessmentPlan", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "1. COPD exacerbation - responding well to corticosteroids and bronchodilators. Continue current treatment plan.\n2. Hypertension - stable, continue home medications\n3. Diabetes - stable, continue metformin\n4. Discharge planning - patient meets criteria for continued inpatient stay for monitoring and treatment optimization.", "userPopulated": ""}, {"aiNotes": "User assigned to process the case", "required": false, "fieldName": "assignedUser", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Sarah Johnson", "userPopulated": ""}, {"aiNotes": "Auto-generated if not provided", "required": false, "fieldName": "authorizationNumber", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "AUTH123456", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "briefClinicalCourse", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient admitted with acute COPD exacerbation. Presented with SOB and chest pain following physical exertion. Currently stable on treatment with prednisone and albuterol. Vital signs improving, O2 sat 92%. Plan for 5-day steroid course and discharge planning in progress.", "userPopulated": ""}, {"aiNotes": "AI-generated clinical rationale", "required": false, "fieldName": "clinicalRationale", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient ID: 12345, Review Type: Pre-Service, Priority: Standard. Clinical Course: Patient admitted for CHF exacerbation, stable on current treatment. Past Medical History: Hypertension, Type 2 Diabetes, prior MI. Skilled Needs: Daily monitoring of vitals, medication management. Medications: Lisinopril 10mg daily, Metformin 500mg BID, IV Lasix 40mg daily.", "userPopulated": ""}, {"aiNotes": "Case complexity level", "required": false, "fieldName": "complexity", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "High", "allowedValues": ["High", "Medium", "Standard", "Low"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "concurrentUpdates", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Day 2: Patient showing improvement in respiratory status. O2 saturation improved to 94%. Continue current treatment plan.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactEmail", "fieldSize": 100, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "mchen@metrogeneral.com", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactFacility", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Metro General Hospital", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactFax", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "(555) 123-4568", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Dr. Michael Chen", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactPhone", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "(555) 123-4567", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "criteria", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "InterQual Acute Adult Criteria for COPD exacerbation requiring inpatient level of care:\n- Acute respiratory symptoms with documented COPD\n- Oxygen saturation <95% on room air\n- Requiring systemic corticosteroids\n- Need for frequent monitoring and medication adjustment", "userPopulated": ""}, {"aiNotes": "AI-generated criteria analysis", "required": false, "fieldName": "criteriaAnalysis", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Based on analysis of clinical documentation against InterQual criteria, patient meets medical necessity for continued inpatient care.", "userPopulated": ""}, {"aiNotes": "File path for uploaded criteria document", "required": false, "fieldName": "criteriaUpload", "fieldSize": 500, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Conditional - shown when determination is denied or partially_approved", "required": false, "fieldName": "denialRationale", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Conditional - shown when mdDetermination is Denied or Partially Approved. Simple language for member letters.", "required": false, "fieldName": "denialRationaleMD", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Values: approved, partially_approved, denied, sent_to_md", "required": true, "fieldName": "determination", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["approved", "partially_approved", "denied", "sent_to_md"], "userPopulated": ""}, {"aiNotes": "Values: medical_necessity, administrative", "required": false, "fieldName": "determinationType", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "medical_necessity", "allowedValues": ["medical_necessity", "administrative"], "userPopulated": ""}, {"aiNotes": "Array of diagnosis codes - updated format for React component", "required": false, "fieldName": "diagnosis_codes", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": ["0001B - Cholera dt Vibrio cholerae"], "userPopulated": []}, {"aiNotes": "", "required": false, "fieldName": "dischargePlanBarriers", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Discharge planning initiated. Patient requires completion of 5-day steroid course. No identified barriers to discharge. Patient has support system at home and adequate understanding of medication regimen.", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "dob", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "88%", "aiPopulated": "1965-01-15", "userPopulated": ""}, {"aiNotes": "System-generated document identifier", "required": false, "fieldName": "documentId", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "DOC-2025-08-001", "userPopulated": ""}, {"aiNotes": "File path for uploaded document", "required": false, "fieldName": "documentUpload", "fieldSize": 500, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "escalationDate", "fieldSize": null, "fieldType": "TIMESTAMP", "aiConfScore": "", "aiPopulated": "2025-08-21T14:30:00", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "escalationReason", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Requires MD review for medical necessity of continued IV therapy and complex comorbidities requiring physician-level assessment.", "userPopulated": ""}, {"aiNotes": "Type of escalation to Medical Director", "required": false, "fieldName": "escalationType", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Nurse Review", "allowedValues": ["Nurse Review", "Appeal", "Complex Case", "Second Opinion"], "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "healthPlan", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "85%", "aiPopulated": "KeyCare Advantage", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "healthplanId", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "92%", "aiPopulated": "H6959", "userPopulated": ""}, {"aiNotes": "Time elapsed since receipt - calculated field", "required": false, "fieldName": "lapseTime", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "2h 15m", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "lastTherapyCertification", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Previous therapy certification: Physical therapy completed 6 months ago for knee rehabilitation.", "userPopulated": ""}, {"aiNotes": "Values: Approved, Partially Approved, Denied", "required": true, "fieldName": "mdDetermination", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["Approved", "Partially Approved", "Denied"], "userPopulated": ""}, {"aiNotes": "Medical Director''s clinical assessment and rationale", "required": true, "fieldName": "mdNote", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Array of medication calculations with dosage details", "required": false, "fieldName": "medicationCalculations", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": [{"cptHcps": "J7506", "freqType": "days", "unitsPer": 10, "frequency": 1, "totalUnits": 20, "doseRequested": 40, "totalUnitsPerDay": 4, "frequencyDuration": 5}], "userPopulated": []}, {"aiNotes": "", "required": false, "fieldName": "medicationsIvFluids", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "1. Lisinopril 10 mg PO daily for hypertension\n2. Metformin 500 mg PO BID for diabetes\n3. Albuterol inhaler 2 puffs q4h PRN dyspnea\n4. Prednisone 40 mg PO daily x 5 days for COPD exacerbation", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "memberName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "95%", "aiPopulated": "John Doe", "userPopulated": "Arun"}, {"aiNotes": "Pre-populated in Medical Director screen from nurse review", "required": false, "fieldName": "nurseReviewNote", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient ID: 12345, Review Type: Pre-Service, Priority: Standard, Clinical Course: Patient admitted for CHF exacerbation, stable on current treatment. Past Medical History: Hypertension, Type 2 Diabetes, prior MI. Skilled Needs: Daily monitoring of vitals, medication management. Medications: Lisinopril 10mg daily, Metformin 500mg BID, IV Lasix 40mg daily. Wounds: Stage 2 pressure ulcer, left heel, 2cm x 2cm x 0.5cm, minimal exudate, treated with hydrocolloid dressing. Physical Therapy: Bed mobility MODA, transfers CGA, ambulation 50ft with walker. Determination: Sent To MD, Rationale: Requires MD review for medical necessity of continued IV therapy and complex comorbidities.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "nurseReviewer", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Sarah Johnson, RN", "userPopulated": ""}, {"aiNotes": "Original nurse reviewer who escalated the case", "required": false, "fieldName": "originalReviewer", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Sarah Johnson, RN", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "pastMedicalHistory", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Hypertension (diagnosed 2015), Type 2 Diabetes Mellitus (diagnosed 2018), Chronic Obstructive Pulmonary Disease. No prior hospitalizations for COPD exacerbation in past 12 months.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "patientId", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "12345", "userPopulated": ""}, {"aiNotes": "Physical/Occupational therapy assessment", "required": false, "fieldName": "physicalTherapy", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": {"transfers": "CGA", "ambulation": "50ft with walker", "bedMobility": "MODA"}, "userPopulated": {}}, {"aiNotes": "Low confidence - verify priority", "required": true, "fieldName": "priority", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "28%", "aiPopulated": "undetermined", "allowedValues": ["expedited_part_b_med", "expedited", "standard_part_b_med", "standard", "undetermined"], "userPopulated": ""}, {"aiNotes": "Primary CPT/HCPCS procedure code", "required": false, "fieldName": "procedureCode", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "99214", "userPopulated": ""}, {"aiNotes": "Values: processed, processed-with-1-phi, unable-to-process", "required": false, "fieldName": "processingResult", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["processed", "processed-with-1-phi", "unable-to-process"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "radiologyDiagnostics", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Chest X-Ray (08/20/2025): No evidence of pneumonia or pneumothorax. EKG: Sinus rhythm, no acute ischemic changes. ABG pending.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "readmission", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "No readmissions in past 12 months. Low risk for 30-day readmission given patient compliance and support system.", "userPopulated": ""}, {"aiNotes": "Updated field name for React component", "required": true, "fieldName": "receipt_date", "fieldSize": null, "fieldType": "TIMESTAMP", "aiConfScore": "", "aiPopulated": "2025-08-06T10:15:00", "userPopulated": ""}, {"aiNotes": "AI-recommended determination", "required": false, "fieldName": "recommendedDetermination", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Approved", "allowedValues": ["Approved", "Partially Approved", "Denied", "Sent to MD"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "requestMethod", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "fax", "allowedValues": ["phone", "email", "fax", "portal"], "userPopulated": ""}, {"aiNotes": "Array of requested items/procedures - updated format for React component", "required": false, "fieldName": "requested_items", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": [{"units": "each", "dosage": "10mg", "cpt_rev": "99214", "duration": "30 days", "end_date": "2025-09-05", "ndc_code": "", "quantity": "1", "frequency": "Daily", "hcpcs_code": "99214", "start_date": "2025-08-06", "place_of_service": "Office", "procedure_description": "Office/outpatient visit est"}], "userPopulated": []}, {"aiNotes": "", "required": false, "fieldName": "requestingEmail", "fieldSize": 100, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "requestingFax", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "68%", "aiPopulated": "(555) 123-4568", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "requestingName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "87%", "aiPopulated": "Dr. Jane Smith, MD", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "requestingNpi", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "98%", "aiPopulated": "1234567890", "userPopulated": ""}, {"aiNotes": "Requesting provider NPI for display in queue", "required": false, "fieldName": "requestingNpiDisplay", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "1234567890", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "requestingPhone", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "72%", "aiPopulated": "(555) 123-4567", "userPopulated": ""}, {"aiNotes": "Final determination result", "required": false, "fieldName": "result", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["Approved", "Denied", "Partially Approved", "Sent to MD", "Pending"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "reviewDate", "fieldSize": null, "fieldType": "TIMESTAMP", "aiConfScore": "", "aiPopulated": "2025-08-21T00:00:00", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "reviewType", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "pre_service", "allowedValues": ["Pre-Service", "Concurrent", "Retrospective", "Post-Service", "Appeal"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingEmail", "fieldSize": 100, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "testservicingemail@gmail.com", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingFax", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "111", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Metro General Hospita", "userPopulated": ""}, {"aiNotes": "Servicing provider name for display in queue", "required": false, "fieldName": "servicingNameDisplay", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Metro General Hospital", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingNpi", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingPhone", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "skilledNeeds", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Continuous monitoring of respiratory status, medication administration and titration, patient education regarding COPD management and medication compliance. Requires skilled nursing assessment of response to treatment.", "userPopulated": ""}, {"aiNotes": "Document source", "required": false, "fieldName": "source", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "fax", "allowedValues": ["fax", "portal", "upload", "email"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "speechTherapy", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "No speech therapy needs identified at this time.", "userPopulated": ""}, {"aiNotes": "Updated field name for React component", "required": false, "fieldName": "start_of_care", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "", "aiPopulated": "2025-08-06", "userPopulated": ""}, {"aiNotes": "Case processing status", "required": false, "fieldName": "status", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "New", "allowedValues": ["New", "In Progress", "Reviewed", "Pending", "Completed", "On Hold"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "templateList", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "ip_hospital", "allowedValues": ["ip_hospital", "ip_psych_hospital", "irf", "ltac", "snf", "sip", "part_b_medications", "part_therapy", "dme", "other_part_b"], "userPopulated": ""}, {"aiNotes": "Template: IP Hospital (REV 0110) - updated field name for React component", "required": true, "fieldName": "template_type", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "IP Hospital (REV 0110)", "allowedValues": ["IP Hospital (REV 0110)", "IP Psych Hospital (REV 0110)", "IRF (REV 0024)", "LTAC (REV 0110)", "SNF (0022)", "SIP (REV 0559)", "Part B Medications", "Part Therapy", "DME", "Other Part B Items/Services"], "userPopulated": ""}, {"aiNotes": "Conditional field shown when processingResult is unable-to-process", "required": false, "fieldName": "unableReason", "fieldSize": 500, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "ventilator", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Not applicable - patient not requiring ventilator support", "userPopulated": ""}, {"aiNotes": "Array of wound assessments", "required": false, "fieldName": "wounds", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": [{"depth": 0.5, "stage": "Stage 2", "width": 2, "length": 2, "exudate": "Minimal", "location": "Left heel", "treatment": "Hydrocolloid dressing"}], "userPopulated": []}]}', '2025-11-21 16:00:10.845936', NULL, '2025-11-26 10:50:16.363754', NULL, false, NULL, NULL, 4, NULL);
INSERT INTO um.um_authorizations VALUES (23, 'AUT25104P000087 - initial Clinical2.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/AUT25104P000087 - initial Clinical2.pdf', 1914171, '2025-11-26 17:27:45.416761', NULL, '3d7cfa20-fde1-4203-b1b6-24a6e99f02aa', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:35:37.429354', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:45.416761', NULL, '2025-11-26 17:27:45.416761', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (24, 'AUT25104P000087 - initial Clinical2.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/AUT25104P000087 - initial Clinical2.pdf', 1914171, '2025-11-26 17:27:45.536424', NULL, '1166dd08-c155-4584-81c9-8e0793d4b6dd', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:35:37.429354', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:45.536424', NULL, '2025-11-26 17:27:45.536424', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (25, '20251110_135727_2428182a.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/20251110_135727_2428182a.pdf', 1110840, '2025-11-26 17:27:45.654715', NULL, '2ad49458-0d57-430e-9c9a-64a09db08ba5', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:05:49.152434', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:45.654715', NULL, '2025-11-26 17:27:45.654715', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (26, 'H00004752 - initial clinical.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/H00004752 - initial clinical.pdf', 1110840, '2025-11-26 17:27:45.906602', NULL, 'ef9e7ccf-e41e-4c92-afac-d19db5c9ae6b', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:56:29.158987', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:45.906602', NULL, '2025-11-26 17:27:45.906602', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (27, 'H00004752 - initial clinical.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/H00004752 - initial clinical.pdf', 1110840, '2025-11-26 17:27:46.086284', NULL, '1c99d4c8-fea7-4835-988f-6bb2ed1fea1f', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:56:29.158987', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:46.086284', NULL, '2025-11-26 17:27:46.086284', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (28, '20251110_135727_2428182a.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/20251110_135727_2428182a.pdf', 1110840, '2025-11-26 17:27:46.443886', NULL, '3f86e2be-1e51-4331-9832-4a1e82b2f3eb', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:05:49.152434', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:46.443886', NULL, '2025-11-26 17:27:46.443886', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (29, 'H00004752 - initial clinical.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/H00004752 - initial clinical.pdf', 1110840, '2025-11-26 17:27:46.482272', NULL, '8b5b738f-befb-4870-8638-37845f3a29fc', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:56:29.158987', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:46.482272', NULL, '2025-11-26 17:27:46.482272', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (30, 'AUT25104P000087 - initial Clinical2.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/AUT25104P000087 - initial Clinical2.pdf', 1914171, '2025-11-26 17:27:46.615806', NULL, '85f8e32f-1e76-44c4-98b6-1b799e3f2108', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:35:37.429354', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:46.615806', NULL, '2025-11-26 17:27:46.615806', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (31, '20251110_135727_2428182a.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/20251110_135727_2428182a.pdf', 1110840, '2025-11-26 17:27:46.816298', NULL, '77116915-5fc3-4514-a960-3ca33eaae703', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:05:49.152434', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:46.816298', NULL, '2025-11-26 17:27:46.816298', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (32, 'AUT25104P000087 - initial Clinical2.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/AUT25104P000087 - initial Clinical2.pdf', 1914171, '2025-11-26 17:27:46.980923', NULL, 'f0e2d270-f4ef-4e72-96fb-b82b35f815fe', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:35:37.429354', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:46.980923', NULL, '2025-11-26 17:27:46.980923', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (33, 'AUT25104P000087 - initial Clinical2.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/AUT25104P000087 - initial Clinical2.pdf', 1914171, '2025-11-26 17:27:46.993071', NULL, '89b40192-4b6d-4a7e-82c6-f3de3b96f3e1', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:35:37.429354', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:46.993071', NULL, '2025-11-26 17:27:46.993071', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (34, 'AUT25104P000087 - initial Clinical2.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/AUT25104P000087 - initial Clinical2.pdf', 1914171, '2025-11-26 17:27:47.123901', NULL, '7a41de0b-e430-4431-86e0-e9ecc91af551', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:35:37.429354', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:47.123901', NULL, '2025-11-26 17:27:47.123901', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (35, '20251110_135727_2428182a.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/20251110_135727_2428182a.pdf', 1110840, '2025-11-26 17:27:47.416183', NULL, 'af63ade1-ad19-4857-a185-05e9569d07e8', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:05:49.152434', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:47.416183', NULL, '2025-11-26 17:27:47.416183', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (36, '20251110_135727_2428182a.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/20251110_135727_2428182a.pdf', 1110840, '2025-11-26 17:27:47.486754', NULL, 'ffef0644-5c41-4d87-a2f1-e6c21d27d134', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:05:49.152434', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:47.486754', NULL, '2025-11-26 17:27:47.486754', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (37, '20251110_135727_2428182a.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/20251110_135727_2428182a.pdf', 1110840, '2025-11-26 17:27:47.646705', NULL, 'cd489309-7f7a-4f39-8736-0d8d08f12925', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:05:49.152434', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:47.646705', NULL, '2025-11-26 17:27:47.646705', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (38, 'H00004752 - initial clinical.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/H00004752 - initial clinical.pdf', 1110840, '2025-11-26 17:27:47.872643', NULL, 'd7b5948d-a87d-411a-b3e4-0ceb9ec5b229', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:56:29.158987', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:47.872643', NULL, '2025-11-26 17:27:47.872643', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (39, '20251110_135727_2428182a.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/20251110_135727_2428182a.pdf', 1110840, '2025-11-26 17:27:48.085682', NULL, 'aef257aa-24e3-49fb-a621-7b69634158f3', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:05:49.152434', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:48.085682', NULL, '2025-11-26 17:27:48.085682', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (40, 'AUT25104P000087 - initial Clinical2.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/AUT25104P000087 - initial Clinical2.pdf', 1914171, '2025-11-26 17:27:48.477181', NULL, '13adb027-8a91-4881-bb90-30035172b54e', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:35:37.429354', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:48.477181', NULL, '2025-11-26 17:27:48.477181', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (41, '20251110_135727_2428182a.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/20251110_135727_2428182a.pdf', 1110840, '2025-11-26 17:27:49.057844', NULL, '5458c88e-6016-4de5-8261-17b6e9adccb9', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:05:49.152434', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:49.057844', NULL, '2025-11-26 17:27:49.057844', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (42, '20251110_135727_2428182a.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/20251110_135727_2428182a.pdf', 1110840, '2025-11-26 17:27:50.149276', NULL, '168717ab-36d0-4725-9d54-c4a21b586c7b', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-21 11:05:49.152434', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:27:50.149276', NULL, '2025-11-26 17:27:50.149276', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (43, '20251121_135110_04697b76.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/20251121_135110_04697b76.pdf', 1914171, '2025-11-26 17:30:52.834101', NULL, '97604388-27f5-42f7-a4f8-1cf0192ade80', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-26 17:30:51.189658', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:30:52.834101', NULL, '2025-11-26 17:30:52.834101', NULL, false, NULL, NULL, 1, NULL);
INSERT INTO um.um_authorizations VALUES (44, '20251121_082317_273856f5.pdf', 'https://umautomationstorage.blob.core.windows.net/um-fax/20251121_082317_273856f5.pdf', 1914171, '2025-11-26 17:34:22.122266', NULL, '0e5e25b0-1a8f-441b-81ed-f86de1354c0a', NULL, 'Unassigned', '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', NULL, 'fax', 'Undetermined', 'Undetermined', '2025-11-26 17:34:21.458462', NULL, 'Queued', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '2025-11-26 17:34:22.122266', NULL, '2025-11-26 17:34:22.122266', NULL, false, NULL, NULL, 1, NULL);


--
-- TOC entry 4804 (class 0 OID 39157)
-- Dependencies: 280
-- Data for Name: um_case_lock; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.um_case_lock VALUES ('7c09af28-1788-b835-f1fd-a75468f19aac', 'e6850498-fe00-4195-94c3-573aca1d7455', 'Arunkumar.Singaram@curanahealth.com', '2025-11-27 05:29:56.548782', '2025-11-27 05:59:56.639764', 'n', 'umdocs_admin', '2025-11-21 21:46:04.715949', 20251121214604, 'umdocs_admin', '2025-11-27 05:29:56.548782', 20251127052956);
INSERT INTO um.um_case_lock VALUES ('32816209-d446-cdb7-9a0b-eb2bcdc5ad66', 'defdd167-c5c6-4192-bcc7-e70479511add', 'Arunkumar.Singaram@curanahealth.com', '2025-11-25 09:27:03.261757', '2025-11-25 10:15:27.153172', 'y', 'umdocs_admin', '2025-11-23 18:43:06.30475', 20251123184306, 'umdocs_admin', '2025-11-25 14:20:43.63198', 20251125142043);
INSERT INTO um.um_case_lock VALUES ('2fd1668c-6509-2c62-5035-0b17f0a3b334', '0e5e25b0-1a8f-441b-81ed-f86de1354c0a', 'Arunkumar.Singaram@curanahealth.com', '2025-11-27 03:31:25.125555', '2025-11-27 04:01:25.22233', 'y', 'umdocs_admin', '2025-11-27 03:31:25.125555', 20251127033125, 'umdocs_admin', '2025-11-27 04:26:01.494339', 20251127042601);


--
-- TOC entry 4803 (class 0 OID 39016)
-- Dependencies: 279
-- Data for Name: um_config; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.um_config VALUES ('4b299a5d-ed47-d93e-78b9-60f1dd05cdce', 'ai_input_field_json', '{"fields": [{"aiNotes": "", "required": false, "fieldName": "additionalNotes", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient is compliant with treatment and demonstrates good understanding of condition management.", "userPopulated": ""}, {"aiNotes": "Conditional - shown when determination is approved or partially_approved", "required": false, "fieldName": "approvedEndDate", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Conditional - shown when determination is approved or partially_approved", "required": false, "fieldName": "approvedStartDate", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "assessmentPlan", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "1. COPD exacerbation - responding well to corticosteroids and bronchodilators. Continue current treatment plan.\n2. Hypertension - stable, continue home medications\n3. Diabetes - stable, continue metformin\n4. Discharge planning - patient meets criteria for continued inpatient stay for monitoring and treatment optimization.", "userPopulated": ""}, {"aiNotes": "User assigned to process the case", "required": false, "fieldName": "assignedUser", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Sarah Johnson", "userPopulated": ""}, {"aiNotes": "Auto-generated if not provided", "required": false, "fieldName": "authorizationNumber", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "AUTH123456", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "briefClinicalCourse", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient admitted with acute COPD exacerbation. Presented with SOB and chest pain following physical exertion. Currently stable on treatment with prednisone and albuterol. Vital signs improving, O2 sat 92%. Plan for 5-day steroid course and discharge planning in progress.", "userPopulated": ""}, {"aiNotes": "AI-generated clinical rationale", "required": false, "fieldName": "clinicalRationale", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient ID: 12345, Review Type: Pre-Service, Priority: Standard. Clinical Course: Patient admitted for CHF exacerbation, stable on current treatment. Past Medical History: Hypertension, Type 2 Diabetes, prior MI. Skilled Needs: Daily monitoring of vitals, medication management. Medications: Lisinopril 10mg daily, Metformin 500mg BID, IV Lasix 40mg daily.", "userPopulated": ""}, {"aiNotes": "Case complexity level", "required": false, "fieldName": "complexity", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "High", "allowedValues": ["High", "Medium", "Standard", "Low"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "concurrentUpdates", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Day 2: Patient showing improvement in respiratory status. O2 saturation improved to 94%. Continue current treatment plan.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactEmail", "fieldSize": 100, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "mchen@metrogeneral.com", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactFacility", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Metro General Hospital", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactFax", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "(555) 123-4568", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Dr. Michael Chen", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "contactPhone", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "(555) 123-4567", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "criteria", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "InterQual Acute Adult Criteria for COPD exacerbation requiring inpatient level of care:\n- Acute respiratory symptoms with documented COPD\n- Oxygen saturation <95% on room air\n- Requiring systemic corticosteroids\n- Need for frequent monitoring and medication adjustment", "userPopulated": ""}, {"aiNotes": "AI-generated criteria analysis", "required": false, "fieldName": "criteriaAnalysis", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Based on analysis of clinical documentation against InterQual criteria, patient meets medical necessity for continued inpatient care.", "userPopulated": ""}, {"aiNotes": "File path for uploaded criteria document", "required": false, "fieldName": "criteriaUpload", "fieldSize": 500, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Conditional - shown when determination is denied or partially_approved", "required": false, "fieldName": "denialRationale", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Conditional - shown when mdDetermination is Denied or Partially Approved. Simple language for member letters.", "required": false, "fieldName": "denialRationaleMD", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Values: approved, partially_approved, denied, sent_to_md", "required": true, "fieldName": "determination", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["approved", "partially_approved", "denied", "sent_to_md"], "userPopulated": ""}, {"aiNotes": "Values: medical_necessity, administrative", "required": false, "fieldName": "determinationType", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "medical_necessity", "allowedValues": ["medical_necessity", "administrative"], "userPopulated": ""}, {"aiNotes": "Array of diagnosis codes", "required": false, "fieldName": "diagnosisCodes", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": [{"code": "J45.909", "confScore": "78%", "description": "Unspecified asthma, uncomplicated"}, {"code": "E11.9", "confScore": "28%", "description": "Type 2 diabetes mellitus without complications"}], "userPopulated": []}, {"aiNotes": "", "required": false, "fieldName": "dischargePlanBarriers", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Discharge planning initiated. Patient requires completion of 5-day steroid course. No identified barriers to discharge. Patient has support system at home and adequate understanding of medication regimen.", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "dob", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "88%", "aiPopulated": "1965-01-15", "userPopulated": ""}, {"aiNotes": "System-generated document identifier", "required": false, "fieldName": "documentId", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "DOC-2025-08-001", "userPopulated": ""}, {"aiNotes": "File path for uploaded document", "required": false, "fieldName": "documentUpload", "fieldSize": 500, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "escalationDate", "fieldSize": null, "fieldType": "TIMESTAMP", "aiConfScore": "", "aiPopulated": "2025-08-21T14:30:00", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "escalationReason", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Requires MD review for medical necessity of continued IV therapy and complex comorbidities requiring physician-level assessment.", "userPopulated": ""}, {"aiNotes": "Type of escalation to Medical Director", "required": false, "fieldName": "escalationType", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Nurse Review", "allowedValues": ["Nurse Review", "Appeal", "Complex Case", "Second Opinion"], "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "healthPlan", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "85%", "aiPopulated": "Medicare Advantage Plus", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "healthplanId", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "92%", "aiPopulated": "HP123456", "userPopulated": ""}, {"aiNotes": "Time elapsed since receipt - calculated field", "required": false, "fieldName": "lapseTime", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "2h 15m", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "lastTherapyCertification", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Previous therapy certification: Physical therapy completed 6 months ago for knee rehabilitation.", "userPopulated": ""}, {"aiNotes": "Values: Approved, Partially Approved, Denied", "required": true, "fieldName": "mdDetermination", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["Approved", "Partially Approved", "Denied"], "userPopulated": ""}, {"aiNotes": "Medical Director''s clinical assessment and rationale", "required": true, "fieldName": "mdNote", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Array of medication calculations with dosage details", "required": false, "fieldName": "medicationCalculations", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": [{"cptHcps": "J7506", "freqType": "days", "unitsPer": 10, "frequency": 1, "totalUnits": 20, "doseRequested": 40, "totalUnitsPerDay": 4, "frequencyDuration": 5}], "userPopulated": []}, {"aiNotes": "", "required": false, "fieldName": "medicationsIvFluids", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "1. Lisinopril 10 mg PO daily for hypertension\n2. Metformin 500 mg PO BID for diabetes\n3. Albuterol inhaler 2 puffs q4h PRN dyspnea\n4. Prednisone 40 mg PO daily x 5 days for COPD exacerbation", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "memberName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "95%", "aiPopulated": "John Doe", "userPopulated": ""}, {"aiNotes": "Pre-populated in Medical Director screen from nurse review", "required": false, "fieldName": "nurseReviewNote", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Patient ID: 12345, Review Type: Pre-Service, Priority: Standard, Clinical Course: Patient admitted for CHF exacerbation, stable on current treatment. Past Medical History: Hypertension, Type 2 Diabetes, prior MI. Skilled Needs: Daily monitoring of vitals, medication management. Medications: Lisinopril 10mg daily, Metformin 500mg BID, IV Lasix 40mg daily. Wounds: Stage 2 pressure ulcer, left heel, 2cm x 2cm x 0.5cm, minimal exudate, treated with hydrocolloid dressing. Physical Therapy: Bed mobility MODA, transfers CGA, ambulation 50ft with walker. Determination: Sent To MD, Rationale: Requires MD review for medical necessity of continued IV therapy and complex comorbidities.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "nurseReviewer", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Sarah Johnson, RN", "userPopulated": ""}, {"aiNotes": "Original nurse reviewer who escalated the case", "required": false, "fieldName": "originalReviewer", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Sarah Johnson, RN", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "pastMedicalHistory", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Hypertension (diagnosed 2015), Type 2 Diabetes Mellitus (diagnosed 2018), Chronic Obstructive Pulmonary Disease. No prior hospitalizations for COPD exacerbation in past 12 months.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "patientId", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "12345", "userPopulated": ""}, {"aiNotes": "Physical/Occupational therapy assessment", "required": false, "fieldName": "physicalTherapy", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": {"transfers": "CGA", "ambulation": "50ft with walker", "bedMobility": "MODA"}, "userPopulated": {}}, {"aiNotes": "Low confidence - verify priority", "required": true, "fieldName": "priority", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "28%", "aiPopulated": "expedited", "allowedValues": ["Expedited Part B Med", "Expedited", "Standard Part B Med", "Standard", "Expedited Med-Service", "Standard Med-Service", "Retrospective", "Urgent"], "userPopulated": ""}, {"aiNotes": "Primary CPT/HCPCS procedure code", "required": false, "fieldName": "procedureCode", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "99214", "userPopulated": ""}, {"aiNotes": "Values: processed, processed-with-1-phi, unable-to-process", "required": false, "fieldName": "processingResult", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["processed", "processed-with-1-phi", "unable-to-process"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "radiologyDiagnostics", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Chest X-Ray (08/20/2025): No evidence of pneumonia or pneumothorax. EKG: Sinus rhythm, no acute ischemic changes. ABG pending.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "readmission", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "No readmissions in past 12 months. Low risk for 30-day readmission given patient compliance and support system.", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "receiptDateTime", "fieldSize": null, "fieldType": "TIMESTAMP", "aiConfScore": "", "aiPopulated": "2025-08-06T10:15:00", "userPopulated": ""}, {"aiNotes": "AI-recommended determination", "required": false, "fieldName": "recommendedDetermination", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Approved", "allowedValues": ["Approved", "Partially Approved", "Denied", "Sent to MD"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "requestMethod", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "fax", "allowedValues": ["phone", "email", "fax", "portal"], "userPopulated": ""}, {"aiNotes": "Array of requested items/procedures", "required": false, "fieldName": "requestedItems", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": [{"cptRev": "99214", "duration": "30 days", "frequency": "Daily", "dosageUnits": "10mg"}], "userPopulated": []}, {"aiNotes": "", "required": false, "fieldName": "requestingEmail", "fieldSize": 100, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "requestingFax", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "68%", "aiPopulated": "(555) 123-4568", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "requestingName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "87%", "aiPopulated": "Dr. Jane Smith, MD", "userPopulated": ""}, {"aiNotes": "", "required": true, "fieldName": "requestingNpi", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "98%", "aiPopulated": "1234567890", "userPopulated": ""}, {"aiNotes": "Requesting provider NPI for display in queue", "required": false, "fieldName": "requestingNpiDisplay", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "1234567890", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "requestingPhone", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "72%", "aiPopulated": "(555) 123-4567", "userPopulated": ""}, {"aiNotes": "Final determination result", "required": false, "fieldName": "result", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "allowedValues": ["Approved", "Denied", "Partially Approved", "Sent to MD", "Pending"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "reviewDate", "fieldSize": null, "fieldType": "TIMESTAMP", "aiConfScore": "", "aiPopulated": "2025-08-21T00:00:00", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "reviewType", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "pre_service", "allowedValues": ["Pre-Service", "Concurrent", "Retrospective", "Post-Service", "Appeal"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingEmail", "fieldSize": 100, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingFax", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingName", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Servicing provider name for display in queue", "required": false, "fieldName": "servicingNameDisplay", "fieldSize": 200, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "Metro General Hospital", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingNpi", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "servicingPhone", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "skilledNeeds", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Continuous monitoring of respiratory status, medication administration and titration, patient education regarding COPD management and medication compliance. Requires skilled nursing assessment of response to treatment.", "userPopulated": ""}, {"aiNotes": "Document source", "required": false, "fieldName": "source", "fieldSize": 20, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "fax", "allowedValues": ["fax", "portal", "upload", "email"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "speechTherapy", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "No speech therapy needs identified at this time.", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "startOfCare", "fieldSize": null, "fieldType": "DATE", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "Case processing status", "required": false, "fieldName": "status", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "New", "allowedValues": ["New", "In Progress", "Reviewed", "Pending", "Completed", "On Hold"], "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "templateList", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "ip_hospital", "allowedValues": ["ip_hospital", "ip_psych_hospital", "irf", "ltac", "snf", "sip", "part_b_medications", "part_therapy", "dme", "other_part_b"], "userPopulated": ""}, {"aiNotes": "Template: IP Hospital (REV 0110)", "required": true, "fieldName": "templateType", "fieldSize": 50, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "ip-hospital", "allowedValues": ["IP Hospital (REV 0110)", "IP Psych Hospital (REV 0110)", "IRF (REV 0024)", "LTAC (REV 0110)", "SNF (0022)", "SIP (REV 0559)", "Part B Medications", "Part Therapy", "DME", "Other Part B Items/Services"], "userPopulated": ""}, {"aiNotes": "Conditional field shown when processingResult is unable-to-process", "required": false, "fieldName": "unableReason", "fieldSize": 500, "fieldType": "VARCHAR", "aiConfScore": "", "aiPopulated": "", "userPopulated": ""}, {"aiNotes": "", "required": false, "fieldName": "ventilator", "fieldSize": null, "fieldType": "TEXT", "aiConfScore": "", "aiPopulated": "Not applicable - patient not requiring ventilator support", "userPopulated": ""}, {"aiNotes": "Array of wound assessments", "required": false, "fieldName": "wounds", "fieldSize": null, "fieldType": "JSON", "aiConfScore": "", "aiPopulated": [{"depth": 0.5, "stage": "Stage 2", "width": 2.0, "length": 2.0, "exudate": "Minimal", "location": "Left heel", "treatment": "Hydrocolloid dressing"}], "userPopulated": []}]}', true, 'n', 'umdocs_admin', '2025-11-14 06:09:09.757671', 20251114060909, 'umdocs_admin', '2025-11-14 06:09:09.757671', 20251114060909);
INSERT INTO um.um_config VALUES ('696d89fa-0319-45fb-82d0-97c28399da8d', 'priority', '[{"value": "expedited_part_b_med", "display_text": "Expedited Part B Med"}, {"value": "expedited", "display_text": "Expedited"}, {"value": "standard_part_b_med", "display_text": "Standard Part B Med"}, {"value": "standard", "display_text": "Standard"}, {"value": "undetermined", "display_text": "Undetermined"}]', true, 'n', 'umdocs_admin', '2025-11-10 20:43:16.187488', 20251110204316, 'umdocs_admin', '2025-11-18 16:58:30.799162', 20251118165830);
INSERT INTO um.um_config VALUES ('a88e74bc-f24d-18a5-c426-d77826eccd7a', 'status', '[{"value": "queued", "display_text": "Queued"}, {"value": "ai_processed", "display_text": "AI Processed"}, {"value": "intake_completed", "display_text": "Intake Completed"}, {"value": "in_review", "display_text": "In Review"}, {"value": "completed", "display_text": "Completed"}]', true, 'n', 'umdocs_admin', '2025-11-10 20:43:16.187488', 20251110204316, 'umdocs_admin', '2025-11-18 16:58:30.799162', 20251118165830);
INSERT INTO um.um_config VALUES ('8a402ebc-f24f-5820-0913-4102e841c9a7', 'source', '[{"value": "fax", "display_text": "Fax"}, {"value": "portal", "display_text": "Portal"}, {"value": "upload", "display_text": "Upload"}]', true, 'n', 'umdocs_admin', '2025-11-10 20:43:16.187488', 20251110204316, 'umdocs_admin', '2025-11-18 16:58:30.799162', 20251118165830);
INSERT INTO um.um_config VALUES ('149a9943-99f7-1caf-f58f-6f7921d818a3', 'intake_processing_result', '[{"value": "processed", "display_text": "Processed"}, {"value": "processed-with-1-phi", "display_text": "Processed with 1 PHI"}, {"value": "unable-to-process", "display_text": "Unable to Process"}]', true, 'n', 'umdocs_admin', '2025-11-25 14:36:57.145806', 20251125143657, 'umdocs_admin', '2025-11-25 14:36:57.145806', 20251125143657);


--
-- TOC entry 4800 (class 0 OID 38934)
-- Dependencies: 276
-- Data for Name: um_diagnosis_codes; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.um_diagnosis_codes VALUES ('72450b20-c154-9dd5-78e8-3befefeffb10', '0001B', 'Cholera dt Vibrio cholerae', 'Cholera', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('8a54e7ee-102c-b1f0-99ea-c93a2bd53bf0', '0002B', 'Cholera dt Vibrio cholerae eltor', 'Cholera', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('fa4fc525-4429-3269-7fcd-40673ce15238', '0003B', 'Cholera unspecified', 'Cholera', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('ccd590e3-5dc6-7915-e3c8-be069927cae0', '0004B', 'Typhoid fever unspecified', 'Typhoid and paratyphoid fevers', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('6e58e93b-0f78-a1b9-7d78-a8a716fa9d9c', '0005B', 'Typhoid meningitis', 'Typhoid and paratyphoid fevers', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('c8c6aac7-3a60-7f82-1c5c-e9bb395e2348', '0006B', 'Typhoid fever w heart involvement', 'Typhoid and paratyphoid fevers', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('ac211f13-59c2-d1e0-df33-97c4243326a3', '0007B', 'Typhoid pneumonia', 'Typhoid and paratyphoid fevers', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('6faaf295-cd95-661d-41d6-ea1bf1e70cec', '0008B', 'Typhoid arthritis', 'Typhoid and paratyphoid fevers', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('ea733037-6016-d35d-7fff-27c340188a25', '0009B', 'Typhoid osteomyelitis', 'Typhoid and paratyphoid fevers', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('d9f2254b-f1a9-1988-2939-e7723b1daf2c', '0010B', 'Typhoid fever w other complications', 'Typhoid and paratyphoid fevers', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('fcc20f8d-6b9a-a5f9-b670-1c5c815099a6', '0011B', 'Paratyphoid fever A', 'Typhoid and paratyphoid fevers', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('15015a68-3937-fccc-f2b3-0f4b65eeb1ab', '0012B', 'Paratyphoid fever B', 'Typhoid and paratyphoid fevers', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);
INSERT INTO um.um_diagnosis_codes VALUES ('47ada744-f4d2-317f-9a65-006faeaa6745', '0013B', 'Paratyphoid fever C', 'Typhoid and paratyphoid fevers', true, 'n', 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354, 'umdocs_admin', '2025-11-25 18:23:54.320849', 20251125182354);


--
-- TOC entry 4798 (class 0 OID 38898)
-- Dependencies: 274
-- Data for Name: um_health_plans; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.um_health_plans VALUES ('304f2121-26e7-0be8-b804-64c861a927ce', 'H1372', 'AgeRight Advantage', 'Oregon', true, 'n', 'umdocs_admin', '2025-11-19 09:56:51.672207', 20251119095651, 'umdocs_admin', '2025-11-19 12:20:33.546103', 20251119122033);
INSERT INTO um.um_health_plans VALUES ('0be3133c-650f-60ab-5366-a5cd3d88bbfd', 'H3419', 'Perennial Advantage', 'Colorado', true, 'n', 'umdocs_admin', '2025-11-19 09:56:51.672207', 20251119095651, 'umdocs_admin', '2025-11-19 12:20:33.546103', 20251119122033);
INSERT INTO um.um_health_plans VALUES ('6c43fede-dcd8-37a1-75ac-49d907580270', 'H4172', 'NHC Advantage', 'South Carolina', true, 'n', 'umdocs_admin', '2025-11-19 09:56:51.672207', 20251119095651, 'umdocs_admin', '2025-11-19 12:20:33.546103', 20251119122033);
INSERT INTO um.um_health_plans VALUES ('c6f865d4-2c27-3973-219f-7b3676fe2328', 'H6959', 'KeyCare Advantage', 'Maryland', true, 'n', 'umdocs_admin', '2025-11-19 09:56:51.672207', 20251119095651, 'umdocs_admin', '2025-11-19 12:20:33.546103', 20251119122033);
INSERT INTO um.um_health_plans VALUES ('a31ada69-6d91-c3c8-55d8-f39ab6ca6703', 'H9917', 'Align Senior Care', 'Florida', true, 'n', 'umdocs_admin', '2025-11-19 09:56:51.672207', 20251119095651, 'umdocs_admin', '2025-11-19 12:20:33.546103', 20251119122033);


--
-- TOC entry 4801 (class 0 OID 38952)
-- Dependencies: 277
-- Data for Name: um_procedure_codes; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.um_procedure_codes VALUES ('5c2de2a6-731c-c95b-980e-ebc5ee15dcee', '0001A', 'imm admn sarscov2 30mcg/0.3ml dil recon 1st dose', 'imm admn sarscov2 30mcg/0.3ml dil recon 1st dose', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);
INSERT INTO um.um_procedure_codes VALUES ('018099c7-92d0-c6c9-c296-061e02829c16', '0002A', 'hrt failure assessed', 'hrt failure assessed', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);
INSERT INTO um.um_procedure_codes VALUES ('08e1872d-08f2-9125-ef2f-c6ab6f1c1f45', '0003A', 'rbc dna hea 35 ag 11 bld grp whl bld cmn allel', 'rbc dna hea 35 ag 11 bld grp whl bld cmn allel', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);
INSERT INTO um.um_procedure_codes VALUES ('efe30835-f476-1c5f-f7d4-f694a263b134', '0004A', 'imm admn sarscov2 30mcg/0.3ml dil recon 2nd dose', 'imm admn sarscov2 30mcg/0.3ml dil recon 2nd dose', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);
INSERT INTO um.um_procedure_codes VALUES ('f557eb3e-0947-3b27-074d-5dd690268b11', '0005A', 'liver dis 10 assays serum algorithm w/ash', 'liver dis 10 assays serum algorithm w/ash', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);
INSERT INTO um.um_procedure_codes VALUES ('5cd11e36-f969-3cb9-88bf-8c8946d06acd', '0006A', 'onc clrct quan 3 ur metabolites alg adnmts plp', 'onc clrct quan 3 ur metabolites alg adnmts plp', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);
INSERT INTO um.um_procedure_codes VALUES ('7021b1b7-b9d3-cfcc-9980-f801027a1424', '0007A', 'imm admn sarscov2 30mcg/0.3ml dil recon 3rd dose', 'imm admn sarscov2 30mcg/0.3ml dil recon 3rd dose', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);
INSERT INTO um.um_procedure_codes VALUES ('ab94956b-2dfd-e1cc-5cbb-4dfa651cf8c3', '0008A', 'liver dis 10 assays serum algorithm w/nash', 'liver dis 10 assays serum algorithm w/nash', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);
INSERT INTO um.um_procedure_codes VALUES ('4524d880-7dca-47a0-8e20-905987d0d2a1', '0009A', 'onc ovarian assay 5 proteins serum alg scor', 'onc ovarian assay 5 proteins serum alg scor', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);
INSERT INTO um.um_procedure_codes VALUES ('fb930cb5-e95e-0cf1-7d93-9788dc09e06c', '0010A', 'imm admn sarscov2 30mcg/0.3ml dil recon bst dose', 'imm admn sarscov2 30mcg/0.3ml dil recon bst dose', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);
INSERT INTO um.um_procedure_codes VALUES ('6902c114-bd58-5e53-0303-96661da2e68b', '0011A', 'scoliosis 53 snps saliva prognostic risk score', 'scoliosis 53 snps saliva prognostic risk score', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);
INSERT INTO um.um_procedure_codes VALUES ('ffbf8db8-3014-4f40-b7d9-3e78b6aea7f7', '0012A', 'osteoarthritis composite', 'osteoarthritis composite', NULL, 'CPT', true, 'n', 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702, 'umdocs_admin', '2025-11-25 18:17:02.052937', 20251125181702);


--
-- TOC entry 4799 (class 0 OID 38916)
-- Dependencies: 275
-- Data for Name: um_providers; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--



--
-- TOC entry 4774 (class 0 OID 38201)
-- Dependencies: 248
-- Data for Name: um_roles; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.um_roles VALUES ('878c5462-c1a1-2864-26de-bea23f873004', 'admin', 'System Administrator', 'Full access to all modules', 'ADMIN', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.um_roles VALUES ('63f0cf1c-4b2b-7527-12b4-03c52afbf05b', 'user', 'Standard User', 'Limited access for standard users', 'USER', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.um_roles VALUES ('11beb034-837a-3a9e-12d3-481ec7f9d8de', 'manager', 'Manager', 'Can view and edit user/facility data', 'MANAGER', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.um_roles VALUES ('0a3db202-f4bd-a5a7-e791-106c55eb65d6', 'viewer', 'Viewer', 'Can only view data', 'VIEWER', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.um_roles VALUES ('d1df653b-d522-8b38-8ba3-e51e283ab5cb', 'intake_specialist', 'Intake Specialist', 'Patient intake and case management', 'INTAKE_SPECIALIST', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.um_roles VALUES ('62f59da6-43b3-ea5c-06c8-1ec00147b702', 'nurse_reviewer', 'Nurse Reviewer', 'Clinical review and determination', 'NURSE_REVIEWER', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.um_roles VALUES ('dea55a66-aebe-15f6-b410-17c464a6224e', 'medical_director', 'Medical Director', 'Medical director review and oversight', 'MEDICAL_DIRECTOR', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);
INSERT INTO um.um_roles VALUES ('8fc1fb39-4ad6-8ec8-7a25-b539631ab74f', 'appeals_specialist', 'Appeals Specialist', 'Appeals and grievances management', 'APPEALS_SPECIALIST', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251);


--
-- TOC entry 4802 (class 0 OID 38971)
-- Dependencies: 278
-- Data for Name: um_templates; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.um_templates VALUES ('66679ca6-ed9c-4bbe-6b46-35a9e5b49128', 'IP Hospital (REV 0110)', 'Part A', NULL, '{}', true, 'n', 'umdocs_admin', '2025-11-19 09:51:53.657787', 20251119095153, 'umdocs_admin', '2025-11-19 09:51:53.657787', 20251119095153);
INSERT INTO um.um_templates VALUES ('abb8bdcd-acfd-68f7-f10b-4bc097d59499', 'IP Psych Hospital (REV 0110)', 'Part A', NULL, '{}', true, 'n', 'umdocs_admin', '2025-11-19 09:52:23.207599', 20251119095223, 'umdocs_admin', '2025-11-19 09:52:23.207599', 20251119095223);
INSERT INTO um.um_templates VALUES ('bf0b65c8-fbf7-5b61-add7-4bbbc1312c26', 'IRF (REV 0024)', 'Part A', NULL, '{}', true, 'n', 'umdocs_admin', '2025-11-19 09:52:41.912389', 20251119095241, 'umdocs_admin', '2025-11-19 09:52:41.912389', 20251119095241);
INSERT INTO um.um_templates VALUES ('9d10bf08-792b-f07d-345f-7c0922ab2524', 'Part B Medications', 'Part B', NULL, '{}', true, 'n', 'umdocs_admin', '2025-11-19 09:53:32.871515', 20251119095332, 'umdocs_admin', '2025-11-19 09:53:32.871515', 20251119095332);
INSERT INTO um.um_templates VALUES ('f0c16cf5-75cc-bfb1-db82-cd8de4353de1', 'Part Therapy', 'Part B', NULL, '{}', true, 'n', 'umdocs_admin', '2025-11-19 09:53:32.871515', 20251119095332, 'umdocs_admin', '2025-11-19 09:53:32.871515', 20251119095332);
INSERT INTO um.um_templates VALUES ('dec9e6b2-ac2e-13fe-6aad-5f57977ac8d5', 'DME', 'Part B', NULL, '{}', true, 'n', 'umdocs_admin', '2025-11-19 09:53:32.871515', 20251119095332, 'umdocs_admin', '2025-11-19 09:53:32.871515', 20251119095332);


--
-- TOC entry 4778 (class 0 OID 38288)
-- Dependencies: 252
-- Data for Name: um_user_roles; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.um_user_roles VALUES ('834ea898-d0a4-cdbc-a18d-af0f60f1be72', '1f86a81c-8e04-d076-8e92-1a18a43f31f1', '878c5462-c1a1-2864-26de-bea23f873004', 'n', 'umdocs_admin', '2025-11-18 15:57:26.243741', 20251118155726, 'umdocs_admin', '2025-11-18 15:57:26.243741', 20251118155726);
INSERT INTO um.um_user_roles VALUES ('cbde90d1-225c-80e0-b06a-41029fe977db', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'd1df653b-d522-8b38-8ba3-e51e283ab5cb', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-20 08:35:11.262821', 20251120083511);


--
-- TOC entry 4773 (class 0 OID 38174)
-- Dependencies: 247
-- Data for Name: um_users; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.um_users VALUES ('3568dcc1-02b3-3f83-629c-b4960ffeb127', 'Arunkumar.Singaram@curanahealth.com', 'Arunkumar', 'Singaram', 'Arunkumar Singaram', '0e7517141fb53f21ee439b355b5a1d0a', true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'approved', NULL, NULL, NULL, NULL, false, NULL, 'America/Chicago', 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-06 06:41:04.060863', 20251106064104);
INSERT INTO um.um_users VALUES ('1f86a81c-8e04-d076-8e92-1a18a43f31f1', 'nisha.mani@curanahealth.com', 'Nisha', 'Mani', 'Nisha Mani', NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'approved', NULL, NULL, NULL, NULL, true, NULL, 'America/Chicago', 'n', 'umdocs_admin', '2025-11-18 15:56:46.667592', 20251118155646, 'umdocs_admin', '2025-11-18 15:56:46.667592', 20251118155646);


--
-- TOC entry 4781 (class 0 OID 38351)
-- Dependencies: 255
-- Data for Name: user_facility_xref; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--



--
-- TOC entry 4779 (class 0 OID 38312)
-- Dependencies: 253
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.user_sessions VALUES ('26ddf0de-be8e-49b8-b658-7641eba2dc65', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsInVzZXJfaWQiOiIzNTY4ZGNjMS0wMmIzLTNmODMtNjI5Yy1iNDk2MGZmZWIxMjciLCJyb2xlcyI6WyJhZG1pbiJdLCJleHAiOjE3NjIzNzUwNTR9.cS1Jsxr8S4iGfvxqQd4oMJsTrgxr635ctePCdS3D8QM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsImV4cCI6MTc2Mjk3NjI1NCwic2NvcGUiOiJyZWZyZXNoX3Rva2VuIn0.eqeFT3Ip8jnsfiZHpMOrXT6aq5p4OLk-lkriIucLviI', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-05 20:37:34.183057', 'n', 'umdocs_admin', '2025-11-05 19:37:34.183392', 20251105193732, NULL, '2025-11-05 19:37:34.183499', NULL);
INSERT INTO um.user_sessions VALUES ('66019cd2-0288-4a24-b8ab-6c8bb52df1a5', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsInVzZXJfaWQiOiIzNTY4ZGNjMS0wMmIzLTNmODMtNjI5Yy1iNDk2MGZmZWIxMjciLCJyb2xlcyI6WyJhZG1pbiJdLCJleHAiOjE3NjIzNzUzMzF9.rIAxvYbNAF8zRhqGI-JsPpHrkRbqWD73eDRGKBjoyXE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsImV4cCI6MTc2Mjk3NjUzMSwic2NvcGUiOiJyZWZyZXNoX3Rva2VuIn0.wiwucZeywWyLk-LWEqvKq-2wRQlz5IXNwGLoxL4PEjQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-05 20:42:11.462231', 'n', 'umdocs_admin', '2025-11-05 19:42:11.462683', 20251105194210, NULL, '2025-11-05 19:42:11.462825', NULL);
INSERT INTO um.user_sessions VALUES ('13941a82-09e4-4dec-af73-fdad7f1e218a', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsInVzZXJfaWQiOiIzNTY4ZGNjMS0wMmIzLTNmODMtNjI5Yy1iNDk2MGZmZWIxMjciLCJyb2xlcyI6WyJhZG1pbiJdLCJleHAiOjE3NjIzNzU3NjF9.MJBwlEGwVtoYDNrJ4R0O7Je4k6DU2YuAOE6Ka6MxZeA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsImV4cCI6MTc2Mjk3Njk2MSwic2NvcGUiOiJyZWZyZXNoX3Rva2VuIn0.39-hOpuk78ifwh_ju5Gegi2dQV3Qdg3d5K79RYGLHXg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-05 20:49:21.161852', 'n', 'umdocs_admin', '2025-11-05 19:49:21.162187', 20251105194919, NULL, '2025-11-05 19:49:21.162286', NULL);
INSERT INTO um.user_sessions VALUES ('6923c6a1-f94a-4fde-aa6b-542ff810bf14', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsInVzZXJfaWQiOiIzNTY4ZGNjMS0wMmIzLTNmODMtNjI5Yy1iNDk2MGZmZWIxMjciLCJyb2xlcyI6WyJhZG1pbiJdLCJleHAiOjE3NjIzNzU4MzN9.2rvNOGI9mB_Gmdxv8QroeafFz9iLwiIiGBQJky3v0_c', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsImV4cCI6MTc2Mjk3NzAzMywic2NvcGUiOiJyZWZyZXNoX3Rva2VuIn0.S2ByDkUf1niYT9ZPqDzVu6P0ua1wcyR_jczcSGSPJ7k', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-05 20:50:33.389968', 'n', 'umdocs_admin', '2025-11-05 19:50:33.390294', 20251105195032, NULL, '2025-11-05 19:50:33.390398', NULL);
INSERT INTO um.user_sessions VALUES ('2a32a79d-95aa-4492-9a68-f7aca4d20116', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsInVzZXJfaWQiOiIzNTY4ZGNjMS0wMmIzLTNmODMtNjI5Yy1iNDk2MGZmZWIxMjciLCJyb2xlcyI6WyJhZG1pbiJdLCJleHAiOjE3NjIzNzYxMzR9.gJjIVuARk5GiHNOTudZkLrpJncsNJiUP9NjYxeH57jQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsImV4cCI6MTc2Mjk3NzMzNCwic2NvcGUiOiJyZWZyZXNoX3Rva2VuIn0.JBc7vLMBhF6FucynfnRWhM00v5-C2Oo9oRqEUt11g-g', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-05 20:55:34.40789', 'n', 'umdocs_admin', '2025-11-05 19:55:34.408291', 20251105195533, NULL, '2025-11-05 19:55:34.40839', NULL);
INSERT INTO um.user_sessions VALUES ('31cebdc5-6ba2-4c10-bd73-12db8c1389d0', '3568dcc1-02b3-3f83-629c-b4960ffeb127', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsInVzZXJfaWQiOiIzNTY4ZGNjMS0wMmIzLTNmODMtNjI5Yy1iNDk2MGZmZWIxMjciLCJyb2xlcyI6WyJhZG1pbiJdLCJleHAiOjE3NjI0MDgwMzR9.QIvKw0fSEpCGF_XrjzSnyj_kcEy1VlX1bbuRwj0Nku0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJBcnVua3VtYXIuU2luZ2FyYW1AY3VyYW5haGVhbHRoLmNvbSIsImV4cCI6MTc2MzAwOTIzNCwic2NvcGUiOiJyZWZyZXNoX3Rva2VuIn0.XwI_VgU9ld_cJwxv6GPBoZfm9D8hpuC2C1NZ3WtP9v4', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-11-06 05:47:14.653847', 'n', 'umdocs_admin', '2025-11-06 04:47:14.654192', 20251106044713, NULL, '2025-11-06 04:47:14.654299', NULL);


--
-- TOC entry 4784 (class 0 OID 38419)
-- Dependencies: 258
-- Data for Name: workflow_logs; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--



--
-- TOC entry 4782 (class 0 OID 38376)
-- Dependencies: 256
-- Data for Name: workflows; Type: TABLE DATA; Schema: um; Owner: umdocs_admin
--

INSERT INTO um.workflows VALUES ('c791247d-9bc1-cbdb-5327-cae6d4ac9efa', 'intake', 'Intake Processing', 'Process incoming documents, validate information, and prepare cases for clinical review.', 1, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-18 10:43:17.337942', 20251118104317, 'fa-inbox', '/intake_queue', 'Access Queue', 'fa-arrow-right');
INSERT INTO um.workflows VALUES ('70b48763-9bea-3cf1-07a0-6e025fa75075', 'clinical', 'Clinical Review', 'Search and review cases, perform medical necessity evaluations, and make determinations.', 2, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-18 10:03:16.646544', 20251118100316, 'fa-user-md', '/clinical', 'Search Cases', 'fa-search');
INSERT INTO um.workflows VALUES ('1e14e761-9106-6813-bb70-28b5f2eca68a', 'medical_director', 'Medical Director', 'Review cases requiring medical director approval and make final determinations.', 3, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-18 10:03:16.646544', 20251118100316, 'fa-user-tie', '/md', 'Review Cases', 'fa-clipboard-check');
INSERT INTO um.workflows VALUES ('a4dca8e3-ab3e-85ed-2efc-acc6eae40528', 'appeals', 'Appeals & Grievances', 'Process appeals and grievances with specialized workflow and documentation requirements.', 4, 'n', 'umdocs_admin', '2025-11-05 15:42:51.329782', 20251105154251, 'umdocs_admin', '2025-11-18 10:03:16.646544', 20251118100316, 'fa-gavel', '/appeals', 'Process Appeals', 'fa-balance-scale');


--
-- TOC entry 4881 (class 0 OID 0)
-- Dependencies: 272
-- Name: um_authorizations_id_seq; Type: SEQUENCE SET; Schema: um; Owner: umdocs_admin
--

SELECT pg_catalog.setval('um.um_authorizations_id_seq', 44, true);


--
-- TOC entry 4471 (class 2606 OID 38548)
-- Name: activity_logs activity_logs_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.activity_logs
    ADD CONSTRAINT activity_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4499 (class 2606 OID 38687)
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- TOC entry 4487 (class 2606 OID 38637)
-- Name: azure_ad_users azure_ad_users_azure_object_id_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.azure_ad_users
    ADD CONSTRAINT azure_ad_users_azure_object_id_key UNIQUE (azure_object_id);


--
-- TOC entry 4489 (class 2606 OID 38635)
-- Name: azure_ad_users azure_ad_users_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.azure_ad_users
    ADD CONSTRAINT azure_ad_users_pkey PRIMARY KEY (id);


--
-- TOC entry 4443 (class 2606 OID 38349)
-- Name: facilities facilities_facility_code_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.facilities
    ADD CONSTRAINT facilities_facility_code_key UNIQUE (facility_code);


--
-- TOC entry 4445 (class 2606 OID 38347)
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- TOC entry 4473 (class 2606 OID 38569)
-- Name: lookup_status lookup_status_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.lookup_status
    ADD CONSTRAINT lookup_status_pkey PRIMARY KEY (id);


--
-- TOC entry 4475 (class 2606 OID 38571)
-- Name: lookup_status lookup_status_status_code_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.lookup_status
    ADD CONSTRAINT lookup_status_status_code_key UNIQUE (status_code);


--
-- TOC entry 4428 (class 2606 OID 38235)
-- Name: modules modules_module_code_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.modules
    ADD CONSTRAINT modules_module_code_key UNIQUE (module_code);


--
-- TOC entry 4430 (class 2606 OID 38233)
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.modules
    ADD CONSTRAINT modules_pkey PRIMARY KEY (id);


--
-- TOC entry 4477 (class 2606 OID 38588)
-- Name: oauth_providers oauth_providers_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.oauth_providers
    ADD CONSTRAINT oauth_providers_pkey PRIMARY KEY (id);


--
-- TOC entry 4479 (class 2606 OID 38590)
-- Name: oauth_providers oauth_providers_provider_name_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.oauth_providers
    ADD CONSTRAINT oauth_providers_provider_name_key UNIQUE (provider_name);


--
-- TOC entry 4485 (class 2606 OID 38608)
-- Name: oauth_tokens oauth_tokens_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.oauth_tokens
    ADD CONSTRAINT oauth_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4433 (class 2606 OID 38253)
-- Name: permissions permissions_permission_key_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.permissions
    ADD CONSTRAINT permissions_permission_key_key UNIQUE (permission_key);


--
-- TOC entry 4435 (class 2606 OID 38251)
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 4457 (class 2606 OID 38454)
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- TOC entry 4459 (class 2606 OID 38456)
-- Name: plans plans_plan_code_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.plans
    ADD CONSTRAINT plans_plan_code_key UNIQUE (plan_code);


--
-- TOC entry 4469 (class 2606 OID 38517)
-- Name: provider_directory provider_directory_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.provider_directory
    ADD CONSTRAINT provider_directory_pkey PRIMARY KEY (id);


--
-- TOC entry 4465 (class 2606 OID 38492)
-- Name: providers providers_npi_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.providers
    ADD CONSTRAINT providers_npi_key UNIQUE (npi);


--
-- TOC entry 4467 (class 2606 OID 38490)
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- TOC entry 4437 (class 2606 OID 38276)
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 4453 (class 2606 OID 38407)
-- Name: role_workflows role_workflows_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.role_workflows
    ADD CONSTRAINT role_workflows_pkey PRIMARY KEY (id);


--
-- TOC entry 4497 (class 2606 OID 38659)
-- Name: security_events security_events_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.security_events
    ADD CONSTRAINT security_events_pkey PRIMARY KEY (id);


--
-- TOC entry 4461 (class 2606 OID 38472)
-- Name: specialties specialties_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.specialties
    ADD CONSTRAINT specialties_pkey PRIMARY KEY (id);


--
-- TOC entry 4463 (class 2606 OID 38474)
-- Name: specialties specialties_specialty_code_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.specialties
    ADD CONSTRAINT specialties_specialty_code_key UNIQUE (specialty_code);


--
-- TOC entry 4517 (class 2606 OID 38811)
-- Name: um_authorizations uk_um_document_id; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_authorizations
    ADD CONSTRAINT uk_um_document_id UNIQUE (document_id);


--
-- TOC entry 4519 (class 2606 OID 38809)
-- Name: um_authorizations um_authorizations_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_authorizations
    ADD CONSTRAINT um_authorizations_pkey PRIMARY KEY (id);


--
-- TOC entry 4567 (class 2606 OID 39173)
-- Name: um_case_lock um_case_lock_document_id_unique; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_case_lock
    ADD CONSTRAINT um_case_lock_document_id_unique UNIQUE (document_id);


--
-- TOC entry 4569 (class 2606 OID 39171)
-- Name: um_case_lock um_case_lock_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_case_lock
    ADD CONSTRAINT um_case_lock_pkey PRIMARY KEY (id);


--
-- TOC entry 4561 (class 2606 OID 39034)
-- Name: um_config um_config_key_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_config
    ADD CONSTRAINT um_config_key_key UNIQUE (config_key);


--
-- TOC entry 4563 (class 2606 OID 39032)
-- Name: um_config um_config_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_config
    ADD CONSTRAINT um_config_pkey PRIMARY KEY (id);


--
-- TOC entry 4540 (class 2606 OID 38951)
-- Name: um_diagnosis_codes um_diagnosis_codes_code_id_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_diagnosis_codes
    ADD CONSTRAINT um_diagnosis_codes_code_id_key UNIQUE (code_id);


--
-- TOC entry 4542 (class 2606 OID 38949)
-- Name: um_diagnosis_codes um_diagnosis_codes_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_diagnosis_codes
    ADD CONSTRAINT um_diagnosis_codes_pkey PRIMARY KEY (id);


--
-- TOC entry 4524 (class 2606 OID 38915)
-- Name: um_health_plans um_health_plans_contract_id_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_health_plans
    ADD CONSTRAINT um_health_plans_contract_id_key UNIQUE (contract_id);


--
-- TOC entry 4526 (class 2606 OID 38913)
-- Name: um_health_plans um_health_plans_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_health_plans
    ADD CONSTRAINT um_health_plans_pkey PRIMARY KEY (id);


--
-- TOC entry 4548 (class 2606 OID 38970)
-- Name: um_procedure_codes um_procedure_codes_code_id_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_procedure_codes
    ADD CONSTRAINT um_procedure_codes_code_id_key UNIQUE (code_id);


--
-- TOC entry 4550 (class 2606 OID 38968)
-- Name: um_procedure_codes um_procedure_codes_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_procedure_codes
    ADD CONSTRAINT um_procedure_codes_pkey PRIMARY KEY (id);


--
-- TOC entry 4533 (class 2606 OID 38933)
-- Name: um_providers um_providers_npi_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_providers
    ADD CONSTRAINT um_providers_npi_key UNIQUE (npi);


--
-- TOC entry 4535 (class 2606 OID 38931)
-- Name: um_providers um_providers_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_providers
    ADD CONSTRAINT um_providers_pkey PRIMARY KEY (id);


--
-- TOC entry 4424 (class 2606 OID 38215)
-- Name: um_roles um_roles_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_roles
    ADD CONSTRAINT um_roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4426 (class 2606 OID 38217)
-- Name: um_roles um_roles_role_key_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_roles
    ADD CONSTRAINT um_roles_role_key_key UNIQUE (role_key);


--
-- TOC entry 4555 (class 2606 OID 38989)
-- Name: um_templates um_templates_name_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_templates
    ADD CONSTRAINT um_templates_name_key UNIQUE (template_name);


--
-- TOC entry 4557 (class 2606 OID 38987)
-- Name: um_templates um_templates_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_templates
    ADD CONSTRAINT um_templates_pkey PRIMARY KEY (id);


--
-- TOC entry 4439 (class 2606 OID 38300)
-- Name: um_user_roles um_user_roles_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_user_roles
    ADD CONSTRAINT um_user_roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4419 (class 2606 OID 38194)
-- Name: um_users um_users_email_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_users
    ADD CONSTRAINT um_users_email_key UNIQUE (email);


--
-- TOC entry 4421 (class 2606 OID 38192)
-- Name: um_users um_users_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_users
    ADD CONSTRAINT um_users_pkey PRIMARY KEY (id);


--
-- TOC entry 4447 (class 2606 OID 38364)
-- Name: user_facility_xref user_facility_xref_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.user_facility_xref
    ADD CONSTRAINT user_facility_xref_pkey PRIMARY KEY (id);


--
-- TOC entry 4441 (class 2606 OID 38326)
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 4455 (class 2606 OID 38433)
-- Name: workflow_logs workflow_logs_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.workflow_logs
    ADD CONSTRAINT workflow_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4449 (class 2606 OID 38391)
-- Name: workflows workflows_pkey; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.workflows
    ADD CONSTRAINT workflows_pkey PRIMARY KEY (id);


--
-- TOC entry 4451 (class 2606 OID 38393)
-- Name: workflows workflows_workflow_key_key; Type: CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.workflows
    ADD CONSTRAINT workflows_workflow_key_key UNIQUE (workflow_key);


--
-- TOC entry 4500 (class 1259 OID 38717)
-- Name: idx_api_keys_expires_at; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_api_keys_expires_at ON um.api_keys USING btree (expires_at) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4501 (class 1259 OID 38716)
-- Name: idx_api_keys_is_active; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_api_keys_is_active ON um.api_keys USING btree (is_active) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4502 (class 1259 OID 38715)
-- Name: idx_api_keys_user_id; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_api_keys_user_id ON um.api_keys USING btree (user_id) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4490 (class 1259 OID 38711)
-- Name: idx_azure_ad_users_azure_email; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_azure_ad_users_azure_email ON um.azure_ad_users USING btree (azure_email) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4491 (class 1259 OID 38710)
-- Name: idx_azure_ad_users_azure_object_id; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_azure_ad_users_azure_object_id ON um.azure_ad_users USING btree (azure_object_id) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4492 (class 1259 OID 38709)
-- Name: idx_azure_ad_users_user_id; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_azure_ad_users_user_id ON um.azure_ad_users USING btree (user_id) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4480 (class 1259 OID 38707)
-- Name: idx_oauth_tokens_expires_at; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_oauth_tokens_expires_at ON um.oauth_tokens USING btree (expires_at) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4481 (class 1259 OID 38706)
-- Name: idx_oauth_tokens_provider_id; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_oauth_tokens_provider_id ON um.oauth_tokens USING btree (provider_id) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4482 (class 1259 OID 38708)
-- Name: idx_oauth_tokens_revoked; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_oauth_tokens_revoked ON um.oauth_tokens USING btree (revoked) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4483 (class 1259 OID 38705)
-- Name: idx_oauth_tokens_user_id; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_oauth_tokens_user_id ON um.oauth_tokens USING btree (user_id) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4431 (class 1259 OID 38718)
-- Name: idx_permissions_permission_code; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE UNIQUE INDEX idx_permissions_permission_code ON um.permissions USING btree (permission_code) WHERE (((deleted)::text = 'n'::text) AND (permission_code IS NOT NULL));


--
-- TOC entry 4493 (class 1259 OID 38714)
-- Name: idx_security_events_createddate; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_security_events_createddate ON um.security_events USING btree (createddate) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4494 (class 1259 OID 38713)
-- Name: idx_security_events_event_type; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_security_events_event_type ON um.security_events USING btree (event_type) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4495 (class 1259 OID 38712)
-- Name: idx_security_events_user_id; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_security_events_user_id ON um.security_events USING btree (user_id) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4503 (class 1259 OID 38815)
-- Name: idx_um_assigned_queue; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_assigned_queue ON um.um_authorizations USING btree (assigned_user, status, priority, receipt_datetime DESC) WHERE ((assigned_user IS NOT NULL) AND (is_deleted = false));


--
-- TOC entry 4504 (class 1259 OID 38812)
-- Name: idx_um_auth_number; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE UNIQUE INDEX idx_um_auth_number ON um.um_authorizations USING btree (authorization_number) WHERE ((authorization_number IS NOT NULL) AND (is_deleted = false));


--
-- TOC entry 4564 (class 1259 OID 39175)
-- Name: idx_um_case_lock_document_id; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_case_lock_document_id ON um.um_case_lock USING btree (document_id) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4565 (class 1259 OID 39176)
-- Name: idx_um_case_lock_expires; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_case_lock_expires ON um.um_case_lock USING btree (lock_expires) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4558 (class 1259 OID 39035)
-- Name: idx_um_config_active; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_config_active ON um.um_config USING btree (is_active) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4559 (class 1259 OID 39036)
-- Name: idx_um_config_key; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_config_key ON um.um_config USING btree (config_key) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4505 (class 1259 OID 38819)
-- Name: idx_um_date_range; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_date_range ON um.um_authorizations USING btree (receipt_datetime DESC, start_of_care, review_date, created_at DESC) WHERE (is_deleted = false);


--
-- TOC entry 4506 (class 1259 OID 38824)
-- Name: idx_um_deleted; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_deleted ON um.um_authorizations USING btree (is_deleted, deleted_at) WHERE (is_deleted = true);


--
-- TOC entry 4507 (class 1259 OID 38820)
-- Name: idx_um_determination_report; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_determination_report ON um.um_authorizations USING btree (determination, md_determination, result, status) WHERE (is_deleted = false);


--
-- TOC entry 4536 (class 1259 OID 39000)
-- Name: idx_um_diagnosis_codes_active; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_diagnosis_codes_active ON um.um_diagnosis_codes USING btree (is_active) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4537 (class 1259 OID 38998)
-- Name: idx_um_diagnosis_codes_code; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_diagnosis_codes_code ON um.um_diagnosis_codes USING btree (code_id) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4538 (class 1259 OID 38999)
-- Name: idx_um_diagnosis_codes_desc; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_diagnosis_codes_desc ON um.um_diagnosis_codes USING btree (description) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4508 (class 1259 OID 38813)
-- Name: idx_um_document_id; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE UNIQUE INDEX idx_um_document_id ON um.um_authorizations USING btree (document_id) WHERE ((document_id IS NOT NULL) AND (is_deleted = false));


--
-- TOC entry 4509 (class 1259 OID 38823)
-- Name: idx_um_form_data_gin; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_form_data_gin ON um.um_authorizations USING gin (form_data) WHERE (is_deleted = false);


--
-- TOC entry 4510 (class 1259 OID 38821)
-- Name: idx_um_health_plan_report; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_health_plan_report ON um.um_authorizations USING btree (health_plan, template_type, priority, status, receipt_datetime DESC) WHERE (is_deleted = false);


--
-- TOC entry 4520 (class 1259 OID 38991)
-- Name: idx_um_health_plans_active; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_health_plans_active ON um.um_health_plans USING btree (is_active) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4521 (class 1259 OID 38990)
-- Name: idx_um_health_plans_contract; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_health_plans_contract ON um.um_health_plans USING btree (contract_id) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4522 (class 1259 OID 38992)
-- Name: idx_um_health_plans_name; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_health_plans_name ON um.um_health_plans USING btree (organization_marketing_name) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4511 (class 1259 OID 38814)
-- Name: idx_um_intake_queue; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_intake_queue ON um.um_authorizations USING btree (is_deleted, status, priority, source, template_type, receipt_datetime DESC) WHERE (is_deleted = false);


--
-- TOC entry 4512 (class 1259 OID 38818)
-- Name: idx_um_md_queue; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_md_queue ON um.um_authorizations USING btree (is_deleted, escalation_date DESC, escalation_type, complexity, priority, md_determination) WHERE ((escalation_date IS NOT NULL) AND (is_deleted = false));


--
-- TOC entry 4513 (class 1259 OID 38816)
-- Name: idx_um_member_search; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_member_search ON um.um_authorizations USING btree (member_name, healthplan_id, dob, health_plan) WHERE (is_deleted = false);


--
-- TOC entry 4543 (class 1259 OID 39004)
-- Name: idx_um_procedure_codes_active; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_procedure_codes_active ON um.um_procedure_codes USING btree (is_active) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4544 (class 1259 OID 39001)
-- Name: idx_um_procedure_codes_code; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_procedure_codes_code ON um.um_procedure_codes USING btree (code_id) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4545 (class 1259 OID 39003)
-- Name: idx_um_procedure_codes_desc; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_procedure_codes_desc ON um.um_procedure_codes USING btree (description) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4546 (class 1259 OID 39002)
-- Name: idx_um_procedure_codes_type; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_procedure_codes_type ON um.um_procedure_codes USING btree (code_type) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4514 (class 1259 OID 38817)
-- Name: idx_um_provider_search; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_provider_search ON um.um_authorizations USING btree (requesting_npi, requesting_name, servicing_name) WHERE (is_deleted = false);


--
-- TOC entry 4527 (class 1259 OID 38995)
-- Name: idx_um_providers_active; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_providers_active ON um.um_providers USING btree (is_active) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4528 (class 1259 OID 38997)
-- Name: idx_um_providers_email; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_providers_email ON um.um_providers USING btree (email) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4529 (class 1259 OID 38994)
-- Name: idx_um_providers_name; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_providers_name ON um.um_providers USING btree (full_name) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4530 (class 1259 OID 38993)
-- Name: idx_um_providers_npi; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_providers_npi ON um.um_providers USING btree (npi) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4531 (class 1259 OID 38996)
-- Name: idx_um_providers_phone; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_providers_phone ON um.um_providers USING btree (phone) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4515 (class 1259 OID 38822)
-- Name: idx_um_reviewer_tracking; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_reviewer_tracking ON um.um_authorizations USING btree (nurse_reviewer, review_date DESC, status, result) WHERE ((nurse_reviewer IS NOT NULL) AND (is_deleted = false));


--
-- TOC entry 4422 (class 1259 OID 38719)
-- Name: idx_um_roles_role_code; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE UNIQUE INDEX idx_um_roles_role_code ON um.um_roles USING btree (role_code) WHERE (((deleted)::text = 'n'::text) AND (role_code IS NOT NULL));


--
-- TOC entry 4551 (class 1259 OID 39007)
-- Name: idx_um_templates_active; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_templates_active ON um.um_templates USING btree (is_active) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4552 (class 1259 OID 39005)
-- Name: idx_um_templates_name; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_templates_name ON um.um_templates USING btree (template_name) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4553 (class 1259 OID 39006)
-- Name: idx_um_templates_type; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_templates_type ON um.um_templates USING btree (template_type) WHERE (deleted = 'n'::bpchar);


--
-- TOC entry 4412 (class 1259 OID 38701)
-- Name: idx_um_users_account_status; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_users_account_status ON um.um_users USING btree (account_status) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4413 (class 1259 OID 38700)
-- Name: idx_um_users_ad_object_id; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_users_ad_object_id ON um.um_users USING btree (ad_object_id) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4414 (class 1259 OID 38699)
-- Name: idx_um_users_ad_username; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_users_ad_username ON um.um_users USING btree (ad_username) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4415 (class 1259 OID 38704)
-- Name: idx_um_users_last_login; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_users_last_login ON um.um_users USING btree (last_login) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4416 (class 1259 OID 38703)
-- Name: idx_um_users_npi; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_users_npi ON um.um_users USING btree (npi_number) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4417 (class 1259 OID 38702)
-- Name: idx_um_users_profession; Type: INDEX; Schema: um; Owner: umdocs_admin
--

CREATE INDEX idx_um_users_profession ON um.um_users USING btree (profession) WHERE ((deleted)::text = 'n'::text);


--
-- TOC entry 4618 (class 2620 OID 38826)
-- Name: um_authorizations trg_um_authorization_updated; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER trg_um_authorization_updated BEFORE UPDATE ON um.um_authorizations FOR EACH ROW EXECUTE FUNCTION um.update_um_authorization_timestamp();


--
-- TOC entry 4611 (class 2620 OID 38554)
-- Name: activity_logs tri_biu_activity_logs; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_activity_logs BEFORE INSERT OR UPDATE ON um.activity_logs FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4617 (class 2620 OID 38698)
-- Name: api_keys tri_biu_api_keys; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_api_keys BEFORE INSERT OR UPDATE ON um.api_keys FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4615 (class 2620 OID 38643)
-- Name: azure_ad_users tri_biu_azure_ad_users; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_azure_ad_users BEFORE INSERT OR UPDATE ON um.azure_ad_users FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4602 (class 2620 OID 38350)
-- Name: facilities tri_biu_facilities; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_facilities BEFORE INSERT OR UPDATE ON um.facilities FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4612 (class 2620 OID 38572)
-- Name: lookup_status tri_biu_lookup_status; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_lookup_status BEFORE INSERT OR UPDATE ON um.lookup_status FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4597 (class 2620 OID 38236)
-- Name: modules tri_biu_modules; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_modules BEFORE INSERT OR UPDATE ON um.modules FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4613 (class 2620 OID 38591)
-- Name: oauth_providers tri_biu_oauth_providers; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_oauth_providers BEFORE INSERT OR UPDATE ON um.oauth_providers FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4614 (class 2620 OID 38619)
-- Name: oauth_tokens tri_biu_oauth_tokens; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_oauth_tokens BEFORE INSERT OR UPDATE ON um.oauth_tokens FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4598 (class 2620 OID 38259)
-- Name: permissions tri_biu_permissions; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_permissions BEFORE INSERT OR UPDATE ON um.permissions FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4607 (class 2620 OID 38457)
-- Name: plans tri_biu_plans; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_plans BEFORE INSERT OR UPDATE ON um.plans FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4610 (class 2620 OID 38533)
-- Name: provider_directory tri_biu_provider_directory; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_provider_directory BEFORE INSERT OR UPDATE ON um.provider_directory FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4609 (class 2620 OID 38503)
-- Name: providers tri_biu_providers; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_providers BEFORE INSERT OR UPDATE ON um.providers FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4599 (class 2620 OID 38287)
-- Name: role_permissions tri_biu_role_permissions; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_role_permissions BEFORE INSERT OR UPDATE ON um.role_permissions FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4605 (class 2620 OID 38418)
-- Name: role_workflows tri_biu_role_workflows; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_role_workflows BEFORE INSERT OR UPDATE ON um.role_workflows FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4616 (class 2620 OID 38670)
-- Name: security_events tri_biu_security_events; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_security_events BEFORE INSERT OR UPDATE ON um.security_events FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4608 (class 2620 OID 38475)
-- Name: specialties tri_biu_specialties; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_specialties BEFORE INSERT OR UPDATE ON um.specialties FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4625 (class 2620 OID 39174)
-- Name: um_case_lock tri_biu_um_case_lock; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_um_case_lock BEFORE INSERT OR UPDATE ON um.um_case_lock FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4624 (class 2620 OID 39037)
-- Name: um_config tri_biu_um_config; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_um_config BEFORE INSERT OR UPDATE ON um.um_config FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4621 (class 2620 OID 39010)
-- Name: um_diagnosis_codes tri_biu_um_diagnosis_codes; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_um_diagnosis_codes BEFORE INSERT OR UPDATE ON um.um_diagnosis_codes FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4619 (class 2620 OID 39008)
-- Name: um_health_plans tri_biu_um_health_plans; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_um_health_plans BEFORE INSERT OR UPDATE ON um.um_health_plans FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4622 (class 2620 OID 39011)
-- Name: um_procedure_codes tri_biu_um_procedure_codes; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_um_procedure_codes BEFORE INSERT OR UPDATE ON um.um_procedure_codes FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4620 (class 2620 OID 39009)
-- Name: um_providers tri_biu_um_providers; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_um_providers BEFORE INSERT OR UPDATE ON um.um_providers FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4596 (class 2620 OID 38218)
-- Name: um_roles tri_biu_um_roles; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_um_roles BEFORE INSERT OR UPDATE ON um.um_roles FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4623 (class 2620 OID 39012)
-- Name: um_templates tri_biu_um_templates; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_um_templates BEFORE INSERT OR UPDATE ON um.um_templates FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4600 (class 2620 OID 38311)
-- Name: um_user_roles tri_biu_um_user_roles; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_um_user_roles BEFORE INSERT OR UPDATE ON um.um_user_roles FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4595 (class 2620 OID 38200)
-- Name: um_users tri_biu_um_users; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_um_users BEFORE INSERT OR UPDATE ON um.um_users FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4603 (class 2620 OID 38375)
-- Name: user_facility_xref tri_biu_user_facility_xref; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_user_facility_xref BEFORE INSERT OR UPDATE ON um.user_facility_xref FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4601 (class 2620 OID 38332)
-- Name: user_sessions tri_biu_user_sessions; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_user_sessions BEFORE INSERT OR UPDATE ON um.user_sessions FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4606 (class 2620 OID 38439)
-- Name: workflow_logs tri_biu_workflow_logs; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_workflow_logs BEFORE INSERT OR UPDATE ON um.workflow_logs FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4604 (class 2620 OID 38394)
-- Name: workflows tri_biu_workflows; Type: TRIGGER; Schema: um; Owner: umdocs_admin
--

CREATE TRIGGER tri_biu_workflows BEFORE INSERT OR UPDATE ON um.workflows FOR EACH ROW EXECUTE FUNCTION um.tri_biu_all_tabs();


--
-- TOC entry 4587 (class 2606 OID 38549)
-- Name: activity_logs activity_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.activity_logs
    ADD CONSTRAINT activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES um.um_users(id);


--
-- TOC entry 4593 (class 2606 OID 38693)
-- Name: api_keys api_keys_revoked_by_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.api_keys
    ADD CONSTRAINT api_keys_revoked_by_fkey FOREIGN KEY (revoked_by) REFERENCES um.um_users(id);


--
-- TOC entry 4594 (class 2606 OID 38688)
-- Name: api_keys api_keys_user_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.api_keys
    ADD CONSTRAINT api_keys_user_id_fkey FOREIGN KEY (user_id) REFERENCES um.um_users(id);


--
-- TOC entry 4590 (class 2606 OID 38638)
-- Name: azure_ad_users azure_ad_users_user_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.azure_ad_users
    ADD CONSTRAINT azure_ad_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES um.um_users(id) ON DELETE CASCADE;


--
-- TOC entry 4588 (class 2606 OID 38614)
-- Name: oauth_tokens oauth_tokens_provider_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.oauth_tokens
    ADD CONSTRAINT oauth_tokens_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES um.oauth_providers(id) ON DELETE CASCADE;


--
-- TOC entry 4589 (class 2606 OID 38609)
-- Name: oauth_tokens oauth_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.oauth_tokens
    ADD CONSTRAINT oauth_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES um.um_users(id) ON DELETE CASCADE;


--
-- TOC entry 4571 (class 2606 OID 38254)
-- Name: permissions permissions_module_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.permissions
    ADD CONSTRAINT permissions_module_id_fkey FOREIGN KEY (module_id) REFERENCES um.modules(id);


--
-- TOC entry 4584 (class 2606 OID 38523)
-- Name: provider_directory provider_directory_plan_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.provider_directory
    ADD CONSTRAINT provider_directory_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES um.plans(id) ON DELETE CASCADE;


--
-- TOC entry 4585 (class 2606 OID 38518)
-- Name: provider_directory provider_directory_provider_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.provider_directory
    ADD CONSTRAINT provider_directory_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES um.providers(id) ON DELETE CASCADE;


--
-- TOC entry 4586 (class 2606 OID 38528)
-- Name: provider_directory provider_directory_specialty_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.provider_directory
    ADD CONSTRAINT provider_directory_specialty_id_fkey FOREIGN KEY (specialty_id) REFERENCES um.specialties(id);


--
-- TOC entry 4582 (class 2606 OID 38498)
-- Name: providers providers_facility_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.providers
    ADD CONSTRAINT providers_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES um.facilities(id);


--
-- TOC entry 4583 (class 2606 OID 38493)
-- Name: providers providers_specialty_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.providers
    ADD CONSTRAINT providers_specialty_id_fkey FOREIGN KEY (specialty_id) REFERENCES um.specialties(id);


--
-- TOC entry 4572 (class 2606 OID 38282)
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES um.permissions(id) ON DELETE CASCADE;


--
-- TOC entry 4573 (class 2606 OID 38277)
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES um.um_roles(id) ON DELETE CASCADE;


--
-- TOC entry 4579 (class 2606 OID 38408)
-- Name: role_workflows role_workflows_role_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.role_workflows
    ADD CONSTRAINT role_workflows_role_id_fkey FOREIGN KEY (role_id) REFERENCES um.um_roles(id) ON DELETE CASCADE;


--
-- TOC entry 4580 (class 2606 OID 38413)
-- Name: role_workflows role_workflows_workflow_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.role_workflows
    ADD CONSTRAINT role_workflows_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES um.workflows(id) ON DELETE CASCADE;


--
-- TOC entry 4591 (class 2606 OID 38665)
-- Name: security_events security_events_resolved_by_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.security_events
    ADD CONSTRAINT security_events_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES um.um_users(id);


--
-- TOC entry 4592 (class 2606 OID 38660)
-- Name: security_events security_events_user_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.security_events
    ADD CONSTRAINT security_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES um.um_users(id);


--
-- TOC entry 4574 (class 2606 OID 38306)
-- Name: um_user_roles um_user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_user_roles
    ADD CONSTRAINT um_user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES um.um_roles(id) ON DELETE CASCADE;


--
-- TOC entry 4575 (class 2606 OID 38301)
-- Name: um_user_roles um_user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_user_roles
    ADD CONSTRAINT um_user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES um.um_users(id) ON DELETE CASCADE;


--
-- TOC entry 4570 (class 2606 OID 38195)
-- Name: um_users um_users_approved_by_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.um_users
    ADD CONSTRAINT um_users_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES um.um_users(id);


--
-- TOC entry 4577 (class 2606 OID 38370)
-- Name: user_facility_xref user_facility_xref_facility_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.user_facility_xref
    ADD CONSTRAINT user_facility_xref_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES um.facilities(id) ON DELETE CASCADE;


--
-- TOC entry 4578 (class 2606 OID 38365)
-- Name: user_facility_xref user_facility_xref_user_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.user_facility_xref
    ADD CONSTRAINT user_facility_xref_user_id_fkey FOREIGN KEY (user_id) REFERENCES um.um_users(id) ON DELETE CASCADE;


--
-- TOC entry 4576 (class 2606 OID 38327)
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES um.um_users(id) ON DELETE CASCADE;


--
-- TOC entry 4581 (class 2606 OID 38434)
-- Name: workflow_logs workflow_logs_performed_by_fkey; Type: FK CONSTRAINT; Schema: um; Owner: umdocs_admin
--

ALTER TABLE ONLY um.workflow_logs
    ADD CONSTRAINT workflow_logs_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES um.um_users(id);


-- Completed on 2025-11-27 04:11:18

--
-- PostgreSQL database dump complete
--

