host := `hostname`
default_switch_config := if host == "nixos-pc" { 
    "pc" 
} else if host == "nixos-laptop" {
    "laptop"
} else {
    "unsupported"
}

env_pattern := "stg|prod"
default_env := "stg"

# build qcow2 image for the baseline vm
[arg('output', long)]
[arg('copy_to_deploy_dir', long="no-copy", value="0")]
[group('homelab')]
build-vm-image output="result" copy_to_deploy_dir="1":
    nix build -o "{{ output }}" .#nixosConfigurations.vm-base.config.system.build.images.qemu
    @if [ {{ copy_to_deploy_dir }} -eq 1 ]; then \
        cp {{ output }}/nixos*.qcow2 homelab/deploy/base.qcow2; \
        chmod 0600 homelab/deploy/base.qcow2; \
    fi

# list all declared nodes for a given environment
[arg('env', long, pattern=env_pattern)]
[group('homelab')]
ls-nodes env=default_env:
    #!/bin/sh

    env_dir="./homelab/deploy/{{ env }}"

    # FIXME: filter non-nixos nodes
    if ! nodes=$(nix eval --json --file "${env_dir}/inventory.nix" --apply 'builtins.attrNames' nodes | jq -r '.[]'); then
        exit 1
    fi

    printf '%s\n' $nodes

[arg('env', long, pattern=env_pattern)]
[group('homelab')]
_build_tf_config env=default_env:
    #!/bin/sh
    tf_path="homelab/deploy/{{ env }}/tf"

    nix build -o ${tf_path}/config.tf.json.tmp .#infra.{{ env }}.tf || exit 1
    cp ${tf_path}/config.tf.json.tmp ${tf_path}/config.tf.json || exit 1
    chmod 0600 ${tf_path}/config.tf.json || exit 1
    rm ${tf_path}/config.tf.json.tmp || exit 1

# run terraform commands within a given environment
[arg('env', long, pattern=env_pattern)]
[group('homelab')]
tf env=default_env +ARGS: (_build_tf_config env)
    terraform -chdir=homelab/deploy/{{ env }}/tf {{ ARGS }}

# deploy infra changes for a given environment (tf + colmena)
[arg('env', long, pattern=env_pattern)]
[arg('ssh_key_path', long)]
[group('homelab')]
deploy env=default_env ssh_key_path="~/.ssh/keys/vm": (_build_tf_config env)
    terraform -chdir=homelab/deploy/{{ env }}/tf apply
    cd homelab/deploy/{{ env }}/secrets && agenix -i "{{ ssh_key_path }}" --rekey
    colmena apply --config homelab/deploy/{{ env }}/hive.nix

# switch to new nixos configuration on the current host
switch config=default_switch_config:
    #!/bin/sh

    if [ "{{ config }}" = "unsupported" ]; then
        echo "Unsupported hostname: {{ host }}. Aborting"
        exit 1
    fi
    sudo nixos-rebuild switch --flake .#{{ config }}

# update nixpkgs or nixpkgs-unstable
[arg('stable', long, value="1")]
[arg('unstable', long, value="1")]
update-nixpkgs stable="0" unstable="0":
    #!/bin/sh

    if [ $(( {{ stable }} ^ {{ unstable }} )) -eq 0 ]; then
        printf 'You either tried to update both stable and unstable packages or forgot to select which nixpkgs to update\n'
        exit 1
    fi

    nixpkgs_type="nixpkgs"
    if [ {{ unstable }} -eq 1 ]; then
        nixpkgs_type="nixpkgs-unstable"
    fi

    git checkout -b "chore/update-${nixpkgs_type}-revision-$(date +%s)" || exit 1
    nix flake update "$nixpkgs_type" || exit 1
    git add flake.lock || exit 1
    nixos-rebuild build --flake .#{{ default_switch_config }} || exit 1

    printf '\nSuccessfully updated %s revision\n' "$nixpkgs_type"
    printf 'Suggested commit command: git commit -m "chore: updated %s revision"\n' "$nixpkgs_type"
