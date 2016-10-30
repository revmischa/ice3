FROM revmischa/ezstream:latest

# deps
RUN ["yum", "-y", "install", "python-virtualenv"]

WORKDIR /home/streamer

# python deps
ADD requirements.txt  ./
USER streamer
# python venv
RUN ["virtualenv", "venv"]
RUN ["bash", "-c", "source venv/bin/activate && easy_install pip"]
# python deps
ADD requirements.txt ./
RUN ["bash", "-c", "source venv/bin/activate && pip install -r requirements.txt"]

# configuration
ADD ezstream.xml playlist.sh s3playlist.py update-config.sh ./
USER root
RUN ["chown", "-R", "streamer", "/home/streamer"]
USER streamer
RUN ["chmod", "og-rw", "ezstream.xml", "playlist.sh", "s3playlist.py"]

# # CMD cat ezstream.xml
CMD ./update-config.sh && echo "Beginning stream..." && ezstream -vv -c ezstream.xml
