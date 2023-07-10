FROM debian:bullseye-slim

MAINTAINER Sébastien Delafond <sdelafond@gmail.com>

ARG PROTONMAIL_BRIDGE_VERSION
ARG SMTP_PORT
ARG IMAP_PORT

ENV PROTONMAIL_BRIDGE_FILE=protonmail-bridge_${PROTONMAIL_BRIDGE_VERSION}_amd64.deb
ENV USER=protonmail
ENV DEBIAN_FRONTEND=noninteractive

# install packages
COPY ./${PROTONMAIL_BRIDGE_FILE} .
RUN apt-get update -q && \
    apt-get install --no-install-recommends --no-install-suggests --yes \
        ./${PROTONMAIL_BRIDGE_FILE} \
	ca-certificates \
 	pass \
        procps \
 	socat \
 	libcap2-bin && \
    apt-get clean && \
    rm ${PROTONMAIL_BRIDGE_FILE}

RUN setcap 'cap_net_bind_service=+ep' /usr/bin/socat

# copy entrypoint and related files to dedicated user's home directory
RUN useradd -m -s /bin/bash ${USER}
COPY entrypoint.sh gpg-key-parameters.txt /home/${USER}/
RUN chown -R ${USER}: /home/${USER}

# document which ports are exposed
EXPOSE ${SMTP_PORT}
EXPOSE ${IMAP_PORT}

# user, workdir, entrypoint
USER ${USER}
WORKDIR /home/${USER}
ENTRYPOINT ./entrypoint.sh
