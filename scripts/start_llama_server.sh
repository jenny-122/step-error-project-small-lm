#!/usr/bin/env bash

set -u

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
models_dir="$project_root/models/annotation"

llama_server_arg=""
model_arg=""
port="8080"

usage() {
    cat <<EOF
usage:
  ./scripts/start_llama_server.sh

options:
  --llama-server PATH
  --model PATH
  --port PORT
EOF
}

expand_home() {
    case "$1" in
        "~/"*)
            echo "$HOME/${1#\~/}"
            ;;
        *)
            echo "$1"
            ;;
    esac
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --llama-server)
            if [[ $# -lt 2 ]]; then
                echo "missing path after --llama-server"
                exit 2
            fi

            llama_server_arg="$(expand_home "$2")"
            shift 2
            ;;

        --model)
            if [[ $# -lt 2 ]]; then
                echo "missing path after --model"
                exit 2
            fi

            model_arg="$(expand_home "$2")"
            shift 2
            ;;

        --port)
            if [[ $# -lt 2 ]]; then
                echo "missing value after --port"
                exit 2
            fi

            port="$2"
            shift 2
            ;;

        -h|--help)
            usage
            exit 0
            ;;

        *)
            echo "unknown option: $1"
            usage
            exit 2
            ;;
    esac
done

llama_server=""

if [[ -n "$llama_server_arg" ]]; then
    llama_server="$llama_server_arg"
elif command -v llama-server >/dev/null 2>&1; then
    llama_server="$(command -v llama-server)"
else
    echo "llama-server was not found in PATH."
    echo
    printf "enter the path to llama-server: "
    IFS= read -r llama_server
    llama_server="$(expand_home "$llama_server")"
fi

if [[ ! -x "$llama_server" ]]; then
    echo "llama-server is not executable:"
    echo "  $llama_server"
    exit 1
fi

model_path=""

if [[ -n "$model_arg" ]]; then
    if [[ -f "$model_arg" ]]; then
        model_path="$model_arg"
    elif [[ -f "$project_root/$model_arg" ]]; then
        model_path="$project_root/$model_arg"
    else
        echo "model checkpoint not found:"
        echo "  $model_arg"
        exit 1
    fi
else
    models=()

    if [[ -d "$models_dir" ]]; then
        while IFS= read -r model; do
            models+=("$model")
        done < <(
            find "$models_dir" -type f -name '*.gguf' | sort
        )
    fi

    if [[ "${#models[@]}" -eq 0 ]]; then
        echo "no gguf checkpoints found in:"
        echo "  $models_dir"
        exit 1
    fi

    echo
    echo "available annotation models"
    echo "---------------------------"

    i=0

    for model in "${models[@]}"; do
        i=$((i + 1))
        relative_path="${model#"$models_dir"/}"
        echo "$i. $relative_path"
    done

    echo

    while true; do
        printf "choose model [1-%s]: " "${#models[@]}"
        IFS= read -r choice

        if [[ "$choice" =~ ^[0-9]+$ ]] &&
           [[ "$choice" -ge 1 ]] &&
           [[ "$choice" -le "${#models[@]}" ]]; then
            model_path="${models[$((choice - 1))]}"
            break
        fi

        echo "invalid selection"
    done
fi

model_alias="$(basename "$model_path" .gguf)"

echo
echo "starting llama-server"
echo "---------------------"
echo "model:      $model_alias"
echo "checkpoint: ${model_path#"$project_root"/}"
echo "port:       $port"
echo

exec "$llama_server" \
    -m "$model_path" \
    --alias "$model_alias" \
    --jinja \
    --reasoning off \
    -c 4096 \
    --port "$port"
