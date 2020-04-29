
## creat .json file and encrypt ##
# crypt.py --encrypt /Volumes/Storage/Beiwe/ted_bpd.json  --output-file /Volumes/Storage/Beiwe/ted_bpd.enc

## now in iPython ##
import mano 
Keyring = mano.keyring(deployment='beiwe.pennlinc', #entities in the .json file
	keyring_file='/Volumes/Storage/Beiwe/ted_bpd.enc', #encrypted loggin credentials
	passphrase='peNNLinC_2020') #this password needs to match the one used in the encryption process above

import logging
import mano.sync as msync
logging.basicConfig(level=logging.INFO)

output_folder = '/Volumes/Storage/Beiwe/'
num_subj = len(list(mano.studies(Keyring)))
for i, study in enumerate(mano.studies(Keyring), start=1):
	study_name,study_id = study
	print(i,"/",num_subj,":",study_name) #help track progress
	for user_id in mano.users(Keyring, study_id):
		print(user_id) #usually one id in each study
		if os.path.exists(os.path.join(output_folder,user_id)):
			print(user_id,'exists') #skip downloading if already exists
		else:
			print(user_id,'downloading')
			zf = msync.download(Keyring, study_id, user_id)
			zf.extractall(output_folder)
			print(user_id,'completed')