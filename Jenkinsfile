@Library('jenkins-ext') _

require 'helm'
require 'kubectl'
initialize this

kubepipe(serviceAccount: 'jenkins-admin') {
    git 'https://github.com/fscottmiller/Jenkins'
    kubectl 'create configmap casc --from-file casc -o yaml --dry-run -n demo | kubectl replace -f -'
    helm 'upgrade jenkins stable/jenkins -n demo -f values.yaml --set master.adminPassword=admintest123$'
    // sh script: "wget --user=admin --password=admintest123$ "
}
