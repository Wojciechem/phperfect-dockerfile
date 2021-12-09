# phperfect-dockerfile
Attempt to create the "perfect" dockerfile for php projects.  
As always, it is _opinionated_ and may be subject to change.



## Work in progress / TODO
- [x] use build-time cache mount for apt & composer
- [x] use buildx bake
- [x] try the experimental [github actions cache](https://github.com/tonistiigi/go-actions-cache/blob/master/api.md).
- [ ] set up something more elaborate on php side (small symfony project?)
- [x] set up self-hosted runner (with warm cache) for speed comparison
- [ ] fix composer cache error 😅
- [ ] code reuse in dockerfile?
  - [ ] decide afterwards - is it worth it?

## Building

This project makes use of the 
[docker buildx](https://github.com/docker/buildx) 
plugin for some nice [BuildKit](#buildkit) capabilities.  

### To build the image(s), run:
```shell
docker buildx bake
```

### Optionally, with custom tag:
```shell
PHPERFECT_TAG=123 docker buildx bake
```

It should build three `phperfect` images with respective tags:
- dev-latest
- latest
- ci-latest

## Using the container
### Dev
This is the container that you can use with volume for local development & debugging.  
Example:
```shell
docker run -v `pwd`:/app phperfect:dev-latest composer install
```

### Prod, aka "give it to your compliance team first"
This container will, well, contain, a built, ready-to-serve-requests app with no volumes attached.
It uses `php-prod` multistage target.  
Use this target for your-app-specific code.

### CI
essentially prod + dev dependencies (test frameworks etc.)
Idea is - you can deploy tens of replicas of CI container to run extensive tests in parallel.

## Why _x_ was used?
### Buildkit
TLDR: build time apt & composer cache, using custom RUN --mount 
[syntax](https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/syntax.md#run---mounttypecache).  

You can read more about BuildKit itself in the [official BuildKit repo](https://github.com/moby/buildkit)

### docker-php-extension-installer
I hate to manually resolve dependencies for each php extension I need.  
[mlocati/docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer)
solves exactly this problem.  
If you know better than that, please let me know :)