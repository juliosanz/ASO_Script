path=/home/julio
patt=".*/(.*)$"
[[ $path =~ $patt ]]
echo "${BASH_REMATCH[1]}"
