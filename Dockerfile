FROM jenkins/jenkins

# set up keystore for SSL
USER root
RUN keytool -genkey -noprompt \
    -alias jenkins \
    -dname "CN=jenkins, OU=DevOps, O=Markel, L=Richmond. S=Virginia, C=US" \
    -keypass jenkins \
    -keyalg RSA \
    -keysize 2048 \ 
    -storepass jenkins \ 
    -keystore jenkins.jks

USER jenkins

# stop the setup wizard
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false ${JAVA_OPTS:-}"

# install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# config as code
COPY config /var/lib/jenkins/config
ENV CASC_JENKINS_CONFIG "/var/lib/jenkins/config"

# insert startup script
# COPY init.groovy $JENKINS_HOME/init.groovy

ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8443 --httpsKeyStore=jenkins.jks --httpsKeyStorePassword=jenkins

