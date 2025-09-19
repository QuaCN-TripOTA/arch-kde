if status is-interactive
	fastfetch
end

set -g fish_greeting
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -gx PATH $PATH /home/licons/.dotnet/tools
