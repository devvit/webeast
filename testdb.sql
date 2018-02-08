drop database if exists testdb;
create database testdb;
\c testdb;
create extension hstore;

create table items (id serial primary key, title text);
insert into items (title) values ('hello world');
