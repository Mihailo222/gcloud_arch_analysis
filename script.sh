GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo  "This is gcloud authentication with service account. Provide path to your gcloud .json key file..."


while true; do
 read -p "Enter gcloud .json key file for service account: " key
 if [[ $key == *.json ]]; then
   gcloud auth activate-service-account --key-file $key
   echo -e "${GREEN}Authentication with user successfully accomplished.${NC}"
   break
 else
   echo -e "${RED}Error: Please enter a valid .json file path.${NC}"
 fi
done

#VM analysis
vm_analysis(){
echo -e "${YELLOW}Listing all VMs within a project: ${NC}"
gcloud compute instances list
echo -e "${YELLOW}Choose VM for memory analysis:${NC}"
read -p "Enter public IP address: " ip_a
read -p "Enter ssh user: " ssh_user
read -p "Provide private key file:" private_key
echo -e "${YELLOW}Project:$( gcloud config get-value project ). VM instance ${ip_a} - Analysis..."

echo -e "${GREEN}########################################################################################################################${NC}"
echo -e "${GREEN}Memory management:${NC}"
echo -e "${GREEN}Free memory: $( sudo ssh -i $private_key $ssh_user@$ip_a "free -h | awk 'NR==2 {print \$7}'" )${NC}"
echo -e "${GREEN}Free swap: $( sudo ssh -i $private_key $ssh_user@$ip_a "free -h | awk 'NR==3 {print \$4}'" )${NC}"

echo -e "${GREEN}########################################################################################################################${NC}"
echo -e "${GREEN}Mounted on root File System:"
echo -e "${GREEN}Free swap: $( sudo ssh -i $private_key $ssh_user@$ip_a "df -hT -x tmpfs -x devtmpfs -x vfat -x squashfs" )${NC}"

echo -e "${GREEN}########################################################################################################################${NC}"
echo -e "${GREEN}Process Management:"

echo -e "${GREEN}Top 6 CPU Killers:"
echo -e "${GREEN}Free swap: $( sudo ssh -i $private_key $ssh_user@$ip_a "ps aux | awk 'NR==1 {print}'" )${NC}"
echo -e "${GREEN}Free swap: $( sudo ssh -i $private_key $ssh_user@$ip_a "ps aux --sort=%cpu | tail -n 6" )${NC}"

echo -e "${GREEN}Top 6 Memory Killers:"
echo -e "${GREEN} $( sudo ssh -i $private_key $ssh_user@$ip_a "ps aux | awk 'NR==1 {print}'" )${NC}"
echo -e "${GREEN} $( sudo ssh -i $private_key $ssh_user@$ip_a "ps aux --sort=%mem | tail -n 6" )${NC}"

echo -e "${GREEN}########################################################################################################################${NC}"
echo -e "${GREEN}Load average and time:"
echo -e "${GREEN} $( sudo ssh -i $private_key $ssh_user@$ip_a "uptime" )${NC}"

echo -e "${GREEN}########################################################################################################################${NC}"
echo -e "${GREEN}Users that can log into system:"
echo -e "${GREEN} $( sudo ssh -i $private_key $ssh_user@$ip_a " grep -v nologin /etc/passwd | awk -F: '\$3 > 999'" )${NC}"
}

iam_analysis(){

while true;
do
  read -p "$( echo -e ${YELLOW}[REQUIRED]${NC} Please enter a projectID where user resides in: ) " projectID
  if gcloud projects describe $projectID &> /dev/null; #stdout + stderr
  then
    echo -e "${GREEN}[SUCCESS]${NC} The project $projectID was found."
    break;
  else
    echo -e "${RED}[ERROR]${NC} A project with a ${projectID} does not exist within your organization or you don't have access to it."
  fi
done
echo -e "${YELLOW}All the roles within a project:${NC}"
echo -e "${GREEN} $( gcloud projects get-iam-policy myprojectmika | grep role | awk ' {print $2}' ) ${NC}"

}





#main menu

echo -e "${YELLOW}Pick a service from a menue:${NC}"
echo "1) VM Analysis"
echo "2) IAM Analysis"
read pick

case $pick in
    1) vm_analysis ;;
    2) iam_analysis ;;
    *) echo "Not invented yet." ;;
esac







