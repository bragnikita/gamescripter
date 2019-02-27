db.users.insert([
    {
        username: 'admin',
        display_name: 'Admin',
        password_digest: '4cb9c8a8048fd02294477fcb1a41191a', //changeme
        notes: '',
        avatar_url: null,
        active: true,
        meta: {},
        created_at: new Date()
    },
    {
        username: 'demo',
        display_name: 'Demo',
        password_digest: '70b078e6735224a212ef4bd9c45e3f83', //tryit
        notes: '',
        avatar_url: null,
        active: true,
        created_at: new Date(),
        meta: {}
    }
]);
var rootId = db.users.findOne({username: 'admin'})['_id'];
db.categories.insert([
    {
        key: 0,
        title: 'root',
        description: '',
        parent_id: null,
        created_at: new Date(),
        creator_id: rootId,
        meta: {}
    }
]);
db.sequences.insert([
    {name: 'categories', next_val: 1},
    {name: 'scripts', next_val: 0}
]);