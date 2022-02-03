all: cli deploy
.PHONY: all doormat_creds doormat_aws deploy destroy console cli
ACCOUNT = se_demos_dev
ORGANIZATION = JamesHashicorp
WORKSPACE = rds-workspace-2
check_creds = $(shell doormat --smoke-test 1>&2 2>/dev/null; echo $$?)
doormat_creds:
ifneq ($(check_creds), 0)
	doormat --refresh
endif
doormat_aws: doormat_creds
	doormat aws --account $(ACCOUNT) \
        --tf-push --tf-organization $(ORGANIZATION) \
        --tf-workspace $(WORKSPACE)
deploy: doormat_aws
	terraform init -upgrade && terraform apply -auto-approve
destroy: doormat_aws
	terraform init -upgrade && terraform destroy -auto-approve
console: doormat_creds
	doormat aws --account $(ACCOUNT) --console
cli: doormat_creds
	doormat aws --account $(ACCOUNT) -m