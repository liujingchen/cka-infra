# IaC code for Kubernetes cluster in EC2

This is for my learning and practice on AWS and Kubernetes.

After applying, run this command on master:

```
kubeadm token create --print-join-command
```

And run the output with `sudo` on each node to join the cluster.
