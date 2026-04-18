#!/bin/bash
set -euo pipefail

# Uso: generate-tag.sh [patch|minor|major]
# Se o argumento for omitido, detecta pelo conventional commits (BREAKING → major, feat → minor, fix → patch).
# Deve ser executado no diretório do repositório da aplicação (não do repo central).

BUMP_FROM_ARG=""
if [[ -n "${1:-}" ]]; then
  case "$1" in
    patch|minor|major) BUMP_FROM_ARG="$1" ;;
    *) echo "Argumento inválido: $1. Use patch, minor ou major." >&2; exit 1 ;;
  esac
fi

echo "Sincronizando tags e histórico..." >&2
git fetch --tags --force
# Shallow clone não tem histórico; des-shallow para ter LAST_TAG..HEAD
git fetch --unshallow 2>/dev/null || true

# Pega última tag semver válida (aceita com ou sem prefixo "v")
LAST_TAG=$(git tag --list | sed -n 's/^v\?\([0-9]\+\.[0-9]\+\.[0-9]\+\)$/\1/p' | sort -V | tail -n 1)

if [ -z "$LAST_TAG" ]; then
  LAST_TAG="0.0.0"
fi

echo "Última versão encontrada: $LAST_TAG" >&2

IFS='.' read -r MAJOR MINOR PATCH <<< "$LAST_TAG"

# Range de commits desde a última tag
if [ "$LAST_TAG" = "0.0.0" ]; then
  RANGE="HEAD"
else
  RANGE="${LAST_TAG}..HEAD"
fi

# Se o tipo de bump foi passado por argumento, usa e calcula nova tag
if [[ -n "$BUMP_FROM_ARG" ]]; then
  echo "Tipo de incremento (argumento): $BUMP_FROM_ARG" >&2
  case "$BUMP_FROM_ARG" in
    major)
      MAJOR=$((MAJOR + 1))
      MINOR=0
      PATCH=0
      ;;
    minor)
      MINOR=$((MINOR + 1))
      PATCH=0
      ;;
    patch)
      PATCH=$((PATCH + 1))
      ;;
  esac
  NEW_TAG="$MAJOR.$MINOR.$PATCH"
  echo "Nova tag: $NEW_TAG" >&2
  git tag "$NEW_TAG"
  git push origin "$NEW_TAG"
  echo "$NEW_TAG"
  exit 0
fi

# Detecção por conventional commits
COMMITS=$(git log "$RANGE" --pretty=format:"%s%n%b")

if [ -z "$COMMITS" ]; then
  echo "Nenhum commit novo encontrado. Reutilizando $LAST_TAG" >&2
  echo "$LAST_TAG"
  exit 0
fi

BUMP="none"
if echo "$COMMITS" | grep -qE "BREAKING CHANGE|!:"; then
  BUMP="major"
elif echo "$COMMITS" | grep -qE "^feat(\(.+\))?:"; then
  BUMP="minor"
elif echo "$COMMITS" | grep -qE "^(fix|hotfix)(\(.+\))?:"; then
  BUMP="patch"
fi

if [ "$BUMP" = "none" ]; then
  echo "Nenhum commit relevante para versionamento. Reutilizando $LAST_TAG" >&2
  echo "$LAST_TAG"
  exit 0
fi

echo "Tipo de incremento detectado: $BUMP" >&2

case $BUMP in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
esac

NEW_TAG="$MAJOR.$MINOR.$PATCH"

echo "Criando nova tag: $NEW_TAG" >&2

git tag "$NEW_TAG"
git push origin "$NEW_TAG"

# Apenas a tag no stdout (para o workflow capturar)
echo "$NEW_TAG"

