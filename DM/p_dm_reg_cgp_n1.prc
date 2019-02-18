CREATE OR REPLACE PROCEDURE DM."P_DM_REG_CGP_N1" (p_REPORT_DT in date, p_group_key in number default 1)  -- Добавил Поляков для настройки матрицы.
IS


BEGIN
      dm.u_log(p_proc => 'DM.P_DM_REG_CGP_N',
           p_step => 'INPUT PARAMS',
           p_info => 'p_group_key:'||p_group_key||'p_REPORT_DT:'||p_REPORT_DT);
    delete from DM_REG_CGP where snapshot_dt = p_REPORT_DT and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT);
  dm.u_log(p_proc => 'DM.P_DM_REG_CGP_N',
           p_step => 'delete from DM_REG_CGP',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
    insert into DM_REG_CGP (
                  SNAPSHOT_CD,
                  SNAPSHOT_DT,
                  SNAPSHOT_MONTH,
                  SNAPSHOT_YEAR,
                  BRANCH_KEY,
                  ACСOUNT_KEY,
                  CONTRACT_KEY,
                  CLIENT_KEY,
                  BANK_KEY,
                  MEMBER_KEY,
                  VTB_MEMBER_FLG,
                  INSTRUMENT_KEY,
                  INSTRUMENT_KIND_CD,
                  SRC_CURRENCY_KEY,
                  CIS_CURRENCY_KEY,
                  TERM_CNT,
                  PERIOD1_TYPE_KEY,
                  PERIOD2_TYPE_KEY,
                  PERIOD3_TYPE_KEY,
                  SRC_AMT,
                  RUR_AMT,
                  CIS_AMT,
                  RATE_W_AMT,
                  TERM_W_AMT,
                  SRC_LIQ_AMT,
                  CIS_LIQ_AMT,
                  SRC_MR_AMT,
                  RUR_MR_AMT,
                  RATE_W_MR_AMT,
                  PAY_DT,
                  EX_RATE,
                  FLOAT_RATE_FLG,
                  RATE_AMT,
                  PURPOSE_DESC,
                  ART_CD,
                  PROCESS_KEY,
                  INSERT_DT
          )
          select
                  'Основной КИС' as snapshot_cd,
                  p_REPORT_DT as snapshot_dt,
                  to_char(p_REPORT_DT, 'MM') as snapshot_month,
                  to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
                  cgp.branch_key as branch_key,
                  null as account_key,
                  cgp.contract_key as contract_key,
                  cgp.client_key as client_key,
                  null as bank_key,
                  cl.member_key as member_key,
                  case
                    when gr.member_cd <> 0
                      then 'Y'
                    else 'N'
                  end as VTB_MEMBER_FLG,
                  (   select
                            it.instrument_key
                      from dwh.instrument_types it
                      where it.instrument_ru_nam = 'Просроченная задолженность'
                        and it.begin_dt <= p_REPORT_DT
                        and it.end_dt > p_REPORT_DT
                  ) as instrument_key,
                  'Активы' as instrument_kind_cd,
                  cgp.CURRENCY_KEY as SRC_CURRENCY_KEY,
                  case
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                      then cgp.CURRENCY_KEY
                    else (
                          select currency_key
                          from dwh.currencies
                          where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                            and currency_letter_cd = 'OTH'
                         )
                  end as cis_currency_key,
                  cgp.END_DT - p_REPORT_DT as TERM_CNT,
                  p1.period_key as PERIOD1_TYPE_KEY,
                  null as PERIOD2_TYPE_KEY,
                  p3.period_key as PERIOD3_TYPE_KEY,
                  cgp.OVERDUE_AMT AS SRC_AMT,
                  case
                    when cr.currency_letter_cd = 'RUB'
                      then cgp.OVERDUE_AMT
                    else cgp.OVERDUE_AMT * er.exchange_rate
                  end as RUR_AMT,
                  case
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                      then cgp.OVERDUE_AMT
                    else cgp.OVERDUE_AMT * er.exchange_rate
                  end as CIS_AMT,
                  cgp.XIRR_RATE * (case
                                      when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                                        then cgp.OVERDUE_AMT
                                      else cgp.OVERDUE_AMT * er.exchange_rate
                                   end
                  ) as RATE_W_AMT,
                  (cgp.END_DT - p_REPORT_DT) * (case
                                                                          when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                                                                            then cgp.OVERDUE_AMT
                                                                          else cgp.OVERDUE_AMT * er.exchange_rate
                                                                        end
                  ) as TERM_W_AMT,
                  cgp.OVERDUE_AMT AS SRC_LIQ_AMT,
                  case
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                      then cgp.OVERDUE_AMT
                    else cgp.OVERDUE_AMT * er.exchange_rate
                  end as CIS_LIQ_AMT,
                  cgp.OVERDUE_AMT as SRC_MR_AMT,
                  case
                    when cr.currency_letter_cd = 'RUB'
                      then cgp.OVERDUE_AMT
                    else cgp.OVERDUE_AMT * er.exchange_rate
                  end as RUR_MR_AMT,
                  case
                    when cr.currency_letter_cd = 'RUB'
                      then cgp.OVERDUE_AMT * cgp.XIRR_RATE
                      else cgp.OVERDUE_AMT * cgp.XIRR_RATE * er.exchange_rate ---// Рашковский - добавил пересчет в рубли для MR
                      end as RATE_W_MR_AMT,
                  cgp.END_DT as PAY_DT,
                  case
                    when cr.currency_letter_cd = 'RUB'
                      then 1
                    else er.exchange_rate
                  end as ex_rate,
                  '0' as FLOAT_RATE_FLG,
                  cgp.xirr_rate as rate_amt,
                  null as purpose_desc,
                  'V-1.3.1.2' as ART_CD,
                  777 AS PROCESS_KEY,
                  SYSDATE AS INSERT_DT
            from
                  dm.dm_cgp cgp,
                  dwh.clients cl,
                  dwh.business_categories bc,
                  dwh.currencies cr,
                  dwh.periods p3,
                  dwh.period_types pt3,
                  dwh.periods p1,
                  dwh.period_types pt1,
                  dwh.exchange_rates er,
                  DWH.IFRS_VTB_GROUP gr,
                  dwh.currencies cr2,
                  dwh.cgp_group bg
            where cgp.SNAPSHOT_DT = p_REPORT_DT
              and cgp.SNAPSHOT_CD = 'Основной КИС'
              and cl.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
              and bc.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
              and cr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
              and cr2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
              and p3.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
              and p1.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
              and er.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
              and gr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
              and pt3.begin_dt <= p_REPORT_DT
              and pt3.end_dt > p_REPORT_DT
              and pt1.begin_dt <= p_REPORT_DT
              and pt1.end_dt > p_REPORT_DT
              and bg.begin_dt <= p_REPORT_DT
              and bg.end_dt > p_REPORT_DT
              and cgp.branch_key = bg.branch_key
              and bg.CGP_GROUP_KEY = p_group_key
              and cl.client_key = cgp.client_key
              and cgp.CURRENCY_KEY = cr.CURRENCY_KEY
              and p3.period_type_key = pt3.period_type_key
              and pt3.period_type_cd = 3
              and p3.period_ru_nam = '07 (свыше 3 лет)'
              and p1.period_type_key = pt1.period_type_key
              and pt1.period_type_cd = 1
              and p1.period_ru_nam = 'более 10 лет'
              and cgp.business_category_key = bc.business_category_key
              and bc.Begin_dt <= cgp.SNAPSHOT_DT
              and bc.end_dt > cgp.SNAPSHOT_DT
              and bc.business_category_key in (1,2,3)
              and cgp.currency_key = er.currency_key
              and cl.member_key = gr.member_key
              and er.base_currency_key = cr2.currency_key
              and er.ex_rate_dt = p_REPORT_DT
              and cr2.currency_letter_cd = 'RUB';

  dm.u_log(p_proc => 'DM.P_DM_REG_CGP_N',
           p_step => 'insert into DM_REG_CGP',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');
commit;
end;
/

