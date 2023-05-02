# RSA key of size 4096 bits 
# This TLS resource creates our Key Pair. This will generate an Instant Key and make our codes more dynamic.
resource "tls_private_key" "us_teamkeypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Creation of path of our key in our local machine
resource "local_file" "keypair" {
  content         = tls_private_key.us_teamkeypair.private_key_pem
  filename        = "us-team-keypair.pem"
  file_permission = "600"
}

#Creation of Keypair
resource "aws_key_pair" "us_keypair" {
  key_name   = "usteam-keypair"
  public_key = tls_private_key.us_teamkeypair.public_key_openssh
}