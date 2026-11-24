#!/usr/bin/env bash

set -u

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
models_dir="$project_root/models/annotation/qwen3"

model_names=(
    "Qwen3-0.6B"
    "Qwen3-1.7B"
    "Qwen3-4B"
    "Qwen3-8B"
)

model_sizes=(
    "397 MB"
    "1.11 GB"
    "2.50 GB"
    "5.03 GB"
)

model_repos=(
    "unsloth/Qwen3-0.6B-GGUF"
    "unsloth/Qwen3-1.7B-GGUF"
    "unsloth/Qwen3-4B-GGUF"
    "unsloth/Qwen3-8B-GGUF"
)

model_files=(
    "Qwen3-0.6B-Q4_K_M.gguf"
    "Qwen3-1.7B-Q4_K_M.gguf"
    "Qwen3-4B-Q4_K_M.gguf"
    "Qwen3-8B-Q4_K_M.gguf"
)

if ! command -v uvx >/dev/null 2>&1; then
    echo "uvx was not found."
    echo "run ./scripts/check_environment.sh first."
    exit 1
fi

mkdir -p "$models_dir"

is_downloaded() {
    local index="$1"
    [[ -f "$models_dir/${model_files[$index]}" ]]
}

show_models() {
    local index=0
    local status=""

    while [[ "$index" -lt "${#model_names[@]}" ]]; do
        status=""

        if is_downloaded "$index"; then
            status=" [downloaded]"
        fi

        printf "%d. %-12s %-8s%s\n" \
            "$((index + 1))" \
            "${model_names[$index]}" \
            "${model_sizes[$index]}" \
            "$status"

        index=$((index + 1))
    done
}

download_model() {
    local index="$1"
    local name="${model_names[$index]}"
    local repo="${model_repos[$index]}"
    local file="${model_files[$index]}"
    local destination="$models_dir/$file"
    local force_arg=""

    if [[ -f "$destination" ]]; then
        printf "%s is already downloaded. overwrite? [y/N]: " "$name"
        IFS= read -r answer

        case "$answer" in
            y|Y)
                force_arg="--force-download"
                ;;
            *)
                echo "keeping existing model."
                return
                ;;
        esac
    fi

    echo
    echo "downloading $name"
    echo "----------------"
    echo "source: $repo"
    echo "file:   $file"
    echo

    if [[ -n "$force_arg" ]]; then
        uvx hf download "$repo" "$file" \
            --local-dir "$models_dir" \
            --force-download
    else
        uvx hf download "$repo" "$file" \
            --local-dir "$models_dir"
    fi
}

download_missing_models() {
    local index=0
    local missing_count=0

    while [[ "$index" -lt "${#model_names[@]}" ]]; do
        if ! is_downloaded "$index"; then
            download_model "$index"
            missing_count=$((missing_count + 1))
        fi

        index=$((index + 1))
    done

    if [[ "$missing_count" -eq 0 ]]; then
        echo "all models are already downloaded."
    fi
}

remove_model() {
    local downloaded_indexes=()
    local index=0
    local choice=""
    local selected_index=""

    while [[ "$index" -lt "${#model_names[@]}" ]]; do
        if is_downloaded "$index"; then
            downloaded_indexes+=("$index")
        fi

        index=$((index + 1))
    done

    if [[ "${#downloaded_indexes[@]}" -eq 0 ]]; then
        echo "no downloaded models to remove."
        return
    fi

    echo
    echo "downloaded models"
    echo "-----------------"

    index=0

    while [[ "$index" -lt "${#downloaded_indexes[@]}" ]]; do
        selected_index="${downloaded_indexes[$index]}"
        echo "$((index + 1)). ${model_names[$selected_index]}"
        index=$((index + 1))
    done

    echo
    printf "choose model [1-%s]: " "${#downloaded_indexes[@]}"
    IFS= read -r choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] ||
       [[ "$choice" -lt 1 ]] ||
       [[ "$choice" -gt "${#downloaded_indexes[@]}" ]]; then
        echo "invalid selection"
        return
    fi

    selected_index="${downloaded_indexes[$((choice - 1))]}"

    printf "remove %s? [y/N]: " "${model_names[$selected_index]}"
    IFS= read -r answer

    case "$answer" in
        y|Y)
            rm "$models_dir/${model_files[$selected_index]}"
            echo "removed ${model_names[$selected_index]}."
            ;;
        *)
            echo "nothing removed."
            ;;
    esac
}

download_one_model() {
    local choice=""

    echo
    echo "available annotation models"
    echo "---------------------------"
    show_models
    echo

    printf "choose model [1-%s]: " "${#model_names[@]}"
    IFS= read -r choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] ||
       [[ "$choice" -lt 1 ]] ||
       [[ "$choice" -gt "${#model_names[@]}" ]]; then
        echo "invalid selection"
        return
    fi

    download_model "$((choice - 1))"
}

while true; do
    echo
    echo "model manager"
    echo "-------------"
    echo "1. download a model"
    echo "2. download all missing models"
    echo "3. remove a model"
    echo "4. exit"
    echo

    printf "choose [1-4]: "
    IFS= read -r choice

    case "$choice" in
        1)
            download_one_model
            ;;
        2)
            download_missing_models
            ;;
        3)
            remove_model
            ;;
        4)
            exit 0
            ;;
        *)
            echo "invalid selection"
            ;;
    esac
done
