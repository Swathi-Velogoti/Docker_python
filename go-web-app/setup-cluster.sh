#!/bin/bash

# Setup script for DevOps end-to-end demo

set -e

echo "Setting up Kubernetes cluster with kind..."

# Create kind cluster
kind create cluster --config kind-config.yaml --name my-dev-cluster

# Wait for cluster to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "Installing NGINX Ingress Controller..."

# Install NGINX ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace

# Wait for ingress controller to be ready
kubectl wait --for=condition=available --timeout=300s deployment/ingress-nginx-controller -n ingress-nginx

echo "Installing Argo CD..."

# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "Setup complete!"
echo ""
echo "Argo CD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
echo ""
echo "To access Argo CD UI:"
echo "kubectl port-forward svc/argocd-server -n argocd 8081:443 &"
echo "Then open https://localhost:8081"
echo ""
echo "To deploy applications:"
echo "kubectl apply -f argocd/application-dev.yaml"
echo "kubectl apply -f argocd/application-staging.yaml"
echo "kubectl apply -f argocd/application-prod.yaml"