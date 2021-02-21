FROM debian:buster-slim

ENV \
    LC_ALL=C \
    LANG=C \
    DEBIAN_FRONTEND=noninteractive

EXPOSE 80 20000

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    default-mysql-client \
    apt-transport-https \
    ca-certificates \
    gnupg \
    dirmngr

RUN mkdir /usr/share/doc/sogo \
        && touch /usr/share/doc/sogo/empty.sh \
        && gpg --keyserver hkp://keys.gnupg.net --recv-key 0x810273C4 \
        && gpg --armor --export 0x810273C4 | apt-key add - \
        && echo "deb http://packages.inverse.ca/SOGo/nightly/5/debian/ buster buster" > /etc/apt/sources.list.d/sogo.list \
        && apt-get update && apt-get install -y  \
		sogo \
		sogo-activesync \
    && apt-get autoremove --purge \
    && wget -qO- $(wget -nv -qO- https://api.github.com/repos/jwilder/dockerize/releases/latest \
                | grep -E 'browser_.*dockerize-linux-amd64' | cut -d\" -f4) | tar xzv -C /usr/local/bin/ \
	&& rm -rf /var/lib/apt/lists/* /var/log/* /tmp/* /var/tmp/* \
	&& chmod o+x -R /usr/local/bin/


COPY ["script", "/usr/local/bin/"]

CMD ["/usr/local/bin/start.sh"]
