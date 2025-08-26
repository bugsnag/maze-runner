ARG BRANCH_NAME
FROM 855461928731.dkr.ecr.us-west-1.amazonaws.com/maze-runner:${BRANCH_NAME}-ci

RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
RUN sudo apt-get install -y nodejs

COPY . /app
WORKDIR /app
