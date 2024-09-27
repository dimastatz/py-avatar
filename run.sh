#!/bin/bash

abort()
{
    echo "*** FAILED ***" >&2
    exit 1
}

if [ "$#" -eq 0 ]; then
    echo "No arguments provided. Usage: 
    1. '-init' to build clean local environment
    2. '-docker' to build and run docker container
    3. '-cli' run avatar creation"
elif [ $1 = "-init" ]; then
    trap 'abort' 0
    set -e
    
    echo "Clone SadTalker"
    rm -rf SadTalker 
    git clone https://github.com/OpenTalker/SadTalker.git
    cd SadTalker 

    echo "Conda Create"
    conda install ffmpeg
    conda create -n sadtalker python=3.8
    conda init
    conda activate sadtalker
    pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113
    pip install -r requirements.txt
    pip install TTS

elif [ $1 = "-cli" ]; then
    trap 'abort' 0
    set -e
    python inference.py --driven_audio ../resources/dima.wav --source_image ../resources/dima.jpeg --enhancer gfpgan 
    
elif [ $1 = "-docker" ]; then
    echo "Building and running docker image"
    docker stop whisperflow-container
    docker rm whisperflow-container
    docker rmi whisperflow-image
    # build docker and run
    docker build --tag whisperflow-image --build-arg CACHEBUST=$(date +%s) .
    docker run --name whisperflow-container -p 8888:8888 -d whisperflow-image
else
  echo "Wrong argument is provided. Usage:
    1. '-init' to build clean local environment
    2. '-docker' to build and run docker container
    3. '-test' to run linter, formatter and tests"
fi

trap : 0
echo >&2 '*** DONE ***'