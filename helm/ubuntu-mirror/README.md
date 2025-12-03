# Ubuntu Mirror Helm Chart

A Helm chart for deploying an Ubuntu package mirror using apt-mirror and nginx.

## Prerequisites

- Kubernetes 1.16+
- Helm 3.0+
- Persistent storage (PVC) for mirror data

## Installing the Chart

To install the chart with the release name `ubuntu-mirror`:

```bash
helm repo add nostoslabs https://nostoslabs.github.io/helm-charts
helm install ubuntu-mirror nostoslabs/ubuntu-mirror
```

Alternatively, install from source:

```bash
git clone https://github.com/nostoslabs/docker-package-mirror.git
cd docker-package-mirror/helm/ubuntu-mirror
helm install ubuntu-mirror .
```

## Configuration

The following table lists the configurable parameters of the Ubuntu Mirror chart and their default values.

### Ubuntu Mirror Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ubuntuMirror.releases` | Ubuntu releases to mirror (space-separated) | `"jammy"` |
| `ubuntuMirror.mirror` | Ubuntu mirror URL | `"http://archive.ubuntu.com/ubuntu"` |
| `ubuntuMirror.securityMirror` | Security mirror URL | `"http://security.ubuntu.com/ubuntu"` |
| `ubuntuMirror.components` | Ubuntu components to mirror | `"main restricted universe multiverse"` |
| `ubuntuMirror.arches` | Ubuntu architectures | `"amd64"` |
| `ubuntuMirror.threads` | Number of mirroring threads | `10` |
| `ubuntuMirror.proxy` | Proxy URL (optional) | `""` |

### Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Image repository | `"ghcr.io/nostoslabs/docker-package-mirror"` |
| `image.tag` | Image tag | `"main"` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `service.targetPort` | Target port | `8080` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `"nginx"` |
| `ingress.hosts` | List of ingress hosts | `[{"host": "ubuntu-mirror.local", "paths": [{"path": "/", "pathType": "Prefix"}]}]` |
| `ingress.tls` | TLS configuration | `[]` |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.storageClass` | Storage class name | `""` |
| `persistence.accessMode` | PVC access mode | `ReadWriteOnce` |
| `persistence.size` | PVC size | `100Gi` |
| `persistence.existingClaim` | Use existing PVC | `""` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `2Gi` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.requests.memory` | Memory request | `1Gi` |

## Platform-Specific Configuration

### Azure Kubernetes Service (AKS)

```yaml
persistence:
  storageClass: "default"  # or "managed-premium"
```

### Amazon EKS

```yaml
persistence:
  storageClass: "gp3"
```

### MicroK8s/K3d

```yaml
persistence:
  storageClass: "local-path"
```

## Usage

### Initial Mirror Sync

After deployment, you need to run the initial mirror sync:

```bash
# Get the pod name
kubectl get pods -l app.kubernetes.io/name=ubuntu-mirror

# Run the sync command
kubectl exec -it <pod-name> -- /usr/local/bin/entrypoint sync
```

### Accessing the Mirror

Once the mirror is synced, you can access it via:

- Service: `http://ubuntu-mirror:8080`
- Ingress: `http://ubuntu-mirror.local` (if configured)

## Troubleshooting

### Large File Upload Issues

The ingress is configured with annotations to handle large package files:

- `nginx.ingress.kubernetes.io/proxy-body-size: "0"`
- `nginx.ingress.kubernetes.io/proxy-read-timeout: "600"`
- `nginx.ingress.kubernetes.io/proxy-send-timeout: "600"`

### Storage Issues

Ensure your storage class has sufficient capacity. The default is 100Gi, but you may need more depending on the Ubuntu releases and architectures you're mirroring.

### Sync Performance

You can adjust the number of mirroring threads via `ubuntuMirror.threads`. More threads can speed up the initial sync but may require more resources.

## License

This chart is licensed under the same terms as the Ubuntu Mirror project.