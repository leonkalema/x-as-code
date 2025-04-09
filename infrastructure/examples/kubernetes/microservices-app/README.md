# Kubernetes Microservices Application

This example demonstrates how to define a microservices application architecture in Kubernetes using declarative YAML manifests.

## Architecture

The application consists of three main components:

1. **Frontend**: NGINX serving static content and proxying API requests to the backend
2. **Backend**: Node.js API service that processes requests and interacts with the database
3. **Database**: PostgreSQL database for persistent storage

```
                   ┌───────────────┐
                   │   Ingress     │
                   └───────┬───────┘
                           │
                           ▼
        ┌───────────────────────────────┐
        │                               │
        ▼                               ▼
┌───────────────┐               ┌───────────────┐
│   Frontend    │───────────────▶    Backend    │
│   (NGINX)     │               │   (Node.js)   │
└───────────────┘               └───────┬───────┘
                                        │
                                        ▼
                                ┌───────────────┐
                                │   Database    │
                                │  (PostgreSQL) │
                                └───────────────┘
```

## Manifests Overview

- `namespace.yaml`: Creates a dedicated namespace for the application
- `frontend-deployment.yaml`: Deploys the frontend service and configures NGINX
- `backend-deployment.yaml`: Deploys the backend API service
- `database-deployment.yaml`: Deploys the PostgreSQL database as a StatefulSet
- `ingress.yaml`: Sets up an ingress controller for external access

## Prerequisites

- Kubernetes cluster (minikube, kind, EKS, GKE, etc.)
- kubectl configured to connect to your cluster
- NGINX Ingress Controller installed in the cluster

## Deployment

1. Create the namespace:
   ```bash
   kubectl apply -f namespace.yaml
   ```

2. Deploy the database:
   ```bash
   kubectl apply -f database-deployment.yaml
   ```

3. Deploy the backend service:
   ```bash
   kubectl apply -f backend-deployment.yaml
   ```

4. Deploy the frontend service:
   ```bash
   kubectl apply -f frontend-deployment.yaml
   ```

5. Apply the ingress configuration:
   ```bash
   kubectl apply -f ingress.yaml
   ```

6. Check the status of all resources:
   ```bash
   kubectl get all -n microservices-demo
   ```

## Accessing the Application

Once deployed, you can access the application at:
- http://app.example.com (update your hosts file or DNS configuration)

## Security Considerations

For production environments, consider:

1. Use Secrets Management systems (Vault, etc.) instead of Kubernetes Secrets
2. Implement network policies to restrict pod-to-pod communication
3. Configure TLS certificates for secure communication
4. Set up proper resource limits and requests
5. Implement pod security policies
6. Use service meshes for additional security features

## Resource Management

The manifests include resource requests and limits to ensure:
- Predictable performance
- Protection against resource exhaustion
- Proper scheduling by the Kubernetes scheduler

## Scaling

The application can be scaled in different ways:

- Scale the frontend and backend deployments horizontally:
  ```bash
  kubectl scale deployment frontend -n microservices-demo --replicas=5
  kubectl scale deployment backend -n microservices-demo --replicas=8
  ```

- For the database, consider using a managed service in production or implementing a proper PostgreSQL cluster

## Integration Points

This example can be integrated with:
- CI/CD pipelines (ArgoCD, Flux, etc.)
- Monitoring as Code (Prometheus, Grafana)
- Security as Code (Kyverno, OPA)
- Service Mesh (Istio, Linkerd)
