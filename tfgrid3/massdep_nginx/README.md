# Development Guide for Mass_dep image

#### Image
image contains only ssh and nginx 

### Pull the image
```bash
docker pull threefolddev/nginx-massdep
```

### Build the image
```bash
docker build -t threefolddev/nginx-massdep .
```

### RUN the image
```bash
sudo docker run -d --name <container_name> threefolddev/nginx-massdep
```
