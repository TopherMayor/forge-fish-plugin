# Forge fish integration
# Provides prompt, commandline actions, key bindings, and completions similar to the zsh plugin.

if status --is-interactive
    set -q _FORGE_BIN; or set -g _FORGE_BIN forge
    set -q _FORGE_ACTIVE_AGENT; or set -U _FORGE_ACTIVE_AGENT forge
    set -q _FORGE_CONVERSATION_ID; or set -U _FORGE_CONVERSATION_ID ""
    set -q _FORGE_PREVIOUS_CONVERSATION_ID; or set -U _FORGE_PREVIOUS_CONVERSATION_ID ""
    set -q _FORGE_SESSION_MODEL; or set -U _FORGE_SESSION_MODEL ""
    set -q _FORGE_SESSION_PROVIDER; or set -U _FORGE_SESSION_PROVIDER ""
    set -q _FORGE_SESSION_REASONING_EFFORT; or set -U _FORGE_SESSION_REASONING_EFFORT ""
    set -q _FORGE_MAX_COMMIT_DIFF; or set -g _FORGE_MAX_COMMIT_DIFF 100000
    set -q _FORGE_PREVIEW_WINDOW; or set -g _FORGE_PREVIEW_WINDOW --preview-window=bottom:75%:wrap:border-sharp

    function __forge_command_available --argument-names cmd
        type -q $cmd
    end

    function __forge_fzf
        if type -q fzf
            command fzf $argv
            return $status
        end

        return 1
    end

    function __forge_short_id --argument-names value
        if test -z "$value" -o "$value" = "[empty]"
            return 0
        end
        string sub -l 8 -- $value
    end

    function __forge_find_index --argument-names output value_to_find field_number field_number2 value_to_find2
        set -l index 1
        set -l line_num 0

        for line in (string split \n -- $output)
            if test -z "$line"
                continue
            end

            set line_num (math $line_num + 1)
            if test $line_num -eq 1
                continue
            end

            set -l normalized (string replace -ar '\\s{2,}' '\t' -- $line)
            set -l fields (string split \t -- $normalized)
            if test (count $fields) -lt $field_number
                set index (math $index + 1)
                continue
            end

            if test "$fields[$field_number]" = "$value_to_find"
                if test -n "$field_number2" -a -n "$value_to_find2"
                    if test (count $fields) -ge $field_number2; and test "$fields[$field_number2]" = "$value_to_find2"
                        echo $index
                        return 0
                    end
                else
                    echo $index
                    return 0
                end
            end

            set index (math $index + 1)
        end

        echo 1
    end

    function __forge_command_type --argument-names action_name
        if test -z "$action_name"
            return 1
        end

        set -l command_row (command $_FORGE_BIN list commands --porcelain 2>/dev/null | string match -r "^$action_name\\b.*")
        if test -z "$command_row"
            return 1
        end

        set command_row $command_row[1]
        set -l command_type (string replace -r '^\\s*[^[:space:]]+\\s+([A-Z]+)\\s+.*$' '$1' -- $command_row)
        if test "$command_type" = "$command_row"
            return 1
        end

        echo (string lower -- $command_type)
    end


    function __forge_pick_from_porcelain --argument-names command_name prompt_text with_nth query current_value field_number
        set -l output (command $_FORGE_BIN $command_name --porcelain 2>/dev/null)
        if test -z "$output"
            return 1
        end

        set -l fzf_args --delimiter='\s\s+' --prompt="$prompt_text" --with-nth="$with_nth"
        if test -n "$query"
            set fzf_args $fzf_args --query="$query"
        end
        if test -n "$current_value"
            set -l index (__forge_find_index "$output" "$current_value" $field_number)
            set fzf_args $fzf_args --bind="start:pos($index)"
        end

        printf '%s\n' $output | __forge_fzf --header-lines=1 $fzf_args
    end

    function __forge_pick_conversation --argument-names query
        set -l output (command $_FORGE_BIN conversation list --porcelain 2>/dev/null)
        if test -z "$output"
            return 1
        end

        set -l current_id $_FORGE_CONVERSATION_ID
        set -l fzf_args --delimiter='\s\s+' --prompt='Conversation ❯ ' --with-nth='2,3' --preview="CLICOLOR_FORCE=1 $_FORGE_BIN conversation info {1}; echo; CLICOLOR_FORCE=1 $_FORGE_BIN conversation show {1}" $_FORGE_PREVIEW_WINDOW
        if test -n "$query"
            set fzf_args $fzf_args --query="$query"
        end
        if test -n "$current_id"
            set -l index (__forge_find_index "$output" "$current_id" 1)
            set fzf_args $fzf_args --bind="start:pos($index)"
        end

        printf '%s\n' $output | __forge_fzf --header-lines=1 $fzf_args
    end

    function __forge_pick_model --argument-names prompt_text query current_model current_provider provider_field
        set -l output (command $_FORGE_BIN list models --porcelain 2>/dev/null)
        if test -z "$output"
            return 1
        end

        set -l fzf_args --delimiter='\s\s+' --prompt="$prompt_text" --with-nth='2,3,5..'
        if test -n "$query"
            set fzf_args $fzf_args --query="$query"
        end
        if test -n "$current_model"
            if test -n "$current_provider" -a -n "$provider_field"
                set -l index (__forge_find_index "$output" "$current_model" 1 "$provider_field" "$current_provider")
                set fzf_args $fzf_args --bind="start:pos($index)"
            else
                set -l index (__forge_find_index "$output" "$current_model" 1)
                set fzf_args $fzf_args --bind="start:pos($index)"
            end
        end

        printf '%s\n' $output | __forge_fzf --header-lines=1 $fzf_args
    end

    function __forge_pick_provider --argument-names query current_provider
        set -l output (command $_FORGE_BIN list provider --porcelain 2>/dev/null)
        if test -z "$output"
            return 1
        end

        set -l current_provider_id (__forge_provider_id_from_text "$current_provider")
        set -l fzf_args --delimiter='\s\s+' --prompt='Provider ❯ ' --with-nth='1,2,3,4'
        if test -n "$query"
            set fzf_args $fzf_args --query="$query"
        end
        if test -n "$current_provider_id"
            set -l index (__forge_find_index "$output" "$current_provider_id" 2)
            set fzf_args $fzf_args --bind="start:pos($index)"
        end

        printf '%s\n' $output | __forge_fzf --header-lines=1 $fzf_args
    end

    function __forge_provider_row_fields --argument-names line
        set -l normalized (string replace -ar '\s{2,}' '\t' -- (string trim -- $line))
        string split \t -- $normalized
    end

    function __forge_provider_id_from_text --argument-names provider_text
        set provider_text (string trim -- $provider_text)
        if test -z "$provider_text"
            return 1
        end

        set -l fields (__forge_provider_row_fields "$provider_text")
        if test (count $fields) -ge 2
            set -l candidate (string trim -- $fields[2])
            if test -n "$candidate"
                echo $candidate
                return 0
            end
        end

        set -l output (command $_FORGE_BIN list provider --porcelain 2>/dev/null)
        if test -z "$output"
            return 1
        end

        for line in (string split \n -- $output)
            if test -z "$line"
                continue
            end

            if string match -rq '^NAME[[:space:]]+ID[[:space:]]+HOST[[:space:]]+LOGGED IN$' -- $line
                continue
            end

            set -l row (__forge_provider_row_fields "$line")
            if test (count $row) -lt 2
                continue
            end

            if test "$row[1]" = "$provider_text"; or test "$row[2]" = "$provider_text"
                echo $row[2]
                return 0
            end
        end

        return 1
    end

    function __forge_provider_login_target_from_text --argument-names provider_text
        set provider_text (string trim -- $provider_text)
        if test -z "$provider_text"
            return 1
        end

        set -l provider_id (__forge_provider_id_from_text "$provider_text")
        if test -n "$provider_id"
            echo $provider_id
            return 0
        end

        echo $provider_text
    end

    function __forge_pick_agent --argument-names query current_agent
        set -l output (command $_FORGE_BIN list agents --porcelain 2>/dev/null)
        if test -z "$output"
            return 1
        end

        set -l fzf_args --delimiter='\s\s+' --prompt='Agent ❯ ' --with-nth='1,2,4,5,6'
        if test -n "$query"
            set fzf_args $fzf_args --query="$query"
        end
        if test -n "$current_agent"
            set -l index (__forge_find_index "$output" "$current_agent" 1)
            set fzf_args $fzf_args --bind="start:pos($index)"
        end

        printf '%s\n' $output | __forge_fzf --header-lines=1 $fzf_args
    end

    function __forge_current_reasoning_effort
        if test -n "$_FORGE_SESSION_REASONING_EFFORT"
            echo $_FORGE_SESSION_REASONING_EFFORT
            return 0
        end
        command $_FORGE_BIN config get reasoning-effort 2>/dev/null
    end

    function __forge_info_porcelain
        __forge_command_available $_FORGE_BIN; or return
        command $_FORGE_BIN info --porcelain 2>/dev/null
    end

    function __forge_prompt_segment
        __forge_command_available $_FORGE_BIN; or return

        set -l info (__forge_info_porcelain)
        if test -z "$info"
            return
        end

        set -l model_line (string match -r '^AGENT[[:space:]]+model[[:space:]]+.+$' -- $info)
        set -l conversation_line (string match -r '^CONVERSATION[[:space:]]+id[[:space:]]+.+$' -- $info)
        set -l model ""
        set -l conversation ""
        set -l effort (__forge_current_reasoning_effort)

        if test (count $model_line) -gt 0
            set model (string replace -r '^AGENT[[:space:]]+model[[:space:]]+' '' -- $model_line[1])
        end

        if test (count $conversation_line) -gt 0
            set conversation (string replace -r '^CONVERSATION[[:space:]]+id[[:space:]]+' '' -- $conversation_line[1])
        end

        set -l segments
        set segments $segments (set_color brblack) '󱙺 FORGE' (set_color normal)

        set -l live_hint (__forge_live_buffer_hint)
        if test -n "$live_hint"
            set segments $segments (set_color brblack) $live_hint (set_color normal)
        end

        if test -n "$_FORGE_ACTIVE_AGENT"; and test "$_FORGE_ACTIVE_AGENT" != "forge"
            set segments $segments (set_color brblack) $_FORGE_ACTIVE_AGENT (set_color normal)
        end

        if test -n "$model"
            set segments $segments (set_color brblack) $model (set_color normal)
        end

        if test -n "$effort"
            set segments $segments (set_color brblack) (string upper -- $effort) (set_color normal)
        end

        if test -n "$conversation"; and test "$conversation" != "[empty]"
            set segments $segments (set_color brblack) (__forge_short_id $conversation) (set_color normal)
        end

        string join ' ' $segments
    end

    function __forge_live_buffer_hint
        set -l buffer (commandline -b 2>/dev/null)
        if test -z "$buffer"
            return
        end

        if string match -rq '^:\s*(tag|file)\b' -- $buffer
            echo (set_color bryellow)'tag' (set_color normal)
            return
        end

        if string match -rq '^:\s*(sync|index|doctor)\b' -- $buffer
            echo (set_color brcyan)'workflow' (set_color normal)
            return
        end

        if string match -rq '@\[' -- $buffer
            echo (set_color brmagenta)'@[...]' (set_color normal)
        end
    end

    function fish_right_prompt --description 'Forge-aware right prompt'
        __forge_prompt_segment
    end

    function __forge_format_buffer
        set -l buffer (commandline -b)
        if test -z "$buffer"
            return 0
        end

        if string match -rq '^:.*' -- $buffer
            set -l formatted (command $_FORGE_BIN zsh format --buffer "$buffer" 2>/dev/null)
            if test -n "$formatted"; and test "$formatted" != "$buffer"
                commandline -r "$formatted"
                return 0
            end
        end
    end

    function __forge_paste_and_format
        fish_clipboard_paste
        __forge_format_buffer
        commandline -f repaint
    end

    function __forge_complete_action_names
        printf '%s\n' \
            help \
            new \
            info \
            dump \
            compact \
            retry \
            agent \
            conversation \
            conversation-rename \
            clone \
            rename \
            copy \
            model \
            config-model \
            config-reload \
            reasoning-effort \
            config-reasoning-effort \
            config-commit-model \
            config-suggest-model \
            tools \
            config \
            config-edit \
            skill \
            edit \
            commit \
            commit-preview \
            suggest \
            workspace-sync \
            sync \
            workspace-init \
            workspace-status \
            workspace-info \
            index \
            doctor \
            tag \
            file
    end

    function __forge_file_tag_candidates
        command $_FORGE_BIN list file --porcelain 2>/dev/null
    end

    function __forge_pick_file_tag --argument-names query current_file
        set -l output (__forge_file_tag_candidates)
        if test -z "$output"
            return 1
        end

        set -l fzf_args --delimiter='\s\s+' --prompt='File Tag ❯ ' --with-nth='1..'
        if test -n "$query"
            set fzf_args $fzf_args --query="$query"
        end
        if test -n "$current_file"
            set -l index (__forge_find_index "$output" "$current_file" 1)
            set fzf_args $fzf_args --bind="start:pos($index)"
        end

        printf '%s\n' $output | __forge_fzf --header-lines=1 $fzf_args
    end

    function __forge_action_tag --argument-names input_text
        set input_text (string trim -- $input_text)
        if test -z "$input_text"
            set -l selected (__forge_pick_file_tag '' '')
            if test -n "$selected"
                set input_text (string trim -- $selected)
            end
        end

        if test -z "$input_text"
            return 0
        end

        if string match -rq '^@\[[^]]+\]$' -- $input_text
            set -l tag_text $input_text
        else if string match -rq '^@\[' -- $input_text
            set -l tag_text $input_text
        else
            set -l tag_text "@[$input_text]"
        end

        commandline -r "$tag_text"
        commandline -f repaint
    end

    function __forge_action_new --argument-names input_text
        set -e _FORGE_CONVERSATION_ID
        set -g _FORGE_PREVIOUS_CONVERSATION_ID ""
        set -g _FORGE_ACTIVE_AGENT forge
        if test -n "$input_text"
            set -l new_id (command $_FORGE_BIN conversation new 2>/dev/null)
            if test -n "$new_id"
                set -g _FORGE_CONVERSATION_ID $new_id
                command $_FORGE_BIN --conversation-id "$new_id" --prompt "$input_text"
            else
                command $_FORGE_BIN --prompt "$input_text"
            end
        else
            command $_FORGE_BIN banner
        end
    end

    function __forge_action_info
        if test -n "$_FORGE_CONVERSATION_ID"
            command $_FORGE_BIN info --conversation-id "$_FORGE_CONVERSATION_ID"
        else
            command $_FORGE_BIN info
        end
    end

    function __forge_action_agent --argument-names input_text
        if test -z "$input_text"
            set -l selected (__forge_pick_agent '' '')
            if test -n "$selected"
                set input_text (string split -m 1 '  ' -- $selected)[1]
            end
        end

        if test -z "$input_text"
            return 0
        end

        set -U _FORGE_ACTIVE_AGENT $input_text
    end

    function __forge_action_help
        command $_FORGE_BIN list command
    end

    function __forge_action_conversation --argument-names input_text
        if test -z "$input_text"
            set -l selected (__forge_pick_conversation)
            if test -n "$selected"
                set input_text (string split -m 1 '  ' -- $selected)[1]
            end
        end

        if test -z "$input_text"
            return 0
        end

        set -g _FORGE_PREVIOUS_CONVERSATION_ID $_FORGE_CONVERSATION_ID
        set -g _FORGE_CONVERSATION_ID $input_text
        command $_FORGE_BIN conversation show "$input_text"
        command $_FORGE_BIN conversation info "$input_text"
    end
    function __forge_action_clone --argument-names input_text
        if test -z "$input_text"
            set -l selected (__forge_pick_conversation)
            if test -n "$selected"
                set input_text (string split -m 1 '  ' -- $selected)[1]
            end
        end

        if test -z "$input_text"
            return 0
        end

        set -l clone_output (command $_FORGE_BIN conversation clone "$input_text" 2>&1)
        set -l new_id (string match -r '[a-f0-9-]{36}' -- $clone_output)
        if test (count $new_id) -gt 0
            set -U _FORGE_PREVIOUS_CONVERSATION_ID $_FORGE_CONVERSATION_ID
            set -U _FORGE_CONVERSATION_ID $new_id[1]
            command $_FORGE_BIN conversation show $_FORGE_CONVERSATION_ID
            command $_FORGE_BIN conversation info $_FORGE_CONVERSATION_ID
        else
            printf '%s\n' $clone_output
        end
    end

    function __forge_action_rename --argument-names input_text
        if test -z "$_FORGE_CONVERSATION_ID"
            return 0
        end

        if test -z "$input_text"
            read -P 'Enter new name: ' input_text
        end

        if test -n "$input_text"
            command $_FORGE_BIN conversation rename $_FORGE_CONVERSATION_ID "$input_text"
        end
    end

    function __forge_action_copy
        if test -z "$_FORGE_CONVERSATION_ID"
            return 0
        end

        set -l content (command $_FORGE_BIN conversation show --md $_FORGE_CONVERSATION_ID 2>/dev/null)
        if test -n "$content"
            printf '%s' "$content" | fish_clipboard_copy
        end
    end

    function __forge_action_commit --argument-names input_text
        if test -n "$input_text"
            command $_FORGE_BIN commit --max-diff "$_FORGE_MAX_COMMIT_DIFF" $input_text
        else
            command $_FORGE_BIN commit --max-diff "$_FORGE_MAX_COMMIT_DIFF"
        end
    end

    function __forge_action_commit_preview --argument-names input_text
        if test -n "$input_text"
            set -l commit_message (command $_FORGE_BIN commit --preview --max-diff "$_FORGE_MAX_COMMIT_DIFF" $input_text)
        else
            set -l commit_message (command $_FORGE_BIN commit --preview --max-diff "$_FORGE_MAX_COMMIT_DIFF")
        end

        if test -n "$commit_message"
            commandline -r "git commit -m $(string escape -- $commit_message)"
            commandline -f repaint
        end
    end

    function __forge_action_suggest --argument-names input_text
        if test -z "$input_text"
            return 0
        end

        set -l generated_command (command $_FORGE_BIN suggest "$input_text")
        if test -n "$generated_command"
            commandline -r "$generated_command"
            commandline -f repaint
        end
    end

    function __forge_action_tools
        set -l agent_id $_FORGE_ACTIVE_AGENT
        if test -z "$agent_id"
            set agent_id forge
        end
        command $_FORGE_BIN list tools "$agent_id"
    end

    function __forge_action_skill
        command $_FORGE_BIN list skill
    end

    function __forge_action_config
        command $_FORGE_BIN config list
    end

    function __forge_action_config_edit
        set -l editor_cmd "$FORGE_EDITOR"
        if test -z "$editor_cmd"
            set editor_cmd "$EDITOR"
        end
        if test -z "$editor_cmd"
            set editor_cmd nano
        end

        set -l config_file (command $_FORGE_BIN config path 2>/dev/null)
        if test -n "$config_file"
            command $editor_cmd $config_file
        end
    end

    function __forge_action_config_reload
        set -e -U _FORGE_SESSION_MODEL
        set -e -U _FORGE_SESSION_PROVIDER
        set -e -U _FORGE_SESSION_REASONING_EFFORT
    end

    function __forge_action_model --argument-names input_text
        if test -z "$input_text"
            set -l current_model (command $_FORGE_BIN config get model 2>/dev/null)
            set -l current_provider (command $_FORGE_BIN config get provider 2>/dev/null)
            set -l selected (__forge_pick_model 'Model ❯ ' '' $current_model $current_provider 3)
            if test -n "$selected"
                set -l fields (string split -m 3 '  ' -- $selected)
                if test (count $fields) -ge 4
                    set -U _FORGE_SESSION_MODEL (string trim -- $fields[1])
                    set -U _FORGE_SESSION_PROVIDER (string trim -- $fields[4])
                end
            end
            return 0
        end

        set -U _FORGE_SESSION_MODEL $input_text
    end

    function __forge_action_config_model --argument-names input_text
        if test -z "$input_text"
            set -l current_model (command $_FORGE_BIN config get model 2>/dev/null)
            set -l current_provider (command $_FORGE_BIN config get provider 2>/dev/null)
            set -l selected (__forge_pick_model 'Config Model ❯ ' '' $current_model $current_provider 3)
            if test -n "$selected"
                set -l fields (string split -m 3 '  ' -- $selected)
                if test (count $fields) -ge 4
                    command $_FORGE_BIN config set model (string trim -- $fields[4]) (string trim -- $fields[1])
                end
            end
            return 0
        end

        command $_FORGE_BIN config set model $input_text
    end

    function __forge_action_config_commit_model --argument-names input_text
        if test -z "$input_text"
            set -l current_commit_model (command $_FORGE_BIN config get commit 2>/dev/null | string split '\n' | tail -n 1)
            set -l current_commit_provider (command $_FORGE_BIN config get commit 2>/dev/null | string split '\n' | head -n 1)
            set -l selected (__forge_pick_model 'Commit Model ❯ ' '' $current_commit_model $current_commit_provider 4)
            if test -n "$selected"
                set -l fields (string split -m 3 '  ' -- $selected)
                if test (count $fields) -ge 4
                    command $_FORGE_BIN config set commit (string trim -- $fields[4]) (string trim -- $fields[1])
                end
            end
            return 0
        end

        command $_FORGE_BIN config set commit $input_text
    end

    function __forge_action_config_suggest_model --argument-names input_text
        if test -z "$input_text"
            set -l current_suggest_model (command $_FORGE_BIN config get suggest 2>/dev/null | string split '\n' | tail -n 1)
            set -l current_suggest_provider (command $_FORGE_BIN config get suggest 2>/dev/null | string split '\n' | head -n 1)
            set -l selected (__forge_pick_model 'Suggest Model ❯ ' '' $current_suggest_model $current_suggest_provider 4)
            if test -n "$selected"
                set -l fields (string split -m 3 '  ' -- $selected)
                if test (count $fields) -ge 4
                    command $_FORGE_BIN config set suggest (string trim -- $fields[4]) (string trim -- $fields[1])
                end
            end
            return 0
        end

        command $_FORGE_BIN config set suggest $input_text
    end

    function __forge_action_reasoning_effort --argument-names input_text
        if test -z "$input_text"
            set -l efforts none minimal low medium high xhigh max
            set -l selected (printf 'EFFORT\n%s\n' $efforts | __forge_fzf --header-lines=1 --prompt='Reasoning Effort ❯ ')
            if test -n "$selected"
                set -U _FORGE_SESSION_REASONING_EFFORT $selected
            end
            return 0
        end

        set -U _FORGE_SESSION_REASONING_EFFORT $input_text
    end

    function __forge_action_config_reasoning_effort --argument-names input_text
        if test -z "$input_text"
            set -l efforts none minimal low medium high xhigh max
            set -l current_effort (command $_FORGE_BIN config get reasoning-effort 2>/dev/null)
            set -l selected (printf 'EFFORT\n%s\n' $efforts | __forge_fzf --header-lines=1 --prompt='Config Reasoning Effort ❯ ')
            if test -n "$selected"
                command $_FORGE_BIN config set reasoning-effort $selected
            end
            return 0
        end

        command $_FORGE_BIN config set reasoning-effort $input_text
    end

    function __forge_action_conversation_rename --argument-names input_text
        if test -z "$input_text"
            set -l selected (__forge_pick_conversation)
            if test -n "$selected"
                set input_text (string split -m 1 '  ' -- $selected)[1]
            end
        end
        if test -z "$input_text"
            return 0
        end

        set -l fields (string split -m 1 ' ' -- $input_text)
        if test (count $fields) -lt 2
            command $_FORGE_BIN conversation rename $fields[1]
            return 0
        end

        command $_FORGE_BIN conversation rename $fields[1] (string join ' ' $fields[2..-1])
    end

    function __forge_action_dump --argument-names input_text
        if test -z "$_FORGE_CONVERSATION_ID"
            return 0
        end
        if test "$input_text" = html
            command $_FORGE_BIN conversation dump --html $_FORGE_CONVERSATION_ID
        else
            command $_FORGE_BIN conversation dump $_FORGE_CONVERSATION_ID
        end
    end

    function __forge_action_compact
        if test -z "$_FORGE_CONVERSATION_ID"
            return 0
        end
        command $_FORGE_BIN conversation compact $_FORGE_CONVERSATION_ID
    end

    function __forge_action_retry
        if test -z "$_FORGE_CONVERSATION_ID"
            return 0
        end
        command $_FORGE_BIN conversation retry $_FORGE_CONVERSATION_ID
    end

    function __forge_action_workspace_sync
        command $_FORGE_BIN workspace sync --init
    end

    function __forge_action_workspace_init
        command $_FORGE_BIN workspace init
    end

    function __forge_action_workspace_status
        command $_FORGE_BIN workspace status .
    end

    function __forge_action_workspace_info
        command $_FORGE_BIN workspace info .
    end

    function __forge_action_provider_login --argument-names input_text
        set input_text (string trim -- $input_text)
        if test -z "$input_text"
            set -l selected (__forge_pick_provider '' '')
            if test -n "$selected"
                set input_text (__forge_provider_id_from_text $selected)
            end
        else
            set input_text (__forge_provider_id_from_text $input_text)
        end

        if test -n "$input_text"
            command $_FORGE_BIN provider login $input_text
        end
    end

    function __forge_action_logout --argument-names input_text
        set input_text (string trim -- $input_text)
        if test -z "$input_text"
            set -l selected (__forge_pick_provider '\[yes\]' '')
            if test -n "$selected"
                set input_text (__forge_provider_id_from_text $selected)
            end
        else
            set input_text (__forge_provider_id_from_text $input_text)
        end

        if test -n "$input_text"
            command $_FORGE_BIN provider logout $input_text
        end
    end

    function __forge_action_default --argument-names user_action input_text
        if test -n "$user_action"
            set -l command_type (__forge_command_type $user_action)
            if test -z "$command_type"
                return 1
            end

            if test -z "$input_text"
                if test "$user_action" = ask
                    set user_action sage
                else if test "$user_action" = plan
                    set user_action muse
                end

                if test "$command_type" = agent
                    set -g _FORGE_ACTIVE_AGENT $user_action
                end
                return 0
            end
        end

        if test -z "$input_text"
            return 0
        end

        if test -z "$_FORGE_CONVERSATION_ID"
            set -l new_id (command $_FORGE_BIN conversation new 2>/dev/null)
            if test -n "$new_id"
                set -g _FORGE_CONVERSATION_ID $new_id
            end
        end

        if test -n "$user_action"
            set -g _FORGE_ACTIVE_AGENT $user_action
        end

        command $_FORGE_BIN --conversation-id "$_FORGE_CONVERSATION_ID" --prompt "$input_text"
    end
    function __forge_dispatch_line --argument-names line
        set -l trimmed (string trim -- $line)
        if not string match -rq '^:' -- $trimmed
            return 1
        end

        printf '\n'

        set -l raw (string replace -r '^:\s*' '' -- $trimmed)
        set -l parts (string split -m 1 ' ' -- $raw)
        set -l action $parts[1]
        set -l input_text ""
        if test (count $parts) -gt 1
            set input_text $parts[2]
        end

        switch $action
            case '' help h
                __forge_action_help
            case new n
                __forge_action_new $input_text
            case info i
                __forge_action_info
            case dump d
                __forge_action_dump $input_text
            case compact
                __forge_action_compact
            case retry r
                __forge_action_retry
            case agent a
                __forge_action_agent $input_text
            case conversation c
                __forge_action_conversation $input_text
            case config-model cm
                __forge_action_config_model $input_text
            case model m
                __forge_action_model $input_text
            case config-reload cr model-reset mr
                __forge_action_config_reload
            case reasoning-effort re
                __forge_action_reasoning_effort $input_text
            case config-reasoning-effort cre
                __forge_action_config_reasoning_effort $input_text
            case config-commit-model ccm
                __forge_action_config_commit_model $input_text
            case config-suggest-model csm
                __forge_action_config_suggest_model $input_text
            case tools t
                __forge_action_tools
            case config env e
                __forge_action_config
            case config-edit ce
                __forge_action_config_edit
            case skill
                __forge_action_skill
            case edit ed
                __forge_format_buffer
            case commit
                __forge_action_commit $input_text
            case commit-preview
                __forge_action_commit_preview $input_text
            case suggest s
                __forge_action_suggest $input_text
            case clone
                __forge_action_clone $input_text
            case rename rn
                __forge_action_rename $input_text
            case conversation-rename
                __forge_action_conversation_rename $input_text
            case copy
                __forge_action_copy
            case workspace-sync sync
                __forge_action_workspace_sync
            case workspace-init sync-init
                __forge_action_workspace_init
            case workspace-status sync-status
                __forge_action_workspace_status
            case workspace-info sync-info
                __forge_action_workspace_info
            case index
                command $_FORGE_BIN index
            case doctor
                command $_FORGE_BIN doctor
            case tag file
                __forge_action_tag $input_text
            case provider-login login provider
                __forge_action_provider_login $input_text
            case logout
                __forge_action_logout $input_text
            case '*'
                __forge_action_default "" $raw
        end
    end

    function __forge_accept_line
        set -l buffer (commandline -b)
        if __forge_dispatch_line "$buffer"
            commandline -r ""
            commandline -f repaint
            return 0
        end
        commandline -f execute
    end
    function __forge_tab_complete
        set -l buffer (commandline -b)
        set -l token (commandline -ct)

        if string match -rq '^@.*' -- $token
            set -l filter_text (string replace -r '^@' '' -- $token)
            set -l file_list (command $_FORGE_BIN list file --porcelain 2>/dev/null)
            if test -n "$file_list"
                set -l fzf_args --prompt='File ❯ ' --preview="if test -d {}; ls -la {}; else command cat {}; end" $_FORGE_PREVIEW_WINDOW
                if test -n "$filter_text"
                    set -l selected (printf '%s\n' $file_list | __forge_fzf --query="$filter_text" $fzf_args)
                else
                    set -l selected (printf '%s\n' $file_list | __forge_fzf $fzf_args)
                end
                if test -n "$selected"
                    set -l new_token "@["$selected"]"
                    commandline -t ""
                    commandline -i $new_token
                    commandline -f repaint
                    return 0
                end
            end
        end

        if string match -rq '^:\s*.*' -- $buffer
            set -l action_list (printf '%s\n' (__forge_complete_action_names))
            set -l action_token (string replace -r '^:\s*' '' -- $token)
            if test -n "$action_list"
                if test -n "$action_token"
                    set -l selected (printf '%s\n' $action_list | __forge_fzf --query="$action_token" --prompt='Forge ❯ ')
                else
                    set -l selected (printf '%s\n' $action_list | __forge_fzf --prompt='Forge ❯ ')
                end
                if test -n "$selected"
                    commandline -r ":$selected "
                    commandline -f repaint
                    return 0
                end
            end
        end

        commandline -f complete
    end

    function fish_user_key_bindings
        fish_default_key_bindings
        bind enter __forge_accept_line
        bind ctrl-j __forge_accept_line
        bind tab __forge_tab_complete
        bind ctrl-v __forge_paste_and_format
    end

    fish_user_key_bindings
    set -gx _FORGE_PLUGIN_LOADED (date +%s)
end
