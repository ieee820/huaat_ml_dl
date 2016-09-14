--------------------�ͻ�����ű�ʹ�õ��ⲿ��һ��-------------------
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
dm_custbd_smzq_type----------�������ڱ�ǩ��
dm_custbd_credit_10------------���ű���ָ���
DM_CUSTBD_KHJZ_QIANLI------------Ǳ����ֵ���ձ�
DM_CUSTBD_MODEL_LISHI_2
dm_custbd_date_dimension
*/

----------------------------------------------------------��������---------------------------------------------------
----��������-----
truncate table dm_custbd_customer_jcsx;
drop table dm_custbd_customer_jcsx;
create table dm_custbd_customer_jcsx  tablespace dmdat as
select distinct a.customer_number,----�ͻ�����
                a.customer_name,-----�ͻ�����
                a.customer_category,-----��������
                a.category_name,-----��������
                a.region,----�������
                a.region_name,-----��������
                a.created_time_long,-----����ʱ��
                b.amount_sum,-----�ŵ�����
                b.amount_area,----�ŵ����
                c.smzq_type_code smzq_type,-----������������
                a.delete_flag-----����״̬
  FROM dm_custbd_customer a
  left join (select distinct a.cus_code customer_number,
a.imonths year_month,a.amount_sum,a.sbr_housemj_sum amount_area  from DM_CUSTBD_CUSTOMER_STORE_SUM a ) b
    on a.customer_number = b.customer_number
  left join dm_custbd_smzq_type c----�������ڱ�ǩ��
    on a.customer_number = c.zsd_soto;


------------------------------------------------------------�������--------------------------------------------------------------

drop table dm_custbd_customer_thnl;
create table dm_custbd_customer_thnl  tablespace dmdat as
SELECT distinct t.zsd_soto,
                t.yuefen,
                t.MAOSHOURU, --ë����
                t.MAOSHOURU_TB, --ͬ��ë����
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
                       end growth_year, ------���ͬ��������
                t.STORE_AMOUNT_SUM, --�ŵ�����
                (sum(t.MAOSHOURU)
                 over(partition by t.zsd_soto order by
                      to_date(t.yuefen, 'yyyymm') range between interval '12'
                      month preceding and CURRENT ROW)) / 12 msr_month_avg, ---ë�������12���µ���ƽ��ֵ�������
                (t.MAOSHOURU / case
                  when t.STORE_AMOUNT_SUM = 0 then
                   null
                  else
                   t.STORE_AMOUNT_SUM
                end) ddgm, --�����ģ
                t.MAOSHOURU_TBLV, --ë����ͬ�������ʣ������ͬ�������ʣ� 
                t.MAOSHOURU_MAX, --�����������󵥴�����  
                t1.hkje_max, --��󵥴λؿ���
                t1.hkje_sum / 365 hkje_avg, --�ؿ������12���µ���ƽ����ƽ�����λؿ��
                (sum(t.MAOSHOURU)
                 over(partition by t.zsd_soto order by
                      to_date(t.yuefen, 'yyyymm') range between interval '12'
                      month preceding and CURRENT ROW)) / 365 msr_day_avg ---ë�������12���µ���ƽ��ֵ��ƽ�����������

  from DM_CUSTBD_KHJZ_QIANLI t

  left join (SELECT distinct customer_code,
                             exchange_month,
                             max(amount) over(partition by customer_code order by to_date(exchange_month, 'yyyymm') 
range between interval '12' month preceding and CURRENT ROW) hkje_max,
                             sum(amount) over(partition by customer_code order by to_date(exchange_month, 'yyyymm') 
range between interval '12' month preceding and CURRENT ROW) hkje_sum
             
               FROM VW_DMCUSTBD_PAYMENT_OVERVIEW
              where exchange_group in ('�ֻ�', '�ж�', '����')) t1
    on t.zsd_soto = t1.customer_code
   and t.yuefen = t1.exchange_month;



---------------------------------------------------------���ƫ��-----------------------------------------------------------------

truncate table dm_custbd_sr_cp_xh_month1;
drop table dm_custbd_sr_cp_xh_month1;
create table dm_custbd_sr_cp_xh_month1 as---------��JDE�ͻ�����ת��ΪGVS���룬�����»��������
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
                    division,----��Ʒ�����
                    division_name,----��Ʒ������
                    zsd_mat,
                    sum(zsd_revq) over(partition by zsd_soto, calmonth,division) zsd_revq,
                      sum(jsr) over(partition by zsd_soto, calmonth,division) jsr,
                        sum(zkje) over(partition by zsd_soto, calmonth,division) zkje,
                          sum(hfje) over(partition by zsd_soto, calmonth,division) hfje,
                            sum(msr) over(partition by zsd_soto, calmonth,division)  msr                         
      from dm_custbd_sr_cp_xh_month1;
    
