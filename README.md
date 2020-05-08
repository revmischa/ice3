# Quickstart
cp sample/* ./
# edit icecast.xml and streambot.env
docker-compose up

# Bleh
This is a containerized ezstremer streamer for automating streaming of audio files to an icecast server.

It runs in docker, you just need to set some environment variables.

It grabs audio files at random out of a S3 bucket that you specify and streams them.

The environment variables are:
* BUCKET_NAME (name of bucket containing audio files)
* STREAM_URL (icecast2 mountpoint)
* STREAM_USER (mountpoint username)
* STREAM_PASS (mountpoint password)
* STREAM_NAME
* INFO_URL
* GENRE
* DESCRIPTION
* SQS_URL (to post track updates to)
* SNS_ARN (to post track updates to)

![Setup](env.png "Setup")
