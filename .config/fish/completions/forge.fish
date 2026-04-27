function __forge_complete_root_commands
    forge --help 2>/dev/null | while read -l line
        if string match -rq '^  [a-z][a-z0-9_-]+\s{2,}' -- $line
            set -l name (string replace -r '^  ([a-z][a-z0-9_-]+)\s{2,}.*$' '$1' -- $line)
            set -l desc (string replace -r '^  [a-z][a-z0-9_-]+\s{2,}(.*)$' '$1' -- $line)
            printf '%s\t%s\n' $name $desc
        end
    end
end

function __forge_complete_prompt_commands
    command forge list commands --porcelain 2>/dev/null | while read -l line
        if string match -rq '^\s*COMMAND\b' -- $line
            continue
        end

        set -l normalized (string replace -ar '\\s{2,}' '\t' -- $line)
        set -l fields (string split \t -- $normalized)
        if test (count $fields) -lt 3
            continue
        end

        set -l name $fields[1]
        set -l desc (string join ' ' $fields[3..-1])
        printf '%s\t%s\n' $name $desc
    end
end

function __forge_complete_zsh_commands
    printf '%s\t%s\n' plugin 'Generate shell plugin script'
    printf '%s\t%s\n' theme 'Generate shell theme'
    printf '%s\t%s\n' doctor 'Run diagnostics on shell environment'
    printf '%s\t%s\n' rprompt 'Get rprompt information (model and conversation stats) for shell integration'
    printf '%s\t%s\n' setup 'Setup zsh integration by updating .zshrc with plugin and theme'
    printf '%s\t%s\n' keyboard 'Show keyboard shortcuts for ZSH line editor'
    printf '%s\t%s\n' format 'Format buffer text by wrapping file paths in @[...] syntax'
    printf '%s\t%s\n' help 'Print this message or the help of the given subcommand(s)'
end

complete -c forge -f
complete -c forge -n '__fish_use_subcommand' -a '(__forge_complete_root_commands)'
complete -c forge -n '__fish_seen_subcommand_from help' -a '(__forge_complete_prompt_commands)'
complete -c forge -n '__fish_seen_subcommand_from zsh help' -a '(__forge_complete_zsh_commands)'
complete -c forge -n '__fish_seen_subcommand_from zsh' -a '(__forge_complete_zsh_commands)'
complete -c forge -n '__fish_seen_subcommand_from commit' -s p -l preview -d 'Preview the commit message without creating it'
complete -c forge -n '__fish_seen_subcommand_from commit' -l max-diff -d 'Limit the diff size used for commit generation' -r
complete -c forge -n '__fish_seen_subcommand_from commit-preview' -l max-diff -d 'Limit the diff size used for commit generation' -r
complete -c forge -n '__fish_seen_subcommand_from update' -l no-confirm -d 'Skip confirmation when updating'
complete -c forge -l prompt -d 'Direct prompt to process without entering interactive mode' -r
complete -c forge -l conversation -d 'Path to a JSON file containing the conversation to execute' -r
complete -c forge -l conversation-id -d 'Conversation ID to use for this session' -r
complete -c forge -s C -l directory -d 'Working directory to use before starting the session' -r
complete -c forge -l sandbox -d 'Name for an isolated git worktree to create for experimentation' -r
complete -c forge -l verbose -d 'Enable verbose logging output'
complete -c forge -l agent -d 'Agent ID to use for this session' -r
complete -c forge -l event -d 'Event to dispatch to the workflow in JSON format' -r
