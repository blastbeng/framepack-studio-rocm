ARG CUDA_VERSION=12.4.1

#FROM nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu22.04
FROM rocm/pytorch:rocm6.4.2_ubuntu24.04_py3.12_pytorch_release_2.6.0

ARG CUDA_VERSION

RUN apt-get update && apt-get install -y \
    python3 python3-pip git ffmpeg wget curl && \
    pip3 install --upgrade pip

WORKDIR /app

# This allows caching pip install if only code has changed
COPY requirements.txt .

# Install dependencies
#RUN pip3 install --no-cache-dir -r requirements.txt
#RUN export CUDA_SHORT_VERSION=$(echo "${CUDA_VERSION}" | sed 's/\.//g' | cut -c 1-3) && \
#    pip3 install --no-cache-dir torch torchvision torchaudio --index-url "https://download.pytorch.org/whl/cu${CUDA_SHORT_VERSION}"

RUN pip3 install -U pip
RUN pip3 install -r requirements.txt
RUN pip3 uninstall -y torch torchvision pytorch-triton-rocm
RUN pip3 install https://repo.radeon.com/rocm/manylinux/rocm-rel-6.4.2/torch-2.6.0%2Brocm6.4.2.git76481f7c-cp312-cp312-linux_x86_64.whl https://repo.radeon.com/rocm/manylinux/rocm-rel-6.4.2/torchvision-0.21.0%2Brocm6.4.2.git4040d51f-cp312-cp312-linux_x86_64.whl https://repo.radeon.com/rocm/manylinux/rocm-rel-6.4.2/pytorch_triton_rocm-3.2.0%2Brocm6.4.2.git7e948ebf-cp312-cp312-linux_x86_64.whl https://repo.radeon.com/rocm/manylinux/rocm-rel-6.4.2/torchaudio-2.6.0%2Brocm6.4.2.gitd8831425-cp312-cp312-linux_x86_64.whl

RUN rm $(pip3 show torch | grep Location | awk -F ": " '{print $2}')/torch/lib/libhsa-runtime64.so*

RUN pip3 install -q transformers accelerate matplotlib hiredis

RUN git clone --single-branch --branch main_perf https://github.com/ROCm/flash-attention.git
WORKDIR  /app/flash-attention/
ENV FLASH_ATTENTION_TRITON_AMD_ENABLE="TRUE"
ENV GPU_ARCHS="gfx1101"
RUN python setup.py install
WORKDIR /app
RUN rm -rf flash-attention

# Copy the source code to /app
COPY . .

RUN ln -s /app/modules/toolbox/bin/ffmpeg /usr/bin/ffmpeg
RUN ln -s /app/modules/toolbox/bin/ffprobe /usr/bin/ffprobe

VOLUME [ "/app/.framepack", "/app/outputs", "/app/loras", "/app/hf_download", "/app/modules/toolbox/model_esrgan", "/app/modules/toolbox/model_rife" ]

EXPOSE 7860

CMD ["python3", "studio.py"]
