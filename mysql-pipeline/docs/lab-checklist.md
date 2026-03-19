# Level 1 Lab Checklist

Use this checklist to confirm the project is complete.

## Core design
- [ ] `source_shop` created
- [ ] `shop_analytics` created
- [ ] source tables loaded with sample data
- [ ] analytics dimensions and fact created
- [ ] fact grain clearly defined as one row per order item

## Transform and load
- [ ] source views created
- [ ] refresh procedure created
- [ ] pipeline wrapper created
- [ ] refresh tested manually

## Logging and quality
- [ ] `etl_run_log` created
- [ ] `dq_check_log` created
- [ ] successful ETL run logged
- [ ] validation checks logged
- [ ] row count reconciliation tested
- [ ] revenue reconciliation tested
- [ ] duplicate check tested

## Automation
- [ ] event scheduler enabled
- [ ] event created
- [ ] event verified

## Reporting
- [ ] daily revenue view created
- [ ] customer revenue view created
- [ ] product sales view created

## End-to-end test
- [ ] new source rows inserted
- [ ] pipeline rerun
- [ ] analytics updated correctly
- [ ] logs updated correctly
- [ ] reports changed correctly
