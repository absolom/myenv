cmd='podman'
TUID=1000
TGID=1000
TUNAME=mike
TGNAME=gamers
VERSION=1.0

# Replace "-v /local/path:/container/path" with the paths that should be mounted in the container (multiple -v's can be added)

$cmd build --build-arg UID=$TUID --build-arg GID=$TGID --build-arg UNAME=$TUNAME --build-arg GNAME=$TGNAME -t mimc/alpine-dev:$VERSION .
if [ "$?" == "0" ]; then
  IMAGE_SHA=$($cmd create -v /local/path:/container/path --privileged -it --entrypoint=/bin/bash mimc/alpine-dev:$VERSION)
  $cmd start $IMAGE_SHA
  $cmd attach $IMAGE_SHA
  # $cmd container rm $IMAGE_SHA
  # $cmd image rm mimc/alpine-dev:1.0
fi

