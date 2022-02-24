# core_to_phylo.pl
A little pipeline that takes core_seq.txt and DATASET.xls files from BPGA 
The program splits the sequences in the core_seqfile by protein family, then, align (muscle), trim (Gblocks), filter out the aligments with no sequences after trimming. 

The processed aligmentes are then concatenated into a supermatrix (FasConCat),  which is labelled with the taxon names. The partition file for IQ tree is prepared and  then the supermatrix and the partition file are used to contruct a phylogeny (IQtree) with independent model per partitions.


***Dependecies:***

**muscle (aligner):**

https://www.drive5.com/muscle/
  Install like this (install in /bin):
  
      sudo apt-get install muscle

**GBlocks (trimmer):**

http://molevol.cmima.csic.es/castresana/Gblocks.html
http://molevol.cmima.csic.es/castresana/Gblocks/Gblocks_documentation.html#Installation
  
  Install like this (install in /bin):
  
    wget http://molevol.cmima.csic.es/castresana/Gblocks/Gblocks_Linux64_0.91b.tar.Z
    tar xvf Gblocks_Linux64_0.91b.tar.Z
    cd Gblocks_0.91b/
    sudo mv Gblocks /usr/bin/

**fastconcat** (Concatenation of alignments):
  Install like this (put it in the same folder as your inputs):
  
    wget https://github.com/PatrickKueck/FASconCAT/raw/master/FASconCAT_v1.11.pl
    
    
  
 ***Running this script***
 

    
    perl core_to_phylo.pl core_seq.txt DATASET.xls

Inputs are obtained from a succesful run of BPGA
https://iicb.res.in/bpga/

core_seq.txt is under /Sequences

DATASET.xls is undet /Supporting_files
    
    
   **Common issue:**
   You may have opened and saed the input files in windows or something other than a unix OS
   clean the files with dos2unix (sudo apt-get install dos2unix)
   
      dos2unix DATASET.xls
      dos2unix core_seq.txt
   
   Try again
   
   
   
    
