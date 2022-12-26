docker build --no-cache -t custom-apt-cacher-ng .
# Push to Private Docker Repo
docker tag 10.27.30.200:2021/custom-apt-caher-ng:latest
docker push 10.27.30.200:2021/custom-apt-caher-ng:latest