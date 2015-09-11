DROP SCHEMA IF EXISTS WAIA;

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS WAIA DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE WAIA;

DROP TABLE IF EXISTS WAIA.SCHEMAS;

CREATE  TABLE WAIA.SCHEMAS (
  schema_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key of the schema table.',
  version VARCHAR(10) NOT NULL COMMENT 'Stores the database schema version.',
  PRIMARY KEY (schema_id_pk))
ENGINE = InnoDB, 
COMMENT = 'Table for storing database schema migrations' ;

CREATE INDEX idx_schemas_pk ON WAIA.SCHEMAS (schema_id_pk ASC);

INSERT INTO waia.schemas (version) VALUES('0000000001');

-- -----------------------------------------------------
-- Table WAIA.MEETINGS
-- -----------------------------------------------------
DROP TABLE IF EXISTS WAIA.MEETINGS;

CREATE  TABLE IF NOT EXISTS WAIA.MEETINGS (
  meeting_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key of the meeting table.',
  gso_group_id INT NULL COMMENT 'Primary key of the meeting table.',
  meeting_name VARCHAR(50) NOT NULL COMMENT 'Name of the meeting.',
  location_name VARCHAR(50) NULL COMMENT 'Name of the meeting location.',
  address1 VARCHAR(100) NOT NULL COMMENT 'Street address of the meeting.',
  address2 VARCHAR(100) NULL COMMENT 'Continued street address of the meeting.',
  quadrant VARCHAR(10) NULL COMMENT 'Quadrant for meetings in District of Columbia.',
  city VARCHAR(50) NOT NULL COMMENT 'City that the meeting is in.',
  state VARCHAR(2) NOT NULL COMMENT 'State that the meeting is in.',
  postal_code VARCHAR(10) NOT NULL COMMENT 'ZIP code that the meeting is in.',
  instructions VARCHAR(100) NULL COMMENT 'Contains any special instructions for locating the meeting.',
  day VARCHAR(15) NOT NULL COMMENT 'Day that the meeting meets.',
  day_order TINYINT NOT NULL COMMENT 'Order of the day that the meeting meets.',
  time TIME NOT NULL COMMENT 'Time that the meeting meets',
  time_order TINYINT NOT NULL COMMENT 'Order override for meetings at midnight.',
  created_by VARCHAR(50) NOT NULL COMMENT 'User who created the record.',
  created_date DATETIME NOT NULL COMMENT 'Date record was created.',
  updated_by VARCHAR(50) NOT NULL COMMENT 'User who last updated the record.',
  updated_date DATETIME NOT NULL COMMENT 'Date record was last updated.',
  PRIMARY KEY (meeting_id_pk))
ENGINE = InnoDB, 
COMMENT = 'Contains list of meetings.';

CREATE INDEX idx_meetings_pk ON WAIA.MEETINGS (meeting_id_pk ASC);

CREATE INDEX idx_meetings_01 ON WAIA.MEETINGS (meeting_name ASC);

CREATE INDEX idx_meetings_02 ON WAIA.MEETINGS (state ASC);

-- -----------------------------------------------------
-- Table WAIA.MEETING_TAG_TYPES
-- -----------------------------------------------------
DROP TABLE IF EXISTS WAIA.MEETING_TAG_TYPES;

CREATE  TABLE IF NOT EXISTS WAIA.MEETING_TAG_TYPES (
  meeting_tag_type_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key of the meeting tag types table.',
  category_id INT NOT NULL COMMENT 'Category ID of tag.',
  category VARCHAR(50) NOT NULL COMMENT 'Category name of tag.',
  order_id INT NOT NULL COMMENT 'Order of tag within category.',
  description VARCHAR(50) NOT NULL COMMENT 'Description for the meeting tag.',
  created_by VARCHAR(50) NOT NULL COMMENT 'User who created the record.',
  created_date DATETIME NOT NULL COMMENT 'Date record was created.',
  updated_by VARCHAR(50) NOT NULL COMMENT 'User who last updated the record.',
  updated_date DATETIME NOT NULL COMMENT 'Date record was last updated.',
  PRIMARY KEY (meeting_tag_type_id_pk))
ENGINE = InnoDB, 
COMMENT = 'Contains list of meeting tag types.';

CREATE INDEX idx_meeting_tags_pk ON WAIA.MEETING_TAG_TYPES (meeting_tag_type_id_pk ASC);

-- -----------------------------------------------------
-- Table WAIA.MEETING_TAGS
-- -----------------------------------------------------
DROP TABLE IF EXISTS WAIA.MEETING_TAGS;

