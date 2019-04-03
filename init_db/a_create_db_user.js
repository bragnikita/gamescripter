// dev user

var roles = [
    {role: "readWrite", db: 'gamescripter'},
    {role: "dbAdmin", db: 'gamescripter'}
];

db.getSiblingDB('gamescripter').createUser(
    {
        user: 'gamescripter-api-user',
        pwd: 'initial_password',
        roles: roles
    }
);

// test user
roles = [
    {role: "readWrite", db: 'gamescripter-test'},
    {role: "dbAdmin", db: 'gamescripter-test'}
];

db.getSiblingDB('gamescripter-test').createUser(
    {
        user: 'gamescripter-test',
        pwd: 'password',
        roles: roles
    }
);


// db.getSiblingDB('test').createUser(
//     {
//         user: 'dba',
//         pwd: 'pass',
//         roles: roles
//     }
// );