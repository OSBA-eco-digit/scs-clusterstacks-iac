# scs-openstack-iac

Proof of Concept for the SCS, using OpenStack and OpenTofu (Infrastructure as Code) to deploy ClusterStack and setup KaaS.

> Ensure you have defined (and exported) the `OS_CLOUD` environment varible for the openstack client. That's the name of your "cloud credentials" set via `clouds.yaml`.

Here's the current list of supported providers:

  - plusserver
  - scaleup

Our goal is to install and setup the necessary virtual infrastructure and the companents to run a Kubernetes Cluster Stack. For that we would need to get Cluster API up and running as well.

* **Official Documentations**

Here's a list of some of documentations we based this work on:

  - https://cluster-api-openstack.sigs.k8s.io/getting-started.html
  - https://github.com/SovereignCloudStack/cluster-stacks/blob/main/providers/openstack/scs2/README.md
  - https://github.com/k3s-io/cluster-api-k3s/blob/main/README.md

* **Environment Variables**

To setup a custom `clouds.yaml` that will be used by the Cluster Stack, a few variables should be set and exported to the shell environment.

Those will be used while applying the Ansible Role. The variables are, in short, related to the setup of OpenStack's client credentials. Here is a list of them:

  > OS_APPLICATION_CREDENTIAL_ID
  > OS_APPLICATION_CREDENTIAL_SECRET
  > OS_AUTH_TYPE
  > OS_AUTH_URL
  > OS_CLOUD
  > OS_EXTERNAL_NETWORK_ID
  > OS_IDENTITY_API_VERSION
  > OS_INTERFACE
  > OS_PROJECT_ID
  > OS_PROJECT_NAME
  > OS_REGION_NAME
  > OS_SECRET
  > OS_TENANT_ID

Be aware that 2 (two) of these variables have been renamed from their defaults so it's possible to have a mixed authentication type set on the environment, and on the remote server that will host the cluster.

  > OS_AUTH_PASSWORD
  > OS_AUTH_USERNAME

Should you be exclusively using the web interface, navigate to the `/identity/application_credentials/create/` route and generate the credentials from there.

A bit more about application credentials used by `clouds.yaml`?
  - https://docs.openstack.org/keystone/queens/user/application_credentials.html
  - https://docs.redhat.com/en/documentation/red_hat_openstack_platform/16.0/html/users_and_identity_management_guide/application_credentials

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
