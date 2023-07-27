-- Given two tables (or a projected subset of columns for two tables), when there are differences in the number of rows containing those values, show the differences
--
-- This is intended to be somewhat like Unix "Diff" but for SQL tables and with a good columnar database can scan a billion rows for differences in under a minute
--
-- Sometimes you want to do data validation on all columns in a table to make sure the source and target values are all mai--ntained properly.  
-- Or you want to look at what's changed, what's the delta, between two versions of a table.
-- 
-- In such cases, the following query can be tweaked to show you which rows are the same vs different.  
--  It even identifies via the counts if there are 2 or more rows (dupes) in one table but only 1 row in the other.
--  I believe it also finds NULL-vs-non-NULL changes if I remember correctly but that might be worth doublechecking.



-- list out *every* column in the table (but perhaps skip any insert/update audit columns whose dates may be expected to change) to check that *every* column matches
SELECT col_1,col_2,col_3,col_4,col_5,
   COUNT(src1) cnt_tbl_1, 
   COUNT(src2) cnt_tbl_2
FROM ( SELECT a.*, 
              1 src1, 
              NULL::INTEGER src2 
       FROM table_1 a  -- optional WHERE clause here if wanting to diff a subset of the table
       
       UNION ALL
       
       SELECT b.*, 
              NULL::INTEGER src1, 
              2 src2 
       FROM table_2 b  -- matching optional WHERE clause here if wanting to diff a subset of the table
     )
GROUP BY col_1,col_2,col_3,col_4,col_5
HAVING count(src1) <> count(src2)
ORDER BY col_1,col_3,col_3,col_4,col_5
LIMIT 2000 -- perhaps just show the first 2000 differences
; -- no rows in the resultset means every column in every row in both tables are identical
