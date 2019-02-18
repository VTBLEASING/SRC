CREATE OR REPLACE PROCEDURE DM.P_DM_NIL_PERIOD (P_REPORT_DT in date)
IS
BEGIN

delete from DM.DM_NIL_PERIOD where snapshot_dt = p_REPORT_DT;


INSERT INTO DM_NIL_PERIOD
(CONTRACT_ID_CD,
BRANCH_NAM,
SNAPSHOT_DT,
F1,
F2,
F3,
F4,
F5,
F6,
F7,
F8,
F9,
F10,
F11,
F12,
F13,
F14,
F15,
F16,
F17,
F18,
F19,
F20,
F21,
F22,
F23,
F24,
F25,
F26,
F27,
F28,
F29,
F30,
F31,
F32,
F33,
F34,
F35,
F36,
F37,
F38,
F39,
F40,
F41,
F42,
F43,
F44,
F45,
F46,
F47,
F48,
F49,
F50,
F51,
F52,
F53,
F54,
F55,
F56,
F57,
F58,
F59,
F60,
F61,
F62,
F63,
F64,
F65,
F66,
F67,
F68,
F69,
F70,
F71,
F72,
F73,
F74,
F75,
F76,
F77,
F78,
F79,
F80,
F81,
F82,
F83,
F84,
F85,
F86,
F87,
F88,
F89,
F90,
F91,
F92,
F93,
F94,
F95,
F96,
F97,
F98,
F99,
F100,
F101,
F102,
F103,
F104,
F105,
F106,
F107,
F108,
F109,
F110,
F111,
F112,
F113,
F114,
F115,
F116,
F117,
F118,
F119,
F120,
F121,
F122,
F123,
F124,
F125,
F126,
F127,
F128,
F129,
F130,
F131,
F132,
F133,
F134,
F135,
F136,
F137,
F138,
F139,
F140,
F141,
F142,
F143,
F144,
F145,
F146,
F147,
F148,
F149,
F150,
F151,
F152,
F153,
F154,
F155,
F156,
F157,
F158,
F159,
F160,
F161,
F162,
F163,
F164,
F165,
F166,
F167,
F168,
F169,
F170,
F171,
F172,
F173,
F174,
F175,
F176,
F177,
F178,
F179,
F180,
F181,
F182,
F183,
F184,
F185,
F186,
F187,
F188,
F189,
F190,
F191,
F192,
F193,
F194,
F195,
F196,
F197,
F198,
F199,
F200,
F201,
F202,
F203,
F204,
F205,
F206,
F207,
F208,
F209,
F210,
F211,
F212,
F213,
F214,
F215,
F216,
F217,
F218,
F219,
F220,
F221,
F222,
F223,
F224,
F225,
F226,
F227,
F228,
F229,
F230,
F231,
F232,
F233,
F234,
F235,
F236,
F237,
F238,
F239,
F240,
F241,
F242,
F243,
F244,
F245,
F246,
F247,
F248,
F249,
F250,
F251,
F252,
F253,
F254,
F255,
F256,
F257,
F258,
F259,
F260,
F261,
F262,
F263,
F264,
F265,
F266,
F267,
F268,
F269,
F270,
F271,
F272,
F273,
F274,
F275,
F276,
F277,
F278,
F279,
F280,
F281,
F282,
F283,
F284,
F285,
F286,
F287,
F288,
F289,
F290,
F291,
F292,
F293,
F294,
F295,
F296,
F297,
F298,
F299,
F300,
F301,
F302,
F303,
F304,
F305,
F306,
F307,
F308,
F309,
F310,
F311,
F312,
F313,
F314,
F315,
F316,
F317,
F318,
F319,
F320,
F321,
F322,
F323,
F324,
F325,
F326,
F327,
F328,
F329,
F330,
F331,
F332,
F333,
F334,
F335,
F336,
F337,
F338,
F339,
F340,
F341,
F342,
F343,
F344,
F345,
F346,
F347,
F348,
F349,
F350,
F351,
F352,
F353,
F354,
F355,
F356,
F357,
F358,
F359,
F360,
F361,
F362,
F363,
F364,
F365,
F366,
F367,
F368,
F369,
F370,
F371,
F372,
F373,
F374,
F375,
F376,
F377,
F378,
F379,
F380,
F381,
F382,
F383,
F384,
F385,
F386,
F387,
F388,
F389,
F390,
F391,
F392,
F393,
F394,
F395,
F396,
F397,
F398,
F399,
F400,
F401,
F402,
F403,
F404,
F405,
F406,
F407,
F408,
F409,
F410,
F411,
F412,
F413,
F414,
F415,
F416,
F417,
F418,
F419,
F420,
F421,
F422,
F423,
F424,
F425,
F426,
F427,
F428,
F429,
F430,
F431,
F432,
F433,
F434,
F435,
F436,
F437,
F438,
F439,
F440,
F441,
F442,
F443,
F444,
F445,
F446,
F447,
F448,
F449,
F450,
F451,
F452,
F453,
F454,
F455,
F456,
F457,
F458,
F459,
F460,
F461,
F462,
F463,
F464,
F465,
F466,
F467,
F468,
F469,
F470,
F471,
F472,
F473,
F474,
F475,
F476,
F477,
F478,
F479,
F480,
F481,
F482,
F483,
F484,
F485,
F486,
F487,
F488,
F489,
F490,
F491,
F492,
F493,
F494,
F495,
F496,
F497,
F498,
F499,
F500,
F501,
F502,
F503,
F504,
F505,
F506,
F507,
F508,
F509,
F510,
F511,
F512,
F513,
F514,
F515,
F516,
F517,
F518,
F519,
F520,
F521,
F522,
F523,
F524,
F525,
F526,
F527,
F528,
F529,
F530,
F531,
F532,
F533,
F534,
F535,
F536,
F537,
F538,
F539,
F540,
F541,
F542,
F543,
F544,
F545,
F546,
F547,
F548,
F549,
F550,
F551,
F552,
F553,
F554,
F555,
F556,
F557,
F558,
F559,
F560,
F561,
F562,
F563,
F564,
F565,
F566,
F567,
F568,
F569,
F570,
F571,
F572,
F573,
F574,
F575,
F576,
F577,
F578,
F579,
F580,
F581,
F582,
F583,
F584,
F585,
F586,
F587,
F588,
F589,
F590,
F591,
F592,
F593,
F594,
F595,
F596,
F597,
F598,
F599,
F600,
F601,
F602,
F603,
F604,
F605,
F606,
F607,
F608,
F609,
F610,
F611,
F612,
F613,
F614,
F615,
F616,
F617,
F618,
F619,
F620,
F621,
F622,
F623,
F624,
F625,
F626,
F627,
F628,
F629,
F630,
F631,
F632,
F633,
F634,
F635,
F636,
F637,
F638,
F639,
F640,
F641,
F642,
F643,
F644,
F645,
F646,
F647,
F648,
F649,
F650,
F651,
F652,
F653,
F654,
F655,
F656,
F657,
F658,
F659,
F660,
F661,
F662,
F663,
F664,
F665,
F666,
F667,
F668,
F669,
F670,
F671,
F672,
F673,
F674,
F675,
F676,
F677,
F678,
F679,
F680,
F681,
F682,
F683,
F684,
F685,
F686,
F687,
F688,
F689,
F690,
F691,
F692,
F693,
F694,
F695,
F696,
F697,
F698,
F699,
F700,
RN
)
with tt0 as
(
select /*+ materialized */ 
pay_dt,BRANCH_NAM,contract_id_cd,period,SNAPSHOT_DT,p_nil
from (
select trunc(t.pay_dt, 'MONTH') +1/(24*60*60) pay_dt, t3.BRANCH_NAM, t2.contract_id_cd,  'M' as period  
,t.snapshot_dt
,to_number(max(t.dnil_amt)) p_nil
from dm.dm_repayment_schedule t
left join dwh.contracts t2 on t2.valid_to_dttm>sysdate+100 and t2.contract_key=t.contract_key
left join dwh.org_structure t3 on t3.branch_key=t.BRANCH_KEY and t3.VALID_TO_DTTM>sysdate+100
where 1=1 
and t.snapshot_dt=P_REPORT_DT
group by 
trunc(t.pay_dt, 'MONTH') +1/(24*60*60) , t3.BRANCH_NAM, t2.contract_id_cd  
,t.snapshot_dt
union all 
select trunc(add_months(trunc(t.pay_dt, 'Q'),3)-1,'MONTH') +2/(24*60*60), t3.BRANCH_NAM, t2.contract_id_cd,  'Q' as period  
,t.snapshot_dt
,to_number(max(t.dnil_amt)) p_nil
from dm.dm_repayment_schedule t
left join dwh.contracts t2 on t2.valid_to_dttm>sysdate+100 and t2.contract_key=t.contract_key
left join dwh.org_structure t3 on t3.branch_key=t.BRANCH_KEY and t3.VALID_TO_DTTM>sysdate+100
where 1=1
and t.snapshot_dt=P_REPORT_DT
group by 
trunc(add_months(trunc(t.pay_dt, 'Q'),3)-1,'MONTH') +2/(24*60*60), t3.BRANCH_NAM, t2.contract_id_cd
,t.snapshot_dt
union all 
select trunc(add_months(trunc(t.pay_dt, 'YEAR'),12)-1,'MONTH') +3/(24*60*60) , t3.BRANCH_NAM, t2.contract_id_cd, 'Y' as period
,t.snapshot_dt
,to_number(max(t.dnil_amt)) as p_nil
from dm.dm_repayment_schedule t
left join dwh.contracts t2 on t2.valid_to_dttm>sysdate+100 and t2.contract_key=t.contract_key
left join dwh.org_structure t3 on t3.branch_key=t.BRANCH_KEY and t3.VALID_TO_DTTM>sysdate+100
where 1=1 
and t.snapshot_dt=P_REPORT_DT
group by 
 trunc(add_months(trunc(t.pay_dt, 'YEAR'),12)-1,'MONTH') +3/(24*60*60) , t3.BRANCH_NAM, t2.contract_id_cd, 'Y'  
,t.snapshot_dt                     
)
--where contract_id_cd = '36106/02-15 СПБ'
)
,tt1 as
(
    select 
    SNAPSHOT_DT, pay_dt date_
    ,row_number() over (partition by   a.SNAPSHOT_DT order by a.pay_dt) rn
    from (select distinct SNAPSHOT_DT,pay_dt from tt0 ) a
)
,tt2 as
(
    select b.SNAPSHOT_DT, 
    max(decode(a.f1,1,b.date_,null)) f1,
    max(decode(a.f2,1,b.date_,null)) f2,
    max(decode(a.f3,1,b.date_,null)) f3,
    max(decode(a.f4,1,b.date_,null)) f4,
    max(decode(a.f5,1,b.date_,null)) f5,
    max(decode(a.f6,1,b.date_,null)) f6,
    max(decode(a.f7,1,b.date_,null)) f7,
    max(decode(a.f8,1,b.date_,null)) f8,
    max(decode(a.f9,1,b.date_,null)) f9,
    max(decode(a.f10,1,b.date_,null)) f10,
    max(decode(a.f11,1,b.date_,null)) f11,
    max(decode(a.f12,1,b.date_,null)) f12,
    max(decode(a.f13,1,b.date_,null)) f13,
    max(decode(a.f14,1,b.date_,null)) f14,
    max(decode(a.f15,1,b.date_,null)) f15,
    max(decode(a.f16,1,b.date_,null)) f16,
    max(decode(a.f17,1,b.date_,null)) f17,
    max(decode(a.f18,1,b.date_,null)) f18,
    max(decode(a.f19,1,b.date_,null)) f19,
    max(decode(a.f20,1,b.date_,null)) f20,
    max(decode(a.f21,1,b.date_,null)) f21,
    max(decode(a.f22,1,b.date_,null)) f22,
    max(decode(a.f23,1,b.date_,null)) f23,
    max(decode(a.f24,1,b.date_,null)) f24,
    max(decode(a.f25,1,b.date_,null)) f25,
    max(decode(a.f26,1,b.date_,null)) f26,
    max(decode(a.f27,1,b.date_,null)) f27,
    max(decode(a.f28,1,b.date_,null)) f28,
    max(decode(a.f29,1,b.date_,null)) f29,
    max(decode(a.f30,1,b.date_,null)) f30,
    max(decode(a.f31,1,b.date_,null)) f31,
    max(decode(a.f32,1,b.date_,null)) f32,
    max(decode(a.f33,1,b.date_,null)) f33,
    max(decode(a.f34,1,b.date_,null)) f34,
    max(decode(a.f35,1,b.date_,null)) f35,
    max(decode(a.f36,1,b.date_,null)) f36,
    max(decode(a.f37,1,b.date_,null)) f37,
    max(decode(a.f38,1,b.date_,null)) f38,
    max(decode(a.f39,1,b.date_,null)) f39,
    max(decode(a.f40,1,b.date_,null)) f40,
    max(decode(a.f41,1,b.date_,null)) f41,
    max(decode(a.f42,1,b.date_,null)) f42,
    max(decode(a.f43,1,b.date_,null)) f43,
    max(decode(a.f44,1,b.date_,null)) f44,
    max(decode(a.f45,1,b.date_,null)) f45,
    max(decode(a.f46,1,b.date_,null)) f46,
    max(decode(a.f47,1,b.date_,null)) f47,
    max(decode(a.f48,1,b.date_,null)) f48,
    max(decode(a.f49,1,b.date_,null)) f49,
    max(decode(a.f50,1,b.date_,null)) f50,
    max(decode(a.f51,1,b.date_,null)) f51,
    max(decode(a.f52,1,b.date_,null)) f52,
    max(decode(a.f53,1,b.date_,null)) f53,
    max(decode(a.f54,1,b.date_,null)) f54,
    max(decode(a.f55,1,b.date_,null)) f55,
    max(decode(a.f56,1,b.date_,null)) f56,
    max(decode(a.f57,1,b.date_,null)) f57,
    max(decode(a.f58,1,b.date_,null)) f58,
    max(decode(a.f59,1,b.date_,null)) f59,
    max(decode(a.f60,1,b.date_,null)) f60,
    max(decode(a.f61,1,b.date_,null)) f61,
    max(decode(a.f62,1,b.date_,null)) f62,
    max(decode(a.f63,1,b.date_,null)) f63,
    max(decode(a.f64,1,b.date_,null)) f64,
    max(decode(a.f65,1,b.date_,null)) f65,
    max(decode(a.f66,1,b.date_,null)) f66,
    max(decode(a.f67,1,b.date_,null)) f67,
    max(decode(a.f68,1,b.date_,null)) f68,
    max(decode(a.f69,1,b.date_,null)) f69,
    max(decode(a.f70,1,b.date_,null)) f70,
    max(decode(a.f71,1,b.date_,null)) f71,
    max(decode(a.f72,1,b.date_,null)) f72,
    max(decode(a.f73,1,b.date_,null)) f73,
    max(decode(a.f74,1,b.date_,null)) f74,
    max(decode(a.f75,1,b.date_,null)) f75,
    max(decode(a.f76,1,b.date_,null)) f76,
    max(decode(a.f77,1,b.date_,null)) f77,
    max(decode(a.f78,1,b.date_,null)) f78,
    max(decode(a.f79,1,b.date_,null)) f79,
    max(decode(a.f80,1,b.date_,null)) f80,
    max(decode(a.f81,1,b.date_,null)) f81,
    max(decode(a.f82,1,b.date_,null)) f82,
    max(decode(a.f83,1,b.date_,null)) f83,
    max(decode(a.f84,1,b.date_,null)) f84,
    max(decode(a.f85,1,b.date_,null)) f85,
    max(decode(a.f86,1,b.date_,null)) f86,
    max(decode(a.f87,1,b.date_,null)) f87,
    max(decode(a.f88,1,b.date_,null)) f88,
    max(decode(a.f89,1,b.date_,null)) f89,
    max(decode(a.f90,1,b.date_,null)) f90,
    max(decode(a.f91,1,b.date_,null)) f91,
    max(decode(a.f92,1,b.date_,null)) f92,
    max(decode(a.f93,1,b.date_,null)) f93,
    max(decode(a.f94,1,b.date_,null)) f94,
    max(decode(a.f95,1,b.date_,null)) f95,
    max(decode(a.f96,1,b.date_,null)) f96,
    max(decode(a.f97,1,b.date_,null)) f97,
    max(decode(a.f98,1,b.date_,null)) f98,
    max(decode(a.f99,1,b.date_,null)) f99,
    max(decode(a.f100,1,b.date_,null)) f100,
    max(decode(a.f101,1,b.date_,null)) f101,
    max(decode(a.f102,1,b.date_,null)) f102,
    max(decode(a.f103,1,b.date_,null)) f103,
    max(decode(a.f104,1,b.date_,null)) f104,
    max(decode(a.f105,1,b.date_,null)) f105,
    max(decode(a.f106,1,b.date_,null)) f106,
    max(decode(a.f107,1,b.date_,null)) f107,
    max(decode(a.f108,1,b.date_,null)) f108,
    max(decode(a.f109,1,b.date_,null)) f109,
    max(decode(a.f110,1,b.date_,null)) f110,
    max(decode(a.f111,1,b.date_,null)) f111,
    max(decode(a.f112,1,b.date_,null)) f112,
    max(decode(a.f113,1,b.date_,null)) f113,
    max(decode(a.f114,1,b.date_,null)) f114,
    max(decode(a.f115,1,b.date_,null)) f115,
    max(decode(a.f116,1,b.date_,null)) f116,
    max(decode(a.f117,1,b.date_,null)) f117,
    max(decode(a.f118,1,b.date_,null)) f118,
    max(decode(a.f119,1,b.date_,null)) f119,
    max(decode(a.f120,1,b.date_,null)) f120,
    max(decode(a.f121,1,b.date_,null)) f121,
    max(decode(a.f122,1,b.date_,null)) f122,
    max(decode(a.f123,1,b.date_,null)) f123,
    max(decode(a.f124,1,b.date_,null)) f124,
    max(decode(a.f125,1,b.date_,null)) f125,
    max(decode(a.f126,1,b.date_,null)) f126,
    max(decode(a.f127,1,b.date_,null)) f127,
    max(decode(a.f128,1,b.date_,null)) f128,
    max(decode(a.f129,1,b.date_,null)) f129,
    max(decode(a.f130,1,b.date_,null)) f130,
    max(decode(a.f131,1,b.date_,null)) f131,
    max(decode(a.f132,1,b.date_,null)) f132,
    max(decode(a.f133,1,b.date_,null)) f133,
    max(decode(a.f134,1,b.date_,null)) f134,
    max(decode(a.f135,1,b.date_,null)) f135,
    max(decode(a.f136,1,b.date_,null)) f136,
    max(decode(a.f137,1,b.date_,null)) f137,
    max(decode(a.f138,1,b.date_,null)) f138,
    max(decode(a.f139,1,b.date_,null)) f139,
    max(decode(a.f140,1,b.date_,null)) f140,
    max(decode(a.f141,1,b.date_,null)) f141,
    max(decode(a.f142,1,b.date_,null)) f142,
    max(decode(a.f143,1,b.date_,null)) f143,
    max(decode(a.f144,1,b.date_,null)) f144,
    max(decode(a.f145,1,b.date_,null)) f145,
    max(decode(a.f146,1,b.date_,null)) f146,
    max(decode(a.f147,1,b.date_,null)) f147,
    max(decode(a.f148,1,b.date_,null)) f148,
    max(decode(a.f149,1,b.date_,null)) f149,
    max(decode(a.f150,1,b.date_,null)) f150,
    max(decode(a.f151,1,b.date_,null)) f151,
    max(decode(a.f152,1,b.date_,null)) f152,
    max(decode(a.f153,1,b.date_,null)) f153,
    max(decode(a.f154,1,b.date_,null)) f154,
    max(decode(a.f155,1,b.date_,null)) f155,
    max(decode(a.f156,1,b.date_,null)) f156,
    max(decode(a.f157,1,b.date_,null)) f157,
    max(decode(a.f158,1,b.date_,null)) f158,
    max(decode(a.f159,1,b.date_,null)) f159,
    max(decode(a.f160,1,b.date_,null)) f160,
    max(decode(a.f161,1,b.date_,null)) f161,
    max(decode(a.f162,1,b.date_,null)) f162,
    max(decode(a.f163,1,b.date_,null)) f163,
    max(decode(a.f164,1,b.date_,null)) f164,
    max(decode(a.f165,1,b.date_,null)) f165,
    max(decode(a.f166,1,b.date_,null)) f166,
    max(decode(a.f167,1,b.date_,null)) f167,
    max(decode(a.f168,1,b.date_,null)) f168,
    max(decode(a.f169,1,b.date_,null)) f169,
    max(decode(a.f170,1,b.date_,null)) f170,
    max(decode(a.f171,1,b.date_,null)) f171,
    max(decode(a.f172,1,b.date_,null)) f172,
    max(decode(a.f173,1,b.date_,null)) f173,
    max(decode(a.f174,1,b.date_,null)) f174,
    max(decode(a.f175,1,b.date_,null)) f175,
    max(decode(a.f176,1,b.date_,null)) f176,
    max(decode(a.f177,1,b.date_,null)) f177,
    max(decode(a.f178,1,b.date_,null)) f178,
    max(decode(a.f179,1,b.date_,null)) f179,
    max(decode(a.f180,1,b.date_,null)) f180,
    max(decode(a.f181,1,b.date_,null)) f181,
    max(decode(a.f182,1,b.date_,null)) f182,
    max(decode(a.f183,1,b.date_,null)) f183,
    max(decode(a.f184,1,b.date_,null)) f184,
    max(decode(a.f185,1,b.date_,null)) f185,
    max(decode(a.f186,1,b.date_,null)) f186,
    max(decode(a.f187,1,b.date_,null)) f187,
    max(decode(a.f188,1,b.date_,null)) f188,
    max(decode(a.f189,1,b.date_,null)) f189,
    max(decode(a.f190,1,b.date_,null)) f190,
    max(decode(a.f191,1,b.date_,null)) f191,
    max(decode(a.f192,1,b.date_,null)) f192,
    max(decode(a.f193,1,b.date_,null)) f193,
    max(decode(a.f194,1,b.date_,null)) f194,
    max(decode(a.f195,1,b.date_,null)) f195,
    max(decode(a.f196,1,b.date_,null)) f196,
    max(decode(a.f197,1,b.date_,null)) f197,
    max(decode(a.f198,1,b.date_,null)) f198,
    max(decode(a.f199,1,b.date_,null)) f199,
    max(decode(a.f200,1,b.date_,null)) f200,
    max(decode(a.f201,1,b.date_,null)) f201,
    max(decode(a.f202,1,b.date_,null)) f202,
    max(decode(a.f203,1,b.date_,null)) f203,
    max(decode(a.f204,1,b.date_,null)) f204,
    max(decode(a.f205,1,b.date_,null)) f205,
    max(decode(a.f206,1,b.date_,null)) f206,
    max(decode(a.f207,1,b.date_,null)) f207,
    max(decode(a.f208,1,b.date_,null)) f208,
    max(decode(a.f209,1,b.date_,null)) f209,
    max(decode(a.f210,1,b.date_,null)) f210,
    max(decode(a.f211,1,b.date_,null)) f211,
    max(decode(a.f212,1,b.date_,null)) f212,
    max(decode(a.f213,1,b.date_,null)) f213,
    max(decode(a.f214,1,b.date_,null)) f214,
    max(decode(a.f215,1,b.date_,null)) f215,
    max(decode(a.f216,1,b.date_,null)) f216,
    max(decode(a.f217,1,b.date_,null)) f217,
    max(decode(a.f218,1,b.date_,null)) f218,
    max(decode(a.f219,1,b.date_,null)) f219,
    max(decode(a.f220,1,b.date_,null)) f220,
    max(decode(a.f221,1,b.date_,null)) f221,
    max(decode(a.f222,1,b.date_,null)) f222,
    max(decode(a.f223,1,b.date_,null)) f223,
    max(decode(a.f224,1,b.date_,null)) f224,
    max(decode(a.f225,1,b.date_,null)) f225,
    max(decode(a.f226,1,b.date_,null)) f226,
    max(decode(a.f227,1,b.date_,null)) f227,
    max(decode(a.f228,1,b.date_,null)) f228,
    max(decode(a.f229,1,b.date_,null)) f229,
    max(decode(a.f230,1,b.date_,null)) f230,
    max(decode(a.f231,1,b.date_,null)) f231,
    max(decode(a.f232,1,b.date_,null)) f232,
    max(decode(a.f233,1,b.date_,null)) f233,
    max(decode(a.f234,1,b.date_,null)) f234,
    max(decode(a.f235,1,b.date_,null)) f235,
    max(decode(a.f236,1,b.date_,null)) f236,
    max(decode(a.f237,1,b.date_,null)) f237,
    max(decode(a.f238,1,b.date_,null)) f238,
    max(decode(a.f239,1,b.date_,null)) f239,
    max(decode(a.f240,1,b.date_,null)) f240,
    max(decode(a.f241,1,b.date_,null)) f241,
    max(decode(a.f242,1,b.date_,null)) f242,
    max(decode(a.f243,1,b.date_,null)) f243,
    max(decode(a.f244,1,b.date_,null)) f244,
    max(decode(a.f245,1,b.date_,null)) f245,
    max(decode(a.f246,1,b.date_,null)) f246,
    max(decode(a.f247,1,b.date_,null)) f247,
    max(decode(a.f248,1,b.date_,null)) f248,
    max(decode(a.f249,1,b.date_,null)) f249,
    max(decode(a.f250,1,b.date_,null)) f250,
    max(decode(a.f251,1,b.date_,null)) f251,
    max(decode(a.f252,1,b.date_,null)) f252,
    max(decode(a.f253,1,b.date_,null)) f253,
    max(decode(a.f254,1,b.date_,null)) f254,
    max(decode(a.f255,1,b.date_,null)) f255,
    max(decode(a.f256,1,b.date_,null)) f256,
    max(decode(a.f257,1,b.date_,null)) f257,
    max(decode(a.f258,1,b.date_,null)) f258,
    max(decode(a.f259,1,b.date_,null)) f259,
    max(decode(a.f260,1,b.date_,null)) f260,
    max(decode(a.f261,1,b.date_,null)) f261,
    max(decode(a.f262,1,b.date_,null)) f262,
    max(decode(a.f263,1,b.date_,null)) f263,
    max(decode(a.f264,1,b.date_,null)) f264,
    max(decode(a.f265,1,b.date_,null)) f265,
    max(decode(a.f266,1,b.date_,null)) f266,
    max(decode(a.f267,1,b.date_,null)) f267,
    max(decode(a.f268,1,b.date_,null)) f268,
    max(decode(a.f269,1,b.date_,null)) f269,
    max(decode(a.f270,1,b.date_,null)) f270,
    max(decode(a.f271,1,b.date_,null)) f271,
    max(decode(a.f272,1,b.date_,null)) f272,
    max(decode(a.f273,1,b.date_,null)) f273,
    max(decode(a.f274,1,b.date_,null)) f274,
    max(decode(a.f275,1,b.date_,null)) f275,
    max(decode(a.f276,1,b.date_,null)) f276,
    max(decode(a.f277,1,b.date_,null)) f277,
    max(decode(a.f278,1,b.date_,null)) f278,
    max(decode(a.f279,1,b.date_,null)) f279,
    max(decode(a.f280,1,b.date_,null)) f280,
    max(decode(a.f281,1,b.date_,null)) f281,
    max(decode(a.f282,1,b.date_,null)) f282,
    max(decode(a.f283,1,b.date_,null)) f283,
    max(decode(a.f284,1,b.date_,null)) f284,
    max(decode(a.f285,1,b.date_,null)) f285,
    max(decode(a.f286,1,b.date_,null)) f286,
    max(decode(a.f287,1,b.date_,null)) f287,
    max(decode(a.f288,1,b.date_,null)) f288,
    max(decode(a.f289,1,b.date_,null)) f289,
    max(decode(a.f290,1,b.date_,null)) f290,
    max(decode(a.f291,1,b.date_,null)) f291,
    max(decode(a.f292,1,b.date_,null)) f292,
    max(decode(a.f293,1,b.date_,null)) f293,
    max(decode(a.f294,1,b.date_,null)) f294,
    max(decode(a.f295,1,b.date_,null)) f295,
    max(decode(a.f296,1,b.date_,null)) f296,
    max(decode(a.f297,1,b.date_,null)) f297,
    max(decode(a.f298,1,b.date_,null)) f298,
    max(decode(a.f299,1,b.date_,null)) f299,
    max(decode(a.f300,1,b.date_,null)) f300,
    max(decode(a.f301,1,b.date_,null)) f301,
    max(decode(a.f302,1,b.date_,null)) f302,
    max(decode(a.f303,1,b.date_,null)) f303,
    max(decode(a.f304,1,b.date_,null)) f304,
    max(decode(a.f305,1,b.date_,null)) f305,
    max(decode(a.f306,1,b.date_,null)) f306,
    max(decode(a.f307,1,b.date_,null)) f307,
    max(decode(a.f308,1,b.date_,null)) f308,
    max(decode(a.f309,1,b.date_,null)) f309,
    max(decode(a.f310,1,b.date_,null)) f310,
    max(decode(a.f311,1,b.date_,null)) f311,
    max(decode(a.f312,1,b.date_,null)) f312,
    max(decode(a.f313,1,b.date_,null)) f313,
    max(decode(a.f314,1,b.date_,null)) f314,
    max(decode(a.f315,1,b.date_,null)) f315,
    max(decode(a.f316,1,b.date_,null)) f316,
    max(decode(a.f317,1,b.date_,null)) f317,
    max(decode(a.f318,1,b.date_,null)) f318,
    max(decode(a.f319,1,b.date_,null)) f319,
    max(decode(a.f320,1,b.date_,null)) f320,
    max(decode(a.f321,1,b.date_,null)) f321,
    max(decode(a.f322,1,b.date_,null)) f322,
    max(decode(a.f323,1,b.date_,null)) f323,
    max(decode(a.f324,1,b.date_,null)) f324,
    max(decode(a.f325,1,b.date_,null)) f325,
    max(decode(a.f326,1,b.date_,null)) f326,
    max(decode(a.f327,1,b.date_,null)) f327,
    max(decode(a.f328,1,b.date_,null)) f328,
    max(decode(a.f329,1,b.date_,null)) f329,
    max(decode(a.f330,1,b.date_,null)) f330,
    max(decode(a.f331,1,b.date_,null)) f331,
    max(decode(a.f332,1,b.date_,null)) f332,
    max(decode(a.f333,1,b.date_,null)) f333,
    max(decode(a.f334,1,b.date_,null)) f334,
    max(decode(a.f335,1,b.date_,null)) f335,
    max(decode(a.f336,1,b.date_,null)) f336,
    max(decode(a.f337,1,b.date_,null)) f337,
    max(decode(a.f338,1,b.date_,null)) f338,
    max(decode(a.f339,1,b.date_,null)) f339,
    max(decode(a.f340,1,b.date_,null)) f340,
    max(decode(a.f341,1,b.date_,null)) f341,
    max(decode(a.f342,1,b.date_,null)) f342,
    max(decode(a.f343,1,b.date_,null)) f343,
    max(decode(a.f344,1,b.date_,null)) f344,
    max(decode(a.f345,1,b.date_,null)) f345,
    max(decode(a.f346,1,b.date_,null)) f346,
    max(decode(a.f347,1,b.date_,null)) f347,
    max(decode(a.f348,1,b.date_,null)) f348,
    max(decode(a.f349,1,b.date_,null)) f349,
    max(decode(a.f350,1,b.date_,null)) f350,
    max(decode(a.f351,1,b.date_,null)) f351,
    max(decode(a.f352,1,b.date_,null)) f352,
    max(decode(a.f353,1,b.date_,null)) f353,
    max(decode(a.f354,1,b.date_,null)) f354,
    max(decode(a.f355,1,b.date_,null)) f355,
    max(decode(a.f356,1,b.date_,null)) f356,
    max(decode(a.f357,1,b.date_,null)) f357,
    max(decode(a.f358,1,b.date_,null)) f358,
    max(decode(a.f359,1,b.date_,null)) f359,
    max(decode(a.f360,1,b.date_,null)) f360,
    max(decode(a.f361,1,b.date_,null)) f361,
    max(decode(a.f362,1,b.date_,null)) f362,
    max(decode(a.f363,1,b.date_,null)) f363,
    max(decode(a.f364,1,b.date_,null)) f364,
    max(decode(a.f365,1,b.date_,null)) f365,
    max(decode(a.f366,1,b.date_,null)) f366,
    max(decode(a.f367,1,b.date_,null)) f367,
    max(decode(a.f368,1,b.date_,null)) f368,
    max(decode(a.f369,1,b.date_,null)) f369,
    max(decode(a.f370,1,b.date_,null)) f370,
    max(decode(a.f371,1,b.date_,null)) f371,
    max(decode(a.f372,1,b.date_,null)) f372,
    max(decode(a.f373,1,b.date_,null)) f373,
    max(decode(a.f374,1,b.date_,null)) f374,
    max(decode(a.f375,1,b.date_,null)) f375,
    max(decode(a.f376,1,b.date_,null)) f376,
    max(decode(a.f377,1,b.date_,null)) f377,
    max(decode(a.f378,1,b.date_,null)) f378,
    max(decode(a.f379,1,b.date_,null)) f379,
    max(decode(a.f380,1,b.date_,null)) f380,
    max(decode(a.f381,1,b.date_,null)) f381,
    max(decode(a.f382,1,b.date_,null)) f382,
    max(decode(a.f383,1,b.date_,null)) f383,
    max(decode(a.f384,1,b.date_,null)) f384,
    max(decode(a.f385,1,b.date_,null)) f385,
    max(decode(a.f386,1,b.date_,null)) f386,
    max(decode(a.f387,1,b.date_,null)) f387,
    max(decode(a.f388,1,b.date_,null)) f388,
    max(decode(a.f389,1,b.date_,null)) f389,
    max(decode(a.f390,1,b.date_,null)) f390,
    max(decode(a.f391,1,b.date_,null)) f391,
    max(decode(a.f392,1,b.date_,null)) f392,
    max(decode(a.f393,1,b.date_,null)) f393,
    max(decode(a.f394,1,b.date_,null)) f394,
    max(decode(a.f395,1,b.date_,null)) f395,
    max(decode(a.f396,1,b.date_,null)) f396,
    max(decode(a.f397,1,b.date_,null)) f397,
    max(decode(a.f398,1,b.date_,null)) f398,
    max(decode(a.f399,1,b.date_,null)) f399,
    max(decode(a.f400,1,b.date_,null)) f400,
    max(decode(a.f401,1,b.date_,null)) f401,
    max(decode(a.f402,1,b.date_,null)) f402,
    max(decode(a.f403,1,b.date_,null)) f403,
    max(decode(a.f404,1,b.date_,null)) f404,
    max(decode(a.f405,1,b.date_,null)) f405,
    max(decode(a.f406,1,b.date_,null)) f406,
    max(decode(a.f407,1,b.date_,null)) f407,
    max(decode(a.f408,1,b.date_,null)) f408,
    max(decode(a.f409,1,b.date_,null)) f409,
    max(decode(a.f410,1,b.date_,null)) f410,
    max(decode(a.f411,1,b.date_,null)) f411,
    max(decode(a.f412,1,b.date_,null)) f412,
    max(decode(a.f413,1,b.date_,null)) f413,
    max(decode(a.f414,1,b.date_,null)) f414,
    max(decode(a.f415,1,b.date_,null)) f415,
    max(decode(a.f416,1,b.date_,null)) f416,
    max(decode(a.f417,1,b.date_,null)) f417,
    max(decode(a.f418,1,b.date_,null)) f418,
    max(decode(a.f419,1,b.date_,null)) f419,
    max(decode(a.f420,1,b.date_,null)) f420,
    max(decode(a.f421,1,b.date_,null)) f421,
    max(decode(a.f422,1,b.date_,null)) f422,
    max(decode(a.f423,1,b.date_,null)) f423,
    max(decode(a.f424,1,b.date_,null)) f424,
    max(decode(a.f425,1,b.date_,null)) f425,
    max(decode(a.f426,1,b.date_,null)) f426,
    max(decode(a.f427,1,b.date_,null)) f427,
    max(decode(a.f428,1,b.date_,null)) f428,
    max(decode(a.f429,1,b.date_,null)) f429,
    max(decode(a.f430,1,b.date_,null)) f430,
    max(decode(a.f431,1,b.date_,null)) f431,
    max(decode(a.f432,1,b.date_,null)) f432,
    max(decode(a.f433,1,b.date_,null)) f433,
    max(decode(a.f434,1,b.date_,null)) f434,
    max(decode(a.f435,1,b.date_,null)) f435,
    max(decode(a.f436,1,b.date_,null)) f436,
    max(decode(a.f437,1,b.date_,null)) f437,
    max(decode(a.f438,1,b.date_,null)) f438,
    max(decode(a.f439,1,b.date_,null)) f439,
    max(decode(a.f440,1,b.date_,null)) f440,
    max(decode(a.f441,1,b.date_,null)) f441,
    max(decode(a.f442,1,b.date_,null)) f442,
    max(decode(a.f443,1,b.date_,null)) f443,
    max(decode(a.f444,1,b.date_,null)) f444,
    max(decode(a.f445,1,b.date_,null)) f445,
    max(decode(a.f446,1,b.date_,null)) f446,
    max(decode(a.f447,1,b.date_,null)) f447,
    max(decode(a.f448,1,b.date_,null)) f448,
    max(decode(a.f449,1,b.date_,null)) f449,
    max(decode(a.f450,1,b.date_,null)) f450,
    max(decode(a.f451,1,b.date_,null)) f451,
    max(decode(a.f452,1,b.date_,null)) f452,
    max(decode(a.f453,1,b.date_,null)) f453,
    max(decode(a.f454,1,b.date_,null)) f454,
    max(decode(a.f455,1,b.date_,null)) f455,
    max(decode(a.f456,1,b.date_,null)) f456,
    max(decode(a.f457,1,b.date_,null)) f457,
    max(decode(a.f458,1,b.date_,null)) f458,
    max(decode(a.f459,1,b.date_,null)) f459,
    max(decode(a.f460,1,b.date_,null)) f460,
    max(decode(a.f461,1,b.date_,null)) f461,
    max(decode(a.f462,1,b.date_,null)) f462,
    max(decode(a.f463,1,b.date_,null)) f463,
    max(decode(a.f464,1,b.date_,null)) f464,
    max(decode(a.f465,1,b.date_,null)) f465,
    max(decode(a.f466,1,b.date_,null)) f466,
    max(decode(a.f467,1,b.date_,null)) f467,
    max(decode(a.f468,1,b.date_,null)) f468,
    max(decode(a.f469,1,b.date_,null)) f469,
    max(decode(a.f470,1,b.date_,null)) f470,
    max(decode(a.f471,1,b.date_,null)) f471,
    max(decode(a.f472,1,b.date_,null)) f472,
    max(decode(a.f473,1,b.date_,null)) f473,
    max(decode(a.f474,1,b.date_,null)) f474,
    max(decode(a.f475,1,b.date_,null)) f475,
    max(decode(a.f476,1,b.date_,null)) f476,
    max(decode(a.f477,1,b.date_,null)) f477,
    max(decode(a.f478,1,b.date_,null)) f478,
    max(decode(a.f479,1,b.date_,null)) f479,
    max(decode(a.f480,1,b.date_,null)) f480,
    max(decode(a.f481,1,b.date_,null)) f481,
    max(decode(a.f482,1,b.date_,null)) f482,
    max(decode(a.f483,1,b.date_,null)) f483,
    max(decode(a.f484,1,b.date_,null)) f484,
    max(decode(a.f485,1,b.date_,null)) f485,
    max(decode(a.f486,1,b.date_,null)) f486,
    max(decode(a.f487,1,b.date_,null)) f487,
    max(decode(a.f488,1,b.date_,null)) f488,
    max(decode(a.f489,1,b.date_,null)) f489,
    max(decode(a.f490,1,b.date_,null)) f490,
    max(decode(a.f491,1,b.date_,null)) f491,
    max(decode(a.f492,1,b.date_,null)) f492,
    max(decode(a.f493,1,b.date_,null)) f493,
    max(decode(a.f494,1,b.date_,null)) f494,
    max(decode(a.f495,1,b.date_,null)) f495,
    max(decode(a.f496,1,b.date_,null)) f496,
    max(decode(a.f497,1,b.date_,null)) f497,
    max(decode(a.f498,1,b.date_,null)) f498,
    max(decode(a.f499,1,b.date_,null)) f499,
    max(decode(a.f500,1,b.date_,null)) f500,
    max(decode(a.f501,1,b.date_,null)) f501,
    max(decode(a.f502,1,b.date_,null)) f502,
    max(decode(a.f503,1,b.date_,null)) f503,
    max(decode(a.f504,1,b.date_,null)) f504,
    max(decode(a.f505,1,b.date_,null)) f505,
    max(decode(a.f506,1,b.date_,null)) f506,
    max(decode(a.f507,1,b.date_,null)) f507,
    max(decode(a.f508,1,b.date_,null)) f508,
    max(decode(a.f509,1,b.date_,null)) f509,
    max(decode(a.f510,1,b.date_,null)) f510,
    max(decode(a.f511,1,b.date_,null)) f511,
    max(decode(a.f512,1,b.date_,null)) f512,
    max(decode(a.f513,1,b.date_,null)) f513,
    max(decode(a.f514,1,b.date_,null)) f514,
    max(decode(a.f515,1,b.date_,null)) f515,
    max(decode(a.f516,1,b.date_,null)) f516,
    max(decode(a.f517,1,b.date_,null)) f517,
    max(decode(a.f518,1,b.date_,null)) f518,
    max(decode(a.f519,1,b.date_,null)) f519,
    max(decode(a.f520,1,b.date_,null)) f520,
    max(decode(a.f521,1,b.date_,null)) f521,
    max(decode(a.f522,1,b.date_,null)) f522,
    max(decode(a.f523,1,b.date_,null)) f523,
    max(decode(a.f524,1,b.date_,null)) f524,
    max(decode(a.f525,1,b.date_,null)) f525,
    max(decode(a.f526,1,b.date_,null)) f526,
    max(decode(a.f527,1,b.date_,null)) f527,
    max(decode(a.f528,1,b.date_,null)) f528,
    max(decode(a.f529,1,b.date_,null)) f529,
    max(decode(a.f530,1,b.date_,null)) f530,
    max(decode(a.f531,1,b.date_,null)) f531,
    max(decode(a.f532,1,b.date_,null)) f532,
    max(decode(a.f533,1,b.date_,null)) f533,
    max(decode(a.f534,1,b.date_,null)) f534,
    max(decode(a.f535,1,b.date_,null)) f535,
    max(decode(a.f536,1,b.date_,null)) f536,
    max(decode(a.f537,1,b.date_,null)) f537,
    max(decode(a.f538,1,b.date_,null)) f538,
    max(decode(a.f539,1,b.date_,null)) f539,
    max(decode(a.f540,1,b.date_,null)) f540,
    max(decode(a.f541,1,b.date_,null)) f541,
    max(decode(a.f542,1,b.date_,null)) f542,
    max(decode(a.f543,1,b.date_,null)) f543,
    max(decode(a.f544,1,b.date_,null)) f544,
    max(decode(a.f545,1,b.date_,null)) f545,
    max(decode(a.f546,1,b.date_,null)) f546,
    max(decode(a.f547,1,b.date_,null)) f547,
    max(decode(a.f548,1,b.date_,null)) f548,
    max(decode(a.f549,1,b.date_,null)) f549,
    max(decode(a.f550,1,b.date_,null)) f550,
    max(decode(a.f551,1,b.date_,null)) f551,
    max(decode(a.f552,1,b.date_,null)) f552,
    max(decode(a.f553,1,b.date_,null)) f553,
    max(decode(a.f554,1,b.date_,null)) f554,
    max(decode(a.f555,1,b.date_,null)) f555,
    max(decode(a.f556,1,b.date_,null)) f556,
    max(decode(a.f557,1,b.date_,null)) f557,
    max(decode(a.f558,1,b.date_,null)) f558,
    max(decode(a.f559,1,b.date_,null)) f559,
    max(decode(a.f560,1,b.date_,null)) f560,
    max(decode(a.f561,1,b.date_,null)) f561,
    max(decode(a.f562,1,b.date_,null)) f562,
    max(decode(a.f563,1,b.date_,null)) f563,
    max(decode(a.f564,1,b.date_,null)) f564,
    max(decode(a.f565,1,b.date_,null)) f565,
    max(decode(a.f566,1,b.date_,null)) f566,
    max(decode(a.f567,1,b.date_,null)) f567,
    max(decode(a.f568,1,b.date_,null)) f568,
    max(decode(a.f569,1,b.date_,null)) f569,
    max(decode(a.f570,1,b.date_,null)) f570,
    max(decode(a.f571,1,b.date_,null)) f571,
    max(decode(a.f572,1,b.date_,null)) f572,
    max(decode(a.f573,1,b.date_,null)) f573,
    max(decode(a.f574,1,b.date_,null)) f574,
    max(decode(a.f575,1,b.date_,null)) f575,
    max(decode(a.f576,1,b.date_,null)) f576,
    max(decode(a.f577,1,b.date_,null)) f577,
    max(decode(a.f578,1,b.date_,null)) f578,
    max(decode(a.f579,1,b.date_,null)) f579,
    max(decode(a.f580,1,b.date_,null)) f580,
    max(decode(a.f581,1,b.date_,null)) f581,
    max(decode(a.f582,1,b.date_,null)) f582,
    max(decode(a.f583,1,b.date_,null)) f583,
    max(decode(a.f584,1,b.date_,null)) f584,
    max(decode(a.f585,1,b.date_,null)) f585,
    max(decode(a.f586,1,b.date_,null)) f586,
    max(decode(a.f587,1,b.date_,null)) f587,
    max(decode(a.f588,1,b.date_,null)) f588,
    max(decode(a.f589,1,b.date_,null)) f589,
    max(decode(a.f590,1,b.date_,null)) f590,
    max(decode(a.f591,1,b.date_,null)) f591,
    max(decode(a.f592,1,b.date_,null)) f592,
    max(decode(a.f593,1,b.date_,null)) f593,
    max(decode(a.f594,1,b.date_,null)) f594,
    max(decode(a.f595,1,b.date_,null)) f595,
    max(decode(a.f596,1,b.date_,null)) f596,
    max(decode(a.f597,1,b.date_,null)) f597,
    max(decode(a.f598,1,b.date_,null)) f598,
    max(decode(a.f599,1,b.date_,null)) f599,
    max(decode(a.f600,1,b.date_,null)) f600,
    max(decode(a.f601,1,b.date_,null)) f601,
    max(decode(a.f602,1,b.date_,null)) f602,
    max(decode(a.f603,1,b.date_,null)) f603,
    max(decode(a.f604,1,b.date_,null)) f604,
    max(decode(a.f605,1,b.date_,null)) f605,
    max(decode(a.f606,1,b.date_,null)) f606,
    max(decode(a.f607,1,b.date_,null)) f607,
    max(decode(a.f608,1,b.date_,null)) f608,
    max(decode(a.f609,1,b.date_,null)) f609,
    max(decode(a.f610,1,b.date_,null)) f610,
    max(decode(a.f611,1,b.date_,null)) f611,
    max(decode(a.f612,1,b.date_,null)) f612,
    max(decode(a.f613,1,b.date_,null)) f613,
    max(decode(a.f614,1,b.date_,null)) f614,
    max(decode(a.f615,1,b.date_,null)) f615,
    max(decode(a.f616,1,b.date_,null)) f616,
    max(decode(a.f617,1,b.date_,null)) f617,
    max(decode(a.f618,1,b.date_,null)) f618,
    max(decode(a.f619,1,b.date_,null)) f619,
    max(decode(a.f620,1,b.date_,null)) f620,
    max(decode(a.f621,1,b.date_,null)) f621,
    max(decode(a.f622,1,b.date_,null)) f622,
    max(decode(a.f623,1,b.date_,null)) f623,
    max(decode(a.f624,1,b.date_,null)) f624,
    max(decode(a.f625,1,b.date_,null)) f625,
    max(decode(a.f626,1,b.date_,null)) f626,
    max(decode(a.f627,1,b.date_,null)) f627,
    max(decode(a.f628,1,b.date_,null)) f628,
    max(decode(a.f629,1,b.date_,null)) f629,
    max(decode(a.f630,1,b.date_,null)) f630,
    max(decode(a.f631,1,b.date_,null)) f631,
    max(decode(a.f632,1,b.date_,null)) f632,
    max(decode(a.f633,1,b.date_,null)) f633,
    max(decode(a.f634,1,b.date_,null)) f634,
    max(decode(a.f635,1,b.date_,null)) f635,
    max(decode(a.f636,1,b.date_,null)) f636,
    max(decode(a.f637,1,b.date_,null)) f637,
    max(decode(a.f638,1,b.date_,null)) f638,
    max(decode(a.f639,1,b.date_,null)) f639,
    max(decode(a.f640,1,b.date_,null)) f640,
    max(decode(a.f641,1,b.date_,null)) f641,
    max(decode(a.f642,1,b.date_,null)) f642,
    max(decode(a.f643,1,b.date_,null)) f643,
    max(decode(a.f644,1,b.date_,null)) f644,
    max(decode(a.f645,1,b.date_,null)) f645,
    max(decode(a.f646,1,b.date_,null)) f646,
    max(decode(a.f647,1,b.date_,null)) f647,
    max(decode(a.f648,1,b.date_,null)) f648,
    max(decode(a.f649,1,b.date_,null)) f649,
    max(decode(a.f650,1,b.date_,null)) f650,
    max(decode(a.f651,1,b.date_,null)) f651,
    max(decode(a.f652,1,b.date_,null)) f652,
    max(decode(a.f653,1,b.date_,null)) f653,
    max(decode(a.f654,1,b.date_,null)) f654,
    max(decode(a.f655,1,b.date_,null)) f655,
    max(decode(a.f656,1,b.date_,null)) f656,
    max(decode(a.f657,1,b.date_,null)) f657,
    max(decode(a.f658,1,b.date_,null)) f658,
    max(decode(a.f659,1,b.date_,null)) f659,
    max(decode(a.f660,1,b.date_,null)) f660,
    max(decode(a.f661,1,b.date_,null)) f661,
    max(decode(a.f662,1,b.date_,null)) f662,
    max(decode(a.f663,1,b.date_,null)) f663,
    max(decode(a.f664,1,b.date_,null)) f664,
    max(decode(a.f665,1,b.date_,null)) f665,
    max(decode(a.f666,1,b.date_,null)) f666,
    max(decode(a.f667,1,b.date_,null)) f667,
    max(decode(a.f668,1,b.date_,null)) f668,
    max(decode(a.f669,1,b.date_,null)) f669,
    max(decode(a.f670,1,b.date_,null)) f670,
    max(decode(a.f671,1,b.date_,null)) f671,
    max(decode(a.f672,1,b.date_,null)) f672,
    max(decode(a.f673,1,b.date_,null)) f673,
    max(decode(a.f674,1,b.date_,null)) f674,
    max(decode(a.f675,1,b.date_,null)) f675,
    max(decode(a.f676,1,b.date_,null)) f676,
    max(decode(a.f677,1,b.date_,null)) f677,
    max(decode(a.f678,1,b.date_,null)) f678,
    max(decode(a.f679,1,b.date_,null)) f679,
    max(decode(a.f680,1,b.date_,null)) f680,
    max(decode(a.f681,1,b.date_,null)) f681,
    max(decode(a.f682,1,b.date_,null)) f682,
    max(decode(a.f683,1,b.date_,null)) f683,
    max(decode(a.f684,1,b.date_,null)) f684,
    max(decode(a.f685,1,b.date_,null)) f685,
    max(decode(a.f686,1,b.date_,null)) f686,
    max(decode(a.f687,1,b.date_,null)) f687,
    max(decode(a.f688,1,b.date_,null)) f688,
    max(decode(a.f689,1,b.date_,null)) f689,
    max(decode(a.f690,1,b.date_,null)) f690,
    max(decode(a.f691,1,b.date_,null)) f691,
    max(decode(a.f692,1,b.date_,null)) f692,
    max(decode(a.f693,1,b.date_,null)) f693,
    max(decode(a.f694,1,b.date_,null)) f694,
    max(decode(a.f695,1,b.date_,null)) f695,
    max(decode(a.f696,1,b.date_,null)) f696,
    max(decode(a.f697,1,b.date_,null)) f697,
    max(decode(a.f698,1,b.date_,null)) f698,
    max(decode(a.f699,1,b.date_,null)) f699,
    max(decode(a.f700,1,b.date_,null)) f700
    from dm_matrix a, tt1 b
    where a.rn = b.rn    
    group by b.SNAPSHOT_DT
)
--select * from tt2
--
,tt3 as
(
    select 
    CONTRACT_ID_CD, a.BRANCH_NAM,a.SNAPSHOT_DT,
    max(decode(a.pay_dt,b.f1,a.P_NIL)) f1,
    max(decode(a.pay_dt,b.f2,a.P_NIL)) f2,
    max(decode(a.pay_dt,b.f3,a.P_NIL)) f3,
    max(decode(a.pay_dt,b.f4,a.P_NIL)) f4,
    max(decode(a.pay_dt,b.f5,a.P_NIL)) f5,
    max(decode(a.pay_dt,b.f6,a.P_NIL)) f6,
    max(decode(a.pay_dt,b.f7,a.P_NIL)) f7,
    max(decode(a.pay_dt,b.f8,a.P_NIL)) f8,
    max(decode(a.pay_dt,b.f9,a.P_NIL)) f9,
    max(decode(a.pay_dt,b.f10,a.P_NIL)) f10,
    max(decode(a.pay_dt,b.f11,a.P_NIL)) f11,
    max(decode(a.pay_dt,b.f12,a.P_NIL)) f12,
    max(decode(a.pay_dt,b.f13,a.P_NIL)) f13,
    max(decode(a.pay_dt,b.f14,a.P_NIL)) f14,
    max(decode(a.pay_dt,b.f15,a.P_NIL)) f15,
    max(decode(a.pay_dt,b.f16,a.P_NIL)) f16,
    max(decode(a.pay_dt,b.f17,a.P_NIL)) f17,
    max(decode(a.pay_dt,b.f18,a.P_NIL)) f18,
    max(decode(a.pay_dt,b.f19,a.P_NIL)) f19,
    max(decode(a.pay_dt,b.f20,a.P_NIL)) f20,
    max(decode(a.pay_dt,b.f21,a.P_NIL)) f21,
    max(decode(a.pay_dt,b.f22,a.P_NIL)) f22,
    max(decode(a.pay_dt,b.f23,a.P_NIL)) f23,
    max(decode(a.pay_dt,b.f24,a.P_NIL)) f24,
    max(decode(a.pay_dt,b.f25,a.P_NIL)) f25,
    max(decode(a.pay_dt,b.f26,a.P_NIL)) f26,
    max(decode(a.pay_dt,b.f27,a.P_NIL)) f27,
    max(decode(a.pay_dt,b.f28,a.P_NIL)) f28,
    max(decode(a.pay_dt,b.f29,a.P_NIL)) f29,
    max(decode(a.pay_dt,b.f30,a.P_NIL)) f30,
    max(decode(a.pay_dt,b.f31,a.P_NIL)) f31,
    max(decode(a.pay_dt,b.f32,a.P_NIL)) f32,
    max(decode(a.pay_dt,b.f33,a.P_NIL)) f33,
    max(decode(a.pay_dt,b.f34,a.P_NIL)) f34,
    max(decode(a.pay_dt,b.f35,a.P_NIL)) f35,
    max(decode(a.pay_dt,b.f36,a.P_NIL)) f36,
    max(decode(a.pay_dt,b.f37,a.P_NIL)) f37,
    max(decode(a.pay_dt,b.f38,a.P_NIL)) f38,
    max(decode(a.pay_dt,b.f39,a.P_NIL)) f39,
    max(decode(a.pay_dt,b.f40,a.P_NIL)) f40,
    max(decode(a.pay_dt,b.f41,a.P_NIL)) f41,
    max(decode(a.pay_dt,b.f42,a.P_NIL)) f42,
    max(decode(a.pay_dt,b.f43,a.P_NIL)) f43,
    max(decode(a.pay_dt,b.f44,a.P_NIL)) f44,
    max(decode(a.pay_dt,b.f45,a.P_NIL)) f45,
    max(decode(a.pay_dt,b.f46,a.P_NIL)) f46,
    max(decode(a.pay_dt,b.f47,a.P_NIL)) f47,
    max(decode(a.pay_dt,b.f48,a.P_NIL)) f48,
    max(decode(a.pay_dt,b.f49,a.P_NIL)) f49,
    max(decode(a.pay_dt,b.f50,a.P_NIL)) f50,
    max(decode(a.pay_dt,b.f51,a.P_NIL)) f51,
    max(decode(a.pay_dt,b.f52,a.P_NIL)) f52,
    max(decode(a.pay_dt,b.f53,a.P_NIL)) f53,
    max(decode(a.pay_dt,b.f54,a.P_NIL)) f54,
    max(decode(a.pay_dt,b.f55,a.P_NIL)) f55,
    max(decode(a.pay_dt,b.f56,a.P_NIL)) f56,
    max(decode(a.pay_dt,b.f57,a.P_NIL)) f57,
    max(decode(a.pay_dt,b.f58,a.P_NIL)) f58,
    max(decode(a.pay_dt,b.f59,a.P_NIL)) f59,
    max(decode(a.pay_dt,b.f60,a.P_NIL)) f60,
    max(decode(a.pay_dt,b.f61,a.P_NIL)) f61,
    max(decode(a.pay_dt,b.f62,a.P_NIL)) f62,
    max(decode(a.pay_dt,b.f63,a.P_NIL)) f63,
    max(decode(a.pay_dt,b.f64,a.P_NIL)) f64,
    max(decode(a.pay_dt,b.f65,a.P_NIL)) f65,
    max(decode(a.pay_dt,b.f66,a.P_NIL)) f66,
    max(decode(a.pay_dt,b.f67,a.P_NIL)) f67,
    max(decode(a.pay_dt,b.f68,a.P_NIL)) f68,
    max(decode(a.pay_dt,b.f69,a.P_NIL)) f69,
    max(decode(a.pay_dt,b.f70,a.P_NIL)) f70,
    max(decode(a.pay_dt,b.f71,a.P_NIL)) f71,
    max(decode(a.pay_dt,b.f72,a.P_NIL)) f72,
    max(decode(a.pay_dt,b.f73,a.P_NIL)) f73,
    max(decode(a.pay_dt,b.f74,a.P_NIL)) f74,
    max(decode(a.pay_dt,b.f75,a.P_NIL)) f75,
    max(decode(a.pay_dt,b.f76,a.P_NIL)) f76,
    max(decode(a.pay_dt,b.f77,a.P_NIL)) f77,
    max(decode(a.pay_dt,b.f78,a.P_NIL)) f78,
    max(decode(a.pay_dt,b.f79,a.P_NIL)) f79,
    max(decode(a.pay_dt,b.f80,a.P_NIL)) f80,
    max(decode(a.pay_dt,b.f81,a.P_NIL)) f81,
    max(decode(a.pay_dt,b.f82,a.P_NIL)) f82,
    max(decode(a.pay_dt,b.f83,a.P_NIL)) f83,
    max(decode(a.pay_dt,b.f84,a.P_NIL)) f84,
    max(decode(a.pay_dt,b.f85,a.P_NIL)) f85,
    max(decode(a.pay_dt,b.f86,a.P_NIL)) f86,
    max(decode(a.pay_dt,b.f87,a.P_NIL)) f87,
    max(decode(a.pay_dt,b.f88,a.P_NIL)) f88,
    max(decode(a.pay_dt,b.f89,a.P_NIL)) f89,
    max(decode(a.pay_dt,b.f90,a.P_NIL)) f90,
    max(decode(a.pay_dt,b.f91,a.P_NIL)) f91,
    max(decode(a.pay_dt,b.f92,a.P_NIL)) f92,
    max(decode(a.pay_dt,b.f93,a.P_NIL)) f93,
    max(decode(a.pay_dt,b.f94,a.P_NIL)) f94,
    max(decode(a.pay_dt,b.f95,a.P_NIL)) f95,
    max(decode(a.pay_dt,b.f96,a.P_NIL)) f96,
    max(decode(a.pay_dt,b.f97,a.P_NIL)) f97,
    max(decode(a.pay_dt,b.f98,a.P_NIL)) f98,
    max(decode(a.pay_dt,b.f99,a.P_NIL)) f99,
    max(decode(a.pay_dt,b.f100,a.P_NIL)) f100,
    max(decode(a.pay_dt,b.f101,a.P_NIL)) f101,
    max(decode(a.pay_dt,b.f102,a.P_NIL)) f102,
    max(decode(a.pay_dt,b.f103,a.P_NIL)) f103,
    max(decode(a.pay_dt,b.f104,a.P_NIL)) f104,
    max(decode(a.pay_dt,b.f105,a.P_NIL)) f105,
    max(decode(a.pay_dt,b.f106,a.P_NIL)) f106,
    max(decode(a.pay_dt,b.f107,a.P_NIL)) f107,
    max(decode(a.pay_dt,b.f108,a.P_NIL)) f108,
    max(decode(a.pay_dt,b.f109,a.P_NIL)) f109,
    max(decode(a.pay_dt,b.f110,a.P_NIL)) f110,
    max(decode(a.pay_dt,b.f111,a.P_NIL)) f111,
    max(decode(a.pay_dt,b.f112,a.P_NIL)) f112,
    max(decode(a.pay_dt,b.f113,a.P_NIL)) f113,
    max(decode(a.pay_dt,b.f114,a.P_NIL)) f114,
    max(decode(a.pay_dt,b.f115,a.P_NIL)) f115,
    max(decode(a.pay_dt,b.f116,a.P_NIL)) f116,
    max(decode(a.pay_dt,b.f117,a.P_NIL)) f117,
    max(decode(a.pay_dt,b.f118,a.P_NIL)) f118,
    max(decode(a.pay_dt,b.f119,a.P_NIL)) f119,
    max(decode(a.pay_dt,b.f120,a.P_NIL)) f120,
    max(decode(a.pay_dt,b.f121,a.P_NIL)) f121,
    max(decode(a.pay_dt,b.f122,a.P_NIL)) f122,
    max(decode(a.pay_dt,b.f123,a.P_NIL)) f123,
    max(decode(a.pay_dt,b.f124,a.P_NIL)) f124,
    max(decode(a.pay_dt,b.f125,a.P_NIL)) f125,
    max(decode(a.pay_dt,b.f126,a.P_NIL)) f126,
    max(decode(a.pay_dt,b.f127,a.P_NIL)) f127,
    max(decode(a.pay_dt,b.f128,a.P_NIL)) f128,
    max(decode(a.pay_dt,b.f129,a.P_NIL)) f129,
    max(decode(a.pay_dt,b.f130,a.P_NIL)) f130,
    max(decode(a.pay_dt,b.f131,a.P_NIL)) f131,
    max(decode(a.pay_dt,b.f132,a.P_NIL)) f132,
    max(decode(a.pay_dt,b.f133,a.P_NIL)) f133,
    max(decode(a.pay_dt,b.f134,a.P_NIL)) f134,
    max(decode(a.pay_dt,b.f135,a.P_NIL)) f135,
    max(decode(a.pay_dt,b.f136,a.P_NIL)) f136,
    max(decode(a.pay_dt,b.f137,a.P_NIL)) f137,
    max(decode(a.pay_dt,b.f138,a.P_NIL)) f138,
    max(decode(a.pay_dt,b.f139,a.P_NIL)) f139,
    max(decode(a.pay_dt,b.f140,a.P_NIL)) f140,
    max(decode(a.pay_dt,b.f141,a.P_NIL)) f141,
    max(decode(a.pay_dt,b.f142,a.P_NIL)) f142,
    max(decode(a.pay_dt,b.f143,a.P_NIL)) f143,
    max(decode(a.pay_dt,b.f144,a.P_NIL)) f144,
    max(decode(a.pay_dt,b.f145,a.P_NIL)) f145,
    max(decode(a.pay_dt,b.f146,a.P_NIL)) f146,
    max(decode(a.pay_dt,b.f147,a.P_NIL)) f147,
    max(decode(a.pay_dt,b.f148,a.P_NIL)) f148,
    max(decode(a.pay_dt,b.f149,a.P_NIL)) f149,
    max(decode(a.pay_dt,b.f150,a.P_NIL)) f150,
    max(decode(a.pay_dt,b.f151,a.P_NIL)) f151,
    max(decode(a.pay_dt,b.f152,a.P_NIL)) f152,
    max(decode(a.pay_dt,b.f153,a.P_NIL)) f153,
    max(decode(a.pay_dt,b.f154,a.P_NIL)) f154,
    max(decode(a.pay_dt,b.f155,a.P_NIL)) f155,
    max(decode(a.pay_dt,b.f156,a.P_NIL)) f156,
    max(decode(a.pay_dt,b.f157,a.P_NIL)) f157,
    max(decode(a.pay_dt,b.f158,a.P_NIL)) f158,
    max(decode(a.pay_dt,b.f159,a.P_NIL)) f159,
    max(decode(a.pay_dt,b.f160,a.P_NIL)) f160,
    max(decode(a.pay_dt,b.f161,a.P_NIL)) f161,
    max(decode(a.pay_dt,b.f162,a.P_NIL)) f162,
    max(decode(a.pay_dt,b.f163,a.P_NIL)) f163,
    max(decode(a.pay_dt,b.f164,a.P_NIL)) f164,
    max(decode(a.pay_dt,b.f165,a.P_NIL)) f165,
    max(decode(a.pay_dt,b.f166,a.P_NIL)) f166,
    max(decode(a.pay_dt,b.f167,a.P_NIL)) f167,
    max(decode(a.pay_dt,b.f168,a.P_NIL)) f168,
    max(decode(a.pay_dt,b.f169,a.P_NIL)) f169,
    max(decode(a.pay_dt,b.f170,a.P_NIL)) f170,
    max(decode(a.pay_dt,b.f171,a.P_NIL)) f171,
    max(decode(a.pay_dt,b.f172,a.P_NIL)) f172,
    max(decode(a.pay_dt,b.f173,a.P_NIL)) f173,
    max(decode(a.pay_dt,b.f174,a.P_NIL)) f174,
    max(decode(a.pay_dt,b.f175,a.P_NIL)) f175,
    max(decode(a.pay_dt,b.f176,a.P_NIL)) f176,
    max(decode(a.pay_dt,b.f177,a.P_NIL)) f177,
    max(decode(a.pay_dt,b.f178,a.P_NIL)) f178,
    max(decode(a.pay_dt,b.f179,a.P_NIL)) f179,
    max(decode(a.pay_dt,b.f180,a.P_NIL)) f180,
    max(decode(a.pay_dt,b.f181,a.P_NIL)) f181,
    max(decode(a.pay_dt,b.f182,a.P_NIL)) f182,
    max(decode(a.pay_dt,b.f183,a.P_NIL)) f183,
    max(decode(a.pay_dt,b.f184,a.P_NIL)) f184,
    max(decode(a.pay_dt,b.f185,a.P_NIL)) f185,
    max(decode(a.pay_dt,b.f186,a.P_NIL)) f186,
    max(decode(a.pay_dt,b.f187,a.P_NIL)) f187,
    max(decode(a.pay_dt,b.f188,a.P_NIL)) f188,
    max(decode(a.pay_dt,b.f189,a.P_NIL)) f189,
    max(decode(a.pay_dt,b.f190,a.P_NIL)) f190,
    max(decode(a.pay_dt,b.f191,a.P_NIL)) f191,
    max(decode(a.pay_dt,b.f192,a.P_NIL)) f192,
    max(decode(a.pay_dt,b.f193,a.P_NIL)) f193,
    max(decode(a.pay_dt,b.f194,a.P_NIL)) f194,
    max(decode(a.pay_dt,b.f195,a.P_NIL)) f195,
    max(decode(a.pay_dt,b.f196,a.P_NIL)) f196,
    max(decode(a.pay_dt,b.f197,a.P_NIL)) f197,
    max(decode(a.pay_dt,b.f198,a.P_NIL)) f198,
    max(decode(a.pay_dt,b.f199,a.P_NIL)) f199,
    max(decode(a.pay_dt,b.f200,a.P_NIL)) f200,
    max(decode(a.pay_dt,b.f201,a.P_NIL)) f201,
    max(decode(a.pay_dt,b.f202,a.P_NIL)) f202,
    max(decode(a.pay_dt,b.f203,a.P_NIL)) f203,
    max(decode(a.pay_dt,b.f204,a.P_NIL)) f204,
    max(decode(a.pay_dt,b.f205,a.P_NIL)) f205,
    max(decode(a.pay_dt,b.f206,a.P_NIL)) f206,
    max(decode(a.pay_dt,b.f207,a.P_NIL)) f207,
    max(decode(a.pay_dt,b.f208,a.P_NIL)) f208,
    max(decode(a.pay_dt,b.f209,a.P_NIL)) f209,
    max(decode(a.pay_dt,b.f210,a.P_NIL)) f210,
    max(decode(a.pay_dt,b.f211,a.P_NIL)) f211,
    max(decode(a.pay_dt,b.f212,a.P_NIL)) f212,
    max(decode(a.pay_dt,b.f213,a.P_NIL)) f213,
    max(decode(a.pay_dt,b.f214,a.P_NIL)) f214,
    max(decode(a.pay_dt,b.f215,a.P_NIL)) f215,
    max(decode(a.pay_dt,b.f216,a.P_NIL)) f216,
    max(decode(a.pay_dt,b.f217,a.P_NIL)) f217,
    max(decode(a.pay_dt,b.f218,a.P_NIL)) f218,
    max(decode(a.pay_dt,b.f219,a.P_NIL)) f219,
    max(decode(a.pay_dt,b.f220,a.P_NIL)) f220,
    max(decode(a.pay_dt,b.f221,a.P_NIL)) f221,
    max(decode(a.pay_dt,b.f222,a.P_NIL)) f222,
    max(decode(a.pay_dt,b.f223,a.P_NIL)) f223,
    max(decode(a.pay_dt,b.f224,a.P_NIL)) f224,
    max(decode(a.pay_dt,b.f225,a.P_NIL)) f225,
    max(decode(a.pay_dt,b.f226,a.P_NIL)) f226,
    max(decode(a.pay_dt,b.f227,a.P_NIL)) f227,
    max(decode(a.pay_dt,b.f228,a.P_NIL)) f228,
    max(decode(a.pay_dt,b.f229,a.P_NIL)) f229,
    max(decode(a.pay_dt,b.f230,a.P_NIL)) f230,
    max(decode(a.pay_dt,b.f231,a.P_NIL)) f231,
    max(decode(a.pay_dt,b.f232,a.P_NIL)) f232,
    max(decode(a.pay_dt,b.f233,a.P_NIL)) f233,
    max(decode(a.pay_dt,b.f234,a.P_NIL)) f234,
    max(decode(a.pay_dt,b.f235,a.P_NIL)) f235,
    max(decode(a.pay_dt,b.f236,a.P_NIL)) f236,
    max(decode(a.pay_dt,b.f237,a.P_NIL)) f237,
    max(decode(a.pay_dt,b.f238,a.P_NIL)) f238,
    max(decode(a.pay_dt,b.f239,a.P_NIL)) f239,
    max(decode(a.pay_dt,b.f240,a.P_NIL)) f240,
    max(decode(a.pay_dt,b.f241,a.P_NIL)) f241,
    max(decode(a.pay_dt,b.f242,a.P_NIL)) f242,
    max(decode(a.pay_dt,b.f243,a.P_NIL)) f243,
    max(decode(a.pay_dt,b.f244,a.P_NIL)) f244,
    max(decode(a.pay_dt,b.f245,a.P_NIL)) f245,
    max(decode(a.pay_dt,b.f246,a.P_NIL)) f246,
    max(decode(a.pay_dt,b.f247,a.P_NIL)) f247,
    max(decode(a.pay_dt,b.f248,a.P_NIL)) f248,
    max(decode(a.pay_dt,b.f249,a.P_NIL)) f249,
    max(decode(a.pay_dt,b.f250,a.P_NIL)) f250,
    max(decode(a.pay_dt,b.f251,a.P_NIL)) f251,
    max(decode(a.pay_dt,b.f252,a.P_NIL)) f252,
    max(decode(a.pay_dt,b.f253,a.P_NIL)) f253,
    max(decode(a.pay_dt,b.f254,a.P_NIL)) f254,
    max(decode(a.pay_dt,b.f255,a.P_NIL)) f255,
    max(decode(a.pay_dt,b.f256,a.P_NIL)) f256,
    max(decode(a.pay_dt,b.f257,a.P_NIL)) f257,
    max(decode(a.pay_dt,b.f258,a.P_NIL)) f258,
    max(decode(a.pay_dt,b.f259,a.P_NIL)) f259,
    max(decode(a.pay_dt,b.f260,a.P_NIL)) f260,
    max(decode(a.pay_dt,b.f261,a.P_NIL)) f261,
    max(decode(a.pay_dt,b.f262,a.P_NIL)) f262,
    max(decode(a.pay_dt,b.f263,a.P_NIL)) f263,
    max(decode(a.pay_dt,b.f264,a.P_NIL)) f264,
    max(decode(a.pay_dt,b.f265,a.P_NIL)) f265,
    max(decode(a.pay_dt,b.f266,a.P_NIL)) f266,
    max(decode(a.pay_dt,b.f267,a.P_NIL)) f267,
    max(decode(a.pay_dt,b.f268,a.P_NIL)) f268,
    max(decode(a.pay_dt,b.f269,a.P_NIL)) f269,
    max(decode(a.pay_dt,b.f270,a.P_NIL)) f270,
    max(decode(a.pay_dt,b.f271,a.P_NIL)) f271,
    max(decode(a.pay_dt,b.f272,a.P_NIL)) f272,
    max(decode(a.pay_dt,b.f273,a.P_NIL)) f273,
    max(decode(a.pay_dt,b.f274,a.P_NIL)) f274,
    max(decode(a.pay_dt,b.f275,a.P_NIL)) f275,
    max(decode(a.pay_dt,b.f276,a.P_NIL)) f276,
    max(decode(a.pay_dt,b.f277,a.P_NIL)) f277,
    max(decode(a.pay_dt,b.f278,a.P_NIL)) f278,
    max(decode(a.pay_dt,b.f279,a.P_NIL)) f279,
    max(decode(a.pay_dt,b.f280,a.P_NIL)) f280,
    max(decode(a.pay_dt,b.f281,a.P_NIL)) f281,
    max(decode(a.pay_dt,b.f282,a.P_NIL)) f282,
    max(decode(a.pay_dt,b.f283,a.P_NIL)) f283,
    max(decode(a.pay_dt,b.f284,a.P_NIL)) f284,
    max(decode(a.pay_dt,b.f285,a.P_NIL)) f285,
    max(decode(a.pay_dt,b.f286,a.P_NIL)) f286,
    max(decode(a.pay_dt,b.f287,a.P_NIL)) f287,
    max(decode(a.pay_dt,b.f288,a.P_NIL)) f288,
    max(decode(a.pay_dt,b.f289,a.P_NIL)) f289,
    max(decode(a.pay_dt,b.f290,a.P_NIL)) f290,
    max(decode(a.pay_dt,b.f291,a.P_NIL)) f291,
    max(decode(a.pay_dt,b.f292,a.P_NIL)) f292,
    max(decode(a.pay_dt,b.f293,a.P_NIL)) f293,
    max(decode(a.pay_dt,b.f294,a.P_NIL)) f294,
    max(decode(a.pay_dt,b.f295,a.P_NIL)) f295,
    max(decode(a.pay_dt,b.f296,a.P_NIL)) f296,
    max(decode(a.pay_dt,b.f297,a.P_NIL)) f297,
    max(decode(a.pay_dt,b.f298,a.P_NIL)) f298,
    max(decode(a.pay_dt,b.f299,a.P_NIL)) f299,
    max(decode(a.pay_dt,b.f300,a.P_NIL)) f300,
    max(decode(a.pay_dt,b.f301,a.P_NIL)) f301,
    max(decode(a.pay_dt,b.f302,a.P_NIL)) f302,
    max(decode(a.pay_dt,b.f303,a.P_NIL)) f303,
    max(decode(a.pay_dt,b.f304,a.P_NIL)) f304,
    max(decode(a.pay_dt,b.f305,a.P_NIL)) f305,
    max(decode(a.pay_dt,b.f306,a.P_NIL)) f306,
    max(decode(a.pay_dt,b.f307,a.P_NIL)) f307,
    max(decode(a.pay_dt,b.f308,a.P_NIL)) f308,
    max(decode(a.pay_dt,b.f309,a.P_NIL)) f309,
    max(decode(a.pay_dt,b.f310,a.P_NIL)) f310,
    max(decode(a.pay_dt,b.f311,a.P_NIL)) f311,
    max(decode(a.pay_dt,b.f312,a.P_NIL)) f312,
    max(decode(a.pay_dt,b.f313,a.P_NIL)) f313,
    max(decode(a.pay_dt,b.f314,a.P_NIL)) f314,
    max(decode(a.pay_dt,b.f315,a.P_NIL)) f315,
    max(decode(a.pay_dt,b.f316,a.P_NIL)) f316,
    max(decode(a.pay_dt,b.f317,a.P_NIL)) f317,
    max(decode(a.pay_dt,b.f318,a.P_NIL)) f318,
    max(decode(a.pay_dt,b.f319,a.P_NIL)) f319,
    max(decode(a.pay_dt,b.f320,a.P_NIL)) f320,
    max(decode(a.pay_dt,b.f321,a.P_NIL)) f321,
    max(decode(a.pay_dt,b.f322,a.P_NIL)) f322,
    max(decode(a.pay_dt,b.f323,a.P_NIL)) f323,
    max(decode(a.pay_dt,b.f324,a.P_NIL)) f324,
    max(decode(a.pay_dt,b.f325,a.P_NIL)) f325,
    max(decode(a.pay_dt,b.f326,a.P_NIL)) f326,
    max(decode(a.pay_dt,b.f327,a.P_NIL)) f327,
    max(decode(a.pay_dt,b.f328,a.P_NIL)) f328,
    max(decode(a.pay_dt,b.f329,a.P_NIL)) f329,
    max(decode(a.pay_dt,b.f330,a.P_NIL)) f330,
    max(decode(a.pay_dt,b.f331,a.P_NIL)) f331,
    max(decode(a.pay_dt,b.f332,a.P_NIL)) f332,
    max(decode(a.pay_dt,b.f333,a.P_NIL)) f333,
    max(decode(a.pay_dt,b.f334,a.P_NIL)) f334,
    max(decode(a.pay_dt,b.f335,a.P_NIL)) f335,
    max(decode(a.pay_dt,b.f336,a.P_NIL)) f336,
    max(decode(a.pay_dt,b.f337,a.P_NIL)) f337,
    max(decode(a.pay_dt,b.f338,a.P_NIL)) f338,
    max(decode(a.pay_dt,b.f339,a.P_NIL)) f339,
    max(decode(a.pay_dt,b.f340,a.P_NIL)) f340,
    max(decode(a.pay_dt,b.f341,a.P_NIL)) f341,
    max(decode(a.pay_dt,b.f342,a.P_NIL)) f342,
    max(decode(a.pay_dt,b.f343,a.P_NIL)) f343,
    max(decode(a.pay_dt,b.f344,a.P_NIL)) f344,
    max(decode(a.pay_dt,b.f345,a.P_NIL)) f345,
    max(decode(a.pay_dt,b.f346,a.P_NIL)) f346,
    max(decode(a.pay_dt,b.f347,a.P_NIL)) f347,
    max(decode(a.pay_dt,b.f348,a.P_NIL)) f348,
    max(decode(a.pay_dt,b.f349,a.P_NIL)) f349,
    max(decode(a.pay_dt,b.f350,a.P_NIL)) f350,
    max(decode(a.pay_dt,b.f351,a.P_NIL)) f351,
    max(decode(a.pay_dt,b.f352,a.P_NIL)) f352,
    max(decode(a.pay_dt,b.f353,a.P_NIL)) f353,
    max(decode(a.pay_dt,b.f354,a.P_NIL)) f354,
    max(decode(a.pay_dt,b.f355,a.P_NIL)) f355,
    max(decode(a.pay_dt,b.f356,a.P_NIL)) f356,
    max(decode(a.pay_dt,b.f357,a.P_NIL)) f357,
    max(decode(a.pay_dt,b.f358,a.P_NIL)) f358,
    max(decode(a.pay_dt,b.f359,a.P_NIL)) f359,
    max(decode(a.pay_dt,b.f360,a.P_NIL)) f360,
    max(decode(a.pay_dt,b.f361,a.P_NIL)) f361,
    max(decode(a.pay_dt,b.f362,a.P_NIL)) f362,
    max(decode(a.pay_dt,b.f363,a.P_NIL)) f363,
    max(decode(a.pay_dt,b.f364,a.P_NIL)) f364,
    max(decode(a.pay_dt,b.f365,a.P_NIL)) f365,
    max(decode(a.pay_dt,b.f366,a.P_NIL)) f366,
    max(decode(a.pay_dt,b.f367,a.P_NIL)) f367,
    max(decode(a.pay_dt,b.f368,a.P_NIL)) f368,
    max(decode(a.pay_dt,b.f369,a.P_NIL)) f369,
    max(decode(a.pay_dt,b.f370,a.P_NIL)) f370,
    max(decode(a.pay_dt,b.f371,a.P_NIL)) f371,
    max(decode(a.pay_dt,b.f372,a.P_NIL)) f372,
    max(decode(a.pay_dt,b.f373,a.P_NIL)) f373,
    max(decode(a.pay_dt,b.f374,a.P_NIL)) f374,
    max(decode(a.pay_dt,b.f375,a.P_NIL)) f375,
    max(decode(a.pay_dt,b.f376,a.P_NIL)) f376,
    max(decode(a.pay_dt,b.f377,a.P_NIL)) f377,
    max(decode(a.pay_dt,b.f378,a.P_NIL)) f378,
    max(decode(a.pay_dt,b.f379,a.P_NIL)) f379,
    max(decode(a.pay_dt,b.f380,a.P_NIL)) f380,
    max(decode(a.pay_dt,b.f381,a.P_NIL)) f381,
    max(decode(a.pay_dt,b.f382,a.P_NIL)) f382,
    max(decode(a.pay_dt,b.f383,a.P_NIL)) f383,
    max(decode(a.pay_dt,b.f384,a.P_NIL)) f384,
    max(decode(a.pay_dt,b.f385,a.P_NIL)) f385,
    max(decode(a.pay_dt,b.f386,a.P_NIL)) f386,
    max(decode(a.pay_dt,b.f387,a.P_NIL)) f387,
    max(decode(a.pay_dt,b.f388,a.P_NIL)) f388,
    max(decode(a.pay_dt,b.f389,a.P_NIL)) f389,
    max(decode(a.pay_dt,b.f390,a.P_NIL)) f390,
    max(decode(a.pay_dt,b.f391,a.P_NIL)) f391,
    max(decode(a.pay_dt,b.f392,a.P_NIL)) f392,
    max(decode(a.pay_dt,b.f393,a.P_NIL)) f393,
    max(decode(a.pay_dt,b.f394,a.P_NIL)) f394,
    max(decode(a.pay_dt,b.f395,a.P_NIL)) f395,
    max(decode(a.pay_dt,b.f396,a.P_NIL)) f396,
    max(decode(a.pay_dt,b.f397,a.P_NIL)) f397,
    max(decode(a.pay_dt,b.f398,a.P_NIL)) f398,
    max(decode(a.pay_dt,b.f399,a.P_NIL)) f399,
    max(decode(a.pay_dt,b.f400,a.P_NIL)) f400,
    max(decode(a.pay_dt,b.f401,a.P_NIL)) f401,
    max(decode(a.pay_dt,b.f402,a.P_NIL)) f402,
    max(decode(a.pay_dt,b.f403,a.P_NIL)) f403,
    max(decode(a.pay_dt,b.f404,a.P_NIL)) f404,
    max(decode(a.pay_dt,b.f405,a.P_NIL)) f405,
    max(decode(a.pay_dt,b.f406,a.P_NIL)) f406,
    max(decode(a.pay_dt,b.f407,a.P_NIL)) f407,
    max(decode(a.pay_dt,b.f408,a.P_NIL)) f408,
    max(decode(a.pay_dt,b.f409,a.P_NIL)) f409,
    max(decode(a.pay_dt,b.f410,a.P_NIL)) f410,
    max(decode(a.pay_dt,b.f411,a.P_NIL)) f411,
    max(decode(a.pay_dt,b.f412,a.P_NIL)) f412,
    max(decode(a.pay_dt,b.f413,a.P_NIL)) f413,
    max(decode(a.pay_dt,b.f414,a.P_NIL)) f414,
    max(decode(a.pay_dt,b.f415,a.P_NIL)) f415,
    max(decode(a.pay_dt,b.f416,a.P_NIL)) f416,
    max(decode(a.pay_dt,b.f417,a.P_NIL)) f417,
    max(decode(a.pay_dt,b.f418,a.P_NIL)) f418,
    max(decode(a.pay_dt,b.f419,a.P_NIL)) f419,
    max(decode(a.pay_dt,b.f420,a.P_NIL)) f420,
    max(decode(a.pay_dt,b.f421,a.P_NIL)) f421,
    max(decode(a.pay_dt,b.f422,a.P_NIL)) f422,
    max(decode(a.pay_dt,b.f423,a.P_NIL)) f423,
    max(decode(a.pay_dt,b.f424,a.P_NIL)) f424,
    max(decode(a.pay_dt,b.f425,a.P_NIL)) f425,
    max(decode(a.pay_dt,b.f426,a.P_NIL)) f426,
    max(decode(a.pay_dt,b.f427,a.P_NIL)) f427,
    max(decode(a.pay_dt,b.f428,a.P_NIL)) f428,
    max(decode(a.pay_dt,b.f429,a.P_NIL)) f429,
    max(decode(a.pay_dt,b.f430,a.P_NIL)) f430,
    max(decode(a.pay_dt,b.f431,a.P_NIL)) f431,
    max(decode(a.pay_dt,b.f432,a.P_NIL)) f432,
    max(decode(a.pay_dt,b.f433,a.P_NIL)) f433,
    max(decode(a.pay_dt,b.f434,a.P_NIL)) f434,
    max(decode(a.pay_dt,b.f435,a.P_NIL)) f435,
    max(decode(a.pay_dt,b.f436,a.P_NIL)) f436,
    max(decode(a.pay_dt,b.f437,a.P_NIL)) f437,
    max(decode(a.pay_dt,b.f438,a.P_NIL)) f438,
    max(decode(a.pay_dt,b.f439,a.P_NIL)) f439,
    max(decode(a.pay_dt,b.f440,a.P_NIL)) f440,
    max(decode(a.pay_dt,b.f441,a.P_NIL)) f441,
    max(decode(a.pay_dt,b.f442,a.P_NIL)) f442,
    max(decode(a.pay_dt,b.f443,a.P_NIL)) f443,
    max(decode(a.pay_dt,b.f444,a.P_NIL)) f444,
    max(decode(a.pay_dt,b.f445,a.P_NIL)) f445,
    max(decode(a.pay_dt,b.f446,a.P_NIL)) f446,
    max(decode(a.pay_dt,b.f447,a.P_NIL)) f447,
    max(decode(a.pay_dt,b.f448,a.P_NIL)) f448,
    max(decode(a.pay_dt,b.f449,a.P_NIL)) f449,
    max(decode(a.pay_dt,b.f450,a.P_NIL)) f450,
    max(decode(a.pay_dt,b.f451,a.P_NIL)) f451,
    max(decode(a.pay_dt,b.f452,a.P_NIL)) f452,
    max(decode(a.pay_dt,b.f453,a.P_NIL)) f453,
    max(decode(a.pay_dt,b.f454,a.P_NIL)) f454,
    max(decode(a.pay_dt,b.f455,a.P_NIL)) f455,
    max(decode(a.pay_dt,b.f456,a.P_NIL)) f456,
    max(decode(a.pay_dt,b.f457,a.P_NIL)) f457,
    max(decode(a.pay_dt,b.f458,a.P_NIL)) f458,
    max(decode(a.pay_dt,b.f459,a.P_NIL)) f459,
    max(decode(a.pay_dt,b.f460,a.P_NIL)) f460,
    max(decode(a.pay_dt,b.f461,a.P_NIL)) f461,
    max(decode(a.pay_dt,b.f462,a.P_NIL)) f462,
    max(decode(a.pay_dt,b.f463,a.P_NIL)) f463,
    max(decode(a.pay_dt,b.f464,a.P_NIL)) f464,
    max(decode(a.pay_dt,b.f465,a.P_NIL)) f465,
    max(decode(a.pay_dt,b.f466,a.P_NIL)) f466,
    max(decode(a.pay_dt,b.f467,a.P_NIL)) f467,
    max(decode(a.pay_dt,b.f468,a.P_NIL)) f468,
    max(decode(a.pay_dt,b.f469,a.P_NIL)) f469,
    max(decode(a.pay_dt,b.f470,a.P_NIL)) f470,
    max(decode(a.pay_dt,b.f471,a.P_NIL)) f471,
    max(decode(a.pay_dt,b.f472,a.P_NIL)) f472,
    max(decode(a.pay_dt,b.f473,a.P_NIL)) f473,
    max(decode(a.pay_dt,b.f474,a.P_NIL)) f474,
    max(decode(a.pay_dt,b.f475,a.P_NIL)) f475,
    max(decode(a.pay_dt,b.f476,a.P_NIL)) f476,
    max(decode(a.pay_dt,b.f477,a.P_NIL)) f477,
    max(decode(a.pay_dt,b.f478,a.P_NIL)) f478,
    max(decode(a.pay_dt,b.f479,a.P_NIL)) f479,
    max(decode(a.pay_dt,b.f480,a.P_NIL)) f480,
    max(decode(a.pay_dt,b.f481,a.P_NIL)) f481,
    max(decode(a.pay_dt,b.f482,a.P_NIL)) f482,
    max(decode(a.pay_dt,b.f483,a.P_NIL)) f483,
    max(decode(a.pay_dt,b.f484,a.P_NIL)) f484,
    max(decode(a.pay_dt,b.f485,a.P_NIL)) f485,
    max(decode(a.pay_dt,b.f486,a.P_NIL)) f486,
    max(decode(a.pay_dt,b.f487,a.P_NIL)) f487,
    max(decode(a.pay_dt,b.f488,a.P_NIL)) f488,
    max(decode(a.pay_dt,b.f489,a.P_NIL)) f489,
    max(decode(a.pay_dt,b.f490,a.P_NIL)) f490,
    max(decode(a.pay_dt,b.f491,a.P_NIL)) f491,
    max(decode(a.pay_dt,b.f492,a.P_NIL)) f492,
    max(decode(a.pay_dt,b.f493,a.P_NIL)) f493,
    max(decode(a.pay_dt,b.f494,a.P_NIL)) f494,
    max(decode(a.pay_dt,b.f495,a.P_NIL)) f495,
    max(decode(a.pay_dt,b.f496,a.P_NIL)) f496,
    max(decode(a.pay_dt,b.f497,a.P_NIL)) f497,
    max(decode(a.pay_dt,b.f498,a.P_NIL)) f498,
    max(decode(a.pay_dt,b.f499,a.P_NIL)) f499,
    max(decode(a.pay_dt,b.f500,a.P_NIL)) f500,
    max(decode(a.pay_dt,b.f501,a.P_NIL)) f501,
    max(decode(a.pay_dt,b.f502,a.P_NIL)) f502,
    max(decode(a.pay_dt,b.f503,a.P_NIL)) f503,
    max(decode(a.pay_dt,b.f504,a.P_NIL)) f504,
    max(decode(a.pay_dt,b.f505,a.P_NIL)) f505,
    max(decode(a.pay_dt,b.f506,a.P_NIL)) f506,
    max(decode(a.pay_dt,b.f507,a.P_NIL)) f507,
    max(decode(a.pay_dt,b.f508,a.P_NIL)) f508,
    max(decode(a.pay_dt,b.f509,a.P_NIL)) f509,
    max(decode(a.pay_dt,b.f510,a.P_NIL)) f510,
    max(decode(a.pay_dt,b.f511,a.P_NIL)) f511,
    max(decode(a.pay_dt,b.f512,a.P_NIL)) f512,
    max(decode(a.pay_dt,b.f513,a.P_NIL)) f513,
    max(decode(a.pay_dt,b.f514,a.P_NIL)) f514,
    max(decode(a.pay_dt,b.f515,a.P_NIL)) f515,
    max(decode(a.pay_dt,b.f516,a.P_NIL)) f516,
    max(decode(a.pay_dt,b.f517,a.P_NIL)) f517,
    max(decode(a.pay_dt,b.f518,a.P_NIL)) f518,
    max(decode(a.pay_dt,b.f519,a.P_NIL)) f519,
    max(decode(a.pay_dt,b.f520,a.P_NIL)) f520,
    max(decode(a.pay_dt,b.f521,a.P_NIL)) f521,
    max(decode(a.pay_dt,b.f522,a.P_NIL)) f522,
    max(decode(a.pay_dt,b.f523,a.P_NIL)) f523,
    max(decode(a.pay_dt,b.f524,a.P_NIL)) f524,
    max(decode(a.pay_dt,b.f525,a.P_NIL)) f525,
    max(decode(a.pay_dt,b.f526,a.P_NIL)) f526,
    max(decode(a.pay_dt,b.f527,a.P_NIL)) f527,
    max(decode(a.pay_dt,b.f528,a.P_NIL)) f528,
    max(decode(a.pay_dt,b.f529,a.P_NIL)) f529,
    max(decode(a.pay_dt,b.f530,a.P_NIL)) f530,
    max(decode(a.pay_dt,b.f531,a.P_NIL)) f531,
    max(decode(a.pay_dt,b.f532,a.P_NIL)) f532,
    max(decode(a.pay_dt,b.f533,a.P_NIL)) f533,
    max(decode(a.pay_dt,b.f534,a.P_NIL)) f534,
    max(decode(a.pay_dt,b.f535,a.P_NIL)) f535,
    max(decode(a.pay_dt,b.f536,a.P_NIL)) f536,
    max(decode(a.pay_dt,b.f537,a.P_NIL)) f537,
    max(decode(a.pay_dt,b.f538,a.P_NIL)) f538,
    max(decode(a.pay_dt,b.f539,a.P_NIL)) f539,
    max(decode(a.pay_dt,b.f540,a.P_NIL)) f540,
    max(decode(a.pay_dt,b.f541,a.P_NIL)) f541,
    max(decode(a.pay_dt,b.f542,a.P_NIL)) f542,
    max(decode(a.pay_dt,b.f543,a.P_NIL)) f543,
    max(decode(a.pay_dt,b.f544,a.P_NIL)) f544,
    max(decode(a.pay_dt,b.f545,a.P_NIL)) f545,
    max(decode(a.pay_dt,b.f546,a.P_NIL)) f546,
    max(decode(a.pay_dt,b.f547,a.P_NIL)) f547,
    max(decode(a.pay_dt,b.f548,a.P_NIL)) f548,
    max(decode(a.pay_dt,b.f549,a.P_NIL)) f549,
    max(decode(a.pay_dt,b.f550,a.P_NIL)) f550,
    max(decode(a.pay_dt,b.f551,a.P_NIL)) f551,
    max(decode(a.pay_dt,b.f552,a.P_NIL)) f552,
    max(decode(a.pay_dt,b.f553,a.P_NIL)) f553,
    max(decode(a.pay_dt,b.f554,a.P_NIL)) f554,
    max(decode(a.pay_dt,b.f555,a.P_NIL)) f555,
    max(decode(a.pay_dt,b.f556,a.P_NIL)) f556,
    max(decode(a.pay_dt,b.f557,a.P_NIL)) f557,
    max(decode(a.pay_dt,b.f558,a.P_NIL)) f558,
    max(decode(a.pay_dt,b.f559,a.P_NIL)) f559,
    max(decode(a.pay_dt,b.f560,a.P_NIL)) f560,
    max(decode(a.pay_dt,b.f561,a.P_NIL)) f561,
    max(decode(a.pay_dt,b.f562,a.P_NIL)) f562,
    max(decode(a.pay_dt,b.f563,a.P_NIL)) f563,
    max(decode(a.pay_dt,b.f564,a.P_NIL)) f564,
    max(decode(a.pay_dt,b.f565,a.P_NIL)) f565,
    max(decode(a.pay_dt,b.f566,a.P_NIL)) f566,
    max(decode(a.pay_dt,b.f567,a.P_NIL)) f567,
    max(decode(a.pay_dt,b.f568,a.P_NIL)) f568,
    max(decode(a.pay_dt,b.f569,a.P_NIL)) f569,
    max(decode(a.pay_dt,b.f570,a.P_NIL)) f570,
    max(decode(a.pay_dt,b.f571,a.P_NIL)) f571,
    max(decode(a.pay_dt,b.f572,a.P_NIL)) f572,
    max(decode(a.pay_dt,b.f573,a.P_NIL)) f573,
    max(decode(a.pay_dt,b.f574,a.P_NIL)) f574,
    max(decode(a.pay_dt,b.f575,a.P_NIL)) f575,
    max(decode(a.pay_dt,b.f576,a.P_NIL)) f576,
    max(decode(a.pay_dt,b.f577,a.P_NIL)) f577,
    max(decode(a.pay_dt,b.f578,a.P_NIL)) f578,
    max(decode(a.pay_dt,b.f579,a.P_NIL)) f579,
    max(decode(a.pay_dt,b.f580,a.P_NIL)) f580,
    max(decode(a.pay_dt,b.f581,a.P_NIL)) f581,
    max(decode(a.pay_dt,b.f582,a.P_NIL)) f582,
    max(decode(a.pay_dt,b.f583,a.P_NIL)) f583,
    max(decode(a.pay_dt,b.f584,a.P_NIL)) f584,
    max(decode(a.pay_dt,b.f585,a.P_NIL)) f585,
    max(decode(a.pay_dt,b.f586,a.P_NIL)) f586,
    max(decode(a.pay_dt,b.f587,a.P_NIL)) f587,
    max(decode(a.pay_dt,b.f588,a.P_NIL)) f588,
    max(decode(a.pay_dt,b.f589,a.P_NIL)) f589,
    max(decode(a.pay_dt,b.f590,a.P_NIL)) f590,
    max(decode(a.pay_dt,b.f591,a.P_NIL)) f591,
    max(decode(a.pay_dt,b.f592,a.P_NIL)) f592,
    max(decode(a.pay_dt,b.f593,a.P_NIL)) f593,
    max(decode(a.pay_dt,b.f594,a.P_NIL)) f594,
    max(decode(a.pay_dt,b.f595,a.P_NIL)) f595,
    max(decode(a.pay_dt,b.f596,a.P_NIL)) f596,
    max(decode(a.pay_dt,b.f597,a.P_NIL)) f597,
    max(decode(a.pay_dt,b.f598,a.P_NIL)) f598,
    max(decode(a.pay_dt,b.f599,a.P_NIL)) f599,
    max(decode(a.pay_dt,b.f600,a.P_NIL)) f600,
    max(decode(a.pay_dt,b.f601,a.P_NIL)) f601,
    max(decode(a.pay_dt,b.f602,a.P_NIL)) f602,
    max(decode(a.pay_dt,b.f603,a.P_NIL)) f603,
    max(decode(a.pay_dt,b.f604,a.P_NIL)) f604,
    max(decode(a.pay_dt,b.f605,a.P_NIL)) f605,
    max(decode(a.pay_dt,b.f606,a.P_NIL)) f606,
    max(decode(a.pay_dt,b.f607,a.P_NIL)) f607,
    max(decode(a.pay_dt,b.f608,a.P_NIL)) f608,
    max(decode(a.pay_dt,b.f609,a.P_NIL)) f609,
    max(decode(a.pay_dt,b.f610,a.P_NIL)) f610,
    max(decode(a.pay_dt,b.f611,a.P_NIL)) f611,
    max(decode(a.pay_dt,b.f612,a.P_NIL)) f612,
    max(decode(a.pay_dt,b.f613,a.P_NIL)) f613,
    max(decode(a.pay_dt,b.f614,a.P_NIL)) f614,
    max(decode(a.pay_dt,b.f615,a.P_NIL)) f615,
    max(decode(a.pay_dt,b.f616,a.P_NIL)) f616,
    max(decode(a.pay_dt,b.f617,a.P_NIL)) f617,
    max(decode(a.pay_dt,b.f618,a.P_NIL)) f618,
    max(decode(a.pay_dt,b.f619,a.P_NIL)) f619,
    max(decode(a.pay_dt,b.f620,a.P_NIL)) f620,
    max(decode(a.pay_dt,b.f621,a.P_NIL)) f621,
    max(decode(a.pay_dt,b.f622,a.P_NIL)) f622,
    max(decode(a.pay_dt,b.f623,a.P_NIL)) f623,
    max(decode(a.pay_dt,b.f624,a.P_NIL)) f624,
    max(decode(a.pay_dt,b.f625,a.P_NIL)) f625,
    max(decode(a.pay_dt,b.f626,a.P_NIL)) f626,
    max(decode(a.pay_dt,b.f627,a.P_NIL)) f627,
    max(decode(a.pay_dt,b.f628,a.P_NIL)) f628,
    max(decode(a.pay_dt,b.f629,a.P_NIL)) f629,
    max(decode(a.pay_dt,b.f630,a.P_NIL)) f630,
    max(decode(a.pay_dt,b.f631,a.P_NIL)) f631,
    max(decode(a.pay_dt,b.f632,a.P_NIL)) f632,
    max(decode(a.pay_dt,b.f633,a.P_NIL)) f633,
    max(decode(a.pay_dt,b.f634,a.P_NIL)) f634,
    max(decode(a.pay_dt,b.f635,a.P_NIL)) f635,
    max(decode(a.pay_dt,b.f636,a.P_NIL)) f636,
    max(decode(a.pay_dt,b.f637,a.P_NIL)) f637,
    max(decode(a.pay_dt,b.f638,a.P_NIL)) f638,
    max(decode(a.pay_dt,b.f639,a.P_NIL)) f639,
    max(decode(a.pay_dt,b.f640,a.P_NIL)) f640,
    max(decode(a.pay_dt,b.f641,a.P_NIL)) f641,
    max(decode(a.pay_dt,b.f642,a.P_NIL)) f642,
    max(decode(a.pay_dt,b.f643,a.P_NIL)) f643,
    max(decode(a.pay_dt,b.f644,a.P_NIL)) f644,
    max(decode(a.pay_dt,b.f645,a.P_NIL)) f645,
    max(decode(a.pay_dt,b.f646,a.P_NIL)) f646,
    max(decode(a.pay_dt,b.f647,a.P_NIL)) f647,
    max(decode(a.pay_dt,b.f648,a.P_NIL)) f648,
    max(decode(a.pay_dt,b.f649,a.P_NIL)) f649,
    max(decode(a.pay_dt,b.f650,a.P_NIL)) f650,
    max(decode(a.pay_dt,b.f651,a.P_NIL)) f651,
    max(decode(a.pay_dt,b.f652,a.P_NIL)) f652,
    max(decode(a.pay_dt,b.f653,a.P_NIL)) f653,
    max(decode(a.pay_dt,b.f654,a.P_NIL)) f654,
    max(decode(a.pay_dt,b.f655,a.P_NIL)) f655,
    max(decode(a.pay_dt,b.f656,a.P_NIL)) f656,
    max(decode(a.pay_dt,b.f657,a.P_NIL)) f657,
    max(decode(a.pay_dt,b.f658,a.P_NIL)) f658,
    max(decode(a.pay_dt,b.f659,a.P_NIL)) f659,
    max(decode(a.pay_dt,b.f660,a.P_NIL)) f660,
    max(decode(a.pay_dt,b.f661,a.P_NIL)) f661,
    max(decode(a.pay_dt,b.f662,a.P_NIL)) f662,
    max(decode(a.pay_dt,b.f663,a.P_NIL)) f663,
    max(decode(a.pay_dt,b.f664,a.P_NIL)) f664,
    max(decode(a.pay_dt,b.f665,a.P_NIL)) f665,
    max(decode(a.pay_dt,b.f666,a.P_NIL)) f666,
    max(decode(a.pay_dt,b.f667,a.P_NIL)) f667,
    max(decode(a.pay_dt,b.f668,a.P_NIL)) f668,
    max(decode(a.pay_dt,b.f669,a.P_NIL)) f669,
    max(decode(a.pay_dt,b.f670,a.P_NIL)) f670,
    max(decode(a.pay_dt,b.f671,a.P_NIL)) f671,
    max(decode(a.pay_dt,b.f672,a.P_NIL)) f672,
    max(decode(a.pay_dt,b.f673,a.P_NIL)) f673,
    max(decode(a.pay_dt,b.f674,a.P_NIL)) f674,
    max(decode(a.pay_dt,b.f675,a.P_NIL)) f675,
    max(decode(a.pay_dt,b.f676,a.P_NIL)) f676,
    max(decode(a.pay_dt,b.f677,a.P_NIL)) f677,
    max(decode(a.pay_dt,b.f678,a.P_NIL)) f678,
    max(decode(a.pay_dt,b.f679,a.P_NIL)) f679,
    max(decode(a.pay_dt,b.f680,a.P_NIL)) f680,
    max(decode(a.pay_dt,b.f681,a.P_NIL)) f681,
    max(decode(a.pay_dt,b.f682,a.P_NIL)) f682,
    max(decode(a.pay_dt,b.f683,a.P_NIL)) f683,
    max(decode(a.pay_dt,b.f684,a.P_NIL)) f684,
    max(decode(a.pay_dt,b.f685,a.P_NIL)) f685,
    max(decode(a.pay_dt,b.f686,a.P_NIL)) f686,
    max(decode(a.pay_dt,b.f687,a.P_NIL)) f687,
    max(decode(a.pay_dt,b.f688,a.P_NIL)) f688,
    max(decode(a.pay_dt,b.f689,a.P_NIL)) f689,
    max(decode(a.pay_dt,b.f690,a.P_NIL)) f690,
    max(decode(a.pay_dt,b.f691,a.P_NIL)) f691,
    max(decode(a.pay_dt,b.f692,a.P_NIL)) f692,
    max(decode(a.pay_dt,b.f693,a.P_NIL)) f693,
    max(decode(a.pay_dt,b.f694,a.P_NIL)) f694,
    max(decode(a.pay_dt,b.f695,a.P_NIL)) f695,
    max(decode(a.pay_dt,b.f696,a.P_NIL)) f696,
    max(decode(a.pay_dt,b.f697,a.P_NIL)) f697,
    max(decode(a.pay_dt,b.f698,a.P_NIL)) f698,
    max(decode(a.pay_dt,b.f699,a.P_NIL)) f699,
    max(decode(a.pay_dt,b.f700,a.P_NIL)) f700
    from tt2 b, tt0 a
    where 1=1--a.BRANCH_NAM = b.BRANCH_NAM
    and a.SNAPSHOT_DT = b.SNAPSHOT_DT
    group by contract_id_cd,a.BRANCH_NAM,a.SNAPSHOT_DT
)
,tt4 as
(
select 1 rn,'CONTRACT' CONTRACT_ID_CD, 'DEPARTMENT' BRANCH_NAM, SNAPSHOT_DT,
case when to_char(f1,'SS') = 2 then 'Квартал'
     when to_char(f1,'SS') = 3 then 'Год'
     else to_char(f1,'DD.MM.YYYY')
        end f1,
case when to_char(f2,'SS') = 2 then 'Квартал'
     when to_char(f2,'SS') = 3 then 'Год'
     else to_char(f2,'DD.MM.YYYY')
        end f2,
case when to_char(f3,'SS') = 2 then 'Квартал'
     when to_char(f3,'SS') = 3 then 'Год'
     else to_char(f3,'DD.MM.YYYY')
        end f3,
case when to_char(f4,'SS') = 2 then 'Квартал'
     when to_char(f4,'SS') = 3 then 'Год'
     else to_char(f4,'DD.MM.YYYY')
        end f4,
case when to_char(f5,'SS') = 2 then 'Квартал'
     when to_char(f5,'SS') = 3 then 'Год'
     else to_char(f5,'DD.MM.YYYY')
        end f5,
case when to_char(f6,'SS') = 2 then 'Квартал'
     when to_char(f6,'SS') = 3 then 'Год'
     else to_char(f6,'DD.MM.YYYY')
        end f6,
case when to_char(f7,'SS') = 2 then 'Квартал'
     when to_char(f7,'SS') = 3 then 'Год'
     else to_char(f7,'DD.MM.YYYY')
        end f7,
case when to_char(f8,'SS') = 2 then 'Квартал'
     when to_char(f8,'SS') = 3 then 'Год'
     else to_char(f8,'DD.MM.YYYY')
        end f8,
case when to_char(f9,'SS') = 2 then 'Квартал'
     when to_char(f9,'SS') = 3 then 'Год'
     else to_char(f9,'DD.MM.YYYY')
        end f9,
case when to_char(f10,'SS') = 2 then 'Квартал'
     when to_char(f10,'SS') = 3 then 'Год'
     else to_char(f10,'DD.MM.YYYY')
        end f10,
case when to_char(f11,'SS') = 2 then 'Квартал'
     when to_char(f11,'SS') = 3 then 'Год'
     else to_char(f11,'DD.MM.YYYY')
        end f11,
case when to_char(f12,'SS') = 2 then 'Квартал'
     when to_char(f12,'SS') = 3 then 'Год'
     else to_char(f12,'DD.MM.YYYY')
        end f12,
case when to_char(f13,'SS') = 2 then 'Квартал'
     when to_char(f13,'SS') = 3 then 'Год'
     else to_char(f13,'DD.MM.YYYY')
        end f13,
case when to_char(f14,'SS') = 2 then 'Квартал'
     when to_char(f14,'SS') = 3 then 'Год'
     else to_char(f14,'DD.MM.YYYY')
        end f14,
case when to_char(f15,'SS') = 2 then 'Квартал'
     when to_char(f15,'SS') = 3 then 'Год'
     else to_char(f15,'DD.MM.YYYY')
        end f15,
case when to_char(f16,'SS') = 2 then 'Квартал'
     when to_char(f16,'SS') = 3 then 'Год'
     else to_char(f16,'DD.MM.YYYY')
        end f16,
case when to_char(f17,'SS') = 2 then 'Квартал'
     when to_char(f17,'SS') = 3 then 'Год'
     else to_char(f17,'DD.MM.YYYY')
        end f17,
case when to_char(f18,'SS') = 2 then 'Квартал'
     when to_char(f18,'SS') = 3 then 'Год'
     else to_char(f18,'DD.MM.YYYY')
        end f18,
case when to_char(f19,'SS') = 2 then 'Квартал'
     when to_char(f19,'SS') = 3 then 'Год'
     else to_char(f19,'DD.MM.YYYY')
        end f19,
case when to_char(f20,'SS') = 2 then 'Квартал'
     when to_char(f20,'SS') = 3 then 'Год'
     else to_char(f20,'DD.MM.YYYY')
        end f20,
case when to_char(f21,'SS') = 2 then 'Квартал'
     when to_char(f21,'SS') = 3 then 'Год'
     else to_char(f21,'DD.MM.YYYY')
        end f21,
case when to_char(f22,'SS') = 2 then 'Квартал'
     when to_char(f22,'SS') = 3 then 'Год'
     else to_char(f22,'DD.MM.YYYY')
        end f22,
case when to_char(f23,'SS') = 2 then 'Квартал'
     when to_char(f23,'SS') = 3 then 'Год'
     else to_char(f23,'DD.MM.YYYY')
        end f23,
case when to_char(f24,'SS') = 2 then 'Квартал'
     when to_char(f24,'SS') = 3 then 'Год'
     else to_char(f24,'DD.MM.YYYY')
        end f24,
case when to_char(f25,'SS') = 2 then 'Квартал'
     when to_char(f25,'SS') = 3 then 'Год'
     else to_char(f25,'DD.MM.YYYY')
        end f25,
case when to_char(f26,'SS') = 2 then 'Квартал'
     when to_char(f26,'SS') = 3 then 'Год'
     else to_char(f26,'DD.MM.YYYY')
        end f26,
case when to_char(f27,'SS') = 2 then 'Квартал'
     when to_char(f27,'SS') = 3 then 'Год'
     else to_char(f27,'DD.MM.YYYY')
        end f27,
case when to_char(f28,'SS') = 2 then 'Квартал'
     when to_char(f28,'SS') = 3 then 'Год'
     else to_char(f28,'DD.MM.YYYY')
        end f28,
case when to_char(f29,'SS') = 2 then 'Квартал'
     when to_char(f29,'SS') = 3 then 'Год'
     else to_char(f29,'DD.MM.YYYY')
        end f29,
case when to_char(f30,'SS') = 2 then 'Квартал'
     when to_char(f30,'SS') = 3 then 'Год'
     else to_char(f30,'DD.MM.YYYY')
        end f30,
case when to_char(f31,'SS') = 2 then 'Квартал'
     when to_char(f31,'SS') = 3 then 'Год'
     else to_char(f31,'DD.MM.YYYY')
        end f31,
case when to_char(f32,'SS') = 2 then 'Квартал'
     when to_char(f32,'SS') = 3 then 'Год'
     else to_char(f32,'DD.MM.YYYY')
        end f32,
case when to_char(f33,'SS') = 2 then 'Квартал'
     when to_char(f33,'SS') = 3 then 'Год'
     else to_char(f33,'DD.MM.YYYY')
        end f33,
case when to_char(f34,'SS') = 2 then 'Квартал'
     when to_char(f34,'SS') = 3 then 'Год'
     else to_char(f34,'DD.MM.YYYY')
        end f34,
case when to_char(f35,'SS') = 2 then 'Квартал'
     when to_char(f35,'SS') = 3 then 'Год'
     else to_char(f35,'DD.MM.YYYY')
        end f35,
case when to_char(f36,'SS') = 2 then 'Квартал'
     when to_char(f36,'SS') = 3 then 'Год'
     else to_char(f36,'DD.MM.YYYY')
        end f36,
case when to_char(f37,'SS') = 2 then 'Квартал'
     when to_char(f37,'SS') = 3 then 'Год'
     else to_char(f37,'DD.MM.YYYY')
        end f37,
case when to_char(f38,'SS') = 2 then 'Квартал'
     when to_char(f38,'SS') = 3 then 'Год'
     else to_char(f38,'DD.MM.YYYY')
        end f38,
case when to_char(f39,'SS') = 2 then 'Квартал'
     when to_char(f39,'SS') = 3 then 'Год'
     else to_char(f39,'DD.MM.YYYY')
        end f39,
case when to_char(f40,'SS') = 2 then 'Квартал'
     when to_char(f40,'SS') = 3 then 'Год'
     else to_char(f40,'DD.MM.YYYY')
        end f40,
case when to_char(f41,'SS') = 2 then 'Квартал'
     when to_char(f41,'SS') = 3 then 'Год'
     else to_char(f41,'DD.MM.YYYY')
        end f41,
case when to_char(f42,'SS') = 2 then 'Квартал'
     when to_char(f42,'SS') = 3 then 'Год'
     else to_char(f42,'DD.MM.YYYY')
        end f42,
case when to_char(f43,'SS') = 2 then 'Квартал'
     when to_char(f43,'SS') = 3 then 'Год'
     else to_char(f43,'DD.MM.YYYY')
        end f43,
case when to_char(f44,'SS') = 2 then 'Квартал'
     when to_char(f44,'SS') = 3 then 'Год'
     else to_char(f44,'DD.MM.YYYY')
        end f44,
case when to_char(f45,'SS') = 2 then 'Квартал'
     when to_char(f45,'SS') = 3 then 'Год'
     else to_char(f45,'DD.MM.YYYY')
        end f45,
case when to_char(f46,'SS') = 2 then 'Квартал'
     when to_char(f46,'SS') = 3 then 'Год'
     else to_char(f46,'DD.MM.YYYY')
        end f46,
case when to_char(f47,'SS') = 2 then 'Квартал'
     when to_char(f47,'SS') = 3 then 'Год'
     else to_char(f47,'DD.MM.YYYY')
        end f47,
case when to_char(f48,'SS') = 2 then 'Квартал'
     when to_char(f48,'SS') = 3 then 'Год'
     else to_char(f48,'DD.MM.YYYY')
        end f48,
case when to_char(f49,'SS') = 2 then 'Квартал'
     when to_char(f49,'SS') = 3 then 'Год'
     else to_char(f49,'DD.MM.YYYY')
        end f49,
case when to_char(f50,'SS') = 2 then 'Квартал'
     when to_char(f50,'SS') = 3 then 'Год'
     else to_char(f50,'DD.MM.YYYY')
        end f50,
case when to_char(f51,'SS') = 2 then 'Квартал'
     when to_char(f51,'SS') = 3 then 'Год'
     else to_char(f51,'DD.MM.YYYY')
        end f51,
case when to_char(f52,'SS') = 2 then 'Квартал'
     when to_char(f52,'SS') = 3 then 'Год'
     else to_char(f52,'DD.MM.YYYY')
        end f52,
case when to_char(f53,'SS') = 2 then 'Квартал'
     when to_char(f53,'SS') = 3 then 'Год'
     else to_char(f53,'DD.MM.YYYY')
        end f53,
case when to_char(f54,'SS') = 2 then 'Квартал'
     when to_char(f54,'SS') = 3 then 'Год'
     else to_char(f54,'DD.MM.YYYY')
        end f54,
case when to_char(f55,'SS') = 2 then 'Квартал'
     when to_char(f55,'SS') = 3 then 'Год'
     else to_char(f55,'DD.MM.YYYY')
        end f55,
case when to_char(f56,'SS') = 2 then 'Квартал'
     when to_char(f56,'SS') = 3 then 'Год'
     else to_char(f56,'DD.MM.YYYY')
        end f56,
case when to_char(f57,'SS') = 2 then 'Квартал'
     when to_char(f57,'SS') = 3 then 'Год'
     else to_char(f57,'DD.MM.YYYY')
        end f57,
case when to_char(f58,'SS') = 2 then 'Квартал'
     when to_char(f58,'SS') = 3 then 'Год'
     else to_char(f58,'DD.MM.YYYY')
        end f58,
case when to_char(f59,'SS') = 2 then 'Квартал'
     when to_char(f59,'SS') = 3 then 'Год'
     else to_char(f59,'DD.MM.YYYY')
        end f59,
case when to_char(f60,'SS') = 2 then 'Квартал'
     when to_char(f60,'SS') = 3 then 'Год'
     else to_char(f60,'DD.MM.YYYY')
        end f60,
case when to_char(f61,'SS') = 2 then 'Квартал'
     when to_char(f61,'SS') = 3 then 'Год'
     else to_char(f61,'DD.MM.YYYY')
        end f61,
case when to_char(f62,'SS') = 2 then 'Квартал'
     when to_char(f62,'SS') = 3 then 'Год'
     else to_char(f62,'DD.MM.YYYY')
        end f62,
case when to_char(f63,'SS') = 2 then 'Квартал'
     when to_char(f63,'SS') = 3 then 'Год'
     else to_char(f63,'DD.MM.YYYY')
        end f63,
case when to_char(f64,'SS') = 2 then 'Квартал'
     when to_char(f64,'SS') = 3 then 'Год'
     else to_char(f64,'DD.MM.YYYY')
        end f64,
case when to_char(f65,'SS') = 2 then 'Квартал'
     when to_char(f65,'SS') = 3 then 'Год'
     else to_char(f65,'DD.MM.YYYY')
        end f65,
case when to_char(f66,'SS') = 2 then 'Квартал'
     when to_char(f66,'SS') = 3 then 'Год'
     else to_char(f66,'DD.MM.YYYY')
        end f66,
case when to_char(f67,'SS') = 2 then 'Квартал'
     when to_char(f67,'SS') = 3 then 'Год'
     else to_char(f67,'DD.MM.YYYY')
        end f67,
case when to_char(f68,'SS') = 2 then 'Квартал'
     when to_char(f68,'SS') = 3 then 'Год'
     else to_char(f68,'DD.MM.YYYY')
        end f68,
case when to_char(f69,'SS') = 2 then 'Квартал'
     when to_char(f69,'SS') = 3 then 'Год'
     else to_char(f69,'DD.MM.YYYY')
        end f69,
case when to_char(f70,'SS') = 2 then 'Квартал'
     when to_char(f70,'SS') = 3 then 'Год'
     else to_char(f70,'DD.MM.YYYY')
        end f70,
case when to_char(f71,'SS') = 2 then 'Квартал'
     when to_char(f71,'SS') = 3 then 'Год'
     else to_char(f71,'DD.MM.YYYY')
        end f71,
case when to_char(f72,'SS') = 2 then 'Квартал'
     when to_char(f72,'SS') = 3 then 'Год'
     else to_char(f72,'DD.MM.YYYY')
        end f72,
case when to_char(f73,'SS') = 2 then 'Квартал'
     when to_char(f73,'SS') = 3 then 'Год'
     else to_char(f73,'DD.MM.YYYY')
        end f73,
case when to_char(f74,'SS') = 2 then 'Квартал'
     when to_char(f74,'SS') = 3 then 'Год'
     else to_char(f74,'DD.MM.YYYY')
        end f74,
case when to_char(f75,'SS') = 2 then 'Квартал'
     when to_char(f75,'SS') = 3 then 'Год'
     else to_char(f75,'DD.MM.YYYY')
        end f75,
case when to_char(f76,'SS') = 2 then 'Квартал'
     when to_char(f76,'SS') = 3 then 'Год'
     else to_char(f76,'DD.MM.YYYY')
        end f76,
case when to_char(f77,'SS') = 2 then 'Квартал'
     when to_char(f77,'SS') = 3 then 'Год'
     else to_char(f77,'DD.MM.YYYY')
        end f77,
case when to_char(f78,'SS') = 2 then 'Квартал'
     when to_char(f78,'SS') = 3 then 'Год'
     else to_char(f78,'DD.MM.YYYY')
        end f78,
case when to_char(f79,'SS') = 2 then 'Квартал'
     when to_char(f79,'SS') = 3 then 'Год'
     else to_char(f79,'DD.MM.YYYY')
        end f79,
case when to_char(f80,'SS') = 2 then 'Квартал'
     when to_char(f80,'SS') = 3 then 'Год'
     else to_char(f80,'DD.MM.YYYY')
        end f80,
case when to_char(f81,'SS') = 2 then 'Квартал'
     when to_char(f81,'SS') = 3 then 'Год'
     else to_char(f81,'DD.MM.YYYY')
        end f81,
case when to_char(f82,'SS') = 2 then 'Квартал'
     when to_char(f82,'SS') = 3 then 'Год'
     else to_char(f82,'DD.MM.YYYY')
        end f82,
case when to_char(f83,'SS') = 2 then 'Квартал'
     when to_char(f83,'SS') = 3 then 'Год'
     else to_char(f83,'DD.MM.YYYY')
        end f83,
case when to_char(f84,'SS') = 2 then 'Квартал'
     when to_char(f84,'SS') = 3 then 'Год'
     else to_char(f84,'DD.MM.YYYY')
        end f84,
case when to_char(f85,'SS') = 2 then 'Квартал'
     when to_char(f85,'SS') = 3 then 'Год'
     else to_char(f85,'DD.MM.YYYY')
        end f85,
case when to_char(f86,'SS') = 2 then 'Квартал'
     when to_char(f86,'SS') = 3 then 'Год'
     else to_char(f86,'DD.MM.YYYY')
        end f86,
case when to_char(f87,'SS') = 2 then 'Квартал'
     when to_char(f87,'SS') = 3 then 'Год'
     else to_char(f87,'DD.MM.YYYY')
        end f87,
case when to_char(f88,'SS') = 2 then 'Квартал'
     when to_char(f88,'SS') = 3 then 'Год'
     else to_char(f88,'DD.MM.YYYY')
        end f88,
case when to_char(f89,'SS') = 2 then 'Квартал'
     when to_char(f89,'SS') = 3 then 'Год'
     else to_char(f89,'DD.MM.YYYY')
        end f89,
case when to_char(f90,'SS') = 2 then 'Квартал'
     when to_char(f90,'SS') = 3 then 'Год'
     else to_char(f90,'DD.MM.YYYY')
        end f90,
case when to_char(f91,'SS') = 2 then 'Квартал'
     when to_char(f91,'SS') = 3 then 'Год'
     else to_char(f91,'DD.MM.YYYY')
        end f91,
case when to_char(f92,'SS') = 2 then 'Квартал'
     when to_char(f92,'SS') = 3 then 'Год'
     else to_char(f92,'DD.MM.YYYY')
        end f92,
case when to_char(f93,'SS') = 2 then 'Квартал'
     when to_char(f93,'SS') = 3 then 'Год'
     else to_char(f93,'DD.MM.YYYY')
        end f93,
case when to_char(f94,'SS') = 2 then 'Квартал'
     when to_char(f94,'SS') = 3 then 'Год'
     else to_char(f94,'DD.MM.YYYY')
        end f94,
case when to_char(f95,'SS') = 2 then 'Квартал'
     when to_char(f95,'SS') = 3 then 'Год'
     else to_char(f95,'DD.MM.YYYY')
        end f95,
case when to_char(f96,'SS') = 2 then 'Квартал'
     when to_char(f96,'SS') = 3 then 'Год'
     else to_char(f96,'DD.MM.YYYY')
        end f96,
case when to_char(f97,'SS') = 2 then 'Квартал'
     when to_char(f97,'SS') = 3 then 'Год'
     else to_char(f97,'DD.MM.YYYY')
        end f97,
case when to_char(f98,'SS') = 2 then 'Квартал'
     when to_char(f98,'SS') = 3 then 'Год'
     else to_char(f98,'DD.MM.YYYY')
        end f98,
case when to_char(f99,'SS') = 2 then 'Квартал'
     when to_char(f99,'SS') = 3 then 'Год'
     else to_char(f99,'DD.MM.YYYY')
        end f99,
case when to_char(f100,'SS') = 2 then 'Квартал'
     when to_char(f100,'SS') = 3 then 'Год'
     else to_char(f100,'DD.MM.YYYY')
        end f100,
case when to_char(f101,'SS') = 2 then 'Квартал'
     when to_char(f101,'SS') = 3 then 'Год'
     else to_char(f101,'DD.MM.YYYY')
        end f101,
case when to_char(f102,'SS') = 2 then 'Квартал'
     when to_char(f102,'SS') = 3 then 'Год'
     else to_char(f102,'DD.MM.YYYY')
        end f102,
case when to_char(f103,'SS') = 2 then 'Квартал'
     when to_char(f103,'SS') = 3 then 'Год'
     else to_char(f103,'DD.MM.YYYY')
        end f103,
case when to_char(f104,'SS') = 2 then 'Квартал'
     when to_char(f104,'SS') = 3 then 'Год'
     else to_char(f104,'DD.MM.YYYY')
        end f104,
case when to_char(f105,'SS') = 2 then 'Квартал'
     when to_char(f105,'SS') = 3 then 'Год'
     else to_char(f105,'DD.MM.YYYY')
        end f105,
case when to_char(f106,'SS') = 2 then 'Квартал'
     when to_char(f106,'SS') = 3 then 'Год'
     else to_char(f106,'DD.MM.YYYY')
        end f106,
case when to_char(f107,'SS') = 2 then 'Квартал'
     when to_char(f107,'SS') = 3 then 'Год'
     else to_char(f107,'DD.MM.YYYY')
        end f107,
case when to_char(f108,'SS') = 2 then 'Квартал'
     when to_char(f108,'SS') = 3 then 'Год'
     else to_char(f108,'DD.MM.YYYY')
        end f108,
case when to_char(f109,'SS') = 2 then 'Квартал'
     when to_char(f109,'SS') = 3 then 'Год'
     else to_char(f109,'DD.MM.YYYY')
        end f109,
case when to_char(f110,'SS') = 2 then 'Квартал'
     when to_char(f110,'SS') = 3 then 'Год'
     else to_char(f110,'DD.MM.YYYY')
        end f110,
case when to_char(f111,'SS') = 2 then 'Квартал'
     when to_char(f111,'SS') = 3 then 'Год'
     else to_char(f111,'DD.MM.YYYY')
        end f111,
case when to_char(f112,'SS') = 2 then 'Квартал'
     when to_char(f112,'SS') = 3 then 'Год'
     else to_char(f112,'DD.MM.YYYY')
        end f112,
case when to_char(f113,'SS') = 2 then 'Квартал'
     when to_char(f113,'SS') = 3 then 'Год'
     else to_char(f113,'DD.MM.YYYY')
        end f113,
case when to_char(f114,'SS') = 2 then 'Квартал'
     when to_char(f114,'SS') = 3 then 'Год'
     else to_char(f114,'DD.MM.YYYY')
        end f114,
case when to_char(f115,'SS') = 2 then 'Квартал'
     when to_char(f115,'SS') = 3 then 'Год'
     else to_char(f115,'DD.MM.YYYY')
        end f115,
case when to_char(f116,'SS') = 2 then 'Квартал'
     when to_char(f116,'SS') = 3 then 'Год'
     else to_char(f116,'DD.MM.YYYY')
        end f116,
case when to_char(f117,'SS') = 2 then 'Квартал'
     when to_char(f117,'SS') = 3 then 'Год'
     else to_char(f117,'DD.MM.YYYY')
        end f117,
case when to_char(f118,'SS') = 2 then 'Квартал'
     when to_char(f118,'SS') = 3 then 'Год'
     else to_char(f118,'DD.MM.YYYY')
        end f118,
case when to_char(f119,'SS') = 2 then 'Квартал'
     when to_char(f119,'SS') = 3 then 'Год'
     else to_char(f119,'DD.MM.YYYY')
        end f119,
case when to_char(f120,'SS') = 2 then 'Квартал'
     when to_char(f120,'SS') = 3 then 'Год'
     else to_char(f120,'DD.MM.YYYY')
        end f120,
case when to_char(f121,'SS') = 2 then 'Квартал'
     when to_char(f121,'SS') = 3 then 'Год'
     else to_char(f121,'DD.MM.YYYY')
        end f121,
case when to_char(f122,'SS') = 2 then 'Квартал'
     when to_char(f122,'SS') = 3 then 'Год'
     else to_char(f122,'DD.MM.YYYY')
        end f122,
case when to_char(f123,'SS') = 2 then 'Квартал'
     when to_char(f123,'SS') = 3 then 'Год'
     else to_char(f123,'DD.MM.YYYY')
        end f123,
case when to_char(f124,'SS') = 2 then 'Квартал'
     when to_char(f124,'SS') = 3 then 'Год'
     else to_char(f124,'DD.MM.YYYY')
        end f124,
case when to_char(f125,'SS') = 2 then 'Квартал'
     when to_char(f125,'SS') = 3 then 'Год'
     else to_char(f125,'DD.MM.YYYY')
        end f125,
case when to_char(f126,'SS') = 2 then 'Квартал'
     when to_char(f126,'SS') = 3 then 'Год'
     else to_char(f126,'DD.MM.YYYY')
        end f126,
case when to_char(f127,'SS') = 2 then 'Квартал'
     when to_char(f127,'SS') = 3 then 'Год'
     else to_char(f127,'DD.MM.YYYY')
        end f127,
case when to_char(f128,'SS') = 2 then 'Квартал'
     when to_char(f128,'SS') = 3 then 'Год'
     else to_char(f128,'DD.MM.YYYY')
        end f128,
case when to_char(f129,'SS') = 2 then 'Квартал'
     when to_char(f129,'SS') = 3 then 'Год'
     else to_char(f129,'DD.MM.YYYY')
        end f129,
case when to_char(f130,'SS') = 2 then 'Квартал'
     when to_char(f130,'SS') = 3 then 'Год'
     else to_char(f130,'DD.MM.YYYY')
        end f130,
case when to_char(f131,'SS') = 2 then 'Квартал'
     when to_char(f131,'SS') = 3 then 'Год'
     else to_char(f131,'DD.MM.YYYY')
        end f131,
case when to_char(f132,'SS') = 2 then 'Квартал'
     when to_char(f132,'SS') = 3 then 'Год'
     else to_char(f132,'DD.MM.YYYY')
        end f132,
case when to_char(f133,'SS') = 2 then 'Квартал'
     when to_char(f133,'SS') = 3 then 'Год'
     else to_char(f133,'DD.MM.YYYY')
        end f133,
case when to_char(f134,'SS') = 2 then 'Квартал'
     when to_char(f134,'SS') = 3 then 'Год'
     else to_char(f134,'DD.MM.YYYY')
        end f134,
case when to_char(f135,'SS') = 2 then 'Квартал'
     when to_char(f135,'SS') = 3 then 'Год'
     else to_char(f135,'DD.MM.YYYY')
        end f135,
case when to_char(f136,'SS') = 2 then 'Квартал'
     when to_char(f136,'SS') = 3 then 'Год'
     else to_char(f136,'DD.MM.YYYY')
        end f136,
case when to_char(f137,'SS') = 2 then 'Квартал'
     when to_char(f137,'SS') = 3 then 'Год'
     else to_char(f137,'DD.MM.YYYY')
        end f137,
case when to_char(f138,'SS') = 2 then 'Квартал'
     when to_char(f138,'SS') = 3 then 'Год'
     else to_char(f138,'DD.MM.YYYY')
        end f138,
case when to_char(f139,'SS') = 2 then 'Квартал'
     when to_char(f139,'SS') = 3 then 'Год'
     else to_char(f139,'DD.MM.YYYY')
        end f139,
case when to_char(f140,'SS') = 2 then 'Квартал'
     when to_char(f140,'SS') = 3 then 'Год'
     else to_char(f140,'DD.MM.YYYY')
        end f140,
case when to_char(f141,'SS') = 2 then 'Квартал'
     when to_char(f141,'SS') = 3 then 'Год'
     else to_char(f141,'DD.MM.YYYY')
        end f141,
case when to_char(f142,'SS') = 2 then 'Квартал'
     when to_char(f142,'SS') = 3 then 'Год'
     else to_char(f142,'DD.MM.YYYY')
        end f142,
case when to_char(f143,'SS') = 2 then 'Квартал'
     when to_char(f143,'SS') = 3 then 'Год'
     else to_char(f143,'DD.MM.YYYY')
        end f143,
case when to_char(f144,'SS') = 2 then 'Квартал'
     when to_char(f144,'SS') = 3 then 'Год'
     else to_char(f144,'DD.MM.YYYY')
        end f144,
case when to_char(f145,'SS') = 2 then 'Квартал'
     when to_char(f145,'SS') = 3 then 'Год'
     else to_char(f145,'DD.MM.YYYY')
        end f145,
case when to_char(f146,'SS') = 2 then 'Квартал'
     when to_char(f146,'SS') = 3 then 'Год'
     else to_char(f146,'DD.MM.YYYY')
        end f146,
case when to_char(f147,'SS') = 2 then 'Квартал'
     when to_char(f147,'SS') = 3 then 'Год'
     else to_char(f147,'DD.MM.YYYY')
        end f147,
case when to_char(f148,'SS') = 2 then 'Квартал'
     when to_char(f148,'SS') = 3 then 'Год'
     else to_char(f148,'DD.MM.YYYY')
        end f148,
case when to_char(f149,'SS') = 2 then 'Квартал'
     when to_char(f149,'SS') = 3 then 'Год'
     else to_char(f149,'DD.MM.YYYY')
        end f149,
case when to_char(f150,'SS') = 2 then 'Квартал'
     when to_char(f150,'SS') = 3 then 'Год'
     else to_char(f150,'DD.MM.YYYY')
        end f150,
case when to_char(f151,'SS') = 2 then 'Квартал'
     when to_char(f151,'SS') = 3 then 'Год'
     else to_char(f151,'DD.MM.YYYY')
        end f151,
case when to_char(f152,'SS') = 2 then 'Квартал'
     when to_char(f152,'SS') = 3 then 'Год'
     else to_char(f152,'DD.MM.YYYY')
        end f152,
case when to_char(f153,'SS') = 2 then 'Квартал'
     when to_char(f153,'SS') = 3 then 'Год'
     else to_char(f153,'DD.MM.YYYY')
        end f153,
case when to_char(f154,'SS') = 2 then 'Квартал'
     when to_char(f154,'SS') = 3 then 'Год'
     else to_char(f154,'DD.MM.YYYY')
        end f154,
case when to_char(f155,'SS') = 2 then 'Квартал'
     when to_char(f155,'SS') = 3 then 'Год'
     else to_char(f155,'DD.MM.YYYY')
        end f155,
case when to_char(f156,'SS') = 2 then 'Квартал'
     when to_char(f156,'SS') = 3 then 'Год'
     else to_char(f156,'DD.MM.YYYY')
        end f156,
case when to_char(f157,'SS') = 2 then 'Квартал'
     when to_char(f157,'SS') = 3 then 'Год'
     else to_char(f157,'DD.MM.YYYY')
        end f157,
case when to_char(f158,'SS') = 2 then 'Квартал'
     when to_char(f158,'SS') = 3 then 'Год'
     else to_char(f158,'DD.MM.YYYY')
        end f158,
case when to_char(f159,'SS') = 2 then 'Квартал'
     when to_char(f159,'SS') = 3 then 'Год'
     else to_char(f159,'DD.MM.YYYY')
        end f159,
case when to_char(f160,'SS') = 2 then 'Квартал'
     when to_char(f160,'SS') = 3 then 'Год'
     else to_char(f160,'DD.MM.YYYY')
        end f160,
case when to_char(f161,'SS') = 2 then 'Квартал'
     when to_char(f161,'SS') = 3 then 'Год'
     else to_char(f161,'DD.MM.YYYY')
        end f161,
case when to_char(f162,'SS') = 2 then 'Квартал'
     when to_char(f162,'SS') = 3 then 'Год'
     else to_char(f162,'DD.MM.YYYY')
        end f162,
case when to_char(f163,'SS') = 2 then 'Квартал'
     when to_char(f163,'SS') = 3 then 'Год'
     else to_char(f163,'DD.MM.YYYY')
        end f163,
case when to_char(f164,'SS') = 2 then 'Квартал'
     when to_char(f164,'SS') = 3 then 'Год'
     else to_char(f164,'DD.MM.YYYY')
        end f164,
case when to_char(f165,'SS') = 2 then 'Квартал'
     when to_char(f165,'SS') = 3 then 'Год'
     else to_char(f165,'DD.MM.YYYY')
        end f165,
case when to_char(f166,'SS') = 2 then 'Квартал'
     when to_char(f166,'SS') = 3 then 'Год'
     else to_char(f166,'DD.MM.YYYY')
        end f166,
case when to_char(f167,'SS') = 2 then 'Квартал'
     when to_char(f167,'SS') = 3 then 'Год'
     else to_char(f167,'DD.MM.YYYY')
        end f167,
case when to_char(f168,'SS') = 2 then 'Квартал'
     when to_char(f168,'SS') = 3 then 'Год'
     else to_char(f168,'DD.MM.YYYY')
        end f168,
case when to_char(f169,'SS') = 2 then 'Квартал'
     when to_char(f169,'SS') = 3 then 'Год'
     else to_char(f169,'DD.MM.YYYY')
        end f169,
case when to_char(f170,'SS') = 2 then 'Квартал'
     when to_char(f170,'SS') = 3 then 'Год'
     else to_char(f170,'DD.MM.YYYY')
        end f170,
case when to_char(f171,'SS') = 2 then 'Квартал'
     when to_char(f171,'SS') = 3 then 'Год'
     else to_char(f171,'DD.MM.YYYY')
        end f171,
case when to_char(f172,'SS') = 2 then 'Квартал'
     when to_char(f172,'SS') = 3 then 'Год'
     else to_char(f172,'DD.MM.YYYY')
        end f172,
case when to_char(f173,'SS') = 2 then 'Квартал'
     when to_char(f173,'SS') = 3 then 'Год'
     else to_char(f173,'DD.MM.YYYY')
        end f173,
case when to_char(f174,'SS') = 2 then 'Квартал'
     when to_char(f174,'SS') = 3 then 'Год'
     else to_char(f174,'DD.MM.YYYY')
        end f174,
case when to_char(f175,'SS') = 2 then 'Квартал'
     when to_char(f175,'SS') = 3 then 'Год'
     else to_char(f175,'DD.MM.YYYY')
        end f175,
case when to_char(f176,'SS') = 2 then 'Квартал'
     when to_char(f176,'SS') = 3 then 'Год'
     else to_char(f176,'DD.MM.YYYY')
        end f176,
case when to_char(f177,'SS') = 2 then 'Квартал'
     when to_char(f177,'SS') = 3 then 'Год'
     else to_char(f177,'DD.MM.YYYY')
        end f177,
case when to_char(f178,'SS') = 2 then 'Квартал'
     when to_char(f178,'SS') = 3 then 'Год'
     else to_char(f178,'DD.MM.YYYY')
        end f178,
case when to_char(f179,'SS') = 2 then 'Квартал'
     when to_char(f179,'SS') = 3 then 'Год'
     else to_char(f179,'DD.MM.YYYY')
        end f179,
case when to_char(f180,'SS') = 2 then 'Квартал'
     when to_char(f180,'SS') = 3 then 'Год'
     else to_char(f180,'DD.MM.YYYY')
        end f180,
case when to_char(f181,'SS') = 2 then 'Квартал'
     when to_char(f181,'SS') = 3 then 'Год'
     else to_char(f181,'DD.MM.YYYY')
        end f181,
case when to_char(f182,'SS') = 2 then 'Квартал'
     when to_char(f182,'SS') = 3 then 'Год'
     else to_char(f182,'DD.MM.YYYY')
        end f182,
case when to_char(f183,'SS') = 2 then 'Квартал'
     when to_char(f183,'SS') = 3 then 'Год'
     else to_char(f183,'DD.MM.YYYY')
        end f183,
case when to_char(f184,'SS') = 2 then 'Квартал'
     when to_char(f184,'SS') = 3 then 'Год'
     else to_char(f184,'DD.MM.YYYY')
        end f184,
case when to_char(f185,'SS') = 2 then 'Квартал'
     when to_char(f185,'SS') = 3 then 'Год'
     else to_char(f185,'DD.MM.YYYY')
        end f185,
case when to_char(f186,'SS') = 2 then 'Квартал'
     when to_char(f186,'SS') = 3 then 'Год'
     else to_char(f186,'DD.MM.YYYY')
        end f186,
case when to_char(f187,'SS') = 2 then 'Квартал'
     when to_char(f187,'SS') = 3 then 'Год'
     else to_char(f187,'DD.MM.YYYY')
        end f187,
case when to_char(f188,'SS') = 2 then 'Квартал'
     when to_char(f188,'SS') = 3 then 'Год'
     else to_char(f188,'DD.MM.YYYY')
        end f188,
case when to_char(f189,'SS') = 2 then 'Квартал'
     when to_char(f189,'SS') = 3 then 'Год'
     else to_char(f189,'DD.MM.YYYY')
        end f189,
case when to_char(f190,'SS') = 2 then 'Квартал'
     when to_char(f190,'SS') = 3 then 'Год'
     else to_char(f190,'DD.MM.YYYY')
        end f190,
case when to_char(f191,'SS') = 2 then 'Квартал'
     when to_char(f191,'SS') = 3 then 'Год'
     else to_char(f191,'DD.MM.YYYY')
        end f191,
case when to_char(f192,'SS') = 2 then 'Квартал'
     when to_char(f192,'SS') = 3 then 'Год'
     else to_char(f192,'DD.MM.YYYY')
        end f192,
case when to_char(f193,'SS') = 2 then 'Квартал'
     when to_char(f193,'SS') = 3 then 'Год'
     else to_char(f193,'DD.MM.YYYY')
        end f193,
case when to_char(f194,'SS') = 2 then 'Квартал'
     when to_char(f194,'SS') = 3 then 'Год'
     else to_char(f194,'DD.MM.YYYY')
        end f194,
case when to_char(f195,'SS') = 2 then 'Квартал'
     when to_char(f195,'SS') = 3 then 'Год'
     else to_char(f195,'DD.MM.YYYY')
        end f195,
case when to_char(f196,'SS') = 2 then 'Квартал'
     when to_char(f196,'SS') = 3 then 'Год'
     else to_char(f196,'DD.MM.YYYY')
        end f196,
case when to_char(f197,'SS') = 2 then 'Квартал'
     when to_char(f197,'SS') = 3 then 'Год'
     else to_char(f197,'DD.MM.YYYY')
        end f197,
case when to_char(f198,'SS') = 2 then 'Квартал'
     when to_char(f198,'SS') = 3 then 'Год'
     else to_char(f198,'DD.MM.YYYY')
        end f198,
case when to_char(f199,'SS') = 2 then 'Квартал'
     when to_char(f199,'SS') = 3 then 'Год'
     else to_char(f199,'DD.MM.YYYY')
        end f199,
case when to_char(f200,'SS') = 2 then 'Квартал'
     when to_char(f200,'SS') = 3 then 'Год'
     else to_char(f200,'DD.MM.YYYY')
        end f200,
case when to_char(f201,'SS') = 2 then 'Квартал'
     when to_char(f201,'SS') = 3 then 'Год'
     else to_char(f201,'DD.MM.YYYY')
        end f201,
case when to_char(f202,'SS') = 2 then 'Квартал'
     when to_char(f202,'SS') = 3 then 'Год'
     else to_char(f202,'DD.MM.YYYY')
        end f202,
case when to_char(f203,'SS') = 2 then 'Квартал'
     when to_char(f203,'SS') = 3 then 'Год'
     else to_char(f203,'DD.MM.YYYY')
        end f203,
case when to_char(f204,'SS') = 2 then 'Квартал'
     when to_char(f204,'SS') = 3 then 'Год'
     else to_char(f204,'DD.MM.YYYY')
        end f204,
case when to_char(f205,'SS') = 2 then 'Квартал'
     when to_char(f205,'SS') = 3 then 'Год'
     else to_char(f205,'DD.MM.YYYY')
        end f205,
case when to_char(f206,'SS') = 2 then 'Квартал'
     when to_char(f206,'SS') = 3 then 'Год'
     else to_char(f206,'DD.MM.YYYY')
        end f206,
case when to_char(f207,'SS') = 2 then 'Квартал'
     when to_char(f207,'SS') = 3 then 'Год'
     else to_char(f207,'DD.MM.YYYY')
        end f207,
case when to_char(f208,'SS') = 2 then 'Квартал'
     when to_char(f208,'SS') = 3 then 'Год'
     else to_char(f208,'DD.MM.YYYY')
        end f208,
case when to_char(f209,'SS') = 2 then 'Квартал'
     when to_char(f209,'SS') = 3 then 'Год'
     else to_char(f209,'DD.MM.YYYY')
        end f209,
case when to_char(f210,'SS') = 2 then 'Квартал'
     when to_char(f210,'SS') = 3 then 'Год'
     else to_char(f210,'DD.MM.YYYY')
        end f210,
case when to_char(f211,'SS') = 2 then 'Квартал'
     when to_char(f211,'SS') = 3 then 'Год'
     else to_char(f211,'DD.MM.YYYY')
        end f211,
case when to_char(f212,'SS') = 2 then 'Квартал'
     when to_char(f212,'SS') = 3 then 'Год'
     else to_char(f212,'DD.MM.YYYY')
        end f212,
case when to_char(f213,'SS') = 2 then 'Квартал'
     when to_char(f213,'SS') = 3 then 'Год'
     else to_char(f213,'DD.MM.YYYY')
        end f213,
case when to_char(f214,'SS') = 2 then 'Квартал'
     when to_char(f214,'SS') = 3 then 'Год'
     else to_char(f214,'DD.MM.YYYY')
        end f214,
case when to_char(f215,'SS') = 2 then 'Квартал'
     when to_char(f215,'SS') = 3 then 'Год'
     else to_char(f215,'DD.MM.YYYY')
        end f215,
case when to_char(f216,'SS') = 2 then 'Квартал'
     when to_char(f216,'SS') = 3 then 'Год'
     else to_char(f216,'DD.MM.YYYY')
        end f216,
case when to_char(f217,'SS') = 2 then 'Квартал'
     when to_char(f217,'SS') = 3 then 'Год'
     else to_char(f217,'DD.MM.YYYY')
        end f217,
case when to_char(f218,'SS') = 2 then 'Квартал'
     when to_char(f218,'SS') = 3 then 'Год'
     else to_char(f218,'DD.MM.YYYY')
        end f218,
case when to_char(f219,'SS') = 2 then 'Квартал'
     when to_char(f219,'SS') = 3 then 'Год'
     else to_char(f219,'DD.MM.YYYY')
        end f219,
case when to_char(f220,'SS') = 2 then 'Квартал'
     when to_char(f220,'SS') = 3 then 'Год'
     else to_char(f220,'DD.MM.YYYY')
        end f220,
case when to_char(f221,'SS') = 2 then 'Квартал'
     when to_char(f221,'SS') = 3 then 'Год'
     else to_char(f221,'DD.MM.YYYY')
        end f221,
case when to_char(f222,'SS') = 2 then 'Квартал'
     when to_char(f222,'SS') = 3 then 'Год'
     else to_char(f222,'DD.MM.YYYY')
        end f222,
case when to_char(f223,'SS') = 2 then 'Квартал'
     when to_char(f223,'SS') = 3 then 'Год'
     else to_char(f223,'DD.MM.YYYY')
        end f223,
case when to_char(f224,'SS') = 2 then 'Квартал'
     when to_char(f224,'SS') = 3 then 'Год'
     else to_char(f224,'DD.MM.YYYY')
        end f224,
case when to_char(f225,'SS') = 2 then 'Квартал'
     when to_char(f225,'SS') = 3 then 'Год'
     else to_char(f225,'DD.MM.YYYY')
        end f225,
case when to_char(f226,'SS') = 2 then 'Квартал'
     when to_char(f226,'SS') = 3 then 'Год'
     else to_char(f226,'DD.MM.YYYY')
        end f226,
case when to_char(f227,'SS') = 2 then 'Квартал'
     when to_char(f227,'SS') = 3 then 'Год'
     else to_char(f227,'DD.MM.YYYY')
        end f227,
case when to_char(f228,'SS') = 2 then 'Квартал'
     when to_char(f228,'SS') = 3 then 'Год'
     else to_char(f228,'DD.MM.YYYY')
        end f228,
case when to_char(f229,'SS') = 2 then 'Квартал'
     when to_char(f229,'SS') = 3 then 'Год'
     else to_char(f229,'DD.MM.YYYY')
        end f229,
case when to_char(f230,'SS') = 2 then 'Квартал'
     when to_char(f230,'SS') = 3 then 'Год'
     else to_char(f230,'DD.MM.YYYY')
        end f230,
case when to_char(f231,'SS') = 2 then 'Квартал'
     when to_char(f231,'SS') = 3 then 'Год'
     else to_char(f231,'DD.MM.YYYY')
        end f231,
case when to_char(f232,'SS') = 2 then 'Квартал'
     when to_char(f232,'SS') = 3 then 'Год'
     else to_char(f232,'DD.MM.YYYY')
        end f232,
case when to_char(f233,'SS') = 2 then 'Квартал'
     when to_char(f233,'SS') = 3 then 'Год'
     else to_char(f233,'DD.MM.YYYY')
        end f233,
case when to_char(f234,'SS') = 2 then 'Квартал'
     when to_char(f234,'SS') = 3 then 'Год'
     else to_char(f234,'DD.MM.YYYY')
        end f234,
case when to_char(f235,'SS') = 2 then 'Квартал'
     when to_char(f235,'SS') = 3 then 'Год'
     else to_char(f235,'DD.MM.YYYY')
        end f235,
case when to_char(f236,'SS') = 2 then 'Квартал'
     when to_char(f236,'SS') = 3 then 'Год'
     else to_char(f236,'DD.MM.YYYY')
        end f236,
case when to_char(f237,'SS') = 2 then 'Квартал'
     when to_char(f237,'SS') = 3 then 'Год'
     else to_char(f237,'DD.MM.YYYY')
        end f237,
case when to_char(f238,'SS') = 2 then 'Квартал'
     when to_char(f238,'SS') = 3 then 'Год'
     else to_char(f238,'DD.MM.YYYY')
        end f238,
case when to_char(f239,'SS') = 2 then 'Квартал'
     when to_char(f239,'SS') = 3 then 'Год'
     else to_char(f239,'DD.MM.YYYY')
        end f239,
case when to_char(f240,'SS') = 2 then 'Квартал'
     when to_char(f240,'SS') = 3 then 'Год'
     else to_char(f240,'DD.MM.YYYY')
        end f240,
case when to_char(f241,'SS') = 2 then 'Квартал'
     when to_char(f241,'SS') = 3 then 'Год'
     else to_char(f241,'DD.MM.YYYY')
        end f241,
case when to_char(f242,'SS') = 2 then 'Квартал'
     when to_char(f242,'SS') = 3 then 'Год'
     else to_char(f242,'DD.MM.YYYY')
        end f242,
case when to_char(f243,'SS') = 2 then 'Квартал'
     when to_char(f243,'SS') = 3 then 'Год'
     else to_char(f243,'DD.MM.YYYY')
        end f243,
case when to_char(f244,'SS') = 2 then 'Квартал'
     when to_char(f244,'SS') = 3 then 'Год'
     else to_char(f244,'DD.MM.YYYY')
        end f244,
case when to_char(f245,'SS') = 2 then 'Квартал'
     when to_char(f245,'SS') = 3 then 'Год'
     else to_char(f245,'DD.MM.YYYY')
        end f245,
case when to_char(f246,'SS') = 2 then 'Квартал'
     when to_char(f246,'SS') = 3 then 'Год'
     else to_char(f246,'DD.MM.YYYY')
        end f246,
case when to_char(f247,'SS') = 2 then 'Квартал'
     when to_char(f247,'SS') = 3 then 'Год'
     else to_char(f247,'DD.MM.YYYY')
        end f247,
case when to_char(f248,'SS') = 2 then 'Квартал'
     when to_char(f248,'SS') = 3 then 'Год'
     else to_char(f248,'DD.MM.YYYY')
        end f248,
case when to_char(f249,'SS') = 2 then 'Квартал'
     when to_char(f249,'SS') = 3 then 'Год'
     else to_char(f249,'DD.MM.YYYY')
        end f249,
case when to_char(f250,'SS') = 2 then 'Квартал'
     when to_char(f250,'SS') = 3 then 'Год'
     else to_char(f250,'DD.MM.YYYY')
        end f250,
case when to_char(f251,'SS') = 2 then 'Квартал'
     when to_char(f251,'SS') = 3 then 'Год'
     else to_char(f251,'DD.MM.YYYY')
        end f251,
case when to_char(f252,'SS') = 2 then 'Квартал'
     when to_char(f252,'SS') = 3 then 'Год'
     else to_char(f252,'DD.MM.YYYY')
        end f252,
case when to_char(f253,'SS') = 2 then 'Квартал'
     when to_char(f253,'SS') = 3 then 'Год'
     else to_char(f253,'DD.MM.YYYY')
        end f253,
case when to_char(f254,'SS') = 2 then 'Квартал'
     when to_char(f254,'SS') = 3 then 'Год'
     else to_char(f254,'DD.MM.YYYY')
        end f254,
case when to_char(f255,'SS') = 2 then 'Квартал'
     when to_char(f255,'SS') = 3 then 'Год'
     else to_char(f255,'DD.MM.YYYY')
        end f255,
case when to_char(f256,'SS') = 2 then 'Квартал'
     when to_char(f256,'SS') = 3 then 'Год'
     else to_char(f256,'DD.MM.YYYY')
        end f256,
case when to_char(f257,'SS') = 2 then 'Квартал'
     when to_char(f257,'SS') = 3 then 'Год'
     else to_char(f257,'DD.MM.YYYY')
        end f257,
case when to_char(f258,'SS') = 2 then 'Квартал'
     when to_char(f258,'SS') = 3 then 'Год'
     else to_char(f258,'DD.MM.YYYY')
        end f258,
case when to_char(f259,'SS') = 2 then 'Квартал'
     when to_char(f259,'SS') = 3 then 'Год'
     else to_char(f259,'DD.MM.YYYY')
        end f259,
case when to_char(f260,'SS') = 2 then 'Квартал'
     when to_char(f260,'SS') = 3 then 'Год'
     else to_char(f260,'DD.MM.YYYY')
        end f260,
case when to_char(f261,'SS') = 2 then 'Квартал'
     when to_char(f261,'SS') = 3 then 'Год'
     else to_char(f261,'DD.MM.YYYY')
        end f261,
case when to_char(f262,'SS') = 2 then 'Квартал'
     when to_char(f262,'SS') = 3 then 'Год'
     else to_char(f262,'DD.MM.YYYY')
        end f262,
case when to_char(f263,'SS') = 2 then 'Квартал'
     when to_char(f263,'SS') = 3 then 'Год'
     else to_char(f263,'DD.MM.YYYY')
        end f263,
case when to_char(f264,'SS') = 2 then 'Квартал'
     when to_char(f264,'SS') = 3 then 'Год'
     else to_char(f264,'DD.MM.YYYY')
        end f264,
case when to_char(f265,'SS') = 2 then 'Квартал'
     when to_char(f265,'SS') = 3 then 'Год'
     else to_char(f265,'DD.MM.YYYY')
        end f265,
case when to_char(f266,'SS') = 2 then 'Квартал'
     when to_char(f266,'SS') = 3 then 'Год'
     else to_char(f266,'DD.MM.YYYY')
        end f266,
case when to_char(f267,'SS') = 2 then 'Квартал'
     when to_char(f267,'SS') = 3 then 'Год'
     else to_char(f267,'DD.MM.YYYY')
        end f267,
case when to_char(f268,'SS') = 2 then 'Квартал'
     when to_char(f268,'SS') = 3 then 'Год'
     else to_char(f268,'DD.MM.YYYY')
        end f268,
case when to_char(f269,'SS') = 2 then 'Квартал'
     when to_char(f269,'SS') = 3 then 'Год'
     else to_char(f269,'DD.MM.YYYY')
        end f269,
case when to_char(f270,'SS') = 2 then 'Квартал'
     when to_char(f270,'SS') = 3 then 'Год'
     else to_char(f270,'DD.MM.YYYY')
        end f270,
case when to_char(f271,'SS') = 2 then 'Квартал'
     when to_char(f271,'SS') = 3 then 'Год'
     else to_char(f271,'DD.MM.YYYY')
        end f271,
case when to_char(f272,'SS') = 2 then 'Квартал'
     when to_char(f272,'SS') = 3 then 'Год'
     else to_char(f272,'DD.MM.YYYY')
        end f272,
case when to_char(f273,'SS') = 2 then 'Квартал'
     when to_char(f273,'SS') = 3 then 'Год'
     else to_char(f273,'DD.MM.YYYY')
        end f273,
case when to_char(f274,'SS') = 2 then 'Квартал'
     when to_char(f274,'SS') = 3 then 'Год'
     else to_char(f274,'DD.MM.YYYY')
        end f274,
case when to_char(f275,'SS') = 2 then 'Квартал'
     when to_char(f275,'SS') = 3 then 'Год'
     else to_char(f275,'DD.MM.YYYY')
        end f275,
case when to_char(f276,'SS') = 2 then 'Квартал'
     when to_char(f276,'SS') = 3 then 'Год'
     else to_char(f276,'DD.MM.YYYY')
        end f276,
case when to_char(f277,'SS') = 2 then 'Квартал'
     when to_char(f277,'SS') = 3 then 'Год'
     else to_char(f277,'DD.MM.YYYY')
        end f277,
case when to_char(f278,'SS') = 2 then 'Квартал'
     when to_char(f278,'SS') = 3 then 'Год'
     else to_char(f278,'DD.MM.YYYY')
        end f278,
case when to_char(f279,'SS') = 2 then 'Квартал'
     when to_char(f279,'SS') = 3 then 'Год'
     else to_char(f279,'DD.MM.YYYY')
        end f279,
case when to_char(f280,'SS') = 2 then 'Квартал'
     when to_char(f280,'SS') = 3 then 'Год'
     else to_char(f280,'DD.MM.YYYY')
        end f280,
case when to_char(f281,'SS') = 2 then 'Квартал'
     when to_char(f281,'SS') = 3 then 'Год'
     else to_char(f281,'DD.MM.YYYY')
        end f281,
case when to_char(f282,'SS') = 2 then 'Квартал'
     when to_char(f282,'SS') = 3 then 'Год'
     else to_char(f282,'DD.MM.YYYY')
        end f282,
case when to_char(f283,'SS') = 2 then 'Квартал'
     when to_char(f283,'SS') = 3 then 'Год'
     else to_char(f283,'DD.MM.YYYY')
        end f283,
case when to_char(f284,'SS') = 2 then 'Квартал'
     when to_char(f284,'SS') = 3 then 'Год'
     else to_char(f284,'DD.MM.YYYY')
        end f284,
case when to_char(f285,'SS') = 2 then 'Квартал'
     when to_char(f285,'SS') = 3 then 'Год'
     else to_char(f285,'DD.MM.YYYY')
        end f285,
case when to_char(f286,'SS') = 2 then 'Квартал'
     when to_char(f286,'SS') = 3 then 'Год'
     else to_char(f286,'DD.MM.YYYY')
        end f286,
case when to_char(f287,'SS') = 2 then 'Квартал'
     when to_char(f287,'SS') = 3 then 'Год'
     else to_char(f287,'DD.MM.YYYY')
        end f287,
case when to_char(f288,'SS') = 2 then 'Квартал'
     when to_char(f288,'SS') = 3 then 'Год'
     else to_char(f288,'DD.MM.YYYY')
        end f288,
case when to_char(f289,'SS') = 2 then 'Квартал'
     when to_char(f289,'SS') = 3 then 'Год'
     else to_char(f289,'DD.MM.YYYY')
        end f289,
case when to_char(f290,'SS') = 2 then 'Квартал'
     when to_char(f290,'SS') = 3 then 'Год'
     else to_char(f290,'DD.MM.YYYY')
        end f290,
case when to_char(f291,'SS') = 2 then 'Квартал'
     when to_char(f291,'SS') = 3 then 'Год'
     else to_char(f291,'DD.MM.YYYY')
        end f291,
case when to_char(f292,'SS') = 2 then 'Квартал'
     when to_char(f292,'SS') = 3 then 'Год'
     else to_char(f292,'DD.MM.YYYY')
        end f292,
case when to_char(f293,'SS') = 2 then 'Квартал'
     when to_char(f293,'SS') = 3 then 'Год'
     else to_char(f293,'DD.MM.YYYY')
        end f293,
case when to_char(f294,'SS') = 2 then 'Квартал'
     when to_char(f294,'SS') = 3 then 'Год'
     else to_char(f294,'DD.MM.YYYY')
        end f294,
case when to_char(f295,'SS') = 2 then 'Квартал'
     when to_char(f295,'SS') = 3 then 'Год'
     else to_char(f295,'DD.MM.YYYY')
        end f295,
case when to_char(f296,'SS') = 2 then 'Квартал'
     when to_char(f296,'SS') = 3 then 'Год'
     else to_char(f296,'DD.MM.YYYY')
        end f296,
case when to_char(f297,'SS') = 2 then 'Квартал'
     when to_char(f297,'SS') = 3 then 'Год'
     else to_char(f297,'DD.MM.YYYY')
        end f297,
case when to_char(f298,'SS') = 2 then 'Квартал'
     when to_char(f298,'SS') = 3 then 'Год'
     else to_char(f298,'DD.MM.YYYY')
        end f298,
case when to_char(f299,'SS') = 2 then 'Квартал'
     when to_char(f299,'SS') = 3 then 'Год'
     else to_char(f299,'DD.MM.YYYY')
        end f299,
case when to_char(f300,'SS') = 2 then 'Квартал'
     when to_char(f300,'SS') = 3 then 'Год'
     else to_char(f300,'DD.MM.YYYY')
        end f300,
case when to_char(f301,'SS') = 2 then 'Квартал'
     when to_char(f301,'SS') = 3 then 'Год'
     else to_char(f301,'DD.MM.YYYY')
        end f301,
case when to_char(f302,'SS') = 2 then 'Квартал'
     when to_char(f302,'SS') = 3 then 'Год'
     else to_char(f302,'DD.MM.YYYY')
        end f302,
case when to_char(f303,'SS') = 2 then 'Квартал'
     when to_char(f303,'SS') = 3 then 'Год'
     else to_char(f303,'DD.MM.YYYY')
        end f303,
case when to_char(f304,'SS') = 2 then 'Квартал'
     when to_char(f304,'SS') = 3 then 'Год'
     else to_char(f304,'DD.MM.YYYY')
        end f304,
case when to_char(f305,'SS') = 2 then 'Квартал'
     when to_char(f305,'SS') = 3 then 'Год'
     else to_char(f305,'DD.MM.YYYY')
        end f305,
case when to_char(f306,'SS') = 2 then 'Квартал'
     when to_char(f306,'SS') = 3 then 'Год'
     else to_char(f306,'DD.MM.YYYY')
        end f306,
case when to_char(f307,'SS') = 2 then 'Квартал'
     when to_char(f307,'SS') = 3 then 'Год'
     else to_char(f307,'DD.MM.YYYY')
        end f307,
case when to_char(f308,'SS') = 2 then 'Квартал'
     when to_char(f308,'SS') = 3 then 'Год'
     else to_char(f308,'DD.MM.YYYY')
        end f308,
case when to_char(f309,'SS') = 2 then 'Квартал'
     when to_char(f309,'SS') = 3 then 'Год'
     else to_char(f309,'DD.MM.YYYY')
        end f309,
case when to_char(f310,'SS') = 2 then 'Квартал'
     when to_char(f310,'SS') = 3 then 'Год'
     else to_char(f310,'DD.MM.YYYY')
        end f310,
case when to_char(f311,'SS') = 2 then 'Квартал'
     when to_char(f311,'SS') = 3 then 'Год'
     else to_char(f311,'DD.MM.YYYY')
        end f311,
case when to_char(f312,'SS') = 2 then 'Квартал'
     when to_char(f312,'SS') = 3 then 'Год'
     else to_char(f312,'DD.MM.YYYY')
        end f312,
case when to_char(f313,'SS') = 2 then 'Квартал'
     when to_char(f313,'SS') = 3 then 'Год'
     else to_char(f313,'DD.MM.YYYY')
        end f313,
case when to_char(f314,'SS') = 2 then 'Квартал'
     when to_char(f314,'SS') = 3 then 'Год'
     else to_char(f314,'DD.MM.YYYY')
        end f314,
case when to_char(f315,'SS') = 2 then 'Квартал'
     when to_char(f315,'SS') = 3 then 'Год'
     else to_char(f315,'DD.MM.YYYY')
        end f315,
case when to_char(f316,'SS') = 2 then 'Квартал'
     when to_char(f316,'SS') = 3 then 'Год'
     else to_char(f316,'DD.MM.YYYY')
        end f316,
case when to_char(f317,'SS') = 2 then 'Квартал'
     when to_char(f317,'SS') = 3 then 'Год'
     else to_char(f317,'DD.MM.YYYY')
        end f317,
case when to_char(f318,'SS') = 2 then 'Квартал'
     when to_char(f318,'SS') = 3 then 'Год'
     else to_char(f318,'DD.MM.YYYY')
        end f318,
case when to_char(f319,'SS') = 2 then 'Квартал'
     when to_char(f319,'SS') = 3 then 'Год'
     else to_char(f319,'DD.MM.YYYY')
        end f319,
case when to_char(f320,'SS') = 2 then 'Квартал'
     when to_char(f320,'SS') = 3 then 'Год'
     else to_char(f320,'DD.MM.YYYY')
        end f320,
case when to_char(f321,'SS') = 2 then 'Квартал'
     when to_char(f321,'SS') = 3 then 'Год'
     else to_char(f321,'DD.MM.YYYY')
        end f321,
case when to_char(f322,'SS') = 2 then 'Квартал'
     when to_char(f322,'SS') = 3 then 'Год'
     else to_char(f322,'DD.MM.YYYY')
        end f322,
case when to_char(f323,'SS') = 2 then 'Квартал'
     when to_char(f323,'SS') = 3 then 'Год'
     else to_char(f323,'DD.MM.YYYY')
        end f323,
case when to_char(f324,'SS') = 2 then 'Квартал'
     when to_char(f324,'SS') = 3 then 'Год'
     else to_char(f324,'DD.MM.YYYY')
        end f324,
case when to_char(f325,'SS') = 2 then 'Квартал'
     when to_char(f325,'SS') = 3 then 'Год'
     else to_char(f325,'DD.MM.YYYY')
        end f325,
case when to_char(f326,'SS') = 2 then 'Квартал'
     when to_char(f326,'SS') = 3 then 'Год'
     else to_char(f326,'DD.MM.YYYY')
        end f326,
case when to_char(f327,'SS') = 2 then 'Квартал'
     when to_char(f327,'SS') = 3 then 'Год'
     else to_char(f327,'DD.MM.YYYY')
        end f327,
case when to_char(f328,'SS') = 2 then 'Квартал'
     when to_char(f328,'SS') = 3 then 'Год'
     else to_char(f328,'DD.MM.YYYY')
        end f328,
case when to_char(f329,'SS') = 2 then 'Квартал'
     when to_char(f329,'SS') = 3 then 'Год'
     else to_char(f329,'DD.MM.YYYY')
        end f329,
case when to_char(f330,'SS') = 2 then 'Квартал'
     when to_char(f330,'SS') = 3 then 'Год'
     else to_char(f330,'DD.MM.YYYY')
        end f330,
case when to_char(f331,'SS') = 2 then 'Квартал'
     when to_char(f331,'SS') = 3 then 'Год'
     else to_char(f331,'DD.MM.YYYY')
        end f331,
case when to_char(f332,'SS') = 2 then 'Квартал'
     when to_char(f332,'SS') = 3 then 'Год'
     else to_char(f332,'DD.MM.YYYY')
        end f332,
case when to_char(f333,'SS') = 2 then 'Квартал'
     when to_char(f333,'SS') = 3 then 'Год'
     else to_char(f333,'DD.MM.YYYY')
        end f333,
case when to_char(f334,'SS') = 2 then 'Квартал'
     when to_char(f334,'SS') = 3 then 'Год'
     else to_char(f334,'DD.MM.YYYY')
        end f334,
case when to_char(f335,'SS') = 2 then 'Квартал'
     when to_char(f335,'SS') = 3 then 'Год'
     else to_char(f335,'DD.MM.YYYY')
        end f335,
case when to_char(f336,'SS') = 2 then 'Квартал'
     when to_char(f336,'SS') = 3 then 'Год'
     else to_char(f336,'DD.MM.YYYY')
        end f336,
case when to_char(f337,'SS') = 2 then 'Квартал'
     when to_char(f337,'SS') = 3 then 'Год'
     else to_char(f337,'DD.MM.YYYY')
        end f337,
case when to_char(f338,'SS') = 2 then 'Квартал'
     when to_char(f338,'SS') = 3 then 'Год'
     else to_char(f338,'DD.MM.YYYY')
        end f338,
case when to_char(f339,'SS') = 2 then 'Квартал'
     when to_char(f339,'SS') = 3 then 'Год'
     else to_char(f339,'DD.MM.YYYY')
        end f339,
case when to_char(f340,'SS') = 2 then 'Квартал'
     when to_char(f340,'SS') = 3 then 'Год'
     else to_char(f340,'DD.MM.YYYY')
        end f340,
case when to_char(f341,'SS') = 2 then 'Квартал'
     when to_char(f341,'SS') = 3 then 'Год'
     else to_char(f341,'DD.MM.YYYY')
        end f341,
case when to_char(f342,'SS') = 2 then 'Квартал'
     when to_char(f342,'SS') = 3 then 'Год'
     else to_char(f342,'DD.MM.YYYY')
        end f342,
case when to_char(f343,'SS') = 2 then 'Квартал'
     when to_char(f343,'SS') = 3 then 'Год'
     else to_char(f343,'DD.MM.YYYY')
        end f343,
case when to_char(f344,'SS') = 2 then 'Квартал'
     when to_char(f344,'SS') = 3 then 'Год'
     else to_char(f344,'DD.MM.YYYY')
        end f344,
case when to_char(f345,'SS') = 2 then 'Квартал'
     when to_char(f345,'SS') = 3 then 'Год'
     else to_char(f345,'DD.MM.YYYY')
        end f345,
case when to_char(f346,'SS') = 2 then 'Квартал'
     when to_char(f346,'SS') = 3 then 'Год'
     else to_char(f346,'DD.MM.YYYY')
        end f346,
case when to_char(f347,'SS') = 2 then 'Квартал'
     when to_char(f347,'SS') = 3 then 'Год'
     else to_char(f347,'DD.MM.YYYY')
        end f347,
case when to_char(f348,'SS') = 2 then 'Квартал'
     when to_char(f348,'SS') = 3 then 'Год'
     else to_char(f348,'DD.MM.YYYY')
        end f348,
case when to_char(f349,'SS') = 2 then 'Квартал'
     when to_char(f349,'SS') = 3 then 'Год'
     else to_char(f349,'DD.MM.YYYY')
        end f349,
case when to_char(f350,'SS') = 2 then 'Квартал'
     when to_char(f350,'SS') = 3 then 'Год'
     else to_char(f350,'DD.MM.YYYY')
        end f350,
case when to_char(f351,'SS') = 2 then 'Квартал'
     when to_char(f351,'SS') = 3 then 'Год'
     else to_char(f351,'DD.MM.YYYY')
        end f351,
case when to_char(f352,'SS') = 2 then 'Квартал'
     when to_char(f352,'SS') = 3 then 'Год'
     else to_char(f352,'DD.MM.YYYY')
        end f352,
case when to_char(f353,'SS') = 2 then 'Квартал'
     when to_char(f353,'SS') = 3 then 'Год'
     else to_char(f353,'DD.MM.YYYY')
        end f353,
case when to_char(f354,'SS') = 2 then 'Квартал'
     when to_char(f354,'SS') = 3 then 'Год'
     else to_char(f354,'DD.MM.YYYY')
        end f354,
case when to_char(f355,'SS') = 2 then 'Квартал'
     when to_char(f355,'SS') = 3 then 'Год'
     else to_char(f355,'DD.MM.YYYY')
        end f355,
case when to_char(f356,'SS') = 2 then 'Квартал'
     when to_char(f356,'SS') = 3 then 'Год'
     else to_char(f356,'DD.MM.YYYY')
        end f356,
case when to_char(f357,'SS') = 2 then 'Квартал'
     when to_char(f357,'SS') = 3 then 'Год'
     else to_char(f357,'DD.MM.YYYY')
        end f357,
case when to_char(f358,'SS') = 2 then 'Квартал'
     when to_char(f358,'SS') = 3 then 'Год'
     else to_char(f358,'DD.MM.YYYY')
        end f358,
case when to_char(f359,'SS') = 2 then 'Квартал'
     when to_char(f359,'SS') = 3 then 'Год'
     else to_char(f359,'DD.MM.YYYY')
        end f359,
case when to_char(f360,'SS') = 2 then 'Квартал'
     when to_char(f360,'SS') = 3 then 'Год'
     else to_char(f360,'DD.MM.YYYY')
        end f360,
case when to_char(f361,'SS') = 2 then 'Квартал'
     when to_char(f361,'SS') = 3 then 'Год'
     else to_char(f361,'DD.MM.YYYY')
        end f361,
case when to_char(f362,'SS') = 2 then 'Квартал'
     when to_char(f362,'SS') = 3 then 'Год'
     else to_char(f362,'DD.MM.YYYY')
        end f362,
case when to_char(f363,'SS') = 2 then 'Квартал'
     when to_char(f363,'SS') = 3 then 'Год'
     else to_char(f363,'DD.MM.YYYY')
        end f363,
case when to_char(f364,'SS') = 2 then 'Квартал'
     when to_char(f364,'SS') = 3 then 'Год'
     else to_char(f364,'DD.MM.YYYY')
        end f364,
case when to_char(f365,'SS') = 2 then 'Квартал'
     when to_char(f365,'SS') = 3 then 'Год'
     else to_char(f365,'DD.MM.YYYY')
        end f365,
case when to_char(f366,'SS') = 2 then 'Квартал'
     when to_char(f366,'SS') = 3 then 'Год'
     else to_char(f366,'DD.MM.YYYY')
        end f366,
case when to_char(f367,'SS') = 2 then 'Квартал'
     when to_char(f367,'SS') = 3 then 'Год'
     else to_char(f367,'DD.MM.YYYY')
        end f367,
case when to_char(f368,'SS') = 2 then 'Квартал'
     when to_char(f368,'SS') = 3 then 'Год'
     else to_char(f368,'DD.MM.YYYY')
        end f368,
case when to_char(f369,'SS') = 2 then 'Квартал'
     when to_char(f369,'SS') = 3 then 'Год'
     else to_char(f369,'DD.MM.YYYY')
        end f369,
case when to_char(f370,'SS') = 2 then 'Квартал'
     when to_char(f370,'SS') = 3 then 'Год'
     else to_char(f370,'DD.MM.YYYY')
        end f370,
case when to_char(f371,'SS') = 2 then 'Квартал'
     when to_char(f371,'SS') = 3 then 'Год'
     else to_char(f371,'DD.MM.YYYY')
        end f371,
case when to_char(f372,'SS') = 2 then 'Квартал'
     when to_char(f372,'SS') = 3 then 'Год'
     else to_char(f372,'DD.MM.YYYY')
        end f372,
case when to_char(f373,'SS') = 2 then 'Квартал'
     when to_char(f373,'SS') = 3 then 'Год'
     else to_char(f373,'DD.MM.YYYY')
        end f373,
case when to_char(f374,'SS') = 2 then 'Квартал'
     when to_char(f374,'SS') = 3 then 'Год'
     else to_char(f374,'DD.MM.YYYY')
        end f374,
case when to_char(f375,'SS') = 2 then 'Квартал'
     when to_char(f375,'SS') = 3 then 'Год'
     else to_char(f375,'DD.MM.YYYY')
        end f375,
case when to_char(f376,'SS') = 2 then 'Квартал'
     when to_char(f376,'SS') = 3 then 'Год'
     else to_char(f376,'DD.MM.YYYY')
        end f376,
case when to_char(f377,'SS') = 2 then 'Квартал'
     when to_char(f377,'SS') = 3 then 'Год'
     else to_char(f377,'DD.MM.YYYY')
        end f377,
case when to_char(f378,'SS') = 2 then 'Квартал'
     when to_char(f378,'SS') = 3 then 'Год'
     else to_char(f378,'DD.MM.YYYY')
        end f378,
case when to_char(f379,'SS') = 2 then 'Квартал'
     when to_char(f379,'SS') = 3 then 'Год'
     else to_char(f379,'DD.MM.YYYY')
        end f379,
case when to_char(f380,'SS') = 2 then 'Квартал'
     when to_char(f380,'SS') = 3 then 'Год'
     else to_char(f380,'DD.MM.YYYY')
        end f380,
case when to_char(f381,'SS') = 2 then 'Квартал'
     when to_char(f381,'SS') = 3 then 'Год'
     else to_char(f381,'DD.MM.YYYY')
        end f381,
case when to_char(f382,'SS') = 2 then 'Квартал'
     when to_char(f382,'SS') = 3 then 'Год'
     else to_char(f382,'DD.MM.YYYY')
        end f382,
case when to_char(f383,'SS') = 2 then 'Квартал'
     when to_char(f383,'SS') = 3 then 'Год'
     else to_char(f383,'DD.MM.YYYY')
        end f383,
case when to_char(f384,'SS') = 2 then 'Квартал'
     when to_char(f384,'SS') = 3 then 'Год'
     else to_char(f384,'DD.MM.YYYY')
        end f384,
case when to_char(f385,'SS') = 2 then 'Квартал'
     when to_char(f385,'SS') = 3 then 'Год'
     else to_char(f385,'DD.MM.YYYY')
        end f385,
case when to_char(f386,'SS') = 2 then 'Квартал'
     when to_char(f386,'SS') = 3 then 'Год'
     else to_char(f386,'DD.MM.YYYY')
        end f386,
case when to_char(f387,'SS') = 2 then 'Квартал'
     when to_char(f387,'SS') = 3 then 'Год'
     else to_char(f387,'DD.MM.YYYY')
        end f387,
case when to_char(f388,'SS') = 2 then 'Квартал'
     when to_char(f388,'SS') = 3 then 'Год'
     else to_char(f388,'DD.MM.YYYY')
        end f388,
case when to_char(f389,'SS') = 2 then 'Квартал'
     when to_char(f389,'SS') = 3 then 'Год'
     else to_char(f389,'DD.MM.YYYY')
        end f389,
case when to_char(f390,'SS') = 2 then 'Квартал'
     when to_char(f390,'SS') = 3 then 'Год'
     else to_char(f390,'DD.MM.YYYY')
        end f390,
case when to_char(f391,'SS') = 2 then 'Квартал'
     when to_char(f391,'SS') = 3 then 'Год'
     else to_char(f391,'DD.MM.YYYY')
        end f391,
case when to_char(f392,'SS') = 2 then 'Квартал'
     when to_char(f392,'SS') = 3 then 'Год'
     else to_char(f392,'DD.MM.YYYY')
        end f392,
case when to_char(f393,'SS') = 2 then 'Квартал'
     when to_char(f393,'SS') = 3 then 'Год'
     else to_char(f393,'DD.MM.YYYY')
        end f393,
case when to_char(f394,'SS') = 2 then 'Квартал'
     when to_char(f394,'SS') = 3 then 'Год'
     else to_char(f394,'DD.MM.YYYY')
        end f394,
case when to_char(f395,'SS') = 2 then 'Квартал'
     when to_char(f395,'SS') = 3 then 'Год'
     else to_char(f395,'DD.MM.YYYY')
        end f395,
case when to_char(f396,'SS') = 2 then 'Квартал'
     when to_char(f396,'SS') = 3 then 'Год'
     else to_char(f396,'DD.MM.YYYY')
        end f396,
case when to_char(f397,'SS') = 2 then 'Квартал'
     when to_char(f397,'SS') = 3 then 'Год'
     else to_char(f397,'DD.MM.YYYY')
        end f397,
case when to_char(f398,'SS') = 2 then 'Квартал'
     when to_char(f398,'SS') = 3 then 'Год'
     else to_char(f398,'DD.MM.YYYY')
        end f398,
case when to_char(f399,'SS') = 2 then 'Квартал'
     when to_char(f399,'SS') = 3 then 'Год'
     else to_char(f399,'DD.MM.YYYY')
        end f399,
case when to_char(f400,'SS') = 2 then 'Квартал'
     when to_char(f400,'SS') = 3 then 'Год'
     else to_char(f400,'DD.MM.YYYY')
        end f400,
case when to_char(f401,'SS') = 2 then 'Квартал'
     when to_char(f401,'SS') = 3 then 'Год'
     else to_char(f401,'DD.MM.YYYY')
        end f401,
case when to_char(f402,'SS') = 2 then 'Квартал'
     when to_char(f402,'SS') = 3 then 'Год'
     else to_char(f402,'DD.MM.YYYY')
        end f402,
case when to_char(f403,'SS') = 2 then 'Квартал'
     when to_char(f403,'SS') = 3 then 'Год'
     else to_char(f403,'DD.MM.YYYY')
        end f403,
case when to_char(f404,'SS') = 2 then 'Квартал'
     when to_char(f404,'SS') = 3 then 'Год'
     else to_char(f404,'DD.MM.YYYY')
        end f404,
case when to_char(f405,'SS') = 2 then 'Квартал'
     when to_char(f405,'SS') = 3 then 'Год'
     else to_char(f405,'DD.MM.YYYY')
        end f405,
case when to_char(f406,'SS') = 2 then 'Квартал'
     when to_char(f406,'SS') = 3 then 'Год'
     else to_char(f406,'DD.MM.YYYY')
        end f406,
case when to_char(f407,'SS') = 2 then 'Квартал'
     when to_char(f407,'SS') = 3 then 'Год'
     else to_char(f407,'DD.MM.YYYY')
        end f407,
case when to_char(f408,'SS') = 2 then 'Квартал'
     when to_char(f408,'SS') = 3 then 'Год'
     else to_char(f408,'DD.MM.YYYY')
        end f408,
case when to_char(f409,'SS') = 2 then 'Квартал'
     when to_char(f409,'SS') = 3 then 'Год'
     else to_char(f409,'DD.MM.YYYY')
        end f409,
case when to_char(f410,'SS') = 2 then 'Квартал'
     when to_char(f410,'SS') = 3 then 'Год'
     else to_char(f410,'DD.MM.YYYY')
        end f410,
case when to_char(f411,'SS') = 2 then 'Квартал'
     when to_char(f411,'SS') = 3 then 'Год'
     else to_char(f411,'DD.MM.YYYY')
        end f411,
case when to_char(f412,'SS') = 2 then 'Квартал'
     when to_char(f412,'SS') = 3 then 'Год'
     else to_char(f412,'DD.MM.YYYY')
        end f412,
case when to_char(f413,'SS') = 2 then 'Квартал'
     when to_char(f413,'SS') = 3 then 'Год'
     else to_char(f413,'DD.MM.YYYY')
        end f413,
case when to_char(f414,'SS') = 2 then 'Квартал'
     when to_char(f414,'SS') = 3 then 'Год'
     else to_char(f414,'DD.MM.YYYY')
        end f414,
case when to_char(f415,'SS') = 2 then 'Квартал'
     when to_char(f415,'SS') = 3 then 'Год'
     else to_char(f415,'DD.MM.YYYY')
        end f415,
case when to_char(f416,'SS') = 2 then 'Квартал'
     when to_char(f416,'SS') = 3 then 'Год'
     else to_char(f416,'DD.MM.YYYY')
        end f416,
case when to_char(f417,'SS') = 2 then 'Квартал'
     when to_char(f417,'SS') = 3 then 'Год'
     else to_char(f417,'DD.MM.YYYY')
        end f417,
case when to_char(f418,'SS') = 2 then 'Квартал'
     when to_char(f418,'SS') = 3 then 'Год'
     else to_char(f418,'DD.MM.YYYY')
        end f418,
case when to_char(f419,'SS') = 2 then 'Квартал'
     when to_char(f419,'SS') = 3 then 'Год'
     else to_char(f419,'DD.MM.YYYY')
        end f419,
case when to_char(f420,'SS') = 2 then 'Квартал'
     when to_char(f420,'SS') = 3 then 'Год'
     else to_char(f420,'DD.MM.YYYY')
        end f420,
case when to_char(f421,'SS') = 2 then 'Квартал'
     when to_char(f421,'SS') = 3 then 'Год'
     else to_char(f421,'DD.MM.YYYY')
        end f421,
case when to_char(f422,'SS') = 2 then 'Квартал'
     when to_char(f422,'SS') = 3 then 'Год'
     else to_char(f422,'DD.MM.YYYY')
        end f422,
case when to_char(f423,'SS') = 2 then 'Квартал'
     when to_char(f423,'SS') = 3 then 'Год'
     else to_char(f423,'DD.MM.YYYY')
        end f423,
case when to_char(f424,'SS') = 2 then 'Квартал'
     when to_char(f424,'SS') = 3 then 'Год'
     else to_char(f424,'DD.MM.YYYY')
        end f424,
case when to_char(f425,'SS') = 2 then 'Квартал'
     when to_char(f425,'SS') = 3 then 'Год'
     else to_char(f425,'DD.MM.YYYY')
        end f425,
case when to_char(f426,'SS') = 2 then 'Квартал'
     when to_char(f426,'SS') = 3 then 'Год'
     else to_char(f426,'DD.MM.YYYY')
        end f426,
case when to_char(f427,'SS') = 2 then 'Квартал'
     when to_char(f427,'SS') = 3 then 'Год'
     else to_char(f427,'DD.MM.YYYY')
        end f427,
case when to_char(f428,'SS') = 2 then 'Квартал'
     when to_char(f428,'SS') = 3 then 'Год'
     else to_char(f428,'DD.MM.YYYY')
        end f428,
case when to_char(f429,'SS') = 2 then 'Квартал'
     when to_char(f429,'SS') = 3 then 'Год'
     else to_char(f429,'DD.MM.YYYY')
        end f429,
case when to_char(f430,'SS') = 2 then 'Квартал'
     when to_char(f430,'SS') = 3 then 'Год'
     else to_char(f430,'DD.MM.YYYY')
        end f430,
case when to_char(f431,'SS') = 2 then 'Квартал'
     when to_char(f431,'SS') = 3 then 'Год'
     else to_char(f431,'DD.MM.YYYY')
        end f431,
case when to_char(f432,'SS') = 2 then 'Квартал'
     when to_char(f432,'SS') = 3 then 'Год'
     else to_char(f432,'DD.MM.YYYY')
        end f432,
case when to_char(f433,'SS') = 2 then 'Квартал'
     when to_char(f433,'SS') = 3 then 'Год'
     else to_char(f433,'DD.MM.YYYY')
        end f433,
case when to_char(f434,'SS') = 2 then 'Квартал'
     when to_char(f434,'SS') = 3 then 'Год'
     else to_char(f434,'DD.MM.YYYY')
        end f434,
case when to_char(f435,'SS') = 2 then 'Квартал'
     when to_char(f435,'SS') = 3 then 'Год'
     else to_char(f435,'DD.MM.YYYY')
        end f435,
case when to_char(f436,'SS') = 2 then 'Квартал'
     when to_char(f436,'SS') = 3 then 'Год'
     else to_char(f436,'DD.MM.YYYY')
        end f436,
case when to_char(f437,'SS') = 2 then 'Квартал'
     when to_char(f437,'SS') = 3 then 'Год'
     else to_char(f437,'DD.MM.YYYY')
        end f437,
case when to_char(f438,'SS') = 2 then 'Квартал'
     when to_char(f438,'SS') = 3 then 'Год'
     else to_char(f438,'DD.MM.YYYY')
        end f438,
case when to_char(f439,'SS') = 2 then 'Квартал'
     when to_char(f439,'SS') = 3 then 'Год'
     else to_char(f439,'DD.MM.YYYY')
        end f439,
case when to_char(f440,'SS') = 2 then 'Квартал'
     when to_char(f440,'SS') = 3 then 'Год'
     else to_char(f440,'DD.MM.YYYY')
        end f440,
case when to_char(f441,'SS') = 2 then 'Квартал'
     when to_char(f441,'SS') = 3 then 'Год'
     else to_char(f441,'DD.MM.YYYY')
        end f441,
case when to_char(f442,'SS') = 2 then 'Квартал'
     when to_char(f442,'SS') = 3 then 'Год'
     else to_char(f442,'DD.MM.YYYY')
        end f442,
case when to_char(f443,'SS') = 2 then 'Квартал'
     when to_char(f443,'SS') = 3 then 'Год'
     else to_char(f443,'DD.MM.YYYY')
        end f443,
case when to_char(f444,'SS') = 2 then 'Квартал'
     when to_char(f444,'SS') = 3 then 'Год'
     else to_char(f444,'DD.MM.YYYY')
        end f444,
case when to_char(f445,'SS') = 2 then 'Квартал'
     when to_char(f445,'SS') = 3 then 'Год'
     else to_char(f445,'DD.MM.YYYY')
        end f445,
case when to_char(f446,'SS') = 2 then 'Квартал'
     when to_char(f446,'SS') = 3 then 'Год'
     else to_char(f446,'DD.MM.YYYY')
        end f446,
case when to_char(f447,'SS') = 2 then 'Квартал'
     when to_char(f447,'SS') = 3 then 'Год'
     else to_char(f447,'DD.MM.YYYY')
        end f447,
case when to_char(f448,'SS') = 2 then 'Квартал'
     when to_char(f448,'SS') = 3 then 'Год'
     else to_char(f448,'DD.MM.YYYY')
        end f448,
case when to_char(f449,'SS') = 2 then 'Квартал'
     when to_char(f449,'SS') = 3 then 'Год'
     else to_char(f449,'DD.MM.YYYY')
        end f449,
case when to_char(f450,'SS') = 2 then 'Квартал'
     when to_char(f450,'SS') = 3 then 'Год'
     else to_char(f450,'DD.MM.YYYY')
        end f450,
case when to_char(f451,'SS') = 2 then 'Квартал'
     when to_char(f451,'SS') = 3 then 'Год'
     else to_char(f451,'DD.MM.YYYY')
        end f451,
case when to_char(f452,'SS') = 2 then 'Квартал'
     when to_char(f452,'SS') = 3 then 'Год'
     else to_char(f452,'DD.MM.YYYY')
        end f452,
case when to_char(f453,'SS') = 2 then 'Квартал'
     when to_char(f453,'SS') = 3 then 'Год'
     else to_char(f453,'DD.MM.YYYY')
        end f453,
case when to_char(f454,'SS') = 2 then 'Квартал'
     when to_char(f454,'SS') = 3 then 'Год'
     else to_char(f454,'DD.MM.YYYY')
        end f454,
case when to_char(f455,'SS') = 2 then 'Квартал'
     when to_char(f455,'SS') = 3 then 'Год'
     else to_char(f455,'DD.MM.YYYY')
        end f455,
case when to_char(f456,'SS') = 2 then 'Квартал'
     when to_char(f456,'SS') = 3 then 'Год'
     else to_char(f456,'DD.MM.YYYY')
        end f456,
case when to_char(f457,'SS') = 2 then 'Квартал'
     when to_char(f457,'SS') = 3 then 'Год'
     else to_char(f457,'DD.MM.YYYY')
        end f457,
case when to_char(f458,'SS') = 2 then 'Квартал'
     when to_char(f458,'SS') = 3 then 'Год'
     else to_char(f458,'DD.MM.YYYY')
        end f458,
case when to_char(f459,'SS') = 2 then 'Квартал'
     when to_char(f459,'SS') = 3 then 'Год'
     else to_char(f459,'DD.MM.YYYY')
        end f459,
case when to_char(f460,'SS') = 2 then 'Квартал'
     when to_char(f460,'SS') = 3 then 'Год'
     else to_char(f460,'DD.MM.YYYY')
        end f460,
case when to_char(f461,'SS') = 2 then 'Квартал'
     when to_char(f461,'SS') = 3 then 'Год'
     else to_char(f461,'DD.MM.YYYY')
        end f461,
case when to_char(f462,'SS') = 2 then 'Квартал'
     when to_char(f462,'SS') = 3 then 'Год'
     else to_char(f462,'DD.MM.YYYY')
        end f462,
case when to_char(f463,'SS') = 2 then 'Квартал'
     when to_char(f463,'SS') = 3 then 'Год'
     else to_char(f463,'DD.MM.YYYY')
        end f463,
case when to_char(f464,'SS') = 2 then 'Квартал'
     when to_char(f464,'SS') = 3 then 'Год'
     else to_char(f464,'DD.MM.YYYY')
        end f464,
case when to_char(f465,'SS') = 2 then 'Квартал'
     when to_char(f465,'SS') = 3 then 'Год'
     else to_char(f465,'DD.MM.YYYY')
        end f465,
case when to_char(f466,'SS') = 2 then 'Квартал'
     when to_char(f466,'SS') = 3 then 'Год'
     else to_char(f466,'DD.MM.YYYY')
        end f466,
case when to_char(f467,'SS') = 2 then 'Квартал'
     when to_char(f467,'SS') = 3 then 'Год'
     else to_char(f467,'DD.MM.YYYY')
        end f467,
case when to_char(f468,'SS') = 2 then 'Квартал'
     when to_char(f468,'SS') = 3 then 'Год'
     else to_char(f468,'DD.MM.YYYY')
        end f468,
case when to_char(f469,'SS') = 2 then 'Квартал'
     when to_char(f469,'SS') = 3 then 'Год'
     else to_char(f469,'DD.MM.YYYY')
        end f469,
case when to_char(f470,'SS') = 2 then 'Квартал'
     when to_char(f470,'SS') = 3 then 'Год'
     else to_char(f470,'DD.MM.YYYY')
        end f470,
case when to_char(f471,'SS') = 2 then 'Квартал'
     when to_char(f471,'SS') = 3 then 'Год'
     else to_char(f471,'DD.MM.YYYY')
        end f471,
case when to_char(f472,'SS') = 2 then 'Квартал'
     when to_char(f472,'SS') = 3 then 'Год'
     else to_char(f472,'DD.MM.YYYY')
        end f472,
case when to_char(f473,'SS') = 2 then 'Квартал'
     when to_char(f473,'SS') = 3 then 'Год'
     else to_char(f473,'DD.MM.YYYY')
        end f473,
case when to_char(f474,'SS') = 2 then 'Квартал'
     when to_char(f474,'SS') = 3 then 'Год'
     else to_char(f474,'DD.MM.YYYY')
        end f474,
case when to_char(f475,'SS') = 2 then 'Квартал'
     when to_char(f475,'SS') = 3 then 'Год'
     else to_char(f475,'DD.MM.YYYY')
        end f475,
case when to_char(f476,'SS') = 2 then 'Квартал'
     when to_char(f476,'SS') = 3 then 'Год'
     else to_char(f476,'DD.MM.YYYY')
        end f476,
case when to_char(f477,'SS') = 2 then 'Квартал'
     when to_char(f477,'SS') = 3 then 'Год'
     else to_char(f477,'DD.MM.YYYY')
        end f477,
case when to_char(f478,'SS') = 2 then 'Квартал'
     when to_char(f478,'SS') = 3 then 'Год'
     else to_char(f478,'DD.MM.YYYY')
        end f478,
case when to_char(f479,'SS') = 2 then 'Квартал'
     when to_char(f479,'SS') = 3 then 'Год'
     else to_char(f479,'DD.MM.YYYY')
        end f479,
case when to_char(f480,'SS') = 2 then 'Квартал'
     when to_char(f480,'SS') = 3 then 'Год'
     else to_char(f480,'DD.MM.YYYY')
        end f480,
case when to_char(f481,'SS') = 2 then 'Квартал'
     when to_char(f481,'SS') = 3 then 'Год'
     else to_char(f481,'DD.MM.YYYY')
        end f481,
case when to_char(f482,'SS') = 2 then 'Квартал'
     when to_char(f482,'SS') = 3 then 'Год'
     else to_char(f482,'DD.MM.YYYY')
        end f482,
case when to_char(f483,'SS') = 2 then 'Квартал'
     when to_char(f483,'SS') = 3 then 'Год'
     else to_char(f483,'DD.MM.YYYY')
        end f483,
case when to_char(f484,'SS') = 2 then 'Квартал'
     when to_char(f484,'SS') = 3 then 'Год'
     else to_char(f484,'DD.MM.YYYY')
        end f484,
case when to_char(f485,'SS') = 2 then 'Квартал'
     when to_char(f485,'SS') = 3 then 'Год'
     else to_char(f485,'DD.MM.YYYY')
        end f485,
case when to_char(f486,'SS') = 2 then 'Квартал'
     when to_char(f486,'SS') = 3 then 'Год'
     else to_char(f486,'DD.MM.YYYY')
        end f486,
case when to_char(f487,'SS') = 2 then 'Квартал'
     when to_char(f487,'SS') = 3 then 'Год'
     else to_char(f487,'DD.MM.YYYY')
        end f487,
case when to_char(f488,'SS') = 2 then 'Квартал'
     when to_char(f488,'SS') = 3 then 'Год'
     else to_char(f488,'DD.MM.YYYY')
        end f488,
case when to_char(f489,'SS') = 2 then 'Квартал'
     when to_char(f489,'SS') = 3 then 'Год'
     else to_char(f489,'DD.MM.YYYY')
        end f489,
case when to_char(f490,'SS') = 2 then 'Квартал'
     when to_char(f490,'SS') = 3 then 'Год'
     else to_char(f490,'DD.MM.YYYY')
        end f490,
case when to_char(f491,'SS') = 2 then 'Квартал'
     when to_char(f491,'SS') = 3 then 'Год'
     else to_char(f491,'DD.MM.YYYY')
        end f491,
case when to_char(f492,'SS') = 2 then 'Квартал'
     when to_char(f492,'SS') = 3 then 'Год'
     else to_char(f492,'DD.MM.YYYY')
        end f492,
case when to_char(f493,'SS') = 2 then 'Квартал'
     when to_char(f493,'SS') = 3 then 'Год'
     else to_char(f493,'DD.MM.YYYY')
        end f493,
case when to_char(f494,'SS') = 2 then 'Квартал'
     when to_char(f494,'SS') = 3 then 'Год'
     else to_char(f494,'DD.MM.YYYY')
        end f494,
case when to_char(f495,'SS') = 2 then 'Квартал'
     when to_char(f495,'SS') = 3 then 'Год'
     else to_char(f495,'DD.MM.YYYY')
        end f495,
case when to_char(f496,'SS') = 2 then 'Квартал'
     when to_char(f496,'SS') = 3 then 'Год'
     else to_char(f496,'DD.MM.YYYY')
        end f496,
case when to_char(f497,'SS') = 2 then 'Квартал'
     when to_char(f497,'SS') = 3 then 'Год'
     else to_char(f497,'DD.MM.YYYY')
        end f497,
case when to_char(f498,'SS') = 2 then 'Квартал'
     when to_char(f498,'SS') = 3 then 'Год'
     else to_char(f498,'DD.MM.YYYY')
        end f498,
case when to_char(f499,'SS') = 2 then 'Квартал'
     when to_char(f499,'SS') = 3 then 'Год'
     else to_char(f499,'DD.MM.YYYY')
        end f499,
case when to_char(f500,'SS') = 2 then 'Квартал'
     when to_char(f500,'SS') = 3 then 'Год'
     else to_char(f500,'DD.MM.YYYY')
        end f500,
case when to_char(f501,'SS') = 2 then 'Квартал'
     when to_char(f501,'SS') = 3 then 'Год'
     else to_char(f501,'DD.MM.YYYY')
        end f501,
case when to_char(f502,'SS') = 2 then 'Квартал'
     when to_char(f502,'SS') = 3 then 'Год'
     else to_char(f502,'DD.MM.YYYY')
        end f502,
case when to_char(f503,'SS') = 2 then 'Квартал'
     when to_char(f503,'SS') = 3 then 'Год'
     else to_char(f503,'DD.MM.YYYY')
        end f503,
case when to_char(f504,'SS') = 2 then 'Квартал'
     when to_char(f504,'SS') = 3 then 'Год'
     else to_char(f504,'DD.MM.YYYY')
        end f504,
case when to_char(f505,'SS') = 2 then 'Квартал'
     when to_char(f505,'SS') = 3 then 'Год'
     else to_char(f505,'DD.MM.YYYY')
        end f505,
case when to_char(f506,'SS') = 2 then 'Квартал'
     when to_char(f506,'SS') = 3 then 'Год'
     else to_char(f506,'DD.MM.YYYY')
        end f506,
case when to_char(f507,'SS') = 2 then 'Квартал'
     when to_char(f507,'SS') = 3 then 'Год'
     else to_char(f507,'DD.MM.YYYY')
        end f507,
case when to_char(f508,'SS') = 2 then 'Квартал'
     when to_char(f508,'SS') = 3 then 'Год'
     else to_char(f508,'DD.MM.YYYY')
        end f508,
case when to_char(f509,'SS') = 2 then 'Квартал'
     when to_char(f509,'SS') = 3 then 'Год'
     else to_char(f509,'DD.MM.YYYY')
        end f509,
case when to_char(f510,'SS') = 2 then 'Квартал'
     when to_char(f510,'SS') = 3 then 'Год'
     else to_char(f510,'DD.MM.YYYY')
        end f510,
case when to_char(f511,'SS') = 2 then 'Квартал'
     when to_char(f511,'SS') = 3 then 'Год'
     else to_char(f511,'DD.MM.YYYY')
        end f511,
case when to_char(f512,'SS') = 2 then 'Квартал'
     when to_char(f512,'SS') = 3 then 'Год'
     else to_char(f512,'DD.MM.YYYY')
        end f512,
case when to_char(f513,'SS') = 2 then 'Квартал'
     when to_char(f513,'SS') = 3 then 'Год'
     else to_char(f513,'DD.MM.YYYY')
        end f513,
case when to_char(f514,'SS') = 2 then 'Квартал'
     when to_char(f514,'SS') = 3 then 'Год'
     else to_char(f514,'DD.MM.YYYY')
        end f514,
case when to_char(f515,'SS') = 2 then 'Квартал'
     when to_char(f515,'SS') = 3 then 'Год'
     else to_char(f515,'DD.MM.YYYY')
        end f515,
case when to_char(f516,'SS') = 2 then 'Квартал'
     when to_char(f516,'SS') = 3 then 'Год'
     else to_char(f516,'DD.MM.YYYY')
        end f516,
case when to_char(f517,'SS') = 2 then 'Квартал'
     when to_char(f517,'SS') = 3 then 'Год'
     else to_char(f517,'DD.MM.YYYY')
        end f517,
case when to_char(f518,'SS') = 2 then 'Квартал'
     when to_char(f518,'SS') = 3 then 'Год'
     else to_char(f518,'DD.MM.YYYY')
        end f518,
case when to_char(f519,'SS') = 2 then 'Квартал'
     when to_char(f519,'SS') = 3 then 'Год'
     else to_char(f519,'DD.MM.YYYY')
        end f519,
case when to_char(f520,'SS') = 2 then 'Квартал'
     when to_char(f520,'SS') = 3 then 'Год'
     else to_char(f520,'DD.MM.YYYY')
        end f520,
case when to_char(f521,'SS') = 2 then 'Квартал'
     when to_char(f521,'SS') = 3 then 'Год'
     else to_char(f521,'DD.MM.YYYY')
        end f521,
case when to_char(f522,'SS') = 2 then 'Квартал'
     when to_char(f522,'SS') = 3 then 'Год'
     else to_char(f522,'DD.MM.YYYY')
        end f522,
case when to_char(f523,'SS') = 2 then 'Квартал'
     when to_char(f523,'SS') = 3 then 'Год'
     else to_char(f523,'DD.MM.YYYY')
        end f523,
case when to_char(f524,'SS') = 2 then 'Квартал'
     when to_char(f524,'SS') = 3 then 'Год'
     else to_char(f524,'DD.MM.YYYY')
        end f524,
case when to_char(f525,'SS') = 2 then 'Квартал'
     when to_char(f525,'SS') = 3 then 'Год'
     else to_char(f525,'DD.MM.YYYY')
        end f525,
case when to_char(f526,'SS') = 2 then 'Квартал'
     when to_char(f526,'SS') = 3 then 'Год'
     else to_char(f526,'DD.MM.YYYY')
        end f526,
case when to_char(f527,'SS') = 2 then 'Квартал'
     when to_char(f527,'SS') = 3 then 'Год'
     else to_char(f527,'DD.MM.YYYY')
        end f527,
case when to_char(f528,'SS') = 2 then 'Квартал'
     when to_char(f528,'SS') = 3 then 'Год'
     else to_char(f528,'DD.MM.YYYY')
        end f528,
case when to_char(f529,'SS') = 2 then 'Квартал'
     when to_char(f529,'SS') = 3 then 'Год'
     else to_char(f529,'DD.MM.YYYY')
        end f529,
case when to_char(f530,'SS') = 2 then 'Квартал'
     when to_char(f530,'SS') = 3 then 'Год'
     else to_char(f530,'DD.MM.YYYY')
        end f530,
case when to_char(f531,'SS') = 2 then 'Квартал'
     when to_char(f531,'SS') = 3 then 'Год'
     else to_char(f531,'DD.MM.YYYY')
        end f531,
case when to_char(f532,'SS') = 2 then 'Квартал'
     when to_char(f532,'SS') = 3 then 'Год'
     else to_char(f532,'DD.MM.YYYY')
        end f532,
case when to_char(f533,'SS') = 2 then 'Квартал'
     when to_char(f533,'SS') = 3 then 'Год'
     else to_char(f533,'DD.MM.YYYY')
        end f533,
case when to_char(f534,'SS') = 2 then 'Квартал'
     when to_char(f534,'SS') = 3 then 'Год'
     else to_char(f534,'DD.MM.YYYY')
        end f534,
case when to_char(f535,'SS') = 2 then 'Квартал'
     when to_char(f535,'SS') = 3 then 'Год'
     else to_char(f535,'DD.MM.YYYY')
        end f535,
case when to_char(f536,'SS') = 2 then 'Квартал'
     when to_char(f536,'SS') = 3 then 'Год'
     else to_char(f536,'DD.MM.YYYY')
        end f536,
case when to_char(f537,'SS') = 2 then 'Квартал'
     when to_char(f537,'SS') = 3 then 'Год'
     else to_char(f537,'DD.MM.YYYY')
        end f537,
case when to_char(f538,'SS') = 2 then 'Квартал'
     when to_char(f538,'SS') = 3 then 'Год'
     else to_char(f538,'DD.MM.YYYY')
        end f538,
case when to_char(f539,'SS') = 2 then 'Квартал'
     when to_char(f539,'SS') = 3 then 'Год'
     else to_char(f539,'DD.MM.YYYY')
        end f539,
case when to_char(f540,'SS') = 2 then 'Квартал'
     when to_char(f540,'SS') = 3 then 'Год'
     else to_char(f540,'DD.MM.YYYY')
        end f540,
case when to_char(f541,'SS') = 2 then 'Квартал'
     when to_char(f541,'SS') = 3 then 'Год'
     else to_char(f541,'DD.MM.YYYY')
        end f541,
case when to_char(f542,'SS') = 2 then 'Квартал'
     when to_char(f542,'SS') = 3 then 'Год'
     else to_char(f542,'DD.MM.YYYY')
        end f542,
case when to_char(f543,'SS') = 2 then 'Квартал'
     when to_char(f543,'SS') = 3 then 'Год'
     else to_char(f543,'DD.MM.YYYY')
        end f543,
case when to_char(f544,'SS') = 2 then 'Квартал'
     when to_char(f544,'SS') = 3 then 'Год'
     else to_char(f544,'DD.MM.YYYY')
        end f544,
case when to_char(f545,'SS') = 2 then 'Квартал'
     when to_char(f545,'SS') = 3 then 'Год'
     else to_char(f545,'DD.MM.YYYY')
        end f545,
case when to_char(f546,'SS') = 2 then 'Квартал'
     when to_char(f546,'SS') = 3 then 'Год'
     else to_char(f546,'DD.MM.YYYY')
        end f546,
case when to_char(f547,'SS') = 2 then 'Квартал'
     when to_char(f547,'SS') = 3 then 'Год'
     else to_char(f547,'DD.MM.YYYY')
        end f547,
case when to_char(f548,'SS') = 2 then 'Квартал'
     when to_char(f548,'SS') = 3 then 'Год'
     else to_char(f548,'DD.MM.YYYY')
        end f548,
case when to_char(f549,'SS') = 2 then 'Квартал'
     when to_char(f549,'SS') = 3 then 'Год'
     else to_char(f549,'DD.MM.YYYY')
        end f549,
case when to_char(f550,'SS') = 2 then 'Квартал'
     when to_char(f550,'SS') = 3 then 'Год'
     else to_char(f550,'DD.MM.YYYY')
        end f550,
case when to_char(f551,'SS') = 2 then 'Квартал'
     when to_char(f551,'SS') = 3 then 'Год'
     else to_char(f551,'DD.MM.YYYY')
        end f551,
case when to_char(f552,'SS') = 2 then 'Квартал'
     when to_char(f552,'SS') = 3 then 'Год'
     else to_char(f552,'DD.MM.YYYY')
        end f552,
case when to_char(f553,'SS') = 2 then 'Квартал'
     when to_char(f553,'SS') = 3 then 'Год'
     else to_char(f553,'DD.MM.YYYY')
        end f553,
case when to_char(f554,'SS') = 2 then 'Квартал'
     when to_char(f554,'SS') = 3 then 'Год'
     else to_char(f554,'DD.MM.YYYY')
        end f554,
case when to_char(f555,'SS') = 2 then 'Квартал'
     when to_char(f555,'SS') = 3 then 'Год'
     else to_char(f555,'DD.MM.YYYY')
        end f555,
case when to_char(f556,'SS') = 2 then 'Квартал'
     when to_char(f556,'SS') = 3 then 'Год'
     else to_char(f556,'DD.MM.YYYY')
        end f556,
case when to_char(f557,'SS') = 2 then 'Квартал'
     when to_char(f557,'SS') = 3 then 'Год'
     else to_char(f557,'DD.MM.YYYY')
        end f557,
case when to_char(f558,'SS') = 2 then 'Квартал'
     when to_char(f558,'SS') = 3 then 'Год'
     else to_char(f558,'DD.MM.YYYY')
        end f558,
case when to_char(f559,'SS') = 2 then 'Квартал'
     when to_char(f559,'SS') = 3 then 'Год'
     else to_char(f559,'DD.MM.YYYY')
        end f559,
case when to_char(f560,'SS') = 2 then 'Квартал'
     when to_char(f560,'SS') = 3 then 'Год'
     else to_char(f560,'DD.MM.YYYY')
        end f560,
case when to_char(f561,'SS') = 2 then 'Квартал'
     when to_char(f561,'SS') = 3 then 'Год'
     else to_char(f561,'DD.MM.YYYY')
        end f561,
case when to_char(f562,'SS') = 2 then 'Квартал'
     when to_char(f562,'SS') = 3 then 'Год'
     else to_char(f562,'DD.MM.YYYY')
        end f562,
case when to_char(f563,'SS') = 2 then 'Квартал'
     when to_char(f563,'SS') = 3 then 'Год'
     else to_char(f563,'DD.MM.YYYY')
        end f563,
case when to_char(f564,'SS') = 2 then 'Квартал'
     when to_char(f564,'SS') = 3 then 'Год'
     else to_char(f564,'DD.MM.YYYY')
        end f564,
case when to_char(f565,'SS') = 2 then 'Квартал'
     when to_char(f565,'SS') = 3 then 'Год'
     else to_char(f565,'DD.MM.YYYY')
        end f565,
case when to_char(f566,'SS') = 2 then 'Квартал'
     when to_char(f566,'SS') = 3 then 'Год'
     else to_char(f566,'DD.MM.YYYY')
        end f566,
case when to_char(f567,'SS') = 2 then 'Квартал'
     when to_char(f567,'SS') = 3 then 'Год'
     else to_char(f567,'DD.MM.YYYY')
        end f567,
case when to_char(f568,'SS') = 2 then 'Квартал'
     when to_char(f568,'SS') = 3 then 'Год'
     else to_char(f568,'DD.MM.YYYY')
        end f568,
case when to_char(f569,'SS') = 2 then 'Квартал'
     when to_char(f569,'SS') = 3 then 'Год'
     else to_char(f569,'DD.MM.YYYY')
        end f569,
case when to_char(f570,'SS') = 2 then 'Квартал'
     when to_char(f570,'SS') = 3 then 'Год'
     else to_char(f570,'DD.MM.YYYY')
        end f570,
case when to_char(f571,'SS') = 2 then 'Квартал'
     when to_char(f571,'SS') = 3 then 'Год'
     else to_char(f571,'DD.MM.YYYY')
        end f571,
case when to_char(f572,'SS') = 2 then 'Квартал'
     when to_char(f572,'SS') = 3 then 'Год'
     else to_char(f572,'DD.MM.YYYY')
        end f572,
case when to_char(f573,'SS') = 2 then 'Квартал'
     when to_char(f573,'SS') = 3 then 'Год'
     else to_char(f573,'DD.MM.YYYY')
        end f573,
case when to_char(f574,'SS') = 2 then 'Квартал'
     when to_char(f574,'SS') = 3 then 'Год'
     else to_char(f574,'DD.MM.YYYY')
        end f574,
case when to_char(f575,'SS') = 2 then 'Квартал'
     when to_char(f575,'SS') = 3 then 'Год'
     else to_char(f575,'DD.MM.YYYY')
        end f575,
case when to_char(f576,'SS') = 2 then 'Квартал'
     when to_char(f576,'SS') = 3 then 'Год'
     else to_char(f576,'DD.MM.YYYY')
        end f576,
case when to_char(f577,'SS') = 2 then 'Квартал'
     when to_char(f577,'SS') = 3 then 'Год'
     else to_char(f577,'DD.MM.YYYY')
        end f577,
case when to_char(f578,'SS') = 2 then 'Квартал'
     when to_char(f578,'SS') = 3 then 'Год'
     else to_char(f578,'DD.MM.YYYY')
        end f578,
case when to_char(f579,'SS') = 2 then 'Квартал'
     when to_char(f579,'SS') = 3 then 'Год'
     else to_char(f579,'DD.MM.YYYY')
        end f579,
case when to_char(f580,'SS') = 2 then 'Квартал'
     when to_char(f580,'SS') = 3 then 'Год'
     else to_char(f580,'DD.MM.YYYY')
        end f580,
case when to_char(f581,'SS') = 2 then 'Квартал'
     when to_char(f581,'SS') = 3 then 'Год'
     else to_char(f581,'DD.MM.YYYY')
        end f581,
case when to_char(f582,'SS') = 2 then 'Квартал'
     when to_char(f582,'SS') = 3 then 'Год'
     else to_char(f582,'DD.MM.YYYY')
        end f582,
case when to_char(f583,'SS') = 2 then 'Квартал'
     when to_char(f583,'SS') = 3 then 'Год'
     else to_char(f583,'DD.MM.YYYY')
        end f583,
case when to_char(f584,'SS') = 2 then 'Квартал'
     when to_char(f584,'SS') = 3 then 'Год'
     else to_char(f584,'DD.MM.YYYY')
        end f584,
case when to_char(f585,'SS') = 2 then 'Квартал'
     when to_char(f585,'SS') = 3 then 'Год'
     else to_char(f585,'DD.MM.YYYY')
        end f585,
case when to_char(f586,'SS') = 2 then 'Квартал'
     when to_char(f586,'SS') = 3 then 'Год'
     else to_char(f586,'DD.MM.YYYY')
        end f586,
case when to_char(f587,'SS') = 2 then 'Квартал'
     when to_char(f587,'SS') = 3 then 'Год'
     else to_char(f587,'DD.MM.YYYY')
        end f587,
case when to_char(f588,'SS') = 2 then 'Квартал'
     when to_char(f588,'SS') = 3 then 'Год'
     else to_char(f588,'DD.MM.YYYY')
        end f588,
case when to_char(f589,'SS') = 2 then 'Квартал'
     when to_char(f589,'SS') = 3 then 'Год'
     else to_char(f589,'DD.MM.YYYY')
        end f589,
case when to_char(f590,'SS') = 2 then 'Квартал'
     when to_char(f590,'SS') = 3 then 'Год'
     else to_char(f590,'DD.MM.YYYY')
        end f590,
case when to_char(f591,'SS') = 2 then 'Квартал'
     when to_char(f591,'SS') = 3 then 'Год'
     else to_char(f591,'DD.MM.YYYY')
        end f591,
case when to_char(f592,'SS') = 2 then 'Квартал'
     when to_char(f592,'SS') = 3 then 'Год'
     else to_char(f592,'DD.MM.YYYY')
        end f592,
case when to_char(f593,'SS') = 2 then 'Квартал'
     when to_char(f593,'SS') = 3 then 'Год'
     else to_char(f593,'DD.MM.YYYY')
        end f593,
case when to_char(f594,'SS') = 2 then 'Квартал'
     when to_char(f594,'SS') = 3 then 'Год'
     else to_char(f594,'DD.MM.YYYY')
        end f594,
case when to_char(f595,'SS') = 2 then 'Квартал'
     when to_char(f595,'SS') = 3 then 'Год'
     else to_char(f595,'DD.MM.YYYY')
        end f595,
case when to_char(f596,'SS') = 2 then 'Квартал'
     when to_char(f596,'SS') = 3 then 'Год'
     else to_char(f596,'DD.MM.YYYY')
        end f596,
case when to_char(f597,'SS') = 2 then 'Квартал'
     when to_char(f597,'SS') = 3 then 'Год'
     else to_char(f597,'DD.MM.YYYY')
        end f597,
case when to_char(f598,'SS') = 2 then 'Квартал'
     when to_char(f598,'SS') = 3 then 'Год'
     else to_char(f598,'DD.MM.YYYY')
        end f598,
case when to_char(f599,'SS') = 2 then 'Квартал'
     when to_char(f599,'SS') = 3 then 'Год'
     else to_char(f599,'DD.MM.YYYY')
        end f599,
case when to_char(f600,'SS') = 2 then 'Квартал'
     when to_char(f600,'SS') = 3 then 'Год'
     else to_char(f600,'DD.MM.YYYY')
        end f600,
case when to_char(f601,'SS') = 2 then 'Квартал'
     when to_char(f601,'SS') = 3 then 'Год'
     else to_char(f601,'DD.MM.YYYY')
        end f601,
case when to_char(f602,'SS') = 2 then 'Квартал'
     when to_char(f602,'SS') = 3 then 'Год'
     else to_char(f602,'DD.MM.YYYY')
        end f602,
case when to_char(f603,'SS') = 2 then 'Квартал'
     when to_char(f603,'SS') = 3 then 'Год'
     else to_char(f603,'DD.MM.YYYY')
        end f603,
case when to_char(f604,'SS') = 2 then 'Квартал'
     when to_char(f604,'SS') = 3 then 'Год'
     else to_char(f604,'DD.MM.YYYY')
        end f604,
case when to_char(f605,'SS') = 2 then 'Квартал'
     when to_char(f605,'SS') = 3 then 'Год'
     else to_char(f605,'DD.MM.YYYY')
        end f605,
case when to_char(f606,'SS') = 2 then 'Квартал'
     when to_char(f606,'SS') = 3 then 'Год'
     else to_char(f606,'DD.MM.YYYY')
        end f606,
case when to_char(f607,'SS') = 2 then 'Квартал'
     when to_char(f607,'SS') = 3 then 'Год'
     else to_char(f607,'DD.MM.YYYY')
        end f607,
case when to_char(f608,'SS') = 2 then 'Квартал'
     when to_char(f608,'SS') = 3 then 'Год'
     else to_char(f608,'DD.MM.YYYY')
        end f608,
case when to_char(f609,'SS') = 2 then 'Квартал'
     when to_char(f609,'SS') = 3 then 'Год'
     else to_char(f609,'DD.MM.YYYY')
        end f609,
case when to_char(f610,'SS') = 2 then 'Квартал'
     when to_char(f610,'SS') = 3 then 'Год'
     else to_char(f610,'DD.MM.YYYY')
        end f610,
case when to_char(f611,'SS') = 2 then 'Квартал'
     when to_char(f611,'SS') = 3 then 'Год'
     else to_char(f611,'DD.MM.YYYY')
        end f611,
case when to_char(f612,'SS') = 2 then 'Квартал'
     when to_char(f612,'SS') = 3 then 'Год'
     else to_char(f612,'DD.MM.YYYY')
        end f612,
case when to_char(f613,'SS') = 2 then 'Квартал'
     when to_char(f613,'SS') = 3 then 'Год'
     else to_char(f613,'DD.MM.YYYY')
        end f613,
case when to_char(f614,'SS') = 2 then 'Квартал'
     when to_char(f614,'SS') = 3 then 'Год'
     else to_char(f614,'DD.MM.YYYY')
        end f614,
case when to_char(f615,'SS') = 2 then 'Квартал'
     when to_char(f615,'SS') = 3 then 'Год'
     else to_char(f615,'DD.MM.YYYY')
        end f615,
case when to_char(f616,'SS') = 2 then 'Квартал'
     when to_char(f616,'SS') = 3 then 'Год'
     else to_char(f616,'DD.MM.YYYY')
        end f616,
case when to_char(f617,'SS') = 2 then 'Квартал'
     when to_char(f617,'SS') = 3 then 'Год'
     else to_char(f617,'DD.MM.YYYY')
        end f617,
case when to_char(f618,'SS') = 2 then 'Квартал'
     when to_char(f618,'SS') = 3 then 'Год'
     else to_char(f618,'DD.MM.YYYY')
        end f618,
case when to_char(f619,'SS') = 2 then 'Квартал'
     when to_char(f619,'SS') = 3 then 'Год'
     else to_char(f619,'DD.MM.YYYY')
        end f619,
case when to_char(f620,'SS') = 2 then 'Квартал'
     when to_char(f620,'SS') = 3 then 'Год'
     else to_char(f620,'DD.MM.YYYY')
        end f620,
case when to_char(f621,'SS') = 2 then 'Квартал'
     when to_char(f621,'SS') = 3 then 'Год'
     else to_char(f621,'DD.MM.YYYY')
        end f621,
case when to_char(f622,'SS') = 2 then 'Квартал'
     when to_char(f622,'SS') = 3 then 'Год'
     else to_char(f622,'DD.MM.YYYY')
        end f622,
case when to_char(f623,'SS') = 2 then 'Квартал'
     when to_char(f623,'SS') = 3 then 'Год'
     else to_char(f623,'DD.MM.YYYY')
        end f623,
case when to_char(f624,'SS') = 2 then 'Квартал'
     when to_char(f624,'SS') = 3 then 'Год'
     else to_char(f624,'DD.MM.YYYY')
        end f624,
case when to_char(f625,'SS') = 2 then 'Квартал'
     when to_char(f625,'SS') = 3 then 'Год'
     else to_char(f625,'DD.MM.YYYY')
        end f625,
case when to_char(f626,'SS') = 2 then 'Квартал'
     when to_char(f626,'SS') = 3 then 'Год'
     else to_char(f626,'DD.MM.YYYY')
        end f626,
case when to_char(f627,'SS') = 2 then 'Квартал'
     when to_char(f627,'SS') = 3 then 'Год'
     else to_char(f627,'DD.MM.YYYY')
        end f627,
case when to_char(f628,'SS') = 2 then 'Квартал'
     when to_char(f628,'SS') = 3 then 'Год'
     else to_char(f628,'DD.MM.YYYY')
        end f628,
case when to_char(f629,'SS') = 2 then 'Квартал'
     when to_char(f629,'SS') = 3 then 'Год'
     else to_char(f629,'DD.MM.YYYY')
        end f629,
case when to_char(f630,'SS') = 2 then 'Квартал'
     when to_char(f630,'SS') = 3 then 'Год'
     else to_char(f630,'DD.MM.YYYY')
        end f630,
case when to_char(f631,'SS') = 2 then 'Квартал'
     when to_char(f631,'SS') = 3 then 'Год'
     else to_char(f631,'DD.MM.YYYY')
        end f631,
case when to_char(f632,'SS') = 2 then 'Квартал'
     when to_char(f632,'SS') = 3 then 'Год'
     else to_char(f632,'DD.MM.YYYY')
        end f632,
case when to_char(f633,'SS') = 2 then 'Квартал'
     when to_char(f633,'SS') = 3 then 'Год'
     else to_char(f633,'DD.MM.YYYY')
        end f633,
case when to_char(f634,'SS') = 2 then 'Квартал'
     when to_char(f634,'SS') = 3 then 'Год'
     else to_char(f634,'DD.MM.YYYY')
        end f634,
case when to_char(f635,'SS') = 2 then 'Квартал'
     when to_char(f635,'SS') = 3 then 'Год'
     else to_char(f635,'DD.MM.YYYY')
        end f635,
case when to_char(f636,'SS') = 2 then 'Квартал'
     when to_char(f636,'SS') = 3 then 'Год'
     else to_char(f636,'DD.MM.YYYY')
        end f636,
case when to_char(f637,'SS') = 2 then 'Квартал'
     when to_char(f637,'SS') = 3 then 'Год'
     else to_char(f637,'DD.MM.YYYY')
        end f637,
case when to_char(f638,'SS') = 2 then 'Квартал'
     when to_char(f638,'SS') = 3 then 'Год'
     else to_char(f638,'DD.MM.YYYY')
        end f638,
case when to_char(f639,'SS') = 2 then 'Квартал'
     when to_char(f639,'SS') = 3 then 'Год'
     else to_char(f639,'DD.MM.YYYY')
        end f639,
case when to_char(f640,'SS') = 2 then 'Квартал'
     when to_char(f640,'SS') = 3 then 'Год'
     else to_char(f640,'DD.MM.YYYY')
        end f640,
case when to_char(f641,'SS') = 2 then 'Квартал'
     when to_char(f641,'SS') = 3 then 'Год'
     else to_char(f641,'DD.MM.YYYY')
        end f641,
case when to_char(f642,'SS') = 2 then 'Квартал'
     when to_char(f642,'SS') = 3 then 'Год'
     else to_char(f642,'DD.MM.YYYY')
        end f642,
case when to_char(f643,'SS') = 2 then 'Квартал'
     when to_char(f643,'SS') = 3 then 'Год'
     else to_char(f643,'DD.MM.YYYY')
        end f643,
case when to_char(f644,'SS') = 2 then 'Квартал'
     when to_char(f644,'SS') = 3 then 'Год'
     else to_char(f644,'DD.MM.YYYY')
        end f644,
case when to_char(f645,'SS') = 2 then 'Квартал'
     when to_char(f645,'SS') = 3 then 'Год'
     else to_char(f645,'DD.MM.YYYY')
        end f645,
case when to_char(f646,'SS') = 2 then 'Квартал'
     when to_char(f646,'SS') = 3 then 'Год'
     else to_char(f646,'DD.MM.YYYY')
        end f646,
case when to_char(f647,'SS') = 2 then 'Квартал'
     when to_char(f647,'SS') = 3 then 'Год'
     else to_char(f647,'DD.MM.YYYY')
        end f647,
case when to_char(f648,'SS') = 2 then 'Квартал'
     when to_char(f648,'SS') = 3 then 'Год'
     else to_char(f648,'DD.MM.YYYY')
        end f648,
case when to_char(f649,'SS') = 2 then 'Квартал'
     when to_char(f649,'SS') = 3 then 'Год'
     else to_char(f649,'DD.MM.YYYY')
        end f649,
case when to_char(f650,'SS') = 2 then 'Квартал'
     when to_char(f650,'SS') = 3 then 'Год'
     else to_char(f650,'DD.MM.YYYY')
        end f650,
case when to_char(f651,'SS') = 2 then 'Квартал'
     when to_char(f651,'SS') = 3 then 'Год'
     else to_char(f651,'DD.MM.YYYY')
        end f651,
case when to_char(f652,'SS') = 2 then 'Квартал'
     when to_char(f652,'SS') = 3 then 'Год'
     else to_char(f652,'DD.MM.YYYY')
        end f652,
case when to_char(f653,'SS') = 2 then 'Квартал'
     when to_char(f653,'SS') = 3 then 'Год'
     else to_char(f653,'DD.MM.YYYY')
        end f653,
case when to_char(f654,'SS') = 2 then 'Квартал'
     when to_char(f654,'SS') = 3 then 'Год'
     else to_char(f654,'DD.MM.YYYY')
        end f654,
case when to_char(f655,'SS') = 2 then 'Квартал'
     when to_char(f655,'SS') = 3 then 'Год'
     else to_char(f655,'DD.MM.YYYY')
        end f655,
case when to_char(f656,'SS') = 2 then 'Квартал'
     when to_char(f656,'SS') = 3 then 'Год'
     else to_char(f656,'DD.MM.YYYY')
        end f656,
case when to_char(f657,'SS') = 2 then 'Квартал'
     when to_char(f657,'SS') = 3 then 'Год'
     else to_char(f657,'DD.MM.YYYY')
        end f657,
case when to_char(f658,'SS') = 2 then 'Квартал'
     when to_char(f658,'SS') = 3 then 'Год'
     else to_char(f658,'DD.MM.YYYY')
        end f658,
case when to_char(f659,'SS') = 2 then 'Квартал'
     when to_char(f659,'SS') = 3 then 'Год'
     else to_char(f659,'DD.MM.YYYY')
        end f659,
case when to_char(f660,'SS') = 2 then 'Квартал'
     when to_char(f660,'SS') = 3 then 'Год'
     else to_char(f660,'DD.MM.YYYY')
        end f660,
case when to_char(f661,'SS') = 2 then 'Квартал'
     when to_char(f661,'SS') = 3 then 'Год'
     else to_char(f661,'DD.MM.YYYY')
        end f661,
case when to_char(f662,'SS') = 2 then 'Квартал'
     when to_char(f662,'SS') = 3 then 'Год'
     else to_char(f662,'DD.MM.YYYY')
        end f662,
case when to_char(f663,'SS') = 2 then 'Квартал'
     when to_char(f663,'SS') = 3 then 'Год'
     else to_char(f663,'DD.MM.YYYY')
        end f663,
case when to_char(f664,'SS') = 2 then 'Квартал'
     when to_char(f664,'SS') = 3 then 'Год'
     else to_char(f664,'DD.MM.YYYY')
        end f664,
case when to_char(f665,'SS') = 2 then 'Квартал'
     when to_char(f665,'SS') = 3 then 'Год'
     else to_char(f665,'DD.MM.YYYY')
        end f665,
case when to_char(f666,'SS') = 2 then 'Квартал'
     when to_char(f666,'SS') = 3 then 'Год'
     else to_char(f666,'DD.MM.YYYY')
        end f666,
case when to_char(f667,'SS') = 2 then 'Квартал'
     when to_char(f667,'SS') = 3 then 'Год'
     else to_char(f667,'DD.MM.YYYY')
        end f667,
case when to_char(f668,'SS') = 2 then 'Квартал'
     when to_char(f668,'SS') = 3 then 'Год'
     else to_char(f668,'DD.MM.YYYY')
        end f668,
case when to_char(f669,'SS') = 2 then 'Квартал'
     when to_char(f669,'SS') = 3 then 'Год'
     else to_char(f669,'DD.MM.YYYY')
        end f669,
case when to_char(f670,'SS') = 2 then 'Квартал'
     when to_char(f670,'SS') = 3 then 'Год'
     else to_char(f670,'DD.MM.YYYY')
        end f670,
case when to_char(f671,'SS') = 2 then 'Квартал'
     when to_char(f671,'SS') = 3 then 'Год'
     else to_char(f671,'DD.MM.YYYY')
        end f671,
case when to_char(f672,'SS') = 2 then 'Квартал'
     when to_char(f672,'SS') = 3 then 'Год'
     else to_char(f672,'DD.MM.YYYY')
        end f672,
case when to_char(f673,'SS') = 2 then 'Квартал'
     when to_char(f673,'SS') = 3 then 'Год'
     else to_char(f673,'DD.MM.YYYY')
        end f673,
case when to_char(f674,'SS') = 2 then 'Квартал'
     when to_char(f674,'SS') = 3 then 'Год'
     else to_char(f674,'DD.MM.YYYY')
        end f674,
case when to_char(f675,'SS') = 2 then 'Квартал'
     when to_char(f675,'SS') = 3 then 'Год'
     else to_char(f675,'DD.MM.YYYY')
        end f675,
case when to_char(f676,'SS') = 2 then 'Квартал'
     when to_char(f676,'SS') = 3 then 'Год'
     else to_char(f676,'DD.MM.YYYY')
        end f676,
case when to_char(f677,'SS') = 2 then 'Квартал'
     when to_char(f677,'SS') = 3 then 'Год'
     else to_char(f677,'DD.MM.YYYY')
        end f677,
case when to_char(f678,'SS') = 2 then 'Квартал'
     when to_char(f678,'SS') = 3 then 'Год'
     else to_char(f678,'DD.MM.YYYY')
        end f678,
case when to_char(f679,'SS') = 2 then 'Квартал'
     when to_char(f679,'SS') = 3 then 'Год'
     else to_char(f679,'DD.MM.YYYY')
        end f679,
case when to_char(f680,'SS') = 2 then 'Квартал'
     when to_char(f680,'SS') = 3 then 'Год'
     else to_char(f680,'DD.MM.YYYY')
        end f680,
case when to_char(f681,'SS') = 2 then 'Квартал'
     when to_char(f681,'SS') = 3 then 'Год'
     else to_char(f681,'DD.MM.YYYY')
        end f681,
case when to_char(f682,'SS') = 2 then 'Квартал'
     when to_char(f682,'SS') = 3 then 'Год'
     else to_char(f682,'DD.MM.YYYY')
        end f682,
case when to_char(f683,'SS') = 2 then 'Квартал'
     when to_char(f683,'SS') = 3 then 'Год'
     else to_char(f683,'DD.MM.YYYY')
        end f683,
case when to_char(f684,'SS') = 2 then 'Квартал'
     when to_char(f684,'SS') = 3 then 'Год'
     else to_char(f684,'DD.MM.YYYY')
        end f684,
case when to_char(f685,'SS') = 2 then 'Квартал'
     when to_char(f685,'SS') = 3 then 'Год'
     else to_char(f685,'DD.MM.YYYY')
        end f685,
case when to_char(f686,'SS') = 2 then 'Квартал'
     when to_char(f686,'SS') = 3 then 'Год'
     else to_char(f686,'DD.MM.YYYY')
        end f686,
case when to_char(f687,'SS') = 2 then 'Квартал'
     when to_char(f687,'SS') = 3 then 'Год'
     else to_char(f687,'DD.MM.YYYY')
        end f687,
case when to_char(f688,'SS') = 2 then 'Квартал'
     when to_char(f688,'SS') = 3 then 'Год'
     else to_char(f688,'DD.MM.YYYY')
        end f688,
case when to_char(f689,'SS') = 2 then 'Квартал'
     when to_char(f689,'SS') = 3 then 'Год'
     else to_char(f689,'DD.MM.YYYY')
        end f689,
case when to_char(f690,'SS') = 2 then 'Квартал'
     when to_char(f690,'SS') = 3 then 'Год'
     else to_char(f690,'DD.MM.YYYY')
        end f690,
case when to_char(f691,'SS') = 2 then 'Квартал'
     when to_char(f691,'SS') = 3 then 'Год'
     else to_char(f691,'DD.MM.YYYY')
        end f691,
case when to_char(f692,'SS') = 2 then 'Квартал'
     when to_char(f692,'SS') = 3 then 'Год'
     else to_char(f692,'DD.MM.YYYY')
        end f692,
case when to_char(f693,'SS') = 2 then 'Квартал'
     when to_char(f693,'SS') = 3 then 'Год'
     else to_char(f693,'DD.MM.YYYY')
        end f693,
case when to_char(f694,'SS') = 2 then 'Квартал'
     when to_char(f694,'SS') = 3 then 'Год'
     else to_char(f694,'DD.MM.YYYY')
        end f694,
case when to_char(f695,'SS') = 2 then 'Квартал'
     when to_char(f695,'SS') = 3 then 'Год'
     else to_char(f695,'DD.MM.YYYY')
        end f695,
case when to_char(f696,'SS') = 2 then 'Квартал'
     when to_char(f696,'SS') = 3 then 'Год'
     else to_char(f696,'DD.MM.YYYY')
        end f696,
case when to_char(f697,'SS') = 2 then 'Квартал'
     when to_char(f697,'SS') = 3 then 'Год'
     else to_char(f697,'DD.MM.YYYY')
        end f697,
case when to_char(f698,'SS') = 2 then 'Квартал'
     when to_char(f698,'SS') = 3 then 'Год'
     else to_char(f698,'DD.MM.YYYY')
        end f698,
case when to_char(f699,'SS') = 2 then 'Квартал'
     when to_char(f699,'SS') = 3 then 'Год'
     else to_char(f699,'DD.MM.YYYY')
        end f699,
case when to_char(f700,'SS') = 2 then 'Квартал'
     when to_char(f700,'SS') = 3 then 'Год'
     else to_char(f700,'DD.MM.YYYY')
        end f700
from tt2
union all
select 2, contract_id_cd,BRANCH_NAM, SNAPSHOT_DT,
to_char(f1) f1,
to_char(f2) f2,
to_char(f3) f3,
to_char(f4) f4,
to_char(f5) f5,
to_char(f6) f6,
to_char(f7) f7,
to_char(f8) f8,
to_char(f9) f9,
to_char(f10) f10,
to_char(f11) f11,
to_char(f12) f12,
to_char(f13) f13,
to_char(f14) f14,
to_char(f15) f15,
to_char(f16) f16,
to_char(f17) f17,
to_char(f18) f18,
to_char(f19) f19,
to_char(f20) f20,
to_char(f21) f21,
to_char(f22) f22,
to_char(f23) f23,
to_char(f24) f24,
to_char(f25) f25,
to_char(f26) f26,
to_char(f27) f27,
to_char(f28) f28,
to_char(f29) f29,
to_char(f30) f30,
to_char(f31) f31,
to_char(f32) f32,
to_char(f33) f33,
to_char(f34) f34,
to_char(f35) f35,
to_char(f36) f36,
to_char(f37) f37,
to_char(f38) f38,
to_char(f39) f39,
to_char(f40) f40,
to_char(f41) f41,
to_char(f42) f42,
to_char(f43) f43,
to_char(f44) f44,
to_char(f45) f45,
to_char(f46) f46,
to_char(f47) f47,
to_char(f48) f48,
to_char(f49) f49,
to_char(f50) f50,
to_char(f51) f51,
to_char(f52) f52,
to_char(f53) f53,
to_char(f54) f54,
to_char(f55) f55,
to_char(f56) f56,
to_char(f57) f57,
to_char(f58) f58,
to_char(f59) f59,
to_char(f60) f60,
to_char(f61) f61,
to_char(f62) f62,
to_char(f63) f63,
to_char(f64) f64,
to_char(f65) f65,
to_char(f66) f66,
to_char(f67) f67,
to_char(f68) f68,
to_char(f69) f69,
to_char(f70) f70,
to_char(f71) f71,
to_char(f72) f72,
to_char(f73) f73,
to_char(f74) f74,
to_char(f75) f75,
to_char(f76) f76,
to_char(f77) f77,
to_char(f78) f78,
to_char(f79) f79,
to_char(f80) f80,
to_char(f81) f81,
to_char(f82) f82,
to_char(f83) f83,
to_char(f84) f84,
to_char(f85) f85,
to_char(f86) f86,
to_char(f87) f87,
to_char(f88) f88,
to_char(f89) f89,
to_char(f90) f90,
to_char(f91) f91,
to_char(f92) f92,
to_char(f93) f93,
to_char(f94) f94,
to_char(f95) f95,
to_char(f96) f96,
to_char(f97) f97,
to_char(f98) f98,
to_char(f99) f99,
to_char(f100) f100,
to_char(f101) f101,
to_char(f102) f102,
to_char(f103) f103,
to_char(f104) f104,
to_char(f105) f105,
to_char(f106) f106,
to_char(f107) f107,
to_char(f108) f108,
to_char(f109) f109,
to_char(f110) f110,
to_char(f111) f111,
to_char(f112) f112,
to_char(f113) f113,
to_char(f114) f114,
to_char(f115) f115,
to_char(f116) f116,
to_char(f117) f117,
to_char(f118) f118,
to_char(f119) f119,
to_char(f120) f120,
to_char(f121) f121,
to_char(f122) f122,
to_char(f123) f123,
to_char(f124) f124,
to_char(f125) f125,
to_char(f126) f126,
to_char(f127) f127,
to_char(f128) f128,
to_char(f129) f129,
to_char(f130) f130,
to_char(f131) f131,
to_char(f132) f132,
to_char(f133) f133,
to_char(f134) f134,
to_char(f135) f135,
to_char(f136) f136,
to_char(f137) f137,
to_char(f138) f138,
to_char(f139) f139,
to_char(f140) f140,
to_char(f141) f141,
to_char(f142) f142,
to_char(f143) f143,
to_char(f144) f144,
to_char(f145) f145,
to_char(f146) f146,
to_char(f147) f147,
to_char(f148) f148,
to_char(f149) f149,
to_char(f150) f150,
to_char(f151) f151,
to_char(f152) f152,
to_char(f153) f153,
to_char(f154) f154,
to_char(f155) f155,
to_char(f156) f156,
to_char(f157) f157,
to_char(f158) f158,
to_char(f159) f159,
to_char(f160) f160,
to_char(f161) f161,
to_char(f162) f162,
to_char(f163) f163,
to_char(f164) f164,
to_char(f165) f165,
to_char(f166) f166,
to_char(f167) f167,
to_char(f168) f168,
to_char(f169) f169,
to_char(f170) f170,
to_char(f171) f171,
to_char(f172) f172,
to_char(f173) f173,
to_char(f174) f174,
to_char(f175) f175,
to_char(f176) f176,
to_char(f177) f177,
to_char(f178) f178,
to_char(f179) f179,
to_char(f180) f180,
to_char(f181) f181,
to_char(f182) f182,
to_char(f183) f183,
to_char(f184) f184,
to_char(f185) f185,
to_char(f186) f186,
to_char(f187) f187,
to_char(f188) f188,
to_char(f189) f189,
to_char(f190) f190,
to_char(f191) f191,
to_char(f192) f192,
to_char(f193) f193,
to_char(f194) f194,
to_char(f195) f195,
to_char(f196) f196,
to_char(f197) f197,
to_char(f198) f198,
to_char(f199) f199,
to_char(f200) f200,
to_char(f201) f201,
to_char(f202) f202,
to_char(f203) f203,
to_char(f204) f204,
to_char(f205) f205,
to_char(f206) f206,
to_char(f207) f207,
to_char(f208) f208,
to_char(f209) f209,
to_char(f210) f210,
to_char(f211) f211,
to_char(f212) f212,
to_char(f213) f213,
to_char(f214) f214,
to_char(f215) f215,
to_char(f216) f216,
to_char(f217) f217,
to_char(f218) f218,
to_char(f219) f219,
to_char(f220) f220,
to_char(f221) f221,
to_char(f222) f222,
to_char(f223) f223,
to_char(f224) f224,
to_char(f225) f225,
to_char(f226) f226,
to_char(f227) f227,
to_char(f228) f228,
to_char(f229) f229,
to_char(f230) f230,
to_char(f231) f231,
to_char(f232) f232,
to_char(f233) f233,
to_char(f234) f234,
to_char(f235) f235,
to_char(f236) f236,
to_char(f237) f237,
to_char(f238) f238,
to_char(f239) f239,
to_char(f240) f240,
to_char(f241) f241,
to_char(f242) f242,
to_char(f243) f243,
to_char(f244) f244,
to_char(f245) f245,
to_char(f246) f246,
to_char(f247) f247,
to_char(f248) f248,
to_char(f249) f249,
to_char(f250) f250,
to_char(f251) f251,
to_char(f252) f252,
to_char(f253) f253,
to_char(f254) f254,
to_char(f255) f255,
to_char(f256) f256,
to_char(f257) f257,
to_char(f258) f258,
to_char(f259) f259,
to_char(f260) f260,
to_char(f261) f261,
to_char(f262) f262,
to_char(f263) f263,
to_char(f264) f264,
to_char(f265) f265,
to_char(f266) f266,
to_char(f267) f267,
to_char(f268) f268,
to_char(f269) f269,
to_char(f270) f270,
to_char(f271) f271,
to_char(f272) f272,
to_char(f273) f273,
to_char(f274) f274,
to_char(f275) f275,
to_char(f276) f276,
to_char(f277) f277,
to_char(f278) f278,
to_char(f279) f279,
to_char(f280) f280,
to_char(f281) f281,
to_char(f282) f282,
to_char(f283) f283,
to_char(f284) f284,
to_char(f285) f285,
to_char(f286) f286,
to_char(f287) f287,
to_char(f288) f288,
to_char(f289) f289,
to_char(f290) f290,
to_char(f291) f291,
to_char(f292) f292,
to_char(f293) f293,
to_char(f294) f294,
to_char(f295) f295,
to_char(f296) f296,
to_char(f297) f297,
to_char(f298) f298,
to_char(f299) f299,
to_char(f300) f300,
to_char(f301) f301,
to_char(f302) f302,
to_char(f303) f303,
to_char(f304) f304,
to_char(f305) f305,
to_char(f306) f306,
to_char(f307) f307,
to_char(f308) f308,
to_char(f309) f309,
to_char(f310) f310,
to_char(f311) f311,
to_char(f312) f312,
to_char(f313) f313,
to_char(f314) f314,
to_char(f315) f315,
to_char(f316) f316,
to_char(f317) f317,
to_char(f318) f318,
to_char(f319) f319,
to_char(f320) f320,
to_char(f321) f321,
to_char(f322) f322,
to_char(f323) f323,
to_char(f324) f324,
to_char(f325) f325,
to_char(f326) f326,
to_char(f327) f327,
to_char(f328) f328,
to_char(f329) f329,
to_char(f330) f330,
to_char(f331) f331,
to_char(f332) f332,
to_char(f333) f333,
to_char(f334) f334,
to_char(f335) f335,
to_char(f336) f336,
to_char(f337) f337,
to_char(f338) f338,
to_char(f339) f339,
to_char(f340) f340,
to_char(f341) f341,
to_char(f342) f342,
to_char(f343) f343,
to_char(f344) f344,
to_char(f345) f345,
to_char(f346) f346,
to_char(f347) f347,
to_char(f348) f348,
to_char(f349) f349,
to_char(f350) f350,
to_char(f351) f351,
to_char(f352) f352,
to_char(f353) f353,
to_char(f354) f354,
to_char(f355) f355,
to_char(f356) f356,
to_char(f357) f357,
to_char(f358) f358,
to_char(f359) f359,
to_char(f360) f360,
to_char(f361) f361,
to_char(f362) f362,
to_char(f363) f363,
to_char(f364) f364,
to_char(f365) f365,
to_char(f366) f366,
to_char(f367) f367,
to_char(f368) f368,
to_char(f369) f369,
to_char(f370) f370,
to_char(f371) f371,
to_char(f372) f372,
to_char(f373) f373,
to_char(f374) f374,
to_char(f375) f375,
to_char(f376) f376,
to_char(f377) f377,
to_char(f378) f378,
to_char(f379) f379,
to_char(f380) f380,
to_char(f381) f381,
to_char(f382) f382,
to_char(f383) f383,
to_char(f384) f384,
to_char(f385) f385,
to_char(f386) f386,
to_char(f387) f387,
to_char(f388) f388,
to_char(f389) f389,
to_char(f390) f390,
to_char(f391) f391,
to_char(f392) f392,
to_char(f393) f393,
to_char(f394) f394,
to_char(f395) f395,
to_char(f396) f396,
to_char(f397) f397,
to_char(f398) f398,
to_char(f399) f399,
to_char(f400) f400,
to_char(f401) f401,
to_char(f402) f402,
to_char(f403) f403,
to_char(f404) f404,
to_char(f405) f405,
to_char(f406) f406,
to_char(f407) f407,
to_char(f408) f408,
to_char(f409) f409,
to_char(f410) f410,
to_char(f411) f411,
to_char(f412) f412,
to_char(f413) f413,
to_char(f414) f414,
to_char(f415) f415,
to_char(f416) f416,
to_char(f417) f417,
to_char(f418) f418,
to_char(f419) f419,
to_char(f420) f420,
to_char(f421) f421,
to_char(f422) f422,
to_char(f423) f423,
to_char(f424) f424,
to_char(f425) f425,
to_char(f426) f426,
to_char(f427) f427,
to_char(f428) f428,
to_char(f429) f429,
to_char(f430) f430,
to_char(f431) f431,
to_char(f432) f432,
to_char(f433) f433,
to_char(f434) f434,
to_char(f435) f435,
to_char(f436) f436,
to_char(f437) f437,
to_char(f438) f438,
to_char(f439) f439,
to_char(f440) f440,
to_char(f441) f441,
to_char(f442) f442,
to_char(f443) f443,
to_char(f444) f444,
to_char(f445) f445,
to_char(f446) f446,
to_char(f447) f447,
to_char(f448) f448,
to_char(f449) f449,
to_char(f450) f450,
to_char(f451) f451,
to_char(f452) f452,
to_char(f453) f453,
to_char(f454) f454,
to_char(f455) f455,
to_char(f456) f456,
to_char(f457) f457,
to_char(f458) f458,
to_char(f459) f459,
to_char(f460) f460,
to_char(f461) f461,
to_char(f462) f462,
to_char(f463) f463,
to_char(f464) f464,
to_char(f465) f465,
to_char(f466) f466,
to_char(f467) f467,
to_char(f468) f468,
to_char(f469) f469,
to_char(f470) f470,
to_char(f471) f471,
to_char(f472) f472,
to_char(f473) f473,
to_char(f474) f474,
to_char(f475) f475,
to_char(f476) f476,
to_char(f477) f477,
to_char(f478) f478,
to_char(f479) f479,
to_char(f480) f480,
to_char(f481) f481,
to_char(f482) f482,
to_char(f483) f483,
to_char(f484) f484,
to_char(f485) f485,
to_char(f486) f486,
to_char(f487) f487,
to_char(f488) f488,
to_char(f489) f489,
to_char(f490) f490,
to_char(f491) f491,
to_char(f492) f492,
to_char(f493) f493,
to_char(f494) f494,
to_char(f495) f495,
to_char(f496) f496,
to_char(f497) f497,
to_char(f498) f498,
to_char(f499) f499,
to_char(f500) f500,
to_char(f501) f501,
to_char(f502) f502,
to_char(f503) f503,
to_char(f504) f504,
to_char(f505) f505,
to_char(f506) f506,
to_char(f507) f507,
to_char(f508) f508,
to_char(f509) f509,
to_char(f510) f510,
to_char(f511) f511,
to_char(f512) f512,
to_char(f513) f513,
to_char(f514) f514,
to_char(f515) f515,
to_char(f516) f516,
to_char(f517) f517,
to_char(f518) f518,
to_char(f519) f519,
to_char(f520) f520,
to_char(f521) f521,
to_char(f522) f522,
to_char(f523) f523,
to_char(f524) f524,
to_char(f525) f525,
to_char(f526) f526,
to_char(f527) f527,
to_char(f528) f528,
to_char(f529) f529,
to_char(f530) f530,
to_char(f531) f531,
to_char(f532) f532,
to_char(f533) f533,
to_char(f534) f534,
to_char(f535) f535,
to_char(f536) f536,
to_char(f537) f537,
to_char(f538) f538,
to_char(f539) f539,
to_char(f540) f540,
to_char(f541) f541,
to_char(f542) f542,
to_char(f543) f543,
to_char(f544) f544,
to_char(f545) f545,
to_char(f546) f546,
to_char(f547) f547,
to_char(f548) f548,
to_char(f549) f549,
to_char(f550) f550,
to_char(f551) f551,
to_char(f552) f552,
to_char(f553) f553,
to_char(f554) f554,
to_char(f555) f555,
to_char(f556) f556,
to_char(f557) f557,
to_char(f558) f558,
to_char(f559) f559,
to_char(f560) f560,
to_char(f561) f561,
to_char(f562) f562,
to_char(f563) f563,
to_char(f564) f564,
to_char(f565) f565,
to_char(f566) f566,
to_char(f567) f567,
to_char(f568) f568,
to_char(f569) f569,
to_char(f570) f570,
to_char(f571) f571,
to_char(f572) f572,
to_char(f573) f573,
to_char(f574) f574,
to_char(f575) f575,
to_char(f576) f576,
to_char(f577) f577,
to_char(f578) f578,
to_char(f579) f579,
to_char(f580) f580,
to_char(f581) f581,
to_char(f582) f582,
to_char(f583) f583,
to_char(f584) f584,
to_char(f585) f585,
to_char(f586) f586,
to_char(f587) f587,
to_char(f588) f588,
to_char(f589) f589,
to_char(f590) f590,
to_char(f591) f591,
to_char(f592) f592,
to_char(f593) f593,
to_char(f594) f594,
to_char(f595) f595,
to_char(f596) f596,
to_char(f597) f597,
to_char(f598) f598,
to_char(f599) f599,
to_char(f600) f600,
to_char(f601) f601,
to_char(f602) f602,
to_char(f603) f603,
to_char(f604) f604,
to_char(f605) f605,
to_char(f606) f606,
to_char(f607) f607,
to_char(f608) f608,
to_char(f609) f609,
to_char(f610) f610,
to_char(f611) f611,
to_char(f612) f612,
to_char(f613) f613,
to_char(f614) f614,
to_char(f615) f615,
to_char(f616) f616,
to_char(f617) f617,
to_char(f618) f618,
to_char(f619) f619,
to_char(f620) f620,
to_char(f621) f621,
to_char(f622) f622,
to_char(f623) f623,
to_char(f624) f624,
to_char(f625) f625,
to_char(f626) f626,
to_char(f627) f627,
to_char(f628) f628,
to_char(f629) f629,
to_char(f630) f630,
to_char(f631) f631,
to_char(f632) f632,
to_char(f633) f633,
to_char(f634) f634,
to_char(f635) f635,
to_char(f636) f636,
to_char(f637) f637,
to_char(f638) f638,
to_char(f639) f639,
to_char(f640) f640,
to_char(f641) f641,
to_char(f642) f642,
to_char(f643) f643,
to_char(f644) f644,
to_char(f645) f645,
to_char(f646) f646,
to_char(f647) f647,
to_char(f648) f648,
to_char(f649) f649,
to_char(f650) f650,
to_char(f651) f651,
to_char(f652) f652,
to_char(f653) f653,
to_char(f654) f654,
to_char(f655) f655,
to_char(f656) f656,
to_char(f657) f657,
to_char(f658) f658,
to_char(f659) f659,
to_char(f660) f660,
to_char(f661) f661,
to_char(f662) f662,
to_char(f663) f663,
to_char(f664) f664,
to_char(f665) f665,
to_char(f666) f666,
to_char(f667) f667,
to_char(f668) f668,
to_char(f669) f669,
to_char(f670) f670,
to_char(f671) f671,
to_char(f672) f672,
to_char(f673) f673,
to_char(f674) f674,
to_char(f675) f675,
to_char(f676) f676,
to_char(f677) f677,
to_char(f678) f678,
to_char(f679) f679,
to_char(f680) f680,
to_char(f681) f681,
to_char(f682) f682,
to_char(f683) f683,
to_char(f684) f684,
to_char(f685) f685,
to_char(f686) f686,
to_char(f687) f687,
to_char(f688) f688,
to_char(f689) f689,
to_char(f690) f690,
to_char(f691) f691,
to_char(f692) f692,
to_char(f693) f693,
to_char(f694) f694,
to_char(f695) f695,
to_char(f696) f696,
to_char(f697) f697,
to_char(f698) f698,
to_char(f699) f699,
to_char(f700) f700
 from tt3 b
union all
select 3, '',BRANCH_NAM, SNAPSHOT_DT,
to_char(sum(f1)) f1,
to_char(sum(f2)) f2,
to_char(sum(f3)) f3,
to_char(sum(f4)) f4,
to_char(sum(f5)) f5,
to_char(sum(f6)) f6,
to_char(sum(f7)) f7,
to_char(sum(f8)) f8,
to_char(sum(f9)) f9,
to_char(sum(f10)) f10,
to_char(sum(f11)) f11,
to_char(sum(f12)) f12,
to_char(sum(f13)) f13,
to_char(sum(f14)) f14,
to_char(sum(f15)) f15,
to_char(sum(f16)) f16,
to_char(sum(f17)) f17,
to_char(sum(f18)) f18,
to_char(sum(f19)) f19,
to_char(sum(f20)) f20,
to_char(sum(f21)) f21,
to_char(sum(f22)) f22,
to_char(sum(f23)) f23,
to_char(sum(f24)) f24,
to_char(sum(f25)) f25,
to_char(sum(f26)) f26,
to_char(sum(f27)) f27,
to_char(sum(f28)) f28,
to_char(sum(f29)) f29,
to_char(sum(f30)) f30,
to_char(sum(f31)) f31,
to_char(sum(f32)) f32,
to_char(sum(f33)) f33,
to_char(sum(f34)) f34,
to_char(sum(f35)) f35,
to_char(sum(f36)) f36,
to_char(sum(f37)) f37,
to_char(sum(f38)) f38,
to_char(sum(f39)) f39,
to_char(sum(f40)) f40,
to_char(sum(f41)) f41,
to_char(sum(f42)) f42,
to_char(sum(f43)) f43,
to_char(sum(f44)) f44,
to_char(sum(f45)) f45,
to_char(sum(f46)) f46,
to_char(sum(f47)) f47,
to_char(sum(f48)) f48,
to_char(sum(f49)) f49,
to_char(sum(f50)) f50,
to_char(sum(f51)) f51,
to_char(sum(f52)) f52,
to_char(sum(f53)) f53,
to_char(sum(f54)) f54,
to_char(sum(f55)) f55,
to_char(sum(f56)) f56,
to_char(sum(f57)) f57,
to_char(sum(f58)) f58,
to_char(sum(f59)) f59,
to_char(sum(f60)) f60,
to_char(sum(f61)) f61,
to_char(sum(f62)) f62,
to_char(sum(f63)) f63,
to_char(sum(f64)) f64,
to_char(sum(f65)) f65,
to_char(sum(f66)) f66,
to_char(sum(f67)) f67,
to_char(sum(f68)) f68,
to_char(sum(f69)) f69,
to_char(sum(f70)) f70,
to_char(sum(f71)) f71,
to_char(sum(f72)) f72,
to_char(sum(f73)) f73,
to_char(sum(f74)) f74,
to_char(sum(f75)) f75,
to_char(sum(f76)) f76,
to_char(sum(f77)) f77,
to_char(sum(f78)) f78,
to_char(sum(f79)) f79,
to_char(sum(f80)) f80,
to_char(sum(f81)) f81,
to_char(sum(f82)) f82,
to_char(sum(f83)) f83,
to_char(sum(f84)) f84,
to_char(sum(f85)) f85,
to_char(sum(f86)) f86,
to_char(sum(f87)) f87,
to_char(sum(f88)) f88,
to_char(sum(f89)) f89,
to_char(sum(f90)) f90,
to_char(sum(f91)) f91,
to_char(sum(f92)) f92,
to_char(sum(f93)) f93,
to_char(sum(f94)) f94,
to_char(sum(f95)) f95,
to_char(sum(f96)) f96,
to_char(sum(f97)) f97,
to_char(sum(f98)) f98,
to_char(sum(f99)) f99,
to_char(sum(f100)) f100,
to_char(sum(f101)) f101,
to_char(sum(f102)) f102,
to_char(sum(f103)) f103,
to_char(sum(f104)) f104,
to_char(sum(f105)) f105,
to_char(sum(f106)) f106,
to_char(sum(f107)) f107,
to_char(sum(f108)) f108,
to_char(sum(f109)) f109,
to_char(sum(f110)) f110,
to_char(sum(f111)) f111,
to_char(sum(f112)) f112,
to_char(sum(f113)) f113,
to_char(sum(f114)) f114,
to_char(sum(f115)) f115,
to_char(sum(f116)) f116,
to_char(sum(f117)) f117,
to_char(sum(f118)) f118,
to_char(sum(f119)) f119,
to_char(sum(f120)) f120,
to_char(sum(f121)) f121,
to_char(sum(f122)) f122,
to_char(sum(f123)) f123,
to_char(sum(f124)) f124,
to_char(sum(f125)) f125,
to_char(sum(f126)) f126,
to_char(sum(f127)) f127,
to_char(sum(f128)) f128,
to_char(sum(f129)) f129,
to_char(sum(f130)) f130,
to_char(sum(f131)) f131,
to_char(sum(f132)) f132,
to_char(sum(f133)) f133,
to_char(sum(f134)) f134,
to_char(sum(f135)) f135,
to_char(sum(f136)) f136,
to_char(sum(f137)) f137,
to_char(sum(f138)) f138,
to_char(sum(f139)) f139,
to_char(sum(f140)) f140,
to_char(sum(f141)) f141,
to_char(sum(f142)) f142,
to_char(sum(f143)) f143,
to_char(sum(f144)) f144,
to_char(sum(f145)) f145,
to_char(sum(f146)) f146,
to_char(sum(f147)) f147,
to_char(sum(f148)) f148,
to_char(sum(f149)) f149,
to_char(sum(f150)) f150,
to_char(sum(f151)) f151,
to_char(sum(f152)) f152,
to_char(sum(f153)) f153,
to_char(sum(f154)) f154,
to_char(sum(f155)) f155,
to_char(sum(f156)) f156,
to_char(sum(f157)) f157,
to_char(sum(f158)) f158,
to_char(sum(f159)) f159,
to_char(sum(f160)) f160,
to_char(sum(f161)) f161,
to_char(sum(f162)) f162,
to_char(sum(f163)) f163,
to_char(sum(f164)) f164,
to_char(sum(f165)) f165,
to_char(sum(f166)) f166,
to_char(sum(f167)) f167,
to_char(sum(f168)) f168,
to_char(sum(f169)) f169,
to_char(sum(f170)) f170,
to_char(sum(f171)) f171,
to_char(sum(f172)) f172,
to_char(sum(f173)) f173,
to_char(sum(f174)) f174,
to_char(sum(f175)) f175,
to_char(sum(f176)) f176,
to_char(sum(f177)) f177,
to_char(sum(f178)) f178,
to_char(sum(f179)) f179,
to_char(sum(f180)) f180,
to_char(sum(f181)) f181,
to_char(sum(f182)) f182,
to_char(sum(f183)) f183,
to_char(sum(f184)) f184,
to_char(sum(f185)) f185,
to_char(sum(f186)) f186,
to_char(sum(f187)) f187,
to_char(sum(f188)) f188,
to_char(sum(f189)) f189,
to_char(sum(f190)) f190,
to_char(sum(f191)) f191,
to_char(sum(f192)) f192,
to_char(sum(f193)) f193,
to_char(sum(f194)) f194,
to_char(sum(f195)) f195,
to_char(sum(f196)) f196,
to_char(sum(f197)) f197,
to_char(sum(f198)) f198,
to_char(sum(f199)) f199,
to_char(sum(f200)) f200,
to_char(sum(f201)) f201,
to_char(sum(f202)) f202,
to_char(sum(f203)) f203,
to_char(sum(f204)) f204,
to_char(sum(f205)) f205,
to_char(sum(f206)) f206,
to_char(sum(f207)) f207,
to_char(sum(f208)) f208,
to_char(sum(f209)) f209,
to_char(sum(f210)) f210,
to_char(sum(f211)) f211,
to_char(sum(f212)) f212,
to_char(sum(f213)) f213,
to_char(sum(f214)) f214,
to_char(sum(f215)) f215,
to_char(sum(f216)) f216,
to_char(sum(f217)) f217,
to_char(sum(f218)) f218,
to_char(sum(f219)) f219,
to_char(sum(f220)) f220,
to_char(sum(f221)) f221,
to_char(sum(f222)) f222,
to_char(sum(f223)) f223,
to_char(sum(f224)) f224,
to_char(sum(f225)) f225,
to_char(sum(f226)) f226,
to_char(sum(f227)) f227,
to_char(sum(f228)) f228,
to_char(sum(f229)) f229,
to_char(sum(f230)) f230,
to_char(sum(f231)) f231,
to_char(sum(f232)) f232,
to_char(sum(f233)) f233,
to_char(sum(f234)) f234,
to_char(sum(f235)) f235,
to_char(sum(f236)) f236,
to_char(sum(f237)) f237,
to_char(sum(f238)) f238,
to_char(sum(f239)) f239,
to_char(sum(f240)) f240,
to_char(sum(f241)) f241,
to_char(sum(f242)) f242,
to_char(sum(f243)) f243,
to_char(sum(f244)) f244,
to_char(sum(f245)) f245,
to_char(sum(f246)) f246,
to_char(sum(f247)) f247,
to_char(sum(f248)) f248,
to_char(sum(f249)) f249,
to_char(sum(f250)) f250,
to_char(sum(f251)) f251,
to_char(sum(f252)) f252,
to_char(sum(f253)) f253,
to_char(sum(f254)) f254,
to_char(sum(f255)) f255,
to_char(sum(f256)) f256,
to_char(sum(f257)) f257,
to_char(sum(f258)) f258,
to_char(sum(f259)) f259,
to_char(sum(f260)) f260,
to_char(sum(f261)) f261,
to_char(sum(f262)) f262,
to_char(sum(f263)) f263,
to_char(sum(f264)) f264,
to_char(sum(f265)) f265,
to_char(sum(f266)) f266,
to_char(sum(f267)) f267,
to_char(sum(f268)) f268,
to_char(sum(f269)) f269,
to_char(sum(f270)) f270,
to_char(sum(f271)) f271,
to_char(sum(f272)) f272,
to_char(sum(f273)) f273,
to_char(sum(f274)) f274,
to_char(sum(f275)) f275,
to_char(sum(f276)) f276,
to_char(sum(f277)) f277,
to_char(sum(f278)) f278,
to_char(sum(f279)) f279,
to_char(sum(f280)) f280,
to_char(sum(f281)) f281,
to_char(sum(f282)) f282,
to_char(sum(f283)) f283,
to_char(sum(f284)) f284,
to_char(sum(f285)) f285,
to_char(sum(f286)) f286,
to_char(sum(f287)) f287,
to_char(sum(f288)) f288,
to_char(sum(f289)) f289,
to_char(sum(f290)) f290,
to_char(sum(f291)) f291,
to_char(sum(f292)) f292,
to_char(sum(f293)) f293,
to_char(sum(f294)) f294,
to_char(sum(f295)) f295,
to_char(sum(f296)) f296,
to_char(sum(f297)) f297,
to_char(sum(f298)) f298,
to_char(sum(f299)) f299,
to_char(sum(f300)) f300,
to_char(sum(f301)) f301,
to_char(sum(f302)) f302,
to_char(sum(f303)) f303,
to_char(sum(f304)) f304,
to_char(sum(f305)) f305,
to_char(sum(f306)) f306,
to_char(sum(f307)) f307,
to_char(sum(f308)) f308,
to_char(sum(f309)) f309,
to_char(sum(f310)) f310,
to_char(sum(f311)) f311,
to_char(sum(f312)) f312,
to_char(sum(f313)) f313,
to_char(sum(f314)) f314,
to_char(sum(f315)) f315,
to_char(sum(f316)) f316,
to_char(sum(f317)) f317,
to_char(sum(f318)) f318,
to_char(sum(f319)) f319,
to_char(sum(f320)) f320,
to_char(sum(f321)) f321,
to_char(sum(f322)) f322,
to_char(sum(f323)) f323,
to_char(sum(f324)) f324,
to_char(sum(f325)) f325,
to_char(sum(f326)) f326,
to_char(sum(f327)) f327,
to_char(sum(f328)) f328,
to_char(sum(f329)) f329,
to_char(sum(f330)) f330,
to_char(sum(f331)) f331,
to_char(sum(f332)) f332,
to_char(sum(f333)) f333,
to_char(sum(f334)) f334,
to_char(sum(f335)) f335,
to_char(sum(f336)) f336,
to_char(sum(f337)) f337,
to_char(sum(f338)) f338,
to_char(sum(f339)) f339,
to_char(sum(f340)) f340,
to_char(sum(f341)) f341,
to_char(sum(f342)) f342,
to_char(sum(f343)) f343,
to_char(sum(f344)) f344,
to_char(sum(f345)) f345,
to_char(sum(f346)) f346,
to_char(sum(f347)) f347,
to_char(sum(f348)) f348,
to_char(sum(f349)) f349,
to_char(sum(f350)) f350,
to_char(sum(f351)) f351,
to_char(sum(f352)) f352,
to_char(sum(f353)) f353,
to_char(sum(f354)) f354,
to_char(sum(f355)) f355,
to_char(sum(f356)) f356,
to_char(sum(f357)) f357,
to_char(sum(f358)) f358,
to_char(sum(f359)) f359,
to_char(sum(f360)) f360,
to_char(sum(f361)) f361,
to_char(sum(f362)) f362,
to_char(sum(f363)) f363,
to_char(sum(f364)) f364,
to_char(sum(f365)) f365,
to_char(sum(f366)) f366,
to_char(sum(f367)) f367,
to_char(sum(f368)) f368,
to_char(sum(f369)) f369,
to_char(sum(f370)) f370,
to_char(sum(f371)) f371,
to_char(sum(f372)) f372,
to_char(sum(f373)) f373,
to_char(sum(f374)) f374,
to_char(sum(f375)) f375,
to_char(sum(f376)) f376,
to_char(sum(f377)) f377,
to_char(sum(f378)) f378,
to_char(sum(f379)) f379,
to_char(sum(f380)) f380,
to_char(sum(f381)) f381,
to_char(sum(f382)) f382,
to_char(sum(f383)) f383,
to_char(sum(f384)) f384,
to_char(sum(f385)) f385,
to_char(sum(f386)) f386,
to_char(sum(f387)) f387,
to_char(sum(f388)) f388,
to_char(sum(f389)) f389,
to_char(sum(f390)) f390,
to_char(sum(f391)) f391,
to_char(sum(f392)) f392,
to_char(sum(f393)) f393,
to_char(sum(f394)) f394,
to_char(sum(f395)) f395,
to_char(sum(f396)) f396,
to_char(sum(f397)) f397,
to_char(sum(f398)) f398,
to_char(sum(f399)) f399,
to_char(sum(f400)) f400,
to_char(sum(f401)) f401,
to_char(sum(f402)) f402,
to_char(sum(f403)) f403,
to_char(sum(f404)) f404,
to_char(sum(f405)) f405,
to_char(sum(f406)) f406,
to_char(sum(f407)) f407,
to_char(sum(f408)) f408,
to_char(sum(f409)) f409,
to_char(sum(f410)) f410,
to_char(sum(f411)) f411,
to_char(sum(f412)) f412,
to_char(sum(f413)) f413,
to_char(sum(f414)) f414,
to_char(sum(f415)) f415,
to_char(sum(f416)) f416,
to_char(sum(f417)) f417,
to_char(sum(f418)) f418,
to_char(sum(f419)) f419,
to_char(sum(f420)) f420,
to_char(sum(f421)) f421,
to_char(sum(f422)) f422,
to_char(sum(f423)) f423,
to_char(sum(f424)) f424,
to_char(sum(f425)) f425,
to_char(sum(f426)) f426,
to_char(sum(f427)) f427,
to_char(sum(f428)) f428,
to_char(sum(f429)) f429,
to_char(sum(f430)) f430,
to_char(sum(f431)) f431,
to_char(sum(f432)) f432,
to_char(sum(f433)) f433,
to_char(sum(f434)) f434,
to_char(sum(f435)) f435,
to_char(sum(f436)) f436,
to_char(sum(f437)) f437,
to_char(sum(f438)) f438,
to_char(sum(f439)) f439,
to_char(sum(f440)) f440,
to_char(sum(f441)) f441,
to_char(sum(f442)) f442,
to_char(sum(f443)) f443,
to_char(sum(f444)) f444,
to_char(sum(f445)) f445,
to_char(sum(f446)) f446,
to_char(sum(f447)) f447,
to_char(sum(f448)) f448,
to_char(sum(f449)) f449,
to_char(sum(f450)) f450,
to_char(sum(f451)) f451,
to_char(sum(f452)) f452,
to_char(sum(f453)) f453,
to_char(sum(f454)) f454,
to_char(sum(f455)) f455,
to_char(sum(f456)) f456,
to_char(sum(f457)) f457,
to_char(sum(f458)) f458,
to_char(sum(f459)) f459,
to_char(sum(f460)) f460,
to_char(sum(f461)) f461,
to_char(sum(f462)) f462,
to_char(sum(f463)) f463,
to_char(sum(f464)) f464,
to_char(sum(f465)) f465,
to_char(sum(f466)) f466,
to_char(sum(f467)) f467,
to_char(sum(f468)) f468,
to_char(sum(f469)) f469,
to_char(sum(f470)) f470,
to_char(sum(f471)) f471,
to_char(sum(f472)) f472,
to_char(sum(f473)) f473,
to_char(sum(f474)) f474,
to_char(sum(f475)) f475,
to_char(sum(f476)) f476,
to_char(sum(f477)) f477,
to_char(sum(f478)) f478,
to_char(sum(f479)) f479,
to_char(sum(f480)) f480,
to_char(sum(f481)) f481,
to_char(sum(f482)) f482,
to_char(sum(f483)) f483,
to_char(sum(f484)) f484,
to_char(sum(f485)) f485,
to_char(sum(f486)) f486,
to_char(sum(f487)) f487,
to_char(sum(f488)) f488,
to_char(sum(f489)) f489,
to_char(sum(f490)) f490,
to_char(sum(f491)) f491,
to_char(sum(f492)) f492,
to_char(sum(f493)) f493,
to_char(sum(f494)) f494,
to_char(sum(f495)) f495,
to_char(sum(f496)) f496,
to_char(sum(f497)) f497,
to_char(sum(f498)) f498,
to_char(sum(f499)) f499,
to_char(sum(f500)) f500,
to_char(sum(f501)) f501,
to_char(sum(f502)) f502,
to_char(sum(f503)) f503,
to_char(sum(f504)) f504,
to_char(sum(f505)) f505,
to_char(sum(f506)) f506,
to_char(sum(f507)) f507,
to_char(sum(f508)) f508,
to_char(sum(f509)) f509,
to_char(sum(f510)) f510,
to_char(sum(f511)) f511,
to_char(sum(f512)) f512,
to_char(sum(f513)) f513,
to_char(sum(f514)) f514,
to_char(sum(f515)) f515,
to_char(sum(f516)) f516,
to_char(sum(f517)) f517,
to_char(sum(f518)) f518,
to_char(sum(f519)) f519,
to_char(sum(f520)) f520,
to_char(sum(f521)) f521,
to_char(sum(f522)) f522,
to_char(sum(f523)) f523,
to_char(sum(f524)) f524,
to_char(sum(f525)) f525,
to_char(sum(f526)) f526,
to_char(sum(f527)) f527,
to_char(sum(f528)) f528,
to_char(sum(f529)) f529,
to_char(sum(f530)) f530,
to_char(sum(f531)) f531,
to_char(sum(f532)) f532,
to_char(sum(f533)) f533,
to_char(sum(f534)) f534,
to_char(sum(f535)) f535,
to_char(sum(f536)) f536,
to_char(sum(f537)) f537,
to_char(sum(f538)) f538,
to_char(sum(f539)) f539,
to_char(sum(f540)) f540,
to_char(sum(f541)) f541,
to_char(sum(f542)) f542,
to_char(sum(f543)) f543,
to_char(sum(f544)) f544,
to_char(sum(f545)) f545,
to_char(sum(f546)) f546,
to_char(sum(f547)) f547,
to_char(sum(f548)) f548,
to_char(sum(f549)) f549,
to_char(sum(f550)) f550,
to_char(sum(f551)) f551,
to_char(sum(f552)) f552,
to_char(sum(f553)) f553,
to_char(sum(f554)) f554,
to_char(sum(f555)) f555,
to_char(sum(f556)) f556,
to_char(sum(f557)) f557,
to_char(sum(f558)) f558,
to_char(sum(f559)) f559,
to_char(sum(f560)) f560,
to_char(sum(f561)) f561,
to_char(sum(f562)) f562,
to_char(sum(f563)) f563,
to_char(sum(f564)) f564,
to_char(sum(f565)) f565,
to_char(sum(f566)) f566,
to_char(sum(f567)) f567,
to_char(sum(f568)) f568,
to_char(sum(f569)) f569,
to_char(sum(f570)) f570,
to_char(sum(f571)) f571,
to_char(sum(f572)) f572,
to_char(sum(f573)) f573,
to_char(sum(f574)) f574,
to_char(sum(f575)) f575,
to_char(sum(f576)) f576,
to_char(sum(f577)) f577,
to_char(sum(f578)) f578,
to_char(sum(f579)) f579,
to_char(sum(f580)) f580,
to_char(sum(f581)) f581,
to_char(sum(f582)) f582,
to_char(sum(f583)) f583,
to_char(sum(f584)) f584,
to_char(sum(f585)) f585,
to_char(sum(f586)) f586,
to_char(sum(f587)) f587,
to_char(sum(f588)) f588,
to_char(sum(f589)) f589,
to_char(sum(f590)) f590,
to_char(sum(f591)) f591,
to_char(sum(f592)) f592,
to_char(sum(f593)) f593,
to_char(sum(f594)) f594,
to_char(sum(f595)) f595,
to_char(sum(f596)) f596,
to_char(sum(f597)) f597,
to_char(sum(f598)) f598,
to_char(sum(f599)) f599,
to_char(sum(f600)) f600,
to_char(sum(f601)) f601,
to_char(sum(f602)) f602,
to_char(sum(f603)) f603,
to_char(sum(f604)) f604,
to_char(sum(f605)) f605,
to_char(sum(f606)) f606,
to_char(sum(f607)) f607,
to_char(sum(f608)) f608,
to_char(sum(f609)) f609,
to_char(sum(f610)) f610,
to_char(sum(f611)) f611,
to_char(sum(f612)) f612,
to_char(sum(f613)) f613,
to_char(sum(f614)) f614,
to_char(sum(f615)) f615,
to_char(sum(f616)) f616,
to_char(sum(f617)) f617,
to_char(sum(f618)) f618,
to_char(sum(f619)) f619,
to_char(sum(f620)) f620,
to_char(sum(f621)) f621,
to_char(sum(f622)) f622,
to_char(sum(f623)) f623,
to_char(sum(f624)) f624,
to_char(sum(f625)) f625,
to_char(sum(f626)) f626,
to_char(sum(f627)) f627,
to_char(sum(f628)) f628,
to_char(sum(f629)) f629,
to_char(sum(f630)) f630,
to_char(sum(f631)) f631,
to_char(sum(f632)) f632,
to_char(sum(f633)) f633,
to_char(sum(f634)) f634,
to_char(sum(f635)) f635,
to_char(sum(f636)) f636,
to_char(sum(f637)) f637,
to_char(sum(f638)) f638,
to_char(sum(f639)) f639,
to_char(sum(f640)) f640,
to_char(sum(f641)) f641,
to_char(sum(f642)) f642,
to_char(sum(f643)) f643,
to_char(sum(f644)) f644,
to_char(sum(f645)) f645,
to_char(sum(f646)) f646,
to_char(sum(f647)) f647,
to_char(sum(f648)) f648,
to_char(sum(f649)) f649,
to_char(sum(f650)) f650,
to_char(sum(f651)) f651,
to_char(sum(f652)) f652,
to_char(sum(f653)) f653,
to_char(sum(f654)) f654,
to_char(sum(f655)) f655,
to_char(sum(f656)) f656,
to_char(sum(f657)) f657,
to_char(sum(f658)) f658,
to_char(sum(f659)) f659,
to_char(sum(f660)) f660,
to_char(sum(f661)) f661,
to_char(sum(f662)) f662,
to_char(sum(f663)) f663,
to_char(sum(f664)) f664,
to_char(sum(f665)) f665,
to_char(sum(f666)) f666,
to_char(sum(f667)) f667,
to_char(sum(f668)) f668,
to_char(sum(f669)) f669,
to_char(sum(f670)) f670,
to_char(sum(f671)) f671,
to_char(sum(f672)) f672,
to_char(sum(f673)) f673,
to_char(sum(f674)) f674,
to_char(sum(f675)) f675,
to_char(sum(f676)) f676,
to_char(sum(f677)) f677,
to_char(sum(f678)) f678,
to_char(sum(f679)) f679,
to_char(sum(f680)) f680,
to_char(sum(f681)) f681,
to_char(sum(f682)) f682,
to_char(sum(f683)) f683,
to_char(sum(f684)) f684,
to_char(sum(f685)) f685,
to_char(sum(f686)) f686,
to_char(sum(f687)) f687,
to_char(sum(f688)) f688,
to_char(sum(f689)) f689,
to_char(sum(f690)) f690,
to_char(sum(f691)) f691,
to_char(sum(f692)) f692,
to_char(sum(f693)) f693,
to_char(sum(f694)) f694,
to_char(sum(f695)) f695,
to_char(sum(f696)) f696,
to_char(sum(f697)) f697,
to_char(sum(f698)) f698,
to_char(sum(f699)) f699,
to_char(sum(f700)) f700
from tt3
group by BRANCH_NAM, SNAPSHOT_DT
union all
select 4, '','', SNAPSHOT_DT,
to_char(sum(f1)) f1,
to_char(sum(f2)) f2,
to_char(sum(f3)) f3,
to_char(sum(f4)) f4,
to_char(sum(f5)) f5,
to_char(sum(f6)) f6,
to_char(sum(f7)) f7,
to_char(sum(f8)) f8,
to_char(sum(f9)) f9,
to_char(sum(f10)) f10,
to_char(sum(f11)) f11,
to_char(sum(f12)) f12,
to_char(sum(f13)) f13,
to_char(sum(f14)) f14,
to_char(sum(f15)) f15,
to_char(sum(f16)) f16,
to_char(sum(f17)) f17,
to_char(sum(f18)) f18,
to_char(sum(f19)) f19,
to_char(sum(f20)) f20,
to_char(sum(f21)) f21,
to_char(sum(f22)) f22,
to_char(sum(f23)) f23,
to_char(sum(f24)) f24,
to_char(sum(f25)) f25,
to_char(sum(f26)) f26,
to_char(sum(f27)) f27,
to_char(sum(f28)) f28,
to_char(sum(f29)) f29,
to_char(sum(f30)) f30,
to_char(sum(f31)) f31,
to_char(sum(f32)) f32,
to_char(sum(f33)) f33,
to_char(sum(f34)) f34,
to_char(sum(f35)) f35,
to_char(sum(f36)) f36,
to_char(sum(f37)) f37,
to_char(sum(f38)) f38,
to_char(sum(f39)) f39,
to_char(sum(f40)) f40,
to_char(sum(f41)) f41,
to_char(sum(f42)) f42,
to_char(sum(f43)) f43,
to_char(sum(f44)) f44,
to_char(sum(f45)) f45,
to_char(sum(f46)) f46,
to_char(sum(f47)) f47,
to_char(sum(f48)) f48,
to_char(sum(f49)) f49,
to_char(sum(f50)) f50,
to_char(sum(f51)) f51,
to_char(sum(f52)) f52,
to_char(sum(f53)) f53,
to_char(sum(f54)) f54,
to_char(sum(f55)) f55,
to_char(sum(f56)) f56,
to_char(sum(f57)) f57,
to_char(sum(f58)) f58,
to_char(sum(f59)) f59,
to_char(sum(f60)) f60,
to_char(sum(f61)) f61,
to_char(sum(f62)) f62,
to_char(sum(f63)) f63,
to_char(sum(f64)) f64,
to_char(sum(f65)) f65,
to_char(sum(f66)) f66,
to_char(sum(f67)) f67,
to_char(sum(f68)) f68,
to_char(sum(f69)) f69,
to_char(sum(f70)) f70,
to_char(sum(f71)) f71,
to_char(sum(f72)) f72,
to_char(sum(f73)) f73,
to_char(sum(f74)) f74,
to_char(sum(f75)) f75,
to_char(sum(f76)) f76,
to_char(sum(f77)) f77,
to_char(sum(f78)) f78,
to_char(sum(f79)) f79,
to_char(sum(f80)) f80,
to_char(sum(f81)) f81,
to_char(sum(f82)) f82,
to_char(sum(f83)) f83,
to_char(sum(f84)) f84,
to_char(sum(f85)) f85,
to_char(sum(f86)) f86,
to_char(sum(f87)) f87,
to_char(sum(f88)) f88,
to_char(sum(f89)) f89,
to_char(sum(f90)) f90,
to_char(sum(f91)) f91,
to_char(sum(f92)) f92,
to_char(sum(f93)) f93,
to_char(sum(f94)) f94,
to_char(sum(f95)) f95,
to_char(sum(f96)) f96,
to_char(sum(f97)) f97,
to_char(sum(f98)) f98,
to_char(sum(f99)) f99,
to_char(sum(f100)) f100,
to_char(sum(f101)) f101,
to_char(sum(f102)) f102,
to_char(sum(f103)) f103,
to_char(sum(f104)) f104,
to_char(sum(f105)) f105,
to_char(sum(f106)) f106,
to_char(sum(f107)) f107,
to_char(sum(f108)) f108,
to_char(sum(f109)) f109,
to_char(sum(f110)) f110,
to_char(sum(f111)) f111,
to_char(sum(f112)) f112,
to_char(sum(f113)) f113,
to_char(sum(f114)) f114,
to_char(sum(f115)) f115,
to_char(sum(f116)) f116,
to_char(sum(f117)) f117,
to_char(sum(f118)) f118,
to_char(sum(f119)) f119,
to_char(sum(f120)) f120,
to_char(sum(f121)) f121,
to_char(sum(f122)) f122,
to_char(sum(f123)) f123,
to_char(sum(f124)) f124,
to_char(sum(f125)) f125,
to_char(sum(f126)) f126,
to_char(sum(f127)) f127,
to_char(sum(f128)) f128,
to_char(sum(f129)) f129,
to_char(sum(f130)) f130,
to_char(sum(f131)) f131,
to_char(sum(f132)) f132,
to_char(sum(f133)) f133,
to_char(sum(f134)) f134,
to_char(sum(f135)) f135,
to_char(sum(f136)) f136,
to_char(sum(f137)) f137,
to_char(sum(f138)) f138,
to_char(sum(f139)) f139,
to_char(sum(f140)) f140,
to_char(sum(f141)) f141,
to_char(sum(f142)) f142,
to_char(sum(f143)) f143,
to_char(sum(f144)) f144,
to_char(sum(f145)) f145,
to_char(sum(f146)) f146,
to_char(sum(f147)) f147,
to_char(sum(f148)) f148,
to_char(sum(f149)) f149,
to_char(sum(f150)) f150,
to_char(sum(f151)) f151,
to_char(sum(f152)) f152,
to_char(sum(f153)) f153,
to_char(sum(f154)) f154,
to_char(sum(f155)) f155,
to_char(sum(f156)) f156,
to_char(sum(f157)) f157,
to_char(sum(f158)) f158,
to_char(sum(f159)) f159,
to_char(sum(f160)) f160,
to_char(sum(f161)) f161,
to_char(sum(f162)) f162,
to_char(sum(f163)) f163,
to_char(sum(f164)) f164,
to_char(sum(f165)) f165,
to_char(sum(f166)) f166,
to_char(sum(f167)) f167,
to_char(sum(f168)) f168,
to_char(sum(f169)) f169,
to_char(sum(f170)) f170,
to_char(sum(f171)) f171,
to_char(sum(f172)) f172,
to_char(sum(f173)) f173,
to_char(sum(f174)) f174,
to_char(sum(f175)) f175,
to_char(sum(f176)) f176,
to_char(sum(f177)) f177,
to_char(sum(f178)) f178,
to_char(sum(f179)) f179,
to_char(sum(f180)) f180,
to_char(sum(f181)) f181,
to_char(sum(f182)) f182,
to_char(sum(f183)) f183,
to_char(sum(f184)) f184,
to_char(sum(f185)) f185,
to_char(sum(f186)) f186,
to_char(sum(f187)) f187,
to_char(sum(f188)) f188,
to_char(sum(f189)) f189,
to_char(sum(f190)) f190,
to_char(sum(f191)) f191,
to_char(sum(f192)) f192,
to_char(sum(f193)) f193,
to_char(sum(f194)) f194,
to_char(sum(f195)) f195,
to_char(sum(f196)) f196,
to_char(sum(f197)) f197,
to_char(sum(f198)) f198,
to_char(sum(f199)) f199,
to_char(sum(f200)) f200,
to_char(sum(f201)) f201,
to_char(sum(f202)) f202,
to_char(sum(f203)) f203,
to_char(sum(f204)) f204,
to_char(sum(f205)) f205,
to_char(sum(f206)) f206,
to_char(sum(f207)) f207,
to_char(sum(f208)) f208,
to_char(sum(f209)) f209,
to_char(sum(f210)) f210,
to_char(sum(f211)) f211,
to_char(sum(f212)) f212,
to_char(sum(f213)) f213,
to_char(sum(f214)) f214,
to_char(sum(f215)) f215,
to_char(sum(f216)) f216,
to_char(sum(f217)) f217,
to_char(sum(f218)) f218,
to_char(sum(f219)) f219,
to_char(sum(f220)) f220,
to_char(sum(f221)) f221,
to_char(sum(f222)) f222,
to_char(sum(f223)) f223,
to_char(sum(f224)) f224,
to_char(sum(f225)) f225,
to_char(sum(f226)) f226,
to_char(sum(f227)) f227,
to_char(sum(f228)) f228,
to_char(sum(f229)) f229,
to_char(sum(f230)) f230,
to_char(sum(f231)) f231,
to_char(sum(f232)) f232,
to_char(sum(f233)) f233,
to_char(sum(f234)) f234,
to_char(sum(f235)) f235,
to_char(sum(f236)) f236,
to_char(sum(f237)) f237,
to_char(sum(f238)) f238,
to_char(sum(f239)) f239,
to_char(sum(f240)) f240,
to_char(sum(f241)) f241,
to_char(sum(f242)) f242,
to_char(sum(f243)) f243,
to_char(sum(f244)) f244,
to_char(sum(f245)) f245,
to_char(sum(f246)) f246,
to_char(sum(f247)) f247,
to_char(sum(f248)) f248,
to_char(sum(f249)) f249,
to_char(sum(f250)) f250,
to_char(sum(f251)) f251,
to_char(sum(f252)) f252,
to_char(sum(f253)) f253,
to_char(sum(f254)) f254,
to_char(sum(f255)) f255,
to_char(sum(f256)) f256,
to_char(sum(f257)) f257,
to_char(sum(f258)) f258,
to_char(sum(f259)) f259,
to_char(sum(f260)) f260,
to_char(sum(f261)) f261,
to_char(sum(f262)) f262,
to_char(sum(f263)) f263,
to_char(sum(f264)) f264,
to_char(sum(f265)) f265,
to_char(sum(f266)) f266,
to_char(sum(f267)) f267,
to_char(sum(f268)) f268,
to_char(sum(f269)) f269,
to_char(sum(f270)) f270,
to_char(sum(f271)) f271,
to_char(sum(f272)) f272,
to_char(sum(f273)) f273,
to_char(sum(f274)) f274,
to_char(sum(f275)) f275,
to_char(sum(f276)) f276,
to_char(sum(f277)) f277,
to_char(sum(f278)) f278,
to_char(sum(f279)) f279,
to_char(sum(f280)) f280,
to_char(sum(f281)) f281,
to_char(sum(f282)) f282,
to_char(sum(f283)) f283,
to_char(sum(f284)) f284,
to_char(sum(f285)) f285,
to_char(sum(f286)) f286,
to_char(sum(f287)) f287,
to_char(sum(f288)) f288,
to_char(sum(f289)) f289,
to_char(sum(f290)) f290,
to_char(sum(f291)) f291,
to_char(sum(f292)) f292,
to_char(sum(f293)) f293,
to_char(sum(f294)) f294,
to_char(sum(f295)) f295,
to_char(sum(f296)) f296,
to_char(sum(f297)) f297,
to_char(sum(f298)) f298,
to_char(sum(f299)) f299,
to_char(sum(f300)) f300,
to_char(sum(f301)) f301,
to_char(sum(f302)) f302,
to_char(sum(f303)) f303,
to_char(sum(f304)) f304,
to_char(sum(f305)) f305,
to_char(sum(f306)) f306,
to_char(sum(f307)) f307,
to_char(sum(f308)) f308,
to_char(sum(f309)) f309,
to_char(sum(f310)) f310,
to_char(sum(f311)) f311,
to_char(sum(f312)) f312,
to_char(sum(f313)) f313,
to_char(sum(f314)) f314,
to_char(sum(f315)) f315,
to_char(sum(f316)) f316,
to_char(sum(f317)) f317,
to_char(sum(f318)) f318,
to_char(sum(f319)) f319,
to_char(sum(f320)) f320,
to_char(sum(f321)) f321,
to_char(sum(f322)) f322,
to_char(sum(f323)) f323,
to_char(sum(f324)) f324,
to_char(sum(f325)) f325,
to_char(sum(f326)) f326,
to_char(sum(f327)) f327,
to_char(sum(f328)) f328,
to_char(sum(f329)) f329,
to_char(sum(f330)) f330,
to_char(sum(f331)) f331,
to_char(sum(f332)) f332,
to_char(sum(f333)) f333,
to_char(sum(f334)) f334,
to_char(sum(f335)) f335,
to_char(sum(f336)) f336,
to_char(sum(f337)) f337,
to_char(sum(f338)) f338,
to_char(sum(f339)) f339,
to_char(sum(f340)) f340,
to_char(sum(f341)) f341,
to_char(sum(f342)) f342,
to_char(sum(f343)) f343,
to_char(sum(f344)) f344,
to_char(sum(f345)) f345,
to_char(sum(f346)) f346,
to_char(sum(f347)) f347,
to_char(sum(f348)) f348,
to_char(sum(f349)) f349,
to_char(sum(f350)) f350,
to_char(sum(f351)) f351,
to_char(sum(f352)) f352,
to_char(sum(f353)) f353,
to_char(sum(f354)) f354,
to_char(sum(f355)) f355,
to_char(sum(f356)) f356,
to_char(sum(f357)) f357,
to_char(sum(f358)) f358,
to_char(sum(f359)) f359,
to_char(sum(f360)) f360,
to_char(sum(f361)) f361,
to_char(sum(f362)) f362,
to_char(sum(f363)) f363,
to_char(sum(f364)) f364,
to_char(sum(f365)) f365,
to_char(sum(f366)) f366,
to_char(sum(f367)) f367,
to_char(sum(f368)) f368,
to_char(sum(f369)) f369,
to_char(sum(f370)) f370,
to_char(sum(f371)) f371,
to_char(sum(f372)) f372,
to_char(sum(f373)) f373,
to_char(sum(f374)) f374,
to_char(sum(f375)) f375,
to_char(sum(f376)) f376,
to_char(sum(f377)) f377,
to_char(sum(f378)) f378,
to_char(sum(f379)) f379,
to_char(sum(f380)) f380,
to_char(sum(f381)) f381,
to_char(sum(f382)) f382,
to_char(sum(f383)) f383,
to_char(sum(f384)) f384,
to_char(sum(f385)) f385,
to_char(sum(f386)) f386,
to_char(sum(f387)) f387,
to_char(sum(f388)) f388,
to_char(sum(f389)) f389,
to_char(sum(f390)) f390,
to_char(sum(f391)) f391,
to_char(sum(f392)) f392,
to_char(sum(f393)) f393,
to_char(sum(f394)) f394,
to_char(sum(f395)) f395,
to_char(sum(f396)) f396,
to_char(sum(f397)) f397,
to_char(sum(f398)) f398,
to_char(sum(f399)) f399,
to_char(sum(f400)) f400,
to_char(sum(f401)) f401,
to_char(sum(f402)) f402,
to_char(sum(f403)) f403,
to_char(sum(f404)) f404,
to_char(sum(f405)) f405,
to_char(sum(f406)) f406,
to_char(sum(f407)) f407,
to_char(sum(f408)) f408,
to_char(sum(f409)) f409,
to_char(sum(f410)) f410,
to_char(sum(f411)) f411,
to_char(sum(f412)) f412,
to_char(sum(f413)) f413,
to_char(sum(f414)) f414,
to_char(sum(f415)) f415,
to_char(sum(f416)) f416,
to_char(sum(f417)) f417,
to_char(sum(f418)) f418,
to_char(sum(f419)) f419,
to_char(sum(f420)) f420,
to_char(sum(f421)) f421,
to_char(sum(f422)) f422,
to_char(sum(f423)) f423,
to_char(sum(f424)) f424,
to_char(sum(f425)) f425,
to_char(sum(f426)) f426,
to_char(sum(f427)) f427,
to_char(sum(f428)) f428,
to_char(sum(f429)) f429,
to_char(sum(f430)) f430,
to_char(sum(f431)) f431,
to_char(sum(f432)) f432,
to_char(sum(f433)) f433,
to_char(sum(f434)) f434,
to_char(sum(f435)) f435,
to_char(sum(f436)) f436,
to_char(sum(f437)) f437,
to_char(sum(f438)) f438,
to_char(sum(f439)) f439,
to_char(sum(f440)) f440,
to_char(sum(f441)) f441,
to_char(sum(f442)) f442,
to_char(sum(f443)) f443,
to_char(sum(f444)) f444,
to_char(sum(f445)) f445,
to_char(sum(f446)) f446,
to_char(sum(f447)) f447,
to_char(sum(f448)) f448,
to_char(sum(f449)) f449,
to_char(sum(f450)) f450,
to_char(sum(f451)) f451,
to_char(sum(f452)) f452,
to_char(sum(f453)) f453,
to_char(sum(f454)) f454,
to_char(sum(f455)) f455,
to_char(sum(f456)) f456,
to_char(sum(f457)) f457,
to_char(sum(f458)) f458,
to_char(sum(f459)) f459,
to_char(sum(f460)) f460,
to_char(sum(f461)) f461,
to_char(sum(f462)) f462,
to_char(sum(f463)) f463,
to_char(sum(f464)) f464,
to_char(sum(f465)) f465,
to_char(sum(f466)) f466,
to_char(sum(f467)) f467,
to_char(sum(f468)) f468,
to_char(sum(f469)) f469,
to_char(sum(f470)) f470,
to_char(sum(f471)) f471,
to_char(sum(f472)) f472,
to_char(sum(f473)) f473,
to_char(sum(f474)) f474,
to_char(sum(f475)) f475,
to_char(sum(f476)) f476,
to_char(sum(f477)) f477,
to_char(sum(f478)) f478,
to_char(sum(f479)) f479,
to_char(sum(f480)) f480,
to_char(sum(f481)) f481,
to_char(sum(f482)) f482,
to_char(sum(f483)) f483,
to_char(sum(f484)) f484,
to_char(sum(f485)) f485,
to_char(sum(f486)) f486,
to_char(sum(f487)) f487,
to_char(sum(f488)) f488,
to_char(sum(f489)) f489,
to_char(sum(f490)) f490,
to_char(sum(f491)) f491,
to_char(sum(f492)) f492,
to_char(sum(f493)) f493,
to_char(sum(f494)) f494,
to_char(sum(f495)) f495,
to_char(sum(f496)) f496,
to_char(sum(f497)) f497,
to_char(sum(f498)) f498,
to_char(sum(f499)) f499,
to_char(sum(f500)) f500,
to_char(sum(f501)) f501,
to_char(sum(f502)) f502,
to_char(sum(f503)) f503,
to_char(sum(f504)) f504,
to_char(sum(f505)) f505,
to_char(sum(f506)) f506,
to_char(sum(f507)) f507,
to_char(sum(f508)) f508,
to_char(sum(f509)) f509,
to_char(sum(f510)) f510,
to_char(sum(f511)) f511,
to_char(sum(f512)) f512,
to_char(sum(f513)) f513,
to_char(sum(f514)) f514,
to_char(sum(f515)) f515,
to_char(sum(f516)) f516,
to_char(sum(f517)) f517,
to_char(sum(f518)) f518,
to_char(sum(f519)) f519,
to_char(sum(f520)) f520,
to_char(sum(f521)) f521,
to_char(sum(f522)) f522,
to_char(sum(f523)) f523,
to_char(sum(f524)) f524,
to_char(sum(f525)) f525,
to_char(sum(f526)) f526,
to_char(sum(f527)) f527,
to_char(sum(f528)) f528,
to_char(sum(f529)) f529,
to_char(sum(f530)) f530,
to_char(sum(f531)) f531,
to_char(sum(f532)) f532,
to_char(sum(f533)) f533,
to_char(sum(f534)) f534,
to_char(sum(f535)) f535,
to_char(sum(f536)) f536,
to_char(sum(f537)) f537,
to_char(sum(f538)) f538,
to_char(sum(f539)) f539,
to_char(sum(f540)) f540,
to_char(sum(f541)) f541,
to_char(sum(f542)) f542,
to_char(sum(f543)) f543,
to_char(sum(f544)) f544,
to_char(sum(f545)) f545,
to_char(sum(f546)) f546,
to_char(sum(f547)) f547,
to_char(sum(f548)) f548,
to_char(sum(f549)) f549,
to_char(sum(f550)) f550,
to_char(sum(f551)) f551,
to_char(sum(f552)) f552,
to_char(sum(f553)) f553,
to_char(sum(f554)) f554,
to_char(sum(f555)) f555,
to_char(sum(f556)) f556,
to_char(sum(f557)) f557,
to_char(sum(f558)) f558,
to_char(sum(f559)) f559,
to_char(sum(f560)) f560,
to_char(sum(f561)) f561,
to_char(sum(f562)) f562,
to_char(sum(f563)) f563,
to_char(sum(f564)) f564,
to_char(sum(f565)) f565,
to_char(sum(f566)) f566,
to_char(sum(f567)) f567,
to_char(sum(f568)) f568,
to_char(sum(f569)) f569,
to_char(sum(f570)) f570,
to_char(sum(f571)) f571,
to_char(sum(f572)) f572,
to_char(sum(f573)) f573,
to_char(sum(f574)) f574,
to_char(sum(f575)) f575,
to_char(sum(f576)) f576,
to_char(sum(f577)) f577,
to_char(sum(f578)) f578,
to_char(sum(f579)) f579,
to_char(sum(f580)) f580,
to_char(sum(f581)) f581,
to_char(sum(f582)) f582,
to_char(sum(f583)) f583,
to_char(sum(f584)) f584,
to_char(sum(f585)) f585,
to_char(sum(f586)) f586,
to_char(sum(f587)) f587,
to_char(sum(f588)) f588,
to_char(sum(f589)) f589,
to_char(sum(f590)) f590,
to_char(sum(f591)) f591,
to_char(sum(f592)) f592,
to_char(sum(f593)) f593,
to_char(sum(f594)) f594,
to_char(sum(f595)) f595,
to_char(sum(f596)) f596,
to_char(sum(f597)) f597,
to_char(sum(f598)) f598,
to_char(sum(f599)) f599,
to_char(sum(f600)) f600,
to_char(sum(f601)) f601,
to_char(sum(f602)) f602,
to_char(sum(f603)) f603,
to_char(sum(f604)) f604,
to_char(sum(f605)) f605,
to_char(sum(f606)) f606,
to_char(sum(f607)) f607,
to_char(sum(f608)) f608,
to_char(sum(f609)) f609,
to_char(sum(f610)) f610,
to_char(sum(f611)) f611,
to_char(sum(f612)) f612,
to_char(sum(f613)) f613,
to_char(sum(f614)) f614,
to_char(sum(f615)) f615,
to_char(sum(f616)) f616,
to_char(sum(f617)) f617,
to_char(sum(f618)) f618,
to_char(sum(f619)) f619,
to_char(sum(f620)) f620,
to_char(sum(f621)) f621,
to_char(sum(f622)) f622,
to_char(sum(f623)) f623,
to_char(sum(f624)) f624,
to_char(sum(f625)) f625,
to_char(sum(f626)) f626,
to_char(sum(f627)) f627,
to_char(sum(f628)) f628,
to_char(sum(f629)) f629,
to_char(sum(f630)) f630,
to_char(sum(f631)) f631,
to_char(sum(f632)) f632,
to_char(sum(f633)) f633,
to_char(sum(f634)) f634,
to_char(sum(f635)) f635,
to_char(sum(f636)) f636,
to_char(sum(f637)) f637,
to_char(sum(f638)) f638,
to_char(sum(f639)) f639,
to_char(sum(f640)) f640,
to_char(sum(f641)) f641,
to_char(sum(f642)) f642,
to_char(sum(f643)) f643,
to_char(sum(f644)) f644,
to_char(sum(f645)) f645,
to_char(sum(f646)) f646,
to_char(sum(f647)) f647,
to_char(sum(f648)) f648,
to_char(sum(f649)) f649,
to_char(sum(f650)) f650,
to_char(sum(f651)) f651,
to_char(sum(f652)) f652,
to_char(sum(f653)) f653,
to_char(sum(f654)) f654,
to_char(sum(f655)) f655,
to_char(sum(f656)) f656,
to_char(sum(f657)) f657,
to_char(sum(f658)) f658,
to_char(sum(f659)) f659,
to_char(sum(f660)) f660,
to_char(sum(f661)) f661,
to_char(sum(f662)) f662,
to_char(sum(f663)) f663,
to_char(sum(f664)) f664,
to_char(sum(f665)) f665,
to_char(sum(f666)) f666,
to_char(sum(f667)) f667,
to_char(sum(f668)) f668,
to_char(sum(f669)) f669,
to_char(sum(f670)) f670,
to_char(sum(f671)) f671,
to_char(sum(f672)) f672,
to_char(sum(f673)) f673,
to_char(sum(f674)) f674,
to_char(sum(f675)) f675,
to_char(sum(f676)) f676,
to_char(sum(f677)) f677,
to_char(sum(f678)) f678,
to_char(sum(f679)) f679,
to_char(sum(f680)) f680,
to_char(sum(f681)) f681,
to_char(sum(f682)) f682,
to_char(sum(f683)) f683,
to_char(sum(f684)) f684,
to_char(sum(f685)) f685,
to_char(sum(f686)) f686,
to_char(sum(f687)) f687,
to_char(sum(f688)) f688,
to_char(sum(f689)) f689,
to_char(sum(f690)) f690,
to_char(sum(f691)) f691,
to_char(sum(f692)) f692,
to_char(sum(f693)) f693,
to_char(sum(f694)) f694,
to_char(sum(f695)) f695,
to_char(sum(f696)) f696,
to_char(sum(f697)) f697,
to_char(sum(f698)) f698,
to_char(sum(f699)) f699,
to_char(sum(f700)) f700
from tt3
group by  SNAPSHOT_DT
)
select 
CONTRACT_ID_CD,
BRANCH_NAM,
SNAPSHOT_DT,
F1,
F2,
F3,
F4,
F5,
F6,
F7,
F8,
F9,
F10,
F11,
F12,
F13,
F14,
F15,
F16,
F17,
F18,
F19,
F20,
F21,
F22,
F23,
F24,
F25,
F26,
F27,
F28,
F29,
F30,
F31,
F32,
F33,
F34,
F35,
F36,
F37,
F38,
F39,
F40,
F41,
F42,
F43,
F44,
F45,
F46,
F47,
F48,
F49,
F50,
F51,
F52,
F53,
F54,
F55,
F56,
F57,
F58,
F59,
F60,
F61,
F62,
F63,
F64,
F65,
F66,
F67,
F68,
F69,
F70,
F71,
F72,
F73,
F74,
F75,
F76,
F77,
F78,
F79,
F80,
F81,
F82,
F83,
F84,
F85,
F86,
F87,
F88,
F89,
F90,
F91,
F92,
F93,
F94,
F95,
F96,
F97,
F98,
F99,
F100,
F101,
F102,
F103,
F104,
F105,
F106,
F107,
F108,
F109,
F110,
F111,
F112,
F113,
F114,
F115,
F116,
F117,
F118,
F119,
F120,
F121,
F122,
F123,
F124,
F125,
F126,
F127,
F128,
F129,
F130,
F131,
F132,
F133,
F134,
F135,
F136,
F137,
F138,
F139,
F140,
F141,
F142,
F143,
F144,
F145,
F146,
F147,
F148,
F149,
F150,
F151,
F152,
F153,
F154,
F155,
F156,
F157,
F158,
F159,
F160,
F161,
F162,
F163,
F164,
F165,
F166,
F167,
F168,
F169,
F170,
F171,
F172,
F173,
F174,
F175,
F176,
F177,
F178,
F179,
F180,
F181,
F182,
F183,
F184,
F185,
F186,
F187,
F188,
F189,
F190,
F191,
F192,
F193,
F194,
F195,
F196,
F197,
F198,
F199,
F200,
F201,
F202,
F203,
F204,
F205,
F206,
F207,
F208,
F209,
F210,
F211,
F212,
F213,
F214,
F215,
F216,
F217,
F218,
F219,
F220,
F221,
F222,
F223,
F224,
F225,
F226,
F227,
F228,
F229,
F230,
F231,
F232,
F233,
F234,
F235,
F236,
F237,
F238,
F239,
F240,
F241,
F242,
F243,
F244,
F245,
F246,
F247,
F248,
F249,
F250,
F251,
F252,
F253,
F254,
F255,
F256,
F257,
F258,
F259,
F260,
F261,
F262,
F263,
F264,
F265,
F266,
F267,
F268,
F269,
F270,
F271,
F272,
F273,
F274,
F275,
F276,
F277,
F278,
F279,
F280,
F281,
F282,
F283,
F284,
F285,
F286,
F287,
F288,
F289,
F290,
F291,
F292,
F293,
F294,
F295,
F296,
F297,
F298,
F299,
F300,
F301,
F302,
F303,
F304,
F305,
F306,
F307,
F308,
F309,
F310,
F311,
F312,
F313,
F314,
F315,
F316,
F317,
F318,
F319,
F320,
F321,
F322,
F323,
F324,
F325,
F326,
F327,
F328,
F329,
F330,
F331,
F332,
F333,
F334,
F335,
F336,
F337,
F338,
F339,
F340,
F341,
F342,
F343,
F344,
F345,
F346,
F347,
F348,
F349,
F350,
F351,
F352,
F353,
F354,
F355,
F356,
F357,
F358,
F359,
F360,
F361,
F362,
F363,
F364,
F365,
F366,
F367,
F368,
F369,
F370,
F371,
F372,
F373,
F374,
F375,
F376,
F377,
F378,
F379,
F380,
F381,
F382,
F383,
F384,
F385,
F386,
F387,
F388,
F389,
F390,
F391,
F392,
F393,
F394,
F395,
F396,
F397,
F398,
F399,
F400,
F401,
F402,
F403,
F404,
F405,
F406,
F407,
F408,
F409,
F410,
F411,
F412,
F413,
F414,
F415,
F416,
F417,
F418,
F419,
F420,
F421,
F422,
F423,
F424,
F425,
F426,
F427,
F428,
F429,
F430,
F431,
F432,
F433,
F434,
F435,
F436,
F437,
F438,
F439,
F440,
F441,
F442,
F443,
F444,
F445,
F446,
F447,
F448,
F449,
F450,
F451,
F452,
F453,
F454,
F455,
F456,
F457,
F458,
F459,
F460,
F461,
F462,
F463,
F464,
F465,
F466,
F467,
F468,
F469,
F470,
F471,
F472,
F473,
F474,
F475,
F476,
F477,
F478,
F479,
F480,
F481,
F482,
F483,
F484,
F485,
F486,
F487,
F488,
F489,
F490,
F491,
F492,
F493,
F494,
F495,
F496,
F497,
F498,
F499,
F500,
F501,
F502,
F503,
F504,
F505,
F506,
F507,
F508,
F509,
F510,
F511,
F512,
F513,
F514,
F515,
F516,
F517,
F518,
F519,
F520,
F521,
F522,
F523,
F524,
F525,
F526,
F527,
F528,
F529,
F530,
F531,
F532,
F533,
F534,
F535,
F536,
F537,
F538,
F539,
F540,
F541,
F542,
F543,
F544,
F545,
F546,
F547,
F548,
F549,
F550,
F551,
F552,
F553,
F554,
F555,
F556,
F557,
F558,
F559,
F560,
F561,
F562,
F563,
F564,
F565,
F566,
F567,
F568,
F569,
F570,
F571,
F572,
F573,
F574,
F575,
F576,
F577,
F578,
F579,
F580,
F581,
F582,
F583,
F584,
F585,
F586,
F587,
F588,
F589,
F590,
F591,
F592,
F593,
F594,
F595,
F596,
F597,
F598,
F599,
F600,
F601,
F602,
F603,
F604,
F605,
F606,
F607,
F608,
F609,
F610,
F611,
F612,
F613,
F614,
F615,
F616,
F617,
F618,
F619,
F620,
F621,
F622,
F623,
F624,
F625,
F626,
F627,
F628,
F629,
F630,
F631,
F632,
F633,
F634,
F635,
F636,
F637,
F638,
F639,
F640,
F641,
F642,
F643,
F644,
F645,
F646,
F647,
F648,
F649,
F650,
F651,
F652,
F653,
F654,
F655,
F656,
F657,
F658,
F659,
F660,
F661,
F662,
F663,
F664,
F665,
F666,
F667,
F668,
F669,
F670,
F671,
F672,
F673,
F674,
F675,
F676,
F677,
F678,
F679,
F680,
F681,
F682,
F683,
F684,
F685,
F686,
F687,
F688,
F689,
F690,
F691,
F692,
F693,
F694,
F695,
F696,
F697,
F698,
F699,
F700,
rn
from tt4 
order by rn; 

        
  
commit;
  
  
end;
/

