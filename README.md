# RedshiftDummyTable
This script is useful if you are beginner in Redshift and want to create a large dummy table (test_table) with huge data set. Below set of queries will dynamically create a table with ~268 Million to billions of rows without loading data into the Redshift from s3.

1) Create table twofivesix which will act as base table for populating data on the  test_table.

2) Create sample table structure (test_table)

3) Run the query to dynamically load data to table

4) Analyze the table;

5) Check the no. of Rows populated. 

redshiftcluster=# select count(*) from test_table;
   count
-----------
 268435456   <--- Table has ~268 Million Rows.
 
6) Consecutive run on of above insert query will 268 million rows for each execution.
