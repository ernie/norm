drop table if exists people;
create table people (
  id         serial primary key,
  name       character varying(255),
  age        integer,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);
