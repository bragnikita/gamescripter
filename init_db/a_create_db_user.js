db.createUser(
    {
        user: 'gamescripter-api-user',
        pwd: 'initial_password',
        roles: [ "readWrite", "dbAdmin" ]
    }
);
db.getSiblingDB('test').createUser(
    {
        user: 'dba',
        pwd: 'pass',
        roles: [ { role: "dbAdmin", db: 'gamescripter'},
            { role: "readWrite", db: 'gamescripter'}
            ]
    }
);