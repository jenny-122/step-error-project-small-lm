from sklearn.cluster import KMeans


def cluster_kmeans(embeddings, k=101, seed=42):
    model = KMeans(
        n_clusters=k,
        n_init=20,
        random_state=seed,
    )
    return model.fit_predict(embeddings)
