--------------------客户画像脚本使用的外部表一览-------------------
/*
odsmdm_pub_customer_corp
ODSMDM_HM_VALUE_SET
VW_DMCUSTBD_PAYMENT_OVERVIEW
vw_dmcustbd_payment_overview
VM_ODSCUSTBD_JXC_PRDGRP_DD
dm_custbd_customer
DM_CUSTBD_HFYT_FCT
DM_CUSTBD_INCOME_FCT
DM_CUSTBD_LYL_FCT
DM_CUSTBD_CUSTOMER_STORE_SUM
dm_custbd_sr_cp_xh_month
dm_custbd_smzq_type----------生命周期标签表
dm_custbd_credit_10------------资信报告指标表
DM_CUSTBD_KHJZ_QIANLI------------潜力价值最终表
DM_CUSTBD_MODEL_LISHI_2
dm_custbd_date_dimension
*/

----------------------------------------------------------基础属性---------------------------------------------------
----基础属性-----
truncate table dm_custbd_customer_jcsx;
drop table dm_custbd_customer_jcsx;
create table dm_custbd_customer_jcsx  tablespace dmdat as
select distinct a.customer_number,----客户编码
                a.customer_name,-----客户姓名
                a.customer_category,-----渠道编码
                a.category_name,-----渠道名称
                a.region,----区域编码
                a.region_name,-----区域名称
                a.created_time_long,-----合作时长
                b.amount_sum,-----门店数量
                b.amount_area,----门店面积
                c.smzq_type_code smzq_type,-----生命周期类型
                a.delete_flag-----冻结状态
  FROM dm_custbd_customer a
  left join (select distinct a.cus_code customer_number,
a.imonths year_month,a.amount_sum,a.sbr_housemj_sum amount_area  from DM_CUSTBD_CUSTOMER_STORE_SUM a ) b
    on a.customer_number = b.customer_number
  left join dm_custbd_smzq_type c----生命周期标签表
    on a.customer_number = c.zsd_soto;


------------------------------------------------------------提货能力--------------------------------------------------------------

drop table dm_custbd_customer_thnl;
create table dm_custbd_customer_thnl  tablespace dmdat as
SELECT distinct t.zsd_soto,
                t.yuefen,
                t.MAOSHOURU, --毛收入
                t.MAOSHOURU_TB, --同期毛收入
                case when sum(t.MAOSHOURU_TB) over (partition by yuefen, zsd_soto order by  to_date(t.yuefen, 'yyyymm') range between interval '12'
                      month preceding and CURRENT ROW) >0 and  sum(t.MAOSHOURU) over (partition by yuefen, zsd_soto order by  to_date(t.yuefen, 'yyyymm') range between interval '12'
                      month preceding and CURRENT ROW) >0 then
                   (sum(t.MAOSHOURU) over (partition by yuefen, zsd_soto order by  to_date(t.yuefen, 'yyyymm') range between interval '12'
                      month preceding and CURRENT ROW)- sum(t.MAOSHOURU_TB) over (partition by yuefen, zsd_soto order by  to_date(t.yuefen, 'yyyymm') range between interval '12'
                      month preceding and CURRENT ROW) )/sum(t.MAOSHOURU_TB) over (partition by yuefen, zsd_soto order by  to_date(t.yuefen, 'yyyymm') range between interval '12'
                      month preceding and CURRENT ROW) 
                   when sum(t.MAOSHOURU_TB) over (partition by yuefen, zsd_soto order by  to_date(t.yuefen, 'yyyymm') range between interval '12'
                      month preceding and CURRENT ROW) >0 and sum(t.MAOSHOURU) over (partition by yuefen, zsd_soto order by  to_date(t.yuefen, 'yyyymm') range between interval '12'
                      month preceding and CURRENT ROW) <=0 then
                     -1
                     else null
                       end growth_year, ------提货同比增长率
                t.STORE_AMOUNT_SUM, --门店数量
                (sum(t.MAOSHOURU)
                 over(partition by t.zsd_soto order by
                      to_date(t.yuefen, 'yyyymm') range between interval '12'
                      month preceding and CURRENT ROW)) / 12 msr_month_avg, ---毛收入最近12个月的月平均值（提货金额）
                (t.MAOSHOURU / case
                  when t.STORE_AMOUNT_SUM = 0 then
                   null
                  else
                   t.STORE_AMOUNT_SUM
                end) ddgm, --单店规模
                t.MAOSHOURU_TBLV, --毛收入同比增长率（提货额同比增长率） 
                t.MAOSHOURU_MAX, --最大单日提货额（最大单次提货额）  
                t1.hkje_max, --最大单次回款金额
                t1.hkje_sum / 365 hkje_avg, --回款金额最近12个月的日平均（平均单次回款金额）
                (sum(t.MAOSHOURU)
                 over(partition by t.zsd_soto order by
                      to_date(t.yuefen, 'yyyymm') range between interval '12'
                      month preceding and CURRENT ROW)) / 365 msr_day_avg ---毛收入最近12个月的日平均值（平均单次提货金额）

  from DM_CUSTBD_KHJZ_QIANLI t

  left join (SELECT distinct customer_code,
                             exchange_month,
                             max(amount) over(partition by customer_code order by to_date(exchange_month, 'yyyymm') 
range between interval '12' month preceding and CURRENT ROW) hkje_max,
                             sum(amount) over(partition by customer_code order by to_date(exchange_month, 'yyyymm') 
range between interval '12' month preceding and CURRENT ROW) hkje_sum
             
               FROM VW_DMCUSTBD_PAYMENT_OVERVIEW
              where exchange_group in ('现汇', '承兑', '其他')) t1
    on t.zsd_soto = t1.customer_code
   and t.yuefen = t1.exchange_month;



