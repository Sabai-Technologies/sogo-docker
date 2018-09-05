FROM debian:stretch-slim

ENV \
    LC_ALL=C \
    LANG=C \
    DEBIAN_FRONTEND=noninteractive

COPY ["script", "/usr/local/bin/"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    mysql-client \
    apt-transport-https \
    ca-certificates \
    gnupg \
    dirmngr

RUN mkdir /usr/share/doc/sogo \
	&& touch /usr/share/doc/sogo/empty.sh \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-key 0x810273C4 \
	&& echo "deb http://packages.inverse.ca/SOGo/nightly/4/debian/ stretch stretch" > /etc/apt/sources.list.d/sogo.list \
	&& apt-get update && apt-get install -y --force-yes \
		sogo \
		sogo-activesync \
    && apt-get autoremove --purge \
    && wget -qO- $(wget -nv -qO- https://api.github.com/repos/jwilder/dockerize/releases/latest \
                | grep -E 'browser_.*dockerize-linux-amd64' | cut -d\" -f4) | tar xzv -C /usr/local/bin/ \
	&& rm -rf /var/lib/apt/lists/* /var/log/* /tmp/* /var/tmp/* \
	&& chmod o+x -R /usr/local/bin/

EXPOSE 20000

VOLUME /usr/lib/GNUstep/SOGo/WebServerResources

USER sogo

CMD ["start.sh"]
