CREATE OR REPLACE PROCEDURE DM.P_DM_REG_REPO (
    p_REPORT_DT in DATE, p_reg_group_key in number default 1)

IS

BEGIN

DELETE FROM dm.DM_REG_REPO WHERE snapshot_DT = p_REPORT_DT and branch_key in (select branch_key from dwh.reg_group where reg_group_key = p_reg_group_key);

insert into dm.DM_REG_REPO(
                  SNAPSHOT_CD,
                  SNAPSHOT_DT,
                  SNAPSHOT_MONTH,
                  SNAPSHOT_YEAR,
                  BRANCH_KEY,
                  ACÑOUNT_KEY,
                  CONTRACT_KEY,
                  CLIENT_KEY,
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

    select /*+ cardinality(p1, 500) cardinality(p2, 500) cardinality(p3, 500) cardinality(cl, 5000) cardinality(er, 50000) cardinality(pt1, 500) cardinality(pt2, 500) cardinality(pt3, 500) use_hash(p1, p2, p3, pt1, pt2, pt3) */
          'Îñíîâíîé ÊÈÑ' as snapshot_cd,
          p_REPORT_DT as snapshot_dt,
          to_char(p_REPORT_DT, 'MM') as snapshot_month,
          to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
          (  select 
                    branch_key 
             from   dwh.org_structure 
             where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
               and BRANCH_CD = 'VTB_LEASING'
          ) as branch_key,
          null as ACÑOUNT_KEY,
          bc.bond_contract_KEY as contract_KEY,
          (  select 
                   client_key
             from  dwh.clients
             where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
               and client_cd = '000002604'
          ) as client_key,
          (  select 
                   member_key
             from  dwh.clients
             where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
               and client_cd = '000002604' 
          ) as member_key,
          'N' as VTB_MEMBER_FLG,
          (  select 
                   instrument_key
             from dwh.instrument_types
             where BEGIN_DT <= p_REPORT_DT  
               and end_dt > p_REPORT_DT  
               and instrument_cd = '20'
               and instrument_type_desc = 'Ïðîöåíòíûé'
          ) as instrument_key,
          (  select 
                   instrument_kind_cd
             from dwh.instrument_types
             where BEGIN_DT <= p_REPORT_DT  
               and end_dt > p_REPORT_DT  
               and instrument_cd = '20'
               and instrument_type_desc = 'Ïðîöåíòíûé'
          ) as instrument_kind_cd,
          bp.currency_key as SRC_CURRENCY_KEY,
          case 
              when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                  then bp.CURRENCY_KEY
              else (
                    select 
                          currency_key 
                    from dwh.currencies 
                    where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') 
                      and currency_letter_cd = 'OTH'
                      and BEGIN_DT <= p_REPORT_DT  
                      and end_dt > p_REPORT_DT 
          ) end as cis_currency_key,
          trd.END_DT - p_REPORT_DT as term_cnt,
          p1.period_key as PERIOD1_TYPE_KEY,
          p2.period_key as PERIOD2_TYPE_KEY,
          p3.period_key as PERIOD3_TYPE_KEY,
            (trd.AMT_REC_F_SEC_SLD) * (-1)
          as src_amt,
          case 
              when cr.currency_letter_cd = 'RUB' 
                  then (trd.AMT_REC_F_SEC_SLD) * (-1)
              else (trd.AMT_REC_F_SEC_SLD) * (-1) * er.exchange_rate 
          end as RUR_AMT,
          case 
              when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                  then (trd.AMT_REC_F_SEC_SLD) * (-1) 
              else (trd.AMT_REC_F_SEC_SLD) * (-1) * er.exchange_rate 
          end as CIS_AMT,
          case 
              when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                  then (trd.AMT_REC_F_SEC_SLD) * (-1)
              else (trd.AMT_REC_F_SEC_SLD) * (-1) * er.exchange_rate
          end * EFF_PRC_RATE /100
          as RATE_W_AMT,
          case 
              when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                  then (trd.AMT_REC_F_SEC_SLD) * (-1) 
              else (trd.AMT_REC_F_SEC_SLD) * (-1) * er.exchange_rate
          end * (trd.END_DT - p_REPORT_DT)
          as TERM_W_AMT,
          - trd.AMT_DUE_F_SEC_PUR as SRC_LIQ_AMT,
          case 
                when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                    then - trd.AMT_DUE_F_SEC_PUR 
                else - trd.AMT_DUE_F_SEC_PUR * er.exchange_rate 
          end as CIS_LIQ_AMT,
          (trd.AMT_REC_F_SEC_SLD 
           + (trd.AMT_REC_F_SEC_SLD - trd.AMT_DUE_F_SEC_PUR) 
           * (trd.START_DT - p_REPORT_DT) 
           / (trd.END_DT - trd.START_DT)) * (-1) as SRC_MR_AMT,
          case 
              when cr.currency_letter_cd = 'RUB' 
                  then (trd.AMT_REC_F_SEC_SLD 
                       + (trd.AMT_REC_F_SEC_SLD - trd.AMT_DUE_F_SEC_PUR) 
                       * (trd.START_DT - p_REPORT_DT) 
                       / (trd.END_DT - trd.START_DT)) * (-1)
              else    (trd.AMT_REC_F_SEC_SLD 
                       + (trd.AMT_REC_F_SEC_SLD - trd.AMT_DUE_F_SEC_PUR) 
                       * (trd.START_DT - p_REPORT_DT) 
                       / (trd.END_DT - trd.START_DT)) * (-1) * er.exchange_rate 
          end as RUR_MR_AMT,
          case 
              when cr.currency_letter_cd = 'RUB' 
                  then (trd.AMT_REC_F_SEC_SLD 
                       + (trd.AMT_REC_F_SEC_SLD - trd.AMT_DUE_F_SEC_PUR) 
                       * (trd.START_DT - p_REPORT_DT) 
                       / (trd.END_DT - trd.START_DT)) * (-1)
              else    (trd.AMT_REC_F_SEC_SLD 
                       + (trd.AMT_REC_F_SEC_SLD - trd.AMT_DUE_F_SEC_PUR) 
                       * (trd.START_DT - p_REPORT_DT) 
                       / (trd.END_DT - trd.START_DT)) * (-1) * er.exchange_rate 
          end * trd.EFF_PRC_RATE / 100 as RATE_W_MR_AMT,
          trd.end_dt as PAY_DT,
          case 
              when cr.currency_letter_cd = 'RUB' 
                  then 1 
              else er.exchange_rate 
          end as EX_RATE,
          '0' as FLOAT_RATE_FLG,
          trd.eff_prc_rate as RATE_AMT,
          null as PURPOSE_DESC,
          'V-1.15.2' as ART_CD,
          777 as PROCESS_KEY,
          SYSDATE AS INSERT_DT
from 
          dwhro.test_repo_direct trd, 
          dwh.currencies cr, 
          dwh.exchange_rates er, 
          dwh.currencies cr2, 
          dwh.periods p1, 
          dwh.periods p2, 
          dwh.periods p3, 
          dwh.period_types pt1, 
          dwh.period_types pt2, 
          dwh.period_types pt3,
          dwh.bonds_contract bc,
          dwh.bonds_portfolio bp
    where trd.STATUS_DT=p_REPORT_DT
      and cr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and cr2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and er.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and p1.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and p2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and p3.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and pt1.begin_dt <= p_REPORT_DT
      and pt1.end_dt > p_REPORT_DT
      and pt2.begin_dt <= p_REPORT_DT
      and pt2.end_dt > p_REPORT_DT
      and pt3.begin_dt <= p_REPORT_DT
      and pt3.end_dt > p_REPORT_DT
      and p1.period_type_key = pt1.period_type_key
      and p2.period_type_key = pt2.period_type_key
      and p3.period_type_key = pt3.period_type_key
      and pt1.period_type_cd = 1
      and pt2.period_type_cd = 2
      and pt3.period_type_cd = 3
      and trd.END_DT - p_REPORT_DT > p1.days_from_cnt and trd.END_DT - p_REPORT_DT <= p1.days_to_cnt
      and trd.END_DT - p_REPORT_DT > p2.days_from_cnt and trd.END_DT - p_REPORT_DT <= p2.days_to_cnt
      and trd.END_DT - p_REPORT_DT > p3.days_from_cnt and trd.END_DT - p_REPORT_DT <= p3.days_to_cnt
      and bp.CURRENCY_KEY = cr.currency_key
      and bp.currency_key = er.currency_key
      and er.base_currency_key = cr2.currency_key
      and er.ex_rate_dt = p_REPORT_DT
      and cr2.currency_letter_cd = 'RUB'
      and bp.bond_id_cd = trd.bond_id_cd
      and bc.isin_cd = bp.isin_cd
      and p_reg_group_key in (1, 2);
      
commit;

end;
/

