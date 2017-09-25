FROM registry.access.redhat.com/rhel7

LABEL name="microsoft/mssql-server-linux" \
      vendor="Microsoft" \
      version="14.0" \
      release="1" \
      summary="MS SQL Server Developer Edition" \
      description="MS SQL Server is ....." \
### Required labels above - recommended below
      url="https://www.microsoft.com/en-us/sql-server/" \
      run='docker run --name ${NAME} \
        -e ACCEPT_EULA=Y -e SA_PASSWORD=yourStrong@Password \
        -p 1433:1433 \
        -d  ${IMAGE}' \
      io.k8s.description="MS SQL Server is ....." \
      io.k8s.display-name="MS SQL Server Developer Edition"

# Install latest mssql-server package
RUN REPOLIST=rhel-7-server-rpms,rhel-7-server-optional-rpms,packages-microsoft-com-mssql-server,packages-microsoft-com-prod && \
    curl https://packages.microsoft.com/config/rhel/7/mssql-server.repo > /etc/yum.repos.d/mssql-server.repo && \
    curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/msprod.repo && \
    ACCEPT_EULA=Y yum install --disablerepo "*" --enablerepo ${REPOLIST} --setopt=tsflags=nodocs -y mssql-server mssql-tools unixODBC-devel && \
    yum clean all

ENV PATH=${PATH}:/opt/mssql/bin:/opt/mssql-tools/bin

# Default SQL Server TCP/Port
EXPOSE 1433

VOLUME /var/opt/mssql

COPY demo ./demo
COPY sudo /opt/mssql-tools/bin

RUN /opt/mssql/bin/mssql-conf setup  --accept-eula
# Run SQL Server process
#cmd tail -f /dev/null
CMD sqlservr --accept-eula
