package require math::bignum

set key_size [get_line_from_file "../info.txt" 28]
puts "keysize located in line 28: $key_size"
set p [expr {1 << $key_size}]
set g 7

set_line_in_file "../Node0/Diffie-Hellman/flow.dat" 1 $p
set_line_in_file "../Node0/Diffie-Hellman/flow.dat" 2 $g
set_line_in_file "../Node1/Diffie-Hellman/flow.dat" 1 $p
set_line_in_file "../Node1/Diffie-Hellman/flow.dat" 2 $g

change_DH_flag "0"
source "../Node0/Diffie-Hellman/dh.tcl"
source "../Node1/Diffie-Hellman/dh.tcl"

set A [get_line_from_file "./Diffie-Hellman/flow.dat" 1]
set B [get_line_from_file "./Diffie-Hellman/flow.dat" 2]

set_line_in_file "../Node1/Diffie-Hellman/flow.dat" 5 $A
set_line_in_file "../Node0/Diffie-Hellman/flow.dat" 5 $B

change_DH_flag "1"
source "../Node0/Diffie-Hellman/dh.tcl"
source "../Node1/Diffie-Hellman/dh.tcl"
