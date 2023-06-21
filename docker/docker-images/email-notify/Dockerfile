FROM python:3.7-slim

COPY requirements.txt /
WORKDIR /
RUN pip install --no-cache-dir -r requirements.txt

COPY pipe /
COPY pipe.yml Readme.md /

ENTRYPOINT ["python3", "/pipe.py"]