---------------------------------------------------------提货偏好-----------------------------------------------------------------

truncate table dm_custbd_sr_cp_xh_month1;
drop table dm_custbd_sr_cp_xh_month1;
create table dm_custbd_sr_cp_xh_month1 as---------将JDE客户编码转换为GVS编码，并重新汇总收入金额。
select a.*, b.pcc_mdmcode
  from dm_custbd_sr_cp_xh_month a
  left join odsmdm_pub_customer_corp b
    on a.zsd_soto =to_char( b.pcc_code);
    update  dm_custbd_sr_cp_xh_month1 set zsd_soto=pcc_mdmcode where pcc_mdmcode is not null);
 
 truncate table dm_custbd_sr_cp_xh_month2;
drop table dm_custbd_sr_cp_xh_month2;
create table dm_custbd_sr_cp_xh_month2 as
    select distinct (zsd_soto),
                    calmonth,
                    calyear,
                    division,----产品组编码
                    division_name,----产品组名称
                    zsd_mat,
                    sum(zsd_revq) over(partition by zsd_soto, calmonth,division) zsd_revq,
                      sum(jsr) over(partition by zsd_soto, calmonth,division) jsr,
                        sum(zkje) over(partition by zsd_soto, calmonth,division) zkje,
                          sum(hfje) over(partition by zsd_soto, calmonth,division) hfje,
                            sum(msr) over(partition by zsd_soto, calmonth,division)  msr                         
      from dm_custbd_sr_cp_xh_month1;
    
--数据源
--提货单价偏好
truncate table dm_custbd_customer_cpph_1;
drop table dm_custbd_customer_cpph_1;
create table  dm_custbd_customer_cpph_1  tablespace dmdat as
---每个客户偏好的提货区间
select distinct t3.ZSD_SOTO,
                t3.CALMONTH,
                t3.CALYEAR,
                 (first_value(t3.djqj)over(partition by t3.ZSD_SOTO, t3.CALMONTH order by zsd_revq_sum desc))
       price_preference
       ---最近12个月内，每个价格区间的提货数量
  from (select distinct t2.ZSD_SOTO,
                        t2.CALMONTH,
                        t2.CALYEAR,
                        t2.djqj,
                        sum(t2.ZSD_REVQ) over(partition by t2.zsd_soto, t2.djqj order by to_date(t2.CALMONTH, 'yyyymm') range between interval '12' month preceding and CURRENT ROW) zsd_revq_sum
 ---给型号的价格划分价格区间       
          from (select distinct t1.*,
                                          
                                case
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 1000 then
                                   '0-1000'
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 1000 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 1500 then
                                   '1000-1500'
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 1500 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 2000 then
                                   '1500-2000'
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 2000 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 2500 then
                                   '2000-2500'
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 2500 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 3000 then
                                   '2500-3000'
                                
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 3000 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 3500 then
                                   '3000-3500'
                                
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 3500 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 4000 then
                                   '3500-4000'
                                
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 4000 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 4500 then
                                   '4000-4500'
                                
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 4500 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 5000 then
                                   '4500-5000'
                                
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 5000 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 5500 then
                                   '5000-5500'
                                
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 5500 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 6000 then
                                   '5500-6000'
                                
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 6000 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 8000 then
                                   '6000-8000'
                                
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 8000 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 10000 then
                                   '8000-10000'
                                
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 10000 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 15000 then
                                   '10000-15000'
                                
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 15000 and (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) < 20000 then
                                   '15000-20000'
                                
                                  when (t1.msr / (case
                                         when t1.zsd_revq = 0 then
                                          null
                                         else
                                          t1.zsd_revq
                                       end)) >= 20000 then
                                   '20000+'
                                end djqj
                
                  from 
                 dm_custbd_sr_cp_xh_month2 t1) t2) t3;



-------产品组偏好

truncate table dm_custbd_customer_cpph;
drop table dm_custbd_customer_cpph;
create table  dm_custbd_customer_cpph  tablespace dmdat as
select distinct l.zsd_soto,l.calmonth,
                       case when l.s is not null then
                       e.value_meaning || ' ' || ',' || ' ' || f.value_meaning 
                       else
                        e.value_meaning
                      end product_preference-----产品组偏好
  
  from (select distinct zsd_soto, calmonth, f, s
          from (select distinct t.zsd_soto, t.calmonth,t.prod_code, t.rank
                  from (
                        select distinct w.zsd_soto,
                                         w.calmonth,
                                         w.prod_code,
                                         w.jsr,
                                         row_number() over(partition by w.zsd_soto,w.calmonth order by w.jsr desc) rank
                          from (select distinct a.zsd_soto,
                                                 a.calmonth,
                                                 a.DIVISION prod_code,                                               
                                                 sum(a.jsr) over(partition by zsd_soto,division order by to_date(calmonth, 'yyyymm') range between interval '11' month preceding and CURRENT ROW) jsr
                                   from dm_custbd_sr_cp_xh_month2 a------临时使用的收入表
               ) w
                         order by zsd_soto, rank) t
                 where t.rank <= 2) m pivot(max(m.prod_code) for rank in(1 as f,
                                                                         2 as s)) s) l
  left join (SELECT distinct value, value_meaning
               FROM ODSMDM_HM_VALUE_SET ---产品维度表
              where value_set_id = 'ProductGroup'
                and DELETE_FLAG = 0
                and ACTIVE_FLAG = 1) e
    on l.f = e.value
  left join (SELECT distinct value, value_meaning
               FROM ODSMDM_HM_VALUE_SET----产品维度表
              where value_set_id = 'ProductGroup'
                and DELETE_FLAG = 0
                and ACTIVE_FLAG = 1) f
    on l.s = f.value;
    

