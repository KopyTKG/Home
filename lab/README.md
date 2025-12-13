# Lab setup

> [!NOTE]
> This repository is a personal project and is not intended for public use. It uses specific configurations and setups tailored to my own environment. Repository is intended as template and usage with ansible for personal setups.

**Network layout:**

- `OPNsense` firewall/router running on dedicated hardware
- `Switch` Mikrotik CSS326-24G-2S+RM managed switch
- `Cluster` a 2U **Supermicro SYS-6028TR-HTR** server
  - `Blades` 4x **X10DRT-H** motherboards with:
    - 2x **Intel(R) Xeon(R) CPU E5-2650 v4 @ 2.20GHz**
    - 8x **8GiB DDR4 ECC RAM** (64GiB total per blade)
    - **WD Blue SN570 500GB NVMe SSD** for OS

> [!IMPORTANT]
> By default, the blades do not have BIOS support for PCIE NVMe drives. To enable it, you need to modify by adding driver to the BIOS and then flash it.

## Software setup

- `Node-1` K3s Tainted node - Master + Worker
- `Node-2` K3s Worker node
- `Node-3` K3s Worker node
- `Node-4` K3s Worker node
- `OS` Rocky Linux 9.7

## Ansible

- `Inventory` located in `lab/inventory/hosts.ini`
- `Playbooks` located in `lab/playbooks/`

### Playbooks

- `startup.yml` - Starts all VMs via `ipmitool` commands

1. `update.yml` - Updates and upgrades all packages on all nodes
2. `1-setup-base.yml` - Basic setup of the nodes (chrony, firewall, `/etc/hosts`, etc.)
3. `2-setup-k3s.yml` - Installs K3s on all nodes
