remove_design -all
set search_path {../lib}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

analyze -format verilog ../rtl/top.v

elaborate APB_SPI_Top

link

check_design

current_design APB_SPI_Top

compile_ultra

write_file -f verilog -hier -output top_netlist.v
