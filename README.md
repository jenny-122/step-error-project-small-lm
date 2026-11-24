## Step-Error Project: Small Language Models for Misconception Discovery

This repository is a scaled-down project inspired by *The Error Is the Signal: Misconception Discovery via Step-Error Annotation Clustering*.

### Source Project
- Paper: [*The Error Is the Signal: Misconception Discovery via Step-Error Annotation Clustering*](https://aclanthology.org/2026.aacl-long.221/)
- Paper-listed repository: [sonkar-lab/llm_misconception_discovery](https://github.com/sonkar-lab/llm_misconception_discovery)
- The paper-listed repository is currently unavailable, so this project uses a minimal adaptation of the experimental design rather than a direct code reproduction

### Original Paper
- Uses step-error annotations to represent specific student mistakes
- Tests whether those representations improve misconception clustering
- Uses large language models and a broad experimental setup

### This Project
- Focuses specifically on **smaller language models**
- Runs on **local consumer hardware**
- Keeps the downstream embedding, clustering, and evaluation pipeline controlled
- Tests how annotation-model size affects clustering quality
