FROM jenkins:2.60.3

USER root
RUN echo "deb http://apt.dockerproject.org/repo debian-jessie main" \
         > /etc/apt/sources.list.d/docker.list \
        && apt-key adv --keyserver keyserver.ubuntu.com \
            --recv-keys F76221572C52609D \
        && apt-get update \
        && apt-get install -y apt-transport-https \
        && apt-get install -y sudo \
        && apt-get install -y docker-engine \
        && rm -rf /var/lib/apt/lists/*

RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose	

USER jenkins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

