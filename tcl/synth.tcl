open_project ./vivado/un_risc5.xpr

# Reset previous synthesis run
reset_run synth_1

# Launch synthesis using multiple jobs (adjust as needed)
launch_runs synth_1 -jobs 8

# Wait until synthesis is finished
wait_on_run synth_1

# Optionally, generate a synthesis report
report_timing_summary -file ./vivado/reports/synth_timing_rpt.txt
report_utilization -file ./vivado/reports/synth_util_rpt.txt
report_property -all -file ./vivado/reports/synth/synth_props_rpt.txt
report_drc -file ./vivado/reports/drc/synth_drc.rpt