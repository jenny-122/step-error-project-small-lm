#!/usr/bin/env bash

set -u

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
models_dir="$project_root/models/annotation"

llama_server_arg=""
blockers=0

usage() {
    echo "usage: ./scripts/check_environment.sh [--llama-server PATH]"
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

ok() {
    echo "[ok] $1"
}

missing() {
    echo "[missing] $1"
    blockers=$((blockers + 1))
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

echo
echo "system"
echo "------"

system_name="$(uname -s)"
architecture="$(uname -m)"

case "$system_name" in
    Darwin)
        ok "macos"
        ;;
    Linux)
        ok "linux"
        ;;
    *)
        missing "unsupported operating system: $system_name"
        ;;
esac

ok "architecture: $architecture"

echo
echo "python"
echo "------"

if command -v uv >/dev/null 2>&1; then
    ok "$(uv --version)"

    python_path="$(
        cd "$project_root" &&
        uv python find 2>/dev/null
    )"

    if [[ -n "$python_path" ]]; then
        ok "python: $python_path"
    else
        missing "python could not be found through uv"
    fi
else
    missing "uv is not installed"
fi

echo
echo "project"
echo "-------"

required_files=(
    "pyproject.toml"
    "uv.lock"
    "prompts/step_error.txt"
)

for file in "${required_files[@]}"; do
    if [[ -f "$project_root/$file" ]]; then
        ok "$file"
    else
        missing "$file"
    fi
done

echo
echo "llama.cpp"
echo "---------"

llama_server=""

if [[ -n "$llama_server_arg" ]]; then
    llama_server="$llama_server_arg"
elif command -v llama-server >/dev/null 2>&1; then
    llama_server="$(command -v llama-server)"
fi

if [[ -n "$llama_server" && -x "$llama_server" ]]; then
    ok "llama-server: $llama_server"
else
    missing "llama-server was not found"
    echo
    echo "you can still provide it when starting the server:"
    echo "  ./scripts/start_llama_server.sh"
fi

echo
echo "annotation models"
echo "-----------------"

model_count=0

if [[ -d "$models_dir" ]]; then
    while IFS= read -r model; do
        relative_path="${model#"$project_root"/}"
        ok "$relative_path"
        model_count=$((model_count + 1))
    done < <(
        find "$models_dir" -type f -name '*.gguf' | sort
    )
fi

if [[ "$model_count" -eq 0 ]]; then
    missing "no gguf checkpoints found in models/annotation"
fi

echo
echo "runs"
echo "----"

if [[ -d "$project_root/runs" ]]; then
    if [[ -w "$project_root/runs" ]]; then
        ok "runs/ is writable"
    else
        missing "runs/ is not writable"
    fi
elif [[ -w "$project_root" ]]; then
    ok "runs/ can be created when the first run starts"
else
    missing "project directory is not writable"
fi

echo
echo "summary"
echo "-------"

if [[ "$blockers" -eq 0 ]]; then
    echo "environment is ready."
    echo
    echo "next:"
    echo "  ./scripts/start_llama_server.sh"
    exit 0
fi

echo "$blockers blocking issue(s) found."
exit 1
