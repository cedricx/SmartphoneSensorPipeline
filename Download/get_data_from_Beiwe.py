
crypt.py --encrypt /Volumes/Storage/Beiwe/ted_bpd.json  --output-file /Volumes/Storage/Beiwe/ted_bpd.enc

import mano 
Keyring = mano.keyring(deployment='beiwe.pennlinc',
	keyring_file='/Volumes/Storage/Beiwe/ted_bpd.enc',
	passphrase='peNNLinC_2020')

for study in mano.studies(Keyring): 
     print(study)

import logging
import mano.sync as msync
logging.basicConfig(level=logging.INFO)

output_folder = '/Volumes/Storage/Beiwe/'

for study in mano.studies(Keyring):
	_,study_id = study
	print(study_id)
	for user_id in mano.users(Keyring, study_id):
		print(user_id)
		if os.path.exists(os.path.join(output_folder,user_id)):
			print(user_id,'exists')
		else:
			print(user_id,'downloading')
			zf = msync.download(Keyring, study_id, user_id)
			zf.extractall(output_folder)
			print(user_id,'completed')