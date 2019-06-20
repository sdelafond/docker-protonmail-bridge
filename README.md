Run ProtonMail Bridge in a docker container

Usage
=====

Starting the service
--------------------

1. get the Debian package for the bridge from ProtonMail, and save it in
   the current directory

2. create your env file from the default one
```
cp default-env .env
```

3. edit .env to add your ProtonMail credentials; you can leave out
   PROTONMAIL_EXTRA_2FA blank: since that value depends on time, you'll
   instead want to specify it when running the service

4. start the service
```
PROTONMAIL_EXTRA_2FA=<code> docker-compose up
```

Configuring your email client
-----------------------------

For credentials, use the "Username: <login>" and "Password: <passwd>"
that the service prints when it start.

The URL for the IMAP service is `localhost:2043`, and the SMTP one is
`localhost:2025`.

Client compatibility
--------------------

The ProtonMail Bridge officially supports Thunderbird only, but using
offlineimap or fetchmail works just fine. Here's an example
.fetchmailrc:

```
set daemon 15

defaults
  fetchall
#  keep

poll 127.0.0.1 service 2043 with protocol imap auth password
  user <login> there is seb here
  password <passwd>
```

SSL certificates
================

SMTP
----

Full certificate information:
```
echo | openssl s_client -connect localhost:2025 -starttls smtp | openssl x509 -noout -text
```

Fingerprints:
```
echo | openssl s_client -connect localhost:2025 -starttls smtp | openssl x509 -noout -fingerprint -md5
echo | openssl s_client -connect localhost:2025 -starttls smtp | openssl x509 -noout -fingerprint -sha1
echo | openssl s_client -connect localhost:2025 -starttls smtp | openssl x509 -noout -fingerprint -sha256
[...]
```

IMAP
----

Full certificate information:
```
echo | openssl s_client -connect localhost:2043 -starttls imap | openssl x509 -noout -text
```

Fingerprints:
```
echo | openssl s_client -connect localhost:2043 -starttls imap | openssl x509 -noout -fingerprint -md5
echo | openssl s_client -connect localhost:2043 -starttls imap | openssl x509 -noout -fingerprint -sha1
echo | openssl s_client -connect localhost:2043 -starttls imap | openssl x509 -noout -fingerprint -sha256
[...]
```


Credits
=======

Thanks to Hendrik Meyer for socat+setcap workaround described at
https://gitlab.com/T4cC0re/protonmail-bridge-docker
