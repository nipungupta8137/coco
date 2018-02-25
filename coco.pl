#!/usr/bin/perl
# Correct code with all the possible loops
# brew install graphviz
# Author : Nipun Gupta

use strict;
use warnings;
use Data::Dumper;

our %graph = ();
our %listHash = ();
my $start = "E1";  # Start node in input file has to be E1
my $stop  = "X";   # Stop node ID has to be X
my $caseNum = 1;
my $inputFile = $ARGV[0]; # input file user responsibility
my $dotFile   = $ARGV[1]; # dot file an input for the graph
my $pngFile   = $ARGV[2]; # graph file
my $graphFlag = ($ARGV[3] eq "ALL") ? $ARGV[3]:"NA"; # graph coverage
my $debugFalg = ($ARGV[4] eq "DEBUG") ? $ARGV[4]:"NA"; # graph coverage

$|=1;

sub CreateDotFile{
	my $filename = shift;
	my $dotFileName = shift;
	my $i;
	my $line;
	my @myGoto = ();
	my @mySwitch = ();
	my @myTokens = ();

	open(MYFILE, $filename) or die "Could not open file '$filename' $!";
	open (FH, ">" . $dotFileName) or die "$!";
	while (<MYFILE>) {
		chomp;
		$line = $_;
		@myTokens = split(/:/,$line);

        print ("\n ************* HERE **************");
        foreach(@myTokens){
            print "\n" . $_
        }

		if($line =~ /:E:/){
	#		print "\n Entry Node";
			print FH "\n digraph G {\n\t" . $myTokens[0] . " [shape=Mdiamond];";
			print FH "\n\trankdir=LR;\n\tnode [shape=record,height=.08,fontsize=11];";
			print FH "\n\t" . $myTokens[0] . " -> " . $myTokens[3] . ";";
			print FH "\n\tsubgraph \"cluster_" . $myTokens[0] . "\" { label=\"" . $myTokens[2] . "\"; " . $myTokens[0] . "; }"
		}

		if($line =~ /:S:/){
	#		print "\n Switch Node";
			$i = 0;
			foreach(@myTokens){
				$mySwitch[$i++] = $_;
			}
		}

		if($line =~ /:G:/){
	#		print "\n Goto Node";
			$i = 0;
			foreach(@myTokens){
				$myGoto[$i++] = $_;
			}
			for($i = 3; $i <= $#myGoto;$i++){
				print FH "\n\t" . $mySwitch[0] . " -> " . $myGoto[$i] . " [label=\"" . $mySwitch[$i] . "\"];";
			}
			print FH "\n\tsubgraph \"cluster_" . $mySwitch[0] . "\" { label=\"" . $mySwitch[2] . "\"; " . $mySwitch[0] . ";}";
			@myGoto   =();
			@mySwitch =();
		}

		if($line =~ /:C:/){
	#		print "\n Case Node";
			print FH "\n\t" . $myTokens[0] ." [shape=diamond]";
			print FH "\n\t" . $myTokens[0] . " -> " . $myTokens[3] . " [label=\"\"];";
			print FH "\n\t" . $myTokens[0] . " -> " . $myTokens[4] . " [label=\"\"];";
			print FH "\n\tsubgraph \"cluster_" . $myTokens[0] . "\" { label=\"" . $myTokens[2] . "\"; " . $myTokens[0] . "; }";
		}

		if($line =~ /:P:/){
	#		print "\n Process Node";
			print FH "\n\t" . $myTokens[0] . " [shape=circle]";
			print FH "\n\t" . $myTokens[0] . " -> " . $myTokens[3] . " [label=\"" . $myTokens[2] . "\"];";
		}

		if($line =~ /^X/){
	#		print "\n Exit Node";

			print FH "\n\t" . $myTokens[0] . " [shape=Msquare]";
			print FH "\n\tsubgraph \"cluster_" . $myTokens[0] . "\" { label=\"" . $myTokens[2] . "\"; " . $myTokens[0] . "; }";
			print FH "\n}";
		}
	}

	close (MYFILE);
	close(FH);

	return $dotFileName;
}

