#!/bin/bash
shopt -s extglob

tableHandling(){
  clear
  select choice in Show Insert Update Delete "Drop Table"
  do
  case $choice in
    "Insert")
      colCount=$(cat .metadata_$1 | wc -l)
      echo $colCount
      line=""
      for ((i=0;i<$colCount;i++))
      do
        Col=$(cat .metadata_$1 | AWK -F: "NR==(($i+1)){print \$1}")
        type=$(cat .metadata_$1 | AWK -F: "NR==(($i+1)){print \$2}")
        pk=$(cat .metadata_$1 | AWK -F: "NR==(($i+1)){print \$3}")
        while true; do
        read -p "Please enter $Col: " data
        case $type in
          "Int")
            if [[ $data =~ ^[0-9]+$ ]]
            then
              if [ $pk -eq 1 ]
              then
                if [ "$(cat $1 | AWK -F: "/$data/{print \$(($i+1))}" | wc -l)" -eq 0 ]
                then
                   line+=:$data
                   break
                else
                  echo "This is primary key column, your entry is duplicate"
                fi
              else
                line+=:$data  
                  break          
              fi             
            else
              echo "This column accept numbers only"              
            fi
            
          ;;
          "Str")
            if [[ $data =~ ^[a-zA-Z]+$ ]]
            then
              if [ $pk -eq 1 ]
              then
                if [ "$(cat $1 | AWK -v IGNORECASE=1 -F: "/$data/{print \$(($i+1))}" | wc -l)" -eq 0 ]
                then
                   line+=:$data
                   break
                else
                  echo "This is primary key column, your entry is duplicate"
                fi
              else
                line+=:$data  
                  break          
              fi      
            else
              echo "This column accept letters only"            
            fi
            
          ;;
        esac
        done
      done
        echo ${line:1} >> $1
        echo "Record has been inserted successfully"
    ;;
    "Update")
      cols=$(cat .metadata_$1 | awk -F: '{if ($3==0){print $1}}')
      table=$(cat $1 | awk -F: '{print}')
      select row in $table
      do
        Rownum=$REPLY
        select column in $cols
        do
          colname=$(cat .metadata_$1 | AWK -F: '{if ($3==0){print $1}}' | AWK "NR==$REPLY")
          coltype=$(cat .metadata_$1 | AWK -F: '{if ($3==0){print $2}}' | AWK "NR==$REPLY")
          echo $coltype
          fieldnum=$(cat .metadata_$1 | AWK -F: "/$colname/{print NR}")
          old=$(awk -F: "NR==$Rownum {print \$$fieldnum}" $1)
          echo $old
          while true; do
            read -p "Enter the new value: " nvalue
            case $coltype in
              "Int")
                if [[ $nvalue =~ ^[0-9]+$ ]]
                then
                  awk -F: -v rownum="$Rownum" -v old="$old" -v nvalue="$nvalue" -v fieldnum="$fieldnum" 'BEGIN { OFS=FS } NR==rownum {gsub(old, nvalue, $fieldnum)} {print}' "$1" > temp && mv temp "$1"
                  rm -f temp
                  echo "Value has been updated successfully!"
                  break
                else
                  echo "This column accept numbers only"              
                fi
                ;;
              "Str")
                if [[ $nvalue =~ ^[a-zA-Z]+$ ]]
                then
                  awk -F: -v rownum="$Rownum" -v old="$old" -v nvalue="$nvalue" -v fieldnum="$fieldnum" 'BEGIN { OFS=FS } NR==rownum {gsub(old, nvalue, $fieldnum)} {print}' "$1" > temp && mv temp "$1"
                  rm -f temp
                  echo "Value has been updated successfully!"
                  break
                else
                  echo "This column accept letters only"            
                fi
                ;;
              esac
          done
        done
      done
    ;;
     "Show")
      if [ -e "$1" ] && [ -e ".metadata_$1" ]
      then
      # Extract column names from metadata
      column_names=$(cat .metadata_ha | awk -F: '{printf $1 " "}' && echo)

      # Display column names on the same line
      echo -n "$column_names" && echo

      # Display data with corresponding column names
      sed 's/:/ /g' "$1" && echo
      else
        echo "Table does not exist."
      fi
      ;;
        "Delete")
        read -p "Enter Row_ID to Delete: " rowID
        if [ -e "$1" ]&&[ -e ".metadata_$1" ]
        then
          sed -i "${rowID}d" "$1"
          echo "Record $rowID Deleted Successfully from $1"
        else
          echo "Table does not exist."
        fi
        ;;
        "Drop Table")
            if [ -e "$1" ] && [ -e ".metadata_$1" ]
            then
              rm "$1" ".metadata_$1"
              echo "$1 Table Dropped Successfully :)"
            else
              echo "Table does not exist."
            fi
            break
        ;;
      esac
      done

    }

displayTBOptions()
{
  select option in CreateTB ListTB
  do
    case $option in
    "CreateTB")
      read -p "Please Enter Table Name: " TBName
      read -p "Please Enter Columns Number: " colNumber
      
      # Create a hidden file for metadata
      touch .metadata_$TBName

      for ((i=0;i<$colNumber;i++))
      do
        line=""
        read -p "Enter Column Name: " ColName
        if [ -z $ColName ]
        then
        echo "please enter a valid number"
        else
        line+=$ColName
        select type in Integer String
      do
              case $type in
              "String")
                line+=:Str
                break
              ;;
              "Integer")
                line+=:Int
                break
              ;;
              esac
        
      done
      echo "Primary key?"
      select PK in Yes No
      do
        case $PK in
          "Yes")
            line+=:1
            break
            ;;
          "No")
            line+=:0
            break
            ;;
        esac
      done
      echo $line >> .metadata_$TBName
        fi
        done
      # Create an empty file for data
      touch $TBName
      clear
      echo "$TBName Table Created Successfully :)"
      ;;



    "ListTB")
      # List available tables
      tables=$(ls -p | grep -v /)
      tabCount=$(ls -p | grep -v / | wc -l)
      select table in $tables
      do
      if [[ $REPLY =~ ^[0-9]+$ ]] && [[ $REPLY -le $tabCount ]];
      then
        selectedTab=$(ls -p | grep -v / | sed -n "${REPLY}p")
        tableHandling $selectedTab
        else
        echo Invalid input
        fi
      done
      ;;
    esac
  done
}

valid_dbname() {
  [[ -n "$1" && "$1" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]
}

select option in CreateDB ConnectDB
do
  case $option in 
    "CreateDB")
      read -p "Please Enter Database Name: " DBName

    if valid_dbname "$DBName"
      then
      if [ ! -e "$DBName" ]
      then
        mkdir ./"$DBName"
        echo "Database created successfully :)"
      else
        echo "Database already exists."
      fi
    else
      echo -e "Invalid database name.\nPlease avoid special characters and ensure it's not empty."
    fi
    ;;

    "ConnectDB")
      read -p "Please Enter Database Name: " ConnDB
      if [ -z "$ConnDB" ]
      then
        echo "Input is Empty"
        continue
      fi
      if [ -e "$ConnDB" ]
      then
        cd "$ConnDB"
        clear
        echo "$ConnDB Database Connected Successfully :)"
        displayTBOptions
      else
        echo "Database does not exist."
      fi
      ;;
  esac
done