docker run --rm -i -v $PWD:/work -w /work \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REAGION=$AWS_DEFAULT_REAGION \
  hashicorp/terraform:0.12.5 "$@"
