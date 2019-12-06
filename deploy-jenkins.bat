
kubectl create configmap casc --from-file casc

helm install jenkins stable/jenkins -f jenkins.yaml