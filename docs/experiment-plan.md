## Research Question

How small can the language model used for step-error annotation become before downstream misconception-clustering quality degrades meaningfully?

The project studies annotation-model size first, then expands to encoder choice while keeping the clustering and evaluation setup controlled.

## Pipeline

```text
MalRuleLib record
      ↓
annotation LM
      ↓
step-error annotation
      ↓
embedding encoder
      ↓
K-means
      ↓
ACC / NMI / ARI / MTC
```

## Original Paper Reference

### Annotation models
- GPT-OSS-120B
- Qwen3-Next-80B-A3B
- Gemma-4-31B-it

### Embedding models
- BGE-M3
- BGE-large-en-v1.5
- Qwen3-Embedding-0.6B
- Qwen3-Embedding-4B

### Controlled settings to preserve
- Problem-template-level train/test split
- K-means with K = 101
- Euclidean distance
- `n_init = 20`
- Seeds: 42, 123, 456, 789, 1337
- Hungarian mapping fit on train for ACC
- Metrics: ACC, NMI, ARI, MTC

## Annotation Models

### Primary family
Current planned Qwen3 size ladder:
- Qwen3-0.6B
- Qwen3-1.7B
- Qwen3-4B
- Qwen3-8B

Exact checkpoints and quantization will be verified before the full run.

### Second family
Still open. Current candidates:
- Ministral 3
- Gemma 3

The purpose of the second family is to test whether the size trend generalizes beyond Qwen.

## Annotation Setup

- Run locally with `llama.cpp` / `llama-server`
- Run one annotation model at a time
- Use the paper's step-error annotation prompt unchanged across models
- Keep decoding settings fixed within comparable runs
- Pilot the output-token cap before fixing it
- Save each model's annotations once and reuse them across encoder experiments

## Encoders

### Original paper
- BGE-M3
- BGE-large-en-v1.5
- Qwen3-Embedding-0.6B
- Qwen3-Embedding-4B

### Generic pretrained encoder baselines
Use the same explicit pooling rule for these models, currently mean pooling:
- BERT-base-uncased
- RoBERTa-base
- DeBERTa-base

### Sentence-embedding baselines
- sentence-transformers/all-MiniLM-L6-v2
- sentence-transformers/all-mpnet-base-v2
- sentence-transformers/all-roberta-large-v1

The first grid should keep the encoder set interpretable rather than adding every available checkpoint.

## Metrics

### ACC
Map arbitrary K-means cluster IDs to misconception labels with Hungarian matching. Fit the mapping on training data and score accuracy on test data.

### NMI
Measure how much information the predicted clustering preserves about the true misconception labels. No cluster-label renaming is required.

### ARI
Measure pairwise grouping agreement, adjusted for chance: which responses are correctly kept together or apart.

### MTC
Measure whether each misconception is recovered across different held-out problem templates.

## Staged Implementation

1. Get one Qwen annotator through the full pipeline with one paper encoder
2. Run the Qwen annotation-size ladder with the encoder fixed
3. Reuse saved annotations across the encoder grid
4. Add the second annotation-model family
5. Add robustness checks only after the basic experiment is stable

## Open Decisions

- Second annotation-model family
- Common quantization level
- First fixed encoder for the annotation-size pilot
- Final additional encoder subset
- Exact MalRuleLib field mapping
- Output-token cap

## Sources

- [The Error Is the Signal: Misconception Discovery via Step-Error Annotation Clustering](https://aclanthology.org/2026.aacl-long.221/)
- [MalRuleLib](https://github.com/sonkar-lab/malrulelib)
