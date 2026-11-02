# darwin

Optimización de circuitos analógicos mediante algoritmos evolutivos (GA y CSA),
con ngspice y el PDK abierto IHP SG13G2 (130 nm).

Proyecto de fin de carrera — Facultad de Ingeniería, Universidad de la República.

## Instalación

```bash
pip install -e ".[dev]"
pytest
```

## Docker

```bash
docker build -f docker/Dockerfile -t darwin:dev .
docker run --rm -it -v "$PWD":/work darwin:dev
```

## Licencia

Apache 2.0
