FROM nvidia/cuda:latest

# Install system dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        curl \
        wget \
        git \
        unzip \
        screen \
        vim \
        net-tools \
    && apt-get clean

# Install python miniconda3 + requirements
ENV MINICONDA_HOME /opt/miniconda
ENV PATH ${MINICONDA_HOME}/bin:${PATH}
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && chmod +x Miniconda3-latest-Linux-x86_64.sh \
    && ./Miniconda3-latest-Linux-x86_64.sh -b -p "${MINICONDA_HOME}" \
    && rm Miniconda3-latest-Linux-x86_64.sh

# JupyterLab
RUN conda install -c conda-forge jupyterlab nodejs

# Code server
RUN wget --quiet https://github.com/cdr/code-server/releases/download/3.2.0/code-server-3.2.0-linux-x86_64.tar.gz \
 && tar -xzf code-server-3.2.0-linux-x86_64.tar.gz \
 && chmod +x code-server-3.2.0-linux-x86_64/code-server \
 && rm code-server-3.2.0-linux-x86_64.tar.gz

COPY . /src
WORKDIR /src

# Requirements
RUN conda install pytorch==1.5.1 torchvision==0.6.1 cudatoolkit=10.2 -c pytorch
RUN conda install -c anaconda numpy

# Start container with notebook and vsc
CMD /code-server-3.2.0-linux-x86_64/code-server --auth none --bind-addr 0.0.0.0:8080 /src/ & \
    jupyter lab --no-browser --ip 0.0.0.0 --port 8000 --allow-root

# docker build -t pytorch_vsc .
# docker run -v /host/directory/data:/data -p 8000:8000 -p 8080:8080 --ipc=host --gpus all -e SHELL=/bin/bash -it pytorch_vsc
