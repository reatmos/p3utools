#!/bin/bash
echo Wait..
if [ -f "py3.txt" ]; then
	rm "py3.txt"
fi
SORT_PATH=$(unalias sort &> /dev/null; command -v sort) || display_error "SORT ERROR" || return 1
versions=$(git ls-remote -t https://github.com/python/cpython | awk -F/ '{ print $NF }' | $SORT_PATH)
for version in $versions; do
	if [[ "${version:0:2}" == "v3" ]]; then
		echo "$version"
	fi
done | sort -V > py3.txt
grep -v "a" py3.txt > temp && mv temp py3.txt
grep -v "b" py3.txt > temp && mv temp py3.txt
grep -v "r" py3.txt > temp && mv temp py3.txt
grep -v "{" py3.txt > temp && mv temp py3.txt
pyl=$(tail -1 py3.txt)
echo "####################"
printf "Latest : "
echo "${pyl:1:8}"
rm "py3.txt"
printf "Current : "
pyv=$(python3 --version)
echo "${pyv:7:8}"
if [[ "${pyv:7:8}" == "${pyl:1:8}" ]]; then
	echo "Python3 is Latest"
else
	echo "Python3 is Updatable"
	numch="${pyl:3:2}"
	echo "--------------------"
	read -p "Do you want to Check list of installed Python? 1.Yes 2. No : " cip
	if [[ "$cip" == "1" ]]; then
		for((i=6;i<="$numch";i++))
		do
			pyil=$(dpkg-query -W --showformat='${Status}\n' python3."$i" 2>&1 | grep "install ok installed")
			if [[ ! "$pyil" == "" ]]; then
				echo "python 3.$i is installed"
				pyiv="$i"
			fi
		done
		read -p "Change to python3.$pyiv? (Priority is 1) 1. Yes 2. No : " upp
		if [[ "$upp" == "1" ]]; then
			sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3."$pyiv" 1
			sudo update-alternatives --set python3 /usr/bin/python3."$pyiv"
			echo "Finish"
			printf "Change to "
			python3 --version
		fi
	fi
	read -p "Do you want to Install Latest? 1. Yes 2. No : " inp
	if [[ "$inp" == "1" ]]; then
		sudo add-apt-repository ppa:deadsnakes/ppa
		sudo apt update
		sudo apt install -y python3."$numch"
		sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3."$numch" 1
		sudo update-alternatives --set python3 /usr/bin/python3."$numch"
		echo "Finish"
		printf "Update to "
		python3 --version
	fi
fi
echo "####################"
:<<'END'
	if [[ "${pyv:9:2}" == "8." ]]; then
		echo "python3.8"
	elif [[ "${pyv:9:2}" == "9." ]]; then
		echo "python3.9"
	elif [[ "${pyv:9:2}" == "10" ]]; then
		echo "python3.10"
	elif [[ "${pyv:9:2}" == "11" ]]; then
		echo "python3.11"
	else
		echo "${pyv:9:2}"
	fi
END
