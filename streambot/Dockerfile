FROM centos:7 AS mp3base
# provide LAME/madplay/taglib

# RUN yum -y install epel-release
RUN yum -y install libid3tag-devel createrepo ncurses-devel

# create package repo and install
WORKDIR /root
ADD pkg mp3pkg/
RUN ["createrepo", "/root/mp3pkg"]
RUN ["chmod", "-R", "o-w+r", "/root/mp3pkg"]
ADD mp3pkg.repo /etc/yum.repos.d/
RUN yum install -y libmad madplay lame lame-devel lame-libs taglib taglib-devel
RUN rm -rf /etc/yum.repos.d/mp3pkg.repo /root/mp3pkg

###

FROM mp3base AS ezstream
# provide ezstream

# deps
RUN yum -y install clang make libxml2-devel libvorbis-devel wget libid3tag-devel flac libtool gettext-devel check-devel file wget git openssl-devel

# build libshout from source
RUN git clone --recurse-submodules --depth 1 https://github.com/xiph/Icecast-libshout.git
RUN cd Icecast-libshout && ./autogen.sh && ./configure && make -j2 && make install
RUN rm -rf Icecast-libshout

ENV EZSTREAM_REL=1_0_1
RUN ["useradd", "-m", "streamer"]
WORKDIR /home/streamer
USER streamer
RUN wget -O ezstream.tar.gz https://github.com/xiph/ezstream/archive/release_${EZSTREAM_REL}.tar.gz
RUN ["tar", "-zxf", "ezstream.tar.gz"]
WORKDIR ezstream-release_1_0_1
RUN ["./autogen.sh"]
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure
RUN ["make", "-j2"]
USER root
RUN ["make", "install"]

###

FROM ezstream AS ice3
# provide ice3 S3 streamer script

# deps
RUN yum -y install python3
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python

USER streamer
WORKDIR /home/streamer

# python deps
ADD pyproject.toml  ./
USER streamer
# python venv
RUN poetry install
RUN ["virtualenv", "venv"]
RUN ["bash", "-c", "source venv/bin/activate"]
# python deps
ADD requirements.txt ./
RUN bash -c source venv/bin/activate && pip install -r requirements.txt

# configuration
ADD ezstream.xml playlist.sh s3playlist.py update-config.sh ./

# cleanup
USER root
RUN ["chown", "-R", "streamer", "/home/streamer"]
RUN yum clean all && \
  rm -rf /var/cache/yum

 # CMD cat ezstream.xml
USER streamer
RUN ["chmod", "og-rw", "ezstream.xml", "playlist.sh", "s3playlist.py"]
CMD ./update-config.sh && echo "Beginning stream..." && ezstream -vv -c ezstream.xml
