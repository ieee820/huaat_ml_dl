select type_1 from bot_img_test_04_p4 t group by t.type_1;

select type_2 from bot_img_test_04_p4 t group by t.type_2;

select count(1) from bot_img_test_04_p4 t where t.score_1 < 0.9;

select t.type,COUNT(t.type) from bot_img_label_until_t3 t GROUP BY t.type;

select COUNT(1) from bot_img_filenames_until_t3 t; --147438
select COUNT(1) from bot_img_filenames_until_t2 t; --137359
select COUNT(1) from bot_img_filenames_until_t4 t; --157913 

select * from bot_img_filenames_until_t4 t where t.img_id = '00ae4bd546d541bab6679d0f5dd10dbd.jpg';

create table bot_img_filenames_until_t3 as select * from bot_img_filenames_until_t2;
create table bot_img_filenames_until_t4 as select * from bot_img_filenames_until_t3;
create table bot_img_0919_trainset as select * from bot_img_filenames_until_t3 where 1=2;

create table bot_img_filenames_t3 as select * from bot_img_filenames_until_t2 where 1=2;
create table bot_img_filenames_t4 as select * from bot_img_filenames_until_t2 where 1=2;
create table bot_img_filenames_t1_t2 as select * from bot_img_filenames_until_t2 where 1=2;
create table bot_img_0919_testset as select * from bot_img_0919_trainset where 1=2;

select count(1) from bot_img_filenames_t3; --10079
select count(1) from bot_img_filenames_t4; --10475
select * from bot_img_filenames_t4 t where t.img_id = '00ae4bd546d541bab6679d0f5dd10dbd.jpg';
select * from bot_img_filenames_t3 t where t.img_id = '5e9c2f1ea0ea42e694d888fba08acb78.jpg';

insert into bot_img_filenames_until_t3 select * from bot_img_filenames_t3;
insert into bot_img_filenames_until_t4 select * from bot_img_filenames_t4;

SELECT * FROM bot_img_filenames_until_t4 ORDER BY RAND() LIMIT 0,100;

select t.type,count(t.type) from (SELECT * FROM bot_img_filenames_until_t4 ORDER BY RAND() LIMIT 0,100) t GROUP BY t.type;

SELECT * FROM bot_img_filenames_until_t4 t where t.type = 0 ORDER BY RAND() LIMIT 0,100;

select t.type,count(t.type) from bot_img_filenames_until_t4 t GROUP BY t.type;

select t.type,count(t.type) from bot_img_0919_trainset t GROUP BY t.type;
#挑选训练集
select * from bot_img_0919_trainset;
select count(DISTINCT img_id) from bot_img_0919_trainset; --115200 --115052
select count(DISTINCT img_id) from bot_img_0919_testset; --13550 --10592
--class GROUP BY
select t.type,count(t.type) from bot_img_0919_trainset t GROUP BY t.type;
select t.type,count(t.type) from bot_img_0919_testset t GROUP BY t.type;
--export dataset ORDER BY class NAME
select DISTINCT * from bot_img_0919_trainset t ORDER BY t.type; --115182/64 = 1800
select DISTINCT * from bot_img_0919_testset t ORDER BY t.type; --10593/64 = 166

#训练集中对t1-t4数据集的包含情况
select count(t1.img_id) from bot_img_0919_trainset t1 join bot_img_filenames_t3 t2 on t1.img_id = t2.img_id --7461
select count(t1.img_id) from bot_img_0919_trainset t1 join bot_img_filenames_t4 t2 on t1.img_id = t2.img_id  --7526
select count(t1.img_id) from bot_img_0919_trainset t1 join bot_img_filenames_t1_t2 t2 on t1.img_id = t2.img_id  --13553

#挑选不在的训练集中的t1-t4图片
select count(img_id) from (select t2.img_id,t2.type as t2_type,t1.type as t1_type from bot_img_0919_trainset t1 
right join bot_img_filenames_t3 t2 on t1.img_id = t2.img_id ) t0 where t0.t1_type is null;  --2636
select count(img_id) from (select t2.img_id,t2.type as t2_type,t1.type as t1_type from bot_img_0919_trainset t1 
right join bot_img_filenames_t4 t2 on t1.img_id = t2.img_id ) t0 where t0.t1_type is null;  --2952
select count(img_id) from (select t2.img_id,t2.type as t2_type,t1.type as t1_type from bot_img_0919_trainset t1 
right join bot_img_filenames_t1_t2 t2 on t1.img_id = t2.img_id ) t0 where t0.t1_type is null;  --5010
--
insert into bot_img_0919_testset select img_id,t2_type from (select t2.img_id,t2.type as t2_type,t1.type as t1_type from bot_img_0919_trainset t1 
right join bot_img_filenames_t3 t2 on t1.img_id = t2.img_id ) t0 where t0.t1_type is null;  --2636
insert into bot_img_0919_testset select img_id,t2_type from (select t2.img_id,t2.type as t2_type,t1.type as t1_type from bot_img_0919_trainset t1 
right join bot_img_filenames_t4 t2 on t1.img_id = t2.img_id ) t0 where t0.t1_type is null;  --2952
insert into bot_img_0919_testset select img_id,t2_type from (select t2.img_id,t2.type as t2_type,t1.type as t1_type from bot_img_0919_trainset t1 
right join bot_img_filenames_t1_t2 t2 on t1.img_id = t2.img_id ) t0 where t0.t1_type is null;  --5010

#
alter table bot_img_0919_trainset add index idx01 (img_id) ;
alter table bot_img_filenames_until_t4 add index idx01 (img_id) ;
alter table bot_img_filenames_until_t3 add index idx01 (img_id) ;
alter table bot_img_filenames_t4 add index idx01 (img_id) ;
alter table bot_img_filenames_t3 add index idx01 (img_id) ;
alter table bot_img_filenames_t1_t2 add index idx01 (img_id) ;
alter table bot_img_0919_testset add index idx01 (img_id) ;

select count(1) from bot_img_answer_01_and_02; --18562
select count(1) from bot_img_filenames_t1_t2; --18539



