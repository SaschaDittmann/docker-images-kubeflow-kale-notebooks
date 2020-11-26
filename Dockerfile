ARG IMAGE_TYPE="cpu"
FROM gcr.io/kubeflow-images-public/tensorflow-1.15.2-notebook-${IMAGE_TYPE}:1.0.0
USER root

# Install basic dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates bash-completion tar less \
        python-pip python-setuptools build-essential python-dev \
        python3-pip python3-wheel && \
    rm -rf /var/lib/apt/lists/*

ENV SHELL /bin/bash
COPY bashrc /etc/bash.bashrc
RUN echo "set background=dark" >> /etc/vim/vimrc.local

# Install latest KFP SDK & Kale & JupyterLab Extension
RUN pip3 install --upgrade pip && \
    pip3 install --upgrade "jupyterlab>=2.0.0,<3.0.0" && \
    pip3 install "enum34==1.1.8" && \
    pip3 install https://storage.googleapis.com/ml-pipeline/release/latest/kfp.tar.gz --upgrade && \
    pip3 install -U kubeflow-kale && \
    jupyter labextension install kubeflow-kale-labextension

RUN echo "jovyan ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/jovyan
WORKDIR /home/jovyan
USER jovyan

CMD ["sh", "-c", \
     "jupyter lab --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser \
      --allow-root --port=8888 --LabApp.token='' --LabApp.password='' \
      --LabApp.allow_origin='*' --LabApp.base_url=${NB_PREFIX}"]