------奖励偏好表------
truncate table dm_custbd_customer_jlph;
drop table dm_custbd_customer_jlph;
create table  dm_custbd_customer_jlph  tablespace dmdat as
  (select distinct t3.customer_number,--------奖励偏好
                            t3.year_month,
                          case when a2 is null and a3 is null then
                            t3.a1
                            when a2 is not null and a3 is null 
                              then 
                                t3.a1 || ' , ' ||t3.a2
                                when a2 is  null and a3 is not null then
                                  t3.a1 || ' , ' ||t3.a3
                                  when a1 is not null and a3 is not null then
                             t3.a1 || ' , ' ||t3.a2 || ' , ' ||
                             t3.a3 
                             end prize_preference
               from (select distinct customer_number, year_month,a1, a2, a3-----取奖励金额前三名
                       from (select distinct t1.customer_number,
                                             t1.year_month,
                                             t1.cprizename,
                                             t1.rank
                             
                               from (select distinct a.customer_number,-------给奖励金额排序
                                                     a.year_month,
                                                     a.cprizename,
                                                     a.hfyt,
                                                     row_number() over(partition by a.customer_number, a.year_month order by(case
                                                       when a.hfyt is null then
                                                        0
                                                       else
                                                        a.hfyt
                                                     end) desc) rank
                                     
                                       from (SELECT distinct period_month_yt year_month,
                                                             trim(czhuhucode) customer_number,
                                                             cprizename,
                                                             sum(iprizemoney_yingfu) over(partition by czhuhucode, cprizename order by to_date(period_month_yt, 'yyyymm') range between interval '12' month preceding and CURRENT ROW) hfyt
                                               FROM DM_CUSTBD_HFYT_FCT) a
                                      where a.cprizename is not null) t1
                              where t1.rank <= 3
                                and t1.hfyt > 0) t2 pivot(max(t2.cprizename) for rank in(1 as a1,
                                                                                                    2 as a2,
                                                                                                    3 as a3))
                     
                     ) t3) ;





---提货频次----------
 
  truncate table dm_custbd_customer_thpcph;
drop table dm_custbd_customer_thpcph;
create table  dm_custbd_customer_thpcph  tablespace dmdat as      
 select zsd_soto,yuefen,
 case when -------取提货频次区间
   less_than_ten=ten_to_twenty or less_than_ten=more_than_twenty or ten_to_twenty=more_than_twenty then '无偏好'
   when   less_than_ten=greatest(less_than_ten,ten_to_twenty,more_than_twenty)  then '10次以下'
    when  ten_to_twenty=greatest(less_than_ten,ten_to_twenty,more_than_twenty)  then '10-19次' 
    when  more_than_twenty=greatest(less_than_ten,ten_to_twenty,more_than_twenty)  then '20次以上'   
  else null
    end freq_preference
    from
(select zsd_soto,-----给提货频次定义区间
       yuefen,
       sum(case when rev_fre<10 then 1 else 0 end)
        over(partition by zsd_soto order by to_date(yuefen, 'yyyymm') range between interval '11' month preceding and CURRENT ROW)
        less_than_ten,
       sum(case when rev_fre>=10 and rev_fre<20 then 1 else 0 end )
        over(partition by zsd_soto order by to_date(yuefen, 'yyyymm') range between interval '11' month preceding and CURRENT ROW)
       Ten_to_twenty,
        sum(case when rev_fre>=20 then 1 else 0 end )
        over(partition by zsd_soto order by to_date(yuefen, 'yyyymm') range between interval '11' month preceding and CURRENT ROW)
         more_than_twenty
from
(select substr(PERIOD_CODE_FEE,1,6) yuefen,zsd_soto,
sum(case when rev_amt>0 then rev_qty else 0 end) rev_qty, 
sum(case when rev_amt>0 then rev_amt else 0 end) rev_amt,
count(distinct case when rev_amt>0 then PERIOD_CODE_FEE else null end) rev_fre
from DM_CUSTBD_INCOME_FCT t
group by substr(PERIOD_CODE_FEE,1,6),zsd_soto));--------基础表


----------回款方式偏好
 
  truncate table dm_custbd_customer_hkpcph;
drop table dm_custbd_customer_hkpcph;
create table  dm_custbd_customer_hkpcph  tablespace dmdat as  
select customer_code,
       exchange_month,
       sum(sum_amount_12m) over(partition by customer_code, exchange_month) sum_amount,
       sum(sum_count_12m) over(partition by customer_code, exchange_month) sum_count,
       (first_value(exchange_type)over(partition by customer_code,exchange_month order by sum_amount_12m desc))
       cash_in_preference--------回款方式偏好，取金额最大的回款方式
  from ----每种回款方式对应的回款金额
         (select distinct (customer_code),
                        exchange_month,
                        exchange_group,
                        exchange_group_id,
                        exchange_type,
                        exchange_type_id,
                        sum(case
                              when amount > 0 then
                               amount
                              else
                               0
                            end) over(partition by exchange_month, customer_code, exchange_type) sum_amount_cur,-----当月回款金额
                        count(case
                                when amount > 0 then
                                 exchange_date
                                else
                                 0
                              end) over(partition by exchange_month, customer_code, exchange_type) sum_count_cur,-----当月回款次数
                               sum(case
                              when amount > 0 then
                               amount
                              else
                               0
                            end) over(partition by  customer_code, exchange_type
                            order by to_date(exchange_month, 'yyyymm') range between interval '11' month preceding and CURRENT ROW) 
                            sum_amount_12m,-----过去12个月的回款金额
                        count(case
                                when amount > 0 then
                                 exchange_date
                                else
                                 0
                              end) over(partition by customer_code, exchange_type
                              order by to_date(exchange_month, 'yyyymm') range between interval '11' month preceding and CURRENT ROW) 
                              sum_count_12m----过去12个月的回款次数
          from vw_dmcustbd_payment_overview)a 
              order by customer_code,exchange_month desc;


