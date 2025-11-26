# scs-openstack-iac
Proof of Concept for the SCS, using OpenStack and OpenTofu (Infrastructure as Code)

> Ensure you have defined (and exported) the `OS_CLOUD` environment varible for the openstack client.

Here's the current list of supported providers:

  - plusserver
  - scaleup

### Setting up Variables

* **Export via Shell (bash)**

```sh
$ export TF_VAR_myvariable=foo
```

* **Define via OpenTofu's CLI**

```sh
$ tofu -var "NAME=value" plan
```

### Applying the Infrastructure Code

```sh
$ export OS_CLOUD=foo
$ make <provider>
```

### Destroying the Infrastructure

```sh
$ export OS_CLOUD=foo
$ make <provider>-destroy
```
