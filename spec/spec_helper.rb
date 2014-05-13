require 'minitest/autorun'
require 'minitest/mock'
require 'norm'

Norm.init!('primary' => {:user=> 'norm_test'})
Norm.connection_manager.with_connection(:primary) do |conn|
  conn.exec_string('SET client_min_messages TO WARNING')
  conn.exec_string('drop table if exists posts')
  conn.exec_string('drop table if exists people')
  conn.exec_string('drop table if exists users')
  conn.exec_string <<-SQL
    CREATE OR REPLACE FUNCTION timestamp_update() RETURNS TRIGGER AS $$
    BEGIN
      NEW.updated_at = now();
      RETURN NEW;
    END;
    $$ language 'plpgsql';
    CREATE OR REPLACE FUNCTION timestamp_create() RETURNS TRIGGER AS $$
    BEGIN
      NEW.created_at = now();
      NEW.updated_at = now();
      RETURN NEW;
    END;
    $$ language 'plpgsql';

    CREATE TABLE people
    (
      id serial NOT NULL,
      name character varying(255),
      age integer,
      created_at timestamp with time zone NOT NULL,
      updated_at timestamp with time zone NOT NULL,
      CONSTRAINT people_pkey PRIMARY KEY (id),
      CONSTRAINT people_name_unique UNIQUE (name)
    );
    CREATE TRIGGER timestamp_update_people
      BEFORE UPDATE ON people FOR EACH ROW
      EXECUTE PROCEDURE timestamp_update();
    CREATE TRIGGER timestamp_create_people
      BEFORE INSERT ON people FOR EACH ROW
      EXECUTE PROCEDURE timestamp_create();

    CREATE TABLE users
    (
      id serial NOT NULL,
      username character varying(32) NOT NULL,
      email character varying(255) NOT NULL,
      first_name character varying(255) NOT NULL,
      last_name character varying(255) NOT NULL,
      encrypted_password character varying(255) NOT NULL,
      created_at timestamp with time zone NOT NULL,
      updated_at timestamp with time zone NOT NULL,
      CONSTRAINT users_username_length CHECK (char_length(username) >= 3),
      CONSTRAINT users_username_unique UNIQUE (username),
      CONSTRAINT users_pkey PRIMARY KEY (id)
    );
    CREATE TRIGGER timestamp_update_users
      BEFORE UPDATE ON users FOR EACH ROW
      EXECUTE PROCEDURE timestamp_update();
    CREATE TRIGGER timestamp_create_users
      BEFORE INSERT ON users FOR EACH ROW
      EXECUTE PROCEDURE timestamp_create();

    CREATE TABLE posts
    (
      id serial NOT NULL,
      person_id integer NOT NULL,
      title character varying(255) NOT NULL,
      body text,
      created_at timestamp with time zone NOT NULL,
      updated_at timestamp with time zone NOT NULL,
      CONSTRAINT posts_owned_by_person
        FOREIGN KEY (person_id) REFERENCES people (id)
    );
    CREATE TRIGGER timestamp_update_posts
      BEFORE UPDATE ON posts FOR EACH ROW
      EXECUTE PROCEDURE timestamp_update();
    CREATE TRIGGER timestamp_create_posts
      BEFORE INSERT ON posts FOR EACH ROW
      EXECUTE PROCEDURE timestamp_create();
  SQL
end