---信用资质
    ---------履约率
    truncate table dm_custbd_customer_lvyl;
drop table dm_custbd_customer_lvyl;
create table  dm_custbd_customer_lvyl  tablespace dmdat as    
select distinct(ccuscode), 
            period_month_cost, 
            avg(lvy_rate)over(partition by  ccuscode
                            order by to_date(period_month_cost, 'yyyymm') range between interval '11' month preceding and CURRENT ROW)  avg_lvy_rate 
        from
        (select ccuscode,
       period_month_cost,
       case when  sum(case when jihua>0 then jihua else 0 end) over(partition by ccuscode, period_month_cost) >0
         then
       sum(case when shiji>0 then shiji else 0 end) over(partition by ccuscode, period_month_cost)/
       sum(case when jihua>0 then jihua else 0 end) over(partition by ccuscode, period_month_cost) 
       else null
        end  lvy_rate------计算履约率，要求计划和实际均大于0，小于0的以0计
       from DM_CUSTBD_LYL_FCT);
 
---零售能力
     -----零售金额，库存周转率
 truncate table dm_custbd_customer_lsje_zzl;
drop table dm_custbd_customer_lsje_zzl;
create table  dm_custbd_customer_lsje_zzl  tablespace dmdat as    
select distinct(t.cust_code),
            t.calmonth,
      sum(t.SH_CNT+t.ZXJH_CNT) over(partition by cust_code,calmonth)  jhsl, --进货数量
      sum(t.SH_AMT+t.ZXJH_AMT)over(partition by cust_code,calmonth)   jhje, --进货金额
      sum(t.LS_CNT+t.PF_CNT+t.DB_OUT_CNT)over(partition by cust_code,calmonth)  xssl, --零售数量
      sum(t.LS_AMT+t.PF_AMT+t.DB_OUT_AMT)over(partition by cust_code,calmonth)   xsje,  --零售金额
      sum((case when t.stat_date=last_day(t.stat_date)  then t.QM_CNT end)+
              (case when t.stat_date=last_day(t.stat_date)  then t.QM_CNT_N end ))over(partition by cust_code,calmonth)  kcsl, --库存数量
      sum((case when  t.stat_date=last_day(t.stat_date)  then  t.QM_AMT end)+
              (case when  t.stat_date=last_day(t.stat_date)  then t.QM_AMT_N end))over(partition by cust_code,calmonth)  kcje, --库存金额
     case when (sum(case when a=1 then t.QC_AMT end)over(partition by cust_code,calmonth) + sum(case when a=1 then t.QC_AMT_N end)over(partition by cust_code,calmonth) +  --本月初第一天
                       sum(case when  t.stat_date=last_day(t.stat_date)  then  t.QM_AMT end)over(partition by cust_code,calmonth)+   --本月末最后一天
                       sum(case when  t.stat_date=last_day(t.stat_date)  then t.QM_AMT_N end)over(partition by cust_code,calmonth)) =0  --期初+期末库存金额为零
                       then null
     else   2*sum(t.LS_AMT+t.PF_AMT+t.DB_OUT_AMT)over(partition by cust_code,calmonth) /(sum(case when a=1 then t.QC_AMT end)over(partition by cust_code,calmonth) +
                                                                                     sum(case when a=1 then t.QC_AMT_N end)over(partition by cust_code,calmonth) +
                                                                                     sum(case when  t.stat_date=last_day(t.stat_date)  then  t.QM_AMT end)over(partition by cust_code,calmonth) +
                                                                                     sum(case when  t.stat_date=last_day(t.stat_date)  then t.QM_AMT_N end)over(partition by cust_code,calmonth) )
    end kczzl, --库存周转率
 
 case when (2*sum(t.LS_AMT+t.PF_AMT+t.DB_OUT_AMT)over(partition by cust_code,calmonth) ) =0 then null
         else 
               (sum(case when a=1 then t.QC_AMT end)over(partition by cust_code,calmonth)
                + sum(case when a=1 then t.QC_AMT_N end)over(partition by cust_code,calmonth) +
               sum(case when  t.stat_date=last_day(t.stat_date)  then  t.QM_AMT end)over(partition by cust_code,calmonth) +
             sum(case when  t.stat_date=last_day(t.stat_date)  then t.QM_AMT_N end)over(partition by cust_code,calmonth) )
             /(2*sum(t.LS_AMT+t.PF_AMT+t.DB_OUT_AMT)over(partition by cust_code,calmonth) )  
             
         end    kxb  --库销比
from (select t.*, row_number() over(partition by t.CUST_CODE,t.calmonth order by t.STAT_DATE) a
        from VM_ODSCUSTBD_JXC_PRDGRP_DD t   )  t ;

     
     -----提货收益、零售利润率
   truncate table dm_custbd_customer_lssy;
