# scs-openstack-iac
Proof of Concept for the SCS, using OpenStack and OpenTofu (Infrastructure as Code)

### Setting up Variables

* **Export via Shell (bash)**

```sh
$ export TF_VAR_myvariable=foo
```

* **Define via OpenTofu's CLI**

```sh
$ tofu -var "NAME=value" plan
```
