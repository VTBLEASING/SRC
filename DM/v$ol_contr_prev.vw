CREATE OR REPLACE FORCE VIEW DM.V$OL_CONTR_PREV AS
(
                          SELECT cn1.contract_key L_key,
                                 cn2.contract_key S_key,
                                 cn1.branch_key,
                                 cn1.Currency_Key L_CUR,                                      -- Валюта договора лизинга
                                 cn2.Currency_key S_CUR,                                      -- Валюта договора поставки
                                 OS.base_currency_key base_currency,
                                 cn1.valid_to_dttm,
                                 cn1.CONTRACT_ID_CD,
                                 cn1.client_key ,
                                 cn2.client_key CLIENT_SUPPLY_KEY,
                                 cl.business_category_key,
                                 cl.group_key,
                                 cl.grf_group_key,
                                 cl.member_key,
                                 cl.credit_rating_key,
                                 cgp_group.cgp_group_key,
                                 clndr.snapshot_dt
                          from dwh.contracts cn1
                          join DWH.CALENDAR clndr on 1=1
                          left join dwh.contracts cn2
                              ON cn1.contract_key = cn2.contract_leasing_key
                              and cn2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                              and cn2.open_dt <= clndr.snapshot_dt
                          inner join dwh.ORG_STRUCTURE OS                                      -- Для пересчета платежей код базовой валюты тянется из справочника структуры компании
                              ON OS.BRANCH_KEY = cn1.BRANCH_KEY
                          inner join dwh.cgp_group cgp_group                                   -- вяжемся с ручным справочником групп организаций для расчета потока для данной группы организаций
                              ON cn1.branch_key = cgp_group.branch_key
                              and cgp_group.begin_dt <= clndr.snapshot_dt
                              and cgp_group.end_dt > clndr.snapshot_dt
                          inner join dwh.clients cl
                              ON cl.client_key = cn1.client_key
                          inner join DWH.LEASING_CONTRACTS LC                                  -- Вяжемся со справчоником лизинговых контрактов для того, чтобы выбрать тип "Финансовый Лизинг"
                              ON cn1.contract_key = LC.contract_key
                          where  cn1.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and cl.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and LC.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and ((LC.contract_fin_kind_desc = 'ОперационнаяАренда'
                                       /*and cn1.branch_key in (                                       -- В случае Головного офиса выбирается 'ФинансовыйЛизинг'
                                                              select branch_key
                                                              from dwh.cgp_group cgp_group
                                                              where cgp_group.cgp_group_key = 2
                                                              and cgp_group.begin_dt <= clndr.snapshot_dt
                                                              and cgp_group.end_dt > clndr.snapshot_dt)*/
                                      )
                                       /* or
                                      (LC.contract_fin_kind_desc is Null                             -- В случае дочерних организаций выбирается Null
                                       and cn1.branch_key in (select branch_key
                                                              from dwh.cgp_group cgp_group
                                                              where cgp_group.cgp_group_key not in (2)
                                                              and cgp_group.begin_dt <= clndr.snapshot_dt
                                                              and cgp_group.end_dt > clndr.snapshot_dt)
                                       )*/)
                                -- and cl.cgp_flg = '1'                                                -- Договор КГП
                             --    and cgp_group.cgp_group_key = v_group_key
                                 and cn1.open_dt <= clndr.snapshot_dt
                                 and nvl(cn1.rehiring_flg, 0) != 1
                                 --and cn1.EXClUDE_CGP IS NULL
                          )
;

