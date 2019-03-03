print('---- Creating user "' + database + '" for database "' + database + '" with initial password "' + password + '" ---');
var roles = [
    {role: "readWrite", db: database},
    {role: "dbAdmin", db: database}
];

db.getSiblingDB(database).createUser(
    {
        user: database,
        pwd: password,
        roles: roles
    }
);