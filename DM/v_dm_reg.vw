CREATE OR REPLACE FORCE VIEW DM.V_DM_REG AS
SELECT 
    t."SNAPSHOT_CD",t."SNAPSHOT_DT",t."SNAPSHOT_MONTH",t."SNAPSHOT_YEAR",t."BRANCH_KEY",t."AC—OUNT_KEY",t."CONTRACT_KEY",t."CLIENT_KEY",t."BANK_KEY",t."MEMBER_KEY",t."VTB_MEMBER_FLG",t."INSTRUMENT_KEY",t."INSTRUMENT_KIND_CD",t."SRC_CURRENCY_KEY",t."CIS_CURRENCY_KEY",t."TERM_CNT",t."PERIOD1_TYPE_KEY",t."PERIOD2_TYPE_KEY",t."PERIOD3_TYPE_KEY",t."SRC_AMT",t."RUR_AMT",t."CIS_AMT",t."RATE_W_AMT",t."TERM_W_AMT",t."SRC_LIQ_AMT",t."CIS_LIQ_AMT",t."SRC_MR_AMT",t."RUR_MR_AMT",t."RATE_W_MR_AMT",t."PAY_DT",t."EX_RATE",t."FLOAT_RATE_FLG",t."RATE_AMT",t."PURPOSE_DESC",t."ART_CD",t."PROCESS_KEY",t."INSERT_DT",t."REG_SOURCE_CD",
    case when t.reg_source_cd in ('CGP','REPAYMENT_SCHEDULE','KS') then t.contract_key else null end as CONTRACT_CGP_KEY,
    case when t.reg_source_cd in ('SWAP') then t.contract_key else null end as CONTRACT_SWAP_KEY,
    case when t.reg_source_cd in ('IRS') then t.contract_key else null end as CONTRACT_IRS_KEY,
    -- [apolyakov 29.08.2016]: ‰Ó·‡‚ÎÂÌËÂ –≈œŒ
    case when t.reg_source_cd in ('BOND', 'REPO') then t.contract_key else null end as CONTRACT_BOND_KEY,
    case when t.reg_source_cd in ('OWNBILL') then t.contract_key else null end as CONTRACT_BILL_KEY,
    case when t.reg_source_cd in ('MISC') then t.contract_key else null end as CONTRACT_MISC_KEY,
    case when t.client_key is not null then cli.grf_entity_key else ban.grf_entity_key end as grf_entity_key
FROM 
   dm.dm_reg t
left join
   dwh.clients cli 
   on cli.client_key=t.CLIENT_KEY
   and cli.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
left join dwh.banks ban
   on ban.bank_key=t.bank_key
   and ban.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
;

