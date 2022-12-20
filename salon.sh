#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n\n~~~ Welcome to Juan's Salon ~~~\n"
  
MAIN_MENU() {
  echo -e "These are the services we can offer for you.\n"

  SERVICES_LIST=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "\nWhat service would you like to book? Enter the corresponding number."
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nInvalid input.\n"
    MAIN_MENU
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
      echo -e "\nInvalid input.\n"
      MAIN_MENU
    else

      echo -e "\nYou have selected a"${SERVICE_NAME,,}". Please enter your phone number."
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nPlease enter your name."
        read CUSTOMER_NAME
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        echo -e "\nHi $CUSTOMER_NAME. You can book from 09:00 am to 04:30 pm.\nAt what time would you like your appointment?"
        APPOINT "$CUSTOMER_NAME" $CUSTOMER_ID "$SERVICE_NAME" $SERVICE_ID_SELECTED
      else
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        echo -e "\nWelcome back"$CUSTOMER_NAME". You can book from 09:00 am to 04:30 pm.\nAt what time would you like your appointment?"
        APPOINT "$CUSTOMER_NAME" $CUSTOMER_ID "$SERVICE_NAME" $SERVICE_ID_SELECTED
      fi
    fi
  fi
}

APPOINT() {
  CUSTOMER_NAME=$1
  CUSTOMER_ID=$2
  SERVICE_NAME=$3
  SERVICE_ID=$4

  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")
  echo -e "\nThanks for using our services!"
  echo I have put you down for a "$SERVICE_NAME" at $SERVICE_TIME, "$CUSTOMER_NAME".
}

MAIN_MENU
