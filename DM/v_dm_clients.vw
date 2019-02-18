CREATE OR REPLACE FORCE VIEW DM.V_DM_CLIENTS AS
SELECT 
cl."SCENARIO_DESC",cl."SNAPSHOT_DT",cl."SNAPSHOT_MONTH",cl."SNAPSHOT_YEAR",cl."CLIENT_KEY",cl."CLIENT_CD",cl."CLIENT_ID",cl."CLIENT_CRM_CD",cl."SHORT_CLIENT_RU_NAM",cl."INN",cl."BUSINESS_CATEGORY_KEY",cl."CREDIT_RATING_KEY",cl."ACTIVITY_TYPE_KEY",cl."REG_COUNTRY_KEY",cl."RISK_COUNTRY_KEY",cl."PARTIES_TYPE_KEY",cl."LAUNDERING_RISK_FLG",cl."ORG_TYPE_KEY",cl."GRF_GROUP_KEY",cl."GROUP_KEY",cl."MEMBER_KEY",cl."FAILURE_FLG",cl."BRANCH_OFFICE_CD",cl."CLIENT_SRC_KEY",cl."CLIENT_ACTIVE_KEY",cl."PROCESS_KEY",cl."INSERT_DT",
act.ACTIVITY_TYPE_CD, act.ACTIVITY_TYPE_RU_DESC, act.ACTIVITY_TYPE_EN_DESC,
bus.BUSINESS_CATEGORY_CD, bus.BUSINESS_CAT_RU_NAM, bus.BUSINESS_CAT_EN_NAM,
actt.CLIENT_ACTIVE_RU_NAM, actt.CLIENT_ACTIVE_EN_NAM,
src.CLIENT_SRC_RU_NAM, src.CLIENT_SRC_EN_NAM,
reg_c.COUNTRY_CD as reg_c_cd, reg_c.COUNTRY_ISO3_CD as reg_c_iso3, reg_c.COUNTRY_RU_NAM as reg_c_ru, reg_c.COUNTRY_EN_NAM as reg_c_en, reg_c.COUNTRY_RU_DESC as reg_c_ru_d, reg_c.COUNTRY_EN_DESC as reg_c_en_d, reg_c.COUNTRY_ISO2_CD as reg_c_iso2, reg_c.LOCATION_RU_DESC as reg_c_loc_ru, reg_c.LOCATION_EN_DESC as reg_c_loc_en, reg_c.OECD_RU_DESC as reg_c_oecd_ru, reg_c.OECD_EN_DESC as reg_c_oecd_en, reg_c.DEVELOPED_RU_DESC as reg_c_dev_ru, reg_c.DEVELOPED_EN_DESC as reg_c_dev_en, 
risk_c.COUNTRY_CD, risk_c.COUNTRY_ISO3_CD, risk_c.COUNTRY_RU_NAM, risk_c.COUNTRY_EN_NAM, risk_c.COUNTRY_RU_DESC, risk_c.COUNTRY_EN_DESC, risk_c.COUNTRY_ISO2_CD, risk_c.LOCATION_RU_DESC, risk_c.LOCATION_EN_DESC, risk_c.OECD_RU_DESC, risk_c.OECD_EN_DESC, risk_c.DEVELOPED_RU_DESC, risk_c.DEVELOPED_EN_DESC, 
rat.CREDIT_RATING_CD, rat.CREDIT_RATING, rat.AGENCY_KEY,
grf.GRF_GROUP_CD, grf.GRF_GROUP_RU_NAM,
gro.GROUP_CD, gro.GROUP_RU_NAM, gro.GROUP_TYPE_KEY, gro.BORROWERS_CD, gro.BORROWER_CRM_CD,
ifrs.INDEX_CD, ifrs.CLASSIFY_FLG, ifrs.MRD_FLG, ifrs.RISK_REPORT_FLG, ifrs.MEMBER_CD, ifrs.COUNTRY_ISO_CD, ifrs.MEMBER_RU_NAM, ifrs.MEMBER_EN_NAM, ifrs.CONS_CIS_FLG,
org.ORG_TYPE_CD, org.ORG_TYPE_EN_NAM, org.ORG_TYPE_RU_NAM,
par.PARTIES_TYPE_CD, par.PARTIES_TYPE_EN_NAM, par.PARTIES_TYPE_RU_NAM, par.PARTIES_TYPE_EN_DESC, par.PARTIES_TYPE_RU_DESC
from dm_clients cl
left join DWH.BUSINESS_CATEGORIES bus on bus.BUSINESS_CATEGORY_KEY=cl.BUSINESS_CATEGORY_KEY and bus.VALID_TO_DTTM> sysdate +100 and cl.SNAPSHOT_DT between bus.BEGIN_DT and bus.END_DT
left join DWH.CREDIT_RATINGS rat on rat.CREDIT_RATING_KEY=cl.CREDIT_RATING_KEY and rat.VALID_TO_DTTM> sysdate +100 and cl.SNAPSHOT_DT between rat.BEGIN_DT and rat.END_DT
left join DWH.ACTIVITY_TYPES act on act.ACTIVITY_TYPE_KEY=cl.ACTIVITY_TYPE_KEY and act.VALID_TO_DTTM> sysdate +100 and cl.SNAPSHOT_DT between act.BEGIN_DT and act.END_DT
left join DWH.COUNTRIES reg_c on reg_c.COUNTRY_KEY=cl.REG_COUNTRY_KEY and reg_c.VALID_TO_DTTM> sysdate +100 and cl.SNAPSHOT_DT between reg_c.BEGIN_DT and reg_c.END_DT
left join DWH.COUNTRIES risk_c on risk_c.COUNTRY_KEY=cl.RISK_COUNTRY_KEY and risk_c.VALID_TO_DTTM> sysdate +100 and cl.SNAPSHOT_DT between risk_c.BEGIN_DT and risk_c.END_DT
left join DWH.PARTIES_TYPES par on par.PARTIES_TYPE_KEY=cl.PARTIES_TYPE_KEY and par.VALID_TO_DTTM> sysdate +100 and cl.SNAPSHOT_DT between par.BEGIN_DT and par.END_DT
left join DWH.ORG_TYPES org on org.ORG_TYPE_KEY=cl.ORG_TYPE_KEY and org.VALID_TO_DTTM> sysdate +100 and cl.SNAPSHOT_DT between org.BEGIN_DT and org.END_DT
left join DWH.GRF_VTB_GROUP grf on grf.GRF_GROUP_KEY=cl.GRF_GROUP_KEY and grf.VALID_TO_DTTM> sysdate +100
left join DWH.GROUPS gro on gro.GROUP_KEY=cl.GROUP_KEY and gro.VALID_TO_DTTM> sysdate +100 
left join DWH.IFRS_VTB_GROUP ifrs on ifrs.MEMBER_KEY=cl.MEMBER_KEY and ifrs.VALID_TO_DTTM> sysdate +100
left join DWH.CLIENT_SOURCES src on src.CLIENT_SCR_KEY=cl.CLIENT_SRC_KEY
left join DWH.CLIENT_ACTIVE_TYPES actt on actt.CLIENT_ACTIVE_KEY=cl.CLIENT_ACTIVE_KEY;
