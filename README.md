#  Goal

This repo provides a minimal but self-contained setup and a reproducible workflow for running a "open weight"/"local" large language model (LLM) on UVA's HPC system, taking advantage of the range of GPU hardware available there.

You can run the scripts unmodified to see how they work. Feel free to experiment and modify them to suit your workflow.

We use: 

- [Ollama](https://ollama.com/) for pulling and running LLMs
- [Apptainer](https://www.rc.virginia.edu/userinfo/hpc/software/apptainer/) for container management 
- [Slurm](https://www.rc.virginia.edu/userinfo/hpc/slurm/) for job management

This setup gets a local LLM up and running quickly without requirng low level tools or configurations. 

But it's not optimal if you need high-volume batch processing. For such needs, check out [vllm](https://github.com/vllm-project/vllm), which requires managing your own python environment but provides superior performance.

# Requirements

You must have access to UVA's HPC system with an active allocation.

Some experience with the Linux shell and familiarity with the tools mentioned above would be helpful.

# What the Scripts Do

## ollama_setup.sh

- Chooses an Ollama model to use.
- Configures paths to store Apptainer cache and Ollama models.
- Pulls a container image from docker and converts it to "sif" (Apptainer's image format).
- Starts the container.
- Runs `ollama serve` inside the container.
- Pulls an Ollama model.

## sample_slurm_job.sh

- Declares, as `sbatch` directives, the resources needed for the job.
- Sources ollama_setup.sh, so everything in that script is run to configure, prepare and launch Ollama.
- Starts a batch job. Usually this would be done by launching a python script from inside this slurm script. In this sample slurm script, a simple curl command is run to interact with Ollama running in the background.

# Instructions

- [Log into UVA HPC](https://www.rc.virginia.edu/userinfo/hpc/login/) using [ssh](https://www.rc.virginia.edu/userinfo/hpc/logintools/rivanna-ssh/) (other methods may work but I haven't tested).
- Once in your shell, move to somewhere in the filesystem (e.g., inside `~` or `/project` or `/scratch`) and clone this repo: `git clone https://github.com/asifm/local-llm-on-hpc`
- cd into the cloned directory. 

From here, you can launch a chat session or start a batch job.

## Chat Session 

1. Run: `ijob -p gpu --gres=gpu:<gpu_type>:1 -A <account_name>`

Replace `<gpu_type>` with the actual name of the GPU type you want to use. See https://www.rc.virginia.edu/userinfo/hpc/ (section titled "Hardware Configuration") to learn about available GPUs.

Replace `<account_name>` with the actual name of your HPC allocation account.

For example: `ijob -p gpu --gres=gpu:a6000:1 -A orsdardencomputing`

This will submit a request for an interactive computing node. Depending on GPU availability, getting the node may take seconds or minutes. (For details on `ijob`, see https://www.rc.virginia.edu/userinfo/hpc/slurm/.) 

2. Run: `source ollama_setup.sh`

Now you have Ollama running in the background through an apptainer container. You can pull new models, run a chat session, call ollama's REST API, etc. See [here](https://docs.ollama.com/cli) for the basic commands. 

Since Ollama is running inside a container, you must prepend this to any Ollama command you want to run: `apptainer exec --nv  $OLLAMA_IMAGE`

For example: `ollama pull $OLLAMA_MODEL` becomes `apptainer exec --nv  $OLLAMA_IMAGE ollama pull $OLLAMA_MODEL`

Important: the `--nv` flag enables NVIDIA GPU support inside the container by allowing it access to the host system's NVIDIA drivers and CUDA libraries.

You can run this command to confirm Ollama is running: `curl http://127.0.0.1:11435/api/tags`

3. To start a chat session, run: `apptainer exec --nv  $OLLAMA_IMAGE ollama run $OLLAMA_MODEL`

## Batch Job Using Slurm

1. Run: `sbatch sample_slurm_job.sh`

Slurm will put your job request in the queue. To check status, run: `squeue -u $USER --all` 

2. When the job is complete, check the output of the job in the file “slurm-<job_id>.out” (where `<job_id>` is the numerical ID assigned by Slurm when a job is submitted).

To do anything useful, you'd need to write some Python code and execute that code from this job script. Ollama provides a [Python library](https://github.com/ollama/ollama-python). There's some [compatibility with the OpenAI API](https://docs.ollama.com/api/openai-compatibility).
