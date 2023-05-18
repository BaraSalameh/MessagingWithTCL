package require math::bignum

set get_flag [open "../Server/Diffie-Hellman/flag.dat"]
set flag [gets $get_flag]
close $get_flag


if {$flag eq "0"} {
	set p [get_line_from_file "../Node1/Diffie-Hellman/flow.dat" 1]
	set g [get_line_from_file "../Node1/Diffie-Hellman/flow.dat" 2]
	
	set a [expr {int(rand() * ([expr $p - 2] - 2)) + 2}]
	if {$a < 0} {set a [expr $a * -1]}
	
	set base [::math::bignum::fromstr $g]
	set exponent [::math::bignum::fromstr $a]
	set modulus [::math::bignum::fromstr $p]
	set A [math::bignum::powm $base $exponent $modulus]
	set A [::math::bignum::tostr $A]
	
	puts "node1{a}: $a"
	puts "node1{A}: $A"
	
	set_line_in_file "../Node1/Diffie-Hellman/flow.dat" 3 $a
	set_line_in_file "../Node1/Diffie-Hellman/flow.dat" 4 $A
	set_line_in_file "./Diffie-Hellman/flow.dat" 2 $A
} elseif {$flag eq "1"} {
	set B [get_line_from_file "../Node1/Diffie-Hellman/flow.dat" 5]
	set a [get_line_from_file "../Node1/Diffie-Hellman/flow.dat" 3]
	set p [get_line_from_file "../Node1/Diffie-Hellman/flow.dat" 1]
	
	puts "node1{B}: $B"
	set base [::math::bignum::fromstr $B]
	set exponent [::math::bignum::fromstr $a]
	set modulus [::math::bignum::fromstr $p]
	set s [math::bignum::powm $base $exponent $modulus]
	set s [::math::bignum::tostr $s]
	
	set_line_in_file "../Node1/Diffie-Hellman/flow.dat" 6 $s
	
	set hex [format "%x" $s]
	set length [string length $hex]
	if {$length eq 16 || $length eq 24 || $length eq 32} {
		set_line_in_file "../Node1/Diffie-Hellman/flow.dat" 7 $hex
		puts "Node1{hex}: $hex"
	} else {
		puts "The key length is too short or too long, exiting..."
		exit
	}
}

