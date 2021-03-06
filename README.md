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

You can mount the ```Data``` folder to have access to the results on your host system (i.e. outside the Docker container). The command below shows how. **Please make sure the path is 1) absolute, and 2) pointing to the Data folder in this project**.
```console
foo@bar:~$ docker run -v [absolute-path-to-Data-folder]:/home/user/orphan-detection/Data -it --name my_detection --rm orphan-detection
```

### Instructions
You can use our implementation by navigating to the ```orphan-detection/src``` folder, and running the ```main.sh``` script providing a domain name:
```console
root@docker:~$ cd orphan-detection/src
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

You can find the results of your run in ```Data/Results/[domain-name]/[domain-name]_potential_orphans```.

### Analysis

In case you want to do an additional automated analysis on the potential orphan pages you can run

 ```console
root@docker:~$ bash analysis.sh [domain-name] [date]
```

where ```[date]``` represents the date on which the archive file was downloaded.

Please note, however, that the analysis code was tailored for a large-scale analysis, and can, hence, drastically filter the list of potential orphan pages. We therefore recommend website administrators to be careful with this step, and consider omitting it, as they might already recognize the pages that should not be accessible anymore from the potential orphan list (produced by ```main.sh```).

The results of the analysis can be found in ```Data/Results/[domain-name]/[domain-name]_analysis_results```.
