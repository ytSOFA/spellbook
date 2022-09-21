{{ config(
  materialized='view'
  , alias='interest'
  , post_hook='{{ expose_spells(\'["optimism"]\',
                                  "project",
                                  "aave_v3",
                                  \'["batwayne", "chuxinh"]\') }}'
  )
}}

select 
  a.reserve, 
  t.symbol,
  date_trunc('hour',a.evt_block_time) as hour, 
  avg(a.liquidityRate) / 1e27 as deposit_apy, 
  avg(a.stableBorrowRate) / 1e27 as stable_borrow_apy, 
  avg(a.variableBorrowRate) / 1e27 as variable_borrow_apy
from {{ source('aave_v3_optimism', 'Pool_evt_ReserveDataUpdated') }} a
left join {{ ref('tokens_optimism_erc20') }} t
on a.reserve=t.contract_address
group by 1,2,3