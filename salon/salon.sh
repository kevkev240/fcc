#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  # print all services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id") 
  echo "$SERVICES" | while read SERIVCE_ID BAR NAME
  do
    echo "$SERIVCE_ID) $NAME"
  done
  
  # validate user input for service wanted
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a number! What would you like today?"
  else
    SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_SELECTED ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # ask for customer info
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then 
        # insert into customers
        echo -e "\nI don't have a record for that phone number, What is your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo -e "\nWhat time would you like to cut, $(echo $CUSTOMER_NAME | sed -r 's/ *$|^ *//g')?"
      read SERVICE_TIME
      # insert appointment info
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/ *$|^ *//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/ *$|^ *//g')."
    fi
  fi
}

MAIN_MENU
