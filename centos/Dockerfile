FROM centos:centos7.8.2003

ARG APISIX_VERSION=2.10.1.1
ARG APISIX_BASE_PKG=apisix-base-1.0.0-0.el7.x86_64.rpm
LABEL apisix_version="${APISIX_VERSION}"

RUN mkdir -p /app

COPY centos/install /app/install

RUN  yum install -y https://repos.apiseven.com/packages/centos/apache-apisix-repo-1.0-1.noarch.rpm \
	&& yum install -y /app/install/${APISIX_BASE_PKG} \
	&& yum install -y https://repos.apiseven.com/packages/centos/7/x86_64/apisix-$APISIX_VERSION-0.el7.x86_64.rpm \
	&& yum clean all \
	&& sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t60/g' /etc/login.defs

WORKDIR /usr/local/apisix

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /usr/local/apisix/logs/access.log \
    && ln -sf /dev/stderr /usr/local/apisix/logs/error.log

EXPOSE 9080 9443

CMD ["sh", "-c", "/usr/bin/apisix init && /usr/bin/apisix init_etcd && /usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'"]

