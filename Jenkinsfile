@Library('jenkins-ext') _

require 'helm'
require 'kubectl'
initialize this

kubepipe(serviceAccount: 'jenkins-admin') {
    stage('Update Configuration') {
        git url: 'https://github.com/fscottmiller/Jenkins', branch: 'tmp'
        kubectl 'create configmap casc -n demo --from-file casc -o yaml --dry-run | kubectl replace -f -'
    }
    stage('Update Application') {
        helm 'repo add stable https://kubernetes-charts.storage.googleapis.com/'
        helm 'repo update'
        helm 'upgrade jenkins stable/jenkins -n demo -f values.yaml --set master.adminPassword=admintest123$'
        echo "${kubectl 'get svc jenkins -n demo'}"
    }
}
