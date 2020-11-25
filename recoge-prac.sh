for dir in $1/*
do
	patt=".*/(.*)$"
	[[ $dir =~ $patt ]]
	name=$(echo "${BASH_REMATCH[1]}")
	cp $dir/prac.sh $2/$name.sh
done
