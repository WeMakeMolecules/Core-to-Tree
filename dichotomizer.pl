# dichotomizer.pl
# a simle script that produces an occurence table for protein homologs
# the database is a set of blast-formatted proteomes (.fas files) 
# for queries it reads files with numbers (1-Z) as names files have the extension .query
# it performs a blast search where the score cut off is set defined by query length
# by pcruzm@biosustain.dtu.dk 25-oct-23
# the output is a table with n rows and Z columns, 1=found 0=not found 

#reading a directory
@FILES=`ls *.fas`;
foreach(@FILES){
	chomp $_;
	$cont=0;
	print "\n$_\t";
	#blasting the queries $cont on the genome $_
	while ($cont < 597){
		$cont++;
		#extracting protein length
		$seq_len=`grep ">" -v $cont.query |wc -c`;
		#the score cut off  is defined for a given $seq_len 
		if ($seq_len > 6000){
			$score_cutoff=4000;
			}
		if ( 5000<= $seq_len <= 5999){
			$score_cutoff= 3000;
		}
		if ( 3000<= $seq_len <= 4999){
			$score_cutoff= 2500;
		}
		if ( 2000<= $seq_len <= 2999){
			$score_cutoff= 2000;
		}
		if ( 1000<= $seq_len <= 1999){
			$score_cutoff= 1000;
		}
		if (  700<= $seq_len <= 999 ){
			$score_cutoff= 500 ;
		}
		if (  500<= $seq_len <= 699 ){
			$score_cutoff= 500 ;
		}
		if (  300<= $seq_len <= 499 ){
			$score_cutoff= 300 ;
		}
		if (  200<= $seq_len <= 299 ){
			$score_cutoff= 200 ;
		}
		if (  100<= $seq_len <= 199 ){
			$score_cutoff= 150 ;
		}
		if (   50<= $seq_len <= 99  ){
			$score_cutoff= 100 ;
		}
		if ($seq_len < 49){
			$score_cutoff=50;
		}																
		$search=`blastp -query $cont.query -db $_ -evalue 0.000001 -outfmt 6 -max_target_seqs 1  2\>\/dev\/null |awk '(\$12 \> $score_cutoff)'|cut -f 2`;
		if ($search=~/peg/){
			print "1\t";
		}
		else {
			print "0\t";
		}
	}
}#foreach files
