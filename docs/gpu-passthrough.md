# GPU Passthrough (GTX 1050 Ti)

The `ai-infer` VM gets the host's **NVIDIA GeForce GTX 1050 Ti** via VFIO
passthrough so Ollama can run GPU-accelerated inference.

## Host prerequisites (done on `pve`)

1. Enable IOMMU in kernel cmdline (`/etc/default/grub`):

   ```
   GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt video=efifb:off"
   ```

   Then `update-grub && reboot`.

2. Load kernel modules (`/etc/modules-load.d/vfio.conf`):

   ```
   vfio
   vfio_iommu_type1
   vfio_pci
   ```

3. Bind the GPU to VFIO via a systemd hook or `options vfio-pci ids=10de:1c82,10de:0fb9`.

   Verify with `lspci -nnk | grep -A3 10de` → the kernel driver should be `vfio-pci`.

## Verify

```bash
# on the host
lspci -nn | grep -i nvidia
# 02:00.0 VGA compatible controller [0300]: NVIDIA Corporation GP107 [GeForce GTX 1050 Ti] [10de:1c82]
```

In the guest:

```bash
nvidia-smi   # should show the GPU
```

## Why passthrough instead of sharing

Full GPU passthrough gives the VM direct, unpinned access to the device — lowering
latency and enabling the best possible inference throughput for a single workload
(the AI platform). It's the correct pattern for a dedicated inference VM.
