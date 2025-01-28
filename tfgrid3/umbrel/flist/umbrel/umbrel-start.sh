set -x
while ! docker info > /dev/null 2>&1; do
    sleep 2
done

docker-compose -f /umbrel/docker-compose.yaml up -d
