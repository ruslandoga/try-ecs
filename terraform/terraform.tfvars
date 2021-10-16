# Set this to `true` and do a `terraform apply` to spin up a bastion host
# and when you are done, set it to `false` and do another `terraform apply`
# once bastion is deployed you can
# > ssh -i ~/.ssh/<ssh-key>.pem -J ubuntu@<bastion-public-ip> ec2-user@<private-ip>
# > ssh -i ~/.ssh/since.pem -J ubuntu@13.49.70.122 ec2-user@10.0.3.158
bastion_enabled = true

# My SSH keyname (without the .pem extension)
ssh_key = "since"

# The IP of my computer. Do a `curl -sq icanhazip.com` to get it
# or add export TF_VAR_myip="[\"$(curl -sq icanhazip.com)/32\"]" to .envrc (needs direnv) to avoid hard-coding
myip = ["95.25.207.42/32"]

# docker image to deploy
docker_image = "ruslandoga/test-ecs:19"
