FROM python:3
WORKDIR /srv/app
COPY app.py ./
#RUN pip3 install --upgrade pip
RUN pip3 install flask --progress-bar off
RUN pip3 install waitress --progress-bar off
RUN pip3 install paste --progress-bar off
RUN pip3 install boto3 --progress-bar off
CMD [ "python" , "./app.py " ]
