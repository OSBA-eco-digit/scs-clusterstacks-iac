# Workflow Diagram

### Key Components

  - Ansible
  - Environment Variables
  - Cluster Stack
  - OpenStack Client
  - OpenTofu (Terraform)
  - Virtual Infrastructure

### Configuration Files

  - `clouds.yaml`

### Mermaid Diagram

```mermaid
flowchart TD
A[Ansible]
C[clouds.yaml]
OSC[OpenStack Client]
OT[OpenTofu/Terraform]
E[Environment Variables]
CS[Cluster Stack]
VI[Virtual Infrastructure]

C -- required by --> A
C -- required by --> OSC
OSC -- required by --> OT
A -- configures --> CS
E -- configures --> A
OT -- deploys --> VI
CS -- depends on --> VI
```
