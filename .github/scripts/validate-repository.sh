#!/bin/bash

# Скрипт для валидации названия репозитория
# Использование: ./validate-repository.sh [repository_name]

set -e

REPOSITORY_NAME="$1"

echo "🔍 Validating repository name..."

# Проверяем, что repository_name передан и не пустой
if [ -z "$REPOSITORY_NAME" ]; then
  echo "❌ Error: Repository name is required but was not provided"
  echo "Please provide 'repository_name' input parameter"
  exit 1
fi

echo "✅ Repository name provided: $REPOSITORY_NAME"

# Извлекаем только имя репозитория без владельца
REPO_NAME_ONLY=$(echo "$REPOSITORY_NAME" | sed 's|.*/||')

# Проверяем, что имя репозитория валидное
if [ -z "$REPO_NAME_ONLY" ]; then
  echo "❌ Error: Invalid repository name format: $REPOSITORY_NAME"
  exit 1
fi

echo "📦 Repository name: $REPO_NAME_ONLY"
echo "repo_name=$REPO_NAME_ONLY" >> $GITHUB_OUTPUT