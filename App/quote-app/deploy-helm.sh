#!/bin/bash
set -e

ENVIRONMENT=${1:-poc}
ACTION=${2:-install}
IMAGE_TAG=${3:-}
RELEASE_NAME=${4:-quote-app-$ENVIRONMENT}
NAMESPACE=${5:-quote-app-$ENVIRONMENT}

echo "🚀 Helm Deployment"
echo "📌 Environment: $ENVIRONMENT"
echo "🎯 Action: $ACTION"
echo "📦 Release: $RELEASE_NAME"
echo "🏷️  Namespace: $NAMESPACE"

cd charts/quote-app

# Create namespace if it doesn't exist
kubectl create namespace "$NAMESPACE" 2>/dev/null || true

# Set image tag if provided
VALUES_FILE="values-$ENVIRONMENT.yaml"
if [[ ! -f "$VALUES_FILE" ]]; then
    echo "❌ Values file not found: $VALUES_FILE"
    exit 1
fi

# Prepare helm command
case $ACTION in
    install|upgrade)
        if [[ "$ACTION" == "install" ]]; then
            CMD="helm install"
        else
            CMD="helm upgrade"
        fi
        
        # Build command with optional image tag
        HELM_CMD="$CMD $RELEASE_NAME . --namespace $NAMESPACE -f $VALUES_FILE"
        
        if [[ -n "$IMAGE_TAG" ]]; then
            HELM_CMD="$HELM_CMD --set image.tag=$IMAGE_TAG"
        fi
        
        echo "📦 Running: $HELM_CMD"
        eval "$HELM_CMD"
        
        # Wait for rollout
        echo "⏳ Waiting for rollout..."
        kubectl rollout status deployment/$RELEASE_NAME -n $NAMESPACE --timeout=300s
        ;;
        
    uninstall)
        echo "🗑️  Uninstalling release..."
        helm uninstall $RELEASE_NAME --namespace $NAMESPACE
        ;;
        
    template)
        echo "📄 Generating templates..."
        if [[ -n "$IMAGE_TAG" ]]; then
            helm template $RELEASE_NAME . -f $VALUES_FILE --set image.tag=$IMAGE_TAG
        else
            helm template $RELEASE_NAME . -f $VALUES_FILE
        fi
        ;;
        
    dry-run)
        echo "🔍 Dry run..."
        if [[ -n "$IMAGE_TAG" ]]; then
            helm install $RELEASE_NAME . --dry-run -f $VALUES_FILE --set image.tag=$IMAGE_TAG
        else
            helm install $RELEASE_NAME . --dry-run -f $VALUES_FILE
        fi
        ;;
        
    lint)
        echo "🔍 Linting chart..."
        helm lint .
        ;;
        
    test)
        echo "🧪 Running helm test..."
        helm test $RELEASE_NAME --namespace $NAMESPACE
        ;;
        
    *)
        echo "❌ Unknown action: $ACTION"
        echo "Usage: $0 [poc|staging|production] [install|upgrade|uninstall|template|dry-run|lint|test] [image-tag] [release-name] [namespace]"
        exit 1
        ;;
esac

# Show status if install/upgrade
if [[ "$ACTION" == "install" || "$ACTION" == "upgrade" ]]; then
    echo "✅ Deployment completed!"
    echo ""
    echo "📊 Status:"
    helm list --namespace $NAMESPACE
    echo ""
    echo "📦 Resources:"
    kubectl get pods,svc,ingress -n $NAMESPACE
fi
