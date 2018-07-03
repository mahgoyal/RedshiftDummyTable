# RedshiftDummyTable
This script is useful if you are beginner in Redshift and want to create a large dummy table (test_table) with huge data set. Below set of queries will dynamically create a table with ~268 Million to billions of rows without loading data into the Redshift from s3.

1) Create table twofivesix which will act as base table for populating data on the  test_table.

redshiftcluster=# drop table if exists twofivesix;
DROP TABLE
redshiftcluster=# create table twofivesix ( n int8 );
CREATE TABLE
redshiftcluster=# insert into twofivesix (
 SELECT
     p0.n
     + p1.n*2
     + p2.n * POWER(2,2)
     + p3.n * POWER(2,3)
     + p4.n * POWER(2,4)
     + p5.n * POWER(2,5)
     + p6.n * POWER(2,6)
     + p7.n * POWER(2,7)
     as number
   FROM
     (SELECT 0 as n UNION SELECT 1) p0,
     (SELECT 0 as n UNION SELECT 1) p1,
     (SELECT 0 as n UNION SELECT 1) p2,
     (SELECT 0 as n UNION SELECT 1) p3,
     (SELECT 0 as n UNION SELECT 1) p4,
     (SELECT 0 as n UNION SELECT 1) p5,
     (SELECT 0 as n UNION SELECT 1) p6,
     (SELECT 0 as n UNION SELECT 1) p7
   Order by 1
 );
 INSERT 0 256
redshiftcluster=# commit;
COMMIT

2) Create sample table structure (test_table)

redshiftcluster=#  drop table  if exists test_table;
DROP TABLE
redshiftcluster=# create table test_table(
 ingest_time timestamp encode zstd,
 doi date encode zstd,
 id  int encode bytedict,
 value float encode zstd,
 data_sig  varchar(32) encode zstd
 ) DISTKEY(id) SORTKEY(ingest_time);
CREATE TABLE

redshiftcluster=# commit;
COMMIT

3) Run the below query to dynamically load data to table

redshiftcluster=# insert into test_table (
 select  dateadd('msec', - 10*n , getdate() ) as ingest_time, trunc(dateadd('msec', - 10*n , getdate() )) as doi,id,
 n::float / 1000000 as value, 'sig-' || to_hex(n % 16) as data_sig
 FROM (select (a.n + b.n + c.n + d.n) as n, (random() * 1000)::int as id from twofivesix a cross join (select n*256 as n from twofivesix) b cross join (select n*65536 as n from twofivesix) c
 cross join (select n*16777216 as n from ( select distinct (n/16)::int as n from twofivesix ) ) d)
 ) order by ingest_time;
 INSERT 0 268435456

redshiftcluster=# commit;
COMMIT

redshiftcluster=# analyze test_table;
ANALYZE

redshiftcluster=# select count(*) from test_table;
   count
-----------
 268435456   <--- Table has ~268 Million Rows.
 
4) Consecutive run on of above insert query will 268 million rows for each execution.
