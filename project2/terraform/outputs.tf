output "s3_bucket_name" {
  value = aws_s3_bucket.vulns_bucket.id
}
output "vulns_app_repository_url" {
  value = aws_ecr_repository.vulns_app.repository_url
}
output "alb_hostname" {
  value = kubernetes_ingress.proxy.load_balancer_ingress[0].hostname
}
