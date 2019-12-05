pipeline {
    agent {
        kubernetes {
            yamlFile 'deploy.yaml'
        }
    }
    environment {
        APP_NAME = "jenkins"
        CHART = "stable/jenkins"
        CONFIG = "casc"
        HELM_REPO = "https://kubernetes-charts.storage.googleapis.com/"
        VALUES_FILE = "values.yaml"
        NAMESPACE = ""
        ADMIN_USER = "admin"
        ADMIN_PASSWORD = "admintest123\$"
    }
    stages {
        stage('Create Namespace') {
            steps {
                container('kubectl') {
                    script {
                        def namespaces = []
                        def yamlText = sh script: "kubectl get ns -o yaml", returnStdout: true, label: "Get Namespaces"
                        def parsed = readYaml text: yamlText
                        for (item in parsed['items']) {
                            namespaces.add item['metadata']['name']
                        }
                        NAMESPACE = "${BRANCH_NAME}".toLowerCase()
                        if (namespaces.contains(NAMESPACE)) {
                            echo "Namespace \"${NAMESPACE}\" already exists."
                        } else {
                            echo "Creating namespace \"${NAMESPACE}\""
                            sh script: "kubectl create ns ${NAMESPACE}", label: "Creating Namespace"
                            sh script: "kubectl create sa ${APP_NAME}-admin -n ${NAMESPACE}", label: "Creating Service Account"
                            sh script: "kubectl create clusterrolebinding ${NAMESPACE}-${APP_NAME}-admin --clusterrole=cluster-admin --serviceaccount=${NAMESPACE}:${APP_NAME}-admin",
                                label: "Configuring Service Account"
                        }
                    }
                }
            }
        }
        stage('Create CasC ConfigMap') {
            steps {
                container('kubectl') {
                    script {
                        def configMapName = CONFIG.split('/').last().toLowerCase()
                        def configmaps = []
                        def yamlText = sh script: "kubectl get configmaps -n ${NAMESPACE} -o yaml", returnStdout: true, label: "Get ConfigMaps"
                        if (yamlText != "No resources found.") {
                            def parsed = readYaml text: yamlText
                            for (item in parsed['items']) {
                                configmaps.add item['metadata']['name']
                            }
                            if (configmaps.contains(configMapName)) {
                                echo "ConfigMap \"${configMapName}\" already exists. Updating now..."
                                sh script: "kubectl create configmap ${configMapName} -n ${NAMESPACE} --from-file ${CONFIG} -o yaml --dry-run | kubectl replace -f -"
                            } else {
                                echo "Creating ConfigMap \"${configMapName}\""
                                sh script: "kubectl create configmap ${configMapName} -n ${NAMESPACE} --from-file ${CONFIG}"
                            }
                        } else {
                            echo "Creating ConfigMap \"${configMapName}\""
                            sh script: "kubectl create configmap ${configMapName} -n ${NAMESPACE} --from-file ${CONFIG}"
                        }
                    }
                }
            }
        }
        stage("Deploy Application") {
            steps {
                container('helm') {
                    script {
                        sh script: "helm repo add stable ${HELM_REPO}", label: "Configure Helm Repo"
                        sh script: "helm repo update", label: "Update Helm Repo"
                        def installed = sh script: "helm list -n ${NAMESPACE}", returnStdout: true
                        if (installed.contains(APP_NAME)) {
                            echo "Upgrading \"${APP_NAME}\""
                            sh script: "helm upgrade ${APP_NAME} ${CHART} -n ${NAMESPACE} -f ${VALUES_FILE} --set master.adminUser=${ADMIN_USER},master.adminPassword=${ADMIN_PASSWORD}"
                        } else {
                            echo "Installing \"${APP_NAME}\""
                            sh script: "helm install ${APP_NAME} ${CHART} -n ${NAMESPACE} -f ${VALUES_FILE} --set master.adminUser=${ADMIN_USER},master.adminPassword=${ADMIN_PASSWORD}"
                        }
                    }
                }
            }
        }
    }
}
