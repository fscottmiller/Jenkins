# Jenkins

## Usage
This instance of Jenkins is run as a container. To run on a local environment, use Docker. Otherwise, run using Kubernetes.

To build the image:
`docker build . -t <image name>`
To run the container:
`docker run -d -p 8080:8080 -p 50000:50000 --name <container name> <image name>`

For production, no changes to configuration should be made in the Jenkins UI, including installing plugins, creating jobs, adding users - anything except running jobs. Instead, the changes should be made in this repository. Then, a new image should be created and deployed to production.

## Installing Plugins
The plugins for an instance of Jenkins are installed when the image is built. Plugins should be listed in plugins.txt. 

Once we start using Kubernetes, we may want to switch to Helm configurations for installing plugins instead of using the script provided in the Jenkins image.

Format for plugins.txt:
`<plugin short name>:<plugin version>`
Note that plugin version defaults to latest if not specified. More options for plugins.txt can be found at https://github.com/jenkinsci/docker/#preinstalling-plugins.

## Configuration as Code
The configuration for Jenkins is all documented as yaml files in the config directory. For information about how to write configuration yaml files, see https://github.com/jenkinsci/configuration-as-code-plugin.

## SSL Configuration
Currently, when the image is built, a self-signed certificate is generated in a Java keystore on the container. This self-signed certificate is being used by Jenkins to configure SSL.

## Todos
In no particular order:
1. Create an Artifactory remote repository for plugins. We can use this to mirror the Jenkins Update Center, which would allow us to scan plugins with Xray before using them.
    - We should probably do this for the base container image as well.
2. Create an Artifactory repository to store the built Jenkins images.
3. Create a CI process for building, testing, and deploying Jenkins container images.
4. Build agent container images for jobs and pipelines.
5. Document our Jenkins configuration as code.
6. Devise a secure way to add the SSL key to the image.
7. Create seed jobs for projects, folders, and views.