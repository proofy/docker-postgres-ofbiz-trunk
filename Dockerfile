FROM openjdk:11-jdk-bullseye as ofbiz
ENV JAVA_OPTS -Xmx2G
RUN apt-get -y update && apt-get -y dist-upgrade && apt-get -qq -y install unzip wget 
# you can build with your own repos e.g. with git daemon --base-path=. --export-all --reuseaddr --informative-errors --verbose 
# and ocker build -t ofbiz:trunk --build-arg REPOS_FRAMEWORK_URL=git://192.168.122.1/ofbiz-framework --build-arg REPOS_PLUGIN_URL=git://192.168.122.1/plugins .
ARG REPOS_FRAMEWORK_URL="https://gitbox.apache.org/repos/asf/ofbiz-framework.git"
ARG REPOS_PLUGIN_URL="https://gitbox.apache.org/repos/asf/ofbiz-plugins.git"
RUN git clone $REPOS_FRAMEWORK_URL ofbiz-framework \
 && git clone $REPOS_PLUGIN_URL plugins
#RUN ln -s ./plugins ./ofbiz-framework/plugins 

WORKDIR /ofbiz-framework
RUN ./gradlew cleanAll
RUN ./gradlew build 
EXPOSE 8080
EXPOSE 8443
EXPOSE 8009

#ENTRYPOINT [ "/ofbiz-framework/gradlew"]
#CMD ["ofbiz --start"]
#TODO: extrace binary from build
FROM ofbiz as ofbiz-postgres
WORKDIR /ofbiz-framework
ENV JDBC_LIB_FILE="postgresql-42.4.1.jar" 
ENV DB_HOST="127.0.0.1"
ENV DB_NAME="ofbiz"
ENV DB_USER="ofbiz"
ENV DB_PASSWORD="ofbiz"
ENV DOMAINLIST="localhost,127.0.0.1"
COPY entrystart.sh /ofbiz-framework/entrystart.sh
RUN chmod +x /ofbiz-framework/entrystart.sh
ENTRYPOINT [ "/ofbiz-framework/entrystart.sh"]
