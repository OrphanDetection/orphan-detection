FROM python:3.8
RUN useradd --create-home --shell /bin/bash user

COPY ./requirements.txt /home/user/orphan-detection/requirements.txt

# Get packages
RUN apt-get update
RUN apt-get install -y parallel
RUN apt-get install -y curl
#RUN apt-get install -y gcc
RUN pip3 install --upgrade pip setuptools
RUN pip3 install -r /home/user/orphan-detection/requirements.txt

WORKDIR /home/user
#USER toolname_user
COPY src/ /home/user/orphan-detection/src
COPY Data/ /home/user/orphan-detection/Data
CMD ["bash"]
