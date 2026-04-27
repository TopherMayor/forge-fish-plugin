function __forge_complete_commands
    forge --help 2>/dev/null | string match -r '^  [a-z][a-z0-9_-]+\s{2,}' | string replace -r '^  ([a-z][a-z0-9_-]+)\s{2,}.*$' '$1'
end

complete -c forge -f
complete -c forge -n '__fish_use_subcommand' -a '(__forge_complete_commands)'
complete -c forge -n '__fish_seen_subcommand_from zsh' -a 'plugin theme doctor rprompt setup keyboard format help'
complete -c forge -n '__fish_seen_subcommand_from commit' -s p -l preview -d 'Preview the commit message without creating it'
complete -c forge -n '__fish_seen_subcommand_from commit' -l max-diff -d 'Limit the diff size used for commit generation'
complete -c forge -n '__fish_seen_subcommand_from update' -l no-confirm -d 'Skip confirmation when updating'