CREATE  TABLE IF NOT EXISTS WAIA.MEETING_TAGS (
  meeting_tag_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key of the meeting tags table.',
  meeting_id_pk INT NOT NULL COMMENT 'Foreign key to the meetings table.',
  meeting_tag_type_id_pk INT NOT NULL COMMENT 'Foreign key to the meeting tag types table.',
  created_by VARCHAR(50) NOT NULL COMMENT 'User who created the record.',
  created_date DATETIME NOT NULL COMMENT 'Date record was created.',
  updated_by VARCHAR(50) NOT NULL COMMENT 'User who last updated the record.',
  updated_date DATETIME NOT NULL COMMENT 'Date record was last updated.',
  PRIMARY KEY (meeting_tag_id_pk),
  CONSTRAINT fk_meeting_tags_01
    FOREIGN KEY (meeting_id_pk)
    REFERENCES WAIA.MEETINGS (meeting_id_pk)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_meeting_tags_02
    FOREIGN KEY (meeting_tag_type_id_pk)
    REFERENCES WAIA.MEETING_TAG_TYPES (meeting_tag_type_id_pk)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB, 
COMMENT = 'Contains list of meeting relationships.';

CREATE INDEX idx_meeting_tags_pk ON WAIA.MEETING_TAGS (meeting_tag_id_pk ASC);

CREATE INDEX idx_meeting_tags_fk_01 ON WAIA.MEETING_TAGS (meeting_id_pk ASC);

CREATE INDEX idx_meeting_tags_fk_02 ON WAIA.MEETING_TAGS (meeting_tag_type_id_pk ASC);

CREATE INDEX idx_meeting_tags_01 ON WAIA.MEETING_TAGS (meeting_id_pk, meeting_tag_type_id_pk);

-- -----------------------------------------------------
-- Table WAIA.CONTACTS
-- -----------------------------------------------------
DROP TABLE IF EXISTS WAIA.CONTACTS;

CREATE  TABLE IF NOT EXISTS WAIA.CONTACTS (
  contact_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key of the contacts table.',
  contact_name VARCHAR(50) NOT NULL COMMENT 'Name of the meeting.',
  email VARCHAR(50) NOT NULL COMMENT 'Email address for the contact.',
  home_phone VARCHAR(20) NULL COMMENT 'Home phone number for the contact.',
  mobile_phone VARCHAR(20) NULL COMMENT 'Mobile phone number for the contact.',
  work_phone VARCHAR(20) NULL COMMENT 'Work phone number for the contact.',
  address1 VARCHAR(100) NOT NULL COMMENT 'Street address for the contact.',
  address2 VARCHAR(100) NULL COMMENT 'Continued street address for the contact.',
  city VARCHAR(50) NOT NULL COMMENT 'City for the contact.',
  state VARCHAR(2) NOT NULL COMMENT 'State for the contact.',
  postal_code VARCHAR(5) NOT NULL COMMENT 'ZIP code for the contact.',
  system_user TINYINT NULL COMMENT 'System User',
  username VARCHAR(50) NULL COMMENT 'User name',
  password VARCHAR(50) NULL COMMENT 'Password',
  enabled TINYINT NULL COMMENT 'Enabled',
  created_by VARCHAR(50) NOT NULL COMMENT 'User who created the record.',
  created_date DATETIME NOT NULL COMMENT 'Date record was created.',
  updated_by VARCHAR(50) NOT NULL COMMENT 'User who last updated the record.',
  updated_date DATETIME NOT NULL COMMENT 'Date record was last updated.',
  PRIMARY KEY (contact_id_pk))
ENGINE = InnoDB, 
COMMENT = 'Contains list of contacts and system users.';

CREATE INDEX idx_contacts_pk ON WAIA.CONTACTS (contact_id_pk ASC);

-- -----------------------------------------------------
-- Table WAIA.CONTACT_ROLE_TYPES
-- -----------------------------------------------------
DROP TABLE IF EXISTS WAIA.CONTACT_ROLE_TYPES;

CREATE  TABLE IF NOT EXISTS WAIA.CONTACT_ROLE_TYPES (
  contact_role_type_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key of the contact role types table.',
  description VARCHAR(50) NOT NULL COMMENT 'Description for the role.',
  created_by VARCHAR(50) NOT NULL COMMENT 'User who created the record.',
  created_date DATETIME NOT NULL COMMENT 'Date record was created.',
  updated_by VARCHAR(50) NOT NULL COMMENT 'User who last updated the record.',
  updated_date DATETIME NOT NULL COMMENT 'Date record was last updated.',
  PRIMARY KEY (contact_role_type_id_pk))
ENGINE = InnoDB, 
COMMENT = 'Contains list of contact role types.';

CREATE INDEX idx_contact_role_types_pk ON WAIA.CONTACT_ROLE_TYPES (contact_role_type_id_pk ASC);

-- -----------------------------------------------------
-- Table WAIA.CONTACT_ROLES
-- -----------------------------------------------------
DROP TABLE IF EXISTS WAIA.CONTACT_ROLES;

CREATE  TABLE IF NOT EXISTS WAIA.CONTACT_ROLES (
  contact_role_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key of the contact roles table.',
  meeting_id_pk INT NOT NULL COMMENT 'Foreign key to the meetings table.',
  contact_id_pk INT NOT NULL COMMENT 'Foreign key to the contacts table.',
  contact_role_type_id_pk INT NOT NULL COMMENT 'Foreign key to the contact role types table.',
  created_by VARCHAR(50) NOT NULL COMMENT 'User who created the record.',
  created_date DATETIME NOT NULL COMMENT 'Date record was created.',
  updated_by VARCHAR(50) NOT NULL COMMENT 'User who last updated the record.',
  updated_date DATETIME NOT NULL COMMENT 'Date record was last updated.',
  PRIMARY KEY (contact_role_id_pk),
  CONSTRAINT fk_contact_roles_01
    FOREIGN KEY (meeting_id_pk)
    REFERENCES WAIA.MEETINGS (meeting_id_pk)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_contact_roles_02
    FOREIGN KEY (contact_id_pk)
    REFERENCES WAIA.CONTACTS (contact_id_pk)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_contact_roles_03
    FOREIGN KEY (contact_role_type_id_pk)
    REFERENCES WAIA.CONTACT_ROLE_TYPES (contact_role_type_id_pk)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB, 
COMMENT = 'Contains list of relationships about contact roles.';

CREATE INDEX idx_contact_roles_pk ON WAIA.CONTACT_ROLES (contact_role_id_pk ASC);

CREATE INDEX idx_contact_roles_fk_01 ON WAIA.CONTACT_ROLES (meeting_id_pk ASC);

CREATE INDEX idx_contact_roles_fk_02 ON WAIA.CONTACT_ROLES (contact_id_pk ASC);

CREATE INDEX idx_contact_roles_fk_03 ON WAIA.CONTACT_ROLES (contact_role_type_id_pk ASC);

CREATE INDEX idx_contact_roles_01 ON WAIA.CONTACT_ROLES (meeting_id_pk, contact_id_pk);

-- -----------------------------------------------------
-- Table WAIA.AUTHORITY_TYPES
-- -----------------------------------------------------

DROP TABLE IF EXISTS WAIA.AUTHORITY_TYPES;

CREATE  TABLE IF NOT EXISTS WAIA.AUTHORITY_TYPES (
  authority_type_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key for the authority types table.',
  description VARCHAR(50) NOT NULL COMMENT 'Authority description',
  created_by VARCHAR(50) NOT NULL COMMENT 'User who created the record.',
  created_date DATETIME NOT NULL COMMENT 'Date record was created.',
  updated_by VARCHAR(50) NOT NULL COMMENT 'User who last updated the record.',
  updated_date DATETIME NOT NULL COMMENT 'Date record was last updated, will also be used to determine active records.',
  PRIMARY KEY (authority_type_id_pk))
ENGINE = InnoDB, 
COMMENT = 'Authority types for the WAIA website';	  

CREATE INDEX idx_authorities_pk ON WAIA.AUTHORITY_TYPES (authority_type_id_pk ASC);

-- -----------------------------------------------------
-- Table WAIA.AUTHORITIES
-- -----------------------------------------------------

DROP TABLE IF EXISTS WAIA.AUTHORITIES;

CREATE  TABLE IF NOT EXISTS WAIA.AUTHORITIES (
  authority_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key for the authorities table.',
  contact_id_pk INT NOT NULL  COMMENT 'Foreign key to the contacts table.',
  authority_type_id_pk INT NOT NULL COMMENT 'Foreign key to the authority types table.',
  created_by VARCHAR(50) NOT NULL COMMENT 'User who created the record.',
  created_date DATETIME NOT NULL COMMENT 'Date record was created.',
  updated_by VARCHAR(50) NOT NULL COMMENT 'User who last updated the record.',
  updated_date DATETIME NOT NULL COMMENT 'Date record was last updated, will also be used to determine active records.',
  PRIMARY KEY (authority_id_pk),
  CONSTRAINT fk_authorities_01
    FOREIGN KEY (contact_id_pk)
    REFERENCES WAIA.CONTACTS (contact_id_pk)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_authorities_02
    FOREIGN KEY (authority_type_id_pk)
    REFERENCES WAIA.AUTHORITY_TYPES (authority_type_id_pk)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB, 
COMMENT = 'Authorities records for the WAIA website';	  

CREATE INDEX idx_authorities_pk ON WAIA.AUTHORITIES (authority_id_pk ASC);

CREATE INDEX idx_authorities_fk_01 ON WAIA.AUTHORITIES (contact_id_pk ASC);

CREATE INDEX idx_authorities_fk_02 ON WAIA.AUTHORITIES (authority_type_id_pk ASC);

CREATE INDEX idx_authorities_01 ON WAIA.AUTHORITIES (contact_id_pk, authority_type_id_pk);

-- -----------------------------------------------------
-- Table WAIA.GROUPS
-- -----------------------------------------------------

DROP TABLE IF EXISTS WAIA.GROUPS;

CREATE  TABLE IF NOT EXISTS WAIA.GROUPS (
  group_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key for the groups table.',
  group_name VARCHAR(50) NOT NULL COMMENT 'Name of the group.',
  created_by VARCHAR(50) NOT NULL COMMENT 'User who created the record. ' ,
  created_date DATETIME NOT NULL COMMENT 'Date record was created. ' ,
  updated_by VARCHAR(50) NOT NULL COMMENT 'User who last updated the record. ' ,
  updated_date DATETIME NOT NULL COMMENT 'Date record was last updated. ' ,
  PRIMARY KEY (group_id_pk) )
ENGINE = InnoDB, 
COMMENT = 'Groups records the WAIA website groups';	  

CREATE INDEX idx_groups_pk ON WAIA.GROUPS (group_id_pk ASC);

-- -----------------------------------------------------
-- Table WAIA.GROUP_AUTHORITIES
-- -----------------------------------------------------

DROP TABLE IF EXISTS WAIA.GROUP_AUTHORITIES;

CREATE  TABLE IF NOT EXISTS WAIA.GROUP_AUTHORITIES (
  group_authority_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key for the group authorities table.',
  group_id_pk INT NOT NULL COMMENT 'Foreign key to the groups table.',  
  authority_type_id_pk INT NOT NULL COMMENT 'Foreign key to the authority types table.',
  created_by VARCHAR(50) NOT NULL COMMENT 'User who created the record.',
  created_date DATETIME NOT NULL COMMENT 'Date record was created.',
  updated_by VARCHAR(50) NOT NULL COMMENT 'User who last updated the record.',
  updated_date DATETIME NOT NULL COMMENT 'Date record was last updated, will also be used to determine active records.',
  PRIMARY KEY (group_authority_id_pk),
  CONSTRAINT fk_group_authorities_01
    FOREIGN KEY (group_id_pk)
    REFERENCES WAIA.GROUPS (group_id_pk)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_group_authorities_02
    FOREIGN KEY (authority_type_id_pk)
    REFERENCES WAIA.AUTHORITY_TYPES (authority_type_id_pk)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)  
ENGINE = InnoDB, 
COMMENT = 'Records the authorities for the WAIA website';	  

CREATE INDEX idx_group_authorities_pk ON WAIA.GROUP_AUTHORITIES (group_authority_id_pk ASC);

CREATE INDEX idx_group_authorities_fk_01 ON WAIA.GROUP_AUTHORITIES (group_id_pk ASC);

CREATE INDEX idx_group_authorities_fk_02 ON WAIA.GROUP_AUTHORITIES (authority_type_id_pk ASC);

-- -----------------------------------------------------
-- Table WAIA.GROUP_MEMBERS
-- -----------------------------------------------------

DROP TABLE IF EXISTS WAIA.GROUP_MEMBERS;

CREATE  TABLE IF NOT EXISTS WAIA.GROUP_MEMBERS (
  group_member_id_pk INT NOT NULL AUTO_INCREMENT COMMENT 'Primary key for the group members table.',
  group_id_pk INT NOT NULL COMMENT 'Foreign key to the groups table.',  
  contact_id_pk INT NOT NULL  COMMENT 'Foreign key to the contacts table.',
  created_by VARCHAR(50) NOT NULL COMMENT 'User who created the record.',
  created_date DATETIME NOT NULL COMMENT 'Date record was created.',
  updated_by VARCHAR(50) NOT NULL COMMENT 'User who last updated the record.',
  updated_date DATETIME NOT NULL COMMENT 'Date record was last updated, will also be used to determine active records.',
  PRIMARY KEY (group_member_id_pk),
  CONSTRAINT fk_group_members_01
    FOREIGN KEY (group_id_pk)
    REFERENCES WAIA.GROUPS (group_id_pk)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_group_members_02
    FOREIGN KEY (contact_id_pk)
    REFERENCES WAIA.CONTACTS (contact_id_pk)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)  
ENGINE = InnoDB, 
COMMENT = 'Group members records the members of groups';	  

CREATE INDEX idx_group_members_pk ON WAIA.GROUP_MEMBERS (group_member_id_pk ASC);

CREATE INDEX idx_group_members_fk_01 ON WAIA.GROUP_MEMBERS (group_id_pk ASC);

CREATE INDEX idx_group_members_fk_02 ON WAIA.GROUP_MEMBERS (contact_id_pk ASC);
