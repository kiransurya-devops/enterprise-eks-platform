# ☸️ Enterprise EKS CD Platform

> Production-grade Kubernetes platform serving 15+ microservices with GitOps,  
> full DevSecOps pipeline, SLO-based observability, and HashiCorp Vault HA.

[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-orange)](https://argoproj.github.io/cd)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC)](https://www.terraform.io)
[![Vault](https://img.shields.io/badge/HashiCorp_Vault-Secrets-black)](https://www.vaultproject.io)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-E6522C)](https://prometheus.io)
[![Security: PCI-DSS](https://img.shields.io/badge/Security-PCI--DSS_Aligned-red)](https://github.com/kiransurya-devops/enterprise-eks-platform)
[![SLA: 99.99%](https://img.shields.io/badge/SLA-99.99%25-brightgreen)](https://github.com/kiransurya-devops/enterprise-eks-platform)

## 📊 Platform Metrics

| Metric | Achievement |
|--------|-------------|
| 🟢 Availability SLA | **99.99%** (3 enterprise clients) |
| 📉 MTTR Reduction | **35%** (52 min → 34 min) |
| 💰 EC2 Cost Reduction | **~30%** (Karpenter Spot) |
| 📋 Daily CI Builds | **120+** (zero-downtime) |
| 🔒 Security Posture | **PCI-DSS aligned** pod-level |
| 📦 Daily Log Volume | **50GB+** processed |
| 🔍 Active Dashboards | **40+** custom Grafana panels |

---

## 🏛️ Platform Architecture
┌─────────────────────────────────────────────────────────────┐
│                     Developer Workflow                       │
│  Code → PR → CI (Jenkins/GHA) → Image → GitOps Repo        │
└─────────────────────┬───────────────────────────────────────┘
│ git push (image tag update)
┌─────────────────────▼───────────────────────────────────────┐
│                  ArgoCD (GitOps Controller)                  │
│         Watches GitOps repo → Syncs to EKS cluster          │
└─────────────────────┬───────────────────────────────────────┘
│ kubernetes apply
┌─────────────────────▼───────────────────────────────────────┐
│                AWS EKS Cluster (ap-south-1)                  │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  Application │  │ Observability│  │    Security       │  │
│  │  Namespace   │  │  Namespace   │  │    Components     │  │
│  │              │  │              │  │                   │  │
│  │ payment-svc  │  │ Prometheus   │  │ HashiCorp Vault   │  │
│  │ auth-svc     │  │ Grafana      │  │ External Secrets  │  │
│  │ order-svc    │  │ Alertmanager │  │ Kyverno           │  │
│  │ ...15+ svcs  │  │ Fluent Bit   │  │ Falco             │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Karpenter (Spot + On-Demand auto-provisioning)       │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
│                │               │
┌────────▼───┐   ┌───────▼────┐  ┌───────▼──────┐
│  RDS Multi │   │ OpenSearch │  │  AWS Services │
│  AZ MySQL  │   │ (50GB/day) │  │  S3, KMS, ECR │
│  99.99% SLA│   │ 12-mo arch │  │  CloudWatch   │
└────────────┘   └────────────┘  └──────────────┘
---

## 📁 Repository Structure
enterprise-eks-platform/
├── terraform/                    # Infrastructure as Code
│   ├── modules/
│   │   ├── eks-cluster/          # EKS cluster with managed node groups
│   │   ├── vpc/                  # VPC, subnets, NAT Gateway
│   │   ├── rds-multi-az/         # MySQL RDS Multi-AZ (99.99% SLA)
│   │   ├── karpenter/            # Spot autoscaling (~30% cost reduction)
│   │   └── irsa-roles/           # Least-privilege pod IAM roles
│   └── environments/
│       ├── dev/ staging/ production/
│
├── kubernetes/                   # Kubernetes manifests
│   ├── base/                     # Shared: namespaces, RBAC, NetworkPolicies
│   ├── apps/                     # Application deployments (Kustomize)
│   └── infrastructure/           # Platform components
│
├── argocd/                       # GitOps configuration
│   ├── applications/             # ArgoCD Application CRDs
│   ├── projects/                 # ArgoCD Projects (RBAC)
│   └── applicationsets/          # Multi-cluster ApplicationSets
│
├── monitoring/                   # Observability (35% MTTR reduction)
│   ├── grafana-dashboards/       # 40+ custom dashboards
│   ├── prometheus-rules/         # SLO-based alert rules
│   └── alertmanager/             # Routing: PagerDuty + Slack
│
├── security/                     # Security controls
│   ├── vault-policies/           # HashiCorp Vault HA policies
│   ├── kyverno-policies/         # Admission control
│   └── network-policies/         # Zero-trust pod networking
│
└── docs/
├── architecture.md
├── runbooks/                  # Incident response runbooks
└── decisions/                 # Architecture Decision Records
---

## 🚀 Quick Start

```bash
# Prerequisites: AWS CLI, kubectl, helm, terraform >= 1.6

# 1. Bootstrap EKS cluster
cd terraform/environments/staging
terraform init
terraform plan
terraform apply

# 2. Configure kubectl
aws eks update-kubeconfig \
  --name staging-eks-cluster \
  --region ap-south-1

# 3. Install ArgoCD
kubectl apply -k kubernetes/infrastructure/argocd/

# 4. Bootstrap App of Apps (deploys everything)
kubectl apply -f argocd/applications/root-app.yaml

# ArgoCD syncs all applications from Git automatically
```

---

## 🔒 Security Highlights

### IRSA (IAM Roles for Service Accounts)
Each pod gets a dedicated IAM role with least-privilege permissions.  
Resolved critical finding from internal cloud security audit.

### HashiCorp Vault HA
- 3-node Vault cluster with Raft backend
- Dynamic database credentials (auto-expiring)
- Vault Agent Injector for zero-code-change secret injection

### Kubernetes Security Posture (PCI-DSS Aligned)
- `runAsNonRoot: true` — all containers
- `readOnlyRootFilesystem: true` — all containers  
- `seccompProfile: RuntimeDefault` — all containers
- `capabilities: drop: [ALL]` — all containers
- Default-deny NetworkPolicies per namespace
- Kyverno admission control enforcing all above

---

## 📈 Observability Stack

**Metrics:** Prometheus + Grafana + Alertmanager  
**Logs:** Fluent Bit → OpenSearch (50GB+/day, 30-day hot, 12-month S3 archive)  
**Alerting:** SLO burn rate (multiwindow, multi-burn-rate)  
**DORA Metrics:** Deployment frequency, lead time, MTTR, change failure rate

---

## 👤 Author

**Kiran S** — DevOps Engineer and Platform Engineer  
[LinkedIn](https://linkedin.com/in/kiransurya-devops) | [GitHub](https://github.com/kiransurya-devops)
