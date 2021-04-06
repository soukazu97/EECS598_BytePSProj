FROM pytorch/pytorch:1.8.0-cuda11.1-cudnn8-devel

RUN pip install psrecord
RUN apt-get update
RUN apt-get install -y linux-tools-common linux-tools-generic linux-tools-`uname -r`

