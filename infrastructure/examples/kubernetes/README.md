# Kubernetes Configuration Examples

This directory contains examples of infrastructure as code using Kubernetes manifests, which allow you to declaratively define containerized applications and their deployment environments.

## What is Kubernetes?

[Kubernetes](https://kubernetes.io/) is an open-source platform for automating deployment, scaling, and management of containerized applications. It groups containers that make up an application into logical units for easy management and discovery.

## Examples

- [Microservices Application](./microservices-app/): A complete microservices architecture with frontend, backend, and database components.

## Key Concepts in Kubernetes

- **Pods**: The smallest deployable units in Kubernetes, containing one or more containers.
- **Deployments**: Manage the desired state of your Pods, including updates and rollbacks.
- **Services**: Abstract way to expose applications running in Pods as network services.
- **ConfigMaps and Secrets**: Store configuration data and sensitive information.
- **StatefulSets**: Manage stateful applications like databases.
- **Ingress**: Manage external access to services in a cluster.
- **Namespaces**: Virtual clusters for resource isolation.

## Kubernetes as Infrastructure as Code

Kubernetes manifests are written in YAML and define:
- The components to be deployed
- The relationships between components
- The desired state of the application
- Resource requirements and limits
- Network configuration
- Storage requirements

## Getting Started

To run these examples, you'll need:

1. A Kubernetes cluster (local like minikube/kind or cloud-based like EKS, GKE, AKS)
2. kubectl command-line tool configured to communicate with your cluster
3. Any prerequisites specified in the example's README.md

## Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Kubernetes GitHub Repository](https://github.com/kubernetes/kubernetes)
- [Kubernetes Patterns](https://k8spatterns.io/)
- [CNCF Landscape](https://landscape.cncf.io/)