--����Դ
--�������ƫ��
truncate table dm_custbd_customer_cpph_1;
drop table dm_custbd_customer_cpph_1;
create table  dm_custbd_customer_cpph_1  tablespace dmdat as
---ÿ���ͻ�ƫ�õ��������
select distinct t3.ZSD_SOTO,
                t3.CALMONTH,
                t3.CALYEAR,
                 (first_value(t3.djqj)over(partition by t3.ZSD_SOTO, t3.CALMONTH order by zsd_revq_sum desc))
       price_preference
       ---���12�����ڣ�ÿ���۸�������������
  from (select distinct t2.ZSD_SOTO,
                        t2.CALMONTH,
                        t2.CALYEAR,
                        t2.djqj,
                        sum(t2.ZSD_REVQ) over(partition by t2.zsd_soto, t2.djqj order by to_date(t2.CALMONTH, 'yyyymm') range between interval '12' month preceding and CURRENT ROW) zsd_revq_sum
 ---���ͺŵļ۸񻮷ּ۸�����       
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



-------��Ʒ��ƫ��

truncate table dm_custbd_customer_cpph;
drop table dm_custbd_customer_cpph;
create table  dm_custbd_customer_cpph  tablespace dmdat as
select distinct l.zsd_soto,l.calmonth,
                       case when l.s is not null then
                       e.value_meaning || ' ' || ',' || ' ' || f.value_meaning 
                       else
                        e.value_meaning
                      end product_preference-----��Ʒ��ƫ��
  
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
                                   from dm_custbd_sr_cp_xh_month2 a------��ʱʹ�õ������
               ) w
                         order by zsd_soto, rank) t
                 where t.rank <= 2) m pivot(max(m.prod_code) for rank in(1 as f,
                                                                         2 as s)) s) l
  left join (SELECT distinct value, value_meaning
               FROM ODSMDM_HM_VALUE_SET ---��Ʒά�ȱ�
              where value_set_id = 'ProductGroup'
                and DELETE_FLAG = 0
                and ACTIVE_FLAG = 1) e
    on l.f = e.value
  left join (SELECT distinct value, value_meaning
               FROM ODSMDM_HM_VALUE_SET----��Ʒά�ȱ�
              where value_set_id = 'ProductGroup'
                and DELETE_FLAG = 0
                and ACTIVE_FLAG = 1) f
    on l.s = f.value;
    

