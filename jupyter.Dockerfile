FROM jupyter/scipy-notebook
# FROM nvidia/cuda:10.2-cudnn7-runtime-ubuntu18.04

ENV DEBIAN_FRONTEND noninteractive

USER root
RUN apt-get update --fix-missing
RUN apt-get install -y \
    net-tools iputils-ping \
    build-essential cmake git \
    curl wget \
    gcc vim \
    libjpeg-dev libpng-dev \
    libtiff-dev libgtk2.0-dev \
    locales zsh \
    imagemagick ffmpeg \
    zip p7zip-full p7zip-rar \
    libomp5 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV ZSH_THEME agnoster
RUN locale-gen en_US.UTF-8
RUN /bin/sh -c chsh -s /bin/zsh

ENV SHELL /bin/zsh
ENV LANG=en_US.UTF-8

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN conda init zsh

RUN curl -fsSL https://code-server.dev/install.sh | sh


USER $NB_UID
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/
RUN pip install --quiet --no-cache-dir -r /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

COPY --chown=${NB_UID}:${NB_GID} conda_req.txt /tmp/
RUN /bin/zsh -c "conda install --file /tmp/conda_req.txt"

COPY --chown=${NB_UID}:${NB_GID} cforge_req.txt /tmp/
RUN conda install -yc conda-forge --file /tmp/cforge_req.txt

# venv ml specifics
RUN conda create -y -n ml python=3.7
# RUN /opt/conda/bin/conda install -yc conda-forge --file /tmp/cforge_req.txt -n ml
# RUN /bin/zsh -c "conda install --file /tmp/conda_req.txt -n ml"
# RUN /bin/zsh -c 'source activate ml && pip install --quiet --no-cache-dir -r /tmp/requirements.txt && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}"'

RUN mkdir -p "/home/${NB_USER}/.local/share/code-server/extensions"
RUN mkdir -p "/home/${NB_USER}/.local/share/code-server/User"
COPY settings.json "/home/${NB_USER}/.local/share/code-server/User"
RUN wget https://github.com/microsoft/vscode-python/releases/latest/download/ms-python-release.vsix
RUN code-server --install-extension ms-python-release.vsix

# https://jupyterlab-code-snippets-documentation.readthedocs.io/en/latest/index.html
RUN jupyter labextension install jupyterlab-code-snippets
RUN jupyter lab clean
RUN jupyter lab build

RUN mkdir -p "/home/${NB_USER}/work"

# Jupyter and Tensorboard ports
EXPOSE 8888 6006