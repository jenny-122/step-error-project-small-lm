import numpy as np
from sklearn.neighbors import NearestNeighbors


def median_nearest_neighbor_distance(embeddings):
    neighbors = NearestNeighbors(n_neighbors=2, metric="euclidean")
    neighbors.fit(embeddings)
    distances, _ = neighbors.kneighbors(embeddings)
    return float(np.median(distances[:, 1]))


def resolve_opening_cost(embeddings, multiplier):
    return multiplier * median_nearest_neighbor_distance(embeddings)


def facility_location_objective(
    embeddings,
    facility_indices,
    assignments,
    opening_cost,
):
    facilities = embeddings[np.asarray(facility_indices)]
    assigned = facilities[np.asarray(assignments)]
    connection_cost = np.linalg.norm(embeddings - assigned, axis=1).sum()
    return float(connection_cost + opening_cost * len(facility_indices))


def cluster_facility_location(embeddings, opening_cost):
    raise NotImplementedError(
        "implement the chosen metric uncapacitated facility-location "
        "approximation here before running experiment B"
    )
