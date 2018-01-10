# copyright 2017-2018 Regents of the University of California and the Broad Institute. All rights reserved.

FROM r-base:3.1.3

RUN mkdir /build
COPY sources.list /etc/apt/sources.list

RUN apt-get update && apt-get upgrade --yes && \
    apt-get install build-essential --yes && \
    apt-get install python-dev --yes && \
    apt-get install default-jre --yes && \
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py 

RUN pip install awscli 

RUN apt-get update && \
    apt-get install curl --yes
    
RUN apt-get install libxml2-dev --yes && \
    apt-get install libcurl4-gnutls-dev --yes && \
    apt-get install mesa-common-dev --yes && \
    apt-get install --yes libglu1-mesa-dev freeglut3-dev  bwidget

COPY common/container_scripts/runS3OnBatch.sh /usr/local/bin/runS3OnBatch.sh
COPY common/container_scripts/installPackages.R-2  /build/source/installPackages.R
COPY common/container_scripts/runLocal.sh /usr/local/bin/runLocal.sh
COPY Rprofile.gp.site ~/.Rprofile
COPY Rprofile.gp.site /usr/lib/R/etc/Rprofile.site
RUN chmod ugo+x /usr/local/bin/runS3OnBatch.sh

COPY Dockerfile /build/Dockerfile

ENV R_LIBS_S3=/genepattern-server/Rlibraries/R313/rlibs
ENV R_LIBS=/usr/local/lib/R/site-library
ENV R_HOME=/usr/local/lib64/R

COPY runS3Batch_prerun_custom.sh /usr/local/bin/runS3Batch_prerun_custom.sh
COPY runS3Batch_postrun_custom.sh /usr/local/bin/runS3Batch_postrun_custom.sh

 
CMD ["/usr/local/bin/runS3OnBatch.sh" ]

