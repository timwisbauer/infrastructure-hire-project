FROM python:3.8-alpine

WORKDIR /contrast-project2

RUN adduser project2 --no-create-home --disabled-password && \
    chown project2 /contrast-project2

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY proxy.py .

USER project2

CMD ["python", "proxy.py"]

