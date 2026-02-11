```mermaid
sequenceDiagram
    actor U as USER
    participant A   as Ansible
    participant C   as clouds.yaml
    participant OSC as OpenStack Client
    participant OT  as OpenTofu
    participant E   as Environment Variables
    participant CS  as Cluster Stack
    participant VI  as Virtual Infrastructure

    U --> A: install
    U --> OT: install
    U --> OSC: install
    U --> C: configure
    U --> E: configure
    OT --> VI: deploy
    A --> VI: apply role
    VI: --> CS: setup
```