------����ƫ�ñ�------
truncate table dm_custbd_customer_jlph;
drop table dm_custbd_customer_jlph;
create table  dm_custbd_customer_jlph  tablespace dmdat as
  (select distinct t3.customer_number,--------����ƫ��
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
               from (select distinct customer_number, year_month,a1, a2, a3-----ȡ�������ǰ����
                       from (select distinct t1.customer_number,
                                             t1.year_month,
                                             t1.cprizename,
                                             t1.rank
                             
                               from (select distinct a.customer_number,-------�������������
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





---���Ƶ��----------
 
  truncate table dm_custbd_customer_thpcph;
drop table dm_custbd_customer_thpcph;
create table  dm_custbd_customer_thpcph  tablespace dmdat as      
 select zsd_soto,yuefen,
 case when -------ȡ���Ƶ������
   less_than_ten=ten_to_twenty or less_than_ten=more_than_twenty or ten_to_twenty=more_than_twenty then '��ƫ��'
   when   less_than_ten=greatest(less_than_ten,ten_to_twenty,more_than_twenty)  then '10������'
    when  ten_to_twenty=greatest(less_than_ten,ten_to_twenty,more_than_twenty)  then '10-19��' 
    when  more_than_twenty=greatest(less_than_ten,ten_to_twenty,more_than_twenty)  then '20������'   
  else null
    end freq_preference
    from
(select zsd_soto,-----�����Ƶ�ζ�������
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
group by substr(PERIOD_CODE_FEE,1,6),zsd_soto));--------������


----------�ؿʽƫ��
 
  truncate table dm_custbd_customer_hkpcph;
drop table dm_custbd_customer_hkpcph;
create table  dm_custbd_customer_hkpcph  tablespace dmdat as  
select customer_code,
       exchange_month,
       sum(sum_amount_12m) over(partition by customer_code, exchange_month) sum_amount,
       sum(sum_count_12m) over(partition by customer_code, exchange_month) sum_count,
       (first_value(exchange_type)over(partition by customer_code,exchange_month order by sum_amount_12m desc))
       cash_in_preference--------�ؿʽƫ�ã�ȡ������Ļؿʽ
  from ----ÿ�ֻؿʽ��Ӧ�Ļؿ���
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
                            end) over(partition by exchange_month, customer_code, exchange_type) sum_amount_cur,-----���»ؿ���
                        count(case
                                when amount > 0 then
                                 exchange_date
                                else
                                 0
                              end) over(partition by exchange_month, customer_code, exchange_type) sum_count_cur,-----���»ؿ����
                               sum(case
                              when amount > 0 then
                               amount
                              else
                               0
                            end) over(partition by  customer_code, exchange_type
                            order by to_date(exchange_month, 'yyyymm') range between interval '11' month preceding and CURRENT ROW) 
                            sum_amount_12m,-----��ȥ12���µĻؿ���
                        count(case
                                when amount > 0 then
                                 exchange_date
                                else
                                 0
                              end) over(partition by customer_code, exchange_type
                              order by to_date(exchange_month, 'yyyymm') range between interval '11' month preceding and CURRENT ROW) 
                              sum_count_12m----��ȥ12���µĻؿ����
          from vw_dmcustbd_payment_overview)a 
              order by customer_code,exchange_month desc;


---��������
    ---------��Լ��
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
        end  lvy_rate------������Լ�ʣ�Ҫ��ƻ���ʵ�ʾ�����0��С��0����0��
       from DM_CUSTBD_LYL_FCT);
 
---��������
     -----���۽������ת��
 truncate table dm_custbd_customer_lsje_zzl;
drop table dm_custbd_customer_lsje_zzl;
create table  dm_custbd_customer_lsje_zzl  tablespace dmdat as    
select distinct(t.cust_code),
            t.calmonth,
      sum(t.SH_CNT+t.ZXJH_CNT) over(partition by cust_code,calmonth)  jhsl, --��������
      sum(t.SH_AMT+t.ZXJH_AMT)over(partition by cust_code,calmonth)   jhje, --�������
      sum(t.LS_CNT+t.PF_CNT+t.DB_OUT_CNT)over(partition by cust_code,calmonth)  xssl, --��������
      sum(t.LS_AMT+t.PF_AMT+t.DB_OUT_AMT)over(partition by cust_code,calmonth)   xsje,  --���۽��
      sum((case when t.stat_date=last_day(t.stat_date)  then t.QM_CNT end)+
              (case when t.stat_date=last_day(t.stat_date)  then t.QM_CNT_N end ))over(partition by cust_code,calmonth)  kcsl, --�������
      sum((case when  t.stat_date=last_day(t.stat_date)  then  t.QM_AMT end)+
              (case when  t.stat_date=last_day(t.stat_date)  then t.QM_AMT_N end))over(partition by cust_code,calmonth)  kcje, --�����
     case when (sum(case when a=1 then t.QC_AMT end)over(partition by cust_code,calmonth) + sum(case when a=1 then t.QC_AMT_N end)over(partition by cust_code,calmonth) +  --���³���һ��
                       sum(case when  t.stat_date=last_day(t.stat_date)  then  t.QM_AMT end)over(partition by cust_code,calmonth)+   --����ĩ���һ��
                       sum(case when  t.stat_date=last_day(t.stat_date)  then t.QM_AMT_N end)over(partition by cust_code,calmonth)) =0  --�ڳ�+��ĩ�����Ϊ��
                       then null
     else   2*sum(t.LS_AMT+t.PF_AMT+t.DB_OUT_AMT)over(partition by cust_code,calmonth) /(sum(case when a=1 then t.QC_AMT end)over(partition by cust_code,calmonth) +
                                                                                     sum(case when a=1 then t.QC_AMT_N end)over(partition by cust_code,calmonth) +
                                                                                     sum(case when  t.stat_date=last_day(t.stat_date)  then  t.QM_AMT end)over(partition by cust_code,calmonth) +
                                                                                     sum(case when  t.stat_date=last_day(t.stat_date)  then t.QM_AMT_N end)over(partition by cust_code,calmonth) )
    end kczzl, --�����ת��
 
 case when (2*sum(t.LS_AMT+t.PF_AMT+t.DB_OUT_AMT)over(partition by cust_code,calmonth) ) =0 then null
         else 
               (sum(case when a=1 then t.QC_AMT end)over(partition by cust_code,calmonth)
                + sum(case when a=1 then t.QC_AMT_N end)over(partition by cust_code,calmonth) +
               sum(case when  t.stat_date=last_day(t.stat_date)  then  t.QM_AMT end)over(partition by cust_code,calmonth) +
             sum(case when  t.stat_date=last_day(t.stat_date)  then t.QM_AMT_N end)over(partition by cust_code,calmonth) )
             /(2*sum(t.LS_AMT+t.PF_AMT+t.DB_OUT_AMT)over(partition by cust_code,calmonth) )  
             
         end    kxb  --������
