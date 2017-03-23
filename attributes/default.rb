# The group we will use to determine who gets a certificate.
# Note, we will also pull the eMail addresses from these user objects
default['windows-ca']['group'] = 'CitrixCertificateAuth'

# The certificate serial number will increment for each certificate issued
default['windows-ca']['next-serial'] = 2 if node['windows-ca']['next-serial'].nil?

# The directories we're using
default['windows-ca']['ca-dir']   = 'c:\windows-ca\cakeys'
default['windows-ca']['cert-dir'] = 'c:\windows-ca\certs'

# The CA cert and key
default['windows-ca']['ca-key-file']  = 'root_ca.key'
default['windows-ca']['ca-cert-file'] = 'root_ca.crt'

# Stuff for Emailing links to end users
# Port 25 was originally for unencrypted SMTP. It can now negotiate an upgrade to TLS
# Port 465 was assigned for 1 year by IETF for secure mail transport and then revoked. Its the most popular port.
# 587 is the correct port for secure SMTP but its not widely used (465 used instead)
default['windows-ca']['mail-relay']['port'] = 25
default['windows-ca']['mail-relay']['encryption'] = :start_tls # :start_tls, :ssl, :none
default['windows=ca']['mail-relay']['hostname'] = nil
default['windows-ca']['mail-relay']['account'] = nil
default['windows-ca']['mail-relay']['password'] = nil
default['windows-ca']['mail']['local-hostname'] = 'ca.mydomain.com'
default['windows-ca']['mail']['use-relay'] = false # If false, route directly using MX records
default['windows-ca']['url-base'] = 'https://ca.mydomain.com/dropbox/certs'
