require 'minitest/autorun'
require 'minitest/mock'
require 'norm'

Norm.init!('primary' => {:user=> 'norm_test'})
Norm.with_connection do |conn|
  conn.exec_string('drop table if exists people')
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
      CONSTRAINT people_pkey PRIMARY KEY (id)
    );
    CREATE TRIGGER timestamp_update_people
      BEFORE UPDATE ON people FOR EACH ROW
      EXECUTE PROCEDURE timestamp_update();
    CREATE TRIGGER timestamp_create_people
      BEFORE INSERT ON people FOR EACH ROW
      EXECUTE PROCEDURE timestamp_create();
  SQL
end
