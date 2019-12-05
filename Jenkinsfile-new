def deployInstances(dir = "instances") {
    if (fileExists(dir)) {
        def instances = sh script: "ls ${dir}", 
            label: "Get Instances", 
            returnStdout: true
        instances.each {
            deploy(it)
        }
    } else {
        deploy()
    }
}

def deploy(instance = "") {
    def namespace = BRANCH_NAME
    def appName = "jenkins"
    if (instance != "") {
        namespace += instance
    }
    createNamespace(namespace)
    createServiceAccount(appName, namespace)
    createSecret(secretName, secretFile, namespace)
    createConfigMap(configMapName, instance, namespace)
    install(appName, instance, namespace)
}

def createNamespace(namespace) {
    def namespaces = sh script: "kubectl get ns --no-headers -o custom-columns=':metadata.name'", 
        label: "Get Namespaces",
        returnStdout: true
    if (namespaces.contains(namespace)) {
        echo "Namespace ${namespace} already exists"
    } else {
        sh script: "kubectl create ns ${namespace}",
            label: "Creating namespace ${namespace}"
    }
}

def createServiceAccount(name, namespace) {
    def serviceAccounts = sh script: "kubectl get sa -n ${namespace} --no-headers -o custom-columns=':metadata.name'",
        label: "Get Service Accounts",
        returnStdout: true
    if (serviceAccounts.contains(name)) {
        echo "Service Account ${name} already exists"
    } else {
        sh script: "kubectl create sa ${name} -n ${namespace}",
            label: "Creating service account ${name}"
        sh script: "kubectl create clusterrolebinding ${namespace}-${name} --clusterrole=cluster-admin --serviceaccount=${namespace}:${name}",
            label: "Creating cluster role binding ${namespace}-${name}"
    }
}

// would require checking secrets into repo - bad idea
def createSecret(name, file, namespace) {
    def secrets = sh script: "kubectl get secrets -n ${namespace} --no-headers -o custom-columns=':metadata.name'",
        label: "Get Secrets",
        returnStdout: true
    if (secrets.contains(name)) {
        echo "Secret ${name} already exists"
    } else {
        sh script: "kubectl create secret generic ${name} --from-file=${file} -n ${namespace}",
            label: "Creating secret ${name}"
    }
}

def mergeYaml(files) {
    echo "Merging configuration"
    def config = [:]
    files.each {
        def content = readYaml(file: it)
        if (!content.isEmpty()) {
            config << content
        }
    }
    return config
}

def createConfigMap(name, files, namespace) {
    def configMaps = sh script: "kubectl get configmaps -n ${namespace} --no-headers -o custom-columns=':metadata.name'",
        label: "Get ConfigMaps",
        returnStdout: true
    def config = mergeYaml(files)
    def fileName = "${name}-tmp-file"
    writeYaml file: fileName, data: config
    sh script: "cat ${fileName}", label: "debug"
    if (configMaps.contains(name)) {
        sh script: "kubectl create configmap ${name} -n ${namespace} --from-file ${fileName} -o yaml --dry-run | kubectl replace -f -",
            label: "Updating ConfigMap ${name}"
    } else {
        sh script: "kubectl create configmap ${name} -n ${namespace} --from-file ${fileName}",
            label: "Creating ConfigMap ${name}"
    }
}

def getYaml(directory) {
    def files = sh( script: "ls ${directory}",
        label: "Get Files",
        returnStdout: true).split()
    yamlFiles = []
    files.each {
        if (it.toLowerCase().contains(".yml") || it.toLowerCase().contains(".yaml")) {
            yamlFiles.add "${directory}/${it}"
        } 
    }
    return yamlFiles
}

def install(name, valuesFiles, namespace, extraParams=[:]) {
    def exec = " ${name} stable/${name} -n ${namespace} "
    valuesFiles.each {
        exec += "-f ${it} "
        echo "${exec}"
    }
    exec += "--set "
    extraParams.each {
        exec += "${it},"
    }
    exec = exec[0..-2]
    def installed = sh script: "helm list -n ${namespace}",
        label: "getting installed apps",
        returnStdout: true
    if (installed.contains(name)) {
        exec = "helm upgrade ${exec}"
    } else {
        exec = "helm install ${exec}"
    }
    sh script: exec, label: "deploying ${name}..."
}

def configureHelm(repo) {
    sh script: "helm repo add stable ${repo}",
        label: "adding helm repo..."
    sh script: "helm repo update",
        label: "updating helm repo..."
}



podTemplate(serviceAccount: "jenkins-admin", containers: [containerTemplate(name: 'kubectl', image: 'fscottmiller/kubectl', ttyEnabled: true, command: 'cat'), containerTemplate(name: 'helm', image: 'fscottmiller/helm', ttyEnabled: true, command: 'cat')]) {
    node(POD_LABEL) {
        git branch: BRANCH_NAME, credentialsId: 'ado', url: 'https://dev.azure.com/markelcorp/DevOps%20and%20QE/_git/Jenkins'
        stage('Create Environment') {
            container('kubectl') {
                createNamespace(BRANCH_NAME)
                createServiceAccount('jenkins-admin', BRANCH_NAME)

                def files = getYaml 'casc'
                files.addAll getYaml('instances/master/casc')
                createConfigMap('casc', files, BRANCH_NAME)
            }
        }
        stage('Deploy') {
            container('helm') {
                def extraParams = [:]
                extraParams['master.adminUser'] = 'scott'
                extraParams['master.adminPassword'] = 'admintest'

                configureHelm('https://kubernetes-charts.storage.googleapis.com/')
                install('jenkins', ['values.yaml'], BRANCH_NAME, extraParams)
            }
        }
    }
}
