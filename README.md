# AWS Bastion Host

Solution for the [roadmap.sh Bastion Host project](https://roadmap.sh/projects/bastion-host).

This project creates a hardened public SSH gateway and a private EC2 server with Terraform. The private server has no public IP and accepts SSH only from the bastion security group.

## Architecture

```text
Trusted administrator /32
          |
       SSH 22
          v
  Bastion EC2 (public subnet)
          |
       SSH 22
          v
  Private EC2 (private subnet, no public IP)
```

The private subnet has no route to an internet gateway. AWS security group references enforce the bastion-only SSH path without depending on changing instance IP addresses.

## Security controls

- Bastion SSH is restricted to one trusted `/32` address.
- Private SSH ingress references only the bastion security group.
- Password, keyboard-interactive, and root SSH logins are disabled.
- SSH agent forwarding and X11 forwarding are disabled on the bastion.
- IMDSv2 is required and both root volumes are encrypted.
- `fail2ban` monitors and blocks repeated SSH failures on the bastion.
- Terraform state, variable files, private keys, and real IP addresses are ignored by Git.

## Deploy

Prerequisites: Terraform, AWS credentials, and an existing SSH key pair.

```bash
terraform init
terraform plan \
  -var='admin_cidr=YOUR_PUBLIC_IP/32' \
  -var="public_key=$(cat ~/.ssh/id_ed25519.pub)"
terraform apply \
  -var='admin_cidr=YOUR_PUBLIC_IP/32' \
  -var="public_key=$(cat ~/.ssh/id_ed25519.pub)"
```

Use `terraform output -raw ssh_config` to generate the two host entries, save them in `~/.ssh/config`, and update the `IdentityFile` path if needed.

## Connect

```bash
# Gateway only
ssh bastion

# Direct command that automatically jumps through the gateway
ssh private-server

# Equivalent command without SSH config
ssh -J ubuntu@BASTION_PUBLIC_IP ubuntu@PRIVATE_SERVER_IP
```

The local client authenticates separately to each host. The private key is never copied to the bastion.

## Verify isolation

```bash
# Shows that the private instance has no public address
terraform state show aws_instance.private_server

# Confirms the actual connection traversed the bastion
ssh -J ubuntu@BASTION_PUBLIC_IP ubuntu@PRIVATE_SERVER_IP hostname

# Check SSH protection on the bastion
ssh bastion 'sudo fail2ban-client status sshd'
```

## Cleanup

```bash
terraform destroy \
  -var='admin_cidr=YOUR_PUBLIC_IP/32' \
  -var="public_key=$(cat ~/.ssh/id_ed25519.pub)"
```

## Repository

https://github.com/Ravshan04/bastion-host
