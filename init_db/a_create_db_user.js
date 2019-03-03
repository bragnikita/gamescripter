var roles = [
    {role: "readWrite", db: 'gamescripter'},
    {role: "dbAdmin", db: 'gamescripter'}
];

db.getSiblingDB('test').createUser(
    {
        user: 'gamescripter-api-user',
        pwd: 'initial_password',
        roles: roles
    }
);
db.getSiblingDB('test').createUser(
    {
        user: 'dba',
        pwd: 'pass',
        roles: roles
    }
);