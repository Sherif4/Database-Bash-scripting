#!/bin/bash
shopt -s extglob

tableHandling(){
  clear
  select choice in Insert Update Delete "Drop Table"
  do
  case $choice in
    "Insert")
      cat .metadata_$1 | cut -d: -f1
    ;;
    "Update")

    ;;
    "Delete")

    ;;
    "Drop Table")

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