#!/bin/bash
shopt -s extglob

tableHandling(){
  clear
  select choice in Show Insert Update Delete "Drop Table" "Back to Main Menu"
  do
  case $choice in
    "Insert")
    clear
      colCount=$(cat .metadata_$1 | wc -l)
      line=""
      for ((i=0;i<$colCount;i++))
      do
        Col=$(cat .metadata_$1 | awk -F: "NR==(($i+1)){print \$1}")
        type=$(cat .metadata_$1 | awk -F: "NR==(($i+1)){print \$2}")
        pk=$(cat .metadata_$1 | awk -F: "NR==(($i+1)){print \$3}")
        while true; do
        read -p "Please enter $Col: " data
        case $type in
          "Int")
            if [[ $data =~ ^[0-9]+$ ]]
            then
              if [ $pk -eq 1 ]
              then
                if [ "$(cat $1 | awk -F: "/$data/{print \$(($i+1))}" | wc -l)" -eq 0 ]
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
            if [[ $data =~ ^[a-zA-Z\.@]+$ ]]
            then
              if [ $pk -eq 1 ]
              then
                if [ "$(cat $1 | awk -v IGNORECASE=1 -F: "/$data/{print \$(($i+1))}" | wc -l)" -eq 0 ]
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
        read -p "Press Enter to continue..."
    ;;
    "Update")
      clear
      cols=$(cat .metadata_$1 | awk -F: '{if ($3==0){print $1}}')
      table=$(cat $1 | awk -F: '{print}')
      records=$(cat $1 | awk -F: '{print}' | wc -l)
      rep=$(cat .metadata_$1 | awk -F: '{if ($3==0){print $1}}' | wc -l)
      select row in $table
      do
        if [ $REPLY -le $records ];
        then
        Rownum=$REPLY
        select column in $cols Back
        do
        
          case $column in
          "Back")
            read -p "Press Enter to continue..."
            return
          ;;
          *)
          if [ $REPLY -le $rep ];
          then  
          colname=$(cat .metadata_$1 | awk -F: '{if ($3==0){print $1}}' | awk "NR==$REPLY")
          coltype=$(cat .metadata_$1 | awk -F: '{if ($3==0){print $2}}' | awk "NR==$REPLY")
          fieldnum=$(cat .metadata_$1 | awk -F: "/$colname/{print NR}")
          old=$(awk -F: "NR==$Rownum {print \$$fieldnum}" $1)
          clear
          echo The old value is: $old
          while true; do
            read -p "Enter the new value: " nvalue
            case $coltype in
              "Int")
                if [[ $nvalue =~ ^[0-9]+$ ]]
                then
                  awk -F: -v rownum="$Rownum" -v old="$old" -v nvalue="$nvalue" -v fieldnum="$fieldnum" 'BEGIN { OFS=FS } NR==rownum {gsub(old, nvalue, $fieldnum)} {print}' "$1" > temp && mv temp "$1"
                  rm -f temp
                  clear
                  echo "Value has been updated successfully!"
                  break
                else
                  echo "This column accept numbers only"              
                fi
                ;;
              "Str")
                if [[ $nvalue =~ ^[a-zA-Z\.@]+$ ]]
                then
                  awk -F: -v rownum="$Rownum" -v old="$old" -v nvalue="$nvalue" -v fieldnum="$fieldnum" 'BEGIN { OFS=FS } NR==rownum {gsub(old, nvalue, $fieldnum)} {print}' "$1" > temp && mv temp "$1"
                  rm -f temp
                  clear
                  echo "Value has been updated successfully!"
                  break
                else
                  echo "This column accept letters only"            
                fi
                ;;
              esac
          done
          else
          echo "Please enter a valid input"
          fi
          ;;
          esac
        done
        else
          echo "Please enter a valid input"
          fi
      done
    ;;
     "Show")
     if [ -e "$1" ] && [ -e ".metadata_$1" ]
      then
        cols=$(cat .metadata_$1 | awk -F: '{print $1}')
        echo "Which columns do you want to see?"
        select selection in "*" $cols
        do
        rep=$(cat .metadata_$1 | awk -F: '{print $1}' | wc -l)
        if [ $REPLY -eq 1  ];
        then   
          # Extract column names from metadata
          echo
          column_names=$(cat .metadata_$1 | awk -F: '{printf $1 " | "}' && echo)
          # Display column names on the same line
          echo -n "$column_names" && echo
          echo -------------------

          # Display data with corresponding column names
          sed 's/:/ /g' "$1" && echo
          break
          elif [ $REPLY -le $((rep + 1)) ];
          then
             echo
            cat .metadata_$1 | awk -F: "NR==(($REPLY - 1)){printf \$1}" && echo
            echo ------------------
            cat $1 | awk -F: "{print \$(($REPLY - 1))}" && echo
            break
          else
            echo "Please enter a valid entry"
            break
            fi
      done
      else
        echo "Table does not exist."
      fi
      read -p "Press Enter to continue..."
      clear
      ;;
        "Delete")
       if [ -e "$1" ]&&[ -e ".metadata_$1" ]
        then
         table=$(cat $1 | awk -F: '{print}')
        select rec in $table
        do
          sed -i "${REPLY}d" "$1"
          echo "Record $REPLY Deleted Successfully from $1"
          break
          done
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
        "Back to Main Menu")
        read -p "Press Enter to continue..."
        clear
        return
        ;;
      esac
      done

    }

