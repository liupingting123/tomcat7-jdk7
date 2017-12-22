FROM openshift/base-centos7

MAINTAINER Ed Veretinskas <ed@mits4u.co.uk>

# Inform about software versions being used inside the builder
ENV TOMCAT_VERSION=7.0.82 \
    TOMCAT_MAJOR=7 \
    MAVEN_VERSION="3.3.9" \
    M2_HOME="/usr/local/apache-maven/apache-maven-3.3.9" \
    CATALINA_HOME="/usr/local/tomcat" \
    APP_ROOT="/opt/app-root/" \
    POM_PATH=. \
    DEBUG="false"

ENV PATH="${PATH}:${M2_HOME}/bin:${CATALINA_HOME}/bin"
#RUN mkdir -p "$CATALINA_HOME"
# Set labels used in OpenShift to describe the builder images
LABEL   io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
        io.openshift.tags="builder,java,tomcat7-jdk7" \
        summary="Builder image for creating tomcat7-jdk7 micro-services" \
        name="openshift-tomcat7-jdk7" \
        java.version="${JAVA_VERSION}" \
        java.architecture="x86_64" \
        java.vendor="mits4u.co.uk"

# Install JAVA_VERSION
RUN yum install -y java-1.7.0-openjdk 


# Install Maven
RUN curl -O http://www.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
 && mkdir -p /usr/local/apache-maven && tar zxvf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /usr/local/apache-maven \
 && rm -rf apache-maven-${MAVEN_VERSION}-bin.tar.gz \
 && chmod 775 -R /usr/local/apache-maven

# install tomcat 
RUN curl -O https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
 && mkdir -p ${CATALINA_HOME} && tar zxvf apache-tomcat-$TOMCAT_VERSION.tar.gz -C /usr/local/tomcat \
 && rm -rf apache-tomcat-$TOMCAT_VERSION.tar.gz \
 && chmod 775 -R /usr/local/tomcat
 
 
# Copy the S2I scripts from ./.s2i/bin/ to /usr/local/s2i when making the builder image
COPY ./.s2i/bin/ /usr/local/s2i
RUN chmod -R 755 /usr/local/s2i

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 ${APP_ROOT}

# Set the default user for the image, the user itself was created in the base image
USER 1001

# Specify the ports the final image will expose
EXPOSE 8080

ADD README.md /usr/local/s2i/usage.txt
CMD [ "/usr/local/s2i/usage" ]
