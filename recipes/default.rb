#
# Cookbook:: windows-ca
# Recipe:: default
#
# Copyright:: 2017, Richard Nixon
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[ node['windows-ca']['ca-dir'], node['windows-ca']['cert-dir']].each do |dirname|
  directory dirname do
    recursive true
  end
end

# Drop the filenames in a variable - purely to make the code more readable
ca_key_file  = File.join( node['windows-ca']['ca-dir'], node['windows-ca']['ca-key-file']  )
ca_cert_file = File.join( node['windows-ca']['ca-dir'], node['windows-ca']['ca-cert-file'] )

# Read in the CA key and certificate
ca_private_key = OpenSSL::PKey::RSA.new(File.read(ca_key_file))
ca_certificate = OpenSSL::X509::Certificate.new(File.read(ca_cert_file))

# Get list of users from a Windows AD group and iterate over them
group_members(node['windows-ca']['group']).each do |name,details|

  ### Make sure we have a unique private private key for each user
  user_private_key = OpenSSL::PKey::RSA.new(2048)

  # This generates the basic certificate
  cert = OpenSSL::X509::Certificate.new()
  cert.version = 2
  cert.serial = node['windows-ca']['next-serial']
  cert.subject = OpenSSL::X509::Name.parse "/CN=#{name}/emailAddress=#{details['EmailAddress']}"
  cert.issuer = ca_certificate.subject # root CA is the issuer
  cert.public_key = user_private_key.public_key
  cert.not_before = Time.now
  cert.not_after = cert.not_before + 1 * 365 * 24 * 60 * 60 # 1 years validity

  # Add some usage and identifier extensions to the certificate
  ef = OpenSSL::X509::ExtensionFactory.new
  ef.subject_certificate = cert
  ef.issuer_certificate = ca_certificate
  cert.add_extension(ef.create_extension("keyUsage","digitalSignature", true))
  cert.add_extension(ef.create_extension("keyUsage","keyEncipherment", true))
  cert.add_extension(ef.create_extension("extendedKeyUsage","clientAuth", true))
  cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))

  # And sign the certificate with the CA private key
  cert.sign(ca_private_key, OpenSSL::Digest::SHA256.new)

  # Instantiate a password protected PKCS12 container to hold the cert and key
  user_pkcs12 = OpenSSL::PKCS12.create(
    "abc123",                       # PKCS passphrase
    "Citrix auth cert for #{name}", # Friendly name
    user_private_key,               # The users key
    cert                            # The user's cert
  )

  ruby_block "Increment the CA serial number" do
    block do
      node.normal['windows-ca']['next-serial'] = node['windows-ca']['next-serial'] +1
      node.save
    end
    action :nothing
  end

  # Write out the PKCS12 container to a PFX file (Windows likes those)
  file "c:\\windows-ca\\certs\\#{name}.pfx" do
    content user_pkcs12.to_der
    action :create_if_missing
    notifies :run, 'ruby_block[Increment the CA serial number]', :immediately
  end

  # Also write the cert (with no key) in pem format for debugging purposes
  file "c:\\windows-ca\\certs\\#{name}.crt" do
    content cert.to_s
    sensitive true
    action :create_if_missing
  end

end
