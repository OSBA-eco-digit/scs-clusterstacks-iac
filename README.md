# scs-openstack-iac

Proof of Concept for the SCS, using OpenStack and OpenTofu (Infrastructure as Code)

> Ensure you have defined (and exported) the `OS_CLOUD` environment varible for the openstack client. That's the name of your "cloud credentials" set via `clouds.yaml`.

Here's the current list of supported providers:

  - plusserver
  - scaleup

Our goal is to install and setup the necessary virtual infrastructure and the companents to run a Kubernetes Cluster Stack.

### Bootstrapping (Initializing OpenTofu Providers)

```sh
$ make
```

### Applying and Deploying the Infrastructure

```sh
$ export OS_CLOUD=foo
$ make <provider>
```

### Installing and Setting up Cluster Stack

```sh
$ export OS_CLOUD=foo
$ make setup
```

### Destroying the Infrastructure

```sh
$ export OS_CLOUD=foo
$ make <provider>-destroy
```
