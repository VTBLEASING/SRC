create or replace force view dm.v$ifrs_nil_fli as
with maxrg as -- максимальная дата регистратора из графиков начислений для каждого приложения
(select max(acc.REGISTRATORDATE) as REGISTRATORDATE, acc.contract_app_key from dwh.accrualscheduleifrs acc
where acc.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy') and acc.date_ > to_date('31.12.2018','dd.mm.yyyy') group by acc.contract_app_key)
select distinct
a.reportingdate as snapshot_dt,
a.contract_app_key as contract_app_key,
t2.date_ as pay_dt,
t2.sum_ as ead,
t2.sum_ + SUM(t1.sum_) OVER (PARTITION BY t2.contract_app_key, t2.date_) as ead_fli,
NVL(LGD_AVTO.LGD,0) as LGD_AVTO,
NVL(LGD_CORP.LGD,0) as LGD_CORP,
1/power(1 + a.XIRR, (t2.date_ -  a.REPORTINGDATE) / 365) as DF_,
NVL(1 - power(1 - case when FLOOR(MONTHS_BETWEEN(a.reportingdate,t2.date_)/12) <= 1 then (case when lc.AUTO_FLG = 1 then pd_auto.PD1_TTC else pd_corp.PD1_MARG end)
                                             when FLOOR(MONTHS_BETWEEN(a.reportingdate,t2.date_)/12) <= 2 then (case when lc.AUTO_FLG = 1 then pd_auto.PD2_TTC else pd_corp.PD2_MARG end)
                                             when FLOOR(MONTHS_BETWEEN(a.reportingdate,t2.date_)/12) <= 3 then (case when lc.AUTO_FLG = 1 then pd_auto.PD3_TTC else pd_corp.PD3_MARG end)
                                             when FLOOR(MONTHS_BETWEEN(a.reportingdate,t2.date_)/12) <= 4 then (case when lc.AUTO_FLG = 1 then pd_auto.PD4_TTC else pd_corp.PD4_MARG end)
                                             when FLOOR(MONTHS_BETWEEN(a.reportingdate,t2.date_)/12) <= 5 then (case when lc.AUTO_FLG = 1 then pd_auto.PD5_TTC else pd_corp.PD5_MARG end)
                                             when FLOOR(MONTHS_BETWEEN(a.reportingdate,t2.date_)/12) <= 6 then (case when lc.AUTO_FLG = 1 then pd_auto.PD6_TTC else pd_corp.PD6_MARG end)
                                             when FLOOR(MONTHS_BETWEEN(a.reportingdate,t2.date_)/12) <= 7 then (case when lc.AUTO_FLG = 1 then pd_auto.PD7_TTC else pd_corp.PD7_MARG end)
                                             when FLOOR(MONTHS_BETWEEN(a.reportingdate,t2.date_)/12) <= 8 then (case when lc.AUTO_FLG = 1 then pd_auto.PD8_TTC else pd_corp.PD8_MARG end)
                                             when FLOOR(MONTHS_BETWEEN(a.reportingdate,t2.date_)/12) <= 9 then (case when lc.AUTO_FLG = 1 then pd_auto.PD9_TTC else pd_corp.PD9_MARG end)
                                             when FLOOR(MONTHS_BETWEEN(a.reportingdate,t2.date_)/12) <= 10 then (case when lc.AUTO_FLG = 1 then pd_auto.PD10_TTC else pd_corp.PD10_MARG end) else 0 end,
                                             mod(FLOOR(MONTHS_BETWEEN(a.reportingdate, t2.date_)), 12)),0) as PDint
from dwh.reportloanportfolio a
LEFT JOIN maxrg mrgt on a.contract_app_key = mrgt.contract_app_key
LEFT JOIN dwh.accrualscheduleifrs t2 on t2.payment_item_key = 79 and t2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy') and
t2.contract_app_key = a.contract_app_key and t2.registratordate = mrgt.registratordate and t2.date_ >= a.reportingdate
and (extract(day from t2.date_) in (30,31) or (extract(day from t2.date_) = 28 and extract(month from t2.date_) = 2))
LEFT JOIN (select contract_app_key, sum_ , date_, registratordate from dwh.accrualscheduleifrs where payment_item_key = 49 and valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy') order by date_) t1
on t1.contract_app_key = t2.contract_app_key and t1.registratordate = mrgt.registratordate and t1.date_ > t2.date_ and t1.date_ <= add_months(t2.date_, 3)
LEFT JOIN dwh.contracts cc on a.contract_key = cc.contract_key and cc.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.leasing_contracts lc on a.contract_key = lc.contract_key and lc.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN (select crm_contract_cd, leasing_offer_key from dwh.crm_leasing_contracts
where valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) clc on lc.crm_contract_cd = clc.crm_contract_cd
LEFT JOIN (select leasing_offer_key, PRODUCT_NAM from dwh.leasing_offers
where valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) lo on lo.leasing_offer_key = clc.leasing_offer_key
LEFT JOIN dwh.RR_LGD_12 LGD_AVTO on LGD_AVTO.deal_type = lo.PRODUCT_NAM --LGD_AVTO
LEFT JOIN (select rc.contract_key, rc.ASSET_TYPE_COL from dwh.Risk_Ec_Contract_Data rc WHERE rc.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) rec on lc.contract_key = rec.contract_key
LEFT JOIN (select * from dwh.ref_lgd lgd where lgd_type_cd like '%RES%' and valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) LGD_CORP on rec.ASSET_TYPE_COL = LGD_CORP.leasing_subject_type_cd -- LGD_CORP
LEFT JOIN dwh.client_rating clr on a.client_key = clr.client_key and clr.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.credit_ratings crr on clr.Credit_rating_code = crr.credit_rating_cd and crr.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.Global_Watch_List_Status glw on a.client_key = glw.client_key and glw.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.ifrs_pd_avto pd_auto on glw.status = pd_auto.bunch_client_status
LEFT JOIN dwh.pd_corp pd_corp on pd_corp.rat_on_date = crr.credit_rating
where a.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
order by a.contract_app_key, t2.date_
;

