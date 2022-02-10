docker build -t mimc/alpine-dev:1.0 .
if [ "$?" == "0" ]; then
  IMAGE_SHA=$(docker create -it --entrypoint=/bin/bash mimc/alpine-dev:1.0)
  docker start $IMAGE_SHA
  docker attach $IMAGE_SHA
  docker container rm $IMAGE_SHA
  docker image rm mimc/alpine-dev:1.0
fi

# docker create -it --entrypoint=/bin/bash -v /local/path:/mnt --privileged mimc/alpine-dev:1.0