#	core_to_phylo.pl
#	A pipeline to make phylogenies from BPGA cores
#	By Pablo Cruz-Morales


open FILE, $ARGV[0] or die "I cant read the inputfile\n";
open OUT, '>TEMP' or die "I cant save the  TEMP file\n";
#----------maiking fasta oneline-------
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
open TEMP, 'TEMP' or die "I cant read the inputfile\n";
while ($line2=<TEMP>){
	$line2=~/>(\d+)\/(\d+)\/\#(.+)/;
	$fam=$1;
	$org=$2;
	$seq=$3;
	open OUTFAM, ">>$fam.faa" or die "i cant print outfam file\n";
	print OUTFAM">$org\n$seq\n";
}

system 'rm TEMP';
close OUTFAM;
system 'ls *.faa >listfaa';
#------------------aligning-------------------
open LIST, 'listfaa' or die "I cant open the listfaa\n";
while ($listline=<LIST>){
chomp $listline;
system `muscle -in $listline -out $listline.aln`;
#----trimming-----
system `Gblocks $listline.aln -t p`;
system `mv $listline.aln-gb $listline.fas`;
system `rm $listline.aln`;
}


#--concatenating----
system `perl FASconCAT_v1.11.pl -s -n`;
#--clening-up----
system `rm *.faa *.htm *.faa.fas`;
system `rm listfaa`;
system `mv FcC_smatrix.fas SUPER_MATRIX.txt`;

#-----changing-indexes-to-species-names--#
open OUTMATRIX, '>SUPER_MATRIX.faa' or die "I cant write the SUPER_MATRIX.faa file\n";
open SMATRIX, 'SUPER_MATRIX.txt' or die "I cant read the SUPER_MATRIX.txt file\n";
while ($matline=<SMATRIX>){
	if ($matline=~/>/){
	$matline=~/(>)(\d+)/;
	$ID="$2";
	open DATASET, 'DATASET.xls' or die "I cant read the DATASET file\n";
		while ($datline=<DATASET>){
			if ($datline=~/Genome\_no\./){
			$dummy++;
			}
			else{	
			$datline=~/(\d+)\t(Organism\d+)\t(.+)/;
			$MATCH="$1";
			$SPECIE="$3";
			$SPECIE=~s/.fas//;
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


#------Constructing the phylogeny with IQtree------#
system 'iqtree -s SUPER_MATRIX.faa -spp SUPERMATRIX.partitions -m TEST -bb 10000';














