# Tahap 1: pasang dependensi Python ke direktori sementara
FROM python:3.11-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Tahap 2: image runtime, hanya membawa hasil pemasangan dan kode
FROM python:3.11-slim

LABEL org.opencontainers.image.title="sentra" \
      org.opencontainers.image.description="Layanan contoh Sentra Digital Batam" \
      org.opencontainers.image.authors="Muhammad Dimas Ardiansyah"

# Proses aplikasi tidak boleh berjalan sebagai root
RUN groupadd --system sentra \
 && useradd --system --gid sentra --home-dir /app sentra

WORKDIR /app
COPY --from=builder /install /usr/local
COPY --chown=sentra:sentra src/ ./src/

ENV HOST=0.0.0.0 \
    PORT=5000
EXPOSE 5000
USER sentra

# Docker menandai container sehat bila /health menjawab 200
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD python3 -c "import urllib.request as u,sys; sys.exit(0 if u.urlopen('http://127.0.0.1:5000/health').status==200 else 1)"

CMD ["python3", "src/app.py"]
