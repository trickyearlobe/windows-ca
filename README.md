# windows-ca

Simple cookbook to issue certs to users in Windows AD.

It's a work in progress and things may change... in particular:-
* CA passwords need to move to a vault and we need to encrypt the CA key
* Passwords for user certs need to be random
* Serial numbers need more careful handling
* We need to support revocation lists
* We need to support re-issue of expiring certificates
* We may rely on an external mailer to enable queueing when things are down.

## Usage

Make a wrapper cookbook to supply configuration

    chef generate cookbook my_ca

Declare a dependency in `my_ca/metadata.rb`

    name 'my-ca'
    maintainer 'Richard Nixon'
    maintainer_email 'richard.nixon@btinternet.com'
    license 'apachev2'
    description 'Installs/Configures windows-ca'
    long_description 'Installs/Configures windows-ca'
    version '0.2.0'

Set configuration in `my_ca/attributes/default.rb`

    # The AD group we will use to determine who gets a certificate.
    default['windows-ca']['group'] = 'Ninjas'

    # The directories we're using
    default['windows-ca']['ca-dir']   = 'c:\ninja\ca'
    default['windows-ca']['cert-dir'] = 'c:\ninja\certs'

    # The CA cert and key
    default['windows-ca']['ca-key-file']  = 'ninjas.key'
    default['windows-ca']['ca-cert-file'] = 'ninjas.crt'

    # Stuff for Emailing links to end users
    default['windows-ca']['mail-relay']['port'] = 25
    default['windows-ca']['mail-relay']['encryption'] = :none
    default['windows-ca']['mail']['local-hostname'] = 'lu-tse.ninja.com'
    default['windows-ca']['mail']['use-relay'] = false # Route directly using MX records
    default['windows-ca']['url-base'] = 'https://lu-tse.ninja.com/dropbox/certs'

## Pull in the dependencies (this cookbook) and drop them on your Chef server

    cd my_ca
    berks install
    berks upload

## Add the wrapper cookbook to the CA server runlist

    knife node run_list add lu-tse.ninja.com 'recipe[my_ca]'
