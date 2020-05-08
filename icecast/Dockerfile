# ###

# FROM ice3 AS ice3-klulz
# # run script to connect to icecast and stream tunes

# ENV s3bucket=tunes.llolo.lol,\
#   stream_uri=http://streamsource.hard.chat:8000/listen.mp3,\
#   stream_pass=JF819fj13123141fh1083fj1fajIAO


##### ICECAST2
FROM ubuntu:focal AS icecast-klulz

MAINTAINER Mischa Spiegelmock "me@mish.dev"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq -y update && \
  apt-get -qq -y install icecast2 && \
  apt-get clean

EXPOSE 80 80

ADD ./start.sh /start-icecast2.sh
ADD ./icecast2-etc /etc/icecast2
RUN chown -R icecast2 /etc/icecast2 /start-icecast2.sh
USER icecast2

CMD ["/start-icecast2.sh"]
