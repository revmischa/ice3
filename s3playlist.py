"""S3 bucket playlist generator."""

import boto3
import random
import sys
import logging
import os

logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger(__name__)


class S3Playlister():
    """Grabs files from the specified bucket and plays a random one."""

    def __init__(self, bucket_name):
        """Save bucket name."""
        assert(bucket_name)
        self.bucket_name = bucket_name
        self._s3 = None
        # create storage area
        from os.path import expanduser
        storage_dir = expanduser("~/s3playlist")
        if not os.path.exists(storage_dir):
            os.makedirs(storage_dir)
        self.storage_dir = storage_dir
        boto3.set_stream_logger('botocore', level=logging.WARN)
        boto3.set_stream_logger('s3transfer', level=logging.WARN)
        boto3.set_stream_logger(level=logging.WARN)

    def get_next_file(self):
        """Return next S3 file to play.

        May download the file.
        """
        files = self.get_s3_files()
        keys = [f['Key'].encode('utf-8') for f in files]
        mp3keys = set([k for k in keys if self.is_key_playable(k)])
        if not mp3keys:
            self._fail("No files found in bucket")
        # pick random key, get file obj
        mp3key = random.sample(mp3keys, 1)[0]
        mp3keyobj = None
        # search and find the response obj
        for f in files:
            if f['Key'] == mp3key:
                mp3keyobj = f
                break
        else:
            self._fail("Couldn't locate file with key", mp3key)

        # do we have this file already?
        fpath = os.path.join(self.storage_dir, self._slugify(mp3key))
        if os.path.exists(fpath):
            # TODO: compare last modified times
            # lastmod = os.path.getmtime(fpath)
            pass
        else:
            # make dirs
            dpath = os.path.dirname(fpath)
            if not os.path.exists(dpath):
                os.makedirs(dpath)
            # download it
            self.bucket().download_file(mp3keyobj['Key'], fpath)

        return fpath

    def _slugify(self, k):
        return k.replace(r'[\s\/]', '-')

    def _fail(self, *err):
        for e in err:
            log.error(e)
        sys.exit(1)

    def get_s3_files(self):
        """List the files in the bucket."""
        ret = []

        def get_more(tok=''):
            return self.s3client().list_objects_v2(
                Bucket=self.bucket_name,
                StartAfter=tok,
            )
        res = get_more()
        ret.extend(res['Contents'])

        while res['IsTruncated']:
            tok = res['ContinuationToken']
            res = get_more(tok)
            ret += res['Contents']
        return ret

    def is_key_playable(self, s3key):
        """Return if the filename looks like a file we can play or not."""
        endings = ['.mp3', '.wav', '.flac', '.ogg']
        for end in endings:
            if s3key.endswith(end):
                return True
        return False

    def can_list_bucket(self):
        """Check if we can list the bucket."""
        # throws error if fails
        client = self.s3client()
        client.head_bucket(Bucket=self.bucket_name)

    def bucket(self):
        """Return boto3 S3 bucket object."""
        return boto3.resource('s3').Bucket(self.bucket_name)

    def s3client(self):
        """Get S3 client."""
        if self._s3 is not None:
            return self._s3
        self._s3 = boto3.client('s3')
        return self._s3

if __name__ == '__main__':
    if len(sys.argv) != 2 or not sys.argv[1]:
        print("Please specify bucket name")
        sys.exit(1)
    bucket_name = sys.argv[1]

    pl = S3Playlister(bucket_name)

    print(pl.get_next_file())
