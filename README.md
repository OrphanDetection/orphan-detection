## Orphan Detection
We provide a docker image containing all the requirements for our implementation. The idea is to get a shell into the docker image and run the code there.
You can build the image as follows:

```console
foo@bar:~$ docker build -t orphan-detection --rm .
```
And run it like this:

```console
foo@bar:~$ docker run -it --name my_detection --rm orphan-detection
```
After which a shell should appear inside the docker container.

If you want to mount the ```Data``` folder to have access to the results on your host system (i.e. outside the Docker container), you can modify the above command as follows:
```console
foo@bar:~$ docker run -v [absolute-path-to-Data-folder]:/home/user/orphan-detection/Data -it --name my_detection --rm orphan-detection
```

### Instructions
You can use our implementation by running the ```main.sh``` script and providing a domain name:
```console
root@docker:~$ bash main.sh [domain-name]
```

#### Omit download phase
If you want to use a previously downloaded version of the archive data, you can skip the downloading phase by providing the ```-s```
 flag, along with the date of the previously downloaded archive data:
 ```console
root@docker:~$ bash main.sh -s 2021-04-20 [domain-name]
```
#### Use Dynamic URL Detection (DUDe)
If you want to use our Dynamic URL Detection heuristic to filter out some of the pages, use the ```-d``` flag:
 ```console
root@docker:~$ bash main.sh -d [domain-name]
```
We recommmend doing this as it significantly reduces the number of URLs to probe. The input parameters of the heuristic can be configured in ```Data/Input/dude_parameters/```. You can change the ```default``` file, or create a new file and adjust to code to use the new file (making it easier to switch and store previous configurations).
