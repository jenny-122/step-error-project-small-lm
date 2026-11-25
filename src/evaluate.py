from sklearn.metrics import (
    adjusted_rand_score,
    homogeneity_completeness_v_measure,
    normalized_mutual_info_score,
)


def evaluate_partition(true_labels, predicted_clusters):
    homogeneity, completeness, v_measure = homogeneity_completeness_v_measure(
        true_labels,
        predicted_clusters,
    )

    return {
        "ari": adjusted_rand_score(true_labels, predicted_clusters),
        "nmi": normalized_mutual_info_score(true_labels, predicted_clusters),
        "homogeneity": homogeneity,
        "completeness": completeness,
        "v_measure": v_measure,
        "k": len(set(predicted_clusters)),
    }
