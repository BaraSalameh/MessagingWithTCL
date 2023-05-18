# RSA Encryption function
proc RSA_Encryption {message e n} {
	set sep [get_line_from_file "../info.txt" 24]
	set mylist [split [separate $message $sep] { }]
	set c ""
	foreach {char} $mylist {
		scan $char %d asc
		set res [expr [expr {$asc ** $e}] % $n]
		append c $res
		append c " "
	}
	set file_handler [open "../Node0/Messages/Operations/rsa_EDFlow.txt" w]
	puts -nonewline $file_handler $c
	close $file_handler
}

# RSA Decryption function
proc RSA_Decryption {cypher d n} {
	set mylist [split $cypher { }]
	set p ""
	set counter 0
	foreach {char} $mylist {
		if {$counter == [expr [strlen $mylist] - 1]} {
			break
		} else {
			set counter [expr $counter + 1]
		}
		scan $char %d asc
		set res 1
		for {set i 1} {$i <= $d} {incr i} {
			set res [expr {($res * $asc) % $n}]
		}
		append p "$res "
	}
	return [converter [maintain $p]]
}

set flag_handler [open "./assets/flag.txt" r]
set flag [read $flag_handler]
close $flag_handler

if {$flag == "00"} {
	set a [get_line_from_file "../Node0/Diffie-Hellman/flow.dat" 3]
	set e [get_line_from_file "../info.txt" 13]
	set n [get_line_from_file "../info.txt" 14]
	puts "node0{e} located in line 13: $e"
	puts "node0{n} located in line 14: $n"
	RSA_Encryption $a $e $n
	
	set b [get_line_from_file "../Node0/Messages/Operations/fito.txt" 1]
	delete_file_content "../Node0/Messages/Operations/fito.txt"
	set_line_in_file "../Node0/Messages/Operations/rsa_EDFlow.txt" 2 $b
} elseif {$flag == "11"} {
	set b [get_line_from_file "../Node0/Messages/Incoming/incoming.txt" 1]	
	set a [get_line_from_file "../Node0/Messages/Incoming/incoming.txt" 2]
	set d [get_line_from_file "../info.txt" 15]
	set n [get_line_from_file "../info.txt" 16]
	puts "node0{d} located in line 15: $d"
	puts "node0{n} located in line 16: $n"
	set a [RSA_Decryption $a $d $n]
	set_line_in_file "../Node0/Messages/Operations/fito.txt" 1 $b
	set_line_in_file "../Node0/Messages/Operations/fito.txt" 2 $a
}

