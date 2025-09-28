// MongoDB CDC Demo Database Initialization
// This script sets up a demo database with sample collections for CDC testing

// Switch to the demo database
db = db.getSiblingDB('cdc_demo');

// Create a sample users collection
db.users.insertMany([
    {
        _id: ObjectId(),
        username: 'john_doe',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: new Date(),
        updatedAt: new Date()
    },
    {
        _id: ObjectId(),
        username: 'jane_smith',
        email: 'jane@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        createdAt: new Date(),
        updatedAt: new Date()
    },
    {
        _id: ObjectId(),
        username: 'bob_wilson',
        email: 'bob@example.com',
        firstName: 'Bob',
        lastName: 'Wilson',
        createdAt: new Date(),
        updatedAt: new Date()
    }
]);

// Create a sample posts collection
db.posts.insertMany([
    {
        _id: ObjectId(),
        userId: db.users.findOne({username: 'john_doe'})._id,
        title: 'My First Post',
        content: 'This is my first blog post!',
        status: 'published',
        tags: ['blog', 'first'],
        createdAt: new Date(),
        updatedAt: new Date()
    },
    {
        _id: ObjectId(),
        userId: db.users.findOne({username: 'jane_smith'})._id,
        title: 'Learning MongoDB',
        content: 'MongoDB is a powerful NoSQL database.',
        status: 'published',
        tags: ['mongodb', 'database'],
        createdAt: new Date(),
        updatedAt: new Date()
    },
    {
        _id: ObjectId(),
        userId: db.users.findOne({username: 'john_doe'})._id,
        title: 'Draft Post',
        content: 'This is a draft post.',
        status: 'draft',
        tags: ['draft'],
        createdAt: new Date(),
        updatedAt: new Date()
    }
]);

// Create a sample orders collection
db.orders.insertMany([
    {
        _id: ObjectId(),
        userId: db.users.findOne({username: 'john_doe'})._id,
        items: [
            {
                productId: ObjectId(),
                productName: 'Laptop',
                quantity: 1,
                price: 999.99
            }
        ],
        total: 999.99,
        status: 'completed',
        shippingAddress: {
            street: '123 Main St',
            city: 'New York',
            state: 'NY',
            zipCode: '10001'
        },
        createdAt: new Date(),
        updatedAt: new Date()
    },
    {
        _id: ObjectId(),
        userId: db.users.findOne({username: 'jane_smith'})._id,
        items: [
            {
                productId: ObjectId(),
                productName: 'Mouse',
                quantity: 2,
                price: 29.99
            }
        ],
        total: 59.98,
        status: 'pending',
        shippingAddress: {
            street: '456 Oak Ave',
            city: 'Los Angeles',
            state: 'CA',
            zipCode: '90210'
        },
        createdAt: new Date(),
        updatedAt: new Date()
    },
    {
        _id: ObjectId(),
        userId: db.users.findOne({username: 'bob_wilson'})._id,
        items: [
            {
                productId: ObjectId(),
                productName: 'Keyboard',
                quantity: 1,
                price: 79.99
            }
        ],
        total: 79.99,
        status: 'shipped',
        shippingAddress: {
            street: '789 Pine St',
            city: 'Chicago',
            state: 'IL',
            zipCode: '60601'
        },
        createdAt: new Date(),
        updatedAt: new Date()
    }
]);

// Create indexes for better performance
db.users.createIndex({ username: 1 }, { unique: true });
db.users.createIndex({ email: 1 }, { unique: true });
db.posts.createIndex({ userId: 1 });
db.posts.createIndex({ status: 1 });
db.posts.createIndex({ createdAt: -1 });
db.orders.createIndex({ userId: 1 });
db.orders.createIndex({ status: 1 });
db.orders.createIndex({ createdAt: -1 });

// Show the created collections
print('Created collections:');
db.getCollectionNames().forEach(function(collection) {
    print('  - ' + collection + ': ' + db[collection].countDocuments() + ' documents');
});

print('MongoDB CDC demo database initialized successfully!');
