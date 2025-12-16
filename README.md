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

> One-liner? `make <provider> OS_CLOUD=foo && sleep 150 && make setup OS_CLOUD=foo`

The current components that are setting up the Cluster Stack are:

  - clusterctl
  - docker
  - helm
  - kind
  - kubernetes
  - orc

### Destroying the Infrastructure

```sh
$ export OS_CLOUD=foo
$ make <provider>-destroy
```

> One-liner? `make <provider>-destroy OS_CLOUD=foo`
