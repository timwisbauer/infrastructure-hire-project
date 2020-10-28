#############################################
# Create an IAM role to be assumed with OIDC
#############################################

module "iam_assumable_role_s3" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.14.0"
  create_role                   = true
  role_name                     = "contrast-project2-s3"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.s3.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}

##############################
# IAM policy for S3 role.
##############################

resource "aws_iam_policy" "s3" {
  description = "Allows access to S3 bucket"
  policy      = data.aws_iam_policy_document.s3.json
}

####################################
# Define an IAM policy document here
####################################

data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = ["${aws_s3_bucket.vulns_bucket.arn}/${aws_s3_bucket_object.vulns_file.id}"]
  }
}
