# ADR-001: ArgoCD over Flux CD for GitOps

**Date:** 2023-03-15  
**Status:** Accepted

## Context
We needed a GitOps controller for our EKS platform managing 15+ microservices.

## Decision
We chose ArgoCD over Flux CD.

## Reasons
1. **UI**: ArgoCD's web UI provides excellent visibility for the operations team
2. **App of Apps**: Native support for bootstrapping entire cluster from one Application
3. **RBAC**: Project-based RBAC integrates well with our team structure
4. **Rollback**: ArgoCD's history and rollback UX is superior for incident response

## Consequences
- Operators can see application sync status without kubectl access
- MTTR improved as operators can identify drift visually
- Slightly more complex to set up than Flux initially
