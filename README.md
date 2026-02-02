# scs-openstack-iac

Proof of Concept for the SCS, using OpenStack and OpenTofu (Infrastructure as Code) to deploy ClusterStack and setup KaaS.

> Ensure you have defined (and exported) the `OS_CLOUD` environment varible for the openstack client. That's the name of your "cloud credentials" set via `clouds.yaml`.

* **Credentials and Permissions**

Should you be exclusively using the web interface of your cloud provider, please navigate to `/identity/application_credentials/create` and generate the application credentials from there.

A bit more information about application credentials used by `clouds.yaml`?

  - https://docs.openstack.org/keystone/queens/user/application_credentials.html
  - https://docs.redhat.com/en/documentation/red_hat_openstack_platform/16.0/html/users_and_identity_management_guide/application_credentials

  The code on this repository will assume you have your credentials available and have the following environment variables set with the proper values:

    - OS_APPLICATION_CREDENTIAL_ID
    - OS_APPLICATION_CREDENTIAL_SECRET

> Other variables are also required to be set! Please read the detailed information below for 'Environment Variables' and set them.

* **Cluster API Images for OpenStack**

Before proceeding any further, ensure you have the supported images available. Here we mean the images to be used by the nodes provisioned by the cluster. Should you need to build images yourself please follow the official documentation here:

  - https://image-builder.sigs.k8s.io/capi/providers/openstack.html

* **Official Providers**

Here's the current list of supported providers:

  - plusserver
  - scaleup

Should you have a custom provider not listed above and your OS_CLOUD has a different value other than those listed above, please define the following variables before:

  - OS_AUTH_URL
  - OS_EXTERNAL_NETWORK_ID

> Defining _OS_CLOUD_ with the name of the official providers sets the other variables by default; that's the current state of the art at the moment.

* **Management Cluster**

By default `kind` is being used behind the setup of the management cluster here. Should you are willing to have `k3s` please run **"setup-k3s"** as your 'setup' target instead.

* **Official Documentations**

Here's a list of some of documentations we based this work on:

  - https://cluster-api-openstack.sigs.k8s.io/getting-started.html
  - https://cluster-api.sigs.k8s.io/user/quick-start.html
  - https://docs.k3s.io
  - https://github.com/SovereignCloudStack/cluster-stacks/blob/main/providers/openstack/scs2/README.md
  - https://github.com/k3s-io/cluster-api-k3s/blob/main/README.md
  - https://kind.sigs.k8s.io/docs/user/quick-start

  * _Extras for Sovereign Cloud Stack (SCS)_
    - https://github.com/SovereignCloudStack/cluster-stacks/blob/main/providers/openstack/scs2/README.md

* **Environment Variables**

To setup a custom `clouds.yaml` that will be used by the Cluster Stack, a few variables should be set and exported to the shell environment.

Those will be used while applying the Ansible Role. The variables are, in short, related to the setup of OpenStack's client credentials. Here is a list of them:

  - OS_APPLICATION_CREDENTIAL_ID
  - OS_APPLICATION_CREDENTIAL_SECRET
  - OS_AUTH_URL
  - OS_CLOUD
  - OS_INTERFACE
  - OS_REGION_NAME

> Set the value using your local environment variables before applying this role.

* **Submodules**

This repository relies on submodules to configure a custom setup with K3S so, please check those remotes before proceeding. Here's how:

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

> One-liner? `make && make <provider> OS_CLOUD=foo && sleep 145 && make setup OS_CLOUD=foo`

The current components that are setting up the Cluster Stack are:

  - clusterctl
  - helm
  - kubectl

> The containers engine is Docker.

### Destroying the Infrastructure

```sh
$ export OS_CLOUD=foo
$ make <provider>-destroy
```

> One-liner? `make <provider>-destroy OS_CLOUD=foo`
