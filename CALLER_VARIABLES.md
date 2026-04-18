# Variáveis necessárias no repositório que chama a pipeline

Configure estas variáveis em **Settings → Secrets and variables → Actions → Variables** do seu repositório.

---

## Google Artifact Registry

| Variável | Exemplo | Descrição |
|---|---|---|
| `GAR_REGISTRY` | `us-central1-docker.pkg.dev/meu-projeto/meu-repo` | URL base do registry no GAR |

---

## GCP — Autenticação (Workload Identity)

| Variável | Exemplo | Descrição |
|---|---|---|
| `GCP_WIF_PROVIDER_DEV` | `projects/123/locations/global/workloadIdentityPools/pool/providers/provider` | Workload Identity Provider do ambiente dev |
| `GCP_SERVICE_ACCOUNT_DEV` | `sa-dev@meu-projeto.iam.gserviceaccount.com` | Service Account usada no ambiente dev |
| `GCP_WIF_PROVIDER_PROD` | `projects/123/locations/global/workloadIdentityPools/pool/providers/provider` | Workload Identity Provider do ambiente prod |
| `GCP_SERVICE_ACCOUNT_PROD` | `sa-prod@meu-projeto.iam.gserviceaccount.com` | Service Account usada no ambiente prod |

---

## GKE — Clusters

| Variável | Exemplo | Descrição |
|---|---|---|
| `GKE_CLUSTER_NAME_DEV` | `meu-cluster-dev` | Nome do cluster GKE de dev |
| `GKE_CLUSTER_LOCATION_DEV` | `us-central1` | Região ou zona do cluster de dev |
| `GKE_CLUSTER_NAME_PROD` | `meu-cluster-prod` | Nome do cluster GKE de prod |
| `GKE_CLUSTER_LOCATION_PROD` | `us-central1` | Região ou zona do cluster de prod |

---

## Como chamar a pipeline

No workflow do seu repositório, passe os inputs obrigatórios:

```yaml
jobs:
  pipeline:
    uses: thesamsco/.github/.github/workflows/pipeline.yaml@v1
    with:
      env: dev          # "dev" ou "prod"
      app_name: minha-app
      namespace: meu-namespace
    permissions:
      id-token: write
      contents: write
```

---

## Permissões necessárias nas Service Accounts

| Papel | Para quê |
|---|---|
| `roles/artifactregistry.repoAdmin` | Criar repositório GAR automaticamente no primeiro push e fazer push de imagens |
| `roles/container.developer` | Obter credenciais do GKE e fazer deploy |