sub readInput{
	my $filename = shift;
	open(RH,$filename);
	while(<RH>){
		chomp;
		if($_ =~ /\s*(.*) -> (.*) \[/ || $_ =~ /\s*(.*) -> (.*);/){
			push @{$graph{$1}},$2;
		}
	}
	close(RH);
}

sub readText{
	my $filename = shift;
	open(RH,$filename);
	while(<RH>){
		chomp;
		if($_ =~ /(.*?):.:(.*?):/){
			$listHash{$1} = $2;
		}
	}
	close(RH);
}

sub FindLoops {
	my @path=@_;
	my $last=$path[-1];
	my $flag;
	my %elements = ( );
	for my $next (@{$graph{$last}}) {
	#	print join (",",@path,$stop),"\n";
		$flag = 0;
		if($next ~~ @path){

			%elements = ( );

			foreach (@path) {
				$elements{$_}++;
			}

			foreach (keys %elements) {
			#	print "\n $_ => " . $elements{$_};
			#	sleep(1);
				$flag = 1 if $elements{$_} > 1;
			}
			if($flag == 1){
				$flag = 0;
				next;
			}

		}
		# next if grep {$_ eq $next } @path;
		if ($next eq $stop){
			open(TF,">>TestCaseLoop_" . $caseNum . ".csv");
			my $str = join ("->",@path,$stop);
			my @strArray = split(/->/,$str);
			my $i = 0;
#			print "\n";
			for($i=0;$i<=$#strArray;$i++){
#				my $testCase = $strArray[$i] . " ( " . $listHash{$strArray[$i]} . " ) -> ";
				my $testCase = "\"" . $strArray[$i] . " ( " . $listHash{$strArray[$i]} . " ) \",";
				$testCase =~ s/\\l/\n/g;
#				print $1 if($testCase =~ /(.*?)-/);
#				print $testCase;
				print TF $testCase;
			}
			print TF "\n\n";
			close(TF);
			# if only node path is needed
#			print "\n\n";
			open(BC,">>branch.txt");
			print join ("->",@path,$stop),"\n";

			print BC join (":",@path,$stop),"\n";
			close(BC);

#			print join ("->",@path,$stop),"\n";
#			sleep(1);
		}
		else {
			FindLoops(@path,$next);
		}
	}
}

sub FindAllPaths {

	my @path=@_;
	my $last=$path[-1];
	for my $next (@{$graph{$last}}) {
		next if $next ~~ @path;
		# next if grep {$_ eq $next } @path;
		if ($next eq $stop){
			open(TF,">>TestCaseNoLoop_" . $caseNum . ".csv");
			my $str = join ("->",@path,$stop);
			my @strArray = split(/->/,$str);
			my $i = 0;
			print "\n";
			for($i=0;$i<=$#strArray;$i++){
				my $testCase = "\"" . $strArray[$i] . " ( " . $listHash{$strArray[$i]} . " ) \",";
				$testCase =~ s/\\l/\n/g;
				print $testCase;
				print TF $testCase;
			}
			print TF "\n\n";
			close(TF);
			#sleep(1);
		}
		else {
			FindAllPaths(@path,$next);
		}
	}
}

sub branchCoverage{
	# get branch coverage
	my $imgCase = 0;
	my $newImgFile;
	my @myArray = ();
	foreach(keys %graph){
		my $last = $_;
	#	print "\n" . $last . " => " . $graph{$last};
		for my $next (@{$graph{$last}}) {
	#		print "\n" . $last . ":" . $next;
			push(@myArray,$last . ":" . $next);
		}
	}

	my %listHash1 = ();
	foreach(@myArray) {
		$listHash1{$_} = 1;
	#	print "\n" . $_ . " ====>>>> " . $listHash1{$_};
	}
	print "\n Branch Coverage\n";
	my @doneArray = ();
	my $flag;
	my $color;
	open(BC,"branch.txt");
	while(<BC>){
		my $line = $_;
		chomp($line);
		$flag = 0;
		@doneArray = split(/:/,$line);
		for(my $i=0;$i<$#doneArray;$i++){
			$flag |= $listHash1{$doneArray[$i] . ":" . $doneArray[$i+1]};
			print "\n$i   " . $doneArray[$i] . ":" . $doneArray[$i+1] . " -> " . $listHash1{$doneArray[$i] . ":" . $doneArray[$i+1]};
			$listHash1{$doneArray[$i] . ":" . $doneArray[$i+1]} = 0;
		}
		if($flag == 1 || $graphFlag eq "ALL"){
			$line =~ s/:/->/g;
			print "\n" . $line;
			open(DOT,"$dotFile");
			$newImgFile = "MyGraph_" . $imgCase++;
			open(NEWDOT,">" . $newImgFile . ".dot");
			while(<DOT>){
				print NEWDOT $_ if $_ ne "}";
			}
			close(DOT);

			if("PASS" ~~ @doneArray){
				$color = "green";
			}
			else{
				$color = "red";
			}

			for(my $i=0;$i<$#doneArray;$i++){
				print NEWDOT "\n\t" .$doneArray[$i] . "[color=\"" . $color . "\"]";
				print NEWDOT "\n\t" . $doneArray[$i] . "->" . $doneArray[$i+1] . " [color=\"" . $color . "\"]";
			}

			print NEWDOT "\n\tX [color=\"" . $color . "\"]";
			print NEWDOT "\n}\n\n digraph G1{";

			#die;
			my $newStr = $line;
			$newStr =~ s/-/_-/g;
			$newStr .= "_";
			print NEWDOT "\n\t$newStr\n}";
			close(NEWDOT);
			system("dot $newImgFile.dot | gvpack -array_u | neato -Tpng -n2 -o $newImgFile.png");
			unlink($newImgFile . ".dot") if $debugFalg ne "DEBUG";
			open(TF,">>TestCaseAllBr_" . $caseNum . ".csv");
			my @strArray = split(/->/,$line);
			my $i = 0;
	#		print "\n\n";
			print TF "\n\n";

			for($i=0;$i<=$#strArray;$i++){
				my $testCase = "\"" . $strArray[$i] . " ( " . $listHash{$strArray[$i]} . " ) \",";
				$testCase =~ s/\\l/\n/g;
	#				print $1 if($testCase =~ /(.*?)-/);
	#			print $testCase;
				print TF $testCase;

			}
			close(TF);

		}
	}
	close(BC);
	unlink("branch.txt") if $debugFalg ne "DEBUG";
}

# 1. Part 1 : Read input file and create dot file.

if($#ARGV < 2){
	print "\n Usage:\nperl coco.pl <input filename> <dot filename> <png filename>";
	exit(0);
}

print "\nCreating DOT file.....";
CreateDotFile($inputFile,$dotFile);
#sleep(1);
print "\nSuccess : DOT file created.....";

# 2. create a png file from the dot file
print "\n\nCreating PNG file.....";
system("dot -Tpng $dotFile -o $pngFile");
sleep(1);
print "\nSuccess : PNG file created.....";

# 3. Part 2 : Search for all possible path avoiding all the loops. Happy path coverage, all nodes shall be touched.
print "\n\nReading DOT file.....";
readInput($dotFile);
readText($inputFile);

print "\n\nSearching all possible loops.....\n";

FindLoops($start);

print "\n\nProcessing paths.....\n";
FindAllPaths($start);
branchCoverage();
unlink($dotFile) if $debugFalg ne "DEBUG";
