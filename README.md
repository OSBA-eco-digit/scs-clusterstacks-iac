# scs-openstack-iac

Proof of Concept for the SCS, using OpenStack and OpenTofu (Infrastructure as Code)

> Ensure you have defined (and exported) the `OS_CLOUD` environment varible for the openstack client. That's the name of your "cloud credentials" set via `clouds.yaml`.

Here's the current list of supported providers:

  - plusserver
  - scaleup

Our goal is to install and setup the necessary virtual infrastructure and the companents to run a Kubernetes Cluster Stack.

* **Environment Variables**

To setup a custom `clouds.yaml` that will be used by the Cluster Stack, a few variables should be set and exported to the shell environment.

Those will be used while applying the Ansible Role. The variables are, in short, related to the setup of OpenStack's client credentials. Here is a list of them:

  > 'OS_APPLICATION_CREDENTIAL_ID'
  > 'OS_APPLICATION_CREDENTIAL_SECRET'
  > 'OS_AUTH_URL'
  > 'OS_CLOUD'
  > 'OS_EXTERNAL_NETWORK_ID'
  > 'OS_INTERFACE'
  > 'OS_REGION_NAME'
  > 'OS_SECRET'

* **Submodules**

This repository relies on submodules, please check those remotes before proceeding. Here's how:

```sh
$ git submodule update --init
```

### Bootstrapping (Initializing OpenTofu Providers)

```sh
$ make
```

> That will not just initialize the providers but also check and validate what is served by the code under the `opentofu/` directory.

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

> One-liner? `make && make <provider> OS_CLOUD=foo && sleep 150 && make setup OS_CLOUD=foo`

The current components that are setting up the Cluster Stack are:

  - clusterctl
  - docker
  - helm
  - kubectl

> We are using **k3s** as submodule (mentioned above) to setup the management cluster.

### Destroying the Infrastructure

```sh
$ export OS_CLOUD=foo
$ make <provider>-destroy
```

> One-liner? `make <provider>-destroy OS_CLOUD=foo`
