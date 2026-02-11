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

    U --> Get Credentials for OpenStack Infrastructure
    U --> Install Required Software
    U --> Define Environment Variables
    U --> Deploy the Virtual Infrastructure
    U --> Apply the Ansible Role to the Server
```
