#!/bin/bash

# Edit this line to use a different model (https://ollama.com/search)
export OLLAMA_MODEL="gemma3:270m"
echo "Model selected: $OLLAMA_MODEL"

# === Setting up paths 
# You can change this if you want. 
export OLLAMA_BASE_DIR="/scratch/$USER/ollama"

echo "Setting up directories in $OLLAMA_BASE_DIR"

export OLLAMA_MODELS="${OLLAMA_BASE_DIR}/models"
export LOG_DIR="${OLLAMA_BASE_DIR}/logs"
mkdir -p "$OLLAMA_BASE_DIR" "$OLLAMA_MODELS" "$LOG_DIR"

export APPTAINER_CACHEDIR="${OLLAMA_BASE_DIR}/apptainer_cache"
export APPTAINER_TMPDIR="${OLLAMA_BASE_DIR}/tmp"
mkdir -p "$APPTAINER_CACHEDIR" "$APPTAINER_TMPDIR"
# ===


module purge
echo "Loading apptainer module"
module load apptainer


# === Pulling Ollama image
export OLLAMA_DOCKER_IMAGE_SRC="docker://ollama/ollama:latest"
export OLLAMA_IMAGE="${OLLAMA_BASE_DIR}/ollama.sif"

# This forces apptainer to ignore any existing docker config
# export DOCKER_CONFIG=/nonexistent

if [ ! -f "$OLLAMA_IMAGE" ]; then
  echo "Apptainer pulling image from $OLLAMA_DOCKER_IMAGE_SRC and converting to sif: $OLLAMA_IMAGE"
  apptainer pull "$OLLAMA_IMAGE" $OLLAMA_DOCKER_IMAGE_SRC
else
  echo "Apptainer image already exists: $OLLAMA_IMAGE. Skipping pull."
fi
# ===


# === Starting container and running Ollama
export APPTAINERENV_OLLAMA_HOST="http://127.0.0.1:11435"
LOG_FILE="$LOG_DIR/ollama_$USER_$(date -Iseconds | sed 's/:/-/g').log"

echo "Launching container from $OLLAMA_IMAGE"
echo "Running 'ollama serve' from the container" 
apptainer exec --nv "$OLLAMA_IMAGE" ollama serve &> "$LOG_FILE" &

sleep 3 # to allow enough time for previous command to succeed before proceeding
echo "Ollama running. REST API: $APPTAINERENV_OLLAMA_HOST/api/"

echo "Pulling $OLLAMA_MODEL"
apptainer exec --nv "$OLLAMA_IMAGE" ollama pull "$OLLAMA_MODEL" 

echo "Logging output to $LOG_FILE"
# ===
#
# TODO: Test first if port in use
# TODO: Exit script when a critical command fails. Provide guidance for troubleshooting.
