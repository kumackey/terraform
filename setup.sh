brew install git-secrets
git secrets --register-aws --global
git secrets --install "$HOME/.git-templates/git-secrets"
git config --global init.templatedir "$HOME/.git-templates/git-secrets"

docker pull hashicorp/terraform:0.12.5

echo 'DONE👍'