from (select t.*, row_number() over(partition by t.CUST_CODE,t.calmonth order by t.STAT_DATE) a
        from VM_ODSCUSTBD_JXC_PRDGRP_DD t   )  t ;

     
     -----������桢����������
   truncate table dm_custbd_customer_lssy;
drop table dm_custbd_customer_lssy;
create table  dm_custbd_customer_lssy  tablespace dmdat as 
  select cus_code,calday, 
                sum(zsd_hfje+zsd_flje) over(partition by cus_code,calday)  profit_sale,  -----�������
                sum(zsd_hfje+zsd_flje+rev_amt)over(partition by cus_code,calday) rev_sal,-----ë����
                case when sum(zsd_hfje+zsd_flje+rev_amt)over(partition by cus_code,calday)>0 then
                sum(zsd_hfje+zsd_flje)over(partition by cus_code,calday)/ sum(zsd_hfje+zsd_flje+rev_amt) over(partition by cus_code,calday)
                else null
                 end profit_rate-----���������ʣ��������/ë����
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
           
---���

truncate table dm_custbd_360_sy;
drop table dm_custbd_360_sy;
create table  dm_custbd_360_sy  tablespace dmdat as
select distinct a.customer_number,--�ͻ�����
                a.customer_name,--�ͻ�����
                a.customer_category,--��������
                a.category_name,--��������
                a.region,--�������
                a.region_name,--��������
               l.the_month year_month,      
                a.created_time_long,--����ʱ��
                (case
                  when (a.created_time_long > 3 or
                       a.created_time_long is null) then
                   3
                  when a.created_time_long <= 3 and a.created_time_long > 1 then
                   2
                  else
                   1
                end) created_time_long_dj,--����ʱ���ȼ�
                
                a.amount_sum mendian_num,--�ŵ�����
                (case
                  when a.amount_sum >= 5 then
                   3
                  when a.amount_sum <= 4 and a.amount_sum > 2 then
                   2
                  else
                   1
                end) mendian_num_dj,--�ŵ������ȼ�
                
                a.amount_area mendian_area,--�ŵ����
                (case
                  when a.amount_area > 500 then
                   3
                  when a.amount_area <= 500 and a.amount_area > 200 then
                   2
                  else
                   1
                end) mendian_area_dj,--�ŵ�����ȼ�
                a.smzq_type,--��������
                
              b.maoshouru_max,--��������
                (case
                  when b.maoshouru_max >= 400000 then
                   3
                  when b.maoshouru_max < 400000 and b.maoshouru_max >= 100000 then
                   2
                  else
                   1
                end) thje_max_dj,--��������ȼ�
                
              b.growth_year,--ͬ��������
               (case
                  when b.growth_year > 0.15 then
                   3
                  when b.growth_year  <= 0.15 and b.growth_year  > 0 then
                   2
                  when b.growth_year  <= 0 then
                   1
                end) growth_year_dj,--ͬ�������ʵȼ�
                
               b.maoshouru/12 thje,-----������
                
               (case
                  when b.maoshouru>= 3000000 then
                   3
                  when b.maoshouru< 3000000 and
                      b.maoshouru>= 1200000 then
                   2
                  when b.maoshouru< 1200000 then
                   1
                end) thje_dj,--������ȼ�
                b.ddgm,----�����ģ
                  (case
                  when   b.ddgm >= 300000 then
                   3
                  when   b.ddgm< 300000 and   b.ddgm >50000 then
                   2
                  when   b.ddgm <= 50000 then
                   1
                end) ddgm_dj,--����ȼ�
                
                b.hkje_max,--��󵥴λؿ���
                (case
                  when  b.hkje_max >= 500000 then
                   3
                  when  b.hkje_max < 500000 and  b.hkje_max >100000 then
                   2
                  when  b.hkje_max <= 100000 then
                   1
                end) max_hk_dj,--��󵥴λؿ���ȼ�
                  b.hkje_avg,--ƽ�����λؿ���
                (case
                  when  b.hkje_avg>= 15000 then
                   3
                  when  b.hkje_avg < 15000 and  b.hkje_avg >10000 then
                   2
                  when  b.hkje_avg <= 10000 then
                   1
                end) avg_hk_dj,--ƽ�����λؿ���ȼ�
                 b.msr_day_avg,--ƽ������������
                (case
                  when  b.msr_day_avg>= 8000 then
                   3
                  when  b.msr_day_avg <8000 and  b.msr_day_avg >2000 then
                   2
                  when  b.msr_day_avg <= 2000 then
                   1
                end) msr_avg_dj,--ƽ������������ȼ�
                 
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
                end  thnl_dj,--��������ȼ������ռ����������ָ���ƽ��ֵ�ֵȼ�
                c.price_preference,------�������ƫ��
                j.Product_preference,------��Ʒ��ƫ��
                k.prize_preference,------����ƫ��
                 d.freq_preference,-----���Ƶ��ƫ�� 
                 e.cash_in_preference,-----�ؿʽƫ��
                 f.avg_lvy_rate lvy_rate,-------��Լ��
                 (case
                  when f.avg_lvy_rate >= 0.8 then
                   3
                  when f.avg_lvy_rate  < 0.8 and f.avg_lvy_rate  > 0.4 then
                   2
                  else
                   1
                end) ly_rate_grade,--��Լ�ʵȼ�
              g.ZONGHE_BD stability,-----�ȶ���
                (case
                  when g.ZONGHE_BD >= 1 then
                   3
                  when g.ZONGHE_BD <1 and g.ZONGHE_BD > 0 then
                   2
                   when g.ZONGHE_BD<=0 and  g.ZONGHE_BD > -1 then
                    1 
                  else
                   0
                end) stability_grade,--�ȶ��Եȼ�
                m.ysyqts_sum ysyqts,---Ӧ���˿���������
                (case
                  when m.ysyqts_sum >= 93 then
                   3
                  when m.ysyqts_sum  < 93 and m.ysyqts_sum  > 7 then
                   2
                  else
                   1
                end) ysyqts_grade,--Ӧ���˿����������ȼ�
                m.ysyqcs_sum ysyqcs ,---Ӧ���˿����ڴ���
                  (case
                  when m.ysyqcs_sum >= 20 then
                   3
                  when m.ysyqcs_sum <20 and m.ysyqcs_sum  > 2 then
                   2
                  else
                   1
                end) ysyqcs_grade,--Ӧ���˿����ڴ����ȼ�
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
                 end credit_value,------�������ʵȼ������ռ�����������ָ���ƽ��ֵ�ֵȼ�
                h.xsje rev_sale,-------���۽��
                case
                  when h.xsje >=1000000 then
                   3
                  when h.xsje <1000000 and h.xsje > 200000 then
                   2
                  else
                   1
                end   rev_sale_grade,------���۽��ȼ�
                h.kczzl stock_turnover,------�����ת��
                 case
                  when  h.kczzl >=1 then
                   3
                  when  h.kczzl<1 and  h.kczzl > 0.3 then
                   2
                  else
                   1
                end  stock_turnover_grade,------�����ת�ʵȼ�
                i.profit_sale,------�������
                 case
                  when  i.profit_sale >=200000 then
                   3
                  when  i.profit_sale<200000 and  i.profit_sale > 50000 then
                   2
                  else
                   1
                end   profit_sale_grade,------�������ȼ�
                i.profit_rate,------����������
                 case
                  when i.profit_rate >=0.2 then
                   3
                  when i.profit_rate<0.2 and i.profit_rate >0.08 then
                   2
                  else
                   1
                end   profit_rate_grade,------���������ʵȼ�
               case when
                  ��case
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
                 ��case
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
                ��case
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
                end sale_power------�������������ռ�����������ָ���ƽ��ֵ�ֵȼ�
                
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
    comment on column dm_custbd_360_sy.customer_number is '�ͻ�����';
        comment on column dm_custbd_360_sy.customer_name is '�ͻ�����';
            comment on column dm_custbd_360_sy.customer_category is '��������';
                comment on column dm_custbd_360_sy.category_name is '��������';
                    comment on column dm_custbd_360_sy.region_name is '��������';
                        comment on column dm_custbd_360_sy.year_month is '�·�';
                            comment on column dm_custbd_360_sy.created_time_long is '����ʱ��';
                                comment on column dm_custbd_360_sy.created_time_long_dj is '����ʱ���ȼ�';
                                    comment on column dm_custbd_360_sy.mendian_num is '�ŵ�����';
                                        comment on column dm_custbd_360_sy.mendian_num_dj is '�ŵ������ȼ�';
                                            comment on column dm_custbd_360_sy.mendian_area is '�ŵ����';
                                                comment on column dm_custbd_360_sy.mendian_area_dj is '�ŵ�����ȼ�';
                                                    comment on column dm_custbd_360_sy.smzq_type is '������������';
                                                        comment on column dm_custbd_360_sy.maoshouru_max is '��󵥴������';
                                                            comment on column dm_custbd_360_sy.growth_year is '���ͬ��������';
                                                            comment on column dm_custbd_360_sy.growth_year_dj is '���ͬ�������ʵȼ�';
        comment on column dm_custbd_360_sy.thje is '������';
            comment on column dm_custbd_360_sy.thje is '������ȼ�';
            comment on column dm_custbd_360_sy.ddgm is '�����ģ';
            comment on column dm_custbd_360_sy.ddgm_dj is '�����ģ�ȼ�';
                comment on column dm_custbd_360_sy.hkje_max is '��󵥴λؿ���';
                    comment on column dm_custbd_360_sy.max_hk_dj is '��󵥴λؿ���ȼ�';
                        comment on column dm_custbd_360_sy.hkje_avg is 'ƽ�����λؿ���';
                            comment on column dm_custbd_360_sy.avg_hk_dj is 'ƽ�����λؿ���ȼ�';
                                comment on column dm_custbd_360_sy.msr_day_avg is 'ƽ������������';
                                    comment on column dm_custbd_360_sy.msr_day_avg_dj is 'ƽ������������ȼ�';
                                     comment on column dm_custbd_360_sy.thnl_dj is '���������ǩ';
                                       comment on column dm_custbd_360_sy.prize_preference is  '����ƫ��';
                                        comment on column dm_custbd_360_sy.product_preference is '��Ʒ��ƫ��' ;
                                         comment on column dm_custbd_360_sy.price_preference is'��Ʒ����ƫ��';
                                            comment on column dm_custbd_360_sy.freq_preference is '���Ƶ��ƫ��';
                                                comment on column dm_custbd_360_sy.cash_in_preference is '�ؿʽƫ��';
                                                    comment on column dm_custbd_360_sy.lvy_rate is '��Լ��';
                                                        comment on column dm_custbd_360_sy.ly_rate_grade is '��Լ�ʵȼ�';
                                                            comment on column dm_custbd_360_sy.stability is '��ȫ��ֵ';
              comment on column dm_custbd_360_sy.stability_grade is '��ȫ��ֵ�ȼ�';
                 comment on column dm_custbd_360_sy.ysyqts is '������������';
              comment on column dm_custbd_360_sy.ysyqts_grade is '�������������ȼ�';
                      comment on column dm_custbd_360_sy.ysyqcs is '�������ڴ���';
              comment on column dm_custbd_360_sy.ysyqcs_grade is '�������ڴ����ȼ�';
            comment on column dm_custbd_360_sy.credit_value is '�������ʱ�ǩ';
                comment on column dm_custbd_360_sy.rev_sale is '���۽��';
                    comment on column dm_custbd_360_sy.rev_sale_grade is '���۽��ȼ�';
                        comment on column dm_custbd_360_sy.stock_turnover is '�����ת��';
                            comment on column dm_custbd_360_sy.stock_turnover_grade is '�����ת�ʵȼ�';
                                comment on column dm_custbd_360_sy.profit_sale is '�������';
                                    comment on column dm_custbd_360_sy.profit_sale_grade is '�������ȼ�';
                                        comment on column dm_custbd_360_sy.profit_rate is '����������';
                                            comment on column dm_custbd_360_sy.profit_rate_grade is '���������ʵȼ�';
                                                comment on column dm_custbd_360_sy.sale_power is '����������ǩ';                                      
    
    
    
  ----------------------�ͻ�����ű�����---------------------------------------
   

