#  Goal

This repo provides a minimal but self-contained setup and a reproducible workflow for running a "open weight"/"local" large language model (LLM) on UVA's HPC system. You can run the scripts unmodified to see how they work. Feel free to modify them to suit your workflow.

The setup uses 

- [Ollama](https://ollama.com/) for pulling and running an LLM
- [Apptainer](https://www.rc.virginia.edu/userinfo/hpc/software/apptainer/) for container management 
- [Slurm](https://www.rc.virginia.edu/userinfo/hpc/slurm/) for batch job management

While this setup gets an LLM up and running quickly without needing low level configurations or applications, it's not optimal if you need high-volume batch processing. For such needs, check out [vllm](https://github.com/vllm-project/vllm), which requires managing your own python environment but provides superior performance.


# Requirements

You must have access to UVA's HPC system with an active allocation.

Some experience with the Linux shell and familiarity with the tools mentioned above would be helpful.

# Scripts

## ollama_setup.sh

## sample_slurm_job.sh

# Instructions

- [Log into UVA HPC](https://www.rc.virginia.edu/userinfo/hpc/login/) using ssh (other methods may work but I haven't tested).
- Once in your shell, clone this repo somewhere in the filesystem (e.g., inside `~` or `/project` or '/scratch')

`git clone https://github.com/asifm/local-llm-on-hpc`

- cd into the cloned directory. 

From here, you can launch a chat session or start a batch job.

## Chat Session 

- Run this command: `ijob -p gpu --gres=gpu:<gpu_type>:1 -A <account_name>`

Replace <gpu_type> with the actual name of the GPU type you want to use. See https://www.rc.virginia.edu/userinfo/hpc/ (section titled "Hardware Configuration") for available GPUs.

Replace <account_name> with the actual name of your HPC allocation account.

For example: `ijob -p gpu --gres=gpu:a6000:1 -A orsdardencomputing`

This will submit a request for an interactive computing node. Depending on GPU availability, getting the node may take seconds or minutes. (For details on `ijob` command, consult https://www.rc.virginia.edu/userinfo/hpc/slurm/.) 

- Run this command: `source ollama_setup.sh`

Now you have Ollama running in the background through an apptainer container. You can pull new models, run a chat session, call ollama's REST API, etc. See [here](https://docs.ollama.com/cli) for the basic commands. 

Since Ollama is running inside a container, you must prepend this to any Ollama command you want to run: `apptainer exec --nv  $OLLAMA_IMAGE`

For example: `ollama pull $OLLAMA_MODEL` becomes `apptainer exec --nv  $OLLAMA_IMAGE ollama pull $OLLAMA_MODEL`

Important: the `--nv` option allows apptainer to connect with HPC's nvidia tools.

- To start a chat session, run: `apptainer exec --nv  $OLLAMA_IMAGE ollama run $OLLAMA_MODEL`

## Batch Job using Slurm

- Run the command: `sbatch sample_slurm_job.sh`
- Check output in the file “slurm-<job_id>.out” (where <job_id> is the numerical ID assigned by Slurm when a job is submitted)

