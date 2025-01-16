build:
	@echo "Please enter your API key:"
	@read -p "API Key: " api_key; \
	chmod +x create_vm_ubuntu_xrdp_flist.sh; \
	sudo ./create_vm_ubuntu_xrdp_flist.sh "$$api_key"

delete:
	sudo rm -rf ubuntu-noble
	sudo rm -rf logs
	sudo rm -rf wget-log
	sudo rm ubuntu-24.04_vm_xrdp.tar.gz