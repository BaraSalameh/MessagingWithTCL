set node0_message [get_line_from_file "../info.txt" 11]
set node1_message [get_line_from_file "../info.txt" 12]
set_line_in_file "../Node0/Messages/Outgoing/aes.dat" 3 $node0_message
set_line_in_file "../Node1/Messages/Outgoing/aes.dat" 3 $node1_message
