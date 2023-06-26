print "# Core_to_phylo.pl                                                               #\n";
print "# A pipeline to make phylogenies from BPGA cores                                 #\n";
print "# By Pablo Cruz-Morales                                                          #\n";
print "# pcruzm\@biosustain.dtu.dk							#\n";
print "# usage: perl core_to_phylo.pl < BPGA core_seq.txt file> <BPGA DATASET.xls file> #\n\n";
print "https\:\/\/github.com\/pablo-genomes-to-vials-cruz\/core_to_phylo.pl\/blob\/main\/core-seq-split.pl\n\n";

print "Eliminating files from previous runs\n";
system 'rm  SUPER* 2> /dev/null';
system 'rm  *.faa 2> /dev/null';
system 'rm  *.fas 2> /dev/null';
system 'rm  FcC_info.xls 2> /dev/null';
system 'rm  FcC_smatrix.nex 2> /dev/null';
system 'rm  *.htm 2> /dev/null';
system 'rm  *listfaa 2> /dev/null';

open FILE, $ARGV[0] or die "I cant read the core_seq.txt input file\n";
open OUT, '>TEMP' or die "I cant save the  TEMP file\n";
#----------making fasta oneline-------
print "Formating the  input\n";
while ($line=<FILE>){
	if ($line=~/>/){
	$line=~s/Org\d+\_Gene\d+//;
	$line=~s/core\///;
	$line=~s/\n/#/;
	}
	print OUT $line;
}
close OUT;
#---------splitting by family---------------
print "Splitting the core into protein families\n";
open TEMP, 'TEMP' or die "I cant read the inputfile\n";
while ($line2=<TEMP>){
	$line2=~/>(\d+)\/(\d+)\/\#(.+)/;
	$fam=$1;
	$org=$2;
	$seq=$3;
	open OUTFAM, ">>$fam.faa" or die "I cant print outfam file\n";
	print OUTFAM">$org\n$seq\n";
}

system 'rm TEMP';
close OUTFAM;
system 'ls *.faa >listfaa';
#------------------aligning-------------------
print "Alingning a lot of sequences\n\n";
open LIST, 'listfaa' or die "I cant open the listfaa\n";
while ($listline=<LIST>){
chomp $listline;
print "Aligning sequences in protein family: $listline\t";
system `muscle -in $listline -out $listline.aln -quiet`;
#----trimming-----
print "Trimming alignment for protein family: $listline \n";
system `Gblocks $listline.aln -t p`;
system `mv $listline.aln-gb $listline.fas`;
system `rm $listline.aln`;
}

#---some alignments are empty after trimming-----#
#---eliminating empty alignents after trimming---#

system 'grep "(0%" *.htm > EMPTYLIST';
open EMPTY, 'EMPTYLIST' or die "I cant open the list of empty alignments\n";
while ($empty=<EMPTY>){
$empty=~/(\d+)(\.faa.+)/;
print "No useful data left after trimming family $1, eliminating it from the matrix\n";
system `rm $1\.faa.fas`;
} 

#--concatenating----
#you neeed FasConCat for this step, get it here:
#https://github.com/PatrickKueck/FASconCAT/raw/master/FASconCAT_v1.11.pl

print "Concatenating the trimmed aligments\n";
system `perl FASconCAT_v1.11.pl -s -n`;
#--cleaning-up----
print "Cleaning up\n";
system `rm *.faa *.htm *.faa.fas`;
system `rm listfaa`;
system `mv FcC_smatrix.fas SUPER_MATRIX.txt`;

#-----changing-indexes-to-species-names--#
print "Naming the sequences in the concatenated supermatrix\n";
open OUTMATRIX, '>SUPER_MATRIX.faa' or die "I cant write the SUPER_MATRIX.faa file\n";
open SMATRIX, 'SUPER_MATRIX.txt' or die "I cant read the SUPER_MATRIX.txt file\n";
while ($matline=<SMATRIX>){
	if ($matline=~/>/){
	$matline=~/(>)(\d+)/;
	$ID="$2";
	open DATASET, $ARGV[1] or die "I cant read the DATASET.xls file\n";
		while ($datline=<DATASET>){
			if ($datline=~/Genome\_no\./){
			$dummy++;
			}
			else{	
			$datline=~/(\d+)\t(Organism\d+)\t(.+)/;
			$MATCH="$1";
			$SPECIE="$3";
			$SPECIE=~s/.fas//;
			$SPECIE=~s/.faa//;
			$SPECIE=~s/ /_/;
				if ($ID==$MATCH){		
				print  OUTMATRIX ">$SPECIE\n";
				}
			}
		}
	}
	else{
	print OUTMATRIX $matline;
	}
}

print "Supermatrix created!\n";
#-----Making a partitions index file----#

open CONCAT_FILE, 'FcC_info.xls' or die "I cant read the CONCAT_INFO file\n";
open PARTITIONS, '>SUPERMATRIX.partitions' or die "I can't write the partitions file\n";

$cont="0";
while ($catline=<CONCAT_FILE>){
        if ($catline=~/\.faa\.fas/){
        $catline=~/(.+.faa.fas)\t(\d+)\t(\d+)\t(\d+\s+\=\>\s+\d+)\t(.+)/;
        $cont++;
        $coordinate="$4";
        $coordinate=~s/\=\>/-/;
        print PARTITIONS "PROTEIN, $cont \= $coordinate\n";
        }
        if ($catline=~/FcC_/){
        $dummy="1";
        }
}

print "Partitions file created! \n";
#------Constructing the phylogeny with IQtree------#
print "Building the phylogeny\n\n";
system 'iqtree2 -s SUPER_MATRIX.faa -spp SUPERMATRIX.partitions -m TEST -bb 10000';
print "All done\n\n";
