#!/bin/bash

openssl genrsa -out myadmin.key 2048
openssl req -new -key myadmin.key -out myadmin.csr -subj "/CN=myadmin"

source env.sh

ssh -o StrictHostKeyChecking=accept-new ubuntu@$MASTER1 "kubectl delete csr myadmin"
ssh -o StrictHostKeyChecking=accept-new ubuntu@$MASTER1 "cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: myadmin
spec:
  groups:
  - system:authenticated
  request: $(cat myadmin.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF"

ssh -o StrictHostKeyChecking=accept-new ubuntu@$MASTER1 "kubectl certificate approve myadmin"
ssh -o StrictHostKeyChecking=accept-new ubuntu@$MASTER1 "kubectl get csr myadmin -o jsonpath='{.status.certificate}'" | base64 -d > myadmin.crt
ssh -o StrictHostKeyChecking=accept-new ubuntu@$MASTER1 "kubectl get cm -o jsonpath='{.items[0].data.ca\.crt}'" > ca.crt

rm -f kube.conf
kubectl config set-cluster kubernetes \
 --server=https://localhost:6443 \
 --tls-server-name=kubernetes \
 --embed-certs --certificate-authority=ca.crt \
 --kubeconfig kube.conf
kubectl config set-credentials myadmin \
 --client-key=myadmin.key \
 --client-certificate=myadmin.crt \
 --embed-certs=true \
 --kubeconfig kube.conf
kubectl config set-context myadmin \
 --cluster=kubernetes --user=myadmin \
 --kubeconfig kube.conf
kubectl config use-context myadmin \
 --kubeconfig kube.conf

ssh -o StrictHostKeyChecking=accept-new ubuntu@$MASTER1 "kubectl create clusterrolebinding cluster-myadmin --clusterrole=cluster-admin --user=myadmin"
