FROM continuumio/miniconda3

RUN head -1 /tmp/environment.yml | cut -d' ' -f2 > /tmp/version \
   && ln -s "/opt/conda/envs/$(cat /tmp/version)" /opt/conda/venv

# Initialize conda in bash config files:
RUN conda init bash

# Activate the environment, and make sure it's activated:
RUN echo "conda activate $(cat /tmp/version)" >> ~/.bashrc

RUN apt-get -y update \
   # Need to run ps
   && apt-get -y install procps \
   && apt-get -y install libxml2 \
   # Clean
   && conda clean -afy \
   && rm -rf /var/cache/apt/* \
   && rm -rf /var/lib/apt/lists/*

RUN echo "source activate $(cat /tmp/version)" >> ~/.bashrc
ENV PATH="/opt/conda/venv/bin:${PATH}"