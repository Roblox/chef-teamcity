#!/usr/bin/env bash
# enable_autologin.sh
#
# Set up and enable auto-login using kcpassword

readonly SCRIPT=$0
readonly KCPASSWORD_PATH='/etc/kcpassword'
readonly CIPHER=( 7D 89 52 23 D2 BC DD EA A3 B9 1F )

usage() {
  echo "Usage: $SCRIPT -u <username> -p <password>"
}

if [ "$#" -ne 4 ]; then
  echo "ERROR! Parameter count incorrect, expect 2."
  usage
  exit 1
fi

while getopts "u:p:" opt; do
  case ${opt} in
    u) username=${OPTARG};;
    p) password=${OPTARG};;
    \?) usage
  esac
done

##
# Checks
##

# /etc/kcpassword can only be edited as root, so check that first.
if [[ $(id -u) -ne 0 ]] ; then
  echo "ERROR! Must be as root"
  exit 1
fi

# Does user exist
if ! id "${username}" &> /dev/null; then
  echo "ERROR! User '${username}' not found, has it been created?"
  exit 1
fi

# Verify password to ensure setting correctly
if ! /usr/bin/dscl /Search -authonly "${username}" "${password}" &> /dev/null; then
  echo "ERROR! Password provided not found in directory services."
  exit 1
fi

##
# Set & enable auto-login
##

# Convert to hex
password_hex_array=( $(echo -n "${password}" | xxd -p -u | sed 's/../& /g') )

# Adjust padding as necessary
if [ "${#password_hex_array[@]}" -lt 12  ]; then
  padding=$(( 12 -  ${#password_hex_array[@]} ))
elif [ "$(( ${#password_hex_array[@]} % 12 ))" -ne 0  ]; then
  padding=$(( (12 - ${#password_hex_array[@]} % 12) ))
else
  padding=12
fi  

encoded_password=""

# Loop through to XOR modulus values
for ((char=0; char < $(( ${#password_hex_array[@]} + ${padding})); char++)); do
  char_cipher=${CIPHER[$(( $char % 11 ))]}
  char_hex=${password_hex_array[$char]}
  encoded_password+=$(printf "%02X" "$(( 0x${char_cipher} ^ 0x${char_hex:-00} ))" | xxd -r -p)
done

if [ -z "${encoded_password}" ]; then
  echo "ERROR! Failed encoding password, check logs."
  exit 1
fi

# Actually set kcpassword
echo "${encoded_password}" > $KCPASSWORD_PATH

if [ $? -ne 0 ]; then
  echo "ERROR! Failed to set password, check logs."
  exit 1
fi

chown root:wheel $KCPASSWORD_PATH
chmod 0600 $KCPASSWORD_PATH

# Plist for auto-login
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser -string "${username}"
if [ $? -ne 0 ]; then
  echo "ERROR! Failed setting plist autoLoginUser."
  exit 1
fi

echo "Enabled auto login enabled '${username}'"
echo "Done."

exit 0
