cd `dirname $0`

arr=()
for i in {1..5}
do
    tid=$(ts -L "S$i" sleep 3)
    arr+=("${tid}")
done



for t in "${arr[@]}"; do
  if [[  "$FIRST_TASK_RUNED" != "" ]];then
    echo "task $t put first"
    ts -u $t
  else
    echo "first task is not Runned"
  fi

  echo wait $t
  ts -w $t
  ts -r $t
  FIRST_TASK_RUNED="TRUE"
done



# arr=()
# for i in {1..10}
# do
#     tid=$(ts -L "S$i" sleep 3)
#     arr+=("${tid}")
# done
#
# for t in "${arr[@]}"; do
#   echo wait $t
#   ts -w $t
#   ts -r $t
# done

#read -p "Hit enter: "
