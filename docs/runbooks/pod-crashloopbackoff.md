# Runbook: Pod CrashLoopBackOff

**Alert:** PodCrashLoopBackOff  
**Severity:** High  
**Owner:** Platform Team

## Symptoms
Pod repeatedly crashing and restarting.
kubectl get pods shows STATUS = CrashLoopBackOff.

## Immediate Diagnosis

```bash
# Step 1: Check which pods are affected
kubectl get pods -n production | grep CrashLoop

# Step 2: Get pod details
kubectl describe pod <pod-name> -n production

# Step 3: Check current logs
kubectl logs <pod-name> -n production --tail=100

# Step 4: Check previous container logs (before crash)
kubectl logs <pod-name> -n production --previous --tail=100
```

## Common Causes and Fixes

### OOMKilled — Out of Memory
```bash
# Check if OOMKilled
kubectl describe pod <pod-name> | grep -A5 "Last State"
# Look for: Reason: OOMKilled

# Fix: Increase memory limit in GitOps repo
# Edit kubernetes/apps/<service>/overlays/production/kustomization.yaml
# Increase resources.limits.memory
# Commit → ArgoCD syncs automatically
```

### Application startup failure
```bash
# Check application logs for startup errors
kubectl logs <pod-name> -n production --previous

# Common causes:
# - Database connection refused (check DB status)
# - Missing environment variable (check secret/configmap)
# - Wrong image tag (check ArgoCD app)
```

## Escalation
- Not resolved in 20 minutes → page team lead
- Affects payment service → P1 — page on call immediately
