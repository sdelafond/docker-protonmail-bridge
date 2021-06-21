#!/bin/bash

set -e

# constants
BRIDGE="protonmail-bridge --cli"
BRIDGE_IMAP_PORT="1143"
BRIDGE_SMTP_PORT="1025"
GPG_PARAMS="${HOME}/gpg-key-parameters.txt"
FIFO="/tmp/fifo"
# other variables are coming from the environment itself

# main
if ! [ -d ~/.gnupg ] ; then
  gpg --generate-key --batch ${GPG_PARAMS}
fi

if ! [ -d ~/.password-store ] ; then
  pass init "$(awk -F: '/^Name-Real/ {print $2}' ${GPG_PARAMS})"
fi

if ! [ -f ~/.cache/protonmail/bridge ] ; then
  echo -e "login\n${PROTONMAIL_LOGIN}\n${PROTONMAIL_PASSWORD}\n${PROTONMAIL_EXTRA_2FA}" | ${BRIDGE} ${BRIDGE_EXTRA_ARGS}
fi

if [ "${BRIDGE_SPLIT_ADDRESS_MODE}" = true ] ; then
  echo -e "change mode\nyes\n" | ${BRIDGE} ${BRIDGE_EXTRA_ARGS}
fi

# socat will make the connection appear to come from 127.0.0.1, since
# the ProtonMail Bridge expects that
socat TCP-LISTEN:${SMTP_PORT},fork TCP:127.0.0.1:${BRIDGE_SMTP_PORT} &
socat TCP-LISTEN:${IMAP_PORT},fork TCP:127.0.0.1:${BRIDGE_IMAP_PORT} &

# display account information, then keep stdin open
[ -e ${FIFO} ] || mkfifo ${FIFO}
{ echo info ; cat ${FIFO} ; } | ${BRIDGE} ${BRIDGE_EXTRA_ARGS}
