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
