#!/bin/bash

#SBATCH -A orsdardencomputing
#SBATCH --partition=gpu
#SBATCH --gres=gpu:a6000:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=0:00:10
#SBATCH --mem=8GB


echo "Sourcing ollama_setup.sh"
source ollama_setup.sh

OLLAMA_MODEL="gemma3:270m"

echo "Pulling Ollama model $OLLAMA_MODEL"
apptainer exec "$OLLAMA_IMAGE" ollama pull $OLLAMA_MODEL

echo "Currently available models in $OLLAMA_MODELS"
apptainer exec "$OLLAMA_IMAGE" ollama list

sleep 3

echo "Setup complete. Ready to run main task."
printf "***************************************\n\n"

# Now do something with the locally available models. Usually through python script
# that uses Ollama REST API, available on $OLLAMA_HOST/api (https://ollama.readthedocs.io/en/api/) 
# or Ollama python library (https://github.com/ollama/ollama-python)

# Below is a direct call to the REST API just as an example. 
# After the job runs, check this job's output file,
# named slurm-<job ID>.out unless changed with SBATCH above


curl "$APPTAINERENV_OLLAMA_HOST/api/generate" -d @- <<EOF
{
  "model": "$OLLAMA_MODEL",
  "prompt": "Why is the sky blue?",
  "stream": false
}
EOF
