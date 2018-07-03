
drop table if exists twofivesix;

create table twofivesix ( n int8 );

insert into twofivesix (
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


drop table  if exists test_table;

create table test_table(
 ingest_time timestamp encode zstd,
 doi date encode zstd,
 id	 int encode bytedict,
 value float encode zstd,
 data_sig varchar(32) encode zstd
) DISTKEY(id) SORTKEY(ingest_time);



insert into test_table (
 select  dateadd('msec', - 10*n , getdate() ) as ingest_time, trunc(dateadd('msec', - 10*n , getdate() )) as doi,id,
 n::float / 1000000 as value, 'sig-' || to_hex(n % 16) as data_sig
 FROM (select (a.n + b.n + c.n + d.n) as n, (random() * 1000)::int as id from twofivesix a cross join (select n*256 as n from twofivesix) b cross join (select n*65536 as n from twofivesix) c
 cross join (select n*16777216 as n from ( select distinct (n/16)::int as n from twofivesix ) ) d)
) order by ingest_time;

commit;

analyze test_table;

