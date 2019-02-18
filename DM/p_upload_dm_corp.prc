CREATE OR REPLACE PROCEDURE DM.P_UPLOAD_DM_CORP (
    p_report_dt date,
    p_script_cd in number
)
is

--> for log
      vi_qty_row pls_integer;
      vd_begin   date;
      vd_end     date;
      cs_proc_name varchar2(50) := 'DM.P_UPLOAD_DM_CORP';
--< for log
    	-- дата снепшота = отчетная дата (в апексе) - 1 день
      v_snapshot_dt date := trunc(to_date(p_report_dt,'dd.mm.yyyy'),'mm')-1;

BEGIN

  dm.u_log(p_proc => cs_proc_name,
           p_step => 'INPUT PARAMS',
           p_info => 'report_dt: ' || to_char(p_report_dt,'dd.mm.yyyy') || '; snapshot_dt: ' || to_char(v_snapshot_dt,'dd.mm.yyyy') || '; script_cd: '|| p_script_cd);

	-- удалим данные по дате снепшота и сценарию, если такие ранее уже были загружены
	vd_begin := sysdate;
  delete from DM.DM_PROFORM_ALLOWANCE_CORP where snapshot_dt = v_snapshot_dt and script_cd = p_script_cd;
  vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'delete from DM.DM_PROFORM_ALLOWANCE_CORP',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


	-- вставим по дате снепшота и сценарию все, что можем просто взять из связанных объектов
  vd_begin := sysdate;
  insert --+ append
  into dm.DM_PROFORM_ALLOWANCE_CORP
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
         t5.name as ASSET_TYPE_COL,
         t7.lgd as LGD_SUBJECT_TYPE_CD,
         nvl(t1.TRANSFER_DT, t1.START_DT) as START_DT,
         t1.MATURITY_DT,
         t1.EFF_PRC_RATE,
         t1.currency_ru_nam as CURRENCY_LETTER_CD,
         t8.DEF_FLG,
         t9.DEF_SGN,
         t10.CLIENT_STATUS,
         max(t1.OVD_DAYS) keep(dense_rank last order by t1.OVD_DAYS) over(partition by t1.client_key) as OVD_DAYS_MAX,
         null as RATING_AGENCY_RU_NAM_REG_DT, --in merge
         null as RANGING_MODEL_REG_DT, --in merge
         null as CREDIT_RATING_REG_DT, --in merge
         null as RATING_NUMBER_REG_DT, --in merge
         t17.RATING_AGENCY_RU_NAM,
         t17.RANGING_MODEL,
         t17.CREDIT_RATING,
         null as RATING_NUMBER, --in merge
         null as STEP, --in merge
         null as NUTS_NUMBER, --in merge
         null as STAGE, --in merge
         null as STAGE_PREV_MNTH, --in merge
         null as CHANGE_STAGE, --in merge
         null as STAGE_QUARTER_BEGIN, --in merge
         null as STAGE_CHANGE_QUARTER_BEGIN, --in merge
         null as STAGE_YEAR_BEGIN, --in merge
         null as STAGE_CHANGE_YEAR_BEGIN, --in merge
         null as CREDIT_RATING_PREV_MNTH, --in merge
         --приводить к %, округлять до 2-х знаков, добавлять символ %
         regexp_replace(round(t15.PD1_MACRO*100,2) || '%','^,','0,') as PD1_MACRO,
         regexp_replace(round(t15.PD2_MACRO*100,2) || '%','^,','0,') as PD2_MACRO,
         regexp_replace(round(t15.PD3_MACRO*100,2) || '%','^,','0,') as PD3_MACRO,
         regexp_replace(round(t15.PD4_MACRO*100,2) || '%','^,','0,') as PD4_MACRO,
         regexp_replace(round(t15.PD5_MACRO*100,2) || '%','^,','0,') as PD5_MACRO,
         regexp_replace(round(t15.PD6_MACRO*100,2) || '%','^,','0,') as PD6_MACRO,
         regexp_replace(round(t15.PD7_MACRO*100,2) || '%','^,','0,') as PD7_MACRO,
         regexp_replace(round(t15.PD8_MACRO*100,2) || '%','^,','0,') as PD8_MACRO,
         regexp_replace(round(t15.PD9_MACRO*100,2) || '%','^,','0,') as PD9_MACRO,
         regexp_replace(round(t15.PD10_MACRO*100,2) || '%','^,','0,') as PD10_MACRO,
         regexp_replace(round(t15.PD1_MARG*100,2) || '%','^,','0,') as PD1_MARG,
         regexp_replace(round(t15.PD2_MARG*100,2) || '%','^,','0,') as PD2_MARG,
         regexp_replace(round(t15.PD3_MARG*100,2) || '%','^,','0,') as PD3_MARG,
         regexp_replace(round(t15.PD4_MARG*100,2) || '%','^,','0,') as PD4_MARG,
         regexp_replace(round(t15.PD5_MARG*100,2) || '%','^,','0,') as PD5_MARG,
         regexp_replace(round(t15.PD6_MARG*100,2) || '%','^,','0,') as PD5_MARG,
         regexp_replace(round(t15.PD7_MARG*100,2) || '%','^,','0,') as PD7_MARG,
         regexp_replace(round(t15.PD8_MARG*100,2) || '%','^,','0,') as PD8_MARG,
         regexp_replace(round(t15.PD9_MARG*100,2) || '%','^,','0,') as PD9_MARG,
         regexp_replace(round(t15.PD10_MARG*100,2) || '%','^,','0,') as PD10_MARG,

         nvl(t3.ECLS, 0) as ECLS,
         nvl(t3.ECLS1, 0) as ECLS1,

         t16.rate * t1.BALANCE_AMT as IND_RES,
         null as IS_RES_NULL, --in merge
         null as FINAL_RES, --in merge
         null as RES_PREV_MNTH, --in merge
         null as RES_CHANGE_MNTH_BEGIN, --in merge
         null as RES_QUARTER_BEGIN, --in merge
         null as RES_CHANGE_QUARTER_BEGIN, --in merge
         null as RES_YEAR_BEGIN, --in merge
         null as RES_CHANGE_YEAR_BEGIN, --in merge
         null as PL_MNTH_BEGIN_RUB, --in merge
         null as PL_QUARTER_BEGIN_RUB, --in merge
         null as PL_YEAR_BEGIN_RUB, --in merge = PL_YEAR_BEGIN_RUB  за предыдущий квартал + PL_QUARTER_BEGIN_RUB за текущую дату
         null as RES_RUB, --in merge
         null as RES_PREV_MNTH_RUB, --in merge
         null as RES_CHANGE_MNTH_BEGIN_RUB, --in merge
         null as RES_QUARTER_BEGIN_RUB, --in merge
         null as RES_CHANGE_QUARTER_BEGIN_RUB, --in merge
         null as RES_YEAR_BEGIN_RUB, --in merge
         null as RES_CHANGE_YEAR_BEGIN_RUB, --in merge
         null as RATE, --in merge
         null as RATE_PREV_MNTH, --in merge
         null as RATE_QUARTER_BEGIN, --in merge
         null as RATE_YEAR_BEGIN, --in merge
         null as RATE_CHANGE_MNTH_BEGIN, --in merge
         null as RATE_CHANGE_QUARTER_BEGIN, --in merge
         null as RATE_CHANGE_YEAR_BEGIN, --in merge
         t1.BALANCE_AMT as EAD,
         null as EAD_PREV_MNTH, --in merge
         null as EAD_CHANGE_MNTH_BEGIN, --in merge
         null as EAD_QUARTER_BEGIN, --in merge
         null as EAD_CHANGE_QUARTER_BEGIN, --in merge
         null as EAD_YEAR_BEGIN, --in merge
         null as EAD_CHANGE_YEAR_BEGIN, --in merge
         t1.BALANCE_AMT_RUB as EAD_RUB,
         null as EAD_PREV_MNTH_RUB, --in merge
         null as EAD_CHANGE_MNTH_BEGIN_RUB, --in merge
         null as EAD_QUARTER_BEGIN_RUB, --in merge
         null as EAD_CHANGE_QUARTER_BEGIN_RUB, --in merge
         null as EAD_YEAR_BEGIN_RUB, --in merge
         null as EAD_CHANGE_YEAR_BEGIN_RUB, --in merge
         t1.OVD_DAYS,
         t1.NIL_WO_SA_RUB /*t1.NIL_WO_SA_RUB + t1.SA_AMT_RUB*/            as NIL_WO_SA,
         t1.OVERDUE_AMOUNT_WO_SA_RUB /*t1.OVERDUE_AMOUNT_WO_SA_RUB + t1.SA_OVD_AMT_RUB*/ as OVERDUE_AMOUNT,
         null as IMPAIRMENT_CATEGORY,--in merge
         null as IMPAIRMENT_CATEGORY_PREV_MONTH,--in merge
         null as IMPAIRMENT_CATEGORY_CHANGE,--in merge
         null as CREDIT_LOSSES,--in merge
         null as CREDIT_LOSSES_PREV_MONTH,--in merge
         null as CREDIT_LOSSES_CHANGE,--in merge
         t1.CLOSING_RATE,
         t1.AVERAGE_RATE,
         t1.CONTRACT_KEY,
         t1.CONTRACT_APP_KEY,
         p_script_cd as SCRIPT_CD,
         sysdate as INSERT_DTTM,
         null as PROCESS_KEY

    from DM.IFRS_BASE_TABLE t1
   inner join dwh.IFRS_LOAD_SCRIPT t2
      on t1.script_cd = t2.script_cd
    left outer join (select contract_app_key,
                            sum(PDint * EAD_FLI * DF_ * LGD_corp) as ECLS,
                            sum(case
                                  when snapshot_dt <= add_months(v_snapshot_dt, 12) then PDint * EAD_FLI * DF_ * LGD_corp else 0
                                end) as ECLS1
                       from dm.IFRS_NIL_FLI
                      where snapshot_dt > v_snapshot_dt
                        and script_cd = p_script_cd
                      group by contract_app_key) t3
      on t1.contract_app_key = t3.contract_app_key /*and t1.snapshot_dt = t3.snapshot_dt and t1.script_cd = t3.script_cd*/
    left outer join dwh.LEASING_APPLS_ASSET t4
      on t1.contract_app_key = t4.contract_app_key
     and t4.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
     --пустая дата указывает, что в 1С информация по ключевой сущности была удалена
     and t4.dt != to_date('01.01.0001', 'dd.mm.yyyy')
    left outer join dwh.ASSET_TYPE t5
      on t4.asset_type_key = t5.asset_type_key
     and t5.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    left outer join dwh.RISK_EC_CONTRACT_DATA t6
      on t1.contract_key = t6.contract_key
     and t6.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    left outer join DWH.REF_LGD t7
      on t6.asset_type_col = t7.leasing_subject_type_cd
     and t7.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
     and t7.lgd_type_cd = 'RES'
    left outer join (select max("DefaultFlag") keep(dense_rank first order by dt desc) as DEF_FLG,
                            client_key
                       from dwh.default_flag
                      where dt <= v_snapshot_dt
                        and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                        --пустая дата указывает, что в 1С информация по ключевой сущности была удалена
                        and dt != to_date('01.01.0001', 'dd.mm.yyyy')
                      group by client_key) t8
      on t1.client_key = t8.client_key
    left outer join (select max("DefaultSign") keep(dense_rank first order by dt desc) as DEF_SGN,
                            client_key
                       from dwh.default_sign
                      where dt <= v_snapshot_dt
                        and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                        --пустая дата указывает, что в 1С информация по ключевой сущности была удалена
                        and dt != to_date('01.01.0001', 'dd.mm.yyyy')
                      group by client_key) t9
      on t1.client_key = t9.client_key
    left outer join (select max(status) keep(dense_rank first order by dt desc) as CLIENT_STATUS,
                            client_key
                       from dwh.GLOBAL_WATCH_LIST_STATUS
                      where dt <= v_snapshot_dt
                        and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                        --пустая дата указывает, что в 1С информация по ключевой сущности была удалена
                        and dt != to_date('01.01.0001', 'dd.mm.yyyy')
                      group by client_key) t10
      on t1.client_key = t10.client_key
    left outer join (select max(t12.name) keep(dense_rank last order by t11.dt)as RATING_AGENCY_RU_NAM,
                            max(t13.name) keep(dense_rank last order by t11.dt) as RANGING_MODEL,
                            max(t14.credit_rating) keep(dense_rank last order by t11.dt) as CREDIT_RATING,
                            t11.client_key
                       from DWH.CLIENT_RATING t11
                       left outer join DWH.RATING_AGENCY t12
                         on t11.rating_agency_key = t12.rating_agency_key
                        and t12.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                       left outer join DWH.RATING_MODEL t13
                         on t11.rating_model_key = t13.rating_model_key
                        and t13.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                       left outer join DWH.CREDIT_RATINGS t14
                         on t11.credit_rating_key = t14.credit_rating_key
                        and t14.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                       /*? Дата максимальная меньше отчетной даты*/
                      where t11.dt <= v_snapshot_dt
                        and t11.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                        --пустая дата указывает, что в 1С информация по ключевой сущности была удалена
                        and t11.dt != to_date('01.01.0001', 'dd.mm.yyyy')
                      group by t11.client_key) t17
      on t1.client_key = t17.client_key
    left outer join DWH.PD_CORP t15
      --on t13.rating_model_key = t15.rank_model_key
      on t17.RANGING_MODEL like '%'|| t15.rank_model ||'%' and t17.CREDIT_RATING = t15.rat_on_date
     and t15.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    left outer join DWH.IFRS_APP_RATE t16
      on t1.contract_app_key = t16.contract_app_key
     and t16.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')

   where t1.snapshot_dt = v_snapshot_dt
     and t1.script_cd = p_script_cd
     --для корпоратов должно выбираться только с флагом = 0, для автолизинга - только с флагом = 1
     and t1.auto_flg = 0;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'insert into DM.DM_PROFORM_ALLOWANCE_CORP',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


	-- досчитаем атрибуты
  -- последовательность расчета атрибутов важна, т.к. есть зависимости атрибутов друг от друга

  vd_begin := sysdate;
    ----RATING_AGENCY_RU_NAM_REG_DT----
    ----RANGING_MODEL_REG_DT----
    ----CREDIT_RATING_REG_DT----
    ----CREDIT_RATING_PREV_MNTH----
    merge into dm.DM_PROFORM_ALLOWANCE_CORP tm
    using (select distinct t.contract_app_key,
                           t.SNAPSHOT_DT,
                           LAG(t.rating_agency_ru_nam, 1, t.rating_agency_ru_nam) OVER(partition by t.contract_app_key ORDER BY t.SNAPSHOT_DT) as rating_agency_ru_nam_reg_dt,
                           LAG(t.ranging_model, 1, t.ranging_model) OVER(partition by t.contract_app_key ORDER BY t.SNAPSHOT_DT) as ranging_model_reg_dt,
                           LAG(t.credit_rating, 1, t.credit_rating) OVER(partition by t.contract_app_key ORDER BY t.SNAPSHOT_DT) as credit_rating_reg_dt,
                           LAG(t.credit_rating,1, 'новый') OVER (partition by t.contract_app_key ORDER BY t.SNAPSHOT_DT) as credit_rating_prev_mnth
             from (select contract_app_key,
                          SNAPSHOT_DT,
                          coalesce(B1, A1, T1) as rating_agency_ru_nam,
                          coalesce(B2, A2, T2) as ranging_model,
                          coalesce(B3, A3, T3) as credit_rating
                     from (select contract_app_key,
                                  SNAPSHOT_DT,
                                  script_cd as script_cd1,
                                  rating_agency_ru_nam,
                                  script_cd as script_cd2,
                                  ranging_model,
                                  script_cd as script_cd3,
                                  credit_rating
                             from dm.DM_PROFORM_ALLOWANCE_CORP
                            where (SNAPSHOT_DT = v_snapshot_dt and script_cd = p_script_cd)
                               or (SNAPSHOT_DT < v_snapshot_dt))
                               pivot(max(rating_agency_ru_nam) for(script_cd1) in(3 as B1, 2 as A1, 1 as T1))
                               pivot(max(ranging_model) for(script_cd2) in (3 as B2, 2 as A2, 1 as T2))
                               pivot(max(credit_rating) for(script_cd3) in (3 as B3, 2 as A3, 1 as T3))
                               ) t) ts
    on (tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.SNAPSHOT_DT = v_snapshot_dt and tm.script_cd = p_script_cd)
    when matched then
      update
         set tm.RATING_AGENCY_RU_NAM_REG_DT = ts.rating_agency_ru_nam_reg_dt,
             tm.RANGING_MODEL_REG_DT        = ts.ranging_model_reg_dt,
             tm.CREDIT_RATING_REG_DT        = ts.credit_rating_reg_dt,
             tm.CREDIT_RATING_PREV_MNTH     = ts.credit_rating_prev_mnth;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_CORP. Merge_1',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----RATING_NUMBER_REG_DT----depend on CREDIT_RATING_REG_DT
    ----RATING_NUMBER----
    update dm.DM_PROFORM_ALLOWANCE_CORP
    set RATING_NUMBER_REG_DT =
    case
    when (CREDIT_RATING_REG_DT in ('AAA','Aaa') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'A1' and RATING_AGENCY_RU_NAM = 'Internal') then 1
    when (CREDIT_RATING_REG_DT  in ('AA+','Aa1') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'A2' and RATING_AGENCY_RU_NAM = 'Internal') then 2
    when (CREDIT_RATING_REG_DT  in ('AA','Aa2') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'A3' and RATING_AGENCY_RU_NAM = 'Internal') then 3
    when (CREDIT_RATING_REG_DT  in ('AA-','Aa3') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'B1' and RATING_AGENCY_RU_NAM = 'Internal') then 4
    when (CREDIT_RATING_REG_DT  in ('A+','A1') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'B2' and RATING_AGENCY_RU_NAM = 'Internal') then 5
    when (CREDIT_RATING_REG_DT  in ('A','A2') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'B3' and RATING_AGENCY_RU_NAM = 'Internal') then 6
    when (CREDIT_RATING_REG_DT  in ('A-','A3') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'C1' and RATING_AGENCY_RU_NAM = 'Internal') then 7
    when (CREDIT_RATING_REG_DT  in ('BBB+','Baa1') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'C2' and RATING_AGENCY_RU_NAM = 'Internal') then 8
    when (CREDIT_RATING_REG_DT  in ('BBB','Baa2') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'C3' and RATING_AGENCY_RU_NAM = 'Internal') then 9
    when (CREDIT_RATING_REG_DT  in ('BBB-','Baa3') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'D1' and RATING_AGENCY_RU_NAM = 'Internal') then 10
    when (CREDIT_RATING_REG_DT  in ('BB+','Ba1') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'D2' and RATING_AGENCY_RU_NAM = 'Internal') then 11
    when (CREDIT_RATING_REG_DT  in ('BB','Ba2') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   in ('D3', 'No rating') and RATING_AGENCY_RU_NAM = 'Internal') then 12
    when (CREDIT_RATING_REG_DT  in ('BB-','Ba3') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'E' and RATING_AGENCY_RU_NAM = 'Internal') then 13
    when (CREDIT_RATING_REG_DT  in ('B+','B1') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING_REG_DT   = 'Dflt' and RATING_AGENCY_RU_NAM = 'Internal') then 14
    when (CREDIT_RATING_REG_DT  in ('B','B2') and  RATING_AGENCY_RU_NAM <> 'Internal') then 15
    when (CREDIT_RATING_REG_DT  in ('B-,B3') and  RATING_AGENCY_RU_NAM <> 'Internal')then 16
    when (CREDIT_RATING_REG_DT  in ('CCC+','Caa1') and  RATING_AGENCY_RU_NAM <> 'Internal') then 17
    when (CREDIT_RATING_REG_DT  in ('CCC','Caa2')  and  RATING_AGENCY_RU_NAM <> 'Internal')then 18
    when (CREDIT_RATING_REG_DT  in ('CCC-','Caa3') and  RATING_AGENCY_RU_NAM <> 'Internal') then 19
    when (CREDIT_RATING_REG_DT  in ('CC','Ca') and  RATING_AGENCY_RU_NAM <> 'Internal') then 20
    when (CREDIT_RATING_REG_DT  in ('C') and  RATING_AGENCY_RU_NAM <> 'Internal') then 21
    when (CREDIT_RATING_REG_DT  in ('D') and  RATING_AGENCY_RU_NAM <> 'Internal') then 22 end,
    RATING_NUMBER =
    case when (CREDIT_RATING in ('AAA','Aaa') and  RATING_AGENCY_RU_NAM   <> 'Internal') or  (CREDIT_RATING  = 'A1' and RATING_AGENCY_RU_NAM = 'Internal') then 1
    when (CREDIT_RATING in ('AA+','Aa1') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'A2' and RATING_AGENCY_RU_NAM = 'Internal') then 2
    when (CREDIT_RATING in ('AA','Aa2') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'A3' and RATING_AGENCY_RU_NAM = 'Internal') then 3
    when (CREDIT_RATING in ('AA-','Aa3') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'B1' and RATING_AGENCY_RU_NAM = 'Internal') then 4
    when (CREDIT_RATING in ('A+','A1') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'B2' and RATING_AGENCY_RU_NAM = 'Internal') then 5
    when (CREDIT_RATING in ('A','A2') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'B3' and RATING_AGENCY_RU_NAM = 'Internal') then 6
    when (CREDIT_RATING in ('A-','A3') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'C1' and RATING_AGENCY_RU_NAM = 'Internal') then 7
    when (CREDIT_RATING in ('BBB+','Baa1') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'C2' and RATING_AGENCY_RU_NAM = 'Internal') then 8
    when (CREDIT_RATING in ('BBB','Baa2') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'C3' and RATING_AGENCY_RU_NAM = 'Internal') then 9
    when (CREDIT_RATING in ('BBB-','Baa3') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'D1' and RATING_AGENCY_RU_NAM = 'Internal') then 10
    when (CREDIT_RATING in ('BB+','Ba1') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'D2' and RATING_AGENCY_RU_NAM = 'Internal') then 11
    when (CREDIT_RATING in ('BB','Ba2') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  in ('D3', 'No rating') and RATING_AGENCY_RU_NAM = 'Internal') then 12
    when (CREDIT_RATING in ('BB-','Ba3') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'E' and RATING_AGENCY_RU_NAM = 'Internal') then 13
    when (CREDIT_RATING in ('B+','B1') and  RATING_AGENCY_RU_NAM <> 'Internal') or  (CREDIT_RATING  = 'Dflt' and RATING_AGENCY_RU_NAM = 'Internal') then 14
    when (CREDIT_RATING in ('B','B2') and  RATING_AGENCY_RU_NAM <> 'Internal') then 15
    when (CREDIT_RATING in ('B-,B3') and  RATING_AGENCY_RU_NAM <> 'Internal')then 16
    when (CREDIT_RATING in ('CCC+','Caa1') and  RATING_AGENCY_RU_NAM <> 'Internal') then 17
    when (CREDIT_RATING in ('CCC','Caa2')  and  RATING_AGENCY_RU_NAM <> 'Internal')then 18
    when (CREDIT_RATING in ('CCC-','Caa3') and  RATING_AGENCY_RU_NAM <> 'Internal') then 19
    when (CREDIT_RATING in ('CC','Ca') and  RATING_AGENCY_RU_NAM <> 'Internal') then 20
    when (CREDIT_RATING in ('C') and  RATING_AGENCY_RU_NAM <> 'Internal') then 21
    when (CREDIT_RATING in ('D') and  RATING_AGENCY_RU_NAM <> 'Internal') then 22 end
    where SNAPSHOT_DT = v_snapshot_dt and script_cd = p_script_cd;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_CORP. Update_2',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----STEP----depend on RATING_NUMBER, RATING_NUMBER_REG_DT
    ----NUTS_NUMBER----depend on CREDIT_RATING_REG_DT, RATING_AGENCY_RU_NAM_REG_DT
    update dm.DM_PROFORM_ALLOWANCE_CORP
    set STEP = RATING_NUMBER - RATING_NUMBER_REG_DT,
    NUTS_NUMBER =
    case when CREDIT_RATING_REG_DT in ('AAA','AA+', 'AA','AA-','A+','A','A-','BBB+','Aaa','Aa1','Aa2','Aa3','A1','A2','A3','Baa1') and RATING_AGENCY_RU_NAM_REG_DT in ('Moody''s','Standart'||'&'||'Poor''s','Fitch', 'Others') then 6
      when CREDIT_RATING_REG_DT in ('BBB', 'BBB-', 'BB+', 'Ba1', 'Baa2', 'Baa3') and RATING_AGENCY_RU_NAM_REG_DT in ('Moody''s','Standart'||'&'||'Poor''s','Fitch', 'Others') then 5
        when CREDIT_RATING_REG_DT in ('BB', 'BB-', 'B+', 'Ba2', 'Ba3', 'B1') and RATING_AGENCY_RU_NAM_REG_DT in ('Moody''s','Standart'||'&'||'Poor''s','Fitch', 'Others') then 4
          when  CREDIT_RATING_REG_DT in ('B', 'B-', 'B2', 'B3') and RATING_AGENCY_RU_NAM_REG_DT in ('Moody''s','Standart'||'&'||'Poor''s','Fitch', 'Others') then 3
           when  CREDIT_RATING_REG_DT in ('CCC+', 'CCC',	'CCC-',	'CC',	'C', 'Caa1',	'Caa2',	'Caa3',	'Ca',	'C') and RATING_AGENCY_RU_NAM_REG_DT in ('Moody''s','Standart'||'&'||'Poor''s','Fitch', 'Others') then -4
             when CREDIT_RATING_REG_DT in ('A1', 'A2', 'A3') and RATING_AGENCY_RU_NAM_REG_DT in ('Internal') then 5
               when CREDIT_RATING_REG_DT in ('B1', 'B2', 'B3') and RATING_AGENCY_RU_NAM_REG_DT in ('Internal') then 4
                 when CREDIT_RATING_REG_DT in ('C1', 'C2', 'C3', 'D1', 'D2', 'D3') and RATING_AGENCY_RU_NAM_REG_DT in ('Internal') then 3 end
    where SNAPSHOT_DT = v_snapshot_dt and script_cd = p_script_cd;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_CORP. Update_3',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----STAGE----depend on CREDIT_RATING_REG_DT, STEP, NUTS_NUMBER
      merge into dm.DM_PROFORM_ALLOWANCE_CORP tm
      using (select distinct t1.contract_key,
                             t1.contract_app_key,
                             t1.SNAPSHOT_DT,
                             t1.script_cd,
                             t2.poci_sign,
                             t1.def_flg,
                             t1.ovd_days,
                             t1.client_status,
                             t1.CREDIT_RATING,
                             t1.credit_rating_reg_dt,
                             t1.STEP,
                             t1.NUTS_NUMBER
               from dm.DM_PROFORM_ALLOWANCE_CORP t1
              inner join DWH.POCI_SIGN t2
                 on t1.contract_key = t2.contract_key
              where t1.SNAPSHOT_DT = v_snapshot_dt
                and t1.script_cd = p_script_cd
                and t2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                --пустая дата указывает, что в 1С информация по ключевой сущности была удалена
                and t2.dt != to_date('01.01.0001', 'dd.mm.yyyy')) ts
      on (tm.contract_key = ts.contract_key and tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.script_cd = ts.script_cd)
      when matched then
        update
           set tm.STAGE = CASE
                            WHEN ts.poci_sign = 'POCI' then
                             'POCI'
                            else
                             case
                               when ts.def_flg = '1' then
                                '3'
                               else
                                case
                                  when (ts.ovd_days > 30 or
                                        ts.client_status = 'ППЗ' or
                                        ts.CREDIT_RATING in ('No rating', 'E') or
                                        ts.credit_rating_reg_dt = 'No rating' or
                                        ts.STEP >= ts.NUTS_NUMBER) then
                                   '2'
                                  else
                                   '1'
                                end
                             end
                          end;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_CORP. Merge_4',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----FINAL_RES----depend on STAGE
    ----IS_RES_NULL----depend on STAGE
    ----IMPAIRMENT_CATEGORY----
    ----CREDIT_LOSSES----depend on STAGE
    update dm.DM_PROFORM_ALLOWANCE_CORP
       set FINAL_RES = CASE
                         WHEN FLG_VTB_GROUP = 'YES' THEN -0.03 * EAD
                         WHEN STAGE = '1' THEN ECLS1
                         WHEN ind_res <> 0 THEN ind_res
                         WHEN STAGE = '2' THEN ECLS
                         WHEN STAGE in ('3', 'POCI') THEN ind_res
                       end,
           IS_RES_NULL = CASE
                           WHEN (CASE
                                  WHEN FLG_VTB_GROUP = 'YES' THEN -0.03 * EAD
                                  WHEN STAGE = '1' THEN ECLS1
                                  WHEN ind_res <> 0 THEN ind_res
                                  WHEN STAGE = '2' THEN ECLS
                                  WHEN STAGE in ('3', 'POCI') THEN ind_res
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
           p_step => 'DM.DM_PROFORM_ALLOWANCE_CORP. Update_5',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----STAGE_PREV_MNTH----
    ----RES_PREV_MNTH----
    ----RES_PREV_MNTH_RUB----
    ----RATE_PREV_MNTH----
    ----EAD_PREV_MNTH----
    ----EAD_PREV_MNTH_RUB----
    ----IMPAIRMENT_CATEGORY_PREV_MONTH----
    ----CREDIT_LOSSES_PREV_MONTH----
     merge into dm.DM_PROFORM_ALLOWANCE_CORP tm
      using (select t1.contract_app_key,
                    t1.SNAPSHOT_DT,
                    t1.script_cd,
                case when t2.credit_loss = 'Not credit-impaired lifetime' then '2'
                     when t2.credit_loss = '12-month' then '1'
                     when t2.credit_loss = 'Credit-impaired lifetime' then '3'
                     when t2.credit_loss = 'Purchased credit-impaired' then 'POCI'
                     else '0' end stage_name,
                     t2.provisions_amt/t1.closing_rate as RES_PREV_MNTH,
                     t2.provisions_amt as RES_PREV_MNTH_RUB,
                     t2.rate_allow as RATE_PREV_MNTH,
                     t2.balance_amt/t1.closing_rate as EAD_PREV_MNTH,
                     t2.balance_amt as EAD_PREV_MNTH_RUB,
                     t2.impairment_type as IMPAIRMENT_CATEGORY_PREV_MONTH,
                     t2.credit_loss as CREDIT_LOSSES_PREV_MONTH
                from DM.DM_PROFORM_ALLOWANCE_CORP t1
                inner join DWH.RISK_IFRS_CGP t2
                on t2.SNAPSHOT_DT = add_months(t1.snapshot_dt, -1) and t2.contract_app_key = t1.contract_app_key
               where t1.snapshot_dt = v_snapshot_dt
                 and t1.script_cd = p_script_cd
                 and t2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) ts
      on (tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.script_cd = ts.script_cd)
      when matched then
        update
           set tm.STAGE_PREV_MNTH 	             = ts.stage_name,
               tm.res_prev_mnth                  = ts.res_prev_mnth,
               tm.res_prev_mnth_rub              = ts.res_prev_mnth_rub,
               tm.rate_prev_mnth                 = ts.rate_prev_mnth,
               tm.ead_prev_mnth                  = ts.ead_prev_mnth,
               tm.ead_prev_mnth_rub              = ts.ead_prev_mnth_rub,
               tm.IMPAIRMENT_CATEGORY_PREV_MONTH = ts.IMPAIRMENT_CATEGORY_PREV_MONTH,
               tm.CREDIT_LOSSES_PREV_MONTH       = ts.CREDIT_LOSSES_PREV_MONTH;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_CORP. Merge_6',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----STAGE_QUARTER_BEGIN----
    ----RES_QUARTER_BEGIN----
    ----RES_QUARTER_BEGIN_RUB----
    ----RATE_QUARTER_BEGIN----
    ----EAD_QUARTER_BEGIN----
    ----EAD_QUARTER_BEGIN_RUB----
     merge into dm.DM_PROFORM_ALLOWANCE_CORP tm
      using (select t1.contract_app_key,
                    t1.SNAPSHOT_DT,
                    t1.script_cd,
                case when t2.credit_loss = 'Not credit-impaired lifetime' then '2'
                     when t2.credit_loss = '12-month' then '1'
                     when t2.credit_loss = 'Credit-impaired lifetime' then '3'
                     when t2.credit_loss = 'Purchased credit-impaired' then 'POCI'
                     else '0' end stage_name,
                     t2.provisions_amt/t1.closing_rate as RES_QUARTER_BEGIN,
                     t2.provisions_amt as RES_QUARTER_BEGIN_RUB,
                     t2.rate_allow as RATE_QUARTER_BEGIN,
                     t2.balance_amt/t1.closing_rate as EAD_QUARTER_BEGIN,
                     t2.balance_amt as EAD_QUARTER_BEGIN_RUB
                from DM.DM_PROFORM_ALLOWANCE_CORP t1
                inner join DWH.RISK_IFRS_CGP t2
                on t2.SNAPSHOT_DT = trunc(t1.snapshot_dt, 'Q')-1 and t2.contract_app_key = t1.contract_app_key
               where t1.snapshot_dt = v_snapshot_dt
                 and t1.script_cd = p_script_cd
                 and t2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) ts
      on (tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.script_cd = ts.script_cd)
      when matched then
        update
           set tm.STAGE_QUARTER_BEGIN   = ts.stage_name,
               tm.res_quarter_begin     = ts.res_quarter_begin,
               tm.res_quarter_begin_rub = ts.res_quarter_begin_rub,
               tm.rate_quarter_begin    = ts.rate_quarter_begin,
               tm.ead_quarter_begin     = ts.ead_quarter_begin,
               tm.ead_quarter_begin_rub = ts.ead_quarter_begin_rub;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_CORP. Merge_7',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----STAGE_YEAR_BEGIN----
    ----RES_YEAR_BEGIN----
    ----RES_YEAR_BEGIN_RUB----
    ----RATE_YEAR_BEGIN----
    ----EAD_YEAR_BEGIN----
    ----EAD_YEAR_BEGIN_RUB----
     merge into dm.DM_PROFORM_ALLOWANCE_CORP tm
      using (select t1.contract_app_key,
                    t1.SNAPSHOT_DT,
                    t1.script_cd,
                case when t2.credit_loss = 'Not credit-impaired lifetime' then '2'
                     when t2.credit_loss = '12-month' then '1'
                     when t2.credit_loss = 'Credit-impaired lifetime' then '3'
                     when t2.credit_loss = 'Purchased credit-impaired' then 'POCI'
                     else '0' end stage_name,
                     t2.provisions_amt/t1.closing_rate as RES_YEAR_BEGIN,
                     t2.provisions_amt as RES_YEAR_BEGIN_RUB,
                     t2.rate_allow as RATE_YEAR_BEGIN,
                     t2.balance_amt/t1.closing_rate as EAD_YEAR_BEGIN,
                     t2.balance_amt as EAD_YEAR_BEGIN_RUB
                from DM.DM_PROFORM_ALLOWANCE_CORP t1
                inner join DWH.RISK_IFRS_CGP t2
                on t2.SNAPSHOT_DT = LAST_DAY(ADD_MONTHS(TRUNC(TRUNC(t1.snapshot_dt,'Year')-1,'Year'),11)) and t2.contract_app_key = t1.contract_app_key
                where t1.snapshot_dt = v_snapshot_dt
                  and t1.script_cd = p_script_cd
                  and t2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) ts
      on (tm.contract_app_key = ts.contract_app_key and tm.SNAPSHOT_DT = ts.SNAPSHOT_DT and tm.script_cd = ts.script_cd)
      when matched then
        update
           set tm.STAGE_YEAR_BEGIN   = ts.stage_name,
               tm.res_year_begin     = ts.res_year_begin,
               tm.res_year_begin_rub = ts.res_year_begin_rub,
               tm.rate_year_begin    = ts.rate_year_begin,
               tm.ead_year_begin     = ts.ead_year_begin,
               tm.ead_year_begin_rub = ts.ead_year_begin_rub;

	vi_qty_row := sql%rowcount;
  commit;
  vd_end     := sysdate;
  dm.u_log(p_proc => cs_proc_name,
           p_step => 'DM.DM_PROFORM_ALLOWANCE_CORP. Merge_8',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----CHANGE_STAGE----depend on STAGE_PREV_MNTH, STAGE
    ----RES_CHANGE_MNTH_BEGIN----depend on FINAL_RES, RES_PREV_MNTH
    ----RES_RUB----depend on FINAL_RES
    ----RES_CHANGE_MNTH_BEGIN_RUB----depend on RES_RUB, RES_PREV_MNTH_RUB
    ----RATE----depend on FINAL_RES
    ----RATE_CHANGE_MNTH_BEGIN----depend on RATE, RATE_PREV_MNTH
    ----EAD_CHANGE_MNTH_BEGIN----depend on EAD_PREV_MNTH
    ----EAD_CHANGE_MNTH_BEGIN_RUB----depend on EAD_PREV_MNTH_RUB
    ----
    ----STAGE_CHANGE_QUARTER_BEGIN----depend on STAGE_QUARTER_BEGIN, STAGE
    ----RES_CHANGE_QUARTER_BEGIN----depend on FINAL_RES, RES_QUARTER_BEGIN
    ----RES_CHANGE_QUARTER_BEGIN_RUB----depend on RES_RUB, RES_QUARTER_BEGIN_RUB
    ----RATE_CHANGE_QUARTER_BEGIN----depend on RATE, RATE_QUARTER_BEGIN
    ----EAD_CHANGE_QUARTER_BEGIN----depend on EAD_QUARTER_BEGIN
    ----EAD_CHANGE_QUARTER_BEGIN_RUB----depend on EAD_QUARTER_BEGIN_RUB
    ----
    ----STAGE_CHANGE_YEAR_BEGIN----depend on STAGE_YEAR_BEGIN, STAGE
    ----RES_CHANGE_YEAR_BEGIN----depend on FINAL_RES, RES_YEAR_BEGIN
    ----RES_CHANGE_YEAR_BEGIN_RUB----depend on RES_RUB, RES_YEAR_BEGIN_RUB
    ----RATE_CHANGE_YEAR_BEGIN----depend on RATE, RATE_YEAR_BEGIN
    ----EAD_CHANGE_YEAR_BEGIN----depend on EAD_YEAR_BEGIN
    ----EAD_CHANGE_YEAR_BEGIN_RUB----depend on EAD_YEAR_BEGIN_RUB
    ----
    ----IMPAIRMENT_CATEGORY_CHANGE----depend on IMPAIRMENT_CATEGORY_PREV_MONTH
	  ----CREDIT_LOSSES_CHANGE----depend on CREDIT_LOSSES_PREV_MONTH
    update dm.DM_PROFORM_ALLOWANCE_CORP
       set CHANGE_STAGE          	      = STAGE_PREV_MNTH || '->' || STAGE,
           RES_CHANGE_MNTH_BEGIN   	    = FINAL_RES - RES_PREV_MNTH,
           RES_RUB                      = FINAL_RES * CLOSING_RATE,
           RES_CHANGE_MNTH_BEGIN_RUB    = /*RES_RUB*/FINAL_RES * CLOSING_RATE - RES_PREV_MNTH_RUB,
           RATE                         = FINAL_RES / EAD,
           RATE_CHANGE_MNTH_BEGIN       = /*RATE*/FINAL_RES / EAD - RATE_PREV_MNTH,
           EAD_CHANGE_MNTH_BEGIN        = EAD - EAD_PREV_MNTH,
           EAD_CHANGE_MNTH_BEGIN_RUB    = EAD_RUB - EAD_PREV_MNTH_RUB,
    ----
           STAGE_CHANGE_QUARTER_BEGIN   = STAGE_QUARTER_BEGIN || '->' || STAGE,
           RES_CHANGE_QUARTER_BEGIN     = FINAL_RES - RES_QUARTER_BEGIN,
           RES_CHANGE_QUARTER_BEGIN_RUB = /*RES_RUB*/FINAL_RES * CLOSING_RATE - RES_QUARTER_BEGIN_RUB,
           RATE_CHANGE_QUARTER_BEGIN    = /*RATE*/FINAL_RES / EAD - RATE_QUARTER_BEGIN,
           EAD_CHANGE_QUARTER_BEGIN     = EAD - EAD_QUARTER_BEGIN,
           EAD_CHANGE_QUARTER_BEGIN_RUB = EAD_RUB - EAD_QUARTER_BEGIN_RUB,
    ----
           STAGE_CHANGE_YEAR_BEGIN      = STAGE_YEAR_BEGIN || '->' || STAGE,
           RES_CHANGE_YEAR_BEGIN        = FINAL_RES -  RES_YEAR_BEGIN,
           RES_CHANGE_YEAR_BEGIN_RUB    = /*RES_RUB*/FINAL_RES * CLOSING_RATE - RES_YEAR_BEGIN_RUB,
           RATE_CHANGE_YEAR_BEGIN       = /*RATE*/FINAL_RES / EAD - RATE_YEAR_BEGIN,
           EAD_CHANGE_YEAR_BEGIN        = EAD - EAD_YEAR_BEGIN,
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
           p_step => 'DM.DM_PROFORM_ALLOWANCE_CORP. Update_9',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----PL_MNTH_BEGIN_RUB----depend on FINAL_RES, RES_QUARTER_BEGIN, PL_MNTH_BEGIN_RUB(prev monthes in quart)
    ----PL_QUARTER_BEGIN_RUB----depend on FINAL_RES, RES_QUARTER_BEGIN
    merge into dm.DM_PROFORM_ALLOWANCE_CORP tm
    using (select t1.contract_app_key, t1.SNAPSHOT_DT, nvl(t2.pl_mnth_begin_rub,0) as pl_mnth_begin_rub
             from dm.DM_PROFORM_ALLOWANCE_CORP t1
             left outer join (select contract_app_key,
                                    sum(coalesce(b, a, t)) as pl_mnth_begin_rub
                               from (select contract_app_key,
                                            script_cd,
                                            SNAPSHOT_DT,
                                            nvl(pl_mnth_begin_rub, 0) as pl_mnth_begin_rub
                                       from dm.DM_PROFORM_ALLOWANCE_CORP
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
           p_step => 'DM.DM_PROFORM_ALLOWANCE_CORP. Merge_10',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


  vd_begin := sysdate;
    ----PL_YEAR_BEGIN_RUB----
    merge into dm.DM_PROFORM_ALLOWANCE_CORP tm
    using (select t1.contract_app_key, t1.SNAPSHOT_DT, nvl(t2.pl_year_begin_rub,0) as pl_year_begin_rub
             from dm.DM_PROFORM_ALLOWANCE_CORP t1
             left outer join (select contract_app_key,
                                    sum(coalesce(b, a, t)) as pl_year_begin_rub
                               from (select contract_app_key,
                                            script_cd,
                                            SNAPSHOT_DT,
                                            nvl(pl_year_begin_rub, 0) as pl_year_begin_rub
                                       from dm.DM_PROFORM_ALLOWANCE_CORP
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
           p_step => 'DM.DM_PROFORM_ALLOWANCE_CORP. Merge_11',
           p_info => 'Start operation: ' || to_char(vd_begin,'dd.mm.yyyy hh24:mi:ss') || '; End operation: ' || to_char(vd_end,'dd.mm.yyyy hh24:mi:ss') || '; processed records: ' || vi_qty_row);


   -- сбор статистики по окончании расчета
   dm.analyze_table(p_table_name => 'DM_PROFORM_ALLOWANCE_CORP',p_schema => 'DM');

   dm.u_log(p_proc => cs_proc_name,
           p_step => 'analyze_table DM.DM_PROFORM_ALLOWANCE_CORP',
           p_info => 'analyze_table done');

  etl.P_DM_LOG('DM_PROFORM_ALLOWANCE_CORP');
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

