#!/usr/bin/env fish

function __forge_fish_setup_usage
    printf '%s\n' \
        'Usage: fish setup.fish [--copy] [--force] [--dry-run] [--target-dir PATH]' \
        '' \
        'Installs the Forge fish integration into your Fish config directories.' \
        '' \
        'Options:' \
        '  --copy            Copy files instead of symlinking them' \
        '  --force           Replace existing files without keeping backups' \
        '  --dry-run         Show what would happen without changing anything' \
        '  --target-dir PATH Install into an alternate Fish config root' \
        '  --help            Show this help'
end

function __forge_fish_setup_error --argument-names message
    printf 'forge fish setup: %s\n' $message >&2
end

function __forge_fish_setup_install --argument-names source target mode force dry_run
    if not test -f "$source"
        __forge_fish_setup_error "missing source file: $source"
        return 1
    end

    set -l target_dir (path dirname "$target")
    if test -z "$target_dir"
        __forge_fish_setup_error "unable to determine target directory for: $target"
        return 1
    end

    if test "$dry_run" = 1
        if test -e "$target" -o -L "$target"
            if test "$force" = 1
                printf '[dry-run] replace %s using %s from %s\n' $target $mode $source
            else
                set -l backup "$target.forge-fish-backup."(date +%Y%m%d%H%M%S)
                printf '[dry-run] back up %s to %s and install from %s as %s\n' $target $backup $source $mode
            end
        else
            printf '[dry-run] install %s from %s as %s\n' $target $source $mode
        end
        return 0
    end

    mkdir -p "$target_dir"; or return 1

    if test -L "$target"
        set -l existing (readlink "$target")
        if test "$existing" = "$source"
            printf 'up-to-date: %s\n' $target
            return 0
        end
    end

    if test -e "$target" -o -L "$target"
        if test "$force" = 1
            rm -f "$target"; or return 1
        else
            set -l backup "$target.forge-fish-backup."(date +%Y%m%d%H%M%S)
            mv "$target" "$backup"; or return 1
            printf 'backed up %s to %s\n' $target $backup
        end
    end

    switch $mode
        case copy
            command cp "$source" "$target"; or return 1
        case symlink
            command ln -s "$source" "$target"; or return 1
        case '*'
            __forge_fish_setup_error "unknown install mode: $mode"
            return 1
    end

    printf 'installed %s via %s\n' $target $mode
end

set -l mode symlink
set -l force 0
set -l dry_run 0
set -l target_root "$HOME/.config/fish"

set -l args $argv
while test (count $args) -gt 0
    set -l arg $args[1]
    set -e args[1]

    switch $arg
        case --copy
            set mode copy
        case --force
            set force 1
        case --dry-run
            set dry_run 1
        case --target-dir
            if test (count $args) -eq 0
                __forge_fish_setup_error "--target-dir requires a path"
                __forge_fish_setup_usage
                exit 1
            end
            set target_root $args[1]
            set -e args[1]
        case -h --help
            __forge_fish_setup_usage
            exit 0
        case '*'
            __forge_fish_setup_error "unknown argument: $arg"
            __forge_fish_setup_usage
            exit 1
    end
end

set -l script_path (status filename)
if test -z "$script_path"
    __forge_fish_setup_error "unable to determine script location"
    exit 1
end

set -l repo_root (path dirname "$script_path")
set -l conf_src "$repo_root/.config/fish/conf.d/forge.fish"
set -l comp_src "$repo_root/.config/fish/completions/forge.fish"
set -l conf_dst "$target_root/conf.d/forge.fish"
set -l comp_dst "$target_root/completions/forge.fish"

if not test -f "$conf_src"
    __forge_fish_setup_error "missing plugin source: $conf_src"
    exit 1
end

if not test -f "$comp_src"
    __forge_fish_setup_error "missing completion source: $comp_src"
    exit 1
end

__forge_fish_setup_install "$conf_src" "$conf_dst" $mode $force $dry_run; or exit 1
__forge_fish_setup_install "$comp_src" "$comp_dst" $mode $force $dry_run; or exit 1

if test "$dry_run" = 1
    printf 'dry-run complete\n'
else
    printf 'forge fish setup complete\n'
end
