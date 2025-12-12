# Lab setup

> [!NOTE]
> This repository is a personal project and is not intended for public use. It uses specific configurations and setups tailored to my own environment. Repository is intended as template and usage with ansible for personal setups.

**Network layout:**

- `OPNsense` firewall/router running on dedicated hardware
- `Switch` Mikrotik CSS326-24G-2S+RM managed switch
- `Cluster` a 2U Supermicro SYS-6028TR-HTR server
  - `Blades` 4x X10DRT-H
    - Intel(R) Xeon(R) CPU E5-2650 v4 @ 2.20GHz
    - DDR4 64GiB RAM
