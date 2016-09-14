FROM ubuntu:16.04
MAINTAINER Danny Wells "danny@parkerici.org"

RUN apt-get update && \
     apt-get upgrade -y && \
     apt-get install -y python && \
     apt-get install -y python3-pip && \
     apt-get clean
     
RUN apt-get install -y wget curl unzip gcc python-dev python-setuptools emacs vim git less lynx 

RUN apt-get install -y hdfview zlib1g-dev libncurses5-dev libncursesw5-dev cmake tar gawk valgrind sed

RUN apt-get install -y python-numpy python-scipy python-matplotlib ipython ipython-notebook python-pandas python-sympy python-nose

RUN apt-get install -y build-essential hdf5-tools libhdf5-dev hdf5-helpers libhdf5-serial-dev apt-utils

RUN apt-get -y install libxml2-dev libcurl4-openssl-dev libssl-dev

#Install samtools
RUN	cd / && \
	wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 && \
	bunzip2 samtools-1.3.1.tar.bz2 && \
	tar -xvf samtools-1.3.1.tar && \
	cd samtools-1.3.1 && \
	make 



#Install bam-readcount
RUN cd / && \
	mkdir git && \
	cd git && \
	git clone --recursive git://github.com/genome/bam-readcount.git && \
	cd / && \
	mkdir bam-readcount && \
	cd bam-readcount && \
	cmake /git/bam-readcount && \
	make 



#Install STAR
RUN cd / && \
	wget https://github.com/alexdobin/STAR/archive/2.5.1b.tar.gz && \
	tar -zxvf 2.5.1b.tar.gz && \
	cd STAR-2.5.1b/source && \
	make STAR && \
	file STAR

#Install fastqc
RUN cd / && \
	wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip && \
	unzip fastqc_v0.11.5.zip && \
	cd FastQC/ && \
	chmod 755 fastqc 

#Need to get java also get R here too.
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:webupd8team/java \
    && echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | tee -a /etc/apt/sources.list \
    && gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 \
    && gpg -a --export E084DAB9 | apt-key add - \
    && apt-get update \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections \
    && apt-get install -y r-base r-base-dev oracle-java8-installer


#Install picard
RUN cd / && \
	wget https://github.com/broadinstitute/picard/releases/download/1.140/picard-tools-1.140.zip -O picard-tools-1.140.zip && \
	unzip picard-tools-1.140.zip 

# Install kallisto
RUN cd / && \
	git clone https://github.com/pachterlab/kallisto.git && \
	cd kallisto && \
	mkdir build && \ 
	cd build && \
	cmake .. && \ 
	make && \ 
	make install


# # Install scala, which is needed for cromwell.
# RUN wget http://www.scala-lang.org/files/archive/scala-2.11.7.deb && \
#     wget http://dl.bintray.com/sbt/debian/sbt-0.13.9.deb && \
#     dpkg -i scala-2.11.7.deb && \
#     dpkg -i sbt-0.13.9.deb && \
#     apt-get update && \
#     apt-get install -y scala sbt && \
#     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /*.deb && \
#     echo "exit" | sbt 

#Get various R packages needed from RNA-seq analysis
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "source('http://bioconductor.org/biocLite.R'); biocLite('devtools')"
RUN Rscript -e "source('http://bioconductor.org/biocLite.R'); biocLite('pachterlab/sleuth')"
RUN Rscript -e 'install.packages(c("ROCR", "ggplot2"))'
#, "Hmisc", "reshape", "gplots","stringr", "NMF", "mixtools", "lars", "reshape2", "vioplot","fastICA", "tsne", "Rtsne", "fpc", "ape", "VGAM", "gdata", "knitr","useful", "jackstraw","Rtsne", "gridExtra","XLConnect"))'
RUN Rscript -e 'install.packages("~/Downloads/Seurat_1.1.tar.gz",type="source",repos=NULL)'
RUN Rscript -e 'source("https://bioconductor.org/biocLite.R");biocLite("scde")'
RUN Rscript -e 'source("https://bioconductor.org/biocLite.R"); biocLite("devtools"); biocLite("YosefLab/scone", dependencies=TRUE)'

# #Get cromwell.
# RUN  cd / && \
#     git clone https://github.com/broadinstitute/cromwell.git && \
#     cd cromwell && \
#     sbt assembly

#Sortmerna
RUN cd / && \
	git clone https://github.com/biocore/sortmerna && \
	cd sortmerna && \
	./build.sh

#trimmomatic
RUN cd / && \
	git clone https://github.com/timflutre/trimmomatic.git && \
	cd trimmomatic && \
	make INSTALL="/" && \
	make check && \
	make install && \
	mv /root/bin/trimmomatic.jar /trimmomatic
	
#samstat
RUN echo $PATH && \ 
	cd / && \
	wget http://downloads.sourceforge.net/project/samstat/samstat-1.5.1.tar.gz && \
	tar -xzvf samstat-1.5.1.tar.gz && \
	cd samstat-1.5.1 && \
	ls /samtools-1.3.1 && \
	sed -i '2847s/.*/SAMTOOLS=samtools/' configure && \
	./configure && \
	make 

#HTSeq
RUN cd / && \
	wget https://pypi.python.org/packages/source/H/HTSeq/HTSeq-0.6.1p1.tar.gz && \
	tar -zxvf HTSeq-0.6.1p1.tar.gz && \
	cd HTSeq-0.6.1p1/ && \
	python setup.py install --user && \
	chmod +x scripts/htseq-count 

#BackSPIN
RUN cd / && \
	wget https://github.com/linnarsson-lab/BackSPIN/archive/v1.0.tar.gz && \
	tar -zxvf v1.0.tar.gz && \
	cd BackSPIN-1.0 && \
	chmod uga+x backSPIN.py

RUN cd / && \
	git clone https://github.com/lakigigar/scRNA-Seq-TCC-prep

RUN apt-get install -y python-sklearn

RUN cd / && rm *.gz *.tar *.zip
ENV PATH="/samtools-1.3.1:/bam-readcount/bin:/STAR-2.5.1b/source:/HTSeq-0.6.1p1/scripts:/FastQC:/picard-tools-1.140:/samstat-1.5.1/src:/kallisto:/sortmerna:/trimmomatic:/usr/local/bin:${PATH}"











