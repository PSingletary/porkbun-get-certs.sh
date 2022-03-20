
porkbun-get-certs.sh
====================

A simple script to fetch Let's Encrypt certificates using the
[Porkbun API](https://porkbun.com/api/json/v3/documentation).

Requisites
----------

This requires nothing but Bash for scripting, and jq for parsing JSON replies from the API.

This can be easily installed on Debian/Ubuntu using:
```bash
sudo apt-get install bash jq
```

Usage
-----

Example usage:
```bash
porkbun-get-certs.sh \
	-p pk1_0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef \
	-s sk1_fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210 \
	orca.pet
```

This will fetch the certificate chain and private keys for orca.pet, and put them into the
`/etc/ssl/porkbun` directory with proper security bits:
```
/etc/ssl/porkbun/orca.pet:
total 20
drwxr-xr-x 2 root root 4096 mar 20 23:27 .
drwxr-xr-x 4 root root 4096 mar 20 23:19 ..
-rw-r--r-- 1 root root 5938 mar 20 23:27 chain.pem
-rw------- 1 root root 3273 mar 20 23:27 private.pem
```

Multiple domains can be specified at once, and the default directory can be overriden as well:
```bash
porkbun-get-certs.sh \
	-p pk1_89abcdef0123456789abcdef0123456789abcdef0123456789abcdef01234567 \
	-s sk1_76543210fedcba9876543210fedcba9876543210fedcba9876543210fedcba98 \
	-d ~/.certs/
	example.com lugia.party
```

Is it safe?
-----------

You might be thinking: "is it safe to use a private key from an externally-generated source?".
The answer is: it depends.

If you can affort the luxury of using a paid certificate with extended validation, there's no
reason why to trust them to generate your private keys.

However, for DV certificates, think that:
  - Let's Encrypt uses nothing but DNS entries for checking ownership of a domain.
  - Porkbun could alter said DNS entries to ask LE for a new certificate with a key they control.
  - Porkbun could alter the A and AAAA entries to point to a server they control and MitM you
    without you ever realizing, since that new certificate would be also valid and trusted by
    your computer.

Hence, if you're already trusting them your DNS entries, you're already trusting them your
security.
