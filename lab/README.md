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
