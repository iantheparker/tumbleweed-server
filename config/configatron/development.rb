# Override your default settings for the Development environment here.
# 
# Example:
#   configatron.file.storage = :local
configatron.apn.passphrase='tweed'
configatron.apn.feedback.passphrase='tweed'
configatron.apn.host # => 'gateway.sandbox.push.apple.com'
configatron.apn.cert=File.join(Rails.root.to_s,"config","ck.pem")
configatron.apn.feedback.cert=File.join(Rails.root.to_s,"config","ck.pem")
