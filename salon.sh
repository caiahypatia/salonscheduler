#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Scheduler ~~~~~\n"

MAIN_MENU() {

  SERVICE_MENU

  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED -gt 0 && $SERVICE_ID_SELECTED -lt 4 ]]
  then
    CUSTOMER_INFO
  else
    MAIN_MENU
  fi
}

SERVICE_MENU() {
    #display available services
    #echo -e "\nPlease select a service 1, 2, or 3.\n"
    echo -e "1)$($PSQL "SELECT name FROM services WHERE service_id=1")"
    echo -e "2)$($PSQL "SELECT name FROM services WHERE service_id=2")"
    echo -e "3)$($PSQL "SELECT name FROM services WHERE service_id=3")\n"

}

CUSTOMER_INFO() {
  #get phone number
  echo -e "\nPlease enter your phone number.\n"

  read CUSTOMER_PHONE

  #check if repeat customer
  CUSTOMER_PHONE_CHECK=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #if NOT found
  if [[ -z $CUSTOMER_PHONE_CHECK ]]
  then
  echo -e "\nWhat is your name?\n"
  read CUSTOMER_NAME
  #enter customername and phone number into database
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  APPOINTMENT_INFO
  else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo -e "\nHi, $CUSTOMER_NAME\n"
  APPOINTMENT_INFO
  fi
}

APPOINTMENT_INFO() {
  echo -e "\nWhat time would you like for your appointment?\n"

  read SERVICE_TIME

  CUSTOMER_ID_NUMBER=$($PSQL "SELECT DISTINCT customer_id FROM customers FULL JOIN appointments USING(customer_id) WHERE phone = '$CUSTOMER_PHONE'")

  #enter all information into database
  INSERT_SERVICE_TIME=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($CUSTOMER_ID_NUMBER, '$SERVICE_TIME', $SERVICE_ID_SELECTED)")

  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  echo -e "\nI have put you down for a$SERVICE_SELECTED at $SERVICE_TIME,$CUSTOMER_NAME. "
}

MAIN_MENU
