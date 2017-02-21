FROM ubuntu:trusty

MAINTAINER Marcus Oliveira da Silva <marcus@gmail.com>

# Fetching the key that signs the CRAN packages
# Reference: http://cran.rstudio.com/bin/linux/ubuntu/README.html
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN apt-get update \
&&  apt-get install -y -q ca-certificates wget apt-utils apt-transport-https
RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

RUN apt-get update && apt-get install -y -q \
    r-base \
    r-base-dev \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libpq-dev \
    libssl-dev \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/*  \
    && rm -rf /var/lib/apt/lists/*

#Install essential r packages
RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='http://cran.us.r-project.org')"

#Download and install shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

#Install apps r packages
RUN R -e "install.packages(c('R.cache','ggplot2','plotly','scales','RPostgreSQL', 'R6'), repos='http://cran.us.r-project.org')"

EXPOSE 3838

ENV LANG pt_BR.UTF-8

#ADD features-diagnosis /srv/shiny-server/features-diagnosis.
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# shiny user is created by the Shiny Server package installed above
# Default shiny UID and GID
ENV SHINYUID 999
ENV SHINYGID 999

# Change the UID/GID of shiny user/group, ownership of files and start
RUN groupmod -g $SHINYGID shiny && \
    usermod -u $SHINYUID shiny && \
    chown -R $SHINYUID:$SHINYGID /home/shiny && \
    chown -R $SHINYUID:$SHINYGID /var/log/shiny-server && \
    chown -R $SHINYUID:$SHINYGID /srv/shiny-server && \

# shiny-server
CMD bash -lc 'shiny-server'
