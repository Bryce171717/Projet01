#!/bin/bash

# Variables
IMAGE_NAME="hello-world-pyspark"
DEPLOYMENT_NAME="hello-world-pyspark-deployment"
NAMESPACE="default"

# Étape 1: Démarrer Minikube (si nécessaire)
echo "Starting Minikube..."
minikube start

# Étape 2: Configurer kubectl pour utiliser Minikube
echo "Configuring kubectl to use Minikube context..."
kubectl config use-context minikube

# Étape 3: Construire l'image Docker
echo "Building Docker image..."
docker build -t $IMAGE_NAME .

# Étape 4: Tester l'image Docker (exécuter le conteneur et vérifier le résultat)
echo "Running Docker container for testing..."
docker run --rm $IMAGE_NAME

# Vérifier le succès de l'exécution précédente
if [ $? -ne 0 ]; then
    echo "Docker container test failed. Exiting."
    exit 1
fi
# Étape 6: Créer un fichier de déploiement Kubernetes
echo "Creating Kubernetes deployment file..."
cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOYMENT_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $IMAGE_NAME
  template:
    metadata:
      labels:
        app: $IMAGE_NAME
    spec:
      containers:
      - name: $IMAGE_NAME
        image: $IMAGE_NAME
        imagePullPolicy: Never
        ports:
        - containerPort: 8080
EOF

# Étape 7: Appliquer le déploiement Kubernetes
echo "Deploying to Kubernetes..."
kubectl apply -f deployment.yaml --namespace $NAMESPACE

# Étape 8: Vérifier le déploiement
echo "Checking deployment status..."
kubectl rollout status deployment/$DEPLOYMENT_NAME --namespace $NAMESPACE