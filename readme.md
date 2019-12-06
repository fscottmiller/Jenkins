## Create your cluster
---
Use your favorite cloud provider!
## Install and Configure Tools
---
##### kubectl
https://kubernetes.io/docs/tasks/tools/install-kubectl/
##### Helm
https://helm.sh/docs/intro/install/
##### Tiller
`helm init`
## Create Kubernetes Resources
---
##### Create the Jenkins namespace
`kubectl create ns jenkins`
##### Create the CasC ConfigMap
`kubectl create configmap casc -n jenkins --from-file casc`
##### Create Secret for Storage 
`kubectl create secret generic <secretName> --from-file=<secretFile> -n jenkins`
## Installing Jenkins
---
```
helm install jenkins        \       
    stable/jenkins          \
    -n jenkins              \
    -f jenkins.yaml         \
    --set master.adminUser=<admin username>,master.adminPassword=<admin password>
```
## Upgrading Jenkins
---
0. Update the configuration files in `casc`
1. Update the ConfigMap
`kubectl create configmap casc -n jenkins --from-file casc -o yaml --dry-run | kubectl replace -f -`
2. Apply the upgrade
```
helm upgrade jenkins        \
    stable/jenkins          \
    -n jenkins              \
    -f jenkins.yaml
```
3. Reload the configuration
Manage Jenkins > Configuration as Code > Reload Existing Configuration
## Development Notes
---
Things to think about:
- using the `--atomic` or `--cleanup-on-fail` flags during helm deployments
- configmap only takes the root level directory - no subdirectories
- we need to consider how to clean up after merges
    - delete namespace (includes service account and app), as well as cluster role binding for the service account
    - need to implement cleanup for backup data
- blue green deployment? need to think it through
- known error: helm marks deployment as successfull before waiting for pods to be ready
    - if CasC fails, Jenkins will stop (failed deploy) but Helm shows success
- check for apply configmap 