CREATE OR REPLACE PROCEDURE DM."P_DM_CGP_DAILY_PRE" (
    p_REPORT_DT in date
)

is

BEGIN
    dm.u_log(p_proc => 'P_DM_CGP_DAILY',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT:'||p_REPORT_DT);

delete from DM.DM_CGP_DAILY
where SNAPSHOT_DT = p_REPORT_DT;
  dm.u_log(p_proc => 'DM.P_DM_CGP_DAILY',
           p_step => 'delete from DM.DM_CGP_DAILY',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

INSERT into DM.DM_CGP_DAILY (
                          SNAPSHOT_DT,
                          SNAPSHOT_MONTH,
                          CONTRACT_KEY,
                          CONTRACT_NUM,
                          CONTRACT_ID_CD,
                          app_num, --ov
                          INN,
                          SHORT_CLIENT_RU_NAM,
                          OGRN, --added by ovilkova 24/05/2018 due to 5611
                          TRANSMIT_SUBJECT_NAM,
                          LEASING_SUBJECT_KEY,
                          LEASING_DEAL_KEY,
                          LEASING_OFFER_KEY,
                          PRODUCT_NAM,
                          ACTUAL_FLG,
                          STATUS_1C_DESC,
                          CONTRACT_STATUS_KEY,
                          STATE_STATUS_KEY,
                          SUBJECT_STATUS_KEY,
                          CUR_LEAS_OVERDUE_DAYS,
                          MAX_LEAS_OVERDUE_DAYS,
                          MAX_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
                          AVG_LEAS_OVERDUE_DAYS,
                          AVG_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
                          CUR_ADV_OVERDUE_DAYS,
                          MAX_ADV_OVERDUE_DAYS,
                          AVG_ADV_OVERDUE_DAYS,
                          CUR_RED_OVERDUE_DAYS,
                          MAX_RED_OVERDUE_DAYS,
                          AVG_RED_OVERDUE_DAYS,
                          CUR_OTH_COM_OVERDUE_DAYS,
                          MAX_OTH_COM_OVERDUE_DAYS,
                          AVG_OTH_COM_OVERDUE_DAYS,
                          CUR_FIX_COM_OVERDUE_DAYS,
                          MAX_FIX_COM_OVERDUE_DAYS,
                          AVG_FIX_COM_OVERDUE_DAYS,
                          CUR_SUB_OVERDUE_DAYS,
                          MAX_SUB_OVERDUE_DAYS,
                          AVG_SUB_OVERDUE_DAYS,
                          CUR_ADD_INS_OVERDUE_DAYS,
                          MAX_ADD_INS_OVERDUE_DAYS,
                          AVG_ADD_INS_OVERDUE_DAYS,
                          CUR_INS_OVERDUE_DAYS,
                          MAX_INS_OVERDUE_DAYS,
                          AVG_INS_OVERDUE_DAYS,
                          CUR_REG_OVERDUE_DAYS,
                          MAX_REG_OVERDUE_DAYS,
                          AVG_REG_OVERDUE_DAYS,
                          CUR_FOR_OVERDUE_DAYS,
                          MAX_FOR_OVERDUE_DAYS,
                          AVG_FOR_OVERDUE_DAYS,
                          CUR_PEN_OVERDUE_DAYS,
                          MAX_PEN_OVERDUE_DAYS,
                          AVG_PEN_OVERDUE_DAYS,
                          CUR_OVR_OVERDUE_DAYS,
                          MAX_OVR_OVERDUE_DAYS,
                          AVG_OVR_OVERDUE_DAYS,
                          CUR_INSUR_OVERDUE_DAYS,
                          MAX_INSUR_OVERDUE_DAYS,
                          AVG_INSUR_OVERDUE_DAYS,
                          CUR_OTH_OVERDUE_DAYS,
                          MAX_OTH_OVERDUE_DAYS,
                          AVG_OTH_OVERDUE_DAYS,
                          LEASING_PAYMENTS_COUNT,
                          LEASING_PAYMENTS_COUNT_12, --[by ovilkova due to cross-checker 24/07/2017]
                          LEASING_PAYMENTS_SUM,
                          CUR_LEAS_OVERDUE_AMT,
                          CUR_ADV_OVERDUE_AMT,
                          CUR_RED_OVERDUE_AMT,
                          CUR_OTH_COM_OVERDUE_AMT,
                          CUR_FIX_COM_OVERDUE_AMT,
                          CUR_SUB_OVERDUE_AMT,
                          CUR_ADD_OVERDUE_AMT,
                          CUR_INS_OVERDUE_AMT,
                          CUR_REG_OVERDUE_AMT,
                          CUR_FOR_OVERDUE_AMT,
                          CUR_PEN_OVERDUE_AMT,
                          CUR_OVR_OVERDUE_AMT,
                          CUR_INSUR_OVERDUE_AMT,
                          CUR_OTH_OVERDUE_AMT,
                          OVERDUE_LEASING_PAYMENTS_COUNT,
                          LEAS_COUNT_12,  --[by ovilkova due to cross-checker 24/07/2017]
                          CUR_LEAS_OVERDUE_DT,
                          MAX_LEAS_PAY_DT,
                          TOTAL_LEAS_OVERDUE_DAYS,
                          CIS_OVERDUE_AMT,
                          CIS_OVERDUE_AMT_TAX,
                          CIS_TERM_AMT_RISK,
                          CIS_TERM_AMT,
                          CIS_TERM_AMT_TAX_RISK,
                          CIS_TERM_AMT_TAX,
                          NIL,
                          FINANCE_AMT,
                          GR_FIN_START_AMT,
                          CL_FIN_START_AMT,
                          GR_FIN_CUR_AMT,
                          CL_FIN_CUR_AMT,
                          PTS_FLG,
                          PTS_DT,
                          PTS_COMM,
                          NONEED,
                          INSERT_DT,
                          SUBPRODUCT_NAM,
                          LEASE_TERM_CNT,
                          end_dt, --[by ovilkova due to cross-checker 1/08/2017]
                          advance_rub, --[by ovilkova due to cross-checker 1/08/2017]
                          SUPPLY_RUB, --[by ovilkova due to cross-checker 1/08/2017]
                          balance, --[by ovilkova due to cross-checker 1/08/2017]
                          cr_ch_flg, --[by ovilkova due to cross-checker 1/08/2017]
                          U_MAX_LEAS_OVERDUE_DAYS,
                          U_MAX_LEAS_OVERDUE_DAYS_12,
                          U_AVG_LEAS_OVERDUE_DAYS,
                          U_AVG_LEAS_OVERDUE_DAYS_12,
                          U_MAX_ADV_OVERDUE_DAYS,
                          U_AVG_ADV_OVERDUE_DAYS,
                          U_MAX_RED_OVERDUE_DAYS,
                          U_AVG_RED_OVERDUE_DAYS,
                          U_MAX_OTH_COM_OVERDUE_DAYS,
                          U_AVG_OTH_COM_OVERDUE_DAYS,
                          U_MAX_FIX_COM_OVERDUE_DAYS,
                          U_AVG_FIX_COM_OVERDUE_DAYS,
                          U_MAX_SUB_OVERDUE_DAYS,
                          U_AVG_SUB_OVERDUE_DAYS,
                          U_MAX_ADD_INS_OVERDUE_DAYS,
                          U_AVG_ADD_INS_OVERDUE_DAYS,
                          U_MAX_INS_OVERDUE_DAYS,
                          U_AVG_INS_OVERDUE_DAYS,
                          U_MAX_REG_OVERDUE_DAYS,
                          U_AVG_REG_OVERDUE_DAYS,
                          U_MAX_FOR_OVERDUE_DAYS,
                          U_AVG_FOR_OVERDUE_DAYS,
                          U_MAX_PEN_OVERDUE_DAYS,
                          U_AVG_PEN_OVERDUE_DAYS,
                          U_MAX_OVR_OVERDUE_DAYS,
                          U_AVG_OVR_OVERDUE_DAYS,
                          U_MAX_INSUR_OVERDUE_DAYS,
                          U_AVG_INSUR_OVERDUE_DAYS,
                          U_MAX_OTH_OVERDUE_DAYS,
                          U_AVG_OTH_OVERDUE_DAYS,
                          U_TOTAL_LEAS_OVERDUE_DAYS
                        )

 with cgp as
            (
              select
                          p_REPORT_DT as snapshot_dt,
                          trunc (p_REPORT_DT, 'mm') as snapshot_month,
                          LC.contract_key,
                          LC.CONTRACT_NUM,
                          LC.CONTRACT_ID_CD,
                          lc.app_num, --ov
                          CL.INN,
                          CL.SHORT_CLIENT_RU_NAM,
                          CL.Ogrn, --added by ovilkova 24/05/2018 due to 5611
                          TT.TRANSMIT_SUBJECT_NAM,
                          LC.LEASING_SUBJECT_KEY,
                          LC.LEASING_DEAL_KEY,
                          LC.LEASING_OFFER_KEY,
                          P.PRODUCT_NAM,
                          SP.SUBPRODUCT_NAM,
                          LO.LEASE_TERM_CNT,
                          LC.ACTUAL_FLG,
                          WS.STATUS_1C_DESC,
                          WS.CONTRACT_STATUS_KEY,
                          WS.STATE_STATUS_KEY,
                          WS.SUBJECT_STATUS_KEY,

                          -- ���������� ���� ��������� �� ���. ��������, �������
                          max(case
                          when pi.payment_item_nam = '���������� ������ (� ���)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > case
                                                                             when par.param_type = 'ABS'
                                                                                  then param_val
                                                                             when par.param_type = 'PRC'
                                                                                  then param_val * DAILY.plan_amt
                                                                        end
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_LEAS_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ���. ��������, ������������
                          max (case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                else null
                          end) as MAX_LEAS_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ���. ��������, ������������ �� ��������� 12 ���. --[by ovilkova due to cross-checker 25/07/2017]
                          max (case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                   --and DAILY.plan_pay_dt_orig > (select add_months(to_date(p_REPORT_DT, 'dd.mm.yyyy'), -12) from dual)--[by ovilkova due to cross-checker 25/07/2017]
                                   and DAILY.plan_pay_dt_orig > add_months(p_REPORT_DT,-12)--[by ovilkova due to cross-checker 25/07/2017]
                                      then
                                            DAILY.overdue_days
                                else null
                          end) as MAX_LEAS_OVERDUE_DAYS_12,

                          -- ������� ���������� ���� ��������� �� ���������� ��������
                          round(AVG(case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       then
                                            DAILY.overdue_days
                               else null
                          end),2) as AVG_LEAS_OVERDUE_DAYS,

                          -- ������� ���������� ���� ��������� �� ���������� �������� --[by ovilkova due to cross-checker 25/07/2017]
                          round(AVG(case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                   --and DAILY.plan_pay_dt_orig > (select add_months(to_date(p_REPORT_DT, 'dd.mm.yyyy'), -12) from dual) --[by ovilkova due to cross-checker 25/07/2017]
                                   and DAILY.plan_pay_dt_orig > add_months(p_REPORT_DT,-12) --[by ovilkova due to cross-checker 25/07/2017]
                                       then
                                            DAILY.overdue_days
                               else null
                          end),2) as AVG_LEAS_OVERDUE_DAYS_12,

                          -- ���������� ���� ��������� �� ����� (� ���), �������
                          max(case
                          when pi.payment_item_nam = '����� (� ���)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_ADV_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� ����� (� ���), ������������
                          max (case
                                  when pi.payment_item_nam = '����� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_ADV_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ����� (� ���),�������
                          avg (case
                                  when pi.payment_item_nam = '����� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_ADV_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� �������� ��������� (� ���), �������
                          max(case
                          when pi.payment_item_nam = '�������� ��������� (� ���)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_RED_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� �������� ��������� (� ���), ������������
                          max (case
                                  when pi.payment_item_nam = '�������� ��������� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_RED_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� �������� ��������� (� ���),�������
                          avg (case
                                  when pi.payment_item_nam = '�������� ��������� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_RED_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ���� �������� �� ����. ������ (��������������� ��), �������
                          max(case
                          when pi.payment_item_nam = '���� �������� �� ����. ������ (��������������� ��)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_OTH_COM_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� ���� �������� �� ����. ������ (��������������� ��), ������������
                          max (case
                                  when pi.payment_item_nam = '���� �������� �� ����. ������ (��������������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_OTH_COM_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ���� �������� �� ����. ������ (��������������� ��),�������
                          avg (case
                                  when pi.payment_item_nam = '���� �������� �� ����. ������ (��������������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_OTH_COM_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� �������� �������������, �������
                          max(case
                          when pi.payment_item_nam = '�������� �������������'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_FIX_COM_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� �������� �������������, ������������
                          max (case
                                  when pi.payment_item_nam = '�������� �������������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_FIX_COM_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� �������� �������������,�������
                          avg (case
                                  when pi.payment_item_nam = '�������� �������������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_FIX_COM_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ��������������� ������ (��������), �������
                          max(case
                          when pi.payment_item_nam = '��������������� ������ (��������)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_SUB_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� ��������������� ������ (��������), ������������
                          max (case
                                  when pi.payment_item_nam = '��������������� ������ (��������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_SUB_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ��������������� ������ (��������),�������
                          avg (case
                                  when pi.payment_item_nam = '��������������� ������ (��������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_SUB_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ����������� ������ (���. ������), �������
                          max(case
                          when pi.payment_item_nam = '����������� ������ (���. ������)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_ADD_INS_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� ����������� ������ (���. ������), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (���. ������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_ADD_INS_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ����������� ������ (���. ������),�������
                          avg (case
                                  when pi.payment_item_nam = '����������� ������ (���. ������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_ADD_INS_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ����������� ������ (����������� ��), �������
                          max(case
                          when pi.payment_item_nam = '����������� ������ (����������� ��)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_INS_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� ����������� ������ (����������� ��), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (����������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_INS_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ����������� ������ (����������� ��),�������
                          avg (case
                                  when pi.payment_item_nam = '����������� ������ (����������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_INS_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ����������� ������ (������ ����������� �� � �����), �������
                          max(case
                          when pi.payment_item_nam = '����������� ������ (������ ����������� �� � �����)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_REG_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� ����������� ������ (������ ����������� �� � �����), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (������ ����������� �� � �����)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_REG_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ����������� ������ (������ ����������� �� � �����),�������
                          avg (case
                                  when pi.payment_item_nam = '����������� ������ (������ ����������� �� � �����)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_REG_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ����������� ������ (������ �� ��������� ���), �������
                          max(case
                          when pi.payment_item_nam = '����������� ������ (������ �� ��������� ���)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_FOR_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� ����������� ������ (������ �� ��������� ���), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (������ �� ��������� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_FOR_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ����������� ������ (������ �� ��������� ���),�������
                          avg (case
                                  when pi.payment_item_nam = '������������ ������ (������ �� ��������� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_FOR_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ����, �������
                          max(case
                          when pi.payment_item_nam = '����'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_PEN_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� ����, ������������
                          max (case
                                  when pi.payment_item_nam = '����'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_PEN_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ����,�������
                          avg (case
                                  when pi.payment_item_nam = '����'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_PEN_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ���������, �������
                          max(case
                          when pi.payment_item_nam = '���������'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_OVR_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� ���������, ������������
                          max (case
                                  when pi.payment_item_nam = '���������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_OVR_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ���������,�������
                          avg (case
                                  when pi.payment_item_nam = '���������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_OVR_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ��������� ����������, �������
                          max(case
                          when pi.payment_item_nam = '��������� ����������'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_INSUR_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� ��������� ����������, ������������
                          max (case
                                  when pi.payment_item_nam = '��������� ����������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_INSUR_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ��������� ����������,�������
                          avg (case
                                  when pi.payment_item_nam = '��������� ����������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_INSUR_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ������ �������, �������
                          max(case
                          when RPI.group_flg = 1
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_OTH_OVERDUE_DAYS,


                          -- ���������� ���� ��������� �� ������ �������, ������������
                          max (case
                                  when RPI.group_flg = 1
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_OTH_OVERDUE_DAYS,

                          -- ���������� ���� ��������� �� ������ �������,�������
                          avg (case
                                  when RPI.group_flg = 1
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_OTH_OVERDUE_DAYS,

                          -- ���������� ��������� ���������� ��������
                          count (distinct case
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                       and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and DAILY.pay_dt_orig <= p_REPORT_DT
                                       and DAILY.after_pay <= case --22/01/2018 ovilkova due to uakr correction
                                                                  when par.param_type = 'ABS'
                                                                      then param_val
                                                                  when par.param_type = 'PRC'
                                                                      then param_val * DAILY.plan_amt
                                                              end
                                           then DAILY.payment_num
                                       else null
                                end
                          ) as LEASING_PAYMENTS_COUNT,

                          -- ���������� ��������� ���������� �������� �� ��������� 12 ������� --[by ovilkova due to cross-checker 24/07/2017]
                          count (distinct case
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                       and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       --and DAILY.plan_pay_dt_orig > (select add_months(to_date(p_REPORT_DT, 'dd.mm.yyyy'), -12) from dual) --[by ovilkova due to cross-checker 25/07/2017]
                                       and DAILY.plan_pay_dt_orig > add_months(p_REPORT_DT,-12) --[by ovilkova due to cross-checker 25/07/2017]
                                       and DAILY.pay_dt_orig <= p_REPORT_DT
                                       and DAILY.after_pay <= case --22/01/2018 ovilkova due to uakr correction
                                                                  when par.param_type = 'ABS'
                                                                      then param_val
                                                                  when par.param_type = 'PRC'
                                                                      then param_val * DAILY.plan_amt
                                                              end
                                           then DAILY.payment_num
                                       else null
                                end
                          ) as LEASING_PAYMENTS_COUNT_12,

                          -- ����� ��������� ���������� ��������
                          sum (case
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                       and plan_pay_dt_orig <= p_REPORT_DT --22/01/2018 ovilkova due to uakr correction
                                       and pay_dt_orig <= p_REPORT_DT
                                           then fact_pay_amt
                                    else null
                          end) as LEASING_PAYMENTS_SUM,

                          --1 ������������ ������������� �� ���. ��������, �������
                          sum ( case
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and DAILY.after_pay > case
                                                                  when par.param_type = 'ABS'
                                                                      then param_val
                                                                  when par.param_type = 'PRC'
                                                                      then param_val * DAILY.plan_amt
                                                              end
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_LEAS_OVERDUE_AMT,

                          --2 ������������ ������������� �� ����� (� ���), �������
                          sum ( case
                                      when pi.payment_item_nam = '����� (� ���)'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_ADV_OVERDUE_AMT,

                          --3 ������������ ������������� �� �������� ��������� (� ���), �������
                          sum ( case
                                      when pi.payment_item_nam = '�������� ��������� (� ���)'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_RED_OVERDUE_AMT,

                          --4 ������������ ������������� �� ���� �������� �� ����. ������ (��������������� ��), �������
                          sum ( case
                                      when pi.payment_item_nam = '���� �������� �� ����. ������ (��������������� ��)'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_OTH_COM_OVERDUE_AMT,

                          --5 ������������ ������������� �� �������� �������������, �������
                          sum ( case
                                      when pi.payment_item_nam = '�������� �������������'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_FIX_COM_OVERDUE_AMT,

                          --6 ������������ ������������� �� ��������������� ������ (��������), �������
                          sum ( case
                                      when pi.payment_item_nam = '��������������� ������ (��������)'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_SUB_OVERDUE_AMT,

                          --7 ������������ ������������� �� ����������� ������ (���. ������), �������
                          sum ( case
                                      when pi.payment_item_nam = '����������� ������ (���. ������)'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_ADD_OVERDUE_AMT,

                          --8 ������������ ������������� �� ����������� ������ (����������� ��), �������
                          sum ( case
                                      when pi.payment_item_nam = '����������� ������ (����������� ��)'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_INS_OVERDUE_AMT,

                          --9 ������������ ������������� �� ����������� ������ (������ ����������� �� � �����), �������
                          sum ( case
                                      when pi.payment_item_nam = '����������� ������ (������ ����������� �� � �����)'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_REG_OVERDUE_AMT,

                          --10 ������������ ������������� �� ����������� ������ (������ �� ��������� ���), �������
                          sum ( case
                                      when pi.payment_item_nam = '����������� ������ (������ �� ��������� ���)'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_FOR_OVERDUE_AMT,

                          --11 ������������ ������������� �� ����, �������
                          sum ( case
                                      when pi.payment_item_nam = '����'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_PEN_OVERDUE_AMT,

                          --12 ������������ ������������� �� ���������, �������
                          sum ( case
                                      when pi.payment_item_nam = '���������'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_OVR_OVERDUE_AMT,

                          --13 ������������ ������������� �� ��������� ����������, �������
                          sum ( case
                                      when pi.payment_item_nam = '��������� ����������'
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_INSUR_OVERDUE_AMT,

                          --14 ������������ ������������� �� ������ �������, �������
                          sum ( case
                                      when RPI.group_flg = 1
                                        and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_OTH_OVERDUE_AMT,

                          -- ���������� ���������� �������� � ����������
                          count (distinct case
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                       and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and DAILY.after_pay > case
                                                                  when par.param_type = 'ABS'
                                                                      then param_val
                                                                  when par.param_type = 'PRC'
                                                                      then param_val * DAILY.plan_amt
                                                              end
                                       and pay_flg = 0
                                           then DAILY.payment_num
                                       else null
                                end
                          ) as OVERDUE_LEASING_PAYMENTS_COUNT,

                          -- ���������� ��� ��������� �� ���������� �������� �� ��������� 12 ���. --[by ovilkova due to cross-checker 25/07/2017]
                          count (distinct case
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                       and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       --and DAILY.plan_pay_dt_orig > (select add_months(to_date(p_REPORT_DT, 'dd.mm.yyyy'), -12) from dual) --[by ovilkova due to cross-checker 25/07/2017]
                                       and DAILY.plan_pay_dt_orig > add_months(p_REPORT_DT, -12) --[by ovilkova due to cross-checker 25/07/2017]
                                     /*  and DAILY.after_pay > case
                                                                  when par.param_type = 'ABS'
                                                                      then param_val
                                                                  when par.param_type = 'PRC'
                                                                      then param_val * DAILY.plan_amt
                                                              end*/ --ovilkova 02/08/2018
                                       --and pay_flg = 0
                                       and DAILY.overdue_days != 0
                                           then DAILY.overdue_days
                                       else null
                                end
                          ) as LEAS_COUNT_12  ,

                          -- ���� ������������� ������������ ������������� �� ���. ��������, �������
                          min (case
                          when pi.payment_item_nam = '���������� ������ (� ���)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then null
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > case
                                                                             when par.param_type = 'ABS'
                                                                                  then param_val
                                                                             when par.param_type = 'PRC'
                                                                                  then param_val * DAILY.plan_amt
                                                                        end
                                                        then DAILY.plan_pay_dt_orig
                                            else null
                                            end
                                      end
                          else null
                          end) as CUR_LEAS_OVERDUE_DT,

                          -- ���� ���������� ����������� �������
                          MAX (case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and plan_pay_dt_orig <= p_REPORT_DT
                                       then plan_pay_dt_orig
                               else null
                          end) as MAX_LEAS_PAY_DT,

                          -- ��������� ���������� ���� ��������� �� ���������� ��������
                          SUM(case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and pay_flg = 0
                                   and DAILY.overdue_days > 0
                                       then DAILY.overdue_days
                               else null
                          end) as TOTAL_LEAS_OVERDUE_DAYS,

                          -- ������������ ������������� ��� ��� ���
                          CGP.OVERDUE_AMT  as CIS_OVERDUE_AMT,

                          -- ������������ ������������� ��� � ���
                          CGP.OVERDUE_AMT_TAX  as CIS_OVERDUE_AMT_TAX,

                          -- ������� ������������� ��� ���, ��� ����� �������� (���)
                          CGP.TERM_AMT_RISK  as CIS_TERM_AMT_RISK,

                          -- ������� ������������� ��� ���, � ������ �������� (���)
                          CGP.TERM_AMT  as CIS_TERM_AMT,

                          -- ������� ������������� � ���, ��� ����� �������� (���)
                          CGP.TERM_AMT_TAX_RISK  as CIS_TERM_AMT_TAX_RISK,

                          -- ������� ������������� ��� ���, ��� ����� �������� (���)
                          CGP.TERM_AMT_TAX as CIS_TERM_AMT_TAX,

                          -- ����� ������������� �� NIL
                          nvl (CGP.OVERDUE_AMT_TAX, 0) + nvl (CGP.TERM_AMT_TAX, 0) as NIL,

                          -- ����� �������������� �� ��������, ��������������
                          TT.FINANCE_AMT,

                          -- ���������� ����� �������������� �� ������ �������� �� ������� ����, ��������������
                          TT.FIRST_FIN_AMT as GR_FIN_START_AMT,

                          -- ���������� ����� �������������� �� ������� �� ������� ����, ��������������
                          TT.FIRST_FIN_AMT_CLIENTS as CL_FIN_START_AMT,
                          decode(min(CFD.ACCEPT),0,'���',1,'��',null) as PTS_FLG,
                          min(CFD.VTBLDATE) as PTS_DT,
                          min(CFD."comment") as PTS_COMM,
                          decode(min(CFD.noneed),0,'���',1,'��',null) as NONEED,
                          SYSDATE as INSERT_DT,
                          LC.account_group_key,
                          LC.crm_client_key,
                         -- LC.end_dt, --[by ovilkova due to cross-checker 1/08/2017] ovilkova 26/12/2017
                          case when LC.end_dt = date'0001-01-01' then null
                               else LC.end_dt
                          end as end_dt,
                          TT.ADVANCE_RUB, --[by ovilkova due to cross-checker 1/08/2017]
                          TT.SUPPLY_RUB, --[by ovilkova due to cross-checker 1/08/2017]
                          (CGP.OVERDUE_AMT_TAX + CGP.TERM_AMT_TAX) as BALANCE, --[by ovilkova due to cross-checker 1/08/2017]
                          case
                            when /*LC.end_dt >=  add_months(p_REPORT_DT, -12) and */ LC.rehiring_flg = '���' --by ovilkova 01.11.2017 rehiring_flg will be deleted after Crosys testing
                              then 1 --ovilkova 19.12.2017 deleting end_date condition
                            else 0
                          end as cr_ch_flg


                           -- 1���������� ���� ��������� �� ���. ��������, ������������
                          ,max (case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                else null
                          end) as U_MAX_LEAS_OVERDUE_DAYS  ,

                                                   -- 2���������� ���� ��������� �� ���. ��������, ������������ �� ��������� 12 ���. --[by ovilkova due to cross-checker 25/07/2017]
                          max (case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                   --and DAILY.plan_pay_dt_orig > (select add_months(to_date(p_REPORT_DT, 'dd.mm.yyyy'), -12) from dual)--[by ovilkova due to cross-checker 25/07/2017]
                                   and DAILY.plan_pay_dt_orig > add_months(p_REPORT_DT,-12)--[by ovilkova due to cross-checker 25/07/2017]
                                      then
                                            --DAILY.overdue_days
                                           /* case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end*/
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                else null
                          end) as U_MAX_LEAS_OVERDUE_DAYS_12,

                          -- 3������� ���������� ���� ��������� �� ���������� ��������
                          round(AVG(case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                               else null
                          end),2) as U_AVG_LEAS_OVERDUE_DAYS,

                          -- 4������� ���������� ���� ��������� �� ���������� �������� --[by ovilkova due to cross-checker 25/07/2017]
                          round(AVG(case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                   --and DAILY.plan_pay_dt_orig > (select add_months(to_date(p_REPORT_DT, 'dd.mm.yyyy'), -12) from dual) --[by ovilkova due to cross-checker 25/07/2017]
                                   and DAILY.plan_pay_dt_orig > add_months(p_REPORT_DT,-12) --[by ovilkova due to cross-checker 25/07/2017]
                                       then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                               else null
                          end),2) as U_AVG_LEAS_OVERDUE_DAYS_12,



                          -- 5���������� ���� ��������� �� ����� (� ���), ������������
                          max (case
                                  when pi.payment_item_nam = '����� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                           /* case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_ADV_OVERDUE_DAYS,

                          -- 6���������� ���� ��������� �� ����� (� ���),�������
                          avg (case
                                  when pi.payment_item_nam = '����� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_ADV_OVERDUE_DAYS,

                          -- 7���������� ���� ��������� �� �������� ��������� (� ���), ������������
                          max (case
                                  when pi.payment_item_nam = '�������� ��������� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_RED_OVERDUE_DAYS,

                          -- 8���������� ���� ��������� �� �������� ��������� (� ���),�������
                          avg (case
                                  when pi.payment_item_nam = '�������� ��������� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_RED_OVERDUE_DAYS,


                          -- 9���������� ���� ��������� �� ���� �������� �� ����. ������ (��������������� ��), ������������
                          max (case
                                  when pi.payment_item_nam = '���� �������� �� ����. ������ (��������������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end*/
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_OTH_COM_OVERDUE_DAYS,

                          -- 10���������� ���� ��������� �� ���� �������� �� ����. ������ (��������������� ��),�������
                          avg (case
                                  when pi.payment_item_nam = '���� �������� �� ����. ������ (��������������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_OTH_COM_OVERDUE_DAYS,


                          -- 11���������� ���� ��������� �� �������� �������������, ������������
                          max (case
                                  when pi.payment_item_nam = '�������� �������������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_FIX_COM_OVERDUE_DAYS,

                          -- 12���������� ���� ��������� �� �������� �������������,�������
                          avg (case
                                  when pi.payment_item_nam = '�������� �������������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_FIX_COM_OVERDUE_DAYS,


                          -- 13���������� ���� ��������� �� ��������������� ������ (��������), ������������
                          max (case
                                  when pi.payment_item_nam = '��������������� ������ (��������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_SUB_OVERDUE_DAYS,

                          -- 14���������� ���� ��������� �� ��������������� ������ (��������),�������
                          avg (case
                                  when pi.payment_item_nam = '��������������� ������ (��������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_SUB_OVERDUE_DAYS,


                          -- 15���������� ���� ��������� �� ����������� ������ (���. ������), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (���. ������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_ADD_INS_OVERDUE_DAYS,

                          -- 16���������� ���� ��������� �� ����������� ������ (���. ������),�������
                          avg (case
                                  when pi.payment_item_nam = '����������� ������ (���. ������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_ADD_INS_OVERDUE_DAYS,

                          -- 17���������� ���� ��������� �� ����������� ������ (����������� ��), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (����������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_INS_OVERDUE_DAYS,

                          -- 18���������� ���� ��������� �� ����������� ������ (����������� ��),�������
                          avg (case
                                  when pi.payment_item_nam = '����������� ������ (����������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_INS_OVERDUE_DAYS,


                          -- 19���������� ���� ��������� �� ����������� ������ (������ ����������� �� � �����), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (������ ����������� �� � �����)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_REG_OVERDUE_DAYS,

                          -- 20���������� ���� ��������� �� ����������� ������ (������ ����������� �� � �����),�������
                          avg (case
                                  when pi.payment_item_nam = '����������� ������ (������ ����������� �� � �����)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_REG_OVERDUE_DAYS,


                          -- 21���������� ���� ��������� �� ����������� ������ (������ �� ��������� ���), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (������ �� ��������� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_FOR_OVERDUE_DAYS,

                          -- 22���������� ���� ��������� �� ����������� ������ (������ �� ��������� ���),�������
                          avg (case
                                  when pi.payment_item_nam = '������������ ������ (������ �� ��������� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_FOR_OVERDUE_DAYS,


                          -- 23���������� ���� ��������� �� ����, ������������
                          max (case
                                  when pi.payment_item_nam = '����'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_PEN_OVERDUE_DAYS,

                          -- 24���������� ���� ��������� �� ����,�������
                          avg (case
                                  when pi.payment_item_nam = '����'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_PEN_OVERDUE_DAYS,

                          -- 25���������� ���� ��������� �� ���������, ������������
                          max (case
                                  when pi.payment_item_nam = '���������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_OVR_OVERDUE_DAYS,

                          -- 26���������� ���� ��������� �� ���������,�������
                          avg (case
                                  when pi.payment_item_nam = '���������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_OVR_OVERDUE_DAYS,


                          -- 27���������� ���� ��������� �� ��������� ����������, ������������
                          max (case
                                  when pi.payment_item_nam = '��������� ����������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_INSUR_OVERDUE_DAYS,

                          -- 28���������� ���� ��������� �� ��������� ����������,�������
                          avg (case
                                  when pi.payment_item_nam = '��������� ����������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_INSUR_OVERDUE_DAYS,


                          -- 29���������� ���� ��������� �� ������ �������, ������������
                          max (case
                                  when RPI.group_flg = 1
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_MAX_OTH_OVERDUE_DAYS,

                          -- 30���������� ���� ��������� �� ������ �������,�������
                          avg (case
                                  when RPI.group_flg = 1
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            --DAILY.overdue_days
                                            /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                                      else null
                          end) as U_AVG_OTH_OVERDUE_DAYS,


                          -- 31��������� ���������� ���� ��������� �� ���������� ��������
                          SUM(case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and pay_flg = 0
                                   and DAILY.overdue_days > 0
                                       then --DAILY.overdue_days
                                         /*case when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                 else DAILY.overdue_days
                                            end */
                                            --DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT) --22/01/2018 ovilkova due to uakr correction
                                            case when daily.pay_dt_orig <= p_REPORT_DT then DAILY.overdue_days --22/01/2018 ovilkova due to uakr correction
                                                when daily.pay_dt_orig is null then   (DAILY.overdue_days - (trunc(sysdate) - p_REPORT_DT))
                                                when daily.pay_dt_orig > p_REPORT_DT then (p_REPORT_DT - daily.plan_pay_dt_orig)
                                            end
                               else null
                          end) as U_TOTAL_LEAS_OVERDUE_DAYS,
                          --����������
                          row_number() over(partition by LC.CONTRACT_NUM
                                          order by max (
                                                             case
                                                                 when lc.rehiring_flg='��' then lc.rehiring_end_dt
                                                                 else  nvl(plan_pay_dt_orig,to_date('01.01.0001','dd.mm.yyyy'))
                                                             end
                                                        ) desc
                                ) rn --����������

              from
                    DWHRO.V_UAKR_LEASING_CONTRACTS LC
              LEFT JOIN DM.DM_TRANSMIT_SUBJECTS TT
                    On TT.CONTRACT_ID_CD = LC.CONTRACT_ID_CD
              left join dwh.leasing_subjects ls
                     ON     tt.leasing_subject_key =
                               ls.leasing_subject_key
                        AND ls.valid_to_dttm =
                               TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                        AND ls.end_dt = to_date ('31.12.3999', 'dd.mm.yyyy')
              LEFT JOIN dwh.products p
                     ON     ls.product_key = p.product_key
                        AND p.valid_to_dttm =
                               TO_DATE ('01.01.2400', 'DD.MM.YYYY')
              LEFT JOIN dwh.subproducts sp
                     ON     ls.SUBPRODUCT_KEY = sp.SUBPRODUCT_KEY
                        AND sp.valid_to_dttm =
                               TO_DATE ('01.01.2400', 'DD.MM.YYYY')
              left join dwh.leasing_offers lo
                     ON     lc.leasing_offer_key =
                               lo.leasing_offer_key
                        AND lo.valid_to_dttm =
                               TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                        AND lo.end_dt = to_date ('31.12.3999', 'dd.mm.yyyy')
              LEFT JOIN dwh.clients CL
                    ON LC.CLIENT_KEY = CL.CLIENT_KEY
                   AND CL.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
              LEFT JOIN DM.DM_DETAILS_DAILY DAILY
                    ON LC.CONTRACT_KEY = DAILY.CONTRACT_KEY
              LEFT JOIN (select CRM_CONTRACT_CD,min(TCF.ACCEPT) as ACCEPT ,min(TCF."comment") as "comment",min(TCF.VTBLDATE) as VTBLDATE, min(TCF.NONEED) as NONEED from DWH.CRM_CONTROLOFDOC tcf
              where tcf.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
              group by tcf.CRM_CONTRACT_CD) CFD
                  --  dm.tmp$CRM_CONTROLOFDOC_agr CFD
                    ON LC.CRM_CONTRACT_CD = CFD.CRM_CONTRACT_CD
                   --AND CFD.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
              LEFT JOIN dwh.PAYMENT_ITEMS PI
                    ON DAILY.PAYMENT_ITEM_KEY = PI.PAYMENT_ITEM_KEY
                   AND PI.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
              LEFT JOIN dwh.REF_PAYMENT_ITEMS RPI
                    ON PI.PAYMENT_ITEM_NAM = RPI.PAYMENT_ITEM_NAM
              LEFT JOIN DWHRO.V_UAKR_CGP CGP
                    ON DAILY.CONTRACT_KEY = CGP.CONTRACT_KEY
                   AND CGP.SNAPSHOT_DT = case
                                              when p_REPORT_DT = last_day (p_REPORT_DT)
                                                  then  p_REPORT_DT
                                              else trunc (p_REPORT_DT, 'mm') - 1
                                         end
              LEFT JOIN DWH.CGP_DAILY_PARAMS par
                    ON 1 = 1
                   AND par.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
              LEFT JOIN DM.DM_WORK_STATUSES WS
                    ON DAILY.CONTRACT_KEY = WS.CONTRACT_KEY
                   AND p_REPORT_DT = WS.REPORT_DT
              --where daily.contract_key =  1836
              GROUP BY  LC.contract_key,
                        LC.CONTRACT_NUM,
                        LC.CONTRACT_ID_CD,
                        lc.app_num, --ov
                        CL.INN,
                        CL.SHORT_CLIENT_RU_NAM,
                        CL.OGRN,
                        TT.TRANSMIT_SUBJECT_NAM,
                        LC.LEASING_SUBJECT_KEY,
                        LC.LEASING_DEAL_KEY,
                        LC.LEASING_OFFER_KEY,
                        P.PRODUCT_NAM,
                        SP.SUBPRODUCT_NAM,
                        LO.LEASE_TERM_CNT,
                        LC.ACTUAL_FLG,
                        WS.STATUS_1C_DESC,
                        WS.CONTRACT_STATUS_KEY,
                        WS.STATE_STATUS_KEY,
                        WS.SUBJECT_STATUS_KEY,
                        CGP.OVERDUE_AMT,
                        CGP.OVERDUE_AMT_TAX,
                        CGP.TERM_AMT_RISK,
                        CGP.TERM_AMT,
                        CGP.TERM_AMT_TAX_RISK,
                        CGP.TERM_AMT_TAX,
                        nvl (CGP.OVERDUE_AMT_TAX, 0) + nvl (CGP.TERM_AMT_TAX, 0),
                        TT.FINANCE_AMT,
                        TT.FIRST_FIN_AMT,
                        TT.FIRST_FIN_AMT_CLIENTS,
                        LC.account_group_key,
                        LC.crm_client_key,
                        LC.end_dt,
                        LC.rehiring_flg, --by ovilkova 01.11.2017 will be deleted later after Crosys test
                        TT.ADVANCE_RUB,
                        TT.Supply_Rub
              )
select
        SNAPSHOT_DT,
        SNAPSHOT_MONTH,
        CONTRACT_KEY,
        CONTRACT_NUM,
        CONTRACT_ID_CD,
        app_num, --ov
        INN,
        SHORT_CLIENT_RU_NAM,
        OGRN, --added by ovilkova 24/05/2018 due to 5611
        TRANSMIT_SUBJECT_NAM,
        LEASING_SUBJECT_KEY,
        LEASING_DEAL_KEY,
        LEASING_OFFER_KEY,
        PRODUCT_NAM,
        ACTUAL_FLG,
        STATUS_1C_DESC,
        CONTRACT_STATUS_KEY,
        STATE_STATUS_KEY,
        SUBJECT_STATUS_KEY,
        CUR_LEAS_OVERDUE_DAYS,
        MAX_LEAS_OVERDUE_DAYS,
        MAX_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
        AVG_LEAS_OVERDUE_DAYS,
        AVG_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
        CUR_ADV_OVERDUE_DAYS,
        MAX_ADV_OVERDUE_DAYS,
        AVG_ADV_OVERDUE_DAYS,
        CUR_RED_OVERDUE_DAYS,
        MAX_RED_OVERDUE_DAYS,
        AVG_RED_OVERDUE_DAYS,
        CUR_OTH_COM_OVERDUE_DAYS,
        MAX_OTH_COM_OVERDUE_DAYS,
        AVG_OTH_COM_OVERDUE_DAYS,
        CUR_FIX_COM_OVERDUE_DAYS,
        MAX_FIX_COM_OVERDUE_DAYS,
        AVG_FIX_COM_OVERDUE_DAYS,
        CUR_SUB_OVERDUE_DAYS,
        MAX_SUB_OVERDUE_DAYS,
        AVG_SUB_OVERDUE_DAYS,
        CUR_ADD_INS_OVERDUE_DAYS,
        MAX_ADD_INS_OVERDUE_DAYS,
        AVG_ADD_INS_OVERDUE_DAYS,
        CUR_INS_OVERDUE_DAYS,
        MAX_INS_OVERDUE_DAYS,
        AVG_INS_OVERDUE_DAYS,
        CUR_REG_OVERDUE_DAYS,
        MAX_REG_OVERDUE_DAYS,
        AVG_REG_OVERDUE_DAYS,
        CUR_FOR_OVERDUE_DAYS,
        MAX_FOR_OVERDUE_DAYS,
        AVG_FOR_OVERDUE_DAYS,
        CUR_PEN_OVERDUE_DAYS,
        MAX_PEN_OVERDUE_DAYS,
        AVG_PEN_OVERDUE_DAYS,
        CUR_OVR_OVERDUE_DAYS,
        MAX_OVR_OVERDUE_DAYS,
        AVG_OVR_OVERDUE_DAYS,
        CUR_INSUR_OVERDUE_DAYS,
        MAX_INSUR_OVERDUE_DAYS,
        AVG_INSUR_OVERDUE_DAYS,
        CUR_OTH_OVERDUE_DAYS,
        MAX_OTH_OVERDUE_DAYS,
        AVG_OTH_OVERDUE_DAYS,
        LEASING_PAYMENTS_COUNT,
        LEASING_PAYMENTS_COUNT_12, --[by ovilkova due to cross-checker 24/07/2017]
        LEASING_PAYMENTS_SUM,
        CUR_LEAS_OVERDUE_AMT,
        CUR_ADV_OVERDUE_AMT,
        CUR_RED_OVERDUE_AMT,
        CUR_OTH_COM_OVERDUE_AMT,
        CUR_FIX_COM_OVERDUE_AMT,
        CUR_SUB_OVERDUE_AMT,
        CUR_ADD_OVERDUE_AMT,
        CUR_INS_OVERDUE_AMT,
        CUR_REG_OVERDUE_AMT,
        CUR_FOR_OVERDUE_AMT,
        CUR_PEN_OVERDUE_AMT,
        CUR_OVR_OVERDUE_AMT,
        CUR_INSUR_OVERDUE_AMT,
        CUR_OTH_OVERDUE_AMT,
        OVERDUE_LEASING_PAYMENTS_COUNT,
        LEAS_COUNT_12,  --[by ovilkova due to cross-checker 24/07/2017]
        CUR_LEAS_OVERDUE_DT,
        MAX_LEAS_PAY_DT,
        TOTAL_LEAS_OVERDUE_DAYS,
        CIS_OVERDUE_AMT,
        CIS_OVERDUE_AMT_TAX,
        CIS_TERM_AMT_RISK,
        CIS_TERM_AMT,
        CIS_TERM_AMT_TAX_RISK,
        CIS_TERM_AMT_TAX,
        NIL,
        FINANCE_AMT,
        GR_FIN_START_AMT,
        CL_FIN_START_AMT,
        -- ���������� ����� �������������� �� ������ �������� �� ������� ����, ���., �������
        SUM (NIL) OVER (PARTITION BY nvl (account_group_key, contract_key)) as GR_FIN_CUR_AMT,

        -- ���������� ����� �������������� �� ������� �� ������� ����, ���., �������
        SUM (NIL) OVER (PARTITION BY crm_client_key) as CL_FIN_CUR_AMT,
        --PTS_FLG, --����������
        --PTS_DT,  --����������
        --PTS_COMM, --����������
        --NONEED,   --����������
        decode(rn,1,PTS_FLG,null) PTS_FLG, --����������
        decode(rn,1,PTS_DT,null) PTS_DT, --����������
        decode(rn,1,PTS_COMM,null) PTS_COMM, --����������
        decode(rn,1,NONEED,null) NONEED, --����������
        INSERT_DT,
        SUBPRODUCT_NAM,
        LEASE_TERM_CNT,
        end_dt, --[by ovilkova due to cross-checker 1/08/2017]
        ADVANCE_RUB, --[by ovilkova due to cross-checker 1/08/2017]
        SUPPLY_RUB, --[by ovilkova due to cross-checker 1/08/2017]
        BALANCE, --[by ovilkova due to cross-checker 1/08/2017]
        cr_ch_flg, --[by ovilkova due to cross-checker 1/08/2017]
        U_MAX_LEAS_OVERDUE_DAYS,
        U_MAX_LEAS_OVERDUE_DAYS_12,
        U_AVG_LEAS_OVERDUE_DAYS,
        U_AVG_LEAS_OVERDUE_DAYS_12,
        U_MAX_ADV_OVERDUE_DAYS,
        U_AVG_ADV_OVERDUE_DAYS,
        U_MAX_RED_OVERDUE_DAYS,
        U_AVG_RED_OVERDUE_DAYS,
        U_MAX_OTH_COM_OVERDUE_DAYS,
        U_AVG_OTH_COM_OVERDUE_DAYS,
        U_MAX_FIX_COM_OVERDUE_DAYS,
        U_AVG_FIX_COM_OVERDUE_DAYS,
        U_MAX_SUB_OVERDUE_DAYS,
        U_AVG_SUB_OVERDUE_DAYS,
        U_MAX_ADD_INS_OVERDUE_DAYS,
        U_AVG_ADD_INS_OVERDUE_DAYS,
        U_MAX_INS_OVERDUE_DAYS,
        U_AVG_INS_OVERDUE_DAYS,
        U_MAX_REG_OVERDUE_DAYS,
        U_AVG_REG_OVERDUE_DAYS,
        U_MAX_FOR_OVERDUE_DAYS,
        U_AVG_FOR_OVERDUE_DAYS,
        U_MAX_PEN_OVERDUE_DAYS,
        U_AVG_PEN_OVERDUE_DAYS,
        U_MAX_OVR_OVERDUE_DAYS,
        U_AVG_OVR_OVERDUE_DAYS,
        U_MAX_INSUR_OVERDUE_DAYS,
        U_AVG_INSUR_OVERDUE_DAYS,
        U_MAX_OTH_OVERDUE_DAYS,
        U_AVG_OTH_OVERDUE_DAYS,
        U_TOTAL_LEAS_OVERDUE_DAYS
from cgp;
   dm.u_log(p_proc => 'DM.P_DM_CGP_DAILY',
           p_step => 'INSERT into DM.DM_CGP_DAILY',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');
commit;

end;
/

