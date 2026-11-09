# Backups & Disaster Recovery

Two independent backup strategies protect the platform:

## 1. Proxmox vzdump (guest-level)

Schedule full backups of every guest to `local` storage via the PVE scheduler
(or a cron):

```bash
# Full backup of the VM/CTs (vmids 110-114) to local, zstd-compressed
vzdump 110 111 112 113 114 --mode snapshot --compress zstd --storage local
```

Restore:

```bash
qmrestore /var/lib/vz/dump/vzdump-qemu-110-*.vma.zst 110
pct restore 114 /var/lib/vz/dump/vzdump-lxc-114-*.tar.zst
```

## 2. Off-site / etcd (for the cluster variant)

If using the Talos/Kubernetes cluster, snapshot etcd and push to object storage:

```bash
talosctl etcd snapshot etcd.snapshot --nodes 10.10.10.200
# then rsync to an off-site location
```

## DR drill

| Scenario | Procedure |
|---|---|
| Guest lost | restore from vzdump |
| Host disk failure | restore last vzdump onto new node, re-apply Terraform |
| GPU failure | `bootstrap-ai-infer.sh` on a re-provisioned VM |
| Config drift | `terraform apply` reverts to code state |

## RPO / RTO

- **RPO:** as frequent as the vzdump schedule (default nightly).
- **RTO:** minutes for a guest restore (restore + `terraform apply` + bootstrap script).
