# Start from a Java image.
FROM openjdk:8 as builder

# Ignite version
ENV IGNITE_VERSION 2.7.5

# Ignite home
ENV IGNITE_HOME /opt/ignite

# Do not rely on anything provided by base image(s), but be explicit, if they are installed already it is noop then
RUN apt-get update && apt-get install -y --no-install-recommends \
        unzip \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

ENV IGNITE_NIGHTLY="https://ci.ignite.apache.org/repository/download/Releases_NightlyRelease_RunApacheIgniteNightlyRelease/4165221:id/apache-ignite-2.8.0.20190621-bin.zip"
ENV IGNITE_SRC=https://codeload.github.com/apache/ignite/zip/master
ENV IGNITE_STABLE=http://mirrors.viethosting.com/apache/ignite/${IGNITE_VERSION}/apache-ignite-${IGNITE_VERSION}-bin.zip

RUN curl --cookie "TCSESSIONID=8F8164C2DBB0CE2E4738F39014A7650D" $IGNITE_NIGHTLY -o ignite.zip \
    && unzip ignite.zip \
    && mv apache-ignite-* $IGNITE_HOME\
    && rm ignite.zip

FROM openjdk:8
ENV IGNITE_HOME /opt/ignite

WORKDIR $IGNITE_HOME

ENV CONFIG_URI=$IGNITE_HOME/conf/ignite-k8s.xml
ENV OPTION_LIBS=ignite-kubernetes

COPY --from=builder $IGNITE_HOME $IGNITE_HOME
# Copy sh files and set permission
COPY ./run.sh $IGNITE_HOME/

RUN chmod +x $IGNITE_HOME/run.sh

COPY ./kubernetes/conf/kube-rbac.xml $IGNITE_HOME/conf/ignite-k8s.xml

CMD $IGNITE_HOME/run.sh

EXPOSE 11211 47100 47500 49112
