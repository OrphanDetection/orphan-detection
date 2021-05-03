FROM python:3.8-slim
RUN useradd --create-home --shell /bin/bash user

# Get packages
RUN apt-get update
RUN apt-get install -y parallel
RUN apt-get install -y curl

WORKDIR /home/user
#USER toolname_user
COPY src/ /home/user/orphan-detection/src
COPY Data/ /home/user/orphan-detection/Data
CMD ["bash"]
