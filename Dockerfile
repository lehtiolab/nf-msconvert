FROM nfcore/base:1.7
LABEL authors="Jorrit Boekel" \
      description="Docker image containing all requirements for nf-core/msconvert pipeline"

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/nf-core-msconvert-1.0dev/bin:$PATH
