from cluster_facility_location import (
    cluster_facility_location,
    resolve_opening_cost,
)
from cluster_kmeans import cluster_kmeans
from evaluate import evaluate_partition


def run_experiment_a(embeddings, true_labels, seed=42):
    predicted = cluster_kmeans(embeddings, k=101, seed=seed)
    result = evaluate_partition(true_labels, predicted)
    result.update(
        {
            "experiment": "A",
            "clustering": "kmeans",
            "seed": seed,
        }
    )
    return result


def run_experiment_b(
    embeddings,
    true_labels,
    lambda_multiplier,
):
    opening_cost = resolve_opening_cost(embeddings, lambda_multiplier)
    predicted = cluster_facility_location(embeddings, opening_cost)
    result = evaluate_partition(true_labels, predicted)
    result.update(
        {
            "experiment": "B",
            "clustering": "facility_location",
            "lambda_multiplier": lambda_multiplier,
            "opening_cost": opening_cost,
        }
    )
    return result


def run_lambda_sweep(
    embeddings,
    true_labels,
    lambda_multipliers,
):
    return [
        run_experiment_b(
            embeddings,
            true_labels,
            lambda_multiplier,
        )
        for lambda_multiplier in lambda_multipliers
    ]
