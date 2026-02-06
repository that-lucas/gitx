function __gitx_print_section --description 'Print a named section with 4-space-indented items'
    if test (count $argv) -lt 1
        return 1
    end

    set -l title $argv[1]
    set -e argv[1]

    # Skip printing sections with no items for cleaner output
    if test (count $argv) -eq 0
        return 0
    end
    
    # For very technical sections, just show count, not details
    set -l hide_details 0
    if string match -q -r -i "would run|ran|output" -- $title
        set hide_details 1
    end
    
    # Skip individual items that are just file paths or technical details
    set -l filtered_items
    for item in $argv
        # Skip items that look like "File: /path", "Contents:", or are just whitespace
        if string match -q -r "^\s*(File:|Contents:)\s*\$" -- $item
            continue
        end
        # Skip items that start with these patterns
        if string match -q "File: *" -- $item
            continue
        end
        if string match -q "Contents:" -- $item
            continue
        end
        set filtered_items $filtered_items $item
    end
    
    # If all items were filtered out, skip the section
    if test (count $filtered_items) -eq 0
        return 0
    end

    # Dim the title for a cleaner look
    set_color brblack
    echo -n "$title: "
    set_color normal
    
    # Determine color based on title/context
    set -l item_color normal
    if string match -q -r -i "error|fail|remove|untrack" -- $title
        set item_color red
    else if string match -q -r -i "success|track|stage|commit" -- $title
        set item_color green
    else if string match -q -r -i "would|dry|resolve" -- $title
        set item_color cyan
    end

    # For technical sections, just show count
    if test $hide_details -eq 1
        set_color $item_color
        printf "%d command" (count $filtered_items)
        if test (count $filtered_items) -ne 1
            echo -n "s"
        end
        echo " executed"
        set_color normal
        echo
        return 0
    end

    # Print items on the same line if few, otherwise show count and list
    if test (count $filtered_items) -le 3
        set_color $item_color
        echo (string join ", " $filtered_items)
        set_color normal
    else
        set_color $item_color
        echo (count $filtered_items)
        set_color normal
        # Only show first 3 items to keep output clean
        set -l show_count (math "min("(count $filtered_items)", 3)")
        for i in (seq 1 $show_count)
            set_color brblack
            echo -n "  • "
            set_color $item_color
            echo "$filtered_items[$i]"
            set_color normal
        end
        # Show ellipsis if there are more items
        if test (count $filtered_items) -gt 3
            set_color brblack
            printf "  ... and %d more\n" (math (count $filtered_items)" - 3")
            set_color normal
        end
    end
    echo
end
