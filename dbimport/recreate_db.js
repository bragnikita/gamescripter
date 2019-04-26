db.users.drop();
db.categories.drop();
db.sequences.drop();
db.permissions.drop();
db.posts.drop();
db.dictionaries.drop();

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
        meta: {},
        content_type: 'general'
    }
]);
var catRoot = db.categories.findOne({title: 'root'});
db.categories.insert([{
    key: 1,
    title: 'Main story',
    description: 'Main story #1',
    parent_id: catRoot['_id'],
    created_at: new Date(),
    creator_id: rootId,
    meta: {story_type: 'main'},
    content_type: 'story'
}]);
db.sequences.insert([
    {name: 'categories', next_val: 1},
    {name: 'scripts', next_val: 0}
]);
var story_types = [
    ['main', 'Main стори'],
    ['another', 'Другая история'],
    ['chara', 'История персонажа'],
    ['costume', 'История костюма'],
    ['event', 'Ивент'],
    ['special', 'Спешл стори']
];
var category_types = [
    ['general', 'Обычная'],
    ['episode', 'Эпизод(話)'],
    ['chapter', 'Глава(章)'],
    ['arc', 'Арка'],
    ['story', 'История']
];
var script_types = [
    ['battle', 'Бэттл'],
    ['part', 'Часть'],
    ['single', 'Сингл'],
    ['intro', 'Интро']
];

function mapDict(c, index) {
    return {
        parameter: c[0],
        title: c[1],
        index: index
    }
}

db.dictionaries.insert([
    {
        name: 'category_types',
        title: 'Category type',
        records: category_types.map(mapDict)
    },
    {
        name: 'script_types',
        title: 'Script type',
        records: script_types.map(mapDict)
    },
    {
        name: 'story_types',
        title: 'Story type',
        records: story_types.map(mapDict)
    }
]);
