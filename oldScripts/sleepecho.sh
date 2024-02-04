cd `dirname $0`

echo sleepecho $@
sleep $1
echo $2

read -p "Hit enter: "
