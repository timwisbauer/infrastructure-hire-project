output "s3_bucket_name" {
  value = aws_s3_bucket.vulns_bucket.id
}
output "vulns_app_repository_url" {
  value = aws_ecr_repository.vulns_app.repository_url
}
