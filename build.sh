#!/bin/bash
#
# Selects appropriate base images and Qemu archs 
# (but doesn’t yet check if they all exist and all - that’s your homework ;) 
# and also removes unnecessary qemu for amd64
#
# https://github.com/multiarch/qemu-user-static
# https://lobradov.github.io/Building-docker-multiarch-images/
# https://ownyourbits.com/2018/06/27/running-and-building-arm-docker-containers-in-x86/
#

FILE_PATH=$(readlink -f $(dirname $0))  #/home/media/docker-certs-extraction
FILE_NAME=$(basename $0)                #build.sh
FILE_NAME=${FILE_NAME%.*}               #build
FILE_DATE=$(date +'%Y%m%d-%H%M%S')
FILE_LOG="/var/log/$FILE_NAME.log"

DOCKER_USER="joweisberg"

if [ -z "$1" ] || [ -z "$(echo $1 | grep '/')" ]; then
  echo "* Require one parameter as <docker_user/docker_respository>:"
  # ./build.sh certs-extraction
  echo "* ./$(basename $0) $DOCKER_USER/$(echo ${FILE_PATH##*/} | sed 's/docker-//g')"
  exit 1
fi
DOCKER_USER=$(echo $1 | cut -d'/' -f1)
DOCKER_REPO=$(echo $1 | cut -d'/' -f2)

echo "* Sign In to https://hub.docker.com/u/$DOCKER_USER"
docker login -u $DOCKER_USER docker.io
if [ $? -ne 0 ]; then
  exit 1
fi

if [ $(apt list --installed 2> /dev/null | grep qemu | wc -l) -eq 0 ]; then
  echo "* Intstall QEMU user emulation to run ARM containers"
  sudo apt -y install qemu-user
fi

# To fix this issue the kernel needs to know what to do when requested to run ARM ELF binaries.
# https://www.balena.io/blog/building-arm-containers-on-any-x86-machine-even-dockerhub/
if [ ! -f ./.binfmt_misc.txt ]; then
  echo "* Fix issue ARM kernel on x86 machine"
  sudo umount /proc/sys/fs/binfmt_misc
  sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
  echo ':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:' | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null 2>&1
  echo ":qemu-aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-aarch64-static:" | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null 2>&1
  docker run --rm --privileged multiarch/qemu-user-static:register --reset > /dev/null 2>&1
  date > ./.binfmt_misc.txt
fi

echo "* Cleanup previous temporary files"
rm -f Dockerfile.a* qemu-* x86_64_qemu-*

echo "* Create different Dockerfile per architecture"
for docker_arch in amd64 arm32v6 arm64v8; do
  case ${docker_arch} in
    amd64   ) qemu_arch="x86_64" ;;
    arm32v6 ) qemu_arch="arm" ;;
    arm64v8 ) qemu_arch="aarch64" ;;    
  esac
  cp Dockerfile.cross Dockerfile.${docker_arch}
  sed -i "s|__BASEIMAGE_ARCH__|${docker_arch}|g" Dockerfile.${docker_arch}
  sed -i "s|__QEMU_ARCH__|${qemu_arch}|g" Dockerfile.${docker_arch}
  if [ ${docker_arch} == "amd64" ]; then
    sed -i "/__CROSS_/d" Dockerfile.${docker_arch}
  else
    sed -i "s/__CROSS_//g" Dockerfile.${docker_arch}
  fi
done

echo "* Download OS architecture qmenu"
echo "* qemu-user-static latest versions:"
git ls-remote --tags --refs https://github.com/multiarch/qemu-user-static.git | cut -d'v' -f2 | sort -nr 2> /dev/null | head -n5
# Get qemu-user-static latest version
if [ -f ./.qemu_ver.txt ]; then
  qemu_ver=$(cat ./.qemu_ver.txt)
else
  qemu_ver=$(git ls-remote --tags --refs https://github.com/multiarch/qemu-user-static.git | cut -d'v' -f2 | sort -nr 2> /dev/null | head -n1)
fi
echo -n "* Enter qemu-user-static version <${qemu_ver}>? "
read answer
if [ -n "$answer" ]; then
  qemu_ver=$answer
fi
echo ${qemu_ver} > ./.qemu_ver.txt
for target_arch in x86_64 arm aarch64; do
  wget -Nq https://github.com/multiarch/qemu-user-static/releases/download/v${qemu_ver}/x86_64_qemu-${target_arch}-static.tar.gz
  tar -xvf x86_64_qemu-${target_arch}-static.tar.gz
  if [ $? -ne 0 ]; then
    exit 1
  fi
done

echo "* Building and tagging individual images"
for docker_arch in amd64 arm32v6 arm64v8; do
  if [ ${docker_arch} == "amd64" ]; then
    docker build -f Dockerfile.${docker_arch} -t $DOCKER_USER/$DOCKER_REPO:latest .
    if [ $? -ne 0 ]; then
      echo "* Error on building image $DOCKER_USER/$DOCKER_REPO:latest"
      exit 1
    fi
    docker push $DOCKER_USER/$DOCKER_REPO:latest
  fi
  docker build -f Dockerfile.${docker_arch} -t $DOCKER_USER/$DOCKER_REPO:${docker_arch}-latest .
  if [ $? -ne 0 ]; then
    echo "* Error on building image $DOCKER_USER/$DOCKER_REPO:${docker_arch}-latest"
    exit 1
  fi
  docker push $DOCKER_USER/$DOCKER_REPO:${docker_arch}-latest
done

echo "* Building a multi-arch manifest"
docker manifest create --amend $DOCKER_USER/$DOCKER_REPO:latest $DOCKER_USER/$DOCKER_REPO:amd64-latest $DOCKER_USER/$DOCKER_REPO:arm32v6-latest $DOCKER_USER/$DOCKER_REPO:arm64v8-latest
docker manifest push --purge $DOCKER_USER/$DOCKER_REPO:latest

echo "* Cleanup unnecessary files"
rm -f Dockerfile.a* qemu-* x86_64_qemu-*

echo -n "* Remove QEMU user emulation package? [y/N]"
read answer
if [ -n "$(echo $answer | grep -i '^y')" ]; then
  sudo apt -y remove --autoremove qemu-user
fi

exit 0