drop table dm_custbd_customer_lssy;
create table  dm_custbd_customer_lssy  tablespace dmdat as 
  select cus_code,calday, 
                sum(zsd_hfje+zsd_flje) over(partition by cus_code,calday)  profit_sale,  -----提货收益
                sum(zsd_hfje+zsd_flje+rev_amt)over(partition by cus_code,calday) rev_sal,-----毛收入
                case when sum(zsd_hfje+zsd_flje+rev_amt)over(partition by cus_code,calday)>0 then
                sum(zsd_hfje+zsd_flje)over(partition by cus_code,calday)/ sum(zsd_hfje+zsd_flje+rev_amt) over(partition by cus_code,calday)
                else null
                 end profit_rate-----零售利润率，提货收益/毛收入
   from
   (select distinct(cus_code), 
                 calday, 
                 sum(case when rev_amt>0 then rev_amt else 0 end) over(partition by cus_code
                            order by to_date(calday, 'yyyymm') range between interval '11' month preceding and CURRENT ROW) 
                            rev_amt,
                            sum(case when zsd_hfje>0 then zsd_hfje else 0 end) over(partition by cus_code
                            order by to_date(calday, 'yyyymm') range between interval '11' month preceding and CURRENT ROW) 
                           zsd_hfje,
                            sum(case when zsd_flje>0 then zsd_flje else 0 end) over(partition by cus_code
                            order by to_date(calday, 'yyyymm') range between interval '11' month preceding and CURRENT ROW) 
                            zsd_flje
                           from  DM_CUSTBD_MODEL_LISHI_2);
           
---宽表

