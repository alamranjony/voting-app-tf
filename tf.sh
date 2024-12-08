# if there are more than 1 arguments check and see if the first one is a valid environment (dev, staging, prod)
if [ $# -gt 1 ] && [ "$1" = "dev" ] || [ "$1" = "uat" ] || [ "$1" = "prod" ]
then
    # set the environment variable
    export TF_WORKSPACE="$1"
    # remove the first argument
    shift
else   
    # raise an error that it requires an environment and exit
    echo "No environment set, please run again with an environment argument (dev, uat, prod)"
    exit
fi

# if 1password is installed, run with that, else run without
if ! command -v op &> /dev/null
then
    echo "1Password CLI not found, running without 1Password support - make sure your terraform.tfvars file is set up correctly"
    terraform $@
else
    # get current environment and run terraform with 1password vars
    op run --env-file="./tf.env" -- terraform $@
fi