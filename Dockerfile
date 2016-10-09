FROM revmischa/mp3:latest

ARG s3path="s3://s3-us-west-2.amazonaws.com/tunes.llolo.lol/01_walking-on-water-original-mix.wav"

ENV BOOTSTRAP_DIR="/home/streamer/ice3"

# for building
# RUN sysctl -w net.ipv6.conf.all.disable_ipv6=1
# RUN sysctl -w net.ipv6.conf.default.disable_ipv6=1

RUN ["yum", "-y", "install", "gcc", "make", "libshout-devel", "libxml2-devel", "taglib-devel", "libvorbis-devel", "wget", "libid3tag-devel"]

RUN ["useradd", "-m", "streamer"]
WORKDIR /home/streamer
USER streamer
RUN mkdir $BOOTSTRAP_DIR
WORKDIR $BOOTSTRAP_DIR
RUN ["wget", "http://downloads.xiph.org/releases/ezstream/ezstream-0.6.0.tar.gz"]
RUN ["tar", "-zxf", "ezstream-0.6.0.tar.gz"]
WORKDIR ezstream-0.6.0
RUN ["./configure"]
RUN ["make", "-j2"]
USER root
RUN ["make", "install"]
# USER streamer

CMD ezstreamer