displayTBOptions()
{
  select option in "Create Table" "List Tables" "Back to Main Menu"
  do
    case $option in
    "Create Table")
    clear
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
      read -p "Press Enter to continue..."
      ;;

    "List Tables")
    clear
  # List available tables
  tables=$(ls -p | grep -v /)
  tabCount=$(ls -p | grep -v / | wc -l)
  select table in $tables "Back to Main Menu.."
  do
    case $table in
      "Back to Main Menu..")
      read -p "Press Enter to continue..."
      cd ..
      clear
        return
        ;;
      *)
        if [[ $REPLY =~ ^[0-9]+$ ]] && [[ $REPLY -le $tabCount ]];
        then
          selectedTab=$(ls -p | grep -v / | sed -n "${REPLY}p")
          tableHandling $selectedTab
        else
          echo Invalid input
        fi
        clear
        ;;
    esac
  done
  ;;
      "Back to Main Menu")
      cd ..
      read -p "Press Enter to continue..."
      clear
        return
        ;;
    esac
  done
}

valid_dbname() {
  [[ -n "$1" && "$1" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]
}

clear
echo "*******************************************************"
echo "******************* DBMS Engine 🛢  ********************"
echo "*******************************************************"
PS3="Enter Value# "
select option in "🆕 Create Database" "📋 List Databases" "🔗 Connect Database" "🗑️  Drop Database" "❗Developers Info" "⛔ Exit"
do
  case $option in 
    "🆕 Create Database")
    clear
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
    read -p "Press Enter to continue..."
    clear
    ;;

    "🔗 Connect Database")
    clear
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
      "📋 List Databases")
      clear
        #list available databases
        dbs=$(ls -F | grep / | sed 's#/$##')
        dbCount=$(echo "$dbs" | wc -w)
        select db in $dbs "Back to Main Menu"
        do
            case $db in
                "Back to Main Menu")
                read -p "Press Enter to continue..."
                clear
                    break
                ;;
                *)
                if [[ $REPLY =~ ^[0-9]+$ ]] && [[ $REPLY -le $dbCount ]];
                then
                    selectedDB=$(echo "$dbs" | sed -n "${REPLY}p")
                    echo "Selected Database: $selectedDB"
                    cd "$selectedDB"
                    clear
                    displayTBOptions
                else
                echo Invalid input
                fi
                ;;
            esac
        done
      ;;

      "🗑️  Drop Database")
            dbs=$(ls -F | grep / | sed 's#/$##')
            dbCount=$(echo "$dbs" | wc -w)

            if [ $dbCount -eq 0 ]
            then
              echo "NO Databases Available to Drop."
              read -p "Press Enter to continue..."
            else
              select dropDB in $dbs "Back to Menu"
              do
                case $dropDB in
                  "Back to Menu")
                    read -p "Press Enter to continue..."
                    clear
                    break
                  ;;
                  *)
                    if [ -n "$dropDB" ]
                    then
                      rm -r "$dropDB"
                      echo "Database $dropDB Dropped Successfully :)"
                      read -p "Press Enter to continue..."
                      clear
                      break
                    else
                      echo "Invalid input. Please select a valid database."
                    fi
                  ;;
                esac
              done
            fi
            clear
            ;;
      "❗Developers Info")
            clear
            echo "*******************************************************"
            echo "************(: Welcome Our Developers 💻:)************"
            echo "*******************************************************"
            echo "DBMS Engine Developers:"
            echo "***********************************"
            echo "1. Sherif Ashraf - Data Engineer"
            echo "   Email: dr.sherif.ashraf4@gmail.com"
            echo "***********************************"
            echo "2. Hassan Hosny - Data Engineer"
            echo "   Email: hassanhosny404@gmail.com"
            read -p "Press Enter to continue..."
            clear
            ;;
      "⛔ Exit")
      clear
      echo
      echo
      #echo -e "\e[6;1mWe Hope that You have Enjoyed Our DBMS.\e[0m"
      #echo -e "\e[6;1m             BYE BYE...! 😊            \e[0m"
      cowsay -f turtle -W 80 "We Hope that You have Enjoyed Our DBMS.
      BYE BYE...! 😊"
      echo
      echo
      echo
        exit
      ;;
      *)
      echo "Invalid option. Please select a valid option."
      clear
      ;;
  esac
done
