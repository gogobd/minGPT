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
RUN wget https://github.com/cdr/code-server/releases/download/v3.6.1/code-server-3.6.1-linux-amd64.tar.gz \
 && tar -xzvf code-server-3.6.1-linux-amd64.tar.gz \
 && chmod +x code-server-3.6.1-linux-amd64/code-server \
 && rm code-server-3.6.1-linux-amd64.tar.gz

COPY . /src
WORKDIR /src

# Start container with notebook and vsc
CMD /code-server-3.6.1-linux-amd64/bin/code-server --auth none --bind-addr 0.0.0.0:8080 /src/ & \
    jupyter lab --no-browser --ip 0.0.0.0 --port 8000 --allow-root

# docker build -t pytorch_vsc .
# docker run -v /host/directory/data:/data -p 8000:8000 -p 8080:8080 --ipc=host --gpus all -e SHELL=/bin/bash -it pytorch_vsc
