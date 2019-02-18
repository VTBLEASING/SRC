CREATE OR REPLACE PROCEDURE DM.P_UPLOAD_DM_AUTO (
    p_report_dt date,
    p_script_cd in number
)
is

--> for log
      vi_qty_row pls_integer;
      vd_begin   date;
      vd_end     date;
      cs_proc_name varchar2(50) := 'DM.P_UPLOAD_DM_AUTO';
--< for log
    	-- дата снепшота = отчетная дата (в апексе) - 1 день
      v_snapshot_dt date := trunc(to_date(p_report_dt,'dd.mm.yyyy'),'mm')-1;

BEGIN

  dm.u_log(p_proc => cs_proc_name,
           p_step => 'INPUT PARAMS',
           p_info => 'report_dt: ' || to_char(p_report_dt,'dd.mm.yyyy') || '; snapshot_dt: ' || to_char(v_snapshot_dt,'dd.mm.yyyy') || '; script_cd: '|| p_script_cd);

	-- удалим данные по дате снепшота и сценарию, если такие ранее уже были загружены
	vd_begin := sysdate;
  delete from DM.DM_PROFORM_ALLOWANCE_AUTO where snapshot_dt = v_snapshot_dt and script_cd = p_script_cd;
  vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'delete from DM.DM_PROFORM_ALLOWANCE_AUTO',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


	-- вставим по дате снепшота и сценарию все, что можем просто взять из связанных объектов
  vd_begin := sysdate;
  insert --+ append
  into dm.DM_PROFORM_ALLOWANCE_AUTO
  select v_snapshot_dt as SNAPSHOT_DT,
         t1.CONTRACT_APP_NUM,
         t1.presentation as CONTRACT_APP_ID_NUM,
         t1.ASSET_TYPE,
         case
           when t1.short_nam = 'FBG' then
            'ФБГ'
           else
            'ВТБЛ'
         end as COMP_NAM,
         t1.SHORT_NAM,
         t1.AUTO_FLG,
         t1.client_key as CLIENT_ID,
         t1.FULL_CLIENT_RU_NAM,
         t1.client_cis as SHORT_CLIENT_RU_NAM,
         t1.FLG_VTB_GROUP,
         t1.VTBL_FLG,
         t1.CONTRACT_NUM,
         t1.CONTRACT_NUM_FULL,
         t1.LEASING_SUBJECT as LEASING_SUBJECT_DESC,
         null as ASSET_TYPE_COL, --in merge
         null as LGD_SUBJECT_TYPE_CD, --in merge
         nvl(t1.TRANSFER_DT, t1.START_DT) as START_DT,
         t1.MATURITY_DT,
         t1.EFF_PRC_RATE,
         t1.currency_ru_nam as CURRENCY_LETTER_CD,
         t3.DEF_FLG,
         t4.DEF_SGN,
         decode(t3.DEFAULT_ATTR,
         	      'Отказ СК', 'отказ СК',
                'Неправомерные действия контрагентов','опер.риск',
                'Кредитный риск','кред.риск',
                null) as RISK_FLG,
         nvl(floor((v_snapshot_dt - trunc(t3.DATE_DEFAULT,'mm'))/30),0) as DEF_MIN_TIME,
         nvl2(t5.contract_app_key,1,0) as RED_FLG,
         t1.OVD_DAYS,
         nvl(nvl(t6.ovd_days, t7.days_overdue_3_month),0) as OVD_DAYS_3_MNTH,
         nvl(nvl(t8.ovd_days, t7.days_overdue_6_month),0) as OVD_DAYS_6_MNTH,
         nvl(nvl(t9.ovd_days, t7.days_overdue_9_month),0) as OVD_DAYS_9_MNTH,
         nvl(nvl(t10.ovd_days, t7.days_overdue_12_month),0) as OVD_DAYS_12_MNTH,
         case when nvl(nvl(t6.ovd_days, t7.days_overdue_3_month),0) > 0 then 1 else 0 end +
         case when nvl(nvl(t8.ovd_days, t7.days_overdue_6_month),0) > 0 then 1 else 0 end +
         case when nvl(nvl(t9.ovd_days, t7.days_overdue_9_month),0) > 0 then 1 else 0 end +
         case when nvl(nvl(t10.ovd_days, t7.days_overdue_12_month),0) > 0 then 1 else 0 end +
         case when nvl(t1.OVD_DAYS,0) > 0 then 1 else 0 end as OVD_TIMES,
         case when t3.DEF_FLG = 1 then 'Д'
              when t1.ovd_days = 0 then '0'
              when t1.ovd_days > 0 and t1.ovd_days <= 30 then '1'
              when t1.ovd_days > 30 and t1.ovd_days <= 60 then '2'
              when t1.ovd_days > 60 and t1.ovd_days <= 90 then '3'
              else null end as STATUS,
         null as STATUS_PREV_MNTH,--in merge
         null as STATUS_CHANGE,--in merge
         null as STATUS_QUARTER_BEGIN,--in merge
         null as STATUS_CHANGE_QUARTER_BEGIN,--in merge
         null as STATUS_YEAR_BEGIN,--in merge
         null as STATUS_CHANGE_YEAR_BEGIN,--in merge
         null as STAGE,--in merge
         null as STAGE_PREV_MNTH,--in merge
         null as STATUS_CHANGE_MNTH_BEGIN,--in merge
         null as STAGE_QUARTER_BEGIN,--in merge
         null as STAGE_CHANGE_QUARTER_BEGIN,--in merge
         null as STAGE_YEAR_BEGIN,--in merge
         null as STAGE_CHANGE_YEAR_BEGIN,--in merge
         null as PD1_TTC,--in merge
         null as PD1_PIT,--in merge
         null as PD2_TTC,--in merge
         null as PD3_TTC,--in merge
         null as PD4_TTC,--in merge
         null as PD5_TTC,--in merge
         null as PD6_TTC,--in merge
         null as PD7_TTC,--in merge
         null as PD8_TTC,--in merge
         null as PD9_TTC,--in merge
         null as PD10_TTC,--in merge
         null as PD1_MARG,--in merge
         null as PD2_MARG,--in merge
         null as PD3_MARG,--in merge
         null as PD4_MARG,--in merge
         null as PD5_MARG,--in merge
         null as PD6_MARG,--in merge
         null as PD7_MARG,--in merge
         null as PD8_MARG,--in merge
         null as PD9_MARG,--in merge
         null as PD10_MARG,--in merge
         nvl(t11.ECLS, 0) as ECLS,
         nvl(t11.ECLS1, 0) as ECLS1,
         t12.rate * t1.BALANCE_AMT as IND_RES,
         null as IS_RES_NULL,--in merge
         null as FINAL_RES,--in merge
         null as RES_PREV_MNTH,--in merge
         null as RES_CHANGE_MNTH_BEGIN,--in merge
         null as RES_QUARTER_BEGIN,--in merge
         null as RES_CHANGE_QUARTER_BEGIN,--in merge
         null as RES_YEAR_BEGIN,--in merge
         null as RES_CHANGE_YEAR_BEGIN,--in merge
         null as PL_MNTH_BEGIN_RUB,--in merge
         null as PL_QUARTER_BEGIN_RUB,--in merge
         null as PL_YEAR_BEGIN_RUB,--in merge
         null as RES_RUB,--in merge
         null as RES_PREV_MNTH_RUB,--in merge
         null as RES_CHANGE_MNTH_BEGIN_RUB,--in merge
         null as RES_QUARTER_BEGIN_RUB,--in merge
         null as RES_CHANGE_QUARTER_BEGIN_RUB,--in merge
         null as RES_YEAR_BEGIN_RUB,--in merge
         null as RES_CHANGE_YEAR_BEGIN_RUB,--in merge
         null as RATE,--in merge
         null as RATE_PREV_MNTH,--in merge
         null as RATE_QUARTER_BEGIN,--in merge
         null as RATE_YEAR_BEGIN,--in merge
         null as RATE_CHANGE_MNTH_BEGIN,--in merge
         null as RATE_CHANGE_QUARTER_BEGIN,--in merge
         null as RATE_CHANGE_YEAR_BEGIN,--in merge
         t1.balance_amt as EAD,
         null as EAD_PREV_MNTH,--in merge
         null as EAD_CHANGE_MNTH_BEGIN,--in merge
         null as EAD_QUARTER_BEGIN,--in merge
         null as EAD_CHANGE_QUARTER_BEGIN,--in merge
         null as EAD_YEAR_BEGIN,--in merge
         null as EAD_CHANGE_YEAR_BEGIN,--in merge
         t1.balance_amt_rub as EAD_RUB,
         null as EAD_PREV_MNTH_RUB,--in merge
         null as EAD_CHANGE_MNTH_BEGIN_RUB,--in merge
         null as EAD_QUARTER_BEGIN_RUB,--in merge
         null as EAD_CHANGE_QUARTER_BEGIN_RUB,--in merge
         null as EAD_YEAR_BEGIN_RUB,--in merge
         null as EAD_CHANGE_YEAR_BEGIN_RUB,--in merge
         t1.nil_wo_sa_rub as NIL_WO_SA,
         t1.overdue_amount_wo_sa_rub as OVERDUE_AMOUNT,
         null as IMPAIRMENT_CATEGORY,--in merge
         null as IMPAIRMENT_CATEGORY_PREV_MONTH,--in merge
         null as IMPAIRMENT_CATEGORY_CHANGE,--in merge
         null as CREDIT_LOSSES,--in merge
         null as CREDIT_LOSSES_PREV_MONTH,--in merge
         null as CREDIT_LOSSES_CHANGE,--in merge
         t1.closing_rate as CLOSING_RATE,
         t1.Average_Rate as AVERAGE_RATE,

         t1.CONTRACT_KEY,
         t1.CONTRACT_APP_KEY,
         p_script_cd as SCRIPT_CD,
         sysdate as INSERT_DTTM,
         null as PROCESS_KEY

    from DM.IFRS_BASE_TABLE t1
   inner join dwh.IFRS_LOAD_SCRIPT t2
      on t1.script_cd = t2.script_cd
    left outer join (select case when max(DATE_DEFAULT) keep(dense_rank first order by DATE_DEFAULT desc) < v_snapshot_dt and
                                      max(DATE_DEFAULT_CNCL) keep(dense_rank first order by DATE_DEFAULT desc) is null
                                   then 1
                                   else 0
                            end DEF_FLG,
                            /*Расчет признака риска есть в dwh.v_default_registry, но в нем нет ключа для связки, поэтому рассчитаем признак на основе dwh.v_default_registry_events в соответствии с алгоритмом:
                            CASE WHEN (S3.DATE_DEFAULT IS NOT NULL AND S3.DEFAULT_EVENT ='Отказ СК') OR
                                      (S3.DATE_DEFAULT IS NOT NULL AND S3.DEFAULT_EVENT ='Неправомерные действия контрагентов') THEN S3.DEFAULT_EVENT
                                 WHEN S3.DATE_DEFAULT IS NULL THEN NULL
                                 ELSE 'Кредитный риск' END AS DEFAULT_ATTR*/
                            case when max(DEFAULT_EVENT) keep(dense_rank first order by DATE_DEFAULT desc) in ('Отказ СК', 'Неправомерные действия контрагентов')
                                   then max(DEFAULT_EVENT) keep(dense_rank first order by DATE_DEFAULT desc)
                                   else 'Кредитный риск'
                            end DEFAULT_ATTR,
                            max(DATE_DEFAULT) keep(dense_rank first order by DATE_DEFAULT desc) DATE_DEFAULT,
                            contract_app_key
                       from dwh.v_default_registry_events
                      where DATE_DEFAULT is not null
                        and DATE_DEFAULT < v_snapshot_dt
                      group by contract_app_key) t3
      on t1.contract_app_key = t3.contract_app_key
    left outer join (select max("DefaultSign") keep(dense_rank first order by dt desc) as DEF_SGN,
                            client_key
                       from dwh.default_sign
                      where dt <= v_snapshot_dt
                        and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                        --пустая дата указывает, что в 1С информация по ключевой сущности была удалена
                        and dt != to_date('01.01.0001', 'dd.mm.yyyy')
                      group by client_key) t4
      on t1.client_key = t4.client_key
    left outer join DWH.IFRS_REDEMPTION_CONTRACTS t5
      on t1.contract_app_key = t5.contract_app_key
     and t5.snapshot_dt = v_snapshot_dt
     and t5.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    left outer join DWH.RISK_IFRS_CGP t6
      on t6.SNAPSHOT_DT = add_months(v_snapshot_dt, -3)
     and t1.contract_app_key = t6.contract_app_key
     and t6.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
    left outer join DWH.AUTO_STAGING t7
      on t1.contract_app_key = t7.contract_app_key
     and t7.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
    left outer join DWH.RISK_IFRS_CGP t8
      on t8.SNAPSHOT_DT = add_months(v_snapshot_dt, -6)
     and t1.contract_app_key = t8.contract_app_key
     and t8.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
    left outer join DWH.RISK_IFRS_CGP t9
      on t9.SNAPSHOT_DT = add_months(v_snapshot_dt, -9)
     and t1.contract_app_key = t9.contract_app_key
     and t9.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
    left outer join DWH.RISK_IFRS_CGP t10
      on t10.SNAPSHOT_DT = add_months(v_snapshot_dt, -12)
     and t1.contract_app_key = t10.contract_app_key
     and t10.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
    left outer join (select contract_app_key,
                            sum(PDint * EAD_FLI * DF_ * LGD_avto) as ECLS,
                            sum(case
                                  when snapshot_dt <= add_months(v_snapshot_dt, 12) then PDint * EAD_FLI * DF_ * LGD_avto else 0
                                end) as ECLS1
                       from dm.IFRS_NIL_FLI
                      where snapshot_dt > v_snapshot_dt
                        and script_cd = p_script_cd
                      group by contract_app_key) t11
      on t1.contract_app_key = t11.contract_app_key /*and t1.snapshot_dt = t11.snapshot_dt and t1.script_cd = t11.script_cd*/
    left outer join DWH.IFRS_APP_RATE t12
      on t1.contract_app_key = t12.contract_app_key
     and t12.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')

   where t1.snapshot_dt = v_snapshot_dt
     and t1.script_cd = p_script_cd
     --для корпоратов должно выбираться только с флагом = 0, для автолизинга - только с флагом = 1
     and t1.auto_flg = 1;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'insert into DM.DM_PROFORM_ALLOWANCE_AUTO',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


	-- досчитаем атрибуты
  -- последовательность расчета атрибутов важна, т.к. есть зависимости атрибутов друг от друга

  vd_begin := sysdate;
    ----STAGE----depend on OVD_TIMES
    update dm.DM_PROFORM_ALLOWANCE_AUTO
       set STAGE = case when def_flg = 1 then 3
                        when (ovd_days > 30 or OVD_TIMES > 2) then 2
                        else 1 end
     where SNAPSHOT_DT = v_snapshot_dt and script_cd = p_script_cd;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_AUTO. Update_1',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----ASSET_TYPE_COL----
    ----LGD_SUBJECT_TYPE_CD----depend on STAGE, RED_FLG, RISK_FLG
    merge into dm.DM_PROFORM_ALLOWANCE_AUTO tm
    using (select t1.contract_app_key,
                  t1.SNAPSHOT_DT,
                  t1.script_cd,
                  t5.deal_type as ASSET_TYPE_COL,
                  case when (t1.STAGE = 1 or t1.STAGE = 2) then nvl(t5.lgd, 17.8)
                       when t1.STAGE = 3 and t1.RED_FLG = 0 and t1.NIL_WO_SA = 0 then 100
                       when t1.STAGE = 3 and t1.RISK_FLG = 'кред.риск' then t6.CREDIT_RISK_RR
                       when t1.STAGE = 3 and t1.RISK_FLG <>'кред.риск' then t6.OPER_RISK_RR
                      else 0 end LGD_SUBJECT_TYPE_CD
             from DM.DM_PROFORM_ALLOWANCE_AUTO t1
             left outer join dwh.leasing_contracts t2
               on t1.contract_key = t2.contract_key and t2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
             left outer join dwh.crm_leasing_contracts t3
               on t2.crm_contract_cd = t3.crm_contract_cd and t3.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
             left outer join dwh.leasing_offers t4
               on t3.leasing_offer_key = t4.leasing_offer_key and t4.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
             left outer join dwh.rr_lgd_12 t5
               on case when t4.product_nam = 'Такси+' then 'Такси' else t4.product_nam end = t5.deal_type and t5.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
             left outer join (select tt2.CREDIT_RISK_RR, tt2.OPER_RISK_RR, tt1.contract_app_key
                                from (select floor(months_between(v_snapshot_dt, max(DATE_DEFAULT) keep(dense_rank first order by DATE_DEFAULT))) as mnth_cnt,
                                                   contract_app_key
                                              from dwh.v_default_registry_events
                                             where DATE_DEFAULT is not null
                                               and DATE_DEFAULT < v_snapshot_dt
                                             group by contract_app_key) tt1
                                      left outer join dwh.rr_lgd_3 tt2
                                        on case when tt1.mnth_cnt >= 19 then 19
                                                when tt1.mnth_cnt < 19 then tt1.mnth_cnt end = tt2.min_time) t6
               on t1.contract_app_key = t6.contract_app_key
            where t1.snapshot_dt = v_snapshot_dt
              and t1.script_cd = p_script_cd) ts
    on (tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.script_cd = ts.script_cd)
    when matched then
      update
         set tm.ASSET_TYPE_COL 		    = ts.asset_type_col,
             tm.LGD_SUBJECT_TYPE_CD   = ts.lgd_subject_type_cd;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_AUTO. Merge_2',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----PD_%----depend on DEF_FLG, STATUS (for join)
     merge into dm.DM_PROFORM_ALLOWANCE_AUTO tm
      using (select t1.contract_app_key,
                    t1.SNAPSHOT_DT,
                    t1.script_cd,
                    regexp_replace(round(t2.d *100,2) || '%','^,','0,') as PD1_TTC,
                    regexp_replace(round(t2.d_macro *100,2) || '%','^,','0,') as PD1_PIT,
                    regexp_replace(round(t2.pd2_ttc *100,2) || '%','^,','0,') as PD2_TTC,
                    regexp_replace(round(t2.pd3_ttc *100,2) || '%','^,','0,') as PD3_TTC,
                    regexp_replace(round(t2.pd4_ttc *100,2) || '%','^,','0,') as PD4_TTC,
                    regexp_replace(round(t2.pd5_ttc *100,2) || '%','^,','0,') as PD5_TTC,
                    regexp_replace(round(t2.pd6_ttc *100,2) || '%','^,','0,') as PD6_TTC,
                    regexp_replace(round(t2.pd7_ttc *100,2) || '%','^,','0,') as PD7_TTC,
                    regexp_replace(round(t2.pd8_ttc *100,2) || '%','^,','0,') as PD8_TTC,
                    regexp_replace(round(t2.pd9_ttc *100,2) || '%','^,','0,') as PD9_TTC,
                    regexp_replace(round(t2.pd10_ttc *100,2) || '%','^,','0,') as PD10_TTC,
                    regexp_replace(round(t2.d_macro *100,2) || '%','^,','0,') as PD1_MARG,
                    regexp_replace(round(Case when t1.DEF_FLG = 1 then t2.d_macro else (t2.PD2_TTC - t2.d_macro) end *100,2) || '%','^,','0,') PD2_MARG,
                    regexp_replace(round(Case when t1.DEF_FLG = 1 then t2.d_macro else (t2.PD3_TTC - t2.PD2_TTC) end *100,2) || '%','^,','0,') PD3_MARG,
                    regexp_replace(round(Case when t1.DEF_FLG = 1 then t2.d_macro else (t2.PD4_TTC - t2.PD3_TTC) end *100,2) || '%','^,','0,') PD4_MARG,
                    regexp_replace(round(Case when t1.DEF_FLG = 1 then t2.d_macro else (t2.PD5_TTC - t2.PD4_TTC) end *100,2) || '%','^,','0,') PD5_MARG,
                    regexp_replace(round(Case when t1.DEF_FLG = 1 then t2.d_macro else (t2.PD6_TTC - t2.PD5_TTC) end *100,2) || '%','^,','0,') PD6_MARG,
                    regexp_replace(round(Case when t1.DEF_FLG = 1 then t2.d_macro else (t2.PD7_TTC - t2.PD6_TTC) end *100,2) || '%','^,','0,') PD7_MARG,
                    regexp_replace(round(Case when t1.DEF_FLG = 1 then t2.d_macro else (t2.PD8_TTC - t2.PD7_TTC) end *100,2) || '%','^,','0,') PD8_MARG,
                    regexp_replace(round(Case when t1.DEF_FLG = 1 then t2.d_macro else (t2.PD9_TTC - t2.PD8_TTC) end *100,2) || '%','^,','0,') PD9_MARG,
                    regexp_replace(round(Case when t1.DEF_FLG = 1 then t2.d_macro else (t2.PD10_TTC - t2.PD9_TTC) end *100,2) || '%','^,','0,') PD10_MARG
                from DM.DM_PROFORM_ALLOWANCE_AUTO t1
                inner join DWH.IFRS_PD_AVTO t2
                on trim(t2.bunch_client_status) = t1.status
               where t1.snapshot_dt = v_snapshot_dt
                 and t1.script_cd = p_script_cd
                 and t2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) ts
      on (tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.script_cd = ts.script_cd)
      when matched then
        update
           set tm.PD1_TTC  = ts.PD1_TTC,
               tm.PD1_PIT  = ts.PD1_PIT,
               tm.PD2_TTC  = ts.PD2_TTC,
               tm.PD3_TTC  = ts.PD3_TTC,
               tm.PD4_TTC  = ts.PD4_TTC,
               tm.PD5_TTC  = ts.PD5_TTC,
               tm.PD6_TTC  = ts.PD6_TTC,
               tm.PD7_TTC  = ts.PD7_TTC,
               tm.PD8_TTC  = ts.PD8_TTC,
               tm.PD9_TTC  = ts.PD9_TTC,
               tm.PD10_TTC = ts.PD10_TTC,
               tm.PD1_MARG = ts.PD1_MARG,
               tm.PD2_MARG = ts.PD2_MARG,
               tm.PD3_MARG = ts.PD3_MARG,
               tm.PD4_MARG = ts.PD4_MARG,
               tm.PD5_MARG = ts.PD5_MARG,
               tm.PD6_MARG = ts.PD6_MARG,
               tm.PD7_MARG = ts.PD7_MARG,
               tm.PD8_MARG = ts.PD8_MARG,
               tm.PD9_MARG = ts.PD9_MARG,
               tm.PD10_MARG = ts.PD10_MARG;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_AUTO. Merge_3',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----FINAL_RES----depend on STAGE
    ----IS_RES_NULL----depend on STAGE
    ----IMPAIRMENT_CATEGORY----
    ----CREDIT_LOSSES----depend on STAGE
    update dm.DM_PROFORM_ALLOWANCE_AUTO
       set FINAL_RES = CASE
                         WHEN FLG_VTB_GROUP = 'Yes' THEN -0.03 * EAD
                         WHEN STAGE = '1' THEN ECLS1
                         WHEN STAGE = '2' THEN ECLS
                         WHEN STAGE = '3' THEN -1* LGD_SUBJECT_TYPE_CD * EAD
                       end,
           IS_RES_NULL = CASE
                           WHEN (CASE
                                    WHEN FLG_VTB_GROUP = 'Yes' THEN -0.03 * EAD
                                    WHEN STAGE = '1' THEN ECLS1
                                    WHEN STAGE = '2' THEN ECLS
                                    WHEN STAGE = '3' THEN -1* LGD_SUBJECT_TYPE_CD * EAD
                                  end) = 0 THEN 'ДА, # ошибка'
                           ELSE 'НЕТ'
                         end,
           IMPAIRMENT_CATEGORY = case
                                   when def_flg = 1 then
                                    case
                                      when OVD_DAYS = 0 then
                                       'High risk'
                                      else
                                       case
                                         when OVD_DAYS <= 90 then
                                          'Default - non-NPL'
                                         else
                                          'Default - NPL'
                                       end
                                    end
                                   else
                                    case
                                      when PD1_MARG > 9.16 then
                                       'High risk'
                                      else
                                       case
                                         when def_flg = 0 then
                                          case
                                            when PD1_MARG < 6.26 then
                                             'Low risk'
                                            else
                                             'Acceptable risk'
                                          end
                                         else
                                          'нет категории'
                                       end
                                    end
                                 end,
           CREDIT_LOSSES = case
                            when stage = 2 then 'Not credit-impaired lifetime'
                            when stage = 1 then '12-month'
                            when stage = 3 then 'Credit-impaired lifetime'
                            when stage = 'POCI' then 'Purchased credit-impaired'
                           else '0'
                           end
     where SNAPSHOT_DT = v_snapshot_dt and script_cd = p_script_cd;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_AUTO. Update_4',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----STATUS_PREV_MNTH----
    ----STAGE_PREV_MNTH----
    ----RES_PREV_MNTH----
    ----RES_PREV_MNTH_RUB----
    ----RATE_PREV_MNTH----
    ----EAD_PREV_MNTH----
    ----EAD_PREV_MNTH_RUB----
    ----IMPAIRMENT_CATEGORY_PREV_MONTH----
    ----CREDIT_LOSSES_PREV_MONTH----
     merge into dm.DM_PROFORM_ALLOWANCE_AUTO tm
      using (select t1.contract_app_key,
                    t1.SNAPSHOT_DT,
                    t1.script_cd,
                    case when t1.DEF_FLG = 1 then 'Д'
                         when t2.ovd_days = 0 then '0'
                         when t2.ovd_days > 0 and t2.ovd_days <= 30 then '1'
                         when t2.ovd_days > 30 and t2.ovd_days <= 60 then '2'
                         when t2.ovd_days > 60 and t2.ovd_days <= 90 then '3'
                         else null end as STATUS_PREV_MNTH,
                    case when t2.credit_loss = 'Not credit-impaired lifetime' then '2'
                         when t2.credit_loss = '12-month' then '1'
                         when t2.credit_loss = 'Credit-impaired lifetime' then '3'
                         when t2.credit_loss = 'Purchased credit-impaired' then 'POCI'
                         else '0' end STAGE_PREV_MNTH,
                    t2.provisions_amt/t1.closing_rate as RES_PREV_MNTH,
                    t2.provisions_amt as RES_PREV_MNTH_RUB,
                    t2.rate_allow as RATE_PREV_MNTH,
                    t2.balance_amt/t1.closing_rate as EAD_PREV_MNTH,
                    t2.balance_amt as EAD_PREV_MNTH_RUB,
                    t2.impairment_type as IMPAIRMENT_CATEGORY_PREV_MONTH,
                    t2.credit_loss as CREDIT_LOSSES_PREV_MONTH
                from DM.DM_PROFORM_ALLOWANCE_AUTO t1
                inner join DWH.RISK_IFRS_CGP t2
                on t2.SNAPSHOT_DT = add_months(t1.snapshot_dt, -1) and t2.contract_app_key = t1.contract_app_key
               where t1.snapshot_dt = v_snapshot_dt
                 and t1.script_cd = p_script_cd
                 and t2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) ts
      on (tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.script_cd = ts.script_cd)
      when matched then
        update
           set tm.STATUS_PREV_MNTH 	             = ts.STATUS_PREV_MNTH,
               tm.STAGE_PREV_MNTH                = ts.STAGE_PREV_MNTH,
               tm.RES_PREV_MNTH                  = ts.RES_PREV_MNTH,
               tm.RES_PREV_MNTH_RUB              = ts.RES_PREV_MNTH_RUB,
               tm.RATE_PREV_MNTH                 = ts.RATE_PREV_MNTH,
               tm.EAD_PREV_MNTH                  = ts.EAD_PREV_MNTH,
               tm.EAD_PREV_MNTH_RUB              = ts.EAD_PREV_MNTH_RUB,
               tm.IMPAIRMENT_CATEGORY_PREV_MONTH = ts.IMPAIRMENT_CATEGORY_PREV_MONTH,
               tm.CREDIT_LOSSES_PREV_MONTH       = ts.CREDIT_LOSSES_PREV_MONTH;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_AUTO. Merge_5',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----STATUS_QUARTER_BEGIN----
    ----STAGE_QUARTER_BEGIN----
    ----RES_QUARTER_BEGIN----
    ----RES_QUARTER_BEGIN_RUB----
    ----RATE_QUARTER_BEGIN----
    ----EAD_QUARTER_BEGIN----
    ----EAD_QUARTER_BEGIN_RUB----
     merge into dm.DM_PROFORM_ALLOWANCE_AUTO tm
      using (select t1.contract_app_key,
                    t1.SNAPSHOT_DT,
                    t1.script_cd,
                    case when t1.DEF_FLG = 1 then 'Д'
                         when t2.ovd_days = 0 then '0'
                         when t2.ovd_days > 0 and t2.ovd_days <= 30 then '1'
                         when t2.ovd_days > 30 and t2.ovd_days <= 60 then '2'
                         when t2.ovd_days > 60 and t2.ovd_days <= 90 then '3'
                         else null end as STATUS_QUARTER_BEGIN,
                    case when t2.credit_loss = 'Not credit-impaired lifetime' then '2'
                         when t2.credit_loss = '12-month' then '1'
                         when t2.credit_loss = 'Credit-impaired lifetime' then '3'
                         when t2.credit_loss = 'Purchased credit-impaired' then 'POCI'
                         else '0' end STAGE_QUARTER_BEGIN,
                    t2.provisions_amt/t1.closing_rate as RES_QUARTER_BEGIN,
                    t2.provisions_amt as RES_QUARTER_BEGIN_RUB,
                    t2.rate_allow as RATE_QUARTER_BEGIN,
                    t2.balance_amt/t1.closing_rate as EAD_QUARTER_BEGIN,
                    t2.balance_amt as EAD_QUARTER_BEGIN_RUB
                from DM.DM_PROFORM_ALLOWANCE_AUTO t1
                inner join DWH.RISK_IFRS_CGP t2
                on t2.SNAPSHOT_DT = trunc(t1.snapshot_dt, 'Q')-1 and t2.contract_app_key = t1.contract_app_key
               where t1.snapshot_dt = v_snapshot_dt
                 and t1.script_cd = p_script_cd
                 and t2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) ts
      on (tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.script_cd = ts.script_cd)
      when matched then
        update
           set tm.STATUS_QUARTER_BEGIN 	= ts.STATUS_QUARTER_BEGIN,
               tm.STAGE_QUARTER_BEGIN   = ts.STAGE_QUARTER_BEGIN,
               tm.RES_QUARTER_BEGIN     = ts.RES_QUARTER_BEGIN,
               tm.RES_QUARTER_BEGIN_RUB = ts.RES_QUARTER_BEGIN_RUB,
               tm.RATE_QUARTER_BEGIN    = ts.RATE_QUARTER_BEGIN,
               tm.EAD_QUARTER_BEGIN     = ts.EAD_QUARTER_BEGIN,
               tm.EAD_QUARTER_BEGIN_RUB = ts.EAD_QUARTER_BEGIN_RUB;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_AUTO. Merge_6',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----STATUS_YEAR_BEGIN----
    ----STAGE_YEAR_BEGIN----
    ----RES_YEAR_BEGIN----
    ----RES_YEAR_BEGIN_RUB----
    ----RATE_YEAR_BEGIN----
    ----EAD_YEAR_BEGIN----
    ----EAD_YEAR_BEGIN_RUB----
     merge into dm.DM_PROFORM_ALLOWANCE_AUTO tm
      using (select t1.contract_app_key,
                    t1.SNAPSHOT_DT,
                    t1.script_cd,
                    case when t1.DEF_FLG = 1 then 'Д'
                         when t2.ovd_days = 0 then '0'
                         when t2.ovd_days > 0 and t2.ovd_days <= 30 then '1'
                         when t2.ovd_days > 30 and t2.ovd_days <= 60 then '2'
                         when t2.ovd_days > 60 and t2.ovd_days <= 90 then '3'
                         else null end as STATUS_YEAR_BEGIN,
                    case when t2.credit_loss = 'Not credit-impaired lifetime' then '2'
                         when t2.credit_loss = '12-month' then '1'
                         when t2.credit_loss = 'Credit-impaired lifetime' then '3'
                         when t2.credit_loss = 'Purchased credit-impaired' then 'POCI'
                         else '0' end STAGE_YEAR_BEGIN,
                    t2.provisions_amt/t1.closing_rate as RES_YEAR_BEGIN,
                    t2.provisions_amt as RES_YEAR_BEGIN_RUB,
                    t2.rate_allow as RATE_YEAR_BEGIN,
                    t2.balance_amt/t1.closing_rate as EAD_YEAR_BEGIN,
                    t2.balance_amt as EAD_YEAR_BEGIN_RUB
                from DM.DM_PROFORM_ALLOWANCE_AUTO t1
                inner join DWH.RISK_IFRS_CGP t2
                on t2.SNAPSHOT_DT = LAST_DAY(ADD_MONTHS(TRUNC(TRUNC(t1.snapshot_dt,'Year')-1,'Year'),11)) and t2.contract_app_key = t1.contract_app_key
               where t1.snapshot_dt = v_snapshot_dt
                 and t1.script_cd = p_script_cd
                 and t2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) ts
      on (tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.script_cd = ts.script_cd)
      when matched then
        update
           set tm.STATUS_YEAR_BEGIN 	= ts.STATUS_YEAR_BEGIN,
               tm.STAGE_YEAR_BEGIN    = ts.STAGE_YEAR_BEGIN,
               tm.RES_YEAR_BEGIN      = ts.RES_YEAR_BEGIN,
               tm.RES_YEAR_BEGIN_RUB  = ts.RES_YEAR_BEGIN_RUB,
               tm.RATE_YEAR_BEGIN     = ts.RATE_YEAR_BEGIN,
               tm.EAD_YEAR_BEGIN      = ts.EAD_YEAR_BEGIN,
               tm.EAD_YEAR_BEGIN_RUB  = ts.EAD_YEAR_BEGIN_RUB;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_AUTO. Merge_7',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----STATUS_CHANGE----depend on STATUS, STATUS_PREV_MNTH
    ----STATUS_CHANGE_QUARTER_BEGIN----depend on STATUS, STATUS_QUARTER_BEGIN
    ----STATUS_CHANGE_YEAR_BEGIN----depend on STATUS, STATUS_YEAR_BEGIN
    ----STATUS_CHANGE_MNTH_BEGIN----depend on STAGE, STAGE_PREV_MNTH
    ----STAGE_CHANGE_QUARTER_BEGIN----depend on STAGE, STAGE_QUARTER_BEGIN
    ----STAGE_CHANGE_YEAR_BEGIN----depend on STAGE, STAGE_YEAR_BEGIN
    ----
    ----RES_CHANGE_MNTH_BEGIN----depend on FINAL_RES, RES_PREV_MNTH
    ----RES_CHANGE_QUARTER_BEGIN----depend on FINAL_RES, RES_QUARTER_BEGIN
    ----RES_CHANGE_YEAR_BEGIN----depend on FINAL_RES, RES_YEAR_BEGIN
    ----RES_RUB----depend on FINAL_RES
    ----RES_CHANGE_MNTH_BEGIN_RUB----depend on RES_RUB, RES_PREV_MNTH_RUB
    ----RES_CHANGE_QUARTER_BEGIN_RUB----depend on RES_RUB, RES_QUARTER_BEGIN_RUB
    ----RES_CHANGE_YEAR_BEGIN_RUB----depend on RES_RUB, RES_YEAR_BEGIN_RUB
    ----
    ----RATE----depend on FINAL_RES
    ----RATE_CHANGE_MNTH_BEGIN----depend on RATE, RATE_PREV_MNTH
    ----RATE_CHANGE_QUARTER_BEGIN----depend on RATE, RATE_QUARTER_BEGIN
    ----RATE_CHANGE_YEAR_BEGIN----depend on RATE, RATE_YEAR_BEGIN
    ----
    ----EAD_CHANGE_MNTH_BEGIN----depend on EAD_PREV_MNTH
    ----EAD_CHANGE_QUARTER_BEGIN----depend on EAD_QUARTER_BEGIN
    ----EAD_CHANGE_YEAR_BEGIN----depend on EAD_YEAR_BEGIN
    ----EAD_CHANGE_MNTH_BEGIN_RUB----depend on EAD_PREV_MNTH_RUB
    ----EAD_CHANGE_QUARTER_BEGIN_RUB----depend on EAD_QUARTER_BEGIN_RUB
    ----EAD_CHANGE_YEAR_BEGIN_RUB----depend on EAD_YEAR_BEGIN_RUB
    ----
    ----IMPAIRMENT_CATEGORY_CHANGE----depend on IMPAIRMENT_CATEGORY_PREV_MONTH
    ----CREDIT_LOSSES_CHANGE----depend on CREDIT_LOSSES_PREV_MONTH
    update dm.DM_PROFORM_ALLOWANCE_AUTO
       set STATUS_CHANGE                = case when STATUS_PREV_MNTH is null then STATUS
                                               when STATUS is null then STATUS_PREV_MNTH || '-> выбыл'
                                               else STATUS_PREV_MNTH || '->' || STATUS end,
           STATUS_CHANGE_QUARTER_BEGIN  = case when STATUS_QUARTER_BEGIN is null then STATUS
                                               when STATUS is null then STATUS_QUARTER_BEGIN || '-> выбыл'
                                               else STATUS_QUARTER_BEGIN || '->' || STATUS end,
           STATUS_CHANGE_YEAR_BEGIN  	  = case when STATUS_YEAR_BEGIN is null then STATUS
                                               when STATUS is null then STATUS_YEAR_BEGIN || '-> выбыл'
                                               else STATUS_YEAR_BEGIN || '->' || STATUS end,
           STATUS_CHANGE_MNTH_BEGIN	    = case when STAGE_PREV_MNTH is null then STAGE
                                               when STAGE is null then STAGE_PREV_MNTH || '-> выбыл'
                                               else STAGE_PREV_MNTH || '->' || STAGE end,
           STAGE_CHANGE_QUARTER_BEGIN	  = case when STAGE_QUARTER_BEGIN is null then STAGE
                                               when STAGE is null then STAGE_QUARTER_BEGIN || '-> выбыл'
                                               else STAGE_QUARTER_BEGIN || '->' || STAGE end,
           STAGE_CHANGE_YEAR_BEGIN	    = case when STAGE_YEAR_BEGIN is null then STAGE
                                               when STAGE is null then STAGE_YEAR_BEGIN || '-> выбыл'
                                               else STAGE_YEAR_BEGIN || '->' || STAGE end,
           ----
           RES_CHANGE_MNTH_BEGIN   	 	  = FINAL_RES - RES_PREV_MNTH,
           RES_CHANGE_QUARTER_BEGIN     = FINAL_RES - RES_QUARTER_BEGIN,
           RES_CHANGE_YEAR_BEGIN        = FINAL_RES -  RES_YEAR_BEGIN,
           RES_RUB                      = FINAL_RES * CLOSING_RATE,
           RES_CHANGE_MNTH_BEGIN_RUB    = /*RES_RUB*/FINAL_RES * CLOSING_RATE - RES_PREV_MNTH_RUB,
           RES_CHANGE_QUARTER_BEGIN_RUB = /*RES_RUB*/FINAL_RES * CLOSING_RATE - RES_QUARTER_BEGIN_RUB,
           RES_CHANGE_YEAR_BEGIN_RUB    = /*RES_RUB*/FINAL_RES * CLOSING_RATE - RES_YEAR_BEGIN_RUB,
           ----
           RATE                         = FINAL_RES / EAD,
           RATE_CHANGE_MNTH_BEGIN       = /*RATE*/FINAL_RES / EAD - RATE_PREV_MNTH,
           RATE_CHANGE_QUARTER_BEGIN    = /*RATE*/FINAL_RES / EAD - RATE_QUARTER_BEGIN,
           RATE_CHANGE_YEAR_BEGIN       = /*RATE*/FINAL_RES / EAD - RATE_YEAR_BEGIN,
           ----
           EAD_CHANGE_MNTH_BEGIN        = EAD - EAD_PREV_MNTH,
           EAD_CHANGE_QUARTER_BEGIN     = EAD - EAD_QUARTER_BEGIN,
           EAD_CHANGE_YEAR_BEGIN        = EAD - EAD_YEAR_BEGIN,
           EAD_CHANGE_MNTH_BEGIN_RUB    = EAD_RUB - EAD_PREV_MNTH_RUB,
           EAD_CHANGE_QUARTER_BEGIN_RUB = EAD_RUB - EAD_QUARTER_BEGIN_RUB,
           EAD_CHANGE_YEAR_BEGIN_RUB    = EAD_RUB - EAD_YEAR_BEGIN_RUB,
           ----
           IMPAIRMENT_CATEGORY_CHANGE	  = case when IMPAIRMENT_CATEGORY = IMPAIRMENT_CATEGORY_PREV_MONTH then 'Изменений нет'
                                               else IMPAIRMENT_CATEGORY_PREV_MONTH || '->' || IMPAIRMENT_CATEGORY end,
           CREDIT_LOSSES_CHANGE	    	  = case when CREDIT_LOSSES = CREDIT_LOSSES_PREV_MONTH then 'Изменений нет'
                                               else CREDIT_LOSSES_PREV_MONTH || '->' || CREDIT_LOSSES end
     where SNAPSHOT_DT = v_snapshot_dt and script_cd = p_script_cd;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_AUTO. Update_8',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----PL_MNTH_BEGIN_RUB----depend on FINAL_RES, RES_QUARTER_BEGIN, PL_MNTH_BEGIN_RUB(prev monthes in quart)
    ----PL_QUARTER_BEGIN_RUB----depend on FINAL_RES, RES_QUARTER_BEGIN
    merge into dm.DM_PROFORM_ALLOWANCE_AUTO tm
    using (select t1.contract_app_key, t1.SNAPSHOT_DT, nvl(t2.pl_mnth_begin_rub,0) as pl_mnth_begin_rub
             from dm.DM_PROFORM_ALLOWANCE_CORP t1
             left outer join (select contract_app_key,
                                    sum(coalesce(b, a, t)) as pl_mnth_begin_rub
                               from (select contract_app_key,
                                            script_cd,
                                            SNAPSHOT_DT,
                                            nvl(pl_mnth_begin_rub, 0) as pl_mnth_begin_rub
                                       from dm.DM_PROFORM_ALLOWANCE_AUTO
                                      where trunc(SNAPSHOT_DT, 'Q') = trunc(v_snapshot_dt,'Q')
                                        and SNAPSHOT_DT < v_snapshot_dt)
                                        pivot(max(pl_mnth_begin_rub) for(script_cd) in (3 as B, 2 as A, 1 as T))
                              group by contract_app_key) t2
               on t1.contract_app_key = t2.contract_app_key
            where t1.SNAPSHOT_DT = v_snapshot_dt
              and t1.script_cd = p_script_cd) ts
    on (tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.SNAPSHOT_DT = v_snapshot_dt and tm.script_cd = p_script_cd)
    when matched then
      update set tm.pl_mnth_begin_rub    = (tm.FINAL_RES - tm.RES_QUARTER_BEGIN) * tm.AVERAGE_RATE - ts.pl_mnth_begin_rub,
                 tm.PL_QUARTER_BEGIN_RUB = (tm.FINAL_RES - tm.RES_QUARTER_BEGIN) * tm.AVERAGE_RATE;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_AUTO. Merge_9',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----PL_YEAR_BEGIN_RUB----depend on PL_QUARTER_BEGIN_RUB
    merge into dm.DM_PROFORM_ALLOWANCE_AUTO tm
    using (select t1.contract_app_key, t1.SNAPSHOT_DT, nvl(t2.pl_year_begin_rub,0) as pl_year_begin_rub
             from dm.DM_PROFORM_ALLOWANCE_CORP t1
             left outer join (select contract_app_key,
                                    sum(coalesce(b, a, t)) as pl_year_begin_rub
                               from (select contract_app_key,
                                            script_cd,
                                            SNAPSHOT_DT,
                                            nvl(pl_year_begin_rub, 0) as pl_year_begin_rub
                                       from dm.DM_PROFORM_ALLOWANCE_AUTO
                                      where SNAPSHOT_DT = last_day(trunc(trunc(v_snapshot_dt,'Q')-1,'Q')))
                                        pivot(max(pl_year_begin_rub) for(script_cd) in (3 as B, 2 as A, 1 as T))
                              group by contract_app_key) t2
               on t1.contract_app_key = t2.contract_app_key
            where t1.SNAPSHOT_DT = v_snapshot_dt
              and t1.script_cd = p_script_cd) ts
    on (tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.SNAPSHOT_DT = v_snapshot_dt and tm.script_cd = p_script_cd)
    when matched then
      update set tm.PL_YEAR_BEGIN_RUB = ts.PL_YEAR_BEGIN_RUB + tm.PL_QUARTER_BEGIN_RUB;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_AUTO. Merge_10',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


   -- сбор статистики по окончании расчета
   dm.analyze_table(p_table_name => 'DM_PROFORM_ALLOWANCE_AUTO',p_schema => 'DM');

   dm.u_log(p_proc => cs_proc_name,
           p_step => 'analyze_table DM.DM_PROFORM_ALLOWANCE_AUTO',
           p_info => 'analyze_table done');

  etl.P_DM_LOG('DM_PROFORM_ALLOWANCE_AUTO');
    exception
    when others then
      dm.u_log(p_proc => cs_proc_name,
               p_step => '',
               p_info => sqlerrm || chr(10) || '##' ||
                                                chr(10) ||
                                                dbms_utility.format_error_stack ||
                                                chr(10) || '##' || chr(10) ||
                                                dbms_utility.format_call_stack ||
                                                chr(10) || '##' || chr(10) ||
                                                dbms_utility.format_error_backtrace);
      raise;
END;
/

