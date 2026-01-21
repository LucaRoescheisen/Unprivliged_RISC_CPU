open_project ./vivado/un_risc5.xpr

# Launch implementation (from last synthesis results)
launch_runs impl_1 -to_step write_bitstream -jobs 8

# Wait for implementation to finish
wait_on_run impl_1

# Optionally, generate implementation reports
report_timing_summary -file ./vivado/reports/impl/impl_timing_rpt.txt
report_utilization -file ./vivado/reports/impl/impl_util_rpt.txt
report_clock_utilization -file ./vivado/reports/impl/impl_clk_rpt.txt
report_drc -file ./vivado/reports/drc/impl_drc.rpt
write_bitstream -force un_risc5.bi

# Write bitstream
write_bitstream -force ../vivado/un_risc5.bit