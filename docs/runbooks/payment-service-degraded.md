# Runbook: Payment Service Degraded

**Severity:** P1  
**Alert:** `SLOBurnRateCritical` or `PaymentServiceHighErrorRate`  
**Owner:** Platform Team  
**Last Updated:** 2024-01-15

## Symptoms
- HTTP 5xx error rate > 1%
- Grafana dashboard shows SLO burn rate > 14.4x
- PagerDuty alert fired

## Immediate Actions (< 2 minutes)

```bash
# 1. Check pod status
kubectl get pods -n production -l app=payment-service

# 2. Check recent events
kubectl describe deployment payment-service -n production | tail -30

# 3. Check logs for errors
kubectl logs -n production -l app=payment-service --tail=100 | grep -i error

# 4. Check ArgoCD sync status
argocd app get payment-service
```

## Diagnosis Tree

### If pods are CrashLoopBackOff:
```bash
kubectl logs -n production <pod-name> --previous
# Check for OOMKilled: kubectl describe pod <pod-name>
```
→ If OOMKilled: Increase memory limits in GitOps repo, PR + merge

### If pods are Running but errors continue:
```bash
# Check if recent deployment caused it
argocd app history payment-service
# If yes: rollback
argocd app rollback payment-service
```

## Escalation
- Not resolved in 15 min → escalate to payments team lead
- Database issues detected → escalate to DBA on-call

## Post-Incident
- Update this runbook with new learnings
- File postmortem within 48 hours
