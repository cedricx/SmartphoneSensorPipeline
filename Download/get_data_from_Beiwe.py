
## creat .json file and encrypt ##
# crypt.py --encrypt /Volumes/Storage/Beiwe/ted_bpd.json  --output-file /Volumes/Storage/Beiwe/ted_bpd.enc

## now in iPython ##
import mano
deployment = 'beiwe.pennlinc'
#keyring_file = '/Volumes/Storage/Beiwe/ted_bpd.enc'
keyring_file = '/storage/xia_mobile/beiwe_data/ted_bpd.enc'
passphrase = 'peNNLinC_2020'
Keyring = mano.keyring(deployment=deployment, #entities in the .json file
	keyring_file=keyring_file, #encrypted loggin credentials
	passphrase=passphrase) #this password needs to match the one used in the encryption process above

import os
import logging
import mano.sync as msync
logging.basicConfig(level=logging.INFO)

#output_folder = '/Volumes/Storage/Beiwe/'
output_folder = '/storage/xia_mobile/beiwe_data/raw_data'
num_subj = len(list(mano.studies(Keyring)))
for i, study in enumerate(mano.studies(Keyring), start=1):
		study_name,study_id = study
		study_name = str(study_name)
		study_id = str(study_id)
		print(i,"/",num_subj,":",study_name) #help track progress
		for user_id in mano.users(Keyring, study_id):
			user_id = str(user_id)
			print(user_id) #usually one id in each study
			if os.path.exists(os.path.join(output_folder,user_id)):
				print(user_id,'exists') #skip downloading if already exists
			else:
				print(user_id,'downloading')
				zf = msync.download(Keyring, study_id, user_id)
				zf.extractall(output_folder)
				print(user_id,'completed')