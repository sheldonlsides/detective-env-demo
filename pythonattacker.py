import boto3, json, time, uuid, random, os
some_random_number = str(random.randrange(100000))

# add access key to seccrets manager
secrets_manager = boto3.client('secretsmanager', region_name='us-east-2')
secret_name = 'some_super_secret-' + str(some_random_number)

response = secrets_manager.create_secret(
    Name=secret_name,
    Description='A secret we created because your account was ccompromised',
    SecretString='test'
)

print(response)