db.createUser(
    {
        user: 'gamescripter-api',
        pwd: 'initial_password',
        roles: [ "readWrite" , "dbAdmin" ]
    }
);