year := "2025"

init day year=year:
    @just _setup {{day}} {{year}}
    @just _open {{day}} {{year}}
    @just _fetch {{day}} {{year}}

run day year=year:
  zig build run_{{year}}_{{day}}

test day year=year:
  zig build test_{{year}}_{{day}}

_setup day year=year:
    #!/usr/bin/env bash
    set -euo pipefail
    
    # Create directories
    mkdir -p "src/{{year}}/{{day}}"
    mkdir -p "data/{{year}}"
    
    zig_file="src/{{year}}/{{day}}/main.zig"
    if [ ! -f "$zig_file" ]; then
        sed "s/{{'{{YEAR}}'}}/{{year}}/g; s/{{'{{DAY}}'}}/{{day}}/g" main.zig.template > "$zig_file"
        echo "Created $zig_file"
    else
        echo "$zig_file already exists, skipping"
    fi

_open day year=year:
    xdg-open "https://adventofcode.com/{{year}}/day/{{day}}"

_fetch day year=year:
    #!/usr/bin/env bash
    set -euo pipefail
    
    input_file="data/{{year}}/{{day}}.bin"
    
    # Check if input already exists
    if [ -f "$input_file" ]; then
        echo "$input_file already exists, skipping download"
        exit 0
    fi
    
    # Check for session cookie
    if [ -z "${AOC_SESSION:-}" ]; then
        echo "Error: AOC_SESSION environment variable not set"
        echo "Set it with: export AOC_SESSION='your_session_cookie'"
        exit 1
    fi
    
    # Download input
    url="https://adventofcode.com/{{year}}/day/{{day}}/input"
    echo "Downloading input from $url"
    
    curl -s -f \
        -H "Cookie: session=$AOC_SESSION" \
        -o "$input_file" \
        "$url"
    
    if [ $? -eq 0 ]; then
        echo "Successfully downloaded to $input_file"
    else
        echo "Failed to download input"
        rm -f "$input_file"
        exit 1
    fi
