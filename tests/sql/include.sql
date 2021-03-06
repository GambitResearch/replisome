\set VERBOSITY terse
\pset format unaligned

-- predictability
SET synchronous_commit = on;

DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;
DROP TABLE IF EXISTS t3;

CREATE TABLE t1 (id int PRIMARY KEY);
CREATE TABLE t2 (id int PRIMARY KEY);
CREATE TABLE t3 (id int PRIMARY KEY);
CREATE TABLE s1 (id int PRIMARY KEY);

SELECT slot_create();


-- Include commands in single tables

insert into t1 values (1);
insert into t2 values (2);
insert into t3 values (3);
update t1 set id = 10 where id = 1;
update t2 set id = 20 where id = 2;
update t3 set id = 30 where id = 3;
delete from t1 where id = 10;
delete from t2 where id = 20;
delete from t3 where id = 30;

SELECT data FROM slot_get(
	'include', '{"table": "t1"}', 'include', '{"table": "t3"}');


-- Include commands on a pattern of tables

insert into t1 values (1);
insert into t2 values (2);
insert into s1 values (3);

SELECT data FROM slot_get(
	'include', '{"tables": "t"}');


insert into t1 values (4);
insert into t2 values (5);
insert into s1 values (6);

SELECT data FROM slot_get(
	'include', '{"tables": "^.1$"}');


-- Exclude a table after inclusion

insert into t1 values (7);
insert into t2 values (8);
insert into t3 values (9);
insert into s1 values (10);

SELECT data FROM slot_get(
	'include', '{"tables": "^t"}', 'exclude', '{"table": "t2"}');


-- Exclude a single table

insert into t1 values (11);
insert into t2 values (12);
insert into t3 values (13);


SELECT data FROM slot_get(
	'exclude', '{"table": "t2"}');


-- Exclude a pattern

insert into t1 values (14);
insert into t2 values (15);
insert into t3 values (16);
insert into s1 values (17);


SELECT data FROM slot_get(
	'exclude', '{"tables": ".1"}');


-- Include after exclusion

insert into t1 values (18);
insert into t2 values (19);
insert into t3 values (20);
insert into s1 values (21);


SELECT data FROM slot_get(
	'exclude', '{"tables": "t"}', 'include', '{"tables": ".2"}');


-- Include specific column

CREATE TABLE tc1 (id int PRIMARY KEY, foo text, bar text);
CREATE TABLE tc2 (id int PRIMARY KEY, foo text, bar text);

-- Columns must be an array
SELECT data FROM slot_get(
	'include', '{"table": "tc1", "columns": 42}');

-- Test including and excluding columns
INSERT INTO tc1 VALUES (1, 'v1', 'v2'), (2, 'v3', 'v4');
UPDATE tc1 SET foo = 'v5' WHERE id = 1;
DELETE FROM tc1 WHERE id = 2;

SELECT data FROM slot_peek(
	'include', '{"table": "tc1", "columns": ["id", "bar", "qux"]}');
SELECT data FROM slot_get(
	'include', '{"table": "tc1", "skip_columns": ["bar", "qux"]}');

-- Later include config overrides previous
INSERT INTO tc1 VALUES (3, 'v1', 'v2');
INSERT INTO tc2 VALUES (4, 'v3', 'v4');
SELECT data FROM slot_peek(
	'include', '{"tables": "^tc", "columns": ["id", "foo"]}');
SELECT data FROM slot_get(
	'include', '{"tables": "^tc", "columns": ["id", "foo"]}',
	'include', '{"table": "tc1", "columns": ["id", "bar"]}');

-- Alter table kicks in new columns
INSERT INTO tc1 VALUES (4, 'v1', 'v2');
ALTER TABLE tc1 ADD qux text;
INSERT INTO tc1 VALUES (5, 'v2', 'v3', 'v4');
ALTER TABLE tc1 DROP qux;
SELECT data FROM slot_get(
	'include', '{"table": "tc1", "columns": ["id", "foo", "qux"]}');


SELECT slot_drop();
