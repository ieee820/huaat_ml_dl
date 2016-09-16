select t1.img_id from bot_img_answer_01  t1 LEFT JOIN bot_img_test_01 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1


select count(1) from bot_img_answer_01 --8513

select count(1) from (
select t1.img_id,t2.type_1 as type_score from bot_img_answer_01  t1 LEFT JOIN bot_img_test_01 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null  
--6736

create table bot_img_test_01_p1 as 
select * from bot_img_test_01

TRUNCATE table bot_img_test_01_p1

#计算第一类的命中率
select count(1) from (
select t1.img_id,t2.type_1 as type_score from bot_img_answer_01  t1 LEFT JOIN bot_img_test_01_p1 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null 
--6739 2016.09.10
--8479 2016.09.11

select count(1) from (
select t1.img_id,t2.type_1 as type_score from bot_img_test_01  t1 LEFT JOIN bot_img_test_01_p1 t2 on t1.img_id = t2.img_id 
and t1.type_1 = t2.type_1 ) t3 where t3.type_score is not null


select t1.img_id,t2.type_1 as type_score,t1.type from bot_img_answer_01  t1 LEFT JOIN bot_img_test_01_p1 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 


select t.img_id, t.type_1,t.type_2 from bot_img_test_01_p1 t where t.img_id like '002b3%'

create table bot_img_test_02_p1 as 
select * from bot_img_test_01 where 1=2

create table bot_img_test_01_p2 as 
select * from bot_img_test_01 where 1=2

select count(1) from bot_img_test_01_p1

create table bot_img_test_02_p3 as 
select * from bot_img_test_02_p2 where 1=2

--2016.09.11
select count(1) from bot_img_test_02_p2

--2016.09.12
create table bot_img_answer_02 as 
select * from bot_img_answer_01 where 1=2

#t2 socre
select count(1) from (
select t1.img_id,t2.type_1 as type_score from bot_img_answer_02  t1 LEFT JOIN bot_img_test_02_p2 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null 
--7287 , 0.73

select count(1) from bot_img_answer_02 --10052

select  count(DISTINCT img_id) from bot_img_answer_02 --10051

--t2 error 
select count(1) from (
select t1.img_id,t2.type_1 as type_score from bot_img_answer_02  t1 LEFT JOIN bot_img_test_02_p2 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is null 

select count(1) from (
select t1.img_id,t2.type_1 as type_score from bot_img_answer_02  t1 LEFT JOIN bot_img_test_02_p2 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is null --2765

select count(1) from (
select t1.img_id,t2.type_1 as type_score from bot_img_answer_02  t1 LEFT JOIN bot_img_test_02_p2 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null 

#t2 error
select img_id,type,type_score from (
select t1.img_id,t1.type, t2.type_1 as type_score from bot_img_answer_02  t1 LEFT JOIN bot_img_test_02_p2 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is null --2765

#t2 error GROUP BY
select type,count(type) from (
select t1.img_id,t1.type, t2.type_1 as type_score from bot_img_answer_02  t1 LEFT JOIN bot_img_test_02_p2 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is null GROUP BY type

#t2 hit
select type,count(type) from (
select t1.img_id,t1.type, t2.type_1 as type_score from bot_img_answer_02  t1 LEFT JOIN bot_img_test_02_p2 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null GROUP BY type

#t1 ERRORS
select img_id,type,type_score from (
select t1.img_id,t1.type, t2.type_1 as type_score from bot_img_answer_01  t1 LEFT JOIN bot_img_test_01 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is null 

#t1 erros GROUP BY
select type,count(type) from (
select t1.img_id,t1.type, t2.type_1 as type_score from bot_img_answer_01  t1 LEFT JOIN bot_img_test_01 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is null GROUP BY type

#t1 hit
select type,count(type) from (
select t1.img_id,t1.type, t2.type_1 as type_score from bot_img_answer_01  t1 LEFT JOIN bot_img_test_01 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null GROUP BY type

#
create table bot_img_test_02_p3 as 
select * from bot_img_test_02_p2 where 1=2

#t2_p3(xiatao) hit
select type,count(type) from (
select t1.img_id,t1.type, t2.type_1 as type_score from bot_img_answer_02  t1 LEFT JOIN bot_img_test_02_p3 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null GROUP BY type

select sum(t4.cc) from (
select type,count(type) as cc from (
select t1.img_id,t1.type, t2.type_1 as type_score from bot_img_answer_02  t1 LEFT JOIN bot_img_test_02_p3 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null GROUP BY type ) t4 --6671


#2016.9.13 15:09 t2 predict re 
CREATE table bot_img_test_02_p4 as 
select * from bot_img_test_02_p3 where 1=2

#t2_p4 hit
select sum(t4.cc) from (
select type,count(type) as cc from (
select t1.img_id,t1.type, t2.type_1 as type_score from bot_img_answer_02  t1 LEFT JOIN bot_img_test_02_p4 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null GROUP BY type ) t4 --9838

#t1 and t2
create table bot_img_answer_01_and_02 as 
select * from bot_img_answer_01 where 1=2 


insert into bot_img_answer_01_and_02 
select * from bot_img_answer_01

select count(1) from bot_img_answer_01_and_02

insert into bot_img_answer_01_and_02 
select * from bot_img_answer_02

#delete from bot_img_answer_02 where img_id = '2db0f7ec0310455eba8c6199f89fab84'
create table bot_img_test_01_and_t2 as 
select * from bot_img_test_02_p4 where 1=2

#t1_t2_hit
select sum(t4.cc) from (
select type,count(type) as cc from (
select t1.img_id,t1.type, t2.type_1 as type_score from bot_img_answer_01_and_02  t1 LEFT JOIN bot_img_test_01_and_t2 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null GROUP BY type ) t4 --18280

#
select count(1) from bot_img_answer_01_and_02 --18562


select * from (
select t1.img_id,t1.type, t2.type_1 as type_score from bot_img_answer_01_and_02  t1 LEFT JOIN bot_img_test_01_and_t2 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is null


#
create table bot_img_label_until_t2 as 
select * from bot_img_answer_01_and_02 where 1=2 

#
select count(1) from bot_img_label_until_t2 --137359
select count(DISTINCT img_id) from bot_img_label_until_t2 --137214


select * from bot_img_label_until_t2 where img_id like '003d5f68f7eb45fdb5d992516da54942%'

#0914
create table bot_img_answer_03 as
select * from bot_img_answer_02 where 1=2

select count(1) from bot_img_answer_03 --10079

create table bot_img_test_03_p1
SELECT * from bot_img_test_01_and_t2 where 1=2

select count(1) from bot_img_test_03_p1 --10237

select count(1) from (
select t1.img_id,t2.type_1 as type_score from bot_img_answer_03  t1 LEFT JOIN bot_img_test_03_p1 t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null  --8288

create table bot_img_test_03_caffemodel AS
select * from bot_img_test_03_p1 where 1=2

create table bot_img_test_03_hybrid_model AS
select * from bot_img_test_03_caffemodel where 1=2

select count(1) from (
select t1.img_id,t2.type_1 as type_score from bot_img_answer_03  t1 LEFT JOIN bot_img_test_03_hybrid_model t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null --8238

select count(1) from (
select t1.img_id,t2.type_1 as type_score from bot_img_answer_03  t1 LEFT JOIN bot_img_test_03_caffemodel t2 on t1.img_id = t2.img_id 
and t1.type = t2.type_1 ) t3 where t3.type_score is not null  --7226

select count(1) from (
select t1.img_id  
from bot_img_test_03_caffemodel t1 inner join bot_img_test_03_p1 t2 on  t1.img_id = t2.img_id  
) t3

select t1.img_id,
case when t1.score_1 > t2.score_1 then
t1.type_1 
else
t2.type_1
end type1,
t1.type_1,
t1.score_1,
t2.type_1,
t2.score_1
from bot_img_test_03_caffemodel t1 inner join bot_img_test_03_p1 t2 on  t1.img_id = t2.img_id  


#
select t1.img_id,
case when t1.score_1 > t2.score_1 then
t1.type_1 
else
t2.type_1
end type1,
case when t1.score_1 > t2.score_1 then
t1.score_1 
else
t2.score_1
end score1,
t1.score_1,
t2.type_1,
t2.score_1
from bot_img_test_03_caffemodel t1 inner join bot_img_test_03_p1 t2 on  t1.img_id = t2.img_id  

select t1.img_id,
case when t1.score_1 > t2.score_1 then
t1.type_1 
else
t2.type_1
end type1
from bot_img_test_03_caffemodel t1 inner join bot_img_test_03_p1 t2 on  t1.img_id = t2.img_id  

#0915
select REPLACE(t.img_id, '.png', '') from bot_img_label_until_t2 t where t.img_id like '%.png' limit 10

select REPLACE(t.img_id, 'p*', '') from bot_img_label_until_t2 t where t.img_id = '05628d13544446afb54335e993dc93ff.png'

select * from bot_img_label_until_t2 t where t.img_id like '%.png' limit 10 #05628d13544446afb54335e993dc93ff

TRIM
select TRIM(TRAILING "ff" from t.img_id) as re from bot_img_label_until_t2 t where t.img_id = '05628d13544446afb54335e993dc93ff.png'
SUBSTRING
select SUBSTRING(t.img_id,'.png') as re from bot_img_label_until_t2 t where t.img_id = '05628d13544446afb54335e993dc93ff.png'
REGEXP 
select t.img_id REGEXP "\.[a-z]*" from bot_img_label_until_t2 t where t.img_id = '05628d13544446afb54335e993dc93ff.png'


select REPLACE(t.img_id, '.png', '') 

from bot_img_label_until_t2 t where t.img_id = '05628d13544446afb54335e993dc93ff.png'

#t1,t2 erros
create table t1_erros  as
select * from bot_img_answer_03 where 1=2

create table t2_erros  as
select * from bot_img_answer_03 where 1=2

select REPLACE(t1.img_id, '.jpg', '') as t1_id_nosuffix from bot_img_label_until_t2 t1 where t1.img_id like '%.jpg'

(select REPLACE(t1.img_id, '.png', '') as t1_id_nosuffix from bot_img_label_until_t2 t1 where t1.img_id like '%.png' )


select  * from bot_img_label_until_t2 t1 where t1.img_id like '%.jpg' 
and REPLACE(t1.img_id, '.jpg', '') in 
(select t2.img_id from t2_erros t2) --2446

select  * from bot_img_label_until_t2 t1 where t1.img_id like '%.png' 
and REPLACE(t1.img_id, '.png', '') in 
(select t2.img_id from t2_erros t2) --290

select  * from bot_img_label_until_t2 t1 where t1.img_id like '%.jpeg' 
and REPLACE(t1.img_id, '.jpeg', '') in 
(select t2.img_id from t2_erros t2) --33 sum(2769)

select count(1) from t2_erros --2765
select count(1) from t1_erros --1777

select  * from bot_img_label_until_t2 t1 where t1.img_id like '%.jpg' 
and REPLACE(t1.img_id, '.jpg', '') in 
(select t2.img_id from t1_erros t2) --1623

#testset t2
select  * from bot_img_label_until_t2 t1 where t1.img_id like '%.jpg' 
and REPLACE(t1.img_id, '.jpg', '') in 
(select t2.img_id from bot_img_answer_02 t2) --9229



#trainset by prd_random1000
create table bot_img_label_r1000 as
select * from bot_img_label_until_t2 where 1=2 

select count(1) from bot_img_label_r1000 --12000

SELECT * from bot_img_label_until_t2 t where t.type = 0




















































