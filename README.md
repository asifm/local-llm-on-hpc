1.	Copy this directory somewhere:  /project/orsDarden/mehedia/local_llm_workflow
2.	cd into the copied directory.
3.	To run a SLURM job
    a.	Run: sbatch sample_slurm_job.slurm
    b.	Check output in the file “slurm-<job_id>.out”
    c.	Modify the file if you want; then run again.
4.	Or, to use Ollama interactively
    a.	Run: ijob -p gpu --gres=gpu:a6000:1 -A orsdardencomputing    
    b.	Run: source ollama_setup.sh. Now you have Ollama running in the background. So, you can pull new models, run a chat session, call REST API, etc. See here for the basic commands. Since Ollama is running inside a container, you need to prepend this to any Ollama command: apptainer exec --nv  $OLLAMA_IMAGE. For example, `ollama pull $OLLAMA_MODEL` becomes `apptainer exec --nv  $OLLAMA_IMAGE ollama pull $OLLAMA_MODEL`
    c.	To start a chat session, run: apptainer exec --nv  $OLLAMA_IMAGE ollama run $OLLAMA_MODEL

