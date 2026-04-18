# Platform Architecture

## Overview

Production EKS platform serving 15+ Spring Boot and Node.js microservices
for 3 enterprise clients. Achieves 99.99% availability SLA.

## Key Design Decisions

### GitOps with ArgoCD
All deployments are managed through ArgoCD watching this repository.
No direct kubectl access to production. Every change is a Git commit.

### IRSA for AWS Access
Every pod has its own IAM role with least-privilege permissions.
Eliminated node-level instance profile abuse (resolved critical audit finding).

### Karpenter for Autoscaling
Spot instance adoption with PodDisruptionBudget integration.
AWS Node Termination Handler for graceful Spot interruption.
Result: ~30% EC2 cost reduction.

### SLO-Based Alerting
Multiwindow burn rate alerts reduce false positives.
MTTR reduced from 52 minutes to 34 minutes (35% improvement).

## Component Map

| Component | Tool | Purpose |
|-----------|------|---------|
| Container Orchestration | AWS EKS 1.29 | Run all workloads |
| GitOps | ArgoCD | Automated deployment |
| Secrets | HashiCorp Vault HA | Dynamic credentials |
| Autoscaling | Karpenter | Spot + On-Demand |
| Metrics | Prometheus + Grafana | 40+ dashboards |
| Logs | Fluent Bit + OpenSearch | 50GB+/day |
| Admission Control | Kyverno | Security policies |
| Service Mesh | Istio | mTLS + traffic management |
| IaC | Terraform | All AWS infrastructure |
