require 'minitest/autorun'
require 'minitest/mock'
require 'norm'

Norm.init!('primary' => {:user=> 'norm_test'})
Norm.with_connection do |conn|
  conn.exec_string('drop table if exists people')
  conn.exec_string <<-SQL
    CREATE TABLE people
    (
      id serial NOT NULL,
      name character varying(255),
      age integer,
      created_at timestamp with time zone NOT NULL,
      updated_at timestamp with time zone NOT NULL,
      CONSTRAINT people_pkey PRIMARY KEY (id)
    )
  SQL
end
