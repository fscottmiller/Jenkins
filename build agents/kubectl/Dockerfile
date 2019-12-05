FROM alpine

# install curl
RUN apk add curl

# download kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
# make kubectl executable
RUN chmod +x ./kubectl
# move kubectl to path
RUN mv ./kubectl /usr/local/bin/kubectl

