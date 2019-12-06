@Library('jenkins-ext') _

require 'helm'
require 'kubectl'
initialize this

kubepipe(serviceAccount: 'jenkins-admin') {
    git 'https://github.com/fscottmiller/Jenkins'
    kubectl 'create configmap casc -n demo --from-file casc -o yaml --dry-run | kubectl replace -f -'
    helm 'repo add stable https://kubernetes-charts.storage.googleapis.com/'
    helm 'repo update'
    helm 'upgrade jenkins stable/jenkins -n demo -f values.yaml --set master.adminPassword=admintest123$'
    // sh script: "wget --user=admin --password=admintest123$ "
}