truncate table dm_custbd_360_sy;
drop table dm_custbd_360_sy;
create table  dm_custbd_360_sy  tablespace dmdat as
select distinct a.customer_number,--客户编码
                a.customer_name,--客户名称
                a.customer_category,--渠道编码
                a.category_name,--渠道名称
                a.region,--区域编码
                a.region_name,--区域名称
               l.the_month year_month,      
                a.created_time_long,--建户时长
                (case
                  when (a.created_time_long > 3 or
                       a.created_time_long is null) then
                   3
                  when a.created_time_long <= 3 and a.created_time_long > 1 then
                   2
                  else
                   1
                end) created_time_long_dj,--合作时长等级
                
                a.amount_sum mendian_num,--门店数量
                (case
                  when a.amount_sum >= 5 then
                   3
                  when a.amount_sum <= 4 and a.amount_sum > 2 then
                   2
                  else
                   1
                end) mendian_num_dj,--门店数量等级
                
                a.amount_area mendian_area,--门店面积
                (case
                  when a.amount_area > 500 then
                   3
                  when a.amount_area <= 500 and a.amount_area > 200 then
                   2
                  else
                   1
                end) mendian_area_dj,--门店面积等级
                a.smzq_type,--生命周期
                
              b.maoshouru_max,--最大提货额
                (case
                  when b.maoshouru_max >= 400000 then
                   3
                  when b.maoshouru_max < 400000 and b.maoshouru_max >= 100000 then
                   2
                  else
                   1
                end) thje_max_dj,--最大提货额等级
                
              b.growth_year,--同比增长率
               (case
                  when b.growth_year > 0.15 then
                   3
                  when b.growth_year  <= 0.15 and b.growth_year  > 0 then
                   2
                  when b.growth_year  <= 0 then
                   1
                end) growth_year_dj,--同比增长率等级
                
               b.maoshouru/12 thje,-----提货金额
                
               (case
                  when b.maoshouru>= 3000000 then
                   3
                  when b.maoshouru< 3000000 and
                      b.maoshouru>= 1200000 then
                   2
                  when b.maoshouru< 1200000 then
                   1
                end) thje_dj,--提货金额等级
                b.ddgm,----单店规模
                  (case
                  when   b.ddgm >= 300000 then
                   3
                  when   b.ddgm< 300000 and   b.ddgm >50000 then
                   2
                  when   b.ddgm <= 50000 then
                   1
                end) ddgm_dj,--单店等级
                
                b.hkje_max,--最大单次回款金额
                (case
                  when  b.hkje_max >= 500000 then
                   3
                  when  b.hkje_max < 500000 and  b.hkje_max >100000 then
                   2
                  when  b.hkje_max <= 100000 then
                   1
                end) max_hk_dj,--最大单次回款金额等级
                  b.hkje_avg,--平均单次回款金额
                (case
                  when  b.hkje_avg>= 15000 then
                   3
                  when  b.hkje_avg < 15000 and  b.hkje_avg >10000 then
                   2
                  when  b.hkje_avg <= 10000 then
                   1
                end) avg_hk_dj,--平均单次回款金额等级
                 b.msr_day_avg,--平均单次提货金额
                (case
                  when  b.msr_day_avg>= 8000 then
                   3
                  when  b.msr_day_avg <8000 and  b.msr_day_avg >2000 then
                   2
                  when  b.msr_day_avg <= 2000 then
                   1
                end) msr_avg_dj,--平均单次提货金额等级
                 
             case when                      
               ((case
                  when b.maoshouru_max >= 400000 then
                   3
                  when b.maoshouru_max < 400000 and b.maoshouru_max >= 100000 then
                   2
                  else
                   1
                end)+(case
                  when b.growth_year  > 0.15 then
                   3
                  when b.growth_year  <= 0.15 and b.growth_year > 0 then
                   2
                  when b.growth_year  <= 0 then
                   1
                end) +  (case
                  when (b.maoshouru/12) >= 250000 then
                   3
                  when (b.maoshouru/12) < 250000 and
                       (b.maoshouru/12) >= 100000 then
                   2
                  when (b.maoshouru/12) < 100000 then
                   1
                end) + (case
                  when  b.hkje_max >= 500000 then
                   3
                  when  b.hkje_max < 500000 and  b.hkje_max >100000 then
                   2
                  when  b.hkje_max <= 100000 then
                   1
                end) +(case
                  when  b.hkje_avg>= 15000 then
                   3
                  when  b.hkje_avg < 15000 and  b.hkje_avg >10000 then
                   2
                  when  b.hkje_avg <= 10000 then
                   1
                end) +
                (case
                  when  b.msr_day_avg>= 8000 then
                   3
                  when  b.msr_day_avg <8000 and  b.msr_day_avg >2000 then
                   2
                  when  b.msr_day_avg <= 2000 then
                   1
                end)+
                 (case
                  when   b.ddgm >= 300000 then
                   3
                  when   b.ddgm< 300000 and   b.ddgm >50000 then
                   2
                  when   b.ddgm <= 50000 then
                   1
                end)) > 14 then
                   3
                when ( (case
                  when b.maoshouru_max >= 400000 then
                   3
                  when b.maoshouru_max< 400000 and b.maoshouru_max >= 100000 then
                   2
                  else
                   1
                end)+(case
                  when b.growth_year > 0.15 then
                   3
                  when b.growth_year <= 0.15 and b.growth_year > 0 then
                   2
                  when b.growth_year <= 0 then
                   1
                end) +  (case
                  when (b.maoshouru/12) >= 250000 then
                   3
                  when (b.maoshouru/12) < 250000 and
                       (b.maoshouru/12) >= 100000 then
                   2
                  when (b.maoshouru/12) < 100000 then
                   1
                end) + (case
                  when  b.hkje_max >= 500000 then
                   3
                  when  b.hkje_max < 500000 and  b.hkje_max >100000 then
                   2
                  when  b.hkje_max <= 100000 then
                   1
                end) +(case
                  when  b.hkje_avg>= 15000 then
                   3
                  when  b.hkje_avg < 15000 and  b.hkje_avg >10000 then
                   2
                  when  b.hkje_avg <= 10000 then
                   1
                end) +
                (case
                  when  b.msr_day_avg>= 8000 then
                   3
                  when  b.msr_day_avg <8000 and  b.msr_day_avg >2000 then
                   2
                  when  b.msr_day_avg <= 2000 then
                   1
                end)+
                 (case
                  when   b.ddgm >= 300000 then
                   3
                  when   b.ddgm< 300000 and   b.ddgm >50000 then
                   2
                  when   b.ddgm <= 50000 then
                   1
                end))/ 7 <=2 and
                  ( (case
                  when b.maoshouru_max >= 400000 then
                   3
                  when b.maoshouru_max < 400000 and b.maoshouru_max >= 100000 then
                   2
                  else
                   1
                end)+(case
                  when b.growth_year  > 0.15 then
                   3
                  when b.growth_year  <= 0.15 and b.growth_year  > 0 then
                   2
                  when b.growth_year <= 0 then
                   1
                end) +  (case
                  when (b.maoshouru/12) >= 250000 then
                   3
                  when (b.maoshouru/12) < 250000 and
                       (b.maoshouru/12) >= 100000 then
                   2
                  when (b.maoshouru/12) < 100000 then
                   1
                end) + (case
                  when  b.hkje_max >= 500000 then
                   3
                  when  b.hkje_max < 500000 and  b.hkje_max >100000 then
                   2
                  when  b.hkje_max <= 100000 then
                   1
                end) +(case
                  when  b.hkje_avg>= 15000 then
                   3
                  when  b.hkje_avg < 15000 and  b.hkje_avg >10000 then
                   2
                  when  b.hkje_avg <= 10000 then
                   1
                end) +
                (case
                  when  b.msr_day_avg>= 8000 then
                   3
                  when  b.msr_day_avg <8000 and  b.msr_day_avg >2000 then
                   2
                  when  b.msr_day_avg <= 2000 then
                   1
                end)+
                 (case
                  when   b.ddgm >= 300000 then
                   3
                  when   b.ddgm< 300000 and   b.ddgm >50000 then
                   2
                  when   b.ddgm <= 50000 then
                   1
                end))/7>1 then
                   2
                  else
                   1
                end  thnl_dj,--提货能力等级，按照几个提货能力指标的平均值分等级
                c.price_preference,------提货单价偏好
                j.Product_preference,------产品组偏好
                k.prize_preference,------奖励偏好
                 d.freq_preference,-----提货频次偏好 
                 e.cash_in_preference,-----回款方式偏好
                 f.avg_lvy_rate lvy_rate,-------履约率
                 (case
                  when f.avg_lvy_rate >= 0.8 then
                   3
                  when f.avg_lvy_rate  < 0.8 and f.avg_lvy_rate  > 0.4 then
                   2
                  else
                   1
                end) ly_rate_grade,--履约率等级
              g.ZONGHE_BD stability,-----稳定性
                (case
                  when g.ZONGHE_BD >= 1 then
                   3
                  when g.ZONGHE_BD <1 and g.ZONGHE_BD > 0 then
                   2
                   when g.ZONGHE_BD<=0 and  g.ZONGHE_BD > -1 then
                    1 
                  else
                   0
                end) stability_grade,--稳定性等级
                m.ysyqts_sum ysyqts,---应收账款逾期天数
                (case
                  when m.ysyqts_sum >= 93 then
                   3
                  when m.ysyqts_sum  < 93 and m.ysyqts_sum  > 7 then
                   2
                  else
                   1
                end) ysyqts_grade,--应收账款逾期天数等级
                m.ysyqcs_sum ysyqcs ,---应收账款逾期次数
                  (case
                  when m.ysyqcs_sum >= 20 then
                   3
                  when m.ysyqcs_sum <20 and m.ysyqcs_sum  > 2 then
                   2
                  else
                   1
                end) ysyqcs_grade,--应收账款逾期次数等级
              case when
                   ((case
                  when f.avg_lvy_rate >= 0.8 then
                   3
                  when f.avg_lvy_rate < 0.8 and f.avg_lvy_rate  > 0.4 then
                   2
                  else
                   1
                end)
                + 
                  (case
                  when g.ZONGHE_BD >= 1 then
                   3
                  when g.ZONGHE_BD <1 and g.ZONGHE_BD > 0 then
                   2
                   when g.ZONGHE_BD<=0 and  g.ZONGHE_BD > -1 then
                    1 
                  else
                   0
                end) )/2>2 then
                3
                when
                   ((case
                  when f.avg_lvy_rate >= 0.8 then
                   3
                  when f.avg_lvy_rate < 0.8 and f.avg_lvy_rate > 0.4 then
                   2
                  else
                   1
                end)
                + 
                 (case
                  when g.ZONGHE_BD >= 1 then
                   3
                  when g.ZONGHE_BD <1 and g.ZONGHE_BD > 0 then
                   2
                   when g.ZONGHE_BD<=0 and  g.ZONGHE_BD > -1 then
                    1 
                  else
                   0
                end) )/2<=2 and
                 ((case
                  when f.avg_lvy_rate >= 0.8 then
                   3
                  when f.avg_lvy_rate < 0.8 and f.avg_lvy_rate  > 0.4 then
                   2
                  else
                   1
                end)
                + 
                 (case
                  when g.ZONGHE_BD >= 1 then
                   3
                  when g.ZONGHE_BD <1 and g.ZONGHE_BD > 0 then
                   2
                   when g.ZONGHE_BD<=0 and  g.ZONGHE_BD > -1 then
                    1 
                  else
                   0
                end) )/2>1 then
                2
                else 1
                 end credit_value,------信用资质等级，按照几个信用资质指标的平均值分等级
                h.xsje rev_sale,-------零售金额
                case
                  when h.xsje >=1000000 then
                   3
                  when h.xsje <1000000 and h.xsje > 200000 then
                   2
                  else
                   1
                end   rev_sale_grade,------零售金额等级
                h.kczzl stock_turnover,------库存周转率
                 case
                  when  h.kczzl >=1 then
                   3
                  when  h.kczzl<1 and  h.kczzl > 0.3 then
                   2
                  else
                   1
                end  stock_turnover_grade,------库存周转率等级
                i.profit_sale,------提货收益
                 case
                  when  i.profit_sale >=200000 then
                   3
                  when  i.profit_sale<200000 and  i.profit_sale > 50000 then
                   2
                  else
                   1
                end   profit_sale_grade,------提货收益等级
                i.profit_rate,------零售利润率
                 case
                  when i.profit_rate >=0.2 then
                   3
                  when i.profit_rate<0.2 and i.profit_rate >0.08 then
                   2
                  else
                   1
                end   profit_rate_grade,------零售利润率等级
               case when
                  （case
                  when h.xsje >=1000000 then
                   3
                  when h.xsje <1000000 and h.xsje > 200000 then
                   2
                  else
                   1
                end 
                +
                case
                  when  h.kczzl >=1 then
                   3
                  when  h.kczzl<1 and  h.kczzl > 0.3 then
                   2
                  else
                   1
                end 
                +
                 case
                  when  i.profit_sale >=200000 then
                   3
                  when  i.profit_sale<200000 and  i.profit_sale > 50000 then
                   2
                  else
                   1
                end
                +
                 case
                  when i.profit_rate >=0.2 then
                   3
                  when i.profit_rate<0.2 and i.profit_rate >0.08 then
                   2
                  else
                   1
                end)/4>2 then
                3
                when 
                 （case
                  when h.xsje >=1000000 then
                   3
                  when h.xsje <1000000 and h.xsje > 200000 then
                   2
                  else
                   1
                end 
                +
                case
                  when  h.kczzl >=1 then
                   3
                  when  h.kczzl<1 and  h.kczzl > 0.3 then
                   2
                  else
                   1
                end 
                +
                 case
                  when  i.profit_sale >=200000 then
                   3
                  when  i.profit_sale<200000 and  i.profit_sale > 50000 then
                   2
                  else
                   1
                end
                +
                 case
                  when i.profit_rate >=0.2 then
                   3
                  when i.profit_rate<0.2 and i.profit_rate >0.08 then
                   2
                  else
                   1
                end)/4<=2 and
                （case
                  when h.xsje >=1000000 then
                   3
                  when h.xsje <1000000 and h.xsje > 200000 then
                   2
                  else
                   1
                end 
                +
                case
                  when  h.kczzl >=1 then
                   3
                  when  h.kczzl<1 and  h.kczzl > 0.3 then
                   2
                  else
                   1
                end 
                +
                 case
                  when  i.profit_sale >=200000 then
                   3
                  when  i.profit_sale<200000 and  i.profit_sale > 50000 then
                   2
                  else
                   1
                end
                +
                 case
                  when i.profit_rate >=0.2 then
                   3
                  when i.profit_rate<0.2 and i.profit_rate >0.08 then
                   2
                  else
                   1
                end)/4<1 then
                2
                else 1
                end sale_power------零售能力，按照几个零售能力指标的平均值分等级
                
  from dm_custbd_customer_jcsx a
  left join dm_custbd_customer_thnl b
    on a.customer_number = b.zsd_soto
    left join dm_custbd_date_dimension l
    on b.yuefen=l.the_month
  left join dm_custbd_customer_cpph_1 c
    on a.customer_number = c.zsd_soto and l.the_month=c.calmonth
    left join dm_custbd_customer_thpcph d
    on a.customer_number=d.zsd_soto and l.the_month=d.yuefen
     left join dm_custbd_customer_hkpcph e
    on a.customer_number=e.customer_code and l.the_month=e.exchange_month
    left join dm_custbd_customer_lvyl f
    on a.customer_number=f.ccuscode and l.the_month=f.period_month_cost
    left join DM_CUSTBD_KHJZ_ANQUAN g
    on a.customer_number=g.zsd_soto and l.the_month=g.yuefen
    left join dm_custbd_customer_lsje_zzl h
    on a.customer_number=h.cust_code and l.the_month=h.calmonth
    left join dm_custbd_customer_lssy i
    on a.customer_number=i.cus_code and l.the_month=i.calday
    left join dm_custbd_customer_cpph j
    on a.customer_number=j.zsd_soto and l.the_month=j.calmonth
    left join dm_custbd_customer_jlph k
    on a.customer_number=k.customer_number and l.the_month=k.year_month
    left join dm_custbd_credit_10 m
    on a.customer_number=m.sold_to and l.the_month=m.year_month;
    comment on column dm_custbd_360_sy.customer_number is '客户编码';
        comment on column dm_custbd_360_sy.customer_name is '客户名称';
            comment on column dm_custbd_360_sy.customer_category is '渠道编码';
                comment on column dm_custbd_360_sy.category_name is '渠道名称';
                    comment on column dm_custbd_360_sy.region_name is '区域名称';
                        comment on column dm_custbd_360_sy.year_month is '月份';
                            comment on column dm_custbd_360_sy.created_time_long is '合作时长';
                                comment on column dm_custbd_360_sy.created_time_long_dj is '合作时长等级';
                                    comment on column dm_custbd_360_sy.mendian_num is '门店数量';
                                        comment on column dm_custbd_360_sy.mendian_num_dj is '门店数量等级';
                                            comment on column dm_custbd_360_sy.mendian_area is '门店面积';
                                                comment on column dm_custbd_360_sy.mendian_area_dj is '门店面积等级';
                                                    comment on column dm_custbd_360_sy.smzq_type is '生命周期类型';
                                                        comment on column dm_custbd_360_sy.maoshouru_max is '最大单次提货额';
                                                            comment on column dm_custbd_360_sy.growth_year is '提货同比增长率';
                                                            comment on column dm_custbd_360_sy.growth_year_dj is '提货同比增长率等级';
        comment on column dm_custbd_360_sy.thje is '提货金额';
            comment on column dm_custbd_360_sy.thje is '提货金额等级';
            comment on column dm_custbd_360_sy.ddgm is '单店规模';
            comment on column dm_custbd_360_sy.ddgm_dj is '单店规模等级';
                comment on column dm_custbd_360_sy.hkje_max is '最大单次回款金额';
                    comment on column dm_custbd_360_sy.max_hk_dj is '最大单次回款金额等级';
                        comment on column dm_custbd_360_sy.hkje_avg is '平均单次回款金额';
                            comment on column dm_custbd_360_sy.avg_hk_dj is '平均单次回款金额等级';
                                comment on column dm_custbd_360_sy.msr_day_avg is '平均单次提货金额';
                                    comment on column dm_custbd_360_sy.msr_day_avg_dj is '平均单次提货金额等级';
                                     comment on column dm_custbd_360_sy.thnl_dj is '提货能力标签';
                                       comment on column dm_custbd_360_sy.prize_preference is  '奖励偏好';
                                        comment on column dm_custbd_360_sy.product_preference is '产品组偏好' ;
                                         comment on column dm_custbd_360_sy.price_preference is'产品单价偏好';
                                            comment on column dm_custbd_360_sy.freq_preference is '提货频次偏好';
                                                comment on column dm_custbd_360_sy.cash_in_preference is '回款方式偏好';
                                                    comment on column dm_custbd_360_sy.lvy_rate is '履约率';
                                                        comment on column dm_custbd_360_sy.ly_rate_grade is '履约率等级';
                                                            comment on column dm_custbd_360_sy.stability is '安全价值';
              comment on column dm_custbd_360_sy.stability_grade is '安全价值等级';
                 comment on column dm_custbd_360_sy.ysyqts is '信用逾期天数';
              comment on column dm_custbd_360_sy.ysyqts_grade is '信用逾期天数等级';
                      comment on column dm_custbd_360_sy.ysyqcs is '信用逾期次数';
              comment on column dm_custbd_360_sy.ysyqcs_grade is '信用逾期次数等级';
            comment on column dm_custbd_360_sy.credit_value is '信用资质标签';
                comment on column dm_custbd_360_sy.rev_sale is '零售金额';
                    comment on column dm_custbd_360_sy.rev_sale_grade is '零售金额等级';
                        comment on column dm_custbd_360_sy.stock_turnover is '库存周转率';
                            comment on column dm_custbd_360_sy.stock_turnover_grade is '库存周转率等级';
                                comment on column dm_custbd_360_sy.profit_sale is '提货收益';
                                    comment on column dm_custbd_360_sy.profit_sale_grade is '提货收益等级';
                                        comment on column dm_custbd_360_sy.profit_rate is '零售利润率';
                                            comment on column dm_custbd_360_sy.profit_rate_grade is '零售利润率等级';
                                                comment on column dm_custbd_360_sy.sale_power is '零售能力标签';                                      
    
    
    
  ----------------------客户画像脚本结束---------------------------------------
   

