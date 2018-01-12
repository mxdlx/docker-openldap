FROM centos:7
MAINTAINER aaraujo@protonmail.ch

# Devel dependencies
RUN yum groupinstall -y "Development Tools"
RUN yum install -y kernel-devel

# OpenLDAP dependencies
RUN yum install -y libdb-devel openssl-devel git

# Clone, configure, install (static modules setup) 
WORKDIR /usr/src
RUN git clone https://github.com/openldap/openldap

RUN cd openldap && ./configure --prefix=/opt/openldap \
                               --enable-debug \
			       --enable-syslog \
			       --enable-slapd \
			       --enable-rewrite \
			       --enable-ldap \
			       --enable-mdb \
			       --enable-meta \
			       --enable-monitor \
			       --enable-relay \
			       --enable-overlays \
    && make && make depend && make install

# Customize install with common install directory structure
# --NO SCHEMAS-- are loaded by default, must be ldapadd-ed from files/schemas/*.ldif
RUN rm -f /opt/openldap/etc/openldap/*.default && \
    rm -f /opt/openldap/etc/openldap/slapd.*

COPY files/slapd.d /opt/openldap/etc/openldap/slapd.d

EXPOSE 389
