FROM ubuntu:16.04

# Add the PostgreSQL PGP key to verify their Debian packages.
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install packages
RUN apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

# Set init.sql
ADD init /root
RUN mv /root/postgresql_table_init.sql /var/lib/postgresql/init.sql

# Run init.sql
USER postgres
WORKDIR /var/lib/postgresql
RUN /etc/init.d/postgresql start \
    && psql --command "CREATE USER griffin WITH SUPERUSER PASSWORD '123456';" \
    && createdb -O griffin quartz \
    && echo "localhost:5432:quartz:griffin:123456" > .pgpass && chmod 600 .pgpass \
    && psql -p 5432 -h localhost -U griffin -f init.sql quartz

# Enable remote connections to the database
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf

# Add listen_addresses
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Set the default command
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]