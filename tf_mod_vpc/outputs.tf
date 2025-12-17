output "vpc_id" {
  description = "The ID of the newly created VPC"
  value = aws_vpc.main.id
}

output "public_subnets" {
  description = "List of public subnet ids"
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnets" {
  description = "List of private subnet ids"
  value = [for s in aws_subnet.private : s.id]
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway ids"
  value       = aws_nat_gateway.nat.*.id
}

output "s3_vpc_endpoint_id" {
  description = "VPC endpoint id for S3"
  value       = aws_vpc_endpoint.s3.id
}