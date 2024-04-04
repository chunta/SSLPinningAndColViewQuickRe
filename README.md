Make sure convert the .pem from server to .der for iOS client<br>
https://www.swiftanytime.com/blog/ssl-pinning-in-ios-application

搞懂 IP、FQDN、DNS、Name Server<br>
https://its-okay.medium.com/%E6%90%9E%E6%87%82-ip-fqdn-dns-name-server-%E9%BC%A0%E5%B9%B4%E5%85%A8%E9%A6%AC%E9%90%B5%E4%BA%BA%E6%8C%91%E6%88%B0-05-aa60f45496fb

以下是用來從cert提煉public key<br>
openssl x509 -inform der -in cert.der -pubkey -noout > certificate_public_key.pem

以下是用來產生public key的hashcode<br>
cat certificate_public_key.pem | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
