# IaC code for Kubernetes cluster in EC2

This is for my learning and practice on AWS and Kubernetes.

After applying, run this script to connect nodes to the cluster:

```
./bootstrap.sh
```

To SSH to nodes, config the `~/.ssh/config`:

```
Host i-* mi-*
    User ubuntu
    Port 22
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
```

then can ssh to the instances:

```
$ source env.sh
$ ssh $MASTER1
$ ssh $NODE1
$ ssh $NODE2
```

## Set Up Kubeconfig in local

Run this script

```
$ ./set_local.sh
```

It will create an user `myadmin` using [Certificate Signing Request](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user), grant it cluster-admin role, and set up config for `kubectl` in `kube.conf`.

In order to connect to the API server running in EC2, use SSM to open a port forwarding in another terminal:

```
$ source env.sh
$ aws ssm start-session --target $MASTER1 \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["6443"],"localPortNumber":["6443"]}'
```

Then can use `kubectl` to connect to the API server:

```
$ export KUBECONFIG=kube.conf
$ kubectl get nodes
```
