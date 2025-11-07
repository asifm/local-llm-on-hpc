#!/bin/bash

export OLLAMA_MODEL="gemma3:4b"

# export OLLAMA_BASE_DIR="/project/orsDarden/ollama"
# In case of permission issues, use
export OLLAMA_BASE_DIR="/scratch/$USER/ollama"

export APPTAINER_CACHE_DIR="${OLLAMA_BASE_DIR}/apptainer_cache"    
export OLLAMA_MODELS="${OLLAMA_BASE_DIR}/models"
export LOG_DIR="${OLLAMA_BASE_DIR}/logs"

echo "Setting up Ollama directories in $OLLAMA_BASE_DIR"

mkdir -p "${OLLAMA_BASE_DIR}"
mkdir -p "${APPTAINER_CACHE_DIR}"
mkdir -p "${OLLAMA_MODELS}"
mkdir -p "${LOG_DIR}"


export OLLAMA_CONTAINER_VERSION="latest"
export OLLAMA_CONTAINER="docker://ollama/ollama:${OLLAMA_CONTAINER_VERSION}"

export OLLAMA_IMAGE="${OLLAMA_BASE_DIR}/ollama.sif"

export OLLAMA_HOST="127.0.0.1:11434"

module purge
echo "Loading apptainer"
module load apptainer

echo "Pulling Ollama container to $OLLAMA_IMAGE"
apptainer pull $OLLAMA_IMAGE $OLLAMA_CONTAINER

LOG_FILE="$LOG_DIR/ollama_$USER_$(date -Iseconds | sed 's/:/-/g').log"
apptainer exec --nv $OLLAMA_IMAGE ollama serve &> $LOG_FILE &

echo "Launched container $OLLAMA_IMAGE"
echo "Runing 'ollama serve' in the background."
echo "Ollama API available on $OLLAMA_HOST/api"
echo "Logging output to $LOG_FILE"

