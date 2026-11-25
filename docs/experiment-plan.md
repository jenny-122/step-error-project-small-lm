## Research Question

How small can the Qwen3 model used for step-error annotation become before downstream misconception structure degrades meaningfully?

The pilot keeps the annotation-model family, quantization, embedding encoder, dataset, split, and evaluation code controlled. It compares a fixed-taxonomy baseline against an unknown-granularity facility-location experiment.

## Shared Pipeline

```text
MalRuleLib record
      ↓
Qwen3 annotation LM
      ↓
step-error annotation
      ↓
fixed embedding encoder
      ↓
clustering
      ↓
ARI / NMI / homogeneity / completeness / V-measure
```

## Controlled Settings

- Dataset: MalRuleLib
- Problem-template-level train/test split
- Annotation family: Qwen3 only
- Annotation sizes: 0.6B, 1.7B, 4B, 8B
- Quantization: Q4_K_M
- One fixed embedding encoder
- Fixed embedding preprocessing and distance definition
- Hidden 101 misconception-family labels used only for evaluation

## Experiment A — Fixed Taxonomy Recovery

Clustering:
- K-means
- K = 101
- Euclidean distance
- n_init = 20
- Seeds: 42, 123, 456, 789, 1337

Question:

> Given the known taxonomy size, how well does each Qwen3 annotation representation recover the 101 MalRuleLib misconception families?

Primary metric:
- ARI

Secondary diagnostics:
- NMI
- homogeneity
- completeness
- V-measure
- MTC where applicable

## Experiment B — Facility Location and Granularity Control

Use metric uncapacitated facility location on the same saved annotation embeddings.

Objective:

```text
minimize assignment distance + λ × number of opened facilities
```

The number of clusters is an output rather than an input.

### Interpretation of λ

- smaller λ → cheaper to open facilities → more clusters → finer error distinctions
- larger λ → more expensive to open facilities → fewer clusters → broader error categories

This makes λ a granularity or complexity control.

Potential educational interpretation:
- coarse granularity may support class-level summaries or broad feedback
- fine granularity may support more specific error descriptions or individualized feedback

This is an application hypothesis to test, not something the optimization itself guarantees.

### Evaluation

For every λ, record:
- λ
- discovered K
- ARI
- NMI
- homogeneity
- completeness
- V-measure

ARI is the primary bridge between Experiments A and B.

Do not select λ simply because K is close to 101. If labels are used to choose λ, describe that explicitly as validation-based hyperparameter selection.

## Matched-K Diagnostic

Optional later diagnostic:

If facility location discovers K = k at a selected λ, run K-means with the same k.

This separates:
- algorithm effects
- granularity effects

## Evaluation-Code Principle

The same partition evaluator should score both experiments.

```text
true labels + predicted cluster assignments
              ↓
ARI
NMI
homogeneity
completeness
V-measure
K
```

Experiment A and Experiment B should differ only at the clustering stage. Saved annotations and embeddings should be reused.

## Minimal Scope

1. Get one Qwen3 annotator through the full pipeline
2. Fix one embedding encoder
3. Run the Qwen3 size ladder with Experiment A
4. Add Experiment B with a predeclared λ sweep
5. Compare ARI and merge/fragmentation diagnostics
6. Add matched-K or feedback-granularity analysis only after the core pipeline works

## Deferred

- second annotation-model family
- large embedding-encoder grid
- quantization sweep
- rubric-aware real-world pilot
- human feedback study

## Sources

- [The Error Is the Signal: Misconception Discovery via Step-Error Annotation Clustering](https://aclanthology.org/2026.aacl-long.221/)
- [MalRuleLib](https://github.com/sonkar-lab/malrulelib)
