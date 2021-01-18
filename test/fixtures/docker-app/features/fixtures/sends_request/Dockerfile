FROM ubuntu

RUN apt-get update && apt-get install curl -y

CMD echo "SOME OUTPUT\n" && curl -F somedata=data http://docker-tests:9339/notify
