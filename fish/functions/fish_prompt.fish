function fish_prompt
    set_color cyan
    echo (pwd)
    set_color green
    echo -n '> '
    set_color normal
end
